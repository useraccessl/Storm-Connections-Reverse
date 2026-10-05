-- Motion of the game's skill objects (ccGameObjectSkill and its action classes,
-- ccSkillActor*), one tick at a time. tState is the object's motion state: position (+70),
-- velocity (+A0), orientation (+AC, 4x4), roll (+EC, degrees), multiplier (+164), frame
-- (+100, ticks since the action started), guidance (+3B0, 0 or 1). tActor holds what the
-- action class keeps for itself. The world (target, ground, obstacles) is the caller's.

StormFX.Core.SkillActor = StormFX.Core.SkillActor or {}

local SKILL_ACTOR = StormFX.Core.SkillActor

local PI = 3.1415927410125732

-- Random numbers ------------------------------------------------------------------------

-- 32-bit xor and and: the bit library in Garry's Mod, arithmetic elsewhere
local fnXor, fnAnd

if bit then

    fnXor = function(iA, iB) return bit.bxor(iA, iB) % 4294967296 end
    fnAnd = function(iA, iB) return bit.band(iA, iB) % 4294967296 end

else

    local function fnCombine(iA, iB, bBoth)

        local iOut, iPlace = 0, 1

        for _ = 1, 32 do

            local iX, iY = iA % 2, iB % 2

            if (bBoth and iX + iY == 2) or (not bBoth and iX ~= iY) then
                iOut = iOut + iPlace
            end

            iA, iB, iPlace = (iA - iX) / 2, (iB - iY) / 2, iPlace * 2

        end

        return iOut

    end

    fnXor = function(iA, iB) return fnCombine(iA, iB, false) end
    fnAnd = function(iA, iB) return fnCombine(iA, iB, true) end

end

local function fnShiftRight(iValue, iCount)
    return math.floor(iValue / 2^iCount)
end

local function fnShiftLeft(iValue, iCount)
    return (iValue * 2^iCount) % 4294967296
end

-- The game's random generator, MT19937 (game: 0x14132d200, state 0x14974c700, seeded by
-- 0x14132d580). The game seeds it from the clock and shares one stream with everything else:
-- the seed is the host's, the sequence of a seed is the game's. Returns a function giving
-- the generator's output shifted right once (0..2^31 - 1, game: 0x14127da70).
function SKILL_ACTOR.Twister(iSeed)

    local tState = {[0] = iSeed % 4294967296}

    for i = 1, 623 do

        local iPrevious = tState[i - 1]
        local iMixed = fnXor(iPrevious, fnShiftRight(iPrevious, 30))
        local iLow = iMixed % 65536
        local iHigh = (iMixed - iLow) / 65536

        tState[i] = ((iHigh * 1812433253) % 65536 * 65536 + iLow * 1812433253 + i) % 4294967296

    end

    local iIndex = 624

    return function()

        if iIndex >= 624 then

            for k = 0, 623 do

                local iY = (tState[k] - tState[k] % 2147483648) + tState[(k + 1) % 624] % 2147483648
                local iValue = fnXor(tState[(k + 397) % 624], fnShiftRight(iY, 1))

                if iY % 2 == 1 then
                    iValue = fnXor(iValue, 0x9908b0df)
                end

                tState[k] = iValue

            end

            iIndex = 0

        end

        local iY = tState[iIndex]
        iIndex = iIndex + 1

        iY = fnXor(iY, fnShiftRight(iY, 11))
        iY = fnXor(iY, fnShiftLeft(fnAnd(iY, 0xff3a58ad), 7))
        iY = fnXor(iY, fnShiftLeft(fnAnd(iY, 0xffffdf8c), 15))
        iY = fnXor(iY, fnShiftRight(iY, 18))

        return fnShiftRight(iY, 1)

    end

end

