"""Check the engine's skill behaviours on real scripts of the game, offline.

`verify_skill_actor_native.py` proves the motion core equal to the game's code;
this checks that the player wires it up: for each behaviour it finds a script
of the game that uses it, imports the skill file into the scratch addon, casts
that script in the engine (lupa, GMod stubs of port_preview.py: flat ground,
no walls, target 500 units ahead) and tests what the actors do against the
script's own parameters.

  SINCURVE          the path leaves the straight line by at most the amplitude
  ELEVATOR          the actor moves along +Z by its Velocity
  BOUNDBALL         the ball falls, meets the ground and comes back up
  Gravity           an ARROW's vertical speed changes by Gravity * 980.665 / rate^2 per tick
  Inductivity       a guided ARROW passes nearer the target than the line it was launched on
  N_WAY_HORIZONTAL  one event launches shotParam1 actors, shotParam2 degrees apart
  RANDOM_CREATION   one event launches shotParam1 actors within shotParam2 units
  Ground contact    a still or crawling object that waits for HIT_WORLD_* to pick its
                    surface variant takes the action its first matching event names
                    (flat ground of the host's default kind, DIRT; journal R94)

No pixel is checked, and the host's world is a stand-in.

  python verify_skill_behaviours.py
"""

from __future__ import annotations

import json
import math
from pathlib import Path

import skill_script
from game_data import GameData
from port_preview import Port, capture_camera
from storm_import import Importer

ROOT = Path(__file__).resolve().parent
SCRATCH = ROOT / 'game_cache' / 'survey_addon'
RATE = 60


def value(action: dict, name: str) -> float:
    entry = (action['parameters'].get(name) or [{}])[0]
    return float(entry.get('value', 0) or 0)


def candidates(game: GameData, wanted) -> list[tuple[str, str, dict]]:
    """(skill file, script id, script) of every script `wanted` accepts."""
    out = []
    for name in sorted(game.find('data/skill/')):
        try:
            scripts = skill_script.load(game.fetch(name))
        except Exception:
            continue
        for script_id, script in scripts.items():
            if script['actions'] and wanted(script):
                out.append((name, script_id, script))
    return out


class Session:
    def __init__(self, game: GameData):
        self.game = game
        self.imported: set[str] = set()

    def run(self, name: str, script_id: str, ticks: int) -> tuple[list[list[dict]], list[str]] | None:
        """Cast one script; per tick, the state of every actor of the cast."""
        stem = Path(name).stem
        try:
            if stem not in self.imported:
                importer = Importer(self.game, stem, SCRATCH)
                importer.skill_file(name)
                importer.write()
                self.imported.add(stem)
            port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (1920, 1080), packages=SCRATCH)
            port.load(stem)
            cast = port.cast([0.0, 0.0, 0.0], [500.0, 0.0, 0.0], 1.0, 1, stem, script_id)
        except Exception:
            return None
        history = []
        for frame in range(ticks):      # a fresh engine each time: its clock starts at 0
            port.advance(frame)
            history.append([{'id': a.id, 'alive': bool(a.alive), 'frame': int(a.state.frame), 'type': a.action.type,
                             'action': int(a.actionIndex or 0),
                             'position': [a.state.position[i] for i in (1, 2, 3)],
                             'velocity': [a.state.velocity[i] for i in (1, 2, 3)]} for a in cast.actors.values()])
        if list(port.field('tFailed', 'failed').keys()):
            return None
        return history, list(cast.log.values())


def first_action(kind: str):
    return lambda script: script['actions'][0]['type'] == kind


def shot(kind: str):
    def wanted(script):
        for event in script['actions'][0]['events']:
            # The event must fire by itself, early, in the host.
            if event.get('type') != 'SKILL_EVENT_TYPE_FRAME_ELAPSED' or int(event.get('arg') or 0) > 20:
                continue
            for effect in event['effects']:
                if effect.get('shotType') == kind and int(effect.get('shotParam1') or 0) >= 2 and 'coord' not in effect \
                        and 'targetDir' not in effect:
                    return True
        return False
    return wanted


