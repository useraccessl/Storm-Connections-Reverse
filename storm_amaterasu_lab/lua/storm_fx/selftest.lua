-- In-game self test: storm_fx_selftest [package] [script] [scale] [seed]
-- Casts a skill from the player as storm_fx_cast does (aim at the ground some distance
-- ahead), captures the screen before the cast and at fixed times after it, and writes what
-- the engine did to data/storm_fx_selftest/: report.json (environment, materials and their
-- shaders, per capture the running effects, particles, trail points, draws, skipped
-- resources and dropped effects, every Lua error) and one PNG per capture.
-- It compares nothing with the game: it records what Garry's Mod shows, so that the offline
-- checks can be set against a real frame.
local P=assert(STORM_FX,'storm_fx/player.lua defines STORM_FX first')
local DIR='storm_fx_selftest'
local TIMES={0.15,0.35,0.6,0.9,1.3,1.8,2.5,3.5}     -- seconds after the cast
local WAIT_UI=20                                     -- seconds to wait for the console to close
local run

local function snapshot(label)
    local out={label=label,time=RealTime()-run.started,draws=P.draws,uploads=P.uploads,renderMs=P.renderMs,
        updateMs=P.updateMs,lights=#P.lights,effects={},skipped={},failed={}}
    for _,a in ipairs(P.instances) do
        local effect={effect=a.effect,frame=a.frame,particles=a.scene and #a.scene.particles or 0,trails={}}
        for _,set in ipairs(a.trailSets or {}) do for _,t in ipairs(set.trails) do
            effect.trails[#effect.trails+1]={trail=t.def.index,points=#t.state.points,samples=#t.state.samples}
        end end
        out.effects[#out.effects+1]=effect
    end
    for name,count in pairs(P.skipped) do out.skipped[tostring(name)]=count end
    for name,why in pairs(P.failed) do out.failed[tostring(name)]=tostring(why) end
    return out
end

-- Every material the package made: error materials, and the shader each one reports.
local function materials(runtime)
    local out={count=0,errors={},shaders={}}
    for _,group in ipairs({runtime.items or {},runtime.ribbons or {}}) do
        for _,item in pairs(group) do for _,part in ipairs(item.parts or {}) do
            local mat=part.mat
            if mat then
                out.count=out.count+1
                if mat:IsError() then out.errors[#out.errors+1]=mat:GetName() end
                local shader=mat:GetShader() or '?'
                out.shaders[shader]=(out.shaders[shader] or 0)+1
            end
        end end
    end
    return out
end

local function finish()
    hook.Remove('Think','StormFxSelfTest')
    hook.Remove('PostRender','StormFxSelfTest')
    hook.Remove('OnLuaError','StormFxSelfTest')
    local report=run.report
    report.duration=RealTime()-run.started
    local ok,runtime=pcall(P.load,run.package)
    if ok and runtime then
        report.materials=materials(runtime)
        report.notImported=#(runtime.data.unsupported or {})
        report.noRenderer={}
        for name,why in pairs(runtime.unsupported or {}) do report.noRenderer[tostring(name)]=tostring(why) end
        report.packageSource=runtime.source
    else report.loadError=tostring(runtime) end
    -- Multiplayer: the StormFX calls the server sent to this client (storm_fx/net.lua).
    report.network={singlePlayer=game.SinglePlayer and game.SinglePlayer() or false,calls=P.netCalls or 0,last=P.lastNetCall}
    file.Write(DIR..'/report.json',util.TableToJSON(report,true))
    print(string.format('Storm FX self test %s: %d captures, %d Lua errors, %d materials (%d error materials) -> data/%s/',
        P.version,#report.captures,#report.errors,report.materials and report.materials.count or 0,
        report.materials and #report.materials.errors or 0,DIR))
    -- Garry's Mod refuses 'quit' from Lua ("Command is blocked"): an unattended run is
    -- closed by whatever started the game, once report.json exists.
    run=nil
end

-- delay: seconds to wait before looking at the console (the autostart lets the map settle).
-- pitch: degrees to look down before the cast (unattended runs), or nil to keep the view.
local function start(package,script,scale,seed,delay,pitch)
    if run then print('Storm FX self test already running') return end
    file.CreateDir(DIR)
    run={package=package,script=script,scale=scale,seed=seed or 1,started=RealTime()+(delay or 0),pitch=pitch,
        phase='ui',pending=nil,next=1,
        report={version=P.version,gmod=VERSIONSTR or tostring(VERSION),branch=BRANCH or '?',map=game.GetMap(),
            screen={ScrW(),ScrH()},date=os.date('%Y-%m-%d %H:%M:%S'),package=package,script=script or '(first root)',
            captures={},samples={},errors={}}}
    print('Storm FX self test: close the console; the cast starts once it is closed (aim at the ground ahead).')
    hook.Add('OnLuaError','StormFxSelfTest',function(err,realm,stack,name)
        if run then run.report.errors[#run.report.errors+1]={error=tostring(err),realm=tostring(realm),name=tostring(name)} end
    end)
    hook.Add('Think','StormFxSelfTest',function()
        if not run or run.pending then return end
        local now=RealTime()
        if now<run.started then return end
        if run.phase=='ui' then
            if not gui.IsGameUIVisible() and not gui.IsConsoleVisible() then
                -- Unattended: look down now (the spawn resets the view set at InitPostEntity),
                -- so the eye trace, hence the target, is on the ground a few metres ahead.
                local player=LocalPlayer()
                if run.pitch and IsValid(player) then player:SetEyeAngles(Angle(run.pitch,player:EyeAngles().y,0)) end
                run.phase='before' run.pending='before'
            elseif now-run.started>WAIT_UI then
                run.report.aborted='the console or the menu stayed open' finish()
            end
        elseif run.phase=='cast' then
            local cast=P.castFromPlayer(run.package,run.script,run.scale,run.seed)
            run.report.cast=cast and {script=cast.actors[1] and cast.actors[1].id or '?',origin={cast.outer.pos.x,cast.outer.pos.y,cast.outer.pos.z},
                scale=cast.outer.scale} or {error='the cast failed (its reason is in the console)'}
            run.castAt=now run.phase='after'
            if not cast then finish() end
        elseif run.phase=='after' then
            local t=TIMES[run.next]
            if not t then finish()
            elseif now-run.castAt>=t then run.pending=string.format('t%02d_%.2fs',run.next,t) run.next=run.next+1 end
        end
    end)
    -- render.Capture reads the frame just drawn: only valid in a render hook.
    hook.Add('PostRender','StormFxSelfTest',function()
        if not run or not run.pending then return end
        local label=run.pending
        local data=render.Capture({format='png',x=0,y=0,w=ScrW(),h=ScrH(),alpha=false})
        local name=label..'.png'
        local written=data and file.Write(DIR..'/'..name,data)
        run.report.captures[#run.report.captures+1]={label=label,file=data and name or nil,bytes=data and #data or 0,
            written=written~=false and data~=nil}
        run.report.samples[#run.report.samples+1]=snapshot(label)
        run.pending=nil
        if label=='before' then run.phase='cast' end
    end)
end

concommand.Add('storm_fx_selftest',function(_,_,args)
    start(args[1] and args[1]~='' and args[1] or '4efb_amt1_x',args[2] and args[2]~='' and args[2]~='-' and args[2] or nil,
        tonumber(args[3]),tonumber(args[4]))
end)

-- Unattended run: data/storm_fx_selftest/autostart.txt (first line: package, optional) starts
-- the test five seconds after the map has loaded, looking 12 degrees down (the ground about
-- 7 m ahead from the eye height of 64 units). The file is deleted first, so the test runs
-- once; the game stays open (see finish).
hook.Add('InitPostEntity','StormFxSelfTestAuto',function()
    local flag=DIR..'/autostart.txt'
    if not file.Exists(flag,'DATA') then return end
    local line=string.Trim((file.Read(flag,'DATA') or ''):match('[^\r\n]*') or '')
    file.Delete(flag)
    -- "perftest [package] [effect]" starts storm_fx_perftest instead (storm_fx/perftest.lua).
    local words=string.Explode(' ',line)
    if words[1]=='perftest' and P.perftest then
        P.perftest(words[2] or '4efb_amt1_x',words[3] or '4efb_amt1_blt00',5)
        return
    end
    start(line~='' and line or '4efb_amt1_x',nil,nil,1,5,12)
end)
