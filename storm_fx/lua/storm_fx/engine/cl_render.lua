-- Drawing the game's effect meshes with Garry's Mod's screenspace_general: render states,
-- materials, meshes, draw constants and draw order.
-- A mesh comes from storm_import.py with its own shader pair (shader_port.py: the game's
-- vertex and pixel programs translated from bytecode, the material's constants compiled in)
-- and a layout saying where the other constants go (StormFX.ShaderLayout).
-- The render state rules are the game's (shader_constant_pipeline.md):
--   * dest_factor low / high nibble: colour / alpha blend mode (tables 0x141b91150 /
--     0x141b911f0, applied by 0x14126bc70);
--   * source_factor: bit 0 translucent bucket (0x141241450), bit 2 no depth write;
--   * blending is enabled by the sort bucket, not by the material (0x141219480);
--   * draw order: layer, bucket, depth, emission order.

StormFX.Render = StormFX.Render or {}

local RENDER = StormFX.Render
local SHADER_LAYOUT = StormFX.ShaderLayout

RENDER.Pack = SHADER_LAYOUT.Pack
RENDER.PackInto = SHADER_LAYOUT.PackInto
RENDER.Static = SHADER_LAYOUT.Static
RENDER.StaticInto = SHADER_LAYOUT.StaticInto
RENDER.Names = SHADER_LAYOUT.Names

-- The game's blend factor code -> Source BLEND_*; the game's operation -> BLENDFUNC_*
local FACTOR = {[0] = 0, [1] = 1, [2] = 9, [3] = 10, [4] = 4, [5] = 5, [6] = 2, [7] = 3, [8] = 6, [9] = 7}
local OPERATION = {[0] = 0, [1] = 1, [2] = 2, [3] = 3, [4] = 4}

-- {source, operation, destination} in the game's codes, by 4-bit mode
RENDER.colorModes = {[0] = {1, 0, 0}, {4, 0, 5}, {4, 0, 1}, {4, 2, 1}, {0, 0, 4}, {4, 2, 4}, {8, 0, 9}, {8, 0, 1}, {8, 2, 1}, {8, 0, 0}, {6, 0, 0}, {1, 0, 5}, {1, 0, 1}}
RENDER.alphaModes = {[0] = {1, 0, 0}, {4, 0, 5}, {4, 0, 1}, {4, 2, 1}, {0, 0, 4}, {4, 2, 4}, {8, 0, 9}, {8, 0, 1}, {8, 2, 1}, {0, 0, 1}, {0, 0, 0}, {1, 0, 5}, {1, 0, 1}}

-- The texture Source gives the copy made by render.UpdateScreenEffectTexture
RENDER.sceneTexture = "_rt_FullFrameFB"

-- nuccChunkModel layer byte -> its place in the frame, from the order of the captures
-- 22127 / 22136 (2, 18, 0, 1, 14). Layer 3 was never captured: placed with the translucent ones.
-- Layer 12 was never captured either (the shadows on the ground of 2sikskl1_s): placed first,
-- a host choice. Drawn last, they were cut by the depth the shadow pool of layer 2 writes
-- under its transparent edge (seen in game).
RENDER.layerRank = {[12] = 0, [2] = 1, [18] = 2, [0] = 3, [1] = 4, [3] = 5, [14] = 6}

-- Bit n of a number
local function fnBit(iValue, n)
    return math.floor(iValue / 2^n) % 2
end

-- The render state of a NUD material record {source_factor, dest_factor, cull_mode}
function RENDER.State(tNud)

    local iSource, iDest = tNud.source_factor or 0, tNud.dest_factor or 0
    local tColor = assert(RENDER.colorModes[iDest % 16], "Unknown native colour blend mode")
    local tAlpha = assert(RENDER.alphaModes[math.floor(iDest / 16) % 16], "Unknown native alpha blend mode")
    local iBucket = fnBit(iSource, 0) == 0 and 0 or fnBit(iSource, 1) == 0 and 2 or fnBit(iSource, 3) == 1 and 3 or 1

    return {
        bucket = iBucket,
        blend = iBucket ~= 0,
        depthWrite = fnBit(iSource, 2) == 0,
        cull = tNud.cull_mode == 1029,
        blendArgs = {FACTOR[tColor[1]], FACTOR[tColor[3]], OPERATION[tColor[2]], FACTOR[tAlpha[1]], FACTOR[tAlpha[3]], OPERATION[tAlpha[2]]}
    }

end

-- The textures a mesh's shader samples, in sampler order ($basetexture, $texture1..), and
-- whether one of them is the scene copy
function RENDER.Textures(tMesh)

    local tNames, bScene = {}, false

    for n, tSampler in ipairs(tMesh.shader.samplers) do

        if tSampler.system then
            tNames[n] = tSampler.system
            bScene = true
        else
            tNames[n] = assert(tMesh.textures[tSampler.material + 1], "Shader samples a texture the material lacks").vtf
        end

    end

    return tNames, bScene

end

-- The material of a mesh.
-- Depth: Garry's Mod's screenspace_general (bin/win64/stdshader_dx9.dll 2026.09.22, shadow
-- state at 0x18004e8e8) sets DepthFunc(ALWAYS) when $writedepth is 1: such a material is
-- drawn over everything. So the materials keep $writedepth 0 and $depthtest 1, and the depth
-- writes of a state go through render.OverrideDepthEnable (RENDER.Begin), which sets the
-- writes only.
function RENDER.Material(sName, tMesh, tState)

    local tShader = tMesh.shader
    local tTextures = RENDER.Textures(tMesh)

    local tParams = {
        ["$pixshader"] = tShader.pixel,
        ["$vertexshader"] = tShader.vertex,
        ["$basetexture"] = tTextures[1],

        -- A studio model's vertices carry no colour (its shader variant has it compiled in)
        ["$vertexcolor"] = tShader.studio and "0" or "1",
        ["$vertextransform"] = "1",
        ["$copyalpha"] = "0",
        ["$alpha_blend"] = "0",
        ["$writealpha"] = "1",
        ["$depthtest"] = "1",
        ["$writedepth"] = "0",
        ["$cull"] = tState.cull and "1" or "0",
        -- Skinned by Source before the shader; a studio variant that skins on the GPU itself
        -- takes the bone matrices instead
        ["$softwareskin"] = tShader.gpuSkin and "0" or "1",
        ["$linearread_basetexture"] = "1",
        ["$linearwrite"] = "1"
    }

    -- Components of the baked TEXCOORD channels; the second UV set, when the shader reads
    -- it, is channel 1 with two
    local sSize = tostring(tShader.channelSize or 2)

    for iChannel = 1, 7 do
        tParams["$tcsize" .. iChannel] = (iChannel == 1 and tShader.attributes.uv1) and "2" or sSize
    end

    if tShader.attributes.normal then
        tParams["$vertexnormal"] = "1"
    end

    for i = 2, #tTextures do
        tParams["$texture" .. (i - 1)] = tTextures[i]
        tParams["$linearread_texture" .. (i - 1)] = "1"
    end

    -- A pair that samples five to eight textures needs screenspace_general_8tex (GMod
    -- 2025.12.01, the same shader with eight samplers)
    return CreateMaterial(sName, tShader.host or "screenspace_general", tParams)

end

-- Whether this Garry's Mod has the shader a mesh asks for (an unknown shader name gives a
-- material of another shader)
function RENDER.HostAvailable(matPart, tMesh)

    local sHost = tMesh.shader.host or "screenspace_general"

    return sHost == "screenspace_general" or not matPart.GetShader or string.lower(matPart:GetShader() or "") == sHost

