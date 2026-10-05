-- storm_fx_studiotest <package> <model> [mode]: draw a studio model of a package (export_studio.py)
-- where the player looks, for ten seconds, its sequence playing, to see which step fails:
--   mode 0: the model as Source draws it, its own (missing) material: the checkerboard if the
--           model loads, its bones and sequence play
--   mode 1: the same with the part's shader variant (MaterialOverride), no constants set
--   mode 2: the same with its constants and the effect's render state (as the engine does)
--   mode 3: as 2, the variant given to the model with SetMaterial (its own material: Source
--           chooses how to skin from it, $softwareskin) instead of MaterialOverride
--   mode 4: as 3, with a copy of the variant that culls nothing
--   mode 5: as 3, with the variant whose vertex shader skins on the GPU ($softwareskin 0)
--   mode 6: the model's own material (the .vmt it names, as the engine draws it), with its
--           constants and the effect's render state; mode 0 shows it without the constants
--   mode 7: as 6, the model placed as King places his (SetPos, SetModelScale), not through
--           EnableMatrix("RenderMultiply")
-- The console gets what was found: the file, the client model, the sequence, the bounds.

local ENGINE = StormFX.Engine

local tTest
local fnDraw

local function fnReport(sText)
    print("[StormFX] studiotest: " .. sText)
end

concommand.Add("storm_fx_studiotest", function(pPlayer, _, tArgs)

    local sPackage, sModel, iMode = tArgs[1], tArgs[2], tonumber(tArgs[3]) or 2

    if not sPackage or not sModel then
        print("storm_fx_studiotest <package> <model> [mode 0..6] [skinning variant a..d]")
        return
    end

    local bOk, tRuntime = pcall(ENGINE.LoadPackage, ENGINE, sPackage)

    if not bOk then
        fnReport("package not loaded: " .. tostring(tRuntime))
        return
    end

    local tItem = tRuntime.items[sModel]
    local tPart

    for _, tCandidate in ipairs(tItem and tItem.parts or {}) do
        if tCandidate.studio then
            tPart = tCandidate
        end
    end

    if not tPart then
        fnReport(sModel .. " has no part with a studio model in " .. sPackage)
        return
    end

    local tStudio = tPart.studio

    -- A skinning test variant (skin_variants.py): its copy of the model and its own material
    local sVariant = tArgs[4]
    local sModelPath = sVariant and string.gsub(tStudio.mdl, "%.mdl$", "_" .. sVariant .. ".mdl") or tStudio.mdl

    fnReport("file " .. sModelPath .. ": exists " .. tostring(file.Exists(sModelPath, "GAME"))
        .. ", util.IsValidModel " .. tostring(util.IsValidModel(sModelPath)))

    if tTest and IsValid(tTest.model) then
        tTest.model:Remove()
    end

    local eModel = ClientsideModel(sModelPath, RENDERGROUP_OTHER)

    if not IsValid(eModel) then
        fnReport("ClientsideModel failed")
        return
    end

    eModel:SetNoDraw(true)

    local iSequence = eModel:LookupSequence(tStudio.animation)
    local vecMins, vecMaxs = eModel:GetModelBounds()

    fnReport("client model " .. tostring(eModel:GetModel()) .. ", sequence " .. tostring(tStudio.animation) .. " = " .. tostring(iSequence)
        .. " of " .. tostring(eModel:GetSequenceCount()) .. ", bones " .. tostring(eModel:GetBoneCount())
        .. ", bounds " .. tostring(vecMins) .. " .. " .. tostring(vecMaxs))
    fnReport("material " .. tStudio.mat:GetName() .. " (shader " .. tostring(tStudio.mat:GetShader()) .. "), mode " .. iMode)

    eModel:ResetSequence(math.max(iSequence, 0))
    eModel:SetPlaybackRate(0)

    -- Modes 3 to 5: the variant as the model's own material; a skinning test variant's own
    local matTest = iMode == 5 and tStudio.matGpu or tStudio.mat

    if sVariant then
        matTest = Material("storm_fx/studio_" .. sVariant .. "/" .. sModel .. "_mesh1")
        fnReport("variant " .. sVariant .. ": material " .. matTest:GetName() .. ", vertex shader "
            .. tostring(matTest:GetString("$vertexshader")) .. ", error " .. tostring(matTest:IsError()))
    end

    if not matTest then
        fnReport("no GPU-skinned variant in this package")
        eModel:Remove()
        return
    end

    if iMode == 4 then

        local tKeys = matTest:GetKeyValues()
        local tParams = {}

        for sKey, value in pairs(tKeys) do
            if type(value) == "string" or type(value) == "number" then
                tParams[sKey] = tostring(value)
            elseif type(value) == "ITexture" then
                tParams[sKey] = value:GetName()
            end
        end

        tParams["$cull"] = "0"
        tParams["$softwareskin"] = "1"
        matTest = CreateMaterial(matTest:GetName() .. "_nocull", "screenspace_general", tParams)

    end

    if iMode == 6 or iMode == 7 then
        fnReport("own material " .. tostring(tStudio.own) .. ": " .. matTest:GetName() .. " (shader " .. tostring(matTest:GetShader())
            .. ", error " .. tostring(matTest:IsError()) .. "), model materials " .. table.concat(eModel:GetMaterials(), ", "))
    elseif iMode >= 3 then
        eModel:SetMaterial("!" .. matTest:GetName())
        -- GetInt returns nothing at all for a parameter the shader does not have
        fnReport("SetMaterial !" .. matTest:GetName() .. " ($cull " .. tostring((matTest:GetInt("$cull"))) .. ", $softwareskin "
            .. tostring((matTest:GetInt("$softwareskin"))) .. ")")
    end

    local tTrace = pPlayer:GetEyeTrace()

    -- The stage values the constants fall back on (built with the meshes)
    ENGINE:EnsureMeshes(StormFX.Config["scale"])

    tTest = {model = eModel, part = tPart, item = tItem, studio = tStudio, mode = iMode, start = CurTime(), mat = matTest,
        pos = tTrace.HitPos + Vector(0, 0, 10), sequence = math.max(iSequence, 0)}

    hook.Add("PostDrawTranslucentRenderables", "StormFX:StudioTest:Draw", fnDraw)

end)

