import sys,bisect,struct,json
from pathlib import Path
sys.path.insert(0,'vendor');import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_AC_WRITE
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']]);entries=[e.struct for e in p.DIRECTORY_ENTRY_EXCEPTION];starts=[e.BeginAddress for e in entries]
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True;out=[]
for i in md.disasm(p.get_data(0x1300000,0xa0000),0x141300000):
 if not i.id:continue
 if any(o.type==CS_OP_MEM and o.mem.disp in (0x198,0x19c) and o.access&CS_AC_WRITE for o in i.operands):
  n=bisect.bisect_right(starts,i.address-0x140000000)-1
  row={'address':hex(i.address),'function':hex(0x140000000+entries[n].BeginAddress),'asm':i.mnemonic+' '+i.op_str};out.append(row);print(row)
Path('particle_model_clock_writes.json').write_text(json.dumps(out,indent=2)+'\n')
print('rate divisor',struct.unpack('<f',p.get_data(0x130b5ef+8+0x458375,4))[0])
