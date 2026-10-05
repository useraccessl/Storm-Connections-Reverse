"""Group the draws of an exported capture into passes (runs sharing output targets).

Reads `<capture>.all_draws.json` and marks which runs contain effect draws
listed in `<capture>.effect_coverage_reference.json`. This is the capture-side
view of the engine's layer order.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent


def target_ids(draw: dict) -> tuple[str, ...]:
    out = []
    for t in draw.get('targets', []):
        rid = t.get('resource') if isinstance(t, dict) else t
        rid = str(rid)
        if rid and not rid.endswith('::0') and 'Null' not in rid:
            out.append(rid.split('::')[-1])
    return tuple(out)


def summarize(frame: int) -> list[dict]:
    base = ROOT / 'gpu_captures' / f'itachi_amaterasu_frame{frame}'
    draws = json.loads(base.with_suffix('.all_draws.json').read_text(encoding='utf-8'))
    coverage = base.with_suffix('.effect_coverage_reference.json')
    effect = {d['event'] for d in json.loads(coverage.read_text(encoding='utf-8'))} if coverage.exists() else set()
    groups: list[dict] = []
    for d in draws:
        key = target_ids(d)
        ps = d.get('shaders', {}).get('ShaderStage.Pixel', '')[:8]
        blend = d.get('blend', [{}])[0].get('enabled')
        if groups and groups[-1]['targets'] == key:
            g = groups[-1]
        else:
            g = {'targets': key, 'first': d['event'], 'draws': 0, 'effect_draws': 0, 'shaders': {}, 'blended': 0}
            groups.append(g)
        g['last'] = d['event']
        g['draws'] += 1
        g['effect_draws'] += d['event'] in effect
        g['blended'] += bool(blend)
        g['shaders'][ps] = g['shaders'].get(ps, 0) + 1
    return groups


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--frame', type=int, default=22136)
    ap.add_argument('--json', type=Path)
    args = ap.parse_args()
    passes = summarize(args.frame)
    for g in passes:
        top = sorted(g['shaders'].items(), key=lambda kv: -kv[1])[:4]
        print(f'{g["first"]:6d}-{g["last"]:6d} draws {g["draws"]:4d} effect {g["effect_draws"]:3d} '
              f'blended {g["blended"]:4d} targets {",".join(g["targets"]) or "-"} shaders {top}')
    if args.json:
        args.json.write_text(json.dumps(passes, indent=2) + '\n', encoding='utf-8')
