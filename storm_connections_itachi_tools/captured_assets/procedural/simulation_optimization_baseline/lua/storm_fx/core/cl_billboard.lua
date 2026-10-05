-- Billboards of the game's effect renderer: the film scroll of a material and the roll of
-- a billboard as the game quantises it.

StormFX.Core.Billboard = StormFX.Core.Billboard or {}

local BILLBOARD = StormFX.Core.Billboard

-- The film scroll a material hands its vertex shader (UV set 3, x). The billboard
-- channel 9 writes g_commonParam.w instead, not this.
function BILLBOARD.Film(tMaterial)
    return tMaterial.scroll1[1]
end

-- Roll of a billboard (game: 0x14130b55c, back to radians at 0x1412c855e): 65536 units a
-- turn, rounded to the nearest, all in float32. Returns the angle and the integer units.
function BILLBOARD.Roll(flRadians, fnFloat32)

    local flTau = 6.2831854820251465

    local flUnits = fnFloat32(fnFloat32(fnFloat32(flRadians) * 65536) / flTau)
    flUnits = fnFloat32(flUnits + (flRadians < 0 and -0.5 or 0.5))

    local iUnits = flUnits < 0 and math.ceil(flUnits) or math.floor(flUnits)

    return fnFloat32(fnFloat32(iUnits * flTau) * 1.52587890625e-5), iUnits

end

return BILLBOARD
