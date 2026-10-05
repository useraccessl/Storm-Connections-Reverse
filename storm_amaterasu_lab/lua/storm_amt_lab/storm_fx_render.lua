-- Generic Storm Connections effect material -> GMod screenspace_general adapter.
-- Every rule here is a native NSUNSC.exe rule (see shader_constant_pipeline.md):
--   * NUD material flags are the shader key; bits 19/20 add screen-film layers.
--   * dest_factor low/high nibble = colour/alpha blend mode (tables 0x141b91150 /
--     0x141b911f0, applied by 0x14126bc70).
--   * source_factor: bit 0 translucent bucket (0x141241450), bit 2 no depth write.
--   * Blend is enabled by the sort bucket, not by the material (0x141219480).
--   * NUD texture wrap codes are D3D11 address modes (1 wrap, 2 mirror, 3 clamp,
--     4 border with colour 0,0,0,0); effect samplers carry LOD bias -16, so only
--     mip 0 is ever sampled.
-- The shaders storm_fx_* are checked against the game's bytecode on captured
-- draws by verify_port_shaders.py. Nothing here is tuned by eye.
local F={version='r18'}

-- Native blend-factor code -> Source BLEND_* value; native op -> BLENDFUNC_*.
local FACTOR={[0]=0,[1]=1,[2]=9,[3]=10,[4]=4,[5]=5,[6]=2,[7]=3,[8]=6,[9]=7}
local OP={[0]=0,[1]=1,[2]=2,[3]=3,[4]=4}
-- {source, operation, destination} in native codes, indexed by 4-bit mode.
F.colorModes={[0]={1,0,0},{4,0,5},{4,0,1},{4,2,1},{0,0,4},{4,2,4},{8,0,9},{8,0,1},{8,2,1},{8,0,0},{6,0,0},{1,0,5},{1,0,1}}
F.alphaModes={[0]={1,0,0},{4,0,5},{4,0,1},{4,2,1},{0,0,4},{4,2,4},{8,0,9},{8,0,1},{8,2,1},{0,0,1},{0,0,0},{1,0,5},{1,0,1}}
-- Translated shader pairs. base: game pairs xxF002 / xxF007 with 0-2 screen
-- films; falloff: 01F008; distort: 03F009 (3dc10cf4 / 4bf6e191).
F.variants={
    base={vertex='storm_fx_vs30',pixel={[0]='storm_fx_ps30','storm_fx_film1_ps30','storm_fx_film2_ps30'}},
    falloff={vertex='storm_fx_falloff_vs30',pixel={[0]='storm_fx_falloff_ps30'},normals=true},
    distort={vertex='storm_fx_distort_vs30',pixel={[0]='storm_fx_distort_ps30'},secondUV=true,scene=true}}
-- Texture name Source gives the copy made by render.UpdateScreenEffectTexture.
F.sceneTexture='_rt_FullFrameFB'
-- nuccChunkModel layer byte -> position in the frame, from the event order of
-- captures 22127 / 22136 (2: 2072.., 18: 5302.., 0: 6241.., 1: 6454.., 14: 6763).
-- Layer 3 was never captured; it is placed with the other translucent layers.
F.layerRank={[2]=1,[18]=2,[0]=3,[1]=4,[3]=5,[14]=6}

local function bit(value,n) return math.floor(value/2^n)%2 end
local function variantOf(key)
    if key==0x3f009 then return 'distort' end
    local family=key%65536
    if family==0xf002 or family==0xf007 then return 'base' end
    if family==0xf008 then return 'falloff' end
end

