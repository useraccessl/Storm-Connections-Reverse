-- The stage's tone control as a screen pass (optional, storm_fx_tone). In the game it is the
-- first pass of the post chain (pixel shader 81206c57, constants paramR / paramG / paramB /
-- hparam / lparam, the same in the seven Amaterasu captures: they belong to the stage, not
-- to the skill). The translated shader storm_tone_ps30 is checked against the game's output
-- by verify_tone_control.py; the glare and soft-focus passes that follow are not ported.

StormFX.StagePost = StormFX.StagePost or {}

local STAGE_POST = StormFX.StagePost

local AXES = {"x", "y", "z", "w"}

-- The pass's constants: tTone {paramR, paramG, paramB, hparam, lparam}, the screen size
function STAGE_POST.Pack(tTone, iWidth, iHeight)

    return {
        {tTone.paramR[1], tTone.paramG[2], tTone.paramB[3], tTone.lparam[4]},
        {tTone.lparam[1], tTone.lparam[2], tTone.lparam[3], 0},
        {tTone.hparam[1], tTone.hparam[2], tTone.hparam[3], 0},
        {1 / iWidth, 1 / iHeight, 0, 0}
    }

end

-- The pass's material
function STAGE_POST.Material(sName)

    return CreateMaterial(sName, "screenspace_general", {
        ["$pixshader"] = "storm_tone_ps30",
        ["$basetexture"] = "_rt_FullFrameFB",
        ["$linearread_basetexture"] = "1",
        ["$linearwrite"] = "1",
        ["$copyalpha"] = "0",
        ["$alpha_blend"] = "0",
        ["$writealpha"] = "0",
        ["$depthtest"] = "0",
        ["$writedepth"] = "0"
    })

end

-- Mark the pixels of the draws that follow with stencil value 1
function STAGE_POST.BeginMask()

    render.ClearStencil()
    render.SetStencilEnable(true)
    render.SetStencilWriteMask(255)
    render.SetStencilTestMask(255)
    render.SetStencilReferenceValue(1)
    render.SetStencilCompareFunction(STENCIL_ALWAYS)
    render.SetStencilPassOperation(STENCIL_REPLACE)
    render.SetStencilFailOperation(STENCIL_KEEP)
    render.SetStencilZFailOperation(STENCIL_KEEP)

end

-- Stop marking
function STAGE_POST.EndMask()
    render.SetStencilEnable(false)
end

-- Run the pass over a fresh copy of the frame: on the marked pixels when bMasked, on the
-- whole screen otherwise
function STAGE_POST.Draw(matTone, tPacked, bMasked)

    render.UpdateScreenEffectTexture()

    for n = 0, 3 do

        local tValues = tPacked[n + 1]

        for i = 1, 4 do
            matTone:SetFloat("$c" .. n .. "_" .. AXES[i], tValues[i])
        end

    end

    if bMasked then
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
    end

    render.SetMaterial(matTone)
    render.DrawScreenQuad()

    if bMasked then
        render.SetStencilEnable(false)
    end

end

return STAGE_POST
