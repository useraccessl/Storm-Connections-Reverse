"""Export a skinned model of a package as a Source studio model (.mdl): its mesh, its skeleton
in the rest pose and the animation that drives it, baked as a sequence (one frame per update of
the game, 50 ticks), compiled with Garry's Mod's studiomdl.exe.

The engine draws the model's skinned meshes this way (engine/cl_studio.lua): Source skins
them in C++ or on the GPU, nothing per vertex in Lua.

Model space is the space a skinned model is drawn in (the palette's: the root coordinate's
pose times its inverse rest matrix, RENDER / Skinning.Palette). In it the rest pose of
coordinate i is its rest matrix, and its pose at a clock is the palette entry times the rest
matrix, whatever the particle carrying the model: the draw matrix holds the particle.

Limits a sequence imposes, checked here: a Source bone has a position and a rotation only
(the animation must keep every scale at 1), a vertex at most three bone links with w = 1, one
UV set. A mesh whose shader reads a second UV set different from the first stays on the
engine's own path (RENDER.SplitSkinned).

  python export_studio.py <package> <model> <animation> [--addon <folder>]
"""

from __future__ import annotations

import argparse
import json
import math
import shutil
import subprocess
import sys
from pathlib import Path

import numpy as np

from port_preview import Port, capture_camera

ROOT = Path(__file__).resolve().parent
ADDON = ROOT.parent / 'storm_amaterasu_lab'
STUDIOMDL = Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\studiomdl.exe')
WORK = ROOT / 'game_cache' / 'studio'
TICKS_PER_FRAME = 50                 # one update of the game (60 a second)
SEQUENCE_ROTATE = -90                # degrees about z (see the QC below)


def matrix(values) -> np.ndarray:
    return np.array([float(values[i]) for i in range(1, 17)], dtype=np.float64).reshape(4, 4)


def euler(m: np.ndarray) -> tuple[float, float, float]:
    """SMD rotation (radians x, y, z) of a rotation matrix: Source's AngleMatrix(RadianEuler)
    builds Rz(z) * Ry(y) * Rx(x)."""
    sy = -m[2, 0]
    y = math.asin(max(-1.0, min(1.0, sy)))
    if abs(math.cos(y)) > 1e-6:
        x = math.atan2(m[2, 1], m[2, 2])
        z = math.atan2(m[1, 0], m[0, 0])
    else:
        x = math.atan2(-m[1, 2], m[1, 1])
        z = 0.0
    return x, y, z


def rebuild(x: float, y: float, z: float) -> np.ndarray:
    cx, sx, cy, sy, cz, sz = math.cos(x), math.sin(x), math.cos(y), math.sin(y), math.cos(z), math.sin(z)
    rx = np.array([[1, 0, 0], [0, cx, -sx], [0, sx, cx]])
    ry = np.array([[cy, 0, sy], [0, 1, 0], [-sy, 0, cy]])
    rz = np.array([[cz, -sz, 0], [sz, cz, 0], [0, 0, 1]])
    return rz @ ry @ rx


# The largest difference between a bone's rotation and the orthonormal one a Source bone
# carries (the game's quaternion bases are a little off unit length in float32)
DEVIATION = {'largest': 0.0}


