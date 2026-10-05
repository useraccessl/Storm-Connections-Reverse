-- StormFX over the network (shared). The effects are drawn by each client's engine; on the
-- server, StormFX.Play / Cast / StopAll send the call to the clients (all of them, or
-- opts.filter: a player, a table of players or a CRecipientFilter), as ParticleEffect does.
--   StormFX.Play(name, pos, ang, {scale, seed, parent, attachment, filter})
--   StormFX.Cast(name, origin, target, {scale, seed, filter})
--   StormFX.StopAll([filter])
if not net then return end          -- offline harnesses have no net library
if SERVER then
    util.AddNetworkString('storm_fx_call')
    StormFX=StormFX or {}
    local function send(kind,name,a,b,opts)
        opts=opts or {}
        net.Start('storm_fx_call')
        net.WriteUInt(kind,2)
        net.WriteString(name or '')
        net.WriteVector(a or vector_origin)
        if kind==2 then net.WriteVector(b or vector_origin) else net.WriteAngle(b or angle_zero) end
        net.WriteFloat(opts.scale or 0)
        net.WriteUInt(opts.seed or 1,16)
        net.WriteEntity(opts.parent or NULL)
        net.WriteString(opts.attachment and tostring(opts.attachment) or '')
        if opts.filter then net.Send(opts.filter) else net.Broadcast() end
    end
    function StormFX.Play(name,pos,ang,opts) send(1,name,pos,ang,opts) end
    function StormFX.Cast(name,origin,target,opts) send(2,name,origin,target,opts) end
    function StormFX.StopAll(filter) send(3,'',nil,nil,{filter=filter}) end
    return
end

net.Receive('storm_fx_call',function()
    local kind=net.ReadUInt(2)
    local name=net.ReadString()
    local a=net.ReadVector()
    local b=kind==2 and net.ReadVector() or net.ReadAngle()
    local scale,seed=net.ReadFloat(),net.ReadUInt(16)
    local parent,attachment=net.ReadEntity(),net.ReadString()
    if STORM_FX then STORM_FX.netCalls,STORM_FX.lastNetCall=(STORM_FX.netCalls or 0)+1,name end
    if not StormFX or not StormFX.Play then return end
    local opts={scale=scale>0 and scale or nil,seed=seed,parent=IsValid(parent) and parent or nil,
        attachment=attachment~='' and (tonumber(attachment) or attachment) or nil}
    if kind==1 then StormFX.Play(name,a,b,opts)
    elseif kind==2 then StormFX.Cast(name,a,b,opts)
    else StormFX.StopAll() end
end)