-- Hooked while a test runs only
function fnDraw(bDepth, bSky)

    if not tTest or bDepth or bSky then return end

    local eModel = tTest.model

    if not IsValid(eModel) or CurTime() - tTest.start > 10 then

        if IsValid(eModel) then
            eModel:Remove()
        end

        tTest = nil
        hook.Remove("PostDrawTranslucentRenderables", "StormFX:StudioTest:Draw")

        return

    end

    -- The model at the default scale, its sequence over its duration
    local flScale = StormFX.Config["scale"]

    eModel:SetSequence(tTest.sequence)
    eModel:SetCycle(((CurTime() - tTest.start) * 3000 / tTest.studio.duration) % 1)

    if tTest.mode == 7 then

        eModel:SetPos(tTest.pos)
        eModel:SetAngles(angle_zero)
        eModel:SetModelScale(flScale, 0)

    else

        local mTransform = Matrix()

        mTransform:SetTranslation(tTest.pos)
        mTransform:Scale(Vector(flScale, flScale, flScale))
        eModel:EnableMatrix("RenderMultiply", mTransform)

    end

    eModel:InvalidateBoneCache()
    eModel:SetupBones()

    local tPart = tTest.part

    if tTest.mode >= 2 then

        -- As engine/cl_draw.lua fnSubmit fills them: white, opaque, the material's own instance
        local RENDER = StormFX.Render
        local tInstance = tPart.instance
        local tValues = {g_multColor = {1, 1, 1, 1}, g_commonParam = {tInstance[0x80], 1, 0, tInstance[0x7c]},
            g_blendRate = {tInstance[0x70], tInstance[0x74], 0, 0}, g_olIdParam = {tInstance[0x84] / 255, 0, 0, 0}}

        for sName, tAt in pairs(ENGINE.INSTANCE_FIELDS) do
            tValues[sName] = {tInstance[tAt[1]], tInstance[tAt[2]], tInstance[tAt[3]], tInstance[tAt[4]]}
        end

        local tPacked = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}

        setmetatable(tValues, {__index = tTest.item.stage or {}})
        RENDER.PackInto(tPart.studio.layout, tValues, tPacked)
        RENDER.Apply(tTest.mat, tPacked)
        RENDER.Begin(tPart.state)

    end

    if tTest.mode == 1 or tTest.mode == 2 then
        render.MaterialOverride(tTest.studio.mat)
    end

    eModel:DrawModel()

    render.MaterialOverride(nil)

    if tTest.mode >= 2 then
        StormFX.Render.Finish()
    end

end
