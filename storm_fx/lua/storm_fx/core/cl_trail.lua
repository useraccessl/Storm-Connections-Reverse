-- Trails of the game (nuccTrailBase): the samples taken from the two edge coordinates on
-- every update (0x141325090), the ribbon points between them (0x1413248a0) and the vertices
-- the draw sends (0x141325a50). The order of operations and the float32 rounding are the
-- game's; fnFloat32 rounds to float32 (nil: no rounding).
--
-- tDef (storm_import.py trail record): maxSamples, maxSubdivisions, flags, alphaFade,
-- widthFade (bytes / 255 per update), colors {C0, C1, C2} (RGBA), colorSplit, profile
-- {A0, A1, A2} (words / 255), profileSplit (byte / 255), keys (32-bit words: bit 31 emission
-- on, the rest a time in animation ticks).
-- tState: samples (1 = newest; each {edge0 = {x, y, z}, edge1 = {x, y, z}}), points (the
-- ribbon, oldest last), keyIndex, lastFrame, emitting, ending, alpha, widthScale.

StormFX.Core.Trail = StormFX.Core.Trail or {}

local TRAIL = StormFX.Core.Trail

local FL_TINY = 1.1754943508222875e-38      -- FLT_MIN, 0x141860548
local FL_EPSILON = 9.999999974752427e-07    -- normalize threshold, 0x141782190
local FL_BEND, FL_BEND_BASE = 0.949999988079071, 0.05000000074505806

local function fnSame(flValue)
    return flValue
end

-- Round toward zero
local function fnTruncate(flValue)
    return flValue >= 0 and math.floor(flValue) or -math.floor(-flValue)
end

-- tA - tB
local function fnSub(tA, tB, fnFloat32)
    return {fnFloat32(tA[1] - tB[1]), fnFloat32(tA[2] - tB[2]), fnFloat32(tA[3] - tB[3])}
end

-- Length, sqrt((x * x + y * y) + z * z) (game: 0x1411ac850)
local function fnLength(tV, fnFloat32)
    return fnFloat32(math.sqrt(fnFloat32(fnFloat32(fnFloat32(tV[1] * tV[1]) + fnFloat32(tV[2] * tV[2])) + fnFloat32(tV[3] * tV[3]))))
end

-- Unit vector, (1, 0, 0) when the length is not above 1e-6 (game: 0x1411acbb0)
local function fnNormalize(tV, fnFloat32)

    local flLength = fnLength(tV, fnFloat32)

    if not (flLength > FL_EPSILON) then
        return {1, 0, 0}
    end

    local flInverse = fnFloat32(1 / flLength)

    return {fnFloat32(tV[1] * flInverse), fnFloat32(tV[2] * flInverse), fnFloat32(tV[3] * flInverse)}

end

-- flA * flT + (1 - flT) * flB (game: 0x1412cd3c0)
local function fnMix(flA, flB, flT, fnFloat32)
    return fnFloat32(fnFloat32(fnFloat32(1 - flT) * flB) + fnFloat32(flA * flT))
end

-- A new trail (game: constructor 0x141323330: last frame -1, emitting, alpha and width 1)
function TRAIL.New()

    return {
        samples = {},
        points = {},
        keyIndex = 0,
        lastFrame = -1,
        emitting = 1,
        ending = false,
        alpha = 1,
        widthScale = 1
    }

end

-- The samples a trail keeps for the time scale flDt (game: 0x141327140; trail +138, 1 unless
-- the effect is slowed)
function TRAIL.MaxSamples(tDef, flDt, fnFloat32)

    fnFloat32 = fnFloat32 or fnSame

    if flDt > 0 then

        local flRate = fnFloat32(1 / flDt)

        if flRate > 0 then
            return fnTruncate(fnFloat32(tDef.maxSamples * flRate))
        end

    end

    return tDef.maxSamples

end

-- The points per segment at most (game: 0x141327060)
function TRAIL.MaxSubdivisions(tDef, flDt, fnFloat32)

    fnFloat32 = fnFloat32 or fnSame

    if flDt > 0 then

        local iCount = fnTruncate(fnFloat32(tDef.maxSubdivisions * flDt))

        return iCount == 0 and 1 or iCount

    end

    return tDef.maxSubdivisions

end

