"""Check the Lua skill-actor core against the game's own code, bit for bit.

`native_image.py` maps NSUNSC.exe; this builds the few objects the action
classes read (a skill object's motion state, an action with its float
parameters, a target in the object map, the update rate) and calls the game's
routines on random inputs. The same inputs go through
`lua/storm_fx/core/cl_skill_actor.lua` of the addon; every float the routine writes must
come out identical.

Checked: the random spread, the shared action init, the ARROW, ELEVATOR and
SINCURVE inits and updates over several ticks (gravity, target guidance, bank
roll, orientation), the CRAWLER init / update where the stage query finds
nothing, and the N_WAY_HORIZONTAL and RANDOM_CREATION shot handlers.
Not checked here: anything that needs the stage's collision (CRAWLER ground
snap, BOUNDBALL), and the two character-specific branches of the guidance.

  python verify_skill_actor_native.py [--cases 400]
"""

from __future__ import annotations

import argparse
import ctypes
import json
import random
import struct
import sys
from pathlib import Path

import numpy as np

from native_image import NativeImage

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from lupa import LuaRuntime  # noqa: E402
from addon_lua import load_core  # noqa: E402

SLOTS = ['Amplitude_x', 'Amplitude_y', 'Amplitude_z', 'BankRollMax', 'BankSpring', 'BankStrong', 'Frequency_x',
         'Frequency_y', 'Frequency_z', 'Friction', 'Gravity', 'Inductivity', 'RandomDirection', 'RandomRoll',
         'Restitution', 'ViewingAngle', 'Velocity', 'VelocityRandomize', 'Rotate_x']      # table 0x142060bd0
INVALID_ID = 0x141b77f2c
MANAGER, OBJECTS, OWNERS, CHARACTERS = 0x1421d7498, 0x1421d7570, 0x1421d7508, 0x1421d74a0
RATE_HOLDER, STAGE, IDENTITY = 0x149709518, 0x142335cd8, 0x149707f10
TARGET_ID = 7


def f32(value: float) -> float:
    with np.errstate(over='ignore', invalid='ignore'):
        return float(np.float32(value))


