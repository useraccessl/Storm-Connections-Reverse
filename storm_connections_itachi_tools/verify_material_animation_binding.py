"""Check material-ANM channel destinations against eight original GPU draws.
Curve-key selection is a compatibility check, NOT a recovered animation clock.
"""
import json,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True);core=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/material_animation_core.lua').read_text(encoding='utf-8-sig'))
aux=json.loads((ROOT/'captured_assets/procedural/auxiliary_resources.json').read_text());entry=next(e for e in aux['animation']['entries'] if e['type']==4 and e['target']=='4efb_amt15')
# CPU offsets -> original exported shader components. Main alpha is supplied elsewhere.
bindings={'g_uvOffset0':[0x30,0x34,0x50,0x54],'g_uvOffset1':[0x38,0x3c,0x58,0x5c],
 'g_uvOffset3':[0x48,0x4c],'g_blendRate':[0x70,0x74]}
report=[]
for path in sorted((ROOT/'gpu_captures').glob('*.effect_coverage_reference.json')):
 for draw in json.loads(path.read_text()):
  if draw['base_asset']!='4efb_amt03':continue
  stages=draw['constants'];fields=stages['ShaderStage.Vertex']['perMaterialBuffer']['fields'];compatible=[]
  for key in range(9):
   channels=l.table_from({c['index']:c['values'][min(key,len(c['values'])-1)][0] for c in entry['curves']})
   payload=core.packChannels(channels);instance=l.table_from({});core.applyPacked(instance,payload)
   errors=[abs(instance[offset]-fields[name]['values'][i]) for name,offsets in bindings.items() for i,offset in enumerate(offsets)]
   errors += [abs(instance[0x7c]-fields['g_commonParam']['values'][3]),abs(instance[0x80]-fields['g_commonParam']['values'][0])]
   if max(errors)<1e-6:compatible.append(key)
  assert compatible,(path.name,draw['event'])
  report.append({'capture':path.name,'event':draw['event'],'compatibleCurveKeys':compatible})
assert len(report)==8
(ROOT/'captured_assets/procedural/material_animation_gpu_binding.json').write_text(json.dumps({'draws':report,'limitations':'Channel correspondence only; curve-key phase is not independently recovered.'},indent=2)+'\n')
print('PASS: original material channel destinations agree with 8 amt15 GPU draws (UV0/1, film strengths, blend rates, common.w and threshold).')
print('LIMIT: curve interpolation, clock and animation callback invocation still require recovery.')