-- The unit directions and first lengths of the two edges, refilled for every segment curve
local tDirection1 = {{0, 0, 0}, {0, 0, 0}}
local tDirection2 = {{0, 0, 0}, {0, 0, 0}}
local tLength1 = {0, 0}
local tEdgePoint = {{0, 0, 0}, {0, 0, 0}}

-- The curve of one segment: the points between samples tB and tC, before the width is applied,
-- and their edge-to-edge vectors. It depends on the three samples only, which do not change
-- once taken (a force field replaces a moved edge with a new table), and on iMaxSub: it is
-- kept on tB and made again only when one of these changed. A segment is drawn for some twenty
-- updates; the width, which changes, is applied by Subdivide on every one.
-- tSegment.points: per point (newest first) p1 x y z, p2 x y z, p1 - p2 x y z.
local function fnSegment(tA, tB, tC, iMaxSub, f)

    local tSegment = tB.segment

    if tSegment and tSegment.a1 == tA[1] and tSegment.a2 == tA[2] and tSegment.b1 == tB[1] and tSegment.b2 == tB[2]
        and tSegment.c1 == tC[1] and tSegment.c2 == tC[2] and tSegment.maxSub == iMaxSub and tSegment.f == f then
        return tSegment
    end

    tSegment = tSegment or {points = {}}
    tSegment.a1, tSegment.a2, tSegment.b1, tSegment.b2, tSegment.c1, tSegment.c2 = tA[1], tA[2], tB[1], tB[2], tC[1], tC[2]
    tSegment.maxSub, tSegment.f, tSegment.count = iMaxSub, f, 0
    tB.segment = tSegment

    local flSum = 0

    for iEdge = 1, 2 do

        local tPointA, tPointB, tPointC = tA[iEdge], tB[iEdge], tC[iEdge]
        local ux, uy, uz = f(tPointA[1] - tPointB[1]), f(tPointA[2] - tPointB[2]), f(tPointA[3] - tPointB[3])
        local vx, vy, vz = f(tPointB[1] - tPointC[1]), f(tPointB[2] - tPointC[2]), f(tPointB[3] - tPointC[3])
        local flA = f(math.sqrt(f(f(f(ux * ux) + f(uy * uy)) + f(uz * uz))))
        local flB = f(math.sqrt(f(f(f(vx * vx) + f(vy * vy)) + f(vz * vz))))

        if not (flA > FL_TINY and flB > FL_TINY) then
            return tSegment
        end

        local flInverseA, flInverseB = f(1 / flA), f(1 / flB)

        ux, uy, uz = f(ux * flInverseA), f(uy * flInverseA), f(uz * flInverseA)
        vx, vy, vz = f(vx * flInverseB), f(vy * flInverseB), f(vz * flInverseB)

        local flDot = f(f(f(vy * uy) + f(vx * ux)) + f(vz * uz))
        flSum = f(flSum + f(f(math.abs(f(flDot - 1)) * FL_BEND) + FL_BEND_BASE))

        local tU, tV = tDirection1[iEdge], tDirection2[iEdge]
        tU[1], tU[2], tU[3] = ux, uy, uz
        tV[1], tV[2], tV[3] = vx, vy, vz
        tLength1[iEdge] = flA

    end

    local iCount = 1 - fnTruncate(f(flSum * -64))

    if iCount < iMaxSub then
        iMaxSub = iCount
    end

    iCount = iMaxSub

    if iCount < 1 then
        return tSegment
    end

    local flHalf = f(f(iCount) + 0.5)
    local tPoints = tSegment.points
    local iRemaining = iCount
    local iAt = 0

    for _ = iCount - 1, 0, -1 do

        local flT = f(iRemaining / flHalf)
        local flWeight = f(f(flT * 0.5) + 0.5)
        local flOther = f(1 - flWeight)

        for iEdge = 1, 2 do

            local tD1, tD2 = tDirection1[iEdge], tDirection2[iEdge]

            -- The blended direction, normalized as fnNormalize does
            local dx = f(f(flWeight * tD1[1]) + f(flOther * tD2[1]))
            local dy = f(f(flWeight * tD1[2]) + f(flOther * tD2[2]))
            local dz = f(f(flWeight * tD1[3]) + f(flOther * tD2[3]))
            local flLength = f(math.sqrt(f(f(f(dx * dx) + f(dy * dy)) + f(dz * dz))))

            if not (flLength > FL_EPSILON) then
                dx, dy, dz = 1, 0, 0
            else
                local flInverse = f(1 / flLength)
                dx, dy, dz = f(dx * flInverse), f(dy * flInverse), f(dz * flInverse)
            end

            local flScale = f(tLength1[iEdge] * flT)
            local tBase = tB[iEdge]
            local tPoint = tEdgePoint[iEdge]

            tPoint[1], tPoint[2], tPoint[3] = f(f(dx * flScale) + tBase[1]), f(f(dy * flScale) + tBase[2]), f(f(dz * flScale) + tBase[3])

        end

        local tPoint1, tPoint2 = tEdgePoint[1], tEdgePoint[2]

        tPoints[iAt + 1], tPoints[iAt + 2], tPoints[iAt + 3] = tPoint1[1], tPoint1[2], tPoint1[3]
        tPoints[iAt + 4], tPoints[iAt + 5], tPoints[iAt + 6] = tPoint2[1], tPoint2[2], tPoint2[3]
        tPoints[iAt + 7], tPoints[iAt + 8], tPoints[iAt + 9] = f(tPoint1[1] - tPoint2[1]), f(tPoint1[2] - tPoint2[2]), f(tPoint1[3] - tPoint2[3])

        iAt = iAt + 9
        iRemaining = iRemaining - 1

    end

    tSegment.count = iCount

    return tSegment

