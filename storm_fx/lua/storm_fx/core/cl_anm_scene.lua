-- An effect's animation as a scene: the coordinates its emitters attach to, its point
-- lights, and every entry for the models the effect draws itself. The root, the translation
-- scales and the local clock are the caller's.

StormFX.Core.AnmScene = StormFX.Core.AnmScene or {}

local ANM_SCENE = StormFX.Core.AnmScene

-- Evaluations kept by clock value (an effect that loops, or plays again, goes through the same
-- ones): under the identity root the whole evaluation depends on the clock alone, so it is
-- made once and shared, its material instances' values kept with it and written back. Read
-- only for whoever gets them. At most MAX_KEPT clock values an animation.
local MAX_KEPT = 1024

ANM_SCENE.bKeep = ANM_SCENE.bKeep ~= false

local function fnIdentity(tMatrix)

    for i = 1, 16 do
        if tMatrix[i] ~= ((i == 1 or i == 6 or i == 11 or i == 16) and 1 or 0) then return false end
    end

    return true

end

-- The material instances' fields, copied (by entry key, then field offset)
local function fnSnapshot(tInstances)

    local tCopy = {}

    for iKey, tFields in pairs(tInstances) do

        local tFieldsCopy = {}

        for iOffset, flValue in pairs(tFields) do
            tFieldsCopy[iOffset] = flValue
        end

        tCopy[iKey] = tFieldsCopy

    end

    return tCopy

end

-- The scene of an animation. tContext: {translationScales, rootMatrix, compiled (optional),
-- options, materialInstances}.
function ANM_SCENE.New(tAnimation, tModules, tContext)

    assert(tContext and tContext.translationScales and tContext.rootMatrix, "The coordinates' context is required")

    local tCompiled = tContext.compiled or tModules.animation.Compile(tAnimation, tModules, tContext.options)
    local tScene = {compiled = tCompiled, ticks = nil, coordinates = nil, lights = {}}

    -- Evaluate the scene at iTicks under tRootMatrix: coordinates by name {position, rotation}
    -- and point lights by name (their fields); self.result keeps every entry
    function tScene:Evaluate(iTicks, tRootMatrix)

        local tRoot = tRootMatrix or tContext.rootMatrix
        local tInstances = tContext.materialInstances or {}
        local tKept

        -- Kept for this animation and these translation scales, under the identity root
        if ANM_SCENE.bKeep and fnIdentity(tRoot) then

            tKept = tCompiled.sceneKept

            if not tKept or tKept.scales ~= tContext.translationScales then
                tKept = {scales = tContext.translationScales, count = 0, ticks = {}}
                tCompiled.sceneKept = tKept
            end

            local tHit = tKept.ticks[iTicks]

            if tHit then

                for iKey, tFields in pairs(tHit.instances) do

                    local tInstance = tInstances[iKey]

                    if tInstance then
                        for iOffset, flValue in pairs(tFields) do
                            tInstance[iOffset] = flValue
                        end
                    end

                end

                self.ticks, self.coordinates, self.lights, self.result = iTicks, tHit.coordinates, tHit.lights, tHit.result

                return tHit.coordinates, tHit.lights

            end

            if tKept.count >= MAX_KEPT then
                tKept = nil
            end

        end

        -- Shared cached scenes stay immutable; transformed scenes own their buffers.
        local tResult = tModules.animation.Evaluate(tCompiled, iTicks, tInstances, not tKept and self.resultStore or nil)
        if not tKept then self.resultStore = tResult end
        local tContexts = self.contexts or {}
        self.contexts = tContexts

        for i, tEntry in ipairs(tCompiled.entries) do

            if tEntry.type == 1 then
                local tEntryContext = tContexts[i] or {}
                tEntryContext.parentMatrix = tRoot
                tEntryContext.translationScale = assert(tContext.translationScales[i], "A coordinate has no translation scale")
                tContexts[i] = tEntryContext
            end

        end

        tModules.animation.CoordinateMatrices(tCompiled, tResult, tContexts, tRootMatrix or tContext.rootMatrix)

        local tCoordinates = not tKept and self.coordinateStore or {}
        local tLights = not tKept and self.lightStore or {}
        tCoordinates, tLights = tCoordinates or {}, tLights or {}
        if not tKept then self.coordinateStore, self.lightStore = tCoordinates, tLights end

        for _, tItem in ipairs(tResult) do

            if tItem.type == 1 then

                local tMatrix = tItem.worldMatrix

                local tCoordinate = tCoordinates[tItem.target] or {position = {}, rotation = {}}
                local tPosition, tRotation = tCoordinate.position, tCoordinate.rotation
                tPosition[1], tPosition[2], tPosition[3] = tMatrix[4], tMatrix[8], tMatrix[12]
                for iRow = 0, 2 do
                    for iCol = 1, 3 do tRotation[iRow * 3 + iCol] = tMatrix[iRow * 4 + iCol] end
                end
                tCoordinates[tItem.target] = tCoordinate

            elseif tItem.type == 6 then
                tLights[tItem.target] = tItem.fields
            end

        end

        self.ticks = iTicks
        self.coordinates = tCoordinates
        self.lights = tLights
        self.result = tResult

        if tKept then
            tKept.ticks[iTicks] = {coordinates = tCoordinates, lights = tLights, result = tResult, instances = fnSnapshot(tInstances)}
            tKept.count = tKept.count + 1
        end

        return tCoordinates, tLights

    end

    return tScene

end

return ANM_SCENE
