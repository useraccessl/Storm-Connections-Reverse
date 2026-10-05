-- Unattended check of the server side of StormFX. It does nothing unless the server's
-- data/storm_fx_selftest/server_autostart.txt exists: the first player to spawn then gets the
-- effect it names ("package/effect", default 4efb_amt1_x/4efb_amt1_blt00) played on the ground
-- in front of them three times, 6, 7 and 8 seconds later, through StormFX.Play (sent to the
-- clients by api/sv_network.lua). The file is deleted at once. Each client counts the calls it
-- receives (StormFX.Engine.iNetCalls, written in the report of storm_fx_selftest).

local FLAG = "storm_fx_selftest/server_autostart.txt"
local HOOK = "StormFX:SelfTest:PlayerInitialSpawn"

hook.Add("PlayerInitialSpawn", HOOK, function(pPlayer)

    hook.Remove("PlayerInitialSpawn", HOOK)

    if not file.Exists(FLAG, "DATA") then return end

    local sName = string.Trim(file.Read(FLAG, "DATA") or "")
    file.Delete(FLAG)

    if sName == "" then
        sName = "4efb_amt1_x/4efb_amt1_blt00"
    end

    for i = 1, 3 do

        timer.Simple(5 + i, function()

            if not IsValid(pPlayer) or not StormFX.Play then return end

            local vecForward = pPlayer:GetAimVector()
            vecForward.z = 0
            vecForward:Normalize()

            local vecAbove = pPlayer:GetPos() + vecForward * 250 + Vector(0, 0, 100)
            local tGround = util.TraceLine({start = vecAbove, endpos = vecAbove - Vector(0, 0, 600), mask = MASK_SOLID_BRUSHONLY})

            StormFX.Play(sName, tGround.Hit and tGround.HitPos or vecAbove, Angle(0, pPlayer:EyeAngles().y, 0))

            print(string.format("StormFX server test: %s sent to the clients (%d/3)", sName, i))

        end)

    end

end)
