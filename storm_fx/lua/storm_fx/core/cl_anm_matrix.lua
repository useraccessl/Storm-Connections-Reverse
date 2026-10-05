-- 4x4 matrices as the game computes them: products, column scales, the local matrix of an
-- animated coordinate and of a scene node. Matrices are row-major tables of 16 numbers, the
-- translation in elements 4, 8 and 12. Every operation is rounded with fnFloat32.

StormFX.Core.AnmMatrix = StormFX.Core.AnmMatrix or {}

local ANM_MATRIX = StormFX.Core.AnmMatrix

-- tA * tB, with the game's grouping of the sums (rows 0 and 2 add the halves the other way).
-- tOut: a table to fill (neither tA nor tB), else a new one.
function ANM_MATRIX.Multiply(tA, tB, fnFloat32, tOut)

    tOut = tOut or {}

    for iRow = 0, 3 do

        for iCol = 1, 4 do

            local flP0 = fnFloat32(tA[iRow * 4 + 1] * tB[iCol])
            local flP1 = fnFloat32(tA[iRow * 4 + 2] * tB[4 + iCol])
            local flP2 = fnFloat32(tA[iRow * 4 + 3] * tB[8 + iCol])
            local flP3 = fnFloat32(tA[iRow * 4 + 4] * tB[12 + iCol])
            local flLow, flHigh = fnFloat32(flP0 + flP1), fnFloat32(flP2 + flP3)

            tOut[iRow * 4 + iCol] = (iRow == 0 or iRow == 2) and fnFloat32(flHigh + flLow) or fnFloat32(flLow + flHigh)

        end

    end

    return tOut

end

-- Scale columns 0..2, the translation unchanged (game: 0x141281e90). tOut: a table to fill
-- (not tA), else a new one.
function ANM_MATRIX.ScaleColumns(tA, tScale, fnFloat32, tOut)

    tOut = tOut or {}

    for iRow = 0, 3 do

        for iCol = 1, 3 do
            tOut[iRow * 4 + iCol] = fnFloat32(tA[iRow * 4 + iCol] * tScale[iCol])
        end

        tOut[iRow * 4 + 4] = tA[iRow * 4 + 4]

    end

    return tOut

end

-- The identity (game: initialiser 0x1400a4ad0)
function ANM_MATRIX.Identity(tOut)
    if not tOut then return {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1} end
    for i = 1, 16 do
        tOut[i] = (i == 1 or i == 6 or i == 11 or i == 16) and 1 or 0
    end
    return tOut
end

-- Local matrix of an animated coordinate (game: controller 0x1413679d0): translation, then
-- rotation, then column scale. tChannels[0] position, [1] rotation, [2] scale.
-- tTranslationScale is the target's +FC / +100 / +104.
function ANM_MATRIX.Coordinate(tChannels, tTranslationScale, tQuaternion, fnFloat32)

    assert(tTranslationScale, "The target's translation scale is required")

    local tLocal = ANM_MATRIX.Identity()

    if tChannels[0] then

        for i = 1, 3 do
            tLocal[i * 4] = fnFloat32(tChannels[0][i] * tTranslationScale[i])
        end

    end

    if tChannels[1] then

        -- A rotation key hands the controller a matrix: built from a quaternion, or kept
        -- from a fixed Euler key
        local tRotation = tChannels[1].matrix

        if not tRotation then

            local tBasis = tQuaternion.Basis(tChannels[1], fnFloat32)
            tRotation = ANM_MATRIX.Identity()

            for iRow = 0, 2 do
                for iCol = 1, 3 do
                    tRotation[iRow * 4 + iCol] = tBasis[iRow * 3 + iCol]
                end
            end

        end

        tLocal = ANM_MATRIX.Multiply(tLocal, tRotation, fnFloat32)

    end

    if tChannels[2] then
        tLocal = ANM_MATRIX.ScaleColumns(tLocal, tChannels[2], fnFloat32)
    end

    return tLocal

end

-- Euler rotation Rx * Ry * Rz, angles in radians (game: 0x1411e9bd0, same order of operations)
function ANM_MATRIX.Euler(flX, flY, flZ, fnFloat32, fnSin, fnCos)

    local flCosX, flCosY, flCosZ = fnCos(flX), fnCos(flY), fnCos(flZ)
    local flSinX, flSinY, flSinZ = fnSin(flX), fnSin(flY), fnSin(flZ)
    local flCosZSinX, flCosZCosX = fnFloat32(flCosZ * flSinX), fnFloat32(flCosZ * flCosX)

    return {
        fnFloat32(flCosZ * flCosY), -fnFloat32(flSinZ * flCosY), flSinY, 0,
        fnFloat32(fnFloat32(flCosZSinX * flSinY) + fnFloat32(flSinZ * flCosX)), fnFloat32(flCosZCosX - fnFloat32(fnFloat32(flSinY * flSinX) * flSinZ)), -fnFloat32(flSinX * flCosY), 0,
        fnFloat32(fnFloat32(flSinZ * flSinX) - fnFloat32(flCosZCosX * flSinY)), fnFloat32(fnFloat32(fnFloat32(flSinY * flCosX) * flSinZ) + flCosZSinX), fnFloat32(flCosX * flCosY), 0,
        0, 0, 0, 1
    }

end

-- Local matrix of a scene node (game: nuccCoord constructor 0x1412892a0): translation *
-- Euler rotation (degrees in the file) * column scale
function ANM_MATRIX.Node(tPosition, tRotationDegrees, tScale, fnFloat32, fnSin, fnCos)

    local tLocal = ANM_MATRIX.Identity()

    for i = 1, 3 do
        tLocal[i * 4] = tPosition[i]
    end

    local function fnRadians(flDegrees)
        return fnFloat32(fnFloat32(flDegrees * fnFloat32(3.1415927410125732)) / 180)
    end

    local tR = tRotationDegrees

    if tR[1] ~= 0 or tR[2] ~= 0 or tR[3] ~= 0 then
        tLocal = ANM_MATRIX.Multiply(tLocal, ANM_MATRIX.Euler(fnRadians(tR[1]), fnRadians(tR[2]), fnRadians(tR[3]), fnFloat32, fnSin, fnCos), fnFloat32)
    end

    return ANM_MATRIX.ScaleColumns(tLocal, tScale, fnFloat32)

end

-- World matrix of a coordinate: the parent's * the local one (game: nuccCoord 0x141289db0).
-- A particle's parent already carries its size as a column scale. tOut as Multiply.
function ANM_MATRIX.World(tParent, tLocal, fnFloat32, tOut)
    return ANM_MATRIX.Multiply(tParent, tLocal, fnFloat32, tOut)
end

return ANM_MATRIX
