-- Packed material-parameter application at NSUNSC 0x1412f6380.
-- Curve interpolation/clock and channel sampling are caller inputs.
-- Packed setter and ANM controller are separate native paths.
local M={}
M.offsets={0x30,0x34,0x38,0x3c,0x40,0x44,0x48,0x4c,
    0x50,0x54,0x58,0x5c,0x70,0x74,0x78,0x7c,0x80,0x84,
    0x68,0x6c,0x60,0x64,0x88}
M.names={'uv0.x','uv0.y','uv1.x','uv1.y','uv2.x','uv2.y','uv3.x','uv3.y',
    'uv0.scaleX','uv0.scaleY','uv1.scaleX','uv1.scaleY','blendRate.x','blendRate.y',
    'uv2.overrideX','commonParam.w','alphaThreshold','olid',
    'uv3.scaleX','uv3.scaleY','uv2.scaleX','uv2.scaleY','opaqueWord88'}
function M.applyPacked(instance,payload)
    local mask=assert(payload[1],'missing original packed mask')
    local cursor=2
    for index,offset in ipairs(M.offsets) do
        if math.floor(mask/2^(index-1))%2==1 then
            instance[offset]=assert(payload[cursor],'short original packed payload')
            cursor=cursor+1
        end
    end
    return cursor-1
end
function M.packChannels(channels)
    local mask=0 local payload={0}
    for index=0,22 do
        if channels[index]~=nil then
            mask=mask+2^index payload[#payload+1]=channels[index]
        end
    end
    payload[1]=mask return payload
end
-- Direct ANM evaluator 0x14139d440; sample(index) returns nil if absent.
-- This is a static instruction translation, not native-oracle validated yet.
function M.evaluateDirect(instance,sample,float32)
    local carry=sample(0)
    -- The original first absent scalar leaves a stack temporary undefined.
    -- Refuse that case rather than invent a default for another effect.
    assert(carry~=nil,'native direct evaluator requires first scalar for deterministic reproduction')
    instance[0x30]=carry
    for index=1,11 do
        local value=sample(index)
        if value~=nil then carry=value end
        instance[M.offsets[index+1]]=carry
    end
    for index=18,21 do
        local value=sample(index)
        if value~=nil then carry=value end
        instance[M.offsets[index+1]]=carry
    end
    for index=12,15 do instance[M.offsets[index+1]]=sample(index) or 0 end
    local threshold=sample(16)
    if threshold~=nil then instance[0x80]=assert(float32)(threshold/255) end
    instance[0x88]=sample(22) or 0
    -- Index 17 / instance +84 is not written by this original evaluator.
end
return M
