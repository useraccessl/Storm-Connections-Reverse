-- Skill actor motion: the action classes ccGameObjectSkill drives each tick
-- (ccSkillActor*). Translated from NSUNSC.exe; every routine names its source.
-- state is the object's motion state: position (+70), velocity (+A0),
-- orientation (+AC, packed 4x4), roll (+EC, degrees), multiplier (+164),
-- frame (+100, ticks since the action started), guidance (+3B0, 0 or 1).
-- actor holds what the action class keeps for itself.
-- The world (target, ground, obstacles) is the caller's: see each routine.
local A={}
local PI=3.1415927410125732

-- Random numbers ---------------------------------------------------------------
-- MT19937, 0x14132d200 (state 0x14974c700, seeded by 0x14132d580). The game
-- seeds it from the clock and shares one stream with everything else, so a
-- seed is a host input; the sequence of one seed is the original's.
local bxor,band
if bit then
    bxor=function(a,b) return bit.bxor(a,b)%4294967296 end
    band=function(a,b) return bit.band(a,b)%4294967296 end
else
    local function combine(a,b,both)
        local out,place=0,1
        for _=1,32 do
            local x,y=a%2,b%2
            if (both and x+y==2) or (not both and x~=y) then out=out+place end
            a,b,place=(a-x)/2,(b-y)/2,place*2
        end
        return out
    end
    bxor=function(a,b) return combine(a,b,false) end
    band=function(a,b) return combine(a,b,true) end
end
local function shiftRight(value,count) return math.floor(value/2^count) end
local function shiftLeft(value,count) return (value*2^count)%4294967296 end
function A.twister(seed)
    local state={[0]=seed%4294967296}
    for i=1,623 do
        local previous=state[i-1]
        local mixed=bxor(previous,shiftRight(previous,30))
        local low=mixed%65536
        local high=(mixed-low)/65536
        state[i]=((high*1812433253)%65536*65536+low*1812433253+i)%4294967296
    end
    local index=624
    -- 0x14127da70: the generator's output shifted right once, 0..2^31-1.
    return function()
        if index>=624 then
            for k=0,623 do
                local y=(state[k]-state[k]%2147483648)+state[(k+1)%624]%2147483648
                local value=bxor(state[(k+397)%624],shiftRight(y,1))
                if y%2==1 then value=bxor(value,0x9908b0df) end
                state[k]=value
            end
            index=0
        end
        local y=state[index]
        index=index+1
        y=bxor(y,shiftRight(y,11))
        y=bxor(y,shiftLeft(band(y,0xff3a58ad),7))
        y=bxor(y,shiftLeft(band(y,0xffffdf8c),15))
        y=bxor(y,shiftRight(y,18))
        return shiftRight(y,1)
    end
end
-- 0x1410abed0: a value in [-range, range).
function A.spread(random,range,f)
    local unit=f(f(random())*4.656612873077393e-10)
    return f(f(f(unit+unit)*range)-range)
end

-- Vectors ---------------------------------------------------------------------
local function squared(v,f) return f(f(f(v[1]*v[1])+f(v[2]*v[2]))+f(v[3]*v[3])) end       -- 0x1411ac880
local function length(v,f) return f(math.sqrt(squared(v,f))) end                            -- 0x1411ac850
local function dot(a,b,f) return f(f(f(a[2]*b[2])+f(a[1]*b[1]))+f(a[3]*b[3])) end          -- 0x1411ac380
-- 0x1411acbb0: a vector no longer than the literal at 0x141782190 becomes (1,0,0).
local SHORT=9.999999974752427e-7
local function unit(v,f)
    local size=length(v,f)
    if not (size>SHORT) then return {1,0,0} end
    local reciprocal=f(1/size)
    return {f(v[1]*reciprocal),f(v[2]*reciprocal),f(v[3]*reciprocal)}
end
-- 0x1411ac0f0: a x b.
local function cross(a,b,f)
    return {f(f(a[2]*b[3])-f(a[3]*b[2])),f(f(b[1]*a[3])-f(a[1]*b[3])),f(f(a[1]*b[2])-f(b[1]*a[2]))}
