-- Section timers of the engine (storm_fx_sections 1 [seconds] | 0 | dump): blocks of the
-- drawing and the update are timed with SysTime where they run, and summed by name; every
-- interval the sums are printed (calls, calls a second, average, total, longest, in ms) with
-- the frame rate. When the gamemode's profiler runs (solve_head_profile 1), the sections go
-- to it too. Off, a section costs one test.
-- storm_fx_skip <step> [1|0] leaves a step of the drawing out, to tell what costs: draw (no
-- mesh drawn), fill (drawn through a one-pixel scissor: the draw calls stay, the pixels go),
-- apply (no pixel constants), blend (no render state), build (the list kept, never rebuilt).
-- What Lua times is the Lua side: with mat_queue_mode -1 the draws are queued for the render
-- thread, and the GPU's work (pixels, blending) is not in these figures.

StormFX.Sections = StormFX.Sections or {}

local SECTIONS = StormFX.Sections

SECTIONS.bEnabled = false
SECTIONS.flInterval = 5
SECTIONS.tBuckets = {}
SECTIONS.tCounters = {}
SECTIONS.iFrames = 0
SECTIONS.flStarted = SysTime()

-- An average hides the slow frames: every frame's time and the time Storm FX spent in it are
-- kept, and printed as percentiles. The sections that are not inside another one make up
-- what Storm FX spent.
SECTIONS.tFrameTimes = {}
SECTIONS.tFrameSpent = {}
SECTIONS.flFrameSpent = 0

local TOP_SECTIONS = {hook = true, think_update = true, think_prerecord = true, think_lights = true}

-- The gamemode's profiler when it is there (solve_head_profile 1): the sections are also
-- given to it, as "stormfx_<name>"
local function fnHost()

    local tSolve = Solve and Solve.Naruto and Solve.Naruto.CharacterCreator
    local tProfiler = tSolve and tSolve.HeadProfiler

    if tProfiler and tProfiler.enabled and tProfiler.Add then
        return tProfiler
    end

end

-- Whether the sections are timed (checked once per hook call)
function SECTIONS:Active()
    return self.bEnabled or fnHost() ~= nil
end

-- Add flSeconds to a section
function SECTIONS:Add(sName, flSeconds)

    local tHost = fnHost()

    if tHost then
        tHost:Add("stormfx_" .. sName, flSeconds)
    end

    if not self.bEnabled then return end

    if TOP_SECTIONS[sName] then
        self.flFrameSpent = self.flFrameSpent + flSeconds
    end

    local tBucket = self.tBuckets[sName]

    if not tBucket then
        tBucket = {calls = 0, total = 0, max = 0}
        self.tBuckets[sName] = tBucket
    end

    tBucket.calls = tBucket.calls + 1
    tBucket.total = tBucket.total + flSeconds

    if flSeconds > tBucket.max then
        tBucket.max = flSeconds
    end

end

-- What Storm FX allocated (KB): the heap's growth over one of its hooks (a collection during
-- the hook hides some; an estimate)
function SECTIONS:Allocated(flKilobytes)

    if self.bEnabled and flKilobytes > 0 then
        self.flOwnAllocated = (self.flOwnAllocated or 0) + flKilobytes
    end

end

-- Count something (draws, meshes, entries)
function SECTIONS:Count(sName, iAmount)

    local tHost = fnHost()

    if tHost and tHost.Count then
        tHost:Count("stormfx_" .. sName, iAmount)
    end

    if not self.bEnabled then return end

    self.tCounters[sName] = (self.tCounters[sName] or 0) + (iAmount or 1)

end

function SECTIONS:Reset()

    self.tBuckets = {}
    self.tCounters = {}
    self.iFrames = 0
    self.flStarted = SysTime()
    self.tFrameTimes = {}
    self.tFrameSpent = {}
    self.flFrameSpent = 0
    self.flAllocated = 0
    self.flOwnAllocated = 0

end

-- p50 / p95 / p99 / max of a list of seconds, in ms
local function fnPercentiles(tValues)

    local tSorted = {}

    for i, flValue in ipairs(tValues) do
        tSorted[i] = flValue
    end

    table.sort(tSorted)

    local iCount = #tSorted

    if iCount == 0 then return "no frame" end

    local function fnAt(flFraction)
        return tSorted[math.max(1, math.min(iCount, math.ceil(iCount * flFraction)))] * 1000
    end

    return string.format("p50 %.2f | p95 %.2f | p99 %.2f | max %.2f ms", fnAt(0.5), fnAt(0.95), fnAt(0.99), tSorted[iCount] * 1000)

end

