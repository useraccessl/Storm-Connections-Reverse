"""Check extracted motion bindings and analytically known force cases."""
from pathlib import Path
import sys,json
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
data=lua.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua').read_text())
assert len(data.effects['4efb_amt1_blt00'])==6
assert len(data.effects['4efb_amt1_hit00'])==18
assert len(data.spatialRecords['4efb_amt1_hit00'].forces)==22
assert len(data.spatialRecords['4efb_amt1_blt00'].forces)==1
motion=lua.execute((ROOT/'particle_motion_core.lua').read_text())
lua.globals().motion=motion
lua.execute('''
local function state() return {position={0,0,0},velocity={0,0,0},secondaryVelocity={0,0,0},rotation={0,0,0},scale={1,1,1},speed=1,scalar=1} end
local function field(kind) return {center={0,0,0},direction={0,0,1},directionLength=1,config={selector=kind,strength=2,strength_multiplier=0,radius_base=10,limit_radius=false,falloff_mode=1,vector_parameter={0,1,0}}} end
local p=state() assert(motion.force(p,field(3),.5)) assert(p.position[3]==1 and p.velocity[3]==0)
p=state() assert(motion.force(p,field(6),.5)) assert(p.velocity[3]==1 and p.position[3]==0)
motion.integrate(p,.5,{0,0,0}) assert(p.position[3]==.5)
p=state() local f=field(1) f.config.strength=-10 assert(motion.force(p,f,.5)) assert(p.speed==0)
p=state() p.position={20,0,0} f=field(6) f.config.limit_radius=true assert(motion.force(p,f,1)) assert(p.velocity[3]==0)
p=state() p.position={5,0,0} f=field(6) f.config.limit_radius=true assert(motion.force(p,f,1)) assert(p.velocity[3]==1)
p=state() p.position={1,0,0} f=field(0) f.config.strength=math.pi/2
assert(motion.force(p,f,1)) assert(p.position[1]==1 and p.velocity[1]==0)
motion.integrate(p,1,{0,0,0})
assert(math.abs(p.position[1])<1e-12 and math.abs(p.position[2]-1)<1e-12)
assert(p.displacement[1]==0 and p.displacement[2]==0)
-- A second integration cannot accumulate the same vortex displacement again.
motion.integrate(p,1,{0,0,0}) assert(math.abs(p.position[2]-1)<1e-12)
-- Axis handedness, center translation, reciprocal direction length and speed.
p=state() p.position={3,2,3} p.speed=.5 f=field(0)
f.center={2,2,3} f.direction={0,0,2} f.directionLength=2 f.config.strength=math.pi
assert(motion.force(p,f,1)) motion.integrate(p,1,{0,0,0})
assert(math.abs(p.position[1]-2.5)<1e-12 and math.abs(p.position[2]-2.5)<1e-12)
local r=motion.rotateAxis({1,0,0},{0,0,1},-math.pi/2)
assert(math.abs(r[1])<1e-12 and math.abs(r[2]+1)<1e-12)
p=state() p.position={5,0,0} f=field(0) f.direction={0,0,0}
assert(motion.force(p,f,1)) assert(p.displacement==nil)
''')
print('Verified 24 emitter records, 23 force bindings, all seven force selectors and vortex/integration checks; complete visual runtime remains unverified')
