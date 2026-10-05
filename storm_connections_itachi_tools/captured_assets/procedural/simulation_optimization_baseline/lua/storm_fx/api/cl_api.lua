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
--   ang: the effect faces its forward (Angle; nil = angle_zero), as ParticleEffect.
--   tOptions.scale: game units to Source units (default StormFX.Config["scale"], a character's
--     height); tOptions.seed: random seed of the emitters (default 1);
--   tOptions.parent: an entity the effect follows (position and angles, every update), as
--     ParticleEffectAttach; the effect goes with it (tOptions.fade: it ends as the game ends it
--     instead); tOptions.attachment: an attachment id or name of the parent to follow instead;
--   tOptions.duration: seconds after which the effect ends as the game ends it (Stop): a
--     looping effect (a held Rasengan, a projectile) otherwise plays until stopped or removed.
-- Stop lets the effect end as the game ends it (emission stops, particles and trails fade);
-- Remove takes it away at once.
-- Cast: a skill script of a package launched from origin toward target (Vectors), with its
-- motion (projectile, crawler...) and the effects its events chain; returns the cast.
-- On the server the same calls are sent to the clients (api/sv_network.lua).

local ENGINE = StormFX.Engine

-- A failure is printed once per name and reason (a missing package would otherwise print at
-- every call)
local tReported = {}

local function fnReport(sWhat, sName, sWhy)

    local sText = sWhat .. " " .. tostring(sName) .. ": " .. tostring(sWhy)

    if tReported[sText] then return end

    tReported[sText] = true
    print(sText)

end

-- "package/effect" -> package, effect
local function fnSplit(sName)

    local sPackage, sItem = tostring(sName):match("^([^/:]+)[/:](.+)$")

    if not sPackage then
        error("StormFX: name \"package/effect\" expected, got " .. tostring(sName), 3)
    end

    return sPackage, sItem

end

-- The game's effects face along their local -y (a projectile flies that way): an effect
-- played with an angle faces that angle's forward, as ParticleEffect does. The yaw goes to
-- the outer transform with the quarter turn that brings -y onto +x; pitch and roll go to the
-- root matrix, in the game space of that outer transform.
local YAW_TO_FORWARD = 90

-- The root matrix for an angle: turn(-(yaw + 90)) x angle x turn(90), identity without pitch
-- or roll
local function fnRootOf(angAngles)

    if angAngles.p == 0 and angAngles.r == 0 then
        return {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}
    end

    -- VMatrix:Rotate post-multiplies
    local mRotation = Matrix()
    mRotation:Rotate(Angle(0, -(angAngles.y + YAW_TO_FORWARD), 0))
    mRotation:Rotate(angAngles)
    mRotation:Rotate(Angle(0, YAW_TO_FORWARD, 0))

    local tRows = mRotation:ToTable()

    return {
        tRows[1][1], tRows[1][2], tRows[1][3], 0,
        tRows[2][1], tRows[2][2], tRows[2][3], 0,
        tRows[3][1], tRows[3][2], tRows[3][3], 0,
        0, 0, 0, 1
    }

end

-- Face an effect along an angle
local function fnPlace(tInstance, angAngles)

    tInstance.outer.yaw = angAngles.y + YAW_TO_FORWARD
    tInstance.root = fnRootOf(angAngles)

end

-- The handle StormFX.Play returns
local HANDLE = {}
HANDLE.__index = HANDLE

function HANDLE:IsValid()
    return self.instance ~= nil and not self.instance.finished
end

-- Let the effect end as the game ends it
function HANDLE:Stop()

    if self.instance then
        self.instance.killed = true
    end

end

-- Take the effect away at once (the engine drops it before its next update or draw)
function HANDLE:Remove()

    if self.instance then
        self.instance.removed = true
        self.instance.finished = true
    end

end

function HANDLE:SetPos(vecPos)

    if self.instance then
        self.instance.outer.pos = Vector(vecPos)
    end

end

function HANDLE:SetAngles(angAngles)

    if self.instance then
        fnPlace(self.instance, angAngles)
    end

end

-- Seconds a parent sent by the server may take to reach this client
local PARENT_WAIT = 2

