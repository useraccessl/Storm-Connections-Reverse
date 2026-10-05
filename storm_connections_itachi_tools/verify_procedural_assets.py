"""Verify file-derived mesh coverage and original spawning arithmetic."""
from pathlib import Path
import sys,json,math
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
pack=lua.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/procedural_assets.lua').read_text())
assert len(list(pack.resources.keys()))==17
for name,count in {'4efb_amt02':369,'4efb_amt03':369,'4efb_amt04':215,'4efb_amt06':215,'1efc_part09b':468,'1efc_part11b':76}.items():
    assert sum(len(m.vertices) for m in pack.resources[name].meshes.values())==count
for resource in pack.resources.values():
    assert all(isinstance(k,(int,float)) for k in resource.billboard.channels.keys()), 'Lua channel indices must be numeric'
    for mesh in resource.meshes.values():
        for v in mesh.vertices.values():
            assert len(v)==9 and all(math.isfinite(n) for n in v.values())
            assert all(0<=v[i]<=1 for i in range(6,10))
        for t in mesh.triangles.values():
            assert len(t)==3 and all(0<=i<len(mesh.vertices) for i in t.values())
        for g in resource.material.texture_groups.values():
            for t in g.textures.values(): assert pack.textures[t.name] is not None
import struct
for name,t in pack.textures.items():
    nut=Path(t.path).read_bytes()
    vtf=(ROOT.parent/'storm_amaterasu_lab/materials/storm_amt_lab'/('procedural_'+name+'.vtf')).read_bytes()
    start=0x10+struct.unpack_from('>H',nut,28)[0]
    assert vtf[80:]==nut[start:start+t.nativeVTF.payloadBytes]
spawn=lua.execute((ROOT/'particle_spawn_core.lua').read_text())
lua.globals().spawn=spawn
lua.execute('''
local r=spawn.random(1)
assert(r:integer()==41 and r:integer()==18467 and r:integer()==6334)
local a,b=spawn.random(1),spawn.random(1)
assert(math.abs(a:interval(-2,6)-(6-b:integer()/32767*8))<1e-12)
local e={direction=0,speed=2,speedRandom=0}
local v=assert(spawn.velocity(e,{3,0,0},{0,0,0},nil,1,spawn.random(1)))
assert(v[1]==2 and v[2]==0 and v[3]==0)
e.direction=1 v=assert(spawn.velocity(e,{3,0,0},{0,0,0},nil,1,spawn.random(1))) assert(v[1]==-2)
e.direction=3 local missing,why=spawn.velocity(e,{0,0,0},{0,0,0},nil,1,spawn.random(1)) assert(missing==nil and why)
local function eSize(independent) return {independentSizeRandom=independent,sizeRandom={1,2,3},sizeStart={1,1,1},sizeMiddle={2,2,2},sizeEnd={3,3,3}} end
a,b=spawn.random(1),spawn.random(1)
local s=spawn.sizeCurves(eSize(true),a)
local z,y,x=b:range(3),b:range(2),b:range(1)
assert(s.sizeStart[1]==1+x and s.sizeStart[2]==1+y and s.sizeStart[3]==1+z)
assert(a.seed==b.seed)
a,b=spawn.random(1),spawn.random(1)
s=spawn.sizeCurves(eSize(false),a) local u=b:range(1)
assert(s.sizeEnd[3]==3*(1+3*u) and a.seed==b.seed)
''')
# Compare the exact low bits to the original uint64 recurrence for 1000 draws.
state=0x12345678
r=spawn.random(state)
for _ in range(1000):
    state=(state*214013+2531011)&0xffffffffffffffff
    assert r.integer(r)==((state>>16)&32767)
print('Verified 17 original billboard meshes/material references and 1000 original RNG steps; no captured positions loaded')
motion=lua.execute((ROOT/'particle_motion_core.lua').read_text())
curves=lua.execute((ROOT/'runtime_core.lua').read_text())
runtime=lua.execute((ROOT/'procedural_runtime.lua').read_text()).new(motion,spawn,curves)
lua.globals().runtime=runtime
lua.globals().emission=lua.execute((ROOT/'emission_core.lua').read_text())
lua.globals().data=lua.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua').read_text())
lua.execute('''
local e=data.effects['4efb_amt1_hit00'][1]
local s=emission.new(false)
assert(emission.update(s,e,0,60,1,2)==0)
assert(emission.update(s,e,165,60,1,2)==0)
local count,copies=emission.update(s,e,166,60,1,2)
assert(count==9 and copies==2)
assert(emission.update(s,e,183,60,1,2)==0)
local p=assert(runtime.create(e,spawn.random(1),function()
    return {position={1,0,0},center={0,0,0},scale=1}
end))
local f={center={0,0,0},direction={0,0,1},directionLength=1,config={selector=0,strength=math.pi/2,
    strength_multiplier=0,radius_base=10,limit_radius=false,falloff_mode=0}}
local startX,startY=p.position[1],p.position[2]
assert(runtime.step(p,1/e.simulationHz,{f},{0,0,0})~=nil)
assert(p.ageTicks==1 and p.position[1]~=startX and p.position[2]~=startY)
assert(p.size and p.alpha and p.resource)
''')
print('Verified procedural create/force/integrate/size path and original timed burst; full skill scheduling and rendering pending')
