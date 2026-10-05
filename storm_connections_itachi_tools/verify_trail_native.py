"""Check lua/storm_fx/core/cl_trail.lua (the addon's) against the game's trail code, run natively.

  python verify_trail_native.py [--cases 3000]

Two routines of nuccTrailBase are called in the game's own code (native_image.py) on
random inputs and compared with the Lua core, value for value:

  * 0x1413248a0, the ribbon points between three consecutive samples (adaptive number
    of points, direction blend, width profile, width fade). Its inputs are built as the
    game keeps them: the sample deque (MSVC deque, one 0x3C-byte sample per block, map
    and proxy) and the output vector (given room enough not to grow).
  * 0x141325a50, the vertices of the ribbon (lengths along each edge, colour gradient,
    alpha, UVs from the billboard's UV values). Its draw part is skipped by leaving the
    texture id at 0; the lock at trail +350 is a real critical section.

  * 0x14132c830, a force field (nuccTrailForceField vtable +0x10) acting on the samples:
    positions, velocities and decay of every sample edge, with the field's coordinate
    (world matrix, or none) and every falloff flag.

The update that takes the samples (0x141325090) allocates and is translated, not run.
"""

from __future__ import annotations

import argparse
import ctypes
import json
import math
import struct
import sys
from pathlib import Path

import numpy as np

from native_image import NativeImage

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from lupa import LuaRuntime  # noqa: E402

from addon_lua import load_core  # noqa: E402
OUT = ROOT / 'captured_assets' / 'procedural' / 'trail_native_verification.json'
SUBDIVIDE, VERTICES, FIELD = 0x1413248a0, 0x141325a50, 0x14132c830
RET = 0x1411ab78d                   # a bare `ret` (end of 0x1411ab760): the coordinate's vtable +0x28
SAMPLE, POINT, VERTEX = 0x3c, 0x3c, 0x40


def f32(v: float) -> float:
    return float(np.float32(v))


def bits(v: float) -> int:
    return struct.unpack('<I', struct.pack('<f', v))[0]