-- A value in [-flRange, flRange) (game: 0x1410abed0)
function SKILL_ACTOR.Spread(fnRandom, flRange, fnFloat32)

    local flUnit = fnFloat32(fnFloat32(fnRandom()) * 4.656612873077393e-10)

    return fnFloat32(fnFloat32(fnFloat32(flUnit + flUnit) * flRange) - flRange)

end

-- Vectors -------------------------------------------------------------------------------

-- Squared length (game: 0x1411ac880)
function SKILL_ACTOR.Squared(tV, fnFloat32)
    return fnFloat32(fnFloat32(fnFloat32(tV[1] * tV[1]) + fnFloat32(tV[2] * tV[2])) + fnFloat32(tV[3] * tV[3]))
end

-- Length (game: 0x1411ac850)
function SKILL_ACTOR.Length(tV, fnFloat32)
    return fnFloat32(math.sqrt(SKILL_ACTOR.Squared(tV, fnFloat32)))
end

-- Dot product (game: 0x1411ac380)
function SKILL_ACTOR.Dot(tA, tB, fnFloat32)
    return fnFloat32(fnFloat32(fnFloat32(tA[2] * tB[2]) + fnFloat32(tA[1] * tB[1])) + fnFloat32(tA[3] * tB[3]))
end

-- A vector normalised (game: 0x1411acbb0): one no longer than the literal at 0x141782190
-- becomes (1, 0, 0)
local FL_SHORT = 9.999999974752427e-7

function SKILL_ACTOR.Unit(tV, fnFloat32)

    local flSize = SKILL_ACTOR.Length(tV, fnFloat32)

    if not (flSize > FL_SHORT) then
        return {1, 0, 0}
    end

    local flReciprocal = fnFloat32(1 / flSize)

    return {fnFloat32(tV[1] * flReciprocal), fnFloat32(tV[2] * flReciprocal), fnFloat32(tV[3] * flReciprocal)}

end

-- tA x tB (game: 0x1411ac0f0)
function SKILL_ACTOR.Cross(tA, tB, fnFloat32)
    return {fnFloat32(fnFloat32(tA[2] * tB[3]) - fnFloat32(tA[3] * tB[2])), fnFloat32(fnFloat32(tB[1] * tA[3]) - fnFloat32(tA[1] * tB[3])), fnFloat32(fnFloat32(tA[1] * tB[2]) - fnFloat32(tB[1] * tA[2]))}
end

-- Column iIndex of a 4x4 (an axis)
function SKILL_ACTOR.Column(tMatrix, iIndex)
    return {tMatrix[iIndex], tMatrix[4 + iIndex], tMatrix[8 + iIndex]}
end

local fnSquared, fnLength, fnDot = SKILL_ACTOR.Squared, SKILL_ACTOR.Length, SKILL_ACTOR.Dot
local fnUnit, fnCross, fnColumn = SKILL_ACTOR.Unit, SKILL_ACTOR.Cross, SKILL_ACTOR.Column

local function fnRadians(flDegrees, fnFloat32)
    return fnFloat32(fnFloat32(flDegrees * fnFloat32(PI)) / 180)
end

-- An angle (double) as the game's 16-bit turn fraction, back in degrees (game:
-- 0x140a627a5..0x140a627f9, the game's rounding)
local function fnTurnDegrees(flAngle, fnFloat32)

    local iUnits

    if flAngle ~= flAngle then

        iUnits = -2147483648 -- cvttsd2si of a NaN

    else

        local flScaled = flAngle * 65536 / 6.2831854820251465 + (0 > flAngle and -0.5 or 0.5)
        iUnits = flScaled >= 0 and math.floor(flScaled) or math.ceil(flScaled)

    end

    return fnFloat32(fnFloat32(fnFloat32(iUnits) * 360) * 1.52587890625e-05)

end

-- Rotation about X (game: 0x1411ed500)
local function fnRotationX(flAngle, fnFloat32, fnSin, fnCos)

    local flCos, flSin = fnCos(flAngle), fnSin(flAngle)

    return {1, 0, 0, 0, 0, flCos, fnFloat32(-flSin), 0, 0, flSin, flCos, 0, 0, 0, 0, 1}

