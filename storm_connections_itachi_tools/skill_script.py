"""Decode the skill scripts (XML inside `data/skill/*_x.xfbin`) into plain data.

A skill file holds one nuccChunkBinary per skill effect; each is a Shift-JIS
XML document: <Skill id type> with <Hit>, <Files>, and <Actions> whose
<Action type> elements carry parameters (child elements with attributes),
<Event> elements (optionally spawning <Effect name shotType>) and
<SoundEffect> elements. Every attribute is kept as written; nothing is
interpreted here.
"""

from __future__ import annotations

import argparse
import collections
import json
import struct
import xml.etree.ElementTree as ET
from pathlib import Path

from xfbin_chunks import parse

STRUCTURAL = {'Event', 'SoundEffect'}


def documents(path: Path) -> dict[str, str]:
    """Chunk name -> XML text of every script in a skill xfbin."""
    data, chunks = parse(path)
    out = {}
    for c in chunks:
        if c['type'] != 'nuccChunkBinary':
            continue
        raw = data[c['offset']:c['offset'] + c['size']]
        size = struct.unpack_from('>I', raw)[0]
        text = raw[4:4 + size].decode('cp932')
        if text.lstrip().startswith('<?xml'):
            out[c['name']] = text.replace('encoding="Shift_JIS"', 'encoding="UTF-8"', 1)
    return out


def decode(text: str) -> dict:
    root = ET.fromstring(text.encode('utf-8'))
    if root.tag != 'Skill':
        raise ValueError(f'unexpected root element {root.tag}')
    skill = {'id': root.get('id'), 'type': root.get('type'), 'hit': None, 'files': [], 'actions': [], 'other': {}}
    for child in root:
        if child.tag == 'Hit':
            skill['hit'] = dict(child.attrib)
        elif child.tag == 'Files':
            skill['files'] = [f.get('path') for f in child.findall('File')]
        elif child.tag == 'Actions':
            for action in child.findall('Action'):
                item = {'id': action.get('id'), 'type': action.get('type'), 'parameters': {}, 'events': [], 'sounds': []}
                for element in action:
                    if element.tag == 'Event':
                        item['events'].append({**element.attrib,
                                               'effects': [dict(e.attrib) for e in element.findall('Effect')],
                                               'children': sorted({e.tag for e in element} - {'Effect'})})
                    elif element.tag == 'SoundEffect':
                        item['sounds'].append(dict(element.attrib))
                    else:
                        item['parameters'].setdefault(element.tag, []).append(dict(element.attrib))
                skill['actions'].append(item)
        else:
            skill['other'].setdefault(child.tag, []).append(dict(child.attrib))
    return skill


def load(path: Path) -> dict[str, dict]:
    return {name: decode(text) for name, text in documents(path).items()}


def script_index(game) -> dict[str, list[str]]:
    """Script name -> packed skill files that define it, over every data/skill
    file (cached in game_cache/). An event may spawn a script of another file:
    the game has every skill file of the loaded characters in memory."""
    from game_data import CACHE
    files = game.find('data/skill/')
    cached = CACHE / 'skill_script_index.json'
    if cached.exists():
        stored = json.loads(cached.read_text(encoding='utf-8'))
        if stored.get('files') == files:
            return stored['scripts']
    scripts: dict[str, list[str]] = {}
    for name in files:
        try:
            for script in documents(game.fetch(name)):
                scripts.setdefault(script, []).append(name)
        except Exception:      # a few files of the folder are not skill scripts
            continue
    cached.write_text(json.dumps({'files': files, 'scripts': scripts}), encoding='utf-8')
    return scripts


if __name__ == '__main__':
    from game_data import GameData

    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('filter', nargs='?', default='data/skill/', help='substring of the packed file names to read')
    ap.add_argument('--output', type=Path)
    ap.add_argument('--show', action='store_true', help='print the decoded scripts')
    args = ap.parse_args()
    game = GameData()
    counters = {k: collections.Counter() for k in ('skill type', 'action type', 'event type', 'event command', 'shot type',
                                                   'action parameter', 'event child', 'top-level element', 'effect file')}
    scripts, failures = {}, []
    for name in game.find(args.filter):
        try:
            decoded = load(game.fetch(name))
        except Exception as error:
            failures.append((name, str(error)))
            continue
        for skill_id, skill in decoded.items():
            scripts[skill_id] = {'source': name, **skill}
            counters['skill type'][skill['type']] += 1
            counters['effect file'].update(skill['files'])
            counters['top-level element'].update(list(skill['other']))
            for action in skill['actions']:
                counters['action type'][action['type']] += 1
                counters['action parameter'].update(list(action['parameters']))
                for event in action['events']:
                    counters['event type'][event.get('type')] += 1
                    counters['event command'][event.get('command')] += 1
                    counters['event child'].update(event['children'])
                    counters['shot type'].update(e.get('shotType') for e in event['effects'])
    print(f'{len(scripts)} skill scripts decoded, {len(failures)} files failed')
    for name, error in failures[:10]:
        print('  FAILED', name, error)
    for label, counter in counters.items():
        shown = counter.most_common(30)
        print(f'{label} ({len(counter)} distinct):')
        for key, count in shown:
            print(f'    {count:6d}  {key}')
    if args.show:
        print(json.dumps(scripts, indent=1, ensure_ascii=False))
    if args.output:
        args.output.write_text(json.dumps(scripts, indent=1, ensure_ascii=False) + '\n', encoding='utf-8')
        print('WROTE:', args.output)
