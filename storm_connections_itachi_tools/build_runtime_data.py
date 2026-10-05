"""Export confirmed game parameters to Lua without manual visual tuning."""
import json, argparse
import struct
from pathlib import Path
ROOT = Path(__file__).resolve().parent
OUT = ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/runtime_data.lua'

def lua(v):
    if v is None: return 'nil'
    if isinstance(v,bool): return 'true' if v else 'false'
    if isinstance(v,(float,int)): return repr(v)
    if isinstance(v,str): return json.dumps(v)
    if isinstance(v,list): return '{'+','.join(map(lua,v))+'}'
    return '{'+','.join('['+lua(k)+']='+lua(value) for k,value in v.items())+'}'

def build(source=ROOT, destination=OUT):
    raw = json.loads((source/'particle_semantics.json').read_text())
    graph = json.loads((source/'particle_graph.json').read_text())
    effects = {}
    for effect,g in zip(raw,graph):
        assert effect['name']==g['name']
        emitters=[]
        for e,ge in zip(effect['emitters'],g['emitters']):
            def field(prefix):
                return next(v for k,v in e.items() if k.startswith(prefix))
            emitters.append({'id':e['id'],'resources':e['resources'],
                'attachments':ge['attachments'],'forces':ge['force_fields'],
                'direct':e['emission_kind']=='direct_count',
                'quantity':field('emission_quantity'), 'simulationHz':field('simulation_step'),
                'durationCounter':field('emission_duration'),
                'life':field('base_lifetime'),'lifeRandom':field('lifetime_random'),
                'scalarBase':field('spawn_scalar_base'),'scalarRandom':field('spawn_scalar_random'),
                'fadeIn':field('fade_in'),'fadeOut':field('fade_out'),
                'sizeStart':field('size_start'),'sizeMiddle':field('size_middle_0'),
                'sizeEnd':field('size_end'),'sizeSplit':field('size_middle_life'),
                'sizeRandom':field('size_random'),'independentSizeRandom':bool(field('config_flags')&1),
                'colorStart':field('color_start'),'colorMiddle':field('color_middle_0'),
                'colorEnd':field('color_end'),'colorSplit':field('color_middle_life'),
                'shape':field('shape_selector'),'direction':field('direction_selector'),
                'orientation':field('orientation_selector'),'rotation':field('rotation_selector'),
                'radius':field('spawn_radius'),'radiusRandom':field('spawn_radial_random'),
                'motionSegment':bool(field('config_flags')&0x10),
                'forceMask':ge['raw_words_0_64'][6],
                'speed':field('speed_base'),'speedRandom':field('speed_random'),
                'angles':field('direction_angles'),'angleRanges':field('direction_angle_ranges'),
                'events':e['event_entry']['events']})
        effects[effect['name']]=emitters
    billboards={}
    for b in json.loads((source/'billboard_arrays.json').read_text()):
        channels={}
        for a in b['arrays']:
            if a['count']:
                data=bytes.fromhex(a['raw_hex'])
                fmt='>'+'f'*(a['width']//4)
                channels[a['group']+1]=[list(struct.unpack_from(fmt,data,i*a['width'])) for i in range(a['count'])]
        billboards[Path(b['source']).stem]={'stepTicks':b['header']['unknown_u32'],
             'count':b['header']['count'],'loop':bool(int(b['header']['mask'],16)&1),'channels':channels}
    materials={}
    for m in json.loads((source/'materials.json').read_text())['materials']:
        blocks={}; cursor=0
        for flag,n in ((1,4),(2,4),(4,4),(8,4),(16,2),(32,1),(64,1),(128,1)):
            if m['format']&flag:
                blocks[flag]=m['floats'][cursor:cursor+n];cursor+=n
        assert cursor==len(m['floats'])
        materials[m['name']]={'uv0':blocks.get(1,[0,0,1,1]),'uv1':blocks.get(2,[0,0,1,1]),
           'scroll0':blocks.get(4,[0,0,0,0]),'scroll1':blocks.get(8,[0,0,0,0]),
           'blend':blocks.get(16,[0,0]),'threshold':m['field02']/255,
           'textures':[t['name'] for t in m['texture_groups'][0]['textures']]}
    result={'effects':effects,'billboards':billboards,'materials':materials,
            'animations':json.loads((source/'effect_animation.json').read_text())}
    spatial=source/'spatial_records.json'
    if spatial.exists():
        result['spatialRecords']=json.loads(spatial.read_text())
        for records in result['spatialRecords'].values():
            for r in records['attachments']+records['forces']:
                raw=bytes.fromhex(r['raw_hex'])
                r['direction']=list(struct.unpack_from('>3f',raw,0x10))
                if r in records['attachments']:
                    r['world_direction']=bool(struct.unpack_from('>I',raw,0x20)[0])
                    r['original_connection_field']=struct.unpack_from('>I',raw,0x1c)[0]
    destination.parent.mkdir(parents=True,exist_ok=True)
    destination.write_text('-- Decoded from original game files; do not tune these numbers by eye.\nreturn '+lua(result)+'\n')
    print('Exported',sum(map(len,effects.values())),'emitters,',len(billboards),'billboards,',len(materials),'materials')

if __name__=='__main__':
    ap=argparse.ArgumentParser()
    ap.add_argument('--captured',action='store_true')
    args=ap.parse_args()
    build(ROOT/'captured_assets',OUT.with_name('captured_runtime_data.lua')) if args.captured else build()
