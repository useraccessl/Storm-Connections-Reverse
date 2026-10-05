-- In-game profile of the engine: storm_fx_profile [seconds]
-- Every function of StormFX.Core and the engine's own steps are timed (SysTime) while effects
-- play; the most expensive ones are printed and written to data/storm_fx_selftest/profile.json.
-- The timing adds a little to every call: compare the functions with each other, not with the
-- frame time.

StormFX.Profile = StormFX.Profile or {}

local PROFILE = StormFX.Profile

local DIRECTORY = "storm_fx_selftest"
local HOOK = "StormFX:Profile"

-- The engine steps timed besides the cores
local ENGINE_STEPS = {
    "UpdateCasts", "UpdateEffects", "SettleTrailSets", "UpdateTrailSet", "CollectLights", "ShowLights", "LightSlot",
    "BuildEntries", "DrawEntries", "RenderEffects"
}

-- The original functions, while a profile runs
local tOriginals

-- Time every function of a table under a label
local function fnWrap(tOwner, sLabel, tRows)

    for sName, fnOriginal in pairs(tOwner) do

        if type(fnOriginal) == "function" then

            local tRow = {time = 0, calls = 0}
            local sKey = sLabel .. "." .. sName

            tRows[sKey] = tRow
            tOriginals[#tOriginals + 1] = {owner = tOwner, name = sName, fn = fnOriginal}

            tOwner[sName] = function(...)

                local flStart = SysTime()
                local a, b, c, d = fnOriginal(...)

                tRow.time = tRow.time + SysTime() - flStart
                tRow.calls = tRow.calls + 1

                return a, b, c, d

            end

        end

    end

end

-- Put the original functions back
local function fnRestore()

    for _, tOriginal in ipairs(tOriginals or {}) do
        tOriginal.owner[tOriginal.name] = tOriginal.fn
    end

    tOriginals = nil

end

-- Profile for flSeconds
function PROFILE:Start(flSeconds)

    if tOriginals then
        print("Storm FX profile already running")
        return
    end

    tOriginals = {}

    local tRows = {}
    local ENGINE = StormFX.Engine

    for sModule, tModule in pairs(StormFX.Core) do
        fnWrap(tModule, sModule, tRows)
    end

    fnWrap(StormFX.Render, "Render", tRows)

    local tSteps = {}

    for _, sName in ipairs(ENGINE_STEPS) do
        tSteps[sName] = ENGINE[sName]
    end

    fnWrap(tSteps, "Engine", tRows)

    for sName, fnStep in pairs(tSteps) do
        ENGINE[sName] = fnStep
    end

    -- The engine steps are methods of ENGINE: their wrappers replace them there, and go back
    for _, tOriginal in ipairs(tOriginals) do
        if tOriginal.owner == tSteps then
            tOriginal.owner = ENGINE
        end
    end

    local flStarted, iFrames = SysTime(), 0

    print(string.format("Storm FX profile: %d seconds, play the effects now", flSeconds))

    hook.Add("Think", HOOK, function()

        iFrames = iFrames + 1

        if SysTime() - flStarted < flSeconds then return end

        hook.Remove("Think", HOOK)
        fnRestore()

        local tSorted = {}

        for sKey, tRow in pairs(tRows) do
            if tRow.calls > 0 then
                tSorted[#tSorted + 1] = {name = sKey, ms = tRow.time * 1000 / iFrames, calls = tRow.calls / iFrames}
            end
        end

        table.sort(tSorted, function(tA, tB) return tA.ms > tB.ms end)

        print(string.format("Storm FX profile, %d frames, %d effects at the end: ms a frame (calls a frame)", iFrames, #ENGINE.tInstances))

        for i = 1, math.min(25, #tSorted) do
            print(string.format("  %7.3f ms  %8.1f  %s", tSorted[i].ms, tSorted[i].calls, tSorted[i].name))
        end

        file.CreateDir(DIRECTORY)
        file.Write(DIRECTORY .. "/profile.json", util.TableToJSON({frames = iFrames, rows = tSorted}, true))

        print("-> data/" .. DIRECTORY .. "/profile.json")

    end)

end

concommand.Add("storm_fx_profile", function(_, _, tArgs)
    PROFILE:Start(math.Clamp(tonumber(tArgs[1]) or 10, 1, 120))
end)
