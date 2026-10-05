import sys,struct
from pathlib import Path
sys.path.insert(0,'vendor')
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_IMM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);base=p.OPTIONAL_HEADER.ImageBase
for vtable in (0x1ba4c08,):
 print('vtable',hex(base+vtable),[hex(x) for x in struct.unpack('<12Q',p.get_data(vtable,96))])
 col=struct.unpack('<Q',p.get_data(vtable-8,8))[0]-base
 print('COL',hex(col),p.get_data(col,24).hex())
 td=struct.unpack_from('<I',p.get_data(col,24),12)[0]
 print('type',p.get_data(td+16,150).split(b'\0')[0])
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
for i in md.disasm(p.get_data(0x1270000,0x130000),base+0x1270000):
 if i.id and i.mnemonic in ('call','jmp') and any(o.type==CS_OP_IMM and o.imm in (0x14138f780,0x14138fc30,0x14138f8f0) for o in i.operands):print(hex(i.address),i.mnemonic,i.op_str)
