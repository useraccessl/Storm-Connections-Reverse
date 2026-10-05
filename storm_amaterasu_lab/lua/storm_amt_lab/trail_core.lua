-- Trails of NSUNSC.exe (nuccTrailBase, nuccTrailBase.cpp): the samples taken from the two
-- edge coordinates on every update (0x141325090), the ribbon points between them
-- (0x1413248a0) and the vertices the draw sends (0x141325a50). Operation order and
-- float32 rounding follow the game's code; f rounds to float32 (identity when nil).
--
-- def (storm_import.py trail record): maxSamples, maxSubdivisions, flags, alphaFade,
-- widthFade (bytes / 255 per update), colors {C0, C1, C2} (RGBA), colorSplit, profile
-- {A0, A1, A2} (words, / 255), profileSplit (byte, / 255), keys (32-bit words: bit 31
-- emission on, the rest a time in animation ticks).
-- state: samples (1 = newest; each {edge0 = {x, y, z}, edge1 = {x, y, z}}), points (the
-- ribbon, oldest last), keyIndex, lastFrame, emitting, ending, alpha, widthScale.
local T={}
local TINY=1.1754943508222875e-38            -- FLT_MIN, 0x141860548
local EPSILON=9.999999974752427e-07          -- normalize threshold, 0x141782190
local BEND,BEND_BASE=0.949999988079071,0.05000000074505806
local function same(v) return v end
local function trunc(v) return v>=0 and math.floor(v) or -math.floor(-v) end

local function sub(a,b,f) return {f(a[1]-b[1]),f(a[2]-b[2]),f(a[3]-b[3])} end
-- 0x1411ac850: sqrt((x*x + y*y) + z*z)
local function length(v,f) return f(math.sqrt(f(f(f(v[1]*v[1])+f(v[2]*v[2]))+f(v[3]*v[3])))) end
-- 0x1411acbb0: unit vector, (1, 0, 0) when the length is not above 1e-6
local function normalize(v,f)
    local l=length(v,f)
    if not (l>EPSILON) then return {1,0,0} end
    local inv=f(1/l)
    return {f(v[1]*inv),f(v[2]*inv),f(v[3]*inv)}
end
-- 0x1412cd3c0 (a, b, t): a * t + (1 - t) * b
local function mix(a,b,t,f) return f(f(f(1-t)*b)+f(a*t)) end

function T.new()
    -- Constructor 0x141323330: last frame -1, emitting, alpha and width scale 1.
    return {samples={},points={},keyIndex=0,lastFrame=-1,emitting=1,ending=false,alpha=1,widthScale=1}
end

-- Sample count the trail keeps (0x141327140) and points per segment at most
-- (0x141327060), for the time scale dt (trail +138, 1 unless the effect is slowed).
function T.maxSamples(def,dt,f)
    f=f or same
    if dt>0 then local r=f(1/dt) if r>0 then return trunc(f(def.maxSamples*r)) end end
    return def.maxSamples
end
function T.maxSubdivisions(def,dt,f)
    f=f or same
    if dt>0 then local n=trunc(f(def.maxSubdivisions*dt)) return n==0 and 1 or n end
    return def.maxSubdivisions
end

