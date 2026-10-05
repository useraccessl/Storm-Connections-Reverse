-- The engine that plays the packages storm_import.py writes: effects (emitters, animations,
-- billboard / clump / animated resources) and the skill scripts that chain them. Nothing in
-- it names a particular skill.
--   * drawing follows the game's render rules (StormFX.Render);
--   * the particle, animation and matrix maths are the game's routines (StormFX.Core);
--   * what the game takes from its world is the host's: the stage, the launch and target
--     points, the ground and the walls (StormFX.Config, StormFX.Engine.tStage).
-- This file holds the engine's state and the modules it works with; the other files of
-- engine/ add the packages, the effects, the skill scripts, the lights, the update and the
-- drawing.

StormFX.Engine = StormFX.Engine or {}

local ENGINE = StormFX.Engine
local CORE = StormFX.Core

-- A reload stops what plays and releases the meshes of the packages loaded before
if ENGINE.Cleanup then
    ENGINE:Cleanup()
end

ENGINE.sVersion = "r28"

ENGINE.tPackages = {}               -- loaded packages, by name
ENGINE.tRecordings = {}             -- recorded one-shot effects (engine/cl_replay.lua)
ENGINE.tInstances = {}              -- running effects
ENGINE.tCasts = {}                  -- running skill scripts
ENGINE.tLights = {}                 -- the effects' point lights, this update

ENGINE.tSkipped = {}                -- what could not be drawn in the last frame (storm_fx_diag)
ENGINE.tFailed = {}                 -- effects dropped on an error (storm_fx_diag)

ENGINE.iDraws = 0                   -- draws of the last view
ENGINE.iCalls = 0                   -- views drawn this frame
ENGINE.tViews = {}                  -- their render targets
ENGINE.flUpdateMs = 0               -- CPU time of the last update
ENGINE.flBuildMs = 0                -- CPU time of the last draw list
ENGINE.flRenderMs = 0               -- CPU time of the last frame's drawing (every view)
ENGINE.iUploads = 0                 -- meshes built since the start
ENGINE.iSkinnedVertices = 0         -- vertices skinned in the last frame
ENGINE.iNetCalls = 0                -- StormFX calls the server sent to this client
ENGINE.sLastNetCall = nil           -- the name of the last one

ENGINE.iToneMode = 0                -- stage tone pass: 0 off, 1 on the effects' pixels, 2 whole screen
ENGINE.sDrawHook = "translucent"    -- the pass the effects are drawn in: translucent, opaque or none
ENGINE.tSkip = {}                   -- draw steps left out, for cost measurements (storm_fx_perftest)
ENGINE.tMainView = {}               -- the main view's camera of this frame

-- ENGINE.ShaderContext, left to the host: an optional function (instance, particle, item) that
-- returns {scroll, clockSeconds} for a draw's screen scroll (kept across reloads)

-- Simulation rate of the effects and the skill objects
ENGINE.FPS = 60

ENGINE.IDENTITY = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}

-- The game's routines round every operation to float32, which is what the offline checks
-- compare bit for bit with the game's code; each rounding costs a frexp and a division. In
-- Garry's Mod (LuaJIT) the engine computes in doubles by default (differences below 1e-6
-- relative, not visible); ENGINE:SetExact(true) or storm_fx_exact 1 brings the rounding back.
local fnExactFloat32 = CORE.MaterialContext.Float32
local bExact = not jit

function ENGINE.Float32(flValue)

    if bExact then
        return fnExactFloat32(flValue)
    end

    return flValue

end

function ENGINE:SetExact(bOn)
    bExact = bOn and true or false
end

function ENGINE:IsExact()
    return bExact
end

-- Skinning runs every update on every vertex of a skinned mesh: in doubles (the game's
-- shader works in float32; the difference is below 1e-6 of a unit)
function ENGINE.Plain(flValue)
    return flValue
end

local fnFloat32 = ENGINE.Float32

-- The modules a particle scene works with
ENGINE.tParticleModules = {
    curves = CORE.Curves,
    spawn = CORE.ParticleSpawn,
    motion = CORE.ParticleMotion,
    runtime = CORE.ParticleRuntime,
    spatial = CORE.SceneSpatial,
    birthSpatial = CORE.ParticleSpatial,
    emission = CORE.Emission
}

-- The modules the animations and the models work with
ENGINE.tAnmModules = {
    quaternion = CORE.QuaternionAnimation,
    scalar = CORE.ScalarAnimation,
    matrix = CORE.AnmMatrix,
    color = CORE.ColorAnimation,
    material = CORE.MaterialAnimation,
    clock = CORE.AnmClock,
    animation = CORE.AnmResource,
    particle = CORE.ParticleMatrix,
    skinning = CORE.Skinning,
    bridge = CORE.ModelInstance,
    context = CORE.MaterialContext
}

-- The options of the animations: the rounding, the trigonometry, the material factory's hold
-- mode, and the size a model particle holds before its first update
ENGINE.tAnmOptions = {
    float32 = fnFloat32,
    sinf = function(flValue) return fnFloat32(math.sin(flValue)) end,
    cosf = function(flValue) return fnFloat32(math.cos(flValue)) end,
    acosf = function(flValue) return fnFloat32(math.acos(flValue)) end,
    materialHold = CORE.AnmResource.MaterialHoldFromContext(60, 0),
    initialSize = function(tParticle) return (CORE.Curves.Sample(tParticle.sampleConfig, tParticle.life, 0, {0, 0, 0})) end
}