-- Print the sums since the last reset
function SECTIONS:Print()

    local flElapsed = math.max(SysTime() - self.flStarted, 0.001)
    local tRows = {}

    for sName, tBucket in pairs(self.tBuckets) do
        tRows[#tRows + 1] = {name = sName, calls = tBucket.calls, total = tBucket.total, max = tBucket.max}
    end

    table.sort(tRows, function(tA, tB) return tA.total > tB.total end)

    print(string.format("[StormFX] %.1f s, %d frames, %.1f fps, %d effects running", flElapsed, self.iFrames, self.iFrames / flElapsed,
        #StormFX.Engine.tInstances))
    print("[StormFX] frame time    " .. fnPercentiles(self.tFrameTimes))
    print("[StormFX] Storm FX time " .. fnPercentiles(self.tFrameSpent))
    print(string.format("[StormFX] Lua heap %.1f MB, allocated about %.1f MB/s (all addons), of which Storm FX about %.1f MB/s",
        collectgarbage("count") / 1024, (self.flAllocated or 0) / 1024 / flElapsed, (self.flOwnAllocated or 0) / 1024 / flElapsed))
    print("[StormFX] section | calls | calls/s | avg ms | ms a frame | total ms | max ms")

    for _, tRow in ipairs(tRows) do
        print(string.format("[StormFX] %-26s | %7d | %8.1f | %7.4f | %7.4f | %9.2f | %7.3f", tRow.name, tRow.calls, tRow.calls / flElapsed,
            tRow.total * 1000 / tRow.calls, tRow.total * 1000 / math.max(self.iFrames, 1), tRow.total * 1000, tRow.max * 1000))
    end

    local tCounters = {}

    for sName, iValue in pairs(self.tCounters) do
        tCounters[#tCounters + 1] = string.format("%s=%.1f/frame", sName, iValue / math.max(self.iFrames, 1))
    end

    table.sort(tCounters)

    if #tCounters > 0 then
        print("[StormFX] counters " .. table.concat(tCounters, " "))
    end

    self:Reset()

end

hook.Add("Think", "StormFX:Sections:Think", function()

    if not SECTIONS.bEnabled then return end

    SECTIONS.iFrames = SECTIONS.iFrames + 1

    -- What Lua allocated (all addons): the heap's growth from frame to frame
    local flHeap = collectgarbage("count")

    if SECTIONS.flHeap and flHeap > SECTIONS.flHeap then
        SECTIONS.flAllocated = (SECTIONS.flAllocated or 0) + flHeap - SECTIONS.flHeap
    end

    SECTIONS.flHeap = flHeap

    -- The last frame's time, and what Storm FX spent since the last Think
    SECTIONS.tFrameTimes[#SECTIONS.tFrameTimes + 1] = RealFrameTime and RealFrameTime() or 0
    SECTIONS.tFrameSpent[#SECTIONS.tFrameSpent + 1] = SECTIONS.flFrameSpent
    SECTIONS.flFrameSpent = 0

    if SysTime() - SECTIONS.flStarted >= SECTIONS.flInterval then
        SECTIONS:Print()
    end

end)

concommand.Add("storm_fx_sections", function(_, _, tArgs)

    local sMode = string.lower(tArgs[1] or "")

    if sMode == "1" or sMode == "on" then

        SECTIONS.bEnabled = true
        SECTIONS.flInterval = math.max(1, tonumber(tArgs[2]) or 5)
        SECTIONS:Reset()

        print("[StormFX] section timers on, every " .. SECTIONS.flInterval .. " s")

    elseif sMode == "0" or sMode == "off" then

        SECTIONS.bEnabled = false
        print("[StormFX] section timers off")

    elseif sMode == "dump" then

        SECTIONS:Print()

    else

        print("storm_fx_sections 1 [seconds] | 0 | dump")

    end

end)

-- storm_fx_share 1 | 0: the animation channels shared between particles (StormFX.Core.AnmResource)
concommand.Add("storm_fx_share", function(_, _, tArgs)

    StormFX.Core.AnmResource.bShare = tArgs[1] ~= "0"
    print("[StormFX] shared animation channels: " .. (StormFX.Core.AnmResource.bShare and "on" or "off"))

end)

-- storm_fx_studio 1 | 0: skinned meshes drawn as their studio models, or by the engine
-- (Config useStudioModels; engine/cl_studio.lua), to compare the two in game
concommand.Add("storm_fx_studio", function(_, _, tArgs)

    StormFX.Config["useStudioModels"] = tArgs[1] ~= "0"
    StormFX.Engine.bListDirty = true

    -- The recordings hold what the particles drew in the other way: made again
    StormFX.Engine.tRecordings = {}
    print("[StormFX] studio models: " .. (StormFX.Config["useStudioModels"] and "on" or "off"))

end)

local SKIP_STEPS = {draw = true, fill = true, apply = true, blend = true, build = true}

concommand.Add("storm_fx_skip", function(_, _, tArgs)

    local sStep = string.lower(tArgs[1] or "")
    local tSkip = StormFX.Engine.tSkip

    if sStep == "none" then

        for sName in pairs(SKIP_STEPS) do
            tSkip[sName] = nil
        end

    elseif SKIP_STEPS[sStep] then

        local bOn = tArgs[2] == nil and not tSkip[sStep] or tArgs[2] == "1"
        tSkip[sStep] = bOn or nil

    else

        print("storm_fx_skip draw|fill|apply|blend|build [1|0] | none")

    end

    local tOn = {}

    for sName in pairs(SKIP_STEPS) do
        if tSkip[sName] then
            tOn[#tOn + 1] = sName
        end
    end

    print("[StormFX] steps left out: " .. (#tOn > 0 and table.concat(tOn, ", ") or "none"))

end)
