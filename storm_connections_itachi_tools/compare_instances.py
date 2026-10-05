"""Compare per-instance transforms: game capture draws versus the port's particles.

Game side: world matrix of every effect draw = g_matWorldViewProj * inverse(VP),
giving instance origin, axis lengths (size) and height above the effect anchor.
Port side: particle position, size and resource from the offline Lua scene.
Both are reported relative to the effect anchor so scale and placement gaps
show up without needing matching random seeds.
"""

from __future__ import annotations

import argparse
import json
from collections import defaultdict
from pathlib import Path

import numpy as np

from port_preview import CAPTURES, Port, capture_camera


def game_instances(frame: int, anchor: np.ndarray) -> list[dict]:
    vp = capture_camera(frame)['vp']
    inverse = np.linalg.inv(vp)
    path = CAPTURES / f'itachi_amaterasu_frame{frame}.effect_coverage_reference.json'
    out = []
    for d in json.loads(path.read_text(encoding='utf-8')):
        fields = d['constants']['ShaderStage.Vertex']
        fields = next(iter(fields.values()))['fields']
        if 'g_matWorldViewProj' not in fields:
            continue
        world = np.array(fields['g_matWorldViewProj']['values'], dtype=np.float64).reshape(4, 4) @ inverse
        out.append({
            'event': d['event'], 'asset': d.get('base_asset'), 'shader': d['shaders']['ShaderStage.Pixel'][:8],
            'textures': len(d['textures']), 'origin': world[3, :3] - anchor,
            'axes': [float(np.linalg.norm(world[i, :3])) for i in range(3)],
            'tint': fields.get('g_multColor', {}).get('values'), 'uv': fields.get('g_uvOffset0', {}).get('values'),
        })
    return out


def summarize(rows: list[dict], key: str) -> None:
    groups = defaultdict(list)
    for r in rows:
        groups[r[key]].append(r)
    for name, items in sorted(groups.items(), key=lambda kv: str(kv[0])):
        origins = np.array([r['origin'] for r in items])
        axes = np.array([r['axes'] for r in items])
        print(f'  {str(name):28s} n={len(items):3d} size x {axes[:, 0].min():7.2f}..{axes[:, 0].max():7.2f} '
              f'y {axes[:, 1].min():7.2f}..{axes[:, 1].max():7.2f} | origin x {origins[:, 0].min():7.1f}..{origins[:, 0].max():7.1f} '
              f'y {origins[:, 1].min():7.1f}..{origins[:, 1].max():7.1f} z {origins[:, 2].min():7.1f}..{origins[:, 2].max():7.1f}')


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--capture-frames', type=int, nargs='+', default=[22082, 22102, 22127, 22136, 22149, 22171, 22200])
    ap.add_argument('--port-frames', type=int, nargs='+', default=[5, 20, 40, 60, 80, 100, 120])
    ap.add_argument('--seed', default='1')
    args = ap.parse_args()
    summary = json.loads((CAPTURES / 'captured_frame_summary.json').read_text(encoding='utf-8'))
    anchor = np.array(summary['original_center'])
    for frame in args.capture_frames:
        rows = game_instances(frame, anchor)
        print(f'GAME frame {frame}: {len(rows)} effect draws')
        summarize(rows, 'asset')
    camera = capture_camera(22136)
    port = Port(camera, [0.0, 0.0, 0.0], (3840, 2160))
    port.start('1', args.seed)
    current = 0
    for target in sorted(args.port_frames):
        while current <= target:
            port.advance(current)
            current += 1
        active = port.lua.globals().STORM_AMATERASU_PROCEDURAL.active
        if not active:
            print(f'PORT frame {target}: effect finished')
            break
        rows = []
        for p in active.scene.particles.values():
            rows.append({'resource': p.resource, 'origin': np.array(list(p.position.values())),
                         'axes': list(p.size.values()) + [0.0] * (3 - len(list(p.size.values())))})
        print(f'PORT frame {target}: {len(rows)} particles (scene frame {active.scene.frame})')
        summarize(rows, 'resource')
