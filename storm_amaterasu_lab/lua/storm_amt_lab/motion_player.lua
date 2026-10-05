local data=include("storm_amt_lab/motion_timeline_data.lua")
local timeline=include("storm_amt_lab/motion_timeline.lua")
local old=STORM_AMATERASU_MOTION
if old and old.cleanup then old.cleanup() end
local state={meshes={},active=nil,lastTime=-1,updates=0}
STORM_AMATERASU_MOTION=state
local function constant(mat,n,v)
    for i,axis in ipairs({"x","y","z","w"}) do mat:SetFloat("$c"..n.."_"..axis,v[i]) end
end
for name,model in pairs(data.models) do
    local material=CreateMaterial("storm_amt_motion_r6_"..name,"screenspace_general",{
        ["$pixshader"]="amt_motion_r6_ps30",["$vertexshader"]="amt_capture_r3_vs30",
        ["$basetexture"]="storm_amt_lab/capture_"..model.texture,
        ["$texture1"]="storm_amt_lab/capture_83535",
        ["$vertexcolor"]="1",["$vertextransform"]="1",["$x360appchooser"]="1",
        ["$copyalpha"]="1",["$alpha_blend"]="0",["$writealpha"]="1",
        ["$depthtest"]="1",["$writedepth"]="1",["$cull"]="0",
        ["$softwareskin"]="1",["$translucent"]="1",
        ["$linearread_basetexture"]="1",["$linearread_texture1"]="1",["$linearwrite"]="1"})
    local vertices={}
    for _,v in ipairs(model.vertices) do vertices[#vertices+1]={pos=Vector(v[1],v[2],v[3]),u=v[4],v=v[5],color=Color(v[6]*255,v[7]*255,v[8]*255,v[9]*255)} end
    local mesh=Mesh(material) mesh:BuildFromTriangles(vertices)
    state.meshes[name]={mesh=mesh,mat=material}
end
state.cleanup=function()
    state.active=nil
    for _,m in pairs(state.meshes) do if m.mesh:IsValid() then m.mesh:Destroy() end end
end
concommand.Add("storm_amt_motion",function(_,_,args)
    local player=LocalPlayer() if not IsValid(player) then return end
    if STORM_AMATERASU_CAPTURE_CLEAR then STORM_AMATERASU_CAPTURE_CLEAR() end
    local trace=player:GetEyeTrace()
    RunConsoleCommand("storm_amt_hide") RunConsoleCommand("storm_amt_sequence_hide") RunConsoleCommand("storm_amt_decoded_hide")
    state.active={pos=trace.HitPos+trace.HitNormal*3,scale=math.Clamp(tonumber(args[1]) or .3,.01,5),
        yaw=EyeAngles().y-data.cameraYaw+(tonumber(args[2]) or 0),start=CurTime(),
        speed=math.Clamp(tonumber(args[4]) or 1,.1,5)}
    state.updates=0 state.lastTime=-1
    print("Amaterasu continuous r6: original atlas key animation, measured transforms interpolated every rendered frame; full force simulation remains unfinished")
end)
concommand.Add("storm_amt_motion_hide",function() state.active=nil end)
concommand.Add("storm_amt_motion_diag",function()
    print("Amaterasu continuous r6; updates="..state.updates.."; playback time="..state.lastTime.."; active="..tostring(state.active~=nil))
end)
hook.Add("PostDrawTranslucentRenderables","StormAmaterasuContinuousMotion",function(depth,sky,sky3d)
    local active=state.active
    if not active or depth or sky or sky3d then return end
    local time=(CurTime()-active.start)*active.speed
    if time>data.duration+.3 then state.active=nil return end
    local tail=time>data.duration and 1-(time-data.duration)/.3 or 1
    local draws=timeline.evaluate(data,math.min(time,data.duration))
    state.lastTime=time state.updates=state.updates+1
    local angle=EyeAngles() local right,up=angle:Right(),angle:Up() local normal=right:Cross(up)
    for _,d in ipairs(draws) do
        local item=state.meshes[d.model] local mat=item.mat
        constant(mat,0,{d.uvScale[1]/ScrW(),-d.uvScale[2]/ScrH(),d.scroll[1]*d.uvScale[1],d.scroll[2]*d.uvScale[2]})
        constant(mat,1,{d.tint[1],d.tint[2],d.tint[3],1})
        constant(mat,2,{d.film,d.threshold,d.opacity,0})
        constant(mat,3,d.uv)
        local offset=Vector(d.origin[1],d.origin[2],d.origin[3]) offset:Rotate(Angle(0,active.yaw,0))
        local pos=active.pos+offset*active.scale
        local transform=Matrix() local size=active.scale*d.weight*tail
        for column=1,3 do
            local j=(column-1)*3
            local axis=right*d.basis[j+1]+up*d.basis[j+2]+normal*d.basis[j+3]
            for row=1,3 do transform:SetField(row,column,axis[row]*size) end
        end
        for row=1,3 do transform:SetField(row,4,pos[row]) end
        cam.PushModelMatrix(transform) render.SetMaterial(mat) item.mesh:Draw() cam.PopModelMatrix()
    end
end)
hook.Add("ShutDown","StormAmaterasuMotionCleanup",state.cleanup)
