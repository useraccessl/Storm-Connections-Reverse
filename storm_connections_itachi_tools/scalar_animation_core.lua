-- ANM key samplers selected by the key factory 0x141367040 (one class per
-- curve format; anm_key_classes.py lists them). Caller owns animation time.
-- Formats here:
--   11 fixed float            12 keyed float, linear (0x141353c80)
--   22 float table, linear or held (the factory picks the class from a flag)
--   24 float table, always held (same class as held 22)
--   15 opacity table of unsigned shorts, linear, * 1/32768 (0x141394da0)
--   29 the same table, held (0x141394e20)
--    5 fixed vector            6 keyed vector, linear (0x141391c10)
--   16 scale table of signed shorts, linear, * 1/4096 (0x141394ee0)
--   21 vector table, linear (0x141395130)   26 vector table, held (0x141395220)
local M={}
local function domain(ticks)
    assert(ticks>=0 and ticks==math.floor(ticks) and ticks<4294967296,'native sampler requires uint32 ticks')
end
-- Keyed curves search from the last key used (cursor kept in `state` or on
-- the curve) and need a key after the clock: files end them with tick -1.
local function keyed(values,ticks,state)
    local index=state.index or 1
    assert(ticks>=values[1][1]%4294967296 and ticks<values[#values][1]%4294967296,'clock outside native timestamp domain')
    while values[index+1][1]%4294967296<=ticks do index=index+1 end
    while values[index][1]%4294967296>ticks do index=index-1 end
    state.index=index
    return values[index],values[index+1]
end
function M.sample(curve,ticks,step,hold,float32,state)
    domain(ticks)
    local values=curve.values
    if curve.format==11 then return values[1][1] end
    local f=assert(float32,'float32 conversion required for original SSE arithmetic')
    if curve.format==12 then
        local a,b=keyed(values,ticks,state or curve)
        local t=f(f(ticks-a[1]%4294967296)/f(b[1]%4294967296-a[1]%4294967296))
        -- Timestamp reader adds the left product first.
        return f(f(f(1-t)*a[2])+f(t*b[2]))
    end
    assert(step>0 and step==math.floor(step),'native sampler requires positive integer step')
    local index=math.floor(ticks/step)+1
    local remainder=ticks%step
    if curve.format==15 or curve.format==29 then
        -- Unsigned shorts; (1-t)*a + t*b, then the 1/32768 scale. Format 29
        -- (0x141394e20) is the same table without interpolation.
        local a=assert(values[index],'clock outside native curve domain')[1]%65536
        if remainder~=0 and curve.format==15 then
            local t=f(f(remainder)/f(step))
            local b=assert(values[index+1],'clock outside native curve interpolation domain')[1]%65536
            a=f(f(f(1-t)*a)+f(b*t))
        end
        return f(a*3.0517578125e-05)
    end
    assert(curve.format==22 or curve.format==24,'unsupported native scalar curve format')
    assert(values[index],'clock outside native curve domain')
    local a=values[index][1]
    if hold or curve.format==24 or remainder==0 then return a end
    local b=assert(values[index+1],'clock outside native curve interpolation domain')[1]
    local t=f(f(remainder)/f(step))
    -- Native operation order: (t*b) + ((1-t)*a), not a+t*(b-a).
    return f(f(t*b)+f(f(1-t)*a))
end
-- Vector curves (position, scale): returns {x, y, z}.
function M.vector(curve,ticks,step,float32,state)
    domain(ticks)
    local values,f=curve.values,assert(float32)
    if curve.format==5 then
        assert(#values==1,'format 5 is a constant vector reader')
        return {values[1][1],values[1][2],values[1][3]}
    end
    if curve.format==6 then
        local a,b=keyed(values,ticks,state or curve)
        local t=f(f(ticks-a[1]%4294967296)/f(b[1]%4294967296-a[1]%4294967296))
        local w=f(1-t)
        -- 0x1411ac910: (1-t)*a + t*b per component.
        return {f(f(w*a[2])+f(t*b[2])),f(f(w*a[3])+f(t*b[3])),f(f(w*a[4])+f(t*b[4]))}
    end
    assert(step>0 and step==math.floor(step),'native sampler requires positive integer step')
    local index=math.floor(ticks/step)+1
    local remainder=ticks%step
    local a=assert(values[index],'clock outside native curve domain')
    if curve.format==26 then return {a[1],a[2],a[3]} end
    if curve.format==16 then
        local scale=0.000244140625
        if remainder==0 then return {f(a[1]*scale),f(a[2]*scale),f(a[3]*scale)} end
        local b=assert(values[index+1],'clock outside native curve interpolation domain')
        local t=f(f(remainder)/f(step))
        local wa,wb=f(f(1-t)*scale),f(t*scale)
        return {f(f(b[1]*wb)+f(a[1]*wa)),f(f(b[2]*wb)+f(a[2]*wa)),f(f(b[3]*wb)+f(a[3]*wa))}
    end
    assert(curve.format==21,'unsupported native vector curve format')
    if remainder==0 then return {a[1],a[2],a[3]} end
    local b=assert(values[index+1],'clock outside native curve interpolation domain')
    local t=f(f(remainder)/f(step))
    local w=f(1-t)
    return {f(f(w*a[1])+f(t*b[1])),f(f(w*a[2])+f(t*b[2])),f(f(w*a[3])+f(t*b[3]))}
end
return M
