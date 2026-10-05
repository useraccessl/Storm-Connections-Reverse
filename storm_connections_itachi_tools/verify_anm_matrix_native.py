"""Verify packed original matrix arithmetic with bounded native instructions."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
allocations=[]
def native(rva,size):
 raw=p.get_data(rva,size);ins=list(md.disasm(raw,0x140000000+rva))
 assert sum(i.size for i in ins)==size and ins[-1].mnemonic=='ret'
 for i in ins:
  assert i.mnemonic in {'sub','add','movdqu','mov','pshufd','movaps','movups','mulps','addps','movss','mulss','ret'},i
  for o in i.operands:
   if o.type==CS_OP_MEM:assert i.reg_name(o.mem.base) in ('rcx','rdx','r8','rsp') and 0<=o.mem.disp<=0x38
 address=k.VirtualAlloc(None,len(raw),0x3000,4);assert address;allocations.append(address)
 ctypes.memmove(address,raw,len(raw));old=ctypes.c_ulong();assert k.VirtualProtect(address,len(raw),0x20,ctypes.byref(old))
 return ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p)(address),hashlib.sha256(raw).hexdigest()
def buffer(values):return ctypes.create_string_buffer(b'\xA5'*16+struct.pack('<%df'%len(values),*values)+b'\x5A'*16)
def pointer(buf):return ctypes.addressof(buf)+16
def guards(buf,n):assert buf.raw[:16]==b'\xA5'*16 and buf.raw[16+n:16+n+16]==b'\x5A'*16
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
lua=LuaRuntime(unpack_returned_tuples=True);core=lua.execute((ROOT/'anm_matrix_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(281e90);count=3000
try:
 mult,mh=native(0x11e7c00,0x13f);scale,sh=native(0x1281e90,0xaf)
 for _ in range(count):
  a=[f(rng.uniform(-100,100)) for _ in range(16)];b=[f(rng.uniform(-100,100)) for _ in range(16)];s=[f(rng.uniform(-5,5)) for _ in range(3)]
  aa,bb,cc=buffer(a),buffer(b),buffer([0]*16)
  mult(pointer(aa),pointer(cc),pointer(bb))
  expected=core.multiply(lua.table_from(a),lua.table_from(b),f)
  assert cc.raw[16:80]==struct.pack('<16f',*[expected[i] for i in range(1,17)])
  assert aa.raw[16:80]==struct.pack('<16f',*a) and bb.raw[16:80]==struct.pack('<16f',*b)
  ss=buffer(s);scale(pointer(aa),pointer(ss),None)
  expected=core.scaleColumns(lua.table_from(a),lua.table_from(s),f)
  assert aa.raw[16:80]==struct.pack('<16f',*[expected[i] for i in range(1,17)])
  for buf,n in ((aa,64),(bb,64),(cc,64),(ss,12)):guards(buf,n)
finally:
 for address in allocations:k.VirtualFree(address,0,0x8000)
(ROOT/'captured_assets/procedural/anm_matrix_native_verification.json').write_text(json.dumps({'casesPerFunction':count,'matrixMultiply':'0x1411e7c00','columnScale':'0x141281e90','codeSha256':{'multiply':mh,'scale':sh},'scope':'Byte-exact 16 float outputs; guards and input preservation. Model parent transform, controller composition and Source layout remain pending.'},indent=2)+'\n')
print('PASS',count,'matrix products and',count,'column scales, byte exact.')
