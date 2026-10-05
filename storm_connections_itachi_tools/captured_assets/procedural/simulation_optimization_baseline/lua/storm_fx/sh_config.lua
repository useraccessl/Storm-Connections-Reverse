-- Settings of Storm FX: what the engine needs from Garry's Mod's world that the game takes
-- from its own (the size of a character, the ground, the lights of the stage).

StormFX.Config = StormFX.Config or {}

-- Game units to Source units: 64 Source units of eye height over the game's 119
StormFX.Config["scale"] = 64 / 119

-- How far in front of the player a skill starts (game units; estimated from capture 22082)
StormFX.Config["launchOffset"] = 40

-- How high above a skill object the ground is looked for (Source units): a step up is climbed
StormFX.Config["groundProbe"] = 64

-- A wall lower than this does not stop a crawling object (Source units)
StormFX.Config["stepHeight"] = 18

-- Frames (60 a second) a looping effect, or a skill object that never ends, runs at most
StormFX.Config["maxLoopFrames"] = 3600

-- The ground kind of a surface whose material the game has no kind for: DIRT, STONE, GRASS,
-- SNOW or IRONSAND
StormFX.Config["defaultGround"] = "DIRT"

-- Small particles of one material (billboards, small models) drawn together, in one mesh a
-- frame; false draws them one by one (the game's order exactly, for comparisons)
StormFX.Config["batchParticles"] = true

-- Ribbon points per trail segment at most (the game makes up to 10: smoother curves, but each
-- point is two vertices sent from Lua every frame); nil keeps the game's count. 1 sends about a
-- third of the vertices 3 sends (the ribbons were most of the drawing's time in game)
StormFX.Config["trailSubdivisions"] = 1

-- One-shot effects played without pitch or roll are recorded the first time and read back
-- the next times, with no simulation (the same draws: an effect is deterministic for its
-- seed). prerecord: record them in the background once the map has loaded (spending at most
-- prerecordBudgetMs a frame), so that even their first play is read back.
StormFX.Config["recordEffects"] = true
StormFX.Config["prerecord"] = true
StormFX.Config["prerecordBudgetMs"] = 1

-- The trail ribbons of a recorded effect are the same at every play: each is built once and
-- kept, for every copy of the effect drawn at the same step and for the lists built again
-- within a step, up to this many vertices in all (the least recently drawn go first); 0
-- builds them every time
StormFX.Config["ribbonCacheVertices"] = 100000

-- Draw lists built a second at most besides the effects' own steps (60 a second): a frame in
-- between draws the list it has (only the billboards' turn to the camera waits, 1/60 s at
-- most); 0 builds one every frame
StormFX.Config["drawRate"] = 60

-- Simulation steps (1/60 s each) an effect makes in one frame at most: after a slow frame it
-- drops the rest rather than catching up all at once (which made the next frames slower still)
StormFX.Config["maxStepsPerFrame"] = 3

-- Skinned models (a mesh the game deforms with bones, as Kisame's wave): the triangles that
-- hang from one bone only are built once and drawn under that bone's matrix, the others
-- skinned on the CPU once per draw list and shared by the copies at the same point of their
-- animation; false skins every vertex on the CPU at every draw (the reference path)
StormFX.Config["splitSkinned"] = true

-- Skinned meshes the package also has as Source studio models (export_studio.py) are drawn
-- as those: Source skins them, from the sequence baked from their animation; false draws
-- them as above. Source hands the vertex shader the bones (hardware skinning): the studio
-- variant of the shader skins them (shader_port.py, found in game with skin_variants.py)
StormFX.Config["useStudioModels"] = true

-- The skinned triangles kept from list to list (the copies of an effect reach the same point
-- of their animation one after the other, and a replayed effect goes through the same points
-- again), up to this many vertices in all (the least recently drawn go first); 0 builds them
-- for each list
StormFX.Config["skinCacheVertices"] = 300000

-- Effects out of the camera's view are not drawn and their trails make no ribbon (they still
-- play, to be right when seen again); false draws everything
StormFX.Config["cullHidden"] = true

-- Bounds that keep the cost the same however many effects play at once (many players casting
-- together). Drawn: the effects nearest the camera, at most maxDrawnEffects of them, within
-- maxDrawDistance (Source units), until maxDrawEntries draws; the others still play.
-- Simulated: the effects that are not read back from a recording spend at most
-- simulationBudgetMs a frame; past it an effect waits for the next frame (it never waits two
-- frames in a row: it then plays at half speed at worst). 0 turns a bound off.
StormFX.Config["maxDrawnEffects"] = 64
StormFX.Config["maxDrawDistance"] = 6000
StormFX.Config["maxDrawEntries"] = 3000
StormFX.Config["simulationBudgetMs"] = 4

-- Load every package found (data_static/storm_fx) when the map has loaded, rather than at the
-- first effect of each (loading one takes a moment: a hitch in play)
StormFX.Config["precacheAll"] = true

-- Models of a package left out of the drawing (they still play: their particles, lights and
-- children run as in the game), by package then model name
-- "*" applies to every package.
StormFX.Config["hiddenModels"] = {

    -- The white shock dome of the common explosions (it looks wrong on GMod's maps)
    ["*"] = {
        ["1efc_shock09"] = true
    },

    -- Amaterasu: the transparent dome that warps the scene behind the big flame, and the
    -- dark disc on the ground
    ["4efb_amt1_x"] = {
        ["1efc_nor_dst03"] = true,
        ["4efb_light00"] = true
    }

}

-- The effects' point lights as Source dynamic lights (the game lights its stage and characters
-- with them): false none, "models" the players and props only (cheap), "world" the map too
-- (Source rebuilds the lightmaps they reach every frame on the CPU: a few big lights can
-- freeze the game); at most maxDynamicLights at once, the strongest first. Their brightness,
-- and the first dynamic light index they take.
StormFX.Config["dynamicLights"] = false
StormFX.Config["maxDynamicLights"] = 4
StormFX.Config["lightBrightness"] = 1
StormFX.Config["lightIndex"] = 4096
