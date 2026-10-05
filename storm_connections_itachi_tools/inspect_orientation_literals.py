import sys,struct
from pathlib import Path
sys.path.insert(0,str(Path('vendor').resolve()))
import pefile
from disasm_exe import EXE
p=pefile.PE(str(EXE));base=p.OPTIONAL_HEADER.ImageBase
for va in (0x1414430a2,0x1414430a8):
 raw=p.get_data(va-base,6);disp=struct.unpack_from('<i',raw,2)[0];slot=va+6+disp
 print(hex(va),raw.hex(),hex(slot))
 for lib in p.DIRECTORY_ENTRY_IMPORT:
  for imp in lib.imports:
   if imp.address==slot:print(lib.dll,imp.name)
for va in (0x1412ccd80+8+0x494a60,0x1412ccd88+8+0x8c9570,0x1412ccd90+8+0x49d6c0,0x1412ccda8+8+0x49d6a8,0x1412ccdb0+8+0x8c79e4):
 print(hex(va),struct.unpack('<f',p.get_data(va-base,4))[0])
