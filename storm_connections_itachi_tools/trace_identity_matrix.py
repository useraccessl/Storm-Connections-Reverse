import struct,sys
sys.path.insert(0,'vendor')
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);m=Cs(CS_ARCH_X86,CS_MODE_64);m.detail=True
section=next(s for s in p.sections if s.Name.startswith(b'.text'));blob=section.get_data();start=0x140000000+section.VirtualAddress;target=0x149707f10
for rel in range(len(blob)-4):
 if start+rel+4+struct.unpack_from('<i',blob,rel)[0]!=target:continue
 for before in range(2,7):
  off=rel-before
  ins=next(m.disasm(blob[off:off+15],start+off),None)
  if ins and any(o.type==CS_OP_MEM and m.reg_name(o.mem.base)=='rip' and ins.address+ins.size+o.mem.disp==target for o in ins.operands):
   print(hex(ins.address),ins.mnemonic,ins.op_str)
