"""Check observed endpoints and actual intermediate changes in the Lua player."""
import sys,math,json
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
addon=ROOT.parent/'storm_amaterasu_lab'
load=lua.eval('load')
for name in ('lua/autorun/client/storm_amt_capture.lua','lua/storm_amt_lab/motion_player.lua','lua/storm_amt_lab/motion_timeline.lua'):
    result=load((addon/name).read_text())
    assert not isinstance(result,tuple),result
data=lua.execute((addon/'lua/storm_amt_lab/motion_timeline_data.lua').read_text())
timeline=lua.execute((addon/'lua/storm_amt_lab/motion_timeline.lua').read_text())
for i in range(1,len(data.snapshots)+1):
    sample=data.snapshots[i]
    output,*_=timeline.evaluate(data,sample.time)
    assert len(output)==len(sample.states),(i,len(output),len(sample.states))
    expected={sample.states[j].track:sample.states[j] for j in range(1,len(sample.states)+1)}
    for j in range(1,len(output)+1):
        item=output[j];source=expected[item.track]
        for name in ('origin','basis','tint','scroll'):
            assert all(abs(item[name][k]-source[name][k])<1e-8 for k in range(1,len(item[name])+1)),(i,name)
        assert item.key==source.key
        assert item.weight==1
    print('Observed endpoint',sample.frame,len(output),'draws preserved')
fingerprints=set()
max_draws=0
for i in range(361):
    output,*_=timeline.evaluate(data,data.duration*i/360)
    current=[]
    max_draws=max(max_draws,len(output))
    for j in range(1,len(output)+1):
        item=output[j]
        current.append((item.track,item.key,round(item.weight,6),tuple(round(item.origin[k],6) for k in range(1,4)),tuple(round(item.basis[k],6) for k in range(1,10))))
        assert all(math.isfinite(item.basis[k]) for k in range(1,10))
        assert 0<item.weight<=1
    fingerprints.add(repr(current))
assert len(fingerprints)>300,len(fingerprints)
assert len(list(data.models.keys()))==3
compiled=ROOT/'shaders/shaders/fxc/amt_motion_r6_ps30.vcs'
assert compiled.exists() and compiled.stat().st_size>100
print('Continuous states:',len(fingerprints),'of 361 evaluations; max draws:',max_draws,'; only three shared meshes required')
print('Syntax and measured endpoints verified; actual GPU rendering still requires GMod validation')