end

-- A big-endian IEEE half float at a 1-based position of a hex string
function RENDER.Half(sHex, iAt)

    local iValue = tonumber(sHex:sub(iAt, iAt + 3), 16)
    local iSign = iValue >= 32768 and -1 or 1
    local iExponent, iMantissa = math.floor(iValue / 1024) % 32, iValue % 1024

    if iExponent == 0 then
        return iSign * iMantissa * 2^-24
    end

    assert(iExponent < 31, "Non-finite half float in a NUD normal")

    return iSign * (1 + iMantissa / 1024) * 2^(iExponent - 15)

end

-- Send the vertices of a mesh. tDefinition: {vertices = {{x, y, z, u, v, r, g, b, a}, ...},
-- triangles = {{i, j, k}, ...}} with 0-based indices, normalHalfRaw / uvSets when the shader
-- reads them. tStatic: the seven TEXCOORD channels of RENDER.Static. tSkinned: {positions,
-- normals} of a skinned mesh, or nil for the vertices as in the file.
-- Winding: the game's front faces are counter-clockwise on screen and Source culls the
-- counter-clockwise ones; the importer emits strips of the opposite parity, so a game front
-- face arrives clockwise, Source's front face (verify_port_winding.py).
-- The position and normal of the vertex being sent, refilled (mesh.Position / Normal copy them)
local vecEmitPosition = Vector(0, 0, 0)
local vecEmitNormal = Vector(0, 0, 0)

