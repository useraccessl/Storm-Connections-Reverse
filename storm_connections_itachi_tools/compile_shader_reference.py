"""Compile extracted D3D11 reference shaders using the local compiler DLL.
This does not compile or validate a Source port.
"""
import ctypes,sys
from pathlib import Path
from disassemble_dxbc import disassemble
root=Path(__file__).resolve().parent
source=root/'shaders/original_amt15_reference.hlsl'
dllpath=Path(r'C:\Windows\System32\d3dcompiler_47.dll')
dll=ctypes.WinDLL(str(dllpath));fn=dll.D3DCompile
fn.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p,ctypes.c_uint,ctypes.c_uint,ctypes.POINTER(ctypes.c_void_p),ctypes.POINTER(ctypes.c_void_p)]
fn.restype=ctypes.c_long

def blob_bytes(blob):
 v=ctypes.cast(blob,ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
 ptr=ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p)(v[3])(blob)
 size=ctypes.WINFUNCTYPE(ctypes.c_size_t,ctypes.c_void_p)(v[4])(blob)
 result=ctypes.string_at(ptr,size)
 ctypes.WINFUNCTYPE(ctypes.c_ulong,ctypes.c_void_p)(v[2])(blob)
 return result
raw=source.read_bytes();buf=ctypes.create_string_buffer(raw)
for entry,target in [('VS','vs_4_0'),('PS','ps_4_0')]:
 output=ctypes.c_void_p();errors=ctypes.c_void_p()
 hr=fn(buf,len(raw),str(source).encode(),None,None,entry.encode(),target.encode(),1<<15,0,ctypes.byref(output),ctypes.byref(errors))
 if errors.value:print(blob_bytes(errors).decode(errors='replace'))
 if hr<0:raise RuntimeError(f'{entry} compile failed {hr:x}')
 code=blob_bytes(output);dest=root/'shaders'/('reference_amt15_'+target+'.dxbc');dest.write_bytes(code)
 dest.with_suffix('.asm').write_text(disassemble(code,dllpath))
 print('Compiled',entry,target,len(code),'bytes')
print('LIMIT: valid D3D11 shader reference only; original equivalence and Source GPU execution not confirmed.')
