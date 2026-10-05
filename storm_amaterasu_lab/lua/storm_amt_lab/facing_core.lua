-- Camera-facing hooks of NSUNSC.exe: slot +68 of nuccModel (0x1412d4f40) and of
-- nuccBillboard (0x1412c84b0), which the model draw callback 0x1412d1870 applies once
-- per draw to a model whose header attribute bit 0 is set (model +2C & 1).
-- Matrices are 4x4 row-major with the translation in elements 4, 8, 12 (columns are
-- the axes). x, y, z are the camera axes (right, up, right x up) in the matrix's space,
-- as tables or vectors with x / y / z fields.
local F={}
local function lengths(m)
    return math.sqrt(m[1]^2+m[5]^2+m[9]^2),math.sqrt(m[2]^2+m[6]^2+m[10]^2),math.sqrt(m[3]^2+m[7]^2+m[11]^2)
end
local function build(ax,ay,az,l1,l2,l3,t)
    return {ax[1]*l1,ay[1]*l2,az[1]*l3,t[1],ax[2]*l1,ay[2]*l2,az[2]*l3,t[2],
        ax[3]*l1,ay[3]*l2,az[3]*l3,t[3],0,0,0,1}
end
-- nuccModel: keeps the translation and the length of each axis, puts the camera's
-- rotation in place of the model's.
function F.model(world,x,y,z)
    local l1,l2,l3=lengths(world)
    return build({x.x,x.y,x.z},{y.x,y.y,y.z},{z.x,z.y,z.z},l1,l2,l3,{world[4],world[8],world[12]})
end
-- nuccBillboard: the camera's rotation turned about its z axis by the roll (a binary
-- angle, value * 2pi / 65536 in float32), axes x / y scaled by the size, the
-- translation moved by the offset. board = {roll=, size={w,h}, offset={x,y,z}};
-- linear: the 4x4 whose 3x3 part takes the offset into the matrix's space (the
-- identity in the game's own space), or nil.
function F.billboard(world,board,x,y,z,linear,f)
    f=f or function(v) return v end
    local l1,l2,l3=lengths(world)
    local angle=f(f(board.roll*f(6.2831854820251465))*f(1.52587890625e-05))
    local c,s=math.cos(angle),math.sin(angle)
    local ax={x.x*c+y.x*s,x.y*c+y.y*s,x.z*c+y.z*s}
    local ay={-x.x*s+y.x*c,-x.y*s+y.y*c,-x.z*s+y.z*c}
    local o,t=board.offset,{world[4],world[8],world[12]}
    for row=1,3 do
        if linear then t[row]=t[row]+linear[row*4-3]*o[1]+linear[row*4-2]*o[2]+linear[row*4-1]*o[3]
        else t[row]=t[row]+o[row] end
    end
    return build(ax,ay,{z.x,z.y,z.z},l1*board.size[1],l2*board.size[2],l3,t)
end
return F
