-- Original material binder: NSUNSC 0x1412f5ff0; constructor 0x1412f5920.
-- Original global epoch and calls per host update remain external inputs.
local M={epsilon=1.1920928955078125e-7,clockMultiplier=0.10000000149011612}
local function nearestEven(value)
    local lo=math.floor(value) local fraction=value-lo
    if fraction>.5 or fraction==.5 and lo%2==1 then return lo+1 end
    return lo
end
function M.float32(value)
    if value==0 or value~=value or math.abs(value)==math.huge then return value end
    local sign=value<0 and -1 or 1 local magnitude=math.abs(value)
    local exponent
    if math.frexp then local mantissa; mantissa,exponent=math.frexp(magnitude)
    else
        exponent=math.floor(math.log(magnitude)/math.log(2))+1
        if magnitude>=2^exponent then exponent=exponent+1 end
        if magnitude<2^(exponent-1) then exponent=exponent-1 end
    end
    local step=2^math.max(exponent-24,-149)
    local rounded=nearestEven(magnitude/step)*step
    if rounded>=2^128 then rounded=math.huge end
    return sign*rounded
end
function M.signedFraction(value)
    local integer=value<0 and math.ceil(value) or math.floor(value)
    return M.float32(value-M.float32(integer))
end
function M.screenScroll(material,clockSeconds)
    -- File flag 4 is UV2 (offset.xy,scale.zw); flag 8 is UV3.
    -- Original screen scroll reads material +60,+64,+68,+6c: their scales.
    local uv2,uv3=material.scroll0,material.scroll1
    local rates={uv2[3],uv2[4],uv3[3],uv3[4]}
    local result={}
    for i,rate in ipairs(rates) do
        result[i]=math.abs(rate)<M.epsilon and 0 or M.signedFraction(M.float32(clockSeconds*rate))
    end
    return result
end
function M.advanceCounter(counter,delta,paused)
    -- 0x14129d957: +958 advances by +94c unless pause flag +95c is set.
    if paused then return counter end
    return (counter+delta)%2147483648
end
function M.originalClock(counter,denominator)
    assert(denominator>0,'Original clock denominator must be positive')
    return M.float32(M.float32(M.float32(counter)*M.clockMultiplier)/M.float32(denominator))
end
function M.deltaForCalls(denominator,calls)
    -- 0x1412a0500: unsigned divide by 60, accumulation capped at 600 calls.
    return math.floor(denominator/60)*math.min(calls,600)
end
function M.screenToUV(width,height)
    -- 0x1413380df: shader context +500 is reciprocal display dimensions.
    assert(width>0 and height>0,'Display dimensions must be positive')
    return {M.float32(1/width),M.float32(1/height),0,0}
end
return M
