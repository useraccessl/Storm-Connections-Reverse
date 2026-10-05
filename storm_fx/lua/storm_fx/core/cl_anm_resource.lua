-- Animations of the game's files (nuccChunkAnm): compiled once, then evaluated at a clock
-- into coordinate matrices, point lights and material instances. The local clock and the
-- material factory's hold mode are the caller's; where the effect sits in the world is not
-- this module's business.

StormFX.Core.AnmResource = StormFX.Core.AnmResource or {}

local ANM_RESOURCE = StormFX.Core.AnmResource

-- Curve formats with a reader, per entry type (key factory 0x141367040) and, for
-- coordinates, per channel: 0 position, 1 rotation, 2 scale, 3 opacity
local COORDINATE_FORMATS = {
    [0] = {[5] = true, [6] = true, [21] = true, [26] = true},
    {[8] = true, [10] = true, [17] = true, [27] = true},
    {[5] = true, [6] = true, [16] = true, [21] = true, [26] = true},
    {[11] = true, [12] = true, [15] = true, [22] = true, [24] = true, [29] = true}
}
local MATERIAL_FORMATS = {[11] = true, [12] = true, [22] = true, [24] = true}
local LIGHT_FORMATS = {[5] = true, [6] = true, [11] = true, [20] = true, [22] = true}

-- Whether the material factory holds its conditional channels (game: 0x1413904d0)
function ANM_RESOURCE.MaterialHoldFromContext(iUpdateRate, iForceLinearFlag)

    assert(type(iUpdateRate) == "number" and type(iForceLinearFlag) == "number")

    return iUpdateRate == 60 and iForceLinearFlag == 0

end

