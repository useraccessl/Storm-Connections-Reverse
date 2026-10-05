"""Export the remaining five resource inputs, without inventing their players."""
import json,struct,hashlib
from pathlib import Path
from xfbin_chunks import parse
from inspect_nud import parse_nud
from export_effect_obj import get_vertices,triangles
from analyze_effect import analyze
from build_runtime_data import lua
from nut_to_vtf import convert
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'captured_assets/procedural'
archives=[(p,*parse(p)) for p in (ROOT/'captured_assets/data/effect/4efb_amt1.xfbin',ROOT/'extracted/data/effect/1efcmn.xfbin')]
names={'4efb_amt15','4efb_light00','1efc_fire03a','1efc_shock09','1efc_nor_dst03'}
textures={c['name']:d[c['offset']:c['offset']+c['size']] for _,d,cs in archives for c in cs if c['type']=='nuccChunkTexture'}
result={'models':{},'textures':{},'animation':json.loads((ROOT/'captured_assets/effect_animation.json').read_text())['4efb_amt1_ptc02']}
for path,data,chunks in archives:
    mats=analyze(path,','.join(sorted(names)))['materials']
    for c in chunks:
        if c['type']!='nuccChunkModel' or c['name'] not in names: continue
        body=data[c['offset']:c['offset']+c['size']]
        nud=body[body.index(b'NDP3'):]
        model={'meshes':[],'materials':[m for m in mats if m['name']==c['name']]}
        coords=[q for q in chunks if q['type']=='nuccChunkCoord' and q['name']==c['name']]
        model['originalCoords']=[data[q['offset']:q['offset']+q['size']].hex() for q in coords]
        for group in parse_nud(nud)['groups']:
            for m in group['meshes']:
                assert m['vertex_size']==6
                verts=get_vertices(nud,m)
                n=m['uv_size']>>4
                stride=24+n*4
                vertices=[];uvs=[];normals=[]
                for i,v in enumerate(verts):
                    offset=m['vertex_offset']+i*stride
                    color=[x/255 for x in nud[offset+20:offset+24]]
                    vertices.append(list(v)+color)
                    uvs.append([list(struct.unpack_from('>2e',nud,offset+24+j*4)) for j in range(n)])
                    normals.append(nud[offset+12:offset+20].hex())
                faces=struct.unpack_from('>'+'h'*m['face_count'],nud,m['poly_offset'])
                model['meshes'].append({'vertices':vertices,'uvSets':uvs,'normalHalfRaw':normals,
                    'triangles':[list(t) for t in triangles(faces,len(verts))],
                    'originalRenderState':m['materials'],'singleBind':group['single_bind']})
        result['models'][c['name']]=model
        for mat in model['materials']:
            for g in mat['texture_groups']:
                for t in g['textures']:
                    name=t['name']
                    if name in result['textures']: continue
                    raw=textures[name];size=struct.unpack_from('>I',raw,8)[0]
                    nut=raw[12:12+size]
                    dest=OUT/'textures'/(name+'.nut');dest.write_bytes(nut)
                    vtf=ROOT.parent/'storm_amaterasu_lab/materials/storm_amt_lab'/('procedural_'+name+'.vtf')
                    native=convert(dest,vtf)
                    result['textures'][name]={'nativeVTF':native,'sourceTexture':'storm_amt_lab/procedural_'+name,
                        'path':str(dest),'sha256':hashlib.sha256(nut).hexdigest()}
        print(c['name'],sum(len(m['vertices']) for m in model['meshes']),'vertices',len(model['materials']),'material records')
assert set(result['models'])==names
result=json.loads(json.dumps(result))
(ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/auxiliary_assets.lua').write_text('return '+lua(result)+'\n')
(OUT/'auxiliary_resources.json').write_text(json.dumps(result,indent=2)+'\n')
print('Five auxiliary model inputs exported; resource players and distortion pass still require integration')
