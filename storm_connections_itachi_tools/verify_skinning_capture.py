"""Check the translated NUD skinning against the game's own compute dispatches.

The game skins on the GPU: a compute shader (in no file of the game; taken from a
RenderDoc capture by rd_dump_compute.py, gpu_captures/compute/shader_*.dxbc)
blends, per vertex, the three first columns of up to four palette matrices by the
vertex weights and writes

    position.xyz = (dot(R0, p), dot(R1, p), dot(R2, p)), position.w kept     (p = x, y, z, w)
    normal       = (dot(R0.xyz, n), dot(R1.xyz, n), dot(R2.xyz, n))          (not renormalised)

with Rk = sum over the four influences of weight * column k of the matrix.
For each dumped dispatch this recomputes the output from the dumped inputs
(vertices, palette, weights and indices) with skin() below - the same arithmetic
as lua/storm_fx/core/cl_skinning.lua - and compares it with what the GPU wrote.

  python verify_skinning_capture.py
"""

from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from lupa import LuaRuntime  # noqa: E402

FOLDER = ROOT / 'gpu_captures' / 'compute'
from addon_lua import load_core  # noqa: E402
F = np.float32


def skin(position, normal, weights, indices, palette):
    """position (4,), normal (3,), weights (4,), indices (4,), palette (N, 4, 4) float32."""
    rows = np.zeros((3, 4), dtype=np.float32)
    # The shader's order: influence 1 first, then 0, 2, 3 (mul, then three mad).
    for k in range(3):
        column = lambda i: palette[indices[i]][:, k]
        r = F(weights[1]) * column(1)
        r = column(0) * F(weights[0]) + r
        r = column(2) * F(weights[2]) + r
        r = column(3) * F(weights[3]) + r
        rows[k] = r.astype(np.float32)
    out_position = np.array([np.dot(rows[k], position) for k in range(3)] + [position[3]], dtype=np.float32)
    out_normal = np.array([np.dot(rows[k][:3], normal) for k in range(3)], dtype=np.float32)
    return out_position, out_normal


def main() -> int:
    report = json.loads((FOLDER / 'dispatches_frame22136.json').read_text(encoding='utf-8'))
    lua = LuaRuntime(unpack_returned_tuples=True)
    core = load_core(lua, 'skinning')
    f = lua.eval('function(g) return function(x) return g(x) end end')(lambda x: float(np.float32(x)))
    worst, total, summary = 0.0, 0, []
    for row in report['dispatches']:
        files = {(b['kind'], b['slot']): FOLDER / b['file'] for b in row['bound'] if 'file' in b}
        if ('ro', 0) not in files:
            continue
        vertices = files[('ro', 0)].read_bytes()
        palette = np.frombuffer(files[('ro', 1)].read_bytes(), dtype='<f4').reshape(-1, 4, 4)
        blend = files[('ro', 2)].read_bytes()
        stride, count = struct.unpack('<2I', files[('ro', 3)].read_bytes()[:8])
        offset3 = struct.unpack('<I', files[('ro', 4)].read_bytes()[:4])[0]
        offset4 = struct.unpack('<I', files[('ro', 5)].read_bytes()[:4])[0]
        out_offset = struct.unpack('<I', files[('cb', 0)].read_bytes()[:4])[0]
        output = files[('rw', 0)].read_bytes()
        if out_offset + count * stride > len(output):
            summary.append(f'event {row["event"]}: output beyond the dumped part of the buffer, skipped')
            continue
        lua_palette = lua.table_from([lua.table_from([float(x) for x in m.reshape(-1)]) for m in palette])
        error = lua_error = 0.0
        bones = set()
        for v in range(count):
            weights = struct.unpack_from('<4f', blend, v * 32)
            indices = struct.unpack_from('<4I', blend, v * 32 + 16)
            position = np.array(struct.unpack_from('<4f', vertices, v * stride + offset4), dtype=np.float32)
            normal = np.array(struct.unpack_from('<3f', vertices, v * stride + offset3), dtype=np.float32)
            got_position = np.array(struct.unpack_from('<4f', output, out_offset + v * stride + offset4))
            got_normal = np.array(struct.unpack_from('<3f', output, out_offset + v * stride + offset3))
            ours_position, ours_normal = skin(position, normal, weights, indices, palette)
            scale = max(1.0, float(np.abs(got_position[:3]).max()))
            error = max(error, float(np.abs(ours_position - got_position).max()) / scale, float(np.abs(ours_normal - got_normal).max()))
            p, n = core.Vertex(lua.table_from([float(x) for x in position]), lua.table_from([float(x) for x in normal]),
                               lua.table_from(list(weights)), lua.table_from([i + 1 for i in indices]), lua_palette, f)
            lua_error = max(lua_error, max(abs(p[i + 1] - got_position[i]) for i in range(4)) / scale,
                            max(abs(n[i + 1] - got_normal[i]) for i in range(3)))
            bones.update(i for i, w in zip(indices, weights) if w)
        total += count
        worst = max(worst, error, lua_error)
        summary.append(f'event {row["event"]}: {count} vertices, stride {stride}, normal at +{offset3}, position at +{offset4}, '
                       f'{len(palette)} matrices ({len(bones)} used): largest relative difference Python {error:.2e}, Lua {lua_error:.2e}')
    for line in summary:
        print(line)
    print(f'{total} vertices compared with the GPU output; worst relative difference {worst:.2e}')
    ok = total > 0 and worst < 2e-6
    print('PASS: the skinning arithmetic equals the game\'s compute shader output' if ok else 'FAIL')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
