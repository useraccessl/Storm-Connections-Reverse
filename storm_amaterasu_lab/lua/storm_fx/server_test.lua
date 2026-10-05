-- Unattended check of the server side of StormFX (server only, run by the generated server
-- autorun). It does nothing unless the server's data/storm_fx_selftest/server_autostart.txt
-- exists: the first player to spawn then gets the effect it names ("package/effect", default
-- 4efb_amt1_x/4efb_amt1_blt00) played on the ground in front of them three times, 6, 7 and
-- 8 seconds later, through StormFX.Play (sent to the clients by storm_fx/net.lua). The file
-- is deleted at once. Each client counts the calls it receives (STORM_FX.netCalls, written
-- in the report of storm_fx_selftest).
local PATH='storm_fx_selftest/server_autostart.txt'
hook.Add('PlayerInitialSpawn','StormFxServerTest',function(ply)
    if not file.Exists(PATH,'DATA') then hook.Remove('PlayerInitialSpawn','StormFxServerTest') return end
    local name=string.Trim(file.Read(PATH,'DATA') or '')
    file.Delete(PATH)
    hook.Remove('PlayerInitialSpawn','StormFxServerTest')
    if name=='' then name='4efb_amt1_x/4efb_amt1_blt00' end
    for k=0,2 do
        timer.Simple(6+k,function()
            if not IsValid(ply) or not StormFX or not StormFX.Play then return end
            local forward=ply:GetAimVector() forward.z=0 forward:Normalize()
            local above=ply:GetPos()+forward*250+Vector(0,0,100)
            local ground=util.TraceLine({start=above,endpos=above-Vector(0,0,600),mask=MASK_SOLID_BRUSHONLY})
            StormFX.Play(name,ground.Hit and ground.HitPos or above,Angle(0,ply:EyeAngles().y,0))
            print(string.format('StormFX server test: %s sent to the clients (%d/3)',name,k+1))
        end)
    end
end)
