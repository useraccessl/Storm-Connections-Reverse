"""Check the engine's point lights on real data of the game, offline.

`verify_point_light_native.py` proves the selection rule equal to the game's
code; this checks that the player wires it up. In the engine (lupa, GMod stubs
of port_preview.py) an effect of the game that carries a light is played next
to lit models of the game (the common weapons file), and for every frame:

  * the scene's light list (StormFX.Engine.tLights) holds the light while the effect's
    animation runs, with the intensity, colour and radii of its animation entry
    at that tick, and nothing afterwards;
  * every draw of a mesh whose shader reads point light slot 0 receives, in its
    pixel constants, what the rule gives for the position of its model -
    recomputed here in Python from the light list - or the values of an unused
    slot when the model's light byte has no light mode or no light is registered.

No pixel is checked, and nothing here runs in Garry's Mod.

  python verify_point_lights.py
"""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np

from game_data import GameData
from port_preview import Port, capture_camera
from storm_import import Importer

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
LIGHT_PACKAGE, WEAPON_PACKAGE = '1efcmn_x', 'cw0_x'
F = np.float32
EPSILON = F(1.1920928955078125e-07)
UNUSED = {'g_pointLightColor0': (0.0, 0.0, 0.0), 'g_pointLightPos0': (0.0, 0.0, 0.0), 'g_pointLightParam0': (0.0, None, 1.0, float(EPSILON))}
POINT_LIGHT_MODES = (0, 1, 3)       # light bytes whose light mode hands over the manager's lights


def key(light: dict, position) -> float:
    """0x1412c9cd0, in float32."""
    d = [F(F(light['position'][i]) - F(position[i])) for i in range(3)]
    distance = F(np.sqrt(F(F(F(d[0] * d[0]) + F(d[1] * d[1])) + F(d[2] * d[2]))))
    weight = F(light['intensity'])
    if weight > 0 and not distance > F(light['far']):
        if distance >= F(light['near']):
            weight = F(weight * F(F(F(light['far']) - distance) / F(F(light['far']) - F(light['near']))))
    else:
        weight = F(0)
    return float(F(-weight * distance))


def slot(lights: list[dict], position) -> dict:
    """Constants of slot 0 for a model at `position`: the first four lights, sorted."""
    first = lights[:4]
    if not first:
        return UNUSED
    order = sorted(range(len(first)), key=lambda i: key(first[i], position))        # stable
    light = first[order[0]]
    near, far = F(light['near']), F(light['far'])
    margin = F(far * EPSILON)
    if margin > abs(F(far - near)):
        far = F(far + margin)
    return {'g_pointLightColor0': tuple(light['color']), 'g_pointLightPos0': tuple(light['position']),
            'g_pointLightParam0': (light['intensity'], None, float(far), float(F(F(1) / F(far - near))))}


def ensure(game: GameData, stem: str) -> None:
    if not (SCRATCH / 'lua/storm_fx/packages' / f'{stem}.lua').exists():
        importer = Importer(game, stem, SCRATCH)
        importer.skill_file(f'data/skill/{stem}.xfbin')
        importer.write()


def light_effects(data) -> list[tuple[str, float]]:
    """(effect animation, largest intensity) of the animations that carry a light."""
    out = []
    for name, animation in data.animations.items():
        if not animation or not animation.entries:
            continue
        for entry in animation.entries.values():
            if entry.type == 6:
                channels = {c.index: [list(v.values()) for v in c['values'].values()] for c in entry.curves.values()}
                out.append((name, max(v[0] for v in channels[1])))
    return sorted(out)


def plain(light) -> dict:
    return {'position': [float(light.position[i]) for i in (1, 2, 3)], 'color': [float(light.color[i]) for i in (1, 2, 3)],
            'intensity': float(light.intensity), 'near': float(light.near), 'far': float(light.far), 'effect': light.effect}


