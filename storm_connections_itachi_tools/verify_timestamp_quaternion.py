"""Check original timestamp ratio instructions and file quaternion traversal."""
import ctypes,json,random,struct,sys,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);start=0x141391e0a;raw=p.get_data(start-0x140000000,0x27)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;ins=list(md.disasm(raw,start));assert sum(i.size for i in ins)==len(raw)
for i in ins:
 assert i.mnemonic in {'xorps','sub','lea','mov','cvtsi2ss','movss','divss'},i
 for o in i.operands:
  if o.type==CS_OP_MEM:assert i.reg_name(o.mem.base) in ('rbx','rsp') and o.mem.disp in (0,4,0x14,0x20,0x40)
code=bytes.fromhex('53 48 83 ec 60 0f 29 74 24 50 48 89 cb 41 89 d0')+raw+bytes.fromhex('0f 28 c6 0f 28 74 24 50 48 83 c4 60 5b c3')
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
addr=k.VirtualAlloc(None,len(code),0x3000,4);assert addr;ctypes.memmove(addr,code,len(code));old=ctypes.c_ulong();assert k.VirtualProtect(addr,len(code),0x20,ctypes.byref(old))
fn=ctypes.WINFUNCTYPE(ctypes.c_float,ctypes.c_void_p,ctypes.c_uint32)(addr)
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
rng=random.Random(3910);count=5000
try:
 for n in range(count):
  begin=rng.randrange(0,4000000000);end=4294967295 if n%5==0 else rng.randrange(begin+1,4294967296);tick=rng.randrange(begin,end)
  keys=ctypes.create_string_buffer(struct.pack('<I4fI4f',begin,0,0,0,1,end,0,0,0,1))
  assert struct.pack('<f',fn(keys,tick))==struct.pack('<f',f(f(tick-begin)/f(end-begin)))
finally:k.VirtualFree(addr,0,0x8000)
lua=LuaRuntime(unpack_returned_tuples=True);Q=lua.execute((ROOT/'quaternion_animation_core.lua').read_text(encoding='utf-8-sig'))
crt=ctypes.CDLL('ucrtbase.dll')
for name in ('sinf','acosf'):getattr(crt,name).argtypes=[ctypes.c_float];getattr(crt,name).restype=ctypes.c_float
assets=json.loads((ROOT/'captured_assets/effect_animation.json').read_text());checks=0
for name in ('4efb_amt1_hit00','4efb_amt1_blt00'):
 for entry in assets[name]['entries']:
  for c in entry['curves']:
   if c['format']!=10:continue
   curve=lua.table_from({'format':10,'values':lua.table_from([lua.table_from(v) for v in c['values']])});prepared=Q.prepareTimestamp(curve,f)
   assert prepared['values'][len(c['values'])][1]==4294967295
   for t in (0,1,50,150,350,550,750,5999,350,0):
    value=Q.sampleTimestamp(prepared,t,f,crt.acosf,crt.sinf)
    left=Q.convert(lua.table_from(c['values'][0][1:]));right=Q.convert(lua.table_from(c['values'][1][1:]))
    expected=Q.interpolate(left,right,f(f(t)/f(4294967295)),f,crt.acosf,crt.sinf)
    assert struct.pack('<4f',*[value[i] for i in range(1,5)])==struct.pack('<4f',*[expected[i] for i in range(1,5)])
    checks+=1
(ROOT/'captured_assets/procedural/timestamp_quaternion_verification.json').write_text(json.dumps({'originalRatioPrefix':hex(start),'codeSha256':hashlib.sha256(raw).hexdigest(),'nativeRatioCases':count,'extractedTimestampCurveSamples':checks,'scope':'Ratio original instructions byte exact; traversal/XYZ conjugation statically translated. Slerp and basis separately verified. Full timestamp reader not executed.'},indent=2)+'\n')
print('PASS',count,'native ratios and',checks,'extracted timestamp rotation samples.')
