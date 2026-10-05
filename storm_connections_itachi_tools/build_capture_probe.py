"""Build a frozen GPU frame probe from actual captured geometry, not emitters."""
import json, struct, math, sys
from pathlib import Path
import numpy as np
from png_to_vtf import convert
ROOT=Path(__file__).resolve().parent
CAP=ROOT/'gpu_captures'
ADDON=ROOT.parent/'storm_amaterasu_lab'
sample=int(sys.argv[1]) if len(sys.argv)>1 else None
records=json.loads((CAP/('itachi_amaterasu_frame'+str(sample or 22136)+'.all_draws.json')).read_text())
draws=json.loads((CAP/('itachi_amaterasu_frame'+str(sample)+'.sequence_geometry.json' if sample else 'amaterasu_geometry.json')).read_text())
def fields(d): return {k:v['values'] for k,v in d['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields'].items()}
target=draws[0]['targets'][0] if sample else 'ResourceId::45595'
reference=next(d for d in records if d['targets'][0]==target and 'g_matWorld' in fields(d) and 'g_matWorldViewProj' in fields(d))
f=fields(reference)
vp=np.linalg.inv(np.array(f['g_matWorld']).reshape(4,4))@np.array(f['g_matWorldViewProj']).reshape(4,4)
inverse=np.linalg.inv(vp)
near=np.array([0,0,0,1])@inverse; near=near[:3]/near[3]
far=np.array([0,0,.99,1])@inverse; far=far[:3]/far[3]
forward=far-near
camera_yaw=math.degrees(math.atan2(forward[1],forward[0]))
camera_right=inverse[0,:3]/np.linalg.norm(inverse[0,:3])
camera_up=inverse[1,:3]/np.linalg.norm(inverse[1,:3])
camera_up-=camera_right*np.dot(camera_up,camera_right)
camera_up/=np.linalg.norm(camera_up)
camera_normal=np.cross(camera_right,camera_up)
camera_basis=np.array([camera_right,camera_up,camera_normal])
def attribute(d,a,index):
    b=d['vertices'][a['buffer']]
    raw=bytes.fromhex(b['raw_hex'])
    offset=index*b['stride']+a['offset']
    if a['type']=='CompType.Float' and a['width']==4:
        return struct.unpack_from('<'+'f'*a['components'],raw,offset)
    if a['type']=='CompType.UNorm' and a['width']==1:
        return tuple(x/255 for x in raw[offset:offset+a['components']])
    raise ValueError(a)
output=[]
all_positions=[]
for d in draws:
    f=fields(d)
    transform=np.array(f['g_matWorldViewProj']).reshape(4,4)@inverse
    assert np.max(np.abs(transform[:3,3]))<1e-4 and abs(transform[3,3]-1)<1e-3, 'Recovered mesh transform is not affine'
    if d['indexed']:
        b=d['index']; raw=bytes.fromhex(b['raw_hex'])
        indices=struct.unpack('<'+('H' if b['stride']==2 else 'I')*d['action']['numIndices'],raw)
        indices=[i+d['action']['baseVertex'] for i in indices]
    else:
        indices=list(range(d['action']['vertexOffset'],d['action']['vertexOffset']+d['action']['numIndices']))
    if d['topology']=='Topology.TriangleStrip':
        indices=[v for i in range(len(indices)-2) for v in ((indices[i+1],indices[i],indices[i+2]) if i%2 else (indices[i],indices[i+1],indices[i+2]))]
    elif d['topology']!='Topology.TriangleList': raise ValueError(d['topology'])
    vertices=[]
    facing_vertices=[]
    inputs={a['name']:a for a in d['inputs']}
    for index in indices:
        local=attribute(d,inputs['POSITION'],index)
        pos=np.array(list(local[:3])+[1])@transform
        pos=pos[:3]/pos[3]
        all_positions.append(pos)
        color=attribute(d,inputs['COLOR'],index)
        uv=attribute(d,inputs['TEXCOORD'],index)
        vertices.append(list(pos)+[uv[0]*f['g_uvOffset0'][2]+f['g_uvOffset0'][0],uv[1]*f['g_uvOffset0'][3]+f['g_uvOffset0'][1]]+[color[i]*f['g_multColor'][i]*f['g_ambientColor'][i] for i in range(3)]+[color[3]])
        facing=(pos-transform[3,:3])@camera_basis.T
        assert np.max(np.abs(facing@camera_basis+transform[3,:3]-pos))<1e-5
        facing_vertices.append(list(facing)+vertices[-1][3:])
    fog=f['g_fogParam']
    clip_w=f['g_matWorldViewProj'][15]
    fog_factor=1 if fog[2]==0 else 1+fog[2]*(max(0,min(1,(fog[1]-clip_w)/(fog[1]-fog[0])))-1)
    output.append({'event':d['event'],'vertices':vertices,'facing_vertices':facing_vertices,
                   'origin':list(transform[3,:3]),'constants':f,'fog':fog_factor,'textures':d.get('verified_textures',[t['resource'].split('::')[-1] for t in d['textures']])})