def check_sincurve(script, history, notes):
    action = script['actions'][0]
    amplitude = math.sqrt(sum(value(action, f'Amplitude_{axis}') ** 2 for axis in 'xyz'))
    if amplitude == 0 or value(action, 'Velocity') == 0 or value(action, 'Inductivity') or value(action, 'Gravity') \
            or value(action, 'RandomDirection'):
        return None
    track = [tick[0] for tick in history if tick and tick[0]['alive'] and tick[0]['type'].endswith('SINCURVE')]
    if len(track) < 8:
        return None
    start = track[0]['position']
    # The base path is straight (no gravity, no guidance): along the first velocity.
    v = track[1]['velocity']
    speed = math.sqrt(sum(c * c for c in v))
    axis = [c / speed for c in v]
    worst = 0.0
    for state in track:
        d = [state['position'][i] - start[i] for i in range(3)]
        along = sum(d[i] * axis[i] for i in range(3))
        off = math.sqrt(max(0.0, sum(c * c for c in d) - along * along))
        worst = max(worst, off)
    assert 0 < worst <= amplitude * 1.0001 + 1e-3, (worst, amplitude)
    return f'{len(track)} ticks, largest offset {worst:.3f} of amplitude {amplitude:.3f}'


def check_elevator(script, history, notes):
    action = script['actions'][0]
    speed = value(action, 'Velocity') * 30 / RATE
    if speed == 0 or value(action, 'Gravity') or value(action, 'VelocityRandomize'):
        return None
    track = [tick[0] for tick in history if tick and tick[0]['alive'] and tick[0]['type'].endswith('ELEVATOR')]
    if len(track) < 5:
        return None
    for before, after in zip(track[1:], track[2:]):
        step = [after['position'][i] - before['position'][i] for i in range(3)]
        assert abs(step[0]) < 1e-4 and abs(step[1]) < 1e-4 and abs(step[2] - speed) < 1e-3 * max(1, abs(speed)), (step, speed)
    return f'{len(track)} ticks, {speed:g} units per tick along +Z'


def check_boundball(script, history, notes):
    action = script['actions'][0]
    if value(action, 'Gravity') <= 0 or value(action, 'Restitution') <= 0:
        return None
    track = [tick[0] for tick in history if tick and tick[0]['alive'] and tick[0]['type'].endswith('BOUNDBALL')]
    if len(track) < 30:
        return None
    lowest = min(state['position'][2] for state in track)
    falls = [i for i in range(1, len(track)) if track[i - 1]['velocity'][2] < 0 <= track[i]['velocity'][2]]
    assert falls, 'the ball never came back up'
    assert lowest > -1.0, lowest
    return f'{len(track)} ticks, {len(falls)} rebound(s), lowest height {lowest:.3f}'


def check_gravity(script, history, notes):
    action = script['actions'][0]
    gravity = value(action, 'Gravity')
    if gravity == 0 or value(action, 'Inductivity') or 'BankStrong' in action['parameters']:
        return None
    track = [tick[0] for tick in history if tick and tick[0]['alive'] and tick[0]['type'].endswith('ARROW')]
    if len(track) < 5:
        return None
    expected = -gravity * 980.665 / RATE ** 2
    for before, after in zip(track[1:], track[2:]):
        change = after['velocity'][2] - before['velocity'][2]
        assert abs(change - expected) < 1e-4 * max(1.0, abs(expected)), (change, expected)
        assert abs(after['velocity'][0] - before['velocity'][0]) < 1e-5
    return f'{len(track)} ticks, vertical speed changes by {expected:.5f} per tick (Gravity {gravity:g})'


