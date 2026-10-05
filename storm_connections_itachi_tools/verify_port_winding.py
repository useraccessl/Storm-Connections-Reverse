"""Check that culled port meshes face the camera the way Source needs.

Game: front faces are counter-clockwise on screen (every triangle of every
captured draw with cull Back is counter-clockwise and visible). Source culls
counter-clockwise triangles. The port must therefore submit a game front face
clockwise. This runs the port offline in a captured camera and asserts that
every triangle of every material created with $cull 1 is clockwise on screen,
and reports the game's own statistics next to it.
"""

from __future__ import annotations

import json
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
from port_preview import CAPTURES, Port, capture_camera  # noqa: E402
from replay_capture_draws import semantic_key, stream, triangles  # noqa: E402

FRAME = 22136


def signed_area(clip: np.ndarray, tris: np.ndarray) -> np.ndarray:
    """> 0 clockwise on screen, < 0 counter-clockwise (pixel y grows downwards)."""
    ndc = clip[:, :2] / clip[:, 3:4]
    sx, sy = ndc[:, 0], -ndc[:, 1]
    a, b, c = tris[:, 0], tris[:, 1], tris[:, 2]
    return (sx[b] - sx[a]) * (sy[c] - sy[a]) - (sx[c] - sx[a]) * (sy[b] - sy[a])


if __name__ == '__main__':
    camera = capture_camera(FRAME)
    game = defaultdict(lambda: [0, 0])
    for d in json.loads((CAPTURES / f'itachi_amaterasu_frame{FRAME}.effect_coverage_reference.json').read_text(encoding='utf-8')):
        if not d['cull'].endswith('Back'):
            continue
        fields = {}
        for stage in d['constants'].values():
            for buf in stage.values():
                fields.update(buf['fields'])
        wvp = np.array(fields['g_matWorldViewProj']['values'], dtype=np.float64).reshape(4, 4)
        elements = {semantic_key(e['name']): e for e in d['inputs']}
        area = signed_area(stream(d, elements['POSITION0']).astype(np.float64) @ wvp, triangles(d))
        row = game[(d['shaders']['ShaderStage.Pixel'][:8], d['base_asset'])]
        row[0] += int((area > 0).sum())
        row[1] += int((area < 0).sum())
    print('game, cull Back (clockwise, counter-clockwise):')
    for key, (cw, ccw) in sorted(game.items()):
        print(f'  {key}: {cw}, {ccw}')
    port = Port(dict(camera, yaw=23.1), [209.6, -476.4, -3.7], (3840, 2160))
    port.start('1', '1')
    materials = port.lua.globals().PREVIEW.materials
    seen = defaultdict(lambda: [0, 0])
    for frame in range(0, 121):
        port.advance(frame)
        if frame % 10:
            continue
        for d in port.collect():
            if d.get('marker') or dict(materials[d['material']].params.items())['$cull'] != '1':
                continue
            data = port.mesh(d['mesh']).astype(np.float64)
            position = np.concatenate([data[:, :3], np.ones((len(data), 1))], axis=1)
            area = signed_area(position @ (d['matrix'].T @ camera['vp']), np.arange(len(data)).reshape(-1, 3))
            seen[d['material']][0] += int((area > 0).sum())
            seen[d['material']][1] += int((area < 0).sum())
    print('port, $cull 1 (clockwise, counter-clockwise):')
    failed = False
    for name, (cw, ccw) in sorted(seen.items()):
        print(f'  {name}: {cw}, {ccw}')
        failed |= ccw > 0 or cw == 0
    if failed or not seen:
        raise SystemExit('FAIL: a culled port material submits back faces to Source')
    print('PASS: every culled port triangle is clockwise on screen, Source front-facing')
