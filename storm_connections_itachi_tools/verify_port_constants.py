"""Check that the port's simulation emits the game's own shader constants.

Particle positions and sizes are random, so pixels cannot match one to one. But
several captured constants are deterministic functions of particle age, and the
game's values form small exact sets. The port, run offline, must produce the
same sets:

  light00   g_commonParam.y of the three subtractive ground discs (colour-curve
            alpha * fade state * node opacity 0.9) and their g_multColor
  amt15     (g_uvOffset0.y, g_commonParam.y) of the four animated projectile
            flames, and g_uvOffsetScreen with four equal components
  part09b   threshold, alpha and tint of the ash billboards (the port also
            shows their two-frame fade-in, which no capture happened to catch)
  light00   never more than three discs per frame (the game shows three)

Values are compared to 4 decimals, the precision of a float32 constant printed
that way. This checks emission cadence, fade state machine, node opacity,
material animation and constant packing; it does not check random placement.
"""

from __future__ import annotations

import json
import re
import sys

import numpy as np

from port_preview import CAPTURES, Port, capture_camera

FRAMES = [22082, 22102, 22127, 22136, 22149, 22171, 22200]
ROOT_POSITION = [209.65, -476.38, -0.68]
PACKAGE = '4efb_amt1_x'     # the skill those captures show


def captured() -> dict:
    light, light_tint, flames, ash, discs_per_frame = set(), set(), set(), set(), []
    for frame in FRAMES:
        draws = json.loads((CAPTURES / f'itachi_amaterasu_frame{frame}.effect_coverage_reference.json').read_text(encoding='utf-8'))
        discs = 0
        for d in draws:
            fields = {}
            for stage in d['constants'].values():
                for buf in stage.values():
                    fields.update(buf['fields'])
            value = lambda name: [round(float(v), 4) for v in fields[name]['values']]
            family, operation = d['shaders']['ShaderStage.Pixel'][:8], d['blend'][0]['rgb'][2].split('.')[-1]
            if family == '01f002_p' and operation == 'ReversedSubtract':
                light.add(value('g_commonParam')[1])
                light_tint.add(tuple(value('g_multColor')[:3]))
                discs += 1
            elif family == '19f002_p':
                flames.add((value('g_uvOffset0')[1], value('g_commonParam')[1]))
                screen = value('g_uvOffsetScreen')
                if len(set(screen)) != 1:
                    raise SystemExit(f'capture {frame} event {d["event"]}: amt15 screen scroll is not uniform: {screen}')
            elif d['base_asset'] == '1efc_part12':
                common, tint = value('g_commonParam'), value('g_multColor')
                # Other effects of the match reuse this texture with grey or white tints;
                # the impact's own emitters 16 / 17 are black.
                if tint[:3] == [0.0, 0.0, 0.0]:
                    ash.add((common[0], common[1], *tint[:3]))
        if discs:
            discs_per_frame.append(discs)
    return {'light': light, 'light_tint': light_tint, 'flames': flames, 'ash': ash, 'discs': set(discs_per_frame)}


KEY_FAMILY = {0x9f007: '915c5e6e', 0x1f007: 'c4ee9b55', 0x19f007: '19f007_p', 0x19f002: '19f002_p', 0x1f002: '01f002_p'}


def captured_context() -> dict:
    """(pixel family, first texture) -> set of (stage fog applied, ambient colour) over all captures."""
    out: dict = {}
    for frame in FRAMES:
        draws = json.loads((CAPTURES / f'itachi_amaterasu_frame{frame}.effect_coverage_reference.json').read_text(encoding='utf-8'))
        for d in draws:
            fields = {}
            for stage in d['constants'].values():
                for buf in stage.values():
                    fields.update(buf['fields'])
            if 'g_fogParam' not in fields:
                continue
            ambient = tuple(round(float(v), 4) for v in fields['g_ambientColor']['values'][:3])
            key = (d['shaders']['ShaderStage.Pixel'][:8], d['base_asset'])
            out.setdefault(key, set()).add((fields['g_fogParam']['values'][2] != 0, ambient))
    return out


