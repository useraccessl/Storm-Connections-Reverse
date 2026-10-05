-- In-game self test: storm_fx_selftest [package] [script] [scale] [seed]
-- Casts a skill from the player as storm_fx_cast does (aim at the ground some distance ahead),
-- captures the screen before the cast and at fixed times after it, and writes what the engine
-- did to data/storm_fx_selftest/: report.json (environment, materials and their shaders, per
-- capture the running effects, particles, trail points, draws, skipped resources and dropped
-- effects, every Lua error) and one PNG per capture.
-- It compares nothing with the game: it records what Garry's Mod shows, so that the offline
-- checks can be set against a real frame.

StormFX.SelfTest = StormFX.SelfTest or {}

local SELF_TEST = StormFX.SelfTest
local ENGINE = StormFX.Engine

SELF_TEST.DIRECTORY = "storm_fx_selftest"

-- Seconds after the cast of each capture
local TIMES = {0.15, 0.35, 0.6, 0.9, 1.3, 1.8, 2.5, 3.5}

-- Seconds to wait for the console to close
local WAIT_UI = 20

local HOOK = "StormFX:SelfTest"

-- The test running, or nil
local tRun

-- What the engine shows at a capture
local function fnSnapshot(sLabel)

    local tSnapshot = {
        label = sLabel,
        time = RealTime() - tRun.started,
        draws = ENGINE.iDraws,
        uploads = ENGINE.iUploads,
        renderMs = ENGINE.flRenderMs,
        updateMs = ENGINE.flUpdateMs,
        lights = #ENGINE.tLights,
        effects = {},
        skipped = {},
        failed = {}
    }

    for _, tInstance in ipairs(ENGINE.tInstances) do

        local tEffect = {effect = tInstance.effect, frame = tInstance.frame, particles = tInstance.scene and #tInstance.scene.particles or 0, trails = {}}

        for _, tSet in ipairs(tInstance.trailSets or {}) do
            for _, tTrail in ipairs(tSet.trails) do
                tEffect.trails[#tEffect.trails + 1] = {trail = tTrail.def.index, points = #tTrail.state.points, samples = #tTrail.state.samples}
            end
        end

        tSnapshot.effects[#tSnapshot.effects + 1] = tEffect

    end

    for sName, iCount in pairs(ENGINE.tSkipped) do
        tSnapshot.skipped[tostring(sName)] = iCount
    end

    for sName, sWhy in pairs(ENGINE.tFailed) do
        tSnapshot.failed[tostring(sName)] = tostring(sWhy)
    end

    return tSnapshot

end

-- Every material the package made: error materials, and the shader each one reports
local function fnMaterials(tRuntime)

    local tMaterials = {count = 0, errors = {}, shaders = {}}

    for _, tGroup in ipairs({tRuntime.items or {}, tRuntime.ribbons or {}}) do

        for _, tItem in pairs(tGroup) do

            for _, tPart in ipairs(tItem.parts or {}) do

                local matPart = tPart.mat

                if matPart then

                    tMaterials.count = tMaterials.count + 1

                    if matPart:IsError() then
                        tMaterials.errors[#tMaterials.errors + 1] = matPart:GetName()
                    end

                    local sShader = matPart:GetShader() or "?"
                    tMaterials.shaders[sShader] = (tMaterials.shaders[sShader] or 0) + 1

                end

            end

        end

    end

    return tMaterials

end

-- Write the report and stop
local function fnFinish()

    hook.Remove("Think", HOOK)
    hook.Remove("PostRender", HOOK)
    hook.Remove("OnLuaError", HOOK)

    local tReport = tRun.report
    tReport.duration = RealTime() - tRun.started

    local bOk, tRuntime = pcall(ENGINE.LoadPackage, ENGINE, tRun.package)

    if bOk and tRuntime then

        tReport.materials = fnMaterials(tRuntime)
        tReport.notImported = #(tRuntime.data.unsupported or {})
        tReport.noRenderer = {}

        for sName, sWhy in pairs(tRuntime.unsupported or {}) do
            tReport.noRenderer[tostring(sName)] = tostring(sWhy)
        end

        tReport.packageSource = tRuntime.source

    else

        tReport.loadError = tostring(tRuntime)

    end

    -- Multiplayer: the StormFX calls the server sent to this client (api/cl_network.lua)
    tReport.network = {
        singlePlayer = game.SinglePlayer and game.SinglePlayer() or false,
        calls = ENGINE.iNetCalls or 0,
        last = ENGINE.sLastNetCall
    }

    file.Write(SELF_TEST.DIRECTORY .. "/report.json", util.TableToJSON(tReport, true))

    print(string.format("Storm FX self test %s: %d captures, %d Lua errors, %d materials (%d error materials) -> data/%s/",
        ENGINE.sVersion, #tReport.captures, #tReport.errors, tReport.materials and tReport.materials.count or 0,
        tReport.materials and #tReport.materials.errors or 0, SELF_TEST.DIRECTORY))

    -- Garry's Mod refuses "quit" from Lua ("Command is blocked"): an unattended run is closed
    -- by whatever started the game, once report.json exists
    tRun = nil

end

-- One step of the test, every frame
local function fnThink()

    if not tRun or tRun.pending then return end

    local flNow = RealTime()

    if flNow < tRun.started then return end

    if tRun.phase == "ui" then

        if not gui.IsGameUIVisible() and not gui.IsConsoleVisible() then

            -- Unattended: look down now (the spawn resets the view set at InitPostEntity), so
            -- the eye trace, hence the target, is on the ground a few metres ahead
            local pPlayer = LocalPlayer()

            if tRun.pitch and IsValid(pPlayer) then
                pPlayer:SetEyeAngles(Angle(tRun.pitch, pPlayer:EyeAngles().y, 0))
            end

            tRun.phase = "before"
            tRun.pending = "before"

        elseif flNow - tRun.started > WAIT_UI then

            tRun.report.aborted = "the console or the menu stayed open"
            fnFinish()

        end

    elseif tRun.phase == "cast" then

        local tCast = ENGINE:CastFromPlayer(tRun.package, tRun.script, tRun.scale, tRun.seed)

        if tCast then
            tRun.report.cast = {
                script = tCast.actors[1] and tCast.actors[1].id or "?",
                origin = {tCast.outer.pos.x, tCast.outer.pos.y, tCast.outer.pos.z},
                scale = tCast.outer.scale
            }
        else
            tRun.report.cast = {error = "the cast failed (its reason is in the console)"}
        end

        tRun.castAt = flNow
        tRun.phase = "after"

        if not tCast then
            fnFinish()
        end

    elseif tRun.phase == "after" then

        local flTime = TIMES[tRun.next]

        if not flTime then
            fnFinish()
        elseif flNow - tRun.castAt >= flTime then
            tRun.pending = string.format("t%02d_%.2fs", tRun.next, flTime)
            tRun.next = tRun.next + 1
        end

    end

end

-- Capture the frame just drawn (render.Capture is only valid in a render hook)
local function fnPostRender()

    if not tRun or not tRun.pending then return end

    local sLabel = tRun.pending
    local sData = render.Capture({format = "png", x = 0, y = 0, w = ScrW(), h = ScrH(), alpha = false})
    local sFile = sLabel .. ".png"
    local bWritten = sData and file.Write(SELF_TEST.DIRECTORY .. "/" .. sFile, sData)

    tRun.report.captures[#tRun.report.captures + 1] = {
        label = sLabel,
        file = sData and sFile or nil,
        bytes = sData and #sData or 0,
        written = bWritten ~= false and sData ~= nil
    }

    tRun.report.samples[#tRun.report.samples + 1] = fnSnapshot(sLabel)
    tRun.pending = nil

    if sLabel == "before" then
        tRun.phase = "cast"
    end

end

-- Start the test. flDelay: seconds to wait before looking at the console (the autostart lets
-- the map settle). flPitch: degrees to look down before the cast (unattended runs), or nil to
-- keep the view.
function SELF_TEST:Start(sPackage, sScript, flScale, iSeed, flDelay, flPitch)

    if tRun then
        print("Storm FX self test already running")
        return
    end

    file.CreateDir(self.DIRECTORY)

    tRun = {
        package = sPackage,
        script = sScript,
        scale = flScale,
        seed = iSeed or 1,
        started = RealTime() + (flDelay or 0),
        pitch = flPitch,
        phase = "ui",
        pending = nil,
        next = 1,
        report = {
            version = ENGINE.sVersion,
            gmod = VERSIONSTR or tostring(VERSION),
            branch = BRANCH or "?",
            map = game.GetMap(),
            screen = {ScrW(), ScrH()},
            date = os.date("%Y-%m-%d %H:%M:%S"),
            package = sPackage,
            script = sScript or "(first root)",
            captures = {},
            samples = {},
            errors = {}
        }
    }

    print("Storm FX self test: close the console; the cast starts once it is closed (aim at the ground ahead).")

    hook.Add("OnLuaError", HOOK, function(sError, sRealm, tStack, sName)

        if tRun then
            tRun.report.errors[#tRun.report.errors + 1] = {error = tostring(sError), realm = tostring(sRealm), name = tostring(sName)}
        end

    end)

    hook.Add("Think", HOOK, fnThink)
    hook.Add("PostRender", HOOK, fnPostRender)

end

concommand.Add("storm_fx_selftest", function(_, _, tArgs)

    local sPackage = tArgs[1] and tArgs[1] ~= "" and tArgs[1] or "4efb_amt1_x"
    local sScript = tArgs[2] and tArgs[2] ~= "" and tArgs[2] ~= "-" and tArgs[2] or nil

    SELF_TEST:Start(sPackage, sScript, tonumber(tArgs[3]), tonumber(tArgs[4]))

end)

-- Unattended run: data/storm_fx_selftest/autostart.txt (first line: package, optional) starts
-- the test five seconds after the map has loaded, looking 12 degrees down (the ground about
-- 7 m ahead from the eye height of 64 units). The file is deleted first, so the test runs
-- once; the game stays open (see fnFinish).
-- "perftest [package] [effect]" starts storm_fx_perftest instead (debug/cl_perftest.lua).
hook.Add("InitPostEntity", "StormFX:SelfTest:InitPostEntity", function()

    local sFlag = SELF_TEST.DIRECTORY .. "/autostart.txt"

    if not file.Exists(sFlag, "DATA") then return end

    local sLine = string.Trim((file.Read(sFlag, "DATA") or ""):match("[^\r\n]*") or "")
    file.Delete(sFlag)

    local tWords = string.Explode(" ", sLine)

    if tWords[1] == "perftest" and StormFX.PerfTest then
        StormFX.PerfTest:Start(tWords[2] or "4efb_amt1_x", tWords[3] or "4efb_amt1_blt00", 5)
        return
    end

    SELF_TEST:Start(sLine ~= "" and sLine or "4efb_amt1_x", nil, nil, 1, 5, 12)

end)
