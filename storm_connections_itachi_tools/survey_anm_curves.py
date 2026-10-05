"""Census of the curve formats the game's effect animations use.

Decodes every nuccChunkAnm of the indexed effect files and counts
(entry type, curve index, curve format). Entry types: 1 coordinate (curves
0 position, 1 rotation, 2 scale, 3 opacity), 4 material, 6 point light, the
others as found. Says which key readers the engine needs (anm_key_classes.py
lists the native class of each format).
"""

from __future__ import annotations

import argparse
import json
import multiprocessing
import struct
from collections import Counter
from pathlib import Path

from chunk_index import SETS
from decode_effect_animation import decode
from game_data import GameData
from xfbin_chunks import parse

ROOT = Path(__file__).resolve().parent
_game: GameData | None = None


def _scan(name: str):
    global _game
    if _game is None:
        _game = GameData()
    rows, failures = Counter(), Counter()
    try:
        data, chunks = parse(_game.fetch(name))
    except Exception as error:
        return rows, Counter({f'file: {type(error).__name__}': 1})
    for c in chunks:
        if c['type'] != 'nuccChunkAnm':
            continue
        version = struct.unpack_from('>H', data, c['offset'] - 4)[0]
        body = data[c['offset']:c['offset'] + c['size']]
        try:
            anm = decode(body, lambda i: i, None, legacy=version <= 0x65)
        except Exception as error:
            failures[f'{type(error).__name__}: {str(error)[:40]}'] += 1
            continue
        rows[('animations', 0, 0)] += 1
        for entry in anm['entries']:
            for curve in entry['curves']:
                rows[(entry['type'], curve['index'], curve['format'])] += 1
    return rows, failures


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('sets', nargs='*', default=['effect', 'spc_eff'])
    args = ap.parse_args()
    game = GameData()
    names = sorted({v['name'] for v in game.index.values() for s in args.sets if SETS[s](v['name'].lower())})
    total, failed = Counter(), Counter()
    with multiprocessing.Pool(max(1, multiprocessing.cpu_count() - 2)) as pool:
        for rows, failures in pool.imap_unordered(_scan, names):
            total.update(rows)
            failed.update(failures)
    print(f'{len(names)} files, {total.pop(("animations", 0, 0), 0)} animations decoded, failures {dict(failed)}')
    for (kind, index, fmt), count in sorted(total.items()):
        print(f'  entry type {kind}  curve {index:2d}  format {fmt:2d} ({fmt:#04x}): {count}')
    target = ROOT / 'captured_assets/anm_curve_census.json'
    target.write_text(json.dumps([{'entry_type': k, 'curve': i, 'format': f, 'count': n} for (k, i, f), n in sorted(total.items())],
                                 indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
