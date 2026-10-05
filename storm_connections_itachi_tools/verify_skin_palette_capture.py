"""What the skinning palette holds, checked on a capture.

The captured compute dispatches (rd_dump_compute.py) skin meshes of Itachi's
model (data/spc/2itcbod1.xfbin: the dispatch inputs are the NUD's own vertices,
see match below). The palette of a dispatch has one matrix per coordinate of the
model's clump, up to the highest bone the NUD names. Hypothesis:

    palette[i] (as the shader reads it) = transpose( pose_i * inverse(bind_i) )

with bind_i the model-space matrix of clump coordinate i at rest (nuccChunkCoord
values, parent * local) and pose_i its animated model-space matrix. The pose of
the captured frame is not known, but a skeleton keeps its bone lengths: under
the hypothesis pose_i = transpose(palette[i]) * bind_i, and the translation of
inverse(pose_parent) * pose_i must be the rest translation of coordinate i.
A wrong index mapping, a wrong matrix order or a wrong rest matrix breaks that.

  python verify_skin_palette_capture.py
"""

from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

from game_data import GameData  # noqa: E402
from inspect_nud import parse_nud  # noqa: E402
from storm_import import Importer, Xfbin  # noqa: E402

FOLDER = ROOT / 'gpu_captures' / 'compute'
FILE = 'data/spc/2itcbod1.xfbin'
MODELS = {70: '2itc00t0 tongue', 418: '2itc00t0 kami', 956: '2itc00t0 kami'}


def euler(x, y, z):
    """anm_matrix_core.lua M.euler (0x1411e9bd0), angles in radians."""
    cx, cy, cz, sx, sy, sz = np.cos(x), np.cos(y), np.cos(z), np.sin(x), np.sin(y), np.sin(z)
    return np.array([[cz * cy, -sz * cy, sy, 0],
                     [cz * sx * sy + sz * cx, cz * cx - sy * sx * sz, -sx * cy, 0],
                     [sz * sx - cz * cx * sy, sy * cx * sz + cz * sx, cx * cy, 0],
                     [0, 0, 0, 1]])


def node(position, rotation, scale):
    """nuccCoord constructor 0x1412892a0: translation * Euler (degrees) * column scale."""
    m = np.eye(4)
    m[:3, 3] = position
    m = m @ euler(*np.radians(rotation))
    m[:, :3] *= np.array(scale)
    return m


def main() -> int:
    game = GameData()
    xf = Xfbin(FILE, game.fetch(FILE))
    report = json.loads((FOLDER / 'dispatches_frame22136.json').read_text(encoding='utf-8'))
    failures, checked_total = 0, 0
    for row in report['dispatches']:
        files = {(b['kind'], b['slot']): FOLDER / b['file'] for b in row['bound'] if 'file' in b}
        if ('ro', 0) not in files:
            continue
        stride, count = struct.unpack('<2I', files[('ro', 3)].read_bytes()[:8])
        model_name = MODELS.get(count)
        chunk = xf.by_key.get(('nuccChunkModel', model_name))
        if chunk is None:
            print(f'event {row["event"]}: model for {count} vertices not found')
            failures += 1
            continue
        body = xf.body(chunk)
        clump_chunk = xf.by_key[('nuccChunkClump', xf.ref(chunk, struct.unpack_from('>I', body, 12)[0])[2])]
        clump = Importer.clump(None, xf, clump_chunk)
        at = body.find(b'NDP3')
        nud = body[at:at + struct.unpack_from('>I', body, at + 4)[0]]
        bone_start, bone_end = struct.unpack_from('>2H', nud, 12)
        # The dispatch input is the NUD mesh itself.
        captured = files[('ro', 0)].read_bytes()
        mesh = next(m for g in parse_nud(nud)['groups'] for m in g['meshes'] if m['vertex_count'] == count)
        same = all(np.allclose(struct.unpack_from('>3f', nud, mesh['extra_offset'] + v * 64),
                               struct.unpack_from('<3f', captured, v * stride), atol=1e-5) for v in range(count))
        palette = np.frombuffer(files[('ro', 1)].read_bytes(), dtype='<f4').reshape(-1, 4, 4).astype(np.float64)
        # Rest matrices of the clump's coordinates, model space.
        bind = []
        for index, name in enumerate(clump['coords']):
            values = struct.unpack_from('>10f', xf.body(xf.by_key[('nuccChunkCoord', name)]))
            local = node(values[0:3], values[3:6], values[6:9])
            parent = clump['parents'][index]
            bind.append(local if parent < 0 else bind[parent] @ local)
        pose = [palette[i].T @ bind[i] for i in range(len(palette))]
        # Bones the mesh's vertices are bound to: the others' matrices need not be current.
        blend = files[('ro', 2)].read_bytes()
        used = set()
        for v in range(count):
            weights = struct.unpack_from('<4f', blend, v * 32)
            used.update(i for i, w in zip(struct.unpack_from('<4I', blend, v * 32 + 16), weights) if w)
        worst, checked, moved, unused_off = 0.0, 0, 0, []
        for i in range(len(palette)):
            parent = clump['parents'][i]
            # The child of the clump root carries the model's own displacement: its translation is animated.
            if parent <= 0 or parent >= len(palette):
                continue
            local_pose = np.linalg.inv(pose[parent]) @ pose[i]
            local_bind = np.linalg.inv(bind[parent]) @ bind[i]
            error = float(np.abs(local_pose[:3, 3] - local_bind[:3, 3]).max())
            ortho = float(np.abs(local_pose[:3, :3] @ local_pose[:3, :3].T - np.eye(3)).max())
            if i not in used:
                if max(error, ortho) >= 2e-2:
                    unused_off.append(i)
                continue
            worst = max(worst, error, ortho)
            checked += 1
            moved += not np.allclose(local_pose[:3, :3], local_bind[:3, :3], atol=1e-3)
        checked_total += checked
        ok = same and checked > 0 and worst < 2e-2 and len(palette) == bone_end + 1
        failures += not ok
        print(f'event {row["event"]} ({model_name!r}, {count} vertices): input == NUD vertices {same}; palette {len(palette)} matrices, '
              f'NUD bones {bone_start}..{bone_end}, clump {len(clump["coords"])} coordinates; {checked} bones the mesh uses, '
              f'{moved} rotated away from rest; largest bone-length / orthonormality difference {worst:.2e} '
              f'{"ok" if ok else "MISMATCH"}' + (f'; matrices of unused bones {unused_off} are not a pose' if unused_off else ''))
    print('PASS: the palette is pose * inverse(rest), one matrix per clump coordinate' if not failures and checked_total
          else 'FAIL')
    return 1 if failures or not checked_total else 0


if __name__ == '__main__':
    sys.exit(main())
