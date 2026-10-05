-- Diagnostic playback of decoded emission/size/alpha/UV/shader parameters.
-- Attachment rotations, force fields, render state and RGB context need validation.
local assets=include("storm_amt_lab/generated.lua")
local data=include("storm_amt_lab/runtime_data.lua")
local core=include("storm_amt_lab/runtime_core.lua")
local cache={} local effect
local function random(seed)
    return function()
        seed=(seed*214013+2531011)%2147483648
        return math.floor(seed/65536)/32767
    end
end
local function meshFor(name,key,uv,shade)
    shade=shade or {1,1,1}
    local rgb={math.floor(shade[1]*255+.5),math.floor(shade[2]*255+.5),math.floor(shade[3]*255+.5)}
    local id=name..":"..key..":"..table.concat(rgb,",")
    if cache[id] then return cache[id] end
    local spec=assets[name] if not spec then return end
    local mat=Material("storm_amt_lab/decoded_"..name)
    local triangles={}
    for _,index in ipairs(spec.triangles) do
        local v=spec.vertices[index]
        triangles[#triangles+1]={pos=Vector(v[1],v[2],v[3]),u=uv[1]+v[4]*uv[3],v=uv[2]+v[5]*uv[4],color=Color(v[6]*rgb[1]/255,v[7]*rgb[2]/255,v[8]*rgb[3]/255,v[9])}
    end
    local mesh=Mesh(mat) mesh:BuildFromTriangles(triangles)
    cache[id]={mesh=mesh,material=mat} return cache[id]
end
local function fractSigned(n) return n-(n>=0 and math.floor(n) or math.ceil(n)) end
local function constant(mat,c,values)
    for i,axis in ipairs({"x","y","z","w"}) do mat:SetFloat("$c"..c.."_"..axis,values[i]) end
end
local function emitParticles(name,seconds,seed,fps)
    local particles={} local rng=random(seed)
    for _,e in ipairs(data.effects[name]) do
        for _,birth in ipairs(core.births(e,seconds,fps)) do
            local resource=e.resources[math.min(#e.resources,math.floor(rng()*#e.resources)+1)]
            if data.billboards[resource] then
                local life=math.floor(e.life*(1+rng()*e.lifeRandom))
                local sr={rng(),0,0}
                if e.independentSizeRandom then sr[2]=rng() sr[3]=rng() else sr[2]=sr[1] sr[3]=sr[1] end
                local radius=e.radius*(1-rng()*e.radiusRandom)
                local theta=rng()*math.pi*2
                local position=Vector(math.cos(theta)*radius,math.sin(theta)*radius,0)
                if e.shape==2 then
                    local phi=rng()*math.pi*2
                    position=Vector(math.cos(theta)*math.cos(phi)*radius,math.sin(theta)*radius,math.cos(theta)*math.sin(phi)*radius)
                end
                local velocity
                if e.direction==2 then velocity=Vector(rng()*2-1,rng()*2-1,rng()*2-1)
                elseif e.direction==0 or e.direction==1 then velocity=position*(e.direction==0 and -1 or 1)
                else
                    -- The precise cone/attachment composition remains unverified.
                    local a=e.angles[1]*(1+(rng()*2-1)*e.angleRanges[1])
                    local b=e.angles[2]*(1+(rng()*2-1)*e.angleRanges[2])
                    velocity=Vector(math.sin(a),math.sin(b),math.cos(a)*math.cos(b))
                end
                velocity:Normalize() velocity=velocity*e.speed*(1+rng()*e.speedRandom)
                particles[#particles+1]={name=resource,birth=birth,life=math.max(1,life),e=e,random=sr,
                    position=position,velocity=velocity,rotation=(e.rotation==1 or e.rotation==3) and (rng()*360-180) or 0}
            end
        end
    end
    return particles
end
concommand.Add("storm_amt_decoded",function(_,_,args)
    local player=LocalPlayer() if not IsValid(player) then return end
    local trace=player:GetEyeTrace()
    local name=tonumber(args[1])==1 and "2efb_amt_blt00" or "2efb_amt_hit00"
    effect={name=name,pos=trace.HitPos+trace.HitNormal*3,scale=math.Clamp(tonumber(args[2]) or 1,0.05,10),
        hold=tonumber(args[3]),start=SysTime(),particles=emitParticles(name,2,tonumber(args[4]) or 1,60),rgb=tonumber(args[5])==1}
    print("Decoded emission, life, XYZ size, alpha, two UVs and screen-space shader. Diagnostic; attachment/force/RGB context is not yet validated.")
end)
concommand.Add("storm_amt_decoded_hide",function() effect=nil end)
hook.Add("PostDrawTranslucentRenderables","StormAmaterasuDecoded",function(_,sky)
    if sky or not effect then return end
    local elapsed=effect.hold or SysTime()-effect.start
    if elapsed>3 then effect=nil return end
    for _,p in ipairs(effect.particles) do
        local age=elapsed-p.birth
        if age>=0 and age*p.e.simulationHz<=p.life then
            local size,color,alpha=core.sample(p.e,p.life,age,p.random)
            local channels,key=core.billboard(data.billboards[p.name],age)
            local original=data.materials[p.name]
            local ou=channels[5] or {original.uv0[1],original.uv0[2]}
            local su=channels[6] or {original.uv0[3],original.uv0[4]}
            local uv={ou[1],ou[2],su[1],su[2]}
            local entry=meshFor(p.name,key,uv,effect.rgb and color or nil)
            if entry then
                local mat=entry.material
                local s0,s1=original.scroll0,original.scroll1
                constant(mat,0,{1/ScrW(),-1/ScrH(),fractSigned(age*s0[3]),fractSigned(age*s0[4])})
                constant(mat,1,{3/ScrW(),-3/ScrH(),3*fractSigned(age*s1[3]),3*fractSigned(age*s1[4])})
                local dual=#original.textures==4
                local opacity=alpha*(channels[4] and channels[4][1] or 1)
                if dual then
                    constant(mat,2,{channels[7] and channels[7][1] or original.blend[1],s1[1],original.threshold,opacity})
                    local ou1=channels[10] or {original.uv1[1],original.uv1[2]}
                    local su1=channels[11] or {original.uv1[3],original.uv1[4]}
                    local rx=su[1]~=0 and su1[1]/su[1] or 0
                    local ry=su[2]~=0 and su1[2]/su[2] or 0
                    constant(mat,3,{ou1[1]-ou[1]*rx,ou1[2]-ou[2]*ry,rx,ry})
                else
                    constant(mat,2,{s1[1],s1[2],original.threshold,opacity})
                    constant(mat,3,{0,0,0,1})
                end
                local pos=effect.pos+(p.position+p.velocity*(age*p.e.simulationHz))*effect.scale
                local angle=EyeAngles()
                local right,up=angle:Right(),angle:Up()
                local radians=math.rad(p.rotation)
                local x=right*math.cos(radians)+up*math.sin(radians)
                local y=up*math.cos(radians)-right*math.sin(radians)
                local z=x:Cross(y)
                local matrix=Matrix()
                for row=1,3 do
                    matrix:SetField(row,1,x[row]*size[1]*effect.scale)
                    matrix:SetField(row,2,y[row]*size[2]*effect.scale)
                    matrix:SetField(row,3,z[row]*size[3]*effect.scale)
                    matrix:SetField(row,4,pos[row])
                end
                cam.PushModelMatrix(matrix)
                render.SetMaterial(mat) entry.mesh:Draw()
                cam.PopModelMatrix()
            end
        end
    end
end)
hook.Add("ShutDown","StormAmaterasuDecodedCleanup",function()
    for _,entry in pairs(cache) do if entry.mesh:IsValid() then entry.mesh:Destroy() end end
end)
