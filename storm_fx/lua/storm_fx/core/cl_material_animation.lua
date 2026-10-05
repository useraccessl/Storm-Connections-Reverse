-- Animated material parameters (game: packed setter 0x1412f6380, direct animation
-- evaluator 0x14139d440). The curves, their clock and the channel sampling are the
-- caller's; the packed setter and the animation controller are separate paths in the game.

StormFX.Core.MaterialAnimation = StormFX.Core.MaterialAnimation or {}

local MATERIAL_ANIMATION = StormFX.Core.MaterialAnimation

-- Offset in the material instance of each channel, by channel index (0-based + 1)
MATERIAL_ANIMATION.offsets = {
    0x30, 0x34, 0x38, 0x3c, 0x40, 0x44, 0x48, 0x4c,
    0x50, 0x54, 0x58, 0x5c, 0x70, 0x74, 0x78, 0x7c, 0x80, 0x84,
    0x68, 0x6c, 0x60, 0x64, 0x88
}

-- What each channel is
MATERIAL_ANIMATION.names = {
    "uv0.x", "uv0.y", "uv1.x", "uv1.y", "uv2.x", "uv2.y", "uv3.x", "uv3.y",
    "uv0.scaleX", "uv0.scaleY", "uv1.scaleX", "uv1.scaleY", "blendRate.x", "blendRate.y",
    "uv2.overrideX", "commonParam.w", "alphaThreshold", "olid",
    "uv3.scaleX", "uv3.scaleY", "uv2.scaleX", "uv2.scaleY", "opaqueWord88"
}

-- Write a packed payload {mask, values...} into a material instance; returns the number
-- of values read
function MATERIAL_ANIMATION.ApplyPacked(tInstance, tPayload)

    local iMask = assert(tPayload[1], "The packed payload has no mask")
    local iCursor = 2

    for iIndex, iOffset in ipairs(MATERIAL_ANIMATION.offsets) do

        if math.floor(iMask / 2^(iIndex - 1)) % 2 == 1 then

            tInstance[iOffset] = assert(tPayload[iCursor], "The packed payload is too short")
            iCursor = iCursor + 1

        end

    end

    return iCursor - 1

end

-- Pack channels (by index 0..22) into a payload {mask, values...}
function MATERIAL_ANIMATION.PackChannels(tChannels)

    local iMask = 0
    local tPayload = {0}

    for iIndex = 0, 22 do

        if tChannels[iIndex] ~= nil then

            iMask = iMask + 2^iIndex
            tPayload[#tPayload + 1] = tChannels[iIndex]

        end

    end

    tPayload[1] = iMask

    return tPayload

end

-- The direct evaluator: fnSample(iIndex) gives a channel's value, or nil when the
-- animation has none. Translated from the instructions, not run against the game's code.
function MATERIAL_ANIMATION.EvaluateDirect(tInstance, fnSample, fnFloat32)

    -- An absent first value leaves a temporary undefined in the game: refuse it rather
    -- than make up a default
    local flCarry = fnSample(0)
    assert(flCarry ~= nil, "The direct evaluator needs the first channel")

    tInstance[0x30] = flCarry

    for iIndex = 1, 11 do

        local flValue = fnSample(iIndex)
        if flValue ~= nil then flCarry = flValue end

        tInstance[MATERIAL_ANIMATION.offsets[iIndex + 1]] = flCarry

    end

    for iIndex = 18, 21 do

        local flValue = fnSample(iIndex)
        if flValue ~= nil then flCarry = flValue end

        tInstance[MATERIAL_ANIMATION.offsets[iIndex + 1]] = flCarry

    end

    for iIndex = 12, 15 do
        tInstance[MATERIAL_ANIMATION.offsets[iIndex + 1]] = fnSample(iIndex) or 0
    end

    local flThreshold = fnSample(16)

    if flThreshold ~= nil then
        tInstance[0x80] = assert(fnFloat32)(flThreshold / 255)
    end

    tInstance[0x88] = fnSample(22) or 0

    -- Channel 17 (instance +84) is not written by this evaluator

end

return MATERIAL_ANIMATION