end

-- Rotation about a unit axis (game: 0x1411ed0c0)
function SKILL_ACTOR.AxisRotation(tAxis, flAngle, fnFloat32, fnSin, fnCos)

    local f = fnFloat32
    local flCos, flSin = fnCos(flAngle), fnSin(flAngle)
    local flT = f(1 - flCos)
    local flX, flY, flZ = tAxis[1], tAxis[2], tAxis[3]
    local flTX, flTY = f(flX * flT), f(flY * flT)
    local flTXY, flTXZ, flTYZ = f(flTX * flY), f(flTX * flZ), f(flTY * flZ)
    local flXS, flYS, flZS = f(flX * flSin), f(flY * flSin), f(flZ * flSin)

    return {
        f(f(flTX * flX) + flCos), f(flTXY - flZS), f(flYS + flTXZ), 0,
        f(flZS + flTXY), f(f(flTY * flY) + flCos), f(flTYZ - flXS), 0,
        f(flTXZ - flYS), f(flXS + flTYZ), f(f(f(flZ * flT) * flZ) + flCos), 0,
        0, 0, 0, 1
    }

end

-- A direction through a rotation matrix (game: 0x1411f00d0)
function SKILL_ACTOR.Rotate(tMatrix, tV, fnFloat32)

    local tOut = {}

    for iRow = 0, 2 do

        local flA, flB = fnFloat32(tMatrix[iRow * 4 + 1] * tV[1]), fnFloat32(tMatrix[iRow * 4 + 2] * tV[2])
        local flC, flD = fnFloat32(tMatrix[iRow * 4 + 3] * tV[3]), tMatrix[iRow * 4 + 4]

        tOut[iRow + 1] = fnFloat32(fnFloat32(flA + flC) + fnFloat32(flB + flD))

    end

    return tOut

end

-- Shots ---------------------------------------------------------------------------------
-- An event's <Effect> spawns a script through the shot handler of its shotType (table
-- 0x141974e80). A request carries position, direction and up axis; a handler returns its
-- launches, each {position, direction, up}.

-- The targetDir attribute: aim at the target from the position (game: 0x140a6a340)
function SKILL_ACTOR.Aim(tPosition, tTarget, tDirection, fnFloat32)

    if not tTarget then return tDirection end

    local tToward = {fnFloat32(tTarget[1] - tPosition[1]), fnFloat32(tTarget[2] - tPosition[2]), fnFloat32(tTarget[3] - tPosition[3])}

    if fnSquared(tToward, fnFloat32) > 0 then
        return fnUnit(tToward, fnFloat32)
    end

    return tToward

end

-- The planeDir attribute (game: 0x140a6a963): the direction laid in the plane whose normal is
-- the request's up axis (the spawner 0x1405e72f0 puts the hit normal there)
function SKILL_ACTOR.PlaneDirection(tDirection, tUp, fnFloat32)

    if not (fnSquared(tUp, fnFloat32) > 0) then
        return {0, 1, 0}, {0, 0, 1}
    end

    local tNormal = fnUnit(tUp, fnFloat32)

    return fnCross(fnCross(tNormal, tDirection, fnFloat32), tNormal, fnFloat32), tNormal

end

-- N_WAY_HORIZONTAL (game: 0x140a6bb10): iCount launches fanned about the up axis, flStep
-- degrees apart, centred on the direction; each launch's up is +Z
function SKILL_ACTOR.NWay(tPosition, tDirection, tUp, iCount, flStep, fnFloat32, fnSin, fnCos)

    local tLaunches = {}
    local flAngle = fnFloat32(fnFloat32((1 - iCount) * flStep) * 0.5)

    for iIndex = 1, iCount do

        local tTurn = SKILL_ACTOR.AxisRotation(tUp, fnRadians(flAngle, fnFloat32), fnFloat32, fnSin, fnCos)

        tLaunches[iIndex] = {
            position = {tPosition[1], tPosition[2], tPosition[3]},
            direction = SKILL_ACTOR.Rotate(tTurn, tDirection, fnFloat32),
            up = {0, 0, 1}
        }

        flAngle = fnFloat32(flAngle + fnFloat32(flStep))

    end

    return tLaunches

