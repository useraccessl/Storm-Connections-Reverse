"""Check the public interface StormFX (storm_fx/ api/cl_api.lua, cl_network.lua,
sv_network.lua) in the offline stubs.

  python verify_api.py

  * StormFX.Play("package/effect", pos, ang) plays the effect at pos with the yaw of ang:
    the handle is valid, the effect draws, Stop() lets it end (emission stops, the handle
    becomes invalid once it has drained), Remove() takes it away at once;
  * opts.parent: the effect follows the entity (its outer position and yaw track the
    parent's every update) and stops once the parent is gone;
  * a wrong name or package gives nil and a message, not a Lua error;
  * StormFX.Effects / Scripts list a package, StormFX.Cast runs a script chain,
    StormFX.StopAll clears everything;
  * a package shipped as content (data_static/storm_fx/<package>.txt, how clients get it
    from a server) loads through file.Read + CompileString like the Lua file; a broken one
    is refused with a message;
  * the server side: the addon's autorun in a server state (api/sv_network.lua,
    debug/sv_selftest.lua) sends three StormFX.Play messages for a spawning player (once:
    the trigger file is deleted); fed to the client receiver (api/cl_network.lua), they
    play three effects and are counted (StormFX.Engine.iNetCalls).
Nothing here runs in Garry's Mod (see storm_fx_selftest for that).
"""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
from port_preview import Port, capture_camera  # noqa: E402

STUBS = r'''
local vector_mt=getmetatable(Vector(0,0,0))
local plainVector=Vector
function Vector(x,y,z)
    if type(x)=='table' then return plainVector(x.x,x.y,x.z) end
    return plainVector(x,y,z)
end
angle_zero=Angle(0,0,0)
vector_origin=Vector(0,0,0)
function isnumber(v) return type(v)=='number' end
local plainMatrix=Matrix
function Matrix()
    local m=plainMatrix()
    function m.Rotate(self,a) self.rotated=a end
    function m.ToTable(self) return {{1,0,0,0},{0,1,0,0},{0,0,1,0},{0,0,0,1}} end
    return m
end
API_LOG={}
local print0=print
function print(...) local t={...} API_LOG[#API_LOG+1]=table.concat((function() local o={} for i=1,#t do o[i]=tostring(t[i]) end return o end)(),' ') end
PARENT={pos=Vector(100,50,0),yaw=30,alive=true}
function PARENT.GetPos(self) return Vector(self.pos) end
function PARENT.GetAngles(self) return Angle(0,self.yaw,0) end
function PARENT.IsDormant(self) return self.dormant == true end
local valid=IsValid
function IsValid(v) if v==PARENT then return PARENT.alive end return valid(v) end
'''


ADDON = ROOT.parent / 'storm_amaterasu_lab/lua'
CLEAN = ROOT.parent / 'storm_fx/lua'
PACKAGE = ADDON / 'storm_fx/packages/4efb_amt1_x.lua'
MESSAGE = 'StormFX:Call'

CONTENT_STUBS = r'''
DATA_STATIC={}
file=file or {}
local read=file.Read
file.Read=function(path,where)
    if where=='GAME' and DATA_STATIC[path] then return DATA_STATIC[path] end
    if read then return read(path,where) end
end
-- GMod: CompileString(code, identifier, false) gives the function or the error message.
function CompileString(text,name,handle)
    local f,e=load(text,'='..name)
    if f then return f end
    if handle==false then return e end
    error(e)
end
'''

CLIENT_NET_STUBS = r'''
NET_RECEIVERS={} NET_QUEUE={}
NULL=setmetatable({},{__tostring=function() return 'NULL' end})
local valid=IsValid
function IsValid(v) if v==NULL then return false end return valid(v) end
local at=0
local function take() at=at+1 return NET_QUEUE[at] end
net={Receive=function(name,fn) NET_RECEIVERS[name]=function() at=0 fn() end end,
    ReadUInt=take,ReadString=take,ReadVector=take,ReadAngle=take,ReadFloat=take,ReadEntity=take,ReadBool=take}
'''