-- Follow a parent entity (or one of its attachments) before every update of the effect. The
-- parent is the entity, or its index when the server sent it (it may not have reached this
-- client yet: looked up until it does). When the parent goes away the effect goes at once,
-- or ends as the game ends it with bFade.
local function fnFollow(tHandle, eParent, iParent, attachment, bFade)

    local tInstance = tHandle.instance
    local fnOwn = tInstance.beforeUpdate
    local bSeen = false
    local flWaitUntil = CurTime() + PARENT_WAIT

    tInstance.beforeUpdate = function(tUpdated)

        if not IsValid(eParent) and iParent and not bSeen then
            eParent = Entity(iParent)
        end

        if not IsValid(eParent) then

            -- Not arrived yet: the effect waits where it was played
            if not bSeen and CurTime() < flWaitUntil then

                if fnOwn then
                    fnOwn(tUpdated)
                end

                return

            end

            if bFade then
                tUpdated.killed = true
            else
                tUpdated.removed = true
                tUpdated.finished = true
            end

        else

            bSeen = true

            -- Read by the drawing: a parent out of this client's PVS (dormant) hides the effect
            tUpdated.parentEntity = eParent

            local vecPos, angAngles = eParent:GetPos(), eParent:GetAngles()

            if attachment then

                local iAttachment = isnumber(attachment) and attachment or eParent:LookupAttachment(attachment)
                local tAttachment = iAttachment and iAttachment > 0 and eParent:GetAttachment(iAttachment)

                if tAttachment then
                    vecPos, angAngles = tAttachment.Pos, tAttachment.Ang
                end

            end

            tUpdated.outer.pos = vecPos
            fnPlace(tUpdated, angAngles)

        end

        if fnOwn then
            fnOwn(tUpdated)
        end

    end

end

-- Load a package now
function StormFX.Precache(sPackage)

    local bOk, tRuntime = pcall(ENGINE.LoadPackage, ENGINE, sPackage)

    if not bOk then
        fnReport("StormFX.Precache", sPackage, tRuntime)
        return false
    end

    return tRuntime ~= nil

end

-- Every package found loaded once the map has loaded, and its meshes built at the default
-- scale (Config precacheAll): the first effect of a package then costs nothing more
hook.Add("InitPostEntity", "StormFX:Api:InitPostEntity", function()

    if not StormFX.Config["precacheAll"] or not file.Find then return end

    local tFiles = file.Find("data_static/storm_fx/*.txt", "GAME") or {}

    for _, sFile in ipairs(tFiles) do

        local sPackage = sFile:gsub("%.txt$", "")

        -- Its one-shot effects recorded in the background (Config prerecord): they are read
        -- back, not simulated, from their first play on
        if StormFX.Precache(sPackage) and StormFX.Config["prerecord"] ~= false then
            ENGINE:QueuePrerecord(sPackage)
        end

    end

    if #tFiles > 0 then
        ENGINE:Begin(StormFX.Config["scale"])
    end

end)

-- Play one effect: "package/effect", at vecPos, with angAngles; returns a handle or nil
function StormFX.Play(sName, vecPos, angAngles, tOptions)

    tOptions = tOptions or {}
    angAngles = angAngles or angle_zero

    local sPackage, sEffect = fnSplit(sName)
    local tOuter = {pos = Vector(vecPos), yaw = angAngles.y + YAW_TO_FORWARD, scale = tOptions.scale or StormFX.Config["scale"]}
    local bOk, tInstance, sWhy = pcall(ENGINE.PlayEffect, ENGINE, sPackage, sEffect, tOuter, tOptions.seed or 1, fnRootOf(angAngles))

    if not bOk or not tInstance then
        fnReport("StormFX.Play", sName, bOk and sWhy or tInstance)
        return nil
    end

    fnPlace(tInstance, angAngles)

    local tHandle = setmetatable({instance = tInstance, name = sName}, HANDLE)

    if tOptions.parent or tOptions.parentIndex then
        fnFollow(tHandle, tOptions.parent, tOptions.parentIndex, tOptions.attachment, tOptions.fade)
    end

    -- Ended as the game ends it after this many seconds (a looping effect plays until then)
    if tOptions.duration and tOptions.duration > 0 then
        tInstance.stopAt = CurTime() + tOptions.duration
    end

    return tHandle

end

-- Cast a skill script: "package/script", from vecOrigin toward vecTarget; returns the cast or nil
function StormFX.Cast(sName, vecOrigin, vecTarget, tOptions)

    tOptions = tOptions or {}

    local sPackage, sScript = fnSplit(sName)

    local bOk, tCast, sWhy = pcall(ENGINE.CastSkill, ENGINE, sPackage, sScript, {
        origin = Vector(vecOrigin),
        target = Vector(vecTarget),
        scale = tOptions.scale or StormFX.Config["scale"],
        seed = tOptions.seed or 1
    })

    if not bOk or not tCast then
        fnReport("StormFX.Cast", sName, bOk and sWhy or tCast)
        return nil
    end

    return tCast

end

-- Stop every effect and skill script
function StormFX.StopAll()
    ENGINE:StopAll()
end

-- The effect animations of a package, sorted
function StormFX.Effects(sPackage)

    local tRuntime = ENGINE:LoadPackage(sPackage)
    local tEffects = {}

    for sEffect in pairs(tRuntime.data.animations) do
        tEffects[#tEffects + 1] = sEffect
    end

    table.sort(tEffects)

    return tEffects

end

-- The root scripts of a package, sorted
function StormFX.Scripts(sPackage)
    return ENGINE:RootScripts(sPackage)
end
