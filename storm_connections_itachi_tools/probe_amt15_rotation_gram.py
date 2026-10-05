import json,numpy as np,sys,ctypes,struct
from pathlib import Path
sys.path.insert(0,'vendor');from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True);q=l.execute(Path('quaternion_animation_core.lua').read_text());f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
crt=ctypes.CDLL('ucrtbase.dll')
for n in ('acosf','sinf'):getattr(crt,n).argtypes=[ctypes.c_float];getattr(crt,n).restype=ctypes.c_float
asset=json.loads(Path('captured_assets/procedural/auxiliary_resources.json').read_text())['animation'];cur=asset['entries'][0]['curves'][1]
cur=l.table_from({'format':cur['format'],'values':l.table_from([l.table_from(v) for v in cur['values']])});prepared=q.prepareCompressed(cur,f)
diag=np.diag([.2**2,.3**2,.2**2]);pred=[]
for t in range(801):
 quat=q.sampleCompressed(prepared,100,t,f,crt.acosf,crt.sinf);basis=q.basis(quat,f);r=np.array([basis[i] for i in range(1,10)]).reshape(3,3)
 for label,g in [('Rtranspose_D_R',r.T@diag@r),('R_D_Rtranspose',r@diag@r.T)]:pred.append((t,label,g/np.trace(g)))
for frame in (22082,22102):
 records=json.loads(Path(f'gpu_captures/itachi_amaterasu_frame{frame}.all_draws.json').read_text())
 def fields(r):return {k:v['values'] for k,v in r['constants'].get('ShaderStage.Vertex',{}).get('perMaterialBuffer',{}).get('fields',{}).items()}
 draws=[r for r in json.loads(Path(f'gpu_captures/itachi_amaterasu_frame{frame}.effect_coverage_reference.json').read_text()) if r['shaders'].get('ShaderStage.Vertex')=='19f002_vs']
 ref=next(r for r in records if r['targets'][0]==draws[0]['targets'][0] and 'g_matWorld' in fields(r));ff=fields(ref)
 vp=np.linalg.inv(np.array(ff['g_matWorld']).reshape(4,4))@np.array(ff['g_matWorldViewProj']).reshape(4,4)
 for d in draws:
  ff=fields(d);w=(np.array(ff['g_matWorldViewProj']).reshape(4,4)@np.linalg.inv(vp))[:3,:3];g=w@w.T;g/=np.trace(g)
  best=min((float(np.max(np.abs(g-p))),t,label) for t,label,p in pred)
  print(frame,d['event'],ff['g_uvOffset0'][1],best)
