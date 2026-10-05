"""Compare Lua ANM scalar sampling to bounded original executable leaves.
One RIP-relative read of 1.0 is relocated to a private literal; instructions
and arithmetic remain original. No calls, stack writes or game execution.
"""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM,CS_OP_IMM
from lupa import LuaRuntime
from disasm_exe import EXE
p=pefile.PE(str(EXE),fast_load=True)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
kernel=ctypes.WinDLL('kernel32',use_last_error=True)
kernel.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];kernel.VirtualAlloc.restype=ctypes.c_void_p
kernel.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];kernel.VirtualProtect.restype=ctypes.c_int
kernel.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];kernel.VirtualFree.restype=ctypes.c_int
allocations=[]
def leaf(rva,size):
 raw=p.get_data(rva,size);ins=list(md.disasm(raw,0x140000000+rva))
 assert sum(i.size for i in ins)==size and ins[-1].mnemonic=='ret'
 patched=bytearray(raw);literals=[]
 for i in ins:
  assert i.mnemonic in {'mov','xor','div','test','jne','movss','ret','xorps','cvtsi2ss','lea','divss','subss','movaps','mulss','addss','cmp','sub','add','ja','jbe','jmp','nop'},i
  for o in i.operands:
   if o.type==CS_OP_MEM:
    base=i.reg_name(o.mem.base)
    assert base in {'rax','rcx','rdx','r9','r10','r11','rip'},i
    if base=='rip':
     assert i.mnemonic=='movss' and i.operands[0].type!=CS_OP_MEM
     literal=p.get_data(i.address+i.size+o.mem.disp-0x140000000,4)
     assert struct.unpack('<f',literal)[0]==1
     offset=i.address-(0x140000000+rva)
     struct.pack_into('<i',patched,offset+i.disp_offset,size+len(literals)*4-(offset+i.size))
     literals.append(literal)
  if i.mnemonic in ('jne','ja','jbe','jmp'):assert 0x140000000+rva<=i.operands[0].imm<0x140000000+rva+size
 code=bytes(patched)+b''.join(literals)
 address=kernel.VirtualAlloc(None,len(code),0x3000,4)
 if not address:raise ctypes.WinError(ctypes.get_last_error())
 allocations.append(address);ctypes.memmove(address,code,len(code));old=ctypes.c_ulong()
 if not kernel.VirtualProtect(address,len(code),0x20,ctypes.byref(old)):raise ctypes.WinError(ctypes.get_last_error())
 return ctypes.WINFUNCTYPE(None,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_uint32)(address),hashlib.sha256(raw).hexdigest()
f32=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
lua=LuaRuntime(unpack_returned_tuples=True)
core=lua.execute((ROOT/'scalar_animation_core.lua').read_text(encoding='utf-8-sig'))
rng=random.Random(2202);counts={};hashes={}
try:
 functions={11:leaf(0x13677a0,9),'linear':leaf(0x13677b0,0x66),'hold':leaf(0x1367820,0x18)}
 curves=[(100,[i*.125 for i in range(9)]),(100,[.125]*9)]
 curves += [(rng.randint(1,1000),[f32(rng.uniform(-1000,1000)) for _ in range(rng.randint(2,30))]) for _ in range(80)]
 for mode,(native,digest) in functions.items():
  cases=0;hashes[str(mode)]=digest
  for step,values in curves:
   format=11 if mode==11 else 22
   raw=struct.pack('<f',values[0]) if format==11 else struct.pack('<I',step)+struct.pack('<'+'f'*len(values),*values)
   keys=ctypes.create_string_buffer(raw);instance=ctypes.create_string_buffer(0x28)
   struct.pack_into('<Q',instance,0x18,ctypes.addressof(keys))
   curve=lua.table_from({'format':format,'values':lua.table_from([lua.table_from([v]) for v in values])})
   ticks=set([0,(len(values)-1)*step]+[rng.randrange((len(values)-1)*step+1) for _ in range(150)])
   for tick in sorted(ticks):
    guard=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*4+b'\x5A'*16,36)
    native(instance,ctypes.addressof(guard)+16,tick)
    actual=guard.raw[16:20]
    expected=struct.pack('<f',core.sample(curve,tick,step,mode=='hold',f32))
    assert actual==expected,(mode,tick,step,actual.hex(),expected.hex())
    assert guard.raw[:16]==b'\xA5'*16 and guard.raw[-16:]==b'\x5A'*16
    cases+=1
  counts[str(mode)]=cases
 native,digest=leaf(0x1353c80,0x72);hashes['timestamp12']=digest
 cases=0
 for step,values in curves:
  times=[0]
  for _ in values[1:]:times.append(times[-1]+rng.randint(1,1000))
  keys=ctypes.create_string_buffer(b''.join(struct.pack('<If',t,v) for t,v in zip(times,values)))
  instance=ctypes.create_string_buffer(0x28)
  struct.pack_into('<Q',instance,0x20,ctypes.addressof(keys))
  curve=lua.table_from({'format':12,'values':lua.table_from([lua.table_from([t,v]) for t,v in zip(times,values)])})
  state=lua.table_from({'index':1})
  ticks=list(set(times[:-1]+[rng.randrange(times[-1]) for _ in range(150)]))
  rng.shuffle(ticks) # Native cached pointer must seek both forwards and backwards.
  for tick in ticks:
   guard=ctypes.create_string_buffer(b'\xA5'*16+b'\0'*4+b'\x5A'*16,36)
   native(instance,ctypes.addressof(guard)+16,tick)
   expected=struct.pack('<f',core.sample(curve,tick,step,False,f32,state))
   assert guard.raw[16:20]==expected,(tick,guard.raw[16:20].hex(),expected.hex())
   pointer=struct.unpack_from('<Q',instance,0x20)[0]
   assert pointer==ctypes.addressof(keys)+(state.index-1)*8
   assert guard.raw[:16]==b'\xA5'*16 and guard.raw[-16:]==b'\x5A'*16
   cases+=1
 counts['timestamp12']=cases
finally:
 for address in allocations:kernel.VirtualFree(address,0,0x8000)
report={'functions':{'constant11':'0x1413677a0','linear22':'0x1413677b0','hold22':'0x141367820','timestamp12':'0x141353c80'},'cases':counts,'originalCodeSha256':hashes,
 'verification':'Byte exact float32 output against original bounded native leaves. Only RIP literal relocated; guarded output.',
 'limitations':'Caller clock, choice of hold mode in active effect, coordinate/quaternion samplers and final rendering remain unverified.'}
(ROOT/'captured_assets/procedural/scalar_animation_native_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS native scalar samplers:',counts)


