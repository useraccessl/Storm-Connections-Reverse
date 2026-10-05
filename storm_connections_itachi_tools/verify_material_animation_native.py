"""Validate Lua parameter writes against the original bounded native leaf.
The copied function has no calls, RIP references, stack writes or system calls.
Runs in this isolated Python test process, never inside either game.
"""
import ctypes,hashlib,json,random,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from disasm_exe import EXE
import pefile
from capstone import Cs,CS_ARCH_X86,CS_MODE_64,CS_OP_MEM
from lupa import LuaRuntime
p=pefile.PE(str(EXE),fast_load=True);code=p.get_data(0x12f6380,0x174)
md=Cs(CS_ARCH_X86,CS_MODE_64);md.detail=True
instructions=list(md.disasm(code,0x1412f6380))
assert instructions[-1].mnemonic=='ret'
assert sum(i.size for i in instructions)==len(code)
for i in instructions:
 assert i.mnemonic in {'mov','add','test','je','jns','bt','jae','ret'},i
 for o in i.operands:
  if o.type==CS_OP_MEM:assert i.reg_name(o.mem.base) in ('rcx','rdx'),i
 if i.mnemonic in ('je','jns','jae'):assert 0x1412f6380<=i.operands[0].imm<0x1412f64f4
kernel=ctypes.WinDLL('kernel32',use_last_error=True)
kernel.VirtualAlloc.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong];kernel.VirtualAlloc.restype=ctypes.c_void_p
kernel.VirtualProtect.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.POINTER(ctypes.c_ulong)];kernel.VirtualProtect.restype=ctypes.c_int
kernel.VirtualFree.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong];kernel.VirtualFree.restype=ctypes.c_int
address=kernel.VirtualAlloc(None,len(code),0x3000,4)
if not address:raise ctypes.WinError(ctypes.get_last_error())
ctypes.memmove(address,code,len(code));old=ctypes.c_ulong()
if not kernel.VirtualProtect(address,len(code),0x20,ctypes.byref(old)):raise ctypes.WinError(ctypes.get_last_error())
original=ctypes.WINFUNCTYPE(None,ctypes.c_void_p,ctypes.c_void_p)(address)
l=LuaRuntime(unpack_returned_tuples=True);core=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/material_animation_core.lua').read_text(encoding='utf-8-sig'))
rand=random.Random(1101)
masks=[0,(1<<23)-1,0xffffffff]+[1<<i for i in range(23)]+[rand.getrandbits(32) for _ in range(2000)]
try:
 for mask in masks:
  initial=[struct.unpack('<f',struct.pack('<f',rand.uniform(-10,10)))[0] for _ in range(36)]
  values=[struct.unpack('<f',struct.pack('<f',rand.uniform(-10,10)))[0] for _ in range(sum(bool(mask&(1<<i)) for i in range(23)))]
  payload=struct.pack('<I',mask)+struct.pack('<'+'f'*len(values),*values)
  # Guards surround the 0x90-byte instance; all writes must stay inside it.
  guarded=ctypes.create_string_buffer(b'\xA5'*16+struct.pack('<36f',*initial)+b'\x5A'*16,176)
  nativepayload=ctypes.create_string_buffer(payload)
  original(ctypes.addressof(guarded)+16,nativepayload)
  assert guarded.raw[:16]==b'\xA5'*16 and guarded.raw[-16:]==b'\x5A'*16
  actual=struct.unpack('<36f',guarded.raw[16:160])
  instance=l.table_from({i*4:v for i,v in enumerate(initial)})
  consumed=core.applyPacked(instance,l.table_from([mask]+values))
  assert consumed==1+len(values)
  for i,value in enumerate(actual):assert instance[i*4]==value,(hex(mask),hex(i*4),instance[i*4],value)
finally:kernel.VirtualFree(address,0,0x8000)
report={'function':'0x1412f6380','codeSha256':hashlib.sha256(code).hexdigest(),'cases':len(masks),
 'verification':'Original executable leaf executed in isolated test process; full instance and guards compared to Lua.',
 'offsets':[core.offsets[i] for i in range(1,24)],
 'limitations':'Validates packed writes only. Animation sampling, active caller, clocks and final GPU rendering remain unverified.'}
(ROOT/'captured_assets/procedural/material_animation_native_verification.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS:',len(masks),'packed masks against ORIGINAL native function; 23 channels, preserved fields and memory guards.')
print(report['limitations'])