# A server state: the net library records what is written; one player spawns.
SERVER_STUBS = r'''
SERVER=true
SENT={}
local message
local function put(v) message.values[#message.values+1]=v end
util={AddNetworkString=function(name) NETWORK_STRING=name end,
    TraceLine=function(t) return {Hit=true,HitPos=Vector(t.start.x,t.start.y,0)} end}
net={Start=function(name) message={name=name,values={}} end,WriteUInt=put,WriteString=put,WriteVector=put,WriteAngle=put,WriteBool=put,
    WriteFloat=put,WriteEntity=put,Send=function(to) message.to=to SENT[#SENT+1]=message end,
    Broadcast=function() message.to='all' SENT[#SENT+1]=message end}
-- The players who can see a place (StormFX.Play / Cast without a filter)
net.SendPVS=function(pos) message.to={kind='filter',pvs=pos} SENT[#SENT+1]=message end
local vec={} vec.__index=vec
function Vector(x,y,z) return setmetatable({kind='vector',x=x or 0,y=y or 0,z=z or 0},vec) end
vec.__add=function(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
vec.__sub=function(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
vec.__mul=function(a,k) return Vector(a.x*k,a.y*k,a.z*k) end
function vec.Normalize(v) local l=math.sqrt(v.x^2+v.y^2+v.z^2) if l>0 then v.x,v.y,v.z=v.x/l,v.y/l,v.z/l end end
function Angle(p,y,r) return {kind='angle',p=p or 0,y=y or 0,r=r or 0} end
vector_origin=Vector(0,0,0) angle_zero=Angle(0,0,0) NULL={kind='entity'} MASK_SOLID_BRUSHONLY=1
HOOKS={}
hook={Add=function(e,n,f) HOOKS[e]=HOOKS[e] or {} HOOKS[e][n]=f end,Remove=function(e,n) if HOOKS[e] then HOOKS[e][n]=nil end end}
TIMERS={}
timer={Simple=function(delay,fn) TIMERS[#TIMERS+1]=fn end}
FILES={['storm_fx_selftest/server_autostart.txt']='4efb_amt1_x/4efb_amt1_blt00\n'}
file={Exists=function(p) return FILES[p]~=nil end,Read=function(p) return FILES[p] end,Delete=function(p) FILES[p]=nil end}
string.Trim=function(s) return (s:gsub('^%s+',''):gsub('%s+$','')) end
function IsValid(v) return v~=nil and v~=NULL end
PLAYER={GetAimVector=function() return Vector(1,0,0.3) end,GetPos=function() return Vector(100,200,0) end,
    EyeAngles=function() return Angle(10,30,0) end}
function print() end
'''


SERVER_HOOK = 'StormFX:SelfTest:PlayerInitialSpawn'


def server_messages() -> tuple[list[dict], bool, bool, list[str]]:
    """Messages the addon sends from a server state when its server test plays an effect for
    a spawning player; whether the trigger file was deleted; whether a second spawn sent
    anything; the files the autorun sends to the clients (AddCSLuaFile)."""
    sys.path.insert(0, str(ROOT / 'vendor'))
    from lupa import LuaRuntime
    server = LuaRuntime(unpack_returned_tuples=True)
    server.execute(SERVER_STUBS)
    s = server.globals()
    s.include = lambda name: server.execute((CLEAN / name).read_text(encoding='utf-8-sig'))
    server.execute('CLIENT=false SENT_LUA={} function AddCSLuaFile(path) SENT_LUA[#SENT_LUA+1]=path end')
    server.execute((CLEAN / 'autorun/sh_storm_fx.lua').read_text(encoding='utf-8-sig'))
    client_files = list(s.SENT_LUA.values())
    s.HOOKS.PlayerInitialSpawn[SERVER_HOOK](s.PLAYER)
    for fn in list(s.TIMERS.values()):
        fn()
    deleted = s.FILES['storm_fx_selftest/server_autostart.txt'] is None
    count = len(list(s.SENT.values()))
    # The hook removed itself: a second player spawning sends nothing.
    again = s.HOOKS.PlayerInitialSpawn[SERVER_HOOK] is not None

    def plain(v):
        if hasattr(v, 'kind'):
            if v.kind == 'vector':
                return ('vector', float(v.x), float(v.y), float(v.z))
            if v.kind == 'angle':
                return ('angle', float(v.p), float(v.y), float(v.r))
            return ('entity',)
        return v
    def recipients(m):
        # A play goes to the players who can see its position (its PVS)
        to = m.to
        if to != 'all' and hasattr(to, 'kind') and to.kind == 'filter' and to.pvs is not None:
            values = list(m['values'].values())
            return 'pvs' if plain(to.pvs) == plain(values[2]) else 'pvs elsewhere'
        return to
    messages = [{'name': m.name, 'to': recipients(m), 'values': [plain(v) for v in m['values'].values()]} for m in s.SENT.values()]
    assert count == len(messages)
    if s.NETWORK_STRING != MESSAGE or any(m['name'] != MESSAGE or m['to'] != 'pvs' for m in messages):
        return [], deleted, again, client_files
    return messages, deleted, again, client_files