end

-- RANDOM_CREATION (game: 0x140a6bfa0): iCount launches, each moved from the position by a
-- whole number of units in [-iRange, iRange) along a random direction of the positive octant
-- (the game draws three non-negative components)
function SKILL_ACTOR.RandomCreation(tPosition, tDirection, tUp, iCount, iRange, fnRandom, fnFloat32)

    local tLaunches = {}

    for iIndex = 1, iCount do

        local flFirst, flSecond, flThird = fnFloat32(fnRandom()), fnFloat32(fnRandom()), fnFloat32(fnRandom())
        local tOffset = {flThird, flSecond, flFirst}
        local tAt = {tPosition[1], tPosition[2], tPosition[3]}

        if fnSquared(tOffset, fnFloat32) > 0 and iRange > 0 then

            tOffset = fnUnit(tOffset, fnFloat32)

            local flDistance = fnFloat32(fnRandom() % (iRange + iRange) - iRange)

            for i = 1, 3 do
                tAt[i] = fnFloat32(tAt[i] + fnFloat32(tOffset[i] * flDistance))
            end

        end

        tLaunches[iIndex] = {
            position = tAt,
            direction = {tDirection[1], tDirection[2], tDirection[3]},
            up = {tUp[1], tUp[2], tUp[3]}
        }

    end

    return tLaunches

end

-- The orientation a launched object starts with (init 0x1405eae00): the identity with the
-- request's up axis as Z, handed with the direction to the orientation update 0x140a61c20
function SKILL_ACTOR.LaunchBasis(tUp)
    return {1, 0, tUp[1], 0, 0, 1, tUp[2], 0, 0, 0, tUp[3], 0, 0, 0, 0, 1}
end

-- Action start --------------------------------------------------------------------------
-- tParameters: the action's float parameters by XML name; Velocity, VelocityRandomize and
-- Inductivity already converted from the 30 Hz rate (loader 0x140a67af0). iRate: updates a
-- second.

-- The start every action class runs first (game: 0x140a6cb10)
function SKILL_ACTOR.Setup(tActor, tState, tParameters, fnRandom, iRate, MATRIX, fnFloat32, fnSin, fnCos)

    local function fnValue(sName)
        return fnFloat32(tParameters[sName] or 0)
    end

    local flWander = fnValue("RandomDirection")
    local flFirst = fnRadians(SKILL_ACTOR.Spread(fnRandom, flWander, fnFloat32), fnFloat32)
    local flSecond = fnRadians(SKILL_ACTOR.Spread(fnRandom, flWander, fnFloat32), fnFloat32)
    local flThird = fnRadians(SKILL_ACTOR.Spread(fnRandom, flWander, fnFloat32), fnFloat32)

    -- 0x14127e960(a, out, b) is b * a: the random turn and the fixed turn about X act in the
    -- object's own frame
    local tMatrix = MATRIX.Multiply(tState.orientation, MATRIX.Euler(flFirst, flSecond, flThird, fnFloat32, fnSin, fnCos), fnFloat32)
    tMatrix = MATRIX.Multiply(tMatrix, fnRotationX(fnRadians(fnValue("Rotate_x"), fnFloat32), fnFloat32, fnSin, fnCos), fnFloat32)

    local flSpeed = fnFloat32(fnValue("Velocity") + SKILL_ACTOR.Spread(fnRandom, fnValue("VelocityRandomize"), fnFloat32))
    local tForward = {fnFloat32(-tMatrix[2]), fnFloat32(-tMatrix[6]), fnFloat32(-tMatrix[10])}

    if fnSquared(tForward, fnFloat32) > 0 then
        tForward = fnUnit(tForward, fnFloat32)
        tState.velocity = {fnFloat32(tForward[1] * flSpeed), fnFloat32(tForward[2] * flSpeed), fnFloat32(tForward[3] * flSpeed)}
    end

    -- Gravity is in g: 980.665 units a second squared along -Z
    local flFall = fnFloat32(fnFloat32(fnValue("Gravity") * fnFloat32(980.6649780273438)) / fnFloat32(iRate * iRate))

    tActor.gravity = {fnFloat32(-0.0 * flFall), fnFloat32(-0.0 * flFall), fnFloat32(-1.0 * flFall)}
    tState.roll = fnFloat32(SKILL_ACTOR.Spread(fnRandom, fnValue("RandomRoll"), fnFloat32) + tState.roll)
    tActor.inductivity, tActor.viewingAngle = fnValue("Inductivity"), fnValue("ViewingAngle")

