-- Console commands of the engine: play, cast, list what a package holds, stop, and the
-- diagnostics.

local ENGINE = StormFX.Engine

-- storm_fx_cast <package> [script] [scale] [seed]: cast a script from in front of the player
concommand.Add("storm_fx_cast", function(_, _, tArgs)

    if not tArgs[1] then
        print("storm_fx_cast <package> [script] [scale] [seed]")
        return
    end

    local sSkillId = tArgs[2] ~= "" and tArgs[2] ~= "-" and tArgs[2] or nil

    ENGINE:CastFromPlayer(tArgs[1], sSkillId, tonumber(tArgs[3]), tonumber(tArgs[4]))

end)

-- storm_fx_play <package> <effect> [scale] [seed]: play one effect where the player aims
concommand.Add("storm_fx_play", function(_, _, tArgs)

    local pPlayer = LocalPlayer()

    if not IsValid(pPlayer) then return end

    if not tArgs[2] then
        print("storm_fx_play <package> <effect> [scale] [seed]")
        return
    end

    local tAim = pPlayer:GetEyeTrace()

    ENGINE:StopAll()

    -- A stationary identity root at the aim point: the effect's own attachments place
    -- everything relative to it
    local tOuter = {pos = tAim.HitPos, yaw = EyeAngles().y, scale = math.Clamp(tonumber(tArgs[3]) or 1, 0.01, 5)}
    local tInstance, sWhy = ENGINE:PlayEffect(tArgs[1], tArgs[2], tOuter, tonumber(tArgs[4]) or 1)

    if not tInstance then
        print("Storm FX: " .. tostring(sWhy))
    end

end)

-- storm_fx_list <package>: the scripts, effects and what could not be imported
concommand.Add("storm_fx_list", function(_, _, tArgs)

    if not tArgs[1] then
        print("storm_fx_list <package>")
        return
    end

    local tRuntime = ENGINE:LoadPackage(tArgs[1])

    print("Scripts (roots first): " .. table.concat(ENGINE:RootScripts(tArgs[1]), ", "))

    for sId, tScript in pairs(tRuntime.data.skills) do
        for _, tAction in ipairs(tScript.actions) do
            print("  " .. sId .. " action " .. tostring(tAction.id) .. " " .. tostring(tAction.type) .. " animation "
                .. tostring(ENGINE.ActionParameter(tAction, "Animation", "chunk")))
        end
    end

    for sName, tEmitters in pairs(tRuntime.data.effects) do
        print("Effect " .. sName .. ": " .. #tEmitters .. " emitters")
    end

    for sName, sWhy in pairs(tRuntime.unsupported) do
        print("No renderer for model " .. sName .. ": " .. sWhy)
    end

    for _, tEntry in ipairs(tRuntime.data.unsupported) do
        print("Not imported: " .. tEntry.what .. " (" .. tEntry.reason .. ")")
    end

end)

concommand.Add("storm_fx_stop", function()
    ENGINE:StopAll()
end)

-- storm_fx_exact 0|1: float32 rounding as the game (slower) or doubles
concommand.Add("storm_fx_exact", function(_, _, tArgs)

    ENGINE:SetExact(tonumber(tArgs[1]) == 1)

    print("Storm FX float32 rounding: " .. (ENGINE:IsExact() and "on (as the game, slower)" or "off (doubles)"))

end)

-- storm_fx_tone 0|1|2: the stage's tone pass off, on the effects' pixels, on the whole screen
concommand.Add("storm_fx_tone", function(_, _, tArgs)

    ENGINE.iToneMode = math.Clamp(math.floor(tonumber(tArgs[1]) or 0), 0, 2)

    local tModes = {[0] = "off", "on the effect pixels", "on the whole screen while an effect plays"}

    print("Storm FX stage tone control: " .. tModes[ENGINE.iToneMode])

end)

-- storm_fx_diag: what plays, what it costs, and what could not be played
concommand.Add("storm_fx_diag", function()

    print("Storm FX " .. ENGINE.sVersion .. ": " .. #ENGINE.tInstances .. " effects running")

    for _, tInstance in ipairs(ENGINE.tInstances) do

        print("  " .. tInstance.effect .. " frame=" .. tInstance.frame .. " particles=" .. (tInstance.scene and #tInstance.scene.particles or 0))

        if tInstance.scene then
            for sName, iCount in pairs(tInstance.scene.births) do
                print("    born: " .. sName .. " " .. iCount)
            end
        end

        for _, tSet in ipairs(tInstance.trailSets or {}) do

            for _, tTrail in ipairs(tSet.trails) do

                local sOwner = tSet.released and "released" or (tSet.particle and "on a particle" or "on the effect")

                print(string.format("    trail %s#%d: %s, %d samples, %d points, alpha %.2f%s", tTrail.def.animation or "?", tTrail.def.index,
                    sOwner, #tTrail.state.samples, #tTrail.state.points, tTrail.state.alpha,
                    tTrail.missing and " (an edge is not in the animation: inert)" or ""))

            end

        end

    end

    print(string.format("CPU: simulation %.3f ms; render %.3f ms (draw list %.3f ms, %d views: %s); draws %d a view; total mesh uploads %d; vertices skinned last frame %d",
        ENGINE.flUpdateMs, ENGINE.flRenderMs, ENGINE.flBuildMs, ENGINE.iCalls, table.concat(ENGINE.tViews, ", "), ENGINE.iDraws,
        ENGINE.iUploads, ENGINE.iSkinnedVertices))

    for iIndex, tLight in ipairs(ENGINE.tLights) do
        print(string.format("  light %d (%s): colour %.2f %.2f %.2f intensity %.2f radii %.0f / %.0f%s", iIndex, tLight.effect,
            tLight.color[1], tLight.color[2], tLight.color[3], tLight.intensity, tLight.near, tLight.far,
            iIndex > 4 and " (beyond the four the game looks at)" or ""))
    end

    for _, tCast in ipairs(ENGINE.tCasts) do
        for _, sLine in ipairs(tCast.log) do
            print("  script: " .. sLine)
        end
    end

    for sName, iCount in pairs(ENGINE.tSkipped) do
        print("Not rendered: " .. sName .. " (" .. iCount .. " latest frame)")
    end

    for sName, sWhy in pairs(ENGINE.tFailed) do
        print("Effect dropped: " .. sName .. " (" .. sWhy .. ")")
    end

end)
