"""RenderDoc embedded Python: one F8 press captures consecutive original states."""
import ctypes, json, os, runpy, shutil, sys, time, traceback
from pathlib import Path
from datetime import datetime
import renderdoc as rd
ROOT=Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0,str(ROOT))
STATUS=ROOT/'gpu_captures/continuous_status.txt'
OPTIONS=ROOT/'continuous_capture_options.json'
GAME=Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS')
target=None

def status(message):
    STATUS.write_text(message,encoding='utf-8')

try:
    options=json.loads(OPTIONS.read_text())
    count=int(options.get('frames',180))
    if not 30<=count<=300: raise ValueError('Frame count must be between 30 and 300')
    for name in ('ExecuteAndInject','CreateTargetControl','CaptureOptions','OpenCaptureFile'):
        assert hasattr(rd,name),name
    user32=ctypes.WinDLL('user32',use_last_error=True)
    user32.GetForegroundWindow.restype=ctypes.c_void_p
    user32.GetWindowThreadProcessId.argtypes=(ctypes.c_void_p,ctypes.POINTER(ctypes.c_ulong))
    user32.GetAsyncKeyState.argtypes=(ctypes.c_int,)
    user32.GetAsyncKeyState.restype=ctypes.c_short
    if options.get('self_test'):
        opts=rd.CaptureOptions()
        opts.hookIntoChildren=True
        assert hasattr(rd.TargetControl,'TriggerCapture')
        assert hasattr(rd.TargetControl,'ReceiveMessage')
        status('SELF TEST OK: RenderDoc API, capture options and Windows F8/foreground APIs available; no game launched')
        raise SystemExit(0)
    # Existing captures average 220 MB. Check a conservative 300 MB/frame budget.
    required=count*300*1024*1024+5*1024**3
    if shutil.disk_usage(ROOT).free<required:
        raise RuntimeError('Insufficient free disk space for the capture batch (need '+str(required//1024**3)+' GB)')
    run=ROOT/'gpu_captures/continuous_runs'/datetime.now().strftime('%Y%m%d_%H%M%S_%f')
    run.mkdir(parents=True)
    opts=rd.CaptureOptions()
    opts.hookIntoChildren=True
    result=rd.ExecuteAndInject(str(GAME/'NSUNSC.exe'),str(GAME),'',[],str(run/'amaterasu_continuous'),opts,False)
    if result.result.code!=rd.ResultCode.Succeeded or not result.ident:
        raise RuntimeError('Game launch failed: '+str(result.result))
    target=rd.CreateTargetControl('',result.ident,'Storm Amaterasu continuous capture',False)
    if not target or not target.Connected(): raise RuntimeError('Cannot connect to the launched game')
    pid=target.GetPID()
    status('READY: entrainement Itachi. Appuie UNE FOIS sur F8 au debut des petites flammes. '+str(count)+' images consecutives seront capturees.')
    armed=True
    previous=False
    captured=[]
    started=time.monotonic()
    while target.Connected() and time.monotonic()-started<1800:
        message=target.ReceiveMessage(None)
        if message.type==rd.TargetControlMessageType.NewCapture:
            item=message.newCapture
            # Process only captures created after our own F8 trigger, in this run.
            if not armed and Path(item.path).resolve().parent==run.resolve():
                captured.append({'frame':item.frameNumber,'path':item.path,'bytes':item.byteSize,'timestamp':item.timestamp})
                (run/'manifest.json').write_text(json.dumps(captured,indent=2))
                status('CAPTURE: '+str(len(captured))+'/'+str(count)+' images. Le jeu peut ralentir. Dossier: '+str(run))
                if len(captured)>=count: break
        foreground_pid=ctypes.c_ulong()
        user32.GetWindowThreadProcessId(user32.GetForegroundWindow(),ctypes.byref(foreground_pid))
        pressed=bool(user32.GetAsyncKeyState(0x77)&0x8000) if foreground_pid.value==pid else False
        if armed and pressed and not previous:
            target.TriggerCapture(count)
            armed=False
            status('CAPTURE: 0/'+str(count)+' images. Continue la technique dans le jeu.')
        previous=pressed
    target.Shutdown()
    target=None
    if not captured: raise RuntimeError('No capture received. F8 must be pressed while the launched STORM game has focus.')
    (run/'capture_result.json').write_text(json.dumps({'requested':count,'received':len(captured),'complete':len(captured)==count},indent=2))
    status('EXTRACTION: '+str(len(captured))+' captures en cours. Les fichiers originaux sont conserves. Dossier: '+str(run))
    os.environ['STORM_CAPTURE_RUN_DIR']=str(run)
    try:
        runpy.run_path(str(ROOT/'replay_sequence.py'),run_name='__main__')
    except SystemExit as exit_result:
        if exit_result.code not in (None,0): raise
    progress=(run/'sequence_progress.txt').read_text()
    if not progress.startswith('Complete:'): raise RuntimeError(progress)
    status('COMPLETE: '+str(len(captured))+'/'+str(count)+' images capturees et extraites. Dossier: '+str(run))
except SystemExit:
    raise
except Exception:
    status('ERROR:\n'+traceback.format_exc())
finally:
    if target: target.Shutdown()
raise SystemExit(0)
