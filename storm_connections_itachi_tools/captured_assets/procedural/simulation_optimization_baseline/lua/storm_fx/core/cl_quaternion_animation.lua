-- Rotation curves of the game's animations: quaternion interpolation (game: 0x1411f4e90),
-- compressed and timestamped keys, and the 3x3 basis of a quaternion. The quaternions are
-- in the game's convention (Convert); fnFloat32, fnAcos and fnSin are the caller's.

StormFX.Core.QuaternionAnimation = StormFX.Core.QuaternionAnimation or {}

local QUATERNION = StormFX.Core.QuaternionAnimation

local FL_MIN_LENGTH = 9.999999747378752e-05

-- Spherical interpolation from tA to tB at flT (linear when they are close), normalised
function QUATERNION.Interpolate(tA, tB, flT, fnFloat32, fnAcos, fnSin)

    local tProducts = {}

    for i = 1, 4 do
        tProducts[i] = fnFloat32(tA[i] * tB[i])
    end

    local flDot = fnFloat32(fnFloat32(tProducts[1] + tProducts[3]) + fnFloat32(tProducts[2] + tProducts[4]))
    local iSign = 1

    if flDot < 0 then
        flDot = -flDot
        iSign = -1
    end

    local flWeightA = fnFloat32(1 - flT)
    local flWeightB = flT

    if flDot <= 0.9700000286102295 then

        local flAngle = fnAcos(flDot)
        local flInverse = fnFloat32(1 / fnSin(flAngle))

        flWeightA = fnFloat32(fnSin(fnFloat32(flWeightA * flAngle)) * flInverse)
        flWeightB = fnFloat32(fnSin(fnFloat32(flAngle * flT)) * flInverse)

    end

    flWeightA = fnFloat32(flWeightA * iSign)

    local tOut = {}

    for i = 1, 4 do
        tOut[i] = fnFloat32(fnFloat32(flWeightA * tA[i]) + fnFloat32(flWeightB * tB[i]))
    end

    local tSquares = {}

    for i = 1, 4 do
        tSquares[i] = fnFloat32(tOut[i] * tOut[i])
    end

    local flLength = fnFloat32(math.sqrt(fnFloat32(fnFloat32(tSquares[1] + tSquares[3]) + fnFloat32(tSquares[2] + tSquares[4]))))

    if flLength >= FL_MIN_LENGTH then

        local flInverse = fnFloat32(1 / flLength)

        for i = 1, 4 do
            tOut[i] = fnFloat32(flInverse * tOut[i])
        end

    end

    return tOut

end

-- A quaternion normalised (left as is when too short)
function QUATERNION.Normalize(tA, fnFloat32)

    local tSquares = {}

    for i = 1, 4 do
        tSquares[i] = fnFloat32(tA[i] * tA[i])
    end

    local flLength = fnFloat32(math.sqrt(fnFloat32(fnFloat32(tSquares[1] + tSquares[3]) + fnFloat32(tSquares[2] + tSquares[4]))))
    local tOut = {tA[1], tA[2], tA[3], tA[4]}

    if flLength >= FL_MIN_LENGTH then

        local flInverse = fnFloat32(1 / flLength)

        for i = 1, 4 do
            tOut[i] = fnFloat32(flInverse * tA[i])
        end

    end

    return tOut

end

-- A file quaternion in the game's convention
function QUATERNION.Convert(tA)
    return {-tA[1], -tA[2], -tA[3], tA[4]}
end

-- Compressed keys (formats 17 and 27) as the game prepares them: decoded, normalised and
-- requantised to 1/16384
function QUATERNION.PrepareCompressed(tCurve, fnFloat32)

    assert(tCurve.format == 17 or tCurve.format == 27, "Unsupported compressed quaternion format")

    local tOut = {format = tCurve.format, values = {}}

    for iIndex, tRaw in ipairs(tCurve.values) do

        local tDecoded = {}

        for i = 1, 4 do
            tDecoded[i] = fnFloat32(tRaw[i] * 6.103515625e-05)
        end

        local tNormalized = QUATERNION.Normalize(tDecoded, fnFloat32)
        local tCompressed = {}

        for i = 1, 4 do
            local flValue = fnFloat32(tNormalized[i] * 16384)
            tCompressed[i] = flValue < 0 and math.ceil(flValue) or math.floor(flValue)
        end

        tOut.values[iIndex] = tCompressed

    end

    return tOut

end

