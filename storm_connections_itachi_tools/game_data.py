"""Read-only access to the game's packed data.

Indexes every CPK of the installation once (cached as JSON), then extracts
single files on demand into `game_cache/`. Nothing is written to the game
folder.
"""

from __future__ import annotations

import argparse
import json
from pathlib import Path

from cpk_index import extract_entry, list_archive

ROOT = Path(__file__).resolve().parent
INSTALL = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS')
CACHE = ROOT / 'game_cache'
INDEX = CACHE / 'cpk_index.json'


class GameData:
    def __init__(self, install: Path = INSTALL):
        self.install = install
        self.headers: dict[str, dict] = {}
        self.index = self._load()

    def _load(self) -> dict[str, dict]:
        archives = sorted(self.install.rglob('*.cpk'))
        # Files the game keeps outside its archives (data/system: the toon ramp
        # celshade.tex.xfbin and other engine textures).
        loose = sorted(self.install.glob('data/**/*.xfbin'))
        stamp = {str(a): [a.stat().st_size, int(a.stat().st_mtime)] for a in archives + loose}
        if INDEX.exists():
            stored = json.loads(INDEX.read_text(encoding='utf-8'))
            if stored.get('archives') == stamp:
                return stored['files']
        files: dict[str, dict] = {}
        for path in loose:
            name = path.relative_to(self.install).as_posix()
            size = path.stat().st_size
            files[name.lower()] = {'archive': None, 'name': name, 'loose': str(path), 'entry': {'FileSize': size, 'ExtractSize': size}}
        for archive in archives:
            try:
                header, entries = list_archive(archive)
            except Exception as error:      # some archives have no TOC (movies, sound)
                print(f'{archive.name}: skipped ({error})')
                continue
            for entry in entries:
                name = f"{entry.get('DirName', '')}/{entry['FileName']}".lstrip('/')
                # Later archives override earlier ones, like the game's patch order.
                files[name.lower()] = {'archive': str(archive), 'name': name, 'entry': entry}
        CACHE.mkdir(parents=True, exist_ok=True)
        INDEX.write_text(json.dumps({'archives': stamp, 'files': files}), encoding='utf-8')
        return files

    def find(self, text: str) -> list[str]:
        text = text.lower()
        return sorted(v['name'] for k, v in self.index.items() if text in k)

    def has(self, name: str) -> bool:
        return name.lower() in self.index

    def fetch(self, name: str) -> Path:
        """Extracted copy of one packed file (decrypted and decompressed)."""
        record = self.index[name.lower()]
        if record.get('loose'):
            return Path(record['loose'])
        target = CACHE / record['name']
        if target.exists():
            return target
        archive = Path(record['archive'])
        if record['archive'] not in self.headers:
            self.headers[record['archive']] = list_archive(archive)[0]
        return extract_entry(archive, self.headers[record['archive']], record['entry'], CACHE)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('filter', nargs='?', default='')
    ap.add_argument('--fetch', action='store_true')
    args = ap.parse_args()
    game = GameData()
    matches = game.find(args.filter)
    print(f'{len(game.index)} packed files, {len(matches)} match "{args.filter}"')
    for name in matches[:400]:
        print(' ', name, '->', game.fetch(name) if args.fetch else '')