end
local function column(matrix,index) return {matrix[index],matrix[4+index],matrix[8+index]} end
A.squared,A.length,A.dot,A.unit,A.cross,A.column=squared,length,dot,unit,cross,column
local function radians(degrees,f) return f(f(degrees*f(PI))/180) end
-- A double angle as the game's 16-bit turn fraction, back in degrees
-- (0x140a627a5..0x140a627f9): the rounding is the original's.
local function turnDegrees(angle,f)
    local units
    if angle~=angle then units=-2147483648      -- cvttsd2si of a NaN
    else
        local scaled=angle*65536/6.2831854820251465+(0>angle and -.5 or .5)
        units=scaled>=0 and math.floor(scaled) or math.ceil(scaled)
    end
    return f(f(f(units)*360)*1.52587890625e-05)
end
-- 0x1411ed500: rotation about X.
local function rotationX(angle,f,sinf,cosf)
    local c,s=cosf(angle),sinf(angle)
    return {1,0,0,0,0,c,f(-s),0,0,s,c,0,0,0,0,1}
end
-- 0x1411ed0c0: rotation about a unit axis.
function A.axisRotation(axis,angle,f,sinf,cosf)
    local c,s=cosf(angle),sinf(angle)
    local t=f(1-c)
    local x,y,z=axis[1],axis[2],axis[3]
    local tx,ty=f(x*t),f(y*t)
    local txy,txz,tyz=f(tx*y),f(tx*z),f(ty*z)
    local xs,ys,zs=f(x*s),f(y*s),f(z*s)
    return {f(f(tx*x)+c),f(txy-zs),f(ys+txz),0,
        f(zs+txy),f(f(ty*y)+c),f(tyz-xs),0,
        f(txz-ys),f(xs+tyz),f(f(f(z*t)*z)+c),0,
        0,0,0,1}
end
-- 0x1411f00d0 on a rotation: matrix * direction.
function A.rotate(matrix,v,f)
    local out={}
    for row=0,2 do
        local a,b=f(matrix[row*4+1]*v[1]),f(matrix[row*4+2]*v[2])
        local c,d=f(matrix[row*4+3]*v[3]),matrix[row*4+4]
        out[row+1]=f(f(a+c)+f(b+d))
    end
    return out
end

-- Shots -----------------------------------------------------------------------
-- An event's <Effect> spawns a script through the shot handler of its
-- shotType (table 0x141974e80). A request carries position, direction and up
-- axis; a handler returns the launches it makes, each {position, direction, up}.
-- 0x140a6a340, the targetDir attribute: aim at the target from the position.
function A.aim(position,target,direction,f)
    if not target then return direction end
    local toward={f(target[1]-position[1]),f(target[2]-position[2]),f(target[3]-position[3])}
    if squared(toward,f)>0 then return unit(toward,f) end
    return toward
end
-- The planeDir attribute (0x140a6a963): the direction is laid in the plane
-- whose normal is the request's up axis (the spawner 0x1405e72f0 puts the hit
-- normal there).
function A.planeDirection(direction,up,f)
    if not (squared(up,f)>0) then return {0,1,0},{0,0,1} end
    local normal=unit(up,f)
    return cross(cross(normal,direction,f),normal,f),normal
end
-- N_WAY_HORIZONTAL 0x140a6bb10: count launches fanned about the up axis,
-- step degrees apart, centred on the direction; each launch's up is +Z.
function A.nWay(position,direction,up,count,step,f,sinf,cosf)
    local out={}
    local angle=f(f((1-count)*step)*.5)
    for index=1,count do
        local turn=A.axisRotation(up,radians(angle,f),f,sinf,cosf)
        out[index]={position={position[1],position[2],position[3]},direction=A.rotate(turn,direction,f),up={0,0,1}}
        angle=f(angle+f(step))
    end
    return out
end
-- RANDOM_CREATION 0x140a6bfa0: count launches, each moved from the position by
-- a whole number of units in [-range, range) along a random direction of the
-- positive octant (the original draws three non-negative components).
function A.randomCreation(position,direction,up,count,range,random,f)
    local out={}
    for index=1,count do
        local first,second,third=f(random()),f(random()),f(random())
        local offset={third,second,first}
        local at={position[1],position[2],position[3]}
        if squared(offset,f)>0 and range>0 then
            offset=unit(offset,f)
            local distance=f(random()%(range+range)-range)
            for i=1,3 do at[i]=f(at[i]+f(offset[i]*distance)) end
        end
        out[index]={position=at,direction={direction[1],direction[2],direction[3]},up={up[1],up[2],up[3]}}
    end
    return out
