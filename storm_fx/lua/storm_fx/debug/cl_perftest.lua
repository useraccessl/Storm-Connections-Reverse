-- In-game performance and occlusion test: storm_fx_perftest [package] [effect]
-- 1. Occlusion: an opaque plate stands between the camera and a playing effect; the screen is
--    captured for the effect, for a depth-tested sphere of Garry's Mod's own in its place, and
--    for the effect with the other addons' render hooks taken out (OCCLUSION), into
--    data/storm_fx_selftest/occlusion_*.png.
-- 2. Performance: 0, 1, 2, 4 and 8 copies of a looping effect play in front of the camera
--    (doubles, no float32 rounding), then eight far away, then eight with one step of the draw
--    loop left out (StormFX.Engine.tSkip) or no rendering at all, then eight drawn in the water
--    views too (storm_fx_water_views 1, put back afterwards); for each case the real frame
--    time, the engine's own update / render time, the views and the draws are averaged over two
--    seconds.
-- The results go to data/storm_fx_selftest/perf.json. The game stays open.

StormFX.PerfTest = StormFX.PerfTest or {}

local PERF_TEST = StormFX.PerfTest
local ENGINE = StormFX.Engine

local DIRECTORY = "storm_fx_selftest"
local HOOK = "StormFX:PerfTest"

-- Copies of the effect of the cases
local COUNTS = {0, 1, 2, 4, 8}

-- Seconds of each case before measuring, then measured
local WARM, MEASURE = 1.0, 2.0

-- Cost attribution of eight effects: one draw-loop step left out, or nothing rendered
local ATTRIBUTION = {"draw", "apply", "matrix", "blend", "render"}

-- Hooks of the other addons on the render events around the effects (GShader Library rebuilds
-- depth and normals in PreDrawTranslucentRenderables and forces NeedsDepthPass): recorded in
-- the report, taken out for the "_alone" variant, put back afterwards
local OTHER_EVENTS = {
    "NeedsDepthPass", "PreDrawOpaqueRenderables", "PostDrawOpaqueRenderables", "PreDrawTranslucentRenderables",
    "PostDrawTranslucentRenderables", "PreDrawEffects", "PostDrawEffects", "RenderScene", "PreRender"
}

-- The events the reference sphere can be drawn from
local SPHERE_EVENTS = {"PostDrawTranslucentRenderables", "PostDrawOpaqueRenderables"}

-- Depth and render settings written in the report
local CONVARS = {
    "mat_queue_mode", "mat_antialias", "r_shaderlib", "r_shaderlib_depthbuffer", "r_shaderlib_3dskybox",
    "r_shaderlib_bumps", "r_shaderlib_lightmaps", "r_3dsky"
}

-- The test running, or nil
local tTest

-- The other addons' hooks taken out, and the event the sphere is drawn from
local tRemoved
local sSphereEvent

local function fnEye()

    local pPlayer = LocalPlayer()

    return pPlayer:EyePos(), pPlayer:EyeAngles()

end

-- Copies of the effect spread on the ground in front of the camera. bCentred: one copy
-- straight ahead, on the view axis (behind the occluding plate). bFar: ten times as far (the
-- same draws, a fraction of the pixels).
local function fnSpawn(iCount, bCentred, bFar)

    ENGINE:StopAll()

    local vecOrigin, angView = fnEye()

    local vecForward = angView:Forward()
    vecForward.z = 0
    vecForward:Normalize()

    local vecRight = angView:Right()
    vecRight.z = 0
    vecRight:Normalize()

    local flFar = bFar and 10 or 1

    for i = 1, iCount do

        local iColumn, iRow = (i - 1) % 4, math.floor((i - 1) / 4)
        local vecPos = bCentred and vecOrigin + vecForward * 360
            or vecOrigin + vecForward * ((260 + iRow * 120) * flFar) + vecRight * ((iColumn - 1.5) * 110 * flFar)

        local tGround = util.TraceLine({start = vecPos + Vector(0, 0, 64), endpos = vecPos - Vector(0, 0, 512), mask = MASK_SOLID_BRUSHONLY})
        local vecAt = tGround.Hit and tGround.HitPos or vecPos

        tTest.effectPos = vecAt
        ENGINE:PlayEffect(tTest.package, tTest.effect, {pos = vecAt, yaw = angView.y, scale = StormFX.Config["scale"]}, i)

    end

end

