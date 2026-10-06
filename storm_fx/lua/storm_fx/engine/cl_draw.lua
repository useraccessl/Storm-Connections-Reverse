-- Drawing. The draw list of a frame is built once (FrameNumber) from the main camera: the
-- models each effect's animation carries, its particles (billboards, clumps, animated
-- resources) and its trail ribbons, sorted as the game sorts them. It is then drawn in every
-- view the hook runs for (the main view, the water's reflection / refraction, other render
-- targets). Offline (no FrameNumber) it is built at every call.

local ENGINE = StormFX.Engine
local CORE = StormFX.Core
local RENDER = StormFX.Render
local STAGE_POST = StormFX.StagePost
local SECTIONS = StormFX.Sections

local INSTANCE_FIELDS = ENGINE.INSTANCE_FIELDS

-- Whether the sections of this hook call are timed (storm_fx_sections, engine/cl_sections.lua)
local bTimed = false
local SysTime = SysTime

-- Add the time since flFrom to a section, and give the time now
local function fnLap(sName, flFrom)

    local flNow = SysTime()

    SECTIONS:Add(sName, flNow - flFrom)

    return flNow

end

local fnFloat32 = ENGINE.Float32
local fnUnpack = unpack or table.unpack

-- Context of a draw when the host gives none
local NO_CONTEXT = {}

-- The water's reflection and refraction views (drawn before the main view on a map with water
-- in sight): the effects are left out of them unless storm_fx_water_views is 1 (they then show
-- in the water's reflection, at the cost of two more passes of draws)
local WATER_VIEWS = {["_rt_waterreflection"] = true, ["_rt_waterrefraction"] = true}

local cvWaterViews = CreateClientConVar and CreateClientConVar("storm_fx_water_views", "0", true, false,
    "Storm FX: also draw the effects in the water reflection / refraction views (costs two more passes)")

-- The constant values of one part, refilled in place for every part (RENDER.Pack copies the
-- numbers out at once): no tables made per part. Its metatable falls back on the item's stage
-- values; the optional keys are cleared before each part.
local tScratch = {g_multColor = {0, 0, 0, 1}, g_commonParam = {0, 0, 0, 0}, g_blendRate = {0, 0, 0, 0}, g_olIdParam = {0, 0, 0, 0}}

for sName in pairs(INSTANCE_FIELDS) do
    tScratch[sName] = {0, 0, 0, 0}
end

local tScratchMeta = {}
setmetatable(tScratch, tScratchMeta)

-- The camera of the draw list being built: its basis (right, up, right x up), its position and
-- its forward axis, also as plain numbers (a GMod Vector operation is a C call and a new object)
local vecRight, vecUp, vecNormal
local rx, ry, rz, ux, uy, uz, nx, ny, nz
local ex, ey, ez, kx, ky, kz

-- The clock of the screen scroll shared by the draws of a list
local flSharedClock

-- The draw list and its entries are kept from frame to frame and refilled in place: a frame
-- makes no table for its draws (Lua's garbage collector was the cause of the worst frames).
-- tPool holds every entry made so far, tEntries the list being built (sorted afterwards).
local tPool = {}
local tEntries = {}
local iEntries = 0

-- Untinted
local WHITE = {1, 1, 1}

-- Scratch tables refilled for each draw (fnSubmit copies what it keeps)
local tModelWorld = {}
local tBillboardWorld = {}
local tBillboardFrame = {uv = {0, 0, 0, 0}}
local tBillboardKeys = {}
local tTrailKeys = {}
local NO_KEYS = {}

-- The constant values of a trail ribbon, refilled for each ribbon; its metatable falls back on
-- the item's stage values. g_multColor is the colour of the trail thread's render context
-- (+80, not traced): white. g_commonParam.w is billboard +2F0 (channel 9), unread by 0x1F007.
local tRibbonValues = {g_multColor = {1, 1, 1, 1}, g_commonParam = {1.1754943508222875e-38, 1, 1, 0}}
local tRibbonMeta = {}
setmetatable(tRibbonValues, tRibbonMeta)

-- The next entry of the list being built
local function fnNewEntry()

    iEntries = iEntries + 1

    local tEntry = tPool[iEntries]

    if not tEntry then
        tEntry = {world = {}, packed = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}}
        tPool[iEntries] = tEntry
    end

    tEntries[iEntries] = tEntry

    return tEntry

end

-- Copy a 4x4 matrix (16 numbers) into another table
local function fnCopyMatrix(tFrom, tTo)

    for i = 1, 16 do
        tTo[i] = tFrom[i]
    end

end

-- Count what could not be drawn (storm_fx_diag)
local function fnSkip(sName)
    ENGINE.tSkipped[sName] = (ENGINE.tSkipped[sName] or 0) + 1
end

-- Camera-facing hook of a model whose header attribute bit 0 is set (StormFX.Core.Facing): the
-- camera basis (right, up, right x up) is the one the captured camera-facing draws have.
-- tWorld is in GMod space (outer x game matrix), so a billboard's offset goes through outer's
-- linear part.
local function fnFacing(tWorld, tBoard, tOuter)

    if tBoard then
        return CORE.Facing.Billboard(tWorld, tBoard, vecRight, vecUp, vecNormal, tOuter, fnFloat32)
    end

    return CORE.Facing.Model(tWorld, vecRight, vecUp, vecNormal)

end

-- The constant values of one part of a model draw, in the scratch table (valid until the next
-- call). tSlot: the model's point light slot so far (worked out for the first part that reads
-- it); returns the values and the slot.
local function fnPartValues(tItem, tPart, tWorld, tFrame, tColor, flAlpha, tAnimated, tContext, tSlot)

    -- Material instance: the animated one, else the material's own (binder 0x1412f5ff0
    -- reads g_uvOffset0..3, g_blendRate, the alpha threshold and g_commonParam.w from it,
    -- then the screen scroll from its uv2 / uv3 scales)
    local tAnimatedInstance = tAnimated and tAnimated[tPart.materialIndex]
    local tMaterial = tAnimatedInstance or tPart.instance
    local tValues = tScratch

    tScratchMeta.__index = tItem.stage
    tValues.g_pointLightColor0, tValues.g_pointLightPos0, tValues.g_pointLightParam0, tValues.g_uvOffsetScreen = nil, nil, nil, nil

    local tValue = tValues.g_multColor
    tValue[1], tValue[2], tValue[3] = tColor[1], tColor[2], tColor[3]

    tValue = tValues.g_commonParam
    tValue[1], tValue[2], tValue[4] = tFrame and tFrame.threshold or tMaterial[0x80], flAlpha, tMaterial[0x7c]

    tValue = tValues.g_blendRate
    tValue[1], tValue[2] = tMaterial[0x70], tMaterial[0x74]

    tValues.g_olIdParam[1] = tMaterial[0x84] / 255

    for sName, tAt in pairs(INSTANCE_FIELDS) do
        tValue = tValues[sName]
        tValue[1], tValue[2], tValue[3], tValue[4] = tMaterial[tAt[1]], tMaterial[tAt[2]], tMaterial[tAt[3]], tMaterial[tAt[4]]
    end

    if tPart.overrideX then
        tValues.g_uvOffset2[1] = tMaterial[0x78]
    end

    if tFrame and tFrame.uv then
        local tUV = tFrame.uv
        tValue = tValues.g_uvOffset0
        tValue[1], tValue[2], tValue[3], tValue[4] = tUV[1], tUV[2], tUV[3], tUV[4]
    end

    if tPart.lit then
        tSlot = tSlot or ENGINE:LightSlot({tWorld[4], tWorld[8], tWorld[12]}, tItem.light)
        tValues.g_pointLightColor0, tValues.g_pointLightPos0, tValues.g_pointLightParam0 = tSlot.color, tSlot.position, tSlot.param
    end

    if tPart.scrolls then

        local flClock = tContext.clockSeconds or flSharedClock

        if tContext.scroll then

            tValues.g_uvOffsetScreen = tContext.scroll

        elseif tAnimatedInstance then

            tValues.g_uvOffsetScreen = CORE.MaterialContext.ScreenScroll({
                scroll0 = {0, 0, tAnimatedInstance[0x60], tAnimatedInstance[0x64]},
                scroll1 = {0, 0, tAnimatedInstance[0x68], tAnimatedInstance[0x6c]}
            }, flClock)

        else

            if tPart.lastClock ~= flClock then

                tPart.lastScroll = CORE.MaterialContext.ScreenScroll({
                    scroll0 = {0, 0, tMaterial[0x60], tMaterial[0x64]},
                    scroll1 = {0, 0, tMaterial[0x68], tMaterial[0x6c]}
                }, flClock)

                tPart.lastClock = flClock

            end

            tValues.g_uvOffsetScreen = tPart.lastScroll

        end

    end

    return tValues, tSlot

