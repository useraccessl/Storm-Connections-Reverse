"""Match recorded GPU vertex inputs and animated UVs to original billboards."""
import json, struct, sys
from pathlib import Path
import numpy as np
from xfbin_chunks import parse
from inspect_nud import parse_nud
from export_effect_obj import get_vertices
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'captured_assets'
data,chunks=parse(OUT/'data/effect/4efb_amt1.xfbin')
models={}
for chunk in chunks:
    if chunk['type']!='nuccChunkModel': continue
    body=data[chunk['offset']:chunk['offset']+chunk['size']]
    nud=body[body.index(b'NDP3'):]
    parsed=parse_nud(nud)
    models[chunk['name']]=np.array(get_vertices(nud,parsed['groups'][0]['meshes'][0]))
billboards={Path(b['source']).stem:b for b in json.loads((OUT/'billboard_arrays.json').read_text())}
sample=int(sys.argv[1]) if len(sys.argv)>1 else None
result=[]
source='itachi_amaterasu_frame'+str(sample)+'.sequence_geometry.json' if sample else 'amaterasu_geometry.json'
for d in json.loads((ROOT/'gpu_captures'/source).read_text()):
    attrs={a['name']:a for a in d['inputs']}
    a=attrs['POSITION'];b=d['vertices'][a['buffer']];raw=bytes.fromhex(b['raw_hex'])
    count=len(raw)//b['stride']
    positions=np.array([struct.unpack_from('<3f',raw,i*b['stride']+a['offset']) for i in range(count)])
    f=d['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields']
    uv=f['g_uvOffset0']['values']
    candidates=[]
    for name,vertices in models.items():
        if name not in billboards or len(vertices)!=len(positions): continue
        error=float(np.max(np.abs(vertices[:,:3]-positions)))
        if error>1e-4: continue
        bb=billboards[name];groups={a['group']:a for a in bb['arrays']}
        offsets=groups[4];scales=groups[5]
        if not offsets['count'] or not scales['count']: continue
        raw0=bytes.fromhex(offsets['raw_hex']);raw1=bytes.fromhex(scales['raw_hex'])
        for k in range(bb['header']['count']):
            value=list(struct.unpack_from('>2f',raw0,min(k,offsets['count']-1)*8))+list(struct.unpack_from('>2f',raw1,min(k,scales['count']-1)*8))
            if max(abs(x-y) for x,y in zip(value,uv))<1e-4:
                candidates.append({'resource':name,'key':k,'step_ticks':bb['header']['unknown_u32'],'position_error':error})
    result.append({'event':d['event'],'vertex_count':count,'uv':uv,'candidates':candidates})
    print(d['event'],count,uv,[(x['resource'],x['key']) for x in candidates])
(OUT/('gpu_billboard_matches_'+str(sample)+'.json' if sample else 'gpu_billboard_matches.json')).write_text(json.dumps(result,indent=2))
