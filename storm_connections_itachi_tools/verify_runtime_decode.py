"""Check decoded binary boundaries and runtime behavior against original evidence."""
import json
import math
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
from decode_billboards import decode

lua=LuaRuntime(unpack_returned_tuples=True)
data=lua.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/runtime_data.lua').read_text())
core=lua.execute((ROOT/'runtime_core.lua').read_text())
hit=data['effects']['2efb_amt_hit00']
assert len(hit)==5 and len(data['effects']['2efb_amt_blt00'])==8
assert len(core.births(hit[1],1,60))==5 # direct count, one start event
assert len(core.births(hit[3],1,60))==10
assert len(core.births(hit[4],1,60))==3 # rate 15/s, stop at 266 ms
assert len(core.births(hit[5],1,60))==7 # rate 30/s, stop at 266 ms
assert len(core.births(data['effects']['2efb_amt_blt00'][7],1,60))==0
e=hit[2]
size,color,alpha=core.sample(e,30,e['sizeSplit']/2,lua.table_from([0,0,0]))
assert all(math.isclose(size[i],v,abs_tol=1e-6) for i,v in enumerate([.45,.5,.45],1))
assert all(color[i]==0 for i in (1,2,3)) # split zero selects middle/end colors
assert alpha==1
raw=json.loads((ROOT/'billboard_arrays.json').read_text())
assert len(raw)==14
for b in raw:
    assert decode(Path(b['source']))==b
    decoded=data['billboards'][Path(b['source']).stem]
    for a in b['arrays']:
        if a['count']: assert len(decoded['channels'][a['group']+1])==a['count']
b=data['billboards']['2efb_amt08']
channels,index=core.billboard(b,0)
assert math.isclose(channels[10][2],-1.3,abs_tol=1e-6)
assert channels[11][2]==1.5 and channels[7][1]==.5
_,index=core.billboard(b,b['count']*b['stepTicks']/3000)
assert index==1
animations=json.loads((ROOT/'effect_animation.json').read_text())
assert sum(len(a['entries']) for a in animations.values())==23
assert all(e['target']!='Page0' for a in animations.values() for e in a['entries'])
print('Verified 13 emitters, direct/rate/stop events, size/color curves, 14 billboard channel layouts, dual UVs, loop cadence and 23 resolved animation entries.')
