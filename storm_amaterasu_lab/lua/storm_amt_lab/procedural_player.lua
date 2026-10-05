-- Amaterasu shortcuts over the generic player (storm_fx/player.lua).
-- The engine and the data are generic; these commands only name the package
-- storm_import.py writes for data/skill/4efb_amt1_x.xfbin.
local fxPlayer=include('storm_fx/player.lua')
local PACKAGE='4efb_amt1_x'
STORM_AMATERASU_PROCEDURAL=fxPlayer
concommand.Add('storm_amt_skill',function(_,_,args)
    fxPlayer.castFromPlayer(PACKAGE,'4efb_amt1_e_begin00',tonumber(args[1]),tonumber(args[2]))
end)
concommand.Add('storm_amt_procedural',function(_,_,args)
    local player=LocalPlayer() if not IsValid(player) then return end
    local trace=player:GetEyeTrace()
    fxPlayer.stop()
    local instance,why=fxPlayer.play(PACKAGE,args[3]=='blt' and '4efb_amt1_blt00' or '4efb_amt1_hit00',
        {pos=trace.HitPos,yaw=EyeAngles().y,scale=math.Clamp(tonumber(args[1]) or 1,.01,5)},tonumber(args[2]) or 1)
    if not instance then print('Storm FX: '..tostring(why)) end
end)
concommand.Add('storm_amt_procedural_hide',function() fxPlayer.stop() end)
concommand.Add('storm_amt_procedural_diag',function() RunConsoleCommand('storm_fx_diag') end)
