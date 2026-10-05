-- Original skill shot math. Host collision/aim correction remains explicit.
local S={}
-- 0x140a67e28..0x140a67ea6, reference-rate getter 0x1405911a0 returns 30.
function S.rateAdjustedParameter(value,updateRate,f)
    assert(updateRate>0,'Original update rate required')
    return f(f(30/f(updateRate))*f(value))
end
-- CONST_AXIS_UP dispatcher slot 7, 0x140a6a5f0. Caller has already applied
-- optional 0x140a6a340 correction when command+50 enables it.
-- 0x140136c20 supplies (0,0,1); 0x140145f60 supplies (1,0,0).
function S.constAxisUp(direction,particleMath,f)
    local dot=f(f(f(direction[1]*0)+f(direction[2]*0))+f(direction[3]*1))
    local projected={f(direction[1]-f(0*dot)),f(direction[2]-f(0*dot)),f(direction[3]-f(1*dot))}
    local square=f(f(f(projected[1]*projected[1])+f(projected[2]*projected[2]))+f(projected[3]*projected[3]))
    if square<=0 then return {1,0,0},{0,0,1} end
    return particleMath.normalize(projected,f),{0,0,1}
end
-- Actor orientation updater 0x140a61c20 on the packed 4x4 at actor+AC.
-- Column getters 0x1411f05d0 (X) / 0x1411f0630 (Z), cross 0x1411ac0f0 (a x b),
-- column setter 0x1411ee000, builder 0x141281640(X, Y, Z).
--   Y = normalize(-velocity)
--   X = normalize(Y x oldZ), Z = normalize(X x Y)
--   if Y x oldZ (or X x Y) degenerates: Z = normalize(oldX x Y), X = normalize(Y x Z)
-- Every length test is `> FLT_EPSILON` (0x14187961c); a failed test leaves the
-- stored orientation untouched. A motionless actor therefore keeps identity.
local epsilon=1.1920928955078125e-7
local function length3(v,f)
    return f(math.sqrt(f(f(f(v[1]*v[1])+f(v[2]*v[2]))+f(v[3]*v[3]))))
end
local function unit3(v,f)
    local reciprocal=f(1/length3(v,f))
    return {f(v[1]*reciprocal),f(v[2]*reciprocal),f(v[3]*reciprocal)}
end
local function cross3(a,b,f)
    return {f(f(a[2]*b[3])-f(a[3]*b[2])),f(f(b[1]*a[3])-f(a[1]*b[3])),f(f(a[1]*b[2])-f(b[1]*a[2]))}
end
function S.orientation(previous,velocity,M,f)
    local oldX={previous[1],previous[5],previous[9]}
    local oldZ={previous[3],previous[7],previous[11]}
    local y={f(-velocity[1]),f(-velocity[2]),f(-velocity[3])}
    if not (length3(y,f)>epsilon) then return previous end
    y=unit3(y,f)
    local x,z
    local candidate=cross3(y,oldZ,f)
    if length3(candidate,f)>epsilon then
        x=unit3(candidate,f)
        candidate=cross3(x,y,f)
        if length3(candidate,f)>epsilon then z=unit3(candidate,f) end
    end
    if not z then
        candidate=cross3(x or oldX,y,f)
        if not (length3(candidate,f)>epsilon) then return previous end
        z=unit3(candidate,f)
        candidate=cross3(y,z,f)
        if not (length3(candidate,f)>epsilon) then return previous end
        x=unit3(candidate,f)
    end
    local out=M.identity()
    for row=0,2 do out[row*4+1]=x[row+1];out[row*4+2]=y[row+1];out[row*4+3]=z[row+1] end
    return out
end
-- ccGameObjectSkill virtual +78, 0x1405e00c0..0x1405e0229.
-- Packed native layout. Source/world conversion remains a separate caller gate.
function S.effectRoot(position,actorOrientation,extraAngleDegrees,actorScale,M,f,sinf,cosf)
    assert(position and actorOrientation and extraAngleDegrees and actorScale,'Original skill fields required')
    local root=M.identity()
    for i=1,3 do root[i*4]=position[i] end
    root=M.multiply(root,actorOrientation,f)
    local angle=f(f(extraAngleDegrees*3.1415927410125732)/180)
    -- 0x1412818a0 -> 0x1411ed680, UCRT cosf/sinf thunks identified.
    local c,s=f(cosf(angle)),f(sinf(angle))
    local rotation={c,0,s,0,0,1,0,0,f(-s),0,c,0,0,0,0,1}
    root=M.multiply(root,rotation,f)
    return M.scaleColumns(root,{actorScale,actorScale,actorScale},f)
end
return S
