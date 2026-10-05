"""Compare the engine's trail ribbons with the trail draws of the GPU captures.

  python verify_trail_capture.py [--package 4efb_amt1_x] [--effect 4efb_amt1_blt00]

The captures of Itachi's Amaterasu (frames 22082 and 22102) hold four trail draws, found
by the context only the trail command writes (key 0x1F007, g_commonParam.x = FLT_MIN;
replay_trail_draws.py exports them into gpu_captures/trail_draws.json): the two black
ribbons of 4efb_amt1_blt00 (the projectile), on the billboard 1efc_fire05. Checked:

  * render state: blend (colour and alpha), depth test and writes, culling, from the
    ribbon's state as render.lua derives it (control: the billboard model's NUD state,
    the rule before R98, must differ);
  * draw constants: g_commonParam, g_multColor, g_uvOffset0/1, g_blendRate;
  * texture size, topology (strip, two vertices per point);
  * geometry: the effect is played in the offline engine with its root travelling in a
    straight line at the captured step (12.5 a update; the captured path turns by less
    than 0.3 degree over a ribbon), oriented as the engine's skill actor orients the
    projectile (local -y forward; a root turned by 90 degrees would fit the ribbons 30
    updates away, see the point light below). Each captured ribbon, rotated into the captured
    direction of travel and moved onto its newest point, must match one ribbon the
    engine draws: its age (updates since launch) and trail follow from the best match,
    which must be clearly better than the ages one update away. Both ribbons of a frame
    must be the two trails at one age, and the two frames 20 updates apart. The match
    tests the field push (7.5 a update upward), the width profile, the edges and the
    rotation of the cross-section, not the travel itself (an input);
  * vertex colours and UVs, at that age: the engine's drawn values, and trail_core.vertices
    on the captured positions with the billboard frame the player picks for that age
    (control: the frame of the rule before R98, one update later, must not match);
  * point light: the effect's light (point-light slot 0 of the lit draws of the same frame,
    intensity -1) against the newest trail point, in the direction of travel: lateral
    offset within 0.1 and height within 0.05 of the engine's, which fixes the root's
    orientation independently of the ribbons; and its animated intensity, whose keys
    differ in the last bits, equal bit for bit at the fitted ages (an independent clock).

Not checked: absolute positions and direction (host inputs here), the sort order, the
sampler's mip filter, the start of a trail's life (both captures are in steady state).
"""

from __future__ import annotations

import argparse
import json
import math
import struct
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
from port_preview import Port, capture_camera  # noqa: E402

DRAWS = ROOT / 'gpu_captures' / 'trail_draws.json'
OUT = ROOT / 'captured_assets' / 'procedural' / 'trail_capture_check.json'
# Source BLEND_* / BLENDFUNC_* (render.lua FACTOR / OP) -> RenderDoc D3D11 names.
FACTOR = {0: 'Zero', 1: 'One', 2: 'DstCol', 3: 'InvDstCol', 4: 'SrcAlpha', 5: 'InvSrcAlpha', 6: 'DstAlpha',
          7: 'InvDstAlpha', 8: 'SrcAlphaSat', 9: 'SrcCol', 10: 'InvSrcCol'}
OP = {0: 'Add', 1: 'Subtract', 2: 'ReversedSubtract', 3: 'Minimum', 4: 'Maximum'}
POSITION_TOLERANCE = 1.0        # game units, after alignment (path curvature, see above)
MARGIN = 1.0                    # the next best age must be worse by at least this much


def f32(x: float) -> float:
    return struct.unpack('<f', struct.pack('<f', x))[0]


def byte(x: float) -> int:
    return int(math.floor(max(0.0, min(1.0, x)) * 255 + 0.5))


def lua_state(render, state) -> dict:
    s = render.State(state)
    args = [int(v) for v in s.blendArgs.values()]
    return {'blend': bool(s.blend), 'rgb': [FACTOR[args[0]], FACTOR[args[1]], OP[args[2]]],
            'alpha': [FACTOR[args[3]], FACTOR[args[4]], OP[args[5]]], 'depthWrites': bool(s.depthWrite),
            'cull': bool(s.cull), 'bucket': int(s.bucket)}


def captured_state(draw: dict) -> dict:
    b = draw['record']['blend'][0]
    name = lambda v: v.split('.')[-1]  # noqa: E731
    return {'blend': bool(b['enabled']), 'rgb': [name(b['rgb'][0]), name(b['rgb'][1]), name(b['rgb'][2])],
            'alpha': [name(b['alpha'][0]), name(b['alpha'][1]), name(b['alpha'][2])],
            'depthWrites': draw['depthStencil']['depthWrites'], 'cull': draw['rasterizer']['cull'] != 'CullMode.NoCull',
            'depthEnable': draw['depthStencil']['depthEnable'], 'depthFunction': draw['depthStencil']['function']}