-- 0x1413248a0: ribbon points between samples i + 1 and i + 2 (0-based i: samples i,
-- i + 1, i + 2 of the newest-first list), appended to out (newest first). Nothing when
-- one of the four sample-to-sample steps has no length.
function T.subdivide(samples,i,maxSub,startWidth,endWidth,widthScale,f,out)
    f=f or same
    local A,B,C=samples[i+1],samples[i+2],samples[i+3]
    local d1,d2,l1={},{},{}
    local sum=0
    for e=1,2 do
        local u,v=sub(A[e],B[e],f),sub(B[e],C[e],f)
        local a,b=length(u,f),length(v,f)
        if not (a>TINY and b>TINY) then return out end
        local ia,ib=f(1/a),f(1/b)
        u={f(u[1]*ia),f(u[2]*ia),f(u[3]*ia)} v={f(v[1]*ib),f(v[2]*ib),f(v[3]*ib)}
        local dot=f(f(f(v[2]*u[2])+f(v[1]*u[1]))+f(v[3]*u[3]))
        sum=f(sum+f(f(math.abs(f(dot-1))*BEND)+BEND_BASE))
        d1[e],d2[e],l1[e]=u,v,a
    end
    local n=1-trunc(f(sum*-64))
    if n<maxSub then maxSub=n end
    n=maxSub
    if n<1 then return out end
    local half=f(f(n)+0.5)
    local step=f(1/f(n))
    local count=n
    for j=n-1,0,-1 do
        local t=f(count/half)
        local w=f(f(t*0.5)+0.5)
        local om=f(1-w)
        local P={}
        for e=1,2 do
            local a,b=d1[e],d2[e]
            local dir=normalize({f(f(w*a[1])+f(om*b[1])),f(f(w*a[2])+f(om*b[2])),f(f(w*a[3])+f(om*b[3]))},f)
            local s=f(l1[e]*t)
            local base=B[e]
            P[e]={f(f(dir[1]*s)+base[1]),f(f(dir[2]*s)+base[2]),f(f(dir[3]*s)+base[3])}
        end
        local delta=sub(P[1],P[2],f)
        local wt=math.min(1,f(f(f(j)+0.5)*step))
        local width=mix(startWidth,endWidth,wt,f)
        local k=f(1-width)
        local off={f(f(delta[1]*k)*0.5),f(f(delta[2]*k)*0.5),f(f(delta[3]*k)*0.5)}
        if widthScale~=1 then
            local g=f(f(f(1-widthScale)*width)*0.5)
            off={f(off[1]+f(delta[1]*g)),f(off[2]+f(delta[2]*g)),f(off[3]+f(delta[3]*g))}
        end
        out[#out+1]={{f(P[1][1]-off[1]),f(P[1][2]-off[2]),f(P[1][3]-off[3])},
            {f(P[2][1]+off[1]),f(P[2][2]+off[2]),f(P[2][3]+off[3])}}
        count=count-1
    end
    return out
end

-- Widths at segment i of n (0x141325090): the profile A0 -> A1 -> A2 along the trail,
-- split at profileSplit, at the segment's two ends.
function T.widths(def,i,n,f)
    f=f or same
    local s=f(def.profileSplit/255)
    local A0,A1,A2=f(def.profile[1]/255),f(def.profile[2]/255),f(def.profile[3]/255)
    local ta=f(f(i)/f(n))
    local tb=math.min(1,f(f(i+1)/f(n)))
    local wa,wb
    if s==0 then
        wa=mix(A1,A2,f(1-ta),f) wb=mix(A1,A2,f(1-tb),f)
    elseif s>=ta then
        wa=mix(A0,A1,f(1-f(ta/s)),f)
        if s>=tb then wb=mix(A0,A1,f(1-f(tb/s)),f)
        else wb=mix(A1,A2,f(1-f(f(tb-s)/f(1-s))),f) end
    else
        wa=mix(A1,A2,f(1-math.min(1,f(f(ta-s)/f(1-s)))),f)
        wb=mix(A1,A2,f(1-math.min(1,f(f(tb-s)/f(1-s)))),f)
    end
    return wa,wb
end

-- 0x1411efdf0: a direction through the rotation rows of a matrix (row-major, translation
-- in the fourth column), each row summed as ((m0 x + m2 z) + m1 y).
local function rotate(m,v,f)
    local out={}
    for r=0,2 do
        local a0,a1,a2=f(m[4*r+1]*v[1]),f(m[4*r+2]*v[2]),f(m[4*r+3]*v[3])
        out[r+1]=f(f(a0+a2)+a1)
    end
    return out
