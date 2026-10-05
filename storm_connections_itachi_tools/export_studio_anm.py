"""Export an animated resource of a package (an animation whose clumps carry models, drawn by
particles) as a Source studio model: the animation baked as a sequence (one frame per 50
ticks), and, per frame and per drawn model, what the engine still sets per draw: the model's
opacity (coordinate channel 3) and the fields of the material instances the animation drives.

Bones, flat under a root: one per rigid model drawn (the coordinate that carries it), and for a
skinned model one per coordinate of its skeleton (Source skins it on the GPU, at most three
links a vertex).

A particle of such a resource then plays the sequence (cycle = its animation clock / duration)
under its parent matrix, with no evaluation of the animation in Lua (engine/cl_studio.lua).
Exact when the particles' clocks are multiples of 50 ticks (the frames); in between Source
interpolates the bones and the engine takes the frame below.

A Source bone has a position and a rotation only. A scale that stays the same over the whole
animation is put into the reference vertices instead (a rigid model: any scale along its
axes; a skinned one: one uniform scale shared by the bones its vertices use).

Refused (the resource stays on the engine's own path): a camera-facing or billboard model, a
scale that changes during the animation, a sheared matrix, vertex colours that vary, a second
UV set unlike the first, a trail on the animation, models of different render states (one
DrawModel draws them all with one blend state), two draws of one mesh whose opacity or
material fields differ (they share the mesh's material).

  python export_studio_anm.py <package> <animation> [--addon <folder>]
"""

from __future__ import annotations

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np

from export_studio import ADDON, DEVIATION, SEQUENCE_ROTATE, STUDIOMDL, TICKS_PER_FRAME, WORK, local_transform, matrix
from port_preview import Port, capture_camera

SCALE_TOLERANCE = 1e-3               # relative: a scale within it over the frames is constant
LINK_TOLERANCE = 5e-3                # relative: the most a vertex cut to three bone links may move