end

-- One draw of a model: every part gets the constants its layout asks for.
-- tFrame: billboard keys {uv = atlas rectangle, threshold = alpha threshold}, or nil.
-- tAnimated: the material instances an animation drives (index in the model's material list ->
-- fields by binder offset), or nil.
-- tDraw: the resolved model draw (models only); it carries the skinning palette of a skinned
-- model and keeps the skinned vertices until the next update.
local function fnSubmit(tInstance, tItem, tWorld, tFrame, tColor, flAlpha, tAnimated, tParticle, tDraw)

    if tDraw and tDraw.hidden then return end

    -- A model the host left out (Config hiddenModels)
    if tItem.hidden then return end

    -- A host binder can supply the scrolling through this hook
    local tContext = ENGINE.ShaderContext and ENGINE.ShaderContext(tInstance, tParticle, tItem) or NO_CONTEXT
    local flDepth = (tWorld[4] - ex) * kx + (tWorld[8] - ey) * ky + (tWorld[12] - ez) * kz

    -- Point light slot 0 of this model, worked out for the first part that reads it
    local tSlot

    for iIndex, tPart in ipairs(tItem.parts) do

        -- A skinned part the package has as a studio model, posed by the animation baked into
        -- its sequence (engine/cl_studio.lua)
        local tStudio = tPart.studio and tDraw and tDraw.palette and tDraw.poseName == tPart.studio.animation
            and ENGINE:StudioAvailable() and tPart.studio or nil

        -- A mesh whose geometry is only in its studio model (slim_package.py) is drawn by it
        -- or not at all
        if tStudio or not tPart.mesh.stripped then

            local tValues
            tValues, tSlot = fnPartValues(tItem, tPart, tWorld, tFrame, tColor, flAlpha, tAnimated, tContext, tSlot)

            local tSkinned

            -- A split skinned part (Config splitSkinned) is skinned when the list's meshes are built
            local bSplit = not tStudio and tPart.rigidMeshes ~= nil and tDraw ~= nil and tDraw.palette ~= nil

            if tPart.mesh.skin and tDraw and tDraw.palette and not bSplit and not tStudio then

                tDraw.skinned = tDraw.skinned or {}
                tSkinned = tDraw.skinned[iIndex]

                if not tSkinned then

                    local tPositions, tNormals = CORE.Skinning.Mesh(tPart.mesh, tDraw.palette, ENGINE.Plain)

                    tSkinned = {positions = tPositions, normals = tNormals}
                    tDraw.skinned[iIndex] = tSkinned
                    ENGINE.iSkinnedVertices = ENGINE.iSkinnedVertices + #tPositions

                end

            end

            local tEntry = fnNewEntry()

            tEntry.item = tItem
            tEntry.part = tPart
            tEntry.state = tPart.state
            tEntry.layer = tItem.layer
            tEntry.depth = flDepth
            tEntry.skinned = tSkinned
            tEntry.ribbon = nil
            tEntry.cachedRibbon = nil
            tEntry.batched = tPart.batched
            tEntry.split = bSplit and tDraw or nil
            tEntry.studio = tStudio
            tEntry.studioParticle = nil
            tEntry.studioCycle = tStudio and tDraw.poseTicks / tStudio.duration or nil

            fnCopyMatrix(tWorld, tEntry.world)

            -- A batched part carries its values in its vertices, the others in the pixel constants
            if tPart.batched then
                tEntry.static = RENDER.StaticInto(tPart.layout, tValues, tEntry.static or {})
            else
                RENDER.PackInto(tPart.layout, tValues, tEntry.packed)
            end

        end

    end

end

-- The models the effect's own animation carries: drawn at their animated coordinate, untinted,
-- with the coordinate's animated opacity, while the animation runs (a one-shot effect's models
-- are not held after its last frame, a killed effect's models go at once: host choices, the
-- particles already born play on as in the captures)
local function fnAddAnimationModels(tInstance, tOuter)

    local tRuntime = tInstance.runtime
    local tResult = tInstance.provider.result

    if not tResult or tInstance.killed or not (tInstance.loop or tInstance.ticks < tInstance.duration) then return end

    -- A host edit of the package: the effect's own models are no longer drawn from a time on
    local tEdit = tRuntime.data.edits and tRuntime.data.edits[tInstance.effect]

    if tEdit and tEdit.hideAfterTicks and tInstance.ticks >= tEdit.hideAfterTicks then return end

    for _, tRootDraw in ipairs(tInstance.modelDraws) do

        local tItem = tRuntime.items[tRootDraw.model]

        if not tItem then

            fnSkip(tRootDraw.model)

        else

            -- Resolved once per update of the effect (a skinned model keeps its skinned
            -- vertices until the animation moves again)
            tInstance.resolved = tInstance.resolved or {}

            local tKept = tInstance.resolved[tRootDraw]

            if not tKept or tKept.ticks ~= tInstance.ticks then
                tKept = {ticks = tInstance.ticks, draw = tRuntime.models.Resolve(tRootDraw, tResult, tInstance.root, tInstance.ticks)}
                tInstance.resolved[tRootDraw] = tKept
            end

            local tDraw = tKept.draw

            -- A skinned model of the effect's own animation: its pose is the animation's at
            -- these ticks (see the skinned meshes of a draw list)
            if tDraw.palette and not tDraw.poseAnimation then
                tDraw.poseAnimation, tDraw.poseTicks = tRootDraw, tInstance.ticks
            end

            local tWorld = tRuntime.models:World(tDraw.matrix, tOuter, tModelWorld)

            if tItem.facing then
                tWorld = fnFacing(tWorld, tDraw.billboard, tOuter)
            end

            fnSubmit(tInstance, tItem, tWorld, nil, WHITE, (tDraw.opacity or tItem.opacity) * (tDraw.alphaScale or 1), tDraw.instances, nil, tDraw)

        end

    end

end

