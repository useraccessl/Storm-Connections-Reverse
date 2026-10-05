import sys, traceback
from pathlib import Path
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
import renderdoc as rd
folder=ROOT/'gpu_captures'
try:
    capture=rd.OpenCaptureFile()
    result=capture.OpenFile(str(folder/'itachi_amaterasu_frame22136.rdc'),'',None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    result,c=capture.OpenCapture(rd.ReplayOptions(),None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    try:
        for event in (5302,5502):
            c.SetFrameEvent(event,True)
            for t in c.GetPipelineState().GetReadOnlyResources(rd.ShaderStage.Pixel):
                rid=t.descriptor.resource
                raw=bytes(c.GetTextureData(rid,rd.Subresource()))
                (folder/('texture_'+str(rid).split('::')[-1]+'.bc')).write_bytes(raw)
        (folder/'texture_bytes_progress.txt').write_text('Original compressed blocks exported')
    finally:
        c.Shutdown();capture.Shutdown()
except Exception:
    (folder/'texture_bytes_progress.txt').write_text(traceback.format_exc())
raise SystemExit(0)
