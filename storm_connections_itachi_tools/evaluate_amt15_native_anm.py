"""Evaluate the original amt15 ANM with native-derived reusable modules.
This is an integration diagnostic, not proof of live host time or world placement.
"""
import ctypes,json,struct,sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent;sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
def luify(x):
 if isinstance(x,dict):return l.table_from({k:luify(v) for k,v in x.items()})
 if isinstance(x,list):return l.table_from([luify(v) for v in x])
 return x
def module(name):return l.execute((ROOT/(name+'.lua')).read_text(encoding='utf-8-sig'))
crt=ctypes.CDLL('ucrtbase.dll')
for name in ('sinf','acosf'):
 fn=getattr(crt,name);fn.argtypes=[ctypes.c_float];fn.restype=ctypes.c_float
f=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
mods=l.table_from({'quaternion':module('quaternion_animation_core'),'scalar':module('scalar_animation_core'),'material':module('material_animation_core'),'clock':module('anm_clock_core'),'matrix':module('anm_matrix_core')})
a=module('anm_resource_core');asset=json.loads((ROOT/'captured_assets/procedural/auxiliary_resources.json').read_text())['animation']
compiled=a.compile(luify(asset),mods,l.table_from({'float32':f,'acosf':crt.acosf,'sinf':crt.sinf,'materialHold':a.materialHoldFromContext(60,0)}))
instances=l.table_from({2:l.table_from({0x80:1,0x84:255})})
report={'resource':'4efb_amt1_ptc02','framesEvaluated':800,'sourceQuaternionKeys':9,'materialContext':{'updateRate':60,'forceLinearFlag':0,'basis':'Hold mode compatible with joint GPU rotation and UV audit; not a general host default'},'samples':[],
 'scope':'Evaluates local ANM clock, channels and 3x3 basis. World matrix and activation remain unverified. Material hold and particle clock are consistent with the GPU audit; final rendering remains pending.'}
for tick in range(800):
 result=a.evaluate(compiled,tick,instances)
 a.coordinateMatrices(compiled,result,l.table_from({1:l.table_from({'translationScale':l.table_from([1,1,1]),'parentMatrix':mods.matrix.identity()})}))
 if tick in (0,50,100,150,400,799):
  coord=result[1];mat=result[2].instance
  report['samples'].append({'ticks':tick,'quaternion':[coord.channels[1][i] for i in range(1,5)],
   'rotationBasis':[coord.rotationBasis[i] for i in range(1,10)],'localMatrix':[coord.localMatrix[i] for i in range(1,17)],'uv0y':mat[0x34],'threshold':mat[0x80],'preservedField84':mat[0x84]})
assert instances[2][0x84]==255
for ticks,value in ((150,.125),(350,.375),(550,.625),(750,.875)):
 result=a.evaluate(compiled,ticks,instances)
 assert result[2].instance[0x34]==value
clock=mods.clock
report['particleClockTimelines']={}
for rate in (30,60):
 delta,speed,ageStep=clock.particleStep(30,rate,1,f)
 player=a.newPlayer(compiled,0,speed)
 timeline=[]
 for _ in range(16):
  result,overflow,step=a.advance(player,delta,instances)
  timeline.append({'ticks':player.clock.ticks,'uv0y':result[2].instance[0x34]})
 report['particleClockTimelines'][str(rate)]={'delta':delta,'speed':speed,'ageStep':ageStep,'timeline':timeline}
assert report['particleClockTimelines']['60']['timeline'][2]=={'ticks':150,'uv0y':.125}
assert report['particleClockTimelines']['30']['timeline'][0]=={'ticks':100,'uv0y':.125}
player=a.newPlayer(compiled,0,1)
report['loopTimeline']=[]
for _ in range(40):
 result,overflow,step=a.advance(player,50,instances)
 report['loopTimeline'].append(player.clock.ticks)
 assert overflow==-1 and step==50
assert report['loopTimeline'][:18]==[50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,50,100]
(ROOT/'captured_assets/procedural/amt15_native_anm_samples.json').write_text(json.dumps(report,indent=2)+'\n')
print('Evaluated 800 local ANM ticks from 9 original rotation keys; no captured positions or geometry per frame.')
print(report['scope'])
