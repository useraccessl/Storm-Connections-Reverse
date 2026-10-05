"""Validate auxiliary textures/geometry against the seven existing captures.

This is a reference export for verifying the procedural port, not new captures
and not an animation playback substitute.
"""
import sys,json,hashlib,struct,traceback
from pathlib import Path
import renderdoc as rd
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
folder=ROOT/'gpu_captures'
log=folder/'coverage_reference_progress.txt'
known={}
for path in (ROOT/'captured_assets/procedural/textures').glob('*.nut'):
    nut=path.read_bytes()
    start=16+struct.unpack_from('>H',nut,28)[0]
    vtf=(ROOT.parent/'storm_amaterasu_lab/materials/storm_amt_lab'/('procedural_'+path.stem+'.vtf')).read_bytes()
    known[hashlib.sha256(vtf[80:]).hexdigest()]=path.stem
def actions(items):
    for a in items:
        yield a
        yield from actions(a.children)
try:
    for path in sorted(folder.glob('itachi_amaterasu_frame*.rdc')):
        outpath=path.with_suffix('.effect_coverage_reference.json')
        if outpath.exists(): continue
        log.write_text('Opening '+path.name)
        capture=rd.OpenCaptureFile()
        result=capture.OpenFile(str(path),'',None)
        if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
        result,c=capture.OpenCapture(rd.ReplayOptions(),None)
        if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
        try:
            records=json.loads(path.with_suffix('.all_draws.json').read_text())
            selected={d['event']:d for d in records if d['textures']}
            matched={}
            output=[]
            for a in actions(c.GetRootActions()):
                if a.eventId not in selected: continue
                c.SetFrameEvent(a.eventId,True)
                p=c.GetPipelineState()
                bindings=list(p.GetReadOnlyResources(rd.ShaderStage.Pixel))
                if not bindings: continue
                rid=bindings[0].descriptor.resource
                if str(rid) not in matched:
                    digest=hashlib.sha256(bytes(c.GetTextureData(rid,rd.Subresource()))).hexdigest()
                    matched[str(rid)]=known.get(digest)
                asset=matched[str(rid)]
                if asset is None: continue
                d=dict(selected[a.eventId])
                d['base_asset']=asset
                d['action']={k:getattr(a,k) for k in ('numIndices','numInstances','baseVertex','vertexOffset','indexOffset','instanceOffset')}
                d['indexed']=bool(a.flags&rd.ActionFlags.Indexed)
                d['topology']=str(p.GetPrimitiveTopology())
                d['inputs']=[{'name':v.name,'buffer':v.vertexBuffer,'offset':v.byteOffset,'format':v.format.Name(),'components':v.format.compCount,'width':v.format.compByteWidth,'type':str(v.format.compType)} for v in p.GetVertexInputs() if v.used]
                d['vertices']=[]
                for b in p.GetVBuffers():
                    if b.resourceId==rd.ResourceId.Null(): d['vertices'].append(None)
                    else: d['vertices'].append({'stride':b.byteStride,'raw_hex':bytes(c.GetBufferData(b.resourceId,b.byteOffset,b.byteSize)).hex()})
                if d['indexed']:
                    b=p.GetIBuffer()
                    d['index']={'stride':b.byteStride,'raw_hex':bytes(c.GetBufferData(b.resourceId,b.byteOffset+a.indexOffset*b.byteStride,a.numIndices*b.byteStride)).hex()}
                output.append(d)
            outpath.write_text(json.dumps(output,indent=2))
            log.write_text(path.name+': '+str(len(output))+' verified auxiliary draws')
        finally:
            c.Shutdown()
            capture.Shutdown()
    log.write_text('Complete: seven captures; original effect textures matched by native block SHA256, independent of shader selection')
except Exception: log.write_text(traceback.format_exc())
raise SystemExit(0)
