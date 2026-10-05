"""Byte exact isolated oracle for original ANM clock, with bounded validated code."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);start=0x1412a3c30;raw=p.get_data(start-0x140000000,0x60)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True;ins=list(md.disasm(raw,start))
assert sum(i.size for i in ins)==len(raw) and ins[-1].mnemonic=='ret'
for i in ins:
 assert i.mnemonic in {'mov','test','jle','cmp','je','cdq','idiv','ret','xor','sub','jns','neg'},i
 if i.mnemonic.startswith('j'):assert start<=i.operands[0].imm<start+len(raw)
 for o in i.operands:
  if o.type==CS_OP_MEM:assert i.reg_name(o.mem.base) in ('rcx','r8') and o.mem.disp in (0x38,0x3c,0x40)
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
address=k.VirtualAlloc(None,len(raw),0x3000,4);assert address
ctypes.memmove(address,raw,len(raw));old=ctypes.c_ulong();assert k.VirtualProtect(address,len(raw),0x20,ctypes.byref(old))
fn=ctypes.WINFUNCTYPE(ctypes.c_int32,ctypes.c_void_p,ctypes.c_int32)(address)
lua=LuaRuntime(unpack_returned_tuples=True);core=lua.execute((ROOT/'anm_clock_core.lua').read_text(encoding='utf-8-sig'))
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
rng=random.Random(20261002);cases=[]
for duration in (0,1,50,100,800,6000,2147483647):
 for ticks in (-1600,-800,-1,0,1,duration,duration+1 if duration<2147483647 else duration):
  for delta in (-100,0,50):
   for flags in (0,1,2,3):
    if flags%2 and duration==0 and ticks<0 and delta<=0:continue
    cases.append((duration,ticks,delta,flags))
for _ in range(10000):cases.append((rng.randint(1,100000),rng.randint(-1000000,1000000),rng.randint(-1000,1000),rng.randint(0,65535)))
try:
 for duration,ticks,delta,flags in cases:
  data=bytearray(b'\xA5'*0x60)
  struct.pack_into('<H',data,0x38,flags);struct.pack_into('<ii',data,0x3c,ticks,duration)
  mem=ctypes.create_string_buffer(bytes(data),len(data));result=fn(mem,delta)
  expected=core.new(duration,flags,ticks,1);luaresult=core.resolve(expected,delta)
  struct.pack_into('<i',data,0x3c,expected.ticks)
  assert result==luaresult and mem.raw==bytes(data),(duration,ticks,delta,flags,result,luaresult)
 # The update prefix was statically transcribed, not executed as a whole.
 timeline=core.new(800,1,0,1)
 sequence=[]
 for _ in range(18):
  result,step=core.advance(timeline,50,f);sequence.append(timeline.ticks)
 assert sequence==[50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,50,100]
finally:k.VirtualFree(address,0,0x8000)
report={'cases':len(cases),'function':hex(start),'codeSha256':hashlib.sha256(raw).hexdigest(),'nativeClock':'Byte-exact clock and return value; all other bytes unchanged','effectTimeline50Ticks':sequence,'limitations':'Effect update float32 prefix statically translated; activation, caller cadence and parent transforms remain unverified.'}
(ROOT/'captured_assets/procedural/anm_clock_native_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS',len(cases),'ANM clock cases; exact endpoint and reverse-loop semantics.')
