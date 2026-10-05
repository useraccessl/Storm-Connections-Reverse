-- Particle world-matrix construction from 0x141386d45..0x14138710f.
-- Pure math only. Host follow/force routing and renderer kind remain caller inputs.
local P={}
local tiny=1.1754943508222875e-38
local pi=3.1415927410125732
local tau=6.2831854820251465
function P.wrapAngle(angle,f)
    local scaled=f(f(f(angle+pi)*1048576)/tau)
    assert(scaled>=-2147483648 and scaled<2147483648,'Original cvttss2si domain required')
    local integer=scaled>=0 and math.floor(scaled) or math.ceil(scaled)
    return f(f(f(integer%1048576*tau)*9.5367431640625e-7)-pi)
end
-- 0x1411acbb0, including original degenerate fallback, not a zero vector.
function P.normalize(vector,f)
    local length=f(math.sqrt(f(f(f(vector[1]*vector[1])+f(vector[2]*vector[2]))+f(vector[3]*vector[3]))))
    if length<=tiny then return {1,0,0},0 end
    local reciprocal=f(1/length)
    return {f(vector[1]*reciprocal),f(vector[2]*reciprocal),f(vector[3]*reciprocal)},length
end
function P.cross(a,b,f)
    return {f(f(a[2]*b[3])-f(a[3]*b[2])),f(f(b[1]*a[3])-f(a[1]*b[3])),f(f(a[1]*b[2])-f(b[1]*a[2]))}
end
-- Original movement direction is retained when displacement length is tiny.
function P.advanceDirection(previousPosition,position,previousDirection,f)
    local delta={}
    for i=1,3 do delta[i]=f(position[i]-previousPosition[i]) end
    local normalized,length=P.normalize(delta,f)
    if length>tiny then return normalized end
    return {previousDirection[1],previousDirection[2],previousDirection[3]}
end
-- 0x141386e7a..0x141386f67. Columns are perpendicular, -travel, cross.
-- zeroTolerance is the original caller literal, explicitly supplied.
function P.travelBasis(direction,zeroTolerance,f)
    assert(zeroTolerance and zeroTolerance>0,'Original direction tolerance required')
    if math.abs(direction[1])<zeroTolerance and math.abs(direction[2])<zeroTolerance and math.abs(direction[3])<zeroTolerance then
        return {1,0,0,0,1,0,0,0,1}
    end
    local negative={f(-direction[1]),f(-direction[2]),f(-direction[3])}
    local perpendicular
    if negative[1]==0 and negative[2]==0 then perpendicular={f(-negative[3]),0,negative[1]}
    else perpendicular={negative[2],f(-negative[1]),0} end
    perpendicular=P.normalize(perpendicular,f)
    local third=P.cross(perpendicular,negative,f)
    return {perpendicular[1],negative[1],third[1],perpendicular[2],negative[2],third[2],perpendicular[3],negative[3],third[3]}
end
-- 0x1412c4330 swaps its first/third angle arguments before 0x1411b8760.
-- API here takes the stored particle angles +94/+98/+9C in that order.
function P.euler(angles,f,sinf,cosf)
    local a,b,c=angles[1],angles[2],angles[3]
    local ca,cb,cc=f(cosf(a)),f(cosf(b)),f(cosf(c))
    local sa,sb,sc=f(sinf(a)),f(sinf(b)),f(sinf(c))
    local saCc=f(sa*cc)
    local ccCa=f(cc*ca)
    return {f(cc*cb),f(-f(sc*cb)),sb,
        f(f(saCc*sb)+f(sc*ca)),f(ccCa-f(f(sb*sa)*sc)),f(-f(sa*cb)),
        f(f(sc*sa)-f(ccCa*sb)),f(f(f(sb*ca)*sc)+saCc),f(cb*ca)}
end
-- 0x1411e7e40: scalar 4x4 * 3x3. Translation column preserved verbatim.
-- Float grouping differs from the SIMD 4x4 * 4x4 helper.
function P.rightBasis(matrix,basis,f)
    local out={}
    for row=0,3 do
        for col=1,3 do
            out[row*4+col]=f(f(f(matrix[row*4+1]*basis[col])+f(matrix[row*4+2]*basis[3+col]))+f(matrix[row*4+3]*basis[6+col]))
        end
        out[row*4+4]=matrix[row*4+4]
    end
    return out
end
-- +178 dirties cached Euler +154. Original angles are quantized only here.
function P.prepareRotation(state,f,sinf,cosf)
    assert(type(state.rotationDirty)=='boolean','Original rotation dirty flag required')
    if state.rotationDirty then
        for i=1,3 do state.angles[i]=P.wrapAngle(state.angles[i],f) end
        state.cachedEuler=P.euler(state.angles,f,sinf,cosf)
        state.rotationDirty=false
    end
end
-- Caller provides recovered fields, not fitted geometry. particle+A0 contains
-- this matrix; render-time lifecycle size +1B0 is a further column scale.
function P.parent(state,matrixCore,f,sinf,cosf)
    local out=matrixCore.identity()
    if state.travelAligned then
        local basis=P.travelBasis(state.direction,state.directionTolerance,f)
        for row=0,2 do for col=1,3 do out[row*4+col]=basis[row*3+col] end end
    end
    for i=1,3 do out[i*4]=state.position[i] end
    P.prepareRotation(state,f,sinf,cosf)
    if state.angles[1]~=0 or state.angles[2]~=0 or state.angles[3]~=0 then
        out=P.rightBasis(out,assert(state.cachedEuler,'Original cached Euler basis required'),f)
    end
    local scale={}
    for i=1,3 do scale[i]=f(f(state.parentScale[i]*state.baseScale[i])*state.uniformScale) end
    local enabled=scale[1]>tiny and scale[2]>tiny and scale[3]>tiny
    if enabled then out=matrixCore.scaleColumns(out,scale,f) end
    return out,enabled
end
return P


