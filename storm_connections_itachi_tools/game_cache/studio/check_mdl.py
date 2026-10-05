"""Bones of a compiled .mdl (v48 mstudiobone_t) against the rest pose they were exported from."""
import struct
import sys
from pathlib import Path
import numpy as np

sys.path.insert(0, str(Path(__file__).resolve().parents[2]))
from port_preview import Port, capture_camera

package, model = sys.argv[1], sys.argv[2]
data = Path(__file__).with_name('game').joinpath('models', 'storm_fx', f'{model}.mdl').read_bytes()
assert data[:4] == b'IDST', data[:4]
version = struct.unpack_from('<i', data, 4)[0]
numbones, boneindex = struct.unpack_from('<ii', data, 156)
print('version', version, 'bones', numbones)
port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64))
skeleton = port.load(package).data.models[model].skeleton
port.lua.execute(f'StormFX.Engine.tPackages["{package}"].models.CompiledFor("2ksmeff1_wtr_ptc15")')
rest_list = [np.array([float(m[i]) for i in range(1, 17)]).reshape(4, 4) for m in skeleton.restWorld.values()]
rest = {str(n): rest_list[i] for i, n in enumerate(skeleton.coords.values())}
worst = 0.0
for b in range(numbones):
    base = boneindex + b * 216
    name_off, parent = struct.unpack_from('<ii', data, base)
    name = data[base + name_off:data.index(b'\0', base + name_off)].decode()
    m34 = np.array(struct.unpack_from('<12f', data, base + 96)).reshape(3, 4)
    pose_to_bone = np.vstack([m34, [0, 0, 0, 1]])
    want = np.linalg.inv(rest[name])
    d = float(np.abs(pose_to_bone - want).max())
    worst = max(worst, d)
    if b < 3 or d > 1e-3:
        print(b, name, 'parent', parent, 'difference from inverse rest', round(d, 5))
print('largest difference', worst)
