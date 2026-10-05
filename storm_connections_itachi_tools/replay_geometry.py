"""Export actual input geometry and atlas textures for identified Amaterasu draws."""
import sys, json, traceback
from pathlib import Path
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0,str(ROOT))
import renderdoc as rd
folder=ROOT/'gpu_captures'
log=folder/'geometry_progress.txt'
def actions(items):
    for a in items:
        yield a
        yield from actions(a.children)
try:
    path=folder/'itachi_amaterasu_frame22136.rdc'
    records=json.loads(path.with_suffix('.all_draws.json').read_text())
    selected={d['event']:d for d in records if d['constants'].get('ShaderStage.Vertex',{}).get('perMaterialBuffer',{}).get('fields',{}).get('g_uvScaleScreen')}
    capture=rd.OpenCaptureFile()
    result=capture.OpenFile(str(path),'',None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    result,c=capture.OpenCapture(rd.ReplayOptions(),None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    output=[]
    textures=set()
    try:
        for a in actions(c.GetRootActions()):
            if a.eventId not in selected: continue
            c.SetFrameEvent(a.eventId,True)
            p=c.GetPipelineState()
            d=dict(selected[a.eventId])
            d['action']={k:getattr(a,k) for k in ('numIndices','numInstances','baseVertex','vertexOffset','indexOffset','instanceOffset')}
            d['indexed']=bool(a.flags&rd.ActionFlags.Indexed)
            d['topology']=str(p.GetPrimitiveTopology())
            d['inputs']=[{'name':v.name,'buffer':v.vertexBuffer,'offset':v.byteOffset,'format':v.format.Name(),'components':v.format.compCount,'width':v.format.compByteWidth,'type':str(v.format.compType)} for v in p.GetVertexInputs() if v.used]
            d['vertices']=[]
            for b in p.GetVBuffers():
                if b.resourceId==rd.ResourceId.Null():
                    d['vertices'].append(None)
                    continue
                raw=bytes(c.GetBufferData(b.resourceId,b.byteOffset,b.byteSize))
                d['vertices'].append({'stride':b.byteStride,'raw_hex':raw.hex()})
            b=p.GetIBuffer()
            if d['indexed']:
                raw=bytes(c.GetBufferData(b.resourceId,b.byteOffset+a.indexOffset*b.byteStride,a.numIndices*b.byteStride))
                d['index']={'stride':b.byteStride,'raw_hex':raw.hex()}
            for used in p.GetReadOnlyResources(rd.ShaderStage.Pixel):
                rid=used.descriptor.resource
                if str(rid) not in textures:
                    save=rd.TextureSave()
                    save.resourceId=rid
                    save.destType=rd.FileType.PNG
                    c.SaveTexture(save,str(folder/('texture_'+str(rid).split('::')[-1]+'.png')))
                    textures.add(str(rid))
            output.append(d)
        (folder/'amaterasu_geometry.json').write_text(json.dumps(output,indent=2))
        log.write_text('Exported '+str(len(output))+' original mesh draws')
    finally:
        c.Shutdown()
        capture.Shutdown()
except Exception:
    log.write_text(traceback.format_exc())
raise SystemExit(0)
