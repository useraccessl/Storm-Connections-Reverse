-- Animation clock of the game's effects (nuccAnm / nuccAnmEffect): ticks, looping, and
-- the clock step of a particle.

StormFX.Core.AnmClock = StormFX.Core.AnmClock or {}

local ANM_CLOCK = StormFX.Core.AnmClock

-- Wrap a number to a signed 32-bit integer
local function fnInt32(iValue)

    iValue = iValue % 4294967296

    if iValue >= 2147483648 then
        iValue = iValue - 4294967296
    end

    return iValue

end

-- Round toward zero
local function fnTruncate(flValue)
    return flValue < 0 and math.ceil(flValue) or math.floor(flValue)
end

-- Remainder of a division rounded toward zero
local function fnRemainder(iA, iB)
    return iA - fnTruncate(iA / iB) * iB
end

-- A clock of iDuration ticks (bit 0 of iFlags: it loops)
function ANM_CLOCK.New(iDuration, iFlags, iTicks, flSpeed)

    assert(iDuration == math.floor(iDuration) and iDuration >= 0 and iDuration <= 2147483647)

    return {
        duration = iDuration,
        flags = iFlags or 0,
        ticks = fnInt32(iTicks or 0),
        speed = flSpeed or 1
    }

end

-- Settle a clock that was just advanced (game: 0x1412a3c30). A looping clock wraps around;
-- another stops at its end and returns how far it went past it. -1 while it runs.
function ANM_CLOCK.Resolve(tClock, iDelta)

    local iTicks, iDuration = tClock.ticks, tClock.duration
    local bLoop = tClock.flags % 2 == 1

    if iDelta > 0 then

        if iTicks <= iDuration then return -1 end

        if bLoop then
            tClock.ticks = iDuration > 0 and fnRemainder(iTicks, iDuration) or 0
            return -1
        end

        tClock.ticks = iDuration
        return fnInt32(iTicks - iDuration)

    end

    if iTicks >= 0 then return -1 end

    if bLoop then

        assert(iDuration > 0, "A reversed looping clock of zero duration divides by zero")
        assert(iTicks ~= -2147483648, "A reversed looping clock at INT_MIN is outside the supported range")

        tClock.ticks = fnInt32(iDuration - fnRemainder(-iTicks, iDuration))
        return -1

    end

    tClock.ticks = 0
    return iTicks

end

-- Advance a clock by iDelta ticks at its speed (game: effect update 0x14136bc90): the step
-- is scaled in float32, truncated, added, then the clock is settled
function ANM_CLOCK.Advance(tClock, iDelta, fnFloat32)

    assert(fnFloat32, "Supply the float32 rounding")
    assert(iDelta == math.floor(iDelta) and iDelta >= -2147483648 and iDelta <= 2147483647)

    local flScaled = fnFloat32(fnFloat32(iDelta) * fnFloat32(tClock.speed))
    assert(flScaled >= -2147483648 and flScaled < 2147483648, "The scaled step overflows (cvttss2si)")

    local iStep = fnTruncate(flScaled)
    tClock.ticks = fnInt32(tClock.ticks + iStep)

    return ANM_CLOCK.Resolve(tClock, iStep), iStep

end

-- Clock of a particle (game: motion 0x141386b70, render update 0x14130b200): its update
-- interval in ticks, its speed and its age step
function ANM_CLOCK.ParticleStep(flSimulationHz, iUpdateRate, flTimeScale, fnFloat32)

    assert(iUpdateRate > 0 and iUpdateRate <= 60 and 60 % iUpdateRate == 0)

    local flFactor = fnFloat32(fnFloat32(flSimulationHz) / fnFloat32(iUpdateRate))
    local flAgeStep = fnFloat32(fnFloat32(flTimeScale) * flFactor)
    local flSpeed = fnFloat32(fnFloat32(fnFloat32(iUpdateRate) / 30) * flAgeStep)

    return math.floor(3000 / iUpdateRate), flSpeed, flAgeStep

end

return ANM_CLOCK