-- nud: NUD material record {flags, source_factor, dest_factor, cull_mode}.
function F.state(nud)
    local source,dest,key=nud.source_factor or 0,nud.dest_factor or 0,nud.flags or 0
    local name=assert(variantOf(key),'Shader key outside the translated effect families')
    local variant=F.variants[name]
    local color=assert(F.colorModes[dest%16],'Unknown native colour blend mode')
    local alpha=assert(F.alphaModes[math.floor(dest/16)%16],'Unknown native alpha blend mode')
    local bucket=bit(source,0)==0 and 0 or bit(source,1)==0 and 2 or bit(source,3)==1 and 3 or 1
    local films=0
    if name=='base' then
        local film0,film1=bit(key,19)==1,bit(key,20)==1
        assert(film0 or not film1,'Second screen film without the first is not a known shader key')
        films=(film0 and 1 or 0)+(film1 and 1 or 0)
    end
    return {shaderKey=key,variant=name,vertexShader=variant.vertex,pixelShader=assert(variant.pixel[films]),
        normals=variant.normals or false,secondUV=variant.secondUV or false,scene=variant.scene or false,
        bucket=bucket,blend=bucket~=0,depthWrite=bit(source,2)==0,cull=nud.cull_mode==1029,films=films,
        blendArgs={FACTOR[color[1]],FACTOR[color[3]],OP[color[2]],FACTOR[alpha[1]],FACTOR[alpha[3]],OP[alpha[2]]}}
end

-- Per-draw pixel constants c0..c3 from the game's own constant names.
function F.pack(native,state)
    local common=native.commonParam
    if state and state.variant=='distort' then
        local second,normal,mask=native.uvOffset1,native.uvScaleNormal,native.uvScaleAlpha
        return {native.uvOffset0,{second[1],second[2],common[2]*second[3],0},normal,{mask[1],mask[2],0,0}}
    end
    local mult,ambient=native.multColor,native.ambientColor or {1,1,1}
    local fog=native.fogColor or {0,0,0}
    local third=native.uvOffsetScreen or {0,0,0,0}
    if state and state.variant=='falloff' then
        local axis=native.viewAxis
        third={axis[1],axis[2],axis[3],native.falloffCoordinate}
    end
    return {native.uvOffset0,
        {mult[1]*ambient[1],mult[2]*ambient[2],mult[3]*ambient[3],common[1]},
        third,
        {fog[1],fog[2],fog[3],common[2]}}
end

-- View z axis expressed in model space, for the falloff variant. world is the
-- packed row-major model matrix (columns are the axes); forward is the camera
-- axis in world space. Returns nil when the model is not uniformly scaled,
-- where the game's inverse-transpose normal has no single-vector equivalent.
function F.viewAxis(world,forward)
    local axis,lengths={},{}
    for i=1,3 do
        local x,y,z=world[i],world[4+i],world[8+i]
        lengths[i]=math.sqrt(x*x+y*y+z*z)
        if lengths[i]==0 then return nil end
        axis[i]=(x*forward[1]+y*forward[2]+z*forward[3])/lengths[i]
    end
    local tolerance=1e-4*lengths[1]
    if math.abs(lengths[2]-lengths[1])>tolerance or math.abs(lengths[3]-lengths[1])>tolerance then return nil end
    return axis
end

-- Texture addressing for a NUD wrap pair. Returns the texture-name suffix of
-- the clamped VTF variant (make_vtf_address_variants.py) and the TEXCOORD7
-- codes read by the pixel shader: 0 native, -1 mirror, texture size for border.
function F.address(wrapS,wrapT,width,height)
    local function axis(mode,size)
        if mode==1 then return false,0 end
        if mode==2 then return true,-1 end
        if mode==3 then return true,0 end
        assert(mode==4,'Unsupported NUD texture address mode')
        return true,size
    end
    local clampS,codeS=axis(wrapS,width)
    local clampT,codeT=axis(wrapT,height)
    local suffix=(clampS or clampT) and ('_c'..(clampS and 's' or '')..(clampT and 't' or '')) or ''
    return suffix,{codeS,codeT}
end

-- Per-material values baked into TEXCOORD1..7 of the cached mesh.
-- scale converts game units to Source units for the fog distances.
function F.static(native,scale,addressCodes)
    local filmScale=native.uvScaleScreen or {1,1,1,1}
    local weight=native.uvOffset3 or {0,0}
    local start,finish,strength=0,1,0
    local fog=native.fogParam
    if fog and fog[3]~=0 then start,finish,strength=fog[1]*scale,fog[2]*scale,fog[3] end
    return {{filmScale[1],filmScale[2]},{filmScale[3],filmScale[4]},{weight[1],weight[2]},
        {start,finish},{strength,0},{native.screenToUV[1],native.screenToUV[2]},
        addressCodes or {0,0}}
