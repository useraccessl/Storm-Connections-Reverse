-- Curves of a particle over its life (size, colour, fade), the frames of a billboard, and
-- the plain readers of decoded animation curves.

StormFX.Core.Curves = StormFX.Core.Curves or {}

local CURVES = StormFX.Core.Curves

-- tA + (tB - tA) * flT, component by component, into tOut (or a new table)
local function fnLerp(tA, tB, flT, tOut)

    tOut = tOut or {}

    for i = 1, #tA do
        tOut[i] = tA[i] + (tB[i] - tA[i]) * flT
    end

    return tOut

end

-- A copy of a key into tOut, or the key itself when there is no tOut
local function fnKey(tKey, tOut)

    if not tOut then return tKey end

    for i = 1, #tKey do
        tOut[i] = tKey[i]
    end

    return tOut

end

-- A three-key curve (start, middle, end) with the middle key at flSplit, at flT in 0..1.
-- tOut: a table to write the value into, or nil (the value may then be one of the keys)
function CURVES.Curve(tStart, tMiddle, tEnd, flSplit, flT, bSize, tOut)

    flT = math.max(0, math.min(1, flT))

    if bSize and flSplit == 0 then return fnKey(tStart, tOut) end

    if flSplit > 0 and flT < flSplit then
        return fnLerp(tStart, tMiddle, flT / flSplit, tOut)
    end

    if flSplit == 1 then return fnKey(tMiddle, tOut) end

    return fnLerp(tMiddle, tEnd, (flT - flSplit) / (1 - flSplit), tOut)

end

-- The size curve's value, read at once by Sample
local tSizeCurve = {}

-- Size, colour and alpha of a particle of an emitter at flAge (closed form; the engine fades
-- with FadeInit / FadeStep, as the game does). tSizeOut / tColorOut: tables to write the size
-- and the colour into, or nil for new ones.
function CURVES.Sample(tEmitter, flLife, flAge, tRandom, tSizeOut, tColorOut)

    local flT = math.min(1, flAge * tEmitter.simulationHz / flLife)
    local tSize = CURVES.Curve(tEmitter.sizeStart, tEmitter.sizeMiddle, tEmitter.sizeEnd, tEmitter.sizeSplit, flT, true, tSizeCurve)
    local tScaled = tSizeOut or {}

    for i = 1, 3 do
        tScaled[i] = tSize[i] * (1 + (tRandom[i] or 0) * tEmitter.sizeRandom[i])
    end

    local tColor = CURVES.Curve(tEmitter.colorStart, tEmitter.colorMiddle, tEmitter.colorEnd, tEmitter.colorSplit, flT, false, tColorOut)
    local flFade = 1

    if tEmitter.fadeIn > 0 then
        flFade = math.min(flFade, flT / tEmitter.fadeIn)
    end

    local flFadeStart = (flLife - math.floor(flLife * tEmitter.fadeOut)) / flLife

    if tEmitter.fadeOut > 0 and flT > flFadeStart then
        flFade = math.min(flFade, 1 - (flT - flFadeStart) / tEmitter.fadeOut)
    end

    return tScaled, tColor, math.max(0, flFade) * tColor[4]

end

-- The fade of a particle as the game runs it (game: initialiser 0x14130c350, state machine
-- 0x14130b3a3..0x14130b436, state at particle +184, value at +68). It lags the closed form
-- by one update at each end: the update that finds age > start only switches to fading out.
function CURVES.FadeInit(flLife, flFadeIn, flFadeOut)

    local tFade = {rateIn = 0, rateOut = 0, value = 0, mode = 0}

    if flLife * flFadeIn ~= 0 then
        tFade.rateIn = 1 / (flLife * flFadeIn)
    end

    local flSpan = flLife * flFadeOut

    if flSpan ~= 0 then
        tFade.rateOut = 1 / flSpan
    end

    tFade.start = flLife - (flSpan >= 0 and math.floor(flSpan) or math.ceil(flSpan))

    -- Without a fade-in the particle starts opaque, unless it would fade out at once
    if flFadeIn == 0 and tFade.start ~= 0 then
        tFade.value = 1
        tFade.mode = 1
    end

    return tFade

end

-- One update of the fade: flAge is the particle's age after this update, flStep the increment
function CURVES.FadeStep(tFade, flAge, flStep)

    if tFade.mode == 0 then

        tFade.value = tFade.value + flStep * tFade.rateIn

        if tFade.value >= 1 then
            tFade.value = 1
            tFade.mode = 1
        end

    elseif tFade.mode == 1 then

        if flAge > tFade.start then
            tFade.mode = 2
        end

    elseif tFade.mode == 2 then

        tFade.value = tFade.value - flStep * tFade.rateOut

        if tFade.value <= 0 then
            tFade.value = 0
            tFade.mode = 3
        end

    end

    return tFade.value