end

-- ELEVATOR start (game: 0x140a6e700): a speed along +Z replaces the launch direction
function SKILL_ACTOR.ElevatorStart(tActor, tState, tParameters, fnFloat32)

    local flSpeed = fnFloat32(tParameters.Velocity or 0)

    if flSpeed ~= 0 then
        tState.velocity = {fnFloat32(flSpeed * 0), fnFloat32(flSpeed * 0), fnFloat32(flSpeed * 1)}
    end

end

-- CRAWLER start (game: 0x140a6e430): keeps its speed. The ground snap and the FixedUp basis
-- need the stage and are the caller's.
function SKILL_ACTOR.CrawlerStart(tActor, tState, fnFloat32)
    tActor.speed = fnLength(tState.velocity, fnFloat32)
end

-- SINCURVE start (game: 0x140a6f030)
function SKILL_ACTOR.SinCurveStart(tActor, tState, tParameters, fnFloat32)

    local function fnValue(sName)
        return fnFloat32(tParameters[sName] or 0)
    end

    tActor.base = {tState.position[1], tState.position[2], tState.position[3]}
    tActor.amplitude = {fnValue("Amplitude_x"), fnValue("Amplitude_y"), fnValue("Amplitude_z")}
    tActor.frequency = {fnValue("Frequency_x"), fnValue("Frequency_y"), fnValue("Frequency_z")}
    tActor.previous = {tState.position[1], tState.position[2], tState.position[3]}

end

-- BOUNDBALL start (game: 0x140a6e060)
function SKILL_ACTOR.BoundBallStart(tActor, tState, tParameters, fnFloat32)

    tActor.friction, tActor.restitution = fnFloat32(tParameters.Friction or 0), fnFloat32(tParameters.Restitution or 0)
    tActor.bounced, tActor.floating = 0, 0
    tActor.previous = {tState.position[1], tState.position[2], tState.position[3]}

end

-- Shared steps --------------------------------------------------------------------------

local function fnAdvance(tPosition, tVelocity, flMultiplier, fnFloat32)

    for i = 1, 3 do
        tPosition[i] = fnFloat32(fnFloat32(flMultiplier * tVelocity[i]) + tPosition[i])
    end

end

