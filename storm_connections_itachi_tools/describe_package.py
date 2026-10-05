"""Summarize a storm_import.py package and what the engine can do with it.

Loads the package in the addon's engine (storm_fx/, GMod API stubbed) and reports, per
script and effect: action types, animation chunks, emitters and their
resources, the models the engine has a shader for, and everything unsupported
on either side (importer or engine). No rendering.
"""

from __future__ import annotations

import argparse
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from port_preview import Port, capture_camera  # noqa: E402


def describe(package: str, verbose: bool = True) -> dict:
    port = Port(dict(capture_camera(22136), yaw=0.0), [0, 0, 0], (1920, 1080))
    supported = port.field('tSupportedActions', 'supportedActions')
    runtime = port.load(package)
    data = runtime.data
    report = {'package': package, 'scripts': {}, 'effects': {}, 'engine_unsupported_models': dict(runtime.unsupported.items()),
              'importer_unsupported': [(e.what, e.reason) for e in data.unsupported.values()],
              'roots': port.roots(package)}
    keys = Counter()
    for name, item in runtime['items'].items():
        for part in item.parts.values():        # one part per NUD mesh, each with its translated shader
            keys[f'{part.layout.key:#x}'] += 1
    report['shader_keys'] = dict(keys)
    report['engine_notes'] = list(runtime.notes.values())
    for skill_id, script in data.skills.items():
        actions = []
        for action in script.actions.values():
            animation = action.parameters['Animation']
            actions.append({'type': action.type, 'supported': bool(supported[action.type]),
                            'animation': animation[1].chunk if animation else None,
                            'parameters': sorted(action.parameters.keys()),
                            'events': [(e.type, e.command, [(x.name, x.shotType) for x in e.effects.values()]) for e in action.events.values()]})
        report['scripts'][skill_id] = actions
    for name, emitters in data.effects.items():
        resources = Counter()
        for emitter in emitters.values():
            for resource in emitter.resources.values():
                resources[data.resources[resource].kind] += 1
        report['effects'][name] = {'emitters': len(list(emitters.values())), 'resource_kinds': dict(resources)}
    if verbose:
        print(f'PACKAGE {package}: roots {report["roots"]}')
        for skill_id, actions in sorted(report['scripts'].items()):
            for a in actions:
                print(f'  script {skill_id}: {a["type"]}{"" if a["supported"] else " (motion NOT translated)"} animation {a["animation"]} parameters {a["parameters"]}')
                for kind, command, effects in a['events']:
                    print(f'      {kind} -> {command} {effects if effects else ""}')
        for name, e in sorted(report['effects'].items()):
            print(f'  effect {name}: {e["emitters"]} emitters, resources {e["resource_kinds"]}')
        print('  meshes with a translated shader, by shader key:', report['shader_keys'])
        for line in report['engine_notes']:
            print(f'  ENGINE: {line}')
        for name, why in sorted(report['engine_unsupported_models'].items()):
            print(f'  ENGINE: no renderer for model {name}: {why}')
        for what, why in report['importer_unsupported']:
            print(f'  IMPORTER: {what}: {why}')
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('package')
    args = ap.parse_args()
    describe(args.package)
