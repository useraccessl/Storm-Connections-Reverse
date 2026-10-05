"""Check every shader of an imported skill against the game's bytecode.

storm_import.py compiles one shader pair per mesh, with the material's own
constants. For each of them this runs the differential test of
verify_shader_port.py: random scenes rendered in software with the game's
vs_4_0 / ps_4_0 pair (constant buffer = the material's constants plus random
per-draw and stage values) and with the port's compiled pair fed through
the addon's engine/cl_shader_layout.lua. The scenes are the hard case: fog range
inside the scene and a different normal per vertex.

  python verify_package_shaders.py 4efb_amt1_x
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402

import verify_shader_port as vsp  # noqa: E402
from shader_library import ShaderLibrary  # noqa: E402
from shader_port import ADDON, nud_filter, nud_lod_bias  # noqa: E402


def plain(value):
    if hasattr(value, 'items'):
        items = list(value.items())
        if items and all(isinstance(k, int) for k, _ in items) and sorted(k for k, _ in items) == list(range(1, len(items) + 1)):
            return [plain(v) for _, v in sorted(items)]
        return {k: plain(v) for k, v in items}
    return value


def normalised(shader) -> dict:
    layout = plain(shader)
    for key in ('dynamic', 'static', 'compiled', 'samplers', 'notes', 'matrices', 'materialTextures'):
        if layout.get(key) in (None, {}):
            layout[key] = []
    return layout


def package_layouts(name: str, addon: Path = ADDON) -> dict[str, tuple[dict, dict]]:
    """mesh label -> (shader layout, texture addressing), for the meshes that have a
    translated shader, and the ribbon of every trail (storm_import.py Importer.ribbon).
    Addressing: game texture name -> verify_shader_port.Sampling."""
    lua = LuaRuntime(unpack_returned_tuples=True)
    data = lua.execute((addon / 'lua/storm_fx/packages' / f'{name}.lua').read_text(encoding='utf-8'))
    out = {}
    for animation, definitions in (data.trails.items() if data.trails else []):
        for index, definition in definitions.items():
            draw = definition.draw
            if not draw or not draw.mesh.shader:
                continue
            layout = normalised(draw.mesh.shader)
            addressing = {}
            for sampler in layout['samplers']:
                slot = sampler.get('material')
                if slot is not None:
                    # The trail descriptor's sampler (0x141237410): wrap (NUD code 1), linear,
                    # the LOD bias the importer recorded (-8).
                    entry = draw.mesh.textures[slot + 1]
                    record = data.textures[entry.name]
                    addressing[sampler['name']] = vsp.Sampling(1, 1, record.width, record.height, record.levels,
                                                               float(entry.lod[1]), False, bool(entry.mipped))
            out[f'trail {animation}#{index}'] = (layout, addressing)
    for model_name, model in data.models.items():
        for index, mesh in model.meshes.items():
            if not mesh.shader:
                continue
            layout = normalised(mesh.shader)
            addressing = {}
            for sampler in layout['samplers']:
                slot = sampler.get('material')
                if slot is not None:
                    # Game side from the raw NUD sampler and the NUT, port side from the VTF the importer picked.
                    state, entry = mesh.state.textures[slot + 1], mesh.textures[slot + 1]
                    record = data.textures[entry.name]
                    addressing[sampler['name']] = vsp.Sampling(
                        state.wrap_s, state.wrap_t, record.width, record.height, record.levels, nud_lod_bias(state.lod_field),
                        nud_filter(state.min_filter, state.mag_filter) == 0, bool(entry.mipped))
            out[f'{model_name}#{index}'] = (layout, addressing)
    return out


def check_package(name: str, scenes: int = 3, seed: int = 1, addon: Path = ADDON, quiet: bool = False) -> dict:
    vsp.FOG_CLAMP = vsp.SMOOTH_NORMALS = True
    library, runner = ShaderLibrary(), vsp.PortRunner()
    report, done = {}, {}
    for label, (layout, addressing) in sorted(package_layouts(name, addon).items()):
        # Meshes with the same key, constants and addressing share a pair and a result.
        pair = (layout['vertex'], layout['pixel'], tuple(sorted(addressing.items(), key=lambda item: item[0])))
        if pair not in done:
            done[pair] = vsp.check(library, runner, layout, scenes, seed, addressing)
        report[label] = done[pair]
        if not quiet:
            print(f'{label} ({layout["key"]:#x}): {vsp.describe(done[pair])}'
                  + (f', notes {layout["notes"]}' if layout['notes'] else ''), flush=True)
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('package')
    ap.add_argument('--scenes', type=int, default=3)
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--addon', type=Path, default=ADDON,
                    help='addon folder holding the package (the surveys import into game_cache/survey_addon)')
    args = ap.parse_args()
    report = check_package(args.package, args.scenes, args.seed, args.addon)
    worst = max((row['max_error_255'] for row in report.values()), default=0.0)
    mismatch = sum(row['coverage_mismatch'] for row in report.values())
    target = ROOT / 'captured_assets' / f'package_shader_check_{args.package}.json'
    target.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print(f'{len(report)} meshes, worst error {worst:.1f}/255, coverage mismatch {mismatch}')
    print('WROTE:', target)
    if worst >= 1.5 or mismatch:
        raise SystemExit('FAIL: a translated shader differs from the game by more than 1/255')
    # Meshes lit by a point light: the port runs the light per pixel, the game per
    # vertex. On a dense mesh with continuous textures nearly every pixel must agree.
    lit = [row['point_light']['dense'] for row in report.values() if row.get('point_light')]
    if lit:
        shares = [100.0 * row['within_2'] / max(row['pixels'], 1) for row in lit]
        print(f'{len(lit)} meshes take a point light: on a dense mesh {min(shares):.2f}% to {max(shares):.2f}% of the pixels '
              f'are within 2/255 of the game, largest difference {max(row["max_error_255"] for row in lit):.0f}/255')
        if min(shares) < 99.0:
            raise SystemExit('FAIL: per-pixel point lighting does not converge to the game on a dense mesh')
    print('PASS: every shader of the package is within 1/255 of the game bytecode on these scenes'
          + (' (no light on the lit meshes; with a light, see the dense-mesh line)' if lit else ''))