-- Steer toward the target (game: 0x140a62320). tTarget: its position, or nil; flIX / flIY /
-- flIZ weigh the pull per axis. Returns false when the guidance must stop (no target, the
-- target outside the viewing cone, no motion). The game's two character-specific cases
-- (4mkgawa*) are not reproduced.
function SKILL_ACTOR.Guide(tState, tTarget, flViewingAngle, flIX, flIY, flIZ, fnFloat32, fnAcos)

    if not tTarget then return false end

    local tToward = {fnFloat32(tTarget[1] - tState.position[1]), fnFloat32(tTarget[2] - tState.position[2]), fnFloat32(tTarget[3] - tState.position[3])}

    if not (fnSquared(tToward, fnFloat32) > 0) then return false end

    tToward = fnUnit(tToward, fnFloat32)

    local tVelocity = tState.velocity

    if not (fnSquared(tVelocity, fnFloat32) > 0) then return false end

    local tHeading = fnUnit(tVelocity, fnFloat32)
    local flOff = fnTurnDegrees(fnAcos(fnDot(tHeading, tToward, fnFloat32)), fnFloat32)

    if fnFloat32(flViewingAngle * 0.5) < flOff then return false end

    local flSpeed = fnLength(tVelocity, fnFloat32)

    tVelocity[1] = fnFloat32(fnFloat32(fnFloat32(tToward[1] * flSpeed) * flIX) + tVelocity[1])
    tVelocity[2] = fnFloat32(fnFloat32(fnFloat32(tToward[2] * flSpeed) * flIY) + tVelocity[2])
    tVelocity[3] = fnFloat32(fnFloat32(fnFloat32(tToward[3] * flSpeed) * flIZ) + tVelocity[3])

    if fnSquared(tVelocity, fnFloat32) > 0 then
        local tDirection = fnUnit(tVelocity, fnFloat32)
        tVelocity[1], tVelocity[2], tVelocity[3] = fnFloat32(flSpeed * tDirection[1]), fnFloat32(flSpeed * tDirection[2]), fnFloat32(flSpeed * tDirection[3])
    end

    return true

end

-- Guidance of a moving class: it stops for good once Guide refuses
local function fnSteer(tActor, tState, tTarget, bVertical, fnFloat32, fnAcos)

    if tState.guidance ~= 0 and not SKILL_ACTOR.Guide(tState, tTarget, tActor.viewingAngle, tActor.inductivity, tActor.inductivity,
        bVertical and tActor.inductivity or 0, fnFloat32, fnAcos) then
        tState.guidance = 0
    end

end

-- Bank roll (game: 0x140a61980). tHeading: the velocity, or the step of a sine object.
function SKILL_ACTOR.Bank(tState, tHeading, tParameters, fnFloat32)

    local flLimit = fnFloat32(tParameters.BankRollMax or 0)
    local flStrength = fnFloat32(tParameters.BankStrong or 0)
    local flSpring = fnFloat32(tParameters.BankSpring or 0)
    local flFloor = fnFloat32(-flLimit)

    if flStrength ~= 0 and flLimit > tState.roll and tState.roll > flFloor and fnSquared(tHeading, fnFloat32) > 0 then

        local flSide = fnDot(fnUnit(tHeading, fnFloat32), fnColumn(tState.orientation, 1), fnFloat32)

        if not (0.000244140625 > fnFloat32(flSide * flSide)) then

            if flSide > 0 then

                tState.roll = fnFloat32(flStrength + tState.roll)
                if tState.roll > flLimit then tState.roll = flLimit end

            elseif 0 > flSide then

                tState.roll = fnFloat32(tState.roll - flStrength)
                if flFloor > tState.roll then tState.roll = flFloor end

            end

        end

    end

    if flSpring ~= 0 then
        tState.roll = fnFloat32(fnFloat32(1 - flSpring) * tState.roll)
    end

end

-- Per-tick updates ----------------------------------------------------------------------
-- Each ends with the orientation update 0x140a61c20 (SkillShot.Orientation), passed in as
-- fnOrient(tState).

-- ARROW (game: 0x140a6ce80)
function SKILL_ACTOR.Arrow(tActor, tState, tParameters, tTarget, fnOrient, fnFloat32, fnAcos)

    fnAdvance(tState.position, tState.velocity, tState.multiplier, fnFloat32)

    for i = 1, 3 do
        tState.velocity[i] = fnFloat32(tState.velocity[i] + tActor.gravity[i])
    end

    fnSteer(tActor, tState, tTarget, true, fnFloat32, fnAcos)
    SKILL_ACTOR.Bank(tState, tState.velocity, tParameters, fnFloat32)
    fnOrient(tState)