end

-- The billboard keys at flAge seconds (wall clock; the engine uses BillboardFromParticle)
function CURVES.Billboard(tBillboard, flAge)

    local iTick = math.floor(flAge * 3000)
    local iDuration = tBillboard.count * tBillboard.stepTicks

    if tBillboard.loop then
        iTick = iTick % iDuration
    end

    local iIndex = math.min(tBillboard.count, math.floor(iTick / tBillboard.stepTicks) + 1)
    local tKeys = {}

    for iChannel, tChannelKeys in pairs(tBillboard.channels) do
        tKeys[iChannel] = tChannelKeys[math.min(iIndex, #tChannelKeys)]
    end

    return tKeys, iIndex

end

-- The billboard keys of a particle after iAgeTicks updates. The particle renderer
-- (0x14130b4a0) advances the billboard once per whole simulation step, by 50 clock ticks
-- (0x1412c7d48), and copies the channels at the old clock first (0x1412c7b00): the last
-- update shows (whole - 1) * 50. tKeys: a table to fill (emptied first), or nil for a new one.
function CURVES.BillboardFromParticle(tBillboard, iAgeTicks, tKeys)

    local iTicks = math.max(0, math.floor(iAgeTicks) - 1) * 50
    local iDuration = tBillboard.count * tBillboard.stepTicks

    if tBillboard.loop then
        iTicks = iTicks % iDuration
    end

    local iIndex = math.min(tBillboard.count, math.floor(iTicks / tBillboard.stepTicks) + 1)

    if tKeys then
        for iChannel in pairs(tKeys) do
            tKeys[iChannel] = nil
        end
    else
        tKeys = {}
    end

    for iChannel, tChannelKeys in pairs(tBillboard.channels) do
        tKeys[iChannel] = tChannelKeys[math.min(iIndex, #tChannelKeys)]
    end

    return tKeys, iIndex, iTicks

end

-- Birth times of an emitter's particles over flSeconds at iFps (closed form)
function CURVES.Births(tEmitter, flSeconds, iFps)

    local bActive = false
    local flAccumulator = 0
    local tBirths = {}
    local iEventIndex = 1

    for iFrame = 0, math.floor(flSeconds * iFps) do

        local flTime = iFrame / iFps

        while tEmitter.events[iEventIndex] and tEmitter.events[iEventIndex].clock_threshold_ms <= math.floor(flTime * 1000) do
            bActive = tEmitter.events[iEventIndex].action == "start_emission"
            iEventIndex = iEventIndex + 1
        end

        if bActive then

            local iCount

            if tEmitter.direct then

                iCount = math.floor(tEmitter.quantity)
                bActive = false

            else

                flAccumulator = flAccumulator + tEmitter.quantity / iFps
                iCount = math.floor(flAccumulator + 1e-12)
                flAccumulator = flAccumulator - iCount

            end

            for _ = 1, iCount do
                tBirths[#tBirths + 1] = flTime
            end

        end

    end

    return tBirths

end

-- A decoded animation curve at iTicks (plain doubles; quaternions renormalised)
function CURVES.Animation(tCurve, iStep, iTicks)

    local tValues = tCurve.values

    if #tValues == 1 then return tValues[1] end

    local bTimestamped = tCurve.format == 6 or tCurve.format == 10 or tCurve.format == 12
    local iIndex = 1

    if bTimestamped then

        while iIndex < #tValues and tValues[iIndex + 1][1] <= iTicks do
            iIndex = iIndex + 1
        end

    else
        iIndex = math.min(#tValues, math.floor(iTicks / iStep) + 1)
    end

    local tA, tB = tValues[iIndex], tValues[math.min(iIndex + 1, #tValues)]
    local iTicksA = bTimestamped and tA[1] or (iIndex - 1) * iStep
    local iTicksB = bTimestamped and tB[1] or iIndex * iStep
    local flT = iTicksB > iTicksA and math.max(0, math.min(1, (iTicks - iTicksA) / (iTicksB - iTicksA))) or 0

    if tCurve.format == 26 or tCurve.format == 27 then
        flT = 0
    end

    local iStart = bTimestamped and 2 or 1
    local tOut = {}

    for i = iStart, #tA do
        tOut[#tOut + 1] = tA[i] + (tB[i] - tA[i]) * flT
    end

    if tCurve.format == 17 or tCurve.format == 27 then

        local flLength = 0

        for i = 1, 4 do
            flLength = flLength + tOut[i]^2
        end

        flLength = math.sqrt(flLength)

        for i = 1, 4 do
            tOut[i] = tOut[i] / flLength
        end

    end

    return tOut

end

return CURVES
