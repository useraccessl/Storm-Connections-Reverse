-- Frozen original GPU frame. Exact recorded inputs; Source postprocessing differs.
local data=include("storm_amt_lab/captured_frame.lua")
include("storm_amt_lab/motion_player.lua")
local draws={} local active local lastDrawFrame=-1
local capturedYaw=data.cameraYaw
local samples={22082,22102,22127,22136,22149,22171,22200}
local cache={}
local replay
STORM_AMATERASU_CAPTURE_CLEAR=function() active=nil replay=nil end
hook.Remove("PostDrawOpaqueRenderables","StormAmaterasuCapturedGPUFrame")
local function constant(mat,n,v)
    for i,axis in ipairs({"x","y","z","w"}) do mat:SetFloat("$c"..n.."_"..axis,v[i]) end
end
local function build(frame,label)
local result={}
for _,d in ipairs(frame) do
    local t=d.textures
    local material=CreateMaterial("storm_amt_gpu_r5_"..label.."_"..d.event,"screenspace_general",{
        ["$pixshader"]="amt_projected_ps30",["$vertexshader"]="amt_capture_r3_vs30",
        ["$basetexture"]="storm_amt_lab/capture_"..t[1],
        ["$texture1"]="storm_amt_lab/capture_"..t[2],
        ["$texture2"]="storm_amt_lab/capture_"..t[#t],
        ["$vertexcolor"]="1",["$vertextransform"]="1",["$x360appchooser"]="1",
        ["$copyalpha"]="1",["$alpha_blend"]="0",["$writealpha"]="1",
        ["$depthtest"]="1",["$writedepth"]="1",["$cull"]="0",
        ["$softwareskin"]="1",["$translucent"]="1",
        ["$linearread_basetexture"]="1",["$linearread_texture1"]="1",
        ["$linearread_texture2"]="1",["$linearwrite"]="1"})
    local plain=CreateMaterial("storm_amt_gpu_plain_r5_"..label.."_"..d.event,"UnlitGeneric",{
        ["$basetexture"]="storm_amt_lab/capture_"..t[1],["$model"]="1",
        ["$vertexcolor"]="1",["$vertexalpha"]="1",["$translucent"]="1",["$nocull"]="1"})
    local vertices={}
    for _,v in ipairs(d.facing_vertices or d.vertices) do
        vertices[#vertices+1]={pos=Vector(v[1],v[2],v[3]),u=v[4],v=v[5],color=Color(math.Clamp(v[6]*255,0,255),math.Clamp(v[7]*255,0,255),math.Clamp(v[8]*255,0,255),math.Clamp(v[9]*255,0,255))}
    end
    local mesh=Mesh(material) mesh:BuildFromTriangles(vertices)
    result[#result+1]={mesh=mesh,mat=material,plain=plain,c=d.constants,fog=d.fog or 1,dual=#d.textures==3,
        origin=d.origin and Vector(d.origin[1],d.origin[2],d.origin[3])}
end
return result
end
draws=build(data,"held")
cache.held=draws
local function selectSample(index)
    local number=samples[index]
    if not number then return false end
    if not cache[number] then cache[number]=build(include("storm_amt_lab/captured_sample_"..number..".lua"),number) end
    draws=cache[number]
    return true
end
local function spawn(args)
    local player=LocalPlayer() if not IsValid(player) then return end
    local trace=player:GetEyeTrace()
    active={pos=trace.HitPos+trace.HitNormal*3,scale=math.Clamp(tonumber(args[1]) or .3,.01,5),
        yaw=EyeAngles().y-capturedYaw+(tonumber(args[2]) or 0),diagnostic=tonumber(args[3])==1}
    RunConsoleCommand("storm_amt_hide")
    RunConsoleCommand("storm_amt_sequence_hide")
    RunConsoleCommand("storm_amt_decoded_hide")
    return true
end
concommand.Add("storm_amt_capture",function(_,_,args)
    RunConsoleCommand("storm_amt_motion_hide")
    replay=nil draws=cache.held
    if not spawn(args) then return end
    print("GPU capture r4: "..#draws.." camera-facing billboards, held animation frame; mode="..(active.diagnostic and "base atlas diagnostic" or "captured shader").."; distance="..math.floor(EyePos():Distance(active.pos)))
end)
concommand.Add("storm_amt_capture_sample",function(_,_,args)
    RunConsoleCommand("storm_amt_motion_hide")
    local index=math.floor(tonumber(args[1]) or 4)
    if not selectSample(index) then print("Sample index must be 1 to 7") return end
    replay=nil
    if not active then spawn({args[2] or "0.3"}) end
    print("Original capture sample "..index.."/7; game frame "..samples[index].."; "..#draws.." verified draws; fixed world placement")
end)
concommand.Add("storm_amt_capture_replay",function(_,_,args)
    active=nil replay=nil
    RunConsoleCommand("storm_amt_motion",args[1] or "0.3",args[2] or "0",args[3] or "0",args[4] or "1")
end)
concommand.Add("storm_amt_capture_hide",function() active=nil replay=nil RunConsoleCommand("storm_amt_motion_hide") end)
concommand.Add("storm_amt_capture_diag",function()
    print("GPU capture r4; active="..tostring(active~=nil).."; last draw frame="..lastDrawFrame.."; current frame="..FrameNumber().."; material error="..tostring(draws[3].mat:IsError()))
    RunConsoleCommand("storm_amt_motion_diag")
end)
hook.Add("PostDrawTranslucentRenderables","StormAmaterasuCapturedGPUFrame",function(depth,sky,sky3d)
    if not active or depth or sky or sky3d then return end
    if replay then
        local frame=samples[1]+(CurTime()-replay.start)*replay.fps
        local index=1
        for i=2,#samples do if frame>=samples[i] then index=i end end
        if index~=replay.index then selectSample(index) replay.index=index end
        if frame>samples[#samples]+replay.fps*.4 then active=nil replay=nil return end
    end
    if lastDrawFrame<0 then print("GPU capture r4: render hook executed") end
    lastDrawFrame=FrameNumber()

    local matrix=Matrix() matrix:SetTranslation(active.pos) matrix:SetAngles(Angle(0,active.yaw,0))
    matrix:SetScale(Vector(active.scale,active.scale,active.scale))
    local angle=EyeAngles()
    local right,up=angle:Right(),angle:Up()
    local normal=right:Cross(up)
    for _,d in ipairs(draws) do
        local c=d.c
        local uv,scroll,film=c.g_uvScaleScreen,c.g_uvOffsetScreen,c.g_uvOffset3
        constant(d.mat,0,{uv[1]/ScrW(),-uv[2]/ScrH(),scroll[1]*uv[1],scroll[2]*uv[2]})
        constant(d.mat,1,{uv[3]/ScrW(),-uv[4]/ScrH(),scroll[3]*uv[3],scroll[4]*uv[4]})
        constant(d.mat,2,{film[1],d.dual and film[2] or 0,c.g_commonParam[1],c.g_commonParam[2]})
        -- Principal atlas draws have fog disabled in the original GPU capture.
        constant(d.mat,3,{c.g_fogColor[1],c.g_fogColor[2],c.g_fogColor[3],d.fog})
        local transform=matrix
        if d.origin then
            local offset=Vector(d.origin.x,d.origin.y,d.origin.z)
            offset:Rotate(Angle(0,active.yaw,0))
            local pos=active.pos+offset*active.scale
            transform=Matrix()
            for row=1,3 do
                transform:SetField(row,1,right[row]*active.scale)
                transform:SetField(row,2,up[row]*active.scale)
                transform:SetField(row,3,normal[row]*active.scale)
                transform:SetField(row,4,pos[row])
            end
        end
        cam.PushModelMatrix(transform)
        render.SetMaterial(active.diagnostic and d.plain or d.mat) d.mesh:Draw()
        cam.PopModelMatrix()
    end
end)
hook.Add("ShutDown","StormAmaterasuCapturedCleanup",function()
    for _,set in pairs(cache) do
        for _,d in ipairs(set) do if d.mesh:IsValid() then d.mesh:Destroy() end end
    end
end)
