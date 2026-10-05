"""Continuous reconstruction of measured states with original atlas keys.

Particle identities are inferred, not recovered engine IDs. Positions between
observations are interpolated; this does not claim a full particle simulation.
"""
import json,struct,math
from pathlib import Path
import numpy as np
from build_runtime_data import lua
ROOT=Path(__file__).resolve().parent
CAP=ROOT/'gpu_captures'
OUT=ROOT.parent/'storm_amaterasu_lab/lua/storm_amt_lab/motion_timeline_data.lua'
numbers=[22082,22102,22127,22136,22149,22171,22200]
# These phase differences follow persistent, unclamped amt00 atlas keys.
# They constrain identity matching; playback retains the existing frame spacing.
phases=[0,10,22,27,33,44,56]
center=np.array(json.loads((CAP/'captured_frame_summary.json').read_text())['original_center'])
boards={Path(b['source']).stem:b for b in json.loads((ROOT/'captured_assets/billboard_arrays.json').read_text())}
models={}
snapshots=[]
tracks=[]

def fields(d):return {k:v['values'] for k,v in d['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields'].items()}
def attribute(d,a,index):
    b=d['vertices'][a['buffer']];raw=bytes.fromhex(b['raw_hex']);offset=index*b['stride']+a['offset']
    if a['type']=='CompType.Float':return struct.unpack_from('<'+'f'*a['components'],raw,offset)
    if a['type']=='CompType.UNorm':return tuple(v/255 for v in raw[offset:offset+a['components']])
    raise ValueError(a)

for index,number in enumerate(numbers):
    draws=json.loads((CAP/f'itachi_amaterasu_frame{number}.sequence_geometry.json').read_text())
    records=json.loads((CAP/f'itachi_amaterasu_frame{number}.all_draws.json').read_text())
    matches={x['event']:x for x in json.loads((ROOT/f'captured_assets/gpu_billboard_matches_{number}.json').read_text())}
    ref=next(d for d in records if d['targets'][0]==draws[0]['targets'][0] and 'g_matWorld' in fields(d) and 'g_matWorldViewProj' in fields(d))
    f=fields(ref);vp=np.linalg.inv(np.array(f['g_matWorld']).reshape(4,4))@np.array(f['g_matWorldViewProj']).reshape(4,4)
    inv=np.linalg.inv(vp)
    right=inv[0,:3]/np.linalg.norm(inv[0,:3]);up=inv[1,:3]/np.linalg.norm(inv[1,:3]);up-=right*np.dot(up,right);up/=np.linalg.norm(up)
    basis=np.array([right,up,np.cross(right,up)])
    states=[]
    for d in draws:
        candidates={c['resource']:c['key'] for c in matches[d['event']]['candidates']}
        assert candidates,'Unidentified original billboard'
        f=fields(d);transform=np.array(f['g_matWorldViewProj']).reshape(4,4)@inv
        assert np.max(np.abs(transform[:3,3]))<1e-4
        bmatrix=transform[:3,:3]@basis.T
        attrs={a['name']:a for a in d['inputs']}
        if d['indexed']:
            ib=d['index'];count=d['action']['numIndices'];raw=bytes.fromhex(ib['raw_hex'])
            ids=[v+d['action']['baseVertex'] for v in struct.unpack('<'+('H' if ib['stride']==2 else 'I')*count,raw)]
        else:ids=list(range(d['action']['vertexOffset'],d['action']['vertexOffset']+d['action']['numIndices']))
        if d['topology']=='Topology.TriangleStrip':ids=[v for i in range(len(ids)-2) for v in ((ids[i+1],ids[i],ids[i+2]) if i%2 else (ids[i],ids[i+1],ids[i+2]))]
        else:assert d['topology']=='Topology.TriangleList'
        vertices=[]
        for vertex in ids:
            xyz=attribute(d,attrs['POSITION'],vertex)[:3];uv=attribute(d,attrs['TEXCOORD'],vertex)[:2];rgba=attribute(d,attrs['COLOR'],vertex)
            vertices.append(list(xyz)+list(uv)+list(rgba))
            world=np.array(xyz)@transform[:3,:3]+transform[3,:3]
            recovered=(np.array(xyz)@bmatrix)@basis+transform[3,:3]
            assert np.max(np.abs(world-recovered))<1e-5
        model_id=str(d['verified_textures'][0])+'_'+str(matches[d['event']]['vertex_count'])
        if model_id in models:assert np.allclose(models[model_id]['vertices'],vertices,atol=1e-6)
        else:models[model_id]={'vertices':vertices,'texture':d['verified_textures'][0]}
        assert abs(f['g_fogParam'][2])<1e-6,'Animated shader assumes captured main-pass fog is disabled'
        states.append({'event':d['event'],'model':model_id,'candidates':candidates,
            'origin':list(transform[3,:3]-center),'basis':bmatrix.flatten().tolist(),
            'tint':[f['g_multColor'][i]*f['g_ambientColor'][i] for i in range(3)],
            'uvScale':f['g_uvScaleScreen'][:2],'scroll':f['g_uvOffsetScreen'][:2],
            'film':f['g_uvOffset3'][0],'threshold':f['g_commonParam'][0],'opacity':f['g_commonParam'][1]})
    # Greedy constrained links, with original resource and age continuity.
    proposals=[]
    if snapshots:
        for a in snapshots[-1]['states']:
            track=tracks[a['track']-1]
            for b_index,b in enumerate(states):
                if a['model']!=b['model']:continue
                common=track['resources']&set(b['candidates'])
                if not common:continue
                errors=[]
                for name in common:
                    ka=a['candidates'][name];kb=b['candidates'][name];last=boards[name]['header']['count']-1
                    expected=min(last,ka+phases[index]-phases[index-1])
                    errors.append(abs(kb-expected))
                if min(errors)>2:continue
                distance=np.linalg.norm(np.array(a['origin'])-np.array(b['origin']))
                scale=np.linalg.norm(np.array(a['basis'])-np.array(b['basis']))
                if distance>250:continue
                proposals.append((min(errors)*1000+distance+scale*20,a['track'],b_index,common))
    used_tracks=set();used_states=set()
    for score,tid,b_index,common in sorted(proposals,key=lambda p:p[0]):
        if tid in used_tracks or b_index in used_states:continue
        used_tracks.add(tid);used_states.add(b_index);states[b_index]['track']=tid;tracks[tid-1]['resources']=common
    for state in states:
        if 'track' not in state:
            tracks.append({'resources':set(state['candidates'])});state['track']=len(tracks)
    snapshots.append({'time':(number-numbers[0])/60,'frame':number,'states':states})