end

-- The ribbon points between samples i + 1 and i + 2 (0-based i: samples i, i + 1, i + 2 of the
-- newest-first list), appended to tOut, newest first (game: 0x1413248a0). Nothing when one of
-- the four sample-to-sample steps has no length.
function TRAIL.Subdivide(tSamples, i, iMaxSub, flStartWidth, flEndWidth, flWidthScale, fnFloat32, tOut)

    local f = fnFloat32 or fnSame
    local tSegment = fnSegment(tSamples[i + 1], tSamples[i + 2], tSamples[i + 3], iMaxSub, f)
    local iCount = tSegment.count

    if iCount < 1 then
        return tOut
    end

    local flStep = f(1 / f(iCount))
    local tPoints = tSegment.points
    local iAt = 0

    for j = iCount - 1, 0, -1 do

        local p1x, p1y, p1z = tPoints[iAt + 1], tPoints[iAt + 2], tPoints[iAt + 3]
        local p2x, p2y, p2z = tPoints[iAt + 4], tPoints[iAt + 5], tPoints[iAt + 6]
        local ex, ey, ez = tPoints[iAt + 7], tPoints[iAt + 8], tPoints[iAt + 9]
        local flWidthT = math.min(1, f(f(f(j) + 0.5) * flStep))
        local flWidth = fnMix(flStartWidth, flEndWidth, flWidthT, f)
        local flK = f(1 - flWidth)
        local ox, oy, oz = f(f(ex * flK) * 0.5), f(f(ey * flK) * 0.5), f(f(ez * flK) * 0.5)

        if flWidthScale ~= 1 then

            local flG = f(f(f(1 - flWidthScale) * flWidth) * 0.5)

            ox, oy, oz = f(ox + f(ex * flG)), f(oy + f(ey * flG)), f(oz + f(ez * flG))

        end

        tOut[#tOut + 1] = {
            {f(p1x - ox), f(p1y - oy), f(p1z - oz)},
            {f(p2x + ox), f(p2y + oy), f(p2z + oz)}
        }

        iAt = iAt + 9

    end

    return tOut

end

-- The widths at the two ends of segment i of iCount (game: in 0x141325090): the profile
-- A0 -> A1 -> A2 along the trail, split at profileSplit
function TRAIL.Widths(tDef, i, iCount, fnFloat32)

    local f = fnFloat32 or fnSame
    local flSplit = f(tDef.profileSplit / 255)
    local flA0, flA1, flA2 = f(tDef.profile[1] / 255), f(tDef.profile[2] / 255), f(tDef.profile[3] / 255)
    local flTA = f(f(i) / f(iCount))
    local flTB = math.min(1, f(f(i + 1) / f(iCount)))
    local flWidthA, flWidthB

    if flSplit == 0 then

        flWidthA = fnMix(flA1, flA2, f(1 - flTA), f)
        flWidthB = fnMix(flA1, flA2, f(1 - flTB), f)

    elseif flSplit >= flTA then

        flWidthA = fnMix(flA0, flA1, f(1 - f(flTA / flSplit)), f)

        if flSplit >= flTB then
            flWidthB = fnMix(flA0, flA1, f(1 - f(flTB / flSplit)), f)
        else
            flWidthB = fnMix(flA1, flA2, f(1 - f(f(flTB - flSplit) / f(1 - flSplit))), f)
        end

    else

        flWidthA = fnMix(flA1, flA2, f(1 - math.min(1, f(f(flTA - flSplit) / f(1 - flSplit)))), f)
        flWidthB = fnMix(flA1, flA2, f(1 - math.min(1, f(f(flTB - flSplit) / f(1 - flSplit)))), f)

    end

    return flWidthA, flWidthB