def split(m: np.ndarray, what: str) -> tuple[np.ndarray, np.ndarray]:
    """A matrix as (rigid part, scale along its axes): M = rigid * diag(scale)."""
    r = m[:3, :3]
    scale = np.linalg.norm(r, axis=0)
    if scale.min() < 1e-9:
        raise SystemExit(f'{what}: scaled to zero')
    q = r / scale
    if np.abs(q.T @ q - np.eye(3)).max() > 2e-3 or np.linalg.det(q) < 0:
        raise SystemExit(f'{what}: sheared or mirrored matrix')
    rigid = np.eye(4)
    rigid[:3, :3], rigid[:3, 3] = q, m[:3, 3]
    return rigid, scale


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('package')
    ap.add_argument('animation')
    ap.add_argument('--addon', type=Path, default=ADDON)
    ap.add_argument('--hang', action='store_true', help='bake a fall into the sequence for the model that hangs on spring bones '
                    '(host animation: the game simulates it)')
    args = ap.parse_args()

    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64))
    lua = port.lua
    runtime = port.load(args.package)
    data = runtime.data
    if data.trails and data.trails[args.animation]:
        raise SystemExit(f'{args.animation} carries trails (their edges follow coordinates the engine evaluates)')

    # Per frame: every drawn model's matrix under the identity parent (and the palette of a
    # skinned one), its opacity and the fields its animated material instances hold
    g = lua.globals()
    g.EXPORT_ANIMATION = args.animation
    baked = lua.execute('''
        local runtime = StormFX.Engine.tPackages["''' + args.package + '''"]
        local models = runtime.models
        local tCompiled = models.CompiledFor(EXPORT_ANIMATION)
        local CORE = StormFX.Core
        local tIdentity = CORE.AnmMatrix.Identity()
        local tInstances = models.Instances(tCompiled)
        local tOut = {duration = tCompiled.compiled.duration, draws = {}, frames = {}}
        for i, d in ipairs(tCompiled.draws) do
            tOut.draws[i] = {model = d.model, coord = d.coord, billboard = d.billboard ~= nil, skin = d.skin ~= nil,
                facing = runtime.items[d.model] and runtime.items[d.model].facing or false}
        end
        for iTicks = 0, tCompiled.compiled.duration, ''' + str(TICKS_PER_FRAME) + ''' do
            local tResult = CORE.AnmResource.Evaluate(tCompiled.compiled, iTicks, tInstances)
            local tContexts = {}
            for i, tEntry in ipairs(tCompiled.compiled.entries) do
                if tEntry.type == 1 then
                    tContexts[i] = {parentMatrix = tIdentity, translationScale = tCompiled.scales[i]}
                end
            end
            CORE.AnmResource.CoordinateMatrices(tCompiled.compiled, tResult, tContexts, tIdentity)
            local tFrame = {ticks = iTicks, draws = {}}
            for i, d in ipairs(tCompiled.draws) do
                local r = models.Resolve(d, tResult, tIdentity, iTicks)
                local tMatrix = {}
                for k = 1, 16 do tMatrix[k] = r.matrix[k] end
                local tPalette
                if r.palette then
                    tPalette = {}
                    for b, p in ipairs(r.palette) do
                        local tCopy = {}
                        for k = 1, 16 do tCopy[k] = p[k] end
                        tPalette[b] = tCopy
                    end
                end
                local tFields = {}
                for iIndex, tInstance in pairs(r.instances or {}) do
                    local tCopy = {}
                    for iOffset, flValue in pairs(tInstance) do tCopy[iOffset] = flValue end
                    tFields[iIndex] = tCopy
                end
                tFrame.draws[i] = {matrix = tMatrix, palette = tPalette, opacity = r.opacity, instances = tFields, hidden = r.hidden}
            end
            tOut.frames[#tOut.frames + 1] = tFrame
        end
        return tOut
    ''')
    duration = int(baked.duration)
    draws = list(baked.draws.values())
    if not draws:
        raise SystemExit(f'{args.animation} draws no model')
    for i, d in enumerate(draws):
        why = 'billboard member' if d.billboard else 'camera-facing' if d.facing else None
        if why:
            raise SystemExit(f'draw {i + 1} ({d.model}): {why}')
    frames = list(baked.frames.values())
    for f, frame in enumerate(frames):
        for i in range(len(draws)):
            if frame.draws[i + 1].hidden:
                raise SystemExit(f'draw {i + 1} hidden at frame {f}')

    # Bones: a root, then per draw one bone (rigid) or its skeleton's (skinned), flat under
    # the root. world[f][j]: bone j in the resource's space at frame f.
    names, owner = ['root'], [None]
    first_bone, rests = [], []
    for i, d in enumerate(draws):
        first_bone.append(len(names))
        if d.skin:
            skeleton = data.models[d.model].skeleton
            if not skeleton.restWorld:
                raise SystemExit(f'{d.model}: rest matrices missing')
            rest = [matrix(m) for m in skeleton.restWorld.values()]
            rests.append(rest)
            for b, coord in enumerate(skeleton.coords.values()):
                names.append(f'draw{i + 1}_{b}_{coord}')
                owner.append((i, b))
        else:
            rests.append(None)
            names.append(f'draw{i + 1}_{d.model}')
            owner.append((i, None))
    names = [n.replace(' ', '_') for n in names]

    def bone_world(frame, j: int) -> np.ndarray:
        i, b = owner[j]
        m = matrix(frame.draws[i + 1].matrix)
        if b is None:
            return m
        return m @ matrix(list(frame.draws[i + 1].palette.values())[b]).T @ rests[i][b]

    count = len(names)
    rigid = [[np.eye(4)] * count for _ in frames]
    scales = [None] * count
    for j in range(1, count):
        column = [split(bone_world(frame, j), f'{names[j]} frame {f}') for f, frame in enumerate(frames)]
        every = np.array([s for _, s in column])
        if (every.max(axis=0) - every.min(axis=0)).max() > SCALE_TOLERANCE * every.max():
            raise SystemExit(f'{names[j]}: scale {every.min(axis=0).round(4).tolist()} to {every.max(axis=0).round(4).tolist()} '
                             f'during the animation (a Source bone has none)')
        scales[j] = every.mean(axis=0)
        for f, (part, _) in enumerate(column):
            rigid[f] = list(rigid[f])
            rigid[f][j] = part

    # --hang: the sequence is not the animation's (which leaves these bones still) but a fall.
    # A model on spring bones (nuccChunkDynamics: the game simulates them, journal R127) is
    # shown falling from its rest pose to hang under its first bone: a host animation, not the
    # game's simulation. The chain must lie level in the resource's space (the engine stands
    # the model upright: engine/cl_effects.lua); it turns about the level axis across it,
    # each bone a little behind the one before, a damped swing that has stopped by the
    # last frame.
    baked = [list(row) for row in rigid]
    hung = []
    if args.hang:
        clumps = [c for c in data.animations[args.animation].clumps.values() if c.dynamics and c.drawn and len(list(c.drawn.values())) == 1]
        for clump in clumps:
            chain = list(clump.dynamics.values())[0]
            model_name = str(list(clump.drawn.values())[0])
            for i, d in enumerate(draws):
                if str(d.model) != model_name or not d.skin:
                    continue
                bones = [first_bone[i] + int(chain.first) + n for n in range(int(chain.count))]
                rest = [rigid[0][j] for j in bones]
                along = rest[-1][:3, 3] - rest[0][:3, 3]
                length = float(np.linalg.norm(along))
                if length <= 0 or abs(along[2]) > 1e-3 * length:
                    raise SystemExit(f'--hang: the chain of {model_name} is not level in the resource ({along.round(3).tolist()})')
                along = along / length
                axis = np.cross(along, np.array([0.0, 0.0, -1.0]))      # turns `along` toward down
                seconds = (len(frames) - 1) * TICKS_PER_FRAME / 3000.0

                def angle(t: float) -> float:
                    """Quarter turn reached with one overshoot, at rest by the end."""
                    if t <= 0:
                        return 0.0
                    decay, swing = 5.0 / seconds, 7.5 / seconds
                    return (np.pi / 2) * (1 - np.exp(-decay * t) * (np.cos(swing * t) + decay / swing * np.sin(swing * t)))

                def turn(theta: float) -> np.ndarray:
                    k = np.array([[0, -axis[2], axis[1]], [axis[2], 0, -axis[0]], [-axis[1], axis[0], 0]])
                    return np.eye(3) + np.sin(theta) * k + (1 - np.cos(theta)) * (k @ k)

                for f in range(len(frames)):
                    t = f * TICKS_PER_FRAME / 3000.0
                    position = rest[0][:3, 3].copy()
                    for n, j in enumerate(bones):
                        # Each bone a twentieth of the duration behind the one before
                        rotation = turn(angle(t - n * seconds / 20))
                        if n > 0:
                            previous = turn(angle(t - (n - 1) * seconds / 20))
                            position = position + previous @ (rest[n][:3, 3] - rest[n - 1][:3, 3])
                        pose = np.eye(4)
                        pose[:3, :3] = rotation @ rest[n][:3, :3]
                        pose[:3, 3] = position
                        baked[f][j] = pose
                hung.append({'model': model_name, 'draw': i + 1, 'bones': len(bones), 'seconds': seconds})
        if not hung:
            raise SystemExit('--hang: no drawn skinned model of this animation has a dynamics chain')

    # Reference pose. A rigid model: its bone at frame 0, its vertices there with their scale.
    # A skinned model: its rest pose grown by the one scale of the bones its vertices use
    # (bone k at frame f is S_k(f) * s; S_k(f) * R_k^-1 * (s * p) = S_k(f) * s * rest_k^-1 * p).
    reference = [np.eye(4)] * count
    skin_scale = {}
    for i, d in enumerate(draws):
        if not d.skin:
            reference[first_bone[i]] = rigid[0][first_bone[i]]
            continue
        used = set()
        for mesh in data.models[d.model].meshes.values():
            skin = mesh.skin
            for v in range(1, len(list(mesh.vertices.values())) + 1):
                used.update(int(skin.indices[v][k]) for k in (1, 2, 3, 4) if float(skin.weights[v][k]) != 0)
        linked = np.array([scales[first_bone[i] + b] for b in sorted(used)])
        if (linked.max() - linked.min()) > SCALE_TOLERANCE * linked.max():
            raise SystemExit(f'draw {i + 1} ({d.model}): its bones have different scales {linked.min():.4f} to {linked.max():.4f}')
        s = float(linked.mean())
        skin_scale[i] = s
        for b, rest in enumerate(rests[i]):
            pose, rest_scale = split(rest, f'{d.model} rest {b}')
            if np.abs(rest_scale - 1).max() > SCALE_TOLERANCE:
                raise SystemExit(f'{d.model} rest {b}: scale {rest_scale.round(4).tolist()}')
            pose[:3, 3] *= s
            reference[first_bone[i] + b] = pose

    nodes = ['nodes', '0 "root" -1'] + [f'{j} "{names[j]}" 0' for j in range(1, count)] + ['end']
    WORK.mkdir(parents=True, exist_ok=True)
    stem = args.animation
    identity = np.eye(4)
    lines = ['version 1'] + nodes + ['skeleton', 'time 0', f'0 {local_transform(identity, "root")}']
    lines += [f'{j} {local_transform(reference[j], names[j] + " reference")}' for j in range(1, count)]
    lines += ['end', 'triangles']

    def plain_instances(instances):
        return {str(int(k)): {str(int(o)): float(x) for o, x in fields.items()} for k, fields in instances.items()}

    # Draws of one model would share its meshes' materials: when what the engine sets per draw
    # (opacity, animated material fields) differs between them, each draw gets materials of
    # its own (the same shader and textures under another name: storm_import.py)
    own_materials = set()
    for name in {str(d.model) for d in draws}:
        sharing = [i + 1 for i, d in enumerate(draws) if str(d.model) == name]
        for frame in frames:
            values = {json.dumps([None if frame.draws[i].opacity is None else float(frame.draws[i].opacity),
                                  plain_instances(frame.draws[i].instances)], sort_keys=True) for i in sharing}
            if len(values) != 1:
                own_materials.add(name)
                break

    # One model per render state (one DrawModel draws its meshes with one blend state): the
    # triangles of each, in the order the states first appear
    header, lines = lines, None
    parts, states, triangles = [], [], {}
    worst, reduced, dropped = 0.0, 0, 0.0
    for i, d in enumerate(draws):
        model = data.models[d.model]
        base = first_bone[i]
        for index, mesh in model.meshes.items():
            attributes = mesh.shader.attributes
            n = len(list(mesh.vertices.values()))
            if attributes.uv1 and mesh.uvSets and not all(
                    abs(float(mesh.uvSets[v][1][k]) - float(mesh.uvSets[v][2][k])) < 1e-7 for v in range(1, n + 1) for k in (1, 2)):
                raise SystemExit(f'{d.model} mesh {index}: second UV set differs from the first')
            colours = {tuple(float(mesh.vertices[v][k]) for k in (6, 7, 8, 9)) for v in range(1, n + 1)}
            if len(colours) != 1:
                raise SystemExit(f'{d.model} mesh {index}: vertex colours vary')
            state = (int(mesh.state.source_factor or 0), int(mesh.state.dest_factor or 0), int(mesh.state.cull_mode or 0),
                     int(model.header.layer or 0))
            if state not in states:
                states.append(state)
            lines = triangles.setdefault(state, [])
            material = (f'{d.model}_mesh{int(index)}' + (f'_d{i + 1}' if str(d.model) in own_materials else '')).replace(' ', '_')
            parts.append({'draw': i + 1, 'model': str(d.model), 'mesh': int(index), 'color': list(next(iter(colours))), 'material': material,
                          'group': states.index(state) + 1})
            if d.skin:
                skin, s = mesh.skin, skin_scale[i]
                checked = set()
                for t in mesh.triangles.values():
                    lines.append(material)
                    for k in (1, 3, 2):
                        v = int(t[k]) + 1
                        p = mesh.vertices[v]
                        w = float(skin.positionW[v]) if skin.positionW else 1.0
                        if w != 1.0:
                            raise SystemExit(f'{d.model} mesh {index} vertex {v}: w = {w} (a studio model has none)')
                        nx, ny, nz = (float(skin.normals[v][k2]) for k2 in (1, 2, 3))
                        links = [(int(skin.indices[v][k2]), float(skin.weights[v][k2])) for k2 in (1, 2, 3, 4)
                                 if float(skin.weights[v][k2]) != 0]
                        full = links
                        if len(links) > 3:
                            # Source takes three links: the three heaviest, their weights
                            # brought back to a sum of 1 (the difference is measured below)
                            links = sorted(links, key=lambda link: -link[1])[:3]
                            total = sum(wt for _, wt in links)
                            if v not in checked:
                                reduced += 1
                                dropped = max(dropped, 1 - total)
                            links = [(b, wt / total) for b, wt in links]
                        position = np.array([float(p[1]), float(p[2]), float(p[3])])
                        link_text = ' '.join(f'{base + b} {wt:.6f}' for b, wt in links)
                        lines.append(f'{base + links[0][0]} {position[0] * s:.6f} {position[1] * s:.6f} {position[2] * s:.6f} '
                                     f'{nx:.6f} {ny:.6f} {nz:.6f} {float(p[4]):.6f} {1 - float(p[5]):.6f} {len(links)} {link_text}')
                        # The sequence against the engine's own skinning, at every frame
                        if v not in checked:
                            checked.add(v)
                            rest_point = np.append(position, 1.0)
                            ref_point = np.append(position * s, 1.0)
                            for f, frame in enumerate(frames):
                                engine = sum(wt * (bone_world(frame, base + b) @ np.linalg.inv(rests[i][b]) @ rest_point) for b, wt in full)
                                source = sum(wt * (rigid[f][base + b] @ np.linalg.inv(reference[base + b]) @ ref_point) for b, wt in links)
                                worst = max(worst, float(np.abs(engine - source)[:3].max()) / max(1.0, float(np.abs(engine[:3]).max())))
            else:
                bind = bone_world(frames[0], base)
                rotation, scale = rigid[0][base][:3, :3], scales[base]
                normals = mesh.normalHalfRaw
                for t in mesh.triangles.values():
                    lines.append(material)
                    for k in (1, 3, 2):
                        v = int(t[k]) + 1
                        p = mesh.vertices[v]
                        position = bind @ np.array([float(p[1]), float(p[2]), float(p[3]), 1.0])
                        if normals:
                            raw = str(normals[v])
                            half = lambda at: np.frombuffer(bytes.fromhex(raw[at - 1:at + 3]), dtype='>f2')[0].astype(np.float64)
                            normal = rotation @ (np.array([half(1), half(5), half(9)]) / scale)
                        else:
                            normal = rotation @ (np.array([0.0, 0.0, 1.0]) / scale)
                        size = np.linalg.norm(normal)
                        normal = normal / size if size > 0 else normal
                        lines.append(f'{base} {position[0]:.6f} {position[1]:.6f} {position[2]:.6f} {normal[0]:.6f} {normal[1]:.6f} '
                                     f'{normal[2]:.6f} {float(p[4]):.6f} {1 - float(p[5]):.6f} 1 {base} 1.000000')
    if worst > LINK_TOLERANCE:
        raise SystemExit(f'skinned vertices up to {worst:.1e} (relative) from the engine\'s ({reduced} vertices cut to three links)')

    anim =['version 1'] + nodes + ['skeleton']
    for f in range(len(frames)):
        anim.append(f'time {f}')
        anim.append(f'0 {local_transform(identity, "root")}')
        anim += [f'{j} {local_transform(baked[f][j], f"{names[j]} frame {f}")}' for j in range(1, count)]
    anim.append('end')
    (WORK / f'{stem}_{stem}.smd').write_text('\n'.join(anim) + '\n', encoding='ascii')

    # The models: the first render state's keeps the animation's name, the others add _s<n>.
    # Each has the whole skeleton and sequence (studiomdl drops the bones its meshes do not use).
    game = WORK / 'game'
    target = args.addon / 'models' / 'storm_fx'
    target.mkdir(parents=True, exist_ok=True)
    model_paths, built = [], []
    for n, state in enumerate(states):
        name = stem if n == 0 else f'{stem}_s{n + 1}'
        (WORK / f'{name}_ref.smd').write_text('\n'.join(header + triangles[state] + ['end']) + '\n', encoding='ascii')
        model_path = f'storm_fx/{name}.mdl'
        qc = [f'$modelname "{model_path}"', '$cdmaterials "storm_fx/studio/"', f'$body body "{name}_ref.smd"',
              '$surfaceprop "default"', '$mostlyopaque',
              f'$sequence "{stem}" "{stem}_{stem}.smd" fps 60 rotate {SEQUENCE_ROTATE}']
        (WORK / f'{name}.qc').write_text('\n'.join(qc) + '\n', encoding='ascii')
        result = subprocess.run([str(STUDIOMDL), '-game', str(game), '-nop4', '-nox360', str(WORK / f'{name}.qc')],
                                cwd=WORK, capture_output=True, text=True)
        if 'Completed' not in result.stdout:
            raise SystemExit('studiomdl failed:\n' + (result.stdout + result.stderr)[-3000:])
        for path in sorted((game / 'models' / 'storm_fx').glob(f'{name}.*')):
            shutil.copyfile(path, target / path.name)
            built.append(path)
        model_paths.append(f'models/{model_path}')
    model_path = f'storm_fx/{stem}.mdl'

    # Stage values of each model, as the wave's (compiled into the shader variants)
    stage = {}
    for d in draws:
        values = lua.execute('''
            local ENGINE = StormFX.Engine
            local tItem = ENGINE.tPackages["''' + args.package + '''"].items["''' + str(d.model) + '''"]
            local tValues = ENGINE:StageValues(tItem, StormFX.Config.scale)
            local tOut = {}
            for sName, tValue in pairs(tValues) do
                local tCopy = {}
                for i, flValue in ipairs(tValue) do tCopy[i] = flValue end
                tOut[sName] = tCopy
            end
            return tOut
        ''')
        stage[str(d.model)] = {str(k): [float(x) for x in v.values()] for k, v in values.items()}

    description = {
        'kind': 'rigid', 'animation': stem, 'mdl': f'models/{model_path}', 'mdls': model_paths, 'duration': duration, 'hung': hung,
        'ticksPerFrame': TICKS_PER_FRAME,
        'draws': [{'model': str(d.model), 'skinned': bool(d.skin)} for d in draws], 'parts': parts, 'stage': stage,
        'frames': [{'opacity': [None if f.draws[i + 1].opacity is None else float(f.draws[i + 1].opacity) for i in range(len(draws))],
                    'instances': [plain_instances(f.draws[i + 1].instances) for i in range(len(draws))]} for f in frames],
        'files': [path.name for path in built]}
    studio = args.addon / 'studio'
    studio.mkdir(parents=True, exist_ok=True)
    (studio / f'{stem}.json').write_text(json.dumps(description) + '\n', encoding='utf-8')
    skinned = sum(1 for d in draws if d.skin)
    print(f'{model_path}: {len(states)} model(s), {len(draws)} draws ({skinned} skinned), {count - 1} bones, {len(parts)} meshes, '
          f'{len(frames)} frames ({duration} ticks) -> {target}; description {studio / (stem + ".json")}; bone rotations within '
          f'{DEVIATION["largest"]:.1e} of the animation\'s'
          + (f'; skinned vertices within {worst:.1e} (relative) of the engine\'s at every frame' if skinned else '')
          + (f'; {reduced} vertices cut to three bone links (weight dropped up to {dropped:.3f})' if reduced else ''))
    return 0


if __name__ == '__main__':
    sys.exit(main())
