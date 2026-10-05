"""Run the in-game self test (storm_fx/ debug/cl_selftest.lua, console command
storm_fx_selftest) and the perf test (debug/cl_perftest.lua) in the offline stubs, before
anyone runs them in Garry's Mod.

  python verify_selftest.py [package]

The stubs of port_preview.py keep one hook per event; GMod keys them by name, so this
installs named hooks (the engine's own Think / draw hooks keep running beside the test's),
a player with a position and an aim, gui / file / render.Capture / util.TableToJSON /
game.GetMap stand-ins, and drives frames: Think, the draw hooks, then PostRender. The
console stays "open" for the first 30 frames to exercise the wait. Checked: the cast
happens after the console closes, nine captures (before + eight) are written as files with
the bytes render.Capture returned, report.json is valid JSON with one sample per capture,
no Lua error, effects running and draws issued after the cast, every material made, none
an error material, and the hooks removed at the end.

This checks the test's own logic and its use of the engine, not Garry's Mod: render.Capture,
file.Write and the console state are stand-ins here.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
from port_preview import Port, capture_camera  # noqa: E402

STUBS = r'''
local multi={}
for event,fn in pairs(hooks) do multi[event]={['StormFX:Engine:'..event]=fn} end
local function dispatcher(event) return function(...) for _,fn in pairs(multi[event] or {}) do fn(...) end end end
hook.Add=function(event,name,fn) multi[event]=multi[event] or {} multi[event][name]=fn hooks[event]=dispatcher(event) end
hook.Remove=function(event,name) if multi[event] then multi[event][name]=nil end end
hook.GetTable=function() return multi end
for event in pairs(multi) do hooks[event]=dispatcher(event) end
function isstring(v) return type(v)=='string' end
function GetConVar(name) if name=='mat_queue_mode' then return {GetString=function() return '-1' end} end end
SELFTEST={files={},console=30,captures=0,hooks=multi}
local mt=getmetatable(Vector(0,0,0))
function mt.Normalize(self) local l=self:Length() if l>0 then self.x,self.y,self.z=self.x/l,self.y/l,self.z/l end end
local eyeTrace=LocalPlayer().GetEyeTrace
-- Angles with the GMod direction methods (Source: pitch down positive, yaw about z).
local plainAngle=Angle
function Angle(p,y,r)
    local a=plainAngle(p,y,r)
    local function rad(x) return x*math.pi/180 end
    function a.Forward(self) local cp=math.cos(rad(self.p)) return Vector(cp*math.cos(rad(self.y)),cp*math.sin(rad(self.y)),-math.sin(rad(self.p))) end
    function a.Right(self) return Vector(math.sin(rad(self.y)),-math.cos(rad(self.y)),0) end
    return a
end
function LocalPlayer()
    local p=PREVIEW.camera.position
    local f=PREVIEW.camera.forward
    return {GetEyeTrace=eyeTrace,GetPos=function() return Vector(p[1],p[2],PREVIEW.groundZ or 0) end,
        GetAimVector=function() return Vector(f[1],f[2],f[3]) end,EyePos=function() return Vector(p[1],p[2],(PREVIEW.groundZ or 0)+64) end,
        EyeAngles=function() return Angle(0,30,0) end,SetEyeAngles=function(self,a) SELFTEST.eyes=a end}
end
RENDERGROUP_OPAQUE=7
function ClientsideModel(model)
    SELFTEST.props=(SELFTEST.props or 0)+1
    local removed=false
    return {SetPos=function() end,SetAngles=function() end,Spawn=function() end,SetNoDraw=function(self,on) SELFTEST.hidden=on end,
        Remove=function() removed=true SELFTEST.propsRemoved=(SELFTEST.propsRemoved or 0)+1 end,IsValid=function() return not removed end}
end
local valid=IsValid
function IsValid(v) if type(v)=='table' and v.IsValid then return v:IsValid() end return valid(v) end
string.Explode=string.Explode or function(sep,s) local out={} for w in (s..sep):gmatch('(.-)'..sep) do out[#out+1]=w end return out end
function SysTime() return PREVIEW.now end
render.SetColorMaterial=function() end
render.DrawSphere=function() SELFTEST.spheres=(SELFTEST.spheres or 0)+1 end
Color=Color or function(r,g,b,a) return {r=r,g=g,b=b,a=a or 255} end
gui={IsGameUIVisible=function() return false end,IsConsoleVisible=function() return SELFTEST.console>0 end}
file={CreateDir=function(name) SELFTEST.dir=name end,Write=function(name,data) SELFTEST.files[name]=data return true end,
    Exists=function(name) return SELFTEST.files[name]~=nil end,Read=function(name) return SELFTEST.files[name] end,
    Delete=function(name) SELFTEST.files[name]=nil end}
string.Trim=string.Trim or function(s) return (s:gsub('^%s+',''):gsub('%s+$','')) end
function RunConsoleCommand(name) SELFTEST.commands=(SELFTEST.commands or '')..name..';' end
render.Capture=function(t) assert(t.format=='png' and t.w and t.h) SELFTEST.captures=SELFTEST.captures+1
    return 'PNG'..string.rep('x',SELFTEST.captures) end
game={GetMap=function() return 'offline' end}
VERSIONSTR='offline' BRANCH='offline'
'''


def to_json(value, pretty=False):
    def plain(v):
        if hasattr(v, 'items') and not isinstance(v, dict):
            items = list(v.items())
            keys = [k for k, _ in items]
            if keys and all(isinstance(k, int) for k in keys) and sorted(keys) == list(range(1, len(keys) + 1)):
                return [plain(x) for _, x in sorted(items)]
            if not keys:
                return []
            return {str(k): plain(x) for k, x in items}
        return v
    return json.dumps(plain(value), indent=1 if pretty else None)


def main() -> int:
    package = sys.argv[1] if len(sys.argv) > 1 else '4efb_amt1_x'
    camera = dict(capture_camera(22136), yaw=0.0)
    port = Port(camera, [209.65, -476.38, -0.68], (1280, 720))
    lua = port.lua
    g = lua.globals()
    g.PREVIEW.groundZ = -0.68
    lua.execute(STUBS)
    hold = lua.eval('function(f) return function(...) return f(...) end end')
    g.util.TableToJSON = hold(to_json)
    t = g.SELFTEST
    fail = []
    g.commands.storm_fx_selftest(None, None, lua.table_from([package]))
    cast_frame = None
    for frame in range(1, 600):
        t.console = max(0, int(t.console) - 1)
        port.advance(frame)
        port.collect()
        g.hooks.PostRender()
        if cast_frame is None and len(list(port.fx.tCasts.values())):
            cast_frame = frame
        if 'storm_fx_selftest/report.json' in dict(t.files.items()):
            break
    files = dict(t.files.items())
    if 'storm_fx_selftest/report.json' not in files:
        print('FAIL: no report written in 600 frames')
        return 1
    report = json.loads(files['storm_fx_selftest/report.json'])
    pngs = sorted(k for k in files if k.endswith('.png'))
    if cast_frame is None or cast_frame <= 30:
        fail.append(f'the cast happened at frame {cast_frame}, before the console closed (frame 30)')
    if len(report['captures']) != 9 or len(pngs) != 9:
        fail.append(f'{len(report["captures"])} captures recorded, {len(pngs)} files written (expected 9)')
    if any(not c['written'] or c['bytes'] == 0 for c in report['captures']):
        fail.append('a capture was not written')
    if len(report['samples']) != len(report['captures']):
        fail.append('one sample per capture expected')
    if report['errors']:
        fail.append(f'Lua errors: {report["errors"][:3]}')
    if 'error' in report.get('cast', {}):
        fail.append(f'cast: {report["cast"]}')
    after = report['samples'][1:]
    if not any(s['effects'] for s in after) or not any(s['draws'] > 0 for s in after):
        fail.append('no effect ran or nothing was drawn after the cast')
    if report['samples'][0]['effects']:
        fail.append('effects were running before the cast')
    materials = report.get('materials', {})
    if not materials.get('count') or materials.get('errors'):
        fail.append(f'materials: {materials}')
    left = [f'{event}/{name}' for event, names in t.hooks.items() for name in names.keys() if name == 'StormFX:SelfTest']
    if left:
        fail.append(f'hooks left installed: {left}')
    if 'quit' in str(t.commands or ''):
        fail.append('the console command run asked to quit the game')

    # Unattended run: autostart.txt read and deleted at InitPostEntity, the view pitched
    # down, the test after a 5 s delay, quit at the end.
    t.files['storm_fx_selftest/report.json'] = None
    t.files['storm_fx_selftest/autostart.txt'] = package + '\r\n'
    port.stop()
    start = float(g.PREVIEW.now)
    g.hooks.InitPostEntity()
    if t.files['storm_fx_selftest/autostart.txt'] is not None:
        fail.append('autostart.txt not deleted')
    auto_cast = None
    for frame in range(1, 900):
        port.advance(round(start * 60) + frame)
        port.collect()
        g.hooks.PostRender()
        if auto_cast is None and len(list(port.fx.tCasts.values())):
            auto_cast = frame
        if t.files['storm_fx_selftest/report.json'] is not None:
            break
    auto = json.loads(t.files['storm_fx_selftest/report.json']) if t.files['storm_fx_selftest/report.json'] else None
    if auto is None:
        fail.append('the unattended run wrote no report')
    else:
        if auto_cast is None or auto_cast < 5 * 60:
            fail.append(f'the unattended cast happened at frame {auto_cast}, before the 5 s delay')
        if len(auto['captures']) != 9 or auto['errors'] or 'error' in auto.get('cast', {}):
            fail.append(f'unattended run: {len(auto["captures"])} captures, errors {auto["errors"][:2]}, cast {auto.get("cast")}')
        if 'quit' in str(t.commands or ''):
            fail.append('the unattended run asked to quit (Garry\'s Mod blocks it from Lua)')
        if not t.eyes or abs(float(t.eyes.p) - 12) > 1e-9:
            fail.append(f'view not pitched down before the cast: {t.eyes}')
        print(f'unattended run: cast at frame {auto_cast}, {len(auto["captures"])} captures, commands {t.commands}')

    # storm_fx_perftest through the autostart: occlusion captures of the effect and of a
    # sphere, with and without another addon's render hook (a stand-in named like GShader
    # Library's), then eleven cases (float32 on / off x 0, 1, 2, 4, 8 effects, 8 far).
    t.files['storm_fx_selftest/autostart.txt'] = 'perftest 4efb_amt1_x 4efb_amt1_blt00'
    lua.execute('''
        SELFTEST.otherHook=function() SELFTEST.otherCalls=(SELFTEST.otherCalls or 0)+1 end
        hook.Add('PreDrawTranslucentRenderables','shaderlib',SELFTEST.otherHook)
    ''')
    port.stop()
    start = float(g.PREVIEW.now)
    g.hooks.InitPostEntity()
    perf = None
    for frame in range(1, 60 * 60):
        port.advance(round(start * 60) + frame)
        port.collect()
        g.hooks.PostRender()
        if t.files['storm_fx_selftest/perf.json'] is not None:
            perf = json.loads(t.files['storm_fx_selftest/perf.json'])
            break
    if perf is None:
        fail.append('the perf test wrote no perf.json in 60 s')
    else:
        labels = [(c['label'], c['drawHook'], c['others'] > 0, c.get('sphere')) for c in perf['captures']]
        if labels != [('occlusion_effect', 'translucent', True, None),
                      ('occlusion_effect_opaque', 'opaque', True, None),
                      ('occlusion_sphere', 'none', True, 'PostDrawTranslucentRenderables'),
                      ('occlusion_effect_alone', 'translucent', False, None),
                      ('occlusion_effect_nowall', 'translucent', True, None)]:
            fail.append(f'occlusion captures {labels}')
        if not t.hidden:
            fail.append('the plate was not hidden for the effect_nowall capture')
        if any(c['count'] and c.get('skip') != 'render' and not (c['calls'] >= 1 and c['views']) for c in perf['cases']):
            fail.append(f'views per frame not recorded: {[(c.get("calls"), c.get("views")) for c in perf["cases"]]}')
        if 'shaderlib' not in perf.get('hooks', {}).get('PreDrawTranslucentRenderables', []):
            fail.append(f'the other addon hook is not in the report: {perf.get("hooks")}')
        if not lua.eval('SELFTEST.hooks.PreDrawTranslucentRenderables.shaderlib==SELFTEST.otherHook'):
            fail.append('the other addon hook was not put back')
        if perf.get('convars', {}).get('mat_queue_mode') != '-1':
            fail.append(f'convars: {perf.get("convars")}')
        if not t.spheres:
            fail.append('the reference sphere was never drawn')
        if not perf.get('wall') or (t.propsRemoved or 0) < 1:
            fail.append('the occluding plate was not made or not removed')
        shape = [(c['count'], bool(c.get('far')), c.get('skip'), bool(c.get('water'))) for c in perf['cases']]
        expected = [(n, False, None, False) for n in (0, 1, 2, 4, 8)] + [(8, True, None, False)] + \
            [(8, False, s, False) for s in ('draw', 'apply', 'matrix', 'blend', 'render')] + [(8, False, None, True), (8, False, None, False)]
        if shape != expected or any(c['frames'] < 60 for c in perf['cases']):
            fail.append(f'perf cases: {shape}, frames {[c["frames"] for c in perf["cases"]]}')
        if any(c['count'] and not c['draws'] and c.get('skip') != 'render' for c in perf['cases']):
            fail.append('a case with effects drew nothing')
        if any(c.get('skip') == 'render' and c['draws'] for c in perf['cases']):
            fail.append('the no-render case drew')
        fx = port.fx
        if fx.IsExact(fx) is not True or len(list(fx.tSkip.keys())) or fx.sDrawHook != 'translucent':
            fail.append('the perf test did not restore the exact mode / draw loop / draw hook')
        left = [f'{event}/{name}' for event, names in t.hooks.items() for name in names.keys()
                if str(name).startswith('StormFX:PerfTest')]
        if left:
            fail.append(f'perf test hooks left installed: {left}')
        print('perf test:', [(c['count'], c.get('far'), c.get('skip'), c['draws']) for c in perf['cases']], 'captures', labels)
    print(f'cast at frame {cast_frame}; captures {[c["label"] for c in report["captures"]]}')
    for s in report['samples']:
        print(f'  {s["label"]:>12s}: {len(s["effects"])} effects, {s["draws"]} draws, '
              f'{sum(e["particles"] for e in s["effects"])} particles, '
              f'{sum(len(e["trails"]) for e in s["effects"])} trails, skipped {list(s["skipped"])}')
    print(f'materials: {materials.get("count")} ({materials.get("shaders")}), errors {materials.get("errors")}')
    for line in fail:
        print('  FAIL', line)
    print('FAIL' if fail else 'PASS: storm_fx_selftest runs, captures and reports in the offline stubs')
    return 1 if fail else 0


if __name__ == '__main__':
    sys.exit(main())
