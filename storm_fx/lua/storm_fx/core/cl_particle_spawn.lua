-- Birth of a particle: the game's random generator, the resource it carries, its life, its
-- size curves and its first velocity. Where it is born is the caller's (ParticleSpatial).

StormFX.Core.ParticleSpawn = StormFX.Core.ParticleSpawn or {}

local PARTICLE_SPAWN = StormFX.Core.ParticleSpawn

local FL_TINY = 1.1754943508222875e-38

-- The game's random generator (a 64-bit LCG of which only the low 31 bits matter for
-- (seed >> 16) & 32767, which keeps it exact in doubles)
function PARTICLE_SPAWN.Random(iSeed)

    local tRandom = {seed = iSeed % 2147483648}

    -- An integer in 0..32767
    function tRandom:Integer()

        self.seed = (self.seed * 214013 + 2531011) % 2147483648

        return math.floor(self.seed / 65536) % 32768

    end

    -- A number in 0..flAmount
    function tRandom:Range(flAmount)
        return self:Integer() / 32767 * flAmount
    end

    -- A number between flLower and flUpper (game: 0x1412cd630 computes upper - u * (upper - lower))
    function tRandom:Interval(flLower, flUpper)
        return flUpper - self:Integer() / 32767 * (flUpper - flLower)
    end

    return tRandom

end

-- The resource a particle carries (game: 0x14131b5c0 / 0x14131c560): no random draw below two
-- resources; an emitter without a resource still makes particles, which carry nothing (nil)
function PARTICLE_SPAWN.Resource(tResources, tRandom)

    if #tResources <= 1 then
        return tResources[1]
    end

    return tResources[tRandom:Integer() % #tResources + 1]

end

-- A particle's life: the base plus a random share of it, truncated
function PARTICLE_SPAWN.Lifetime(flBase, flRandomAmount, tRandom)

    local flResult = flBase + flBase * tRandom:Range(flRandomAmount)

    return flResult >= 0 and math.floor(flResult) or math.ceil(flResult)

end

-- A value plus a random amount
function PARTICLE_SPAWN.Scalar(flBase, flRandomAmount, tRandom)
    return flBase + tRandom:Range(flRandomAmount)
end

-- The size curves of a particle with its random size (the game draws Z, Y then X, even for a
-- zero range)
function PARTICLE_SPAWN.SizeCurves(tEmitter, tRandom)

    local tFactors = {}

    if tEmitter.independentSizeRandom then

        for i = 3, 1, -1 do
            tFactors[i] = math.abs(tRandom:Range(tEmitter.sizeRandom[i]))
        end

    else

        local flShared = math.abs(tRandom:Range(1))

        for i = 1, 3 do
            tFactors[i] = flShared * tEmitter.sizeRandom[i]
        end

    end

    local tCurves = {}

    for _, sName in ipairs({"sizeStart", "sizeMiddle", "sizeEnd"}) do

        local tValues = {}

        for i = 1, 3 do
            tValues[i] = tEmitter[sName][i] * (1 + tFactors[i])
        end

        tCurves[sName] = tValues

    end

    return tCurves

end

-- Normalise a vector in place (left as is when too short)
local function fnNormalize(tVector)

    local flLength = math.sqrt(tVector[1]^2 + tVector[2]^2 + tVector[3]^2)

    if flLength > FL_TINY then

        for i = 1, 3 do
            tVector[i] = tVector[i] / flLength
        end

    end

    return tVector

end

-- First velocity of a particle (game: 0x14131d750). Direction selector 0: away from the
-- centre, 1: toward it, 2: random, 3: inside a cone (fnConeTransform is required for it).
-- Returns nil and a reason when it cannot be computed.
function PARTICLE_SPAWN.Velocity(tEmitter, tPosition, tCenter, tAttachmentDirection, flAttachmentScale, tRandom, fnConeTransform)

    local tVelocity = {0, 0, 0}

    if tEmitter.direction == 0 or tEmitter.direction == 1 then

        for i = 1, 3 do
            tVelocity[i] = (tPosition[i] - tCenter[i]) * (tEmitter.direction == 0 and 1 or -1)
        end

    elseif tEmitter.direction == 2 then

        -- Drawn Z, Y then X, before the vector setter
        for i = 3, 1, -1 do
            tVelocity[i] = tRandom:Interval(-1, 1)
        end

    elseif tEmitter.direction == 3 then

        if not fnConeTransform then
            return nil, "original cone/attachment transform required"
        end

        local flB = math.abs(tEmitter.angles[2] * (1 + tEmitter.angleRanges[2]))
        local flA = math.abs(tEmitter.angles[1] * (1 + tEmitter.angleRanges[1]))
        local flAngleB = tRandom:Interval(-flB, flB)
        local flAngleA = tRandom:Interval(-flA, flA)

        tVelocity = fnConeTransform(flAngleA, flAngleB, tAttachmentDirection)

    else
        return nil, "unknown direction selector"
    end

    if tEmitter.direction ~= 3 and tAttachmentDirection then

        fnNormalize(tVelocity)

        for i = 1, 3 do
            tVelocity[i] = tVelocity[i] + tAttachmentDirection[i]
        end

    end

    fnNormalize(tVelocity)

    local flSpeed = tEmitter.speed * (1 + tRandom:Range(tEmitter.speedRandom)) * flAttachmentScale

    for i = 1, 3 do
        tVelocity[i] = tVelocity[i] * flSpeed
    end

    return tVelocity

end

return PARTICLE_SPAWN
