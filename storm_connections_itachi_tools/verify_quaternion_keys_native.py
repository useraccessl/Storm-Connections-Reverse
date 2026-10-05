"""Validate ANM compressed key preprocessing/conversion with original native helpers.
Sampler scheduling follows static original code; clock/host remains external.
"""
import ctypes,hashlib,json,math,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
kernel=ctypes.WinDLL('kernel32',use_last_error=True)
kernel.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];kernel.VirtualAlloc.restype=ctypes.c_void_p
kernel.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];kernel.VirtualProtect.restype=ctypes.c_int
kernel.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];kernel.VirtualFree.restype=ctypes.c_int
allocations=[]
def native(rva,size,conversion=False):
 raw=p.get_data(rva,size);ins=list(md.disasm(raw,0x140000000+rva));assert ins[-1].mnemonic=='ret'
 assert sum(i.size for i in ins)==size
 code=bytearray(raw)
 for i in ins:
  assert i.mnemonic in {'movups','movaps','movdqu','mov','mulps','pshufd','addps','sqrtps','movss','comiss','ja','divss','shufps','ret','xorps','sub','add','mulss','addss','subss'},i
  if i.mnemonic=='ja':assert 0x140000000+rva<=i.operands[0].imm<0x140000000+rva+size
  for op in i.operands:
   if op.type==CS_OP_MEM:
    assert i.reg_name(op.mem.base) in {'rcx','rdx','rip','rax','rsp'}
    if i.reg_name(op.mem.base)=='rip':
     target=i.address+i.size+op.mem.disp-0x140000000
     if conversion:
      assert target==0x97080f0
      # Actual static initializer 0x1400a4cf0 copies this literal to runtime mask.
      literal=p.get_data(0x1761170,16)
      assert struct.unpack('<4I',literal)==(0x80000000,0x80000000,0x80000000,0)
     else:literal=p.get_data(target,16)
     code+=b'\0'*((-len(code))%16);offset=len(code);code+=literal
     struct.pack_into('<i',code,i.address-(0x140000000+rva)+i.disp_offset,offset-(i.address-(0x140000000+rva)+i.size))
 address=kernel.VirtualAlloc(None,len(code),0x3000,4);assert address;allocations.append(address)
 ctypes.memmove(address,bytes(code),len(code));old=ctypes.c_ulong();assert kernel.VirtualProtect(address,len(code),0x20,ctypes.byref(old))
 return ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p,ctypes.c_void_p)(address),hashlib.sha256(raw).hexdigest()
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
lua=LuaRuntime(unpack_returned_tuples=True);core=lua.execute((ROOT/'quaternion_animation_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(1703);cases=[[rng.randint(-32768,32767) for _ in range(4)] for _ in range(4000)]
assets=json.loads((ROOT/'captured_assets/procedural/auxiliary_resources.json').read_text())
def collect(obj):
 if isinstance(obj,dict):
  if obj.get('format') in (17,27):cases.extend(obj['values'])
  for v in obj.values():collect(v)
 elif isinstance(obj,list):
  for v in obj:collect(v)
collect(assets)
cases += [[0]*4,[16384,0,0,0],[-16384,0,0,0],[1,1,0,0]]
try:
 norm,nh=native(0x11f4910,0x47);convert,ch=native(0x11f2000,0xe,True)
 basis,bh=native(0x11bb590,0x145)
 for raw in cases:
  decoded=[f(x/16384) for x in raw]
  source=ctypes.create_string_buffer(struct.pack('<4f',*decoded))
  guard=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*16+b'\x5A'*16,48)
  norm(source,ctypes.addressof(guard)+16)
  values=core.normalize(lua.table_from(decoded),f)
  expected=struct.pack('<4f',*[values[i] for i in range(1,5)])
  assert guard.raw[16:32]==expected
  assert guard.raw[:16]==b'\xA5'*16 and guard.raw[-16:]==b'\x5A'*16
  nativekeys=[math.trunc(f(v*16384)) for v in struct.unpack('<4f',guard.raw[16:32])]
  prepared=core.prepareCompressed(lua.table_from({'format':17,'values':lua.table_from([lua.table_from(raw)])}),f)
  assert nativekeys==[prepared["values"][1][i] for i in range(1,5)]
  before=guard.raw[16:32];convert(ctypes.addressof(guard)+16,None)
  luaout=core.convert(values)
  assert guard.raw[16:32]==struct.pack('<4f',*[luaout[i] for i in range(1,5)])
  matrix=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*36+b'\x5A'*16,68)
  basis(ctypes.addressof(matrix)+16,ctypes.addressof(guard)+16)
  expected=core.basis(luaout,f)
  assert matrix.raw[16:52]==struct.pack('<9f',*[expected[i] for i in range(1,10)])
  assert matrix.raw[:16]==b'\xA5'*16 and matrix.raw[-16:]==b'\x5A'*16
  assert guard.raw[:16]==b'\xA5'*16 and guard.raw[-16:]==b'\x5A'*16
finally:
 for a in allocations:kernel.VirtualFree(a,0,0x8000)
report={'cases':len(cases),'normalization':'0x1411f4910','conversion':'0x1411f2000','maskInitializer':'0x1400a4cf0','basis':'0x1411bb590',
 'originalCodeSha256':{'normalization':nh,'conversion':ch,'basis':bh},
 'verification':'Byte exact native helper outputs; prepared keys compared using native normalization output and float32 truncation.',
 'limitations':'Complete sampler/controller not executed. Scheduling and recompression are static translations; host time and GMod math parity still require validation.'}
(ROOT/'captured_assets/procedural/quaternion_keys_native_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS:',len(cases),'compressed-key normalization/conversion/basis cases, including extracted asset keys.')

