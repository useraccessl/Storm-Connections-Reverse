"""Check the native constant-buffer and render-state model against captured draws.

Native rules under test (NSUNSC.exe, see shader_constant_pipeline.md):
  1. Buffer layout = D3DReflect variables merged per register slot over VS+PS;
     captured field offsets must equal the reflected StartOffset.
  2. NUD material property "NU_x" is staged as shader constant "g_x"
     (0x141270830 builds "g_%s" from name+3; 0x141271ea0 applies it).
  3. The per-program staging block is zero-filled after each model draw
     (0x141237b80), so a constant no native writer touches is uploaded as zero.
  4. Every enabled blend state is one colour mode and one alpha mode of the
     two native 13-entry tables (0x14126bc70).
  5. A NUD material fixes blend modes (dest_factor nibbles), depth write
     (source_factor bit 2) and cull (cull_mode) as decoded in 0x141270830,
     and blend enable through its sort bucket (source_factor bit 0,
     0x141241450 with the layer toggles of 0x141219480).

Rules 3 and 5 need the NUD group of the draw. The capture's `base_asset` names
the first bound texture, so the group is resolved by name plus texture count,
else by the same-family groups that have that texture count. Other draws get
their non-accessor, non-zero fields listed as open writer inventory.
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path

from dxbc_rdef import merged_layout, parse_rdef
from native_render_state import ALPHA_MODES, COLOR_MODES, blend_mode, nud_material_state

ROOT = Path(__file__).resolve().parent
PROGRAM_STANDARD = {'g_matWorldViewProj'}  # program+0x2f8, written by 0x141271ea0


def nud_materials(path: Path) -> dict[str, dict]:
    """NUD group name -> {'textures': count, 'props': {"g_x": values}, 'state': {...}}."""
    out: dict[str, dict] = {}
    for model in json.loads(path.read_text(encoding='utf-8')).get('models', []):
        for group in model.get('groups', []):
            rec = out.setdefault(group.get('name'), {'textures': 0, 'props': {}, 'state': None})
            for mesh in group.get('meshes', []):
                for material in mesh.get('materials', []):
                    rec['textures'] = max(rec['textures'], len(material.get('textures', [])))
                    rec['state'] = rec['state'] or nud_material_state(material)
                    for prop in material.get('properties', []):
                        if prop.get('name', '').startswith('NU_'):
                            rec['props']['g_' + prop['name'][3:]] = prop['values']
    return out


def resolve_material(nud: dict[str, dict], asset: str | None, texture_count: int) -> tuple[list[dict], str]:
    """Candidate NUD groups for a draw and how they were found.

    A texture can be shared by several groups, so a same-named group is only a
    hint: every same-family group with the draw's texture count is a candidate.
    """
    if not asset:
        return [], 'unresolved'
    family = asset.split('_')[0] + '_'
    same = [m for name, m in nud.items() if name.startswith(family) and m['textures'] == texture_count]
    if not same:
        return [], 'unresolved'
    own = nud.get(asset)
    return same, 'group_name' if own in same else 'texture_count'


def strip(name: str) -> str:
    return name.split('.', 1)[-1]


def captured_state(draw: dict) -> dict:
    blend = draw['blend'][0]
    return {
        'blend_enabled': blend['enabled'],
        'rgb': tuple(strip(x) for x in blend['rgb']), 'alpha': tuple(strip(x) for x in blend['alpha']),
        'depth_write': draw['depth']['writes'], 'cull': strip(draw['cull']),
        'topology': strip(draw['topology']),
    }


def state_matches(native: dict, seen: dict) -> bool:
    if native['depth_write'] != seen['depth_write'] or native['cull'] != seen['cull']:
        return False
    if native['topology'] != seen['topology'] or native['blend_enabled'] != seen['blend_enabled']:
        return False
    return not seen['blend_enabled'] or (native['rgb'] == seen['rgb'] and native['alpha'] == seen['alpha'])


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--capture-dir', type=Path, default=ROOT / 'gpu_captures')
    ap.add_argument('--capture-glob', default='*.effect_coverage_reference.json')
    ap.add_argument('--shader-dir', type=Path, default=ROOT / 'gpu_captures/captured_shaders')
    ap.add_argument('--inventory', type=Path, default=ROOT / 'captured_assets/nud_inventory.json')
    ap.add_argument('--accessors', type=Path, default=ROOT / 'shader_bindings_dispatch.json')
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/procedural/constant_buffer_model_check.json')
    ap.add_argument('--tolerance', type=float, default=1e-6)
    args = ap.parse_args()

    accessor_names = {row['name'] for row in json.loads(args.accessors.read_text(encoding='utf-8'))}
    nud = nud_materials(args.inventory)
    colour_modes = {blend_mode(c): c for c in range(len(COLOR_MODES))}
    alpha_modes = {blend_mode(c, alpha=True): c for c in range(len(ALPHA_MODES))}
    layouts: dict[tuple[str, str], dict] = {}
    stats = defaultdict(int)
    failures: list[dict] = []
    open_writers: dict[str, dict[str, int]] = defaultdict(lambda: defaultdict(int))
    blend_mode_use: dict[str, int] = defaultdict(int)
    pairs: dict[str, dict] = {}

    for capture in sorted(args.capture_dir.glob(args.capture_glob)):
        for draw in json.loads(capture.read_text(encoding='utf-8')):
            vs_id = draw['shaders'].get('ShaderStage.Vertex', '')
            ps_id = draw['shaders'].get('ShaderStage.Pixel', '')
            key = (vs_id, ps_id)
            if key not in layouts:
                blobs = [args.shader_dir / f'{i}.dxbc' for i in key]
                if not all(b.exists() for b in blobs):
                    stats['draws_without_bytecode'] += 1
                    continue
                layouts[key] = merged_layout(*(parse_rdef(b.read_bytes()) for b in blobs))
            by_name = {b['name']: b for b in layouts[key]['buffers']}
            pair = f'{vs_id[:8]}/{ps_id[:8]}'
            pairs.setdefault(pair, {'draws': 0, 'buffers': {b['name']: {'slot': b['slot'], 'size': b['size']} for b in by_name.values()}})
            pairs[pair]['draws'] += 1
            stats['draws'] += 1
            asset = draw.get('base_asset')
            where = {'capture': capture.name, 'event': draw['event'], 'asset': asset, 'pair': pair}
            seen = captured_state(draw)

            # Rule 4: blend state is a pair of native mode codes.
            if seen['blend_enabled']:
                stats['blend_enabled_draws'] += 1
                c, a = colour_modes.get(seen['rgb']), alpha_modes.get(seen['alpha'])
                if c is None or a is None:
                    failures.append({**where, 'rule': 'blend_mode_table', 'detail': f'{seen["rgb"]} / {seen["alpha"]}'})
                else:
                    blend_mode_use[f'colour {c} alpha {a}'] += 1

            # Material resolution, then rule 5 on the candidates.
            candidates, how = resolve_material(nud, asset, len(draw.get('textures', [])))
            if candidates:
                fitting = [m for m in candidates if state_matches(m['state'], seen)]
                if not fitting:
                    failures.append({**where, 'rule': 'nud_state', 'detail': f'captured {seen}; native {[m["state"] for m in candidates]}'})
                else:
                    stats['nud_state_draws'] += 1
                    distinct = {json.dumps(m['state'], sort_keys=True) for m in candidates}
                    stats['nud_state_draws_all_candidates_agree'] += len(distinct) == 1
                    candidates = fitting
            props = candidates[0]['props'] if candidates and all(m['props'] == candidates[0]['props'] for m in candidates) else None
            if candidates and props is None:
                how = 'unresolved'
            is_nud = props is not None
            stats[f'material_{how}'] += 1

            for stage, buffers in draw.get('constants', {}).items():
                for name, buf in buffers.items():
                    ref = by_name.get(name)
                    if ref is None:
                        failures.append({**where, 'rule': 'layout', 'detail': f'{name} not in merged reflection'})
                        continue
                    captured_size = len(buf.get('raw_hex', '')) // 2
                    if captured_size > ref['gpu_byte_width']:
                        failures.append({**where, 'rule': 'layout', 'detail': f'{name} captured {captured_size} > merged {ref["gpu_byte_width"]}'})
                    stats['buffers'] += 1
                    stats['buffers_size_equal_merged'] += captured_size == ref['gpu_byte_width']
                    offsets = {v['name']: v for v in ref['variables']}
                    for field, rec in buf.get('fields', {}).items():
                        stats['fields'] += 1
                        var = offsets.get(field)
                        if var is None or var['offset'] != rec['offset']:
                            failures.append({**where, 'rule': 'layout', 'detail': f'{field} captured +{rec["offset"]} reflected {var and var["offset"]}'})
                            continue
                        values = rec['values']
                        nonzero = any(abs(x) > args.tolerance for x in values)
                        expected = props.get(field) if is_nud else None
                        if expected is not None:
                            stats['nud_property_fields'] += 1
                            if len(expected) > len(values) or any(abs(a - b) > args.tolerance for a, b in zip(expected, values)):
                                failures.append({**where, 'rule': 'nud_property', 'detail': f'{field} nud {expected} gpu {values}'})
                        elif field in accessor_names or field in PROGRAM_STANDARD:
                            stats['accessor_or_standard_fields'] += 1
                        elif is_nud:
                            stats['unwritten_fields'] += 1
                            if nonzero:
                                failures.append({**where, 'rule': 'zero_fill', 'detail': f'{field} = {values}'})
                        elif nonzero:
                            open_writers[pair][field] += 1

    report = {
        'rules': [line.strip() for line in __doc__.strip().splitlines()[3:14]],
        'stats': dict(stats),
        'blend_mode_use': dict(blend_mode_use),
        'shader_pairs': pairs,
        'failures': failures[:200],
        'failure_count': len(failures),
        'non_nud_draw_fields_needing_a_writer': {p: dict(f) for p, f in open_writers.items()},
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + '\n', encoding='utf-8')
    print(json.dumps(report['stats'], indent=2))
    print('blend modes used:', dict(blend_mode_use))
    for p, fields in report['non_nud_draw_fields_needing_a_writer'].items():
        print('open writers', p, fields)
    if failures:
        for f in failures[:20]:
            print('FAIL', f)
        raise SystemExit(f'{len(failures)} failures; report: {args.output}')
    print('PASS: layout, NUD property, zero-fill, blend-mode and NUD state rules hold on every checked draw')
    print('WROTE:', args.output)


if __name__ == '__main__':
    main()
