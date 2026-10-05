-- Trails (StormFX.Core.Trail). Every animation object of an effect launches the trails of its
-- animation (0x1412ba6f0): the effect's own animation, and the animation each particle with
-- an animated resource plays. A set of trails belongs to one such object: while it lives, each
-- of its updates samples the world positions of the edge coordinates, with its animation's time
-- in ticks for the keys (0x1412ba230 -> 0x141325090). When the object goes (effect over or
-- killed, particle dead), the set is released (0x1412ba540 -> 0x14127a090(handle, 0, 0) ->
-- group 0x141322310 -> trail +168 = 1): its trails stop sampling and shrink, one sample per
-- update, then vanish.

local ENGINE = StormFX.Engine
local TRAIL = StormFX.Core.Trail

local fnFloat32 = ENGINE.Float32

-- A released set has no edges
local NO_EDGE = {0, 0, 0}

-- An edge is looked up in the object's coordinates (0x14132b3f0) by its parent and its name,
-- then by its name alone: the names are the instance names the animation gives its clumps and
-- their coordinates (entry target, clump name), not the chunk names
local function fnEdgeKey(tAnimation, tEdge)

    local iFound

    for iKey, tEntry in ipairs(tAnimation.entries) do

        if tEntry.type == 1 and tEntry.target == tEdge.coord then

            local tClump = tEntry.clump_index and tEntry.clump_index >= 0 and tAnimation.clumps[tEntry.clump_index + 1]

            if tEdge.parent and tClump and tClump.name == tEdge.parent then
                return iKey
            end

            iFound = iFound or iKey

        end

    end

    return iFound

end

-- The trails of an animation, or nil when it has none
function ENGINE:NewTrailSet(tData, sName)

    local tDefinitions = tData.trails and tData.trails[sName]

    if not tDefinitions then return nil end

    local tSet = {animation = tData.animations[sName], trails = {}}

    for _, tDefinition in ipairs(tDefinitions) do

        -- Force fields (table 3): their coordinate is looked up once (0x14132b350) with the
        -- parent's key; what that key matches was not traced, so (parent, name) is tried, then
        -- the name. None found: the field sits at the origin, as in the game.
        local tFields = {}

        for _, tField in ipairs(tDefinition.fields or {}) do
            tFields[#tFields + 1] = {
                field = tField,
                key = tField.coord and fnEdgeKey(tSet.animation, {coord = tField.coord, parent = tField.parent})
            }
        end

        local tState = TRAIL.New()

        -- Fewer ribbon points per segment than the game (Config trailSubdivisions)
        tState.maxSubdivisions = StormFX.Config["trailSubdivisions"]

        tSet.trails[#tSet.trails + 1] = {
            def = tDefinition,
            state = tState,
            board = tData.resources[tDefinition.billboard],
            updates = 0,
            keys = {fnEdgeKey(tSet.animation, tDefinition.edges[1]), fnEdgeKey(tSet.animation, tDefinition.edges[2])},
            fields = tFields
        }

    end

    return tSet

end

-- One update of a set: tResult = the owner's evaluated entries, iTicks = its animation time.
-- A released set has no time (-1) and no edges.
function ENGINE:UpdateTrailSet(tSet, tResult, iTicks)

    for _, tTrail in ipairs(tSet.trails) do

        if tSet.released then

            tTrail.state.ending = true
            TRAIL.Update(tTrail.state, tTrail.def, -1, NO_EDGE, NO_EDGE, 1, fnFloat32)
            tTrail.updates = tTrail.updates + 1

        else

            local tStart = tTrail.keys[1] and tResult[tTrail.keys[1]] and tResult[tTrail.keys[1]].worldMatrix
            local tEnd = tTrail.keys[2] and tResult[tTrail.keys[2]] and tResult[tTrail.keys[2]].worldMatrix

            if tStart and tEnd then

                local tFields

                if #tTrail.fields > 0 then

                    tFields = {}

                    for i, tField in ipairs(tTrail.fields) do
                        tFields[i] = {
                            field = tField.field,
                            matrix = tField.key and tResult[tField.key] and tResult[tField.key].worldMatrix or nil
                        }
                    end

                end

                TRAIL.Update(tTrail.state, tTrail.def, iTicks, {tStart[4], tStart[8], tStart[12]}, {tEnd[4], tEnd[8], tEnd[12]}, 1, fnFloat32, tFields)
                tTrail.updates = tTrail.updates + 1

            else

                tTrail.missing = true

            end

        end

    end

end

-- Whether no trail of a set has a sample left
function ENGINE:IsTrailSetEmpty(tSet)

    for _, tTrail in ipairs(tSet.trails) do
        if #tTrail.state.samples > 0 then return false end
    end

    return true

end

-- After an update of a running effect: a particle set its owner did not update (the particle
-- is gone) is released; released particle sets shrink; empty released sets go
function ENGINE:SettleTrailSets(tInstance)

    for i = #tInstance.trailSets, 1, -1 do

        local tSet = tInstance.trailSets[i]

        if tSet.particle then

            if not tSet.touched then
                tSet.released = true
                self:UpdateTrailSet(tSet)
            end

            tSet.touched = false

        end

        if tSet.released and self:IsTrailSetEmpty(tSet) then
            table.remove(tInstance.trailSets, i)
        end

    end

end
