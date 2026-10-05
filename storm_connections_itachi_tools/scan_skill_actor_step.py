import sys,json,bisect
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
functions=[(e.struct.BeginAddress,e.struct.EndAddress) for e in p.DIRECTORY_ENTRY_EXCEPTION];starts=[a for a,b in functions];base=p.OPTIONAL_HEADER.ImageBase
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
hits=[]
for i in md.disasm(p.get_data(0xa50000,0x30000),base+0xa50000):
 if i.id==0 or not i.operands or i.operands[0].type!=CS_OP_MEM or i.operands[0].mem.disp!=0x164:continue
 if not i.mnemonic.startswith(('mov','add','sub','mul','div')):continue
 n=bisect.bisect_right(starts,i.address-base)-1;fn=functions[n][0]+base if n>=0 and i.address-base<functions[n][1] else None
 h={'address':hex(i.address),'function':hex(fn) if fn else None,'asm':i.mnemonic+' '+i.op_str};hits.append(h);print(h)
(ROOT/'captured_assets/procedural/skill_actor_step_writes.json').write_text(json.dumps(hits,indent=2)+'\n')
