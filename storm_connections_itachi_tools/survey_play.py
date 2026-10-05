"""Import many skills and play each one in the offline engine.

For a sample of data/skill files: storm_import.py into a scratch addon, then
play_package.py (every root script cast, stepped until it drains). Counts what
ran and every reason something did not: Lua errors, effects that could not be
launched, engine notes, meshes without a shader, importer gaps. The aim is to
find what the engine still lacks on skills no capture covers; it checks no
pixel.

  python survey_play.py --count 25 --seed 2
"""

from __future__ import annotations

import argparse
import json
import random
import re
import traceback
from collections import Counter
from pathlib import Path

from game_data import GameData
from play_package import play
from storm_import import Importer

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'

if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--count', type=int, default=20)
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--filter', default='')
    ap.add_argument('--frames', type=int, default=600)
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/skill_play_survey.json')
    args = ap.parse_args()
    game = GameData()
    files = [n for n in game.find('data/skill/') if args.filter in n]
    random.Random(args.seed).shuffle(files)
    files = files[:args.count] if args.count else files
    totals = {k: Counter() for k in ('outcome', 'script', 'note', 'not rendered', 'mesh without shader', 'importer gap')}
    rows = {}
    generic = lambda text: re.sub(r'[0-9a-z_]*\d[0-9a-z_]*', '#', text)
    for name in files:
        stem = Path(name).stem
        try:
            importer = Importer(game, stem, SCRATCH)
            importer.skill_file(name)
            importer.write()
            report = play(stem, args.frames, verbose=False, addon=SCRATCH)
        except Exception as error:
            totals['outcome'][f'failed: {type(error).__name__}: {generic(str(error))[:90]}'] += 1
            rows[stem] = {'crash': traceback.format_exc(limit=4)}
            print(f'{stem}: FAILED {type(error).__name__}: {str(error)[:140]}', flush=True)
            continue
        rows[stem] = report
        totals['outcome']['imported and played'] += 1
        drew = 0
        for script, row in report['scripts'].items():
            drew += row['draws']
            if row['error']:
                totals['script'][f'error: {generic(row["error"])[:110]}'] += 1
            elif not row['effects']:
                totals['script']['ran, launched no effect'] += 1
            else:
                totals['script']['ran with effects'] += 1
            for note in row['notes']:
                totals['note'][generic(note.split(': ', 1)[-1])[:110]] += 1
            for skipped in row['skipped']:
                totals['not rendered'][generic(skipped)[:60]] += 1
            for why in row.get('dropped', {}).values():
                totals['script'][f'effect dropped: {generic(why)[:110]}'] += 1
        for why in report['models_without_shader'].values():
            totals['mesh without shader'][generic(why)[:110]] += 1
        for line in report['engine_notes']:
            totals['note'][generic(line)[:110]] += 1
        for what, why in report['not_imported']:
            totals['importer gap'][f'{what.split(" ")[0]}: {generic(why)[:100]}'] += 1
        print(f'{stem}: {len(report["scripts"])} root scripts, {drew} draws sampled, '
              f'{report["meshes_drawn"]} meshes drawn, {len(report["meshes_never_drawn"])} never drawn', flush=True)
    args.output.write_text(json.dumps({'files': len(files), 'totals': {k: dict(v.most_common()) for k, v in totals.items()},
                                       'per_file': rows}, indent=1, default=str) + '\n', encoding='utf-8')
    for label, counter in totals.items():
        print(f'{label}:')
        for key, count in counter.most_common(25):
            print(f'    {count:5d}  {key}')
    print('WROTE:', args.output)
