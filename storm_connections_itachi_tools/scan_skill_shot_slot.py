import sys,bisect,collections
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']]);fs=[(e.struct.BeginAddress,e.struct.EndAddress) for e in p.DIRECTORY_ENTRY_EXCEPTION];starts=[x[0] for x in fs];base=0x140000000
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
for i in md.disasm(p.get_data(0xa50000,0x30000),base+0xa50000):
 if i.id==0 or not any(o.type==CS_OP_MEM and o.mem.disp==int(sys.argv[1],0) for o in i.operands):continue
 n=bisect.bisect_right(starts,i.address-base)-1
 print(hex(i.address),'fn',hex(base+fs[n][0]),i.mnemonic,i.op_str)
