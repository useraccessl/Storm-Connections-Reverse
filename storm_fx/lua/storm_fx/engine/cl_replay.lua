-- Replays. An effect is deterministic: with the same seed and the same root, every step gives
-- the same particles, models and trails, in game space (the outer transform, which holds the
-- position, the yaw and the scale, only applies at draw). So the first time a one-shot effect
-- plays, what the drawing needs is recorded step by step, and the next times it plays (any
-- position, yaw or scale) the recording is read back: no simulation at all.
-- Recorded: one-shot effects with emitters, under the identity root (an angle without pitch
-- or roll). Not recorded: looping effects, effects of skill scripts (their root moves), an
-- effect stopped before its end (incomplete). Config recordEffects false turns it off.

local ENGINE = StormFX.Engine
local CONFIG = StormFX.Config

local IDENTITY = ENGINE.IDENTITY

-- Recordings by "package/effect/seed": the steps, each {particles, trails, models, lights, ticks}
ENGINE.tRecordings = ENGINE.tRecordings or {}

local function fnIsIdentity(tMatrix)

    for i = 1, 16 do
        if tMatrix[i] ~= IDENTITY[i] then return false end
    end

    return true

end

local function fnCopy3(t)
    return {t[1], t[2], t[3]}
end

-- A copy of a model draw: its matrix and its animated material instances may be tables the
-- next steps rewrite (the skinned vertices it caches are not kept)
local function fnCopyDraw(tDraw)

    if not tDraw then return nil end

    local tCopy = {}

    for sKey, value in pairs(tDraw) do

        if sKey == "matrix" then

            tCopy.matrix = {}

            for i = 1, 16 do
                tCopy.matrix[i] = value[i]
            end

        elseif sKey == "instances" then

            tCopy.instances = {}

            for iIndex, tFields in pairs(value) do

                local tFieldsCopy = {}

                for iOffset, flValue in pairs(tFields) do
                    tFieldsCopy[iOffset] = flValue
                end

                tCopy.instances[iIndex] = tFieldsCopy

            end

        elseif sKey ~= "skinned" then

            tCopy[sKey] = value

        end

    end

    return tCopy

end

local function fnCopyDraws(tDraws)

    if not tDraws then return nil end

    local tCopy = {}

    for i, tDraw in ipairs(tDraws) do
        tCopy[i] = fnCopyDraw(tDraw)
    end

    return tCopy

end

-- The key of a recording
function ENGINE:RecordingKey(sPackage, sEffect, iSeed)
    return sPackage .. "/" .. sEffect .. "/" .. (iSeed or 1)
end

-- Start recording an effect that was just launched (when it can be)
function ENGINE:StartRecording(tInstance, sKey)

    if CONFIG["recordEffects"] == false or tInstance.loop or not tInstance.scene then return end

    tInstance.recording = {key = sKey, steps = {}}

end