-- A red sphere of Garry's Mod's own (render.SetColorMaterial: depth tested) where the effect
-- is, drawn from the given hook, or none
local function fnSphere(sEvent)

    for _, sOther in ipairs(SPHERE_EVENTS) do
        hook.Remove(sOther, HOOK .. ":Sphere")
    end

    sSphereEvent = sEvent

    if not sEvent then return end

    local vecAt = tTest.effectPos + Vector(0, 0, 40)

    hook.Add(sEvent, HOOK .. ":Sphere", function(bDepth, bSky, bSky3d)

        if bDepth or bSky or bSky3d then return end

        render.SetColorMaterial()
        render.DrawSphere(vecAt, 40, 16, 16, Color(255, 0, 0))

    end)

end

-- The other addons' hooks on the render events
local function fnOthers()

    local tOthers = {}

    for _, sEvent in ipairs(OTHER_EVENTS) do
        for name, fnHook in pairs(hook.GetTable()[sEvent] or {}) do
            if not (isstring(name) and name:find("^StormFX:")) then
                tOthers[#tOthers + 1] = {event = sEvent, name = name, fn = fnHook}
            end
        end
    end

    return tOthers

end

local function fnRemoveOthers()

    tRemoved = tRemoved or {}

    for _, tHook in ipairs(fnOthers()) do
        tRemoved[#tRemoved + 1] = tHook
        hook.Remove(tHook.event, tHook.name)
    end

end

local function fnRestoreOthers()

    for _, tHook in ipairs(tRemoved or {}) do
        hook.Add(tHook.event, tHook.name, tHook.fn)
    end

    tRemoved = nil

end

-- The variants of the occlusion captures, in order; each is captured "wait" seconds after its
-- set(). sDrawHook = "none" hides the effects without stopping them. (R107: with $writedepth 1
-- the materials drew over everything; the sphere is the reference a depth-tested draw gives,
-- fnRemoveOthers() the check that no other addon is involved.)
local OCCLUSION = {

    -- The engine as it is, translucent pass, then end of the opaque pass
    {name = "effect", set = function() ENGINE.sDrawHook = "translucent" end},
    {name = "effect_opaque", set = function() ENGINE.sDrawHook = "opaque" end},

    -- The sphere alone
    {name = "sphere", set = function()
        ENGINE.sDrawHook = "none"
        fnSphere("PostDrawTranslucentRenderables")
    end},

    -- The effect without the other addons' render hooks
    {name = "effect_alone", wait = 0.5, set = function()
        fnRemoveOthers()
        fnSphere(nil)
        ENGINE.sDrawHook = "translucent"
    end},

    -- The effect with the plate hidden: it is there and drawn
    {name = "effect_nowall", set = function()

        fnRestoreOthers()

        if IsValid(tTest.wall) then
            tTest.wall:SetNoDraw(true)
        end

    end}

}

local function fnRestoreOcclusion()

    fnSphere(nil)
    fnRestoreOthers()

    ENGINE.sDrawHook = "translucent"

end

-- Write the report and put everything back
local function fnFinish()

    hook.Remove("Think", HOOK)
    hook.Remove("PostRender", HOOK)

    fnRestoreOcclusion()

    if IsValid(tTest.wall) then
        tTest.wall:Remove()
    end

    ENGINE:StopAll()
    ENGINE.tSkip = {}
    ENGINE:SetExact(tTest.exactBefore)
    StormFX.Config["batchParticles"] = tTest.batchBefore

    RunConsoleCommand("storm_fx_water_views", tTest.waterBefore)

    file.Write(DIRECTORY .. "/perf.json", util.TableToJSON(tTest.report, true))

    for _, tRow in ipairs(tTest.report.cases) do

        local sVariant = tRow.far and ", far" or (tRow.water and ", water views" or (tRow.single and ", one draw a particle" or ""))
        local sSkip = tRow.skip and ", without " .. tRow.skip or ""

        print(string.format("Storm FX perf: %d x %s%s%s: %.2f ms a frame (%.0f fps), engine %.2f + %.2f ms (draw list %.2f ms, %.1f views), %d draws a view",
            tRow.count, tTest.effect, sVariant, sSkip, tRow.frameMs, 1000 / tRow.frameMs, tRow.updateMs, tRow.renderMs, tRow.buildMs, tRow.calls, tRow.draws))

    end

    print("Storm FX perf test done -> data/" .. DIRECTORY .. "/perf.json")

    tTest = nil

end

-- Phase "ui": wait for the console to close, then put one copy behind an opaque plate standing
-- across the view, 150 units ahead
local function fnStartOcclusion(flTime)

    if gui.IsGameUIVisible() or gui.IsConsoleVisible() then return end

    local pPlayer = LocalPlayer()

    if IsValid(pPlayer) then
        pPlayer:SetEyeAngles(Angle(10, pPlayer:EyeAngles().y, 0))
    end

    tTest.phase = "occlusion"
    tTest.phaseAt = flTime

    fnSpawn(1, true)

    local vecOrigin, angView = fnEye()
    local eWall = ClientsideModel("models/hunter/plates/plate2x2.mdl", RENDERGROUP_OPAQUE)

    if IsValid(eWall) then
        eWall:SetPos(vecOrigin + angView:Forward() * 150)
        eWall:SetAngles(Angle(angView.p + 90, angView.y, 0))
        eWall:Spawn()
    end

    tTest.wall = eWall
    tTest.report.wall = IsValid(eWall)

    -- The other addons' render hooks and the depth settings in force
    tTest.report.hooks = {}

    for _, tHook in ipairs(fnOthers()) do
        local tNames = tTest.report.hooks[tHook.event] or {}
        tNames[#tNames + 1] = tostring(tHook.name)
        tTest.report.hooks[tHook.event] = tNames
    end

    tTest.report.convars = {}

    for _, sName in ipairs(CONVARS) do

        local cvSetting = GetConVar(sName)

        if cvSetting then
            tTest.report.convars[sName] = cvSetting:GetString()
        end

    end

end

-- Phase "occlusion": one capture per variant, the effect behind the plate. A variant is set
-- at stepAt and captured "wait" seconds later, the first one second into the phase.
local function fnStepOcclusion(flTime)

    local tVariant = tTest.variant

    if tVariant then

        if flTime - tTest.stepAt >= (tVariant.wait or 0.25) then
            tTest.pending = "occlusion_" .. tVariant.name
            tTest.variant = nil
        end

        return

    end

    if flTime - tTest.phaseAt <= 1.0 then return end

    tTest.occlusionStep = (tTest.occlusionStep or 0) + 1
    tVariant = OCCLUSION[tTest.occlusionStep]

    if tVariant then

        tVariant.set()
        tTest.variant = tVariant
        tTest.stepAt = flTime

    else

        fnRestoreOcclusion()

        if IsValid(tTest.wall) then
            tTest.wall:Remove()
        end

        tTest.phase = "case"
        tTest.case = 0

    end

end

-- The averages of a measured case
local function fnCaseResult(tCurrent)

    local iFrames = math.max(tCurrent.frames, 1)
    local tViews = {}

    for sName in pairs(tCurrent.views) do
        tViews[#tViews + 1] = sName
    end

    table.sort(tViews)

    return {
        count = tCurrent.count,
        far = tCurrent.far,
        skip = tCurrent.skip,
        water = tCurrent.water,
        single = tCurrent.single,
        frames = tCurrent.frames,
        frameMs = tCurrent.frameSum / iFrames * 1000,
        updateMs = tCurrent.updateSum / iFrames,
        renderMs = tCurrent.renderSum / iFrames,
        buildMs = tCurrent.buildSum / iFrames,
        calls = tCurrent.callSum / iFrames,
        views = tViews,
        draws = math.floor(tCurrent.drawSum / iFrames + 0.5),
        worstFrameMs = tCurrent.worst * 1000
    }

end

-- Start the next case
local function fnNextCase(flTime)

    tTest.case = tTest.case + 1

    local tCase = tTest.queue[tTest.case]

    if not tCase then
        fnFinish()
        return
    end

    ENGINE:SetExact(false)
    RunConsoleCommand("storm_fx_water_views", tCase.water and "1" or "0")
    StormFX.Config["batchParticles"] = not tCase.single and tTest.batchBefore

    -- "render": nothing drawn (the update alone); otherwise one step left out
    ENGINE.tSkip = {}
    ENGINE.sDrawHook = "translucent"

    if tCase.skip == "render" then
        ENGINE.sDrawHook = "none"
        ENGINE.iDraws, ENGINE.flRenderMs, ENGINE.flBuildMs, ENGINE.iCalls, ENGINE.tViews = 0, 0, 0, 0, {}
    elseif tCase.skip then
        ENGINE.tSkip[tCase.skip] = true
    end

    fnSpawn(tCase.count, false, tCase.far)

    tTest.current = {
        count = tCase.count,
        far = tCase.far,
        skip = tCase.skip,
        water = tCase.water,
        single = tCase.single,
        at = flTime,
        frames = 0,
        frameSum = 0,
        updateSum = 0,
        renderSum = 0,
        buildSum = 0,
        callSum = 0,
        views = {},
        drawSum = 0,
        worst = 0
    }

end

-- Phase "case": measure the current case, then start the next one
local function fnStepCase(flTime, flFrame)

    local tCurrent = tTest.current

    if not tCurrent or flTime - tCurrent.at >= WARM + MEASURE then

        if tCurrent then
            tTest.report.cases[#tTest.report.cases + 1] = fnCaseResult(tCurrent)
        end

        fnNextCase(flTime)

    elseif flFrame and flTime - tCurrent.at >= WARM then

        -- Think runs before the frame is drawn: the engine's figures are the previous frame's
        -- (all its views)
        tCurrent.frames = tCurrent.frames + 1
        tCurrent.frameSum = tCurrent.frameSum + flFrame
        tCurrent.worst = math.max(tCurrent.worst, flFrame)
        tCurrent.updateSum = tCurrent.updateSum + ENGINE.flUpdateMs
        tCurrent.renderSum = tCurrent.renderSum + ENGINE.flRenderMs
        tCurrent.buildSum = tCurrent.buildSum + ENGINE.flBuildMs
        tCurrent.callSum = tCurrent.callSum + ENGINE.iCalls

        for _, sName in ipairs(ENGINE.tViews) do
            tCurrent.views[sName] = true
        end

        tCurrent.drawSum = tCurrent.drawSum + ENGINE.iDraws

    end

end

-- Start the test, flDelay seconds from now
function PERF_TEST:Start(sPackage, sEffect, flDelay)

    if tTest then
        print("Storm FX perf test already running")
        return
    end

    file.CreateDir(DIRECTORY)

    tTest = {
        package = sPackage,
        effect = sEffect,
        started = RealTime() + (flDelay or 0),
        phase = "ui",
        exactBefore = ENGINE:IsExact(),
        batchBefore = StormFX.Config["batchParticles"] ~= false,
        report = {
            version = ENGINE.sVersion,
            gmod = VERSIONSTR or tostring(VERSION),
            branch = BRANCH or "?",
            map = game.GetMap(),
            screen = {ScrW(), ScrH()},
            date = os.date("%Y-%m-%d %H:%M:%S"),
            package = sPackage,
            effect = sEffect,
            cases = {},
            captures = {}
        }
    }

    local tCases = {}

    for _, iCount in ipairs(COUNTS) do
        tCases[#tCases + 1] = {count = iCount}
    end

    -- Eight copies far away: the same draws on few pixels (draw cost against fill cost)
    tCases[#tCases + 1] = {count = 8, far = true}

    for _, sSkip in ipairs(ATTRIBUTION) do
        tCases[#tCases + 1] = {count = 8, skip = sSkip}
    end

    -- Eight with the water's reflection / refraction views drawn too
    tCases[#tCases + 1] = {count = 8, water = true}

    -- Eight with the small particles drawn one by one (Config batchParticles false)
    tCases[#tCases + 1] = {count = 8, single = true}

    local cvWater = GetConVar("storm_fx_water_views")

    tTest.waterBefore = cvWater and cvWater:GetString() or "0"
    tTest.queue = tCases

    print("Storm FX perf test: close the console; it starts once it is closed.")

    local flLast

    hook.Add("Think", HOOK, function()

        if not tTest then return end

        local flNow = SysTime()
        local flFrame = flLast and (flNow - flLast) or nil

        flLast = flNow

        if RealTime() < tTest.started or tTest.pending then return end

        local flTime = RealTime()

        if tTest.phase == "ui" then
            fnStartOcclusion(flTime)
        elseif tTest.phase == "occlusion" then
            fnStepOcclusion(flTime)
        elseif tTest.phase == "case" then
            fnStepCase(flTime, flFrame)
        end

    end)

    hook.Add("PostRender", HOOK, function()

        if not tTest or not tTest.pending then return end

        local sData = render.Capture({format = "png", x = 0, y = 0, w = ScrW(), h = ScrH(), alpha = false})
        local sFile = tTest.pending .. ".png"

        if sData then
            file.Write(DIRECTORY .. "/" .. sFile, sData)
        end

        tTest.report.captures[#tTest.report.captures + 1] = {
            label = tTest.pending,
            file = sData and sFile or nil,
            drawHook = ENGINE.sDrawHook,
            sphere = sSphereEvent,
            others = #fnOthers()
        }

        tTest.pending = nil

    end)

end

concommand.Add("storm_fx_perftest", function(_, _, tArgs)

    local sPackage = tArgs[1] and tArgs[1] ~= "" and tArgs[1] or "4efb_amt1_x"
    local sEffect = tArgs[2] and tArgs[2] ~= "" and tArgs[2] or "4efb_amt1_blt00"

    PERF_TEST:Start(sPackage, sEffect)

end)
