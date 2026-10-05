"""Check the generic importer against the hand-assembled Amaterasu data.

Before storm_import.py the Amaterasu data was produced by a chain of
single-purpose scripts (captured_runtime_data.lua, procedural_assets.lua,
auxiliary_assets.lua). Those files drove every verified result so far. This
compares them, value for value, with the package storm_import.py writes for
the same skill, so the generic path inherits that validation.
"""

from __future__ import annotations

import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402

ADDON = ROOT.parent / 'storm_amaterasu_lab/lua'
EFFECTS = ('4efb_amt1_hit00', '4efb_amt1_blt00')


def plain(value):
    if hasattr(value, 'items'):
        items = list(value.items())
        if items and all(isinstance(k, int) for k, _ in items) and sorted(k for k, _ in items) == list(range(1, len(items) + 1)):
            return [plain(v) for _, v in sorted(items)]
        return {k: plain(v) for k, v in items}
    return value


def differences(old, new, path='', out=None, limit=12):
    out = [] if out is None else out
    if len(out) >= limit:
        return out
    if isinstance(old, dict) and isinstance(new, dict):
        for key in old:
            if key not in new:
                out.append(f'{path}.{key}: missing in the package')
            else:
                differences(old[key], new[key], f'{path}.{key}', out, limit)
    elif isinstance(old, list) and isinstance(new, list):
        if len(old) != len(new):
            out.append(f'{path}: length {len(old)} vs {len(new)}')
        else:
            for i, (a, b) in enumerate(zip(old, new)):
                differences(a, b, f'{path}[{i + 1}]', out, limit)
    elif old != new and not (old in ([], {}) and new in ([], {})) and not same_vertex_value(old, new, path):
        out.append(f'{path}: {old!r} vs {new!r}')
    return out


def same_vertex_value(old, new, path: str) -> bool:
    """The package writes vertex rows and second UV sets short (storm_import.Short): the
    same float32 with fewer digits."""
    if '.vertices[' not in path and '.uvSets[' not in path:
        return False
    if not isinstance(old, (int, float)) or not isinstance(new, (int, float)):
        return False
    return np.float32(old) == np.float32(new)


def outside_targets(animation: dict, package_animation: dict) -> tuple[dict, list[str]]:
    """The hand-assembled animations name an entry outside the clumps (a light) after
    the reference pair of its index; the animation reader 0x14134a350 resolves those
    references in the file's chunk map (journal R86), so the package names the light
    chunk itself. The reference copy takes the package's name for those entries, and
    each such replacement is listed."""
    out, notes = dict(animation), []
    entries = []
    for old, new in zip(animation['entries'], package_animation['entries']):
        if old.get('clump_index') == -1 and old.get('target') != new.get('target'):
            notes.append(f'entry type {old["type"]}: {old["target"]!r} -> {new["target"]!r} ({new.get("chunkType")})')
            old = dict(old, target=new['target'])
        entries.append(old)
    out['entries'] = entries
    return out, notes


def renamed(state: dict) -> dict:
    """A NUD state exported before the sampler bytes were named after what the game does
    with them (inspect_nud.py): +0xE is the third wrap code, +0x10 the minify filter,
    +0x16 the LOD bias field (it was read as a signed short)."""
    out = dict(state)
    out['textures'] = [{'unk0': t['unk0'], 'map_mode': t['map_mode'], 'wrap_s': t['wrap_s'], 'wrap_t': t['wrap_t'],
                        'wrap_r': t['min_filter'], 'mag_filter': t['mag_filter'], 'min_filter': t['mip_detail'],
                        'unk1': t['unk1'], 'lod_field': t['unk2'] & 0xffff} for t in state['textures']]
    return out


if __name__ == '__main__':
    lua = LuaRuntime(unpack_returned_tuples=True)
    load = lambda relative: plain(lua.execute((ADDON / relative).read_text(encoding='utf-8-sig')))
    data = load('storm_amt_lab/captured_runtime_data.lua')
    assets = load('storm_amt_lab/procedural_assets.lua')
    aux = load('storm_amt_lab/auxiliary_assets.lua')
    package = load('storm_fx/packages/4efb_amt1_x.lua')
    failures = []

    def check(label, old, new):
        found = differences(old, new)
        print(f'{"PASS" if not found else "FAIL"}: {label}')
        for line in found:
            print('     ', line)
        failures.extend(found)

    for effect in EFFECTS:
        old = [{k: v for k, v in e.items() if k not in ('attachments', 'forces')} for e in data['effects'][effect]]
        check(f'{effect}: emitter fields, resources and events', old, package['effects'][effect])
        check(f'{effect}: attachments per emitter',
              [[{'coord': a['coord'], 'clump': a['clump']} for a in e['attachments']] for e in data['effects'][effect]],
              [e['attachments'] for e in package['effects'][effect]])
        records = data['spatialRecords'][effect]
        check(f'{effect}: spatial records',
              {kind: [{k: v for k, v in r.items() if k != 'file_offset'} for r in records[kind]] for kind in ('attachments', 'forces')},
              package['spatialRecords'][effect])
        reference, notes = outside_targets(data['animations'][effect], package['animations'][effect])
        for note in notes:
            print(f'NOTE: {effect}: outside-clump {note} (R86 reference rule)')
        check(f'{effect}: animation', reference, package['animations'][effect])
    check('4efb_amt1_ptc02: animation', aux['animation'], package['animations']['4efb_amt1_ptc02'])
    for name, resource in assets['resources'].items():
        entry = package['resources'][name]
        model = package['models'][entry['model']]
        check(f'billboard {name}: channels and clock', resource['billboard'], entry['billboard'])
        check(f'billboard {name}: geometry and NUD state',
              [{'vertices': m['vertices'], 'triangles': m['triangles'], 'state': renamed(m['originalRenderState'][0])} for m in resource['meshes']],
              [{'vertices': m['vertices'], 'triangles': m['triangles'], 'state': m['state']} for m in model['meshes']])
        old = resource['material']
        check(f'billboard {name}: material',
              {'format': old['format'], 'field02': old['field02'], 'field04': old['field04'],
               'textures': [t['name'] for t in old['texture_groups'][0]['textures']]},
              {k: model['materials'][0][k] for k in ('format', 'field02', 'field04', 'textures')})
    for name, old in aux['models'].items():
        model = package['models'][name]
        check(f'model {name}: geometry, normals, UV sets and NUD state',
              [{'vertices': m['vertices'], 'triangles': m['triangles'], 'state': renamed(m['originalRenderState'][0]),
                'normalHalfRaw': m['normalHalfRaw']} for m in old['meshes']],
              [{'vertices': m['vertices'], 'triangles': m['triangles'], 'state': m['state'],
                'normalHalfRaw': m['normalHalfRaw']} for m in model['meshes']])
        check(f'model {name}: material',
              {k: old['materials'][0][k] for k in ('format', 'field02', 'field04')},
              {k: model['materials'][0][k] for k in ('format', 'field02', 'field04')})
    kinds = {name: package['resources'][name]['kind'] for name in assets['unsupportedResources']}
    print('non-billboard resources:', kinds)
    if failures:
        raise SystemExit(f'FAIL: {len(failures)} differences')
    print('PASS: the generic package equals the hand-assembled Amaterasu data')