def main() -> int:
    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64))
    lua = port.lua
    lua.execute(STUBS)
    g = lua.globals()
    api = g.StormFX
    fail = []
    if api is None:
        print('FAIL: StormFX is not defined')
        return 1
    effects = list(api.Effects('4efb_amt1_x').values())
    scripts = list(api.Scripts('4efb_amt1_x').values())
    if '4efb_amt1_hit00' not in effects or '4efb_amt1_e_begin00' not in scripts:
        fail.append(f'Effects / Scripts: {effects}, {scripts}')
    clock = [0]

    def run(frames):
        draws = 0
        for _ in range(frames):
            clock[0] += 1
            port.advance(clock[0])
            draws = max(draws, len([d for d in port.collect() if not d.get('marker')]))
        return draws

    # Play, draw, Stop, drain.
    handle = api.Play('4efb_amt1_x/4efb_amt1_hit00', g.Vector(10, 20, 0), g.Angle(0, 45, 0))
    if handle is None or not handle.IsValid(handle):
        fail.append('Play gave no valid handle')
    else:
        if abs(float(handle.instance.outer.yaw) - (45 + 90)) > 1e-9 or float(handle.instance.outer.pos.x) != 10:
            fail.append('Play did not place the effect at pos with the yaw of ang')
        drawn = run(60)
        if not drawn:
            fail.append('the played effect drew nothing')
        handle.Stop(handle)
        frames = 0
        while handle.IsValid(handle) and frames < 1200:
            run(1)
            frames += 1
        if handle.IsValid(handle):
            fail.append('Stop: the effect never ended')
        print(f'Play: {drawn} draws at most; ended {frames} frames after Stop')

    # Remove at once.
    handle = api.Play('4efb_amt1_x/4efb_amt1_blt00', g.Vector(0, 0, 0))
    run(10)
    handle.Remove(handle)
    if handle.IsValid(handle) or any(a == handle.instance for a in port.fx.tInstances.values()):
        fail.append('Remove left the effect running')

    # Follow a parent, stop with it.
    parent = g.PARENT
    opts = lua.table()
    opts.parent = parent
    handle = api.Play('4efb_amt1_x/4efb_amt1_blt00', g.Vector(0, 0, 0), None, opts)
    run(5)
    parent.pos = g.Vector(300, -40, 5)
    parent.yaw = 120
    run(5)
    outer = handle.instance.outer
    if (float(outer.pos.x), float(outer.pos.y), float(outer.yaw)) != (300.0, -40.0, 120.0 + 90):
        fail.append(f'parent not followed: {float(outer.pos.x)}, {float(outer.pos.y)}, {float(outer.yaw)}')
    parent.alive = False
    frames = 0
    while handle.IsValid(handle) and frames < 1200:
        run(1)
        frames += 1
    if handle.IsValid(handle):
        fail.append('the effect did not stop when its parent went away')
    print(f'parent: followed to (300, -40) yaw 120; ended {frames} frames after the parent went away')

    # Wrong names: nil and a message, no error.
    for bad in ('4efb_amt1_x/no_such_effect', 'no_such_package/effect'):
        try:
            if api.Play(bad, g.Vector(0, 0, 0)) is not None:
                fail.append(f'{bad}: a handle for nothing')
        except Exception as error:  # noqa: BLE001
            fail.append(f'{bad}: Lua error {error}')
    messages = [m for m in g.API_LOG.values() if 'StormFX.Play' in str(m)]
    if len(messages) < 2:
        fail.append(f'no message for the wrong names: {list(g.API_LOG.values())[-3:]}')

    # Cast and StopAll.
    cast = api.Cast('4efb_amt1_x/4efb_amt1_e_begin00', g.Vector(0, 0, 0), g.Vector(500, 0, 0))
    run(60)
    if cast is None or not len(list(port.fx.tInstances.values())):
        fail.append('Cast launched nothing')
    api.StopAll()
    if len(list(port.fx.tInstances.values())) or len(list(port.fx.tCasts.values())):
        fail.append('StopAll left effects running')

    # A package as content, the way clients get it from a server: data_static/storm_fx/<name>.txt
    # read through the GAME path and compiled with CompileString (LoadPackage prefers it).
    lua.execute(CONTENT_STUBS)
    path = 'data_static/storm_fx/4efb_amt1_x.txt'
    g.DATA_STATIC[path] = PACKAGE.read_text(encoding='utf-8')
    models_from_lua = len(list(port.load('4efb_amt1_x').data.models.keys()))
    port.fx.tPackages['4efb_amt1_x'] = None
    runtime = port.load('4efb_amt1_x')
    if runtime.source != path or len(list(runtime.data.models.keys())) != models_from_lua:
        fail.append(f'data_static package: source {runtime.source}, {len(list(runtime.data.models.keys()))} models')
    handle = api.Play('4efb_amt1_x/4efb_amt1_hit00', g.Vector(0, 0, 0))
    if handle is None or not run(30):
        fail.append('the effect of the data_static package drew nothing')
    api.StopAll()
    g.DATA_STATIC['data_static/storm_fx/broken_x.txt'] = 'return {format=1,'
    try:
        port.load('broken_x')
        fail.append('a package that does not compile was accepted')
    except Exception as error:  # noqa: BLE001
        if 'does not compile' not in str(error):
            fail.append(f'broken package: {error}')
    print(f'data_static package: loaded from {runtime.source} ({models_from_lua} models, as from the Lua file)')

    # The server side: the addon's autorun in a server state; the messages it sends are fed
    # to the client receiver of this state.
    messages, deleted, again, client_files = server_messages()
    if len(messages) != 3 or not deleted or again:
        fail.append(f'server test: {len(messages)} messages, file deleted {deleted}, second spawn sent {again}')
    # Every client and shared file of the addon is sent to the clients, no server file.
    shipped = sorted(str(p.relative_to(CLEAN)).replace('\\', '/') for p in (CLEAN / 'storm_fx').rglob('*.lua')
                     if p.name[:3] in ('cl_', 'sh_') and 'packages' not in p.parts)
    if sorted(client_files) != shipped:
        fail.append(f'AddCSLuaFile: {sorted(set(shipped) ^ set(client_files))} differ')
    lua.execute(CLIENT_NET_STUBS)
    lua.execute((CLEAN / 'storm_fx/api/cl_network.lua').read_text(encoding='utf-8-sig'))
    engine = port.fx
    before = int(engine.iNetCalls or 0)
    for message in messages:
        feed = lua.table()
        for i, value in enumerate(message['values'], 1):
            if isinstance(value, tuple) and value[0] == 'vector':
                feed[i] = g.Vector(*value[1:])
            elif isinstance(value, tuple) and value[0] == 'angle':
                feed[i] = g.Angle(*value[1:])
            elif isinstance(value, tuple) and value[0] == 'entity':
                feed[i] = g.NULL
            else:
                feed[i] = value
        g.NET_QUEUE = feed
        g.NET_RECEIVERS[message['name']]()
    played = [a for a in engine.tInstances.values() if a.effect == '4efb_amt1_blt00']
    if int(engine.iNetCalls or 0) - before != 3 or len(played) != 3 or engine.sLastNetCall != '4efb_amt1_x/4efb_amt1_blt00':
        fail.append(f'client receiver: {int(engine.iNetCalls or 0) - before} calls, {len(played)} effects')
    elif not run(20):
        fail.append('the effects sent by the server drew nothing')
    print(f'server -> client: {len(messages)} StormFX.Play messages from debug/sv_selftest.lua, {len(played)} effects on the client; '
          f'{len(client_files)} files sent to the clients')
    for line in fail:
        print('  FAIL', line)
    print('FAIL' if fail else 'PASS: StormFX.Play / Stop / Remove / parent / Cast / StopAll behave in the offline stubs')
    return 1 if fail else 0


if __name__ == '__main__':
    sys.exit(main())