-- A prepared compressed curve at iTicks, one key every iStep ticks (format 27 holds its keys)
function QUATERNION.SampleCompressed(tPrepared, iStep, iTicks, fnFloat32, fnAcos, fnSin)

    assert(iStep > 0 and iStep == math.floor(iStep), "The step must be a positive integer")
    assert(iTicks >= 0 and iTicks == math.floor(iTicks) and iTicks < 4294967296, "The clock must be a uint32")

    local iIndex = math.floor(iTicks / iStep) + 1

    local function fnDecode(tKey)

        assert(tKey, "The clock is outside the quaternion keys")

        local tOut = {}

        for i = 1, 4 do
            tOut[i] = fnFloat32(tKey[i] * 6.103515625e-05)
        end

        return QUATERNION.Convert(tOut)

    end

    local tA = fnDecode(tPrepared.values[iIndex])
    local iRemainder = iTicks % iStep

    if tPrepared.format == 27 or iRemainder == 0 then
        return tA
    end

    assert(tPrepared.format == 17, "Unsupported quaternion reader")

    return QUATERNION.Interpolate(tA, fnDecode(tPrepared.values[iIndex + 1]), fnFloat32(fnFloat32(iRemainder) / fnFloat32(iStep)), fnFloat32, fnAcos, fnSin)

end

-- The 3x3 basis of a quaternion as the game writes it (game: 0x1411bb590)
function QUATERNION.Basis(tA, fnFloat32)

    local flX, flY, flZ, flW = tA[1], tA[2], tA[3], tA[4]
    local flXX, flYY, flZZ = fnFloat32(flX * flX), fnFloat32(flY * flY), fnFloat32(flZ * flZ)
    local flXY, flXZ, flYZ = fnFloat32(flY * flX), fnFloat32(flZ * flX), fnFloat32(flZ * flY)
    local flWY, flWZ, flWX = fnFloat32(flW * flY), fnFloat32(flW * flZ), fnFloat32(flW * flX)

    local function fnTwice(flValue)
        return fnFloat32(flValue + flValue)
    end

    return {
        fnFloat32(1 - fnTwice(fnFloat32(flYY + flZZ))), fnTwice(fnFloat32(flXY - flWZ)), fnTwice(fnFloat32(flXZ + flWY)),
        fnTwice(fnFloat32(flWZ + flXY)), fnFloat32(1 - fnTwice(fnFloat32(flXX + flZZ))), fnTwice(fnFloat32(flYZ - flWX)),
        fnTwice(fnFloat32(flXZ - flWY)), fnTwice(fnFloat32(flWX + flYZ)), fnFloat32(1 - fnTwice(fnFloat32(flXX + flYY)))
    }

end

-- Timestamped keys (format 10) as the game reads them (game: 0x141391db0); -1 in the file
-- is the UINT32_MAX end key
function QUATERNION.PrepareTimestamp(tCurve, fnFloat32)

    assert(tCurve.format == 10 and #tCurve.values >= 2)

    local tOut = {format = 10, values = {}, cursor = 1}

    for iIndex, tRow in ipairs(tCurve.values) do

        local tKey = {tRow[1] % 4294967296}

        for i = 2, 5 do
            tKey[i] = fnFloat32(tRow[i])
        end

        if iIndex > 1 then
            assert(tKey[1] > tOut.values[iIndex - 1][1], "Timestamp keys must increase")
        end

        tOut.values[iIndex] = tKey

    end

    return tOut

end

-- A prepared timestamped curve at iTicks (the search starts from the last key used)
function QUATERNION.SampleTimestamp(tPrepared, iTicks, fnFloat32, fnAcos, fnSin)

    assert(iTicks >= 0 and iTicks == math.floor(iTicks) and iTicks < 4294967296)

    local tKeys = tPrepared.values
    assert(iTicks >= tKeys[1][1] and iTicks < tKeys[#tKeys][1], "The timestamp reader needs a key after the clock")

    local iIndex = tPrepared.cursor

    while tKeys[iIndex + 1][1] <= iTicks do
        iIndex = iIndex + 1
    end

    while tKeys[iIndex][1] > iTicks do
        iIndex = iIndex - 1
    end

    tPrepared.cursor = iIndex

    local tA, tB = tKeys[iIndex], tKeys[iIndex + 1]
    local flRatio = fnFloat32(fnFloat32(iTicks - tA[1]) / fnFloat32(tB[1] - tA[1]))
    local tLeft = QUATERNION.Convert({tA[2], tA[3], tA[4], tA[5]})
    local tRight = QUATERNION.Convert({tB[2], tB[3], tB[4], tB[5]})

    return QUATERNION.Interpolate(tLeft, tRight, flRatio, fnFloat32, fnAcos, fnSin)

end

return QUATERNION
