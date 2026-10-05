"""The game's material shader archive, by shader key.

data/system/nuccMaterial_dx11.nsh holds one vertex/pixel DXBC pair per shader
key (the NUD material `flags`). This module indexes the pairs and reads what
each program declares (RDEF: constant buffers, variables, textures, samplers;
ISGN/OSGN signatures), so that the engine side can be derived from the game's
own shaders instead of from captures.

  python shader_library.py                 # summary: keys, identical programs
  python shader_library.py 0x1f002         # what one key's pair declares
  python shader_library.py 0x1f002 --asm   # with the disassembly
"""

from __future__ import annotations

import argparse
import hashlib
import struct
from collections import defaultdict
from pathlib import Path

from inspect_nsh import shaders

ROOT = Path(__file__).resolve().parent
GAME = Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS')
NSH = GAME / 'data/system/nuccMaterial_dx11.nsh'
COMPILER = GAME / 'd3dcompiler_47.dll'


def _cstr(data: bytes, at: int) -> str:
    return data[at:data.index(b'\0', at)].decode('ascii', 'replace')


def chunks(dxbc: bytes) -> dict[str, bytes]:
    count = struct.unpack_from('<I', dxbc, 28)[0]
    out = {}
    for offset in struct.unpack_from(f'<{count}I', dxbc, 32):
        tag = dxbc[offset:offset + 4].decode('ascii')
        size = struct.unpack_from('<I', dxbc, offset + 4)[0]
        out[tag] = dxbc[offset + 8:offset + 8 + size]
    return out


def rdef(dxbc: bytes) -> dict:
    """Constant buffers (with variables) and bound resources of a program."""
    data = chunks(dxbc)['RDEF']
    cb_count, cb_offset, bind_count, bind_offset = struct.unpack_from('<4I', data)
    buffers = []
    for i in range(cb_count):
        name, var_count, var_offset, size, _, _ = struct.unpack_from('<6I', data, cb_offset + i * 24)
        variables = []
        for v in range(var_count):
            vname, start, vsize, flags, type_offset, _ = struct.unpack_from('<6I', data, var_offset + v * 24)
            cls, kind, rows, columns, elements, _ = struct.unpack_from('<6H', data, type_offset)
            variables.append({'name': _cstr(data, vname), 'offset': start, 'size': vsize, 'used': bool(flags & 2),
                              'rows': rows, 'columns': columns, 'elements': elements})
        buffers.append({'name': _cstr(data, name), 'size': size, 'variables': variables})
    bindings = []
    for i in range(bind_count):
        name, kind, _, _, _, slot, count, _ = struct.unpack_from('<8I', data, bind_offset + i * 32)
        bindings.append({'name': _cstr(data, name), 'kind': {0: 'cbuffer', 2: 'texture', 3: 'sampler'}.get(kind, kind),
                         'slot': slot, 'count': count})
    return {'buffers': buffers, 'bindings': bindings}


def signature(dxbc: bytes, tag: str) -> list[dict]:
    data = chunks(dxbc).get(tag)
    if data is None:
        return []
    count = struct.unpack_from('<I', data)[0]
    out = []
    for i in range(count):
        name, index, system, component, register, mask, rw = struct.unpack_from('<5I2B', data, 8 + i * 24)
        out.append({'semantic': f'{_cstr(data, name)}{index}', 'register': register, 'mask': mask, 'system': system})
    return out


class ShaderLibrary:
    def __init__(self, path: Path = NSH):
        self.path = path
        self.data = path.read_bytes()
        programs = shaders(path)
        if len(programs) % 2:
            raise ValueError('unpaired shaders in the archive')
        self.pairs: dict[int, tuple[bytes, bytes]] = {}
        for i in range(0, len(programs), 2):
            vs, ps = programs[i], programs[i + 1]
            key = struct.unpack_from('<I', self.data, vs['offset'] - 8)[0]
            pair = tuple(self.data[p['offset']:p['offset'] + p['size']] for p in (vs, ps))
            if key in self.pairs and self.pairs[key] != pair:
                raise ValueError(f'shader key {key:#x} appears twice with different programs')
            self.pairs[key] = pair

    def has(self, key: int) -> bool:
        return key in self.pairs

    def digest(self, key: int) -> tuple[str, str]:
        """Hashes of the executable code only (SHEX/SHDR chunk): two keys with the
        same digest run the same instructions."""
        out = []
        for program in self.pairs[key]:
            parts = chunks(program)
            code = parts.get('SHEX') or parts.get('SHDR')
            out.append(hashlib.sha256(code).hexdigest()[:12])
        return out[0], out[1]

    def describe(self, key: int) -> dict:
        vs, ps = self.pairs[key]
        out = {'key': f'{key:#08x}', 'digest': self.digest(key)}
        for stage, program in (('vs', vs), ('ps', ps)):
            info = rdef(program)
            out[stage] = {
                'inputs': [s['semantic'] for s in signature(program, 'ISGN')],
                'outputs': [s['semantic'] for s in signature(program, 'OSGN')],
                'textures': [b['name'] for b in info['bindings'] if b['kind'] == 'texture'],
                'constants': {b['name']: [v['name'] for v in b['variables'] if v['used']] for b in info['buffers']}}
        return out

    def asm(self, key: int) -> tuple[str, str]:
        from disassemble_dxbc import disassemble
        return tuple(disassemble(program, COMPILER) for program in self.pairs[key])


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('keys', nargs='*', help='shader keys (hex)')
    ap.add_argument('--asm', action='store_true')
    args = ap.parse_args()
    library = ShaderLibrary()
    if not args.keys:
        by_vs, by_ps = defaultdict(list), defaultdict(list)
        for key in sorted(library.pairs):
            vs, ps = library.digest(key)
            by_vs[vs].append(key)
            by_ps[ps].append(key)
        print(f'{len(library.pairs)} shader keys, {len(by_vs)} distinct vertex programs, {len(by_ps)} distinct pixel programs')
        for digest, keys in sorted(by_ps.items(), key=lambda kv: kv[1][0]):
            print(f'  ps {digest}: ' + ' '.join(f'{k:#x}' for k in keys))
    for text in args.keys:
        key = int(text, 16)
        info = library.describe(key)
        print(f'KEY {info["key"]}: vs {info["digest"][0]} ps {info["digest"][1]}')
        for stage in ('vs', 'ps'):
            s = info[stage]
            print(f'  {stage} in  {s["inputs"]}')
            print(f'  {stage} out {s["outputs"]}')
            print(f'  {stage} textures {s["textures"]}')
            for buffer, names in s['constants'].items():
                print(f'  {stage} {buffer}: {names}')
        if args.asm:
            for stage, text in zip(('vs', 'ps'), library.asm(key)):
                print(f'---- {stage} ----')
                print(text)
