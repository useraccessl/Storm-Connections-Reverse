-- Translation of NSUNSC force dispatch 0x141385ec0 and integration
-- 0x141386b70. Caller supplies resolved force centers/directions and the
-- original step factor. Attachment composition remains the caller's job.
local M={}
local epsilon=1.1754943508222875e-38 -- original float at VA 0x141860548
local function add(target,source,factor)
    for i=1,3 do target[i]=target[i]+source[i]*factor end
end
-- 0x141386bfb: context +90, +88, +80, in that order. The caller
-- supplies those resolved lists; field configuration order is preserved.
function M.routeFields(mask,lists)
    local out={}
    for i,bit in ipairs({1,256,65536}) do
        if math.floor(mask/bit)%2==1 then
            for _,f in ipairs(lists[i] or {}) do out[#out+1]=f end
        end
    end
    return out
end
-- 0x1411f1870 -> 0x1411bb590 -> 0x1411bcea0. Angle is in radians;
-- the game forms (axis*sin(angle/2),cos(angle/2)), then applies matrix rows.
function M.rotateAxis(vector,axis,angle)
    local s,w=math.sin(angle*.5),math.cos(angle*.5)
    local x,y,z=axis[1]*s,axis[2]*s,axis[3]*s
    return {
        (1-2*(y*y+z*z))*vector[1]+2*(x*y-w*z)*vector[2]+2*(x*z+w*y)*vector[3],
        2*(x*y+w*z)*vector[1]+(1-2*(x*x+z*z))*vector[2]+2*(y*z-w*x)*vector[3],
        2*(x*z-w*y)*vector[1]+2*(y*z+w*x)*vector[2]+(1-2*(x*x+y*y))*vector[3]
    }
end
function M.force(state,field,step)
    local f=field.config
    if f.strength==0 then return true end
    local offset={} local squared=0
    for i=1,3 do offset[i]=field.center[i]-state.position[i] squared=squared+offset[i]^2 end
    local distance=math.sqrt(squared)
    local radius=f.radius_base*field.directionLength
    if f.limit_radius and radius*radius<=squared then return true end
    local falloff=1
    if f.limit_radius and math.abs(radius)>epsilon then
        if f.falloff_mode==1 then falloff=1-distance/radius
        elseif f.falloff_mode==2 then falloff=distance/radius end
    end
    local strength=f.strength*(1+f.strength_multiplier)*state.scalar*step
    local kind=f.selector
    if kind==0 then
        local squaredAxis=0
        for i=1,3 do squaredAxis=squaredAxis+field.direction[i]^2 end
        if squaredAxis<=epsilon then return true end
        local reciprocal=math.abs(field.directionLength)>epsilon and 1/field.directionLength or 1
        local axis={} local relative={}
        for i=1,3 do
            axis[i]=field.direction[i]/math.sqrt(squaredAxis)
            relative[i]=-offset[i]
        end
        local rotated=M.rotateAxis(relative,axis,strength*falloff*reciprocal)
        -- Original branch accumulates into +0x1dc, shared with parent motion.
        -- It does not translate +0x7c directly or add persistent velocity.
        state.displacement=state.displacement or {0,0,0}
        for i=1,3 do state.displacement[i]=state.displacement[i]+rotated[i]-relative[i] end
    elseif kind==1 then
        state.speed=state.speed+strength
        if strength<0 and state.speed<0 then state.speed=0 end
    elseif kind==2 then
        if distance>epsilon then add(state.velocity,offset,strength*falloff/distance) end
    elseif kind==3 then add(state.position,field.direction,strength*falloff)
    elseif kind==4 then add(state.rotation,f.vector_parameter,strength*falloff)
    elseif kind==5 then add(state.scale,f.vector_parameter,strength*falloff)
    elseif kind==6 then add(state.velocity,field.direction,strength*falloff)
    else return false,"unknown force selector" end
    return true
end
function M.integrate(state,step,parentDisplacement)
    add(state.position,state.velocity,state.speed*step)
    add(state.position,parentDisplacement,state.speed)
    if state.displacement then
        add(state.position,state.displacement,state.speed)
        for i=1,3 do state.displacement[i]=0 end
    end
    add(state.position,state.secondaryVelocity,state.speed*step)
end
return M
