"""Check original spatial formulas, axes and RNG call ordering independently."""
import sys,math
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
l.globals().spatial=l.execute((ROOT/'particle_spatial_core.lua').read_text())
l.globals().spawn=l.execute((ROOT/'particle_spawn_core.lua').read_text())
l.execute('''
local function close(a,b) assert(math.abs(a-b)<1e-10) end
local s=spatial
-- With no cone angle, every attachment axis must be reproduced, including
-- the singular +/-X branch and the fallback zero direction.
for _,axis in ipairs({{0,0,1},{0,-1,0},{1,0,0},{-1,0,0},{.2,.3,.4}}) do
    local v=s.cone(0,0,axis)
    local n=math.sqrt(axis[1]^2+axis[2]^2+axis[3]^2)
    for i=1,3 do close(v[i],axis[i]/n) end
end
local v=s.cone(.3,.4,nil)
close(v[1],-math.sin(.4)*math.cos(.3))
close(v[2],math.cos(.4)*math.cos(.3)) close(v[3],math.sin(.3))
local e={shape=1,radius=10,radiusRandom=.5,direction=0}
local r,ref=spawn.random(1),spawn.random(1)
local p=assert(s.single(e,r,{{position={2,3,4},scale=2}}))
local theta=ref:interval(-math.pi,math.pi)
ref:interval(-math.pi,math.pi)
local inner=(1-ref:range(.5))*10
local radius=ref:interval(inner*2,20)
close(p.position[1],2+radius*math.cos(theta))
close(p.position[2],3+radius*math.sin(theta)) close(p.position[3],4)
assert(r.seed==ref.seed)
e.shape=2 r,ref=spawn.random(1),spawn.random(1)
p=assert(s.single(e,r,{{position={0,0,0},scale=1}}))
theta=ref:interval(-math.pi,math.pi) local phi=ref:interval(-math.pi,math.pi)
inner=(1-ref:range(.5))*10 radius=ref:interval(inner,10)
close(p.position[1],radius*math.cos(theta))
close(p.position[2],radius*math.cos(phi)*math.sin(theta))
close(p.position[3],radius*math.sin(phi)*math.sin(theta))
assert(r.seed==ref.seed)
-- Segment sampling consumes: pair, longitudinal distance, two angles,
-- radial random, radius, and (mode 0 only) endpoint selection.
local pair={{position={0,0,0}},{position={0,0,20}}}
for mode=3,5 do
    e.shape=mode r,ref=spawn.random(13),spawn.random(13)
    p=assert(s.segment(e,r,{pair}))
    ref:integer() local along=ref:range(1)*20
    theta=ref:interval(-math.pi,math.pi) phi=ref:interval(-math.pi,math.pi)
    inner=(1-ref:range(.5))*10 radius=ref:interval(inner,10)
    close(p.position[1],radius*math.cos(theta))
    close(p.position[2],radius*math.cos(phi)*math.sin(theta))
    close(p.position[3],along+radius*math.sin(phi)*math.sin(theta))
    if mode==3 then ref:integer() end
    assert(r.seed==ref.seed)
end
''')
print('PASS: attachment cone axes, circle/sphere/segment formulas and original RNG consumption')
l.globals().scene=l.execute((ROOT/'scene_spatial_core.lua').read_text())
l.globals().data=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua').read_text())
l.globals().runtime=l.execute((ROOT/'procedural_runtime.lua').read_text()).new(
    l.execute((ROOT/'particle_motion_core.lua').read_text()),
    l.globals().spawn,l.execute((ROOT/'runtime_core.lua').read_text()))
l.execute('''
local name='4efb_amt1_hit00'
local coords=assert(scene.coordinates(data.animations[name]))
assert(coords['1efc_dmy01_01'].position[3]==6)
assert(math.abs(coords['1efc_dmy01_002'].position[3]-189.6452)<.001)
local records=data.spatialRecords[name]
local r=spawn.random(1)
for _,e in ipairs(data.effects[name]) do
    local a=assert(scene.attachments(records.attachments,coords,e.id))
    local fields=assert(scene.fields(records.forces,coords,e.id))
    local segments=scene.segments(a)
    local p=assert(runtime.create(e,r,function(config,rng)
        if config.shape>=3 and #a>1 then return spatial.segment(config,rng,segments) end
        return spatial.single(config,rng,a)
    end))
    for i=1,5 do assert(runtime.step(p,1/60,fields,{0,0,0})~=nil) end
    for i=1,3 do assert(p.position[i]==p.position[i] and math.abs(p.position[i])<1e9) end
end
''')
print('PASS: all 18 impact emitters resolve original ANM attachments and step with their file-derived force fields')
l.globals().curves=l.execute((ROOT/'runtime_core.lua').read_text())
l.execute('''
local b=data.billboards['4efb_amt00']
local _,index,ticks=curves.billboardFromParticle(b,27.5)
assert(ticks==1300 and index==math.min(b.count,math.floor(1300/b.stepTicks)+1))
local _,first,firstTicks=curves.billboardFromParticle(b,1)
assert(first==1 and firstTicks==0)
local _,a=curves.billboardFromParticle(b,.5)
local _,c=curves.billboardFromParticle(b,.999)
assert(a==c)
''')
print('PASS: original sample-before-advance billboard phase and 50-tick advancement')