class Harness:
    def __init__(self):
        self.image = image = NativeImage()
        image.pack('<9f', 0x1420c3260, 1, 0, 0, 0, 1, 0, 0, 0, 1)
        image.pack('<16f', 0x149707f10, *np.eye(4).ravel())
        self.subdivide = image.function(SUBDIVIDE, None, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_int,
                                        ctypes.c_int, ctypes.c_float, ctypes.c_float)
        self.vertices = image.function(VERTICES, ctypes.c_int, ctypes.c_void_p)
        self.field = image.function(FIELD, ctypes.c_int, ctypes.c_void_p, ctypes.c_void_p, ctypes.c_float)
        self.field_object = image.block(0x80)
        self.field_record = image.block(0x20)
        self.coordinate = image.block(0x200)
        self.coordinate_vtable = image.block(0x40)
        self.trail = image.block(0x800)
        self.proxy = image.block(0x10)
        self.map = image.block(8 * 64)
        self.samples = [image.block(0x40) for _ in range(64)]
        self.vector = image.block(0x40)
        self.points = image.block(POINT * 4096)
        self.vertex_buffer = image.block(VERTEX * 8192)
        self.record = image.block(0x80)
        self.billboard = image.block(0x400)
        # Lock at trail +350 (0x1412a7920): enabled flag at +28, then a recursive mutex at +8
        # (0x14120c210: owner thread id +8, count +C). Marked as already held once by this
        # thread, the routine's lock and unlock only count, never reaching the OS primitive.
        kernel32 = ctypes.WinDLL('kernel32')
        image.pack('<i', self.trail + 0x350 + 0x28, 1)
        image.pack('<Ii', self.trail + 0x358 + 8, kernel32.GetCurrentThreadId(), 1)

    def run_subdivide(self, samples, i, max_sub, start_w, end_w, width_scale, offset):
        im, t = self.image, self.trail
        im.pack('<Q', t + 0x1f8, self.proxy)
        im.pack('<Q', self.proxy, t + 0x1f8)
        im.pack('<QQQQ', t + 0x200, self.map, 64, offset, len(samples))
        for k, sample in enumerate(samples):
            block = self.samples[k]
            im.pack('<6f', block, *sample[0], *sample[1])
            im.pack('<Q', self.map + 8 * ((offset + k) % 64), block)
        im.pack('<QQQ', self.vector + 0x18, self.points, self.points, self.points + POINT * 4096)
        im.pack('<f', t + 0x340, width_scale)
        self.subdivide(t, self.vector, t + 0x1e0, i, max_sub, start_w, end_w)
        end = struct.unpack('<Q', im.read(self.vector + 0x20, 8))[0]
        out = []
        for at in range(self.points, end, POINT):
            v = struct.unpack('<6f', im.read(at, 24))
            out.append((v[0:3], v[3:6]))
        return out

    def run_field(self, samples, field, matrix, offset):
        """samples: [(p0, p1, v0, v1, decay)]; field: dict of the record; matrix: 16 floats or
        None. Returns the samples after 0x14132c830, same shape."""
        im, t = self.image, self.trail
        deque = t + 0x1e0
        im.pack('<Q', t + 0x1f8, self.proxy)
        im.pack('<Q', self.proxy, t + 0x1f8)
        im.pack('<QQQQ', t + 0x200, self.map, 64, offset, len(samples))
        for k, (p0, p1, v0, v1, decay) in enumerate(samples):
            block = self.samples[k]
            im.write(block, bytes(0x40))
            im.pack('<6f', block, *p0, *p1)
            im.pack('<6f', block + 0x20, *v0, *v1)
            im.pack('<f', block + 0x38, decay)
            im.pack('<Q', self.map + 8 * ((offset + k) % 64), block)
        # Record (memory +0x18 of the table-3 record): direction, decay, kind, radius,
        # strength, flags.
        rec = self.field_record
        im.pack('<3ff', rec, *field['direction'], field['decay'])
        im.pack('<i', rec + 0x10, field['kind'])
        im.pack('<ff', rec + 0x14, field['radius'], field['strength'])
        im.pack('<i', rec + 0x1c, field['flags'])
        ff = self.field_object
        im.write(ff, bytes(0x80))
        im.pack('<Q', ff + 0x20, rec)
        if matrix is None:
            im.pack('<Q', ff + 0x28, 0)
        else:
            c = self.coordinate
            im.write(c, bytes(0x200))
            im.pack('<Q', c, self.coordinate_vtable)
            im.pack('<Q', self.coordinate_vtable + 0x28, RET)
            im.pack('<16f', c + 0x7c, *matrix)
            im.pack('<B', c + 0x120, 0)
            im.pack('<Q', ff + 0x28, c)
        self.field(ff, deque, 1.0)
        out = []
        for k in range(len(samples)):
            block = self.samples[k]
            p = struct.unpack('<6f', im.read(block, 24))
            v = struct.unpack('<6f', im.read(block + 0x20, 24))
            decay = struct.unpack('<f', im.read(block + 0x38, 4))[0]
            out.append((p[0:3], p[3:6], v[0:3], v[3:6], decay))
        return out

    def run_vertices(self, points, colors, split, alpha, rect):
        im, t = self.image, self.trail
        for k, (p0, p1) in enumerate(points):
            im.pack('<6f', self.points + POINT * k, *p0, *p1)
            im.write(self.points + POINT * k + 0x18, bytes(POINT - 0x18))
        im.pack('<QQ', t + 0x238, self.points, self.points + POINT * len(points))
        im.pack('<Q', t + 0x320, self.vertex_buffer)
        im.pack('<i', t + 0x32c, 8192)
        im.write(self.vertex_buffer, bytes(VERTEX * 2 * len(points)))
        # Record (memory) +0x20 onwards: +0x10 C0, +0x20 C1, +0x30 C2, +0x40 split.
        im.pack('<12f', self.record + 0x10, *colors[0], *colors[1], *colors[2])
        im.pack('<f', self.record + 0x40, split)
        im.pack('<Q', t + 0x1a8, self.record)
        im.pack('<f', t + 0x33c, alpha)
        im.pack('<i', t + 0x2e0, 0)
        im.pack('<i', t + 0x1a0, 0)
        if rect is None:
            im.pack('<QQQ', t + 0x10, 0, 0, 0)
            im.pack('<Q', t + 0x198, 0)
        else:
            im.pack('<QQ', t + 0x10, self.billboard, self.billboard)
            im.pack('<Q', t + 0x198, self.billboard)
            im.pack('<8f', self.billboard + 0x2c8, *rect)
            im.pack('<f', self.billboard + 0x2f0, 1.0)
        self.vertices(t)
        out = []
        for k in range(2 * len(points)):
            v = struct.unpack('<16f', im.read(self.vertex_buffer + VERTEX * k, 64))
            out.append({'position': v[0:3], 'color': v[8:12], 'u': v[12], 'v': v[13]})
        return out


def random_sample(rng, scale):
    return [[f32(x) for x in rng.uniform(-scale, scale, 3)] for _ in range(2)]


def random_matrix(rng, near):
    """A world matrix (row-major, translation in the fourth column): rotation x scale,
    translation near a point (so that samples fall inside the field's radius)."""
    q = rng.normal(size=4)
    q /= np.linalg.norm(q)
    w, x, y, z = q
    r = np.array([[1 - 2 * (y * y + z * z), 2 * (x * y - w * z), 2 * (x * z + w * y)],
                  [2 * (x * y + w * z), 1 - 2 * (x * x + z * z), 2 * (y * z - w * x)],
                  [2 * (x * z - w * y), 2 * (y * z + w * x), 1 - 2 * (x * x + y * y)]]) * rng.uniform(0.3, 2.0)
    t = np.array(near) + rng.normal(0, 60, 3)
    rows = [list(r[i]) + [t[i]] for i in range(3)] + [[0.0, 0.0, 0.0, 1.0]]
    return [f32(v) for row in rows for v in row]


