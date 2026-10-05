-- Storm Connections stage tone control as a GMod screen pass.
-- Game side: first pass of the post chain, pixel shader 81206c57, constants
-- paramR / paramG / paramB / hparam / lparam. They did not change over the
-- seven Amaterasu captures: they belong to the stage, not to the skill.
-- The translated shader storm_tone_ps30 is checked against the game's own
-- output by verify_tone_control.py. The glare and soft-focus passes that follow
-- in the game are not ported.
local S={}
-- tone: {paramR, paramG, paramB, hparam, lparam} as four-float lists.
function S.pack(tone,width,height)
    return {{tone.paramR[1],tone.paramG[2],tone.paramB[3],tone.lparam[4]},
        {tone.lparam[1],tone.lparam[2],tone.lparam[3],0},
        {tone.hparam[1],tone.hparam[2],tone.hparam[3],0},
        {1/width,1/height,0,0}}
end
function S.material(name)
    return CreateMaterial(name,'screenspace_general',{['$pixshader']='storm_tone_ps30',
        ['$basetexture']='_rt_FullFrameFB',['$linearread_basetexture']='1',['$linearwrite']='1',
        ['$x360appchooser']='1',['$copyalpha']='0',['$alpha_blend']='0',['$writealpha']='0',
        ['$depthtest']='0',['$writedepth']='0'})
end
local AXES={'x','y','z','w'}
-- Marks the pixels of the draws that follow with stencil value 1.
function S.beginMask()
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
function S.endMask() render.SetStencilEnable(false) end
-- Runs the tone pass over a fresh copy of the frame: on the masked pixels when
-- masked is true, on the whole screen otherwise.
function S.draw(material,packed,masked)
    render.UpdateScreenEffectTexture()
    for n=0,3 do local v=packed[n+1]
        for i=1,4 do material:SetFloat('$c'..n..'_'..AXES[i],v[i]) end
    end
    if masked then
        render.SetStencilEnable(true)
        render.SetStencilReferenceValue(1)
        render.SetStencilCompareFunction(STENCIL_EQUAL)
        render.SetStencilPassOperation(STENCIL_KEEP)
    end
    render.SetMaterial(material)
    render.DrawScreenQuad()
    if masked then render.SetStencilEnable(false) end
end
return S
