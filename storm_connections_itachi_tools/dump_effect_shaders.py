"""Write the D3D disassembly of every shader used by captured effect draws.

Output: captured_assets/procedural/effect_shaders/<vs>__<ps>.txt with the
draw count per capture, one file per shader pair, so each pair can be ported
and checked against the game with soft_replay.
"""

from __future__ import annotations

import json
from collections import Counter
from pathlib import Path

import soft_replay as sr

ROOT = Path(__file__).resolve().parent
CAPTURES = ROOT / 'gpu_captures'
OUT = ROOT / 'captured_assets/procedural/effect_shaders'

if __name__ == '__main__':
    pairs: Counter = Counter()
    for path in sorted(CAPTURES.glob('*.effect_coverage_reference.json')):
        for d in json.loads(path.read_text(encoding='utf-8')):
            pairs[(d['shaders']['ShaderStage.Vertex'], d['shaders']['ShaderStage.Pixel'])] += 1
    OUT.mkdir(parents=True, exist_ok=True)
    for (vs, ps), count in pairs.most_common():
        text = [f'// {count} effect draws in the exported captures', f'// vertex {vs}', f'// pixel  {ps}', '']
        for shader in (vs, ps):
            text.append(sr.disassemble((CAPTURES / 'captured_shaders' / f'{shader}.dxbc').read_bytes()).replace('\0', ''))
        name = f'{vs[:8]}__{ps[:8]}.txt'
        (OUT / name).write_text('\n'.join(text), encoding='utf-8')
        print(f'{count:4d} {name}')
