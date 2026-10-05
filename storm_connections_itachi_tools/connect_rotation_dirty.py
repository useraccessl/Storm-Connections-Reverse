from pathlib import Path
p=Path('particle_matrix_core.lua');s=p.read_text(encoding='utf-8-sig')
s=s.replace('-- Caller provides recovered fields, not fitted geometry.', '''-- +178 dirties cached Euler +154. Original angles are quantized only here.
function P.prepareRotation(state,f,sinf,cosf)
    assert(type(state.rotationDirty)=='boolean','Original rotation dirty flag required')
    if state.rotationDirty then
        for i=1,3 do state.angles[i]=P.wrapAngle(state.angles[i],f) end
        state.cachedEuler=P.euler(state.angles,f,sinf,cosf)
        state.rotationDirty=false
    end
end
-- Caller provides recovered fields, not fitted geometry.''')
s=s.replace('if state.angles[1]~=0 or state.angles[2]~=0 or state.angles[3]~=0 then\n        out=P.rightBasis(out,P.euler(state.angles,f,sinf,cosf),f)', "P.prepareRotation(state,f,sinf,cosf)\n    if state.angles[1]~=0 or state.angles[2]~=0 or state.angles[3]~=0 then\n        out=P.rightBasis(out,assert(state.cachedEuler,'Original cached Euler basis required'),f)")
p.write_text(s,encoding='utf-8');Path('../storm_amaterasu_lab/lua/storm_amt_lab/particle_matrix_core.lua').write_text(s,encoding='utf-8')
p=Path('verify_model_effect_bridge.py');s=p.read_text(encoding='utf-8-sig').replace("'travelAligned':True", "'rotationDirty':False,'travelAligned':True");p.write_text(s,encoding='utf-8')
