-- The animation of a model carried by a particle (game: render 0x14130b5a2..0x14130b601).
-- The parent matrix and the particle's size come from the particle runtime.

StormFX.Core.ModelInstance = StormFX.Core.ModelInstance or {}

local MODEL_INSTANCE = StormFX.Core.ModelInstance

-- A model animation for a particle. ticks is the sum of the deltas the animation was
-- advanced by: the clock its clumps hand their billboard members (0x14128c890 gets the
-- delta times the speed, truncated, from the animation player 0x1412af9b5).
function MODEL_INSTANCE.New(tCompiled, tModules, tOptions)

    assert(tOptions and tOptions.coordinateTranslationScales, "The coordinates' translation scales are required")

    local tEffect = {
        compiled = tCompiled,
        modules = tModules,
        options = tOptions,
        player = tModules.animation.NewPlayer(tCompiled, tOptions.initialTicks or 0, 1),
        materialInstances = tOptions.materialInstances or {},
        ticks = 0
    }

    -- One update of the animation under the particle; returns the evaluated entries, the
    -- clock overflow, the step and the parent matrix
    function tEffect:Update(tParticleParent, flLifecycleSize, flSimulationHz, iUpdateRate, flHostTimeScale)

        -- The parent matrix and the contexts are refilled from update to update (whoever keeps
        -- them keeps them until the next update only, as the animation's result)
        local fnFloat32 = self.compiled.options.float32

        self.parentStore = self.parentStore or {}

        local tParent = self.modules.matrix.ScaleColumns(tParticleParent, flLifecycleSize, fnFloat32, self.parentStore)
        local iDelta, flSpeed = self.modules.clock.ParticleStep(flSimulationHz, iUpdateRate, flHostTimeScale, fnFloat32)

        self.player.clock.speed = flSpeed
        self.ticks = self.ticks + math.floor(iDelta * flSpeed)

        -- A model updates its animation first (a billboard does it in another order)
        local tResult, iOverflow, iStep = self.modules.animation.Advance(self.player, iDelta, self.materialInstances)
        local tContexts = self.contexts

        if not tContexts then

            tContexts = {}

            for i, tEntry in ipairs(self.compiled.entries) do

                if tEntry.type == 1 then
                    tContexts[i] = {
                        translationScale = assert(self.options.coordinateTranslationScales[i], "A coordinate has no translation scale")
                    }
                end

            end

            self.contexts = tContexts

        end

        for _, tContext in pairs(tContexts) do
            tContext.parentMatrix = tParent
        end

        self.modules.animation.CoordinateMatrices(self.compiled, tResult, tContexts, tParent)

        return tResult, iOverflow, iStep, tParent

    end

    -- The same update without evaluating the animation: the clock and the parent matrix only
    -- (a host that plays the animation itself, as a baked sequence, reads the clock)
    function tEffect:UpdateClock(tParticleParent, flLifecycleSize, flSimulationHz, iUpdateRate, flHostTimeScale)

        local fnFloat32 = self.compiled.options.float32

        self.parentStore = self.parentStore or {}

        local tParent = self.modules.matrix.ScaleColumns(tParticleParent, flLifecycleSize, fnFloat32, self.parentStore)
        local iDelta, flSpeed = self.modules.clock.ParticleStep(flSimulationHz, iUpdateRate, flHostTimeScale, fnFloat32)

        self.player.clock.speed = flSpeed
        self.ticks = self.ticks + math.floor(iDelta * flSpeed)
        self.modules.clock.Advance(self.player.clock, iDelta, fnFloat32)

        return tParent

    end

    return tEffect

end

return MODEL_INSTANCE
