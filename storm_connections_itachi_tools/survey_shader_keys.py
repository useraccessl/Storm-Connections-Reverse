"""Census of the NUD shader keys used by the game's effect models.

Walks every nuccChunkModel of the indexed effect files (chunk_index.py sets)
and counts, per material pass of every mesh, the shader key (NUD material
flags), blend factors and vertex layout. Says which shader pairs of
nuccMaterial_dx11.nsh the engine needs for full coverage.
"""

from __future__ import annotations

import argparse
import json
import multiprocessing
import struct
from collections import Counter
from pathlib import Path

from chunk_index import SETS
from game_data import GameData
from inspect_nud import parse_nud
from xfbin_chunks import parse

ROOT = Path(__file__).resolve().parent
_game: GameData | None = None


def _scan(name: str):
    global _game
    if _game is None:
        _game = GameData()
    rows = []
    try:
        data, chunks = parse(_game.fetch(name))
    except Exception as error:
        return name, rows, repr(error)
    for c in chunks:
        if c['type'] != 'nuccChunkModel':
            continue
        body = data[c['offset']:c['offset'] + c['size']]
        at = body.find(b'NDP3')
        if at < 0:
            continue
        try:
            nud = parse_nud(body[at:at + struct.unpack_from('>I', body, at + 4)[0]])
        except Exception:
            rows.append((c['name'], 'unparsed', 0, 0, 0, 0, 0))
            continue
        for g in nud['groups']:
            for m in g['meshes']:
                passes = tuple(mat['flags'] for mat in m['materials'])
                for index, mat in enumerate(m['materials']):
                    rows.append((c['name'], passes, index, mat['flags'], mat['source_factor'], mat['dest_factor'],
                                 m['vertex_size'] | (m['uv_size'] << 8)))
    return name, rows, None


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('sets', nargs='*', default=['effect', 'spc_eff'])
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/shader_key_census.json')
    args = ap.parse_args()
    game = GameData()
    names = sorted({v['name'] for v in game.index.values() for s in args.sets if SETS[s](v['name'].lower())})
    keys, combos, first_pass, layouts, examples = Counter(), Counter(), Counter(), Counter(), {}
    models = set()
    with multiprocessing.Pool(max(1, multiprocessing.cpu_count() - 2)) as pool:
        for name, rows, error in pool.imap_unordered(_scan, names):
            if error:
                print('  failed', name, error)
            for model, passes, index, flags, source, dest, layout in rows:
                if passes == 'unparsed':
                    keys['unparsed NUD'] += 1
                    continue
                if (name, model) in models and index == 0:
                    pass
                models.add((name, model))
                keys[f'{flags:#08x}'] += 1
                examples.setdefault(f'{flags:#08x}', f'{model} ({name})')
                if index == 0:
                    combos[' + '.join(f'{p:#x}' for p in passes)] += 1
                    first_pass[f'{flags:#08x}'] += 1
                layouts[f'{flags:#08x} vertex {layout & 0xff:#04x} uv {layout >> 8:#04x}'] += 1
    report = {'files': len(names), 'models': len(models), 'keys': dict(keys.most_common()), 'pass_lists': dict(combos.most_common()),
              'first_pass': dict(first_pass.most_common()), 'layouts': dict(layouts.most_common()), 'examples': examples}
    args.output.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print(f'{len(names)} files, {len(models)} models')
    print('pass lists (materials of one mesh):')
    for k, v in combos.most_common(40):
        print(f'  {v:6d}  {k}')
    print('keys over all passes:')
    for k, v in keys.most_common(60):
        print(f'  {v:6d}  {k}   e.g. {examples.get(k, "")}')
    print('WROTE:', args.output)