def field_check(h, lua, core, f, rng, cases, row):
    """0x14132c830 against trail_core.applyField on random samples, fields and coordinates."""
    table = lambda values: lua.table_from(list(values))  # noqa: E731
    for case in range(cases):
        n = int(rng.integers(1, 7))
        base = rng.uniform(-300, 300, 3)
        samples = []
        for _ in range(n):
            p0 = [f32(x) for x in base + rng.normal(0, 80, 3)]
            p1 = [f32(x) for x in base + rng.normal(0, 80, 3)]
            moving = rng.random() < 0.5
            v0 = [f32(x) for x in rng.normal(0, 5, 3)] if moving else [0.0, 0.0, 0.0]
            v1 = [f32(x) for x in rng.normal(0, 5, 3)] if moving and rng.random() < 0.8 else [0.0, 0.0, 0.0]
            decay = 0.0 if rng.random() < 0.3 else f32(rng.uniform(-0.6, 0.6))
            samples.append((p0, p1, v0, v1, decay))
        direction = [0.0, 0.0, 0.0] if rng.random() < 0.15 else [f32(x) for x in rng.normal(0, 1, 3) * rng.uniform(0.01, 3)]
        flags = int(rng.choice([0, 1, 2, 3, 4, 5, 6, 7])) | (0x10 if rng.random() < 0.5 else 0)
        field = {'direction': direction, 'decay': f32(rng.uniform(-0.5, 0.5)),
                 'kind': 1 if rng.random() < 0.9 else int(rng.choice([0, 2])),
                 'radius': f32(rng.uniform(-0.2, 4.0)), 'strength': f32(rng.uniform(-30, 30)), 'flags': flags}
        matrix = None if rng.random() < 0.3 else random_matrix(rng, base)
        native = h.run_field(samples, field, matrix, int(rng.integers(0, 64)))
        lua_samples = lua.table_from([lua.table_from({1: table(p0), 2: table(p1),
                                                      'velocity': lua.table_from([table(v0), table(v1)]), 'decay': decay})
                                      for p0, p1, v0, v1, decay in samples])
        lua_field = lua.table_from({'direction': table(direction), 'decay': field['decay'], 'kind': field['kind'],
                                    'radius': field['radius'], 'strength': field['strength'], 'flags': flags})
        core.ApplyField(lua_field, table(matrix) if matrix else None, lua_samples, f)
        row['cases'] += 1
        bad = False
        for k, (np0, np1, nv0, nv1, ndecay) in enumerate(native):
            s = lua_samples[k + 1]
            got = [list(s[1].values()), list(s[2].values()), list(s.velocity[1].values()), list(s.velocity[2].values())]
            for e, (want, have) in enumerate(zip((np0, np1, nv0, nv1), got)):
                if any(bits(a) != bits(f32(b)) for a, b in zip(want, have)):
                    bad = True
            if bits(ndecay) != bits(f32(s.decay)):
                bad = True
            # Which branch each edge took (approximately: by distance to the field's centre).
            center = np.array([matrix[3], matrix[7], matrix[11]]) if matrix else np.zeros(3)
            for e in range(2):
                row['edges'] += 1
                before, after = samples[k][e], (np0, np1)[e]
                if tuple(before) != tuple(after):
                    inside = field['kind'] == 1 and 1e-30 < np.linalg.norm(np.array(before) - center) < field['radius'] * 100
                    row['pushed' if inside else 'drifting'] += 1
        if bad:
            row['differ'] += 1
            if row['differ'] <= 3:
                print('field differs:', case, field, matrix is not None, native[:1],
                      [(list(s[1].values()), list(s.velocity[1].values()), s.decay) for s in list(lua_samples.values())[:1]])


