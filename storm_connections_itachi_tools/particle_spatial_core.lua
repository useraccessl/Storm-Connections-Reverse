-- NSUNSC 0x14131c560 and 0x14131d750. Coordinates are resolved by the scene.
-- These functions consume the original RNG calls, including zero ranges.
local S={}
local tiny=1.1754943508222875e-38
local function norm(v)
    local n=math.sqrt(v[1]^2+v[2]^2+v[3]^2)
    if n>tiny then return {v[1]/n,v[2]/n,v[3]/n} end
    return {v[1],v[2],v[3]}
end
local function rotate(m,v)
    if not m then return {v[1],v[2],v[3]} end
    return {m[1]*v[1]+m[2]*v[2]+m[3]*v[3],
        m[4]*v[1]+m[5]*v[2]+m[6]*v[3],m[7]*v[1]+m[8]*v[2]+m[9]*v[3]}
end
-- 0x14127fd10 reorders its arguments before 0x1411ea620.
-- Multiplication is by matrix rows, not a generic Source Euler angle.
function S.cone(a,b,direction)
    local v={-math.sin(b)*math.cos(a),math.cos(b)*math.cos(a),math.sin(a)}
    if not direction then return v end
    -- 0x1412cd160 negates the normalized argument. Its caller also negates
    -- the attachment direction, so the second basis column is +direction.
    local n=norm(direction)
    local q=math.sqrt(n[2]^2+n[3]^2)
    if q==0 then
        if n[1]==0 then return v end
        return {n[1]*v[2],-n[1]*v[1],v[3]}
    end
    return {q*v[1]+n[1]*v[2],
        -n[1]*n[2]/q*v[1]+n[2]*v[2]-n[3]/q*v[3],
        -n[1]*n[3]/q*v[1]+n[3]*v[2]+n[2]/q*v[3]}
end
function S.single(e,rng,attachments)
    if #attachments==0 then return nil,'no resolved attachment' end
    if e.motionSegment then return nil,'moving attachment segment not resolved' end
    if e.shape>2 and #attachments>1 then return nil,'multi-attachment spawn requires segment resolver' end
    local index=#attachments>1 and rng:integer()%#attachments+1 or 1
    local a=attachments[index]
    local center=a.position
    local scale=a.scale or 1
    local direction=a.direction or {0,0,1}
    if direction[1]^2+direction[2]^2+direction[3]^2<tiny then direction={0,0,1} end
    if not a.worldDirection then direction=norm(rotate(a.rotation,direction)) end
    local theta=rng:interval(-math.pi,math.pi)
    local phi=rng:interval(-math.pi,math.pi)
    local radius=e.shape==0 and .01 or e.radius
    if (e.shape==1 or e.shape==2) and radius<tiny then radius=1 end
    local inner=(1-rng:range(e.radiusRandom))*radius
    local r=rng:interval(inner*scale,radius*scale)
    local offset
    if e.shape==1 then offset={math.cos(theta),math.sin(theta),0}
    else offset={math.cos(theta),math.cos(phi)*math.sin(theta),math.sin(phi)*math.sin(theta)} end
    for i=1,3 do offset[i]=offset[i]*r end
    if not a.worldDirection then offset=rotate(a.rotation,offset) end
    local position={}
    for i=1,3 do position[i]=center[i]+offset[i] end
    return {position=position,center={center[1],center[2],center[3]},scale=scale,
        direction=e.direction==3 and norm(direction) or nil,coneTransform=S.cone,attachment=index}
end
-- The caller supplies eligible consecutive attachment pairs in original
-- list order. Disabled-node filtering belongs to the scene graph, not RNG.
function S.segment(e,rng,segments)
    if #segments==0 then return nil,'no eligible attachment segment' end
    local index=rng:integer()%#segments+1
    local pair=segments[index]
    local a,b=pair[1],pair[2]
    local delta={} local length=0
    for i=1,3 do delta[i]=b.position[i]-a.position[i] length=length+delta[i]^2 end
    length=math.sqrt(length)
    if length<=tiny then delta={0,1,0} length=1 end
    local direction=norm(delta)
    local distance=length*rng:range(1)
    local base={}
    for i=1,3 do base[i]=a.position[i]+direction[i]*distance end
    local theta=rng:interval(-math.pi,math.pi)
    local phi=rng:interval(-math.pi,math.pi)
    local inner=(1-rng:range(e.radiusRandom))*e.radius
    -- Z rotation followed by X rotation (0x1412818f0 / 0x141281850).
    local offset={math.cos(theta),math.cos(phi)*math.sin(theta),math.sin(phi)*math.sin(theta)}
    local scale=a.scale or 1
    local radius=rng:interval(inner*scale,e.radius*scale)
    local position={}
    for i=1,3 do position[i]=base[i]+offset[i]*radius end
    local center,extra
    if e.shape==3 then
        center=(rng:integer()%2==1 and a or b).position
        extra=norm({position[1]-center[1],position[2]-center[2],position[3]-center[3]})
        if extra[1]^2+extra[2]^2+extra[3]^2<=tiny then extra=nil end
    elseif e.shape==4 then center=a.position extra=direction
    elseif e.shape==5 then center=b.position extra={-direction[1],-direction[2],-direction[3]}
    else return nil,'invalid segment shape' end
    return {position=position,center={center[1],center[2],center[3]},direction=extra,
        scale=scale,coneTransform=S.cone,attachment=index}
end
return S
