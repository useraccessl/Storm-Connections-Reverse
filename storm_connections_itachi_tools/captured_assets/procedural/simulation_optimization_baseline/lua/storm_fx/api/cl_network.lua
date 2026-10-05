-- The calls the server sends (api/sv_network.lua), played by this client's engine.

local CALL_PLAY = 1
local CALL_CAST = 2

net.Receive("StormFX:Call", function()

    local iKind = net.ReadUInt(2)
    local sName = net.ReadString()
    local vecA = net.ReadVector()
    local b = iKind == CALL_CAST and net.ReadVector() or net.ReadAngle()
    local flScale, iSeed = net.ReadFloat(), net.ReadUInt(16)
    local iParent, sAttachment = net.ReadUInt(16), net.ReadString()
    local bFade = net.ReadBool()
    local flDuration = net.ReadFloat()

    local ENGINE = StormFX.Engine

    ENGINE.iNetCalls = ENGINE.iNetCalls + 1
    ENGINE.sLastNetCall = sName

    local tOptions = {
        scale = flScale > 0 and flScale or nil,
        seed = iSeed,

        -- The parent may not have reached this client yet: StormFX.Play looks it up by index
        parentIndex = iParent > 0 and iParent or nil,
        attachment = sAttachment ~= "" and (tonumber(sAttachment) or sAttachment) or nil,
        fade = bFade,
        duration = flDuration > 0 and flDuration or nil
    }

    if iKind == CALL_PLAY then
        StormFX.Play(sName, vecA, b, tOptions)
    elseif iKind == CALL_CAST then
        StormFX.Cast(sName, vecA, b, tOptions)
    else
        StormFX.StopAll()
    end

end)