end
-- SSE minss / maxss: the second operand when the comparison fails (NaN included).
local function minss(a,b) if a<b then return a end return b end
local function maxss(a,b) if a>b then return a end return b end

-- One force field (nuccTrailForceField vtable +10 = 0x14132c830) acting on the samples.
-- field (table-3 record from +0x10 of the file record): direction, decay, kind (only 1
-- acts), radius (x 100), strength, flags (1: half strength everywhere, 2: falling to the
-- edge, 4: rising to the edge, 0x10: direction in world space). matrix: the world matrix
-- of the field's coordinate, or nil (the field then sits at the origin, axis-aligned).
-- Inside the radius a sample edge is pushed by direction * strength * falloff, which
-- becomes its velocity, and the sample takes the field's decay; outside, an edge with a
-- velocity keeps moving: velocity += velocity * decay, position += velocity.
function T.applyField(field,matrix,samples,f)
    f=f or same
    if #samples==0 then return end
    local d=field.direction
    local dir={0,0,1}
    if length(d,f)>TINY then dir=normalize(d,f) end
    local center={0,0,0}
    local m={1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1}
    if matrix then
        m=matrix
        center={matrix[4],matrix[8],matrix[12]}
    end
    local flags=field.flags
    if math.floor(flags/16)%2==1 then m={1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1} end
    local w=rotate(m,dir,f)
    if f(f(f(w[1]*w[1])+f(w[2]*w[2]))+f(w[3]*w[3]))>0 then w=normalize(w,f) end
    local strength=field.strength
    local force={f(w[1]*strength),f(w[2]*strength),f(w[3]*strength)}
    local radius=f(field.radius*100)
    if field.kind~=1 then return end
    for _,s in ipairs(samples) do
        for e=1,2 do
            local p=s[e]
            local dist=length(sub(p,center,f),f)
            local k
            if flags%2==1 then k=0.5
            elseif math.floor(flags/2)%2==1 then
                if radius>0 then k=f(1-math.abs(f(dist/radius))) else k=0 end
            elseif math.floor(flags/4)%2==1 then
                if radius>0 then k=f(1-f(1-math.abs(f(dist/radius)))) else k=1 end
            else k=0.5 end
            k=maxss(0,minss(1,k))
            if dist>TINY and radius>dist then
                local delta={f(force[1]*k),f(force[2]*k),f(force[3]*k)}
                s[e]={f(p[1]+delta[1]),f(p[2]+delta[2]),f(p[3]+delta[3])}
                s.velocity[e]=delta
                s.decay=field.decay
            else
                local v=s.velocity[e]
                if f(f(f(v[1]*v[1])+f(v[2]*v[2]))+f(v[3]*v[3]))>TINY and math.abs(s.decay)>TINY then
                    local c=s.decay
                    v={f(v[1]+f(c*v[1])),f(v[2]+f(c*v[2])),f(v[3]+f(c*v[3]))}
                    s.velocity[e]=v
                    s[e]={f(p[1]+v[1]),f(p[2]+v[2]),f(p[3]+v[3])}
                end
            end
        end
    end
end