def check_guidance(script, history, notes):
    action = script['actions'][0]
    if value(action, 'Inductivity') <= 0 or value(action, 'ViewingAngle') < 90 or value(action, 'Velocity') < 10 \
            or value(action, 'Gravity') or value(action, 'RandomDirection') < 5:
        return None
    track = [tick[0] for tick in history if tick and tick[0]['alive'] and tick[0]['type'].endswith('ARROW')]
    if len(track) < 6:
        return None

    target = [500.0, 0.0, 0.0]

    def miss(a, b):
        """Distance from the target to the segment a-b."""
        ab = [b[i] - a[i] for i in range(3)]
        size = sum(c * c for c in ab)
        t = 0.0 if size == 0 else max(0.0, min(1.0, sum((target[i] - a[i]) * ab[i] for i in range(3)) / size))
        return math.sqrt(sum((a[i] + ab[i] * t - target[i]) ** 2 for i in range(3)))
    start, first = track[0]['position'], track[1]['velocity']
    speed = math.sqrt(sum(c * c for c in first))
    if speed < 1e-6:
        return None
    # Unguided, the actor would keep its first velocity.
    straight = miss(start, [start[i] + first[i] / speed * 2000.0 for i in range(3)])
    if straight < 5.0:
        return None
    # The path includes the step on which the actor ended (its last position is kept).
    path = [tick[0]['position'] for tick in history[:len(track) + 1] if tick]
    guided = min(miss(a, b) for a, b in zip(path, path[1:]))
    assert guided < straight, (guided, straight)
    return (f'passes {guided:.1f} units from the target; its launch line passes {straight:.1f} units away '
            f'(Inductivity {value(action, "Inductivity"):g})')


def launched_by(script, history, kind):
    effect = next(e for event in script['actions'][0]['events'] for e in event['effects'] if e.get('shotType') == kind)
    count, second = int(effect['shotParam1']), int(effect.get('shotParam2') or 0)
    for index, tick in enumerate(history):
        born = [state for state in tick[1:] if state['id'] == effect['name']]
        if born:
            return effect, count, second, born, history[index]
    return effect, count, second, [], None


def check_n_way(script, history, notes):
    effect, count, step, born, tick = launched_by(script, history, 'SKILL_SHOT_TYPE_N_WAY_HORIZONTAL')
    if not born:
        return None
    assert len(born) == count, (len(born), count)
    headings = []
    for state in born:
        speed = math.sqrt(sum(c * c for c in state['velocity']))
        if speed < 1e-6:
            return f'{count} actors launched (they do not move: the fan is not measurable)'
        headings.append(math.degrees(math.atan2(state['velocity'][1], state['velocity'][0])))
    gaps = [(b - a + 540) % 360 - 180 for a, b in zip(headings, headings[1:])]
    if any(abs(abs(g) - step) > 0.5 for g in gaps):
        return f'{count} actors launched (their action turns them: gaps {[round(g, 1) for g in gaps]} for a step of {step})'
    return f'{count} actors launched, {step} degrees apart'


def check_random_creation(script, history, notes):
    effect, count, reach, born, tick = launched_by(script, history, 'SKILL_SHOT_TYPE_RANDOM_CREATION')
    if not born:
        return None
    assert len(born) == count, (len(born), count)
    parent = tick[0]['position']
    farthest = 0.0
    for state in born:
        if state['frame'] > 1:
            return None
        farthest = max(farthest, math.sqrt(sum((state['position'][i] - parent[i]) ** 2 for i in range(3))))
    return f'{count} actors launched, farthest {farthest:.1f} units from the parent (range {reach})'


GROUND_EVENTS = ('SKILL_EVENT_TYPE_HIT_WORLD_FLOOR', 'SKILL_EVENT_TYPE_HIT_WORLD_DIRT')


def ground_detector(script):
    """First action still or crawling, no animation, world hits on, a radius, and a
    CHANGE_ACTION on a floor / dirt / default world hit."""
    action = script['actions'][0]
    if action['type'] not in ('SKILL_ACTION_TYPE_NONE', 'SKILL_ACTION_TYPE_CRAWLER') or 'Animation' in action['parameters']:
        return False
    if (action['parameters'].get('WorldHitDisable') or [{}])[0].get('value') == 'true':
        return False
    if not float((script.get('hit') or {}).get('worldHitRadius') or 0) > 0:
        return False
    return any(e.get('command') == 'SKILL_EVENT_COMMAND_CHANGE_ACTION'
               and e.get('type') in GROUND_EVENTS + ('SKILL_EVENT_TYPE_HIT_WORLD_DEFAULT',) for e in action['events'])


