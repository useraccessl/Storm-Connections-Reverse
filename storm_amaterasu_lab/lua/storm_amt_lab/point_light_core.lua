-- Point lights of the scene as the game hands them to a lit model.
-- Translated from NSUNSC.exe:
--   0x14110dac0  ccCmnLightManager: a light joins the end of the list, unless
--                its two radii are zero
--   0x14110ded0  the lights of an object: the first four of the list, sorted
--   0x1412c9cd0  their sort key for the object's position
--   0x1413368f0  render context fill: g_pointLightColor / Pos / Param of a slot
-- A light: {position={x,y,z} (world), color={r,g,b}, intensity, near, far}.
-- f rounds to float32. verify_point_light_native.py runs the first three
-- against the game's code.
local L={}
local EPSILON=1.1920928955078125e-07
-- 0x1411ac850
local function length(x,y,z,f) return f(math.sqrt(f(f(f(x*x)+f(y*y))+f(z*z)))) end
-- A light whose two radii are zero is refused when it registers.
function L.accepted(light) return not (light.near==0 and light.far==0) end
-- The strongest light sorts first: minus (intensity attenuated between the two
-- radii) times the distance. A light with no positive intensity, or out of
-- reach, has key zero.
function L.key(light,position,f)
    local p=light.position
    local d=length(f(p[1]-position[1]),f(p[2]-position[2]),f(p[3]-position[3]),f)
    local w=light.intensity
    if w>0 and not (d>light.far) then
        if d>=light.near then w=f(w*f(f(light.far-d)/f(light.far-light.near))) end
    else w=0 end
    return f(-w*d)
end
-- lights: the manager's list in registration order. The game looks at the
-- first four only, whatever their distance, and sorts those (std::sort on four
-- slots: lights with equal keys keep their order).
function L.select(lights,position,f)
    local slots={}
    for i=1,math.min(#lights,4) do slots[i]={light=lights[i],key=L.key(lights[i],position,f)} end
    for i=2,#slots do
        local slot=slots[i]
        local j=i-1
        while j>=1 and slots[j].key>slot.key do slots[j+1]=slots[j] j=j-1 end
        slots[j+1]=slot
    end
    local out={}
    for i,slot in ipairs(slots) do out[i]=slot.light end
    return out
end
-- Shader constants of one light slot. The far radius is pushed away from the
-- near one when they are closer than far * epsilon. The game leaves the w of
-- colour and position unwritten (the lit shaders read xyz).
function L.constants(light,f)
    local near,far=light.near,light.far
    local margin=f(far*EPSILON)
    if margin>math.abs(f(far-near)) then far=f(far+margin) end
    return {color={light.color[1],light.color[2],light.color[3],1},
        position={light.position[1],light.position[2],light.position[3],1},
        param={light.intensity,near,far,f(1/f(far-near))}}
end
-- A slot no light uses.
L.unused={color={0,0,0,1},position={0,0,0,1},param={0,0,1,EPSILON}}
return L
