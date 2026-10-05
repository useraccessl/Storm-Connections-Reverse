"""Export every original billboard mesh referenced by the verified 4efb effect.

No recorded particle positions or interpolated identities are used here.
Unported clump/animation resources remain explicit in the coverage report.
"""
import json, struct, hashlib
from pathlib import Path
from xfbin_chunks import parse
from inspect_page_refs import table, resolve
from inspect_nud import parse_nud
from export_effect_obj import get_vertices, triangles
from decode_billboards import decode
from analyze_effect import analyze
from build_runtime_data import lua
from nut_to_vtf import convert as native_vtf

ROOT=Path(__file__).resolve().parent
OUT=ROOT/'captured_assets/procedural'
OUT.mkdir(parents=True,exist_ok=True)
graphs=json.loads((ROOT/'captured_assets/particle_graph.json').read_text())
referenced={r['name']:r['type'] for g in graphs for e in g['emitters'] for r in e['resources']}
resources={}
textures={}
archives=[(p,*parse(p)) for p in (ROOT/'captured_assets/data/effect/4efb_amt1.xfbin',ROOT/'extracted/data/effect/1efcmn.xfbin')]
texture_chunks={c['name']:d[c['offset']:c['offset']+c['size']] for _,d,cs in archives for c in cs if c['type']=='nuccChunkTexture'}
for path,data,chunks in archives:
    refs=table(data)
    wanted={c['name'] for c in chunks if c['type']=='nuccChunkBillboard' and c['name'] in referenced}
    mats={m['name']:m for m in analyze(path,','.join(sorted(wanted)))['materials']}
    for name in sorted(wanted):
        bc=next(c for c in chunks if c['type']=='nuccChunkBillboard' and c['name']==name)
        target=OUT/'billboards'/(name+'.bin')
        target.parent.mkdir(exist_ok=True)
        target.write_bytes(data[bc['offset']:bc['offset']+bc['size']])
        board=decode(target)
        kind,_,modelname=resolve(refs,bc['page']+board['header']['resource_page_index'])
        assert kind=='nuccChunkModel',(name,kind)
        # Preserve the full referenced input geometry, not a substitute quad.
        mc=next(c for c in chunks if c['type']=='nuccChunkModel' and c['name']==modelname)
        body=data[mc['offset']:mc['offset']+mc['size']]
        nud=body[body.index(b'NDP3'):]
        parsed=parse_nud(nud)
        meshes=[]
        for group in parsed['groups']:
            for mesh in group['meshes']:
                verts=get_vertices(nud,mesh)
                vtype=mesh['vertex_size']&15
                assert mesh['vertex_size']&0xf0==0
                uv_count=mesh['uv_size']>>4
                start=mesh['vertex_offset']+12+(4 if vtype==0 else 8)
                stride=12+(4 if vtype==0 else 8)+4+uv_count*4
                colors=[list(nud[start+i*stride:start+i*stride+4]) for i in range(len(verts))]
                assert all(len(c)==4 for c in colors)
                vertices=[list(v)+[c/255 for c in color] for v,color in zip(verts,colors)]
                strip=struct.unpack_from('>'+'h'*mesh['face_count'],nud,mesh['poly_offset'])
                faces=[list(t) for t in triangles(strip,len(verts))]
                meshes.append({'vertices':vertices,'triangles':faces,'originalRenderState':mesh['materials'],
                               'group':group['name'],'singleBind':group['single_bind']})
        mat=mats[name]
        texture_names={t['name'] for group in mat['texture_groups'] for t in group['textures']}
        for tn in texture_names:
            raw=texture_chunks[tn]
            size=struct.unpack_from('>I',raw,8)[0]
            nut=raw[12:12+size]
            assert nut[:4]==b'NTP3'
            nt=OUT/'textures'/(tn+'.nut')
            nt.parent.mkdir(exist_ok=True)
            nt.write_bytes(nut)
            vtf=ROOT.parent/'storm_amaterasu_lab/materials/storm_amt_lab'/('procedural_'+tn+'.vtf')
            native=native_vtf(nt,vtf)
            textures[tn]={'path':str(nt),'sha256':hashlib.sha256(nut).hexdigest(),'bytes':len(nut),
                          'sourceTexture':'storm_amt_lab/procedural_'+tn,'nativeVTF':native}
        channels={a['group']+1:[list(struct.unpack_from('>'+'f'*(a['width']//4),bytes.fromhex(a['raw_hex']),i*a['width']))
                  for i in range(a['count'])] for a in board['arrays'] if a['count']}
        resources[name]={'meshes':meshes,'material':mat,'billboard':{'channels':channels,
                         'count':board['header']['count'],'stepTicks':board['header']['unknown_u32'],
                         'loop':bool(int(board['header']['mask'],16)&1)},'source':str(path)}
        print(name,sum(len(m['vertices']) for m in meshes),'vertices',sum(len(m['triangles']) for m in meshes),'triangles')

result={'resources':resources,'textures':textures,
        'unsupportedResources':{n:k for n,k in referenced.items() if n not in resources}}
result=json.loads(json.dumps(result))
for resource in result['resources'].values():
    resource['billboard']['channels']={int(k):v for k,v in resource['billboard']['channels'].items()}
(ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/procedural_assets.lua').write_text('return '+lua(result)+'\n')
(OUT/'coverage.json').write_text(json.dumps({'billboards':sorted(resources),'textures':textures,
    'unsupportedResources':result['unsupportedResources'],'source':'original files; no captured particle positions'},indent=2)+'\n')
print('Exported',len(resources),'original billboard resources;',len(result['unsupportedResources']),'clump/animation resources require their own player')
