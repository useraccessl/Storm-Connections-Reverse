-- Native packed 4x4 math. Source/world conversion is a separate verified gate.
local M={}
function M.multiply(a,b,f)
    local out={}
    for row=0,3 do
        for col=1,4 do
            local p0=f(a[row*4+1]*b[col])
            local p1=f(a[row*4+2]*b[4+col])
            local p2=f(a[row*4+3]*b[8+col])
            local p3=f(a[row*4+4]*b[12+col])
            local low,high=f(p0+p1),f(p2+p3)
            out[row*4+col]=(row==0 or row==2) and f(high+low) or f(low+high)
        end
    end
    return out
end
-- 0x141281e90 scales columns 0..2, leaving translation at +0C/+1C/+2C unchanged.
function M.scaleColumns(a,scale,f)
    local out={}
    for row=0,3 do
        for col=1,3 do out[row*4+col]=f(a[row*4+col]*scale[col]) end
        out[row*4+4]=a[row*4+4]
    end
    return out
end
-- Identity literal initializer 0x1400a4ad0 -> runtime 0x149707f10.
function M.identity() return {1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1} end
-- Coordinate controller 0x1413679d0: translation, right rotation, column scale.
-- translationScale is the original target +FC/+100/+104, supplied by caller.
function M.coordinate(channels,translationScale,quaternion,f)
    assert(translationScale,'Original target translation scale required')
    local localMatrix=M.identity()
    if channels[0] then
        for i=1,3 do localMatrix[i*4]=f(channels[0][i]*translationScale[i]) end
    end
    if channels[1] then
        -- A rotation key hands the controller a matrix (key method +20): built
        -- from a quaternion, or kept from a fixed Euler key.
        local rotation=channels[1].matrix
        if not rotation then
            local basis=quaternion.basis(channels[1],f)
            rotation=M.identity()
            for row=0,2 do for col=1,3 do rotation[row*4+col]=basis[row*3+col] end end
        end
        localMatrix=M.multiply(localMatrix,rotation,f)
    end
    if channels[2] then localMatrix=M.scaleColumns(localMatrix,channels[2],f) end
    return localMatrix
end
-- Euler rotation 0x1411e9bd0 (angles in radians): Rx * Ry * Rz, same operation
-- order as the original.
function M.euler(x,y,z,f,sinf,cosf)
    local cx,cy,cz,sx,sy,sz=cosf(x),cosf(y),cosf(z),sinf(x),sinf(y),sinf(z)
    local czsx,czcx=f(cz*sx),f(cz*cx)
    return {f(cz*cy),-f(sz*cy),sy,0,
        f(f(czsx*sy)+f(sz*cx)),f(czcx-f(f(sy*sx)*sz)),-f(sx*cy),0,
        f(f(sz*sx)-f(czcx*sy)),f(f(f(sy*cx)*sz)+czsx),f(cx*cy),0,
        0,0,0,1}
end
-- nuccCoord constructor 0x1412892a0: local matrix of a nuccChunkCoord node =
-- translation * Euler rotation (degrees in the file, * pi / 180) * column scale.
function M.node(position,rotationDegrees,scale,f,sinf,cosf)
    local localMatrix=M.identity()
    for i=1,3 do localMatrix[i*4]=position[i] end
    local function radians(degrees) return f(f(degrees*f(3.1415927410125732))/180) end
    local r=rotationDegrees
    if r[1]~=0 or r[2]~=0 or r[3]~=0 then
        localMatrix=M.multiply(localMatrix,M.euler(radians(r[1]),radians(r[2]),radians(r[3]),f,sinf,cosf),f)
    end
    return M.scaleColumns(localMatrix,scale,f)
end
-- Parent has already received the particle's size via column scaling.
-- nuccCoord 0x141289db0: active parent matrix * local matrix.
function M.world(parent,localMatrix,f) return M.multiply(parent,localMatrix,f) end
return M
