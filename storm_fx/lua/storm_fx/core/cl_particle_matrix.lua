-- World matrix of a particle (game: 0x141386d45..0x14138710f): direction of travel,
-- Euler angles, scales. Pure maths; which force or follow mode applies is the caller's.

StormFX.Core.ParticleMatrix = StormFX.Core.ParticleMatrix or {}

local PARTICLE_MATRIX = StormFX.Core.ParticleMatrix

local FL_TINY = 1.1754943508222875e-38
local PI = 3.1415927410125732
local TAU = 6.2831854820251465

-- An angle wrapped to [-pi, pi) through the game's 20-bit binary angle
function PARTICLE_MATRIX.WrapAngle(flAngle, fnFloat32)

    local flScaled = fnFloat32(fnFloat32(fnFloat32(flAngle + PI) * 1048576) / TAU)
    assert(flScaled >= -2147483648 and flScaled < 2147483648, "The angle overflows (cvttss2si)")

    local iInteger = flScaled >= 0 and math.floor(flScaled) or math.ceil(flScaled)

    return fnFloat32(fnFloat32(fnFloat32(iInteger % 1048576 * TAU) * 9.5367431640625e-7) - PI)

end

-- A vector normalised (game: 0x1411acbb0); a vector too short gives {1, 0, 0}. Returns the
-- unit vector and the length.
function PARTICLE_MATRIX.Normalize(tVector, fnFloat32)

    local flLength = fnFloat32(math.sqrt(fnFloat32(fnFloat32(fnFloat32(tVector[1] * tVector[1]) + fnFloat32(tVector[2] * tVector[2])) + fnFloat32(tVector[3] * tVector[3]))))

    if flLength <= FL_TINY then
        return {1, 0, 0}, 0
    end

    local flReciprocal = fnFloat32(1 / flLength)

    return {fnFloat32(tVector[1] * flReciprocal), fnFloat32(tVector[2] * flReciprocal), fnFloat32(tVector[3] * flReciprocal)}, flLength

end

-- tA x tB
function PARTICLE_MATRIX.Cross(tA, tB, fnFloat32)

    return {
        fnFloat32(fnFloat32(tA[2] * tB[3]) - fnFloat32(tA[3] * tB[2])),
        fnFloat32(fnFloat32(tB[1] * tA[3]) - fnFloat32(tA[1] * tB[3])),
        fnFloat32(fnFloat32(tA[1] * tB[2]) - fnFloat32(tB[1] * tA[2]))
    }

end

-- The direction of travel after a move; a move too short keeps the previous direction
function PARTICLE_MATRIX.AdvanceDirection(tPreviousPosition, tPosition, tPreviousDirection, fnFloat32, tOut)

    local x = fnFloat32(tPosition[1] - tPreviousPosition[1])
    local y = fnFloat32(tPosition[2] - tPreviousPosition[2])
    local z = fnFloat32(tPosition[3] - tPreviousPosition[3])
    local flLength = fnFloat32(math.sqrt(fnFloat32(fnFloat32(fnFloat32(x * x) + fnFloat32(y * y)) + fnFloat32(z * z))))
    tOut = tOut or {}

    if flLength > FL_TINY then
        local flReciprocal = fnFloat32(1 / flLength)
        tOut[1], tOut[2], tOut[3] = fnFloat32(x * flReciprocal), fnFloat32(y * flReciprocal), fnFloat32(z * flReciprocal)
    else
        tOut[1], tOut[2], tOut[3] = tPreviousDirection[1], tPreviousDirection[2], tPreviousDirection[3]
    end

    return tOut

end

-- 3x3 basis of a particle aligned with its travel (game: 0x141386e7a..0x141386f67). The
-- columns are a perpendicular, -travel, and their cross product. flZeroTolerance is the
-- caller's literal.
function PARTICLE_MATRIX.TravelBasis(tDirection, flZeroTolerance, fnFloat32)

    assert(flZeroTolerance and flZeroTolerance > 0, "The direction tolerance is required")

    if math.abs(tDirection[1]) < flZeroTolerance and math.abs(tDirection[2]) < flZeroTolerance and math.abs(tDirection[3]) < flZeroTolerance then
        return {1, 0, 0, 0, 1, 0, 0, 0, 1}
    end

    local tNegative = {fnFloat32(-tDirection[1]), fnFloat32(-tDirection[2]), fnFloat32(-tDirection[3])}
    local tPerpendicular

    if tNegative[1] == 0 and tNegative[2] == 0 then
        tPerpendicular = {fnFloat32(-tNegative[3]), 0, tNegative[1]}
    else
        tPerpendicular = {tNegative[2], fnFloat32(-tNegative[1]), 0}
    end

    tPerpendicular = PARTICLE_MATRIX.Normalize(tPerpendicular, fnFloat32)

    local tThird = PARTICLE_MATRIX.Cross(tPerpendicular, tNegative, fnFloat32)

    return {
        tPerpendicular[1], tNegative[1], tThird[1],
        tPerpendicular[2], tNegative[2], tThird[2],
        tPerpendicular[3], tNegative[3], tThird[3]
    }

