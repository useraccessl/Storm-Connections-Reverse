-- The places of an effect's emitters and force fields: the constant coordinates of its
-- animation, its attachment records, the segments between attachments. An animated
-- coordinate is sampled by the caller.

StormFX.Core.SceneSpatial = StormFX.Core.SceneSpatial or {}

local SCENE_SPATIAL = StormFX.Core.SceneSpatial

-- A vector through a 3x3 matrix
local function fnRotate(tMatrix, tVector)

    return {
        tMatrix[1] * tVector[1] + tMatrix[2] * tVector[2] + tMatrix[3] * tVector[3],
        tMatrix[4] * tVector[1] + tMatrix[5] * tVector[2] + tMatrix[6] * tVector[3],
        tMatrix[7] * tVector[1] + tMatrix[8] * tVector[2] + tMatrix[9] * tVector[3]
    }

end

-- tA * tB, 3x3
local function fnMultiply(tA, tB)

    local tOut = {}

    for iRow = 0, 2 do
        for iCol = 1, 3 do
            tOut[iRow * 3 + iCol] = tA[iRow * 3 + 1] * tB[iCol] + tA[iRow * 3 + 2] * tB[3 + iCol] + tA[iRow * 3 + 3] * tB[6 + iCol]
        end
    end

    return tOut

end

-- The 3x3 matrix of a quaternion and a scale
local function fnMatrix(tQuaternion, tScale)

    local flX, flY, flZ, flW = tQuaternion[1], tQuaternion[2], tQuaternion[3], tQuaternion[4]
    local flLength = math.sqrt(flX * flX + flY * flY + flZ * flZ + flW * flW)

    if flLength == 0 then
        return nil, "zero coordinate quaternion"
    end

    flX, flY, flZ, flW = flX / flLength, flY / flLength, flZ / flLength, flW / flLength

    return {
        (1 - 2 * (flY * flY + flZ * flZ)) * tScale[1], 2 * (flX * flY - flW * flZ) * tScale[2], 2 * (flX * flZ + flW * flY) * tScale[3],
        2 * (flX * flY + flW * flZ) * tScale[1], (1 - 2 * (flX * flX + flZ * flZ)) * tScale[2], 2 * (flY * flZ - flW * flX) * tScale[3],
        2 * (flX * flZ - flW * flY) * tScale[1], 2 * (flY * flZ + flW * flX) * tScale[2], (1 - 2 * (flX * flX + flY * flY)) * tScale[3]
    }

end

