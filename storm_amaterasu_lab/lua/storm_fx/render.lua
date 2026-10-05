-- Storm Connections effect meshes -> GMod screenspace_general.
-- A mesh comes from storm_import.py with its own shader pair (shader_port.py:
-- the game's vertex and pixel programs translated from bytecode, the material's
-- constants compiled in) and a layout saying where the remaining constants go:
-- per-draw values in pixel constants c0-c3, stage values in TEXCOORD channels
-- of the cached mesh (storm_fx/shader_layout.lua).
-- The render state rules are native NSUNSC.exe rules (shader_constant_pipeline.md):
--   * dest_factor low/high nibble = colour/alpha blend mode (tables 0x141b91150 /
--     0x141b911f0, applied by 0x14126bc70);
--   * source_factor: bit 0 translucent bucket (0x141241450), bit 2 no depth write;
--   * blend is enabled by the sort bucket, not by the material (0x141219480);
--   * draw order: layer, bucket, depth, emission order.
-- verify_package_shaders.py checks every shader pair against the game's bytecode.
local layout=include('storm_fx/shader_layout.lua')
local R={pack=layout.pack,static=layout.static,names=layout.names}

-- Native blend-factor code -> Source BLEND_* value; native op -> BLENDFUNC_*.
local FACTOR={[0]=0,[1]=1,[2]=9,[3]=10,[4]=4,[5]=5,[6]=2,[7]=3,[8]=6,[9]=7}
local OP={[0]=0,[1]=1,[2]=2,[3]=3,[4]=4}
-- {source, operation, destination} in native codes, indexed by 4-bit mode.
R.colorModes={[0]={1,0,0},{4,0,5},{4,0,1},{4,2,1},{0,0,4},{4,2,4},{8,0,9},{8,0,1},{8,2,1},{8,0,0},{6,0,0},{1,0,5},{1,0,1}}
R.alphaModes={[0]={1,0,0},{4,0,5},{4,0,1},{4,2,1},{0,0,4},{4,2,4},{8,0,9},{8,0,1},{8,2,1},{0,0,1},{0,0,0},{1,0,5},{1,0,1}}
-- Texture name Source gives the copy made by render.UpdateScreenEffectTexture.
R.sceneTexture='_rt_FullFrameFB'
-- nuccChunkModel layer byte -> position in the frame, from the event order of
-- captures 22127 / 22136 (2: 2072.., 18: 5302.., 0: 6241.., 1: 6454.., 14: 6763).
-- Layer 3 was never captured; it is placed with the other translucent layers.
R.layerRank={[2]=1,[18]=2,[0]=3,[1]=4,[3]=5,[14]=6}

local function bit(value,n) return math.floor(value/2^n)%2 end

-- Render state of a NUD material record {source_factor, dest_factor, cull_mode}.
function R.state(nud)
    local source,dest=nud.source_factor or 0,nud.dest_factor or 0
    local color=assert(R.colorModes[dest%16],'Unknown native colour blend mode')
    local alpha=assert(R.alphaModes[math.floor(dest/16)%16],'Unknown native alpha blend mode')
    local bucket=bit(source,0)==0 and 0 or bit(source,1)==0 and 2 or bit(source,3)==1 and 3 or 1
    return {bucket=bucket,blend=bucket~=0,depthWrite=bit(source,2)==0,cull=nud.cull_mode==1029,
        blendArgs={FACTOR[color[1]],FACTOR[color[3]],OP[color[2]],FACTOR[alpha[1]],FACTOR[alpha[3]],OP[alpha[2]]}}
end

-- mesh: package mesh {shader=layout, textures={{vtf=...},...}}. Port sampler n
-- is $basetexture / $texture1..3; a layout sampler names the material texture it
-- binds, or the scene copy.
function R.textures(mesh)
    local names,scene={},false
    for n,sampler in ipairs(mesh.shader.samplers) do
        if sampler.system then names[n]=sampler.system scene=true
        else names[n]=assert(mesh.textures[sampler.material+1],'Shader samples a texture the material lacks').vtf end
    end
    return names,scene
