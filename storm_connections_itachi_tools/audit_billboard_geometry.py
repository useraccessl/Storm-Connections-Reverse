"""Audit original GPU billboard geometry against file-driven property bounds.
No captured positions are supplied to the runtime. Compatibility is not identity.
"""
import json,math,sys
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
base=ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab'
d=l.execute((base/'captured_runtime_data.lua').read_text())
a=l.execute((base/'procedural_assets.lua').read_text())
c=l.execute((ROOT/'runtime_core.lua').read_text())

def fields(draw):
 return {k:v['values'] for k,v in draw['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields'].items()}
catalog={}
for effect,emitters in d.effects.items():
 for e in emitters.values():
  for name in e.resources.values():
   resource=a.resources[name]
   if resource is None or resource.material.format!=77:continue
   rows=catalog.setdefault(name,[])
   for life in range(e.life,math.floor(e.life*(1+e.lifeRandom))+1):
    for half_age in range(1,life*2):
     age=half_age*.5
     size,_,_=c.sample(e,life,age/e.simulationHz,l.table_from([0,0,0]))
     _,key,_=c.billboardFromParticle(resource.billboard,age)
     rows.append((effect,e.id,life,age,key,list(size.values())[:2],list(e.sizeRandom.values())[:2],e.independentSizeRandom))
report=[]
for path in sorted((ROOT/'gpu_captures').glob('*.sequence_geometry.json')):
 number=path.name.split('frame')[1].split('.')[0]
 draws=json.loads(path.read_text());records=json.loads(path.with_name(f'itachi_amaterasu_frame{number}.all_draws.json').read_text())
 matches={m['event']:m for m in json.loads((ROOT/f'captured_assets/gpu_billboard_matches_{number}.json').read_text())}
 f=fields(next(r for r in records if r['targets'][0]==draws[0]['targets'][0] and 'g_matWorld' in fields(r) and 'g_matWorldViewProj' in fields(r)))
 vp=np.linalg.inv(np.array(f['g_matWorld']).reshape(4,4))@np.array(f['g_matWorldViewProj']).reshape(4,4)
 inv=np.linalg.inv(vp);right=inv[0,:3]/np.linalg.norm(inv[0,:3]);up=inv[1,:3]/np.linalg.norm(inv[1,:3]);up-=right*np.dot(up,right);up/=np.linalg.norm(up)
 basis=np.array([right,up,np.cross(right,up)])
 for draw in draws:
  f=fields(draw);m=(np.array(f['g_matWorldViewProj']).reshape(4,4)@inv)[:3,:3]@basis.T
  # Singular values also expose nonuniform scale when rotation mixes axes.
  sizes=np.linalg.norm(m[:2,:],axis=1);candidates=[]
  for match in matches[draw['event']]['candidates']:
   name=match['resource'];key=match['key']+1
   for effect,emitter,life,age,k,minimum,random,independent in catalog[name]:
    if k!=key:continue
    minimum=np.array(minimum);random=np.array(random)
    error=float(max(np.max(minimum-sizes),np.max(sizes-minimum*(1+random)),0))
    if error<1e-3:
     ratio=sizes/minimum-1
     if not independent:
      implied=[ratio[i]/random[i] for i in range(2) if random[i]!=0]
      if len(implied)==2 and abs(implied[0]-implied[1])>1e-3:continue
     candidates.append({'resource':name,'effect':effect,'emitter':emitter,'life':life,'ageTicks':age})
  film_candidates={match['resource']:d.materials[match['resource']].scroll1[1] for match in matches[draw['event']]['candidates']}
  report.append({'capture':number,'event':draw['event'],'sizes':sizes.tolist(),'matrixInCameraBasis':m.tolist(),
    'rowOrthogonalityError':float(abs(np.dot(m[0],m[1]))),
    'filmGPU':f['g_uvOffset3'][0],'filmFromFile':film_candidates,'compatibleSizeCandidates':candidates})
summary={'draws':len(report),'sizesCompatible':sum(bool(r['compatibleSizeCandidates']) for r in report),
 'filmCompatible':sum(any(abs(v-r['filmGPU'])<1e-5 for v in r['filmFromFile'].values()) for r in report),
 'limitations':'UV-constrained property bounds only. Unknown RNG identities, host inputs, force-scale and trajectories are not established.',
 'records':report}
(ROOT/'captured_assets/procedural/geometry_property_audit.json').write_text(json.dumps(summary,indent=2)+'\n')
print({k:v for k,v in summary.items() if k!='records'})
for r in report:
 if not r['compatibleSizeCandidates']:print('Size mismatch',r['capture'],r['event'],r['sizes'])
