-- Packages: loading one (its data, then a drawable item per model and per trail ribbon, each
-- with its materials and meshes), and the meshes the stage values are baked into.

local ENGINE = StormFX.Engine
local RENDER = StormFX.Render

-- What the engine sets for each draw of every material (storm_import.py DRAW_CONSTANTS), and
-- point light slot 0 for the lit ones
local PER_DRAW = {
    g_uvOffset0 = true,
    g_multColor = true,
    g_commonParam = true,
    g_uvOffsetScreen = true,
    g_pointLightColor0 = true,
    g_pointLightPos0 = true,
    g_pointLightParam0 = true
}

-- Material instance fields -> constant components (binder 0x1412f5ff0): the same map
-- storm_import.py uses for the constants it compiles in
ENGINE.INSTANCE_FIELDS = {
    g_uvOffset0 = {0x30, 0x34, 0x50, 0x54},
    g_uvOffset1 = {0x38, 0x3c, 0x58, 0x5c},
    g_uvOffset2 = {0x40, 0x44, 0x60, 0x64},
    g_uvOffset3 = {0x48, 0x4c, 0x68, 0x6c}
}

local INSTANCE_FIELDS = ENGINE.INSTANCE_FIELDS

-- Add a note to a package once
local function fnNote(tRuntime, sText)

    if not tRuntime.noted[sText] then
        tRuntime.noted[sText] = true
        tRuntime.notes[#tRuntime.notes + 1] = sText
    end

end

-- One drawable model: a part per NUD mesh, each with its own material, shader pair and render
-- state; the nuccChunkModel header and the node opacity. facing: header attribute bit 0
-- (model +2C), the camera-facing hook at draw.
local function fnAddModel(tRuntime, sName, tModel)

    local tStage = ENGINE.tStage

    local tItem = {
        name = sName,
        parts = {},
        fogged = tStage.fogLayers[tModel.header.layer] == true,
        light = tModel.header.light,
        layer = tModel.header.layer,
        opacity = tModel.node and tModel.node.opacity or 1,
        facing = tModel.header.attributes % 2 == 1
    }

    local tProblems = {}
    local tAvailable = ENGINE:StageValues(tItem, 1)

    if not tStage.lightSets[tItem.light] and tStage.lightModes[tItem.light] then
        fnNote(tRuntime, "light mode " .. tostring(tItem.light) .. " was never captured: its ambient is the host default")
    end

    for iIndex, tMesh in ipairs(tModel.meshes) do

        local sWhy = not tMesh.shader and (tMesh.shaderProblem or "no translated shader")

        if not sWhy then

            for _, tGroup in ipairs({tMesh.shader.dynamic, tMesh.shader.static}) do
                for _, tEntry in ipairs(tGroup) do
                    if not PER_DRAW[tEntry.name] and not INSTANCE_FIELDS[tEntry.name] and tEntry.name ~= "g_blendRate"
                        and tEntry.name ~= "g_olIdParam" and not tAvailable[tEntry.name] then
                        sWhy = "the stage has no value for " .. tEntry.name
                    end
                end
            end

        end

        if sWhy then

            tProblems[#tProblems + 1] = "mesh " .. iIndex .. ": " .. sWhy

        else

            if tMesh.shader.frozen and #tMesh.shader.frozen > 0 then
                fnNote(tRuntime, "some lit meshes have " .. table.concat(tMesh.shader.frozen, ", ")
                    .. " of the import-time stage compiled in (pixel constant budget): the stage table does not reach them")
            end

            if tMesh.shader.unlit then
                fnNote(tRuntime, "some lit meshes take no point light (pixel constant budget): their light slot is compiled as unused")
            end

            local tState = RENDER.State(tMesh.state)
            local _, bScene = RENDER.Textures(tMesh)
            tState.scene = bScene

            -- What the shader reads per draw (a batched shader reads it from the vertices)
            local tDynamic, tStatic = RENDER.Names(tMesh.shader)

            if tMesh.shader.batched then
                tDynamic = tStatic
            end

            local tMaterial = tModel.materials[tMesh.material + 1]
            local matPart = RENDER.Material("storm_fx_" .. ENGINE.sVersion .. "_" .. tRuntime.name .. "_" .. sName .. "_" .. iIndex, tMesh, tState)

            if not RENDER.HostAvailable(matPart, tMesh) then

                tProblems[#tProblems + 1] = "mesh " .. iIndex .. ": this GMod has no " .. tMesh.shader.host
                    .. " (five to eight textures; GMod 2025.12.01)"

            else

                tItem.parts[#tItem.parts + 1] = {
                    mesh = tMesh,
                    state = tState,
                    layout = tMesh.shader,
                    instance = tMaterial.instance,
                    materialIndex = tMesh.material + 1,

                    -- The shader reads point light slot 0 of the model's light set
                    lit = (tDynamic.g_pointLightColor0 or tDynamic.g_pointLightPos0 or tDynamic.g_pointLightParam0) == true,

                    -- Material format bit 5: its float replaces the x offset of UV set 2 (falloff)
                    overrideX = math.floor(tMaterial.format / 32) % 2 == 1,

                    scrolls = tDynamic.g_uvOffsetScreen == true,

                    -- Drawn with the other particles of the material, in one mesh a frame
                    batched = tMesh.shader.batched == true,

                    mat = matPart
                }

                -- A skinned mesh the package also has as a Source studio model (export_studio.py):
                -- Source skins it, from the sequence baked from its animation (engine/cl_studio.lua)
                if tMesh.studioShader and tModel.studio then

                    local tStudioMesh = {shader = tMesh.studioShader, textures = tMesh.textures}

                    tItem.parts[#tItem.parts].studio = {
                        mdl = tModel.studio.mdl,
                        animation = tModel.studio.animation,
                        duration = tModel.studio.duration,
                        layout = tMesh.studioShader,
                        mat = RENDER.Material("storm_fx_" .. ENGINE.sVersion .. "_" .. tRuntime.name .. "_" .. sName .. "_" .. iIndex .. "_studio",
                            tStudioMesh, tState)
                    }

                    -- The model's own material (a .vmt the .mdl names: Source builds the model's
                    -- vertex buffers for it): the per-draw constants are set on it
                    -- (its shader is the variant that skins on the GPU: studioGpuShader, whose
                    -- constants are laid out as the other variant's)
                    if tMesh.studioMaterial and Material then
                        tItem.parts[#tItem.parts].studio.mat = Material(tMesh.studioMaterial)
                        tItem.parts[#tItem.parts].studio.own = true
                    end

                    -- The variant that skins on the GPU from the bones Source loads
                    if tMesh.studioGpuShader then
                        tItem.parts[#tItem.parts].studio.matGpu = RENDER.Material("storm_fx_" .. ENGINE.sVersion .. "_" .. tRuntime.name
                            .. "_" .. sName .. "_" .. iIndex .. "_studio_gpu", {shader = tMesh.studioGpuShader, textures = tMesh.textures}, tState)
                    end

                end

            end

        end

    end

    if #tProblems > 0 then
        tRuntime.unsupported[sName] = table.concat(tProblems, "; ")
    end

    if #tItem.parts > 0 then
        tRuntime.items[sName] = tItem
    end

end

-- One trail ribbon (storm_import.py Importer.ribbon): the shader of key 0x1F007 with the
-- constants of the DrawTrail command, the billboard's texture, its vertices sent with every
-- draw. Layer, light byte and fog follow the billboard's model (the light byte is the game's:
-- 0x141325a50 hands it to the context fill; the layer and the render state are stand-ins).
local function fnAddRibbon(tRuntime, sKey, tDefinition)

    local tDraw = tDefinition.draw
    local tModel = tRuntime.data.models[tDraw.model]
    local tMesh = tDraw.mesh

    local tItem = {
        name = sKey,
        parts = {},
        fogged = ENGINE.tStage.fogLayers[tModel.header.layer] == true,
        light = tModel.header.light,
        layer = tModel.header.layer,
        opacity = 1
    }

    local tAvailable = ENGINE:StageValues(tItem, 1)

    for _, tGroup in ipairs({tMesh.shader.dynamic, tMesh.shader.static}) do
        for _, tEntry in ipairs(tGroup) do
            if tEntry.name ~= "g_multColor" and tEntry.name ~= "g_commonParam" and not tAvailable[tEntry.name] then
                tRuntime.unsupported[sKey] = "the stage has no value for " .. tEntry.name
                return
            end
        end
    end

    local tState = RENDER.State(tMesh.state)
    local matPart = RENDER.Material("storm_fx_" .. ENGINE.sVersion .. "_" .. tRuntime.name .. "_" .. sKey, tMesh, tState)

    tItem.parts[1] = {mesh = tMesh, state = tState, layout = tMesh.shader, ribbon = true, mat = matPart}
    tRuntime.ribbons[tDefinition] = tItem

end

-- The data of a package. It travels as content, data_static/storm_fx/<name>.txt (its Lua
-- source), read through the GAME path and compiled: a client Lua file (AddCSLuaFile) may not
-- exceed 64 KB compressed and a package is hundreds of KB. The Lua file
-- storm_fx/packages/<name>.lua is the fallback (offline checks, development copies).
local function fnReadPackage(sName)

    local sPath = "data_static/storm_fx/" .. sName .. ".txt"
    local sText = file and file.Read and CompileString and file.Read(sPath, "GAME")

    if sText then

        local fnChunk = CompileString(sText, sPath, false)

        if type(fnChunk) ~= "function" then
            error("Storm FX package " .. sName .. " does not compile: " .. tostring(fnChunk))
        end

        return fnChunk(), sPath

    end

    local sLua = "storm_fx/packages/" .. sName .. ".lua"

    if CompileString and file.Exists and not file.Exists(sLua, "LUA") then

        -- In game, without the content: say why rather than let include() fail
        error("package " .. sName .. " is not on this client (" .. sPath .. " missing): the Storm FX content was not "
            .. "downloaded (the Workshop content the server lists, or cl_downloadfilter \"all\" for the files of the server itself)", 0)

    end

    return include(sLua), "lua"

end

-- A package, loaded once: {name, data, source, items (by model), ribbons (by trail
-- definition), unsupported, notes, models (the model particles)}
function ENGINE:LoadPackage(sName)

    local tRuntime = self.tPackages[sName]

    if tRuntime then return tRuntime end

    local tData, sSource = fnReadPackage(sName)
    assert(type(tData) == "table" and tData.format == 1, "Not a storm_import.py package: " .. tostring(sName))

    tRuntime = {
        name = sName,
        data = tData,
        source = sSource,
        items = {},
        ribbons = {},
        unsupported = {},
        notes = {},
        noted = {}
    }

    for sModel, tModel in pairs(tData.models) do
        fnAddModel(tRuntime, sModel, tModel)
    end

    -- The models the host leaves out of the drawing: those of every package ("*"), then this one's
    local tHidden = StormFX.Config["hiddenModels"] or {}

    for _, tModels in ipairs({tHidden["*"] or {}, tHidden[sName] or {}}) do
        for sModel, bHidden in pairs(tModels) do
            if bHidden and tRuntime.items[sModel] then
                tRuntime.items[sModel].hidden = true
            end
        end
    end

    local tAnimations = {}

    for sAnimation in pairs(tData.trails or {}) do
        tAnimations[#tAnimations + 1] = sAnimation
    end

    table.sort(tAnimations)

    for _, sAnimation in ipairs(tAnimations) do
        for iIndex, tDefinition in ipairs(tData.trails[sAnimation]) do
            if tDefinition.draw then
                fnAddRibbon(tRuntime, sAnimation .. "_trail" .. iIndex, tDefinition)
            end
        end
    end

    tRuntime.models = StormFX.Core.ModelParticles.New(tData, self.tAnmModules, self.tAnmOptions)
    self.tPackages[sName] = tRuntime

    return tRuntime

end

-- The stage values are baked into the meshes (TEXCOORD channels): a mesh is rebuilt when the
-- scale (fog distances) or the screen size (g_ScreenToUV) changes
local function fnStaticKey(flScale)
    return flScale .. "|" .. ScrW() .. "x" .. ScrH()
end

-- Release the rigid pieces of a skinned part
local function fnDestroyRigid(tPart)

    for _, tMeshes in pairs(tPart.rigidMeshes or {}) do
        for _, mshPiece in ipairs(tMeshes) do
            mshPiece:Destroy()
        end
    end

    tPart.rigidMeshes = nil

end

ENGINE.DestroyRigid = fnDestroyRigid

-- Build the meshes of an item for a scale
local function fnBuildMeshes(tItem, flScale)

    tItem.stage = ENGINE:StageValues(tItem, flScale)

    for _, tPart in ipairs(tItem.parts) do

        if tPart.buffer then
            tPart.buffer:Destroy()
            tPart.buffer = nil
        end

        fnDestroyRigid(tPart)

        -- A batched part's channels hold per-particle values too: made for each draw
        tPart.static = not tPart.batched and RENDER.Static(tPart.layout, tItem.stage) or nil

        -- A skinned mesh's triangles that hang from one palette entry only, built once
        -- (RENDER.SplitSkinned; Config splitSkinned)
        -- (a mesh whose geometry is only in its studio model, slim_package.py, has none to build)
        if tPart.mesh.skin and not tPart.mesh.stripped and StormFX.Config["splitSkinned"] ~= false then

            tPart.rigidMeshes = {}

            for iBone, tRigid in pairs(RENDER.SplitSkinned(tPart.mesh).rigid) do
                tPart.rigidMeshes[iBone] = RENDER.BuildMeshes(tPart.mat, tRigid, tPart.static)
                ENGINE.iUploads = ENGINE.iUploads + 1
            end

        end

        -- A skinned mesh has no cached buffer: its vertices are skinned on the CPU and sent
        -- with every draw (the game skins into a dynamic buffer too). Neither has a ribbon
        -- (dynamic vertices, 0x141325a50), nor a batched part (its particles' vertices are
        -- sent together every frame).
        if not tPart.mesh.skin and not tPart.mesh.stripped and not tPart.ribbon and not tPart.batched then
            tPart.buffer = RENDER.BuildMesh(tPart.mat, tPart.mesh, tPart.static)
            ENGINE.iUploads = ENGINE.iUploads + 1
        end

    end

    tItem.staticKey = fnStaticKey(flScale)

end

-- Build the meshes that the scale or the screen size made stale
function ENGINE:EnsureMeshes(flScale)

    local sKey = fnStaticKey(flScale)

    for _, tRuntime in pairs(self.tPackages) do

        for _, tItem in pairs(tRuntime.items) do
            if tItem.staticKey ~= sKey then fnBuildMeshes(tItem, flScale) end
        end

        for _, tItem in pairs(tRuntime.ribbons) do
            if tItem.staticKey ~= sKey then fnBuildMeshes(tItem, flScale) end
        end

    end

end

-- Stop every effect and skill script
function ENGINE:StopAll()

    self.tInstances = {}
    self.tCasts = {}
    self.tLights = {}
    self.bListDirty = true

end

-- Stop everything and release the meshes (map change, reload)
function ENGINE:Cleanup()

    self:StopAll()

    -- The draw list in use and its meshes (engine/cl_draw.lua), the client models
    -- (engine/cl_studio.lua)
    if self.ResetDrawList then
        self:ResetDrawList()
    end

    if self.RemoveStudioModels then
        self:RemoveStudioModels()
    end

    for _, tRuntime in pairs(self.tPackages) do

        for _, tItem in pairs(tRuntime.items) do

            for _, tPart in ipairs(tItem.parts) do

                if tPart.buffer then
                    tPart.buffer:Destroy()
                    tPart.buffer = nil
                end

                fnDestroyRigid(tPart)

            end

            tItem.staticKey = nil

        end

        for _, tItem in pairs(tRuntime.ribbons) do
            tItem.staticKey = nil
        end

    end

end

-- Get ready to play at a scale: a new scale stops what plays at the old one
function ENGINE:Begin(flScale)

    if self.flScale ~= flScale then
        self:StopAll()
    end

    self.flScale = flScale
    self:EnsureMeshes(flScale)

end
