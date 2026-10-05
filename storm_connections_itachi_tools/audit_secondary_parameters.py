"""Check file-derived BB UV/color/opacity compatibility with original GPU draws.

This audits property-clock hypotheses, not particle identity or trajectories.
The report retains mismatches rather than fitting material constants to them.
"""
import sys,json,math,argparse
from pathlib import Path
ROOT=Path(__file__).resolve().parent
ap=argparse.ArgumentParser()
ap.add_argument('--phase',type=int,default=1,help='whole billboard updates sampled before current clock')
args=ap.parse_args()
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
import numpy as np
l=LuaRuntime(unpack_returned_tuples=True)
curves=l.execute((ROOT/'runtime_core.lua').read_text())
data=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua').read_text())
pack=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/procedural_assets.lua').read_text())
catalog={}
for effect,emitters in data.effects.items():
    for e in emitters.values():
        for resource in e.resources.values():
            r=pack.resources[resource]
            if r is None: continue
            entries=catalog.setdefault(resource,[])
            max_life=math.floor(e.life*(1+e.lifeRandom))
            for life in range(e.life,max_life+1):
                for half_age in range(0,life*2):
                    age_ticks=half_age*.5
                    _,color,alpha=curves.sample(e,life,age_ticks/e.simulationHz,l.table_from([0,0,0]))
                    # The evaluator now uses the verified before-increment
                    # phase. Keep phase=0 available to audit the former bug.
                    keys,index,_=curves.billboardFromParticle(r.billboard,max(0,age_ticks+1-args.phase))
                    uv=list(keys[5].values())+list(keys[6].values())
                    opacity=alpha*(keys[4][1] if keys[4] else 1)
                    entries.append((uv,list(color.values())[:3],opacity,effect,e.id,life,age_ticks,index))
matrices={n:np.array([row[0]+row[1]+[row[2]] for row in rows]) for n,rows in catalog.items()}
matches=json.loads((ROOT/'captured_assets/procedural/secondary_matches.json').read_text())
match_index={(m['capture'],m['event']):m['candidates'] for m in matches}
report=[]
for path in sorted((ROOT/'gpu_captures').glob('*.secondary_reference.json')):
    for draw in json.loads(path.read_text()):
        f=draw['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields']
        target=np.array(f['g_uvOffset0']['values']+f['g_multColor']['values'][:3]+[f['g_commonParam']['values'][1]])
        best=None
        for name in {c['resource'] for c in match_index[(path.stem,draw['event'])]}:
            matrix=matrices[name]
            eligible=np.flatnonzero(np.max(np.abs(matrix[:,:4]-target[:4]),axis=1)<1e-4)
            if len(eligible)==0: continue
            errors=np.max(np.abs(matrix[eligible,4:]-target[4:]),axis=1)
            k=int(eligible[int(np.argmin(errors))])
            error=float(np.min(errors))
            if best is None or error<best['error']:
                row=catalog[name][k]
                best={'resource':name,'error':error,'effect':row[3],'emitter':row[4],
                      'life':row[5],'ageTicks':row[6],'key':row[7],
                      'predictedColor':row[1],'predictedOpacity':row[2]}
        report.append({'capture':path.stem,'event':draw['event'],
                       'originalColor':target[4:7].tolist(),'originalOpacity':float(target[7]),'closest':best})
output=ROOT/f'captured_assets/procedural/secondary_parameter_audit_phase{args.phase}.json'
output.write_text(json.dumps(report,indent=2)+'\n')
passed=sum(r['closest'] is not None and r['closest']['error']<1e-4 for r in report)
print(f'Property compatibility: {passed}/{len(report)} original draws within 1e-4 for UV + color + opacity')
bad=[r for r in report if r['closest'] is None or r['closest']['error']>=1e-4]
for r in bad[:8]: print(r['capture'],r['event'],r['closest'])
print('Report:',output)
print('This does not validate trajectories, host scheduling or final pixel colors.')