for track in tracks:track['resource']=sorted(track['resources'])[0]
used_boards={}
for snapshot in snapshots:
    for state in snapshot['states']:
        resource=tracks[state['track']-1]['resource']
        state['key']=state.pop('candidates')[resource]
        state['resource']=resource
        bb=boards[resource];groups={a['group']:a for a in bb['arrays']}
        if resource not in used_boards:
            keys=[]
            for k in range(bb['header']['count']):
                offset=groups[4];scale=groups[5]
                uv=list(struct.unpack_from('>2f',bytes.fromhex(offset['raw_hex']),min(k,offset['count']-1)*8))+list(struct.unpack_from('>2f',bytes.fromhex(scale['raw_hex']),min(k,scale['count']-1)*8))
                keys.append(uv)
            used_boards[resource]=keys
result={'models':models,'billboards':used_boards,'snapshots':snapshots,'duration':snapshots[-1]['time'],
        'cameraYaw':31.42391621604697,'version':'continuous-r6','method':'original atlas keys; inferred particle links; interpolated measured transforms'}
result=json.loads(json.dumps(result)) # NumPy scalars must serialize as plain Lua numbers.
OUT.write_text('return '+lua(result)+'\n')
report={'tracks':len(tracks),'models':len(models),'states':[len(s['states']) for s in snapshots],
        'linked_transitions':sum(len({s['track'] for s in snapshots[i]['states']}&{s['track'] for s in snapshots[i+1]['states']}) for i in range(6)),
        'method':result['method']}
(ROOT/'captured_assets/motion_timeline_summary.json').write_text(json.dumps(report,indent=2))
print(report)
