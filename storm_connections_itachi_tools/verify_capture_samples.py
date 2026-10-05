"""Validate the new captured states, independent of legacy 2efb exports."""
from pathlib import Path
import sys, math
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
addon=ROOT.parent/'storm_amaterasu_lab'
load=lua.eval('load')
source=addon/'lua/autorun/client/storm_amt_capture.lua'
result=load(source.read_text())
assert not isinstance(result,tuple),result
for number in (22082,22102,22127,22136,22149,22171,22200):
    path=addon/f'lua/storm_amt_lab/captured_sample_{number}.lua'
    frame=lua.execute(path.read_text())
    assert math.isfinite(frame.cameraYaw)
    assert len(frame)>0
    for i in range(1,len(frame)+1):
        draw=frame[i]
        assert len(draw.facing_vertices)%3==0
        assert len(draw.origin)==3
        for j in range(1,len(draw.facing_vertices)+1):
            vertex=draw.facing_vertices[j]
            assert len(vertex)==9
            assert all(math.isfinite(vertex[k]) for k in range(1,10))
        assert draw.textures[1] in ('83525','83527')
        assert draw.textures[2]=='83535'
        for j in range(1,len(draw.textures)+1):
            assert (addon/f'materials/storm_amt_lab/capture_{draw.textures[j]}.vtf').exists()
    print(number,len(frame),'validated original draws')
print('Capture viewer syntax and all seven sample meshes/material references validated')
