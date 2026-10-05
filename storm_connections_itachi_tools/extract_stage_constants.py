"""List the stage-level shader constants the captured match used.

The lit shader families (toon, point-lit) read constants the game fills from
its render context: light direction and colours, cel-shade parameters, stage
colour, point lights. This collects, over every draw of the Amaterasu
captures, the distinct values of each such constant, so the engine's stage
table can carry what the captured stage really had.

  python extract_stage_constants.py
"""

from __future__ import annotations

import json
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CAPTURES = ROOT / 'gpu_captures'
FRAMES = [22082, 22102, 22127, 22136, 22149, 22171, 22200]
# Constants written by the context accessors (shader_bindings_dispatch.json), not by a material.
STAGE = ['g_lightDirection', 'g_lightColor', 'g_dlightDirection', 'g_dlightColor', 'g_celShadeParam', 'g_ambientColor',
         'g_fogColor', 'g_fogParam', 'g_stageColor', 'g_stageParam', 'g_cparaColor1', 'g_cparaColor2', 'g_cparaParam',
         'g_pointLightColor0', 'g_pointLightPos0', 'g_pointLightParam0', 'g_shadowColor', 'g_eyePos', 'g_outlineParam',
         'g_dloutlineParam', 'g_olIdParam', 'g_shadeColor', 'g_toneOffsetParam', 'g_useStColor', 'g_zrange', 'g_clip',
         'g_volumeParam', 'g_ScreenToUV']

if __name__ == '__main__':
    values: dict[str, Counter] = defaultdict(Counter)
    draws = 0
    for frame in FRAMES:
        path = CAPTURES / f'itachi_amaterasu_frame{frame}.all_draws.json'
        if not path.exists():
            continue
        for d in json.loads(path.read_text(encoding='utf-8')):
            draws += 1
            seen = {}
            matrix = None
            for stage in d.get('constants', {}).values():
                for buf in stage.values():
                    for name, field in buf.get('fields', {}).items():
                        if name in STAGE:
                            seen[name] = tuple(round(float(v), 5) for v in field['values'])
                        elif name == 'g_matWorld':
                            m = [float(v) for v in field['values']]
                            matrix = [m[0:4], m[4:8], m[8:12], m[12:16]]
            for name, value in seen.items():
                values[name][value] += 1
            # g_lightDirection is the light set's first directional light taken into
            # object space (context fill 0x1413368f0: inverse(model) * direction).
            # Back in world space every draw of one light set must agree.
            if 'g_lightDirection' in seen and matrix is not None:
                x, y, z = seen['g_lightDirection'][:3]
                world = [x * matrix[0][c] + y * matrix[1][c] + z * matrix[2][c] for c in range(3)]
                size = sum(c * c for c in world) ** 0.5
                if size > 1e-6:
                    values['light direction, world space (unit)'][tuple(round(c / size, 3) for c in world)] += 1
                    values['light direction, world space (length)'][(round(size, 3),)] += 1
    STAGE += ['light direction, world space (unit)', 'light direction, world space (length)']
    report = {}
    print(f'{draws} draws')
    for name in STAGE:
        if name not in values:
            print(f'{name}: never captured')
            continue
        print(f'{name}: {len(values[name])} distinct values')
        for value, count in values[name].most_common(6):
            print(f'    {count:5d}  {list(value)}')
        report[name] = [{'value': list(v), 'draws': c} for v, c in values[name].most_common(40)]
    target = ROOT / 'captured_assets/stage_constants.json'
    target.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
