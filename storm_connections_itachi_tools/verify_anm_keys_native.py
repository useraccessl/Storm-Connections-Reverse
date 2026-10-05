"""Check the table key readers of the ANM cores against the game's own code.

The key factory 0x141367040 picks one class per curve format; a table class
reads `key+0x18` -> {u32 step, values...} at a tick. This calls the game's
reader (native_image.py) and lua/storm_amt_lab/scalar_animation_core.lua on
the same random tables and ticks; the floats must be identical.

  format 15  unsigned shorts, interpolated, * 1/32768   0x141394da0
  format 29  unsigned shorts, held, * 1/32768           0x141394e20
  format 16  signed short triples, interpolated, * 1/4096  0x141394ee0
  format 21  float triples, interpolated                0x141395130
  format 26  float triples, held                        0x141395220

(11, 12, 22 and 24 are covered by verify_scalar_animation_native.py.)

  python verify_anm_keys_native.py [--cases 3000]
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

LUA = ROOT.parent / 'storm_amaterasu_lab' / 'lua' / 'storm_amt_lab'
# format: (reader, value layout, components, value generator)
READERS = {15: (0x141394da0, 'H', 1), 29: (0x141394e20, 'H', 1), 16: (0x141394ee0, '3h', 3),
           21: (0x141395130, '3f', 3), 26: (0x141395220, '3f', 3)}


def f32(value: float) -> float:
    with np.errstate(over='ignore', invalid='ignore'):
        return float(np.float32(value))


def run(cases: int) -> dict:
    image = NativeImage()
    lua = LuaRuntime(unpack_returned_tuples=True)
    core = lua.execute((LUA / 'scalar_animation_core.lua').read_text(encoding='utf-8-sig'))
    f = lua.eval('function(g) return function(x) return g(x) end end')(f32)      # see native_image / lupa note
    key, data, out = image.block(0x40), image.block(0x4000), image.block(0x20)
    image.pack('<Q', key + 0x18, data)
    rng = random.Random(0x394DA0)
    report = {}
    for fmt, (address, layout, components) in READERS.items():
        reader = image.function(address, None, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_uint32)
        size = struct.calcsize('<' + layout)
        on_key = between = 0
        for case in range(cases):
            count = rng.randrange(2, 40)
            step = rng.choice([50, 100, 100, 200, rng.randrange(1, 400)])
            if layout == 'H':
                rows = [(rng.randrange(0, 65536),) for _ in range(count)]
            elif layout == '3h':
                rows = [tuple(rng.randrange(-32768, 32768) for _ in range(3)) for _ in range(count)]
            else:
                rows = [tuple(f32(rng.uniform(-500, 500)) for _ in range(3)) for _ in range(count)]
            image.pack('<I', data, step)
            for index, row in enumerate(rows):
                image.pack('<' + layout, data + 4 + index * size, *row)
            # Inside the table: an interpolating reader needs the next row.
            ticks = rng.randrange(0, (count - 1) * step) if rng.random() < 0.7 else rng.randrange(0, count - 1) * step
            image.write(out, bytes(0x20))
            reader(key, out, ticks)
            native = image.read(out, 4 * components)
            curve = lua.table_from({'format': fmt, 'values': lua.table_from([lua.table_from(list(row)) for row in rows])})
            if components == 1:
                ported = struct.pack('<f', core.sample(curve, ticks, step, False, f))
            else:
                value = core.vector(curve, ticks, step, f)
                ported = struct.pack('<3f', value[1], value[2], value[3])
            if native != ported:
                raise SystemExit(f'format {fmt}: case {case} differs at tick {ticks} (step {step}): native '
                                 f'{struct.unpack(f"<{components}f", native)}, Lua {struct.unpack(f"<{components}f", ported)}')
            if ticks % step:
                between += 1
            else:
                on_key += 1
        report[f'format {fmt} ({address:#x})'] = {'on a key': on_key, 'between two keys': between}
        print(f'PASS format {fmt} ({address:#x}): {on_key} ticks on a key, {between} between two keys, identical floats')
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=3000)
    args = ap.parse_args()
    result = run(args.cases)
    target = ROOT / 'captured_assets' / 'procedural' / 'anm_keys_native_verification.json'
    target.write_text(json.dumps(result, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
