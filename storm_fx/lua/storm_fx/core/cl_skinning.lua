-- Skinning of NUD meshes as the game does it: a compute shader run once per skinned mesh
-- (captured in RenderDoc, gpu_captures/compute/shader_*.dxbc; it is in no file of the game).
-- Per vertex it blends the first three columns of the palette matrices of the four
-- influences by their weights, then
--   position.xyz = (dot(R1, p), dot(R2, p), dot(R3, p)), position.w kept
--   normal       = (dot(R1.xyz, n), dot(R2.xyz, n), dot(R3.xyz, n))   -- not renormalised
-- A palette matrix is sixteen numbers as the shader reads them (row vectors: the translation
-- in elements 13..15), so column k is elements k, k + 4, k + 8, k + 12. The palette has one
-- matrix per coordinate of the model's clump: transpose(pose * inverse(rest)).
-- verify_skinning_capture.py compares Vertex with the captured dispatches.

StormFX.Core.Skinning = StormFX.Core.Skinning or {}

local SKINNING = StormFX.Core.Skinning

-- One vertex: tPosition {x, y, z, w}, tNormal {x, y, z}, four weights and palette indices
-- (1-based). The sums run in the shader's order: influence 2 first.
function SKINNING.Vertex(tPosition, tNormal, tWeights, tIndices, tPalette, fnFloat32)

    local f = fnFloat32
    local tA, tB, tC, tD = tPalette[tIndices[1]], tPalette[tIndices[2]], tPalette[tIndices[3]], tPalette[tIndices[4]]
    local flW1, flW2, flW3, flW4 = tWeights[1], tWeights[2], tWeights[3], tWeights[4]
    local tOutPosition, tOutNormal = {}, {}

    for k = 1, 3 do

        local flR1 = f(f(f(f(flW2 * tB[k]) + f(tA[k] * flW1)) + f(tC[k] * flW3)) + f(tD[k] * flW4))
        local flR2 = f(f(f(f(flW2 * tB[k + 4]) + f(tA[k + 4] * flW1)) + f(tC[k + 4] * flW3)) + f(tD[k + 4] * flW4))
        local flR3 = f(f(f(f(flW2 * tB[k + 8]) + f(tA[k + 8] * flW1)) + f(tC[k + 8] * flW3)) + f(tD[k + 8] * flW4))
        local flR4 = f(f(f(f(flW2 * tB[k + 12]) + f(tA[k + 12] * flW1)) + f(tC[k + 12] * flW3)) + f(tD[k + 12] * flW4))

        tOutPosition[k] = f(f(f(f(flR1 * tPosition[1]) + f(flR2 * tPosition[2])) + f(flR3 * tPosition[3])) + f(flR4 * tPosition[4]))
        tOutNormal[k] = f(f(f(flR1 * tNormal[1]) + f(flR2 * tNormal[2])) + f(flR3 * tNormal[3]))

    end

    tOutPosition[4] = tPosition[4]

    return tOutPosition, tOutNormal

end

-- Inverse of an affine matrix in the engine's layout (rows of a 3x4 transform, the
-- translation in elements 4, 8, 12); nil for a matrix that flattens space (an animation
-- scales a coordinate to zero to hide what hangs from it)
function SKINNING.Inverse(tM)

    local a, b, c, d, e, g, h, i, j = tM[1], tM[2], tM[3], tM[5], tM[6], tM[7], tM[9], tM[10], tM[11]
    local flA, flB, flC = e * j - g * i, g * h - d * j, d * i - e * h
    local flDeterminant = a * flA + b * flB + c * flC

    if flDeterminant == 0 or flDeterminant ~= flDeterminant then
        return nil
    end

    local tR = {
        flA / flDeterminant, (c * i - b * j) / flDeterminant, (b * g - c * e) / flDeterminant, 0,
        flB / flDeterminant, (a * j - c * h) / flDeterminant, (c * d - a * g) / flDeterminant, 0,
        flC / flDeterminant, (b * h - a * i) / flDeterminant, (a * e - b * d) / flDeterminant, 0,
        0, 0, 0, 1
    }

    local flX, flY, flZ = tM[4], tM[8], tM[12]

    tR[4] = -(tR[1] * flX + tR[2] * flY + tR[3] * flZ)
    tR[8] = -(tR[5] * flX + tR[6] * flY + tR[7] * flZ)
    tR[12] = -(tR[9] * flX + tR[10] * flY + tR[11] * flZ)

    return tR

end

-- A matrix transposed
local function fnTransposed(tM)
    return {tM[1], tM[5], tM[9], tM[13], tM[2], tM[6], tM[10], tM[14], tM[3], tM[7], tM[11], tM[15], tM[4], tM[8], tM[12], tM[16]}
end

-- The palette of a skinned model as the shader reads it. tPose[i]: matrix of clump
-- coordinate i in the space the effect is evaluated in; tRestInverse[i]: inverse of its rest
-- matrix in the clump's space; tDrawInverse: inverse of the matrix the model is drawn with.
function SKINNING.Palette(tPose, tRestInverse, tDrawInverse, fnMultiply, fnFloat32)

    local tPalette = {}

    for i = 1, #tPose do
        tPalette[i] = fnTransposed(fnMultiply(tDrawInverse, fnMultiply(tPose[i], tRestInverse[i], fnFloat32), fnFloat32))
    end

    return tPalette

end

-- A whole mesh: tDefinition.vertices {{x, y, z, ...}}, tDefinition.skin {normals, indices
-- (0-based, as in the NUD), weights, positionW or nil}. Returns positions and normals.
function SKINNING.Mesh(tDefinition, tPalette, fnFloat32)

    local tSkin = tDefinition.skin
    local tPositions, tNormals = {}, {}
    local tIndex = {0, 0, 0, 0}

    for iVertex, tVertex in ipairs(tDefinition.vertices) do

        local tBones = tSkin.indices[iVertex]
        tIndex[1], tIndex[2], tIndex[3], tIndex[4] = tBones[1] + 1, tBones[2] + 1, tBones[3] + 1, tBones[4] + 1

        tPositions[iVertex], tNormals[iVertex] = SKINNING.Vertex({tVertex[1], tVertex[2], tVertex[3], tSkin.positionW and tSkin.positionW[iVertex] or 1},
            tSkin.normals[iVertex], tSkin.weights[iVertex], tIndex, tPalette, fnFloat32)

    end

    return tPositions, tNormals

end

return SKINNING
