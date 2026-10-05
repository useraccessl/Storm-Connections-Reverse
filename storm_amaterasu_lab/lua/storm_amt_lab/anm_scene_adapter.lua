-- Convert the recovered ANM hierarchy into generator attachment coordinates.
-- Host root, translation scales and local ticks are explicit caller inputs.
local S={}
function S.new(animation,modules,context)
    assert(context and context.translationScales and context.rootMatrix,'Original coordinate context required')
    local compiled=context.compiled or modules.animation.compile(animation,modules,context.options)
    local out={compiled=compiled,ticks=nil,coordinates=nil,lights={}}
    function out:evaluate(ticks,rootMatrix)
        local result=modules.animation.evaluate(compiled,ticks,context.materialInstances or {})
        local contexts={}
        for i,e in ipairs(compiled.entries) do if e.type==1 then
            contexts[i]={parentMatrix=rootMatrix or context.rootMatrix,
                translationScale=assert(context.translationScales[i],'Missing target translation scale')}
        end end
        modules.animation.coordinateMatrices(compiled,result,contexts,rootMatrix or context.rootMatrix)
        local coords,lights={},{}
        for _,item in ipairs(result) do
            if item.type==1 then
                local m=item.worldMatrix
                coords[item.target]={position={m[4],m[8],m[12]},
                    rotation={m[1],m[2],m[3],m[5],m[6],m[7],m[9],m[10],m[11]}}
            elseif item.type==6 then lights[item.target]=item.fields end
        end
        -- result: every entry of the animation (coordinates with their world matrix
        -- and channels, material instances), for the models the effect draws itself.
        self.ticks=ticks;self.coordinates=coords;self.lights=lights;self.result=result
        return coords,lights
    end
    return out
end
return S