end

-- 3x3 Euler basis of a particle's stored angles (+94 / +98 / +9C, in that order: the game
-- swaps the first and third before 0x1411b8760, at 0x1412c4330)
function PARTICLE_MATRIX.Euler(tAngles, fnFloat32, fnSin, fnCos)

    local flA, flB, flC = tAngles[1], tAngles[2], tAngles[3]
    local flCosA, flCosB, flCosC = fnFloat32(fnCos(flA)), fnFloat32(fnCos(flB)), fnFloat32(fnCos(flC))
    local flSinA, flSinB, flSinC = fnFloat32(fnSin(flA)), fnFloat32(fnSin(flB)), fnFloat32(fnSin(flC))
    local flSinACosC = fnFloat32(flSinA * flCosC)
    local flCosCCosA = fnFloat32(flCosC * flCosA)

    return {
        fnFloat32(flCosC * flCosB), fnFloat32(-fnFloat32(flSinC * flCosB)), flSinB,
        fnFloat32(fnFloat32(flSinACosC * flSinB) + fnFloat32(flSinC * flCosA)), fnFloat32(flCosCCosA - fnFloat32(fnFloat32(flSinB * flSinA) * flSinC)), fnFloat32(-fnFloat32(flSinA * flCosB)),
        fnFloat32(fnFloat32(flSinC * flSinA) - fnFloat32(flCosCCosA * flSinB)), fnFloat32(fnFloat32(fnFloat32(flSinB * flCosA) * flSinC) + flSinACosC), fnFloat32(flCosB * flCosA)
    }

end

-- A 4x4 times a 3x3, the translation kept as is (game: 0x1411e7e40; the sums are grouped
-- unlike the 4x4 * 4x4 product)
function PARTICLE_MATRIX.RightBasis(tMatrix, tBasis, fnFloat32, tOut)

    tOut = tOut or {}

    for iRow = 0, 3 do

        for iCol = 1, 3 do
            tOut[iRow * 4 + iCol] = fnFloat32(fnFloat32(fnFloat32(tMatrix[iRow * 4 + 1] * tBasis[iCol]) + fnFloat32(tMatrix[iRow * 4 + 2] * tBasis[3 + iCol])) + fnFloat32(tMatrix[iRow * 4 + 3] * tBasis[6 + iCol]))
        end

        tOut[iRow * 4 + 4] = tMatrix[iRow * 4 + 4]

    end

    return tOut

end

-- Rebuild the cached Euler basis when the angles changed (+178 dirties +154); the angles are
-- wrapped only here
function PARTICLE_MATRIX.PrepareRotation(tState, fnFloat32, fnSin, fnCos)

    assert(type(tState.rotationDirty) == "boolean", "The rotation dirty flag is required")

    if tState.rotationDirty then

        for i = 1, 3 do
            tState.angles[i] = PARTICLE_MATRIX.WrapAngle(tState.angles[i], fnFloat32)
        end

        tState.cachedEuler = PARTICLE_MATRIX.Euler(tState.angles, fnFloat32, fnSin, fnCos)
        tState.rotationDirty = false

    end

end

-- The particle's matrix (particle +A0): travel basis, position, rotation, scales. Its size
-- over its life (+1B0) is a further column scale, applied when it is drawn. Returns the
-- matrix and whether the scale is not degenerate.
function PARTICLE_MATRIX.Parent(tState, tMatrixModule, fnFloat32, fnSin, fnCos, tStore)

    local tOut = tMatrixModule.Identity(tStore and tStore.base)

    if tState.travelAligned then

        local tBasis = PARTICLE_MATRIX.TravelBasis(tState.direction, tState.directionTolerance, fnFloat32)

        for iRow = 0, 2 do
            for iCol = 1, 3 do
                tOut[iRow * 4 + iCol] = tBasis[iRow * 3 + iCol]
            end
        end

    end

    for i = 1, 3 do
        tOut[i * 4] = tState.position[i]
    end

    PARTICLE_MATRIX.PrepareRotation(tState, fnFloat32, fnSin, fnCos)

    if tState.angles[1] ~= 0 or tState.angles[2] ~= 0 or tState.angles[3] ~= 0 then
        tOut = PARTICLE_MATRIX.RightBasis(tOut, assert(tState.cachedEuler, "The cached Euler basis is required"), fnFloat32, tStore and tStore.rotated)
    end

    local tScale = tStore and tStore.scale or {}

    for i = 1, 3 do
        tScale[i] = fnFloat32(fnFloat32(tState.parentScale[i] * tState.baseScale[i]) * tState.uniformScale)
    end

    local bEnabled = tScale[1] > FL_TINY and tScale[2] > FL_TINY and tScale[3] > FL_TINY

    if bEnabled then
        tOut = tMatrixModule.ScaleColumns(tOut, tScale, fnFloat32, tStore and tStore.scaled)
    end

    return tOut, bEnabled

end

return PARTICLE_MATRIX
