import sys,bisect
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']]);fs=[(e.struct.BeginAddress,e.struct.EndAddress) for e in p.DIRECTORY_ENTRY_EXCEPTION];starts=[x[0] for x in fs];base=0x140000000
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
for i in md.disasm(p.get_data(0x1300000,0x90000),base+0x1300000):
 if i.id==0 or not i.operands or i.operands[0].type!=CS_OP_MEM:continue
 o=i.operands[0]
 if o.mem.disp not in (0x108,0x1f4) or md.reg_name(o.mem.base) in ('rsp','rbp'):continue
 if not i.mnemonic.startswith(('mov','mul','add')):continue
 n=bisect.bisect_right(starts,i.address-base)-1
 print(hex(i.address),'fn',hex(base+fs[n][0]),i.mnemonic,i.op_str)