-- What one step of the effect drew, kept: the particles (copied: the update rewrites some of
-- their values in place), their model draws, the models of the effect's own animation, its
-- trails (their points are new tables every step) and its point lights
local function fnRecordStep(tInstance)

    local tRecording = tInstance.recording

    -- A moving root (a skill script, a pitched parent) makes another effect each time
    if not fnIsIdentity(tInstance.root) or #tRecording.steps >= (CONFIG["maxRecordedSteps"] or 900) then
        tInstance.recording = nil
        return
    end

    local tStep = {particles = {}, trails = {}, models = {}, lights = {}, ticks = tInstance.ticks}

    for i, tParticle in ipairs(tInstance.scene.particles) do
        tStep.particles[i] = {
            resource = tParticle.resource,
            position = fnCopy3(tParticle.position),
            size = fnCopy3(tParticle.size),
            rotation = fnCopy3(tParticle.rotation),
            color = {tParticle.color[1], tParticle.color[2], tParticle.color[3], tParticle.color[4]},
            alpha = tParticle.alpha,
            ageTicks = tParticle.ageTicks,
            modelDraws = fnCopyDraws(tParticle.modelDraws),
            modelEnabled = tParticle.modelEnabled,
            modelUpdates = tParticle.modelUpdates,

            -- A particle drawn as its resource's studio model: its clock and parent matrix
            studioPose = tParticle.studioPose and {ticks = tParticle.studioPose.ticks, matrix = fnCopyDraw({matrix = tParticle.studioPose.matrix}).matrix}
        }
    end

    for _, tSet in ipairs(tInstance.trailSets) do
        for _, tTrail in ipairs(tSet.trails) do
            tStep.trails[#tStep.trails + 1] = {
                def = tTrail.def,
                board = tTrail.board,
                updates = tTrail.updates,
                points = tTrail.state.points,
                alpha = tTrail.state.alpha
            }
        end
    end

    -- The models the effect's animation carries, resolved for this step
    local tResult = tInstance.provider.result

    if tResult and not tInstance.killed and (tInstance.loop or tInstance.ticks < tInstance.duration) then
        for i, tRootDraw in ipairs(tInstance.modelDraws) do
            tStep.models[i] = fnCopyDraw(tInstance.runtime.models.Resolve(tRootDraw, tResult, tInstance.root, tInstance.ticks))
        end
    end

    tStep.hasResult = tResult ~= nil

    -- Its point lights (animation entries of type 6)
    for _, tItem in ipairs(tResult or {}) do

        if tItem.type == 6 then

            local tFields = {}

            for _, iOffset in ipairs({0x50, 0x54, 0x58, 0x60, 0x70, 0x74, 0x78, 0x88, 0x8c}) do
                tFields[iOffset] = tItem.fields[iOffset]
            end

            tStep.lights[#tStep.lights + 1] = {type = 6, fields = tFields}

        end

    end

    tRecording.steps[#tRecording.steps + 1] = tStep

end

ENGINE.RecordStep = fnRecordStep

-- An effect that ended as the game ends it keeps its recording
function ENGINE:FinishRecording(tInstance)

    local tRecording = tInstance.recording

    -- A script that kills its object once the animation is over cut nothing short
    if tRecording and not tInstance.failed and not tInstance.removed and (not tInstance.killed or tInstance.endedBeforeKill) then
        self.tRecordings[tRecording.key] = tRecording.steps
    end

    tInstance.recording = nil

end

-- Recordings made in the background (Config prerecord): effects simulated off screen, not
-- drawn, a few steps a frame within Config prerecordBudgetMs, so that even the first time an
-- effect plays it is read back
ENGINE.tWarmups = {}

-- Queue every one-shot effect with emitters of a package
function ENGINE:QueuePrerecord(sPackage)

    local tRuntime = self:LoadPackage(sPackage)

    for sEffect, tAnimation in pairs(tRuntime.data.animations) do

        local tEmitters = tRuntime.data.effects[sEffect]
        local sKey = self:RecordingKey(sPackage, sEffect, 1)

        if tAnimation.loop == 0 and tEmitters and #tEmitters > 0 and not self.tRecordings[sKey] then
            self.tWarmups[#self.tWarmups + 1] = {runtime = tRuntime, effect = sEffect, key = sKey}
        end

    end

end

-- Step the background recordings for at most flBudget milliseconds
function ENGINE:StepPrerecords(flBudget)

    local tWarmup = self.tWarmups[1]

    if not tWarmup then return end

    local flStop = SysTime() + flBudget / 1000

    while tWarmup and SysTime() < flStop do

        local tInstance = tWarmup.instance

        if not tInstance then

            -- Launched at the default scale; a launch adds the effect to the running ones: it
            -- is taken out of them at once (stepped here, never drawn)
            local tOuter = {pos = Vector(0, 0, 0), yaw = 0, scale = CONFIG["scale"]}

            tInstance = self:Launch(tWarmup.runtime, tWarmup.effect, {outer = tOuter, seed = 1})

            for i = #self.tInstances, 1, -1 do
                if self.tInstances[i] == tInstance then
                    table.remove(self.tInstances, i)
                end
            end

            if tInstance then
                self:StartRecording(tInstance, tWarmup.key)
            end

            tWarmup.instance = tInstance

        end

        local bDone = not tInstance or not tInstance.recording

        if not bDone then

            local bOk = pcall(function()
                tInstance.scene:Update()
                self:SettleTrailSets(tInstance)
                self.RecordStep(tInstance)
            end)

            tInstance.frame = tInstance.frame + 1

            local bDrained = tInstance.scene.emissionStopped and tInstance.scene:IsDrained()

            for _, tSet in ipairs(tInstance.trailSets) do
                if not self:IsTrailSetEmpty(tSet) then
                    bDrained = false
                end
            end

            if not bOk then
                tInstance.recording = nil
            elseif bDrained or tInstance.frame >= tInstance.maxFrames then
                self:FinishRecording(tInstance)
            end

            bDone = not tInstance.recording

        end

        if bDone then
            table.remove(self.tWarmups, 1)
            tWarmup = self.tWarmups[1]
        end

    end

end

-- Play a recording: an instance with no scene to simulate, whose steps set what the drawing
-- reads (scene.particles, the resolved models, the trails, the lights)
function ENGINE:LaunchReplay(tRuntime, sEffect, tOptions, tSteps)

    local tData = tRuntime.data
    local tAnimation = tData.animations[sEffect]

    local tInstance = {
        effect = sEffect,
        runtime = tRuntime,
        outer = tOptions.outer,
        root = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1},
        start = tOptions.start or CurTime(),
        beforeUpdate = tOptions.beforeUpdate,
        ticks = 0,
        frame = 0,
        modelDraws = tRuntime.models.CompiledFor(sEffect).draws,
        loop = false,
        duration = tAnimation.duration_ticks,
        ignoredEntries = {},
        external = {},
        trailSets = {},
        resolved = {},
        scene = {particles = {}, births = {}},
        provider = {result = nil},
        replay = tSteps,
        maxFrames = #tSteps
    }

    self.tInstances[#self.tInstances + 1] = tInstance
    self.bListDirty = true

    return tInstance

end

-- One step of a replay
function ENGINE:ReplayStep(tInstance)

    if tInstance.beforeUpdate then
        tInstance.beforeUpdate(tInstance)
    end

    local tStep = tInstance.replay[tInstance.frame + 1]

    if not tStep then return end

    tInstance.ticks = tStep.ticks
    tInstance.scene.particles = tStep.particles
    tInstance.provider.result = tStep.hasResult and tStep.lights or nil

    -- The tables below are the instance's, refilled at every step (a replay makes no garbage)
    for i, tRootDraw in ipairs(tInstance.modelDraws) do

        if tStep.models[i] then

            local tKept = tInstance.resolved[tRootDraw]

            if tKept then
                tKept.ticks, tKept.draw = tStep.ticks, tStep.models[i]
            else
                tInstance.resolved[tRootDraw] = {ticks = tStep.ticks, draw = tStep.models[i]}
            end

        end

    end

    -- The trails, each with a state of its own (the ribbon vertices are made from it)
    local tTrails = tInstance.replayTrails

    if not tTrails then
        tTrails = {}
        tInstance.replayTrails = tTrails
        tInstance.trailSets = {{trails = tTrails}}
    end

    for i, tRecorded in ipairs(tStep.trails) do

        local tTrail = tTrails[i]

        if not tTrail then
            tTrail = {state = {}}
            tTrails[i] = tTrail
        end

        tTrail.state.points, tTrail.state.alpha = tRecorded.points, tRecorded.alpha

        -- recorded: the key of its ribbon, built once for every play (engine/cl_draw.lua)
        tTrail.def, tTrail.board, tTrail.updates, tTrail.recorded = tRecorded.def, tRecorded.board, tRecorded.updates, tRecorded

    end

    for i = #tStep.trails + 1, #tTrails do
        tTrails[i] = nil
    end

end
