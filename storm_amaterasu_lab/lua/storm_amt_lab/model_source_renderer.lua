-- Source adapter for original amt15 geometry and two-film shader family.
-- Caller supplies the recovered world matrix and original material context.
-- No captured points, fitted motion, default placement or guessed tint.
local R={}
local function constant(mat,n,v)
    assert(n>=0 and n<=3,'Source exposes four custom pixel constants')
    for i,axis in ipairs({'x','y','z','w'}) do mat:SetFloat('$c'..n..'_'..axis,assert(v[i],'Missing shader constant')) end
end
function R.new(assets,context)
    assert(context and context.filmWeights and context.parameters,'Original static material context required')
    assert(context.fogAmount==0,'This shader family is verified only for zero fog amt15 draws')
    local definition=assert(assets.models['4efb_amt15'])
    local material=assert(definition.materials[1]);local textures=material.texture_groups[1].textures
    local params={['$vertexshader']='amt_model_r11_vs30',['$pixshader']='amt_model_r11_ps30',
        ['$vertextransform']='1',['$vertexcolor']='1',['$tcsize1']='2',['$tcsize2']='3',
        ['$copyalpha']='0',['$alpha_blend']='1',['$writealpha']='1',
        ['$depthtest']='1',['$writedepth']='0',['$cull']='0',
        ['$softwareskin']='1',['$translucent']='1',['$linearwrite']='1'}
    for i,t in ipairs(textures) do
        local key=i==1 and 'basetexture' or 'texture'..(i-1)
        params['$'..key]=assert(assets.textures[t.name]).sourceTexture
        params['$linearread_'..key]='1'
    end
    local out={meshes={},definition=definition,draws=0,uploads=0,destroyed=false}
    out.material=CreateMaterial('storm_amt_model_r11_amt15','screenspace_general',params)
    for _,model in ipairs(definition.meshes) do
        local buffer=Mesh(out.material)
        mesh.Begin(buffer,MATERIAL_TRIANGLES,#model.triangles)
        for _,triangle in ipairs(model.triangles) do for _,index in ipairs(triangle) do
            local v=assert(model.vertices[index+1])
            mesh.Position(Vector(v[1],v[2],v[3]));mesh.TexCoord(0,v[4],v[5])
            mesh.TexCoord(1,context.filmWeights[1],context.filmWeights[2])
            mesh.TexCoord(2,context.parameters[1],context.parameters[2],context.parameters[3])
            mesh.Color(v[6]*255,v[7]*255,v[8]*255,v[9]*255);mesh.AdvanceVertex()
        end end
        mesh.End();out.meshes[#out.meshes+1]=buffer;out.uploads=out.uploads+1
    end
    function out:draw(packet)
        assert(not self.destroyed,'Destroyed model renderer')
        assert(packet and packet.worldMatrix and packet.screen0 and packet.screen1 and packet.tintAlpha and packet.atlas,
            'Recovered actor/particle/ANM matrix and shader context required')
        local transform=Matrix()
        for row=1,4 do for col=1,4 do transform:SetField(row,col,assert(packet.worldMatrix[(row-1)*4+col])) end end
        constant(self.material,0,packet.screen0);constant(self.material,1,packet.screen1)
        constant(self.material,2,packet.tintAlpha);constant(self.material,3,packet.atlas)
        cam.PushModelMatrix(transform);render.SetMaterial(self.material)
        for _,buffer in ipairs(self.meshes) do buffer:Draw();self.draws=self.draws+1 end
        cam.PopModelMatrix()
    end
    function out:destroy()
        if self.destroyed then return end
        for _,buffer in ipairs(self.meshes) do buffer:Destroy() end
        self.meshes={};self.destroyed=true
    end
    return out
end
return R