-- The coordinates of an animation by target name: {position, rotation (3x3)}, through the
-- parent links of its clumps. fnSampleAnimated(curve) samples a curve that is not constant
-- (nil: such a coordinate is refused).
function SCENE_SPATIAL.Coordinates(tAnimation, fnSampleAnimated)

    local tCoordinates = {}

    for _, tEntry in ipairs(tAnimation.entries) do

        if tEntry.type == 1 then

            local tValues = {}

            for _, tCurve in ipairs(tEntry.curves) do

                if tCurve.index < 3 then

                    local tValue = tCurve.values[1]
                    local bConstant = true

                    for j = 2, #tCurve.values do

                        local iStart = (tCurve.format == 10 or tCurve.format == 6 or tCurve.format == 12) and 2 or 1

                        for k = iStart, #tValue do
                            if tValue[k] ~= tCurve.values[j][k] then bConstant = false end
                        end

                    end

                    if not bConstant then

                        if not fnSampleAnimated then
                            return nil, "animated coordinate requires original sampler: " .. tEntry.target
                        end

                        tValue = fnSampleAnimated(tCurve)

                    elseif tCurve.format == 10 or tCurve.format == 6 or tCurve.format == 12 then

                        local tTrimmed = {}

                        for k = 2, #tValue do
                            tTrimmed[#tTrimmed + 1] = tValue[k]
                        end

                        tValue = tTrimmed

                    end

                    tValues[tCurve.index + 1] = tValue

                end

            end

            local tBasis, sWhy = fnMatrix(tValues[2], tValues[3])

            if not tBasis then return nil, sWhy end

            tCoordinates[tEntry.target] = {position = {tValues[1][1], tValues[1][2], tValues[1][3]}, rotation = tBasis}

        end

    end

    -- A parent tuple is the parent's clump and bone, then the child's
    local tParentOf = {}

    for _, tParent in ipairs(tAnimation.parents) do

        local sParent = tAnimation.clumps[tParent[1] + 1].bones[tParent[2] + 1]
        local sChild = tAnimation.clumps[tParent[3] + 1].bones[tParent[4] + 1]

        tParentOf[sChild] = sParent

    end

    local tResolved = {}
    local tVisiting = {}

    local function fnResolve(sName)

        if tResolved[sName] then return tResolved[sName] end
        if tVisiting[sName] then error("cyclic original ANM hierarchy") end

        tVisiting[sName] = true

        local tCoordinate = tCoordinates[sName]

        if tParentOf[sName] then

            local tParentCoordinate = fnResolve(tParentOf[sName])
            local tOffset = fnRotate(tParentCoordinate.rotation, tCoordinate.position)

            tCoordinate = {
                position = {tParentCoordinate.position[1] + tOffset[1], tParentCoordinate.position[2] + tOffset[2], tParentCoordinate.position[3] + tOffset[3]},
                rotation = fnMultiply(tParentCoordinate.rotation, tCoordinate.rotation)
            }

        end

        tVisiting[sName] = nil
        tResolved[sName] = tCoordinate

        return tCoordinate

    end

    for sName in pairs(tCoordinates) do
        fnResolve(sName)
    end

    return tResolved

end

-- The attachments of an emitter. fnExternal(name) gives the coordinate of a node the effect's
-- animation does not carry (a bone of the caster, another object), or nil.
function SCENE_SPATIAL.Attachments(tRecords, tCoordinates, sEmitter, fnExternal)

    local tAttachments = {}

    for _, tRecord in ipairs(tRecords) do

        if tRecord.emitter == sEmitter then

            local tCoordinate = tCoordinates[tRecord.coord] or (fnExternal and fnExternal(tRecord.coord))

            if not tCoordinate then
                return nil, "unresolved coordinate: " .. tRecord.coord
            end

            local tRotation = tCoordinate.rotation

            tAttachments[#tAttachments + 1] = {
                position = tCoordinate.position,
                rotation = tRotation,
                direction = tRecord.direction,
                worldDirection = tRecord.world_direction,
                scale = math.sqrt(tRotation[1]^2 + tRotation[4]^2 + tRotation[7]^2),
                connection = tRecord.original_connection_field or 0
            }

        end

    end

    return tAttachments

end

-- The segments between consecutive attachments (game: 0x1413856b0 counts the nodes whose
-- config +0xc is not 0, 0x1413852f0 returns that field; 0x14131cbf0 has a branch for index
-- zero and falls back to the last two nodes: it does not close a polygon)
function SCENE_SPATIAL.Segments(tAttachments)

    local iCount = #tAttachments

    if iCount < 2 then return {} end

    local iBreaks = 0

    for _, tAttachment in ipairs(tAttachments) do
        if tAttachment.connection ~= 0 then iBreaks = iBreaks + 1 end
    end

    local iSegments = iCount == iBreaks and iCount or iCount - iBreaks
    local tSegments = {{tAttachments[1], tAttachments[2]}}

    for iSelected = 1, iSegments - 1 do

        local iOrdinal = 0
        local iFound = nil

        for i, tAttachment in ipairs(tAttachments) do

            if tAttachment.connection == 0 then

                if iOrdinal == iSelected then
                    iFound = i
                    break
                end

                iOrdinal = iOrdinal + 1

            end

        end

        if iFound and iFound < iCount then
            tSegments[#tSegments + 1] = {tAttachments[iFound], tAttachments[iFound + 1]}
        else
            tSegments[#tSegments + 1] = {tAttachments[iCount - 1], tAttachments[iCount]}
        end

    end

    return tSegments

end

-- The force fields of an emitter: {center, direction (unit), directionLength, config}
function SCENE_SPATIAL.Fields(tRecords, tCoordinates, sEmitter, fnExternal)

    local tFields = {}

    for _, tRecord in ipairs(tRecords) do

        if tRecord.emitter == sEmitter then

            local tCoordinate = tCoordinates[tRecord.coord] or (fnExternal and fnExternal(tRecord.coord))

            if not tCoordinate then
                return nil, "unresolved force coordinate: " .. tRecord.coord
            end

            local tDirection = tRecord.direction

            if not tRecord.world_direction then
                tDirection = fnRotate(tCoordinate.rotation, tDirection)
            end

            local flLength = math.sqrt(tDirection[1]^2 + tDirection[2]^2 + tDirection[3]^2)

            tFields[#tFields + 1] = {
                center = tCoordinate.position,
                direction = flLength > 0 and {tDirection[1] / flLength, tDirection[2] / flLength, tDirection[3] / flLength} or {0, 0, 0},
                directionLength = flLength,
                config = tRecord
            }

        end

    end

    return tFields

end

return SCENE_SPATIAL
