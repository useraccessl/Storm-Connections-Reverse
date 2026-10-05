-- Original billboard/material channel mapping; no captured positions.
local B={}
function B.film(material)
    -- VS 612d54 reads g_uvOffset3.x. Constructor +48 -> binder UV3.x.
    -- BB channel 9 writes material +7c (g_commonParam.w), not UV3.x.
    return material.scroll1[1]
end
function B.roll(radians,float32)
    -- 0x14130b55c: 65536 units per turn, signed rounding to nearest.
    -- 0x1412c855e converts the integer back to radians with float32 ops.
    local tau=6.2831854820251465
    local units=float32(float32(float32(radians)*65536)/tau)
    units=float32(units+(radians<0 and -.5 or .5))
    local integer=units<0 and math.ceil(units) or math.floor(units)
    return float32(float32(integer*tau)*1.52587890625e-5),integer
end
return B
