-- Where a particle is born (game: 0x14131c560, 0x14131d750): around one attachment, or
-- along a segment between two. The coordinates come resolved from the scene; every random
-- draw of the game is made, zero ranges included.

StormFX.Core.ParticleSpatial = StormFX.Core.ParticleSpatial or {}

local PARTICLE_SPATIAL = StormFX.Core.ParticleSpatial

local FL_TINY = 1.1754943508222875e-38

-- A vector normalised (a copy; left as is when too short)
local function fnNormalize(tVector)

    local flLength = math.sqrt(tVector[1]^2 + tVector[2]^2 + tVector[3]^2)

    if flLength > FL_TINY then
        return {tVector[1] / flLength, tVector[2] / flLength, tVector[3] / flLength}
    end

    return {tVector[1], tVector[2], tVector[3]}

end

-- A vector through a 3x3 rotation (a copy when there is none)
local function fnRotate(tMatrix, tVector)

    if not tMatrix then
        return {tVector[1], tVector[2], tVector[3]}
    end

    return {
        tMatrix[1] * tVector[1] + tMatrix[2] * tVector[2] + tMatrix[3] * tVector[3],
        tMatrix[4] * tVector[1] + tMatrix[5] * tVector[2] + tMatrix[6] * tVector[3],
        tMatrix[7] * tVector[1] + tMatrix[8] * tVector[2] + tMatrix[9] * tVector[3]
    }

end

-- A direction inside a cone of angles flA, flB about tDirection (game: 0x14127fd10 reorders
-- its arguments before 0x1411ea620; the product is by matrix rows, not a Source Euler angle).
-- 0x1412cd160 negates the normalised argument and its caller negates the attachment's
-- direction too: the second basis column is +direction.
function PARTICLE_SPATIAL.Cone(flA, flB, tDirection)

    local tVector = {-math.sin(flB) * math.cos(flA), math.cos(flB) * math.cos(flA), math.sin(flA)}

    if not tDirection then return tVector end

    local tN = fnNormalize(tDirection)
    local flQ = math.sqrt(tN[2]^2 + tN[3]^2)

    if flQ == 0 then

        if tN[1] == 0 then return tVector end

        return {tN[1] * tVector[2], -tN[1] * tVector[1], tVector[3]}

    end

    return {
        flQ * tVector[1] + tN[1] * tVector[2],
        -tN[1] * tN[2] / flQ * tVector[1] + tN[2] * tVector[2] - tN[3] / flQ * tVector[3],
        -tN[1] * tN[3] / flQ * tVector[1] + tN[3] * tVector[2] + tN[2] / flQ * tVector[3]
    }

end

-- Birth around one attachment (shapes 0: point, 1: circle, 2: sphere). Returns the birth
-- {position, center, scale, direction, coneTransform, attachment}, or nil and a reason.
function PARTICLE_SPATIAL.Single(tEmitter, tRandom, tAttachments)

    -- Config flag 0x10 (motionSegment) does not stop the birth: 0x14131ca0b only adds an
    -- offset made from two vectors of the attachment record (+68, +74), and only when both are
    -- longer than a threshold. Those vectors are not reproduced: taken as zero, as for a
    -- coordinate that does not move (Kisame's wave lost its near waves while these births
    -- were refused).
    if #tAttachments == 0 then return nil, "no resolved attachment" end
    if tEmitter.shape > 2 and #tAttachments > 1 then return nil, "multi-attachment spawn requires segment resolver" end

    local iIndex = #tAttachments > 1 and tRandom:Integer() % #tAttachments + 1 or 1
    local tAttachment = tAttachments[iIndex]
    local tCenter = tAttachment.position
    local flScale = tAttachment.scale or 1
    local tDirection = tAttachment.direction or {0, 0, 1}

    if tDirection[1]^2 + tDirection[2]^2 + tDirection[3]^2 < FL_TINY then
        tDirection = {0, 0, 1}
    end

    if not tAttachment.worldDirection then
        tDirection = fnNormalize(fnRotate(tAttachment.rotation, tDirection))
    end

    local flTheta = tRandom:Interval(-math.pi, math.pi)
    local flPhi = tRandom:Interval(-math.pi, math.pi)
    local flRadius = tEmitter.shape == 0 and 0.01 or tEmitter.radius

    if (tEmitter.shape == 1 or tEmitter.shape == 2) and flRadius < FL_TINY then
        flRadius = 1
    end

    local flInner = (1 - tRandom:Range(tEmitter.radiusRandom)) * flRadius
    local flDistance = tRandom:Interval(flInner * flScale, flRadius * flScale)
    local tOffset

    if tEmitter.shape == 1 then
        tOffset = {math.cos(flTheta), math.sin(flTheta), 0}
    else
        tOffset = {math.cos(flTheta), math.cos(flPhi) * math.sin(flTheta), math.sin(flPhi) * math.sin(flTheta)}
    end

    for i = 1, 3 do
        tOffset[i] = tOffset[i] * flDistance
    end

    if not tAttachment.worldDirection then
        tOffset = fnRotate(tAttachment.rotation, tOffset)
    end

    local tPosition = {}

    for i = 1, 3 do
        tPosition[i] = tCenter[i] + tOffset[i]
    end

    return {
        position = tPosition,
        center = {tCenter[1], tCenter[2], tCenter[3]},
        scale = flScale,
        direction = tEmitter.direction == 3 and fnNormalize(tDirection) or nil,
        coneTransform = PARTICLE_SPATIAL.Cone,
        attachment = iIndex
    }

