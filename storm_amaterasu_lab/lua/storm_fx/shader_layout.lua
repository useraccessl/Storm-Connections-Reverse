-- Constant layout of the shaders shader_port.py translates from the game's
-- bytecode (lua/storm_fx/shaders.lua lists one layout per shader key).
-- screenspace_general offers four pixel constants and no vertex constant: a
-- layout says which game constant component goes to which of c0-c3 (dynamic)
-- and which is baked into a TEXCOORD channel of the cached mesh (static).
-- values: game constant name -> {x, y, z, w} (rows of an array follow each
-- other).
local L={}
local function value(values,entry)
    local v=values[entry.name]
    if not v then error('Storm FX: no value for shader constant '..entry.name) end
    return v[entry.row*4+entry.component+1] or 0
end
-- Pixel constants c0..c3 of one draw.
function L.pack(layout,values)
    local out={{0,0,0,0},{0,0,0,0},{0,0,0,0},{0,0,0,0}}
    for _,e in ipairs(layout.dynamic) do out[e.register+1][e.slot+1]=value(values,e) end
    return out
end
-- TEXCOORD1..7 values baked into a mesh: layout.channelSize floats per channel
-- (two, or four when the shader's stage values need the room). A layout whose
-- shader reads the second UV set leaves channel 1 to the mesh's own coordinates.
function L.static(layout,values)
    local out={}
    for channel=1,7 do
        out[channel]={}
        for slot=1,layout.channelSize or 2 do out[channel][slot]=0 end
    end
    for _,e in ipairs(layout.static) do out[e.channel][e.slot+1]=value(values,e) end
    return out
end
-- Names of the constants a layout reads, split by where they go.
function L.names(layout)
    local dynamic,static={},{}
    for _,e in ipairs(layout.dynamic) do dynamic[e.name]=true end
    for _,e in ipairs(layout.static) do static[e.name]=true end
    return dynamic,static
end
return L
