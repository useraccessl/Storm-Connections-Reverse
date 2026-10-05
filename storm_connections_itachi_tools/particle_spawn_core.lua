-- Original arithmetic helpers. Spatial attachment composition is supplied by
-- the caller; this module never loads recorded particle positions.
local S={}
local tiny=1.1754943508222875e-38
function S.random(seed)
    local rng={seed=seed%2147483648}
    function rng:integer()
        -- Only low 31 bits affect (seed >> 16) & 32767 in the original
        -- 64-bit LCG. This also stays within exact Lua double integer range.
        self.seed=(self.seed*214013+2531011)%2147483648
        return math.floor(self.seed/65536)%32768
    end
    function rng:range(amount) return self:integer()/32767*amount end
    -- 0x1412cd630 computes upper - u*(upper-lower), not lower+u*range.
    function rng:interval(lower,upper) return upper-self:integer()/32767*(upper-lower) end
    return rng
end
-- 0x14131b5c0 / 0x14131c560: no random draw below two resources; an emitter without a
-- resource still makes its particles, which carry none (nil: nothing to draw).
function S.resource(resources,rng)
    if #resources<=1 then return resources[1] end
    return resources[rng:integer()%#resources+1]
end
function S.lifetime(base,randomAmount,rng)
    local result=base+base*rng:range(randomAmount)
    return result>=0 and math.floor(result) or math.ceil(result)
end
function S.scalar(base,randomAmount,rng) return base+rng:range(randomAmount) end
function S.sizeCurves(e,rng)
    local random={}
    if e.independentSizeRandom then
        -- Assembly samples Z, Y, X, even when a range is zero.
        for i=3,1,-1 do random[i]=math.abs(rng:range(e.sizeRandom[i])) end
    else
        local r=math.abs(rng:range(1))
        for i=1,3 do random[i]=r*e.sizeRandom[i] end
    end
    local result={}
    for _,name in ipairs({'sizeStart','sizeMiddle','sizeEnd'}) do
        local values={}
        for i=1,3 do values[i]=e[name][i]*(1+random[i]) end
        result[name]=values
    end
    return result
end
local function normalize(v)
    local length=math.sqrt(v[1]^2+v[2]^2+v[3]^2)
    if length>tiny then for i=1,3 do v[i]=v[i]/length end end
    return v
end
-- 0x14131d750: selectors 0/1 have opposite meanings to the old diagnostic.
-- Selector 3 requires the original Euler/axis alignment, deliberately explicit.
function S.velocity(e,position,center,attachmentDirection,attachmentScale,rng,coneTransform)
    local v={0,0,0}
    if e.direction==0 or e.direction==1 then
        for i=1,3 do v[i]=(position[i]-center[i])*(e.direction==0 and 1 or -1) end
    elseif e.direction==2 then
        -- Calls occur Z, Y, X before the vector setter.
        for i=3,1,-1 do v[i]=rng:interval(-1,1) end
    elseif e.direction==3 then
        if not coneTransform then return nil,'original cone/attachment transform required' end
        local b=math.abs(e.angles[2]*(1+e.angleRanges[2]))
        local a=math.abs(e.angles[1]*(1+e.angleRanges[1]))
        local angleB=rng:interval(-b,b)
        local angleA=rng:interval(-a,a)
        v=coneTransform(angleA,angleB,attachmentDirection)
    else return nil,'unknown direction selector' end
    if e.direction~=3 and attachmentDirection then
        normalize(v)
        for i=1,3 do v[i]=v[i]+attachmentDirection[i] end
    end
    normalize(v)
    local speed=e.speed*(1+rng:range(e.speedRandom))*attachmentScale
    for i=1,3 do v[i]=v[i]*speed end
    return v
end
return S