end

-- Birth along a segment between two attachments (shapes 3: either end, 4: from the first, 5:
-- from the second). tSegments are the eligible consecutive pairs, in the game's order.
function PARTICLE_SPATIAL.Segment(tEmitter, tRandom, tSegments)

    if #tSegments == 0 then return nil, "no eligible attachment segment" end

    local iIndex = tRandom:Integer() % #tSegments + 1
    local tPair = tSegments[iIndex]
    local tA, tB = tPair[1], tPair[2]
    local tDelta = {}
    local flLength = 0

    for i = 1, 3 do
        tDelta[i] = tB.position[i] - tA.position[i]
        flLength = flLength + tDelta[i]^2
    end

    flLength = math.sqrt(flLength)

    if flLength <= FL_TINY then
        tDelta = {0, 1, 0}
        flLength = 1
    end

    local tDirection = fnNormalize(tDelta)
    local flAlong = flLength * tRandom:Range(1)
    local tBase = {}

    for i = 1, 3 do
        tBase[i] = tA.position[i] + tDirection[i] * flAlong
    end

    local flTheta = tRandom:Interval(-math.pi, math.pi)
    local flPhi = tRandom:Interval(-math.pi, math.pi)
    local flInner = (1 - tRandom:Range(tEmitter.radiusRandom)) * tEmitter.radius

    -- A Z rotation, then an X rotation (0x1412818f0 / 0x141281850)
    local tOffset = {math.cos(flTheta), math.cos(flPhi) * math.sin(flTheta), math.sin(flPhi) * math.sin(flTheta)}
    local flScale = tA.scale or 1
    local flRadius = tRandom:Interval(flInner * flScale, tEmitter.radius * flScale)
    local tPosition = {}

    for i = 1, 3 do
        tPosition[i] = tBase[i] + tOffset[i] * flRadius
    end

    local tCenter, tExtra

    if tEmitter.shape == 3 then

        tCenter = (tRandom:Integer() % 2 == 1 and tA or tB).position
        tExtra = fnNormalize({tPosition[1] - tCenter[1], tPosition[2] - tCenter[2], tPosition[3] - tCenter[3]})

        if tExtra[1]^2 + tExtra[2]^2 + tExtra[3]^2 <= FL_TINY then
            tExtra = nil
        end

    elseif tEmitter.shape == 4 then

        tCenter = tA.position
        tExtra = tDirection

    elseif tEmitter.shape == 5 then

        tCenter = tB.position
        tExtra = {-tDirection[1], -tDirection[2], -tDirection[3]}

    else
        return nil, "invalid segment shape"
    end

    return {
        position = tPosition,
        center = {tCenter[1], tCenter[2], tCenter[3]},
        direction = tExtra,
        scale = flScale,
        coneTransform = PARTICLE_SPATIAL.Cone,
        attachment = iIndex
    }

end

return PARTICLE_SPATIAL
