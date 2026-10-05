-- Effects: one running effect animation of a package, with its emitters (a particle scene),
-- the models it carries and its trails.

local ENGINE = StormFX.Engine
local CORE = StormFX.Core
local SECTIONS = StormFX.Sections

local fnFloat32 = ENGINE.Float32

-- Start an effect. tOptions: {outer = {pos, yaw, scale} (game units to the Source world), root
-- (the game's effect root matrix inside that space), start (CurTime of frame 0), seed,
-- beforeUpdate (called before every update)}. Returns the instance, or nil and why.
function ENGINE:Launch(tRuntime, sEffect, tOptions)

    local tData = tRuntime.data
    local tAnimation = tData.animations[sEffect]

    if not tAnimation then
        return nil, "effect animation not in the package: " .. tostring(sEffect)
    end

    -- The animation's entries: the coordinates the emitters attach to, the models it carries
    -- itself (modelDraws) and the material instances it drives. An entry or curve kind with no
    -- recovered reader makes the effect unplayable.
    local bOk, tCompiled = pcall(tRuntime.models.CompiledFor, sEffect)

    if not bOk then
        return nil, "animation " .. sEffect .. " not playable: " .. tostring(tCompiled)
    end

    local tInstance = {
        effect = sEffect,
        runtime = tRuntime,
        outer = tOptions.outer,
        root = tOptions.root or CORE.AnmMatrix.Identity(),
        start = tOptions.start or CurTime(),
        beforeUpdate = tOptions.beforeUpdate,
        ticks = 0,
        frame = 0,
        modelDraws = tCompiled.draws,
        loop = tAnimation.loop ~= 0,
        ignoredEntries = tCompiled.compiled.ignored
    }

    local tProvider = CORE.AnmScene.New(tAnimation, self.tAnmModules, {
        compiled = tCompiled.compiled,
        translationScales = tCompiled.scales,
        rootMatrix = CORE.AnmMatrix.Identity(),
        options = self.tAnmOptions,
        materialInstances = tRuntime.models.Instances(tCompiled)
    })

    tInstance.provider = tProvider

    local tClock = CORE.AnmClock.New(tAnimation.duration_ticks, tAnimation.loop, 0, 1)
    tInstance.duration = tAnimation.duration_ticks
    tInstance.trailSets = {}

    local tEffectTrails = self:NewTrailSet(tData, sEffect)

    if tEffectTrails then
        tInstance.trailSets[1] = tEffectTrails
    end

    -- One update of the animation: ccGameObjectSkill virtual +78, the actor moves, the root is
    -- rebuilt and handed to the effect, then the animation advances by the host delta (50)
    local function fnAdvance()

        if tInstance.beforeUpdate then
            tInstance.beforeUpdate(tInstance)
        end

        local bTimed = SECTIONS:Active()
        local flFrom = bTimed and SysTime()

        CORE.AnmClock.Advance(tClock, 50, fnFloat32)
        tInstance.ticks = tInstance.ticks + 50

        local tCoordinates = tProvider:Evaluate(tClock.ticks, tInstance.root)

        if bTimed then
            SECTIONS:Add("step_part_effect_anim", SysTime() - flFrom)
        end

        if tEffectTrails then

            -- A one-shot effect's object goes when its animation is over
            if tInstance.killed or (not tInstance.loop and tInstance.ticks >= tInstance.duration) then
                tEffectTrails.released = true
            end

            self:UpdateTrailSet(tEffectTrails, tProvider.result, tClock.ticks)

        end

        return tCoordinates

    end

    local tEmitters = tData.effects[sEffect]
    tInstance.external = {}

    if tEmitters and #tEmitters > 0 then

        local bLoaded, tScene, sWhy = pcall(CORE.ParticleScene.New, tData, sEffect, self.tParticleModules, {
            seed = tOptions.seed or 1,
            fps = self.FPS,
            coordinates = tProvider:Evaluate(0, tInstance.root),
            updateCoordinates = fnAdvance,

            -- An emitter or a force attached to a node the effect does not animate (a bone of
            -- the caster, another object): the host puts it at the effect root
            externalCoordinate = function(sName)

                tInstance.external[sName] = true

                local tRoot = tInstance.root

                return {
                    position = {tRoot[4], tRoot[8], tRoot[12]},
                    rotation = {tRoot[1], tRoot[2], tRoot[3], tRoot[5], tRoot[6], tRoot[7], tRoot[9], tRoot[10], tRoot[11]}
                }

            end,

            -- A one-shot effect stops emitting when its animation ends; a looping one emits
            -- until its actor is killed
            stopEmission = function()
                return tInstance.killed or (tAnimation.loop == 0 and tClock.ticks >= tAnimation.duration_ticks)
            end,

            afterParticleStep = function(tParticle, iRate)

                -- Clump and animated resources carry a model matrix, billboards do not
                local tResource = tParticle.resource and tData.resources[tParticle.resource] or {}
                local sKind = tResource.kind

                if sKind == "clump" or sKind == "anm" then

                    local bTimed = SECTIONS:Active()
                    local flFrom = bTimed and SysTime()

                    tRuntime.models:Update(tParticle, iRate)

                    if bTimed then
                        SECTIONS:Add("step_part_models", SysTime() - flFrom)
                    end

                end

                -- The trails of an animated resource follow the particle's animation
                if sKind == "anm" and tParticle.modelResult then

                    if tParticle.trailSet == nil then

                        tParticle.trailSet = self:NewTrailSet(tData, tResource.animation) or false

                        if tParticle.trailSet then
                            tParticle.trailSet.particle = true
                            tInstance.trailSets[#tInstance.trailSets + 1] = tParticle.trailSet
                        end

                    end

                    if tParticle.trailSet then
                        tParticle.trailSet.touched = true
                        self:UpdateTrailSet(tParticle.trailSet, tParticle.modelResult, tParticle.modelInstance.player.clock.ticks)
                    end

                end

            end
        })

        if not bLoaded then
            return nil, "effect " .. sEffect .. " not playable: " .. tostring(tScene)
        end

        if not tScene then
            return nil, sWhy
        end

        tInstance.scene = tScene

    else

        tInstance.advance = fnAdvance

    end

    -- How long the effect may run: its animation, then its longest particle life, then the
    -- trails (a released trail shrinks by one sample per update: up to maxSamples updates)
    local iTailFrames = 0
    local iTrailSamples = 0

    local function fnCountSamples(sName)

        for _, tDefinition in ipairs(tData.trails and tData.trails[sName] or {}) do
            iTrailSamples = math.max(iTrailSamples, tDefinition.maxSamples)
        end

    end

    fnCountSamples(sEffect)

    for _, tEmitter in ipairs(tEmitters or {}) do

        iTailFrames = math.max(iTailFrames, math.ceil(tEmitter.life * (1 + tEmitter.lifeRandom) * self.FPS / (tEmitter.simulationHz or 30)))

        for _, sResource in ipairs(tEmitter.resources or {}) do

            local tResource = tData.resources[sResource]

            if tResource and tResource.kind == "anm" then
                fnCountSamples(tResource.animation)
            end

        end

    end

    -- Looping effects run until killed; the cap only stops an effect nobody owns
    tInstance.maxFrames = tAnimation.loop ~= 0 and StormFX.Config["maxLoopFrames"]
        or math.ceil(tAnimation.duration_ticks / 50) + iTailFrames + iTrailSamples + 2

    self.tInstances[#self.tInstances + 1] = tInstance
    self.bListDirty = true

    return tInstance

end

-- Whether a root is the identity (an effect played without pitch or roll)
local function fnIsIdentity(tRoot)

    if not tRoot then return true end

    for i = 1, 16 do
        if tRoot[i] ~= ENGINE.IDENTITY[i] then return false end
    end

    return true

end

-- Play one effect of a package at a fixed root (nil: the identity). A one-shot effect under
-- the identity root is read back from its recording when it has one, else recorded
-- (engine/cl_replay.lua).
function ENGINE:PlayEffect(sPackage, sEffect, tOuter, iSeed, tRoot)

    local tRuntime = self:LoadPackage(sPackage)

    self:Begin(tOuter.scale)

    local bFlat = fnIsIdentity(tRoot)
    local sKey = self:RecordingKey(sPackage, sEffect, iSeed)
    local tSteps = bFlat and StormFX.Config["recordEffects"] ~= false and self.tRecordings[sKey]

    if tSteps then
        return self:LaunchReplay(tRuntime, sEffect, {outer = tOuter}, tSteps)
    end

    local tInstance, sWhy = self:Launch(tRuntime, sEffect, {outer = tOuter, seed = iSeed, root = tRoot})

    if not tInstance then
        return nil, sWhy
    end

    if bFlat then
        self:StartRecording(tInstance, sKey)
    end

    return tInstance

end
