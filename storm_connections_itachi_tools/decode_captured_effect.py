"""Decode the effect asset identified by the original GPU atlas bindings."""
import json,struct
from pathlib import Path
from xfbin_chunks import parse
from inspect_page_refs import table,resolve
from particle_graph import chunk_graph
from decode_billboards import decode as billboard
from decode_particle_records import decode as particle
from decode_effect_animation import decode as animation
from analyze_effect import analyze
import decode_particle_semantics as semantics
ROOT=Path(__file__).resolve().parent
OUT=ROOT/'captured_assets'
SOURCE=OUT/'data/effect/4efb_amt1.xfbin'
data,chunks=parse(SOURCE)
for c in chunks:
    target=OUT/'chunks/4efb_amt1'/c['type']/(c['name']+'.bin')
    target.parent.mkdir(parents=True,exist_ok=True)
    target.write_bytes(data[c['offset']:c['offset']+c['size']])
def write(name,value): (OUT/name).write_text(json.dumps(value,indent=2)+'\n')
t=table(data)
graphs=[chunk_graph(data,t,c,OUT/'chunks/4efb_amt1/nuccChunkParticle') for c in chunks if c['type']=='nuccChunkParticle']
write('particle_graph.json',graphs)
write('particle_records_typed.json',[particle(OUT/'chunks/4efb_amt1/nuccChunkParticle'/(c['name']+'.bin')) for c in chunks if c['type']=='nuccChunkParticle'])
semantics.ROOT=OUT
semantics.main()
write('billboard_arrays.json',[billboard(OUT/'chunks/4efb_amt1/nuccChunkBillboard'/(c['name']+'.bin')) for c in chunks if c['type']=='nuccChunkBillboard'])
write('materials.json',analyze(SOURCE))
types,paths,names,maps,indices=t
counts=struct.unpack_from('>10I',data,28)
ref_start=((68+counts[1]+counts[3]+counts[5]+3)&~3)+counts[7]
ref_pairs=[struct.unpack_from('>II',data,ref_start+i*8) for i in range(counts[9])]
page_refs={};cursor=0
for c in chunks:
    if c['type']=='nuccChunkPage':
        count=struct.unpack_from('>I',data,c['offset']+4)[0]
        page_refs[c['page']]=ref_pairs[cursor:cursor+count];cursor+=count
anms={}
for c in chunks:
    if c['type']!='nuccChunkAnm': continue
    version=struct.unpack_from('>H',data,c['offset']-4)[0]
    if version<=0x65: raise ValueError('Unsupported legacy animation')
    ref=(lambda i:resolve(t,c['page']+i)[2]) if version<=0x67 else (lambda i:names[page_refs[c['page']][i][0]])
    anms[c['name']]=animation(data[c['offset']:c['offset']+c['size']],ref)
write('effect_animation.json',anms)
for g in graphs:
    print(g['name'],'emitters',len(g['emitters']))
    for e in g['emitters']: print(' ',e['index'],[r['name'] for r in e['resources']])
print('Decoded billboards',sum(c['type']=='nuccChunkBillboard' for c in chunks),'animations',len(anms))
