"""Export sparse original animation samples; never substitute scene particles."""
import sys, json, hashlib, traceback, os
from pathlib import Path
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0,str(ROOT))
import renderdoc as rd
from export_frame_constants import export
run_directory=os.environ.get('STORM_CAPTURE_RUN_DIR')
folder=Path(run_directory) if run_directory else ROOT/'gpu_captures'
log=folder/'sequence_progress.txt'
known={x['compressed_sha256']:x for x in json.loads((ROOT/'gpu_captures/asset_matches.json').read_text())}

def actions(items):
    for a in items:
        yield a
        yield from actions(a.children)

try:
    paths=sorted(folder.glob('*.rdc' if run_directory else 'itachi_amaterasu_frame*.rdc'))
    for path in paths:
        destination=path.with_suffix('.sequence_geometry.json')
        if destination.exists(): continue
        log.write_text('Opening '+path.name)
        capture=rd.OpenCaptureFile()
        status=capture.OpenFile(str(path),'',None)
        if status.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(status))
        status,c=capture.OpenCapture(rd.ReplayOptions(),None)
        if status.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(status))
        try:
            record_path=path.with_suffix('.all_draws.json')
            records=json.loads(record_path.read_text()) if record_path.exists() else export(c,record_path,True,False)
            selected={d['event']:d for d in records if d['constants'].get('ShaderStage.Vertex',{}).get('perMaterialBuffer',{}).get('fields',{}).get('g_uvScaleScreen')}
            texture_matches={}
            output=[]
            for a in actions(c.GetRootActions()):
                if a.eventId not in selected: continue
                c.SetFrameEvent(a.eventId,True)
                p=c.GetPipelineState()
                bindings=list(p.GetReadOnlyResources(rd.ShaderStage.Pixel))
                if not bindings: continue
                rid=bindings[0].descriptor.resource
                if str(rid) not in texture_matches:
                    digest=hashlib.sha256(bytes(c.GetTextureData(rid,rd.Subresource()))).hexdigest()
                    texture_matches[str(rid)]=known.get(digest)
                match=texture_matches[str(rid)]
                if not match or match['asset'] not in ('4efb_amt00','4efb_amt01'): continue
                d=dict(selected[a.eventId])
                d['base_asset']=match['asset']
                d['action']={k:getattr(a,k) for k in ('numIndices','numInstances','baseVertex','vertexOffset','indexOffset','instanceOffset')}
                d['indexed']=bool(a.flags&rd.ActionFlags.Indexed)
                d['topology']=str(p.GetPrimitiveTopology())
                d['inputs']=[{'name':v.name,'buffer':v.vertexBuffer,'offset':v.byteOffset,'format':v.format.Name(),'components':v.format.compCount,'width':v.format.compByteWidth,'type':str(v.format.compType)} for v in p.GetVertexInputs() if v.used]
                d['vertices']=[]
                for b in p.GetVBuffers():
                    if b.resourceId==rd.ResourceId.Null():
                        d['vertices'].append(None)
                    else:
                        raw=bytes(c.GetBufferData(b.resourceId,b.byteOffset,b.byteSize))
                        d['vertices'].append({'stride':b.byteStride,'raw_hex':raw.hex()})
                if d['indexed']:
                    b=p.GetIBuffer()
                    raw=bytes(c.GetBufferData(b.resourceId,b.byteOffset+a.indexOffset*b.byteStride,a.numIndices*b.byteStride))
                    d['index']={'stride':b.byteStride,'raw_hex':raw.hex()}
                d['verified_textures']=[]
                for b in bindings:
                    rid=b.descriptor.resource
                    if str(rid) not in texture_matches:
                        digest=hashlib.sha256(bytes(c.GetTextureData(rid,rd.Subresource()))).hexdigest()
                        texture_matches[str(rid)]=known.get(digest)
                    verified=texture_matches[str(rid)]
                    if not verified: raise RuntimeError('Unexpected film texture '+str(rid))
                    d['verified_textures'].append(verified['gpu_resource'])
                output.append(d)
            destination.write_text(json.dumps(output,indent=2))
            log.write_text(path.name+': '+str(len(output))+' verified original draws exported')
        finally:
            c.Shutdown()
            capture.Shutdown()
    log.write_text('Complete: '+str(len(paths))+' original animation samples exported')
except Exception:
    log.write_text(traceback.format_exc())
raise SystemExit(0)
