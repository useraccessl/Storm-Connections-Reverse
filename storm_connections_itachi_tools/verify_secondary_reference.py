"""Match exported auxiliary mesh positions/UV animation to original GPU inputs."""
import sys,json,struct
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime()
pack=l.execute((ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/procedural_assets.lua').read_text())
models={}
for name,r in pack.resources.items():
    models[name]=[np.array([list(v.values())[:3] for v in m.vertices.values()]) for m in r.meshes.values()]
output=[]
for path in sorted((ROOT/'gpu_captures').glob('*.secondary_reference.json')):
    draws=json.loads(path.read_text())
    for d in draws:
        attrs={a['name']:a for a in d['inputs']}
        a=attrs['POSITION'];b=d['vertices'][a['buffer']]
        raw=bytes.fromhex(b['raw_hex']);count=len(raw)//b['stride']
        pos=np.array([struct.unpack_from('<3f',raw,i*b['stride']+a['offset']) for i in range(count)])
        fields=d['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields']
        uv=fields['g_uvOffset0']['values']
        candidates=[]
        for name,meshes in models.items():
            r=pack.resources[name]
            if r.material.texture_groups[1].textures[1].name!=d['base_asset']: continue
            if not any(v.shape==pos.shape and np.max(np.abs(v-pos))<1e-4 for v in meshes): continue
            ch=r.billboard.channels
            offsets=ch[5];scales=ch[6]
            base=list(r.material.floats.values())[:4]
            for key in range(1,r.billboard.count+1):
                value=(list(offsets[min(key,len(offsets))].values()) if offsets else base[:2])+(
                    list(scales[min(key,len(scales))].values()) if scales else base[2:])
                if max(abs(x-y) for x,y in zip(value,uv))<1e-4:
                    candidates.append({'resource':name,'key':key})
        assert candidates,(path.name,d['event'],d['base_asset'],count,uv)
        assert d['depth']['writes'] and not d['blend'][0]['enabled']
        output.append({'capture':path.stem,'event':d['event'],'candidates':candidates})
(ROOT/'captured_assets/procedural/secondary_matches.json').write_text(json.dumps(output,indent=2)+'\n')
print('PASS:',len(output),'auxiliary GPU draws match original meshes, texture blocks, UV keys and opaque depth state')
