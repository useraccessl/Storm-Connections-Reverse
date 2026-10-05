"""Check how the engine draws the billboard members of an emitter's clump resource.

  python verify_resource_billboards.py [package ...]

The game (journal R102): a nuccBillboard's clock only moves in 0x14128c890 (the one
caller of 0x1412c7f90), which runs for the clumps of an animation object; the clump of
an emitter resource is not one, so its billboard members keep what their initialisation
copies (0x1412c8110): the first key of every channel. Every effect of the given packages
whose emitters spawn such a clump is played in the engine (port_preview stubs) and every
draw of a member is compared with the package data: g_uvOffset0 = frame 0 of channels 5
(offset) and 6 (scale), the components the shader reads, as float32. Control: for a
member whose frame 1 differs, frame 1 must not match.

Nothing here runs in Garry's Mod, and no capture holds these draws.
"""

from __future__ import annotations

import struct
import sys
from pathlib import Path

from port_preview import Port, capture_camera

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
DEFAULT = ['4mkgspl1_x', '1skrspl1_x', '2efb_kgt_x', '2efb_sbr_x', '3obt_x', '8bra_x', '2mkg_x']
FRAMES = 150


def f32(x: float) -> float:
    return struct.unpack('<f', struct.pack('<f', x))[0]


def frame_key(board, channel: int, frame: int):
    keys = board.channels[channel] if board.channels else None
    if not keys:
        return None
    rows = list(keys.values())
    row = rows[min(frame, len(rows) - 1)]
    return [float(v) for v in row.values()]


def expected(board, frame: int):
    offset, scale = frame_key(board, 5, frame), frame_key(board, 6, frame)
    if offset is None and scale is None:
        return None
    return [*(offset or [None, None]), *(scale or [None, None])]


def check_package(stem: str) -> dict:
    camera = dict(capture_camera(22136), yaw=0.0)
    probe = Port(camera, [0.0, 0.0, 0.0], (1280, 720), packages=SCRATCH)
    data = probe.load(stem)['data']
    boards = {}
    resources = set()
    for name, resource in data.resources.items():
        if resource and resource.kind == 'clump' and resource.billboards:
            resources.add(name)
            for model, board in resource.billboards.items():
                boards[model] = board
    effects = sorted(name for name, emitters in data.effects.items()
                     if emitters and any(r in resources for e in emitters.values() for r in (e.resources.values() if e.resources else [])))
    row = {'members': sorted(boards), 'effects': effects, 'draws': 0, 'compared': 0, 'differ': 0, 'control_differ': 0,
           'control_draws': 0, 'members_drawn': set(), 'failures': []}
    for effect in effects:
        port = Port(camera, [0.0, 0.0, 0.0], (1280, 720), packages=SCRATCH)
        runtime = port.load(stem)
        materials = {part.mat.name: item.name for item in runtime['items'].values() for part in item.parts.values()}
        instance = port.play(stem, effect, (0.0, 0.0, 0.0), 0.0, 1.0, 1)
        if not instance or isinstance(instance, tuple):
            row['failures'].append(f'{effect}: not played')
            continue
        for frame in range(1, FRAMES):
            port.advance(frame)
            for d in port.collect():
                if d.get('marker') or materials.get(d['material']) not in boards:
                    continue
                model = materials[d['material']]
                board = boards[model]
                row['draws'] += 1
                row['members_drawn'].add(model)
                got = port.named(d).get('g_uvOffset0')
                want = expected(board, 0)
                if got is None or want is None:
                    continue
                pairs = [(g_, w) for g_, w in zip(got, want) if g_ is not None and w is not None]
                if not pairs:
                    continue
                row['compared'] += 1
                if any(f32(g_) != f32(w) for g_, w in pairs):
                    row['differ'] += 1
                    if len(row['failures']) < 5:
                        row['failures'].append(f'{effect} {model}: g_uvOffset0 {got}, frame 0 keys {want}')
                other = expected(board, 1)
                if other is not None and other != want:
                    row['control_draws'] += 1
                    if any(g_ is not None and w is not None and f32(g_) != f32(w) for g_, w in zip(got, other)):
                        row['control_differ'] += 1
    row['members_drawn'] = sorted(row['members_drawn'])
    return row


def main() -> int:
    stems = sys.argv[1:] or DEFAULT
    failed = False
    totals = {'draws': 0, 'compared': 0, 'differ': 0, 'control_draws': 0, 'control_differ': 0}
    for stem in stems:
        row = check_package(stem)
        for k in totals:
            totals[k] += row[k]
        print(f'{stem}: members {row["members"]}, drawn {row["members_drawn"]}, {row["draws"]} draws, {row["compared"]} compared, '
              f'{row["differ"]} differ; control (frame 1) {row["control_differ"]}/{row["control_draws"]} differ')
        for line in row['failures']:
            print('   FAIL', line)
        failed = failed or bool(row['differ']) or any('not played' not in f for f in row['failures'] if f)
        if row['control_draws'] and row['control_differ'] != row['control_draws']:
            print('   FAIL control: frame 1 matched some draws')
            failed = True
    print('totals', totals)
    if not totals['compared']:
        print('FAIL: nothing compared')
        failed = True
    print('FAIL' if failed else 'PASS: emitter-clump billboard members draw the keys of their frame 0')
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
