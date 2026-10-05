-- In-game performance and occlusion test: storm_fx_perftest [package] [effect]
-- 1. Occlusion: an opaque plate stands between the camera and a playing effect; the
--    screen is captured for the effect, for a depth-tested sphere of Garry's Mod's own in
--    its place, and for the effect with the other addons' render hooks taken out
--    (OCCLUSION), into data/storm_fx_selftest/occlusion_*.png.
-- 2. Performance: 0, 1, 2, 4 and 8 copies of a looping effect play in front of the
--    camera (doubles, no float32 rounding), then eight far away, then eight with one step
--    of the draw loop left out (P.skip) or no rendering at all, then eight drawn in the
--    water views too (storm_fx_water_views 1, put back afterwards); for each case the real
--    frame time, the engine's own update / render time, the views and the draws are
--    averaged over two seconds.
-- The results go to data/storm_fx_selftest/perf.json. The game stays open.
local P=assert(STORM_FX,'storm_fx/player.lua defines STORM_FX first')
local DIR='storm_fx_selftest'
local COUNTS={0,1,2,4,8}
local WARM,MEASURE=1.0,2.0
-- Cost attribution of eight effects: one draw-loop step left out, or nothing rendered.
local ATTRIBUTION={'draw','apply','matrix','blend','render'}
local test

local function eye()
    local player=LocalPlayer()
    return player:EyePos(),player:EyeAngles()
end

-- Copies of the effect spread on the ground in front of the camera; centred: one copy
-- straight ahead, on the view axis (behind the occluding plate).
-- far: ten times as far (the same draws, a fraction of the pixels).
local function spawn(count,centred,far)
    P.stop()
    local origin,angles=eye()
    local forward=angles:Forward() forward.z=0 forward:Normalize()
    local right=angles:Right() right.z=0 right:Normalize()
    local k0=far and 10 or 1
    for k=1,count do
        local column,row=(k-1)%4,math.floor((k-1)/4)
        local pos=centred and origin+forward*360 or origin+forward*((260+row*120)*k0)+right*((column-1.5)*110*k0)
        local ground=util.TraceLine({start=pos+Vector(0,0,64),endpos=pos-Vector(0,0,512),mask=MASK_SOLID_BRUSHONLY})
        local at=ground.Hit and ground.HitPos or pos
        test.effectPos=at
        P.play(test.package,test.effect,{pos=at,yaw=angles.y,scale=P.host.scale},k)
    end
end

-- A red sphere of Garry's Mod's own (render.SetColorMaterial: depth tested) where the
-- effect is, drawn from the given hook, or none.
local SPHERE_EVENTS={'PostDrawTranslucentRenderables','PostDrawOpaqueRenderables'}
local sphereEvent
local function sphere(event,test)
    for _,e in ipairs(SPHERE_EVENTS) do hook.Remove(e,'StormFxPerfReference') end
    sphereEvent=event
    if not event then return end
    local at=test.effectPos+Vector(0,0,40)
    hook.Add(event,'StormFxPerfReference',function(d,s,s3)
        if d or s or s3 then return end
        render.SetColorMaterial()
        render.DrawSphere(at,40,16,16,Color(255,0,0))
    end)
end
-- Hooks of the other addons on the render events around the effects (GShader Library
-- rebuilds depth and normals in PreDrawTranslucentRenderables and forces NeedsDepthPass):
-- recorded in the report, taken out for the '_alone' variants, put back afterwards.
local OTHER_EVENTS={'NeedsDepthPass','PreDrawOpaqueRenderables','PostDrawOpaqueRenderables','PreDrawTranslucentRenderables',
    'PostDrawTranslucentRenderables','PreDrawEffects','PostDrawEffects','RenderScene','PreRender'}
