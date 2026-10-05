"""Independent amt15 rotation/UV audit; inferred ages are diagnostics, not host inputs."""
import json,numpy as np,sys,ctypes,struct
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'));from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True);q=l.execute((ROOT/'quaternion_animation_core.lua').read_text(encoding='utf-8-sig'));f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
crt=ctypes.CDLL('ucrtbase.dll')
for n in ('acosf','sinf'):getattr(crt,n).argtypes=[ctypes.c_float];getattr(crt,n).restype=ctypes.c_float
asset=json.loads((ROOT/'captured_assets/procedural/auxiliary_resources.json').read_text())['animation'];curve=asset['entries'][0]['curves'][1]
packed=l.table_from({'format':curve['format'],'values':l.table_from([l.table_from(v) for v in curve['values']])});prepared=q.prepareCompressed(packed,f)
scale=[.2,.3,.2];D=np.diag(np.square(scale));pred=[]
uv=next(c for c in asset['entries'][1]['curves'] if c['index']==1)['values']
uv=[v[0] for v in uv]
for t in range(801):
 quat=q.sampleCompressed(prepared,100,t,f,crt.acosf,crt.sinf);basis=q.basis(quat,f);r=np.array([basis[i] for i in range(1,10)]).reshape(3,3)
 key=t//100;fraction=(t%100)/100
 held=uv[key];linear=held if fraction==0 else held+(uv[key+1]-held)*fraction
 for label,g in [('Rtranspose_D_R',r.T@D@r),('R_D_Rtranspose',r@D@r.T)]:pred.append((t,label,g/np.trace(g),held,linear))
def fields(r):return {k:v['values'] for k,v in r['constants'].get('ShaderStage.Vertex',{}).get('perMaterialBuffer',{}).get('fields',{}).items()}
report={'method':'Camera removed using independently captured world and WVP from a different draw. Compare normalized world row Gram to file rotation and emitter anisotropic size. No position fitting.','records':[],'limitations':'Age selected by invariant search, not independently recovered activation. Parent identity/RNG/translation and final pixels remain unverified. Gram discards parent rotation and cannot prove all orientation axes.'}
for frame in (22082,22102):
 records=json.loads((ROOT/f'gpu_captures/itachi_amaterasu_frame{frame}.all_draws.json').read_text())
 draws=[r for r in json.loads((ROOT/f'gpu_captures/itachi_amaterasu_frame{frame}.effect_coverage_reference.json').read_text()) if r['shaders'].get('ShaderStage.Vertex')=='19f002_vs']
 ref=next(r for r in records if r['targets'][0]==draws[0]['targets'][0] and 'g_matWorld' in fields(r));ff=fields(ref)
 vp=np.linalg.inv(np.array(ff['g_matWorld']).reshape(4,4))@np.array(ff['g_matWorldViewProj']).reshape(4,4)
 for draw in draws:
  ff=fields(draw);world=np.array(ff['g_matWorldViewProj']).reshape(4,4)@np.linalg.inv(vp);w=world[:3,:3];g=w@w.T;g/=np.trace(g)
  row={'capture':frame,'event':draw['event'],'cameraReferenceEvent':ref['event'],'uv0y':ff['g_uvOffset0'][1],'worldMatrixDiagnostic':world.tolist(),'singularValues':np.linalg.svd(w,compute_uv=False).tolist()}
  for mode,uvindex in [('hold',3),('linear',4)]:
   compatible=[p for p in pred if abs(p[uvindex]-row['uv0y'])<1e-7]
   error,t,label=min((float(np.max(np.abs(g-p[2]))),p[0],p[1]) for p in compatible)
   row[mode]={'maxNormalizedGramError':error,'compatibleTicks':t,'basisConvention':label}
  report['records'].append(row)
report['holdCompatible']=sum(r['hold']['maxNormalizedGramError']<2e-5 for r in report['records'])
report['linearCompatible']=sum(r['linear']['maxNormalizedGramError']<2e-5 for r in report['records'])
(ROOT/'captured_assets/procedural/amt15_rotation_gpu_audit.json').write_text(json.dumps(report,indent=2)+'\n')
print('Draws:',len(report['records']),'hold-compatible:',report['holdCompatible'],'linear-compatible:',report['linearCompatible'])
for r in report['records']:print(r['capture'],r['event'],'hold',r['hold'],'linear',r['linear'])
assert report['holdCompatible']==8 and report['linearCompatible']==2

