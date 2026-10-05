"""Check lua/storm_fx/core/cl_point_light.lua (the addon's) against the game's own code.

Runs, on random lights and object positions (native_image.py):

  0x1412c9cd0  sort key of a point light (nuccLightPoint: intensity +0x60, world
               position +0x7C, radii +0x88 / +0x8C) for a position
  0x14110ded0  ccCmnLightManager: the lights of an object, at most four, sorted
               (list at +0x80, count +0x88, four sort slots at [+0x90]+0x18)
  0x14110dac0  registration: which lights the list accepts, and in what order

and compares the key bit for bit and the selected lights in order. The shader
constants of a slot (inside the context fill 0x1413368f0) are not run here.

  python verify_point_light_native.py [--cases 4000]
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
OUT = ROOT / 'captured_assets' / 'procedural' / 'point_light_native_verification.json'
FLT_MAX = 3.4028234663852886e+38


def f32(value: float) -> float:
    with np.errstate(over='ignore', invalid='ignore'):
        return float(np.float32(value))


def random_light(rng: random.Random) -> dict:
    near = f32(rng.choice([0.0, 0.0, 70.0, 100.0, 500.0, rng.uniform(0, 600)]))
    far = f32(rng.choice([near, 300.0, 1000.0, near + rng.uniform(0, 1500), rng.uniform(0, 3000)]))
    return {'position': [f32(rng.uniform(-800, 800)) for _ in range(3)],
            'color': [f32(rng.random()) for _ in range(3)],
            'intensity': f32(rng.choice([-1.0, 0.0, 0.5, 1.0, 3.0, rng.uniform(-2, 10)])), 'near': near, 'far': far}


def run(cases: int) -> dict:
    image = NativeImage()
    lua = LuaRuntime(unpack_returned_tuples=True)
    core = load_core(lua, 'point_light')
    f = lua.eval('function(g) return function(x) return g(x) end end')(f32)      # see native_image / lupa note
    key = image.function(0x1412c9cd0, ctypes.c_float, ctypes.c_void_p, ctypes.c_void_p)
    select = image.function(0x14110ded0, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int, ctypes.c_void_p, ctypes.c_uint32)
    position = image.block(0x10)
    rng = random.Random(0x2C9CD0)

    def write_light(address: int, light: dict) -> None:
        image.pack('<3f', address + 0x50, *light['color'])
        image.pack('<f', address + 0x60, light['intensity'])
        image.pack('<3f', address + 0x7c, *light['position'])
        image.pack('<2f', address + 0x88, light['near'], light['far'])

    def table(light: dict):
        return lua.table_from({'position': lua.table_from(light['position']), 'color': lua.table_from(light['color']),
                               'intensity': light['intensity'], 'near': light['near'], 'far': light['far']})

    # -- sort key ---------------------------------------------------------------
    light_block = image.block(0x100)
    key_failures, branches = [], {'inside near': 0, 'between': 0, 'beyond far': 0, 'no intensity': 0}
    for case in range(cases):
        light = random_light(rng)
        at = [f32(light['position'][i] + rng.uniform(-1, 1) * rng.choice([50, 400, 2500])) for i in range(3)]
        write_light(light_block, light)
        image.pack('<3f', position, *at)
        native = struct.pack('<f', key(light_block, position))
        ours = struct.pack('<f', core.Key(table(light), lua.table_from(at), f))
        distance = float(np.linalg.norm(np.array(light['position']) - np.array(at)))
        branch = ('no intensity' if light['intensity'] <= 0 else 'beyond far' if distance > light['far']
                  else 'inside near' if distance < light['near'] else 'between')
        branches[branch] += 1
        # -0.0 and 0.0 are the same key
        if native != ours and not (struct.unpack('<f', native)[0] == 0 == struct.unpack('<f', ours)[0]):
            key_failures.append({'case': case, 'light': light, 'position': at, 'native': native.hex(), 'port': ours.hex()})

    # -- selection ----------------------------------------------------------------
    lights_block = image.block(0x100 * 8)
    entries, nodes = image.block(0x18 * 8), image.block(0x18 * 9)
    slots, slot_table, holder, manager = image.block(0x10 * 4), image.block(8 * 4), image.block(0x30), image.block(0xa0)
    out = image.block(8 * 4)
    image.pack('<4Q', slot_table, *(slots + 0x10 * i for i in range(4)))
    image.pack('<2Q', holder + 0x18, slot_table, slot_table + 8 * 4)
    image.pack('<Q', manager + 0x90, holder)
    select_failures, counts = [], {}
    for case in range(cases):
        count = rng.choice([1, 1, 2, 3, 4, 4, 5, 7])
        lights = [random_light(rng) for _ in range(count)]
        if rng.random() < 0.3:          # equal keys: lights with no positive intensity, or all out of reach
            for light in lights:
                light['intensity'] = f32(rng.choice([-1.0, 0.0]))
        at = [f32(rng.uniform(-600, 600)) for _ in range(3)]
        image.pack('<3f', position, *at)
        head = nodes                    # std::list sentinel, then one node per light
        for i, light in enumerate(lights):
            write_light(lights_block + 0x100 * i, light)
            image.pack('<IIQQ', entries + 0x18 * i, 1, 0, lights_block + 0x100 * i, 0)
            node = nodes + 0x18 * (i + 1)
            following = nodes + 0x18 * (i + 2) if i + 1 < count else head
            image.pack('<3Q', node, following, nodes + 0x18 * i, entries + 0x18 * i)
        image.pack('<3Q', head, nodes + 0x18, nodes + 0x18 * count, 0)
        image.pack('<QQ', manager + 0x80, head, count)
        for i in range(4):
            image.pack('<Qf', slots + 0x10 * i, 0, FLT_MAX)
        image.write(out, bytes(8 * 4))
        found = select(manager, out, 4, position, 0xffffffff)
        native = [(pointer - entries) // 0x18 for pointer in image.unpack('<4Q', out)[:found]]
        chosen = core.Select(lua.table_from([table(light) for light in lights]), lua.table_from(at), f)
        ours = []
        for item in chosen.values():
            ours.append(next(i for i, light in enumerate(lights) if light['position'] == list(item.position.values())
                             and light['intensity'] == item.intensity and light['far'] == item.far))
        counts[count] = counts.get(count, 0) + 1
        if native != ours:
            select_failures.append({'case': case, 'lights': lights, 'position': at, 'native': native, 'port': ours})

    # -- registration ---------------------------------------------------------------
    # 0x14110dac0 logs and skips a light whose two radii are zero (ucomiss on +0x88 and
    # +0x8C) and appends the others before the sentinel: read from the listing, the routine
    # allocates through the game's heap and is not run here.
    accepted = [(near, far, bool(core.Accepted(lua.table_from({'near': near, 'far': far}))))
                for near, far in ((0.0, 0.0), (0.0, 300.0), (100.0, 0.0), (150.0, 300.0))]
    registration_ok = [row[2] for row in accepted] == [False, True, True, True]
    return {'cases': cases, 'key': {'failures': key_failures[:10], 'failed': len(key_failures), 'branches': branches},
            'select': {'failures': select_failures[:10], 'failed': len(select_failures), 'lists_by_size': counts},
            'registration': {'rows': accepted, 'ok': registration_ok}}


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=4000)
    args = ap.parse_args()
    report = run(args.cases)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=1))
    print(f'sort key 0x1412c9cd0: {report["cases"]} cases, branches {report["key"]["branches"]}, '
          f'{report["key"]["failed"]} differ')
    for row in report['key']['failures'][:3]:
        print('   ', row)
    print(f'selection 0x14110ded0: {report["cases"]} lists (sizes {dict(sorted(report["select"]["lists_by_size"].items()))}), '
          f'{report["select"]["failed"]} differ')
    for row in report['select']['failures'][:3]:
        print('   ', {k: row[k] for k in ('case', 'native', 'port')})
    print('registration rule (read, not run):', 'as translated' if report['registration']['ok'] else 'MISMATCH')
    print(f'WROTE: {OUT}')
    failed = report['key']['failed'] or report['select']['failed'] or not report['registration']['ok']
    print('FAIL' if failed else 'PASS: point light key and selection equal the game code')
    sys.exit(1 if failed else 0)
