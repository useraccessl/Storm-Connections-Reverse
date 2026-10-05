-- Launch maths of the game's skill objects: parameters converted from the 30 Hz rate, the
-- CONST_AXIS_UP shot, the orientation of a moving object and the root of its effect.
-- Collisions and aim corrections are the host's.

StormFX.Core.SkillShot = StormFX.Core.SkillShot or {}

local SKILL_SHOT = StormFX.Core.SkillShot

local FL_EPSILON = 1.1920928955078125e-7

-- A parameter given at the 30 Hz reference rate, at iUpdateRate (game: 0x140a67e28..0x140a67ea6;
-- the reference rate getter 0x1405911a0 returns 30)
function SKILL_SHOT.RateAdjustedParameter(flValue, iUpdateRate, fnFloat32)

    assert(iUpdateRate > 0, "The update rate is required")

    return fnFloat32(fnFloat32(30 / fnFloat32(iUpdateRate)) * fnFloat32(flValue))

end

-- The CONST_AXIS_UP shot (game: dispatcher slot 7, 0x140a6a5f0): the direction projected on
-- the horizontal plane and normalised, up = (0, 0, 1). The optional correction 0x140a6a340 is
-- the caller's.
function SKILL_SHOT.ConstAxisUp(tDirection, tParticleMath, fnFloat32)

    local flDot = fnFloat32(fnFloat32(fnFloat32(tDirection[1] * 0) + fnFloat32(tDirection[2] * 0)) + fnFloat32(tDirection[3] * 1))
    local tProjected = {fnFloat32(tDirection[1] - fnFloat32(0 * flDot)), fnFloat32(tDirection[2] - fnFloat32(0 * flDot)), fnFloat32(tDirection[3] - fnFloat32(1 * flDot))}
    local flSquare = fnFloat32(fnFloat32(fnFloat32(tProjected[1] * tProjected[1]) + fnFloat32(tProjected[2] * tProjected[2])) + fnFloat32(tProjected[3] * tProjected[3]))

    if flSquare <= 0 then
        return {1, 0, 0}, {0, 0, 1}
    end

    return tParticleMath.Normalize(tProjected, fnFloat32), {0, 0, 1}

end

-- Length of a vector
local function fnLength(tV, fnFloat32)
    return fnFloat32(math.sqrt(fnFloat32(fnFloat32(fnFloat32(tV[1] * tV[1]) + fnFloat32(tV[2] * tV[2])) + fnFloat32(tV[3] * tV[3]))))
end

-- A vector normalised
local function fnUnit(tV, fnFloat32)

    local flReciprocal = fnFloat32(1 / fnLength(tV, fnFloat32))

    return {fnFloat32(tV[1] * flReciprocal), fnFloat32(tV[2] * flReciprocal), fnFloat32(tV[3] * flReciprocal)}

end

-- tA x tB
local function fnCross(tA, tB, fnFloat32)
    return {fnFloat32(fnFloat32(tA[2] * tB[3]) - fnFloat32(tA[3] * tB[2])), fnFloat32(fnFloat32(tB[1] * tA[3]) - fnFloat32(tA[1] * tB[3])), fnFloat32(fnFloat32(tA[1] * tB[2]) - fnFloat32(tB[1] * tA[2]))}
end

-- Orientation of a moving object (game: updater 0x140a61c20 on the 4x4 at actor +AC):
--   Y = normalize(-velocity)
--   X = normalize(Y x oldZ), Z = normalize(X x Y)
--   when Y x oldZ (or X x Y) degenerates: Z = normalize(oldX x Y), X = normalize(Y x Z)
-- Every length test is > FLT_EPSILON; a failed one leaves the orientation as it was (a still
-- object keeps the identity).
function SKILL_SHOT.Orientation(tPrevious, tVelocity, tMatrixModule, fnFloat32)

    local tOldX = {tPrevious[1], tPrevious[5], tPrevious[9]}
    local tOldZ = {tPrevious[3], tPrevious[7], tPrevious[11]}
    local tY = {fnFloat32(-tVelocity[1]), fnFloat32(-tVelocity[2]), fnFloat32(-tVelocity[3])}

    if not (fnLength(tY, fnFloat32) > FL_EPSILON) then return tPrevious end

    tY = fnUnit(tY, fnFloat32)

    local tX, tZ
    local tCandidate = fnCross(tY, tOldZ, fnFloat32)

    if fnLength(tCandidate, fnFloat32) > FL_EPSILON then

        tX = fnUnit(tCandidate, fnFloat32)
        tCandidate = fnCross(tX, tY, fnFloat32)

        if fnLength(tCandidate, fnFloat32) > FL_EPSILON then
            tZ = fnUnit(tCandidate, fnFloat32)
        end

    end

    if not tZ then

        tCandidate = fnCross(tX or tOldX, tY, fnFloat32)
        if not (fnLength(tCandidate, fnFloat32) > FL_EPSILON) then return tPrevious end

        tZ = fnUnit(tCandidate, fnFloat32)

        tCandidate = fnCross(tY, tZ, fnFloat32)
        if not (fnLength(tCandidate, fnFloat32) > FL_EPSILON) then return tPrevious end

        tX = fnUnit(tCandidate, fnFloat32)

    end

    local tOut = tMatrixModule.Identity()

    for iRow = 0, 2 do
        tOut[iRow * 4 + 1] = tX[iRow + 1]
        tOut[iRow * 4 + 2] = tY[iRow + 1]
        tOut[iRow * 4 + 3] = tZ[iRow + 1]
    end

    return tOut

end

-- The root matrix of a skill object's effect (game: ccGameObjectSkill virtual +78,
-- 0x1405e00c0..0x1405e0229): position * orientation * roll about Y * scale
function SKILL_SHOT.EffectRoot(tPosition, tActorOrientation, flExtraAngleDegrees, flActorScale, tMatrixModule, fnFloat32, fnSin, fnCos)

    assert(tPosition and tActorOrientation and flExtraAngleDegrees and flActorScale, "The skill object's fields are required")

    local tRoot = tMatrixModule.Identity()

    for i = 1, 3 do
        tRoot[i * 4] = tPosition[i]
    end

    tRoot = tMatrixModule.Multiply(tRoot, tActorOrientation, fnFloat32)

    local flAngle = fnFloat32(fnFloat32(flExtraAngleDegrees * 3.1415927410125732) / 180)

    -- 0x1412818a0 -> 0x1411ed680 (UCRT cosf / sinf)
    local flCos, flSin = fnFloat32(fnCos(flAngle)), fnFloat32(fnSin(flAngle))
    local tRotation = {flCos, 0, flSin, 0, 0, 1, 0, 0, fnFloat32(-flSin), 0, flCos, 0, 0, 0, 0, 1}

    tRoot = tMatrixModule.Multiply(tRoot, tRotation, fnFloat32)

    return tMatrixModule.ScaleColumns(tRoot, {flActorScale, flActorScale, flActorScale}, fnFloat32)

end

return SKILL_SHOT
