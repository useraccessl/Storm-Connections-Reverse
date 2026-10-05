"""Evaluate all file ANM entries for the impact and projectile, with explicit diagnostic root."""
import ctypes,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'));from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
def luify(v):
 if isinstance(v,dict):return l.table_from({k:luify(x) for k,x in v.items()})
 if isinstance(v,list):return l.table_from([luify(x) for x in v])
 return v
def module(n):return l.execute((ROOT/(n+'.lua')).read_text(encoding='utf-8-sig'))
f=lambda v:struct.unpack('<f',struct.pack('<f',v))[0]
crt=ctypes.CDLL('ucrtbase.dll')
for n in ('sinf','acosf'):getattr(crt,n).argtypes=[ctypes.c_float];getattr(crt,n).restype=ctypes.c_float
mods=l.table_from({k:module(v) for k,v in {'quaternion':'quaternion_animation_core','scalar':'scalar_animation_core','matrix':'anm_matrix_core','color':'color_animation_core','material':'material_animation_core','clock':'anm_clock_core'}.items()})
reader=module('anm_resource_core');assets=json.loads((ROOT/'captured_assets/effect_animation.json').read_text());report={'resources':{},'scope':'All decoded ANM entries evaluated. Identity root and unit target translation scales are diagnostic caller inputs, not recovered skill placement. No GPU positions supplied.'}
for name in ('4efb_amt1_hit00','4efb_amt1_blt00'):
 asset=assets[name];compiled=reader.compile(luify(asset),mods,l.table_from({'float32':f,'acosf':crt.acosf,'sinf':crt.sinf,'materialHold':reader.materialHoldFromContext(60,0)}))
 contexts=l.table_from({i+1:l.table_from({'translationScale':l.table_from([1,1,1]),'parentMatrix':mods.matrix.identity()}) for i,e in enumerate(asset['entries']) if e['type']==1})
 samples=[];steps=0
 for tick in range(0,asset['duration_ticks']+1,50):
  result=reader.evaluate(compiled,tick,l.table());reader.coordinateMatrices(compiled,result,contexts);steps+=1
  for item in result.values():
   if item.type==1:assert all(abs(item.worldMatrix[i])<1e8 for i in range(1,17))
  if tick in (0,150,750,3000):
   samples.append({'ticks':tick,'entries':[{'type':item.type,'target':item.target,'worldMatrix':[item.worldMatrix[i] for i in range(1,17)]} if item.type==1 else {'type':item.type,'target':item.target,'pointLightFields':{str(k):v for k,v in item.fields.items()}} for item in result.values()]})
 report['resources'][name]={'entries':len(asset['entries']),'types':sorted(set(e['type'] for e in asset['entries'])),'ticksEvaluated':steps,'duration':asset['duration_ticks'],'samples':samples}
 print(name,'all',len(asset['entries']),'entries,',steps,'samples; types',report['resources'][name]['types'])
(ROOT/'captured_assets/procedural/full_effect_anm_diagnostic.json').write_text(json.dumps(report,indent=2)+'\n')
