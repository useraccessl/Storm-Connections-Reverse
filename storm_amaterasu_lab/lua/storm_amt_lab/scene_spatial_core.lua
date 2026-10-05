-- Resolve original constant ANM coordinates and typed attachment records.
-- Animated coordinate sampling is an explicit caller input until its
-- interpolation convention is checked. No GPU position samples are used.
local S={}
local function rotate(m,v)
    return {m[1]*v[1]+m[2]*v[2]+m[3]*v[3],m[4]*v[1]+m[5]*v[2]+m[6]*v[3],m[7]*v[1]+m[8]*v[2]+m[9]*v[3]}
end
local function multiply(a,b)
    local out={}
    for row=0,2 do for col=1,3 do
        out[row*3+col]=a[row*3+1]*b[col]+a[row*3+2]*b[3+col]+a[row*3+3]*b[6+col]
    end end
    return out
end
local function matrix(q,scale)
    local x,y,z,w=q[1],q[2],q[3],q[4]
    local n=math.sqrt(x*x+y*y+z*z+w*w)
    if n==0 then return nil,'zero coordinate quaternion' end
    x,y,z,w=x/n,y/n,z/n,w/n
    return {(1-2*(y*y+z*z))*scale[1],2*(x*y-w*z)*scale[2],2*(x*z+w*y)*scale[3],
        2*(x*y+w*z)*scale[1],(1-2*(x*x+z*z))*scale[2],2*(y*z-w*x)*scale[3],
        2*(x*z-w*y)*scale[1],2*(y*z+w*x)*scale[2],(1-2*(x*x+y*y))*scale[3]}
end
function S.coordinates(animation,sampleAnimated)
    local coords={}
    for _,entry in ipairs(animation.entries) do if entry.type==1 then
        local values={}
        for _,c in ipairs(entry.curves) do if c.index<3 then
            local value=c.values[1]
            local constant=true
            for j=2,#c.values do
                local start=(c.format==10 or c.format==6 or c.format==12) and 2 or 1
                for k=start,#value do if value[k]~=c.values[j][k] then constant=false end end
            end
            if not constant then
                if not sampleAnimated then return nil,'animated coordinate requires original sampler: '..entry.target end
                value=sampleAnimated(c)
            elseif c.format==10 or c.format==6 or c.format==12 then
                local trimmed={} for k=2,#value do trimmed[#trimmed+1]=value[k] end value=trimmed
            end
            values[c.index+1]=value
        end end
        local basis,why=matrix(values[2],values[3])
        if not basis then return nil,why end
        coords[entry.target]={position={values[1][1],values[1][2],values[1][3]},rotation=basis}
    end end
    -- Parent tuples contain parent clump/bone then child clump/bone indices.
    local parentOf={}
    for _,p in ipairs(animation.parents) do
        local a=animation.clumps[p[1]+1].bones[p[2]+1]
        local b=animation.clumps[p[3]+1].bones[p[4]+1]
        parentOf[b]=a
    end
    local resolved={};local visiting={}
    local function resolve(name)
        if resolved[name] then return resolved[name] end
        if visiting[name] then error('cyclic original ANM hierarchy') end
        visiting[name]=true
        local c=coords[name]
        if parentOf[name] then
            local p=resolve(parentOf[name])
            local offset=rotate(p.rotation,c.position)
            c={position={p.position[1]+offset[1],p.position[2]+offset[2],p.position[3]+offset[3]},rotation=multiply(p.rotation,c.rotation)}
        end
        visiting[name]=nil resolved[name]=c return c
    end
    for name in pairs(coords) do resolve(name) end
    return resolved
end
-- external(name): coordinate of a node the effect's own animation does not
-- carry (a bone of the caster, another object's clump), supplied by the host,
-- or nil.
function S.attachments(records,coords,emitter,external)
    local out={}
    for _,r in ipairs(records) do if r.emitter==emitter then
        local c=coords[r.coord] or (external and external(r.coord))
        if not c then return nil,'unresolved coordinate: '..r.coord end
        local m=c.rotation
        out[#out+1]={position=c.position,rotation=m,direction=r.direction,worldDirection=r.world_direction,
            scale=math.sqrt(m[1]^2+m[4]^2+m[7]^2),connection=r.original_connection_field or 0}
    end end
    return out
end
-- 0x1413856b0 counts node.config+0xc != 0; 0x1413852f0 returns
-- that field (file+0x1c). 0x14131cbf0 has a special index-zero branch
-- and falls back to the last two nodes; it does not close a polygon.
function S.segments(attachments)
    local n=#attachments
    if n<2 then return {} end
    local breaks=0
    for _,a in ipairs(attachments) do if a.connection~=0 then breaks=breaks+1 end end
    local count=n==breaks and n or n-breaks
    local out={{attachments[1],attachments[2]}}
    for selected=1,count-1 do
        local ordinal=0 local found=nil
        for i,a in ipairs(attachments) do
            if a.connection==0 then
                if ordinal==selected then found=i break end
                ordinal=ordinal+1
            end
        end
        if found and found<n then out[#out+1]={attachments[found],attachments[found+1]}
        else out[#out+1]={attachments[n-1],attachments[n]} end
    end
    return out
end
function S.fields(records,coords,emitter,external)
    local out={}
    for _,r in ipairs(records) do if r.emitter==emitter then
        local c=coords[r.coord] or (external and external(r.coord))
        if not c then return nil,'unresolved force coordinate: '..r.coord end
        local v=r.direction
        if not r.world_direction then v=rotate(c.rotation,v) end
        local n=math.sqrt(v[1]^2+v[2]^2+v[3]^2)
        out[#out+1]={center=c.position,direction=n>0 and {v[1]/n,v[2]/n,v[3]/n} or {0,0,0},
            directionLength=n,config=r}
    end end
    return out
end
return S
