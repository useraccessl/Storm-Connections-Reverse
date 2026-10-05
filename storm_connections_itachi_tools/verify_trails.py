"""Check the trail wiring of the engine (storm_fx/ engine/cl_trails.lua, cl_draw.lua,
cl_render.lua) against the game's code.

  python verify_trails.py [--package 1efcmn_x] [--addon game_cache/survey_addon] [--frames 150]

The trail routines themselves (core/cl_trail.lua) are checked by verify_trail_native.py. This
script checks what the engine does around them, on a package imported with trails:

  * edges: every edge of every trail resolves to at most one coordinate entry of its
    animation, by (parent clump instance, name), else by name alone (0x14132b3f0); the
    names are instance names, so the edge must be an entry target. An edge the animation
    lacks makes an inert trail in the game too (0x141325090 returns at once on a null
    edge): those are listed, not failed;
  * motion: the effect root turns and travels along a circle (a host input, as the actor
    moves it in a skill), so the trails of an effect's own animation draw too;
  * drawing: every effect that carries trails (its own animation, or the animation of an
    emitter's resource) is played in the offline engine (port_preview.Port). At sampled
    frames each ribbon the player draws is rebuilt independently: the trail's ribbon
    points go through the game's vertex routine 0x141325a50 (run natively,
    verify_trail_native.Harness) with the UV values of the billboard frame the game shows
    after that many updates (0x1412c7b00 copies frame floor(clock / step), then the clock
    advances by 50 and wraps or holds at the end, one call fewer than updates of the effect
    as the capture of 4efb_amt1_blt00 shows (R98); channels 5 / 6 / 10 / 11, else the
    defaults of 0x1412c8110), taken into the GMod world by the effect's outer transform
    and expanded into the strip's triangles (a, c, b), (c, d, b). The drawn mesh must
    equal it: positions to 1e-6, colours to the 8 bits Source keeps, texture coordinates
    exactly. The number of ribbon draws must equal the number of trails with two points
    or more.

What this does not check: the render state and the layer of the ribbon (see
storm_import.py Importer.ribbon and verify_trail_capture.py), the release timing against a
capture, pixels.
"""

from __future__ import annotations

import argparse
import json
import math
import sys
from pathlib import Path

import numpy as np

from port_preview import Port, capture_camera
from verify_trail_native import Harness

ROOT = Path(__file__).resolve().parent
OUT = ROOT / 'captured_assets' / 'procedural' / 'trail_wiring_verification.json'


def values(table) -> list:
    return list(table.values()) if table is not None else []


def edge_entries(animation, edge) -> list[int]:
    """Keys of the coordinate entries an edge matches: (parent, name) first, then name."""
    named = []
    clumps = values(animation.clumps)
    for key, entry in animation.entries.items():
        if entry.type == 1 and entry.target == edge.coord:
            named.append((key, entry))
    exact = [k for k, e in named if edge.parent and e.clump_index is not None and e.clump_index >= 0
             and e.clump_index < len(clumps) and clumps[e.clump_index].name == edge.parent]
    return exact or [k for k, _ in named]


CONTROL = {'shift': 0}      # --control: one update more, to show a wrong frame is caught


def board_frame(board, updates: int) -> int:
    """Frame of the billboard's keys a trail shows after `updates` updates of its effect: one
    billboard update fewer (capture of 4efb_amt1_blt00, journal R98)."""
    count, step = int(board.count), int(board.stepTicks)
    total, clock, frame = count * step, 0, 0
    for _ in range(updates - 1 + CONTROL['shift']):
        index = clock // step
        if index < count:
            frame = index
        clock += 50
        if clock >= total:
            clock = clock % total if board.loop else total
    return frame


def rect_of(board, updates: int) -> list[float]:
    if board is None or updates < 1:
        return [0.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0]
    frame = board_frame(board, updates)

    def key(channel, default):
        keys = board.channels[channel] if board.channels else None
        if keys is None:
            return default
        rows = values(keys)
        return values(rows[min(frame, len(rows) - 1)])
    out = []
    for channel, default in ((5, [0.0, 0.0]), (6, [1.0, 1.0]), (10, [0.0, 0.0]), (11, [1.0, 1.0])):
        out += [float(x) for x in key(channel, default)]
    return out


def outer_matrix(outer) -> np.ndarray:
    c, s, k = math.cos(math.radians(outer.yaw)), math.sin(math.radians(outer.yaw)), float(outer.scale)
    return np.array([[c * k, -s * k, 0, outer.pos.x], [s * k, c * k, 0, outer.pos.y], [0, 0, k, outer.pos.z], [0, 0, 0, 1]])


def quantise(x: float) -> float:
    return math.floor(max(0.0, min(255.0, min(1.0, max(0.0, x)) * 255)) + 0.5) / 255


