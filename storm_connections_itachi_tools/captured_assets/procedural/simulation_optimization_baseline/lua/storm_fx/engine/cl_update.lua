-- The update: every frame, the skill objects and the effects are stepped at 60 updates a
-- second from their start time, then the point lights are gathered.

local ENGINE = StormFX.Engine
local CONFIG = StormFX.Config

-- Step the skill objects that show no effect of their own; the others are stepped by their
-- effect, once per effect update
function ENGINE:UpdateCasts()

    local tCasts = {}

    for _, tCast in ipairs(self.tCasts) do

        local bBusy = false
        local iIndex = 1

        while iIndex <= #tCast.actors do

            local tActor = tCast.actors[iIndex]

            -- An effect that ran out no longer steps its actor; a one-shot animation that did
            -- has ended (the game keeps it at its last frame)
            if tActor.instance and tActor.instance.finished then
                tActor.animationEnded = not tActor.instance.loop
                tActor.instance = nil
            end

            if tActor.alive and not tActor.instance then

                local iFrame = math.floor((CurTime() - tActor.start) * self.FPS)

                while tActor.alive and not tActor.instance and tActor.frame <= iFrame do

                    tActor.tick()

                    -- An actor with no effect and no event that ends it is dropped
                    if tActor.frame >= CONFIG["maxLoopFrames"] then
                        tActor.alive = false
                    end

                end

            end

            if tActor.alive then
                bBusy = true
            end

            iIndex = iIndex + 1

        end

        if bBusy then
            tCasts[#tCasts + 1] = tCast
        else
            tCast.finished = true
        end

    end

    self.tCasts = tCasts

end

-- Step the effects up to the current frame
function ENGINE:UpdateEffects()

    local tAlive = {}
    local iIndex = 1

    -- Timed by kind and effect (storm_fx_sections): replay, live (simulated), record (simulated
    -- and kept)
    local SECTIONS = StormFX.Sections
    local bTimed = SECTIONS:Active()

    -- The time the simulated (not read back) effects may spend this frame (Config
    -- simulationBudgetMs), and what they spent
    local flBudget = (CONFIG["simulationBudgetMs"] or 0) / 1000
    local flLiveSpent = 0

    -- One effect's steps; whether it plays on. bHidden: a simulated effect the last draw
    -- list left out (out of view, too far, past the bounds): it takes only what the budget has
    -- left, and past it waits as long as it has to (it plays on where it was when seen again).
    local function fnUpdateOne(tInstance, bHidden)

        local iFrame = math.floor((CurTime() - tInstance.start) * self.FPS)

        -- Its time is up (StormFX.Play duration): it ends as the game ends it
        if tInstance.stopAt and CurTime() >= tInstance.stopAt then
            tInstance.killed = true
        end

        -- At most Config maxStepsPerFrame steps a frame: after a slow frame an effect would
        -- otherwise catch up with several steps at once, making the next frame slower still.
        -- Further behind, its clock moves on (the steps are dropped). An effect taken away
        -- (removed: StormFX handle Remove, its parent gone) stops at once.
        local iMaxSteps = CONFIG["maxStepsPerFrame"] or 3

        if iFrame - tInstance.frame >= iMaxSteps then
            tInstance.start = tInstance.start + (iFrame - tInstance.frame - iMaxSteps + 1) / self.FPS
            iFrame = tInstance.frame + iMaxSteps - 1
        end

        -- Past the budget, a simulated effect due a step waits for the next frame (its clock
        -- waits too); one that waited last frame makes one step
        if not tInstance.replay and iFrame >= tInstance.frame then

            if flBudget > 0 and flLiveSpent >= flBudget then

                if tInstance.waited and not bHidden then
                    iFrame = tInstance.frame
                    tInstance.waited = false
                else
                    tInstance.start = tInstance.start + (iFrame - tInstance.frame + 1) / self.FPS
                    iFrame = tInstance.frame - 1
                    tInstance.waited = true

                    if bTimed then
                        SECTIONS:Count("effects_waited")
                    end
                end

            else

                tInstance.waited = false

            end

        end

        local flLiveFrom = not tInstance.replay and SysTime()

        while tInstance.frame <= iFrame and tInstance.frame < tInstance.maxFrames and not tInstance.failed and not tInstance.removed do

            local flFrom = bTimed and SysTime()
            local sKind = tInstance.replay and "step_replay:" or tInstance.recording and "step_record:" or "step_live:"

            -- An effect that hits something the engine cannot simulate is dropped and
            -- reported (storm_fx_diag), it does not stop the others
            local bOk, sWhy = pcall(function()

                -- A replay reads its recorded step instead (engine/cl_replay.lua); a recorded
                -- effect keeps what this step drew
                if tInstance.replay then
                    self:ReplayStep(tInstance)
                    return
                end

                if tInstance.scene then
                    tInstance.scene:Update()
                else
                    tInstance.advance()
                end

                self:SettleTrailSets(tInstance)

                if tInstance.recording then
                    self.RecordStep(tInstance)
                end

            end)

            if not bOk then
                tInstance.failed = tostring(sWhy)
                self.tFailed[tInstance.effect] = tInstance.failed
            end

            if bTimed then
                SECTIONS:Add(sKind .. tInstance.effect, SysTime() - flFrom)
            end

            tInstance.frame = tInstance.frame + 1

            -- The draw list is built again (engine/cl_draw.lua)
            self.bListDirty = true

        end

        if flLiveFrom then
            flLiveSpent = flLiveSpent + SysTime() - flLiveFrom
        end

        local bDrained

        if tInstance.replay then

            bDrained = tInstance.frame >= #tInstance.replay

        else

            bDrained = tInstance.scene and tInstance.scene.emissionStopped and tInstance.scene:IsDrained()
                or (not tInstance.scene and (tInstance.killed or tInstance.ticks >= tInstance.duration))

            for _, tSet in ipairs(tInstance.trailSets or {}) do
                if not self:IsTrailSetEmpty(tSet) then
                    bDrained = false
                end
            end

        end

        if not (bDrained or tInstance.failed or tInstance.removed or tInstance.frame >= tInstance.maxFrames) then
            return true
        end

        tInstance.finished = true
        self.bListDirty = true

        if tInstance.recording then
            self:FinishRecording(tInstance)
        end

        return false

    end

    -- The drawn effects first, the hidden simulated ones with what is left. An effect
    -- launched during another effect's update joins this same pass.
    local tHidden = {}

    while iIndex <= #self.tInstances do

        local tInstance = self.tInstances[iIndex]

        if flBudget > 0 and not tInstance.replay and tInstance.drawn == false then
            tHidden[#tHidden + 1] = tInstance
        elseif fnUpdateOne(tInstance, false) then
            tAlive[#tAlive + 1] = tInstance
        end

        iIndex = iIndex + 1

    end

    for _, tInstance in ipairs(tHidden) do
        if fnUpdateOne(tInstance, true) then
            tAlive[#tAlive + 1] = tInstance
        end
    end

    -- Launched by a hidden one
    while iIndex <= #self.tInstances do

        local tInstance = self.tInstances[iIndex]

        if fnUpdateOne(tInstance, false) then
            tAlive[#tAlive + 1] = tInstance
        end

        iIndex = iIndex + 1

    end

    self.tInstances = tAlive

end

-- One update of everything that plays
function ENGINE:Update()

    local SECTIONS = StormFX.Sections
    local bTimed = SECTIONS:Active()
    local flHeap = bTimed and collectgarbage("count")

    -- Background recordings first (engine/cl_replay.lua), within their budget
    if #self.tWarmups > 0 then

        local flFrom = SysTime()

        self:StepPrerecords(CONFIG["prerecordBudgetMs"] or 1)

        if bTimed then
            SECTIONS:Add("think_prerecord", SysTime() - flFrom)
        end

    end

    if #self.tInstances == 0 and #self.tCasts == 0 then

        self.tLights = {}
        self.flUpdateMs = 0

        if bTimed then
            SECTIONS:Allocated(collectgarbage("count") - flHeap)
        end

        return

    end

    local flStarted = SysTime()

    self:UpdateCasts()

    if bTimed then
        SECTIONS:Add("think_casts", SysTime() - flStarted)
    end

    self:UpdateEffects()

    local flLights = SysTime()

    self.tLights = self:CollectLights()
    self:ShowLights(self.tLights)

    local flNow = SysTime()

    self.flUpdateMs = (flNow - flStarted) * 1000

    if bTimed then
        SECTIONS:Add("think_update", flLights - flStarted)
        SECTIONS:Add("think_lights", flNow - flLights)
        SECTIONS:Allocated(collectgarbage("count") - flHeap)
    end

end

hook.Add("Think", "StormFX:Engine:Think", function()
    StormFX.Engine:Update()
end)
