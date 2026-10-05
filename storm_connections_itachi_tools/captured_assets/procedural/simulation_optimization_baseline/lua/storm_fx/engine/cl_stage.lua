-- The stage: what the game's scene hands the effects (fog, light sets, directional light,
-- stage colour, tone), as captured in the Amaterasu match (frames 22082..22200). A host may
-- replace StormFX.Engine.tStage.
-- The game reads the fog from the render context a model is submitted in (context +20) and
-- the ambient from that context's light set, chosen by the model's light byte (0x141312a90 on
-- context +38).

local ENGINE = StormFX.Engine

ENGINE.tStage = {

    -- The stage fog, and the model layers whose context carried it in the captures (0 and 2;
    -- 1 and 18 had it disabled, 3 was never captured)
    fogColor = {0.6470588446, 0.9215686321, 1},
    fogParam = {200, 13000, 0.30000001192092896},
    fogLayers = {[0] = true, [2] = true},

    -- Ambient by model light byte. 0 and 1: light mode 0x140ae8e80, ambient (1, 1, 1). 4: no
    -- light mode, the context's default light set (captured). 3: light mode 0x140ae91f0, the
    -- light manager's ambient (manager +F0, the scene block's first ambient): the mode of the
    -- characters (light byte 3), whose captured draws carried 120 / 255 with the directional
    -- light below. Effect lights that override the ambient (0x140ae8940) are not played.
    lightSets = {[0] = {1, 1, 1}, [1] = {1, 1, 1}, [3] = {120 / 255, 120 / 255, 120 / 255},
        [4] = {0.9411764741, 0.9607843161, 0.8235294223}},
    defaultAmbient = {1, 1, 1},

    -- Light bytes with a light mode in the effects' context (table 0x140ae98e0): 0, 1 and 3.
    -- Any other byte takes the context's default light set (+30), the one captured under
    -- byte 4 (journal R95).
    lightModes = {[0] = true, [1] = true, [3] = true},

    -- Light bytes whose light mode hands the effects' point lights to the model (0x140ae9ce0)
    pointLightModes = {[0] = true, [1] = true, [3] = true},

    -- The first directional light of the scene's light set (the world direction it travels
    -- along, its colour), the stage colour and the cel-shade offset: one value each over the
    -- 476 lit draws of the captures
    lightDirection = {-0.58321, 0.29161, -0.75818},
    lightColor = {160 / 255, 160 / 255, 140 / 255},
    stageColor = {143 / 255, 142 / 255, 98 / 255, 1},
    celShade = 0,

    -- The constants of the stage's tone pass (StormFX.StagePost)
    tone = {
        paramR = {-0.0372549, 0.0372549, 0.0372549, 0},
        paramG = {-0.0156863, 0.0156863, -0.0156863, 0},
        paramB = {-0.027451, -0.027451, 0.027451, 0},
        hparam = {0, 0, 0, 0},
        lparam = {0, 0, 0, 0.0196078}
    }

}

-- The values of the scene for one model, by the game's constant names. g_clip / g_zrange are
-- the camera constants of the soft-particle shaders, set so that their linear depth is
-- Source's view depth (there is no scene depth to fade against).
function ENGINE:StageValues(tItem, flScale)

    local tStage = self.tStage
    local tView = render.GetViewSetup and render.GetViewSetup() or {}
    local flNear, flFar = tView.znear or 7, tView.zfar or 30000
    local tFog = tItem.fogged and tStage.fogParam or nil
    local tLight = tStage.lightDirection

    return {

        g_fogParam = tFog and {tFog[1] * flScale, tFog[2] * flScale, tFog[3], 0} or {0, 1, 0, 0},
        g_fogColor = tItem.fogged and tStage.fogColor or {0, 0, 0},

        -- A byte without a light mode takes the default light set (byte 4's); a light mode
        -- without a captured ambient has the host default
        g_ambientColor = tStage.lightSets[tItem.light] or (not tStage.lightModes[tItem.light] and tStage.lightSets[4])
            or tStage.defaultAmbient,

        g_ScreenToUV = StormFX.Core.MaterialContext.ScreenToUV(ScrW(), ScrH()),

        -- Lit families (context fill 0x1413368f0). The vertex shader takes the light direction
        -- into object space with the inverse of the model matrix it is given; that matrix
        -- carries the host scale, undone here. Light slots 1..3 are unused.
        g_lightDirectionWorld = {tLight[1] * flScale, tLight[2] * flScale, tLight[3] * flScale, 0},
        g_lightColor = {tStage.lightColor[1], tStage.lightColor[2], tStage.lightColor[3], 1, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1},

        g_stageColor = tStage.stageColor,
        g_celShadeParam = {tStage.celShade, 0, 0, 0},

        -- The .w of the two screen-tint colours is the inverse screen size (the colours are
        -- compiled into the shaders, see storm_import.py)
        g_cparaColor1 = {1, 1, 1, 1 / ScrW()},
        g_cparaColor2 = {1, 1, 1, 1 / ScrH()},

        g_clip = {flFar * flNear, flFar - flNear, flFar, 0},
        g_zrange = {1, 0, 0, 0}

    }

end