positions=np.array(all_positions)
print('World bounds:',positions.min(axis=0),positions.max(axis=0),'reference',reference['event'])
print('Billboard up:',(np.array(fields(draws[2])['g_matWorldViewProj']).reshape(4,4)@inverse)[1,:3])
# Game world uses Z up (confirmed by recovered billboard up and character world transform).
center=(positions.min(axis=0)+positions.max(axis=0))/2
center[2]=positions[:,2].min()
if sample:
    center=np.array(json.loads((CAP/'captured_frame_summary.json').read_text())['original_center'])
for d in output:
    d['origin']=[round(float(d['origin'][i]-center[i]),6) for i in range(3)]
    for v in d['facing_vertices']:
        for i in range(len(v)): v[i]=round(float(v[i]),7)
    for v in d['vertices']:
        for i in range(3): v[i]=round(float(v[i]-center[i]),6)
        for i in range(3,len(v)): v[i]=round(float(v[i]),7)
texture_ids={t for d in output for t in d['textures']}
for tid in sorted(texture_ids): convert(CAP/('texture_'+tid+'.png'),ADDON/'materials/storm_amt_lab'/('capture_'+tid+'.vtf'))
def lua(v):
    if isinstance(v,dict): return '{'+','.join('['+json.dumps(k)+']='+lua(x) for k,x in v.items())+'}'
    if isinstance(v,list): return '{'+','.join(lua(x) for x in v)+'}'
    if isinstance(v,str): return json.dumps(v)
    return repr(v)
name='captured_sample_'+str(sample) if sample else 'captured_frame'
(ADDON/('lua/storm_amt_lab/'+name+'.lua')).write_text('local frame='+lua(output)+'\nframe.cameraYaw='+repr(camera_yaw)+'\nreturn frame\n')
(CAP/(name+'_summary.json')).write_text(json.dumps({'reference_event':reference['event'],'original_center':center.tolist(),'bounds_min':positions.min(axis=0).tolist(),'bounds_max':positions.max(axis=0).tolist(),'draws':len(output),'textures':sorted(texture_ids)},indent=2))
if sample: raise SystemExit(0)
for d in output:
    tex=d['textures']
    mat='"screenspace_general"\n{\n"$pixshader" "amt_projected_ps30"\n"$basetexture" "storm_amt_lab/capture_'+tex[0]+'"\n"$texture1" "storm_amt_lab/capture_'+tex[1]+'"\n"$texture2" "storm_amt_lab/capture_'+tex[-1]+'"\n"$x360appchooser" "1"\n"$vertexcolor" "1"\n"$copyalpha" "1"\n"$alpha_blend" "0"\n"$depthtest" "1"\n"$cull" "0"\n"$softwareskin" "1"\n}\n'
    (ADDON/'materials/storm_amt_lab'/('captured_'+str(d['event'])+'.vmt')).write_text(mat)
print('Built frozen GPU geometry:',len(output),'draws')
