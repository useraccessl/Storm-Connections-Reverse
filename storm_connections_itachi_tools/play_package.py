"""Play every script of an imported skill in the engine, offline, and report.

The addon (storm_fx/) runs under lupa against the GMod API stubs of port_preview.py
(flat ground, no walls, a camera from the Amaterasu capture). Each root script
of the package is cast toward a target 500 game units away and stepped at
60 Hz until everything drains. Reported per script: the script chain that
ran, the effects launched, how many particles and model draws were issued,
which meshes were never drawn, and every note the engine left (motion types
not translated, models without a shader, ...).

This is a functional check of the engine on data no capture covers: it shows
the package plays without error and what is still missing. It says nothing
about pixels.

  python play_package.py 3efb_3ssk1_x [--frames 900]
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path

from port_preview import Port, capture_camera

ROOT = Path(__file__).resolve().parent


def play(package: str, frames: int = 900, distance: float = 500.0, verbose: bool = True, addon: Path | None = None) -> dict:
    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=addon)
    runtime = port.load(package)
    report = {'package': package, 'scripts': {}, 'engine_notes': list(runtime.notes.values()),
              'models_without_shader': dict(runtime.unsupported.items()),
              'not_imported': [(e.what, e.reason) for e in runtime.data.unsupported.values()]}
    drawable = {part.mat.name for _, part in port.parts()}
    drawn_ever: Counter = Counter()
    clock = 0       # the host time never runs backwards between two scripts
    for root in port.roots(package):
        port.stop()
        row = {'error': None, 'actors': [], 'effects': [], 'frames': 0, 'peak_particles': 0, 'draws': 0, 'notes': [], 'skipped': {}}
        report['scripts'][root] = row
        try:
            cast = port.cast([0.0, 0.0, 0.0], [distance, 0.0, 0.0], 1.0, 1, package, root)
            effects = []
            for frame in range(frames):
                port.advance(clock)
                clock += 1
                running = port.instances()
                for instance in running:
                    if instance.effect not in effects:
                        effects.append(instance.effect)
                    if instance.scene:
                        row['peak_particles'] = max(row['peak_particles'], len(list(instance.scene.particles.values())))
                if frame % 4 == 0:
                    for d in port.collect():
                        if not d.get('marker'):
                            row['draws'] += 1
                            drawn_ever[d['material']] += 1
                    for name, count in port.field('tSkipped', 'skipped').items():
                        row['skipped'][name] = max(row['skipped'].get(name, 0), int(count))
                row['frames'] = frame + 1
                if frame > 2 and not running and not list(port.field('tCasts', 'casts').values()):
                    break
            row['actors'] = [(a.id, a.action.type if a.action else None) for a in cast.actors.values()]
            row['effects'] = effects
            row['notes'] = list(cast.log.values())
            row['still_running'] = [i.effect for i in port.instances()]
            failed = port.field('tFailed', 'failed')
            row['dropped'] = {name: str(why)[:200] for name, why in failed.items()}
            for name in list(failed.keys()):
                failed[name] = None
        except Exception as error:      # a Lua error ends this script, not the report
            row['error'] = f'{type(error).__name__}: {error}'
        if verbose:
            print(f'SCRIPT {root}: {row["frames"]} frames, effects {row["effects"]}, peak particles {row["peak_particles"]}, '
                  f'{row["draws"]} draws sampled')
            for actor in row['actors']:
                print(f'    actor {actor[0]} ({actor[1]})')
            for note in row['notes']:
                print(f'    note: {note}')
            for name, count in row['skipped'].items():
                print(f'    not rendered: {name} x{count}')
            if row.get('still_running'):
                print(f'    still running at the end: {row["still_running"]}')
            for name, why in row.get('dropped', {}).items():
                print(f'    effect dropped: {name}: {why}')
            if row['error']:
                print(f'    ERROR {row["error"]}')
    report['meshes_drawn'] = len(drawn_ever)
    report['meshes_never_drawn'] = sorted(drawable - set(drawn_ever))
    if verbose:
        print(f'{len(drawable)} drawable meshes, {len(drawn_ever)} drawn at least once')
        for line in report['engine_notes']:
            print(f'  engine: {line}')
        for name, why in sorted(report['models_without_shader'].items()):
            print(f'  no shader: {name}: {why}')
        for what, why in report['not_imported']:
            print(f'  not imported: {what}: {why}')
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('package')
    ap.add_argument('--frames', type=int, default=900)
    args = ap.parse_args()
    result = play(args.package, args.frames)
    target = ROOT / 'captured_assets' / f'package_play_{args.package}.json'
    target.write_text(json.dumps(result, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
    errors = [name for name, row in result['scripts'].items() if row['error']]
    if errors:
        raise SystemExit(f'FAIL: {len(errors)} script(s) raised an error: {errors}')