def port_context() -> dict:
    """Same key -> {resource: (fogged, ambient)} for every resource the port can draw."""
    port = Port(dict(capture_camera(22136), yaw=0.0), ROOT_POSITION, (3840, 2160))
    stage = port.field('tStage', 'stage')
    out: dict = {}
    for name, item in port.load(PACKAGE)['items'].items():     # ['items']: .items is lupa's own method
        family = KEY_FAMILY.get(item.parts[1].layout.key)
        if family is None:
            continue
        # The game's texture name: the VTF name without the importer's variant suffixes.
        texture = re.sub(r'(_m)?(_c[st]{1,2})?(_p)?$', '', item.parts[1].mat.params['$basetexture'].rsplit('/', 1)[-1])
        ambient = stage.lightSets[item.light]
        ambient = tuple(round(float(v), 4) for v in ambient.values()) if ambient is not None else (1.0, 1.0, 1.0)
        out.setdefault((family, texture), {})[name] = (bool(item.fogged), ambient)
    return out


def played(phase: tuple[str, ...], frames: int, seed: str = '1') -> dict:
    port = Port(dict(capture_camera(22136), yaw=0.0), ROOT_POSITION, (3840, 2160))
    port.lua.globals().StormFX.Config['batchParticles'] = False      # one particle a draw: its values per draw
    port.start('1', seed, *phase)
    out = {'light': set(), 'light_tint': set(), 'flames': set(), 'flame_scroll': set(), 'ash': set(), 'discs': set()}
    for frame in range(frames):
        port.advance(frame)
        discs = 0
        for d in port.collect():
            if d.get('marker'):
                continue
            name = d['material']
            # The pixel constants of the draw, by the game's names (layout of the mesh's shader).
            value = {k: [None if x is None else round(x, 4) for x in v] for k, v in port.named(d).items()}
            if '_4efb_light00_' in name:
                out['light'].add(value['g_commonParam'][1])
                out['light_tint'].add(tuple(value['g_multColor'][:3]))
                discs += 1
            elif '_4efb_amt15_' in name:
                out['flames'].add((value['g_uvOffset0'][1], value['g_commonParam'][1]))
                out['flame_scroll'].add(len(set(value['g_uvOffsetScreen'])))
            elif '_1efc_part09b_' in name:
                out['ash'].add((value['g_commonParam'][0], value['g_commonParam'][1], *value['g_multColor'][:3]))
        if discs:
            out['discs'].add(discs)
    return out


if __name__ == '__main__':
    game = captured()
    hit = played((), 90)
    projectile = played(('blt',), 60)
    failures = []

    def check(label: str, got, expected, exact: bool = True) -> None:
        ok = got == expected if exact else expected <= got
        print(f'{"PASS" if ok else "FAIL"}: {label}\n      game {sorted(expected)}\n      port {sorted(got)}')
        if not ok:
            failures.append(label)

    check('light00 alpha lattice (g_commonParam.y)', hit['light'], game['light'])
    check('light00 tint (g_multColor)', hit['light_tint'], game['light_tint'])
    check('light00 discs drawn per frame', {max(hit['discs'])}, {max(game['discs'])})
    check('ash billboards (threshold, alpha, tint)', hit['ash'], game['ash'], exact=False)
    check('amt15 (uv offset, alpha) pairs', projectile['flames'], game['flames'], exact=False)
    check('amt15 screen scroll components equal', projectile['flame_scroll'], {1})
    # Stage fog and ambient per resource: every port resource whose (shader family, first
    # texture) was captured must use a context the game used for that pair.
    game_context, covered = captured_context(), 0
    for key, resources in sorted(port_context().items()):
        if key not in game_context:
            print(f'      not captured: {key} {sorted(resources)}')
            continue
        for name, context in sorted(resources.items()):
            covered += 1
            if context not in game_context[key]:
                print(f'FAIL: {name} uses fog/ambient {context}, the game used {sorted(game_context[key])} for {key}')
                failures.append(f'context {name}')
    print(f'{"PASS" if not any(f.startswith("context") for f in failures) else "FAIL"}: stage fog / ambient of {covered} resources match a captured draw of the same shader and texture')
    if failures:
        raise SystemExit(f'{len(failures)} check(s) failed')
    print('PASS: the port emits the captured deterministic constants')
