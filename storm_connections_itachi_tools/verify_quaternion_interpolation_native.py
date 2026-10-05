"""Validate original slerp arithmetic with relocated constants/math-only calls.
Runs in an isolated test process. No game hooks, cookie bypass or injection.
"""
import ctypes,hashlib,json,math,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);base=0x1411f4e90
raw=p.get_data(base-0x140000000,0x179)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
instructions=list(md.disasm(raw,base));assert instructions[-1].mnemonic=='ret'
assert sum(i.size for i in instructions)==len(raw)
crt=ctypes.CDLL('ucrtbase.dll')
for name in ('acosf','sinf'):
 fn=getattr(crt,name);fn.argtypes=[ctypes.c_float];fn.restype=ctypes.c_float
mathcalls={0x1411db5c0:crt.acosf,0x1411dbd00:crt.sinf}
code=bytearray(raw)
for ins in instructions:
 offset=ins.address-base
 assert ins.mnemonic not in ('syscall','sysenter','int','int3'),ins
 if ins.mnemonic=='call':
  assert ins.operands[0].type==CS_OP_IMM and ins.operands[0].imm in mathcalls
  target=len(code)
  # math-only absolute tail thunk; RAX is caller-clobbered in native ABI.
  code+=b'\x48\xb8'+struct.pack('<Q',ctypes.cast(mathcalls[ins.operands[0].imm],ctypes.c_void_p).value)+b'\xff\xe0'
  struct.pack_into('<i',code,offset+ins.imm_offset,target-(offset+ins.size))
 elif ins.mnemonic in ('jbe','jb','ja'):
  assert base<=ins.operands[0].imm<base+len(raw)
 for op in ins.operands:
  if op.type==CS_OP_MEM and ins.reg_name(op.mem.base)=='rip':
   assert ins.mnemonic in ('movss','xorps')
   literal=p.get_data(ins.address+ins.size+op.mem.disp-0x140000000,16)
   code+=b'\0'*((-len(code))%16)
   target=len(code);code+=literal
   struct.pack_into('<i',code,offset+ins.disp_offset,target-(offset+ins.size))
kernel=ctypes.WinDLL('kernel32',use_last_error=True)
kernel.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];kernel.VirtualAlloc.restype=ctypes.c_void_p
kernel.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];kernel.VirtualProtect.restype=ctypes.c_int
kernel.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];kernel.VirtualFree.restype=ctypes.c_int
address=kernel.VirtualAlloc(None,len(code),0x3000,4);assert address
ctypes.memmove(address,bytes(code),len(code));old=ctypes.c_ulong()
assert kernel.VirtualProtect(address,len(code),0x20,ctypes.byref(old))
original=ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_float)(address)
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
lua=LuaRuntime(unpack_returned_tuples=True);core=lua.execute((ROOT/'quaternion_animation_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(1702);cases=[]
for _ in range(3000):
 a=[rng.uniform(-1,1) for _ in range(4)];b=[rng.uniform(-1,1) for _ in range(4)]
 a=[f(v/math.sqrt(sum(x*x for x in a))) for v in a]
 b=[f(v/math.sqrt(sum(x*x for x in b))) for v in b]
 cases.append((a,b,f(rng.random())))
# Near parallel, negative dot, zero-length and exact endpoints.
for dot in [0,.969,.97,.971,.999,1,-.969,-.97,-.971,-1]:
 a=[0,0,0,1];b=[f(math.sqrt(max(0,1-dot*dot))),0,0,f(dot)]
 for t in [0,.125,.5,.875,1]:cases.append((a,b,f(t)))
cases.append(([0]*4,[0]*4,.5))
try:
 for a,b,t in cases:
  aa=ctypes.create_string_buffer(struct.pack('<4f',*a));bb=ctypes.create_string_buffer(struct.pack('<4f',*b))
  output=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*16+b'\x5A'*16,48)
  original(aa,ctypes.addressof(output)+16,bb,t)
  values=core.interpolate(lua.table_from(a),lua.table_from(b),t,f,crt.acosf,crt.sinf)
  expected=struct.pack('<4f',*[values[i] for i in range(1,5)])
  assert output.raw[16:32]==expected,(a,b,t,output.raw[16:32].hex(),expected.hex())
  assert output.raw[:16]==b'\xA5'*16 and output.raw[-16:]==b'\x5A'*16
finally:kernel.VirtualFree(address,0,0x8000)
report={'function':hex(base),'cases':len(cases),'originalCodeSha256':hashlib.sha256(raw).hexdigest(),
 'verification':'Byte exact four float32 values against original instructions. Constants relocated; original math-only call targets mapped to UCRT acosf/sinf.',
 'limitations':'Native quaternion input conversion, caller time and compressed curve scheduler not verified. GMod math library parity is not established.'}
(ROOT/'captured_assets/procedural/quaternion_interpolation_native_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS:',len(cases),'native quaternion interpolation comparisons.')
