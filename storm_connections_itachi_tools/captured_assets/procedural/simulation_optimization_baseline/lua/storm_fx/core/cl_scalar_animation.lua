-- Scalar and vector curves of the game's animations, one reader per curve format (game: key
-- factory 0x141367040). The caller owns the animation's time.
--   11 fixed float              12 keyed float, linear (0x141353c80)
--   22 float table, linear or held (the factory picks the reader from a flag)
--   24 float table, always held (the reader of a held 22)
--   15 opacity table of unsigned shorts, linear, * 1/32768 (0x141394da0)
--   29 the same table, held (0x141394e20)
--    5 fixed vector              6 keyed vector, linear (0x141391c10)
--   16 scale table of signed shorts, linear, * 1/4096 (0x141394ee0)
--   21 vector table, linear (0x141395130)   26 vector table, held (0x141395220)

StormFX.Core.ScalarAnimation = StormFX.Core.ScalarAnimation or {}

local SCALAR_ANIMATION = StormFX.Core.ScalarAnimation

-- The game's readers take a uint32 clock
local function fnCheckTicks(iTicks)
    assert(iTicks >= 0 and iTicks == math.floor(iTicks) and iTicks < 4294967296, "The clock must be a uint32")
end

-- The two keys around iTicks in a keyed curve. The search starts from the last key used
-- (kept in tState, or on the curve); the files end the keys with tick -1.
local function fnKeysAround(tValues, iTicks, tState)

    local iIndex = tState.index or 1

    assert(iTicks >= tValues[1][1] % 4294967296 and iTicks < tValues[#tValues][1] % 4294967296, "The clock is outside the keys")

    while tValues[iIndex + 1][1] % 4294967296 <= iTicks do
        iIndex = iIndex + 1
    end

    while tValues[iIndex][1] % 4294967296 > iTicks do
        iIndex = iIndex - 1
    end

    tState.index = iIndex

    return tValues[iIndex], tValues[iIndex + 1]

end

-- A scalar curve at iTicks (one key every iStep ticks for the tables; bHold: no interpolation)
function SCALAR_ANIMATION.Sample(tCurve, iTicks, iStep, bHold, fnFloat32, tState)

    fnCheckTicks(iTicks)

    local tValues = tCurve.values

    if tCurve.format == 11 then
        return tValues[1][1]
    end

    local f = assert(fnFloat32, "The float32 rounding is required")

    if tCurve.format == 12 then

        local tA, tB = fnKeysAround(tValues, iTicks, tState or tCurve)
        local flT = f(f(iTicks - tA[1] % 4294967296) / f(tB[1] % 4294967296 - tA[1] % 4294967296))

        -- The timestamp reader adds the left product first
        return f(f(f(1 - flT) * tA[2]) + f(flT * tB[2]))

    end

    assert(iStep > 0 and iStep == math.floor(iStep), "The step must be a positive integer")

    local iIndex = math.floor(iTicks / iStep) + 1
    local iRemainder = iTicks % iStep

    if tCurve.format == 15 or tCurve.format == 29 then

        -- Unsigned shorts: (1 - t) * a + t * b, then * 1/32768. Format 29 does not interpolate.
        local flA = assert(tValues[iIndex], "The clock is outside the curve")[1] % 65536

        if iRemainder ~= 0 and tCurve.format == 15 then

            local flT = f(f(iRemainder) / f(iStep))
            local flB = assert(tValues[iIndex + 1], "The clock is outside the curve")[1] % 65536

            flA = f(f(f(1 - flT) * flA) + f(flB * flT))

        end

        return f(flA * 3.0517578125e-05)

    end

    assert(tCurve.format == 22 or tCurve.format == 24, "Unsupported scalar curve format")
    assert(tValues[iIndex], "The clock is outside the curve")

    local flA = tValues[iIndex][1]

    if bHold or tCurve.format == 24 or iRemainder == 0 then
        return flA
    end

    local flB = assert(tValues[iIndex + 1], "The clock is outside the curve")[1]
    local flT = f(f(iRemainder) / f(iStep))

    -- The game's order: (t * b) + ((1 - t) * a), not a + t * (b - a)
    return f(f(flT * flB) + f(f(1 - flT) * flA))

end

-- A vector curve (position, scale) at iTicks: {x, y, z}
function SCALAR_ANIMATION.Vector(tCurve, iTicks, iStep, fnFloat32, tState)

    fnCheckTicks(iTicks)

    local tValues, f = tCurve.values, assert(fnFloat32)

    if tCurve.format == 5 then

        assert(#tValues == 1, "Format 5 is a constant vector")

        return {tValues[1][1], tValues[1][2], tValues[1][3]}

    end

    if tCurve.format == 6 then

        local tA, tB = fnKeysAround(tValues, iTicks, tState or tCurve)
        local flT = f(f(iTicks - tA[1] % 4294967296) / f(tB[1] % 4294967296 - tA[1] % 4294967296))
        local flW = f(1 - flT)

        -- (1 - t) * a + t * b per component (game: 0x1411ac910)
        return {f(f(flW * tA[2]) + f(flT * tB[2])), f(f(flW * tA[3]) + f(flT * tB[3])), f(f(flW * tA[4]) + f(flT * tB[4]))}

    end

    assert(iStep > 0 and iStep == math.floor(iStep), "The step must be a positive integer")

    local iIndex = math.floor(iTicks / iStep) + 1
    local iRemainder = iTicks % iStep
    local tA = assert(tValues[iIndex], "The clock is outside the curve")

    if tCurve.format == 26 then
        return {tA[1], tA[2], tA[3]}
    end

    if tCurve.format == 16 then

        local flScale = 0.000244140625

        if iRemainder == 0 then
            return {f(tA[1] * flScale), f(tA[2] * flScale), f(tA[3] * flScale)}
        end

        local tB = assert(tValues[iIndex + 1], "The clock is outside the curve")
        local flT = f(f(iRemainder) / f(iStep))
        local flWeightA, flWeightB = f(f(1 - flT) * flScale), f(flT * flScale)

        return {f(f(tB[1] * flWeightB) + f(tA[1] * flWeightA)), f(f(tB[2] * flWeightB) + f(tA[2] * flWeightA)), f(f(tB[3] * flWeightB) + f(tA[3] * flWeightA))}

    end

    assert(tCurve.format == 21, "Unsupported vector curve format")

    if iRemainder == 0 then
        return {tA[1], tA[2], tA[3]}
    end

    local tB = assert(tValues[iIndex + 1], "The clock is outside the curve")
    local flT = f(f(iRemainder) / f(iStep))
    local flW = f(1 - flT)

    return {f(f(flW * tA[1]) + f(flT * tB[1])), f(f(flW * tA[2]) + f(flT * tB[2])), f(f(flW * tA[3]) + f(flT * tB[3]))}

end

return SCALAR_ANIMATION