-- Compile an animation: rest matrices of its coordinates, prepared curves of its entries
function ANM_RESOURCE.Compile(tAnimation, tModules, tOptions)

    local tCompiled = {
        step = tAnimation.frame_step_ticks,
        duration = tAnimation.duration_ticks,
        loop = tAnimation.loop,
        parents = tAnimation.parents or {},
        entries = {},
        modules = tModules,
        options = tOptions,
        rest = {}
    }

    local QUATERNION = assert(tModules.quaternion)
    local fnFloat32 = assert(tOptions.float32)

    -- Rest local matrix of every coordinate the animation lists, by "clump:bone" (game: nuccCoord
    -- constructor 0x1412892a0): what a coordinate keeps when no entry animates it
    for iClump, tClump in ipairs(tAnimation.clumps or {}) do

        for iBone, tRest in ipairs(tClump.rest or {}) do

            if tRest then
                tCompiled.rest[(iClump - 1) .. ":" .. (iBone - 1)] = tModules.matrix.Node({tRest[1], tRest[2], tRest[3]}, {tRest[4], tRest[5], tRest[6]},
                    {tRest[7], tRest[8], tRest[9]}, fnFloat32, tOptions.sinf, tOptions.cosf)
            end

        end

    end

    assert(type(tOptions.materialHold) == "boolean", "The material factory's mode is required")

    tCompiled.ignored = {}

    for _, tEntry in ipairs(tAnimation.entries) do

        local tOut = {
            type = tEntry.type,
            target = tEntry.target,
            clump = tEntry.clump_index,
            bone = tEntry.bone_index,
            curves = {}
        }

        if tEntry.type ~= 1 and tEntry.type ~= 4 and tEntry.type ~= 6 then

            -- Camera (2), directional light (5) and the other entry types met in effect files
            -- move no coordinate and no material: kept in place (entry indices are keys), not
            -- evaluated
            tOut.ignored = true
            tCompiled.ignored[tEntry.type] = (tCompiled.ignored[tEntry.type] or 0) + 1

        else

            for _, tCurve in ipairs(tEntry.curves) do

                local iFormat = tCurve.format

                if tEntry.type == 1 then
                    assert(COORDINATE_FORMATS[tCurve.index] and COORDINATE_FORMATS[tCurve.index][iFormat],
                        "coordinate curve " .. tCurve.index .. " reader not recovered: format " .. iFormat)
                elseif tEntry.type == 4 then
                    assert(MATERIAL_FORMATS[iFormat], "material curve reader not recovered: " .. iFormat)
                else
                    assert(LIGHT_FORMATS[iFormat], "point-light curve reader not recovered: " .. iFormat)
                end

                if iFormat == 17 or iFormat == 27 then

                    tOut.curves[tCurve.index] = QUATERNION.PrepareCompressed(tCurve, fnFloat32)

                elseif iFormat == 10 then

                    tOut.curves[tCurve.index] = QUATERNION.PrepareTimestamp(tCurve, fnFloat32)

                elseif iFormat == 8 then

                    -- A fixed Euler rotation in degrees, built once into a matrix like a node's
                    -- (key constructor case of 0x141367040, 0x14127fea0)
                    assert(#tCurve.values == 1, "Format 8 is a constant rotation")

                    local function fnRadians(flDegrees)
                        return fnFloat32(fnFloat32(flDegrees * fnFloat32(3.1415927410125732)) / 180)
                    end

                    local tValue = tCurve.values[1]

                    tOut.curves[tCurve.index] = {
                        format = 8,
                        matrix = tModules.matrix.Euler(fnRadians(tValue[1]), fnRadians(tValue[2]), fnRadians(tValue[3]), fnFloat32, tOptions.sinf, tOptions.cosf)
                    }

                else
                    tOut.curves[tCurve.index] = tCurve
                end

            end

        end

        tCompiled.entries[#tCompiled.entries + 1] = tOut

    end

    return tCompiled

end

-- Evaluate a compiled animation at iTicks: one item per entry (coordinate channels and
-- rotation basis, point light fields, or the material instance it drives). Wrapping or
-- clamping the clock is the host's.
-- The channels of the coordinates and point lights depend on the clock alone: they are kept
-- by clock value (shared, never written to after), for every particle that plays the same
-- animation and every copy of an effect. Material entries write into their own instance and
-- run every time. At most MAX_KEPT_TICKS clock values an animation; started again when the
-- float rounding mode changes.
local MAX_KEPT_TICKS = 4096

-- false evaluates every time (to compare the cost in game: storm_fx_share 0 / 1)
ANM_RESOURCE.bShare = ANM_RESOURCE.bShare ~= false

local function fnKept(tCompiled, iTicks, fnFloat32)

    if not ANM_RESOURCE.bShare then return {}, false end

    local bRounds = fnFloat32(0.1) ~= 0.1
    local tKept = tCompiled.kept

    if not tKept or tKept.rounds ~= bRounds then
        tKept = {rounds = bRounds, count = 0, ticks = {}}
        tCompiled.kept = tKept
    end

    local tTick = tKept.ticks[iTicks]

    if tTick then return tTick, true end
    if tKept.count >= MAX_KEPT_TICKS then return {}, false end

    tTick = {}
    tKept.ticks[iTicks] = tTick
    tKept.count = tKept.count + 1

    return tTick, false

end

-- The sampler a material entry hands its instance (one per entry, made once: the clock it
-- samples at is set on the entry before each evaluation)
local function fnMaterialSampler(tCompiled, tEntry)

    local tModules, tOptions = tCompiled.modules, tCompiled.options
    local fnFloat32 = tOptions.float32

    return function(iIndex)

        local tCurve = tEntry.curves[iIndex]

        if not tCurve then return nil end

        -- The factory forces linear for channels 12..17 and 22
        local bHold = (iIndex < 12 or (iIndex >= 18 and iIndex <= 21)) and tOptions.materialHold

        return tModules.scalar.Sample(tCurve, tEntry.sampleTicks, tCompiled.step, bHold, fnFloat32)

    end

end

-- tReuse: the result of an earlier evaluation of the same player, refilled in place (its
-- tables are not new: whoever keeps a result keeps it until the next evaluation only)
function ANM_RESOURCE.Evaluate(tCompiled, iTicks, tMaterialInstances, tReuse)

    assert(iTicks >= 0 and iTicks == math.floor(iTicks), "The clock must be an integer number of ticks")

    local tModules, tOptions = tCompiled.modules, tCompiled.options
    local fnFloat32 = tOptions.float32
    local tResult = tReuse or {}
    local tTick, bKept = fnKept(tCompiled, iTicks, fnFloat32)

    for iKey, tEntry in ipairs(tCompiled.entries) do

        local tItem = tResult[iKey]

        if tItem then
            tItem.ignored, tItem.channels, tItem.rotationBasis, tItem.shared, tItem.fields = nil, nil, nil, nil, nil
            tItem.instance, tItem.localMatrix, tItem.worldMatrix = nil, nil, nil
        else
            tItem = {}
        end

        tItem.type, tItem.target, tItem.clump, tItem.bone = tEntry.type, tEntry.target, tEntry.clump, tEntry.bone

        local tShared = bKept and tTick[iKey]

        if tEntry.ignored then

            tItem.ignored = true

        elseif tShared then

            -- Kept from an earlier evaluation at this clock value
            tItem.channels, tItem.rotationBasis = tShared.channels, tShared.rotationBasis
            tItem.shared = tShared

            if tShared.fields then

                local tFields = {}

                for iOffset, flValue in pairs(tShared.fields) do
                    tFields[iOffset] = flValue
                end

                tItem.fields = tFields

            end

        elseif tEntry.type == 1 then

            -- A coordinate
            tItem.channels = {}

            for iIndex, tCurve in pairs(tEntry.curves) do

                if tCurve.format == 10 then
                    tItem.channels[iIndex] = tModules.quaternion.SampleTimestamp(tCurve, iTicks, fnFloat32, tOptions.acosf, tOptions.sinf)
                elseif tCurve.format == 17 or tCurve.format == 27 then
                    tItem.channels[iIndex] = tModules.quaternion.SampleCompressed(tCurve, tCompiled.step, iTicks, fnFloat32, tOptions.acosf, tOptions.sinf)
                elseif tCurve.format == 8 then
                    tItem.channels[iIndex] = {matrix = tCurve.matrix}
                elseif iIndex == 3 then
                    tItem.channels[iIndex] = {tModules.scalar.Sample(tCurve, iTicks, tCompiled.step, false, fnFloat32)}
                else
                    tItem.channels[iIndex] = tModules.scalar.Vector(tCurve, iTicks, tCompiled.step, fnFloat32)
                end

            end

            if tItem.channels[1] and not tItem.channels[1].matrix then
                tItem.rotationBasis = tModules.quaternion.Basis(tItem.channels[1], fnFloat32)
            end

            tItem.shared = {channels = tItem.channels, rotationBasis = tItem.rotationBasis}
            tTick[iKey] = tItem.shared

        elseif tEntry.type == 6 then

            -- A point light: colour, intensity, position, near and far radii
            local tChannels = {}

            for iIndex, tCurve in pairs(tEntry.curves) do

                if tCurve.format == 20 then
                    tChannels[iIndex] = assert(tModules.color).Sample(tCurve, iTicks, tCompiled.step, fnFloat32)
                elseif tCurve.format == 5 or tCurve.format == 6 then
                    tChannels[iIndex] = tModules.scalar.Vector(tCurve, iTicks, tCompiled.step, fnFloat32)
                else
                    tChannels[iIndex] = tModules.scalar.Sample(tCurve, iTicks, tCompiled.step, false, fnFloat32)
                end

            end

            for iIndex = 0, 4 do
                assert(tChannels[iIndex], "The point light needs channel " .. iIndex)
            end

            tItem.channels = tChannels
            tItem.fields = {
                [0x50] = tChannels[0][1], [0x54] = tChannels[0][2], [0x58] = tChannels[0][3], [0x5c] = 1,
                [0x60] = tChannels[1],
                [0x70] = tChannels[2][1], [0x74] = tChannels[2][2], [0x78] = tChannels[2][3],
                [0x88] = tChannels[3], [0x8c] = tChannels[4]
            }

            local tFields = {}

            for iOffset, flValue in pairs(tItem.fields) do
                tFields[iOffset] = flValue
            end

            tTick[iKey] = {channels = tChannels, fields = tFields}

        else

            -- A material instance
            local tInstance = assert(tMaterialInstances[iKey], "The material entry " .. iKey .. " needs its constructor's fields")

            tEntry.sampler = tEntry.sampler or fnMaterialSampler(tCompiled, tEntry)
            tEntry.sampleTicks = iTicks

            tModules.material.EvaluateDirect(tInstance, tEntry.sampler, fnFloat32)

            tItem.instance = tInstance

        end

        tResult[iKey] = tItem

    end

    return tResult

end

-- A player of a compiled animation: it owns its local clock (the host's delta stays outside)
function ANM_RESOURCE.NewPlayer(tCompiled, iTicks, flSpeed)

    local CLOCK = assert(tCompiled.modules.clock, "The clock module is required")

    return {compiled = tCompiled, clock = CLOCK.New(tCompiled.duration, tCompiled.loop, iTicks, flSpeed)}

end

-- Advance a player by iDelta ticks and evaluate it; returns the result, the clock's overflow
-- and the step
function ANM_RESOURCE.Advance(tPlayer, iDelta, tMaterialInstances)

    local tCompiled = tPlayer.compiled
    local iOverflow, iStep = tCompiled.modules.clock.Advance(tPlayer.clock, iDelta, tCompiled.options.float32)

    -- The player's previous result is refilled (see Evaluate)
    tPlayer.result = ANM_RESOURCE.Evaluate(tCompiled, tPlayer.clock.ticks, tMaterialInstances, tPlayer.result)

    return tPlayer.result, iOverflow, iStep

end

-- The world matrix of every coordinate of an evaluated animation. tCoordinateContexts[key]:
-- {parentMatrix, translationScale}. tRootMatrix is the parent of a coordinate that has none;
-- it is needed only when an animated coordinate hangs from one the animation does not animate
-- (that one keeps its rest matrix under its own parent).
function ANM_RESOURCE.CoordinateMatrices(tCompiled, tEvaluated, tCoordinateContexts, tRootMatrix)

    local MATRIX = assert(tCompiled.modules.matrix, "The matrix module is required")
    local fnFloat32 = tCompiled.options.float32

    local function fnId(iClump, iBone)
        return iClump .. ":" .. iBone
    end

    -- The hierarchy and the names of the coordinates, worked out once per animation
    local tParentOf = tCompiled.parentOf

    if not tParentOf then

        tParentOf = {}

        for _, tLink in ipairs(tCompiled.parents) do
            tParentOf[fnId(tLink[3], tLink[4])] = fnId(tLink[1], tLink[2])
        end

        tCompiled.parentOf = tParentOf
        tCompiled.nodeIds = {}

    end

    local tNodeIds = tCompiled.nodeIds

    -- The nodes of this call, in tables kept by the animation (refilled every call: an
    -- animation's matrices are worked out one call after the other)
    local tNodes = tCompiled.scratchNodes

    if tNodes then
        for sName in pairs(tNodes) do
            tNodes[sName] = nil
        end
    else
        tNodes = {}
        tCompiled.scratchNodes = tNodes
    end

    for iKey, tItem in ipairs(tEvaluated) do

        if tItem.type == 1 then

            local tContext = assert(tCoordinateContexts[iKey], "A coordinate has no context")

            -- Kept with the shared channels (tItem.shared), for the last translation scale it
            -- was made with (never written to after)
            local tShared = tItem.shared
            local tLocal = tShared and tShared.scale == tContext.translationScale and tShared.localMatrix

            if not tLocal then

                tLocal = MATRIX.Coordinate(tItem.channels, tContext.translationScale, tCompiled.modules.quaternion, fnFloat32)

                if tShared then
                    tShared.scale, tShared.localMatrix = tContext.translationScale, tLocal
                end

            end

            tItem.localMatrix = tLocal

            local sId = tNodeIds[iKey]

            if not sId then
                sId = fnId(tItem.clump, tItem.bone)
                tNodeIds[iKey] = sId
            end

            -- The item keeps its node table (and its world matrix's) from call to call
            local tNode = tItem.node or {}

            tNode.item, tNode.context = tItem, tContext
            tItem.node = tNode
            tNodes[sId] = tNode

        end

    end

    local tVisiting = {}

    local function fnResolve(sName)

        local tNode = tNodes[sName]

        if not tNode then

            local tRest = tCompiled.rest and tCompiled.rest[sName]
            assert(tRest and tRootMatrix, "Missing animated parent coordinate " .. sName)

            tNode = {item = {localMatrix = tRest}, context = {parentMatrix = tRootMatrix}}
            tNodes[sName] = tNode

        end

        local tItem = tNode.item

        if tItem.worldMatrix then
            return tItem.worldMatrix
        end

        assert(not tVisiting[sName], "Cyclic ANM parent hierarchy")
        tVisiting[sName] = true

        local tParent = tParentOf[sName] and fnResolve(tParentOf[sName]) or assert(tNode.context.parentMatrix, "The root parent is required")

        tItem.worldStore = tItem.worldStore or {}
        tItem.worldMatrix = MATRIX.World(tParent, tItem.localMatrix, fnFloat32, tItem.worldStore)
        tVisiting[sName] = nil

        return tItem.worldMatrix

    end

    -- In entry order, not pairs(tNodes): fnResolve adds rest parents to tNodes, and a table
    -- that grows during pairs() can skip keys (journal R97)
    for iKey, tItem in ipairs(tEvaluated) do

        if tItem.type == 1 then
            fnResolve(tNodeIds[iKey])
        end

    end

    return tEvaluated

end

return ANM_RESOURCE