local function fnEmit(tDefinition, tStatic, tSkinned, iFirst, iLast)

    local tAttributes = tDefinition.shader.attributes
    local tTriangles = tDefinition.triangles

    for iTriangle = iFirst or 1, iLast or #tTriangles do

        local tTriangle = tTriangles[iTriangle]

        for _, iIndex in ipairs(tTriangle) do

            local tVertex = tDefinition.vertices[iIndex + 1]
            local tPosition = tSkinned and tSkinned.positions[iIndex + 1] or tVertex

            vecEmitPosition:SetUnpacked(tPosition[1], tPosition[2], tPosition[3])
            mesh.Position(vecEmitPosition)

            if tAttributes.normal then

                if tDefinition.skin then

                    local tNormal = tSkinned and tSkinned.normals[iIndex + 1] or tDefinition.skin.normals[iIndex + 1]
                    vecEmitNormal:SetUnpacked(tNormal[1], tNormal[2], tNormal[3])

                else

                    local sRaw = assert(tDefinition.normalHalfRaw, "Shader needs NUD normals")[iIndex + 1]
                    vecEmitNormal:SetUnpacked(RENDER.Half(sRaw, 1), RENDER.Half(sRaw, 5), RENDER.Half(sRaw, 9))

                end

                mesh.Normal(vecEmitNormal)

            end

            mesh.TexCoord(0, tVertex[4], tVertex[5])

            for iChannel, tBaked in ipairs(tStatic) do

                if iChannel == 1 and tAttributes.uv1 then
                    local tSecond = assert(tDefinition.uvSets, "Shader needs the second UV set")[iIndex + 1][2]
                    mesh.TexCoord(1, tSecond[1], tSecond[2])
                elseif #tBaked == 4 then
                    mesh.TexCoord(iChannel, tBaked[1], tBaked[2], tBaked[3], tBaked[4])
                else
                    mesh.TexCoord(iChannel, tBaked[1], tBaked[2])
                end

            end

            mesh.Color(tVertex[6] * 255, tVertex[7] * 255, tVertex[8] * 255, tVertex[9] * 255)
            mesh.AdvanceVertex()

        end

    end

end

