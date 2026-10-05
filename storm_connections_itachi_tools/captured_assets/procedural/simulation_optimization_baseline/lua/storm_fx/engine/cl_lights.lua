-- Point lights. An effect registers the lights of its animation with the scene when it starts
-- (0x1405fb550 -> ccCmnLightManager 0x14110dac0: in entry order, a light whose two radii are
-- zero being refused) and takes them back when it ends. A light is an animation entry of type 6
-- outside the clumps, naming its nuccChunkLightPoint (a page-local reference, journal R86):
-- colour, intensity, local position and radii are the entry's curves, the world position is the
-- parent's world matrix x the local position (nuccLightPoint 0x1412c9a40). No light entry of the
-- data has a parent link, so the parent is taken as the animation's root (what the game hangs it
-- on is not traced). Kept here in Source units: world position, radii scaled.
-- When the game takes a light back is not traced: an effect holds its lights as long as it
-- shows its own models.

local ENGINE = StormFX.Engine
local POINT_LIGHT = StormFX.Core.PointLight
local CONFIG = StormFX.Config

local fnFloat32 = ENGINE.Float32

-- The point lights of the running effects
function ENGINE:CollectLights()

    local tLights = {}

    for _, tInstance in ipairs(self.tInstances) do

        local tResult = tInstance.provider.result

        if tResult and not tInstance.killed and (tInstance.loop or tInstance.ticks < tInstance.duration) then

            local tOuter = tInstance.outer
            local flCos, flSin = math.cos(tOuter.yaw * math.pi / 180), math.sin(tOuter.yaw * math.pi / 180)

            tInstance.lightAccepted = tInstance.lightAccepted or {}

            for iKey, tItem in ipairs(tResult) do

                if tItem.type == 6 then

                    local tFields = tItem.fields

                    local tLight = {
                        color = {tFields[0x50], tFields[0x54], tFields[0x58]},
                        intensity = tFields[0x60],
                        near = tFields[0x88],
                        far = tFields[0x8c],
                        effect = tInstance.effect
                    }

                    if tInstance.lightAccepted[iKey] == nil then
                        tInstance.lightAccepted[iKey] = POINT_LIGHT.Accepted(tLight)
                    end

                    if tInstance.lightAccepted[iKey] then

                        local tRoot = tInstance.root
                        local x, y, z = tFields[0x70], tFields[0x74], tFields[0x78]

                        local gx = tRoot[1] * x + tRoot[2] * y + tRoot[3] * z + tRoot[4]
                        local gy = tRoot[5] * x + tRoot[6] * y + tRoot[7] * z + tRoot[8]
                        local gz = tRoot[9] * x + tRoot[10] * y + tRoot[11] * z + tRoot[12]

                        tLight.position = {
                            tOuter.pos.x + (flCos * gx - flSin * gy) * tOuter.scale,
                            tOuter.pos.y + (flSin * gx + flCos * gy) * tOuter.scale,
                            tOuter.pos.z + gz * tOuter.scale
                        }

                        tLight.near, tLight.far = fnFloat32(tLight.near * tOuter.scale), fnFloat32(tLight.far * tOuter.scale)
                        tLights[#tLights + 1] = tLight

                    end

                end

            end

        end

    end

    return tLights

end

-- Point light slot 0 of a model's light set (context fill 0x1413368f0): the lights its light
-- mode hands it for its position, strongest first; the lit shaders read the first. tPosition:
-- the model's origin, in Source units.
function ENGINE:LightSlot(tPosition, iLightByte)

    local tFirst = self.tStage.pointLightModes[iLightByte] and POINT_LIGHT.Select(self.tLights, tPosition, fnFloat32)[1]

    return tFirst and POINT_LIGHT.Constants(tFirst, fnFloat32) or POINT_LIGHT.unused

end

-- Host stand-in: the game lights its stage and characters with these lights; here they become
-- Source dynamic lights, reaching as far as the far radius. Source cannot subtract light, so a
-- light of negative intensity (Amaterasu) is left out.
-- Config dynamicLights: "models" lights the models only (Source's entity lights: cheap),
-- "world" the map too (each frame Source rebuilds the lightmaps of every surface the light
-- reaches, on the CPU: a few big lights can freeze the game), false none. At most
-- Config maxDynamicLights, the strongest first.
local tShown = {}

local function fnStronger(tA, tB)
    return tA.intensity * tA.far > tB.intensity * tB.far
end

function ENGINE:ShowLights(tLights)

    local sMode = CONFIG["dynamicLights"]

    if not sMode or not DynamicLight then return end

    for i = #tShown, 1, -1 do
        tShown[i] = nil
    end

    for _, tLight in ipairs(tLights) do
        if tLight.intensity > 0 and tLight.far > 0 then
            tShown[#tShown + 1] = tLight
        end
    end

    table.sort(tShown, fnStronger)

    local bModelsOnly = sMode ~= "world"

    for iIndex = 1, math.min(#tShown, CONFIG["maxDynamicLights"] or 4) do

        local tLight = tShown[iIndex]
        local tDynamic = DynamicLight(CONFIG["lightIndex"] + iIndex, bModelsOnly)

        if tDynamic then
            tDynamic.pos = Vector(tLight.position[1], tLight.position[2], tLight.position[3])
            tDynamic.r = math.Clamp(tLight.color[1] * 255, 0, 255)
            tDynamic.g = math.Clamp(tLight.color[2] * 255, 0, 255)
            tDynamic.b = math.Clamp(tLight.color[3] * 255, 0, 255)
            tDynamic.brightness = tLight.intensity * CONFIG["lightBrightness"]
            tDynamic.size = tLight.far
            tDynamic.decay = 0
            tDynamic.dietime = CurTime() + 0.1
        end

    end

end
