import sys,bisect,json
from pathlib import Path
sys.path.insert(0,'vendor');import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
entries=[e.struct for e in p.DIRECTORY_ENTRY_EXCEPTION];starts=[e.BeginAddress for e in entries]
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True;out=[]
for i in md.disasm(p.get_data(0x1270000,0x130000),0x141270000):
 if i.id==0:continue
 if any(o.type==CS_OP_MEM and o.mem.disp==0x952 for o in i.operands):
  n=bisect.bisect_right(starts,i.address-0x140000000)-1
  fn=hex(0x140000000+entries[n].BeginAddress) if n>=0 and entries[n].EndAddress>i.address-0x140000000 else None
  out.append({'address':hex(i.address),'function':fn,'asm':i.mnemonic+' '+i.op_str})
Path('animation_mode_accesses.json').write_text(json.dumps(out,indent=2)+'\n')
for row in out:print(row)