end
-- Depth: Garry's Mod's screenspace_general (bin/win64/stdshader_dx9.dll 2026.09.22, shadow
-- state at 0x18004e8e8) does EnableDepthWrites($writedepth), then, when $writedepth is set,
-- EnableDepthTest(true) and DepthFunc(SHADER_DEPTHFUNC_ALWAYS), then EnableDepthTest($depthtest):
-- a material with $writedepth 1 is drawn over everything. So the materials keep
-- $writedepth 0 and $depthtest 1 (the default near-or-equal test) and the depth writes of
-- a state go through render.OverrideDepthEnable (R.begin), which sets the writes only.
-- $vertexcolor is the generic material flag; this shader has no $x360appchooser.
function R.material(name,mesh,state)
    local shader=mesh.shader
    local textures=R.textures(mesh)
    local params={['$pixshader']=shader.pixel,['$vertexshader']=shader.vertex,
        ['$basetexture']=textures[1],['$vertexcolor']='1',['$vertextransform']='1',
        ['$copyalpha']='0',['$alpha_blend']='0',['$writealpha']='1',['$depthtest']='1',
        ['$writedepth']='0',['$cull']=state.cull and '1' or '0',['$softwareskin']='1',
        ['$linearread_basetexture']='1',['$linearwrite']='1'}
    -- Components of the baked TEXCOORD channels (shader_layout.lua); the second UV
    -- set, when the shader reads it, is channel 1 with two.
    local size=tostring(shader.channelSize or 2)
    for channel=1,7 do params['$tcsize'..channel]=(channel==1 and shader.attributes.uv1) and '2' or size end
    if shader.attributes.normal then params['$vertexnormal']='1' end
    for i=2,#textures do
        params['$texture'..(i-1)]=textures[i]
        params['$linearread_texture'..(i-1)]='1'
    end
    -- A pair that samples five to eight textures needs screenspace_general_8tex
    -- (GMod 2025.12.01; the same shader with eight samplers).
    return CreateMaterial(name,shader.host or 'screenspace_general',params)
end
-- Whether this GMod has the host shader a mesh asks for (an unknown shader name
-- gives a material of another shader).
function R.hostAvailable(material,mesh)
    local host=mesh.shader.host or 'screenspace_general'
    return host=='screenspace_general' or not material.GetShader or string.lower(material:GetShader() or '')==host
end

-- Big-endian IEEE half float at a 1-based position of a hex string.
local function half(hex,at)
    local value=tonumber(hex:sub(at,at+3),16)
    local sign=value>=32768 and -1 or 1
    local exponent,mantissa=math.floor(value/1024)%32,value%1024
    if exponent==0 then return sign*mantissa*2^-24 end
    assert(exponent<31,'Non-finite half float in a NUD normal')
    return sign*(1+mantissa/1024)*2^(exponent-15)
end
R.half=half

-- mesh: {vertices={{x,y,z,u,v,r,g,b,a},...},triangles={{i,j,k},...}} with 0-based
-- indices, normalHalfRaw / uvSets when the shader reads them. static: the seven
-- TEXCOORD channels of R.static (two or four floats each).
-- Winding: the game's front faces are counter-clockwise on screen and Source
-- culls counter-clockwise ones; the importer emits strips with the parity
-- opposite to D3D's, so a game front face arrives clockwise, Source's front
-- face (verify_port_winding.py).
-- skinned: {positions, normals} of a skinned mesh (skinning_core.lua), or nil
-- for the vertices as they are in the file.
local function emit(definition,static,skinned)
    local attributes=definition.shader.attributes
    for _,triangle in ipairs(definition.triangles) do for _,index in ipairs(triangle) do
        local v=definition.vertices[index+1]
        local position=skinned and skinned.positions[index+1] or v
        mesh.Position(Vector(position[1],position[2],position[3]))
        if attributes.normal then
            if definition.skin then
                local normal=skinned and skinned.normals[index+1] or definition.skin.normals[index+1]
                mesh.Normal(Vector(normal[1],normal[2],normal[3]))
            else
                local raw=assert(definition.normalHalfRaw,'Shader needs NUD normals')[index+1]
                mesh.Normal(Vector(half(raw,1),half(raw,5),half(raw,9)))
            end
        end
        mesh.TexCoord(0,v[4],v[5])
        for channel,baked in ipairs(static) do
            if channel==1 and attributes.uv1 then
                local second=assert(definition.uvSets,'Shader needs the second UV set')[index+1][2]
                mesh.TexCoord(1,second[1],second[2])
            elseif #baked==4 then mesh.TexCoord(channel,baked[1],baked[2],baked[3],baked[4])
            else mesh.TexCoord(channel,baked[1],baked[2]) end
        end
        mesh.Color(v[6]*255,v[7]*255,v[8]*255,v[9]*255)
        mesh.AdvanceVertex()
    end end
