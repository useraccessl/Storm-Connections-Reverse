"""RenderDoc --python entry point. Processes captures, then exits before UI."""
import sys
import traceback
from pathlib import Path
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0,str(ROOT))
from export_frame_constants import export
import renderdoc as rd

log=ROOT/'gpu_captures/replay_progress.txt'
try:
    captures=sorted((ROOT/'gpu_captures').glob('*.rdc'))
    for path in captures:
        destination=path.with_suffix('.constants.json')
        if destination.exists(): continue
        log.write_text('Opening '+path.name+'\n',encoding='utf-8')
        capture=rd.OpenCaptureFile()
        result=capture.OpenFile(str(path),'',None)
        if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
        result,controller=capture.OpenCapture(rd.ReplayOptions(),None)
        if result.code!=rd.ResultCode.Succeeded: raise RuntimeError(str(result))
        try:
            export(controller,destination)
        finally:
            controller.Shutdown()
            capture.Shutdown()
        log.write_text('Exported '+path.name+'\n',encoding='utf-8')
    log.write_text('Completed all captures\n',encoding='utf-8')
except Exception:
    log.write_text(traceback.format_exc(),encoding='utf-8')
raise SystemExit(0)