-- One update (0x141325090): frame = the animation's time in ticks (-1: no time),
-- edge0 / edge1 = world positions of the two edge coordinates, dt = time scale.
-- fields: the trail's force fields in table-3 order, {field, matrix} each (applyField);
-- they act on the kept samples before the new one is taken, unless the trail is ending.
function T.update(state,def,frame,edge0,edge1,dt,f,fields)
    f=f or same
    if frame==-1 then
        state.emitting=0
        if not state.ending then return end
    elseif frame~=state.lastFrame then
        if frame<state.lastFrame then state.keyIndex=0 end
        state.lastFrame=frame
        local key=def.keys and def.keys[state.keyIndex+1]
        if key then
            local at=key%2147483648
            if at<=frame then
                if key>=2147483648 then
                    state.emitting=1
                    if not state.ending then state.alpha,state.widthScale=1,1 end
                else state.emitting=0 end
                state.keyIndex=state.keyIndex+1
            end
        end
    end
    local samples=state.samples
    if not state.ending then
        for _,field in ipairs(fields or {}) do T.applyField(field.field,field.matrix,samples,f) end
        -- A new sample (0x1413235b0) has no velocity and no decay.
        table.insert(samples,1,{{edge0[1],edge0[2],edge0[3]},{edge1[1],edge1[2],edge1[3]},
            velocity={{0,0,0},{0,0,0}},decay=0})
    end
    if state.ending or state.emitting==0 then
        if def.flags%2==1 and #samples>0 then
            state.alpha=f(state.alpha-f(def.alphaFade/255))
            if not (state.alpha>0) then state.alpha=0 end
        end
        if math.floor(def.flags/2)%2==1 then
            state.widthScale=f(state.widthScale-f(def.widthFade/255))
            if not (state.widthScale>0) then state.widthScale=0 end
        end
    end
    -- Ribbon points, from the samples before this update's trimming.
    local points={}
    local segments=#samples-2
    local limit=T.maxSamples(def,dt,f)
    local maxSub=T.maxSubdivisions(def,dt,f)
    for i=0,math.min(limit,segments)-1 do
        local wa,wb=T.widths(def,i,segments,f)
        T.subdivide(samples,i,maxSub,wa,wb,state.widthScale,f,points)
    end
    if state.ending then
        if #samples>0 then table.remove(samples) end
    elseif state.emitting==0 then
        for _=1,2 do if #samples>=2 then table.remove(samples) end end
    end
    while #samples>limit do table.remove(samples) end
    while #points>=maxSub*limit and #points>0 do table.remove(points) end
    state.points=points
end

-- Vertices of the ribbon (0x141325a50): two per point (edge 0, edge 1), each
-- {position, color RGBA, u, v}. rect: the trail billboard's UV values {uv0 offset u, v,
-- uv0 scale u, v, uv1 offset u, v, uv1 scale u, v} (billboard +2C8.. +2E0), or nil.
function T.vertices(state,def,rect,f)
    f=f or same
    local points=state.points
    local n=#points
    if n<=1 then return {} end
    local cum={{0,0}}
    local total={0,0}
    for k=2,n do
        cum[k]={}
        for e=1,2 do
            local seg=length(sub(points[k-1][e],points[k][e],f),f)
            total[e]=f(total[e]+seg)
            cum[k][e]=f(cum[k-1][e]+seg)
        end
    end
    -- Without a billboard every UV value is 0 and the u span 1.
    local u0,du,v0,spanV,scaleV=0,1,0,0,0
    if rect then
        u0,v0=rect[1],rect[2]
        du=f(f(rect[7]-rect[5])*rect[3])
        spanV,scaleV=f(rect[8]-rect[6]),rect[4]
    end
    local C0,C1,C2=def.colors[1],def.colors[2],def.colors[3]
    local m=def.colorSplit
    local out={}
    for k=1,n do
        for e=1,2 do
            local tot=total[e]
            local v=f(f(f(f(cum[k][e]/tot)*spanV)*scaleV)+v0)
            local t=tot==0 and 0 or f(cum[k][e]/tot)
            local A,B,s
            if m==0 then A,B,s=C1,C2,t
            elseif m>t then A,B,s=C0,C1,f(t/m)
            else A,B,s=C1,C2,f(f(t-m)/f(1-m)) end
            local w=f(1-s)
            local om=f(1-w)
            local color={}
            for c=1,4 do color[c]=f(f(w*A[c])+f(om*B[c])) end
            color[4]=f(state.alpha*color[4])
            local p=points[k][e]
            out[#out+1]={position={p[1],p[2],p[3]},color=color,u=e==1 and f(du+u0) or u0,v=v}
        end
    end
    return out
end
return T
