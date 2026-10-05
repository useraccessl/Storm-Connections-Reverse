"""Check the engine's skinned models on real data of the game, offline.

`verify_skinning_capture.py` proves the per-vertex arithmetic against the game's
compute shader and `verify_skin_palette_capture.py` the meaning of the palette
on a capture. This checks that the importer and the player wire them up: every
animation of a package that draws a skinned model is played in the engine (lupa,
GMod stubs of port_preview.py), and on every frame the vertices the engine sends
for that model are compared with linear blend skinning written directly here,
from the package's own data:

    vertex = sum over the four influences of weight * (pose_bone * inverse(rest_bone) * bind position)

with pose_bone the animated matrix of the clump coordinate (taken from the
engine's animation evaluator, itself checked elsewhere) and rest_bone the product
of the nuccChunkCoord rest transforms. The engine goes another way round (palette
relative to the model's draw matrix, the shader's arithmetic); both must give the
same points and normals in the effect's space.

No pixel is checked, and nothing here runs in Garry's Mod.

  python verify_skinned_models.py [package ...]      (default 3mdr_2_x)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

import numpy as np

from game_data import GameData
from port_preview import Port, capture_camera
from storm_import import Importer
from verify_skin_palette_capture import node

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
FRAMES = 40
# Vertices of one chunk of a skinned draw: RENDER.BATCH_VERTICES (2048) rounded down to triangles
CHUNK = 2048 // 3 * 3


def matrix(values) -> np.ndarray:
    return np.array([values[i] for i in range(1, 17)], dtype=np.float64).reshape(4, 4)


def ensure(game: GameData, stem: str) -> None:
    path = SCRATCH / 'lua/storm_fx/packages' / f'{stem}.lua'
    if not path.exists() or '["skeleton"]' not in path.read_text(encoding='utf-8'):
        importer = Importer(game, stem, SCRATCH)
        importer.skill_file(f'data/skill/{stem}.xfbin')
        importer.write()


def skinned_animations(data) -> dict[str, list[tuple[int, str]]]:
    """animation -> [(clump index, skinned model)]"""
    out = {}
    for name, animation in data.animations.items():
        if not animation or not animation.clumps:
            continue
        for index, clump in animation.clumps.items():
            for model_name in (clump.drawn.values() if clump.drawn else []):
                model = data.models[model_name]
                if model and model.skeleton:
                    out.setdefault(name, []).append((index - 1, model_name))
    return out


def check_package(game: GameData, stem: str) -> dict:
    ensure(game, stem)
    probe = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
    data = probe.load(stem).data
    wanted = skinned_animations(data)
    report = {'package': stem, 'animations': {}, 'not_played': {}}
    for effect, members in sorted(wanted.items()):
        port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
        # The reference path: every vertex skinned at every draw (the split drawing,
        # Config splitSkinned, is compared with it elsewhere)
        port.lua.execute('StormFX.Config.splitSkinned = false')
        runtime = port.load(stem)
        data = runtime.data
        instance = port.play(stem, effect, (0.0, 0.0, 0.0), 0.0, 1.0, 1)
        if not instance or isinstance(instance, tuple):
            report['not_played'][effect] = str(instance[1] if isinstance(instance, tuple) else instance)
            continue
        animation = data.animations[effect]
        # Per clump of the animation: the coordinate chunks it lists, and the other
        # clumps that list the same clump chunk.
        own_coordinates = {index - 1: {chunk[2] for chunk in clump.boneChunks.values()} for index, clump in animation.clumps.items()}
        same_chunk = {index - 1: [other - 1 for other, c in animation.clumps.items() if other != index and c.chunk == clump.chunk]
                      for index, clump in animation.clumps.items()}
        materials = {part.mat.name: (item.name, index) for item in runtime['items'].values()
                     for index, part in item.parts.items() if part.mesh.skin}
        row = {'frames': 0, 'draws': 0, 'vertices': 0, 'worst_position': 0.0, 'worst_normal': 0.0, 'largest_displacement': 0.0,
               'models': sorted({m for _, m in members})}
        for frame in range(FRAMES):
            port.advance(frame)
            failed = port.field('tFailed', 'failed')
            if list(failed.keys()):
                report['not_played'][effect] = str(dict(failed.items()))
                break
            result = instance.provider.result
            if result is None:
                continue
            draws = [d for d in port.collect() if not d.get('marker') and d['material'] in materials]
            if not draws:
                continue
            # A skinned part is drawn in chunks of CHUNK vertices (the dynamic vertex buffer's
            # limit, RENDER.DrawSkinned): a full chunk and the draws that follow it under the
            # same material and matrix are one draw.
            joined = []
            for draw in draws:
                sent = port.mesh(draw['mesh'])
                last = joined[-1] if joined else None
                if (last is not None and len(last['sent']) % CHUNK == 0 and last['chunk_full']
                        and last['material'] == draw['material'] and np.array_equal(last['matrix'], draw['matrix'])):
                    last['sent'] = np.concatenate([last['sent'], sent])
                    last['chunk_full'] = len(sent) == CHUNK
                    continue
                joined.append(dict(draw, sent=sent, chunk_full=len(sent) == CHUNK))
            draws = joined
            # Animated matrix of every coordinate, by clump index and chunk name.
            pose_of = {}
            for key, item in result.items():
                if item.type == 1:
                    entry = animation.entries[key]
                    pose_of[(entry.clump_index, entry.chunk or entry.target)] = matrix(item.worldMatrix)
            root = matrix(instance.root)
            row['frames'] += 1
            wanted_cache = {}

            def expected(model, mesh, clump_index):
                skeleton = model.skeleton
                rest, pose = [], []
                for i in range(1, len(list(skeleton.rest.values())) + 1):
                    v = [skeleton.rest[i][k] for k in range(1, 10)]
                    local = node(v[0:3], v[3:6], v[6:9])
                    parent = skeleton.parents[i]
                    rest.append(local if parent < 0 else rest[parent] @ local)
                    animated = pose_of.get((clump_index, skeleton.coords[i]))
                    if animated is None and skeleton.coords[i] not in own_coordinates[clump_index]:
                        # The coordinate belongs to another clump of the animation that
                        # lists the same clump chunk (one chunk split between several).
                        animated = next((pose_of[(c, skeleton.coords[i])] for c in sorted(same_chunk[clump_index])
                                         if (c, skeleton.coords[i]) in pose_of), None)
                    pose.append(animated if animated is not None else (root if parent < 0 else pose[parent]) @ local)
                skin_matrix = [pose[i] @ np.linalg.inv(rest[i]) for i in range(len(rest))]
                expected_p, expected_n, bind = [], [], []
                for v in range(1, len(list(mesh.vertices.values())) + 1):
                    position = np.array([mesh.vertices[v][1], mesh.vertices[v][2], mesh.vertices[v][3],
                                         mesh.skin.positionW[v] if mesh.skin.positionW else 1.0])
                    normal = np.array([mesh.skin.normals[v][k] for k in (1, 2, 3)])
                    p, n = np.zeros(3), np.zeros(3)
                    for k in (1, 2, 3, 4):
                        weight, bone = mesh.skin.weights[v][k], mesh.skin.indices[v][k]
                        p += weight * (skin_matrix[bone] @ position)[:3]
                        n += weight * (skin_matrix[bone][:3, :3] @ normal)
                    expected_p.append(p)
                    expected_n.append(n)
                    bind.append(position[:3])
                order = [mesh.triangles[t][k] for t in range(1, len(list(mesh.triangles.values())) + 1) for k in (1, 2, 3)]
                return (np.array([expected_p[i] for i in order]), np.array([expected_n[i] for i in order]),
                        np.array([root[:3, :3] @ bind[i] + root[:3, 3] for i in order]))

            # One clump chunk can be played twice by an animation: each copy draws the
            # model with its own pose. Every draw must be the model under one of the
            # poses, and every pose must have its draw.
            matched = {}
            for draw in draws:
                model_name, part_index = materials[draw['material']]
                model = data.models[model_name]
                # A skinned model spawned by an emitter of the effect (not one of the
                # animation's own clumps) has its own animation instance: not checked here.
                candidates = [c for c, m in members if m == model_name]
                if not candidates:
                    row['other_skinned_draws'] = row.get('other_skinned_draws', 0) + 1
                    continue
                mesh = model.meshes[part_index]
                sent = draw['sent']
                world = draw['matrix']
                got_p = sent[:, 0:3].astype(np.float64) @ world[:3, :3].T + world[:3, 3]
                got_n = sent[:, 39:42].astype(np.float64) @ world[:3, :3].T
                best = None
                for clump_index in candidates:
                    key = (model_name, part_index, clump_index)
                    if key not in wanted_cache:
                        wanted_cache[key] = expected(model, mesh, clump_index)
                    want_p, want_n, bind_world = wanted_cache[key]
                    assert len(sent) == len(want_p), (effect, model_name, len(sent), len(want_p))
                    scale = max(1.0, float(np.abs(want_p).max()))
                    error = float(np.abs(got_p - want_p).max()) / scale
                    if best is None or error < best[0]:
                        best = (error, clump_index, want_p, want_n, bind_world)
                error, clump_index, want_p, want_n, bind_world = best
                matched[(model_name, part_index, clump_index)] = matched.get((model_name, part_index, clump_index), 0) + 1
                row['worst_position'] = max(row['worst_position'], error)
                if mesh.shader.attributes.normal:
                    row['worst_normal'] = max(row['worst_normal'], float(np.abs(got_n - want_n).max()))
                row['largest_displacement'] = max(row['largest_displacement'], float(np.abs(want_p - bind_world).max()))
                row['draws'] += 1
                row['vertices'] += len(want_p)
            # Poses that differ must each have been drawn once (two copies in the same
            # pose cannot be told apart, and need not be).
            for (model_name, part_index, clump_index), count in matched.items():
                others = [c for c, m in members if m == model_name and c != clump_index
                          and (model_name, part_index, c) not in matched]
                for other in others:
                    same_pose = np.allclose(wanted_cache[(model_name, part_index, other)][0],
                                            wanted_cache[(model_name, part_index, clump_index)][0], atol=1e-4)
                    if not same_pose:
                        row['poses_without_draw'] = row.get('poses_without_draw', 0) + 1
        if effect not in report['not_played']:
            report['animations'][effect] = row
    return report


if __name__ == '__main__':
    game = GameData()
    failures = 0
    reports = []
    for stem in sys.argv[1:] or ['3mdr_2_x']:
        report = check_package(game, stem)
        reports.append(report)
        for effect, row in report['animations'].items():
            ok = (row['draws'] > 0 and row['worst_position'] < 1e-4 and row['worst_normal'] < 1e-4
                  and not row.get('poses_without_draw'))
            failures += not ok
            print(f'{stem} / {effect} ({", ".join(row["models"])}): {row["frames"]} frames, {row["draws"]} skinned draws, '
                  f'{row["vertices"]} vertices; largest difference: position {row["worst_position"]:.1e} (relative), '
                  f'normal {row["worst_normal"]:.1e}; the pose moves vertices up to {row["largest_displacement"]:.2f} units '
                  f'from the rest pose {"ok" if ok else "MISMATCH"}')
        for effect, why in report['not_played'].items():
            print(f'{stem} / {effect}: not played ({why})')
    target = ROOT / 'captured_assets' / 'skinned_model_check.json'
    target.write_text(json.dumps(reports, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
    checked = sum(len(r['animations']) for r in reports)
    if failures or not checked:
        raise SystemExit('FAIL: a skinned model differs from linear blend skinning of its own data' if failures
                         else 'FAIL: no animation with a skinned model was played')
    print('PASS: the engine skins the models as their data says')