def expected_triangles(harness: Harness, trail, outer: np.ndarray) -> np.ndarray:
    state, d = trail.state, trail['def']
    points = [(values(p[1]), values(p[2])) for p in values(state.points)]
    colors = [values(c) for c in values(d.colors)]
    board = trail.board.billboard if trail.board else None
    native = harness.run_vertices(points, colors, float(d.colorSplit), float(state.alpha), rect_of(board, int(trail.updates)))
    rows = []
    for v in native:
        p = outer @ np.array([*v['position'], 1.0])
        rows.append([p[0], p[1], p[2], *(quantise(c) for c in v['color']), v['u'], v['v']])
    rows = np.array(rows)
    order = []
    for k in range(len(points) - 1):
        a, b, c, e = 2 * k, 2 * k + 1, 2 * k + 2, 2 * k + 3
        order += [a, c, b, c, e, b]
    return rows[order]


def drawn_rows(port: Port, draw: dict) -> np.ndarray:
    mesh = port.mesh(draw['mesh'])
    return np.column_stack([mesh[:, 0:3], mesh[:, 3:7], mesh[:, 7:9]]).astype(np.float64)


def effects_with_trails(data) -> list[str]:
    trails = set(data.trails.keys()) if data.trails else set()
    found = []
    for name in sorted(data.effects.keys()):
        emitters = data.effects[name]
        carried = name in trails
        for e in values(emitters):
            for r in values(e.resources):
                res = data.resources[r]
                carried = carried or (res is not None and res.kind == 'anm' and res.animation in trails)
        if carried and data.animations[name]:
            found.append(name)
    for name in sorted(trails):
        if name not in found and data.animations[name] and not data.effects[name]:
            found.append(name)
    return found


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--package', default='1efcmn_x')
    ap.add_argument('--addon', type=Path, default=ROOT / 'game_cache' / 'survey_addon')
    ap.add_argument('--frames', type=int, default=150)
    ap.add_argument('--every', type=int, default=7)
    ap.add_argument('--effects', type=int, default=6, help='at most this many effects')
    ap.add_argument('--control', action='store_true', help='negative control: expect the frame one update later (must FAIL)')
    args = ap.parse_args()
    CONTROL['shift'] = 1 if args.control else 0
    root = [209.65, -476.38, -0.68]
    port = Port(dict(capture_camera(22136), yaw=0.0), root, (1920, 1080), packages=args.addon)
    runtime = port.load(args.package)
    data = runtime.data
    # The effect root turns and travels on a circle of radius 60 (game units), one degree a
    # tick-update; the player calls beforeUpdate before every update of the animation.
    move = port.lua.eval('''function(a)
        local t=a.ticks/50
        local angle=math.rad(t*6)
        local c,s=math.cos(angle),math.sin(angle)
        a.root={c,-s,0,60*c,s,c,0,60*s,0,0,1,10,0,0,0,1}
    end''')
    report = {'package': args.package, 'control': args.control, 'edges': {'checked': 0, 'unresolved': [], 'ambiguous': []},
              'effects': {}, 'ribbons': 0, 'vertices': 0, 'differ': 0, 'count_mismatch': 0, 'failures': [],
              'animated_uv_billboards': []}
    for name, defs in (data.trails.items() if data.trails else []):
        for d in values(defs):
            board = data.resources[d.billboard]
            channels = board.billboard.channels if board and board.billboard else None
            moving = [c for c in (5, 6, 10, 11) if channels and channels[c] is not None
                      and len({tuple(values(k)) for k in values(channels[c])}) > 1]
            if moving and d.billboard not in report['animated_uv_billboards']:
                report['animated_uv_billboards'].append(d.billboard)
    print('trail billboards with animated UV channels:', report['animated_uv_billboards'])
    report['fields'] = {'checked': 0, 'resolved': 0, 'at_origin': []}
    for name, defs in (data.trails.items() if data.trails else []):
        animation = data.animations[name]
        for d in values(defs):
            for field in (values(d.fields) if d.fields else []):
                report['fields']['checked'] += 1
                if animation and field.coord and edge_entries(animation, field):
                    report['fields']['resolved'] += 1
                else:
                    report['fields']['at_origin'].append(f'{name}: {field.coord} ({field.parent})')
            for edge in values(d.edges):
                report['edges']['checked'] += 1
                keys = edge_entries(animation, edge) if animation else []
                if not keys:
                    report['edges']['unresolved'].append(f'{name}: {edge.coord} ({edge.parent})')
                elif len(keys) > 1:
                    report['edges']['ambiguous'].append(f'{name}: {edge.coord} ({edge.parent}) -> {keys}')
    harness = Harness()
    clock = 0       # the host time never runs backwards between two effects
    for effect in effects_with_trails(data)[:args.effects]:
        port.stop()
        instance = port.play(args.package, effect, root, 30.0, 64 / 119, 1)
        if isinstance(instance, tuple) or instance is None:
            report['effects'][effect] = {'error': f'not launched: {instance}'}
            continue
        instance.beforeUpdate = move
        matrix = outer_matrix(instance.outer)
        row = {'frames': 0, 'ribbons': 0, 'vertices': 0, 'differ': 0, 'max_position_error': 0.0}
        for frame in range(args.frames):
            clock += 1
            port.advance(clock)
            row['frames'] = frame + 1
            if frame % args.every:
                continue
            draws = [d for d in port.collect() if not d.get('marker') and '_trail' in d['material']]
            expected = []
            for s in values(instance.trailSets):
                for t in values(s.trails):
                    # Samples a force field has set moving (velocity not zero).
                    for sample in values(t.state.samples):
                        if sample.velocity and any(any(v != 0 for v in values(e)) for e in values(sample.velocity)):
                            report['fields']['moved_samples'] = report['fields'].get('moved_samples', 0) + 1
                    if len(values(t.state.points)) > 1 and runtime.ribbons[t['def']] is not None:
                        expected.append(expected_triangles(harness, t, matrix))
            if len(draws) != len(expected):
                row['count_mismatch'] = row.get('count_mismatch', 0) + 1
                report['count_mismatch'] += 1
                report['failures'].append(f'{effect} frame {frame}: {len(draws)} ribbon draws, {len(expected)} trails with points')
            pool = list(expected)
            for d in draws:
                got = drawn_rows(port, d)
                best, best_error = None, None
                for i, rows in enumerate(pool):
                    if rows.shape != got.shape:
                        continue
                    error = float(np.max(np.abs(rows[:, :3] - got[:, :3])))
                    if best_error is None or error < best_error:
                        best, best_error = i, error
                row['ribbons'] += 1
                row['vertices'] += got.shape[0]
                if best is None:
                    row['differ'] += 1
                    report['failures'].append(f'{effect} frame {frame}: a ribbon of {got.shape[0]} vertices matches no trail')
                    continue
                rows = pool.pop(best)
                scale = max(1.0, float(np.max(np.abs(rows[:, :3]))))
                row['max_position_error'] = max(row['max_position_error'], best_error / scale)
                # The preview keeps the mesh in float32 (port_preview.Port.mesh): positions are
                # compared to float32 precision, colours and UVs as float32 values.
                single = rows.astype(np.float32)
                wrong = {'position': best_error > 1e-6 * scale,
                         'colour': not np.array_equal(single[:, 3:7], got[:, 3:7].astype(np.float32)),
                         'uv': not np.array_equal(single[:, 7:9], got[:, 7:9].astype(np.float32))}
                if any(wrong.values()):
                    row['differ'] += 1
                    if len(report['failures']) < 12:
                        k = int(np.argmax(np.any(single != got.astype(np.float32), axis=1)))
                        report['failures'].append(f'{effect} frame {frame}: {[w for w, v in wrong.items() if v]} vertex {k} '
                                                  f'expected {rows[k].round(5).tolist()} drawn {got[k].round(5).tolist()}')
        report['effects'][effect] = row
        report['ribbons'] += row['ribbons']
        report['vertices'] += row['vertices']
        report['differ'] += row['differ']
        print(f'{effect}: {row["frames"]} frames, {row["ribbons"]} ribbons, {row["vertices"]} vertices, {row["differ"]} differ, '
              f'max position error {row["max_position_error"]:.2e}', flush=True)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    edges = report['edges']
    print(f'edges: {edges["checked"]} checked, {len(edges["unresolved"])} not in their animation (inert trails, '
          f'as in the game), {len(edges["ambiguous"])} ambiguous')
    for line in edges['unresolved'][:5]:
        print('   inert:', line)
    fields = report['fields']
    if fields['checked']:
        print(f'force fields: {fields["checked"]}, {fields["resolved"]} on a coordinate of their animation, '
              f'{len(fields["at_origin"])} at the origin; samples seen moved by a field: {fields.get("moved_samples", 0)}')
    for line in edges['ambiguous'][:5] + report['failures'][:12]:
        print('  ', line)
    print(f'ribbons: {report["ribbons"]} drawn, {report["vertices"]} vertices, {report["differ"]} differ, '
          f'{report["count_mismatch"]} frames with a count mismatch')
    print('WROTE:', OUT)
    ok = report['ribbons'] > 0 and not report['differ'] and not report['count_mismatch'] and not edges['ambiguous']
    print('PASS: the drawn ribbons equal the game\'s vertex routine on the trails the player keeps' if ok else 'FAIL')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
