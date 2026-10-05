-- Skill scripts. A script is a list of actions; an action has a motion class, parameters, an
-- optional animation (the effect it shows) and events. An event fires a command on its actor
-- and may spawn other scripts with a shot type.
-- The object model is ccGameObjectSkill's: one tick is update 0x1405e5240 (motion from the
-- second tick of an action on, then events, then the effect root, then the frame counter); the
-- motion is StormFX.Core.SkillActor. What the game takes from its world is the host's: the
-- target is one point, the ground and obstacles are traces, a character hit is the actor
-- reaching the target point.

local ENGINE = StormFX.Engine
local CORE = StormFX.Core
local CONFIG = StormFX.Config

local SKILL_ACTOR = CORE.SkillActor
local SKILL_SHOT = CORE.SkillShot
local MATRIX = CORE.AnmMatrix

local fnFloat32 = ENGINE.Float32
local fnSin = ENGINE.tAnmOptions.sinf
local fnCos = ENGINE.tAnmOptions.cosf

-- Motion class of each action type
local CLASSES = {
    SKILL_ACTION_TYPE_NONE = "none",
    SKILL_ACTION_TYPE_ARROW = "arrow",
    SKILL_ACTION_TYPE_CRAWLER = "crawler",
    SKILL_ACTION_TYPE_SINCURVE = "sinCurve",
    SKILL_ACTION_TYPE_ELEVATOR = "elevator",
    SKILL_ACTION_TYPE_BOUNDBALL = "boundBall"
}

ENGINE.tSupportedActions = {}

for sType in pairs(CLASSES) do
    ENGINE.tSupportedActions[sType] = true
end

-- Float parameters of an action (table 0x142060bd0); the loader 0x140a67af0 converts the
-- RATED ones from the 30 Hz reference rate
local FLOATS = {
    "Amplitude_x", "Amplitude_y", "Amplitude_z", "BankRollMax", "BankSpring", "BankStrong", "Frequency_x", "Frequency_y",
    "Frequency_z", "Friction", "Gravity", "Inductivity", "RandomDirection", "RandomRoll", "Restitution", "ViewingAngle",
    "Velocity", "VelocityRandomize", "Rotate_x"
}

local RATED = {Inductivity = true, Velocity = true, VelocityRandomize = true}

-- World-hit events that name a surface: what the hit must be
local SURFACE = {
    SKILL_EVENT_TYPE_HIT_WORLD_WATER = "water",
    SKILL_EVENT_TYPE_HIT_WORLD_WALL = "wall",
    SKILL_EVENT_TYPE_HIT_WORLD_FLOOR = "floor"
}

local GROUND = {
    SKILL_EVENT_TYPE_HIT_WORLD_DIRT = "DIRT",
    SKILL_EVENT_TYPE_HIT_WORLD_STONE = "STONE",
    SKILL_EVENT_TYPE_HIT_WORLD_GRASS = "GRASS",
    SKILL_EVENT_TYPE_HIT_WORLD_SNOW = "SNOW",
    SKILL_EVENT_TYPE_HIT_WORLD_IRONSAND = "IRONSAND"
}

-- Source surface material -> the ground kind of the HIT_WORLD_* events. Hard surfaces the game
-- has no kind for are taken as stone (host choice); a surface of no known material takes
-- StormFX.Config["defaultGround"].
local MATERIALS = {}

for sMaterial, sGround in pairs({
    MAT_DIRT = "DIRT", MAT_SAND = "DIRT", MAT_GRASS = "GRASS", MAT_FOLIAGE = "GRASS", MAT_SNOW = "SNOW",
    MAT_CONCRETE = "STONE", MAT_TILE = "STONE", MAT_METAL = "STONE", MAT_VENT = "STONE", MAT_GRATE = "STONE",
    MAT_COMPUTER = "STONE", MAT_WOOD = "STONE", MAT_GLASS = "STONE", MAT_PLASTIC = "STONE"
}) do

    if _G[sMaterial] then
        MATERIALS[_G[sMaterial]] = sGround
    end

end

-- A parameter of an action: the value (or another attribute) of its first entry
function ENGINE.ActionParameter(tAction, sName, sAttribute)

    local tList = tAction.parameters[sName]

    return tList and tList[1] and tList[1][sAttribute or "value"] or nil

end

local fnParameter = ENGINE.ActionParameter

