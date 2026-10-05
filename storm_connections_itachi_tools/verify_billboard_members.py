"""Check, offline on real data, how the engine draws the models of an animation that
face the camera: billboard members of an animated clump and models whose header
attribute bit 0 is set.

The game (journal R85): the model draw callback 0x1412d1870 applies slot +68 of a
model with header attribute bit 0 once per draw: nuccModel 0x1412d4f40 replaces the
rotation of the world matrix by the camera's and keeps the axis lengths and the
translation; nuccBillboard 0x1412c84b0 also applies its roll, its size (axes x, y)
and its position offset (verify_facing_native.py runs both against facing_core.lua).
A billboard member's clock is advanced by the animation's delta (0x1412c7f90: wraps
when the chunk loops, else stops on the total) and the keys of frame
floor(ticks / step) are copied after the advance (0x1412c7b00): material fields
(draw 0x1412c7dd0), opacity (+A0), offset, roll and size.

Here every animation of the given packages that draws such a model is played in the
engine (lupa, GMod stubs of port_preview.py, camera of capture 22136) and every draw
of those models is compared with what this file computes from the package data:
the world matrix (the coordinate's animated matrix from the engine's evaluator, then
the hook written out here with numpy), the UV set 0 offset / scale, the alpha
threshold and the alpha. No pixel is checked, nothing runs in Garry's Mod.

  python verify_billboard_members.py [package ...]
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

from game_data import GameData
from port_preview import Port, capture_camera
from storm_import import Importer

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
FRAMES = 90
DEFAULT = ['3mdr_2_x', 'cw0_x', '7brn_x', '2nej_x', '4efb_2hnt1_x', '3efbtf_2sin1_x', '1efcmn_x']


def matrix(values) -> np.ndarray:
    return np.array([values[i] for i in range(1, 17)], dtype=np.float64).reshape(4, 4)


def ensure(game: GameData, stem: str) -> None:
    path = SCRATCH / 'lua/storm_fx/packages' / f'{stem}.lua'
    if not path.exists() or '["billboards"]' not in path.read_text(encoding='utf-8'):
        importer = Importer(game, stem, SCRATCH)
        importer.skill_file(f'data/skill/{stem}.xfbin')
        importer.write()


def billboard_frame(board, ticks: int) -> int:
    count, step = board.count, board.stepTicks
    total = count * step
    if ticks >= total:
        ticks = ticks % total if board.loop else total
    return min(ticks // step, count - 1)


def key(board, channel: int, frame: int):
    keys = board.channels[channel] if board.channels else None
    if not keys:
        return None
    values = list(keys.values())
    return [values[min(frame, len(values) - 1)][i] for i in range(1, len(list(values[0].values())) + 1)]


def check_package(game: GameData, stem: str, control: bool = False) -> dict:
    """control: play with the engine's facing hook switched off (negative control)."""
    ensure(game, stem)
    camera = capture_camera(22136)
    right, up = np.asarray(camera['right'], dtype=np.float64), np.asarray(camera['up'], dtype=np.float64)
    normal = np.cross(right, up)
    probe = Port(dict(camera, yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
    data = probe.load(stem).data
    wanted = {}
    for name, animation in data.animations.items():
        if not animation or not animation.clumps:
            continue
        for index, clump in animation.clumps.items():
            for model_name in (clump.drawn.values() if clump.drawn else []):
                model = data.models[model_name]
                board = clump.billboards[model_name] if clump.billboards else None
                if model and (board or model.header.attributes % 2 == 1):
                    wanted.setdefault(name, []).append((index - 1, model_name, board))
    report = {'package': stem, 'animations': {}, 'not_played': {}}
    for effect, members in sorted(wanted.items()):
        port = Port(dict(camera, yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
        runtime = port.load(stem)
        if control:
            for item in runtime['items'].values():
                item.facing = False
        data = runtime.data
        instance = port.play(stem, effect, (0.0, 0.0, 0.0), 0.0, 1.0, 1)
        if not instance or isinstance(instance, tuple):
            report['not_played'][effect] = str(instance[1] if isinstance(instance, tuple) else instance)
            continue
        animation = data.animations[effect]
        materials = {part.mat.name: (item.name, index) for item in runtime['items'].values() for index, part in item.parts.items()}
        # Batched parts: their model-space vertices in the order a draw sends them (triangles,
        # 0-based indices), as homogeneous rows
        port.lua.globals().StormFX.Config['batchParticles'] = False
        batched = {}
        for item in runtime['items'].values():
            for part in item.parts.values():
                if part.batched:
                    triangles = [tuple(t.values()) for t in part.mesh.triangles.values()]
                    corners = port.lua.globals().StormFX.Render.Quad(part.mesh)
                    if corners and port.lua.globals().StormFX.Render.useQuads:
                        # Sent as one quad, split by Source as (q0, q1, q2), (q0, q2, q3): the
                        # same two triangles, each with its winding (any starting corner)
                        q = list(corners.values())
                        split = [(q[0], q[1], q[2]), (q[0], q[2], q[3])]
                        rotations = lambda t: {t, t[1:] + t[:1], t[2:] + t[:2]}
                        assert all(any(s in rotations(t) for t in triangles) for s in split) and len(triangles) == 2, \
                            (part.mat.name, triangles, q)
                        triangles = split
                    rows = [part.mesh.vertices[i + 1] for t in triangles for i in t]
                    batched[part.mat.name] = np.array([[r[1], r[2], r[3], 1.0] for r in rows], dtype=np.float64)
        names = {m for _, m, _ in members}
        row = {'models': sorted(names), 'billboards': sorted({m for _, m, b in members if b}), 'draws': 0, 'frames_seen': [],
               'worst_matrix': 0.0, 'worst_constant': 0.0, 'other_draws': 0}
        for frame in range(FRAMES):
            port.advance(frame)
            failed = port.field('tFailed', 'failed')
            if list(failed.keys()):
                report['not_played'][effect] = str(dict(failed.items()))
                break
            result = instance.provider.result
            if result is None:
                continue
            draws = [d for d in port.collect() if not d.get('marker') and d['material'] in materials
                     and materials[d['material']][0] in names]
            if not draws:
                continue
            ticks = int(instance.ticks)
            poses, animated = {}, {}
            for k, item in result.items():
                entry = animation.entries[k]
                if item.type == 1:
                    poses[(entry.clump_index, entry.chunk or entry.target)] = (matrix(item.worldMatrix), item)
                elif item.type == 4:
                    animated[(entry.clump_index, entry.chunk or entry.target)] = item.instance
            for draw in draws:
                model_name, part_index = materials[draw['material']]
                model = data.models[model_name]
                best = None
                for clump_index, member, board in members:
                    if member != model_name:
                        continue
                    clump = animation.clumps[clump_index + 1]
                    bone = clump.coords[model.header.bone + 1] if clump.coords else None
                    pose = poses.get((clump_index, bone))
                    world = pose[0] if pose else matrix(instance.root)
                    lengths = np.linalg.norm(world[:3, :3], axis=0)
                    axes, size, offset, roll = [right, up], [1.0, 1.0], np.zeros(3), 0
                    alpha = 1.0
                    if pose is not None:
                        channels = pose[1].channels
                        alpha = float(channels[3][1]) if channels and channels[3] else 1.0
                    else:
                        alpha = float(model.node.opacity) if model.node else 1.0
                    material = model.materials[model.meshes[part_index].material + 1]
                    base = animated.get((clump_index, material.name)) or material.instance
                    uv0 = [base[0x30], base[0x34], base[0x50], base[0x54]]
                    threshold = base[0x80]
                    frame_index = None
                    if board:
                        frame_index = billboard_frame(board, ticks)
                        size = key(board, 3, frame_index) or size
                        offset = np.array(key(board, 1, frame_index) or [0.0, 0.0, 0.0])
                        roll = list(board.rolls.values())[min(frame_index, len(list(board.rolls.values())) - 1)] if board.rolls else 0
                        opacity = key(board, 4, frame_index)
                        alpha *= opacity[0] if opacity else 1.0
                        k5, k6, k12 = key(board, 5, frame_index), key(board, 6, frame_index), key(board, 12, frame_index)
                        uv0 = (k5 or uv0[0:2]) + (k6 or uv0[2:4])
                        threshold = k12[0] / 255 if k12 else threshold
                    angle = float(np.float32(np.float32(roll * np.float32(6.2831854820251465)) * np.float32(1.52587890625e-05)))
                    c, s = np.cos(angle), np.sin(angle)
                    x, y = right * c + up * s, -right * s + up * c
                    expected = np.eye(4)
                    expected[:3, 0] = x * lengths[0] * size[0]
                    expected[:3, 1] = y * lengths[1] * size[1]
                    expected[:3, 2] = normal * lengths[2]
                    expected[:3, 3] = world[:3, 3] + offset
                    if draw['material'] in batched:
                        # A batched part is drawn under the identity, its vertices placed in the
                        # world by the engine (one particle a draw here): compare the vertices
                        drawn = port.mesh(draw['mesh'])[:, :3].astype(np.float64)
                        placed = batched[draw['material']] @ expected.T
                        m_error = float(np.abs(drawn - placed[:, :3]).max() / max(1.0, np.abs(placed[:, :3]).max()))
                    else:
                        m_error = float(np.abs(draw['matrix'] - expected).max() / max(1.0, np.abs(expected).max()))
                    named = port.named(draw)
                    sent_uv0, sent_common = named.get('g_uvOffset0'), named.get('g_commonParam')
                    c_error = 0.0
                    if sent_uv0 and None not in sent_uv0:
                        c_error = max(c_error, float(np.abs(np.array(sent_uv0) - uv0).max()))
                    if sent_common and sent_common[0] is not None:
                        c_error = max(c_error, abs(sent_common[0] - threshold))
                    if sent_common and sent_common[1] is not None:
                        c_error = max(c_error, abs(sent_common[1] - alpha))
                    if best is None or m_error + c_error < best[0] + best[1]:
                        best = (m_error, c_error, frame_index)
                if best is None:
                    row['other_draws'] += 1
                    continue
                row['draws'] += 1
                row['worst_matrix'] = max(row['worst_matrix'], best[0])
                row['worst_constant'] = max(row['worst_constant'], best[1])
                if best[2] is not None and best[2] not in row['frames_seen']:
                    row['frames_seen'].append(best[2])
        if effect not in report['not_played']:
            report['animations'][effect] = row
    return report


if __name__ == '__main__':
    game = GameData()
    failures, reports = 0, []
    for stem in sys.argv[1:] or DEFAULT:
        report = check_package(game, stem)
        reports.append(report)
        for effect, row in report['animations'].items():
            ok = row['draws'] > 0 and row['worst_matrix'] < 1e-5 and row['worst_constant'] < 1e-5
            failures += not ok
            print(f'{stem} / {effect}: models {row["models"]} (billboards {row["billboards"]}): {row["draws"]} draws, '
                  f'billboard frames seen {sorted(row["frames_seen"])[:12]}; largest difference: matrix {row["worst_matrix"]:.1e} '
                  f'(relative), constants {row["worst_constant"]:.1e} {"ok" if ok else "MISMATCH"}')
        for effect, why in report['not_played'].items():
            print(f'{stem} / {effect}: not played ({why})')
    # Negative control: the same check with the engine's facing hook off must fail.
    stem = next(r['package'] for r in reports if r['animations'])
    control = check_package(game, stem, control=True)
    control_worst = max(row['worst_matrix'] for row in control['animations'].values())
    print(f'negative control ({stem}, facing hook off in the engine): largest matrix difference {control_worst:.2e} '
          f'{"(detected)" if control_worst > 1e-3 else "NOT DETECTED"}')
    failures += control_worst <= 1e-3
    target = ROOT / 'captured_assets' / 'billboard_member_check.json'
    target.write_text(json.dumps({'packages': reports, 'negativeControl': control}, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
    checked = sum(len(r['animations']) for r in reports)
    if failures or not checked:
        raise SystemExit('FAIL: a camera-facing model is not drawn as its data and the game rule say' if failures
                         else 'FAIL: no animation with a camera-facing model was played')
    print('PASS: billboard members and camera-facing models are drawn as the game rule says')
