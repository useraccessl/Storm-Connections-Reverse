-- Skinned meshes drawn as Source studio models (export_studio.py): the mesh, its skeleton and
-- the animation that drives it, baked as a sequence (one frame per 50 ticks). Source skins the
-- vertices, nothing is done per vertex in Lua. A copy's pose is its animation's clock: the
-- sequence's cycle. One client model per .mdl draws every copy, one after the other (its
-- cycle and its matrix are set before each draw).
-- Used when Config useStudioModels is not false and the game has ClientsideModel (not in the
-- offline checks: the engine then draws the mesh itself, RENDER.SplitSkinned).

local ENGINE = StormFX.Engine

-- The client model of each .mdl
ENGINE.tStudioModels = ENGINE.tStudioModels or {}

-- Whether studio models are drawn
function ENGINE:StudioAvailable()
    return ClientsideModel ~= nil and StormFX.Config["useStudioModels"] ~= false
end

-- The particles of an animated resource the package has as a studio model only advance their
-- clock (StormFX.Core.ModelParticles): asked at every update
ENGINE.tAnmOptions.studioEnabled = function()
    return ENGINE:StudioAvailable()
end

-- The studio models of an animated resource of a package (storm_import.py studio_resources),
-- made once: one per render state of its meshes (a DrawModel draws with one blend state),
-- each with its parts: their engine part (constants), the material the .mdl names (the
-- mesh's .vmt, or the draw's own), and the values per frame. false when a part is missing.
function ENGINE:StudioResource(tRuntime, sResource)

    tRuntime.studioResources = tRuntime.studioResources or {}

    local tStudios = tRuntime.studioResources[sResource]

    if tStudios ~= nil then return tStudios end

    local tData = tRuntime.data
    local tSource = tData.resources[sResource].studio

    tStudios = {}

    for iGroup, sModel in ipairs(tSource.mdls or {tSource.mdl}) do
        tStudios[iGroup] = {mdl = sModel, animation = tSource.animation, duration = tSource.duration,
            ticksPerFrame = tSource.ticksPerFrame, frames = tSource.frames, own = true, parts = {}}
    end

    for _, tSourcePart in ipairs(tSource.parts) do

        local tItem = tRuntime.items[tSourcePart.model]
        local tMesh = tData.models[tSourcePart.model].meshes[tSourcePart.mesh]
        local tPart

        for _, tCandidate in ipairs(tItem and tItem.parts or {}) do
            if tCandidate.mesh == tMesh then
                tPart = tCandidate
            end
        end

        local tStudio = tStudios[tSourcePart.group or 1]

        if not tPart or not tMesh.studioMaterial or not tStudio then
            tStudios = false
            break
        end

        tStudio.parts[#tStudio.parts + 1] = {draw = tSourcePart.draw, item = tItem, part = tPart,
            mat = Material(tSourcePart.material or tMesh.studioMaterial)}

    end

    tRuntime.studioResources[sResource] = tStudios

    return tStudios

end

-- The client model of a .mdl, made the first time (nil when it cannot be)
local function fnModelOf(tStudio)

    local eModel = ENGINE.tStudioModels[tStudio.mdl]

    if IsValid(eModel) then return eModel end

    eModel = ClientsideModel(tStudio.mdl, RENDERGROUP_OTHER)

    if not IsValid(eModel) then return nil end

    eModel:SetNoDraw(true)
    eModel:SetPos(vector_origin)
    eModel:SetAngles(angle_zero)
    eModel:SetRenderBounds(Vector(-100000, -100000, -100000), Vector(100000, 100000, 100000))
    eModel:SetPlaybackRate(0)

    eModel.stormSequence = eModel:LookupSequence(tStudio.animation)

    if not eModel.stormSequence or eModel.stormSequence < 0 then
        ErrorNoHalt("StormFX: " .. tStudio.mdl .. " has no sequence " .. tostring(tStudio.animation) .. "\n")
        eModel.stormSequence = 0
    end

    eModel:ResetSequence(eModel.stormSequence)
    ENGINE.tStudioModels[tStudio.mdl] = eModel

    return eModel

end

-- Draw one copy: tStudio (the part's), the cycle, the model matrix (VMatrix: the draw matrix
-- of the skinned mesh, in which the .mdl is modelled). The material is the part's studio
-- variant, its pixel constants set by the caller (RENDER.Apply): the model's own .vmt
-- (tStudio.own), else a Lua material put over the model (an in-game test drew nothing so).
function ENGINE:DrawStudio(tStudio, flCycle, mTransform)

    local eModel = fnModelOf(tStudio)

    if not eModel then return false end

    eModel:SetSequence(eModel.stormSequence)
    eModel:SetCycle(math.Clamp(flCycle, 0, 1))
    eModel:EnableMatrix("RenderMultiply", mTransform)
    eModel:InvalidateBoneCache()
    eModel:SetupBones()

    -- A model drawn with its own material (the .vmt it names) needs no override
    if tStudio.own then
        eModel:DrawModel()
    else
        render.MaterialOverride(tStudio.mat)
        eModel:DrawModel()
        render.MaterialOverride(nil)
    end

    return true

end

-- Remove the client models (map change, reload)
function ENGINE:RemoveStudioModels()

    for sModel, eModel in pairs(self.tStudioModels) do

        if IsValid(eModel) then
            eModel:Remove()
        end

        self.tStudioModels[sModel] = nil

    end

end