end
-- The orientation a launched object starts with (init 0x1405eae00): the
-- identity basis with the request's up axis as Z, handed with the direction
-- to the orientation update 0x140a61c20.
function A.launchBasis(up) return {1,0,up[1],0,0,1,up[2],0,0,0,up[3],0,0,0,0,1} end

-- Action start ----------------------------------------------------------------
-- parameters: the action's float parameters by XML name, Velocity,
-- VelocityRandomize and Inductivity already converted from the 30 Hz
-- reference rate (loader 0x140a67af0). rate is the update rate.
-- 0x140a6cb10, the init every action class runs first.
function A.setup(actor,state,parameters,random,rate,M,f,sinf,cosf)
    local function value(name) return f(parameters[name] or 0) end
    local wander=value('RandomDirection')
    local first=radians(A.spread(random,wander,f),f)
    local second=radians(A.spread(random,wander,f),f)
    local third=radians(A.spread(random,wander,f),f)
    -- 0x14127e960(a, out, b) is b * a: the random turn and the fixed turn about
    -- X act in the object's own frame.
    local matrix=M.multiply(state.orientation,M.euler(first,second,third,f,sinf,cosf),f)
    matrix=M.multiply(matrix,rotationX(radians(value('Rotate_x'),f),f,sinf,cosf),f)
    local speed=f(value('Velocity')+A.spread(random,value('VelocityRandomize'),f))
    local forward={f(-matrix[2]),f(-matrix[6]),f(-matrix[10])}
    if squared(forward,f)>0 then
        forward=unit(forward,f)
        state.velocity={f(forward[1]*speed),f(forward[2]*speed),f(forward[3]*speed)}
    end
    -- Gravity is in g: 980.665 units per second squared along -Z.
    local fall=f(f(value('Gravity')*f(980.6649780273438))/f(rate*rate))
    actor.gravity={f(-0.0*fall),f(-0.0*fall),f(-1.0*fall)}
    state.roll=f(A.spread(random,value('RandomRoll'),f)+state.roll)
    actor.inductivity,actor.viewingAngle=value('Inductivity'),value('ViewingAngle')
end
-- Class inits that add to it.
-- ELEVATOR 0x140a6e700: a speed along +Z replaces the launch direction.
function A.elevatorStart(actor,state,parameters,f)
    local speed=f(parameters.Velocity or 0)
    if speed~=0 then state.velocity={f(speed*0),f(speed*0),f(speed*1)} end
end
-- CRAWLER 0x140a6e430: keeps its speed. The ground snap and the FixedUp basis
-- need the stage and are the caller's.
function A.crawlerStart(actor,state,f) actor.speed=length(state.velocity,f) end
-- SINCURVE 0x140a6f030.
function A.sinCurveStart(actor,state,parameters,f)
    local function value(name) return f(parameters[name] or 0) end
    actor.base={state.position[1],state.position[2],state.position[3]}
    actor.amplitude={value('Amplitude_x'),value('Amplitude_y'),value('Amplitude_z')}
    actor.frequency={value('Frequency_x'),value('Frequency_y'),value('Frequency_z')}
    actor.previous={state.position[1],state.position[2],state.position[3]}
end
-- BOUNDBALL 0x140a6e060.
function A.boundBallStart(actor,state,parameters,f)
    actor.friction,actor.restitution=f(parameters.Friction or 0),f(parameters.Restitution or 0)
    actor.bounced,actor.floating=0,0
    actor.previous={state.position[1],state.position[2],state.position[3]}
end

-- Shared steps ----------------------------------------------------------------
local function advance(position,velocity,multiplier,f)
    for i=1,3 do position[i]=f(f(multiplier*velocity[i])+position[i]) end