local removed
local function others()
    local out={}
    for _,event in ipairs(OTHER_EVENTS) do
        for name,fn in pairs(hook.GetTable()[event] or {}) do
            if not (isstring(name) and name:find('^StormFx')) then out[#out+1]={event=event,name=name,fn=fn} end
        end
    end
    return out
end
local function removeOthers()
    removed=removed or {}
    for _,h in ipairs(others()) do removed[#removed+1]=h hook.Remove(h.event,h.name) end
end
local function restoreOthers()
    for _,h in ipairs(removed or {}) do hook.Add(h.event,h.name,h.fn) end
    removed=nil
end
-- Variants of the occlusion captures, in order; each is captured 'wait' seconds after its
-- set(). P.drawHook='none' hides the effects without stopping them. (R107: with $writedepth
-- 1 the materials drew over everything; the sphere is the reference a depth-tested draw
-- gives, removeOthers() the check that no other addon is involved.)
local OCCLUSION={
    -- the engine as it is, translucent pass, then end of the opaque pass
    {name='effect',set=function() P.drawHook='translucent' end},
    {name='effect_opaque',set=function() P.drawHook='opaque' end},
    -- the sphere alone
    {name='sphere',set=function(test) P.drawHook='none' sphere('PostDrawTranslucentRenderables',test) end},
    -- the effect without the other addons' render hooks
    {name='effect_alone',set=function(test) removeOthers() sphere(nil) P.drawHook='translucent' end,wait=0.5},
    -- the effect with the plate hidden: it is there and drawn
    {name='effect_nowall',set=function(test) restoreOthers() if IsValid(test.wall) then test.wall:SetNoDraw(true) end end},
}
function OCCLUSION.restore()
    sphere(nil)
    restoreOthers()
    P.drawHook='translucent'
end

local function finish()
    hook.Remove('Think','StormFxPerfTest')
    hook.Remove('PostRender','StormFxPerfTest')
    OCCLUSION.restore()
    if IsValid(test.wall) then test.wall:Remove() end
    P.stop()
    P.skip={}
    P.setExact(test.exactBefore)
    RunConsoleCommand('storm_fx_water_views',test.waterBefore)
    file.Write(DIR..'/perf.json',util.TableToJSON(test.report,true))
    for _,row in ipairs(test.report.cases) do
        print(string.format('Storm FX perf: %d x %s%s%s: %.2f ms a frame (%.0f fps), engine %.2f + %.2f ms (draw list %.2f ms, %.1f views), %d draws a view',
            row.count,test.effect,row.far and ', far' or (row.water and ', water views' or ''),row.skip and ', without '..row.skip or '',
            row.frameMs,1000/row.frameMs,row.updateMs,row.renderMs,row.buildMs,row.calls,row.draws))
    end
    print('Storm FX perf test done -> data/'..DIR..'/perf.json')
    test=nil
end

local function start(package,effect,delay)
    if test then print('Storm FX perf test already running') return end
    file.CreateDir(DIR)
    test={package=package,effect=effect,started=RealTime()+(delay or 0),phase='ui',exactBefore=P.isExact(),
        report={version=P.version,gmod=VERSIONSTR or tostring(VERSION),branch=BRANCH or '?',map=game.GetMap(),
            screen={ScrW(),ScrH()},date=os.date('%Y-%m-%d %H:%M:%S'),package=package,effect=effect,cases={},captures={}}}
    local cases={}
    for _,count in ipairs(COUNTS) do cases[#cases+1]={count=count} end
    -- Eight copies far away: the same draws on few pixels (draw cost against fill cost).
    cases[#cases+1]={count=8,far=true}
    for _,skip in ipairs(ATTRIBUTION) do cases[#cases+1]={count=8,skip=skip} end
    -- Eight with the water's reflection / refraction views drawn too (storm_fx_water_views 1).
    cases[#cases+1]={count=8,water=true}
    local water=GetConVar('storm_fx_water_views')
    test.waterBefore=water and water:GetString() or '0'
    test.queue=cases
    print('Storm FX perf test: close the console; it starts once it is closed.')
    local last
    hook.Add('Think','StormFxPerfTest',function()
        if not test then return end
        local now=SysTime()
        local frame=last and (now-last) or nil
        last=now
        if RealTime()<test.started or test.pending then return end
        local t=RealTime()
        if test.phase=='ui' then
            if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end
            local player=LocalPlayer()
            if IsValid(player) then player:SetEyeAngles(Angle(10,player:EyeAngles().y,0)) end
            test.phase='occlusion' test.phaseAt=t
            -- One copy behind an opaque plate standing across the view, 150 units ahead.
            spawn(1,true)
            local origin,angles=eye()
            local wall=ClientsideModel('models/hunter/plates/plate2x2.mdl',RENDERGROUP_OPAQUE)
            if IsValid(wall) then
                wall:SetPos(origin+angles:Forward()*150)
                wall:SetAngles(Angle(angles.p+90,angles.y,0))
                wall:Spawn()
            end
            test.wall=wall
            test.report.wall=IsValid(wall)
            -- The other addons' render hooks and the depth settings in force.
            test.report.hooks={}
            for _,h in ipairs(others()) do
                local names=test.report.hooks[h.event] or {}
                names[#names+1]=tostring(h.name)
                test.report.hooks[h.event]=names
            end
            test.report.convars={}
            for _,name in ipairs({'mat_queue_mode','mat_antialias','r_shaderlib','r_shaderlib_depthbuffer','r_shaderlib_3dskybox',
                'r_shaderlib_bumps','r_shaderlib_lightmaps','r_3dsky'}) do
                local cv=GetConVar(name)
                if cv then test.report.convars[name]=cv:GetString() end
            end
        elseif test.phase=='occlusion' then
            -- One capture per variant, the effect behind the plate (see OCCLUSION): set at
            -- stepAt, captured 'wait' seconds later, the first one second into the phase.
            local variant=test.variant
            if not variant then
                if t-test.phaseAt>1.0 then
                    local step=(test.occlusionStep or 0)+1
                    test.occlusionStep=step
                    variant=OCCLUSION[step]
                    if variant then variant.set(test) test.variant=variant test.stepAt=t
                    else
                        OCCLUSION.restore()
                        if IsValid(test.wall) then test.wall:Remove() end
                        test.phase='case' test.case=0
                    end
                end
            elseif t-test.stepAt>=(variant.wait or 0.25) then
                test.pending='occlusion_'..variant.name
                test.variant=nil
            end
        elseif test.phase=='case' then
            local current=test.current
            if not current or t-current.at>=WARM+MEASURE then
                if current then
                    local n=math.max(current.frames,1)
                    local views={}
                    for name in pairs(current.views) do views[#views+1]=name end
                    table.sort(views)
                    test.report.cases[#test.report.cases+1]={count=current.count,far=current.far,skip=current.skip,water=current.water,frames=current.frames,
                        frameMs=current.frameSum/n*1000,updateMs=current.updateSum/n,renderMs=current.renderSum/n,
                        buildMs=current.buildSum/n,calls=current.callSum/n,views=views,
                        draws=math.floor(current.drawSum/n+0.5),worstFrameMs=current.worst*1000}
                end
                test.case=test.case+1
                local nextCase=test.queue[test.case]
                if not nextCase then finish() return end
                P.setExact(false)
                RunConsoleCommand('storm_fx_water_views',nextCase.water and '1' or '0')
                -- 'render': nothing drawn (the update alone); otherwise one step left out.
                P.skip={} P.drawHook='translucent'
                if nextCase.skip=='render' then P.drawHook='none' P.draws=0 P.renderMs=0 P.buildMs=0 P.calls=0 P.views={}
                elseif nextCase.skip then P.skip[nextCase.skip]=true end
                spawn(nextCase.count,false,nextCase.far)
                test.current={count=nextCase.count,far=nextCase.far,skip=nextCase.skip,water=nextCase.water,at=t,frames=0,frameSum=0,updateSum=0,renderSum=0,
                    buildSum=0,callSum=0,views={},drawSum=0,worst=0}
            elseif frame and t-current.at>=WARM then
                -- Think runs before the frame is drawn: P.renderMs and the rest are the
                -- previous frame's (all its views).
                current.frames=current.frames+1
                current.frameSum=current.frameSum+frame
                current.worst=math.max(current.worst,frame)
                current.updateSum=current.updateSum+P.updateMs
                current.renderSum=current.renderSum+P.renderMs
                current.buildSum=current.buildSum+P.buildMs
                current.callSum=current.callSum+P.calls
                for _,name in ipairs(P.views) do current.views[name]=true end
                current.drawSum=current.drawSum+P.draws
            end
        end
    end)
    hook.Add('PostRender','StormFxPerfTest',function()
        if not test or not test.pending then return end
        local data=render.Capture({format='png',x=0,y=0,w=ScrW(),h=ScrH(),alpha=false})
        local name=test.pending..'.png'
        if data then file.Write(DIR..'/'..name,data) end
        test.report.captures[#test.report.captures+1]={label=test.pending,file=data and name or nil,
            drawHook=P.drawHook,sphere=sphereEvent,others=#others()}
        test.pending=nil
    end)
end
P.perftest=start
concommand.Add('storm_fx_perftest',function(_,_,args)
    start(args[1] and args[1]~='' and args[1] or '4efb_amt1_x',args[2] and args[2]~='' and args[2] or '4efb_amt1_blt00')
end)
