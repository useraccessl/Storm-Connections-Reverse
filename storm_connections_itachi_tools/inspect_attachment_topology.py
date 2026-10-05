"""Preserve attachment topology evidence from the current original executable."""
import sys, struct, hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from disasm_exe import EXE
import pefile
from capstone import Cs, CS_ARCH_X86, CS_MODE_64
data=EXE.read_bytes()
pe=pefile.PE(data=data,fast_load=True)
base=pe.OPTIONAL_HEADER.ImageBase
def read(va,count):
    off=pe.get_offset_from_rva(va-base)
    return data[off:off+count]
md=Cs(CS_ARCH_X86,CS_MODE_64)
vtable=0x141ba44c8
getter=struct.unpack('<Q',read(vtable+0x68,8))[0]
print('EXE SHA256',hashlib.sha256(data).hexdigest())
print('Attachment vtable',hex(vtable),'virtual +68',hex(getter))
for va,count in ((0x1413856b0,0x105),(getter,0x40)):
    print('\nRoutine',hex(va))
    for insn in md.disasm(read(va,count),va):
        print(f'{insn.address:016x}: {insn.mnemonic:8s} {insn.op_str}')
        if va==getter and insn.mnemonic=='ret': break
