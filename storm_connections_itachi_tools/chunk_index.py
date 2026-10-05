"""Global index of the chunks the game's xfbin files define.

An xfbin references chunks of other files by (type, path, name): a skill's
effect file names `e\\1efcmn\\max\\1efc_part09b.max`, which lives in
data/effect/1efcmn.xfbin, and nothing in the skill script says so. The game
resolves these against everything it has loaded; this index gives the same
answer offline: which packed file defines a chunk.

  python chunk_index.py --build effect spc_eff     # extract + scan (slow, once)
  python chunk_index.py --find 1efc_part09b

The index is a SQLite file in game_cache/ (not loaded into memory). Scanning is
incremental: a packed file already scanned with the same size is skipped.
"""

from __future__ import annotations

import argparse
import multiprocessing
import sqlite3
import time
from pathlib import Path

from game_data import CACHE, GameData
from xfbin_chunks import parse

DATABASE = CACHE / 'chunk_index.sqlite'
STRUCTURAL = {'nuccChunkNull', 'nuccChunkPage', 'nuccChunkIndex'}
# Named groups of packed files worth scanning. The whole of data/spc is 10 GB extracted.
SETS = {
    'effect': lambda n: n.startswith('data/effect/') and n.endswith('.xfbin'),
    'spc_eff': lambda n: n.startswith('data/spc/') and n.endswith('.xfbin') and 'eff' in n.rsplit('/', 1)[1],
    'boss_cmn': lambda n: n.startswith('data/boss') and n.endswith('.xfbin') and 'cmn' in n.rsplit('/', 1)[1],
    'boss': lambda n: n.startswith('data/boss') and n.endswith('.xfbin'),
    'spc': lambda n: n.startswith('data/spc/') and n.endswith('.xfbin'),
    'skill': lambda n: n.startswith('data/skill/') and n.endswith('.xfbin'),
    'system': lambda n: n.startswith('data/system/') and n.endswith('.xfbin'),
}

_game: GameData | None = None


def _scan(name: str):
    """Chunks with a body in one packed file: [(type, path, name, size)]."""
    global _game
    if _game is None:
        _game = GameData()
    try:
        _, chunks = parse(_game.fetch(name))
    except Exception as error:      # archives hold a few files this reader does not handle
        return name, None, f'{type(error).__name__}: {error}'
    rows = [(c['type'], c['path'], c['name'], c['size']) for c in chunks if c['type'] not in STRUCTURAL]
    return name, rows, None


class ChunkIndex:
    def __init__(self, game: GameData, database: Path = DATABASE):
        self.game = game
        database.parent.mkdir(parents=True, exist_ok=True)
        self.db = sqlite3.connect(database)
        self.db.executescript('''
            create table if not exists files (id integer primary key, name text unique, size integer, error text);
            create table if not exists chunks (type text, path text, name text, size integer, file integer);
            create index if not exists chunks_by_name on chunks (type, name);
        ''')

    def scanned(self) -> dict[str, int]:
        return dict(self.db.execute('select name, size from files'))

    def build(self, names: list[str], workers: int = 0) -> dict:
        done = self.scanned()
        todo = [n for n in names if done.get(n) != int(self.game.index[n.lower()]['entry']['FileSize'])]
        report = {'requested': len(names), 'scanned': 0, 'failed': {}}
        if not todo:
            return report
        # Largest first, so the long files do not all end up at the tail of the pool.
        todo.sort(key=lambda n: -int(self.game.index[n.lower()]['entry']['FileSize']))
        started = time.time()
        with multiprocessing.Pool(workers or max(1, multiprocessing.cpu_count() - 2)) as pool:
            for count, (name, rows, error) in enumerate(pool.imap_unordered(_scan, todo), 1):
                size = int(self.game.index[name.lower()]['entry']['FileSize'])
                old = self.db.execute('select id from files where name = ?', (name,)).fetchone()
                if old:
                    self.db.execute('delete from chunks where file = ?', old)
                    self.db.execute('delete from files where id = ?', old)
                file_id = self.db.execute('insert into files (name, size, error) values (?, ?, ?)', (name, size, error)).lastrowid
                if rows is None:
                    report['failed'][name] = error
                else:
                    self.db.executemany('insert into chunks values (?, ?, ?, ?, ?)', [(*row, file_id) for row in rows])
                    report['scanned'] += 1
                if count % 25 == 0 or count == len(todo):
                    self.db.commit()
                    print(f'  {count}/{len(todo)} files, {time.time() - started:.0f} s', flush=True)
        self.db.commit()
        return report

    def files(self, kind: str, name: str, path: str | None = None) -> list[str]:
        """Packed files defining the chunk, smallest first; `path` narrows the match when given."""
        query = 'select files.name from chunks join files on files.id = chunks.file where chunks.type = ? and chunks.name = ?'
        values = [kind, name]
        if path is not None:
            # Files spell one path with either separator (shader/toon/... and shader\toon\...).
            query += " and replace(chunks.path, '\\', '/') = ?"
            values.append(path.replace('\\', '/'))
        return [row[0] for row in self.db.execute(query + ' order by files.size', values)]

    def paths(self, kind: str, name: str) -> list[tuple[str, str]]:
        return list(self.db.execute('select chunks.path, files.name from chunks join files on files.id = chunks.file '
                                    'where chunks.type = ? and chunks.name = ?', (kind, name)))


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--build', nargs='*', metavar='SET', help=f'scan these sets: {", ".join(SETS)}')
    ap.add_argument('--workers', type=int, default=0)
    ap.add_argument('--find', help='list the files defining chunks whose name contains this')
    args = ap.parse_args()
    game = GameData()
    index = ChunkIndex(game)
    for group in args.build or []:
        names = sorted(v['name'] for v in game.index.values() if SETS[group](v['name'].lower()))
        print(f'{group}: {len(names)} packed files')
        report = index.build(names, args.workers)
        print(f'{group}: scanned {report["scanned"]}, failed {len(report["failed"])}')
        for name, error in list(report['failed'].items())[:20]:
            print(f'    {name}: {error}')
    files, chunks = index.db.execute('select count(*) from files').fetchone()[0], index.db.execute('select count(*) from chunks').fetchone()[0]
    print(f'index: {files} files, {chunks} chunks')
    if args.find:
        for row in index.db.execute('select chunks.type, chunks.path, chunks.name, files.name from chunks join files on files.id = chunks.file '
                                    'where chunks.name like ? limit 200', (f'%{args.find}%',)):
            print('  ', *row)