end
-- 0x140a62320: steer toward the target. target is its position, or nil when
-- the object has none; ix/iy/iz weigh the pull per axis. Returns false when
-- guidance must stop (no target, target outside the viewing cone, no motion).
-- The original's two character-specific cases (4mkgawa*) are not reproduced.
function A.guide(state,target,viewingAngle,ix,iy,iz,f,acos)
    if not target then return false end
    local toward={f(target[1]-state.position[1]),f(target[2]-state.position[2]),f(target[3]-state.position[3])}
    if not (squared(toward,f)>0) then return false end
    toward=unit(toward,f)
    local velocity=state.velocity
    if not (squared(velocity,f)>0) then return false end
    local heading=unit(velocity,f)
    local off=turnDegrees(acos(dot(heading,toward,f)),f)
    if f(viewingAngle*.5)<off then return false end
    local speed=length(velocity,f)
    velocity[1]=f(f(f(toward[1]*speed)*ix)+velocity[1])
    velocity[2]=f(f(f(toward[2]*speed)*iy)+velocity[2])
    velocity[3]=f(f(f(toward[3]*speed)*iz)+velocity[3])
    if squared(velocity,f)>0 then
        local direction=unit(velocity,f)
        velocity[1],velocity[2],velocity[3]=f(speed*direction[1]),f(speed*direction[2]),f(speed*direction[3])
    end
    return true
end
local function steer(actor,state,target,vertical,f,acos)
    if state.guidance~=0 and not A.guide(state,target,actor.viewingAngle,actor.inductivity,actor.inductivity,
        vertical and actor.inductivity or 0,f,acos) then
        state.guidance=0
    end
end
-- 0x140a61980: bank roll. heading is the vector the caller passes (the
-- velocity, or the step of a sine actor).
function A.bank(state,heading,parameters,f)
    local limit,strength,spring=f(parameters.BankRollMax or 0),f(parameters.BankStrong or 0),f(parameters.BankSpring or 0)
    local floor=f(-limit)
    if strength~=0 and limit>state.roll and state.roll>floor and squared(heading,f)>0 then
        local side=dot(unit(heading,f),column(state.orientation,1),f)
        if not (0.000244140625>f(side*side)) then
            if side>0 then
                state.roll=f(strength+state.roll)
                if state.roll>limit then state.roll=limit end
            elseif 0>side then
                state.roll=f(state.roll-strength)
                if floor>state.roll then state.roll=floor end
            end
        end
    end
    if spring~=0 then state.roll=f(f(1-spring)*state.roll) end
end

-- Per-tick updates --------------------------------------------------------------
-- Each ends with the orientation update 0x140a61c20 (skill_shot_core
-- orientation), passed in as orient(state).
-- ARROW 0x140a6ce80.
function A.arrow(actor,state,parameters,target,orient,f,acos)
    advance(state.position,state.velocity,state.multiplier,f)
    for i=1,3 do state.velocity[i]=f(state.velocity[i]+actor.gravity[i]) end
    steer(actor,state,target,true,f,acos)
    A.bank(state,state.velocity,parameters,f)
    orient(state)
end
-- ELEVATOR 0x140a6e670.
function A.elevator(actor,state,orient,f)
    advance(state.position,state.velocity,state.multiplier,f)
    for i=1,3 do state.velocity[i]=f(state.velocity[i]+actor.gravity[i]) end
    orient(state)
end
-- SINCURVE 0x140a6eb60: the straight path carries a sine offset along each
-- axis of the object's frame. sin is the double sine.
function A.sinCurve(actor,state,parameters,target,rate,orient,f,acos,sin)
    actor.previous={state.position[1],state.position[2],state.position[3]}
    advance(actor.base,state.velocity,state.multiplier,f)
    state.position={actor.base[1],actor.base[2],actor.base[3]}
    for i=1,3 do state.velocity[i]=f(state.velocity[i]+actor.gravity[i]) end
    steer(actor,state,target,true,f,acos)
    local elapsed,swing=f(state.frame),{}
    for axis=1,3 do
        local degrees=f(f(f(actor.frequency[axis]*360)*elapsed)/f(rate))
        local scaled=f(f(f(degrees*65536)/360)+(0>degrees and -.5 or .5))
        local units=scaled>=0 and math.floor(scaled) or math.ceil(scaled)
        swing[axis]=f(f(sin(f(f(f(units)*f(6.2831854820251465))*1.52587890625e-05)))*actor.amplitude[axis])
    end
    local o=state.orientation
    local x,y,z=column(o,1),column(o,2),column(o,3)
    state.position={f(f(f(f(x[1]*swing[1])+actor.base[1])+f(y[1]*swing[2]))+f(z[1]*swing[3])),
        f(f(f(f(swing[1]*x[2])+actor.base[2])+f(swing[2]*y[2]))+f(swing[3]*z[2])),
        f(f(f(f(swing[1]*x[3])+actor.base[3])+f(swing[2]*y[3]))+f(swing[3]*z[3]))}
    local step={f(f(state.position[1]-actor.previous[1])+state.velocity[1]),
        f(f(state.position[2]-actor.previous[2])+state.velocity[2]),
        f(f(state.position[3]-actor.previous[3])+state.velocity[3])}
    A.bank(state,step,parameters,f)
    orient(state)
