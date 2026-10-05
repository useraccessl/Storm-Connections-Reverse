"""Measure how much of the game's skills the generic pipeline covers.

Runs storm_import.py on many skill files (into a scratch folder, not the
addon) and counts, over everything they reference:
  * emitter resource kinds and the chunk types the importer cannot turn into data;
  * NUD shader keys of the imported meshes, split by whether shader_port.py
    could translate the game's shader pair for that material;
  * script action types with / without a translated motion;
  * importer failure reasons.
The result says what to reverse next; it renders nothing.
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
from storm_import import Importer

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
# Action classes skill_actor_core.lua translates (LASER and LIGHTNING_CRAWL are not).
SUPPORTED_ACTIONS = {'SKILL_ACTION_TYPE_NONE', 'SKILL_ACTION_TYPE_ARROW', 'SKILL_ACTION_TYPE_ELEVATOR', 'SKILL_ACTION_TYPE_CRAWLER',
                     'SKILL_ACTION_TYPE_SINCURVE', 'SKILL_ACTION_TYPE_BOUNDBALL'}


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--count', type=int, default=40, help='number of skill files to sample (0 = all)')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--filter', default='', help='only skill files whose name contains this')
    ap.add_argument('--max-file-mb', type=float, default=40, help='skip skills whose effect files exceed this packed size')
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/skill_import_survey.json')
    args = ap.parse_args()
    game = GameData()
    files = [n for n in game.find('data/skill/') if args.filter in n]
    random.Random(args.seed).shuffle(files)
    if args.count:
        files = files[:args.count]
    totals = {k: Counter() for k in ('resource kind', 'unsupported resource type', 'importer reason', 'shader key with renderer',
                                     'shader key without renderer', 'extra pass (not drawn)', 'action type',
                                     'skill file outcome', 'model problem')}
    per_file = {}
    for name in files:
        stem = Path(name).stem
        try:
            importer = Importer(game, stem, SCRATCH)
            sizes = []
            # Effect files can be large and the pure-Python unpacker is slow: check before loading.
            import skill_script
            scripts = skill_script.load(game.fetch(name))
            for script in scripts.values():
                for f in script['files']:
                    if game.has(f):
                        sizes.append(int(game.index[f.lower()]['entry']['FileSize']) / 1e6)
            if sizes and max(sizes) > args.max_file_mb:
                totals['skill file outcome']['skipped: effect file too large for the survey'] += 1
                continue
            importer.skill_file(name)
            importer.shaders()
        except Exception as error:      # a survey must not stop on one file
            totals['skill file outcome'][f'importer crashed: {type(error).__name__}'] += 1
            per_file[stem] = {'crash': traceback.format_exc(limit=3)}
            continue
        out = importer.out
        totals['skill file outcome']['imported'] += 1
        row = {'effects': len([e for e in out['effects'].values() if e]), 'unsupported': out['unsupported'], 'keys': {}}
        for resource in out['resources'].values():
            totals['resource kind'][resource['kind']] += 1
            if resource['kind'] in ('unsupported', 'missing'):
                totals['unsupported resource type'][resource['type']] += 1
        for entry in out['unsupported']:
            reason = re.sub(r'[0-9a-fx_]*\d[0-9a-fx_]*', '#', entry['reason'])
            kind = entry['what'].split(' ')[0]
            totals['importer reason'][f'{kind}: {reason[:90]}'] += 1
            if kind == 'model':
                totals['model problem'][reason[:90]] += 1
        for model_name, model in out['models'].items():
            if not model:
                continue
            for mesh in model['meshes']:
                key = mesh['state']['flags']
                if mesh.get('shader'):
                    totals['shader key with renderer'][f'{key:#08x}'] += 1
                else:
                    totals['shader key without renderer'][f'{key:#08x}: {mesh.get("shaderProblem", "?")[:70]}'] += 1
                for extra in mesh['passes'][1:]:
                    totals['extra pass (not drawn)'][f'{extra:#08x}'] += 1
            row['keys'][model_name] = [f'{m["state"]["flags"]:#x}' for m in model['meshes']]
        for script in out['skills'].values():
            for action in script['actions']:
                totals['action type'][action['type'] + ('' if action['type'] in SUPPORTED_ACTIONS else ' (motion not translated)')] += 1
        per_file[stem] = row
        print(f'{stem}: {row["effects"]} effects, {len(out["resources"])} resources, {len(out["unsupported"])} unsupported', flush=True)
    report = {'files': len(files), 'totals': {k: dict(v.most_common()) for k, v in totals.items()}, 'per_file': per_file}
    args.output.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    for label, counter in totals.items():
        print(f'{label}:')
        for key, count in counter.most_common(25):
            print(f'    {count:6d}  {key}')
    print('WROTE:', args.output)
