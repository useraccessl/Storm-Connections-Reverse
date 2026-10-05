"""Preserve original spatial bindings and force fields; no inferred trajectories."""
import json, struct
from pathlib import Path
ROOT=Path(__file__).resolve().parent
SOURCE=ROOT/'captured_assets'
typed=json.loads((SOURCE/'particle_records_typed.json').read_text())
graphs={x['name']:x for x in json.loads((SOURCE/'particle_graph.json').read_text())}
animations=json.loads((SOURCE/'effect_animation.json').read_text())
result={}
for chunk in typed:
    name=Path(chunk['source']).stem
    emitters={e['index']:e for e in graphs[name]['emitters']}
    attachments=[]
    section=chunk['sections'][2]
    raw=bytes.fromhex(section['raw_hex'])
    assert len(raw)==section['count']*56
    seen={}
    for i in range(section['count']):
        body=raw[i*56:(i+1)*56]
        ref,eid=struct.unpack_from('>2I',body)
        ordinal=seen.get(eid,0)
        seen[eid]=ordinal+1
        resolved=emitters[eid]['attachments'][ordinal]
        assert resolved['coord_page_index']==ref
        attachments.append({'emitter':eid,'coord':resolved['coord'],'clump':resolved['clump'],
                            'raw_hex':body.hex(),'file_offset':section['file_offset']+i*56})
    forces=[]
    section=chunk['sections'][3]
    raw=bytes.fromhex(section['raw_hex'])
    assert len(raw)==section['count']*112
    seen={}
    for i in range(section['count']):
        body=raw[i*112:(i+1)*112]
        ref,eid=struct.unpack_from('>2I',body)
        ordinal=seen.get(eid,0)
        seen[eid]=ordinal+1
        resolved=emitters[eid]['force_fields'][ordinal]
        assert resolved['page_index']==ref
        forces.append({'emitter':eid,'coord':resolved['name'],'raw_hex':body.hex(),
            'file_offset':section['file_offset']+i*112,
            'selector':body[0x30], 'world_direction':bool(body[0x31]),
            'limit_radius':bool(body[0x32]),
            'radius_base':struct.unpack_from('>f',body,0x38)[0],
            'falloff_mode':struct.unpack_from('>I',body,0x3c)[0],
            'strength':struct.unpack_from('>f',body,0x40)[0],
            'strength_multiplier':struct.unpack_from('>f',body,0x44)[0],
            'vector_parameter':list(struct.unpack_from('>3f',body,0x50))})
    result[name]={'attachments':attachments,'forces':forces}
    print(name,len(attachments),'spatial bindings',len(forces),'force fields')
(SOURCE/'spatial_records.json').write_text(json.dumps(result,indent=2)+'\n')
summary={}
for name,a in animations.items():
    transforms=[e for e in a['entries'] if e['type']==1]
    translations=[c for e in transforms for c in e['curves'] if c['index']==0]
    rotations=[c for e in transforms for c in e['curves'] if c['index']==1]
    summary[name]={'duration_ticks':a['duration_ticks'],'transform_targets':len(transforms),
        'constant_translations':sum(len(c['values'])==1 for c in translations),
        'animated_rotations':sum(len(c['values'])>2 for c in rotations)}
(SOURCE/'motion_curve_summary.json').write_text(json.dumps(summary,indent=2)+'\n')
