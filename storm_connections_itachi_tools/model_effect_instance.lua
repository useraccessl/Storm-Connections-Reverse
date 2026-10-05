-- Original model-effect bridge, render 0x14130b5a2..0x14130b601.
-- Parent matrix and lifecycle size must come from the particle runtime.
-- This module has no captured geometry, position track or visual tuning inputs.
local B={}
function B.new(compiled,modules,options)
    assert(options and options.coordinateTranslationScales,'Original coordinate translation scales required')
    -- ticks: the sum of the deltas the animation was advanced by, which is the clock
    -- its clumps hand their billboard members (0x14128c890 gets the delta times the
    -- speed, truncated, from the animation player 0x1412af9b5).
    local effect={compiled=compiled,modules=modules,options=options,
        player=modules.animation.newPlayer(compiled,options.initialTicks or 0,1),
        materialInstances=options.materialInstances or {},ticks=0}
    function effect:update(particleParent,lifecycleSize,simulationHz,updateRate,hostTimeScale)
        local parent=self.modules.matrix.scaleColumns(particleParent,lifecycleSize,self.compiled.options.float32)
        local delta,speed=self.modules.clock.particleStep(simulationHz,updateRate,hostTimeScale,self.compiled.options.float32)
        self.player.clock.speed=speed
        self.ticks=self.ticks+math.floor(delta*speed)
        -- Model branch updates ANM first. Billboard branch has another order.
        local result,overflow,step=self.modules.animation.advance(self.player,delta,self.materialInstances)
        local contexts={}
        for i,entry in ipairs(self.compiled.entries) do if entry.type==1 then
            contexts[i]={parentMatrix=parent,translationScale=assert(self.options.coordinateTranslationScales[i],'Missing original target translation scale')}
        end end
        self.modules.animation.coordinateMatrices(self.compiled,result,contexts,parent)
        return result,overflow,step,parent
    end
    return effect
end
return B

