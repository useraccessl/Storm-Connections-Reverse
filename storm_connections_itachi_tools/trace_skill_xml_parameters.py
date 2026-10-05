import sys,struct,json
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile,numpy as np
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);data=EXE.read_bytes();base=p.OPTIONAL_HEADER.ImageBase
for name in sys.argv[1:] or ('Velocity','Inductivity','FrameElapsed'):
 needle=name.encode()+b'\0';start=0
 while True:
  off=data.find(needle,start)
  if off<0:break
  start=off+len(needle);target=base+p.get_rva_from_offset(off);print(name,hex(target))
  for section in p.sections:
   blob=section.get_data();sbase=base+section.VirtualAddress
   if section.Characteristics&0x20000000:
    for a in range(4):
     v=np.frombuffer(blob[a:a+((len(blob)-a)//4)*4],dtype='<i4').astype(np.int64);positions=np.arange(a,a+len(v)*4,4,dtype=np.int64)
     for h in positions[sbase+positions+4+v==target]:print(' rip candidate',hex(sbase+int(h)))
   else:
    at=0;pattern=struct.pack('<Q',target)
    while True:
     at=blob.find(pattern,at)
     if at<0:break
     print(' pointer',hex(sbase+at));at+=1

