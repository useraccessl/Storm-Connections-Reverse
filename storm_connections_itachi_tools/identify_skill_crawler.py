import re,sys,struct
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile,numpy as np
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);data=EXE.read_bytes();base=p.OPTIONAL_HEADER.ImageBase
for m in re.finditer(rb'[\x20-\x7e]{5,}',data):
 if b'crawler' not in m.group().lower():continue
 print(hex(base+p.get_rva_from_offset(m.start())),m.group().decode()[:200])
needle=b'SKILL_ACTION_TYPE_CRAWLER\0';off=data.find(needle);target=base+p.get_rva_from_offset(off);print('enum target',hex(target))
for section in p.sections:
 if not section.Characteristics&0x20000000:continue
 blob=section.get_data();n=len(blob)-3
 # All unaligned rel32 endpoints, candidate only until disassembly confirms.
 for alignment in range(4):
  v=np.frombuffer(blob[alignment:alignment+((len(blob)-alignment)//4)*4],dtype='<i4').astype(np.int64)
  positions=np.arange(alignment,alignment+len(v)*4,4,dtype=np.int64)
  hits=positions[base+section.VirtualAddress+positions+4+v==target]
  for h in hits:print('xref candidate',hex(base+section.VirtualAddress+int(h)))