def state_diff(port: dict, game: dict) -> list[str]:
    return [f'{k}: engine {port[k]}, game {game[k]}' for k in ('blend', 'rgb', 'alpha', 'depthWrites', 'cull') if port[k] != game[k]]


def captured_vertices(draw: dict) -> np.ndarray:
    n = draw['action']['numIndices']
    return np.frombuffer(bytes.fromhex(draw['vertices'][0]['raw_hex'])[:n * 64], dtype='<f4').reshape(-1, 16).astype(np.float64)


def strip_from_triangles(rows: np.ndarray) -> np.ndarray:
    """Strip vertices of a drawn ribbon (render.lua R.drawRibbon: triangles a c b, c d b)."""
    segments = len(rows) // 6
    out = []
    for k in range(segments):
        out += [rows[6 * k], rows[6 * k + 2]]
    out += [rows[6 * (segments - 1) + 1], rows[6 * (segments - 1) + 4]]
    return np.array(out)


def aligned(rows: np.ndarray, heading: float, anchor: np.ndarray) -> np.ndarray:
    c, s = math.cos(heading), math.sin(heading)
    out = rows @ np.array([[c, -s, 0], [s, c, 0], [0, 0, 1]]).T
    return out - (out[0] + out[1]) / 2 + anchor


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--package', default='4efb_amt1_x')
    ap.add_argument('--effect', default='4efb_amt1_blt00')
    ap.add_argument('--addon', type=Path, help='addon with the package (default: the project addon)')
    ap.add_argument('--updates', type=int, default=110, help='engine updates to play')
    args = ap.parse_args()
    draws = json.loads(DRAWS.read_text(encoding='utf-8'))
    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64),
                packages=(ROOT / args.addon) if args.addon else None)
    lua = port.lua
    g = lua.globals()
    runtime = port.load(args.package)
    data = runtime['data']
    trails = data.trails[args.effect] if data.trails else None
    if not trails:
        raise SystemExit(f'{args.package} has no trail for {args.effect} (re-import it)')
    render, core = g.StormFX.Render, g.StormFX.Core
    trail_core, curves, float32 = core.Trail, core.Curves, core.MaterialContext.Float32
    definitions = [trails[i] for i in range(1, len(trails) + 1)]
    report = {'package': args.package, 'effect': args.effect, 'draws': [], 'failures': []}
    fail = report['failures']

    # -- render state, constants, texture, topology ------------------------------
    board = data.resources[definitions[0].billboard].billboard
    mesh = definitions[0].draw.mesh
    compiled = {(e.name, int(e.component)): float(e.value) for e in mesh.shader.compiled.values() if int(e.row) == 0}
    alphas = {f32(board.channels[9][k][1]) for k in range(1, int(board.count) + 1)}
    for draw in draws:
        game = captured_state(draw)
        entry = {'frame': draw['frame'], 'event': draw['event'], 'game': game, 'engine': {}, 'controlNudState': {}}
        for d in definitions:
            engine = lua_state(render, d.draw.mesh.state)
            old = lua_state(render, data.models[d.draw.model].meshes[1].state)
            entry['engine'][int(d.index)], entry['controlNudState'][int(d.index)] = engine, old
            if state_diff(engine, game):
                fail.append(f'trail {d.index} vs {draw["frame"]}/{draw["event"]} state: ' + '; '.join(state_diff(engine, game)))
            if not state_diff(old, game):
                fail.append(f'control: the billboard NUD state also matches {draw["frame"]}/{draw["event"]}')
        if not game['depthEnable'] or game['depthFunction'] != 'CompareFunction.LessEqual':
            fail.append(f'{draw["frame"]}/{draw["event"]}: depth test {game["depthEnable"]} {game["depthFunction"]}')
        fields = draw['record']['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields']
        if len(alphas) != 1:
            fail.append(f'billboard alpha varies {sorted(alphas)}')
        # The player's per-draw values (player.lua ribbon entry): g_multColor white,
        # g_commonParam = (FLT_MIN, 1, 1, billboard channel 9).
        want = {'g_commonParam': [compiled.get(('g_commonParam', 0)), compiled.get(('g_commonParam', 1)), 1.0, next(iter(alphas))],
                'g_multColor': [1.0, 1.0, 1.0, 1.0],
                'g_uvOffset0': [compiled.get(('g_uvOffset0', c), 0.0) for c in range(4)],
                'g_uvOffset1': [0.0, 0.0, 1.0, 1.0], 'g_blendRate': [0.0, 0.0, 0.0, 0.0]}
        for name, values in want.items():
            if [f32(v) for v in values] != [f32(v) for v in fields[name]['values']]:
                fail.append(f'{draw["frame"]}/{draw["event"]} {name}: engine {values}, game {fields[name]["values"]}')
        size = [int(v) for v in mesh.textures[1].size.values()]
        info = draw['record']['textures'][0]['info']
        if size != [info['width'], info['height']]:
            fail.append(f'{draw["frame"]}/{draw["event"]} texture {size} vs {info["width"]}x{info["height"]}')
        if draw['topology'] != 'Topology.TriangleStrip' or draw['indexed'] or draw['action']['numIndices'] % 2:
            fail.append(f'{draw["frame"]}/{draw["event"]} topology {draw["topology"]} indexed {draw["indexed"]}')
        report['draws'].append(entry)

    # -- the engine's ribbons, root travelling straight at the captured step -------
    steps = []
    for draw in draws:
        v = captured_vertices(draw)
        mids = (v[0::2, 0:3] + v[1::2, 0:3]) / 2
        steps += list(np.linalg.norm(np.diff(mids[:, :2], axis=0), axis=1))
    step = float(np.mean(steps))
    report['capturedStep'] = step
    # The root as the engine's skill actor builds it for a projectile travelling along +x
    # (cast of 4efb_amt1_e_begin00: local -y forward, rows (0,-1,0) (1,0,0) (0,0,1)).
    move = lua.eval('''function(step) return function(a)
        local t=a.ticks/50
        a.root={0,-1,0,step*t,1,0,0,0,0,0,1,0,0,0,0,1}
    end end''')(step)
    instance = port.play(args.package, args.effect, (0.0, 0.0, 0.0), 0.0, 1.0, 1)
    instance.beforeUpdate = move
    drawn = []          # (age, trail index, strip rows: position, colour, uv)
    lights = {}         # age -> world position of the effect's point light (player.lua collectLights)
    intensities = {}    # age -> its intensity (an animated channel: a clock independent of the ribbons)
    clock = 0
    prefix = f'storm_fx_{port.fx.sVersion}_{args.package}_{args.effect}_trail'
    for _ in range(args.updates):
        clock += 1
        port.advance(clock)
        ages = {int(t['def'].index): int(t.updates) for s in instance.trailSets.values() for t in s.trails.values()}
        r = [float(x) for x in instance.root.values()]
        for item in (instance.provider.result or {}).values():
            if item.type == 6 and ages:
                x, y, z = (float(item.fields[k]) for k in (0x70, 0x74, 0x78))
                intensities[next(iter(ages.values()))] = f32(float(item.fields[0x60]))
                lights[next(iter(ages.values()))] = np.array([r[0] * x + r[1] * y + r[2] * z + r[3], r[4] * x + r[5] * y + r[6] * z + r[7],
                                                              r[8] * x + r[9] * y + r[10] * z + r[11]])
        for d in port.collect():
            if d.get('marker') or not str(d['material']).startswith(prefix):
                continue
            index = int(str(d['material'])[len(prefix):]) - 1      # player.lua: '_trail'..position (1-based)
            index = int(definitions[index].index)
            drawn.append((ages[index], index, strip_from_triangles(port.mesh(d['mesh']).astype(np.float64))))
    if not drawn:
        fail.append('the engine drew no ribbon')

    # Position error of every captured ribbon against every drawn one.
    errors = {}         # (draw number, age, trail) -> (error, rows)
    for n, draw in enumerate(draws):
        v = captured_vertices(draw)
        mids = (v[0::2, 0:3] + v[1::2, 0:3]) / 2
        heading = math.atan2(mids[0, 1] - mids[1, 1], mids[0, 0] - mids[1, 0])
        for age, index, rows in drawn:
            if len(rows) == len(v):
                errors[(n, age, index)] = (float(np.abs(aligned(rows[:, 0:3], heading, mids[0]) - v[:, 0:3]).max()), rows)
    # A single ribbon repeats (trails swapped or reversed) every 30 updates: the cross-section
    # turns 3 degrees an update and the two trails are perpendicular. The age is the one at
    # which both ribbons of a frame are the two trails, and the second frame 20 later.
    frames = sorted({d['frame'] for d in draws})
    by_frame = {f: [n for n, d in enumerate(draws) if d['frame'] == f] for f in frames}
    gaps = {f: int(f) - int(frames[0]) for f in frames}
    indices = sorted(int(d.index) for d in definitions)

    def frame_cost(f, age):
        best = None
        members = by_frame[f]
        for order in ([0, 1], [1, 0]) if len(members) == 2 else ([0],):
            cost, picks = 0.0, []
            for n, k in zip(members, order):
                e = errors.get((n, age, indices[k]))
                if e is None:
                    cost = None
                    break
                cost = max(cost, e[0])
                picks.append((n, indices[k]))
            if cost is not None and (best is None or cost < best[0]):
                best = (cost, picks)
        return best
    candidates = []
    for age in sorted({a for _, a, _ in errors}):
        parts = [frame_cost(f, age + gaps[f]) for f in frames]
        if all(parts):
            candidates.append((max(p[0] for p in parts), age, parts))
    candidates.sort(key=lambda c: c[0])
    ages = {}
    if not candidates:
        fail.append('no engine age matches the captured ribbons')
    else:
        cost, age, parts = candidates[0]
        others = [c[0] for c in candidates if c[1] != age]
        report['ageFit'] = {'age': age, 'error': cost, 'nextBest': min(others) if others else None,
                            'nextBestAge': next((c[1] for c in candidates if c[1] != age), None)}
        if cost > POSITION_TOLERANCE:
            fail.append(f'best engine age {age}: ribbons {cost:.3f} away')
        if not others or min(others) < cost + MARGIN:
            fail.append(f'age not determined: {age} at {cost:.3f}, next {report["ageFit"]["nextBestAge"]} at {min(others) if others else None}')
        for f, part in zip(frames, parts):
            for n, index in part[1]:
                a = age + gaps[f]
                ages.setdefault(f, []).append((a, index))
                report['draws'][n].update({'age': a, 'trail': index, 'positionError': errors[(n, a, index)][0]})
    for n, (draw, entry) in enumerate(zip(draws, report['draws'])):
        if 'age' not in entry:
            continue
        age, index = entry['age'], entry['trail']
        v = captured_vertices(draw)
        rows = errors[(n, age, index)][1]
        # Colours (8 bits, as Source keeps them) and UVs the engine draws at that age; its
        # UVs follow its own arc lengths, which differ from the captured ones with the
        # positions (see the routine check below for exact values).
        bad = [k for k in range(len(v)) if [byte(c) for c in rows[k, 3:7]] != [byte(c) for c in v[k, 8:12]]
               or np.abs(rows[k, 7:9] - v[k, 12:14]).max() > 1e-3]
        entry['drawnAttributeMismatches'] = len(bad)
        entry['drawnUvMaxError'] = float(np.abs(rows[:, 7:9] - v[:, 12:14]).max())
        if bad:
            k = bad[0]
            fail.append(f'{draw["frame"]}/{draw["event"]}: vertex {k} engine colour/uv {rows[k, 3:9].round(5).tolist()}, '
                        f'game {v[k, 8:14].round(5).tolist()}')
        # trail_core.vertices on the captured positions, billboard frame of that age.
        points = lua.table_from([lua.table_from([lua.table_from([float(x) for x in v[2 * k, 0:3]]),
                                                 lua.table_from([float(x) for x in v[2 * k + 1, 0:3]])]) for k in range(len(v) // 2)])
        state = lua.table()
        state.points, state.alpha = points, 1.0

        def attributes(updates):
            keys = curves.BillboardFromParticle(board, updates)[0]
            rect = lua.table_from([keys[5][1], keys[5][2], keys[6][1], keys[6][2], keys[10][1], keys[10][2], keys[11][1], keys[11][2]])
            out = list(trail_core.Vertices(state, definitions[index], rect, float32).values())
            colour = max(abs(float(c) - v[i, 8 + j]) for i, x in enumerate(out) for j, c in enumerate(x.color.values()))
            uv = max(max(abs(float(x.u) - v[i, 12]), abs(float(x.v) - v[i, 13])) for i, x in enumerate(out))
            return colour, uv
        colour_error, uv_error = attributes(age - 1)          # the player's frame (player.lua: t.updates-1)
        _, control = attributes(age)                          # the rule before R98, one frame later
        entry.update({'routineColourError': colour_error, 'routineUvError': uv_error, 'controlPreviousFrameUvError': control})
        if colour_error or uv_error:
            fail.append(f'{draw["frame"]}/{draw["event"]}: trail_core.vertices on the captured points: colour {colour_error}, uv {uv_error}')
        if control == 0:
            fail.append(f'{draw["frame"]}/{draw["event"]}: control frame also matches')
    # The effect's point light against the newest trail point, in the frame of travel.
    intensity = radii = None
    for item in (instance.provider.result or {}).values():
        if item.type == 6:
            intensity, radii = float(item.fields[0x60]), (f32(float(item.fields[0x88])), f32(float(item.fields[0x8c])))
    report['light'] = {}
    for f in frames:
        n = by_frame[f][0]
        entry = report['draws'][n]
        if 'age' not in entry or intensity is None or entry['age'] not in lights:
            fail.append(f'frame {f}: no engine light or age to compare')
            continue
        records = json.loads((ROOT / 'gpu_captures' / f'itachi_amaterasu_frame{f}.all_draws.json').read_text(encoding='utf-8'))
        light = None
        for record in records:
            fields = record['constants'].get('ShaderStage.Vertex', {}).get('perMaterialBuffer', {}).get('fields', {})
            for slot in range(4):
                p = fields.get(f'g_pointLightParam{slot}')
                # The light by its intensity (an animated value: -0.99999994 at 22102) and radii.
                if p and abs(p['values'][0] - intensity) < 1e-4 and (f32(p['values'][1]), f32(p['values'][2])) == radii:
                    light = np.array(fields[f'g_pointLightPos{slot}']['values'][:3], dtype=np.float64)
                    captured_intensity = f32(p['values'][0])
                    break
            if light is not None:
                break
        if light is None:
            fail.append(f'frame {f}: no captured point light of intensity {intensity}')
            continue
        v = captured_vertices(draws[n])
        mids = (v[0::2, 0:3] + v[1::2, 0:3]) / 2
        h = math.atan2(mids[0, 1] - mids[1, 1], mids[0, 0] - mids[1, 0])
        d = light - mids[0]
        game = [d[0] * math.cos(h) + d[1] * math.sin(h), -d[0] * math.sin(h) + d[1] * math.cos(h), d[2]]
        rows = errors[(n, entry['age'], entry['trail'])][1]
        e = lights[entry['age']] - (rows[0, 0:3] + rows[1, 0:3]) / 2          # the engine travels along +x
        report['light'][f] = {'game': [round(x, 4) for x in game], 'engine': [round(float(x), 4) for x in e],
                              'intensityGame': captured_intensity, 'intensityEngine': intensities.get(entry['age'])}
        # The intensity channel's keys differ in the last bits from key to key: the engine
        # must give the captured value bit for bit at the fitted age.
        if intensities.get(entry['age']) != captured_intensity:
            fail.append(f'frame {f}: light intensity at age {entry["age"]}: engine {intensities.get(entry["age"])}, game {captured_intensity}')
        if abs(game[1] - e[1]) > 0.1 or abs(game[2] - e[2]) > 0.05:
            fail.append(f'frame {f}: light - newest trail point (ahead, side, up) game {np.round(game, 3).tolist()}, '
                        f'engine {np.round(e, 3).tolist()}')
    for frame, found in ages.items():
        if len({a for a, _ in found}) != 1 or sorted(i for _, i in found) != list(range(len(definitions))):
            fail.append(f'frame {frame}: ribbons at ages/trails {found}, expected every trail at one age')
    if {'22082', '22102'} <= set(ages) and ages['22102'][0][0] - ages['22082'][0][0] != 20:
        fail.append(f'ages {ages}: the captures are 20 frames apart')
    report['ages'] = ages
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=1, default=str) + '\n', encoding='utf-8')
    for e in report['draws']:
        print(f"{e['frame']}/{e['event']}: trail {e.get('trail')} age {e.get('age')}, position error {e.get('positionError', 0):.3f}, "
              f"drawn colour/uv mismatches {e.get('drawnAttributeMismatches')} (uv max {e.get('drawnUvMaxError', 0):.2e}), "
              f"routine colour/uv error {e.get('routineColourError')}/{e.get('routineUvError')}, "
              f"previous-frame control uv error {e.get('controlPreviousFrameUvError')}")
    print('captured step', round(step, 4), 'ages', ages, 'fit', report.get('ageFit'))
    print('light - newest trail point (ahead, side, up):', report['light'])
    for line in fail:
        print('  FAIL', line)
    print('FAIL' if fail else 'PASS', '-', OUT)
    return 1 if fail else 0


if __name__ == '__main__':
    sys.exit(main())
