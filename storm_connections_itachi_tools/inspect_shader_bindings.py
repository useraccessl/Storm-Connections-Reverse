"""Dump the shader-parameter dispatch table used by nuccMaterial::apply."""
import json
import hashlib
import re
import struct
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent / 'vendor'))
import pefile
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
from disasm_exe import EXE

data = EXE.read_bytes()
expected_sha256 = 'cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e'
actual_sha256 = hashlib.sha256(data).hexdigest()
if actual_sha256 != expected_sha256:
    raise ValueError(f'unsupported NSUNSC.exe build: {actual_sha256} (expected {expected_sha256})')
pe = pefile.PE(data=data, fast_load=True)
base = pe.OPTIONAL_HEADER.ImageBase
offset = lambda va: pe.get_offset_from_rva(va - base)
md = Cs(CS_ARCH_X86, CS_MODE_64)
table = 0x141b9d2d8
names_table = 0x141b9ce50
items = []
for n in range(72):
    fn, other = struct.unpack_from('<QQ', data, offset(table) + n * 16)
    if not base <= fn < base + pe.OPTIONAL_HEADER.SizeOfImage:
        break
    asm = []
    for insn in md.disasm(data[offset(fn):offset(fn)+0x300], fn):
        asm.append(f'{insn.address:#x}: {insn.mnemonic} {insn.op_str}')
        # Some generated accessors are tail-call thunks ending in an
        # unconditional jmp. Do not disassemble the following function as if
        # it were part of this accessor.
        if insn.mnemonic in ('ret', 'jmp'):
            break
    ident, name_pointer = struct.unpack_from('<QQ', data, offset(names_table) + n * 16)
    name_offset = offset(name_pointer)
    name = data[name_offset:data.index(b'\0', name_offset)].decode('ascii')
    if ident != n:
        raise ValueError(f'name/dispatch index mismatch: {ident}/{other}/{n}')
    terminal = asm[-1] if asm else ''
    dispatch_path = 'sampler_resource' if 'jmp 0x14123c0e0' in terminal else 'parameter_value'
    binding_id_loads = [x for x in asm if 'mov ecx, dword ptr [' in x]
    if len(binding_id_loads) != 1:
        raise ValueError(f'{name}: expected one runtime binding-ID load, found {binding_id_loads}')
    match = re.search(r'mov ecx, dword ptr \[(\w+) \+ (0x[0-9a-f]+|\d+)\]', binding_id_loads[0])
    if not match:
        raise ValueError(f'{name}: unrecognized runtime binding-ID load: {binding_id_loads[0]}')
    binding_id_register, binding_id_offset_text = match.groups()
    binding_id_offset = int(binding_id_offset_text, 16)
    expected_binding_id_offset = 4 + n * 4
    if binding_id_offset != expected_binding_id_offset:
        raise ValueError(
            f'{name}: runtime binding-ID field is {binding_id_offset:#x}, '
            f'expected caller record offset {expected_binding_id_offset:#x}'
        )
    item = {
        'accessor_index': n,
        'name': name,
        'function': hex(fn),
        'name_table_index': ident,
        'dispatch_table_aux': other,
        'dispatch_path': dispatch_path,
        'runtime_id_source_register': binding_id_register,
        'runtime_id_source_offset': hex(binding_id_offset),
        'asm': asm,
    }
    items.append(item)
    if any(any(off in x for off in ('0x510','0x520','0x530','0x540','0x550','0x560','0x4f0','0x3b0')) for x in asm):
        print(name, hex(fn), [x for x in asm if 'add rcx' in x or 'sub rcx' in x])
Path('shader_bindings_dispatch.json').write_text(json.dumps(items, indent=2)+'\n')