def run(cases: int) -> dict:
    h = Harness()
    lua = LuaRuntime(unpack_returned_tuples=True)
    core = load_core(lua, 'trail')
    f = lua.eval('function(g) return function(x) return g(x) end end')(f32)
    table = lambda values: lua.table_from([lua.table_from(list(v)) for v in values])  # noqa: E731
    rng = np.random.default_rng(0x1413248A0)
    report = {'subdivide': {'cases': 0, 'points': 0, 'empty': 0, 'differ': 0},
              'vertices': {'cases': 0, 'vertices': 0, 'differ': 0},
              'field': {'cases': 0, 'edges': 0, 'pushed': 0, 'drifting': 0, 'differ': 0}}
    field_check(h, lua, core, f, np.random.default_rng(0x14132C830), cases, report['field'])
    for case in range(cases):
        # Three samples: smooth motion, sharp turns, repeated points.
        base = random_sample(rng, 300)
        step = [[f32(x) for x in rng.normal(0, 30, 3)] for _ in range(2)]
        turn = [[f32(x) for x in rng.normal(0, 30 if case % 3 else 2, 3)] for _ in range(2)]
        a = base
        b = [[f32(a[e][c] + step[e][c]) for c in range(3)] for e in range(2)]
        c = [[f32(b[e][c2] + step[e][c2] + turn[e][c2]) for c2 in range(3)] for e in range(2)]
        if case % 17 == 0:
            c = [list(b[0]), list(b[1])]
        samples = [a, b, c] + [random_sample(rng, 300) for _ in range(int(rng.integers(0, 3)))]
        max_sub = int(rng.integers(1, 14))
        start_w, end_w = f32(rng.uniform(0, 2)), f32(rng.uniform(0, 2))
        width_scale = 1.0 if case % 2 else f32(rng.uniform(0, 1))
        native = h.run_subdivide(samples, 0, max_sub, start_w, end_w, width_scale, int(rng.integers(0, 64)))
        lua_samples = lua.table_from([table(s) for s in samples])
        ported = core.Subdivide(lua_samples, 0, max_sub, start_w, end_w, width_scale, f, lua.table())
        ported = [(tuple(p[1][k] for k in (1, 2, 3)), tuple(p[2][k] for k in (1, 2, 3))) for p in ported.values()]
        report['subdivide']['cases'] += 1
        report['subdivide']['points'] += len(native)
        report['subdivide']['empty'] += not native
        if len(native) != len(ported) or any(bits(x) != bits(y) for n, p in zip(native, ported)
                                             for e in range(2) for x, y in zip(n[e], p[e])):
            report['subdivide']['differ'] += 1
            if report['subdivide']['differ'] <= 3:
                print('subdivide differs:', case, len(native), len(ported), native[:1], ported[:1])
        # Vertices of a random ribbon.
        n = int(rng.integers(2, 40))
        points = [random_sample(rng, 400) for _ in range(n)]
        if case % 11 == 0:
            points = [points[0]] * n             # no length: t = 0
        colors = [[f32(x) for x in rng.uniform(0, 1, 4)] for _ in range(3)]
        split = 0.0 if case % 4 == 0 else f32(rng.uniform(0.01, 0.99))
        alpha = f32(rng.uniform(0, 1))
        rect = None if case % 5 == 0 else [f32(x) for x in rng.uniform(-1, 2, 8)]
        native_v = h.run_vertices(points, colors, split, alpha, rect)
        definition = lua.table_from({'colors': table(colors), 'colorSplit': split})
        state = lua.table_from({'points': lua.table_from([table(p) for p in points]), 'alpha': alpha})
        ported_v = core.Vertices(state, definition, lua.table_from(rect) if rect else None, f)
        ported_v = list(ported_v.values())
        report['vertices']['cases'] += 1
        report['vertices']['vertices'] += len(native_v)
        bad = len(native_v) != len(ported_v)
        for nv, pv in zip(native_v, ported_v):
            values = [(nv['position'][k], pv.position[k + 1]) for k in range(3)]
            values += [(nv['color'][k], pv.color[k + 1]) for k in range(4)]
            values += [(nv['u'], pv.u), (nv['v'], pv.v)]
            for x, y in values:
                if not ((math.isnan(x) and math.isnan(y)) or bits(x) == bits(f32(y))):
                    bad = True
        if bad:
            report['vertices']['differ'] += 1
            if report['vertices']['differ'] <= 3:
                print('vertices differ:', case, native_v[:2], [(v.position[1], v.color[1], v.u, v.v) for v in ported_v[:2]])
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--cases', type=int, default=3000)
    args = ap.parse_args()
    report = run(args.cases)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    s, v, ff = report['subdivide'], report['vertices'], report['field']
    print(f'subdivision 0x1413248a0: {s["cases"]} cases, {s["points"]} points ({s["empty"]} cases with none), {s["differ"]} differ')
    print(f'vertices 0x141325a50: {v["cases"]} ribbons, {v["vertices"]} vertices, {v["differ"]} differ')
    print(f'force field 0x14132c830: {ff["cases"]} cases, {ff["edges"]} sample edges ({ff["pushed"]} pushed inside the radius, '
          f'{ff["drifting"]} drifting on their velocity), {ff["differ"]} differ')
    print('WROTE:', OUT)
    ok = s['differ'] == 0 and v['differ'] == 0 and ff['differ'] == 0
    print('PASS: core/cl_trail.lua equals the game code, bit for bit' if ok else 'FAIL')
    sys.exit(0 if ok else 1)