class Harness:
    def __init__(self):
        self.image = image = NativeImage()
        ucrt = ctypes.CDLL('ucrtbase')
        for name, kind in (('sinf', ctypes.c_float), ('cosf', ctypes.c_float), ('acos', ctypes.c_double), ('sin', ctypes.c_double)):
            function = getattr(ucrt, name)
            function.restype, function.argtypes = kind, [kind]
        self.lua = lua = LuaRuntime(unpack_returned_tuples=True)
        self.A = load_core(lua, 'skill_actor')
        self.M = load_core(lua, 'anm_matrix')
        self.S = load_core(lua, 'skill_shot')
        # A Python callable handed to Lua as a bare argument is wrapped in a fresh
        # proxy on every call; lupa 2.8 / Lua 5.5 was seen reusing a proxy the
        # collector had already finalised, and calling it then returns its own
        # argument. Each callable is therefore held by one Lua closure for good.
        hold = lua.eval('function(callable) return function(...) return callable(...) end end')
        self.f, self.sinf, self.cosf, self.acos, self.sin = (hold(g) for g in (f32, ucrt.sinf, ucrt.cosf, ucrt.acos, ucrt.sin))
        self.no_ground = lua.eval('function() return nil end')
        self.orient = lua.eval('function(S, M, f) return function(state) '
                               'state.orientation = S.Orientation(state.orientation, state.velocity, M, f) end end')(self.S, self.M, self.f)
        # A global a static constructor fills in the game (0x1400a4ad0): the identity matrix.
        image.pack('<16f', IDENTITY, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
        # Objects the routines reach through globals.
        self.rate_object = image.block(0x1000)
        image.pack('<Q', RATE_HOLDER, self.rate_object)
        self.parameters = image.block(0x200)
        entry = image.block(0x400)
        image.pack('<Q', entry + 0x360, self.parameters)
        table = image.block(0x40)
        image.pack('<Q', table + 8, entry)
        manager = image.block(0x40)
        image.pack('<Q', manager + 0x30, table)
        image.pack('<Q', MANAGER, manager)
        image.pack('<Q', STAGE, image.block(0x200))
        self.invalid = image.unpack('<I', INVALID_ID)[0]
        # MSVC std::map: a head node (nil) whose parent is the root.
        self.target = image.block(0x200)
        image.pack('<I', self.target + 0x90, self.invalid)
        self.maps = {}
        for name, address in (('objects', OBJECTS), ('owners', OWNERS), ('characters', CHARACTERS)):
            holder, head, node = image.block(0x80), image.block(0x40), image.block(0x40)
            image.pack('<QQQ', head, head, head, head)
            image.pack('<B', head + 0x19, 1)
            image.pack('<QQQ', node, head, head, head)
            image.pack('<I', node + 0x20, TARGET_ID)
            image.pack('<Q', node + 0x28, self.target)
            image.pack('<Q', holder + 0x58, head)
            image.pack('<Q', address, holder)
            self.maps[name] = (head, node)
        self.state = image.block(0x800)
        self.action = image.block(0x40)
        image.pack('<Q', self.action + 8, self.state)
        self.actor = image.block(0x80)
        self.seed = image.function(0x14132d580, None, ctypes.c_uint32)
        two = (None, ctypes.c_void_p, ctypes.c_void_p)
        self.addresses = {'setup': 0x140a6cb10, 'arrow': 0x140a6ce80, 'elevatorStart': 0x140a6e700, 'elevator': 0x140a6e670,
                          'sinCurveStart': 0x140a6f030, 'sinCurve': 0x140a6eb60, 'crawlerStart': 0x140a6e430, 'crawler': 0x140a6e0d0}
        self.native = {name: image.function(address, *two) for name, address in self.addresses.items()}
        self.spread = image.function(0x1410abed0, ctypes.c_float, ctypes.c_float)

    def target_present(self, present: bool) -> None:
        head, node = self.maps['objects']
        self.image.pack('<Q', head + 8, node if present else head)

    def set_rate(self, rate: int) -> None:
        self.image.pack('<B', self.rate_object + 0x952, rate)

    def set_parameters(self, values: dict, fixed_up: bool = False) -> None:
        image = self.image
        image.write(self.parameters, bytes(0x200))
        image.pack('<I', self.parameters + 0x100, int(fixed_up))
        for slot, name in enumerate(SLOTS):
            image.pack('<f', self.parameters + 0x10c + 4 * slot, values.get(name, 0.0))

    def write_state(self, state: dict) -> None:
        image, at = self.image, self.state
        image.write(at, bytes(0x800))
        image.pack('<3f', at + 0x70, *state['position'])
        image.pack('<3f', at + 0xa0, *state['velocity'])
        image.pack('<16f', at + 0xac, *state['orientation'])
        image.pack('<f', at + 0xec, state['roll'])
        image.pack('<I', at + 0xf0, TARGET_ID if state['target'] else self.invalid)
        image.pack('<Q', at + 0x100, state['frame'])
        image.pack('<f', at + 0x164, state['multiplier'])
        image.pack('<I', at + 0x3b0, state['guidance'])
        if state['target']:
            image.pack('<3f', self.target + 0x70, *state['target'])
        self.target_present(bool(state['target']))

    def read_state(self) -> bytes:
        image, at = self.image, self.state
        return image.read(at + 0x70, 12) + image.read(at + 0xa0, 12 + 64) + image.read(at + 0xec, 4) + image.read(at + 0x3b0, 4)

    def lua_state(self, state: dict):
        table = self.lua.table_from
        return table({'position': table(state['position']), 'velocity': table(state['velocity']),
                      'orientation': table(state['orientation']), 'roll': state['roll'], 'frame': state['frame'],
                      'multiplier': state['multiplier'], 'guidance': state['guidance']})

    @staticmethod
    def pack_state(lua_state) -> bytes:
        return (struct.pack('<3f', *[lua_state.position[i] for i in (1, 2, 3)])
                + struct.pack('<3f', *[lua_state.velocity[i] for i in (1, 2, 3)])
                + struct.pack('<16f', *[lua_state.orientation[i] for i in range(1, 17)])
                + struct.pack('<f', lua_state.roll) + struct.pack('<I', int(lua_state.guidance)))


def random_state(h: Harness, rng: random.Random) -> dict:
    angles = [f32(rng.uniform(-3.2, 3.2)) for _ in range(3)]
    orientation = h.M.Euler(*angles, h.f, h.sinf, h.cosf)
    speed = rng.choice([0.0, rng.uniform(0.01, 80.0)])
    direction = [rng.uniform(-1, 1) for _ in range(3)]
    return {'position': [f32(rng.uniform(-900, 900)) for _ in range(3)],
            'velocity': [f32(c * speed) for c in direction],
            'orientation': [orientation[i] for i in range(1, 17)],
            'roll': f32(rng.choice([0.0, rng.uniform(-90, 90)])),
            'frame': rng.randrange(0, 400), 'multiplier': f32(rng.choice([1.0, 1.0, rng.uniform(0.2, 2.0)])),
            'guidance': rng.choice([0, 1, 1]),
            'target': rng.choice([None, [f32(rng.uniform(-900, 900)) for _ in range(3)], [f32(rng.uniform(-900, 900)) for _ in range(3)]])}


def random_parameters(rng: random.Random) -> dict:
    def some(low, high, zero=0.3):
        return 0.0 if rng.random() < zero else f32(rng.uniform(low, high))
    return {'Amplitude_x': some(-100, 100), 'Amplitude_y': some(-30, 30), 'Amplitude_z': some(-50, 50),
            'BankRollMax': some(0, 100), 'BankSpring': some(0, 1), 'BankStrong': some(-1, 60),
            'Frequency_x': some(0, 50), 'Frequency_y': some(0, 50), 'Frequency_z': some(-5, 50),
            'Gravity': some(-5, 6), 'Inductivity': some(0, 0.5), 'RandomDirection': some(0, 360),
            'RandomRoll': some(0, 360), 'ViewingAngle': some(0, 360, 0.1), 'Velocity': some(-1, 150),
            'VelocityRandomize': some(0, 30), 'Rotate_x': some(-180, 180, 0.6)}


def mismatch(label: str, case: int, native: bytes, ported: bytes) -> str:
    count = len(native) // 4
    a, b = struct.unpack(f'<{count}I', native), struct.unpack(f'<{count}I', ported)
    fa, fb = struct.unpack(f'<{count}f', native), struct.unpack(f'<{count}f', ported)
    lines = [f'{label}: case {case} differs']
    for index in range(count):
        if a[index] != b[index]:
            lines.append(f'    word {index}: native {fa[index]!r} ({a[index]:#010x}), Lua {fb[index]!r} ({b[index]:#010x})')
    return '\n'.join(lines)


def run(cases: int) -> dict:
    h = Harness()
    image, A, lua = h.image, h.A, h.lua
    rng = random.Random(0xA6CB10)
    table = lua.table_from
    report = {'cases': cases, 'checks': {}}

    # 1. Random spread.
    for case in range(cases):
        seed = rng.randrange(1 << 32)
        h.seed(seed)
        generator = A.Twister(seed)
        for _ in range(8):
            reach = f32(rng.uniform(0, 400))
            native, ported = h.spread(reach), A.Spread(generator, reach, h.f)
            assert struct.pack('<f', native) == struct.pack('<f', ported), ('spread', seed, reach, native, ported)
    report['checks']['spread 0x1410abed0'] = cases * 8

    def actor_bytes(count: int) -> bytes:
        return image.read(h.actor + 8, count)

    # 2. Shared init, then each class init on top of it.
    for kind, start in (('setup', None), ('elevatorStart', A.ElevatorStart), ('sinCurveStart', A.SinCurveStart),
                        ('crawlerStart', A.CrawlerStart)):
        for case in range(cases):
            state, parameters, rate, seed = random_state(h, rng), random_parameters(rng), rng.choice([30, 60]), rng.randrange(1 << 32)
            h.set_rate(rate)
            h.set_parameters(parameters, fixed_up=rng.random() < 0.5 if kind == 'crawlerStart' else False)
            h.write_state(state)
            image.write(h.actor, bytes(0x80))
            h.seed(seed)
            h.native[kind](h.actor, h.action)
            ported, actor = h.lua_state(state), table({})
            A.Setup(actor, ported, table(parameters), A.Twister(seed), rate, h.M, h.f, h.sinf, h.cosf)
            expected_actor = struct.pack('<3f', *[actor.gravity[i] for i in (1, 2, 3)]) + struct.pack('<2f', actor.inductivity, actor.viewingAngle)
            if kind == 'elevatorStart':
                start(actor, ported, table(parameters), h.f)
            elif kind == 'sinCurveStart':
                start(actor, ported, table(parameters), h.f)
                expected_actor += b''.join(struct.pack('<3f', *[vector[i] for i in (1, 2, 3)])
                                           for vector in (actor.base, actor.amplitude, actor.frequency, actor.previous))
                expected_actor = expected_actor[:20] + bytes(4) + expected_actor[20:]       # +1C is padding
            elif kind == 'crawlerStart':
                start(actor, ported, h.f)
                # Without a stage the ground snap finds nothing; FixedUp rebuilds
                # the basis, then the init ends on the orientation update.
                if image.unpack('<I', h.parameters + 0x100)[0]:
                    A.FixedUp(ported)
                h.orient(ported)
                expected_actor += bytes(4) + struct.pack('<f', actor.speed)
            native_actor = actor_bytes(len(expected_actor))
            if native_actor != expected_actor:
                raise SystemExit(mismatch(f'{kind} actor fields', case, native_actor, expected_actor))
            if h.read_state() != h.pack_state(ported):
                raise SystemExit(mismatch(f'{kind} state', case, h.read_state(), h.pack_state(ported)))
        report['checks'][f'{kind} {h.addresses[kind]:#x}'] = cases

    # 3. Updates, several ticks in a row from one start.
    def actor_fields(parameters: dict, state: dict) -> dict:
        fall = f32(rng.choice([0.0, rng.uniform(-3, 3)]))
        return {'gravity': [f32(rng.choice([0.0, rng.uniform(-1, 1)])), 0.0, fall],
                'inductivity': parameters['Inductivity'], 'viewingAngle': parameters['ViewingAngle']}

    for kind in ('arrow', 'elevator', 'sinCurve', 'crawler'):
        ticks = 0
        for case in range(cases):
            state, parameters, rate = random_state(h, rng), random_parameters(rng), rng.choice([30, 60])
            fixed_up = kind == 'crawler' and rng.random() < 0.5
            fields = actor_fields(parameters, state)
            h.set_rate(rate)
            h.set_parameters(parameters, fixed_up)
            h.write_state(state)
            image.write(h.actor, bytes(0x80))
            image.pack('<3f', h.actor + 8, *fields['gravity'])
            image.pack('<2f', h.actor + 0x14, fields['inductivity'], fields['viewingAngle'])
            ported = h.lua_state(state)
            actor = table({'gravity': table(fields['gravity']), 'inductivity': fields['inductivity'], 'viewingAngle': fields['viewingAngle']})
            target = table(state['target']) if state['target'] else None
            if kind == 'sinCurve':
                A.SinCurveStart(actor, ported, table(parameters), h.f)
                for offset, vector in ((0x20, actor.base), (0x2c, actor.amplitude), (0x38, actor.frequency), (0x44, actor.previous)):
                    image.pack('<3f', h.actor + offset, *[vector[i] for i in (1, 2, 3)])
            elif kind == 'crawler':
                actor.speed = f32(rng.uniform(0, 80))
                image.pack('<f', h.actor + 0x20, actor.speed)
            for tick in range(6):
                image.pack('<Q', h.state + 0x100, state['frame'] + tick)
                ported.frame = state['frame'] + tick
                h.native[kind](h.actor, h.action)
                if kind == 'arrow':
                    A.Arrow(actor, ported, table(parameters), target, h.orient, h.f, h.acos)
                elif kind == 'elevator':
                    A.Elevator(actor, ported, h.orient, h.f)
                elif kind == 'sinCurve':
                    A.SinCurve(actor, ported, table(parameters), target, rate, h.orient, h.f, h.acos, h.sin)
                else:
                    A.Crawler(actor, ported, target, rate, h.no_ground, h.orient, h.f, h.acos, fixed_up)
                ticks += 1
                if h.read_state() != h.pack_state(ported):
                    raise SystemExit(mismatch(f'{kind} update, tick {tick}', case, h.read_state(), h.pack_state(ported)))
        report['checks'][f'{kind} update {h.addresses[kind]:#x}'] = ticks

    # 4. Shot handlers: the spawner 0x140a66080 is replaced by a recorder.
    launches: list = []

    def record(request):
        launches.append(image.read(request + 0x10, 12) + image.read(request + 0x34, 24))
        return 0

    recorder = ctypes.WINFUNCTYPE(ctypes.c_uint32, ctypes.c_void_p)(record)
    image.write(0x140a66080, b'\x48\xb8' + struct.pack('<Q', ctypes.cast(recorder, ctypes.c_void_p).value) + b'\xff\xe0')
    three = (None, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)
    n_way = image.function(0x140a6bb10, *three)
    random_creation = image.function(0x140a6bfa0, *three)
    request, effect, results, storage = image.block(0x400), image.block(0x80), image.block(0x40), image.block(0x4000)
    for kind in ('nWay', 'randomCreation'):
        total = 0
        for case in range(cases):
            position = [f32(rng.uniform(-900, 900)) for _ in range(3)]
            direction = [f32(rng.uniform(-1, 1)) for _ in range(3)]
            axis = [f32(c) for c in rng.choice([[0, 0, 1], [rng.uniform(-1, 1) for _ in range(3)]])]
            count, second = rng.randrange(0, 9), rng.randrange(0, 90)
            seed = rng.randrange(1 << 32)
            image.write(request, bytes(0x400))
            image.pack('<3f', request + 0x10, *position)
            image.pack('<3f', request + 0x34, *direction)
            image.pack('<3f', request + 0x40, *axis)
            image.pack('<I', request + 0x4c, h.invalid)
            image.write(effect, bytes(0x80))
            image.pack('<2i', effect + 0x44, count, second)
            image.pack('<QQ', results + 0x20, storage, storage + 0x4000)
            launches.clear()
            h.seed(seed)
            if kind == 'nWay':
                n_way(request, effect, results)
                ported = A.NWay(table(position), table(direction), table(axis), count, second, h.f, h.sinf, h.cosf)
            else:
                random_creation(request, effect, results)
                ported = A.RandomCreation(table(position), table(direction), table(axis), count, second, A.Twister(seed), h.f)
            expected = [struct.pack('<9f', *[launch[key][i] for key in ('position', 'direction', 'up') for i in (1, 2, 3)])
                        for launch in ported.values()]
            assert len(launches) == len(expected) == count, (kind, case, len(launches), len(expected), count)
            for index, (native, wanted) in enumerate(zip(launches, expected)):
                if native != wanted:
                    raise SystemExit(mismatch(f'{kind} launch {index}', case, native, wanted))
            total += count
        report['checks'][f'{kind} launches'] = total
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=400)
    args = ap.parse_args()
    result = run(args.cases)
    target = ROOT / 'captured_assets' / 'procedural' / 'skill_actor_native_verification.json'
    result['scope'] = ('Byte-exact against NSUNSC.exe code run in process (native_image.py). Stage collision, the BOUNDBALL '
                       'class and the character-specific guidance branches are not covered.')
    target.write_text(json.dumps(result, indent=1) + '\n', encoding='utf-8')
    for name, count in result['checks'].items():
        print(f'PASS {name}: {count}')
    print('WROTE:', target)
