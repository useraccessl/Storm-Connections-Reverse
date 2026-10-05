"""Compile SM3 and build a single-combo Valve v6 shader package.
Package structure is checked against locally working shaders. No game injection.
"""
import ctypes,lzma,struct,zlib,json,argparse,hashlib
from pathlib import Path
ROOT=Path(__file__).resolve().parent
DLL=Path(r'C:\Windows\System32\d3dcompiler_47.dll')
def blob_bytes(blob):
 v=ctypes.cast(blob,ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
 ptr=ctypes.WINFUNCTYPE(ctypes.c_void_p,ctypes.c_void_p)(v[3])(blob)
 size=ctypes.WINFUNCTYPE(ctypes.c_size_t,ctypes.c_void_p)(v[4])(blob)
 out=ctypes.string_at(ptr,size);ctypes.WINFUNCTYPE(ctypes.c_ulong,ctypes.c_void_p)(v[2])(blob);return out
def compile(source,target):
 dll=ctypes.WinDLL(str(DLL));fn=dll.D3DCompile
 fn.argtypes=[ctypes.c_void_p,ctypes.c_size_t,ctypes.c_char_p,ctypes.c_void_p,ctypes.c_void_p,ctypes.c_char_p,ctypes.c_char_p,ctypes.c_uint,ctypes.c_uint,ctypes.POINTER(ctypes.c_void_p),ctypes.POINTER(ctypes.c_void_p)];fn.restype=ctypes.c_long
 raw=source.read_bytes();buf=ctypes.create_string_buffer(raw);out=ctypes.c_void_p();errors=ctypes.c_void_p()
 hr=fn(buf,len(raw),str(source).encode(),None,None,b'main',target.encode(),1<<15,0,ctypes.byref(out),ctypes.byref(errors))
 if errors.value:print(blob_bytes(errors).decode(errors='replace'))
 if hr<0:raise RuntimeError(f'{source.name}: compile failed {hr:x}')
 return blob_bytes(out)
def unpack(raw):
 version,total,dynamic,flags,centroid,statics,crc=struct.unpack_from('<7I',raw)
 assert (version,total,dynamic,flags,centroid,statics)==(6,1,1,0,0,2)
 combo,start,sentinel,end,aliases=struct.unpack_from('<5I',raw,28)
 assert (combo,start,sentinel,end,aliases)==(0,48,0xffffffff,len(raw),0)
 block=struct.unpack_from('<I',raw,48)[0];n=block&0x3fffffff;assert block>>30==1 and raw[52:56]==b'LZMA'
 size,packed=struct.unpack_from('<2I',raw,56);assert n==17+packed
 prop=raw[64];lc=prop%9;prop//=9;lp=prop%5;pb=prop//5
 decoder=lzma.LZMADecompressor(format=lzma.FORMAT_RAW,filters=[{'id':lzma.FILTER_LZMA1,'dict_size':struct.unpack_from('<I',raw,65)[0],'lc':lc,'lp':lp,'pb':pb}])
 payload=decoder.decompress(raw[69:69+packed],max_length=size)
 assert len(payload)==size and struct.unpack_from('<I',raw,52+n)[0]==0xffffffff and 56+n==len(raw)
 index,length=struct.unpack_from('<2I',payload);assert index==0 and length==len(payload)-8
 return payload[8:]
def package(bytecode,source):
 payload=struct.pack('<2I',0,len(bytecode))+bytecode;dictionary=1<<20
 packed=lzma.compress(payload,format=lzma.FORMAT_RAW,filters=[{'id':lzma.FILTER_LZMA1,'dict_size':dictionary,'lc':3,'lp':0,'pb':2}])
 valve=b'LZMA'+struct.pack('<2I',len(payload),len(packed))+bytes([93])+struct.pack('<I',dictionary)+packed
 end=52+len(valve)+4
 raw=struct.pack('<7I',6,1,1,0,0,2,zlib.crc32(source))+struct.pack('<5I',0,48,0xffffffff,end,0)+struct.pack('<I',0x40000000|len(valve))+valve+struct.pack('<I',0xffffffff)
 assert unpack(raw)==bytecode;return raw
if __name__=='__main__':
 ap=argparse.ArgumentParser();ap.add_argument('sources',nargs='+',type=Path);args=ap.parse_args()
 # Validate structure against an already deployed working package.
 unpack((ROOT/'../storm_amaterasu_lab/shaders/fxc/amt_motion_r6_ps30.vcs').read_bytes())
 manifest=[]
 for source in args.sources:
  target='vs_3_0' if source.stem.endswith('_vs30') else 'ps_3_0';code=compile(source,target)
  expected=0xfffe0300 if target.startswith('vs') else 0xffff0300
  assert struct.unpack_from('<I',code)[0]==expected and struct.unpack_from('<I',code,len(code)-4)[0]==0xffff
  source.with_suffix('.bin').write_bytes(code)
  raw=package(code,source.read_bytes());dest=ROOT/'../storm_amaterasu_lab/shaders/fxc'/(source.stem+'.vcs');dest.write_bytes(raw)
  manifest.append({'source':str(source),'target':target,'codeBytes':len(code),'packageBytes':len(raw),'destination':str(dest),'sha256':hashlib.sha256(raw).hexdigest()});print('Compiled and package round-tripped',source.name,len(code),'bytes')
 (ROOT/'captured_assets/procedural/r11_shader_build.json').write_text(json.dumps({'compiler':str(DLL),'shaders':manifest,'scope':'Compilation and package structure/bytecode integrity; live GPU and original pixel equivalence pending.'},indent=2)+'\n')
