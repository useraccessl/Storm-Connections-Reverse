-- Birth and step of one particle, from the data of the effect files. Where it is born, the
-- order of the force fields and its parent's displacement are the caller's.

StormFX.Core.ParticleRuntime = StormFX.Core.ParticleRuntime or {}

local PARTICLE_RUNTIME = StormFX.Core.ParticleRuntime

-- The size randomness of a step: none (it was applied once, at birth)
local NO_RANDOM = {0, 0, 0}

-- A particle runtime over the motion, spawn and curves modules
function PARTICLE_RUNTIME.New(MOTION, SPAWN, CURVES)

    local tRuntime = {}

    -- A new particle of an emitter, or nil and a reason. fnResolveSpawn(emitter, random) gives
    -- its birth place (it must make the game's random draws, not reuse recorded positions);
    -- fnResourceAvailable(resource) can refuse a resource after every draw was made.
    function tRuntime.Create(tEmitter, tRandom, fnResolveSpawn, fnResourceAvailable)

        local sResource = SPAWN.Resource(tEmitter.resources, tRandom)
        local iLife = SPAWN.Lifetime(tEmitter.life, tEmitter.lifeRandom, tRandom)

        if iLife == 0 then
            return nil, "original zero lifetime"
        end

        local flScalar = SPAWN.Scalar(tEmitter.scalarBase, tEmitter.scalarRandom, tRandom)
        local tSpatial, sWhy = fnResolveSpawn(tEmitter, tRandom)

        if not tSpatial then
            return nil, sWhy
        end

        local tVelocity
        tVelocity, sWhy = SPAWN.Velocity(tEmitter, tSpatial.position, tSpatial.center, tSpatial.direction, tSpatial.scale, tRandom, tSpatial.coneTransform)

        if not tVelocity then
            return nil, sWhy
        end

        local tRotation = {0, 0, 0}

        local function fnRandomAngle()

            local flAngle = tRandom:Range(2 * math.pi)

            if flAngle > math.pi then
                flAngle = flAngle - 2 * math.pi
            end

            return flAngle

        end

        if tEmitter.rotation == 1 then

            for i = 1, 3 do
                tRotation[i] = fnRandomAngle()
            end

        elseif tEmitter.rotation == 3 then
            tRotation[2] = fnRandomAngle()
        end

        local tSizes = SPAWN.SizeCurves(tEmitter, tRandom)
        local tSampleConfig = {}

        for k, v in pairs(tEmitter) do
            tSampleConfig[k] = v
        end

        for k, v in pairs(tSizes) do
            tSampleConfig[k] = v
        end

        -- The random size was applied once, at birth, above
        tSampleConfig.sizeRandom = {0, 0, 0}

        -- A resource that cannot be drawn must not change the random stream
        if fnResourceAvailable and not fnResourceAvailable(sResource) then
            return nil, "resource player not implemented: " .. sResource
        end

        return {
            resource = sResource,
            life = iLife,
            ageTicks = 0,
            position = tSpatial.position,
            fade = CURVES.FadeInit(iLife, tEmitter.fadeIn, tEmitter.fadeOut),
            attachmentScale = tSpatial.scale,
            previousPosition = {tSpatial.position[1], tSpatial.position[2], tSpatial.position[3]},
            velocity = tVelocity,
            secondaryVelocity = {0, 0, 0},
            displacement = {0, 0, 0},

            -- Written in place by every step
            size = {0, 0, 0},
            color = {0, 0, 0, 0},
            lifecycleSize = {0, 0, 0},

            rotation = tRotation,
            scale = {1, 1, 1},
            speed = 1,
            scalar = flScalar,
            sampleConfig = tSampleConfig,
            alive = true,
            alignTravel = tEmitter.rotation == 2 or tEmitter.rotation == 3
        }

    end

    -- Step a particle by flSeconds through its force fields; returns whether it is still
    -- alive, or nil and a reason
    function tRuntime.Step(tParticle, flSeconds, tFields, tParentDisplacement)

        if not tParticle.alive then return false end

        local tPosition, tPrevious = tParticle.position, tParticle.previousPosition
        tPrevious[1], tPrevious[2], tPrevious[3] = tPosition[1], tPosition[2], tPosition[3]

        local flStep = flSeconds * tParticle.sampleConfig.simulationHz

        for _, tField in ipairs(tFields) do

            local bOk, sWhy = MOTION.Force(tParticle, tField, flStep)

            if not bOk then
                return nil, sWhy
            end

        end

        MOTION.Integrate(tParticle, flStep, tParentDisplacement)

        tParticle.ageTicks = tParticle.ageTicks + flStep
        tParticle.alive = tParticle.ageTicks < tParticle.life

        local flAge = tParticle.ageTicks / tParticle.sampleConfig.simulationHz
        local tSize = tParticle.size

        CURVES.Sample(tParticle.sampleConfig, tParticle.life, flAge, NO_RANDOM, tSize, tParticle.color)

        -- The alpha is the colour curve's alpha times the fade (game: 0x14130b436)
        tParticle.alpha = tParticle.color[4] * CURVES.FadeStep(tParticle.fade, tParticle.ageTicks, flStep)

        local tLifecycle = tParticle.lifecycleSize
        tLifecycle[1], tLifecycle[2], tLifecycle[3] = tSize[1], tSize[2], tSize[3]

        for i = 1, 3 do
            tSize[i] = tSize[i] * tParticle.scale[i]
        end

        return tParticle.alive

    end

    return tRuntime

end

return PARTICLE_RUNTIME
