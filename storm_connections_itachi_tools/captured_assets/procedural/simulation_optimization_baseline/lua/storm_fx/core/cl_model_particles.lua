-- Models carried by particles: clump resources (nuccChunkClump) and animated resources
-- (nuccChunkAnm) of a package. This makes their matrices, material instances and skinning
-- palettes; drawing them is the engine's job.

StormFX.Core.ModelParticles = StormFX.Core.ModelParticles or {}

local MODEL_PARTICLES = StormFX.Core.ModelParticles

-- Material instance field each billboard channel replaces when the chunk has it (game: draw
-- 0x1412c7dd0): UV sets 0 / 1 offset and scale, blend rate x / y, the header float, the
-- outline id; channel 12 is the alpha threshold * 255
local BOARD_FIELDS = {
    [5] = {0x30, 0x34}, [6] = {0x50, 0x54}, [10] = {0x38, 0x3c}, [11] = {0x58, 0x5c},
    [7] = {0x70}, [8] = {0x74}, [9] = {0x7c}, [13] = {0x84}
}

-- The model particles of a package (a storm_import.py data package)
function MODEL_PARTICLES.New(tPackage, tModules, tOptions)

    local fnFloat32 = tOptions.float32
    local tModels = {modules = tModules, updates = 0, compiled = {}}

    -- The package's materials by name: an animated material instance starts as a copy of
    -- its fields (constructor 0x1412f5920)
    local tMaterials = {}

    for _, tModel in pairs(tPackage.models) do
        for _, tMaterial in ipairs(tModel.materials) do
            tMaterials[tMaterial.name] = tMaterial
        end
    end

    -- Rest pose of the clump of a skinned model: local matrices (nuccCoord constructor
    -- 0x1412892a0), their products down the hierarchy and their inverses. A NUD bone index is
    -- a coordinate index of that clump.
    local function fnSkeletonOf(tModel)

        local tSkeleton = tModel.skeleton

        if tSkeleton and not tSkeleton.restInverse then

            local SKINNING = assert(tModules.skinning, "skinning module required for a skinned model")

            tSkeleton.restLocal, tSkeleton.restWorld, tSkeleton.restInverse = {}, {}, {}

            for i, tRest in ipairs(tSkeleton.rest) do

                local tLocal = tModules.matrix.Node({tRest[1], tRest[2], tRest[3]}, {tRest[4], tRest[5], tRest[6]}, {tRest[7], tRest[8], tRest[9]}, fnFloat32, tOptions.sinf, tOptions.cosf)
                local iParent = tSkeleton.parents[i]

                tSkeleton.restLocal[i] = tLocal
                tSkeleton.restWorld[i] = iParent < 0 and tLocal or tModules.matrix.World(tSkeleton.restWorld[iParent + 1], tLocal, fnFloat32)
                tSkeleton.restInverse[i] = assert(SKINNING.Inverse(tSkeleton.restWorld[i]), "A coordinate of a skinned model has a flat rest transform")

            end

        end

        return tSkeleton

    end

    -- An animation compiled for its models: which entry animates each drawn model, its
    -- materials and, for a skinned model, its coordinates
    function tModels.CompiledFor(sName)

        local tCompiled = tModels.compiled[sName]

        if tCompiled then return tCompiled end

        local tAnimation = assert(tPackage.animations[sName], "Animation not in the package")

        tCompiled = {compiled = tModules.animation.Compile(tAnimation, tModules, tOptions), scales = {}, materials = {}, draws = {}}

        for iKey, tEntry in ipairs(tAnimation.entries) do

            if tEntry.type == 1 then

                tCompiled.scales[iKey] = {1, 1, 1}

            elseif tEntry.type == 4 then

                local tInstance = {[0x80] = 0, [0x84] = 0}
                local tMaterial = tMaterials[tEntry.chunk or tEntry.target]

                if tMaterial then
                    for iOffset, flValue in pairs(tMaterial.instance) do
                        tInstance[iOffset] = fnFloat32(flValue)
                    end
                end

                tCompiled.materials[iKey] = tInstance

            end

        end

        -- An entry names its target: a coordinate (type 1) or a material (type 4) of its
        -- clump. A model hangs on the clump coordinate its header indexes. entry.target is the
        -- animation's instance name, entry.chunk the chunk it instances (they differ when a
        -- clump is instanced more than once). draw.materials: material index -> entry.
        for iClump, tClump in ipairs(tAnimation.clumps) do

            for _, sModel in ipairs(tClump.drawn or {}) do

                local tModel = assert(tPackage.models[sModel])

                -- billboard: the nuccChunkBillboard keys of a billboard member, or nil
                local tDraw = {model = sModel, materials = {}, billboard = tClump.billboards and tClump.billboards[sModel]}
                local sBone = tClump.coords and tClump.coords[tModel.header.bone + 1]

                -- A skinned model: the entry animating each coordinate of its skeleton
                local tSkeleton = fnSkeletonOf(tModel)
                local tCoordinateIndex, tOwn = {}, {}

                if tSkeleton then

                    tDraw.skin = {}

                    for i, sCoordinate in ipairs(tSkeleton.coords) do
                        tCoordinateIndex[sCoordinate] = i
                    end

                    for _, tChunk in ipairs(tClump.boneChunks or {}) do
                        tOwn[tChunk[2]] = true
                    end

                end

                for iKey, tEntry in ipairs(tAnimation.entries) do

                    if tEntry.clump_index == iClump - 1 then

                        local sChunk = tEntry.chunk or tEntry.target

                        if tEntry.type == 1 and sChunk == sBone then
                            tDraw.coord = iKey
                        end

                        if tEntry.type == 1 and tCoordinateIndex[sChunk] then
                            tDraw.skin[tCoordinateIndex[sChunk]] = iKey
                        end

                        if tEntry.type == 4 then
                            for iIndex, tMaterial in ipairs(tModel.materials) do
                                if tMaterial.name == sChunk then
                                    tDraw.materials[iIndex] = iKey
                                end
                            end
                        end

                    elseif tSkeleton and tEntry.type == 1 and tEntry.clump_index >= 0 then

                        -- An animation can list one clump chunk as several clumps, each with
                        -- part of its coordinates (the four tails of 4mnreff1_tail00): a bone
                        -- this clump does not list is then animated in another. A coordinate
                        -- this clump lists itself is never taken from another copy.
                        local tOther = tAnimation.clumps[tEntry.clump_index + 1]
                        local sChunk = tEntry.chunk or tEntry.target

                        if tOther and tOther.chunk == tClump.chunk and tCoordinateIndex[sChunk] and not tOwn[sChunk]
                            and not tDraw.skin[tCoordinateIndex[sChunk]] then
                            tDraw.skin[tCoordinateIndex[sChunk]] = iKey
                        end

                    end

                end

                tCompiled.draws[#tCompiled.draws + 1] = tDraw

            end

        end

        tModels.compiled[sName] = tCompiled

        return tCompiled

    end

    -- Fresh material instances for one playing copy of an animation
    function tModels.Instances(tCompiled)

        local tInstances = {}

        for iKey, tFields in pairs(tCompiled.materials) do

            local tCopy = {}

            for iOffset, flValue in pairs(tFields) do
                tCopy[iOffset] = flValue
            end

            tInstances[iKey] = tCopy

        end

        return tInstances

    end

    -- Frame of a billboard member at iTicks of its own clock. The clump advances the clock by
    -- the animation's delta (0x1412c7f90): past the total it wraps when the chunk loops, else
    -- it stops on the total; the keys of frame floor(ticks / step) are copied (0x1412c7b00),
    -- none once past the last frame, which therefore stays.
    function tModels.BillboardFrame(tBoard, iTicks)

        local iTotal = tBoard.count * tBoard.stepTicks

        if iTicks >= iTotal then
            iTicks = tBoard.loop and iTicks % iTotal or iTotal
        end

        return math.min(math.floor(iTicks / tBoard.stepTicks), tBoard.count - 1)

    end

    -- One drawn model of an evaluated animation: its matrix, the animated instance of each of
    -- its materials, its opacity (the coordinate controller 0x1413679d0 writes nuccCoord +38 on
    -- every update: curve 3 of the coordinate, or 1). iTicks: the clock of the animation's
    -- billboard members (the sum of its deltas).
    function tModels.Resolve(tDraw, tResult, tFallbackMatrix, iTicks)

        local tCoordinate = tDraw.coord and tResult[tDraw.coord]
        local tInstances = {}

        for iIndex, iKey in pairs(tDraw.materials) do
            tInstances[iIndex] = tResult[iKey].instance
        end

        local tResolved = {
            model = tDraw.model,
            matrix = tCoordinate and tCoordinate.worldMatrix or tFallbackMatrix,
            instances = tInstances,
            opacity = tCoordinate and (tCoordinate.channels[3] and tCoordinate.channels[3][1] or 1) or nil
        }

        if tDraw.billboard then

            -- A billboard member: its keys go into the material instances, its opacity channel
            -- (4) replaces the model opacity (+A0), and the facing hook takes its position
            -- offset (1), roll (2) and size (3); absent channels keep offset 0, roll 0, size 1
            local tBoard = tDraw.billboard
            local iFrame = tModels.BillboardFrame(tBoard, iTicks or 0)

            local function fnKey(iChannel)
                local tKeys = tBoard.channels[iChannel]
                return tKeys and tKeys[math.min(iFrame + 1, #tKeys)]
            end

            tResolved.billboard = {
                offset = fnKey(1) or {0, 0, 0},
                size = fnKey(3) or {1, 1},
                roll = tBoard.rolls and tBoard.rolls[math.min(iFrame + 1, #tBoard.rolls)] or 0,
                frame = iFrame
            }

            tResolved.alphaScale = fnKey(4) and fnKey(4)[1] or 1

            for iIndex, tMaterial in ipairs(tPackage.models[tDraw.model].materials) do

                local tCopy = {}

                for iOffset, flValue in pairs(tInstances[iIndex] or tMaterial.instance) do
                    tCopy[iOffset] = flValue
                end

                for iChannel, tFields in pairs(BOARD_FIELDS) do

                    local tValue = fnKey(iChannel)

                    if tValue then
                        for i, iOffset in ipairs(tFields) do
                            tCopy[iOffset] = fnFloat32(tValue[i])
                        end
                    end

                end

                if fnKey(12) then
                    tCopy[0x80] = fnFloat32(fnKey(12)[1] / 255)
                end

                tInstances[iIndex] = tCopy

            end

        end

        if tDraw.skin then

            -- A skinned model: every coordinate of its clump has a pose (its animated matrix, or
            -- its rest transform under its parent's pose). It is drawn with the matrix that
            -- makes the palette entry of the root coordinate the identity, as in the captured
            -- palettes, and its vertices are skinned in that matrix's space.
            local tSkeleton = fnSkeletonOf(tPackage.models[tDraw.model])
            local tPose = {}

            for i = 1, #tSkeleton.rest do

                local iKey = tDraw.skin[i]

                if iKey then
                    tPose[i] = tResult[iKey].worldMatrix
                else
                    local iParent = tSkeleton.parents[i]
                    tPose[i] = tModules.matrix.World(iParent < 0 and tFallbackMatrix or tPose[iParent + 1], tSkeleton.restLocal[i], fnFloat32)
                end

            end

            tResolved.matrix = tModules.matrix.World(tPose[1], tSkeleton.restInverse[1], fnFloat32)

            local tInverse = tModules.skinning.Inverse(tResolved.matrix)

            -- A root coordinate scaled to zero flattens the whole model: nothing to draw
            if tInverse then
                tResolved.palette = tModules.skinning.Palette(tPose, tSkeleton.restInverse, tInverse, tModules.matrix.Multiply, fnFloat32)
            else
                tResolved.hidden = true
            end

        end

        return tResolved

    end

    -- Local transform of a clump model (nuccCoord constructor 0x1412892a0): translation,
    -- Euler rotation, scale
    local function fnNodeMatrix(tBase, tNode)

        if not tNode then return tBase end

        local tLocal = tModules.matrix.Node(tNode.position, tNode.rotation, tNode.scale, fnFloat32, tOptions.sinf, tOptions.cosf)

        return tModules.matrix.World(tBase, tLocal, fnFloat32)

    end

    -- Update the models of a particle after its step (iRate: the scene's updates a second)
    function tModels:Update(tParticle, iRate)

        local tResource = assert(tPackage.resources[tParticle.resource])

        if not tParticle.modelDirection then
            tParticle.modelDirection = {0, 0, 0}
        end

        tParticle.modelDirection = tModules.particle.AdvanceDirection(tParticle.previousPosition, tParticle.position, tParticle.modelDirection, fnFloat32)

        local tFields = {
            position = tParticle.position,
            direction = tParticle.modelDirection,
            travelAligned = tParticle.alignTravel,
            directionTolerance = 0.0010000000474974513,
            angles = {tParticle.rotation[1], tParticle.rotation[2], tParticle.rotation[3]},
            rotationDirty = true,
            parentScale = {1, 1, 1},
            baseScale = tParticle.scale,
            uniformScale = tParticle.attachmentScale
        }

        local tParent, bEnabled = tModules.particle.Parent(tFields, tModules.matrix, fnFloat32, tOptions.sinf, tOptions.cosf)
        tParticle.modelEnabled = bEnabled

        -- 0x14130b200 writes the size-curve output (+88) and hands the model the matrix +A0
        -- the mover built before that write: a model shows the size of the previous update
        -- with the current alpha (capture 22127: shock09 has its size at life 4/8 with its
        -- alpha at 4.5/8). Billboards read +88 directly.
        local tSize = tParticle.modelSize or tOptions.initialSize(tParticle)

        tParticle.modelSize = {tParticle.lifecycleSize[1], tParticle.lifecycleSize[2], tParticle.lifecycleSize[3]}
        tParticle.modelUpdates = (tParticle.modelUpdates or 0) + 1

        local tDraws = {}

        if tResource.kind == "anm" then

            local tCompiled = tModels.CompiledFor(tResource.animation)

            if not tParticle.modelInstance then
                tParticle.modelInstance = tModules.bridge.New(tCompiled.compiled, tModules, {
                    coordinateTranslationScales = tCompiled.scales,
                    materialInstances = tModels.Instances(tCompiled)
                })
            end

            -- A resource the package also has as a studio model (its animation baked into a
            -- sequence): the clock and the parent matrix only, the host plays the sequence
            if tResource.studio and tOptions.studioEnabled and tOptions.studioEnabled() then

                local tScaled = tParticle.modelInstance:UpdateClock(tParent, tSize, tParticle.sampleConfig.simulationHz, iRate, 1)

                tParticle.studioPose = {ticks = tParticle.modelInstance.player.clock.ticks, matrix = tScaled}
                tParticle.modelResult = nil
                tParticle.modelDraws = tDraws
                self.updates = self.updates + 1

                return

            end

            tParticle.studioPose = nil

            local tResult, _, _, tScaled = tParticle.modelInstance:Update(tParent, tSize, tParticle.sampleConfig.simulationHz, iRate, 1)

            for i, tDraw in ipairs(tCompiled.draws) do

                tDraws[i] = tModels.Resolve(tDraw, tResult, tScaled, tParticle.modelInstance.ticks)

                -- A skinned model's palette (relative to its own draw matrix) depends on its
                -- animation's clock alone: copies at the same clock look alike (the host may
                -- share their skinned vertices)
                if tDraw.skin then
                    tDraws[i].poseAnimation, tDraws[i].poseTicks = tDraw, tParticle.modelInstance.player.clock.ticks
                    tDraws[i].poseName = tResource.animation
                end

            end

            -- The evaluated entries, for the trails of the animation (their edge coordinates)
            tParticle.modelResult = tResult

        else

            -- Render 0x14130b64f: the particle's matrix +A0, columns scaled by +1B0
            local tBase = tModules.matrix.ScaleColumns(tParent, tSize, fnFloat32)

            for i, sModel in ipairs(tResource.models) do

                -- A skinned model of a clump nothing animates stays in its rest pose: its
                -- vertices are already in the clump's space
                local tModel = tPackage.models[sModel]
                local tMatrix = tModel.skeleton and tBase or fnNodeMatrix(tBase, tModel.node)
                local tBoard = tResource.billboards and tResource.billboards[sModel]

                -- A billboard member keeps the keys of its frame 0: nothing advances the
                -- clock of an emitter clump's members (journal R102)
                tDraws[i] = tBoard and tModels.Resolve({model = sModel, materials = {}, billboard = tBoard}, {}, tMatrix, 0)
                    or {model = sModel, matrix = tMatrix}

            end

        end

        tParticle.modelDraws = tDraws
        self.updates = self.updates + 1

    end

    -- The models a particle draws now, or nil. A model particle is not drawn on the frame it
    -- is born (the captures never show light00 at age 0.5: the mover has not built its matrix).
    function tModels:Draws(tParticle)

        if not tParticle.modelDraws or not tParticle.modelEnabled or tParticle.modelUpdates < 2 then
            return nil
        end

        return tParticle.modelDraws

    end

    -- A model matrix in the world: the outer matrix * it (into tOut when given, else a new table)
    function tModels:World(tMatrix, tOuterMatrix, tOut)
        return tModules.matrix.World(tOuterMatrix, tMatrix, fnFloat32, tOut)
    end

    return tModels

end

return MODEL_PARTICLES
