"""Check decoded material/binder correspondence, not final GPU parity."""
import json,sys,struct,random,math
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
core=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/material_context_core.lua').read_text())
m=l.table_from({'scroll0':l.table_from([0,0,0,1]),'scroll1':l.table_from([1,0,1,1])})
assert abs(core.signedFraction(-1.25)+.25)<1e-12
assert abs(core.originalClock(30000,3000)-1)<1e-7
assert core.advanceCounter(2147483640,20,False)==12
assert core.advanceCounter(1200,50,True)==1200
def f32(x):return struct.unpack('<f',struct.pack('<f',x))[0]
rng=random.Random(9300)
values=[0,1,-1,2**-149,2**-150,1+2**-24,1+3*2**-24,2147483647]
values += [rng.uniform(-1,1)*2**rng.randrange(-145,120) for _ in range(1000)]
for v in values:assert core.float32(v)==f32(v),(v,core.float32(v),f32(v))
for count in [0,50,30000,21050,4111050,2147483647]:
    assert core.originalClock(count,3000)==f32(f32(f32(count)*f32(.1))/f32(3000))
assert core.deltaForCalls(3000,601)==30000
assert core.deltaForCalls(3000,1)==50
screen=core.screenToUV(3840,2160)
assert screen[1]==f32(1/3840) and screen[2]==f32(1/2160)
captures=draws=0
for path in sorted((ROOT/'gpu_captures').glob('*.all_draws.json')):
    matched=0
    for draw in json.loads(path.read_text()):
        if not draw['shaders'].get('ShaderStage.Pixel','').startswith('915c5e'): continue
        for buf in draw['constants']['ShaderStage.Vertex'].values():
            fields=buf.get('fields',{})
            if 'g_uvOffsetScreen' not in fields: continue
            actual=fields['g_uvOffsetScreen']['values']
            original_screen=fields['g_ScreenToUV']['values']
            assert [screen[i+1] for i in range(4)]==original_screen
            # Input phase from capture tests the four-channel mapping only.
            predicted=core.screenScroll(m,actual[1])
            assert max(abs(predicted[i+1]-actual[i]) for i in range(4))<1e-7
            matched+=1
    if matched: captures+=1;draws+=matched
assert captures==7
print(f'PASS: original binder mapping in {draws} primary draws across {captures} captures; signed fractional wrapping and clock conversion.')
print('PASS: 1008 float32 edge/random cases, original counter step/pause/wrap and ScreenToUV values in all 213 draws.')
print('LIMIT: original clock epoch/host scheduling and final pixels remain unverified.')
