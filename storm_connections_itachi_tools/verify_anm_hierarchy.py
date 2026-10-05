"""Check the world matrix of every animated coordinate of every effect animation.

  python verify_anm_hierarchy.py [--addon game_cache/survey_addon] [packages ...]

StormFX.Core.AnmResource.CoordinateMatrices assembles the coordinate hierarchy of an effect
animation: each animated coordinate's local matrix under its parent's world matrix, a
parent the animation does not animate keeping its rest matrix (nuccCoord constructor)
under the effect root. This evaluates every animation of every package at three ticks
under a non-identity root, and checks that every coordinate entry received a world matrix
equal to an independent reference: the parent chain walked here, in Python, with the same
float32 product (StormFX.Core.AnmMatrix.World). The reference does not depend on the order
the engine visits the nodes in.

Why it exists (journal R97): the engine used to visit the nodes with pairs() while adding
the rest parents to the same table, which Lua leaves undefined; with some string-hash seeds
two coordinates of 3efbtf_2mkg2_blt00 were never resolved and the effect stopped with
"attempt to index a nil value (local 'm')".

Control: the same comparison with the parent links ignored must find differences (the
check sees the hierarchy).
"""

from __future__ import annotations

import argparse
import json
import math
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
from port_preview import ADDON, Port, capture_camera  # noqa: E402

OUT = ROOT / 'captured_assets' / 'procedural' / 'anm_hierarchy_check.json'


def f32(x: float) -> float:
    return struct.unpack('<f', struct.pack('<f', x))[0]


def root_matrix() -> list[float]:
    """A float32 rotation (30 degrees about z, 10 about x) with a translation."""
    a, b = math.radians(30.0), math.radians(10.0)
    rz = [[math.cos(a), -math.sin(a), 0.0], [math.sin(a), math.cos(a), 0.0], [0.0, 0.0, 1.0]]
    rx = [[1.0, 0.0, 0.0], [0.0, math.cos(b), -math.sin(b)], [0.0, math.sin(b), math.cos(b)]]
    r = [[sum(rz[i][k] * rx[k][j] for k in range(3)) for j in range(3)] for i in range(3)]
    t = [12.5, -40.25, 7.0]
    return [f32(v) for v in (r[0] + [t[0]] + r[1] + [t[1]] + r[2] + [t[2]] + [0.0, 0.0, 0.0, 1.0])]


def check_animation(lua, runtime, name: str, animation, root) -> dict:
    ok, compiled = lua.eval('function(f, n) return pcall(f, n) end')(runtime.models.CompiledFor, name)
    if not ok:
        return {'skipped': str(compiled)[:200]}
    c = compiled.compiled
    A = c.modules.animation
    M = c.modules.matrix
    f = c.options.float32
    instances = runtime.models.Instances(compiled)
    parent_of = {}
    for link in (animation.parents or {}).values():
        parent_of[f'{int(link[3])}:{int(link[4])}'] = f'{int(link[1])}:{int(link[2])}'
    duration = int(animation.duration_ticks)
    out = {'coordinates': 0, 'restParents': 0, 'missing': 0, 'differ': 0, 'controlDiffer': 0}
    for ticks in sorted({0, duration // 2, duration}):
        result = A.Evaluate(c, ticks, instances)
        contexts = lua.table()
        items = {}
        for key, entry in c.entries.items():
            if entry.type == 1:
                context = lua.table()
                context.parentMatrix = root
                context.translationScale = compiled.scales[key]
                contexts[key] = context
        A.CoordinateMatrices(c, result, contexts, root)
        for key, item in result.items():
            if item.type == 1:
                items[f'{int(item.clump)}:{int(item.bone)}'] = item

        def world(name: str, links: dict, cache: dict):
            if name in cache:
                return cache[name]
            item = items.get(name)
            local = item.localMatrix if item is not None else c.rest[name]
            if local is None:
                raise RuntimeError(f'{name}: neither animated nor with a rest matrix')
            parent = world(links[name], links, cache) if name in links else root
            cache[name] = M.World(parent, local, f)
            return cache[name]

        reference, control = {}, {}
        rest = {p for child, p in parent_of.items() if p not in items}
        out['restParents'] = max(out['restParents'], len(rest))
        for name, item in items.items():
            out['coordinates'] += 1
            if item.worldMatrix is None:
                out['missing'] += 1
                continue
            got = list(item.worldMatrix.values())
            if got != list(world(name, parent_of, reference).values()):
                out['differ'] += 1
            if got != list(world(name, {}, control).values()):
                out['controlDiffer'] += 1
    return out


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('packages', nargs='*', help='default: every package of the addon')
    ap.add_argument('--addon', type=Path, help='an addon folder with lua/storm_fx/packages (default: the project addon)')
    args = ap.parse_args()
    addon = (ROOT / args.addon) if args.addon and not args.addon.is_absolute() else (args.addon or ADDON)
    names = args.packages or sorted(p.stem for p in (addon / 'lua/storm_fx/packages').glob('*.lua'))
    totals = {'packages': 0, 'animations': 0, 'skipped': 0, 'coordinates': 0, 'withRestParents': 0,
              'missing': 0, 'differ': 0, 'controlDiffer': 0}
    report = {}
    for package in names:
        # One Lua state per package: a fresh state per package also varies the
        # string-hash seed the old traversal depended on.
        port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64),
                    packages=None if addon == ADDON else addon)
        lua = port.lua
        root = lua.table_from(root_matrix())
        runtime = port.load(package)
        if not runtime:
            print(f'{package}: not loadable')
            continue
        totals['packages'] += 1
        rows = {}
        for name, animation in sorted(runtime['data'].animations.items()):
            row = check_animation(lua, runtime, name, animation, root)
            rows[name] = row
            totals['animations'] += 1
            if 'skipped' in row:
                totals['skipped'] += 1
                continue
            for key in ('coordinates', 'missing', 'differ', 'controlDiffer'):
                totals[key] += row[key]
            totals['withRestParents'] += bool(row['restParents'])
            if row['missing'] or row['differ']:
                print(f'  FAIL {package} {name}: {row}')
        report[package] = rows
        bad = sum(r.get('missing', 0) + r.get('differ', 0) for r in rows.values())
        print(f'{package}: {len(rows)} animations, {sum(r.get("coordinates", 0) for r in rows.values())} coordinate '
              f'evaluations, {"FAIL" if bad else "ok"}')
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({'addon': str(addon), 'totals': totals, 'packages': report}, indent=1) + '\n', encoding='utf-8')
    print(json.dumps(totals))
    failed = totals['missing'] or totals['differ']
    blind = totals['coordinates'] and not totals['controlDiffer']
    if blind:
        print('CONTROL FAILED: ignoring the parent links changed nothing')
    print('FAIL' if failed or blind else 'PASS', '-', OUT)
    return 1 if failed or blind else 0


if __name__ == '__main__':
    sys.exit(main())