def local_transform(m: np.ndarray, what: str) -> str:
    """An SMD bone line's six numbers for a local 4x4 (rotation part orthonormal within 1e-3:
    its nearest rotation is written, the difference kept in DEVIATION)."""
    r = m[:3, :3]
    scale = np.linalg.norm(r, axis=0)
    if np.abs(scale - 1).max() > 1e-3 or abs(np.linalg.det(r) - 1) > 1e-3:
        raise SystemExit(f'{what}: scale {scale.round(4).tolist()} (a Source bone has none)')
    u, _, vt = np.linalg.svd(r)
    nearest = u @ vt
    x, y, z = euler(nearest)
    if np.abs(rebuild(x, y, z) - nearest).max() > 1e-6:
        raise SystemExit(f'{what}: rotation does not round-trip through the SMD angles')
    DEVIATION['largest'] = max(DEVIATION['largest'], float(np.abs(nearest - r).max()))
    t = m[:3, 3]
    return f'{t[0]:.6f} {t[1]:.6f} {t[2]:.6f} {x:.6f} {y:.6f} {z:.6f}'


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('package')
    ap.add_argument('model')
    ap.add_argument('animation')
    ap.add_argument('--addon', type=Path, default=ADDON)
    args = ap.parse_args()

    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64))
    lua = port.lua
    runtime = port.load(args.package)
    data = runtime.data
    model = data.models[args.model]
    skeleton = model.skeleton
    assert skeleton, f'{args.model} is not skinned'

    # The poses, frame by frame, from the engine: the animation evaluated under the identity,
    # resolved as a particle's draw is (palette relative to the draw matrix)
    g = lua.globals()
    g.EXPORT_ANIMATION, g.EXPORT_MODEL = args.animation, args.model
    frames = lua.execute('''
        local runtime = StormFX.Engine.tPackages["''' + args.package + '''"]
        local models = runtime.models
        local tCompiled = models.CompiledFor(EXPORT_ANIMATION)
        local CORE = StormFX.Core
        local tIdentity = CORE.AnmMatrix.Identity()
        local tDraw
        for _, d in ipairs(tCompiled.draws) do
            if d.model == EXPORT_MODEL and d.skin then tDraw = d end
        end
        assert(tDraw, "the animation does not draw the model skinned")
        local tInstances = models.Instances(tCompiled)
        local tOut = {duration = tCompiled.compiled.duration, frames = {}}
        for iTicks = 0, tCompiled.compiled.duration, ''' + str(TICKS_PER_FRAME) + ''' do
            local tResult = CORE.AnmResource.Evaluate(tCompiled.compiled, iTicks, tInstances)
            local tContexts = {}
            for i, tEntry in ipairs(tCompiled.compiled.entries) do
                if tEntry.type == 1 then
                    tContexts[i] = {parentMatrix = tIdentity, translationScale = tCompiled.scales[i]}
                end
            end
            CORE.AnmResource.CoordinateMatrices(tCompiled.compiled, tResult, tContexts, tIdentity)
            local tResolved = models.Resolve(tDraw, tResult, tIdentity, iTicks)
            tOut.frames[#tOut.frames + 1] = {ticks = iTicks, palette = tResolved.palette, hidden = tResolved.hidden}
        end
        return tOut
    ''')
    duration = int(frames.duration)
    palettes = []
    for frame in frames.frames.values():
        if frame.hidden:
            raise SystemExit(f'frame at {int(frame.ticks)} ticks flattens the model (root scaled to zero)')
        palettes.append([matrix(p).T for p in frame.palette.values()])        # engine layout E_i

    rest_world = [matrix(m) for m in skeleton.restWorld.values()] if skeleton.restWorld else None
    if rest_world is None:
        raise SystemExit('rest matrices missing (the engine computes them on first use)')
    parents = [int(p) for p in skeleton.parents.values()]
    names = [str(n) for n in skeleton.coords.values()]
    count = len(names)

    def local_of(world: list[np.ndarray], i: int) -> np.ndarray:
        return world[i] if parents[i] < 0 else np.linalg.inv(world[parents[i]]) @ world[i]

    WORK.mkdir(parents=True, exist_ok=True)
    stem = args.model
    nodes = ['nodes'] + [f'{i} "{names[i]}" {parents[i]}' for i in range(count)] + ['end']

    # Reference: the rest pose, and the meshes Source can carry
    lines = ['version 1'] + nodes + ['skeleton', 'time 0']
    lines += [f'{i} {local_transform(local_of(rest_world, i), names[i] + " rest")}' for i in range(count)]
    lines += ['end', 'triangles']
    kept, left = [], []
    for index, mesh in model.meshes.items():
        attributes = mesh.shader.attributes
        n = len(list(mesh.vertices.values()))
        uv_same = all(abs(float(mesh.uvSets[v][1][k]) - float(mesh.uvSets[v][2][k])) < 1e-7 for v in range(1, n + 1) for k in (1, 2)) \
            if attributes.uv1 and mesh.uvSets else True
        colours = {tuple(float(mesh.vertices[v][k]) for k in (6, 7, 8, 9)) for v in range(1, n + 1)}
        if not uv_same or len(colours) != 1:
            left.append((int(index), 'second UV set differs from the first' if not uv_same else 'vertex colours vary'))
            continue
        kept.append((int(index), next(iter(colours))))
        material = f'{stem}_mesh{int(index)}'
        skin = mesh.skin
        for t in mesh.triangles.values():
            lines.append(material)
            # The engine's triangles arrive clockwise on screen for the game's front faces
            # (Source's front face); studiomdl wants them counter-clockwise from the front
            for k in (1, 3, 2):
                v = int(t[k]) + 1
                p = mesh.vertices[v]
                w = float(skin.positionW[v]) if skin.positionW else 1.0
                if w != 1.0:
                    raise SystemExit(f'mesh {index} vertex {v}: w = {w} (a studio model has none)')
                nx, ny, nz = (float(skin.normals[v][k2]) for k2 in (1, 2, 3))
                links = [(int(skin.indices[v][k2]), float(skin.weights[v][k2])) for k2 in (1, 2, 3, 4) if float(skin.weights[v][k2]) != 0]
                if len(links) > 3:
                    raise SystemExit(f'mesh {index} vertex {v}: {len(links)} bone links (Source takes three)')
                link_text = ' '.join(f'{b} {wt:.6f}' for b, wt in links)
                lines.append(f'{links[0][0]} {float(p[1]):.6f} {float(p[2]):.6f} {float(p[3]):.6f} {nx:.6f} {ny:.6f} {nz:.6f} '
                             f'{float(p[4]):.6f} {1 - float(p[5]):.6f} {len(links)} {link_text}')
    lines.append('end')
    if not kept:
        raise SystemExit(f'no mesh of {stem} fits a studio model: {left}')
    (WORK / f'{stem}_ref.smd').write_text('\n'.join(lines) + '\n', encoding='ascii')

    # The sequence: model-space pose of bone i at a frame = E_i * rest_i
    anim = ['version 1'] + nodes + ['skeleton']
    for f, palette in enumerate(palettes):
        world = [palette[i] @ rest_world[i] for i in range(count)]
        anim.append(f'time {f}')
        anim += [f'{i} {local_transform(local_of(world, i), f"{names[i]} frame {f}")}' for i in range(count)]
    anim.append('end')
    (WORK / f'{stem}_{args.animation}.smd').write_text('\n'.join(anim) + '\n', encoding='ascii')

    model_path = f'storm_fx/{stem}.mdl'
    # The sequence's frames are turned back a quarter turn about z: in game the posed model
    # looked 90 degrees to the left of the engine's own drawing (its rest pose in the .mdl
    # matched the export exactly: the turn is in the compiled animation)
    qc = [f'$modelname "{model_path}"', '$cdmaterials "storm_fx/studio/"', f'$body body "{stem}_ref.smd"',
          '$surfaceprop "default"', '$mostlyopaque',
          f'$sequence "{args.animation}" "{stem}_{args.animation}.smd" fps 60 rotate {SEQUENCE_ROTATE}']
    (WORK / f'{stem}.qc').write_text('\n'.join(qc) + '\n', encoding='ascii')
    print(f'{stem}: {count} bones, {len(palettes)} frames ({duration} ticks), meshes kept {[k for k, _ in kept]}, left {left}')

    # Compile in a game folder of its own (the game's own is left alone), then into the addon
    game = WORK / 'game'
    game.mkdir(parents=True, exist_ok=True)
    (game / 'gameinfo.txt').write_text('"GameInfo"\n{\n    game "storm_fx studio build"\n    type multiplayer_only\n'
                                       '    FileSystem\n    {\n        SteamAppId 4000\n        SearchPaths\n        {\n'
                                       '            game |gameinfo_path|.\n        }\n    }\n}\n', encoding='ascii')
    result = subprocess.run([str(STUDIOMDL), '-game', str(game), '-nop4', '-nox360', str(WORK / f'{stem}.qc')],
                            cwd=WORK, capture_output=True, text=True)
    if 'Completed' not in result.stdout:
        raise SystemExit('studiomdl failed:\n' + (result.stdout + result.stderr)[-3000:])
    target = args.addon / 'models' / 'storm_fx'
    target.mkdir(parents=True, exist_ok=True)
    built = sorted((game / 'models' / 'storm_fx').glob(f'{stem}.*'))
    for path in built:
        shutil.copyfile(path, target / path.name)

    # What the importer needs to make the meshes' shader variants: the one vertex colour of
    # each kept mesh, and the stage values the engine gives the model at the default scale
    # (compiled into the variant: a play at another scale keeps the default scale's fog)
    stage = lua.execute('''
        local ENGINE = StormFX.Engine
        local tItem = ENGINE.tPackages["''' + args.package + '''"].items["''' + args.model + '''"]
        local tValues = ENGINE:StageValues(tItem, StormFX.Config.scale)
        local tOut = {}
        for sName, tValue in pairs(tValues) do
            local tCopy = {}
            for i, flValue in ipairs(tValue) do tCopy[i] = flValue end
            tOut[sName] = tCopy
        end
        return tOut
    ''')
    description = {
        'model': stem, 'mdl': f'models/{model_path}', 'animation': args.animation, 'duration': duration,
        'ticksPerFrame': TICKS_PER_FRAME, 'frames': len(palettes),
        'meshes': {str(index): {'color': list(colour)} for index, colour in kept},
        'left': {str(index): why for index, why in left},
        'stage': {str(k): [float(x) for x in v.values()] for k, v in stage.items()},
        'files': [path.name for path in built]}
    studio = args.addon / 'studio'
    studio.mkdir(parents=True, exist_ok=True)
    (studio / f'{stem}.json').write_text(json.dumps(description, indent=1) + '\n', encoding='utf-8')
    print(f'{model_path}: {", ".join(path.name for path in built)} -> {target}; description {studio / (stem + ".json")}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
