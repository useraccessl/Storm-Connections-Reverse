-- Constant layout of the shaders shader_port.py translates from the game's bytecode.
-- screenspace_general offers four pixel constants and no vertex constant: a layout says
-- which game constant component goes to which of c0..c3 (dynamic: set for each draw) and
-- which is baked into a TEXCOORD channel of the cached mesh (static).
-- tValues: game constant name -> {x, y, z, w} (the rows of an array follow each other).

StormFX.ShaderLayout = StormFX.ShaderLayout or {}

local SHADER_LAYOUT = StormFX.ShaderLayout

-- The value of one layout entry
local function fnValue(tValues, tEntry)

    local tValue = tValues[tEntry.name]

    if not tValue then
        error("Storm FX: no value for shader constant " .. tEntry.name)
    end

    return tValue[tEntry.row * 4 + tEntry.component + 1] or 0

end

-- The pixel constants c0..c3 of one draw, written into tPacked (four tables of four numbers)
function SHADER_LAYOUT.PackInto(tLayout, tValues, tPacked)

    for iRegister = 1, 4 do
        local tRegister = tPacked[iRegister]
        tRegister[1], tRegister[2], tRegister[3], tRegister[4] = 0, 0, 0, 0
    end

    for _, tEntry in ipairs(tLayout.dynamic) do
        tPacked[tEntry.register + 1][tEntry.slot + 1] = fnValue(tValues, tEntry)
    end

    return tPacked

end

-- The pixel constants c0..c3 of one draw, in new tables
function SHADER_LAYOUT.Pack(tLayout, tValues)
    return SHADER_LAYOUT.PackInto(tLayout, tValues, {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}})
end

-- The TEXCOORD1..7 values baked into a mesh: channelSize numbers per channel (two, or four
-- when the shader's stage values need the room). A shader that reads the second UV set
-- leaves channel 1 to the mesh's own coordinates.
function SHADER_LAYOUT.Static(tLayout, tValues)
    return SHADER_LAYOUT.StaticInto(tLayout, tValues, {})
end

-- The same, written into tChannels (its seven channel tables are made the first time)
function SHADER_LAYOUT.StaticInto(tLayout, tValues, tChannels)

    local iSize = tLayout.channelSize or 2

    for iChannel = 1, 7 do

        local tChannel = tChannels[iChannel]

        if not tChannel then
            tChannel = {}
            tChannels[iChannel] = tChannel
        end

        for iSlot = 1, iSize do
            tChannel[iSlot] = 0
        end

        for iSlot = iSize + 1, #tChannel do
            tChannel[iSlot] = nil
        end

    end

    for _, tEntry in ipairs(tLayout.static) do
        tChannels[tEntry.channel][tEntry.slot + 1] = fnValue(tValues, tEntry)
    end

    return tChannels

end

-- The names of the constants a layout reads: dynamic ones, static ones. A batched layout
-- (storm_import.py) carries the per-draw values in the static channels too.
function SHADER_LAYOUT.Names(tLayout)

    local tDynamic, tStatic = {}, {}

    for _, tEntry in ipairs(tLayout.dynamic) do
        tDynamic[tEntry.name] = true
    end

    for _, tEntry in ipairs(tLayout.static) do
        tStatic[tEntry.name] = true
    end

    return tDynamic, tStatic

end

return SHADER_LAYOUT
