-- Forces and motion of a particle (game: force dispatch 0x141385ec0, integration 0x141386b70).
-- The caller resolves the force fields' centres and directions and supplies the step.

StormFX.Core.ParticleMotion = StormFX.Core.ParticleMotion or {}

local PARTICLE_MOTION = StormFX.Core.ParticleMotion

local FL_EPSILON = 1.1754943508222875e-38 -- the game's float at 0x141860548

-- tTarget += tSource * flFactor
local function fnAdd(tTarget, tSource, flFactor)

    for i = 1, 3 do
        tTarget[i] = tTarget[i] + tSource[i] * flFactor
    end

end

-- The force fields that apply, from the lists the mask selects (game: 0x141386bfb, context
-- +90, +88, +80 in that order)
function PARTICLE_MOTION.RouteFields(iMask, tLists)

    local tFields = {}

    for i, iBit in ipairs({1, 256, 65536}) do

        if math.floor(iMask / iBit) % 2 == 1 then

            for _, tField in ipairs(tLists[i] or {}) do
                tFields[#tFields + 1] = tField
            end

        end

    end

    return tFields

end

-- A vector rotated about an axis by flAngle radians (game: 0x1411f1870 -> 0x1411bb590 ->
-- 0x1411bcea0: the quaternion (axis * sin(angle / 2), cos(angle / 2)) as matrix rows)
function PARTICLE_MOTION.RotateAxis(tVector, tAxis, flAngle)

    local flSin, flW = math.sin(flAngle * 0.5), math.cos(flAngle * 0.5)
    local flX, flY, flZ = tAxis[1] * flSin, tAxis[2] * flSin, tAxis[3] * flSin

    return {
        (1 - 2 * (flY * flY + flZ * flZ)) * tVector[1] + 2 * (flX * flY - flW * flZ) * tVector[2] + 2 * (flX * flZ + flW * flY) * tVector[3],
        2 * (flX * flY + flW * flZ) * tVector[1] + (1 - 2 * (flX * flX + flZ * flZ)) * tVector[2] + 2 * (flY * flZ - flW * flX) * tVector[3],
        2 * (flX * flZ - flW * flY) * tVector[1] + 2 * (flY * flZ + flW * flX) * tVector[2] + (1 - 2 * (flX * flX + flY * flY)) * tVector[3]
    }

end

-- Scratch vectors of Force, refilled for every field (no table made per particle)
local tOffsetScratch, tAxisScratch, tRelativeScratch = {0, 0, 0}, {0, 0, 0}, {0, 0, 0}

-- Apply one force field to a particle. Returns false and a reason for an unknown kind.
function PARTICLE_MOTION.Force(tState, tField, flStep)

    local tConfig = tField.config

    if tConfig.strength == 0 then return true end

    local tOffset = tOffsetScratch
    local flSquared = 0

    for i = 1, 3 do
        tOffset[i] = tField.center[i] - tState.position[i]
        flSquared = flSquared + tOffset[i]^2
    end

    local flDistance = math.sqrt(flSquared)
    local flRadius = tConfig.radius_base * tField.directionLength

    if tConfig.limit_radius and flRadius * flRadius <= flSquared then return true end

    local flFalloff = 1

    if tConfig.limit_radius and math.abs(flRadius) > FL_EPSILON then

        if tConfig.falloff_mode == 1 then
            flFalloff = 1 - flDistance / flRadius
        elseif tConfig.falloff_mode == 2 then
            flFalloff = flDistance / flRadius
        end

    end

    local flStrength = tConfig.strength * (1 + tConfig.strength_multiplier) * tState.scalar * flStep
    local iKind = tConfig.selector

    if iKind == 0 then

        -- Whirl about the field's axis
        local flSquaredAxis = 0

        for i = 1, 3 do
            flSquaredAxis = flSquaredAxis + tField.direction[i]^2
        end

        if flSquaredAxis <= FL_EPSILON then return true end

        local flReciprocal = math.abs(tField.directionLength) > FL_EPSILON and 1 / tField.directionLength or 1
        local tAxis = tAxisScratch
        local tRelative = tRelativeScratch

        for i = 1, 3 do
            tAxis[i] = tField.direction[i] / math.sqrt(flSquaredAxis)
            tRelative[i] = -tOffset[i]
        end

        local tRotated = PARTICLE_MOTION.RotateAxis(tRelative, tAxis, flStrength * flFalloff * flReciprocal)

        -- The game accumulates the move into +0x1dc (shared with the parent's motion): no
        -- direct move of +0x7c, no lasting velocity
        tState.displacement = tState.displacement or {0, 0, 0}

        for i = 1, 3 do
            tState.displacement[i] = tState.displacement[i] + tRotated[i] - tRelative[i]
        end

    elseif iKind == 1 then

        -- Speed
        tState.speed = tState.speed + flStrength

        if flStrength < 0 and tState.speed < 0 then
            tState.speed = 0
        end

    elseif iKind == 2 then

        -- Attraction toward the centre
        if flDistance > FL_EPSILON then
            fnAdd(tState.velocity, tOffset, flStrength * flFalloff / flDistance)
        end

    elseif iKind == 3 then
        fnAdd(tState.position, tField.direction, flStrength * flFalloff)
    elseif iKind == 4 then
        fnAdd(tState.rotation, tConfig.vector_parameter, flStrength * flFalloff)
    elseif iKind == 5 then
        fnAdd(tState.scale, tConfig.vector_parameter, flStrength * flFalloff)
    elseif iKind == 6 then
        fnAdd(tState.velocity, tField.direction, flStrength * flFalloff)
    else
        return false, "unknown force selector"
    end

    return true

end

-- Move a particle by one step: its velocity, its parent's move, the forces' displacement and
-- its secondary velocity
function PARTICLE_MOTION.Integrate(tState, flStep, tParentDisplacement)

    fnAdd(tState.position, tState.velocity, tState.speed * flStep)
    fnAdd(tState.position, tParentDisplacement, tState.speed)

    if tState.displacement then

        fnAdd(tState.position, tState.displacement, tState.speed)

        for i = 1, 3 do
            tState.displacement[i] = 0
        end

    end

    fnAdd(tState.position, tState.secondaryVelocity, tState.speed * flStep)

end

return PARTICLE_MOTION
