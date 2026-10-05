"""Verify original RGB ANM reader with relocated original tail setter."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);start=0x141395000;raw=p.get_data(start-0x140000000,0x124)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;ins=list(md.disasm(raw,start));assert sum(i.size for i in ins)==len(raw)
setter=p.get_data(0x11adb80,0xf);assert setter[-1]==0xc3
code=bytearray(raw+setter)
for i in ins:
 assert i.mnemonic in {'sub','mov','movaps','xor','div','lea','movzx','movd','cvtdq2ps','test','jne','movss','divss','jmp','xorps','cvtsi2ss','subss','mulss','addss','add'},i
 offset=i.address-start
 if i.mnemonic in ('jmp','jne'):
  target=i.operands[0].imm
  if target==0x1411adb80:struct.pack_into('<i',code,offset+i.imm_offset,len(raw)-(offset+i.size))
  else:assert start<=target<start+len(raw)
 for o in i.operands:
  if o.type==CS_OP_MEM:
   reg=i.reg_name(o.mem.base);assert reg in {'rip','rsp','rcx','r9','r8','rax'}
   if reg=='rip':
    literal=p.get_data(i.address+i.size+o.mem.disp-0x140000000,4)
    assert struct.unpack('<f',literal)[0] in (1,255)
    code+=b'\0'*((-len(code))%16);target=len(code);code+=literal
    struct.pack_into('<i',code,offset+i.disp_offset,target-(offset+i.size))
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
addr=k.VirtualAlloc(None,len(code),0x3000,4);assert addr;ctypes.memmove(addr,bytes(code),len(code));old=ctypes.c_ulong();assert k.VirtualProtect(addr,len(code),0x20,ctypes.byref(old))
fn=ctypes.WINFUNCTYPE(None,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_uint32)(addr)
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
l=LuaRuntime(unpack_returned_tuples=True);core=l.execute((ROOT/'color_animation_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(395000);cases=[]
for _ in range(4000):
 keys=[[rng.randrange(256) for _ in range(3)] for _ in range(rng.randrange(2,20))];step=rng.choice((1,50,100,1000));tick=rng.randrange((len(keys)-1)*step+1);cases.append((keys,step,tick))
assets=json.loads((ROOT/'captured_assets/effect_animation.json').read_text())
for a in assets.values():
 for entry in a['entries']:
  for c in entry['curves']:
   if c['format']==20:
    step=a['frame_step_ticks']
    for tick in range(0,(len(c['values'])-1)*step+1,50):cases.append((c['values'],step,tick))
try:
 for keys,step,tick in cases:
  packed=ctypes.create_string_buffer(struct.pack('<I',step)+bytes(v for key in keys for v in key))
  controller=ctypes.create_string_buffer(32);struct.pack_into('<Q',controller,0x18,ctypes.addressof(packed))
  out=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*12+b'\x5A'*16,44)
  fn(controller,ctypes.addressof(out)+16,tick)
  curve=l.table_from({'format':20,'values':l.table_from([l.table_from(v) for v in keys])});v=core.sample(curve,tick,step,f)
  assert out.raw[16:28]==struct.pack('<3f',*[v[i] for i in range(1,4)])
  assert out.raw[:16]==b'\xA5'*16 and out.raw[-16:]==b'\x5A'*16
finally:k.VirtualFree(addr,0,0x8000)
(ROOT/'captured_assets/procedural/color_animation_native_verification.json').write_text(json.dumps({'cases':len(cases),'function':hex(start),'codeSha256':hashlib.sha256(raw).hexdigest(),'verification':'All three floats byte exact; original tail setter and relocated literal constants; memory guards','limitations':'Point-light controller field mapping statically transcribed; rendering of light and deferred compositing not verified.'},indent=2)+'\n')
print('PASS',len(cases),'original RGB animation cases.')
