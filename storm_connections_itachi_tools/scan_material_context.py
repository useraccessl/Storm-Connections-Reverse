"""Find original shader-context accessors/writers in the NUCC code region."""
import sys,json,bisect
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from disasm_exe import EXE
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
p=pefile.PE(str(EXE),fast_load=True)
p.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXCEPTION']])
functions=[(e.struct.BeginAddress,e.struct.EndAddress) for e in p.DIRECTORY_ENTRY_EXCEPTION]
starts=[a for a,b in functions]
base=p.OPTIONAL_HEADER.ImageBase
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;md.skipdata=True
begin,end=0x1270000,0x13a0000
blob=p.get_data(begin,end-begin)
hits=[]
for i in md.disasm(blob,base+begin):
    if i.id==0: continue
    if not any(o.type==CS_OP_MEM and o.mem.disp in (0x4f0,0x510,0x540,0x550) for o in i.operands): continue
    index=bisect.bisect_right(starts,i.address-base)-1
    function=functions[index][0]+base if index>=0 and i.address-base<functions[index][1] else None
    hits.append({'address':hex(i.address),'function':hex(function) if function else None,'asm':i.mnemonic+' '+i.op_str})
(ROOT/'material_context_accesses.json').write_text(json.dumps(hits,indent=2)+'\n')
for h in hits: print(h['function'],h['address'],h['asm'])