end

-- ELEVATOR (game: 0x140a6e670)
function SKILL_ACTOR.Elevator(tActor, tState, fnOrient, fnFloat32)

    fnAdvance(tState.position, tState.velocity, tState.multiplier, fnFloat32)

    for i = 1, 3 do
        tState.velocity[i] = fnFloat32(tState.velocity[i] + tActor.gravity[i])
    end

    fnOrient(tState)

end

-- SINCURVE (game: 0x140a6eb60): the straight path carries a sine offset along each axis of
-- the object's frame. fnSin is the double sine.
function SKILL_ACTOR.SinCurve(tActor, tState, tParameters, tTarget, iRate, fnOrient, fnFloat32, fnAcos, fnSin)

    local f = fnFloat32

    tActor.previous = {tState.position[1], tState.position[2], tState.position[3]}

    fnAdvance(tActor.base, tState.velocity, tState.multiplier, f)
    tState.position = {tActor.base[1], tActor.base[2], tActor.base[3]}

    for i = 1, 3 do
        tState.velocity[i] = f(tState.velocity[i] + tActor.gravity[i])
    end

    fnSteer(tActor, tState, tTarget, true, f, fnAcos)

    local flElapsed, tSwing = f(tState.frame), {}

    for iAxis = 1, 3 do

        local flDegrees = f(f(f(tActor.frequency[iAxis] * 360) * flElapsed) / f(iRate))
        local flScaled = f(f(f(flDegrees * 65536) / 360) + (0 > flDegrees and -0.5 or 0.5))
        local iUnits = flScaled >= 0 and math.floor(flScaled) or math.ceil(flScaled)

        tSwing[iAxis] = f(f(fnSin(f(f(f(iUnits) * f(6.2831854820251465)) * 1.52587890625e-05))) * tActor.amplitude[iAxis])

    end

    local tOrientation = tState.orientation
    local tX, tY, tZ = fnColumn(tOrientation, 1), fnColumn(tOrientation, 2), fnColumn(tOrientation, 3)

    tState.position = {
        f(f(f(f(tX[1] * tSwing[1]) + tActor.base[1]) + f(tY[1] * tSwing[2])) + f(tZ[1] * tSwing[3])),
        f(f(f(f(tSwing[1] * tX[2]) + tActor.base[2]) + f(tSwing[2] * tY[2])) + f(tSwing[3] * tZ[2])),
        f(f(f(f(tSwing[1] * tX[3]) + tActor.base[3]) + f(tSwing[2] * tY[3])) + f(tSwing[3] * tZ[3]))
    }

    local tStep = {
        f(f(tState.position[1] - tActor.previous[1]) + tState.velocity[1]),
        f(f(tState.position[2] - tActor.previous[2]) + tState.velocity[2]),
        f(f(tState.position[3] - tActor.previous[3]) + tState.velocity[3])
    }

    SKILL_ACTOR.Bank(tState, tStep, tParameters, f)
    fnOrient(tState)

end

