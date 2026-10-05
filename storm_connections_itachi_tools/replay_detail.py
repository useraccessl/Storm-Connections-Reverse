import sys, traceback
from pathlib import Path
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0,str(ROOT))
from export_frame_constants import export
import renderdoc as rd
log=ROOT/'gpu_captures/detail_progress.txt'
try:
    path=ROOT/'gpu_captures/itachi_amaterasu_frame22136.rdc'
    capture=rd.OpenCaptureFile()
    result=capture.OpenFile(str(path),'',None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    result,controller=capture.OpenCapture(rd.ReplayOptions(),None)
    if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
    try:
        log.write_text('Exporting every draw and original textures\n')
        output=export(controller,path.with_suffix('.all_draws.json'),True)
        log.write_text('Exported '+str(len(output))+' draws\n')
    finally:
        controller.Shutdown()
        capture.Shutdown()
except Exception:
    log.write_text(traceback.format_exc())
raise SystemExit(0)