-- The float parameters of an action, converted once
local function fnFloats(tAction)

    if not tAction.floats then

        tAction.floats = {}

        for _, sName in ipairs(FLOATS) do

            local flValue = fnFloat32(tonumber(fnParameter(tAction, sName)) or 0)

            tAction.floats[sName] = RATED[sName] and SKILL_SHOT.RateAdjustedParameter(flValue, ENGINE.FPS, fnFloat32) or flValue

        end

    end

    return tAction.floats

end

-- Add a line to a cast's log once
local function fnNote(tCast, sText)

    if not tCast.notes[sText] then
        tCast.notes[sText] = true
        tCast.log[#tCast.log + 1] = sText
    end

end

-- The effect root of an actor
local function fnRootOf(tActor)

    local tState = tActor.state

    return SKILL_SHOT.EffectRoot(tState.position, tState.orientation, tState.roll, 1, MATRIX, fnFloat32, fnSin, fnCos)

end

-- Turn an actor's basis toward its velocity
local function fnOrient(tState)
    tState.orientation = SKILL_SHOT.Orientation(tState.orientation, tState.velocity, MATRIX, fnFloat32)
end

-- Game point -> Source point
local function fnWorldPoint(tCast, tPosition)
    return tCast.outer.pos + Vector(tPosition[1], tPosition[2], tPosition[3]) * tCast.outer.scale
end

-- Source point -> game point
local function fnGamePoint(tCast, vecPoint)

    local vecDelta = (vecPoint - tCast.outer.pos) * (1 / tCast.outer.scale)

    return {fnFloat32(vecDelta.x), fnFloat32(vecDelta.y), fnFloat32(vecDelta.z)}

end

-- Stage query 0x140a620a0 of the ground-following classes: a sweep straight down from just
-- above the object. The host probes from groundProbe above it (so a step up is climbed) and
-- answers with the height of what it meets.
local function fnGroundBelow(tCast, tState)

    local vecWorld = fnWorldPoint(tCast, tState.position)

    local tTrace = util.TraceLine({
        start = vecWorld + Vector(0, 0, CONFIG["groundProbe"]),
        endpos = vecWorld - Vector(0, 0, 30000 * tCast.outer.scale),
        mask = MASK_SOLID_BRUSHONLY
    })

    if tTrace.Hit and not tTrace.StartSolid then
        return fnFloat32((tTrace.HitPos.z - tCast.outer.pos.z) / tCast.outer.scale)
    end

    return nil

end

local fnSpawnActor

-- Start an action of an actor: its motion, then its effect
local function fnSetAction(tCast, tActor, iIndex)

    local tAction = tActor.script.actions[iIndex]
    local tState = tActor.state

    tActor.action, tActor.actionIndex, tActor.fired, tActor.motion = tAction, iIndex, {}, {}
    tState.frame = 0

    local sClass = CLASSES[tAction.type]

    if not sClass then
        fnNote(tCast, tActor.id .. ": action " .. tostring(tAction.type) .. " has no translated motion, played as static")
    end

    local tValues = fnFloats(tAction)

    SKILL_ACTOR.Setup(tActor.motion, tState, tValues, tCast.random, ENGINE.FPS, MATRIX, fnFloat32, fnSin, fnCos)

    if sClass == "elevator" then

        SKILL_ACTOR.ElevatorStart(tActor.motion, tState, tValues, fnFloat32)

    elseif sClass == "sinCurve" then

        SKILL_ACTOR.SinCurveStart(tActor.motion, tState, tValues, fnFloat32)

    elseif sClass == "boundBall" then

        SKILL_ACTOR.BoundBallStart(tActor.motion, tState, tValues, fnFloat32)
        fnNote(tCast, tActor.id .. ": BOUNDBALL bounces on what the host traces; its rolling and floating on water are not reproduced")

    elseif sClass == "crawler" then

        -- 0x140a6e430: speed kept, object put on the ground, basis rebuilt
        SKILL_ACTOR.CrawlerStart(tActor.motion, tState, fnFloat32)

        local flHeight = fnGroundBelow(tCast, tState)

        if flHeight then
            tState.position[3] = flHeight
        end

        if fnParameter(tAction, "FixedUp") == "true" then
            SKILL_ACTOR.FixedUp(tState)
        end

        fnOrient(tState)

    end

    if fnParameter(tAction, "SkillHoming") then
        fnNote(tCast, tActor.id .. ": SkillHoming (following another object) is not reproduced")
    end

    if fnParameter(tAction, "Animation", "coord") then
        fnNote(tCast, tActor.id .. ": Animation coord attribute is not reproduced")
    end

    -- <Animation inherite="true"/> keeps the effect of the previous action
    if fnParameter(tAction, "Animation", "inherite") == "true" then return end

    if tActor.instance then
        tActor.instance.killed = true
        tActor.instance.beforeUpdate = nil
        tActor.instance = nil
    end

    tActor.animationEnded = false

    local sChunk = fnParameter(tAction, "Animation", "chunk")

    if not sChunk then return end

    tCast.spawned = tCast.spawned + 1

    local tInstance, sWhy = ENGINE:Launch(tCast.package, sChunk, {
        outer = tCast.outer,
        root = fnRootOf(tActor),
        start = tActor.start + tActor.frame / ENGINE.FPS,
        seed = tCast.seed + tCast.spawned - 1,
        beforeUpdate = function() tActor.tick() end
    })

    if not tInstance then
        fnNote(tCast, tActor.id .. ": " .. tostring(sWhy))
        return
    end

    tActor.instance = tInstance

    for sKind, iCount in pairs(tInstance.ignoredEntries) do
        fnNote(tCast, sChunk .. ": " .. iCount .. " animation entries of type " .. sKind .. " (camera, light, ...) are not played")
    end

    for sName in pairs(tInstance.external) do
        fnNote(tCast, sChunk .. ": attached to " .. sName .. ", a node outside the effect, placed at the effect root")
    end

end

-- Host stand-in for the contact of a resting or crawling object with the world below it (the
-- game's collision query is not traced): a surface within the object's world-hit radius
-- (action Hit hitRadiusWorld, else the script's hit worldHitRadius, game units) above or below
-- it. A contact is reported when it begins and whenever the kind of surface changes, not on
-- every tick: the data's ground variants switch on a surface event and name their own surface
-- again (1efc_e_ge13: action 1 changes to action 1 on DIRT), which a contact reported every tick
-- would restart forever.
local function fnContact(tCast, tActor)

    local tAction = tActor.action

    if fnParameter(tAction, "WorldHitDisable") == "true" then return end

    local flRadius = tonumber(fnParameter(tAction, "Hit", "hitRadiusWorld") or (tActor.script.hit and tActor.script.hit.worldHitRadius)) or 0

    if flRadius <= 0 then return end

    local vecAt = fnWorldPoint(tCast, tActor.state.position)
    local vecReach = Vector(0, 0, flRadius * tCast.outer.scale)

    local tTrace = util.TraceLine({start = vecAt + vecReach, endpos = vecAt - vecReach, mask = MASK_SOLID_BRUSHONLY})
    local tWater = MASK_WATER and util.TraceLine({start = vecAt + vecReach, endpos = vecAt - vecReach, mask = MASK_WATER})

    local tHit, vecPosition, tNormal

    if tWater and tWater.Hit and not tWater.StartSolid and (not tTrace.Hit or (tWater.Fraction or 0) < (tTrace.Fraction or 1)) then

        tHit, vecPosition, tNormal = {world = true, water = true, kind = "water"}, tWater.HitPos, {0, 0, 1}

    elseif tTrace.Hit and not tTrace.StartSolid then

        local vecNormal = tTrace.HitNormal
        local bFloor = vecNormal ~= nil and vecNormal.z > 0.7
        local sMaterial = MATERIALS[tTrace.MatType] or CONFIG["defaultGround"]

        tHit = {
            world = true,
            floor = bFloor,
            wall = not bFloor,
            material = sMaterial,
            kind = (bFloor and "floor " or "wall ") .. sMaterial
        }

        vecPosition = tTrace.HitPos
        tNormal = vecNormal and {vecNormal.x, vecNormal.y, vecNormal.z} or {0, 0, 1}

    end

    local sKind = tHit and tHit.kind or "none"

    if sKind == tActor.contactKind then return end

    tActor.contactKind = sKind

    if tHit then
        tActor.hitPosition, tActor.hitNormal = fnGamePoint(tCast, vecPosition), tNormal
    end

    return tHit

end

-- The motion of one tick (actor class update, vtable +10). Returns what the host saw the actor
-- meet, or nil: {world = true, floor, wall, water, material} or {character = true}.
local function fnMove(tCast, tActor)

    local tAction, tState, tMotion = tActor.action, tActor.state, tActor.motion
    local sClass = CLASSES[tAction.type]

    -- A still object meets the world only by contact (the ones a hit spawns on a surface to
    -- wait for HIT_WORLD_*: 7brteff1_*_e_worldhit00, dust, splash or snow by surface)
    if sClass == "none" then
        return fnContact(tCast, tActor)
    end

    if not sClass then return end

    local tValues, tTarget = fnFloats(tAction), tCast.target
    local vecBefore = fnWorldPoint(tCast, tState.position)
    local tCame = {tState.position[1], tState.position[2], tState.position[3]}

    if sClass == "arrow" then

        SKILL_ACTOR.Arrow(tMotion, tState, tValues, tTarget, fnOrient, fnFloat32, math.acos)

    elseif sClass == "elevator" then

        SKILL_ACTOR.Elevator(tMotion, tState, fnOrient, fnFloat32)

    elseif sClass == "sinCurve" then

        SKILL_ACTOR.SinCurve(tMotion, tState, tValues, tTarget, ENGINE.FPS, fnOrient, fnFloat32, math.acos, math.sin)

    elseif sClass == "crawler" then

        SKILL_ACTOR.Crawler(tMotion, tState, tTarget, ENGINE.FPS, function(tAt) return fnGroundBelow(tCast, tAt) end,
            fnOrient, fnFloat32, math.acos, fnParameter(tAction, "FixedUp") == "true")

    elseif sClass == "boundBall" then

        SKILL_ACTOR.BoundBall(tMotion, tState, tTarget, ENGINE.FPS, function(tAt)

            local vecFrom = fnWorldPoint(tCast, tAt.position)
            local vecStep = Vector(tAt.velocity[1], tAt.velocity[2], tAt.velocity[3]) * tCast.outer.scale
            local tTrace = util.TraceLine({start = vecFrom, endpos = vecFrom + vecStep, mask = MASK_SOLID_BRUSHONLY})

            if not tTrace.Hit or tTrace.StartSolid then return nil end

            local vecNormal = tTrace.HitNormal

            return {
                fraction = fnFloat32(tTrace.Fraction or 0),
                normal = {fnFloat32(vecNormal.x), fnFloat32(vecNormal.y), fnFloat32(vecNormal.z)}
            }

        end, fnFloat32, math.acos)

        -- No orientation update in this class (its basis is the rolling one), and its contacts
        -- are bounces, not the host's hit events
        return

    end

    local tVelocity = tState.velocity
    local flSpeed = SKILL_ACTOR.Length(tVelocity, fnFloat32)

    if not (flSpeed > 0) then

        if sClass == "crawler" then
            return fnContact(tCast, tActor)
        end

        return

    end

    local tHit

    if fnParameter(tAction, "WorldHitDisable") ~= "true" then

        -- Host stand-in for the world-hit events: a crawler only meets walls taller than a
        -- step, other projectiles anything on their path. The game tells surfaces apart by
        -- flags of the stage collision (0x1405e8af4 and on); the host answers with the
        -- trace's normal and material.
        local vecLift = sClass == "crawler" and Vector(0, 0, CONFIG["stepHeight"]) or Vector(0, 0, 0)
        local vecFrom, vecTo = vecBefore + vecLift, fnWorldPoint(tCast, tState.position) + vecLift

        local tTrace = util.TraceLine({start = vecFrom, endpos = vecTo, mask = MASK_SOLID_BRUSHONLY})
        local tWater = MASK_WATER and util.TraceLine({start = vecFrom, endpos = vecTo, mask = MASK_WATER})

        if tWater and tWater.Hit and not tWater.StartSolid and (not tTrace.Hit or (tWater.Fraction or 0) < (tTrace.Fraction or 1)) then

            tHit = {world = true, water = true}
            tActor.hitPosition, tActor.hitNormal = fnGamePoint(tCast, tWater.HitPos), {0, 0, 1}

        elseif tTrace.Hit then

            local vecNormal = tTrace.HitNormal
            local bFloor = vecNormal ~= nil and vecNormal.z > 0.7

            tHit = {world = true, floor = bFloor, wall = not bFloor, material = MATERIALS[tTrace.MatType] or CONFIG["defaultGround"]}
            tActor.hitPosition = fnGamePoint(tCast, tTrace.HitPos)
            tActor.hitNormal = vecNormal and {vecNormal.x, vecNormal.y, vecNormal.z} or {0, 0, 1}

        end

        -- A crawler keeps to the ground: below a wall it meets the floor it runs on
        if not tHit and sClass == "crawler" then
            tHit = fnContact(tCast, tActor)
        end

    end

    if fnParameter(tAction, "CharacterHitDisable") ~= "true" and tTarget then

        -- Host stand-in for the character-hit events: the target point lies on the step just
        -- made, or is now behind the actor. A world contact of the same tick does not hide it
        -- (a crawler reports its floor again at every action start).
        local tAhead = {tTarget[1] - tState.position[1], tTarget[2] - tState.position[2], tTarget[3] - tState.position[3]}
        local tBehind = {tTarget[1] - tCame[1], tTarget[2] - tCame[2], tTarget[3] - tCame[3]}
        local tStep = {tState.position[1] - tCame[1], tState.position[2] - tCame[2], tState.position[3] - tCame[3]}

        local bPassed = tAhead[1] * tStep[1] + tAhead[2] * tStep[2] + tAhead[3] * tStep[3] <= 0
            and tBehind[1] * tStep[1] + tBehind[2] * tStep[2] + tBehind[3] * tStep[3] >= 0

        if bPassed then
            tHit = tHit or {}
            tHit.character = true
            tActor.hitPosition = {tTarget[1], tTarget[2], tTarget[3]}
            tActor.hitNormal = {-tVelocity[1] / flSpeed, -tVelocity[2] / flSpeed, -tVelocity[3] / flSpeed}
        end

    end

    return tHit

end

-- The launches an event's <Effect> makes (spawner 0x1405e72f0, then the shot handler of its
-- shotType). The request starts from the actor's basis, or from the named coordinate of its
-- effect; planeDir puts the hit normal in the up axis; targetDir aims at the target.
local function fnLaunches(tCast, tActor, tEffect, tHit)

    local tState = tActor.state
    local tBasis = tState.orientation
    local tPosition = {tState.position[1], tState.position[2], tState.position[3]}
    local tDirection, tUp = {fnFloat32(-tBasis[2]), fnFloat32(-tBasis[6]), fnFloat32(-tBasis[10])}, {tBasis[3], tBasis[7], tBasis[11]}

    if tEffect.coord and tEffect.coord ~= "" then

        local tCoordinate = tActor.instance and tActor.instance.provider.coordinates and tActor.instance.provider.coordinates[tEffect.coord]

        if tCoordinate then

            local tRotation = tCoordinate.rotation

            tPosition = {tCoordinate.position[1], tCoordinate.position[2], tCoordinate.position[3]}
            tDirection, tUp = {fnFloat32(-tRotation[2]), fnFloat32(-tRotation[5]), fnFloat32(-tRotation[8])}, {tRotation[3], tRotation[6], tRotation[9]}

        else

            fnNote(tCast, tActor.id .. ": coordinate " .. tEffect.coord .. " is not a node of its effect, the actor itself is used")

        end

    end

    if tEffect.planeDir == "true" and tHit and tActor.hitNormal then
        tUp = tActor.hitNormal
    end

    local tTarget = tCast.target
    local bAimed = tEffect.targetDir == "true"
    local sKind = tEffect.shotType or "SKILL_SHOT_TYPE_DEFAULT"
    local iCount, iSecond = math.floor(tonumber(tEffect.shotParam1) or 0), math.floor(tonumber(tEffect.shotParam2) or 0)

    -- One launch along the plane (planeDir) and toward the target (targetDir)
    local function fnPlaned()

        if tEffect.planeDir == "true" then
            tDirection, tUp = SKILL_ACTOR.PlaneDirection(tDirection, tUp, fnFloat32)
        end

        if bAimed then
            tDirection = SKILL_ACTOR.Aim(tPosition, tTarget, tDirection, fnFloat32)
        end

        return {{position = tPosition, direction = tDirection, up = tUp}}

    end

    if sKind == "SKILL_SHOT_TYPE_DEFAULT" then

        return fnPlaned()

    elseif sKind == "SKILL_SHOT_TYPE_N_WAY_HORIZONTAL" then

        if bAimed then
            tDirection = SKILL_ACTOR.Aim(tPosition, tTarget, tDirection, fnFloat32)
        end

        return SKILL_ACTOR.NWay(tPosition, tDirection, tUp, iCount, iSecond, fnFloat32, fnSin, fnCos)

    elseif sKind == "SKILL_SHOT_TYPE_RANDOM_CREATION" then

        local tLaunches = SKILL_ACTOR.RandomCreation(tPosition, tDirection, tUp, iCount, iSecond, tCast.random, fnFloat32)

        if bAimed then
            for _, tLaunched in ipairs(tLaunches) do
                tLaunched.direction = SKILL_ACTOR.Aim(tLaunched.position, tTarget, tDirection, fnFloat32)
            end
        end

        return tLaunches

    elseif sKind == "SKILL_SHOT_TYPE_ENEMY_FOOT" or sKind == "SKILL_SHOT_TYPE_HIT_FOOT" then

        -- 0x140a6abe0: the target's position, dropped on the ground below it
        tPosition = {tTarget[1], tTarget[2], tTarget[3]}

        local vecWorld = fnWorldPoint(tCast, tPosition)

        local tTrace = util.TraceLine({
            start = vecWorld + Vector(0, 0, tCast.outer.scale),
            endpos = vecWorld - Vector(0, 0, 1000 * tCast.outer.scale),
            mask = MASK_SOLID_BRUSHONLY
        })

        if tTrace.Hit and not tTrace.StartSolid then
            tPosition = fnGamePoint(tCast, tTrace.HitPos)
        end

        if bAimed then
            fnNote(tCast, tActor.id .. ": targetDir on a foot shot is not reproduced")
        end

        return {{position = tPosition, direction = tDirection, up = tUp}}

    elseif sKind == "SKILL_SHOT_TYPE_ENEMY_TARGET" then

        tPosition = {tTarget[1], tTarget[2], tTarget[3]}

        return fnPlaned()

    elseif sKind == "SKILL_SHOT_TYPE_HIT" then

        -- The contact point the host recorded, else where the actor is
        if tActor.hitPosition then
            tPosition = {tActor.hitPosition[1], tActor.hitPosition[2], tActor.hitPosition[3]}
        end

        return fnPlaned()

    elseif sKind == "SKILL_SHOT_TYPE_CONST_AXIS_UP" then

        if bAimed then
            tDirection = SKILL_ACTOR.Aim(tPosition, tTarget, tDirection, fnFloat32)
        end

        tDirection, tUp = SKILL_SHOT.ConstAxisUp(tDirection, CORE.ParticleMatrix, fnFloat32)

        return {{position = tPosition, direction = tDirection, up = tUp}}

    end

    fnNote(tCast, tostring(tEffect.name) .. ": shot type " .. tostring(sKind) .. " is played as DEFAULT")

    return fnPlaned()

end

-- Fire an event: its launches, then its command
local function fnFire(tCast, tActor, tEvent, tHit)

    for _, tEffect in ipairs(tEvent.effects) do
        for _, tLaunched in ipairs(fnLaunches(tCast, tActor, tEffect, tHit)) do
            fnSpawnActor(tCast, tEffect.name, tLaunched, tActor)
        end
    end

    -- Commands (0x1405e7dc6, enumeration 0x142060d20). KILL and STICK both end the object
    -- (STICK skips the decal KILL can leave); CHANGE_ACTION takes the action's index; a name
    -- outside the enumeration (REMOVE) does nothing.
    local sCommand = tEvent.command

    if sCommand == "SKILL_EVENT_COMMAND_KILL" or sCommand == "SKILL_EVENT_COMMAND_STICK" then

        tActor.alive = false

        if tActor.instance then
            tActor.instance.killed = true
            tActor.instance.beforeUpdate = nil
        end

    elseif sCommand == "SKILL_EVENT_COMMAND_CHANGE_ACTION" then

        local iIndex = (tonumber(tEvent.commandParameter) or 0) + 1

        if tActor.script.actions[iIndex] then
            fnSetAction(tCast, tActor, iIndex)
        else
            fnNote(tCast, tActor.id .. ": CHANGE_ACTION to a missing action " .. tostring(tEvent.commandParameter))
        end

    elseif sCommand == "SKILL_EVENT_COMMAND_SHAKE" then

        fnNote(tCast, tActor.id .. ": camera shake is not reproduced")

    end

end

-- Frame events count ticks of the action at the 30 Hz reference (0x1405e87f3)
local function fnTicksOf(sFrames)
    return math.floor(fnFloat32(fnFloat32(tonumber(sFrames) or 0) / fnFloat32(30 / ENGINE.FPS)))
end

-- One tick of an actor
local function fnTick(tCast, tActor)

    if not tActor.alive then return end

    local tAction, tState = tActor.action, tActor.state
    local tHit

    if tState.frame > 0 then
        tHit = fnMove(tCast, tActor)
    end

    -- The target was reached on a tick whose action ended before its hit events were read:
    -- the new action sees it now (the host's hit is one point passed once, the game's a
    -- collision that lasts)
    if tActor.reached then

        tActor.reached = nil

        if fnParameter(tAction, "CharacterHitDisable") ~= "true" and tCast.target then
            tHit = tHit or {}
            tHit.character = true
            tActor.hitPosition = {tCast.target[1], tCast.target[2], tCast.target[3]}
        end

    end

    -- Events, 0x1405e8690. First pass: frame, animation and the hit events that name a
    -- surface. Second pass: the DEFAULT hit events; the world one only when no surface event
    -- took the hit. A hit event is fired once here (the host has one target and no hit list).
    local bTaken = false

    for iIndex, tEvent in ipairs(tAction.events) do

        if not tActor.alive or tActor.action ~= tAction then break end

        local sKind = tEvent.type
        local bNow, bAgain = false, false

        if sKind == "SKILL_EVENT_TYPE_FRAME_ELAPSED" then

            bNow = tState.frame == fnTicksOf(tEvent.arg)

        elseif sKind == "SKILL_EVENT_TYPE_FRAME_FIXED" then

            -- Every arg frames, from the first tick on
            local iPeriod = fnTicksOf(tEvent.arg)

            bNow, bAgain = iPeriod ~= 0 and tState.frame % iPeriod == 0, true

        elseif sKind == "SKILL_EVENT_TYPE_ANIMATION_END" then

            -- 0x1412a3c00: a looping animation never ends. loopCount replays are counted, not
            -- replayed.
            local tInstance = tActor.instance

            bNow = tActor.animationEnded or (tInstance ~= nil and not tInstance.loop
                and tInstance.ticks >= tInstance.duration * (tonumber(tEvent.loopCount) or 1))

        elseif tHit and tHit.world and ((SURFACE[sKind] and tHit[SURFACE[sKind]]) or (GROUND[sKind] and tHit.material == GROUND[sKind])) then

            bNow, bTaken = true, true

        end

        if bNow and (bAgain or not tActor.fired[iIndex]) then
            tActor.fired[iIndex] = true
            fnFire(tCast, tActor, tEvent, tHit)
        end

    end

    if tHit then

        tActor.reached = (tHit.character and tActor.alive and tActor.action ~= tAction) or nil

        for iIndex, tEvent in ipairs(tAction.events) do

            if not tActor.alive or tActor.action ~= tAction then break end

            local sKind = tEvent.type
            local bNow = (sKind == "SKILL_EVENT_TYPE_HIT_CHARACTER_DEFAULT" and tHit.character)
                or (sKind == "SKILL_EVENT_TYPE_HIT_WORLD_DEFAULT" and tHit.world and not bTaken)

            if bNow and not tActor.fired[iIndex] then
                tActor.fired[iIndex] = true
                fnFire(tCast, tActor, tEvent, tHit)
            end

        end

    end

    tActor.frame = tActor.frame + 1

    if not tActor.alive then return end

    tActor.state.frame = tActor.state.frame + 1

    if tActor.instance then
        tActor.instance.root = fnRootOf(tActor)
    end

end

-- A launched object (init 0x1405eae00): the direction is its first velocity, its basis comes
-- from the direction and the up axis, guidance is on whenever it has a target, and its first
-- action starts
fnSpawnActor = function(tCast, sSkillId, tLaunched, tParent)

    local tScript = tCast.package.data.skills[sSkillId]

    if not tScript then
        fnNote(tCast, "script " .. tostring(sSkillId) .. " is not in this package")
        return
    end

    if not tScript.actions[1] then return end

    local tDirection = tLaunched.direction

    local tState = {
        position = {tLaunched.position[1], tLaunched.position[2], tLaunched.position[3]},
        velocity = {tDirection[1], tDirection[2], tDirection[3]},
        orientation = SKILL_ACTOR.LaunchBasis(tLaunched.up),
        roll = 0,
        multiplier = 1,
        frame = 0,
        guidance = tCast.target and 1 or 0
    }

    fnOrient(tState)

    local tActor = {
        id = sSkillId,
        script = tScript,
        state = tState,
        alive = true,
        frame = 0,
        start = tParent.start + tParent.frame / ENGINE.FPS
    }

    tActor.tick = function() fnTick(tCast, tActor) end

    tCast.actors[#tCast.actors + 1] = tActor
    fnSetAction(tCast, tActor, 1)

    return tActor

end

-- The scripts of a package no other script spawns, sorted
function ENGINE:RootScripts(sPackage)

    local tData = self:LoadPackage(sPackage).data
    local tSpawned, tRoots = {}, {}

    for _, tScript in pairs(tData.skills) do
        for _, tAction in ipairs(tScript.actions) do
            for _, tEvent in ipairs(tAction.events) do
                for _, tEffect in ipairs(tEvent.effects) do
                    tSpawned[tEffect.name] = true
                end
            end
        end
    end

    for sId in pairs(tData.skills) do
        if not tSpawned[sId] then
            tRoots[#tRoots + 1] = sId
        end
    end

    table.sort(tRoots)

    return tRoots

end

-- Cast a script of a package. tShot: {origin (Vector: where the first script starts, on the
-- ground), target (Vector: where the host reports the hit), scale, seed, start}.
function ENGINE:CastSkill(sPackage, sSkillId, tShot)

    local tRuntime = self:LoadPackage(sPackage)

    sSkillId = sSkillId or self:RootScripts(sPackage)[1]

    if not tRuntime.data.skills[sSkillId] then
        return nil, "script not in the package: " .. tostring(sSkillId)
    end

    local flScale = tShot.scale or CONFIG["scale"]

    self:Begin(flScale)

    local vecDelta = (tShot.target - tShot.origin) * (1 / flScale)

    local tCast = {
        package = tRuntime,
        outer = {pos = tShot.origin, yaw = 0, scale = flScale},
        target = {fnFloat32(vecDelta.x), fnFloat32(vecDelta.y), fnFloat32(vecDelta.z)},
        seed = tShot.seed or 1,
        random = SKILL_ACTOR.Twister(tShot.seed or 1),
        spawned = 0,
        actors = {},
        log = {},
        notes = {}
    }

    -- The first script starts at the origin, level, heading for the target
    local tDirection, tUp = SKILL_SHOT.ConstAxisUp({vecDelta.x, vecDelta.y, vecDelta.z}, CORE.ParticleMatrix, fnFloat32)

    fnSpawnActor(tCast, sSkillId, {position = {0, 0, 0}, direction = tDirection, up = tUp}, {start = tShot.start or CurTime(), frame = 0})

    self.tCasts[#self.tCasts + 1] = tCast

    return tCast

end

-- Cast a script from in front of the local player toward what they aim at
function ENGINE:CastFromPlayer(sPackage, sSkillId, flScale, iSeed)

    local pPlayer = LocalPlayer()

    if not IsValid(pPlayer) then return end

    flScale = math.Clamp(flScale or CONFIG["scale"], 0.01, 5)

    local tAim = pPlayer:GetEyeTrace()
    local vecForward = pPlayer:GetAimVector()

    vecForward.z = 0
    vecForward:Normalize()

    local vecFeet = pPlayer:GetPos() + vecForward * (CONFIG["launchOffset"] * flScale)
    local vecProbe = Vector(0, 0, CONFIG["groundProbe"])
    local tGround = util.TraceLine({start = vecFeet + vecProbe, endpos = vecFeet - vecProbe, mask = MASK_SOLID_BRUSHONLY})

    local tCast, sWhy = self:CastSkill(sPackage, sSkillId, {
        origin = tGround.Hit and tGround.HitPos or vecFeet,
        target = tAim.HitPos,
        scale = flScale,
        seed = iSeed
    })

    if not tCast then
        print("Storm FX: " .. tostring(sWhy))
        return
    end

    print(string.format("Storm FX %s: %s / %s at scale %.3f", self.sVersion, sPackage, tCast.actors[1] and tCast.actors[1].id or "?", flScale))

    return tCast

end