-- The FixedUp parameter (game: 0x141282120 on the object's basis): +Z replaces the Z axis
-- before the orientation update, so the object stays upright on a slope
function SKILL_ACTOR.FixedUp(tState)

    local tO = tState.orientation

    tState.orientation = {tO[1], tO[2], 0, tO[4], tO[5], tO[6], 0, tO[8], tO[9], tO[10], 1, tO[12], 0, 0, 0, 1}

end

-- CRAWLER (game: 0x140a6e0d0). fnGround(tState) answers the stage query 0x140a620a0 (a sphere
-- dropped from above the object): nil when it finds nothing, else the height of the first
-- walkable surface (false when no hit is walkable). bUpright: the action's FixedUp.
function SKILL_ACTOR.Crawler(tActor, tState, tTarget, iRate, fnGround, fnOrient, fnFloat32, fnAcos, bUpright)

    fnAdvance(tState.position, tState.velocity, tState.multiplier, fnFloat32)

    local tVelocity = tState.velocity
    local flVertical = tVelocity[3]

    if flVertical > 0 then

        if fnSquared(tVelocity, fnFloat32) > 0 then

            local tDirection = fnUnit(tVelocity, fnFloat32)

            for i = 1, 3 do
                tVelocity[i] = fnFloat32(tActor.speed * tDirection[i])
            end

        end

    else

        tVelocity[3] = 0

        if fnSquared(tVelocity, fnFloat32) > 0 then
            local tDirection = fnUnit(tVelocity, fnFloat32)
            tVelocity[1], tVelocity[2] = fnFloat32(tActor.speed * tDirection[1]), fnFloat32(tActor.speed * tDirection[2])
        end

        tVelocity[3] = flVertical

    end

    local flHeight = fnGround(tState)

    if flHeight == nil then
        tVelocity[3] = fnFloat32(tVelocity[3] - fnFloat32(98 / fnFloat32(iRate)))
    elseif flHeight then
        tState.position[3] = flHeight
    end

    if bUpright then
        SKILL_ACTOR.FixedUp(tState)
    end

    fnSteer(tActor, tState, tTarget, false, fnFloat32, fnAcos)
    fnOrient(tState)

end

-- BOUNDBALL (game: 0x140a6cfe0), the solid-surface path: gravity, a sweep along the velocity,
-- and on contact a reflection weighed by Restitution (along the surface normal) and Friction
-- (along the surface). fnSweep(tState) answers the stage query: nil, or {fraction, normal}.
-- The game also rolls the model with the distance covered and floats on water: not
-- reproduced.
function SKILL_ACTOR.BoundBall(tActor, tState, tTarget, iRate, fnSweep, fnFloat32, fnAcos)

    local f = fnFloat32
    local tVelocity = tState.velocity

    if tActor.floating == 0 then
        for i = 1, 3 do
            tVelocity[i] = f(tVelocity[i] + tActor.gravity[i])
        end
    end

    if tActor.bounced ~= 0 then
        fnSteer(tActor, tState, tTarget, false, f, fnAcos)
    end

    tActor.bounced = 0
    tActor.previous = {tState.position[1], tState.position[2], tState.position[3]}

    local tHit = fnSweep(tState)

    if not tHit then
        fnAdvance(tState.position, tVelocity, tState.multiplier, f)
        return
    end

    tActor.bounced = 1

    local tNormal = tHit.normal
    local flInto = f(-fnDot(tVelocity, tNormal, f))
    local flKeep = f(1 - tActor.friction)
    local tAlong = {f(f(f(tNormal[1] * flInto) + tVelocity[1]) * flKeep), f(f(f(tNormal[2] * flInto) + tVelocity[2]) * flKeep),
        f(f(f(tNormal[3] * flInto) + tVelocity[3]) * flKeep)}
    local tAway = {f(f(tNormal[1] * flInto) * tActor.restitution), f(f(tNormal[2] * flInto) * tActor.restitution),
        f(f(tNormal[3] * flInto) * tActor.restitution)}

    -- Up to the contact, then one unit (30 Hz reference) off the surface
    local flLift = f(f(30 / f(iRate)) * 1)

    for i = 1, 3 do
        tState.position[i] = f(f(tState.position[i] + f(tHit.fraction * tVelocity[i])) + f(tNormal[i] * flLift))
    end

    -- A weak rebound is halved, the others keep 98 %
    local flDamping = f(f(30 / f(iRate)) * 4) > fnSquared(tAway, f) and 0.5 or f(0.9800000190734863)

    for i = 1, 3 do
        tVelocity[i] = f(f(tAway[i] * flDamping) + tAlong[i])
    end

end

return SKILL_ACTOR
