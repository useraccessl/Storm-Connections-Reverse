"""Bounded native particle orientation math comparisons; no game execution."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);BASE=0x140000000
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
crt=ctypes.CDLL('ucrtbase.dll')
for n in ('sinf','cosf'):
 fn=getattr(crt,n);fn.argtypes=[ctypes.c_float];fn.restype=ctypes.c_float
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
allocations=[];hashes={}
# Only closed math helpers may be copied. No globals except relocated literals.
SIZES={0x1411b8760:0x154,0x1411acbb0:0x72,0x1412ccd80:0x41,
       0x1411e7e40:0x2f6,0x1411bd720:4}
# Last helper is a leaf returning this; verify its bytes before use.
assert p.get_data(0x11bd720,4)==b'\x48\x8b\xc1\xc3'
ALLOWED={'push','pop','sub','add','mov','movaps','movups','movss','movsd','mulss','divss','addss','subss','xorps','xor','and','cvttss2si','movd','cvtdq2ps','comiss','jbe','jmp','ret','call','sqrtss','lea'}
def build(entry):
 code=bytearray();locations={};pending=[]
 def append(va):
  if va in locations:return locations[va]
  offset=len(code);locations[va]=offset
  raw=p.get_data(va-BASE,SIZES[va]);hashes[hex(va)]=hashlib.sha256(raw).hexdigest()
  ins=list(md.disasm(raw,va));assert sum(i.size for i in ins)==len(raw) and ins[-1].mnemonic=='ret'
  code.extend(raw)
  for i in ins:
   assert i.mnemonic in ALLOWED,i
   local=offset+i.address-va
   if i.mnemonic=='call':
    target=i.operands[0].imm
    assert i.operands[0].type==CS_OP_IMM and target in (0x1414430a2,0x1414430a8,0x1411bd720),i
    pending.append((local,i,target))
   elif i.mnemonic.startswith('j'):
    assert va<=i.operands[0].imm<va+len(raw),i
   for op in i.operands:
    if op.type==CS_OP_MEM and i.reg_name(op.mem.base)=='rip':
     assert i.mnemonic in ('movss','xorps','addss','mulss','divss','subss','comiss'),i
     code.extend(b'\0'*((-len(code))%16));dest=len(code)
     code.extend(p.get_data(i.address+i.size+op.mem.disp-BASE,16))
     struct.pack_into('<i',code,local+i.disp_offset,dest-(local+i.size))
  return offset
 append(entry)
 for local,i,target in pending:
  if target==0x1411bd720:dest=append(target)
  else:
   dest=len(code);fn=crt.cosf if target==0x1414430a2 else crt.sinf
   code.extend(b'\x48\xb8'+struct.pack('<Q',ctypes.cast(fn,ctypes.c_void_p).value)+b'\xff\xe0')
  struct.pack_into('<i',code,local+i.imm_offset,dest-(local+i.size))
 address=k.VirtualAlloc(None,len(code),0x3000,4);assert address;allocations.append(address)
 ctypes.memmove(address,bytes(code),len(code));old=ctypes.c_ulong();assert k.VirtualProtect(address,len(code),0x20,ctypes.byref(old))
 return address
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
l=LuaRuntime(unpack_returned_tuples=True);core=l.execute((ROOT/'particle_matrix_core.lua').read_text(encoding='utf-8-sig'))
def buf(values):return ctypes.create_string_buffer(b'\xA5'*16+struct.pack('<%df'%len(values),*values)+b'\x5A'*16)
def ptr(b):return ctypes.addressof(b)+16
def check(b,values):
 assert b.raw[16:16+4*len(values)]==struct.pack('<%df'%len(values),*values),(b.raw[16:16+4*len(values)].hex(),values)
 assert b.raw[:16]==b'\xA5'*16 and b.raw[16+4*len(values):16+4*len(values)+16]==b'\x5A'*16
rng=random.Random(1386);counts={}
try:
 euler=ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p,ctypes.c_float,ctypes.c_float,ctypes.c_float)(build(0x1411b8760))
 angles=[[0,0,0],[0,0,3.141592741],[0,1.57079637,0]]+[[f(rng.uniform(-4,4)) for _ in range(3)] for _ in range(3000)]
 for a in angles:
  a=list(map(f,a));out=buf([0]*9);euler(ptr(out),*a)
  expected=core.euler(l.table_from(a),f,crt.sinf,crt.cosf);check(out,[expected[i] for i in range(1,10)])
 counts['euler']=len(angles)
 normal=ctypes.WINFUNCTYPE(ctypes.c_float,ctypes.c_void_p)(build(0x1411acbb0))
 vectors=[[0,0,0],[1e-40,0,0],[0,-1,0]]+[[f(rng.uniform(-100,100)) for _ in range(3)] for _ in range(3000)]
 for v in vectors:
  v=list(map(f,v));out=buf(v);length=normal(ptr(out));expected,el=core.normalize(l.table_from(v),f)
  check(out,[expected[i] for i in range(1,4)]);assert struct.pack('<f',length)==struct.pack('<f',el)
 counts['normalize']=len(vectors)
 wrap=ctypes.WINFUNCTYPE(ctypes.c_float,ctypes.c_float)(build(0x1412ccd80))
 angles=[f(rng.uniform(-1000,1000)) for _ in range(3000)]+list(map(f,[0,3.141592741,-3.141592741,6.283185482]))
 for a in angles:assert struct.pack('<f',wrap(a))==struct.pack('<f',core.wrapAngle(a,f)),a
 counts['angleWrap']=len(angles)
 multiply=ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p)(build(0x1411e7e40))
 for _ in range(3000):
  a=[f(rng.uniform(-50,50)) for _ in range(16)];b=[f(rng.uniform(-5,5)) for _ in range(9)]
  aa,bb,out=buf(a),buf(b),buf([0]*16);multiply(ptr(aa),ptr(out),ptr(bb));expected=core.rightBasis(l.table_from(a),l.table_from(b),f)
  check(out,[expected[i] for i in range(1,17)]);check(aa,a);check(bb,b)
 counts['rightBasis']=3000
finally:
 for address in allocations:k.VirtualFree(address,0,0x8000)
(ROOT/'captured_assets/procedural/particle_matrix_native_verification.json').write_text(json.dumps({'counts':counts,'codeSha256':hashes,'scope':'Original bounded Euler, normalization, angle quantization and 4x4-by-3x3 helpers, byte-exact outputs and guards. Euler CRT import targets mapped to UCRT cosf/sinf. Full parent builder and travel basis remain statically translated, not independently native verified.'},indent=2)+'\n')
print('PASS',counts)
