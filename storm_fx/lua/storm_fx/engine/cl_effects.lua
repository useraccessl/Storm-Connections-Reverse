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

    -- An emitter or a force attached to a node the effect does not animate (a bone of the
    -- caster, another object): the host puts it at the effect root
    local function fnExternalCoordinate(sName)

        tInstance.external[sName] = true

        local tRoot = tInstance.root

        return {
            position = {tRoot[4], tRoot[8], tRoot[12]},
            rotation = {tRoot[1], tRoot[2], tRoot[3], tRoot[5], tRoot[6], tRoot[7], tRoot[9], tRoot[10], tRoot[11]}
        }

    end

    -- The coordinates of a particle's own animation, as a scene takes them: where its emitters
    -- attach (the matrices are already under the particle's)
    local function fnParticleCoordinates(tParticle)

        local tCoordinates = tParticle.nestedCoordinates or {}

        tParticle.nestedCoordinates = tCoordinates

        for _, tItem in ipairs(tParticle.modelResult) do

            if tItem.type == 1 then

                local tMatrix = tItem.worldMatrix
                local tCoordinate = tCoordinates[tItem.target] or {position = {}, rotation = {}}
                local tPosition, tRotation = tCoordinate.position, tCoordinate.rotation

                tPosition[1], tPosition[2], tPosition[3] = tMatrix[4], tMatrix[8], tMatrix[12]

                for iRow = 0, 2 do
                    for iCol = 1, 3 do tRotation[iRow * 3 + iCol] = tMatrix[iRow * 4 + iCol] end
                end

                tCoordinates[tItem.target] = tCoordinate

            end

        end

        return tCoordinates

    end

    -- A resource whose one model hangs on spring bones (nuccChunkDynamics, journal R127): the
    -- chain's pivot, rest direction and length in the model's space. The game simulates every
    -- bone; the host plays a fall baked in the studio model (fnUpright). false: none, nil: not yet known.
    local function fnSwayOf(tResource)

        if tResource.sway ~= nil then return tResource.sway end

        local tResourceAnimation = tData.animations[tResource.animation]
        local tFound

        for _, tClump in ipairs(tResourceAnimation and tResourceAnimation.clumps or {}) do

            if #(tClump.drawn or {}) > 0 then

                if tFound or not tClump.dynamics or #tClump.dynamics ~= 1 or #tClump.drawn ~= 1 then
                    tResource.sway = false
                    return false
                end

                tFound = tClump

            end

        end

        local tModel = tFound and tData.models[tFound.drawn[1]]

        if not tModel or not tModel.skeleton then
            tResource.sway = false
            return false
        end

        -- The rest matrices are made when the model is first resolved
        local tRest = tModel.skeleton.restWorld

        if not tRest then return nil end

        local tChain = tFound.dynamics[1]
        local tFirst, tLast = tRest[tChain.first + 1], tRest[tChain.first + tChain.count]
        local dx, dy, dz = tLast[4] - tFirst[4], tLast[8] - tFirst[8], tLast[12] - tFirst[12]
        local flLength = math.sqrt(dx * dx + dy * dy + dz * dz)

        if not (flLength > 0) then
            tResource.sway = false
            return false
        end

        tResource.sway = {
            pivot = {tFirst[4], tFirst[8], tFirst[12]},
            direction = {dx / flLength, dy / flLength, dz / flLength},
            length = flLength,
            bounce = tChain.coefficients[1],
            gain = tChain.coefficients[2]
        }

        return tResource.sway

    end

    -- A hanging model whose fall is baked in its studio model's sequence (export_studio_anm.py
    -- --hang): the sequence falls toward the model's own -z, so the model is stood upright,
    -- keeping only the heading of its chain. The turn is found once per particle; every update
    -- then writes the same rotation over the particle's (no bone is touched from Lua).
    local function fnUpright(tParticle, tSway)

        local tMatrix = tParticle.studioPose and tParticle.studioPose.matrix

        if not tMatrix then return end

        local tTurn = tParticle.upright

        if tTurn == nil then

            local tDirection = tSway.direction
            local rx = tMatrix[1] * tDirection[1] + tMatrix[2] * tDirection[2] + tMatrix[3] * tDirection[3]
            local ry = tMatrix[5] * tDirection[1] + tMatrix[6] * tDirection[2] + tMatrix[7] * tDirection[3]
            local rz = tMatrix[9] * tDirection[1] + tMatrix[10] * tDirection[2] + tMatrix[11] * tDirection[3]
            local flScale = math.sqrt(rx * rx + ry * ry + rz * rz)
            local flLevel = math.sqrt(rx * rx + ry * ry)
            local flRest = math.sqrt(tDirection[1] * tDirection[1] + tDirection[2] * tDirection[2])

            -- A chain that points straight up or down has no heading: left as it is
            if flLevel < 1e-4 * flScale or flRest < 1e-4 or math.abs(tDirection[3]) > 1e-3 then
                tParticle.upright = false
                return
            end

            -- About z, from the chain's rest heading in the model to its heading in the effect
            local flCos = (tDirection[1] * rx + tDirection[2] * ry) / (flRest * flLevel)
            local flSin = (tDirection[1] * ry - tDirection[2] * rx) / (flRest * flLevel)

            tTurn = {flCos * flScale, -flSin * flScale, flSin * flScale, flCos * flScale, flScale}
            tParticle.upright = tTurn

        end

        if not tTurn then return end

        -- The pivot stays where the particle's own matrix puts it
        local tPivot = tSway.pivot
        local px = tMatrix[1] * tPivot[1] + tMatrix[2] * tPivot[2] + tMatrix[3] * tPivot[3] + tMatrix[4]
        local py = tMatrix[5] * tPivot[1] + tMatrix[6] * tPivot[2] + tMatrix[7] * tPivot[3] + tMatrix[8]
        local pz = tMatrix[9] * tPivot[1] + tMatrix[10] * tPivot[2] + tMatrix[11] * tPivot[3] + tMatrix[12]

        tMatrix[1], tMatrix[2], tMatrix[3] = tTurn[1], tTurn[2], 0
        tMatrix[5], tMatrix[6], tMatrix[7] = tTurn[3], tTurn[4], 0
        tMatrix[9], tMatrix[10], tMatrix[11] = 0, 0, tTurn[5]
        tMatrix[4] = px - (tTurn[1] * tPivot[1] + tTurn[2] * tPivot[2])
        tMatrix[8] = py - (tTurn[3] * tPivot[1] + tTurn[4] * tPivot[2])
        tMatrix[12] = pz - tTurn[5] * tPivot[3]

    end

    -- The particle scenes of the animated resources that carry emitters of their own (one per
    -- particle of such a resource): stepped with the effect, their particles listed with its own
    tInstance.nestedScenes = {}

    local fnAfterParticleStep

    local function fnNestedScene(tParticle, tResource)

        local tNestedEmitters = tResource.nested and tData.effects[tResource.animation]

        if not tNestedEmitters or #tNestedEmitters == 0 then return false end

        local tNestedAnimation = tData.animations[tResource.animation]

        local bLoaded, tNested = pcall(CORE.ParticleScene.New, tData, tResource.animation, self.tParticleModules, {
            seed = (tOptions.seed or 1) + #tInstance.nestedScenes + 1,
            fps = self.FPS,
            coordinates = fnParticleCoordinates(tParticle),
            updateCoordinates = function() return fnParticleCoordinates(tParticle) end,
            externalCoordinate = fnExternalCoordinate,

            -- As an effect's: no emission once the particle is gone or its animation is over
            stopEmission = function()
                return tInstance.killed or not tParticle.alive
                    or (tNestedAnimation.loop == 0 and tParticle.modelInstance.player.clock.ticks >= tNestedAnimation.duration_ticks)
            end,

            afterParticleStep = function(tChild, iRate) fnAfterParticleStep(tChild, iRate) end
        })

        if not bLoaded or not tNested then
            self.tSkipped[tResource.animation .. " (emitters of the resource)"] = true
            return false
        end

        tInstance.nestedScenes[#tInstance.nestedScenes + 1] = {scene = tNested, particle = tParticle, listed = 0}

        return tNested

    end

    if tEmitters and #tEmitters > 0 then

        local bLoaded, tScene, sWhy = pcall(CORE.ParticleScene.New, tData, sEffect, self.tParticleModules, {
            seed = tOptions.seed or 1,
            fps = self.FPS,
            coordinates = tProvider:Evaluate(0, tInstance.root),
            updateCoordinates = fnAdvance,
            externalCoordinate = fnExternalCoordinate,

            -- A one-shot effect stops emitting when its animation ends; a looping one emits
            -- until its actor is killed
            stopEmission = function()
                return tInstance.killed or (tAnimation.loop == 0 and tClock.ticks >= tAnimation.duration_ticks)
            end,

            afterParticleStep = function(tParticle, iRate) fnAfterParticleStep(tParticle, iRate) end
        })

        fnAfterParticleStep = function(tParticle, iRate)

                -- Clump and animated resources carry a model matrix, billboards do not
                local tResource = tParticle.resource and tData.resources[tParticle.resource] or {}
                local sKind = tResource.kind

                if sKind == "clump" or sKind == "anm" then

                    local bTimed = SECTIONS:Active()
                    local flFrom = bTimed and SysTime()

                    tRuntime.models:Update(tParticle, iRate)

                    -- A hanging model whose fall is in its studio model's sequence stands upright
                    local tSway = sKind == "anm" and tResource.studio and tResource.studio.hung and fnSwayOf(tResource)

                    if tSway then
                        fnUpright(tParticle, tSway)
                    end

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

                    -- The emitters the resource carries itself, made when the particle first
                    -- has its animation
                    if tParticle.nestedScene == nil then
                        tParticle.nestedScene = fnNestedScene(tParticle, tResource)
                    end

                end

        end

        if not bLoaded then
            return nil, "effect " .. sEffect .. " not playable: " .. tostring(tScene)
        end

        if not tScene then
            return nil, sWhy
        end

        -- After the effect's own particles, the scenes of its resources: their emitters, then
        -- their particles, which join the effect's list (drawn and recorded with the others;
        -- the scene that owns them steps them, the effect's list only drops them once dead)
        local fnUpdateScene = tScene.Update

        function tScene:Update()

            fnUpdateScene(self)

            local tNestedScenes = tInstance.nestedScenes
            local iKept = 0

            for i = 1, #tNestedScenes do

                local tNested = tNestedScenes[i]
                local tChild = tNested.scene

                tChild:Update()

                -- A particle born in this update: listed once (a scene only appends, and
                -- compacts in order)
                for _, tParticle in ipairs(tChild.particles) do

                    if not tParticle.listed then
                        tParticle.listed = true
                        self.particles[#self.particles + 1] = tParticle
                    end

                end

                if not (tChild.emissionStopped and tChild:IsDrained()) then
                    iKept = iKept + 1
                    tNestedScenes[iKept] = tNested
                end

            end

            for i = iKept + 1, #tNestedScenes do tNestedScenes[i] = nil end

            -- Those that died in this update leave the list now, not at the next one
            local tParticles = self.particles
            local iCount, iAlive = #tParticles, 0

            for i = 1, iCount do

                local tParticle = tParticles[i]

                if tParticle.alive then
                    iAlive = iAlive + 1
                    tParticles[iAlive] = tParticle
                end

            end

            for i = iAlive + 1, iCount do tParticles[i] = nil end

        end

        -- Drained when the scenes of its resources are too
        local fnIsDrained = tScene.IsDrained

        function tScene:IsDrained()
            return fnIsDrained(self) and #tInstance.nestedScenes == 0
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

    -- A host edit of the package: the effect starts some updates into its animation
    local tEdit = tRuntime.data.edits and tRuntime.data.edits[sEffect]
    local iSkip = tEdit and tEdit.skipFrames or 0
    local tInstance, sWhy

    if tSteps then

        tInstance = self:LaunchReplay(tRuntime, sEffect, {outer = tOuter}, tSteps)

    else

        tInstance, sWhy = self:Launch(tRuntime, sEffect, {outer = tOuter, seed = iSeed, root = tRoot})

        if not tInstance then
            return nil, sWhy
        end

        if bFlat then
            self:StartRecording(tInstance, sKey)
        end

    end

    if iSkip > 0 then
        self:SkipFrames(tInstance, iSkip)
    end

    return tInstance

end
