-- Storm FX: the effects of NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS, played in Garry's Mod.
-- The files are loaded in this order; the prefix of a file name gives its realm:
-- cl_ client, sv_ server, sh_ both.

StormFX = StormFX or {}
StormFX.Core = StormFX.Core or {}

local tFiles = {

    -- Settings
    "storm_fx/sh_config.lua",

    -- The game's routines, translated (particles, animations, trails, skill motion)
    "storm_fx/core/cl_curves.lua",
    "storm_fx/core/cl_anm_clock.lua",
    "storm_fx/core/cl_anm_matrix.lua",
    "storm_fx/core/cl_anm_resource.lua",
    "storm_fx/core/cl_anm_scene.lua",
    "storm_fx/core/cl_billboard.lua",
    "storm_fx/core/cl_color_animation.lua",
    "storm_fx/core/cl_emission.lua",
    "storm_fx/core/cl_facing.lua",
    "storm_fx/core/cl_material_animation.lua",
    "storm_fx/core/cl_material_context.lua",
    "storm_fx/core/cl_model_instance.lua",
    "storm_fx/core/cl_model_particles.lua",
    "storm_fx/core/cl_particle_matrix.lua",
    "storm_fx/core/cl_particle_motion.lua",
    "storm_fx/core/cl_particle_spatial.lua",
    "storm_fx/core/cl_particle_spawn.lua",
    "storm_fx/core/cl_particle_runtime.lua",
    "storm_fx/core/cl_particle_scene.lua",
    "storm_fx/core/cl_point_light.lua",
    "storm_fx/core/cl_quaternion_animation.lua",
    "storm_fx/core/cl_scalar_animation.lua",
    "storm_fx/core/cl_scene_spatial.lua",
    "storm_fx/core/cl_skill_actor.lua",
    "storm_fx/core/cl_skill_shot.lua",
    "storm_fx/core/cl_skinning.lua",
    "storm_fx/core/cl_trail.lua",

    -- Drawing with the game's render rules
    "storm_fx/engine/cl_shader_layout.lua",
    "storm_fx/engine/cl_render.lua",
    "storm_fx/engine/cl_stage_post.lua",

    -- The engine: its state, the stage, the packages, the effects, the skill scripts, the
    -- point lights, the update and the drawing
    "storm_fx/engine/cl_engine.lua",
    "storm_fx/engine/cl_sections.lua",
    "storm_fx/engine/cl_stage.lua",
    "storm_fx/engine/cl_packages.lua",
    "storm_fx/engine/cl_trails.lua",
    "storm_fx/engine/cl_effects.lua",
    "storm_fx/engine/cl_replay.lua",
    "storm_fx/engine/cl_scripts.lua",
    "storm_fx/engine/cl_lights.lua",
    "storm_fx/engine/cl_update.lua",
    "storm_fx/engine/cl_studio.lua",
    "storm_fx/engine/cl_draw.lua",
    "storm_fx/engine/cl_commands.lua",

    -- The public interface: StormFX.Play, StormFX.Cast, ... (the server sends them to the clients)
    "storm_fx/api/cl_api.lua",
    "storm_fx/api/cl_network.lua",
    "storm_fx/api/sv_network.lua",

    -- Tests run in game (console commands and unattended runs)
    "storm_fx/debug/cl_selftest.lua",
    "storm_fx/debug/cl_perftest.lua",
    "storm_fx/debug/cl_profile.lua",
    "storm_fx/debug/cl_studiotest.lua",
    "storm_fx/debug/sv_selftest.lua"

}

-- Include a file in its realm and send the client ones
local function fnLoadFile(sPath)

    local sFile = sPath:match("([^/]+)$")
    local sPrefix = sFile:sub(1, 3)

    if sPrefix == "cl_" then

        if SERVER then
            AddCSLuaFile(sPath)
        else
            include(sPath)
        end

    elseif sPrefix == "sv_" then

        if SERVER then
            include(sPath)
        end

    else

        if SERVER then
            AddCSLuaFile(sPath)
        end

        include(sPath)

    end

end

for _, sPath in ipairs(tFiles) do
    fnLoadFile(sPath)
end
