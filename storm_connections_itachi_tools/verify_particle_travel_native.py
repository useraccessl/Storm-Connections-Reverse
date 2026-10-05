"""Native travel-basis prefix comparison. Only arithmetic and three closed helpers."""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True);BASE=0x140000000
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
begin,end=0x141386e7a,0x141386f55
sizes={0x1411ab440:0x12,0x1411acbb0:0x72,0x1411ac0f0:0x5b}
code=bytearray(bytes.fromhex('57 53 48 81 ec c8 00 00 00 f3 0f 7f b4 24 80 00 00 00 48 8b f9 48 8b da'))
locations={};pending=[];hashes={}
allowed={'movss','movsd','movaps','xorps','xor','lea','ucomiss','jp','jne','jmp','call','mov','unpcklps','mulss','addss','subss','sqrtss','comiss','jbe','divss','ret'}
def copy(va,size,is_prefix=False):
 offset=len(code);locations[va]=offset;raw=p.get_data(va-BASE,size);code.extend(raw)
 hashes[hex(va)]=hashlib.sha256(raw).hexdigest()
 ins=list(md.disasm(raw,va));assert sum(i.size for i in ins)==size
 if not is_prefix:assert ins[-1].mnemonic=='ret'
 for i in ins:
  assert i.mnemonic in allowed,i
  pos=offset+i.address-va
  if i.mnemonic=='call':
   assert i.operands[0].type==CS_OP_IMM and i.operands[0].imm in sizes,i
   pending.append((pos,i,i.operands[0].imm))
  elif i.mnemonic.startswith('j'):assert va<=i.operands[0].imm<va+size,i
  for op in i.operands:
   if op.type==CS_OP_MEM and i.reg_name(op.mem.base)=='rip':
    assert i.mnemonic in ('movss','xorps','comiss'),i
    # Queue literals after the prefix epilogue; cannot insert into fallthrough.
    pending.append((pos,i,('literal',i.address+i.size+op.mem.disp)))
 return offset
copy(begin,end-begin,True)
# Write three source vectors as contiguous XYZ, preserving original native ABI.
for stack,dest in ((0x30,0),(0x60,12),(0x50,24)):
 code.extend(bytes.fromhex('f2 0f 10 44 24')+bytes([stack]))
 code.extend(bytes.fromhex('f2 0f 11 43')+bytes([dest]))
 code.extend(bytes.fromhex('f3 0f 10 44 24')+bytes([stack+8]))
 code.extend(bytes.fromhex('f3 0f 11 43')+bytes([dest+8]))
code.extend(bytes.fromhex('f3 0f 6f b4 24 80 00 00 00 48 81 c4 c8 00 00 00 5b 5f c3'))
for pos,i,target in pending:
 if isinstance(target,tuple):
  code.extend(b'\0'*((-len(code))%16));dest=len(code);code.extend(p.get_data(target[1]-BASE,16));field=i.disp_offset
 else:
  dest=locations.get(target)
  if dest is None:dest=copy(target,sizes[target])
  field=i.imm_offset
 struct.pack_into('<i',code,pos+field,dest-(pos+i.size))
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];k.VirtualProtect.restype=ctypes.c_int
k.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];k.VirtualFree.restype=ctypes.c_int
address=k.VirtualAlloc(None,len(code),0x3000,4);assert address
ctypes.memmove(address,bytes(code),len(code));old=ctypes.c_ulong();assert k.VirtualProtect(address,len(code),0x20,ctypes.byref(old))
original=ctypes.WINFUNCTYPE(None,ctypes.c_void_p,ctypes.c_void_p)(address)
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
l=LuaRuntime(unpack_returned_tuples=True);core=l.execute((ROOT/'particle_matrix_core.lua').read_text(encoding='utf-8-sig'))
tolerance=struct.unpack('<f',p.get_data(0x1386e5b+8+0x3e1b85,4))[0]
rng=random.Random(1386);cases=[[0,0,1],[0,0,-1],[1,0,0],[0,1,0]]+[[f(rng.uniform(-1,1)) for _ in range(3)] for _ in range(3000)]
try:
 for d in cases:
  d=list(map(f,d))
  state=ctypes.create_string_buffer(0x218);struct.pack_into('<3f',state,0x20c,*d)
  out=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*36+b'\x5A'*16)
  original(state,ctypes.addressof(out)+16)
  basis=core.travelBasis(l.table_from(d),tolerance,f)
  expected=struct.pack('<9f',*[basis[i] for i in (1,4,7,2,5,8,3,6,9)])
  assert out.raw[16:52]==expected,(d,out.raw[16:52].hex(),expected.hex())
  assert out.raw[:16]==b'\xA5'*16 and out.raw[52:68]==b'\x5A'*16
finally:k.VirtualFree(address,0,0x8000)
(ROOT/'captured_assets/procedural/particle_travel_basis_verification.json').write_text(json.dumps({'cases':len(cases),'prefix':[hex(begin),hex(end)],'codeSha256':hashes,'directionTolerance':tolerance,'scope':'Native original prefix including perpendicular special case, normalize and cross; three output vectors byte exact with guards. Caller zero-direction skip, direction persistence, full parent and host state are statically translated, not full native executed.'},indent=2)+'\n')
print('PASS',len(cases),'native travel bases; direction tolerance',tolerance)


