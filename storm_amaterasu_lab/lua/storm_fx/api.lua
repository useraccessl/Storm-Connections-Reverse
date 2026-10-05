-- StormFX: the public interface of the engine (client), in the manner of ParticleEffect.
--
--   StormFX.Precache("4efb_amt1_x")                         load a package now (it is large:
--                                                           better at map start than at first use)
--   local fx = StormFX.Play("4efb_amt1_x/4efb_amt1_hit00", pos, ang, {scale = 1, parent = ent})
--   fx:IsValid()  fx:Stop()  fx:Remove()  fx:SetPos(v)  fx:SetAngles(a)
--   StormFX.Cast("4efb_amt1_x/4efb_amt1_e_begin00", origin, target)   a whole skill script chain
--   StormFX.StopAll()
--   StormFX.Effects("4efb_amt1_x"), StormFX.Scripts("4efb_amt1_x")      names a package holds
--
-- Play: one effect animation of a package, its emitters, models and trails, at pos.
--   ang: yaw, pitch and roll of the effect (Angle; nil = angle_zero).
--   opts.scale: game units to Source units (default: the engine's 64 / 119, a character's
--     height); opts.seed: random seed of the emitters (default 1);
--   opts.parent: an entity the effect follows (position and angles, every update);
--     opts.attachment: an attachment id or name of the parent to follow instead.
-- Stop lets the effect end as the game ends it (emission stops, particles and trails fade);
-- Remove takes it away at once.
-- Cast: a skill script of a package launched from origin toward target (Vectors), with its
-- motion (projectile, crawler...) and the effects its events chain; returns the cast.
-- On the server the same calls are sent to the clients (storm_fx/net.lua).
local P=assert(STORM_FX,'storm_fx/player.lua defines STORM_FX first')
StormFX=StormFX or {}
local S=StormFX
S.engine=P

-- A failure is printed once per name and reason (a missing package would otherwise print
-- at every call).
local reported={}
local function report(what,name,why)
    local text=what..' '..tostring(name)..': '..tostring(why)
    if reported[text] then return end
    reported[text]=true
    print(text)
end

local function split(name)
    local package,item=tostring(name):match('^([^/:]+)[/:](.+)$')
    if not package then error('StormFX: name "package/effect" expected, got '..tostring(name),3) end
    return package,item
end

function S.Precache(package)
    local ok,runtime=pcall(P.load,package)
    if not ok then report('StormFX.Precache',package,runtime) return false end
    return runtime~=nil
end

-- Root matrix of the effect in game space for an angle's pitch and roll (the yaw goes
-- to the outer transform, which also takes the position and the scale).
local function rootOf(ang)
    if not ang or (ang.p==0 and ang.r==0) then return nil end
    local m=Matrix()
    m:Rotate(Angle(ang.p,0,ang.r))
    local t=m:ToTable()
    return {t[1][1],t[1][2],t[1][3],0,t[2][1],t[2][2],t[2][3],0,t[3][1],t[3][2],t[3][3],0,0,0,0,1}
end

local Handle={}
Handle.__index=Handle
function Handle:IsValid() return self.instance~=nil and not self.instance.finished end
function Handle:Stop() if self.instance then self.instance.killed=true end end
function Handle:Remove()
    local a=self.instance
    if not a then return end
    for i,b in ipairs(P.instances) do if b==a then table.remove(P.instances,i) break end end
    a.finished=true
end
function Handle:SetPos(pos) if self.instance then self.instance.outer.pos=Vector(pos) end end
function Handle:SetAngles(ang)
    local a=self.instance
    if not a then return end
    a.outer.yaw=ang.y
    a.root=rootOf(ang) or a.root
end

-- Follow a parent entity (or one of its attachments) before every update of the effect.
local function follow(handle,parent,attachment)
    local a=handle.instance
    local own=a.beforeUpdate
    a.beforeUpdate=function(instance)
        if IsValid(parent) then
            local pos,ang=parent:GetPos(),parent:GetAngles()
            if attachment then
                local id=isnumber(attachment) and attachment or parent:LookupAttachment(attachment)
                local at=id and id>0 and parent:GetAttachment(id)
                if at then pos,ang=at.Pos,at.Ang end
            end
            instance.outer.pos=pos
            instance.outer.yaw=ang.y
            instance.root=rootOf(ang) or instance.root
        else
            instance.killed=true
        end
        if own then own(instance) end
    end
end

function S.Play(name,pos,ang,opts)
    opts=opts or {}
    local package,effect=split(name)
    ang=ang or angle_zero
    local outer={pos=Vector(pos),yaw=ang.y,scale=opts.scale or P.host.scale}
    local ok,instance,why=pcall(P.play,package,effect,outer,opts.seed or 1)
    if not ok or not instance then
        report('StormFX.Play',name,ok and why or instance)
        return nil
    end
    instance.root=rootOf(ang) or instance.root
    local handle=setmetatable({instance=instance,name=name},Handle)
    if opts.parent then follow(handle,opts.parent,opts.attachment) end
    return handle
end

function S.Cast(name,origin,target,opts)
    opts=opts or {}
    local package,script=split(name)
    local ok,cast,why=pcall(P.cast,package,script,{origin=Vector(origin),target=Vector(target),
        scale=opts.scale or P.host.scale,seed=opts.seed or 1})
    if not ok or not cast then report('StormFX.Cast',name,ok and why or cast) return nil end
    return cast
end

function S.StopAll() P.stop() end

function S.Effects(package)
    local runtime=P.load(package)
    local out={}
    for effect in pairs(runtime.data.animations) do out[#out+1]=effect end
    table.sort(out)
    return out
end

function S.Scripts(package) return P.roots(package) end

-- The server side of these calls (and their client receiver).
include('storm_fx/net.lua')
