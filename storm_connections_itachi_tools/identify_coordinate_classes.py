import sys,struct,re
from pathlib import Path
sys.path.insert(0,'vendor');import pefile
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);base=p.OPTIONAL_HEADER.ImageBase;data=EXE.read_bytes()
r=p.get_section_by_rva(0x1735000);rd=p.get_data(r.VirtualAddress,r.SizeOfRawData)
for m in re.finditer(rb'\.\?AVnucc(?:Coord|Clump)[^\x00]{0,80}@@\x00',data):
 td=p.get_rva_from_offset(m.start())-16
 cols=[]
 for c in re.finditer(re.escape(struct.pack('<I',td)),rd):
  off=c.start()-12
  if off>=0 and struct.unpack_from('<I',rd,off)[0]==1 and struct.unpack_from('<I',rd,off+20)[0]==r.VirtualAddress+off:cols.append(r.VirtualAddress+off)
 for col in cols:
  for q in re.finditer(re.escape(struct.pack('<Q',base+col)),rd):
   vt=r.VirtualAddress+q.start()+8
   funcs=struct.unpack('<8Q',p.get_data(vt,64))
   print(m.group()[:-1].decode(),hex(base+vt),' '.join(hex(f) for f in funcs))
