"""Exercise a complete original impact scene without captured positions."""
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
def module(name): return l.execute((ROOT/(name+'.lua')).read_text())
modules=l.table_from({k:module(v) for k,v in {
    'spawn':'particle_spawn_core','motion':'particle_motion_core','curves':'runtime_core',
    'runtime':'procedural_runtime','spatial':'scene_spatial_core',
    'birthSpatial':'particle_spatial_core','emission':'emission_core'}.items()})
data=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua').read_text())
driver=module('procedural_scene')
l.globals().spatial=modules.spatial
l.globals().motion=modules.motion
l.execute('''
local first,second,third={},{},{}
local lists={{first},{second},{third}}
assert(#motion.routeFields(0,lists)==0)
assert(motion.routeFields(1,lists)[1]==first)
assert(motion.routeFields(256,lists)[1]==second)
assert(motion.routeFields(65536,lists)[1]==third)
local all=motion.routeFields(65793,lists)
assert(#all==3 and all[1]==first and all[2]==second and all[3]==third)
local a,b,c={connection=0},{connection=0},{connection=1}
local pairs=spatial.segments({a,b,c})
assert(#pairs==2 and pairs[1][1]==a and pairs[2][1]==b)
a.connection=1 b.connection=0 c.connection=0
pairs=spatial.segments({a,b,c})
assert(#pairs==2 and pairs[1][1]==a and pairs[2][1]==b and pairs[2][2]==c)
-- End-of-list fallback selects the last two, never last-to-first.
a.connection=0
pairs=spatial.segments({a,b,c})
assert(#pairs==3 and pairs[3][1]==b and pairs[3][2]==c)
a.connection=1 b.connection=1 c.connection=1
pairs=spatial.segments({a,b,c})
assert(#pairs==3 and pairs[2][1]==b and pairs[3][1]==b)
''')
scenes=[driver.new(data,'4efb_amt1_hit00',modules,l.table_from({
    'seed':1,'fps':60,'stopEmission':lambda frame: frame>=100})) for _ in range(2)]
births_at_end=[None,None]
for frame in range(360):
    for index,s in enumerate(scenes):
        s.update(s)
        for p in s.particles.values():
            for x in p.position.values(): assert abs(x)<1e8
        if frame==100:
            births_at_end[index]=dict(s.births.items())
        if frame>100:
            assert dict(s.births.items())==births_at_end[index], 'no births may occur after the ANM endpoint'
    assert scenes[0].rng.seed==scenes[1].rng.seed
    assert len(scenes[0].particles)==len(scenes[1].particles)
for s in scenes:
    assert len(s.errors)==0
    assert len(s.particles)==0,'particles must expire'
    assert s.emissionStopped and s.isDrained(s),'effect endpoint must stop births and drain alive particles'
    assert s.births['1efc_part09b']>0,'ash generator must emit'
    assert any(s.births[n]>0 for n in ('4efb_amt02','4efb_amt03','4efb_amt04'))
print('PASS: original attachment break field, special first segment and tail fallback')
print('PASS: 360 full scene updates, deterministic RNG, finite positions, exact emission cutoff, ash/lateral births and expiry')
print('Births:',dict(scenes[0].births.items()))
print('Stop notifications:',len(scenes[0].stopNotifications))
