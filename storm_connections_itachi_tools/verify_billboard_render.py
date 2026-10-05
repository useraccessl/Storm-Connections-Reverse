"""Original CPU/channel regression checks; not live shader parity."""
import sys,json,math,struct,random
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True);base=ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab'
b=l.execute((base/'billboard_render_core.lua').read_text());ctx=l.execute((base/'material_context_core.lua').read_text());d=l.execute((base/'captured_runtime_data.lua').read_text());a=l.execute((base/'procedural_assets.lua').read_text())
assert b.film(d.materials['4efb_amt08'])==struct.unpack('<f',struct.pack('<f',.05))[0]
assert a.resources['4efb_amt08'].billboard.channels[9][1][1]==1
report=json.loads((ROOT/'captured_assets/procedural/geometry_property_audit.json').read_text())
for r in report['records']:
 assert any(abs(b.film(d.materials[name])-r['filmGPU'])<1e-5 for name in r['filmFromFile'])
f32=lambda x:struct.unpack('<f',struct.pack('<f',x))[0]
rng=random.Random(1010);angles=[0,-0.0,math.pi,-math.pi,2*math.pi,-2*math.pi]
angles += [rng.uniform(-4*math.pi,4*math.pi) for _ in range(1000)]
for angle in angles:
 x=f32(f32(f32(angle)*65536)/f32(2*math.pi));integer=math.trunc(f32(x+(-.5 if angle<0 else .5)))
 expected=f32(f32(integer*f32(2*math.pi))*2**-16)
 actual,units=b.roll(angle,ctx.float32)
 assert actual==expected and units==integer
print('PASS: film mapping agrees with 213 original draws; amt08 retains file value 0.05 instead of channel 9 value 1.')
print('PASS: 1006 native float32 angle-quantization cases match original CPU operation order.')
print('LIMIT: geometry-property compatibility does not validate final shape, trajectories or image parity.')