-- A billboard particle: its origin is the particle position through outer (yaw, scale,
-- position); its axes are the camera's right / up turned by the roll and scaled by the size,
-- and the camera normal
local function fnAddBillboard(tInstance, tOuter, tParticle, tResource)

    local tItem = tInstance.runtime.items[tResource.model]

    if not tItem then
        fnSkip(tParticle.resource)
        return
    end

    local tKeys = CORE.Curves.BillboardFromParticle(tResource.billboard, tParticle.ageTicks, tBillboardKeys)

    -- Billboard channels 5 / 6 replace the atlas offset / size of UV set 0 (else the
    -- material's own), channel 12 the alpha threshold
    local tBase = tItem.parts[1].instance
    local tFrame = tBillboardFrame
    local tUV = tFrame.uv

    if tKeys[5] then
        tUV[1], tUV[2] = tKeys[5][1], tKeys[5][2]
    else
        tUV[1], tUV[2] = tBase[0x30], tBase[0x34]
    end

    if tKeys[6] then
        tUV[3], tUV[4] = tKeys[6][1], tKeys[6][2]
    else
        tUV[3], tUV[4] = tBase[0x50], tBase[0x54]
    end

    tFrame.threshold = tKeys[12] and tKeys[12][1] / 255 or nil

    local x, y, z = tParticle.position[1], tParticle.position[2], tParticle.position[3]
    local px, py, pz = tOuter[1] * x + tOuter[2] * y + tOuter[4], tOuter[5] * x + tOuter[6] * y + tOuter[8], tOuter[11] * z + tOuter[12]

    local flRoll = CORE.Billboard.Roll(tParticle.rotation[2], fnFloat32)
    local flRollCos, flRollSin = math.cos(flRoll), math.sin(flRoll)

    local flScale = tInstance.outer.scale
    local k1, k2, k3 = tParticle.size[1] * flScale, tParticle.size[2] * flScale, flScale

    local tWorld = tBillboardWorld

    tWorld[1], tWorld[2], tWorld[3], tWorld[4] = (rx * flRollCos + ux * flRollSin) * k1, (ux * flRollCos - rx * flRollSin) * k2, nx * k3, px
    tWorld[5], tWorld[6], tWorld[7], tWorld[8] = (ry * flRollCos + uy * flRollSin) * k1, (uy * flRollCos - ry * flRollSin) * k2, ny * k3, py
    tWorld[9], tWorld[10], tWorld[11], tWorld[12] = (rz * flRollCos + uz * flRollSin) * k1, (uz * flRollCos - rz * flRollSin) * k2, nz * k3, pz
    tWorld[13], tWorld[14], tWorld[15], tWorld[16] = 0, 0, 0, 1

    fnSubmit(tInstance, tItem, tWorld, tFrame, tParticle.color, (tKeys[4] and tKeys[4][1] or 1) * tParticle.alpha, nil, tParticle)

end

-- A particle of an animated resource drawn as its studio model (engine/cl_studio.lua): one
-- entry, every part's constants as fnSubmit makes them, from the values baked for the frame of
-- the particle's clock (its opacity, its animated material instances), untinted
local function fnAddStudioParticle(tInstance, tOuter, tParticle, tStudio)

    local tPose = tParticle.studioPose
    local iFrame = math.min(#tStudio.frames, math.floor(tPose.ticks / tStudio.ticksPerFrame) + 1)
    local tValuesOfFrame = tStudio.frames[iFrame]
    local tWorld = tInstance.runtime.models:World(tPose.matrix, tOuter, tModelWorld)
    local tFirst = tStudio.parts[1]

    if tFirst.item.hidden then return end

    local tContext = ENGINE.ShaderContext and ENGINE.ShaderContext(tInstance, tParticle, tFirst.item) or NO_CONTEXT
    local tEntry = fnNewEntry()

    tEntry.item = tFirst.item
    tEntry.part = tFirst.part
    tEntry.state = tFirst.part.state
    tEntry.layer = tFirst.item.layer
    tEntry.depth = (tWorld[4] - ex) * kx + (tWorld[8] - ey) * ky + (tWorld[12] - ez) * kz
    tEntry.skinned, tEntry.ribbon, tEntry.cachedRibbon, tEntry.batched, tEntry.split, tEntry.studio = nil, nil, nil, false, nil, nil
    tEntry.studioParticle = tStudio
    tEntry.studioCycle = tPose.ticks / tStudio.duration
    tEntry.studioPacked = tEntry.studioPacked or {}

    fnCopyMatrix(tWorld, tEntry.world)

    local tSlot

    for i, tStudioPart in ipairs(tStudio.parts) do

        local flOpacity = tValuesOfFrame.opacity[tStudioPart.draw] or tStudioPart.item.opacity
        local tValues

        tValues, tSlot = fnPartValues(tStudioPart.item, tStudioPart.part, tWorld, nil, WHITE, tParticle.alpha * flOpacity,
            tValuesOfFrame.instances[tStudioPart.draw], tContext, tSlot)

        tEntry.studioPacked[i] = tEntry.studioPacked[i] or {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
        RENDER.PackInto(tStudioPart.part.layout, tValues, tEntry.studioPacked[i])

    end

end

-- The models of a clump or animated resource particle. The node opacity scales the alpha of a
-- model: the nuccChunkCoord value for a clump, the animated value for an animated resource
-- (billboards get it through billboard channel 4). An animated resource is drawn untinted
-- (the captured g_multColor is 1, 1, 1, 1 for amt15).
local function fnAddModelParticle(tInstance, tOuter, tParticle, tResource)

    local tRuntime = tInstance.runtime

    -- A resource drawn as its studio model: not on the frame the particle is born (as Draws)
    if tParticle.studioPose then

        local tStudios = tParticle.modelEnabled and tParticle.modelUpdates >= 2 and ENGINE:StudioAvailable()
            and ENGINE:StudioResource(tRuntime, tParticle.resource)

        -- One model per render state of the resource's meshes
        for _, tStudio in ipairs(tStudios or NO_KEYS) do
            fnAddStudioParticle(tInstance, tOuter, tParticle, tStudio)
        end

        return

    end

    for _, tDraw in ipairs(tRuntime.models:Draws(tParticle) or {}) do

        local tItem = tRuntime.items[tDraw.model]

        if not tItem then

            fnSkip(tDraw.model)

        else

            local tWorld = tRuntime.models:World(tDraw.matrix, tOuter, tModelWorld)

            if tItem.facing then
                tWorld = fnFacing(tWorld, tDraw.billboard, tOuter)
            end

            fnSubmit(tInstance, tItem, tWorld, nil, tResource.kind == "anm" and WHITE or tParticle.color,
                tParticle.alpha * (tDraw.opacity or tItem.opacity) * (tDraw.alphaScale or 1), tDraw.instances, tParticle, tDraw)

        end

    end

end

-- The particles of an effect
local function fnAddParticles(tInstance, tOuter)

    local tResources = tInstance.runtime.data.resources

    -- A host edit of the package: from a time on, only the particles of the resources it keeps
    local tEdit = tInstance.runtime.data.edits and tInstance.runtime.data.edits[tInstance.effect]
    local tKeep = tEdit and tEdit.hideAfterTicks and tInstance.ticks >= tEdit.hideAfterTicks and (tEdit.hideKeep or NO_KEYS) or nil

    for _, tParticle in ipairs(tInstance.scene and tInstance.scene.particles or {}) do

        -- A particle of an emitter without a resource carries nothing to draw
        local tResource = tParticle.resource and tResources[tParticle.resource] or {}

        if tKeep and not tKeep[tParticle.resource] then
            -- Hidden by the edit
        elseif tResource.kind == "billboard" then
            fnAddBillboard(tInstance, tOuter, tParticle, tResource)
        elseif tResource.kind == "clump" or tResource.kind == "anm" then
            fnAddModelParticle(tInstance, tOuter, tParticle, tResource)
        elseif tParticle.resource then
            fnSkip(tParticle.resource)
        end

    end

end

-- Trail ribbons (0x141325a50 then DrawTrail 0x141389f40): world-space vertices under the
-- identity, the UVs of the billboard's frame (copied during the last update, then its clock
-- advanced: BillboardFromParticle), sorted on the mean of the vertex positions (renderer
-- 0x141248b70, flag bit 18 clear)
-- The ribbons of recorded trails (engine/cl_replay.lua), by recorded trail: built once in
-- the effect's space, drawn under each copy's outer matrix. {mesh, x, y, z (the mean of the
-- vertices), w (g_commonParam.w), vertices, used (the list that last drew it)}
local tRibbonCache = {}
local iCachedVertices = 0
local iListSerial = 0

local function fnClearRibbonCache()

    for tRecorded, tKept in pairs(tRibbonCache) do

        if tKept.mesh then
            tKept.mesh:Destroy()
        end

        tRibbonCache[tRecorded] = nil

    end

    iCachedVertices = 0

end

-- Drop the ribbons drawn longest ago until the cache holds a quarter less than its budget
local function fnTrimRibbonCache(iBudget)

    if iCachedVertices <= iBudget then return end

    local tOld = {}

    for tRecorded, tKept in pairs(tRibbonCache) do
        if tKept.used < iListSerial then
            tOld[#tOld + 1] = tRecorded
        end
    end

    table.sort(tOld, function(tA, tB) return tRibbonCache[tA].used < tRibbonCache[tB].used end)

    for _, tRecorded in ipairs(tOld) do

        if iCachedVertices <= iBudget * 0.75 then break end

        local tKept = tRibbonCache[tRecorded]

        if tKept.mesh then
            tKept.mesh:Destroy()
        end

        iCachedVertices = iCachedVertices - tKept.vertices
        tRibbonCache[tRecorded] = nil

    end

end

-- The UV keys of a trail's billboard: the frame one update earlier (see fnAddTrails)
local function fnTrailKeys(tTrail)

    local tBoard = tTrail.board and tTrail.board.billboard

    return tBoard and tTrail.updates > 0 and CORE.Curves.BillboardFromParticle(tBoard, tTrail.updates - 1, tTrailKeys) or NO_KEYS

end

-- The ribbon of a recorded trail, built the first time
local function fnCachedRibbon(tTrail, tItem)

    local tKept = tRibbonCache[tTrail.recorded]
    local tPart = tItem.parts[1]

    -- Built with stage values since rebuilt (the scale or the screen size changed)
    if tKept and tKept.static ~= tPart.static then

        if tKept.mesh then
            tKept.mesh:Destroy()
        end

        iCachedVertices = iCachedVertices - tKept.vertices
        tKept = nil

    end

    if not tKept then

        local tKeys = fnTrailKeys(tTrail)
        local tOffset0, tSize0 = tKeys[5] or {0, 0}, tKeys[6] or {1, 1}
        local tOffset1, tSize1 = tKeys[10] or {0, 0}, tKeys[11] or {1, 1}

        local tVertices = CORE.Trail.Vertices(tTrail.state, tTrail.def,
            {tOffset0[1], tOffset0[2], tSize0[1], tSize0[2], tOffset1[1], tOffset1[2], tSize1[1], tSize1[2]}, fnFloat32)

        local cx, cy, cz = 0, 0, 0

        for _, tVertex in ipairs(tVertices) do
            local tPosition = tVertex.position
            cx, cy, cz = cx + tPosition[1], cy + tPosition[2], cz + tPosition[3]
        end

        local iCount = math.max(#tVertices, 1)

        tKept = {
            mesh = RENDER.BuildRibbon(tPart.mat, tPart.mesh, tPart.static, tVertices),
            static = tPart.static,
            x = cx / iCount, y = cy / iCount, z = cz / iCount,
            w = tKeys[9] and tKeys[9][1] or 0,
            vertices = #tVertices
        }

        tRibbonCache[tTrail.recorded] = tKept
        iCachedVertices = iCachedVertices + tKept.vertices

    end

    if bTimed then
        SECTIONS:Count(tKept.used and "ribbon_cache_hits" or "ribbon_cache_builds")
    end

    tKept.used = iListSerial

    return tKept

end

local function fnAddTrails(tInstance, tOuter)

    local tRuntime = tInstance.runtime
    local bCache = (StormFX.Config["ribbonCacheVertices"] or 0) > 0

    for _, tSet in ipairs(tInstance.trailSets or {}) do

        for _, tTrail in ipairs(tSet.trails) do

            local tItem = tRuntime.ribbons[tTrail.def]

            if not tItem then

                fnSkip(tTrail.def.billboard)

            elseif bCache and tTrail.recorded and #tTrail.state.points > 1 then

                -- A recorded trail: its ribbon in the effect's space, under the outer matrix
                local tKept = fnCachedRibbon(tTrail, tItem)

                if tKept.mesh then

                    local x, y, z = tKept.x, tKept.y, tKept.z
                    local px = tOuter[1] * x + tOuter[2] * y + tOuter[3] * z + tOuter[4]
                    local py = tOuter[5] * x + tOuter[6] * y + tOuter[7] * z + tOuter[8]
                    local pz = tOuter[9] * x + tOuter[10] * y + tOuter[11] * z + tOuter[12]
                    local tPart = tItem.parts[1]

                    tRibbonMeta.__index = tItem.stage
                    tRibbonValues.g_commonParam[4] = tKept.w

                    local tEntry = fnNewEntry()

                    tEntry.item = tItem
                    tEntry.part = tPart
                    tEntry.state = tPart.state
                    tEntry.layer = tItem.layer
                    tEntry.depth = (px - ex) * kx + (py - ey) * ky + (pz - ez) * kz
                    tEntry.skinned = nil
                    tEntry.ribbon = true
                    tEntry.cachedRibbon = tKept.mesh
                    tEntry.batched = false
                    tEntry.split = nil
                    tEntry.studio = nil
                    tEntry.studioParticle = nil
                tEntry.studioParticle = nil

                    fnCopyMatrix(tOuter, tEntry.world)
                    RENDER.PackInto(tPart.layout, tRibbonValues, tEntry.packed)

                end

            elseif #tTrail.state.points > 1 then

                -- The game shows the frame one billboard update earlier than one call per
                -- update of the effect gives (capture of 4efb_amt1_blt00, journal R98): as if
                -- the trail were first updated one update after its launch (its updates run as
                -- render-thread jobs; not traced). Hence updates - 1 (fnTrailKeys).
                local tKeys = fnTrailKeys(tTrail)

                -- Billboard +2C8..+2E4: channels 5, 6, 10, 11, or the defaults of 0x1412c8110
                local tOffset0, tSize0 = tKeys[5] or {0, 0}, tKeys[6] or {1, 1}
                local tOffset1, tSize1 = tKeys[10] or {0, 0}, tKeys[11] or {1, 1}

                local tVertices = CORE.Trail.Vertices(tTrail.state, tTrail.def,
                    {tOffset0[1], tOffset0[2], tSize0[1], tSize0[2], tOffset1[1], tOffset1[2], tSize1[1], tSize1[2]}, fnFloat32)

                local cx, cy, cz = 0, 0, 0

                for _, tVertex in ipairs(tVertices) do

                    -- Into the world, in place (the trail refills its vertices every frame)
                    local tPosition = tVertex.position
                    local x, y, z = tPosition[1], tPosition[2], tPosition[3]

                    tPosition[1] = tOuter[1] * x + tOuter[2] * y + tOuter[3] * z + tOuter[4]
                    tPosition[2] = tOuter[5] * x + tOuter[6] * y + tOuter[7] * z + tOuter[8]
                    tPosition[3] = tOuter[9] * x + tOuter[10] * y + tOuter[11] * z + tOuter[12]

                    cx, cy, cz = cx + tPosition[1], cy + tPosition[2], cz + tPosition[3]

                end

                local iCount = #tVertices
                local flDepth = (cx / iCount - ex) * kx + (cy / iCount - ey) * ky + (cz / iCount - ez) * kz
                local tPart = tItem.parts[1]

                tRibbonMeta.__index = tItem.stage
                tRibbonValues.g_commonParam[4] = tKeys[9] and tKeys[9][1] or 0

                local tEntry = fnNewEntry()

                tEntry.item = tItem
                tEntry.part = tPart
                tEntry.state = tPart.state
                tEntry.layer = tItem.layer
                tEntry.depth = flDepth
                tEntry.skinned = nil
                tEntry.ribbon = tVertices
                tEntry.cachedRibbon = nil
                tEntry.batched = false
                tEntry.split = nil
                tEntry.studio = nil
                tEntry.studioParticle = nil

                fnCopyMatrix(ENGINE.IDENTITY, tEntry.world)
                RENDER.PackInto(tPart.layout, tRibbonValues, tEntry.packed)

            end

        end

    end

end

-- The view's half-angle tangents (horizontal, vertical) of the draw list being built
local flTanX, flTanY = 1, 1

-- Game units around an effect's origin its own models may reach (they are not measured)
local MODEL_REACH = 300

-- Whether an effect may be in view: a sphere around its origin holding its particles (and a
-- margin for its models) against the main camera's view. An effect out of view is not drawn,
-- and its trails make no ribbon points (StormFX.Core.Trail, tState.hidden); it still plays.
local function fnInView(tInstance)

    local tOuter = tInstance.outer
    local flRadius = MODEL_REACH

    for _, tParticle in ipairs(tInstance.scene and tInstance.scene.particles or NO_KEYS) do

        local tPosition, tSize = tParticle.position, tParticle.size
        local flReach = math.sqrt(tPosition[1] * tPosition[1] + tPosition[2] * tPosition[2] + tPosition[3] * tPosition[3])
            + math.max(tSize[1], tSize[2])

        if flReach > flRadius then
            flRadius = flReach
        end

    end

    flRadius = flRadius * tOuter.scale

    local dx, dy, dz = tOuter.pos.x - ex, tOuter.pos.y - ey, tOuter.pos.z - ez
    local flDepth = dx * kx + dy * ky + dz * kz

    if flDepth < -flRadius then return false end

    -- Sideways and up: the distance from the view axis against the view's half-width at that
    -- depth, the sphere's radius taken along the slanted planes
    local flSide = math.abs(dx * rx + dy * ry + dz * rz)
    local flUp = math.abs(dx * ux + dy * uy + dz * uz)

    if flSide > flDepth * flTanX + flRadius * math.sqrt(1 + flTanX * flTanX) then return false end
    if flUp > flDepth * flTanY + flRadius * math.sqrt(1 + flTanY * flTanY) then return false end

    return true

end

-- Tell an effect's trails whether they are seen
local function fnHideTrails(tInstance, bHidden)

    for _, tSet in ipairs(tInstance.trailSets or NO_KEYS) do
        for _, tTrail in ipairs(tSet.trails) do
            tTrail.state.hidden = bHidden
        end
    end

end

-- The effects that may be drawn in the list being built (refilled in place)
local tCandidates = {}

-- Nearer to the camera first, then in play order
local function fnNearer(tA, tB)

    if tA.drawDistance ~= tB.drawDistance then
        return tA.drawDistance < tB.drawDistance
    end

    return tA.drawIndex < tB.drawIndex

end

-- The meshes built for the current draw list (released when the next one is built)
local tListMeshes = {}

local function fnReleaseListMeshes()

    for i = #tListMeshes, 1, -1 do
        tListMeshes[i]:Destroy()
        tListMeshes[i] = nil
    end

end

-- Build the meshes of a sorted draw list: a batched run (the entries of one part the sort keeps
-- together; one entry a run with bGroup off) gets its meshes on its first entry (meshes,
-- runLast), a trail ribbon its mesh (ribbonMesh)
-- The skinned meshes kept from list to list, by mesh, animation and ticks: {meshes, static,
-- vertices, used (the list that last drew them)}, at most Config skinCacheVertices vertices
-- (the least recently drawn go first)
local tSkinCache = {}
local iSkinCachedVertices = 0

local function fnDestroyPieces(tMeshes)

    for _, mshPiece in ipairs(tMeshes) do
        mshPiece:Destroy()
    end

end

-- Whether two palettes are the same but for rounding (a pose kept for a clock is shared only
-- then: two copies at the same clock nearly always have the same pose, not always)
local function fnSamePalette(tA, tB)

    if tA == tB then return true end
    if #tA ~= #tB then return false end

    for i = 1, #tA do

        local tMa, tMb = tA[i], tB[i]

        for k = 1, 16 do

            local flA, flB = tMa[k], tMb[k]

            if math.abs(flA - flB) > 1e-4 * math.max(1, math.abs(flA)) then
                return false
            end

        end

    end

    return true

end

local function fnClearSkinCache()

    for tMesh, tByAnimation in pairs(tSkinCache) do
        for _, tByTicks in pairs(tByAnimation) do
            for _, tKept in pairs(tByTicks) do
                fnDestroyPieces(tKept.meshes)
            end
        end
        tSkinCache[tMesh] = nil
    end

    iSkinCachedVertices = 0

end

local function fnTrimSkinCache(iBudget)

    if iSkinCachedVertices <= iBudget then return end

    local tOld = {}

    for _, tByAnimation in pairs(tSkinCache) do
        for _, tByTicks in pairs(tByAnimation) do
            for iTicks, tKept in pairs(tByTicks) do
                if tKept.used < iListSerial then
                    tOld[#tOld + 1] = {kept = tKept, owner = tByTicks, ticks = iTicks}
                end
            end
        end
    end

    table.sort(tOld, function(tA, tB) return tA.kept.used < tB.kept.used end)

    for _, tOldest in ipairs(tOld) do

        if iSkinCachedVertices <= iBudget * 0.75 then break end

        fnDestroyPieces(tOldest.kept.meshes)
        iSkinCachedVertices = iSkinCachedVertices - tOldest.kept.vertices
        tOldest.owner[tOldest.ticks] = nil

    end

end

-- The mixed triangles of a split skinned part (RENDER.SplitSkinned), skinned with the
-- entry's palette. Copies at the same point of the same animation share them, in this list
-- and the next ones (tSkinCache): their palettes, relative to their own draw matrices, differ
-- by rounding only. A draw with no pose key gets meshes of its own, released with the list.
local function fnSplitMeshes(tEntry)

    local tPart, tDraw = tEntry.part, tEntry.split
    local tMixed = RENDER.SplitSkinned(tPart.mesh).mixed

    if not tMixed then return nil end

    local tByTicks

    if tDraw.poseAnimation and (StormFX.Config["skinCacheVertices"] or 0) > 0 then

        local tByAnimation = tSkinCache[tPart.mesh] or {}
        tSkinCache[tPart.mesh] = tByAnimation

        tByTicks = tByAnimation[tDraw.poseAnimation] or {}
        tByAnimation[tDraw.poseAnimation] = tByTicks

        local tKept = tByTicks[tDraw.poseTicks]

        -- Built with stage values since rebuilt (the scale or the screen size changed)
        if tKept and tKept.static ~= tPart.static then
            fnDestroyPieces(tKept.meshes)
            iSkinCachedVertices = iSkinCachedVertices - tKept.vertices
            tKept = nil
        end

        if tKept and fnSamePalette(tKept.palette, tDraw.palette) then
            tKept.used = iListSerial
            return tKept.meshes
        end

        -- Another pose at this clock: this copy gets meshes of its own
        if tKept then
            tByTicks = nil
        end

    end

    local tPositions, tNormals = CORE.Skinning.Mesh(tMixed, tDraw.palette, ENGINE.Plain)

    ENGINE.iSkinnedVertices = ENGINE.iSkinnedVertices + #tPositions

    local tMeshes = RENDER.BuildMeshes(tPart.mat, tMixed, tPart.static, {positions = tPositions, normals = tNormals})

    if tByTicks then

        local iVertices = #tMixed.triangles * 3

        tByTicks[tDraw.poseTicks] = {meshes = tMeshes, static = tPart.static, palette = tDraw.palette, vertices = iVertices, used = iListSerial}
        iSkinCachedVertices = iSkinCachedVertices + iVertices

    else

        for _, mshPiece in ipairs(tMeshes) do
            tListMeshes[#tListMeshes + 1] = mshPiece
        end

    end

    return tMeshes

end

local function fnBuildListMeshes(tList, bGroup)

    fnReleaseListMeshes()

    local iCount = #tList
    local iIndex = 1

    while iIndex <= iCount do

        local tEntry = tList[iIndex]

        tEntry.meshes, tEntry.runLast, tEntry.ribbonMesh, tEntry.mixedMeshes = nil, nil, nil, nil

        if tEntry.batched then

            local iLast = iIndex

            if bGroup then
                while iLast < iCount and tList[iLast + 1].part == tEntry.part do
                    iLast = iLast + 1
                end
            end

            local flFrom = bTimed and SysTime()

            tEntry.meshes = RENDER.BuildBatch(tEntry.part, tList, iIndex, iLast, {})
            tEntry.runLast = iLast

            for _, mshBatch in ipairs(tEntry.meshes) do
                tListMeshes[#tListMeshes + 1] = mshBatch
            end

            if bTimed then
                fnLap("build_batch_mesh", flFrom)
                SECTIONS:Count("batch_quads", iLast - iIndex + 1)
            end

            iIndex = iLast + 1

        else

            if tEntry.split then

                local flFrom = bTimed and SysTime()

                tEntry.mixedMeshes = fnSplitMeshes(tEntry)

                if bTimed then
                    fnLap("build_skinned_mesh", flFrom)
                end

            elseif tEntry.cachedRibbon then

                -- Kept by the ribbon cache, not released with the list
                tEntry.ribbonMesh = tEntry.cachedRibbon

            elseif tEntry.ribbon then

                local tPart = tEntry.part
                local flFrom = bTimed and SysTime()

                tEntry.ribbonMesh = RENDER.BuildRibbon(tPart.mat, tPart.mesh, tPart.static, tEntry.ribbon)

                if tEntry.ribbonMesh then
                    tListMeshes[#tListMeshes + 1] = tEntry.ribbonMesh
                end

                if bTimed then
                    fnLap("build_ribbon_mesh", flFrom)
                    SECTIONS:Count("ribbon_vertices", #tEntry.ribbon)
                end

            end

            iIndex = iIndex + 1

        end

    end

end

-- The model matrices of a split skinned entry's rigid pieces: its world matrix times each
-- palette entry, the palette being in the shader's layout (transposed: SKINNING.Vertex reads
-- position k as the sum over j of palette[k + 4 (j - 1)] * vertex[j])
local function fnBoneMatrices(tEntry)

    local w, tPalette = tEntry.world, tEntry.split.palette

    tEntry.boneMatrices = tEntry.boneMatrices or {}

    for iBone in pairs(tEntry.part.rigidMeshes) do

        local p = tPalette[iBone]
        local mBone = tEntry.boneMatrices[iBone]

        if not mBone then
            mBone = Matrix()
            tEntry.boneMatrices[iBone] = mBone
        end

        -- w (rows, translation in 4, 8, 12) x E, E[(k - 1) * 4 + j] = p[k + 4 (j - 1)], E's last row 0 0 0 1
        local e1, e2, e3, e4 = p[1], p[5], p[9], p[13]
        local e5, e6, e7, e8 = p[2], p[6], p[10], p[14]
        local e9, e10, e11, e12 = p[3], p[7], p[11], p[15]

        mBone:SetUnpacked(
            w[1] * e1 + w[2] * e5 + w[3] * e9, w[1] * e2 + w[2] * e6 + w[3] * e10, w[1] * e3 + w[2] * e7 + w[3] * e11, w[1] * e4 + w[2] * e8 + w[3] * e12 + w[4],
            w[5] * e1 + w[6] * e5 + w[7] * e9, w[5] * e2 + w[6] * e6 + w[7] * e10, w[5] * e3 + w[6] * e7 + w[7] * e11, w[5] * e4 + w[6] * e8 + w[7] * e12 + w[8],
            w[9] * e1 + w[10] * e5 + w[11] * e9, w[9] * e2 + w[10] * e6 + w[11] * e10, w[9] * e3 + w[10] * e7 + w[11] * e11, w[9] * e4 + w[10] * e8 + w[11] * e12 + w[12],
            0, 0, 0, 1)

    end

end

-- The draws of one effect
local function fnAddInstance(tInstance)

    local tOuter = tInstance.outer
    local flCos, flSin = math.cos(tOuter.yaw * math.pi / 180), math.sin(tOuter.yaw * math.pi / 180)

    -- The outer transform (yaw, scale, position), kept by the instance
    local tOuterMatrix = tInstance.outerMatrix

    if not tOuterMatrix then
        tOuterMatrix = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1}
        tInstance.outerMatrix = tOuterMatrix
    end

    tOuterMatrix[1], tOuterMatrix[2], tOuterMatrix[4] = flCos * tOuter.scale, -flSin * tOuter.scale, tOuter.pos.x
    tOuterMatrix[5], tOuterMatrix[6], tOuterMatrix[8] = flSin * tOuter.scale, flCos * tOuter.scale, tOuter.pos.y
    tOuterMatrix[11], tOuterMatrix[12] = tOuter.scale, tOuter.pos.z

    if not bTimed then

        fnAddAnimationModels(tInstance, tOuterMatrix)
        fnAddParticles(tInstance, tOuterMatrix)
        fnAddTrails(tInstance, tOuterMatrix)

        return

    end

    local flFrom = SysTime()

    fnAddAnimationModels(tInstance, tOuterMatrix)
    flFrom = fnLap("build_add_models", flFrom)

    fnAddParticles(tInstance, tOuterMatrix)
    flFrom = fnLap("build_add_particles", flFrom)

    fnAddTrails(tInstance, tOuterMatrix)
    fnLap("build_add_trails", flFrom)

end

-- The draw list of the frame, sorted, with the model matrices
function ENGINE:BuildEntries()

    local flFrom = bTimed and SysTime()

    iListSerial = iListSerial + 1

    self.iSkinnedVertices = 0
    self:EnsureMeshes(self.flScale)

    -- The main view's camera (see the RenderScene hook below), else the current view's
    local tMain = self.tMainView
    local bCurrent = tMain.frame and FrameNumber and tMain.frame == FrameNumber()
    local angView = bCurrent and tMain.angles or EyeAngles()
    local vecForward = angView:Forward()
    local vecEye = bCurrent and tMain.origin or EyePos()

    vecRight, vecUp = angView:Right(), angView:Up()
    vecNormal = vecRight:Cross(vecUp)

    rx, ry, rz, ux, uy, uz, nx, ny, nz = vecRight.x, vecRight.y, vecRight.z, vecUp.x, vecUp.y, vecUp.z, vecNormal.x, vecNormal.y, vecNormal.z
    ex, ey, ez, kx, ky, kz = vecEye.x, vecEye.y, vecEye.z, vecForward.x, vecForward.y, vecForward.z

    -- Shared values, once per frame rather than once per particle. Source's clock supplies the
    -- missing original epoch (about 0.1 per real second).
    flSharedClock = CORE.MaterialContext.OriginalClock(math.floor(CurTime() * 60) * 50 % 2147483648, 3000)

    for sName in pairs(self.tSkipped) do
        self.tSkipped[sName] = nil
    end

    local iPrevious = iEntries
    iEntries = 0

    -- The view's half-angles: GMod's fov is the horizontal one (a little margin)
    local tView = render.GetViewSetup and render.GetViewSetup() or NO_KEYS
    local flFov = math.min(tView.fov or 90, 170)

    flTanX = math.tan(math.rad(flFov / 2)) * 1.1
    flTanY = flTanX * ScrH() / ScrW()

    local bCull = StormFX.Config["cullHidden"] ~= false

    if bTimed then
        flFrom = fnLap("build_camera", flFrom)
    end

    local CONFIG = StormFX.Config
    local iMaxEffects = CONFIG["maxDrawnEffects"] or 0
    local flMaxDistance = CONFIG["maxDrawDistance"] or 0
    local iMaxEntries = CONFIG["maxDrawEntries"] or 0
    local iCandidates = 0

    for _, tInstance in ipairs(self.tInstances) do

        -- An effect taken away since the last update is not drawn, nor one out of view, nor
        -- one too far
        if not tInstance.removed then

            local flCull = bTimed and SysTime()
            local tPos = tInstance.outer.pos
            local dx, dy, dz = tPos.x - ex, tPos.y - ey, tPos.z - ez
            local flDistance = dx * dx + dy * dy + dz * dz
            local eParent = tInstance.parentEntity
            local bDormant = eParent ~= nil and IsValid(eParent) and eParent:IsDormant()
            local bInView = not bDormant and (flMaxDistance <= 0 or flDistance <= flMaxDistance * flMaxDistance)
                and (not bCull or fnInView(tInstance))

            if bInView then
                iCandidates = iCandidates + 1
                tCandidates[iCandidates] = tInstance
                tInstance.drawDistance = flDistance
                tInstance.drawIndex = iCandidates
            else
                fnHideTrails(tInstance, true)
                tInstance.drawn = false
            end

            if bTimed then
                fnLap("build_cull", flCull)
                SECTIONS:Count(bInView and "effects_seen" or "effects_culled")
            end

        end

    end

    for i = iCandidates + 1, #tCandidates do
        tCandidates[i] = nil
    end

    -- With a bound, the nearest first (they keep their place when the bound is reached)
    local bBounded = iMaxEffects > 0 and iCandidates > iMaxEffects or iMaxEntries > 0

    if bBounded and iCandidates > 1 then
        table.sort(tCandidates, fnNearer)
    end

    for i, tInstance in ipairs(tCandidates) do

        local bDrawn = (iMaxEffects <= 0 or i <= iMaxEffects) and (iMaxEntries <= 0 or iEntries < iMaxEntries)

        fnHideTrails(tInstance, not bDrawn)

        -- Read by the update: a simulated effect left out waits first (engine/cl_update.lua)
        tInstance.drawn = bDrawn

        if bDrawn then
            fnAddInstance(tInstance)
        elseif bTimed then
            SECTIONS:Count("effects_over_bounds")
        end

    end

    -- The list ends with this frame's entries
    for i = iEntries + 1, iPrevious do
        tEntries[i] = nil
    end

    -- The cached ribbons this list does not draw may go
    fnTrimRibbonCache(StormFX.Config["ribbonCacheVertices"] or 0)

    if bTimed then
        flFrom = SysTime()
        SECTIONS:Count("list_entries", iEntries)
        SECTIONS:Count("cached_ribbon_vertices", iCachedVertices)
    end

    RENDER.Sort(tEntries, StormFX.Config["batchParticles"] ~= false)

    if bTimed then
        flFrom = fnLap("build_sort", flFrom)
    end

    -- Model matrices, once per frame (every view of the frame pushes the same ones), each in
    -- one call; a batched entry has none (its vertices are placed in the world)
    if not self.tSkip.matrix then

        for _, tEntry in ipairs(tEntries) do

            if not tEntry.batched then

                local mTransform = tEntry.matrix

                if not mTransform then
                    mTransform = Matrix()
                    tEntry.matrix = mTransform
                end

                mTransform:SetUnpacked(fnUnpack(tEntry.world, 1, 16))

                if tEntry.split then
                    fnBoneMatrices(tEntry)
                end

            end

        end

    end

    if bTimed then
        flFrom = fnLap("build_matrices", flFrom)
    end

    -- The meshes made from Lua (batched particles, trail ribbons), built once per list: every
    -- frame drawn from it only draws them
    fnBuildListMeshes(tEntries, StormFX.Config["batchParticles"] ~= false)

    -- The kept skinned meshes this list does not draw may go
    fnTrimSkinCache(StormFX.Config["skinCacheVertices"] or 0)

    if bTimed then
        fnLap("build_meshes", flFrom)
        SECTIONS:Count("cached_skinned_vertices", iSkinCachedVertices)
    end

    return tEntries

end

local matTone

-- The model matrix of the batches (their vertices are in world space)
local mIdentity = Matrix()

-- Draw a draw list in the current view
function ENGINE:DrawEntries(tList)

    self.iDraws = 0

    local tCurrent, bSceneCopied, bMasking
    local bMasked = self.iToneMode == 1
    local tSkip = self.tSkip
    local iCount = #tList
    local iIndex = 1

    while iIndex <= iCount do

        local tEntry = tList[iIndex]
        local tPart = tEntry.part
        local flFrom = bTimed and SysTime()

        -- Tone control on the effect's own pixels: the opaque draws mark the stencil
        if bMasked and tEntry.state.bucket == 0 and not bMasking then
            STAGE_POST.BeginMask()
            bMasking = true
        end

        if bMasking and tEntry.state.bucket ~= 0 then
            STAGE_POST.EndMask()
            bMasking = false
        end

        -- The game copies the scene target once, when its refraction layer starts (capture
        -- 22127: event 6632, before the draw at 6763)
        if tEntry.state.scene and not bSceneCopied then

            render.UpdateScreenEffectTexture()
            bSceneCopied = true

            if bTimed then
                flFrom = fnLap("draw_screen_copy", flFrom)
            end

        end

        if tCurrent ~= tEntry.state then

            if not tSkip.blend then
                RENDER.Begin(tEntry.state)
            end

            tCurrent = tEntry.state

            if bTimed then
                flFrom = fnLap("draw_state", flFrom)
                SECTIONS:Count("state_changes")
            end

        end

        local iNext = iIndex + 1

        if tEntry.batched then

            -- The run of entries of the same part (the sort keeps them together), in the
            -- meshes built with the list, vertices in world space
            cam.PushModelMatrix(mIdentity)
            render.SetMaterial(tPart.mat)

            for _, mshBatch in ipairs(tEntry.meshes or NO_KEYS) do

                if not tSkip.draw then
                    mshBatch:Draw()
                end

                self.iDraws = self.iDraws + 1

            end

            cam.PopModelMatrix()

            iNext = (tEntry.runLast or iIndex) + 1

            if bTimed then
                fnLap("draw_batch", flFrom)
                SECTIONS:Count("draw_calls", #(tEntry.meshes or NO_KEYS))
            end

        elseif tEntry.studioParticle then

            -- A particle drawn as its studio model: every part's constants on that part's own
            -- material, then the model at the particle's cycle (engine/cl_studio.lua)
            local tStudio = tEntry.studioParticle

            if not tSkip.apply then
                for i, tStudioPart in ipairs(tStudio.parts) do
                    RENDER.Apply(tStudioPart.mat, tEntry.studioPacked[i])
                end
            end

            if not tSkip.draw and tEntry.matrix then
                self:DrawStudio(tStudio, tEntry.studioCycle, tEntry.matrix)
            end

            self.iDraws = self.iDraws + 1

            if bTimed then
                fnLap("draw_studio", flFrom)
                SECTIONS:Count("draw_calls")
            end

        elseif tEntry.studio then

            -- A studio model (engine/cl_studio.lua): its own matrix, not the pushed one
            if not tSkip.apply then
                RENDER.Apply(tEntry.studio.mat, tEntry.packed)
            end

            if not tSkip.draw and tEntry.matrix then
                self:DrawStudio(tEntry.studio, tEntry.studioCycle, tEntry.matrix)
            end

            self.iDraws = self.iDraws + 1

            if bTimed then
                fnLap("draw_studio", flFrom)
                SECTIONS:Count("draw_calls")
            end

        else

            if not tSkip.apply then
                RENDER.Apply(tPart.mat, tEntry.packed)
            end

            if bTimed then
                flFrom = fnLap("draw_apply", flFrom)
            end

            if tSkip.matrix then
                tSkip.shared = tSkip.shared or Matrix()
                cam.PushModelMatrix(tSkip.shared)
            else
                cam.PushModelMatrix(tEntry.matrix)
            end

            if not tSkip.draw then

                render.SetMaterial(tPart.mat)

                if tEntry.ribbon then

                    if tEntry.ribbonMesh then
                        tEntry.ribbonMesh:Draw()
                    end

                elseif tEntry.split then

                    -- The skinned triangles under the draw matrix, then each rigid piece under
                    -- its palette entry
                    for _, mshPiece in ipairs(tEntry.mixedMeshes or NO_KEYS) do
                        mshPiece:Draw()
                    end

                    for iBone, tMeshes in pairs(tPart.rigidMeshes) do

                        local mBone = tEntry.boneMatrices and tEntry.boneMatrices[iBone]

                        if mBone then

                            cam.PushModelMatrix(mBone)

                            for _, mshPiece in ipairs(tMeshes) do
                                mshPiece:Draw()
                            end

                            cam.PopModelMatrix()

                        end

                    end

                elseif tPart.mesh.skin then
                    RENDER.DrawSkinned(tPart.mesh, tPart.static, tEntry.skinned)
                else
                    tPart.buffer:Draw()
                end

            end

            self.iDraws = self.iDraws + 1
            cam.PopModelMatrix()

            if bTimed then
                fnLap(tEntry.ribbon and "draw_ribbon" or tPart.mesh.skin and "draw_skinned" or "draw_model", flFrom)
                SECTIONS:Count("draw_calls")
            end

        end

        iIndex = iNext

    end

    local flFrom = bTimed and SysTime()

    if bMasking then
        STAGE_POST.EndMask()
    end

    RENDER.Finish()

    if self.iToneMode > 0 and #tList > 0 then
        matTone = matTone or STAGE_POST.Material("storm_fx_stage_tone_" .. self.sVersion)
        STAGE_POST.Draw(matTone, STAGE_POST.Pack(self.tStage.tone, ScrW(), ScrH()), bMasked)
    end

    if bTimed then
        fnLap("draw_finish", flFrom)
    end

end

-- The draw list in use, and the frame it was last drawn in
local tBuilt = {}
local iDrawnFrame

-- Drop the draw list in use and its meshes; bKeepCache keeps the cached ribbons (they serve
-- the next plays: only a map change or a reload lets them go)
function ENGINE:ResetDrawList(bKeepCache)

    fnReleaseListMeshes()
    tBuilt = {}
    tCandidates = {}

    if not bKeepCache then
        fnClearRibbonCache()
        fnClearSkinCache()
    end

end

-- Draw the effects in the view being drawn. iCalls / tViews (the render target of each call) /
-- flBuildMs / flRenderMs (every call) are this frame's figures.
-- The list is built again when the effects stepped or changed (bListDirty, set by the
-- update), else at most Config drawRate times a second (the camera moved: the billboards turn
-- to it); a frame in between draws the list it has. The effects change 60 times a second: at
-- 500 frames a second, most frames only draw. Offline (no FrameNumber) it is built at every call.
function ENGINE:RenderEffects(bDepth, bSky, bSky3d)

    if bDepth or bSky or bSky3d then return end

    if #self.tInstances == 0 then

        self.iDraws, self.flRenderMs, self.flBuildMs, self.iCalls = 0, 0, 0, 0

        if tBuilt.entries then
            self:ResetDrawList(true)
        end

        return

    end

    local flStarted = SysTime()
    local iFrame = FrameNumber and FrameNumber()

    bTimed = SECTIONS:Active()

    local flHeap = bTimed and collectgarbage("count")

    if iFrame ~= iDrawnFrame or not iFrame then
        iDrawnFrame = iFrame
        self.iCalls, self.tViews, self.flRenderMs, self.flBuildMs = 0, {}, 0, 0
    end

    local flRate = StormFX.Config["drawRate"] or 0
    local bDue = not tBuilt.entries or not iFrame or self.bListDirty or flRate <= 0 or flStarted - tBuilt.time >= 1 / flRate

    -- storm_fx_skip build: the list in use is kept (what drawing alone costs)
    if self.tSkip.build and tBuilt.entries then
        bDue = false
    end

    if bDue and tBuilt.frame ~= iFrame or not iFrame then

        tBuilt = {frame = iFrame, time = flStarted, entries = self:BuildEntries()}
        self.bListDirty = false
        self.flBuildMs = (SysTime() - flStarted) * 1000

        if bTimed then
            SECTIONS:Add("build", self.flBuildMs / 1000)
        end

    end

    self.iCalls = self.iCalls + 1

    local rtTarget = render.GetRenderTarget and render.GetRenderTarget()
    local sTarget = rtTarget and string.lower(rtTarget:GetName()) or "frame buffer"

    if WATER_VIEWS[sTarget] and not (cvWaterViews and cvWaterViews:GetBool()) then

        self.tViews[self.iCalls] = sTarget .. " (left out)"

    else

        self.tViews[self.iCalls] = sTarget

        local flDraw = bTimed and SysTime()

        -- storm_fx_skip fill: every draw call is made, through a one-pixel scissor (the GPU
        -- draws almost no pixel)
        if self.tSkip.fill then
            render.SetScissorRect(0, 0, 1, 1, true)
        end

        self:DrawEntries(tBuilt.entries)

        if self.tSkip.fill then
            render.SetScissorRect(0, 0, 0, 0, false)
        end

        if bTimed then
            fnLap("draw", flDraw)
            SECTIONS:Count("views")
        end

    end

    local flSpent = SysTime() - flStarted

    self.flRenderMs = self.flRenderMs + flSpent * 1000

    if bTimed then
        SECTIONS:Add("hook", flSpent)
        SECTIONS:Allocated(collectgarbage("count") - flHeap)
    end

end

-- The main view's camera of this frame (RenderScene runs once per frame, before any view is
-- drawn). The draw list is built from it: EyePos / EyeAngles give the camera of the view being
-- drawn, and the first view of a frame can be the water reflection (camera mirrored under the
-- water), which turned the billboards away from the player.
hook.Add("RenderScene", "StormFX:Engine:RenderScene", function(vecOrigin, angView)
    StormFX.Engine.tMainView = {frame = FrameNumber(), origin = vecOrigin, angles = angView}
end)

-- The effects are drawn in the translucent pass; sDrawHook = "opaque" draws them at the end of
-- the opaque pass instead (comparison of the depth state, storm_fx_perftest)
hook.Add("PostDrawTranslucentRenderables", "StormFX:Engine:PostDrawTranslucentRenderables", function(bDepth, bSky, bSky3d)

    if StormFX.Engine.sDrawHook == "translucent" then
        StormFX.Engine:RenderEffects(bDepth, bSky, bSky3d)
    end

end)

hook.Add("PostDrawOpaqueRenderables", "StormFX:Engine:PostDrawOpaqueRenderables", function(bDepth, bSky, bSky3d)

    if StormFX.Engine.sDrawHook == "opaque" then
        StormFX.Engine:RenderEffects(bDepth, bSky, bSky3d)
    end

end)

hook.Add("ShutDown", "StormFX:Engine:ShutDown", function()
    StormFX.Engine:Cleanup()
end)
