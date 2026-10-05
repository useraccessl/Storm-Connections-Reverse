-- The particles of one effect: its emitters, their attachments and force fields, births and
-- steps at a fixed rate. The host supplies the animation's coordinates, the force routing
-- and the end of the emission; the fixed rate keeps runs deterministic, it does not claim to
-- be the game's scheduler.

StormFX.Core.ParticleScene = StormFX.Core.ParticleScene or {}

local PARTICLE_SCENE = StormFX.Core.ParticleScene

-- A particle's parent displacement in a scene: none (read only)
local NO_DISPLACEMENT = {0, 0, 0}

-- The particle scene of the effect sName of a package. tOptions: fps, seed, coordinates (or
-- sampleAnimated), externalCoordinate(name), updateCoordinates(frame), stopEmission(frame),
-- context88Fields / context80Fields, resolveFrame(emitter, clock), routeFields(emitter,
-- particle), afterParticleStep(particle, fps). Returns nil and a reason when it cannot be made.
function PARTICLE_SCENE.New(tData, sName, tModules, tOptions)

    tOptions = tOptions or {}

    local tScene = {
        name = sName,
        frame = 0,
        particles = {},
        births = {},
        errors = {},
        stopNotifications = {},
        fps = tOptions.fps or 60,
        rng = tModules.spawn.Random(tOptions.seed or 1),
        emitters = {}
    }

    local tRuntime = tModules.runtime.New(tModules.motion, tModules.spawn, tModules.curves)
    local tRecords = assert(tData.spatialRecords[sName], "missing spatial records")
    local tCoordinates, sWhy

    if tOptions.coordinates then
        tCoordinates = tOptions.coordinates
    else
        tCoordinates, sWhy = tModules.spatial.Coordinates(tData.animations[sName], tOptions.sampleAnimated)
    end

    if not tCoordinates then
        return nil, sWhy
    end

    -- tOptions.externalCoordinate(name): the host's value for a coordinate outside the effect
    local fnExternal = tOptions.externalCoordinate

    for _, tEmitter in ipairs(assert(tData.effects[sName], "missing effect")) do

        local tAttachments = assert(tModules.spatial.Attachments(tRecords.attachments, tCoordinates, tEmitter.id, fnExternal))
        local tFields = assert(tModules.spatial.Fields(tRecords.forces, tCoordinates, tEmitter.id, fnExternal))

        tScene.emitters[#tScene.emitters + 1] = {
            config = tEmitter,
            state = tModules.emission.New(false),
            particles = {},
            attachments = tAttachments,
            segments = tModules.spatial.Segments(tAttachments),
            fields = tFields,
            routedFields = tModules.motion.RouteFields(assert(tEmitter.forceMask, "missing original force mask"),
                {tFields, tOptions.context88Fields or {}, tOptions.context80Fields or {}})
        }

    end

    -- Stop every emitter for good
    function tScene:StopEmission()

        if self.emissionStopped then return end

        self.emissionStopped = true

        for _, tGenerator in ipairs(self.emitters) do
            tModules.emission.Stop(tGenerator.state)
        end

    end

    -- Whether every particle is gone
    function tScene:IsDrained()
        return #self.particles == 0
    end

    -- One update: coordinates, emission, births, then the steps of the living particles
    function tScene:Update()

        local flClock = self.frame * 1000 / self.fps

        if tOptions.updateCoordinates then

            local tCurrent = assert(tOptions.updateCoordinates(self.frame), "Missing ANM coordinates")

            for _, tGenerator in ipairs(self.emitters) do

                tGenerator.attachments = assert(tModules.spatial.Attachments(tRecords.attachments, tCurrent, tGenerator.config.id, fnExternal))
                tGenerator.segments = tModules.spatial.Segments(tGenerator.attachments)
                tGenerator.fields = assert(tModules.spatial.Fields(tRecords.forces, tCurrent, tGenerator.config.id, fnExternal))
                tGenerator.routedFields = tModules.motion.RouteFields(tGenerator.config.forceMask,
                    {tGenerator.fields, tOptions.context88Fields or {}, tOptions.context80Fields or {}})

            end

        end

        if tOptions.stopEmission and tOptions.stopEmission(self.frame) then
            self:StopEmission()
        end

        for _, tGenerator in ipairs(self.emitters) do

            local tEmitter = tGenerator.config

            if tOptions.resolveFrame then

                tOptions.resolveFrame(tGenerator, flClock)
                tGenerator.routedFields = tModules.motion.RouteFields(tEmitter.forceMask,
                    {tGenerator.fields, tOptions.context88Fields or {}, tOptions.context80Fields or {}})

            end

            local iCount, _, bNotify = tModules.emission.Update(tGenerator.state, tEmitter, flClock, self.fps, 1, #tGenerator.attachments)

            if bNotify then
                self.stopNotifications[#self.stopNotifications + 1] = {emitter = tEmitter.id, clock = flClock}
            end

            for _ = 1, math.max(0, iCount) do

                local tParticle, sReason = tRuntime.Create(tEmitter, self.rng, function(tConfig, tRandom)

                    if tConfig.shape >= 3 and #tGenerator.attachments > 1 then
                        return tModules.birthSpatial.Segment(tConfig, tRandom, tGenerator.segments)
                    end

                    return tModules.birthSpatial.Single(tConfig, tRandom, tGenerator.attachments)

                end)

                if tParticle then

                    tParticle.emitter = tEmitter.id
                    tParticle.generator = tGenerator
                    tGenerator.particles[#tGenerator.particles + 1] = tParticle
                    self.particles[#self.particles + 1] = tParticle

                    -- An emitter without a resource still makes particles
                    local sKey = tParticle.resource or "(no resource)"
                    self.births[sKey] = (self.births[sKey] or 0) + 1

                else
                    self.errors[#self.errors + 1] = {emitter = tEmitter.id, clock = flClock, reason = sReason}
                end

            end

            -- The game's generator emits before it updates its particle list
            local tAlive = {}

            for _, tParticle in ipairs(tGenerator.particles) do

                if tParticle.alive then

                    -- The generator's own fields go to +90 (0x1412765c0); the +88 / +80 lists
                    -- come from the skill's scene
                    local tFields = tOptions.routeFields and tOptions.routeFields(tGenerator, tParticle) or tGenerator.routedFields
                    local bOk, sReason = tRuntime.Step(tParticle, 1 / self.fps, tFields, NO_DISPLACEMENT)

                    if bOk == nil then error(sReason) end

                    if tOptions.afterParticleStep then
                        tOptions.afterParticleStep(tParticle, self.fps)
                    end

                    if tParticle.alive then
                        tAlive[#tAlive + 1] = tParticle
                    end

                end

            end

            tGenerator.particles = tAlive

        end

        local tAlive = {}

        for _, tParticle in ipairs(self.particles) do
            if tParticle.alive then tAlive[#tAlive + 1] = tParticle end
        end

        self.particles = tAlive
        self.frame = self.frame + 1

    end

    return tScene

end

return PARTICLE_SCENE
