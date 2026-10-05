"""File-driven model/particle/ANM bridge diagnostic; explicit synthetic host inputs."""
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
for n in ('sinf','cosf','acosf'):getattr(crt,n).argtypes=[ctypes.c_float];getattr(crt,n).restype=ctypes.c_float
mods=l.table_from({k:module(v) for k,v in {'quaternion':'quaternion_animation_core','scalar':'scalar_animation_core','matrix':'anm_matrix_core','material':'material_animation_core','clock':'anm_clock_core','animation':'anm_resource_core'}.items()})
particle=module('particle_matrix_core');bridge=module('model_effect_instance');assets=json.loads((ROOT/'captured_assets/procedural/auxiliary_resources.json').read_text())
compiled=mods.animation.compile(luify(assets['animation']),mods,l.table_from({'float32':f,'acosf':crt.acosf,'sinf':crt.sinf,'materialHold':mods.animation.materialHoldFromContext(60,0)}))
# Explicit synthetic fields isolate bridge order. Not inferred live activation/placement.
state=luify({'position':[10.,20.,30.],'rotationDirty':False,'travelAligned':True,'direction':[0.,0.,1.],'directionTolerance':f(.001),'angles':[0.,0.,0.],'parentScale':[1.,1.,1.],'baseScale':[1.,1.,1.],'uniformScale':1.})
parent,enabled=particle.parent(state,mods.matrix,f,crt.sinf,crt.cosf);assert enabled
size=luify([.2,.3,.2]);scales=luify({1:[1.,1.,1.]});instance=bridge.new(compiled,mods,l.table_from({'coordinateTranslationScales':scales,'materialInstances':luify({2:{0x80:1.,0x84:255.}})}))
samples=[]
for frame in range(1,41):
 result,overflow,step,scaled=instance.update(instance,parent,size,30,60,1)
 tick=instance.player.clock.ticks;assert step==50 and overflow==-1
 expected=mods.matrix.world(scaled,result[1].localMatrix,f)
 assert [expected[i] for i in range(1,17)]==[result[1].worldMatrix[i] for i in range(1,17)]
 for i,v in zip((4,8,12),(10.,20.,30.)):assert scaled[i]==v
 if frame in (1,3,7,11,15,16,17):samples.append({'frame':frame,'ticks':tick,'uv0y':result[2].instance[0x34],'worldMatrix':[result[1].worldMatrix[i] for i in range(1,17)]})
assert samples[1]['ticks']==150 and samples[1]['uv0y']==.125
assert samples[-2]['ticks']==800 and samples[-1]['ticks']==50
report={'frames':40,'samples':samples,'scope':'Integration of native-derived particle parent, lifecycle column scale, model-before-sample clock update, original ANM channels and hierarchy. Explicit synthetic position/direction/angles/scale; not original host scene or pixel parity. No captured points used.'}
(ROOT/'captured_assets/procedural/model_effect_bridge_diagnostic.json').write_text(json.dumps(report,indent=2)+'\n')
print('PASS 40 file-driven model bridge updates, including exact endpoint and repeated loops.')
