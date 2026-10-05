import json,traceback
from pathlib import Path
import renderdoc as rd
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
OUT=ROOT/'gpu_captures/material_pipeline_reference.json'
def value(obj,depth=0):
 if obj is None or isinstance(obj,(bool,int,float,str)):return obj
 if depth>4:return str(obj)
 if isinstance(obj,(list,tuple)) or hasattr(obj,'__len__') and hasattr(obj,'__getitem__'):return [value(x,depth+1) for x in list(obj)[:32]]
 result={}
 for key in dir(obj):
  if key.startswith('_') or key in ('this','thisown'):continue
  try:
   v=getattr(obj,key)
   if callable(v):continue
   result[key]=value(v,depth+1)
  except Exception:pass
 return result or str(obj)
try:
 capture=rd.OpenCaptureFile();r=capture.OpenFile(str(ROOT/'gpu_captures/itachi_amaterasu_frame22136.rdc'),'',None)
 if r.code!=rd.ResultCode.Succeeded:raise RuntimeError(str(r))
 r,c=capture.OpenCapture(rd.ReplayOptions(),None)
 if r.code!=rd.ResultCode.Succeeded:raise RuntimeError(str(r))
 try:
  textures={str(x.resourceId):{'width':x.width,'height':x.height,'format':x.format.Name()} for x in c.GetTextures()}
  output={}
  for event in [5302, 2102, 5315, 6241, 7896, 8037, 8076, 8185, 9378, 9419]:
   c.SetFrameEvent(event,True);p=c.GetPipelineState();d=c.GetD3D11PipelineState()
   targets=p.GetOutputTargets()
   output[str(event)]={'targets':value(targets),'targetTextures':[{ 'id':str(t.resource),**textures.get(str(t.resource),{})} for t in targets],
     'viewport':value(p.GetViewport(0)),'samplers':value(p.GetSamplers(rd.ShaderStage.Pixel)),
     'outputMerger':value(d.outputMerger),'rasterizer':value(d.rasterizer)}
  OUT.write_text(json.dumps(output,indent=2))
  rows={d['event']:d for d in json.loads((ROOT/'gpu_captures/itachi_amaterasu_frame22136.all_draws.json').read_text())}
  def actions(items):
   for a in items:
    yield a
    yield from actions(a.children)
  actionmap={a.eventId:a for a in actions(c.GetRootActions())}
  chain={}
  for target in c.GetPipelineState().GetOutputTargets()[:3]:
   rid=target.resource
   if rid==rd.ResourceId.Null():continue
   chain[str(rid)]=[]
   for u in c.GetUsage(rid):
    a=actionmap.get(u.eventId)
    chain[str(rid)].append({'event':u.eventId,'usage':str(u.usage),'name':a.customName if a else None,'draw':rows.get(u.eventId,{}).get('shaders')})
  (ROOT/'gpu_captures/material_compositing_chain.json').write_text(json.dumps(chain,indent=2))
  # Follow later consumers of the effect's color/parameter attachments.
  queue=[t.resource for t in c.GetPipelineState().GetOutputTargets()[:2]]
  seen_resources=set();seen_events=set();graph=[]
  while queue and len(seen_events)<80:
   rid=queue.pop(0)
   if str(rid) in seen_resources or rid==rd.ResourceId.Null():continue
   seen_resources.add(str(rid))
   for u in c.GetUsage(rid):
    if u.usage!=rd.ResourceUsage.PS_Resource or u.eventId<7054 or u.eventId in seen_events:continue
    seen_events.add(u.eventId);c.SetFrameEvent(u.eventId,True);p=c.GetPipelineState()
    inputs=[{'slot':b.access.index,'resource':str(b.descriptor.resource)} for b in p.GetReadOnlyResources(rd.ShaderStage.Pixel)]
    targets=[t.resource for t in p.GetOutputTargets() if t.resource!=rd.ResourceId.Null()]
    graph.append({'event':u.eventId,'from':str(rid),'inputs':inputs,'outputs':[str(x) for x in targets],
      'shader':rows.get(u.eventId,{}).get('shaders',{}).get('ShaderStage.Pixel'),'viewport':value(p.GetViewport(0))})
    queue.extend(targets)
  (ROOT/'gpu_captures/material_postprocess_graph.json').write_text(json.dumps(sorted(graph,key=lambda x:x['event']),indent=2))

 finally:c.Shutdown();capture.Shutdown()
except Exception:OUT.write_text(traceback.format_exc())
raise SystemExit(0)

