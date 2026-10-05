-- Material context of the game's renderer (game: binder 0x1412f5ff0, constructor
-- 0x1412f5920): float32 rounding, the screen scroll, the global clock and the screen size.
-- The game's global epoch and the number of calls per update are the caller's.

StormFX.Core.MaterialContext = StormFX.Core.MaterialContext or {}

local MATERIAL_CONTEXT = StormFX.Core.MaterialContext

MATERIAL_CONTEXT.epsilon = 1.1920928955078125e-7
MATERIAL_CONTEXT.clockMultiplier = 0.10000000149011612

-- Round to the nearest integer, ties to even
local function fnNearestEven(flValue)

    local flFloor = math.floor(flValue)
    local flFraction = flValue - flFloor

    if flFraction > 0.5 or (flFraction == 0.5 and flFloor % 2 == 1) then
        return flFloor + 1
    end

    return flFloor

end

-- A double rounded to the nearest float32 (ties to even, subnormals, overflow to infinity)
function MATERIAL_CONTEXT.Float32(flValue)

    if flValue == 0 or flValue ~= flValue or math.abs(flValue) == math.huge then
        return flValue
    end

    local iSign = flValue < 0 and -1 or 1
    local flMagnitude = math.abs(flValue)
    local iExponent

    if math.frexp then

        local _
        _, iExponent = math.frexp(flMagnitude)

    else

        iExponent = math.floor(math.log(flMagnitude) / math.log(2)) + 1

        if flMagnitude >= 2^iExponent then iExponent = iExponent + 1 end
        if flMagnitude < 2^(iExponent - 1) then iExponent = iExponent - 1 end

    end

    local flStep = 2^math.max(iExponent - 24, -149)
    local flRounded = fnNearestEven(flMagnitude / flStep) * flStep

    if flRounded >= 2^128 then
        flRounded = math.huge
    end

    return iSign * flRounded

end

-- The fractional part of a value, signed, in float32
function MATERIAL_CONTEXT.SignedFraction(flValue)

    local iInteger = flValue < 0 and math.ceil(flValue) or math.floor(flValue)

    return MATERIAL_CONTEXT.Float32(flValue - MATERIAL_CONTEXT.Float32(iInteger))

end

-- The screen scroll of a material at flClockSeconds. The rates are the scales of UV sets 2
-- and 3 (file flags 4 and 8; the game reads material +60, +64, +68, +6c).
function MATERIAL_CONTEXT.ScreenScroll(tMaterial, flClockSeconds)

    local tUV2, tUV3 = tMaterial.scroll0, tMaterial.scroll1
    local tRates = {tUV2[3], tUV2[4], tUV3[3], tUV3[4]}
    local tScroll = {}

    for i, flRate in ipairs(tRates) do
        tScroll[i] = math.abs(flRate) < MATERIAL_CONTEXT.epsilon and 0
            or MATERIAL_CONTEXT.SignedFraction(MATERIAL_CONTEXT.Float32(flClockSeconds * flRate))
    end

    return tScroll

end

-- The global counter, advanced unless paused (game: 0x14129d957)
function MATERIAL_CONTEXT.AdvanceCounter(iCounter, iDelta, bPaused)

    if bPaused then return iCounter end

    return (iCounter + iDelta) % 2147483648

end

-- The clock the materials read, from the global counter
function MATERIAL_CONTEXT.OriginalClock(iCounter, iDenominator)

    assert(iDenominator > 0, "The clock's denominator must be positive")

    return MATERIAL_CONTEXT.Float32(MATERIAL_CONTEXT.Float32(MATERIAL_CONTEXT.Float32(iCounter) * MATERIAL_CONTEXT.clockMultiplier)
        / MATERIAL_CONTEXT.Float32(iDenominator))

end

-- What the counter advances by for a number of calls (game: 0x1412a0500, unsigned divide by
-- 60, at most 600 calls)
function MATERIAL_CONTEXT.DeltaForCalls(iDenominator, iCalls)
    return math.floor(iDenominator / 60) * math.min(iCalls, 600)
end

-- The inverse screen size the shaders read (game: shader context +500, set at 0x1413380df)
function MATERIAL_CONTEXT.ScreenToUV(iWidth, iHeight)

    assert(iWidth > 0 and iHeight > 0, "The screen size must be positive")

    return {MATERIAL_CONTEXT.Float32(1 / iWidth), MATERIAL_CONTEXT.Float32(1 / iHeight), 0, 0}

end

return MATERIAL_CONTEXT
