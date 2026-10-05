-- Point lights of the scene as the game hands them to a lit model:
--   0x14110dac0  ccCmnLightManager: a light joins the end of the list, unless its two
--                radii are zero
--   0x14110ded0  the lights of an object: the first four of the list, sorted
--   0x1412c9cd0  their sort key for the object's position
--   0x1413368f0  render context fill: g_pointLightColor / Pos / Param of a slot
-- A light: {position = {x, y, z} (world), color = {r, g, b}, intensity, near, far}.
-- verify_point_light_native.py runs the first three against the game's code.

StormFX.Core.PointLight = StormFX.Core.PointLight or {}

local POINT_LIGHT = StormFX.Core.PointLight

local FL_EPSILON = 1.1920928955078125e-07

-- Length of a vector (game: 0x1411ac850)
local function fnLength(flX, flY, flZ, fnFloat32)
    return fnFloat32(math.sqrt(fnFloat32(fnFloat32(fnFloat32(flX * flX) + fnFloat32(flY * flY)) + fnFloat32(flZ * flZ))))
end

-- Whether the manager accepts a light (both radii zero: refused)
function POINT_LIGHT.Accepted(tLight)
    return not (tLight.near == 0 and tLight.far == 0)
end

-- Sort key of a light for a position: minus (intensity, attenuated between the two radii)
-- times the distance. The strongest sorts first; no positive intensity, or out of reach: 0.
function POINT_LIGHT.Key(tLight, tPosition, fnFloat32)

    local tLightPosition = tLight.position
    local flDistance = fnLength(fnFloat32(tLightPosition[1] - tPosition[1]), fnFloat32(tLightPosition[2] - tPosition[2]), fnFloat32(tLightPosition[3] - tPosition[3]), fnFloat32)
    local flWeight = tLight.intensity

    if flWeight > 0 and not (flDistance > tLight.far) then

        if flDistance >= tLight.near then
            flWeight = fnFloat32(flWeight * fnFloat32(fnFloat32(tLight.far - flDistance) / fnFloat32(tLight.far - tLight.near)))
        end

    else
        flWeight = 0
    end

    return fnFloat32(-flWeight * flDistance)

end

-- The lights of an object at tPosition: the first four of the manager's list (in
-- registration order, whatever their distance), sorted by key (lights of equal keys keep
-- their order, as std::sort on four slots does)
function POINT_LIGHT.Select(tLights, tPosition, fnFloat32)

    local tSlots = {}

    for i = 1, math.min(#tLights, 4) do
        tSlots[i] = {light = tLights[i], key = POINT_LIGHT.Key(tLights[i], tPosition, fnFloat32)}
    end

    for i = 2, #tSlots do

        local tSlot = tSlots[i]
        local j = i - 1

        while j >= 1 and tSlots[j].key > tSlot.key do
            tSlots[j + 1] = tSlots[j]
            j = j - 1
        end

        tSlots[j + 1] = tSlot

    end

    local tSelected = {}

    for i, tSlot in ipairs(tSlots) do
        tSelected[i] = tSlot.light
    end

    return tSelected

end

-- Shader constants of one light slot. The far radius is pushed away from the near one when
-- they are closer than far * epsilon; the game leaves the w of colour and position unwritten.
function POINT_LIGHT.Constants(tLight, fnFloat32)

    local flNear, flFar = tLight.near, tLight.far
    local flMargin = fnFloat32(flFar * FL_EPSILON)

    if flMargin > math.abs(fnFloat32(flFar - flNear)) then
        flFar = fnFloat32(flFar + flMargin)
    end

    return {
        color = {tLight.color[1], tLight.color[2], tLight.color[3], 1},
        position = {tLight.position[1], tLight.position[2], tLight.position[3], 1},
        param = {tLight.intensity, flNear, flFar, fnFloat32(1 / fnFloat32(flFar - flNear))}
    }

end

-- A slot no light uses
POINT_LIGHT.unused = {
    color = {0, 0, 0, 1},
    position = {0, 0, 0, 1},
    param = {0, 0, 1, FL_EPSILON}
}

return POINT_LIGHT