end
function R.buildMesh(material,definition,static)
    local buffer=Mesh(material)
    mesh.Begin(buffer,MATERIAL_TRIANGLES,#definition.triangles)
    emit(definition,static)
    mesh.End()
    return buffer
end
-- A skinned mesh, sent as a dynamic mesh with the material bound by the caller
-- (render.SetMaterial) under the caller's model matrix.
function R.drawSkinned(definition,static,skinned)
    mesh.Begin(MATERIAL_TRIANGLES,#definition.triangles)
    emit(definition,static,skinned)
    mesh.End()
end

-- A trail ribbon (trail_core.lua vertices, two per point: edge 0, edge 1), sent as the
-- triangles of the game's strip (0x141389eb0 draws 2 x points vertices), wound like the
-- importer's strips (see emit). The trail's vertices carry no normal (zero).
function R.drawRibbon(definition,static,vertices)
    local attributes=definition.shader.attributes
    local n=#vertices/2
    if n<2 then return end
    local function put(v)
        mesh.Position(Vector(v.position[1],v.position[2],v.position[3]))
        if attributes.normal then mesh.Normal(Vector(0,0,0)) end
        mesh.TexCoord(0,v.u,v.v)
        for channel,baked in ipairs(static) do
            if channel==1 and attributes.uv1 then mesh.TexCoord(1,v.u,v.v)
            elseif #baked==4 then mesh.TexCoord(channel,baked[1],baked[2],baked[3],baked[4])
            else mesh.TexCoord(channel,baked[1],baked[2]) end
        end
        local c=v.color
        mesh.Color(math.Clamp(c[1],0,1)*255,math.Clamp(c[2],0,1)*255,math.Clamp(c[3],0,1)*255,math.Clamp(c[4],0,1)*255)
        mesh.AdvanceVertex()
    end
    mesh.Begin(MATERIAL_TRIANGLES,2*(n-1))
    for k=1,n-1 do
        local a,b,c,d=vertices[2*k-1],vertices[2*k],vertices[2*k+1],vertices[2*k+2]
        -- Strip triangles (a, b, c) and (c, b, d), with the opposite parity.
        put(a) put(c) put(b)
        put(c) put(d) put(b)
    end
    mesh.End()
end

-- Pixel constants c0-c3 of a draw. The names are built once; a material keeps the
-- values last set on it and only the components that changed are sent.
local CONSTANT_NAMES={}
for n=0,3 do for i,axis in ipairs({'x','y','z','w'}) do CONSTANT_NAMES[n*4+i]='$c'..n..'_'..axis end end
local sent=setmetatable({},{__mode='k'})
function R.apply(material,packed)
    local last=sent[material]
    if not last then last={} sent[material]=last end
    for n=0,3 do local v=packed[n+1]
        for i=1,4 do
            local k=n*4+i
            local value=v[i] or 0
            if last[k]~=value then material:SetFloat(CONSTANT_NAMES[k],value) last[k]=value end
        end
    end
end

-- Native render state for the draws that follow: the blend, and the depth writes
-- (render.OverrideDepthEnable sets the writes only; the test is the material's
-- $depthtest, see R.material).
function R.begin(state)
    if state.blend then local b=state.blendArgs
        render.OverrideBlend(true,b[1],b[2],b[3],b[4],b[5],b[6])
    else
        render.OverrideBlend(true,1,0,0,1,0,0)
    end
    render.OverrideDepthEnable(true,state.depthWrite)
end
function R.finish()
    render.OverrideBlend(false)
    render.OverrideDepthEnable(false,false)
end

-- Draw order of the engine queue: layer, then bucket, then depth (bucket 0
-- near to far, bucket 2 far to near), then emission order. depth grows away
-- from the eye; entry.layer is the nuccChunkModel layer byte.
function R.sort(entries)
    for i,e in ipairs(entries) do
        e.order=i
        -- A layer never captured has no known place in the frame: drawn last.
        e.rank=R.layerRank[e.layer or 0] or 7
    end
    table.sort(entries,function(a,b)
        if a.rank~=b.rank then return a.rank<b.rank end
        if a.state.bucket~=b.state.bucket then return a.state.bucket<b.state.bucket end
        if a.state.bucket==0 and a.depth~=b.depth then return a.depth<b.depth end
        if a.state.bucket==2 and a.depth~=b.depth then return a.depth>b.depth end
        return a.order<b.order
    end)
    return entries
end
return R