end

-- A direction through the rotation rows of a matrix (game: 0x1411efdf0), each row summed as
-- ((m0 x + m2 z) + m1 y)
local function fnRotate(tMatrix, tV, fnFloat32)

    local tOut = {}

    for iRow = 0, 2 do

        local flA0, flA1, flA2 = fnFloat32(tMatrix[4 * iRow + 1] * tV[1]), fnFloat32(tMatrix[4 * iRow + 2] * tV[2]), fnFloat32(tMatrix[4 * iRow + 3] * tV[3])

        tOut[iRow + 1] = fnFloat32(fnFloat32(flA0 + flA2) + flA1)

    end

    return tOut

end

-- SSE minss / maxss: the second operand when the comparison fails (NaN included)
local function fnMinss(flA, flB)
    if flA < flB then return flA end
    return flB
end

local function fnMaxss(flA, flB)
    if flA > flB then return flA end
    return flB
end

-- One force field acting on the samples (nuccTrailForceField vtable +10 = 0x14132c830).
-- tField (table-3 record from +0x10 of the file record): direction, decay, kind (only 1
-- acts), radius (x 100), strength, flags (1: half strength everywhere, 2: falling to the
-- edge, 4: rising to the edge, 0x10: direction in world space). tMatrix: the world matrix of
-- the field's coordinate, or nil (the field then sits at the origin, axis-aligned).
-- Inside the radius a sample edge is pushed by direction * strength * falloff, which becomes
-- its velocity, and the sample takes the field's decay; outside, an edge with a velocity keeps
-- moving: velocity += velocity * decay, position += velocity.
function TRAIL.ApplyField(tField, tMatrix, tSamples, fnFloat32)

    local f = fnFloat32 or fnSame

    if #tSamples == 0 then return end

    local tFieldDirection = tField.direction
    local tDirection = {0, 0, 1}

    if fnLength(tFieldDirection, f) > FL_TINY then
        tDirection = fnNormalize(tFieldDirection, f)
    end

    local tCenter = {0, 0, 0}
    local tM = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}

    if tMatrix then
        tM = tMatrix
        tCenter = {tMatrix[4], tMatrix[8], tMatrix[12]}
    end

    local iFlags = tField.flags

    if math.floor(iFlags / 16) % 2 == 1 then
        tM = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    end

    local tWorld = fnRotate(tM, tDirection, f)

    if f(f(f(tWorld[1] * tWorld[1]) + f(tWorld[2] * tWorld[2])) + f(tWorld[3] * tWorld[3])) > 0 then
        tWorld = fnNormalize(tWorld, f)
    end

    local flStrength = tField.strength
    local tForce = {f(tWorld[1] * flStrength), f(tWorld[2] * flStrength), f(tWorld[3] * flStrength)}
    local flRadius = f(tField.radius * 100)

    if tField.kind ~= 1 then return end

    for _, tSample in ipairs(tSamples) do

        for iEdge = 1, 2 do

            local tPoint = tSample[iEdge]
            local flDistance = fnLength(fnSub(tPoint, tCenter, f), f)
            local flK

            if iFlags % 2 == 1 then

                flK = 0.5

            elseif math.floor(iFlags / 2) % 2 == 1 then

                if flRadius > 0 then flK = f(1 - math.abs(f(flDistance / flRadius))) else flK = 0 end

            elseif math.floor(iFlags / 4) % 2 == 1 then

                if flRadius > 0 then flK = f(1 - f(1 - math.abs(f(flDistance / flRadius)))) else flK = 1 end

            else
                flK = 0.5
            end

            flK = fnMaxss(0, fnMinss(1, flK))

            if flDistance > FL_TINY and flRadius > flDistance then

                local tDelta = {f(tForce[1] * flK), f(tForce[2] * flK), f(tForce[3] * flK)}

                tSample[iEdge] = {f(tPoint[1] + tDelta[1]), f(tPoint[2] + tDelta[2]), f(tPoint[3] + tDelta[3])}
                tSample.velocity[iEdge] = tDelta
                tSample.decay = tField.decay

            else

                local tVelocity = tSample.velocity[iEdge]

                if f(f(f(tVelocity[1] * tVelocity[1]) + f(tVelocity[2] * tVelocity[2])) + f(tVelocity[3] * tVelocity[3])) > FL_TINY and math.abs(tSample.decay) > FL_TINY then

                    local flDecay = tSample.decay

                    tVelocity = {f(tVelocity[1] + f(flDecay * tVelocity[1])), f(tVelocity[2] + f(flDecay * tVelocity[2])), f(tVelocity[3] + f(flDecay * tVelocity[3]))}
                    tSample.velocity[iEdge] = tVelocity
                    tSample[iEdge] = {f(tPoint[1] + tVelocity[1]), f(tPoint[2] + tVelocity[2]), f(tPoint[3] + tVelocity[3])}

                end

            end

        end

    end

