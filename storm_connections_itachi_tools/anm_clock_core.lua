-- Original nuccAnm / nuccAnmEffect clock, not nuccSpriteAnm.
local C = {}
local function i32(v)
    v = v % 4294967296
    if v >= 2147483648 then v = v - 4294967296 end
    return v
end
local function trunc(v) return v < 0 and math.ceil(v) or math.floor(v) end
local function rem(a,b) return a - trunc(a/b)*b end
function C.new(duration, flags, ticks, speed)
    assert(duration == math.floor(duration) and duration >= 0 and duration <= 2147483647)
    return {duration=duration, flags=flags or 0, ticks=i32(ticks or 0), speed=speed or 1}
end
-- 0x1412a3c30 resolves an already advanced clock. Equality retains endpoint.
function C.resolve(state, delta)
    local t, d = state.ticks, state.duration
    local loop = state.flags % 2 == 1
    if delta > 0 then
        if t <= d then return -1 end
        if loop then
            state.ticks = d > 0 and rem(t,d) or 0
            return -1
        end
        state.ticks = d
        return i32(t-d)
    end
    if t >= 0 then return -1 end
    if loop then
        assert(d > 0, 'Original reverse-loop clock divides by zero for zero duration')
        assert(t ~= -2147483648, 'Original reverse-loop INT_MIN arithmetic is outside supported domain')
        state.ticks = i32(d-rem(-t,d))
        return -1
    end
    state.ticks = 0
    return t
end
-- Effect update 0x14136bc90: float32(delta)*speed, truncate, add, resolve.
function C.advance(state, delta, float32)
    assert(float32, 'Supply original-compatible float32 rounding')
    assert(delta == math.floor(delta) and delta >= -2147483648 and delta <= 2147483647)
    local scaled = float32(float32(delta)*float32(state.speed))
    assert(scaled >= -2147483648 and scaled < 2147483648, 'Unsupported cvttss2si overflow')
    local step=trunc(scaled)
    state.ticks=i32(state.ticks+step)
    return C.resolve(state,step),step
end
-- Particle motion 0x141386b70 -> render update 0x14130b200.
function C.particleStep(simulationHz, updateRate, timeScale, f)
    assert(updateRate>0 and updateRate<=60 and 60%updateRate==0)
    local factor=f(f(simulationHz)/f(updateRate))
    local ageStep=f(f(timeScale)*factor)
    local speed=f(f(f(updateRate)/30)*ageStep)
    return math.floor(3000/updateRate),speed,ageStep
end
return C
