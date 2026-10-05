"""Parse DXBC RDEF reflection and rebuild the engine's merged constant-buffer layout.

NSUNSC.exe reflects each stage with D3DReflect (0x141426eb0 -> 0x1414274f0) and
merges the VS and PS constant buffers per register slot (0x141405cc0): buffer
size is the max of both stages, variables are united by name and keep the
reflected StartOffset/Size. The staged CPU block is uploaded whole, so these
offsets are the GPU byte offsets. This module reproduces that from the bytecode.
"""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

SIT = {0: 'cbuffer', 1: 'tbuffer', 2: 'texture', 3: 'sampler', 4: 'uav_rwtyped', 5: 'structured'}
STAGE_BIT = {'vs': 1 << 1, 'ps': 1 << 2}  # engine flag: 1 << stage type (VS=1, PS=2)
SVF_USED = 2


def chunks(blob: bytes) -> dict[str, bytes]:
    if blob[:4] != b'DXBC':
        raise ValueError('not a DXBC container')
    count = struct.unpack_from('<I', blob, 28)[0]
    out = {}
    for off in struct.unpack_from(f'<{count}I', blob, 32):
        tag = blob[off:off + 4].decode('ascii', 'replace')
        size = struct.unpack_from('<I', blob, off + 4)[0]
        out[tag] = blob[off + 8:off + 8 + size]
    return out


def cstr(data: bytes, off: int) -> str:
    return data[off:data.index(b'\0', off)].decode('ascii', 'replace')


def parse_rdef(blob: bytes) -> dict:
    c = chunks(blob)
    r = c['RDEF']
    cb_count, cb_off, bind_count, bind_off, minor, major, ptype = struct.unpack_from('<4I2BH', r, 0)
    stage = {0xfffe: 'vs', 0xffff: 'ps'}.get(ptype, hex(ptype))
    var_stride = 40 if major >= 5 else 24
    buffers = []
    for i in range(cb_count):
        name, var_count, var_off, size, flags, kind = struct.unpack_from('<6I', r, cb_off + i * 24)
        variables = []
        for v in range(var_count):
            vname, start, vsize, vflags, _type, _default = struct.unpack_from('<6I', r, var_off + v * var_stride)
            variables.append({'name': cstr(r, vname), 'offset': start, 'size': vsize,
                              'used': bool(vflags & SVF_USED)})
        buffers.append({'name': cstr(r, name), 'size': size, 'type': kind, 'variables': variables})
    bindings = []
    for i in range(bind_count):
        name, kind, _ret, _dim, _samples, point, count, _flags = struct.unpack_from('<8I', r, bind_off + i * 32)
        bindings.append({'name': cstr(r, name), 'type': SIT.get(kind, kind), 'slot': point, 'count': count})
    slot_by_name = {b['name']: b['slot'] for b in bindings if b['type'] == 'cbuffer'}
    for b in buffers:
        b['slot'] = slot_by_name.get(b['name'])
    return {'stage': stage, 'version': f'{major}.{minor}', 'buffers': buffers, 'bindings': bindings}


def merged_layout(*stages: dict) -> dict:
    """Engine merge (0x141405cc0): one buffer per slot, shared by VS and PS."""
    slots: dict[int, dict] = {}
    for st in stages:
        bit = STAGE_BIT.get(st['stage'], 0)
        for b in st['buffers']:
            if b['slot'] is None:
                continue  # declared but not bound by this stage
            cur = slots.setdefault(b['slot'], {'slot': b['slot'], 'name': b['name'], 'size': 0, 'variables': {}})
            cur['size'] = max(cur['size'], b['size'])
            for v in b['variables']:
                flag = bit if v['used'] else 0
                old = cur['variables'].get(v['name'])
                if old is None:
                    cur['variables'][v['name']] = {'offset': v['offset'], 'size': v['size'], 'stage_mask': flag}
                elif old['offset'] == v['offset'] and old['size'] == v['size']:
                    old['stage_mask'] |= flag
                else:
                    old.setdefault('conflicts', []).append({'stage': st['stage'], **v})
    out = []
    for slot in sorted(slots):
        b = slots[slot]
        b['variables'] = [{'name': n, **v} for n, v in sorted(b['variables'].items(), key=lambda kv: kv[1]['offset'])]
        b['gpu_byte_width'] = max(b['size'], 16)  # CreateBuffer clamp in 0x141428000
        out.append(b)
    return {'buffers': out}


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('dxbc', nargs='+', type=Path, help='One stage, or VS then PS to print the merged layout')
    ap.add_argument('--json', action='store_true')
    args = ap.parse_args()
    parsed = [parse_rdef(p.read_bytes()) for p in args.dxbc]
    result = {'stages': parsed, 'merged': merged_layout(*parsed)}
    if args.json:
        print(json.dumps(result, indent=2))
    else:
        for p, st in zip(args.dxbc, parsed):
            print(f'== {p.name} [{st["stage"]} {st["version"]}]')
            for b in st['bindings']:
                print(f'   bind {b["type"]:8s} slot {b["slot"]:2d} x{b["count"]} {b["name"]}')
        for b in result['merged']['buffers']:
            print(f'== merged b{b["slot"]} {b["name"]} size {b["size"]} (GPU ByteWidth {b["gpu_byte_width"]})')
            for v in b['variables']:
                note = ' CONFLICT' if 'conflicts' in v else ''
                print(f'   +{v["offset"]:4d} size {v["size"]:3d} stages {v["stage_mask"]:#04x} {v["name"]}{note}')