def run() -> dict:
    game = GameData()
    for stem in (LIGHT_PACKAGE, WEAPON_PACKAGE):
        ensure(game, stem)
    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
    lights_data = port.load(LIGHT_PACKAGE).data
    effect, peak = next((name, peak) for name, peak in light_effects(lights_data) if peak > 0 and lights_data.effects[name] is not None)
    # Lit models: cast weapon scripts until one draws a mesh that reads the light.
    port.load(WEAPON_PACKAGE)
    lit_materials = {part.mat.name: int(item.light) for item, part in port.parts() if part.lit}
    assert lit_materials, 'the weapons package has no mesh reading point light 0'
    report = {'effect': effect, 'peak_intensity': peak}
    for script in port.roots(WEAPON_PACKAGE):
        port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
        port.load(LIGHT_PACKAGE)
        port.load(WEAPON_PACKAGE)
        lit_materials = {part.mat.name: int(item.light) for item, part in port.parts() if part.lit}
        port.cast([0.0, 0.0, 0.0], [400.0, 0.0, 0.0], 1.0, 1, WEAPON_PACKAGE, script)
        instance = port.play(LIGHT_PACKAGE, effect, (150.0, 40.0, 60.0), 0.0, 1.0, 1)
        assert instance and not isinstance(instance, tuple), f'effect {effect} rejected: {instance}'
        frames = seen_lit = lit_by_light = unused_draws = 0
        intensities, checked, ended_at = [], 0, None
        for frame in range(240):
            port.advance(frame)
            lights = [plain(light) for light in port.field('tLights', 'lights').values()]
            mine = [light for light in lights if light['effect'] == effect]
            if mine:
                intensities.append(mine[0]['intensity'])
                assert ended_at is None, 'the light came back after it ended'
            elif intensities and ended_at is None:
                ended_at = frame
            for draw in port.collect():
                if draw.get('marker') or draw['material'] not in lit_materials:
                    continue
                seen_lit += 1
                named = port.named(draw)
                position = [float(draw['matrix'][i, 3]) for i in range(3)]
                expected = slot(lights, position) if lit_materials[draw['material']] in POINT_LIGHT_MODES else UNUSED
                for name, values in expected.items():
                    for component, value in enumerate(values):
                        got = named[name][component]
                        if value is None or got is None:
                            continue
                        assert abs(got - value) <= 1e-6 * max(1.0, abs(value)), (frame, draw['material'], name, component, got, value)
                        checked += 1
                if expected is UNUSED:
                    unused_draws += 1
                elif expected['g_pointLightParam0'][0] > 0 and key(lights[0], position) < 0:
                    lit_by_light += 1
            frames += 1
        if list(port.field('tFailed', 'failed').keys()):
            continue
        if seen_lit and lit_by_light and intensities and ended_at is not None:
            assert abs(max(intensities) - peak) <= 0.05 * peak + 1e-6, (max(intensities), peak)
            report.update({'weapon_script': script, 'frames': frames, 'lit_draws': seen_lit, 'draws_reached_by_the_light': lit_by_light,
                           'draws_with_unused_slot': unused_draws, 'constants_compared': checked,
                           'light_frames': len(intensities), 'largest_intensity_seen': max(intensities), 'light_ended_at_frame': ended_at})
            return report
    raise SystemExit('FAIL: no weapon script put a lit mesh within reach of the light')


if __name__ == '__main__':
    report = run()
    target = ROOT / 'captured_assets' / 'point_light_engine_check.json'
    target.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print(f'effect {report["effect"]} (largest intensity {report["peak_intensity"]:g}) next to script {report["weapon_script"]}: '
          f'{report["frames"]} frames')
    print(f'  light registered for {report["light_frames"]} frames, largest intensity seen {report["largest_intensity_seen"]:.3f}, '
          f'gone at frame {report["light_ended_at_frame"]}')
    print(f'  {report["lit_draws"]} draws of lit meshes: {report["draws_reached_by_the_light"]} reached by the light, '
          f'{report["draws_with_unused_slot"]} with the unused slot; {report["constants_compared"]} constants equal the rule')
    print('WROTE:', target)
    print('PASS: the engine registers the effect light and hands it to the lit meshes as the game rule says')
