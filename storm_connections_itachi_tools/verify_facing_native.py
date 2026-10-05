"""Check lua/storm_fx/core/cl_facing.lua (the addon's) against the game's camera-facing hooks.

  python verify_facing_native.py [--cases 2000]

The model draw callback 0x1412d1870 calls slot +68 of a model whose header attribute
bit 0 is set (model +2C & 1), once per draw, on the world matrix of the draw:
nuccModel 0x1412d4f40, nuccBillboard 0x1412c84b0. Both are run here in the game's
own code (native_image.py) on random matrices (rotation, scale, translation), random
camera rotations (the 3x3 at camera +80) and, for the billboard, random size,
position offset and roll (+2B0 offset, +2BC roll as a 32-bit integer, +2C0 size),
and compared with the Lua core given the camera's columns as (x, y, z).

The two 3x3 / 4x4 identity globals these routines start from are filled by static
constructors the native image does not run; they are written here.
"""

from __future__ import annotations

import argparse
import ctypes
import json
import struct
import sys
from pathlib import Path

import numpy as np

from native_image import NativeImage

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from lupa import LuaRuntime  # noqa: E402

from addon_lua import load_core  # noqa: E402
OUT = ROOT / 'captured_assets' / 'procedural' / 'facing_native_verification.json'
IDENTITY3 = 0x1420c3260
IDENTITY4 = 0x149707f10


def rotation(rng: np.random.Generator) -> np.ndarray:
    q = rng.normal(size=4)
    q /= np.linalg.norm(q)
    w, x, y, z = q
    return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - z * w), 2 * (x * z + y * w)],
                     [2 * (x * y + z * w), 1 - 2 * (x * x + z * z), 2 * (y * z - x * w)],
                     [2 * (x * z - y * w), 2 * (y * z + x * w), 1 - 2 * (x * x + y * y)]])


def run(cases: int) -> dict:
    image = NativeImage()
    image.pack('<9f', IDENTITY3, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    image.pack('<16f', IDENTITY4, *np.eye(4).ravel())
    hooks = {'model': image.function(0x1412d4f40, None, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p),
             'billboard': image.function(0x1412c84b0, None, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p)}
    this, matrix, camera = image.block(0x400), image.block(0x40), image.block(0x100)
    lua = LuaRuntime(unpack_returned_tuples=True)
    core = load_core(lua, 'facing')
    f32 = lambda v: float(np.float32(v))  # noqa: E731
    f = lua.eval('function(g) return function(x) return g(x) end end')(f32)   # see native_image / lupa note
    rng = np.random.default_rng(0x12C84B0)
    worst = {'model': 0.0, 'billboard': 0.0}
    for case in range(cases):
        m = np.eye(4)
        scale = rng.uniform(0.05, 20, 3) * rng.choice([-1, 1], 3) if case % 7 == 0 else rng.uniform(0.05, 20, 3)
        r = rotation(rng)
        m[:3, :3] = (r @ np.diag(scale)) if case % 2 else (np.diag(scale) @ r)
        m[:3, 3] = rng.uniform(-3000, 3000, 3)
        m = m.astype(np.float32).astype(np.float64)
        c = rotation(rng).astype(np.float32).astype(np.float64)
        axes = [lua.table_from({'x': c[0, k], 'y': c[1, k], 'z': c[2, k]}) for k in range(3)]
        board = {'roll': int(rng.integers(-200000, 200000)) if case % 3 else 0,
                 'size': [f32(v) for v in rng.uniform(0.01, 30, 2)], 'offset': [f32(v) for v in rng.uniform(-500, 500, 3)]}
        for kind, hook in hooks.items():
            image.pack('<16f', matrix, *m.ravel())
            image.pack('<9f', camera + 0x80, *c.ravel())
            if kind == 'billboard':
                image.pack('<3f', this + 0x2b0, *board['offset'])
                image.pack('<i', this + 0x2bc, board['roll'])
                image.pack('<2f', this + 0x2c0, *board['size'])
            hook(this, matrix, camera)
            native = np.array(struct.unpack('<16f', image.read(matrix, 64)), dtype=np.float64)
            world = lua.table_from(list(m.ravel()))
            if kind == 'model':
                ported = core.Model(world, *axes)
            else:
                ported = core.Billboard(world, lua.table_from({'roll': board['roll'], 'size': lua.table_from(board['size']),
                                                               'offset': lua.table_from(board['offset'])}), *axes, None, f)
            ported = np.array([ported[i + 1] for i in range(16)], dtype=np.float64)
            # Relative to the size of what is compared: translations reach 3500, axes 600.
            error = np.abs(native - ported) / np.maximum(1.0, np.abs(native))
            worst[kind] = max(worst[kind], float(error.max()))
    return {'cases': cases, 'worstRelativeDifference': worst,
            'functions': {'model': '0x1412d4f40', 'billboard': '0x1412c84b0', 'caller': '0x1412d1870'}}


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=2000)
    args = ap.parse_args()
    report = run(args.cases)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    for kind, error in report['worstRelativeDifference'].items():
        print(f'{kind} hook: {report["cases"]} cases, largest relative difference {error:.2e}')
    print('WROTE:', OUT)
    ok = all(error < 2e-5 for error in report['worstRelativeDifference'].values())
    print('PASS: core/cl_facing.lua equals the game hooks (float32 rounding)' if ok else 'FAIL')
    sys.exit(0 if ok else 1)
