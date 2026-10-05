-- Translation of the forward-clock path at 0x14131bbb0. External activation,
-- animation loop resets and particle stop notifications remain caller inputs.
local E={}
function E.new(initiallyActive)
    return {active=initiallyActive or false,index=1,accumulator=0,frames=0,
            multiplier=0,blocked=false,previousClock=nil}
end
-- The effect instance has a lifetime boundary in addition to emitter events.
-- When its ANM ends, the native host stops every generator, including ones
-- whose particle records have no explicit stop event.
function E.stop(s)
    s.active=false
    s.blocked=true
end
function E.update(s,e,clockMs,gameFPS,updateFactor,attachmentCount)
    local event=e.events[s.index]
    local notify=false
    -- The original processes at most one event per update, even on a jump.
    if clockMs~=s.previousClock and event and clockMs>=event.clock_threshold_ms then
        if event.start_flag then
            if not s.blocked then s.active=true end
            s.multiplier=1
        else
            if not s.blocked then s.active=false end
            notify=event.stop_flag
        end
        s.index=s.index+1
    end
    s.frames=s.frames+1
    local count=0
    if clockMs~=s.previousClock or clockMs==0 and not s.seenZero then
        if s.active and attachmentCount>0 then
            local quantity=e.quantity
            if e.direct then
                if not s.blocked then s.active=false end
            else
                quantity=quantity/gameFPS*updateFactor+s.accumulator
                s.accumulator=quantity
            end
            count=quantity>=0 and math.floor(quantity) or math.ceil(quantity)
            if count~=0 then s.accumulator=s.accumulator-count end
        end
    end
    if e.durationCounter~=-1 and s.frames>e.durationCounter then
        if not s.blocked then s.active=false end
        s.blocked=true
    end
    s.previousClock=clockMs
    if clockMs==0 then s.seenZero=true end
    return count,attachmentCount*s.multiplier,notify
end
return E