end

-- One update (game: 0x141325090). iFrame: the animation's time in ticks (-1: no time);
-- tEdge0 / tEdge1: world positions of the two edge coordinates; flDt: the time scale.
-- tFields: the trail's force fields in table-3 order, {field, matrix} each (ApplyField); they
-- act on the kept samples before the new one is taken, unless the trail is ending.
function TRAIL.Update(tState, tDef, iFrame, tEdge0, tEdge1, flDt, fnFloat32, tFields)

    local f = fnFloat32 or fnSame

    if iFrame == -1 then

        tState.emitting = 0

        if not tState.ending then return end

    elseif iFrame ~= tState.lastFrame then

        if iFrame < tState.lastFrame then
            tState.keyIndex = 0
        end

        tState.lastFrame = iFrame

        local iKey = tDef.keys and tDef.keys[tState.keyIndex + 1]

        if iKey then

            local iAt = iKey % 2147483648

            if iAt <= iFrame then

                if iKey >= 2147483648 then

                    tState.emitting = 1

                    if not tState.ending then
                        tState.alpha, tState.widthScale = 1, 1
                    end

                else
                    tState.emitting = 0
                end

                tState.keyIndex = tState.keyIndex + 1

            end

        end

    end

    local tSamples = tState.samples

    if not tState.ending then

        for _, tField in ipairs(tFields or {}) do
            TRAIL.ApplyField(tField.field, tField.matrix, tSamples, f)
        end

        -- A new sample (0x1413235b0) has no velocity and no decay
        table.insert(tSamples, 1, {
            {tEdge0[1], tEdge0[2], tEdge0[3]},
            {tEdge1[1], tEdge1[2], tEdge1[3]},
            velocity = {{0, 0, 0}, {0, 0, 0}},
            decay = 0
        })

    end

    if tState.ending or tState.emitting == 0 then

        if tDef.flags % 2 == 1 and #tSamples > 0 then
            tState.alpha = f(tState.alpha - f(tDef.alphaFade / 255))
            if not (tState.alpha > 0) then tState.alpha = 0 end
        end

        if math.floor(tDef.flags / 2) % 2 == 1 then
            tState.widthScale = f(tState.widthScale - f(tDef.widthFade / 255))
            if not (tState.widthScale > 0) then tState.widthScale = 0 end
        end

    end

    -- The ribbon points, from the samples before this update's trimming
    local tPoints = {}
    local iSegments = #tSamples - 2
    local iLimit = TRAIL.MaxSamples(tDef, flDt, f)
    local iMaxSub = TRAIL.MaxSubdivisions(tDef, flDt, f)

    -- A host may cap the points per segment (tState.maxSubdivisions; the game: none)
    if tState.maxSubdivisions and iMaxSub > tState.maxSubdivisions then
        iMaxSub = tState.maxSubdivisions
    end

    -- A trail nobody sees (tState.hidden, set by the host) keeps its samples but makes no
    -- points: they are only drawn
    if not tState.hidden then
        for i = 0, math.min(iLimit, iSegments) - 1 do
            local flWidthA, flWidthB = TRAIL.Widths(tDef, i, iSegments, f)
            TRAIL.Subdivide(tSamples, i, iMaxSub, flWidthA, flWidthB, tState.widthScale, f, tPoints)
        end
    end

    if tState.ending then

        if #tSamples > 0 then
            table.remove(tSamples)
        end

    elseif tState.emitting == 0 then

        for _ = 1, 2 do
            if #tSamples >= 2 then table.remove(tSamples) end
        end

    end

    while #tSamples > iLimit do
        table.remove(tSamples)
    end

    while #tPoints >= iMaxSub * iLimit and #tPoints > 0 do
        table.remove(tPoints)
    end

    tState.points = tPoints

