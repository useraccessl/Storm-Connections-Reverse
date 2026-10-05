"""The clean addon (storm_fx/) against the reference engine (the lab tree), draw by draw.

  python verify_clean_engine.py            # every scenario
  python verify_clean_engine.py --quick    # the project's two packages, fewer frames

Both engines run in the offline stubs of port_preview.py with the same camera, the same
packages and the same clock. Scenarios: for each package, its first root script cast
toward a target 500 units away, and its first effects played alone at a fixed point.
Every frame, every draw of the two engines must be the same: material (its name without
the engine version, and its parameters), render state (blend, depth writes, cull,
stencil, hook), model matrix, pixel constants, and the vertices of the mesh drawn. The
markers (scene copies, stencil clears, tone pass) must come in the same order.

This proves the clean addon behaves as the reference does on these scenarios; the
reference itself is what the other checks of the repository verify.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
from port_preview import Port, capture_camera  # noqa: E402

PROJECT = ['4efb_amt1_x', '3efb_3ssk1_x']
SURVEY_ADDON = ROOT / 'game_cache' / 'survey_addon'
# Survey packages with what the project's two lack: debris trails, skinned models,
# lit meshes, many shader families.
SURVEY = ['1efcmn_x', '1hak_x', '1efb_bss_x', '3mdr_2_x', '4mnr_x', '3efbtf_srd1_x', '5obt_x', '5efb_9ind1_x', 'cw0_x']
VERSION = re.compile(r'storm_fx_r\d+_|_r\d+$')


def name(material: str) -> str:
    return VERSION.sub('storm_fx_', material) if material else material


class Pair:
    """The two engines side by side on one scenario."""

    def __init__(self, packages: Path | None):
        camera = dict(capture_camera(22136), yaw=0.0)
        self.ports = [Port(camera, [0.0, 0.0, 0.0], (640, 360), packages=packages, engine=engine)
                      for engine in ('reference', 'clean')]
        for port in self.ports:
            port.lua.globals().PREVIEW.groundZ = 0.0
        self.static: dict[tuple[int, int], bool] = {}

    def vertices(self, port: Port, mesh_id) -> np.ndarray:
        rows = port.lua.globals().PREVIEW.meshes[mesh_id].vertices
        return np.array([list(v.values()) for v in rows.values()], dtype=np.float64)

    def same_mesh(self, a, b) -> bool:
        ra, rb = self.ports
        dynamic = bool(ra.lua.globals().PREVIEW.meshes[a['mesh']].dynamic)
        key = (a['mesh'], b['mesh'])
        if not dynamic and key in self.static:
            return self.static[key]
        same = np.array_equal(self.vertices(ra, a['mesh']), self.vertices(rb, b['mesh']))
        if not dynamic:
            self.static[key] = same
        return same

    @staticmethod
    def state(port: Port) -> tuple[list, list]:
        """The skill objects (id, alive, position, velocity, frame) and the running effects
        (effect, frame, particles) of an engine."""
        actors = []
        for cast in port.field('tCasts', 'casts').values():
            for actor in cast.actors.values():
                s = actor.state
                actors.append((actor.id, bool(actor.alive), tuple(s.position.values()), tuple(s.velocity.values()), actor.frame))
        effects = [(a.effect, a.frame, len(a.scene.particles) if a.scene else 0) for a in port.instances()]
        return actors, effects

    def compare(self, frame: int) -> list[str]:
        ra, rb = self.ports
        sa, sb = self.state(ra), self.state(rb)
        if sa != sb:
            return [f'frame {frame}: skill objects / effects {sa} against {sb}'[:600]]
        da, db = ra.collect(), rb.collect()
        if len(da) != len(db):
            return [f'frame {frame}: {len(da)} draws against {len(db)}']
        out = []
        for index, (a, b) in enumerate(zip(da, db)):
            where = f'frame {frame} draw {index} ({name(a["material"])})'
            if a.get('marker') or b.get('marker'):
                keep = lambda d: {k: (name(v) if k == 'material' else v) for k, v in d.items()}
                if keep(a) != keep(b):
                    out.append(f'{where}: marker {keep(a)} against {keep(b)}')
                continue
            for key in ('blend', 'depthWrite', 'cull', 'tag', 'stencilWrite', 'constants'):
                if a[key] != b[key]:
                    out.append(f'{where}: {key} {a[key]} against {b[key]}')
            if name(a['material']) != name(b['material']):
                out.append(f'{where}: material {a["material"]} against {b["material"]}')
            if not np.array_equal(a['matrix'], b['matrix']):
                out.append(f'{where}: matrix differs by {np.abs(a["matrix"] - b["matrix"]).max()}')
            if not self.same_mesh(a, b):
                out.append(f'{where}: vertices differ')
            if len(out) > 8:
                break
        return out

    def materials(self) -> list[str]:
        ra, rb = self.ports

        def table(port):
            out = {}
            for key, material in port.lua.globals().PREVIEW.materials.items():
                out[name(key)] = {k: (name(v) if isinstance(v, str) else v) for k, v in material.params.items()}
            return out
        a, b = table(ra), table(rb)
        out = [f'material {k} only in the reference' for k in a.keys() - b.keys()]
        out += [f'material {k} only in the clean engine' for k in b.keys() - a.keys()]
        out += [f'material {k}: {a[k]} against {b[k]}' for k in a.keys() & b.keys() if a[k] != b[k]]
        return out


def run(package: str, packages: Path | None, frames: int, effects: int, scripts: int = 1) -> tuple[int, int, list[str]]:
    """(scenarios, draws compared, problems) for one package: its first `scripts` root
    scripts cast, its first `effects` effects played alone."""
    problems, scenarios, draws = [], 0, 0
    pair = Pair(packages)
    ref, clean = pair.ports
    try:
        roots = ref.roots(package)
    except Exception:  # noqa: BLE001  a package the reference engine cannot load is not compared
        return 0, 0, []
    try:
        clean_roots = clean.roots(package)
    except Exception as error:  # noqa: BLE001
        return 0, 0, [f'{package}: the clean engine cannot load it: {error}']
    if roots != clean_roots:
        return 0, 0, [f'{package}: root scripts {roots} against {clean_roots}']
    plays = []
    for root in roots[:scripts]:
        plays.append(('cast ' + root, lambda port, root=root: port.cast([0.0, 0.0, 0.0], [500.0, 0.0, 0.0], 1.0, 1, package, root)))
    names = sorted(ref.packages_loaded()[package].data.animations.keys())
    for effect in names[:effects]:
        plays.append(('play ' + effect, lambda port, effect=effect: port.play(package, effect, (0.0, 0.0, 0.0), 30.0, 1.0, 3)))
    clock = 0
    for label, start in plays:
        for port in pair.ports:
            port.lua.globals().PREVIEW.now = clock / 60
            start(port)
        scenarios += 1
        for frame in range(frames):
            clock += 1
            for port in pair.ports:
                port.advance(clock)
            found = pair.compare(clock)
            draws += len(ref.lua.globals().PREVIEW.draws)
            if found:
                problems += [f'{package} / {label}: {p}' for p in found]
                break
        for port in pair.ports:
            port.stop()
        if problems:
            break
    problems += [f'{package}: {p}' for p in pair.materials()]
    return scenarios, draws, problems


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--quick', action='store_true')
    ap.add_argument('--wide', type=int, metavar='N', help='also every root script of N survey packages (every motion class)')
    ap.add_argument('--packages', nargs='*')
    args = ap.parse_args()
    frames, effects, scripts = (120, 2, 1) if args.quick else (240, 3, 1)
    targets = [(p, None) for p in PROJECT]
    if not args.quick:
        targets += [(p, SURVEY_ADDON) for p in SURVEY if (SURVEY_ADDON / 'lua/storm_fx/packages' / f'{p}.lua').exists()]
    if args.packages:
        targets = [(p, None if p in PROJECT else SURVEY_ADDON) for p in args.packages]
    if args.wide:
        # Every root script (up to 6) of N survey packages, evenly spread over their names.
        names = sorted(p.stem for p in (SURVEY_ADDON / 'lua/storm_fx/packages').glob('*.lua'))
        pick = names[::max(1, len(names) // args.wide)][:args.wide]
        targets = [(p, SURVEY_ADDON) for p in pick]
        frames, effects, scripts = 180, 0, 6
    fail = []
    total = [0, 0]
    for package, folder in targets:
        scenarios, draws, problems = run(package, folder, frames, effects, scripts)
        total[0] += scenarios
        total[1] += draws
        print(f'{package}: {scenarios} scenarios, {draws} draws compared' + (f', {len(problems)} problems' if problems else ''))
        fail += problems
    for line in fail[:30]:
        print('  FAIL', line)
    if fail:
        print('FAIL')
        return 1
    print(f'PASS: the clean addon draws exactly what the reference engine draws ({total[0]} scenarios, {total[1]} draws)')
    return 0


if __name__ == '__main__':
    sys.exit(main())
