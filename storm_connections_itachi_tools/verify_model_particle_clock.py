"""Validate original model-particle speed prefix; independent bounded math only."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
start=0x14130b5d3;raw=p.get_data(start-0x140000000,0x2e);ins=list(md.disasm(raw,start));assert sum(i.size for i in ins)==len(raw)
# ABI wrapper preserves RBX/XMM9 and supplies the original accumulated age step.
prologue=bytes.fromhex('53 48 83 ec 20 44 0f 29 0c 24 48 89 cb 44 0f 28 c9')
epilogue=bytes.fromhex('44 0f 28 0c 24 48 83 c4 20 5b c3')
code=bytearray(prologue+raw+epilogue);globalobject=ctypes.create_string_buffer(0x960)
for i in ins:
 assert i.mnemonic in {'mov','movaps','movzx','movd','cvtdq2ps','divss','mulss','movss'}
 for o in i.operands:
  if o.type==CS_OP_MEM:
   reg=i.reg_name(o.mem.base);assert reg in {'rip','rbx','rax'}
   if reg=='rip':
    target=i.address+i.size+o.mem.disp-0x140000000
    if i.mnemonic=='mov':literal=struct.pack('<Q',ctypes.addressof(globalobject))
    else:
     literal=p.get_data(target,4);assert struct.unpack('<f',literal)[0]==30
    code+=b'\0'*((-len(code))%16);offset=len(code);code+=literal
    at=len(prologue)+i.address-start
    struct.pack_into('<i',code,at+i.disp_offset,offset-(at+i.size))
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
address=k.VirtualAlloc(None,len(code),0x3000,4);assert address;ctypes.memmove(address,bytes(code),len(code));old=ctypes.c_ulong();assert k.VirtualProtect(address,len(code),0x20,ctypes.byref(old))
fn=ctypes.WINFUNCTYPE(None,ctypes.c_void_p,ctypes.c_float)(address)
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
lua=LuaRuntime(unpack_returned_tuples=True);core=lua.execute((ROOT/'anm_clock_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(0x305d3);cases=[(hz,rate,scale) for hz in (15,30,60) for rate in (1,2,3,4,5,6,10,12,15,20,30,60) for scale in (0,.1,.5,1,2)]
cases += [(rng.randint(1,120),rng.choice((15,20,30,60)),f(rng.uniform(0,4))) for _ in range(2000)]
try:
 for hz,rate,scale in cases:
  delta,speed,age=core.particleStep(hz,rate,scale,f)
  globalobject[0x952]=rate
  obj=ctypes.create_string_buffer(b'\xA5'*0x80,0x80);packet=ctypes.create_string_buffer(0x48)
  struct.pack_into('<Q',packet,0x40,ctypes.addressof(obj))
  fn(packet,age)
  expected=bytearray(b'\xA5'*0x80);struct.pack_into('<f',expected,0x48,speed)
  assert obj.raw==bytes(expected)
finally:k.VirtualFree(address,0,0x8000)
report={'cases':len(cases),'originalPrefix':'0x14130b5d3..0x14130b601','codeSha256':hashlib.sha256(raw).hexdigest(),'verification':'Original speed prefix byte exact, all other target fields guarded','limitations':'Age factor producer and delta division statically transcribed; full motion/render update not executed.'}
(ROOT/'captured_assets/procedural/model_particle_clock_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS',len(cases),'original model particle speed cases.')