end

-- The distance along each edge to every point, refilled by every Vertices
local tCumulated = {{0}, {0}}

-- The vertices of the ribbon (game: 0x141325a50): two per point (edge 0, edge 1), each
-- {position, color RGBA, u, v}. tRect: the trail billboard's UV values {uv0 offset u, v, uv0
-- scale u, v, uv1 offset u, v, uv1 scale u, v} (billboard +2C8.. +2E0), or nil.
-- The vertex tables belong to the trail (tState.vertices) and are refilled by the next call.
function TRAIL.Vertices(tState, tDef, tRect, fnFloat32)

    local f = fnFloat32 or fnSame
    local tPoints = tState.points
    local iCount = #tPoints

    if iCount <= 1 then return {} end

    local tTotal1, tTotal2 = 0, 0
    local tCumulated1, tCumulated2 = tCumulated[1], tCumulated[2]

    for k = 2, iCount do

        local tPrevious, tPoint = tPoints[k - 1], tPoints[k]

        for iEdge = 1, 2 do

            local tA, tB = tPrevious[iEdge], tPoint[iEdge]
            local x, y, z = f(tA[1] - tB[1]), f(tA[2] - tB[2]), f(tA[3] - tB[3])
            local flSegment = f(math.sqrt(f(f(f(x * x) + f(y * y)) + f(z * z))))

            if iEdge == 1 then
                tTotal1 = f(tTotal1 + flSegment)
                tCumulated1[k] = f(tCumulated1[k - 1] + flSegment)
            else
                tTotal2 = f(tTotal2 + flSegment)
                tCumulated2[k] = f(tCumulated2[k - 1] + flSegment)
            end

        end

    end

    local tTotal = {tTotal1, tTotal2}

    -- Without a billboard every UV value is 0 and the u span 1
    local flU0, flDU, flV0, flSpanV, flScaleV = 0, 1, 0, 0, 0

    if tRect then
        flU0, flV0 = tRect[1], tRect[2]
        flDU = f(f(tRect[7] - tRect[5]) * tRect[3])
        flSpanV, flScaleV = f(tRect[8] - tRect[6]), tRect[4]
    end

    local tC0, tC1, tC2 = tDef.colors[1], tDef.colors[2], tDef.colors[3]
    local flSplit = tDef.colorSplit
    local tVertices = tState.vertices or {}
    local iVertex = 0

    tState.vertices = tVertices

    for k = 1, iCount do

        for iEdge = 1, 2 do

            local flTotal = tTotal[iEdge]
            local flCumulated = tCumulated[iEdge][k]
            local flV = f(f(f(f(flCumulated / flTotal) * flSpanV) * flScaleV) + flV0)
            local flT = flTotal == 0 and 0 or f(flCumulated / flTotal)
            local tA, tB, flS

            if flSplit == 0 then
                tA, tB, flS = tC1, tC2, flT
            elseif flSplit > flT then
                tA, tB, flS = tC0, tC1, f(flT / flSplit)
            else
                tA, tB, flS = tC1, tC2, f(f(flT - flSplit) / f(1 - flSplit))
            end

            local flWeight = f(1 - flS)
            local flOther = f(1 - flWeight)

            iVertex = iVertex + 1

            local tVertex = tVertices[iVertex]

            if not tVertex then
                tVertex = {position = {0, 0, 0}, color = {0, 0, 0, 0}}
                tVertices[iVertex] = tVertex
            end

            local tColor = tVertex.color

            for c = 1, 4 do
                tColor[c] = f(f(flWeight * tA[c]) + f(flOther * tB[c]))
            end

            tColor[4] = f(tState.alpha * tColor[4])

            local tPoint, tPosition = tPoints[k][iEdge], tVertex.position

            tPosition[1], tPosition[2], tPosition[3] = tPoint[1], tPoint[2], tPoint[3]
            tVertex.u = iEdge == 1 and f(flDU + flU0) or flU0
            tVertex.v = flV

        end

    end

    for i = iVertex + 1, #tVertices do
        tVertices[i] = nil
    end

    return tVertices

end

return TRAIL
