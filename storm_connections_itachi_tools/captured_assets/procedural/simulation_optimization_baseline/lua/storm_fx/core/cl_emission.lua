-- Emission of a particle generator (game: forward clock path 0x14131bbb0): its start and
-- stop events, and how many particles it emits each update. Its activation from outside,
-- the resets of a looping animation and the stop notifications are the caller's.

StormFX.Core.Emission = StormFX.Core.Emission or {}

local EMISSION = StormFX.Core.Emission

-- The emission state of one generator
function EMISSION.New(bInitiallyActive)

    return {
        active = bInitiallyActive or false,
        index = 1,
        accumulator = 0,
        frames = 0,
        multiplier = 0,
        blocked = false,
        previousClock = nil
    }

end

-- Stop a generator for good. When the effect's animation ends, the game stops every
-- generator, even those whose particles have no stop event of their own.
function EMISSION.Stop(tState)

    tState.active = false
    tState.blocked = true

end

-- One update at iClockMs: returns the particles to emit, the attachments they go to and
-- whether a stop event asks for a notification
function EMISSION.Update(tState, tEmitter, iClockMs, flGameFPS, flUpdateFactor, iAttachmentCount)

    local tEvent = tEmitter.events[tState.index]
    local bNotify = false

    -- The game handles at most one event an update, even when the clock jumps
    if iClockMs ~= tState.previousClock and tEvent and iClockMs >= tEvent.clock_threshold_ms then

        if tEvent.start_flag then

            if not tState.blocked then tState.active = true end
            tState.multiplier = 1

        else

            if not tState.blocked then tState.active = false end
            bNotify = tEvent.stop_flag

        end

        tState.index = tState.index + 1

    end

    tState.frames = tState.frames + 1

    local iCount = 0

    if iClockMs ~= tState.previousClock or (iClockMs == 0 and not tState.seenZero) then

        if tState.active and iAttachmentCount > 0 then

            local flQuantity = tEmitter.quantity

            if tEmitter.direct then

                if not tState.blocked then tState.active = false end

            else

                flQuantity = flQuantity / flGameFPS * flUpdateFactor + tState.accumulator
                tState.accumulator = flQuantity

            end

            iCount = flQuantity >= 0 and math.floor(flQuantity) or math.ceil(flQuantity)

            if iCount ~= 0 then
                tState.accumulator = tState.accumulator - iCount
            end

        end

    end

    if tEmitter.durationCounter ~= -1 and tState.frames > tEmitter.durationCounter then

        if not tState.blocked then tState.active = false end
        tState.blocked = true

    end

    tState.previousClock = iClockMs

    if iClockMs == 0 then
        tState.seenZero = true
    end

    return iCount, iAttachmentCount * tState.multiplier, bNotify

end

return EMISSION