end

function F.material(name,state,textures)
    local params={['$pixshader']=state.pixelShader,['$vertexshader']=state.vertexShader,
        ['$basetexture']=textures[1],['$vertexcolor']='1',['$vertextransform']='1',['$x360appchooser']='1',
        ['$tcsize1']='2',['$tcsize2']='2',['$tcsize3']='2',['$tcsize4']='2',['$tcsize5']='2',['$tcsize6']='2',
        ['$tcsize7']='2',['$copyalpha']='0',['$alpha_blend']='0',['$writealpha']='1',['$depthtest']='1',
        ['$writedepth']=state.depthWrite and '1' or '0',['$cull']=state.cull and '1' or '0',['$softwareskin']='1',
        ['$linearread_basetexture']='1',['$linearwrite']='1'}
    if state.normals then params['$vertexnormal']='1' end
    for i=2,#textures do
        params['$texture'..(i-1)]=textures[i]
        params['$linearread_texture'..(i-1)]='1'
    end
    return CreateMaterial(name,'screenspace_general',params)
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
F.half=half

-- model: {vertices={{x,y,z,u,v,r,g,b,a},...},triangles={{i,j,k},...}} with 0-based
-- indices; normalHalfRaw (NUD half-float normals) and uvSets when the variant
-- needs them.
-- Winding: the game's front faces are counter-clockwise on screen (measured on
-- every culled capture draw) and Source culls counter-clockwise ones. The
-- exported triangle lists (export_effect_obj.triangles) already use the strip
-- parity opposite to D3D's, so a game front face arrives here clockwise, which
-- is Source's front face. verify_port_winding.py checks this per resource.
function F.buildMesh(material,model,static,state)
    local buffer=Mesh(material)
    mesh.Begin(buffer,MATERIAL_TRIANGLES,#model.triangles)
    for _,triangle in ipairs(model.triangles) do for _,index in ipairs(triangle) do
        local v=model.vertices[index+1]
        mesh.Position(Vector(v[1],v[2],v[3]))
        if state and state.normals then
            local raw=assert(model.normalHalfRaw,'Variant needs NUD normals')[index+1]
            mesh.Normal(Vector(half(raw,1),half(raw,5),half(raw,9)))
        end
        mesh.TexCoord(0,v[4],v[5])
        for channel,pair in ipairs(static) do mesh.TexCoord(channel,pair[1],pair[2]) end
        if state and state.secondUV then
            local second=assert(model.uvSets,'Variant needs the second UV set')[index+1][2]
            mesh.TexCoord(1,second[1],second[2])
        end
        mesh.Color(v[6]*255,v[7]*255,v[8]*255,v[9]*255)
        mesh.AdvanceVertex()
    end end
    mesh.End()
    return buffer
end

local AXES={'x','y','z','w'}
function F.apply(material,packed)
    for n=0,3 do local v=packed[n+1]
        for i=1,4 do material:SetFloat('$c'..n..'_'..AXES[i],v[i] or 0) end
    end
end

-- Native render state for the draws that follow.
function F.begin(state)
    if state.blend then local b=state.blendArgs
        render.OverrideBlend(true,b[1],b[2],b[3],b[4],b[5],b[6])
    else
        render.OverrideBlend(true,1,0,0,1,0,0)
    end
    render.OverrideDepthEnable(true,state.depthWrite)
end
function F.finish()
    render.OverrideBlend(false)
    render.OverrideDepthEnable(false,false)
end

-- Draw order of the engine queue: layer, then bucket, then depth (bucket 0
-- near to far, bucket 2 far to near), then emission order. depth grows away
-- from the eye; entry.layer is the nuccChunkModel layer byte.
function F.sort(entries)
    for i,e in ipairs(entries) do
        e.order=i
        e.rank=assert(F.layerRank[e.layer or 0],'Model layer with no known frame position')
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
return F
