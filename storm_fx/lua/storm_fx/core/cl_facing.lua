-- Camera-facing models and billboards (game: slot +68 of nuccModel 0x1412d4f40 and of
-- nuccBillboard 0x1412c84b0, applied once per draw by 0x1412d1870 to a model whose header
-- attribute bit 0 is set).
-- Matrices are 4x4 row-major, the translation in elements 4, 8 and 12 (the columns are
-- the axes). vecRight, vecUp and vecNormal are the camera's axes (right, up, right x up)
-- in the matrix's space: anything with x / y / z fields.

StormFX.Core.Facing = StormFX.Core.Facing or {}

local FACING = StormFX.Core.Facing

-- Length of each axis (column) of a matrix
local function fnAxisLengths(tMatrix)

    return math.sqrt(tMatrix[1]^2 + tMatrix[5]^2 + tMatrix[9]^2),
        math.sqrt(tMatrix[2]^2 + tMatrix[6]^2 + tMatrix[10]^2),
        math.sqrt(tMatrix[3]^2 + tMatrix[7]^2 + tMatrix[11]^2)

end

-- A matrix from three axes, their lengths and a translation
local function fnBuild(tAxisX, tAxisY, tAxisZ, flLength1, flLength2, flLength3, tTranslation)

    return {
        tAxisX[1] * flLength1, tAxisY[1] * flLength2, tAxisZ[1] * flLength3, tTranslation[1],
        tAxisX[2] * flLength1, tAxisY[2] * flLength2, tAxisZ[2] * flLength3, tTranslation[2],
        tAxisX[3] * flLength1, tAxisY[3] * flLength2, tAxisZ[3] * flLength3, tTranslation[3],
        0, 0, 0, 1
    }

end

-- A model: keeps its translation and the length of each axis, takes the camera's rotation
function FACING.Model(tWorld, vecRight, vecUp, vecNormal)

    local flLength1, flLength2, flLength3 = fnAxisLengths(tWorld)

    return fnBuild({vecRight.x, vecRight.y, vecRight.z}, {vecUp.x, vecUp.y, vecUp.z}, {vecNormal.x, vecNormal.y, vecNormal.z},
        flLength1, flLength2, flLength3, {tWorld[4], tWorld[8], tWorld[12]})

end

-- A billboard: the camera's rotation turned about its z axis by the roll (a binary angle,
-- value * 2pi / 65536 in float32), its x / y axes scaled by the size, its translation moved
-- by the offset. tBoard = {roll, size = {w, h}, offset = {x, y, z}}; tLinear: a 4x4 whose 3x3
-- part takes the offset into the matrix's space (nil: the game's own space).
function FACING.Billboard(tWorld, tBoard, vecRight, vecUp, vecNormal, tLinear, fnFloat32)

    fnFloat32 = fnFloat32 or function(flValue) return flValue end

    local flLength1, flLength2, flLength3 = fnAxisLengths(tWorld)
    local flAngle = fnFloat32(fnFloat32(tBoard.roll * fnFloat32(6.2831854820251465)) * fnFloat32(1.52587890625e-05))
    local flCos, flSin = math.cos(flAngle), math.sin(flAngle)

    local tAxisX = {vecRight.x * flCos + vecUp.x * flSin, vecRight.y * flCos + vecUp.y * flSin, vecRight.z * flCos + vecUp.z * flSin}
    local tAxisY = {-vecRight.x * flSin + vecUp.x * flCos, -vecRight.y * flSin + vecUp.y * flCos, -vecRight.z * flSin + vecUp.z * flCos}

    local tOffset, tTranslation = tBoard.offset, {tWorld[4], tWorld[8], tWorld[12]}

    for iRow = 1, 3 do

        if tLinear then
            tTranslation[iRow] = tTranslation[iRow] + tLinear[iRow * 4 - 3] * tOffset[1] + tLinear[iRow * 4 - 2] * tOffset[2] + tLinear[iRow * 4 - 1] * tOffset[3]
        else
            tTranslation[iRow] = tTranslation[iRow] + tOffset[iRow]
        end

    end

    return fnBuild(tAxisX, tAxisY, {vecNormal.x, vecNormal.y, vecNormal.z}, flLength1 * tBoard.size[1], flLength2 * tBoard.size[2], flLength3, tTranslation)

end

return FACING