end
-- The FixedUp parameter (0x141282120 on the object's basis): +Z replaces the Z
-- axis before the orientation update, so the object stays upright on a slope.
function A.fixedUp(state)
    local o=state.orientation
    state.orientation={o[1],o[2],0,o[4],o[5],o[6],0,o[8],o[9],o[10],1,o[12],0,0,0,1}
end
-- CRAWLER 0x140a6e0d0. ground(state) answers the stage query 0x140a620a0 (a
-- sphere dropped from above the object): nil when the query finds nothing,
-- else the height of the first walkable surface (false when none of the hits
-- is walkable). upright is the action's FixedUp parameter.
function A.crawler(actor,state,target,rate,ground,orient,f,acos,upright)
    advance(state.position,state.velocity,state.multiplier,f)
    local velocity=state.velocity
    local vertical=velocity[3]
    if vertical>0 then
        if squared(velocity,f)>0 then
            local direction=unit(velocity,f)
            for i=1,3 do velocity[i]=f(actor.speed*direction[i]) end
        end
    else
        velocity[3]=0
        if squared(velocity,f)>0 then
            local direction=unit(velocity,f)
            velocity[1],velocity[2]=f(actor.speed*direction[1]),f(actor.speed*direction[2])
        end
        velocity[3]=vertical
    end
    local height=ground(state)
    if height==nil then velocity[3]=f(velocity[3]-f(98/f(rate)))
    elseif height then state.position[3]=height end
    if upright then A.fixedUp(state) end
    steer(actor,state,target,false,f,acos)
    orient(state)
end
-- BOUNDBALL 0x140a6cfe0, the solid-surface path: gravity, a sweep along the
-- velocity, and on contact a reflection weighed by Restitution (along the
-- surface normal) and Friction (along the surface). sweep(state) answers the
-- stage query: nil, or {fraction=, normal=}. The original also rolls the model
-- with the distance covered and floats on water surfaces: not reproduced.
function A.boundBall(actor,state,target,rate,sweep,f,acos)
    local velocity=state.velocity
    if actor.floating==0 then for i=1,3 do velocity[i]=f(velocity[i]+actor.gravity[i]) end end
    if actor.bounced~=0 then steer(actor,state,target,false,f,acos) end
    actor.bounced=0
    actor.previous={state.position[1],state.position[2],state.position[3]}
    local hit=sweep(state)
    if not hit then advance(state.position,velocity,state.multiplier,f) return end
    actor.bounced=1
    local normal=hit.normal
    local into=f(-dot(velocity,normal,f))
    local keep=f(1-actor.friction)
    local along={f(f(f(normal[1]*into)+velocity[1])*keep),f(f(f(normal[2]*into)+velocity[2])*keep),
        f(f(f(normal[3]*into)+velocity[3])*keep)}
    local away={f(f(normal[1]*into)*actor.restitution),f(f(normal[2]*into)*actor.restitution),
        f(f(normal[3]*into)*actor.restitution)}
    -- Up to the contact, then one unit (30 Hz reference) off the surface.
    local lift=f(f(30/f(rate))*1)
    for i=1,3 do state.position[i]=f(f(state.position[i]+f(hit.fraction*velocity[i]))+f(normal[i]*lift)) end
    -- A weak rebound is halved, the others keep 98 %.
    local damping=f(f(30/f(rate))*4)>squared(away,f) and .5 or f(.9800000190734863)
    for i=1,3 do velocity[i]=f(f(away[i]*damping)+along[i]) end
end
return A
