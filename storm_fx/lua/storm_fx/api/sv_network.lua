-- StormFX on the server. The effects are drawn by each client's engine: StormFX.Play / Cast
-- send the call to the players who can see the place it plays at (its PVS: the parent's
-- position for an effect that follows one); a player elsewhere (another skybox, far across
-- the map) gets nothing, simulates nothing. A player who comes into view of it later does not
-- get it either. tOptions.filter (a player, a table of players or a CRecipientFilter) chooses
-- the players instead, tOptions.everyone sends it to all. StopAll goes to all (or its filter).
--   StormFX.Play(sName, vecPos, angAngles, {scale, seed, parent, attachment, fade, duration, filter, everyone})
--   StormFX.Cast(sName, vecOrigin, vecTarget, {scale, seed, filter, everyone})
--   StormFX.StopAll([filter])

util.AddNetworkString("StormFX:Call")

-- The kinds of call
local CALL_PLAY = 1
local CALL_CAST = 2
local CALL_STOP_ALL = 3

-- Send one call to the clients
local function fnSend(iKind, sName, vecA, b, tOptions)

    tOptions = tOptions or {}

    net.Start("StormFX:Call")
    net.WriteUInt(iKind, 2)
    net.WriteString(sName or "")
    net.WriteVector(vecA or vector_origin)

    if iKind == CALL_CAST then
        net.WriteVector(b or vector_origin)
    else
        net.WriteAngle(b or angle_zero)
    end

    net.WriteFloat(tOptions.scale or 0)
    net.WriteUInt(tOptions.seed or 1, 16)

    -- The parent goes as its index: an entity made this tick reaches the clients after this
    -- message, the client looks it up until it arrives
    net.WriteUInt(IsValid(tOptions.parent) and tOptions.parent:EntIndex() or 0, 16)
    net.WriteString(tOptions.attachment and tostring(tOptions.attachment) or "")
    net.WriteBool(tOptions.fade == true)
    net.WriteFloat(tOptions.duration or 0)

    if tOptions.filter then
        net.Send(tOptions.filter)
    elseif tOptions.everyone or iKind == CALL_STOP_ALL then
        net.Broadcast()
    else
        net.SendPVS(IsValid(tOptions.parent) and tOptions.parent:GetPos() or vecA or vector_origin)
    end

end

function StormFX.Play(sName, vecPos, angAngles, tOptions)
    fnSend(CALL_PLAY, sName, vecPos, angAngles, tOptions)
end

function StormFX.Cast(sName, vecOrigin, vecTarget, tOptions)
    fnSend(CALL_CAST, sName, vecOrigin, vecTarget, tOptions)
end

function StormFX.StopAll(filter)
    fnSend(CALL_STOP_ALL, "", nil, nil, {filter = filter})
end