def check_ground(script, history, notes):
    events = script['actions'][0]['events']
    # First pass: the surface events, in list order; second pass: DEFAULT (journal R94).
    chosen = next((e for e in events if e.get('type') in GROUND_EVENTS), None) \
        or next((e for e in events if e.get('type') == 'SKILL_EVENT_TYPE_HIT_WORLD_DEFAULT'), None)
    if chosen is None or chosen.get('command') != 'SKILL_EVENT_COMMAND_CHANGE_ACTION':
        return None
    target = int(chosen.get('commandParameter') or 0)
    for index, tick in enumerate(history):
        if tick and tick[0]['action'] == target + 1:
            return f'took action {target} ({chosen["type"].replace("SKILL_EVENT_TYPE_", "")}) at tick {index}'
    raise AssertionError(f'never took action {target} on {chosen["type"]}')


def plain_sincurve(script):
    action = script['actions'][0]
    return (action['type'] == 'SKILL_ACTION_TYPE_SINCURVE' and value(action, 'Velocity') and not value(action, 'Inductivity')
            and not value(action, 'Gravity') and not value(action, 'RandomDirection')
            and any(value(action, f'Amplitude_{axis}') and value(action, f'Frequency_{axis}') for axis in 'xyz'))


def falling_arrow(script):
    action = script['actions'][0]
    return (action['type'] == 'SKILL_ACTION_TYPE_ARROW' and value(action, 'Gravity') and not value(action, 'Inductivity')
            and 'BankStrong' not in action['parameters'])


def guided_arrow(script):
    action = script['actions'][0]
    return (action['type'] == 'SKILL_ACTION_TYPE_ARROW' and value(action, 'Inductivity') > 0 and value(action, 'ViewingAngle') >= 90
            and value(action, 'Velocity') >= 10 and not value(action, 'Gravity') and value(action, 'RandomDirection') >= 5)


CHECKS = [
    ('SINCURVE', plain_sincurve, check_sincurve, 60),
    ('ELEVATOR', first_action('SKILL_ACTION_TYPE_ELEVATOR'), check_elevator, 30),
    ('BOUNDBALL', first_action('SKILL_ACTION_TYPE_BOUNDBALL'), check_boundball, 240),
    ('Gravity', falling_arrow, check_gravity, 30),
    ('Inductivity', guided_arrow, check_guidance, 30),
    ('N_WAY_HORIZONTAL', shot('SKILL_SHOT_TYPE_N_WAY_HORIZONTAL'), check_n_way, 60),
    ('RANDOM_CREATION', shot('SKILL_SHOT_TYPE_RANDOM_CREATION'), check_random_creation, 60),
    ('Ground contact', ground_detector, check_ground, 30),
]

if __name__ == '__main__':
    game = GameData()
    session = Session(game)
    report = {}
    missing = []
    for label, wanted, check, ticks in CHECKS:
        found = None
        tried = 0
        for name, script_id, script in candidates(game, wanted):
            if tried >= 25:
                break
            tried += 1
            result = session.run(name, script_id, ticks)
            if result is None:
                continue
            outcome = check(script, *result)
            if outcome:
                found = {'file': name, 'script': script_id, 'result': outcome}
                break
        if found:
            report[label] = found
            print(f'PASS {label}: {found["script"]} ({Path(found["file"]).name}): {found["result"]}', flush=True)
        else:
            missing.append(label)
            print(f'NO CASE {label}: none of the first {tried} scripts using it could be measured', flush=True)
    target = ROOT / 'captured_assets' / 'skill_behaviour_check.json'
    target.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print('WROTE:', target)
    if missing:
        raise SystemExit(f'FAIL: no measurable script for {missing}')