-- A cached mesh (IMesh) of a mesh definition
function RENDER.BuildMesh(matPart, tDefinition, tStatic)

    local mshBuffer = Mesh(matPart)

    mesh.Begin(mshBuffer, MATERIAL_TRIANGLES, #tDefinition.triangles)
        fnEmit(tDefinition, tStatic)
    mesh.End()

    return mshBuffer

end

-- The cached meshes (IMesh) of a mesh definition, in pieces a vertex buffer holds
-- (RENDER.BATCH_VERTICES), appended to tOut. tSkinned as fnEmit.
function RENDER.BuildMeshes(matPart, tDefinition, tStatic, tSkinned, tOut)

    tOut = tOut or {}

    local iTriangles = #tDefinition.triangles
    local iPerPiece = math.floor(RENDER.BATCH_VERTICES / 3)

    for iFirst = 1, iTriangles, iPerPiece do

        local iLast = math.min(iTriangles, iFirst + iPerPiece - 1)
        local mshPiece = Mesh(matPart)

        mesh.Begin(mshPiece, MATERIAL_TRIANGLES, iLast - iFirst + 1)
            fnEmit(tDefinition, tStatic, tSkinned, iFirst, iLast)
        mesh.End()

        tOut[#tOut + 1] = mshPiece

    end

    return tOut

end

-- A skinned mesh split for drawing (made once per mesh definition). A vertex whose weight is
-- exactly 1 on one influence (the others exactly 0) and whose w is 1 is that palette matrix
-- times the vertex (SKINNING.Vertex: the zero-weight terms add exact zeros): the triangles
-- whose three vertices hang that way from the same palette entry are drawn as they are in the
-- file, under the draw matrix times that entry (rigid[entry]: a definition over the same
-- vertices). The other triangles (mixed) are skinned on the CPU: a compact definition of their
-- own vertices. Returns {rigid = {[palette index] = definition}, mixed = definition or nil}.
function RENDER.SplitSkinned(tDefinition)

    local tSplit = tDefinition.split

    if tSplit then return tSplit end

    local tSkin = tDefinition.skin
    local tBoneOf = {}

    for iVertex = 1, #tDefinition.vertices do

        local tWeights, tBones = tSkin.weights[iVertex], tSkin.indices[iVertex]
        local iBone
        local bRigid = not tSkin.positionW or tSkin.positionW[iVertex] == 1

        for k = 1, 4 do
            if tWeights[k] == 1 and not iBone then
                iBone = tBones[k] + 1
            elseif tWeights[k] ~= 0 then
                bRigid = false
            end
        end

        tBoneOf[iVertex] = bRigid and iBone or false

    end

    local tRigid, tMixed = {}, {}

    for _, tTriangle in ipairs(tDefinition.triangles) do

        local iBone = tBoneOf[tTriangle[1] + 1]

        if iBone and tBoneOf[tTriangle[2] + 1] == iBone and tBoneOf[tTriangle[3] + 1] == iBone then

            local tPart = tRigid[iBone]

            if not tPart then
                tPart = {shader = tDefinition.shader, vertices = tDefinition.vertices, skin = tSkin, uvSets = tDefinition.uvSets,
                    normalHalfRaw = tDefinition.normalHalfRaw, triangles = {}}
                tRigid[iBone] = tPart
            end

            tPart.triangles[#tPart.triangles + 1] = tTriangle

        else

            tMixed[#tMixed + 1] = tTriangle

        end

    end

    -- The mixed triangles over their own vertices, renumbered
    local tCompact

    if #tMixed > 0 then

        tCompact = {shader = tDefinition.shader, vertices = {}, triangles = {}, uvSets = tDefinition.uvSets and {} or nil,
            skin = {normals = {}, indices = {}, weights = {}, positionW = tSkin.positionW and {} or nil}}

        local tNewIndex = {}

        for iTriangle, tTriangle in ipairs(tMixed) do

            local tNew = {}

            for k = 1, 3 do

                local iOld = tTriangle[k] + 1
                local iNew = tNewIndex[iOld]

                if not iNew then

                    iNew = #tCompact.vertices + 1
                    tNewIndex[iOld] = iNew

                    tCompact.vertices[iNew] = tDefinition.vertices[iOld]
                    tCompact.skin.normals[iNew] = tSkin.normals[iOld]
                    tCompact.skin.indices[iNew] = tSkin.indices[iOld]
                    tCompact.skin.weights[iNew] = tSkin.weights[iOld]

                    if tCompact.skin.positionW then
                        tCompact.skin.positionW[iNew] = tSkin.positionW[iOld]
                    end

                    if tCompact.uvSets then
                        tCompact.uvSets[iNew] = tDefinition.uvSets[iOld]
                    end

                end

                tNew[k] = iNew - 1

            end

            tCompact.triangles[iTriangle] = tNew

        end

    end

    tSplit = {rigid = tRigid, mixed = tCompact}
    tDefinition.split = tSplit

    return tSplit

end

-- A skinned mesh, sent as a dynamic mesh with the material the caller bound
-- (render.SetMaterial), under the caller's model matrix
function RENDER.DrawSkinned(tDefinition, tStatic, tSkinned)

    -- In pieces a dynamic vertex buffer holds (RENDER.BATCH_VERTICES)
    local iTriangles = #tDefinition.triangles
    local iPerPiece = math.floor(RENDER.BATCH_VERTICES / 3)

    for iFirst = 1, iTriangles, iPerPiece do

        local iLast = math.min(iTriangles, iFirst + iPerPiece - 1)

        mesh.Begin(MATERIAL_TRIANGLES, iLast - iFirst + 1)
            fnEmit(tDefinition, tStatic, tSkinned, iFirst, iLast)
        mesh.End()

    end

end

-- The channels a shader reads (each is a call a vertex): its static entries, and channel 1
-- for the second UV set; counted once per mesh
local function fnUsedChannels(tDefinition)

    local iChannels = tDefinition.usedChannels

    if not iChannels then

        local tShader = tDefinition.shader

        iChannels = tShader.attributes.uv1 and 1 or 0

        for _, tEntry in ipairs(tShader.static) do
            iChannels = math.max(iChannels, tEntry.channel)
        end

        tDefinition.usedChannels = iChannels

    end

    return iChannels

end

RENDER.UsedChannels = fnUsedChannels

-- The ribbon vertex being sent, and its position (refilled: mesh.Position copies it)
local vecRibbon = Vector(0, 0, 0)
local vecNoNormal = Vector(0, 0, 0)

-- A colour component in 0..255
local function fnByte(flValue)

    if flValue <= 0 then return 0 end
    if flValue >= 1 then return 255 end

    return flValue * 255

end

-- The static channels of a ribbon part, flattened once: channel, then four values (nil for
-- a two-value channel); channel 1 is the vertex's own UV when the shader reads a second set
local function fnRibbonChannels(tDefinition, tStatic, iChannels)

    local tFlat = {}

    for iChannel = 1, iChannels do

        local tBaked = tStatic[iChannel]

        if iChannel == 1 and tDefinition.shader.attributes.uv1 then
            tFlat[#tFlat + 1] = {iChannel, uv = true}
        elseif #tBaked == 4 then
            tFlat[#tFlat + 1] = {iChannel, tBaked[1], tBaked[2], tBaked[3], tBaked[4]}
        else
            tFlat[#tFlat + 1] = {iChannel, tBaked[1], tBaked[2]}
        end

    end

    return tFlat

end

-- The flattened channels, by static table
local tRibbonChannels = setmetatable({}, {__mode = "k"})

-- One ribbon vertex
local function fnPutRibbonVertex(tVertex, bNormal, tChannels)

    local tPosition = tVertex.position
    local fnTexCoord = mesh.TexCoord
    local u, v = tVertex.u, tVertex.v

    vecRibbon:SetUnpacked(tPosition[1], tPosition[2], tPosition[3])
    mesh.Position(vecRibbon)

    if bNormal then
        mesh.Normal(vecNoNormal)
    end

    fnTexCoord(0, u, v)

    for i = 1, #tChannels do

        local tChannel = tChannels[i]

        if tChannel.uv then
            fnTexCoord(1, u, v)
        elseif tChannel[4] then
            fnTexCoord(tChannel[1], tChannel[2], tChannel[3], tChannel[4], tChannel[5])
        else
            fnTexCoord(tChannel[1], tChannel[2], tChannel[3])
        end

    end

    local tColor = tVertex.color

    mesh.Color(fnByte(tColor[1]), fnByte(tColor[2]), fnByte(tColor[3]), fnByte(tColor[4]))
    mesh.AdvanceVertex()

end

-- A trail ribbon (StormFX.Core.Trail vertices, two per point: edge 0, edge 1), sent as the
-- game sends it, a triangle strip (0x141389eb0 draws 2 x points vertices). The first vertex
-- goes twice: the degenerate first triangle flips the strip's parity, so that every triangle
-- is wound as the importer's strips are, (a, c, b) and (c, d, b) for points a-b and c-d. A
-- trail's vertices carry no normal (zero).
-- Vertices of one mesh built from Lua at most: GMod refuses more than its vertex buffer holds
-- (29988 > 10922 seen for these vertex formats: an engine error that closes the game)
RENDER.BATCH_VERTICES = 2048

-- A trail ribbon (see above) in a mesh of its own (Mesh of the part's material), drawn under
-- the identity matrix; nil when it has no triangle. A ribbon longer than a mesh holds keeps
-- its newest points.
function RENDER.BuildRibbon(matPart, tDefinition, tStatic, tVertices)

    local tAttributes = tDefinition.shader.attributes
    local iVertices = math.min(#tVertices, RENDER.BATCH_VERTICES - 2)

    iVertices = iVertices - iVertices % 2

    if iVertices < 4 then return nil end

    local tChannels = tRibbonChannels[tStatic]

    if not tChannels then
        tChannels = fnRibbonChannels(tDefinition, tStatic, fnUsedChannels(tDefinition))
        tRibbonChannels[tStatic] = tChannels
    end

    local bNormal = tAttributes.normal and true or false
    local mshRibbon = Mesh(matPart)

    mesh.Begin(mshRibbon, MATERIAL_TRIANGLE_STRIP, iVertices - 1)

        fnPutRibbonVertex(tVertices[1], bNormal, tChannels)

        for k = 1, iVertices do
            fnPutRibbonVertex(tVertices[k], bNormal, tChannels)
        end

    mesh.End()

    return mshRibbon

end

-- The position of the vertex being sent, refilled (mesh.Position copies it)
local vecBatch = Vector(0, 0, 0)

-- A two-triangle mesh (a billboard's card) as one quad: its four vertex indices q0..q3 such
-- that the triangles are (q0, q1, q2) and (q0, q2, q3), the split of Source's quads, each
-- with its winding; false when the two triangles do not make one
local function fnQuad(tDefinition)

    local bQuad = tDefinition.quadCorners

    if bQuad ~= nil then return bQuad end

    local tTriangles = tDefinition.triangles
    local tQuad = false

    if #tTriangles == 2 then

        local tA, tB = tTriangles[1], tTriangles[2]

        for r1 = 0, 2 do

            local q0, q1, q2 = tA[r1 % 3 + 1], tA[(r1 + 1) % 3 + 1], tA[(r1 + 2) % 3 + 1]

            for r2 = 0, 2 do

                if not tQuad and tB[r2 % 3 + 1] == q0 and tB[(r2 + 1) % 3 + 1] == q2 then
                    tQuad = {q0, q1, q2, tB[(r2 + 2) % 3 + 1]}
                end

            end

        end

    end

    tDefinition.quadCorners = tQuad

    return tQuad

end

RENDER.Quad = fnQuad

-- Billboards sent as quads (false: as their two triangles, for comparisons)
RENDER.useQuads = true

-- The particles iFirst .. iFirst + iCount - 1 of a draw list, into the mesh being built: their
-- triangles, or their quads (tQuad, four vertices a particle instead of six)
local function fnEmitBatch(tPart, tEntries, iFirst, iCount, tQuad)

    local tDefinition = tPart.mesh
    local tAttributes = tDefinition.shader.attributes
    local tTriangles, tMeshVertices = tDefinition.triangles, tDefinition.vertices
    local tCorners = tQuad and {tQuad}

    -- Only the channels the shader reads are sent (each is a call a vertex)
    local iChannels = fnUsedChannels(tDefinition)

    for iEntry = iFirst, iFirst + iCount - 1 do

        local tEntry = tEntries[iEntry]
        local w = tEntry.world
        local tStatic = tEntry.static

        for _, tTriangle in ipairs(tCorners or tTriangles) do

            for _, iIndex in ipairs(tTriangle) do

                local tVertex = tMeshVertices[iIndex + 1]
                local x, y, z = tVertex[1], tVertex[2], tVertex[3]

                vecBatch:SetUnpacked(w[1] * x + w[2] * y + w[3] * z + w[4], w[5] * x + w[6] * y + w[7] * z + w[8],
                    w[9] * x + w[10] * y + w[11] * z + w[12])

                mesh.Position(vecBatch)

                mesh.TexCoord(0, tVertex[4], tVertex[5])

                for iChannel = 1, iChannels do

                    local tBaked = tStatic[iChannel]

                    if iChannel == 1 and tAttributes.uv1 then
                        local tSecond = tDefinition.uvSets[iIndex + 1][2]
                        mesh.TexCoord(1, tSecond[1], tSecond[2])
                    elseif #tBaked == 4 then
                        mesh.TexCoord(iChannel, tBaked[1], tBaked[2], tBaked[3], tBaked[4])
                    else
                        mesh.TexCoord(iChannel, tBaked[1], tBaked[2])
                    end

                end

                mesh.Color(tVertex[6] * 255, tVertex[7] * 255, tVertex[8] * 255, tVertex[9] * 255)
                mesh.AdvanceVertex()

            end

        end

    end

end

-- The particles of a batched part (entries iFirst..iLast of a draw list) in meshes of their
-- own, appended to tOut, drawn under the identity matrix: each particle's vertices go through
-- its world matrix here, its values (per-draw and stage, RENDER.StaticInto) in the TEXCOORD
-- channels. A mesh holds RENDER.BATCH_VERTICES vertices at most: more particles, more meshes.
function RENDER.BuildBatch(tPart, tEntries, iFirst, iLast, tOut)

    local iTriangles = #tPart.mesh.triangles
    local tQuad = RENDER.useQuads and fnQuad(tPart.mesh)
    local iPerParticle = tQuad and 4 or iTriangles * 3
    local iPerMesh = math.max(1, math.floor(RENDER.BATCH_VERTICES / iPerParticle))
    local iEntry = iFirst

    while iEntry <= iLast do

        local iCount = math.min(iLast - iEntry + 1, iPerMesh)
        local mshBatch = Mesh(tPart.mat)

        if tQuad then
            mesh.Begin(mshBatch, MATERIAL_QUADS, iCount)
        else
            mesh.Begin(mshBatch, MATERIAL_TRIANGLES, iTriangles * iCount)
        end

            fnEmitBatch(tPart, tEntries, iEntry, iCount, tQuad)

        mesh.End()

        tOut[#tOut + 1] = mshBatch
        iEntry = iEntry + iCount

    end

    return tOut

end

-- The names $c0_x .. $c3_w, built once
local CONSTANT_NAMES = {}

for n = 0, 3 do
    for i, sAxis in ipairs({"x", "y", "z", "w"}) do
        CONSTANT_NAMES[n * 4 + i] = "$c" .. n .. "_" .. sAxis
    end
end

-- The values last set on each material: only the components that change are sent
local tSent = setmetatable({}, {__mode = "k"})

-- Set the pixel constants c0..c3 of a draw on its material
function RENDER.Apply(matPart, tPacked)

    local tLast = tSent[matPart]

    if not tLast then
        tLast = {}
        tSent[matPart] = tLast
    end

    for n = 0, 3 do

        local tValues = tPacked[n + 1]

        for i = 1, 4 do

            local k = n * 4 + i
            local flValue = tValues[i] or 0

            if tLast[k] ~= flValue then
                matPart:SetFloat(CONSTANT_NAMES[k], flValue)
                tLast[k] = flValue
            end

        end

    end

end

-- The game's render state for the draws that follow: the blend, and the depth writes
-- (render.OverrideDepthEnable sets the writes only; the test is the material's $depthtest)
function RENDER.Begin(tState)

    if tState.blend then
        local tArgs = tState.blendArgs
        render.OverrideBlend(true, tArgs[1], tArgs[2], tArgs[3], tArgs[4], tArgs[5], tArgs[6])
    else
        render.OverrideBlend(true, 1, 0, 0, 1, 0, 0)
    end

    render.OverrideDepthEnable(true, tState.depthWrite)

end

-- Release the render state
function RENDER.Finish()

    render.OverrideBlend(false)
    render.OverrideDepthEnable(false, false)

end

-- Sort the draws as the game's queue: layer, then bucket, then depth (bucket 0 near to far,
-- bucket 2 far to near), then emission order. depth grows away from the eye; entry.layer is
-- the nuccChunkModel layer byte.
-- With bGroup, the entries of a batched part are kept together, to be drawn at once: the
-- group takes the place of its farthest member among the blended draws (bucket 2), of its
-- nearest among the opaque ones (bucket 0), of its first member otherwise; inside the group
-- the members keep the game's order. Without it the order is the game's.
-- The keys are worked out once per entry (Sort): sortRank (rank, then bucket), sortGroup /
-- sortDepth (the depths, negated for bucket 2, which goes far to near; 0 for the other
-- buckets, which keep their order)
local function fnBefore(tA, tB)

    local a, b = tA.sortRank, tB.sortRank

    if a ~= b then return a < b end

    a, b = tA.sortGroup, tB.sortGroup

    if a ~= b then return a < b end

    a, b = tA.groupOrder, tB.groupOrder

    if a ~= b then return a < b end

    a, b = tA.sortDepth, tB.sortDepth

    if a ~= b then return a < b end

    return tA.order < tB.order

end

-- The place of each group of this sort, by part
local tGroupDepth, tGroupOrder = {}, {}

function RENDER.Sort(tEntries, bGroup)

    for tPart in pairs(tGroupDepth) do
        tGroupDepth[tPart], tGroupOrder[tPart] = nil, nil
    end

    for i, tEntry in ipairs(tEntries) do

        tEntry.order = i

        -- A layer never captured has no known place in the frame: drawn last
        tEntry.rank = RENDER.layerRank[tEntry.layer or 0] or 7

        if bGroup and tEntry.batched then

            local tPart = tEntry.part
            local flDepth = tGroupDepth[tPart]

            if flDepth == nil then
                tGroupDepth[tPart], tGroupOrder[tPart] = tEntry.depth, i
            elseif tEntry.state.bucket == 0 then
                tGroupDepth[tPart] = math.min(flDepth, tEntry.depth)
            else
                tGroupDepth[tPart] = math.max(flDepth, tEntry.depth)
            end

        end

    end

    for _, tEntry in ipairs(tEntries) do

        local tPart = bGroup and tEntry.batched and tEntry.part

        tEntry.groupDepth = tPart and tGroupDepth[tPart] or tEntry.depth
        tEntry.groupOrder = tPart and tGroupOrder[tPart] or tEntry.order

        local iBucket = tEntry.state.bucket

        tEntry.sortRank = tEntry.rank * 1024 + iBucket
        tEntry.sortGroup = iBucket == 0 and tEntry.groupDepth or iBucket == 2 and -tEntry.groupDepth or 0
        tEntry.sortDepth = iBucket == 0 and tEntry.depth or iBucket == 2 and -tEntry.depth or 0

    end

    table.sort(tEntries, fnBefore)

    return tEntries

end

return RENDER
