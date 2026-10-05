import sys,struct
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile,numpy as np
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);base=p.OPTIONAL_HEADER.ImageBase
for target in [int(a,0) for a in sys.argv[1:]]:
 print('TARGET',hex(target))
 for section in p.sections:
  blob=section.get_data();sb=base+section.VirtualAddress
  if section.Characteristics&0x20000000:
   for a in range(4):
    v=np.frombuffer(blob[a:a+((len(blob)-a)//4)*4],dtype='<i4').astype(np.int64);pos=np.arange(a,a+len(v)*4,4,dtype=np.int64)
    for h in pos[sb+pos+4+v==target]:print('disp',hex(sb+int(h)))
  else:
   at=0
   while True:
    at=blob.find(struct.pack('<Q',target),at)
    if at<0:break
    print('ptr',hex(sb+at));at+=1
