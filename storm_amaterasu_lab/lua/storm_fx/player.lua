-- Storm Connections effect engine for GMod: generic player.
-- Plays any data package written by storm_import.py: effects (emitters,
-- animations, billboard / clump / animated resources) and the skill scripts
-- that chain them. Nothing here names a particular skill.
--   * drawing follows the native render rules (storm_fx_render.lua);
--   * particle, animation and matrix maths are the translated native routines
--     (storm_amt_lab/*_core.lua);
--   * what the game takes from its world is an explicit host input: the stage
--     context (fog, light sets, tone), the launch point, the target point,
--     ground and wall queries.
-- These commands are not a parity assertion; see MOTEUR_EFFETS_REVERSE.md.
local curves=include('storm_amt_lab/runtime_core.lua')
local modules={curves=curves,spawn=include('storm_amt_lab/particle_spawn_core.lua'),
    motion=include('storm_amt_lab/particle_motion_core.lua'),runtime=include('storm_amt_lab/procedural_runtime.lua'),
    spatial=include('storm_amt_lab/scene_spatial_core.lua'),birthSpatial=include('storm_amt_lab/particle_spatial_core.lua'),
    emission=include('storm_amt_lab/emission_core.lua')}
local driver=include('storm_amt_lab/procedural_scene.lua')
local materialContext=include('storm_amt_lab/material_context_core.lua')
local billboardRender=include('storm_amt_lab/billboard_render_core.lua')
local facingCore=include('storm_amt_lab/facing_core.lua')
local trailCore=include('storm_amt_lab/trail_core.lua')
local fx=include('storm_fx/render.lua')
local post=include('storm_amt_lab/storm_stage_post.lua')
local skillShot=include('storm_amt_lab/skill_shot_core.lua')
local skillActor=include('storm_amt_lab/skill_actor_core.lua')
local pointLight=include('storm_amt_lab/point_light_core.lua')
local anmModules={quaternion=include('storm_amt_lab/quaternion_animation_core.lua'),
    scalar=include('storm_amt_lab/scalar_animation_core.lua'),matrix=include('storm_amt_lab/anm_matrix_core.lua'),
    color=include('storm_amt_lab/color_animation_core.lua'),material=include('storm_amt_lab/material_animation_core.lua'),
    clock=include('storm_amt_lab/anm_clock_core.lua'),animation=include('storm_amt_lab/anm_resource_core.lua')}
local anmScene=include('storm_amt_lab/anm_scene_adapter.lua')
local modelFactory=include('storm_amt_lab/model_particle_adapter.lua')
anmModules.particle=include('storm_amt_lab/particle_matrix_core.lua')
anmModules.skinning=include('storm_amt_lab/skinning_core.lua')
anmModules.bridge=include('storm_amt_lab/model_effect_instance.lua')
anmModules.context=materialContext
-- The translated routines round every operation to float32 as the game does: that
-- is what the offline checks compare bit for bit with the native code, but each
-- rounding costs a frexp and a division. In Garry's Mod (LuaJIT) the engine computes
-- in doubles by default (differences below 1e-6 relative, not visible);
-- P.setExact(true) / storm_fx_exact 1 brings the rounding back.
local exactFloat32=materialContext.float32
local exact=not jit
local function float32(v) if exact then return exactFloat32(v) end return v end
-- Skinning runs every update on every vertex of a skinned mesh: in doubles (the
-- game's shader works in float32; the difference is below 1e-6 of a unit).
local function plain(value) return value end
local M=anmModules.matrix
local anmOptions={float32=float32,
    sinf=function(v) return float32(math.sin(v)) end,
    cosf=function(v) return float32(math.cos(v)) end,
    acosf=function(v) return float32(math.acos(v)) end,
    materialHold=anmModules.animation.materialHoldFromContext(60,0),
    -- Size-curve output a model particle holds before its first update.
    initialSize=function(p) return (curves.sample(p.sampleConfig,p.life,0,{0,0,0})) end}
local old=STORM_FX
if old and old.cleanup then old.cleanup() end
-- stage: scene inputs of the captured match (Amaterasu captures, frames
-- 22082-22200); a host may replace this table. The game reads fog from the
-- render context a model is submitted in (context +20) and ambient from that
-- context's light set chosen by the model's light byte (0x141312a90 on context
-- +38). fogLayers lists the model layers whose context carried the stage fog in
-- the captures (0 and 2; 1 and 18 had it disabled, 3 was never captured).
-- tone holds the constants of the stage's tone-control pass.
-- host: stand-ins for what the game takes from its world. scale maps game
-- units to Source units by eye height (64 over the game's 119); launchOffset
-- is an estimate from capture 22082. dynamicLights: the point lights of the
-- effects also light the Source world, as dynamic lights (the game lights its
-- stage and characters with them); lightBrightness scales their intensity.
local P={version='r27',packages={},instances={},casts={},lights={},skipped={},failed={},draws=0,renderMs=0,updateMs=0,uploads=0,toneMode=0,
    skinnedVertices=0,
    stage={fogColor={.6470588446,.9215686321,1},fogParam={200,13000,.30000001192092896},fogLayers={[0]=true,[2]=true},
        -- Ambient by model light byte. 0 and 1: light mode 0x140ae8e80, ambient constant
        -- (1, 1, 1). 4: no light mode, the context's default light set (captured). 3:
        -- light mode 0x140ae91f0, ambient taken from the light manager, never captured.
        lightSets={[0]={1,1,1},[1]={1,1,1},[4]={.9411764741,.9607843161,.8235294223}},defaultAmbient={1,1,1},
        -- Light bytes with a light mode in the effects' context (table 0x140ae98e0): 0, 1
        -- and 3. Any other byte has none and takes the context's default light set (+30),
        -- the one captured under byte 4 (journal R95).
        lightModes={[0]=true,[1]=true,[3]=true},
        -- Light bytes whose light mode hands the effects' point lights to the model
        -- (0x140ae9ce0); the default light set of the other models is the stage's own.
        pointLightModes={[0]=true,[1]=true,[3]=true},
        -- First directional light of the scene's light set (world direction it
        -- travels along, colour), stage colour and cel-shade offset: one value each
        -- over the 476 lit draws of the captures.
        lightDirection={-.58321,.29161,-.75818},lightColor={160/255,160/255,140/255},
        stageColor={143/255,142/255,98/255,1},celShade=0,
        tone={paramR={-.0372549,.0372549,.0372549,0},paramG={-.0156863,.0156863,-.0156863,0},
            paramB={-.027451,-.027451,.027451,0},hparam={0,0,0,0},lparam={0,0,0,.0196078}}},
    host={launchOffset=40,groundProbe=64,stepHeight=18,scale=64/119,maxLoopFrames=3600,defaultGround='DIRT',
        dynamicLights=true,lightBrightness=1,lightIndex=4096}}
STORM_FX=P
function P.setExact(on) exact=on and true or false end
function P.isExact() return exact end
P.fx=fx
local FPS=60
local IDENTITY={1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1}
-- Values of the scene for one model, by the game's constant names. The game
-- reads fog from the render context a model is submitted in and ambient from
-- that context's light set (model light byte). g_clip / g_zrange are the
-- camera constants of the soft-particle shaders, set so that their linear
-- depth is Source's view depth; the port has no scene depth to fade against.
local function stageValues(item,scale)
    local stage=P.stage
    local view=render.GetViewSetup and render.GetViewSetup() or {}
    local near,far=view.znear or 7,view.zfar or 30000
    local fog=item.fogged and stage.fogParam or nil
    local light=stage.lightDirection
    return {g_fogParam=fog and {fog[1]*scale,fog[2]*scale,fog[3],0} or {0,1,0,0},
        g_fogColor=item.fogged and stage.fogColor or {0,0,0},
        -- A byte without a light mode takes the default light set (byte 4's); a light mode
        -- no capture showed (byte 3, the light manager's ambient) has the host default.
        g_ambientColor=stage.lightSets[item.light] or (not stage.lightModes[item.light] and stage.lightSets[4])
            or stage.defaultAmbient,
        g_ScreenToUV=materialContext.screenToUV(ScrW(),ScrH()),
        -- Lit families (context fill 0x1413368f0). The vertex shader takes the light
        -- direction into object space with the inverse of the model matrix it is
        -- given; that matrix carries the host scale, undone here. Light slots 1..3
        -- are unused.
        g_lightDirectionWorld={light[1]*scale,light[2]*scale,light[3]*scale,0},
        g_lightColor={stage.lightColor[1],stage.lightColor[2],stage.lightColor[3],1,0,0,0,1,0,0,0,1,0,0,0,1},
        g_stageColor=stage.stageColor,g_celShadeParam={stage.celShade,0,0,0},
        -- The .w of the two screen-tint colours is the inverse screen size (the
        -- colours themselves are compiled into the shaders, see storm_import.py).
        g_cparaColor1={1,1,1,1/ScrW()},g_cparaColor2={1,1,1,1/ScrH()},
        g_clip={far*near,far-near,far,0},g_zrange={1,0,0,0}}
end
-- What the player sets per draw for every material (storm_import.py DRAW_CONSTANTS),
-- and point light slot 0 for the lit ones.
local PER_DRAW={g_uvOffset0=true,g_multColor=true,g_commonParam=true,g_uvOffsetScreen=true,
    g_pointLightColor0=true,g_pointLightPos0=true,g_pointLightParam0=true}
-- Material instance field -> constant component (binder 0x1412f5ff0): the same
-- map storm_import.py uses for the constants it compiles in.
local INSTANCE={g_uvOffset0={0x30,0x34,0x50,0x54},g_uvOffset1={0x38,0x3c,0x58,0x5c},
    g_uvOffset2={0x40,0x44,0x60,0x64},g_uvOffset3={0x48,0x4c,0x68,0x6c}}
-- One drawable model: a part per NUD mesh, each with its own material, shader
-- pair and render state; nuccChunkModel header, node opacity.
local function addModel(runtime,name,model)
    -- facing: header attribute bit 0 (model +2C), the camera-facing hook at draw.
    local item={name=name,parts={},fogged=P.stage.fogLayers[model.header.layer]==true,light=model.header.light,
        layer=model.header.layer,opacity=model.node and model.node.opacity or 1,facing=model.header.attributes%2==1}
    local problems={}
    local available=stageValues(item,1)
    if not P.stage.lightSets[item.light] and P.stage.lightModes[item.light] then
        local text='light mode '..tostring(item.light)..' was never captured: its ambient is the host default'
        if not runtime.noted[text] then runtime.noted[text]=true runtime.notes[#runtime.notes+1]=text end
    end
    for index,mesh in ipairs(model.meshes) do
        local why=not mesh.shader and (mesh.shaderProblem or 'no translated shader')
        if not why then
            for _,group in ipairs({mesh.shader.dynamic,mesh.shader.static}) do for _,entry in ipairs(group) do
                if not PER_DRAW[entry.name] and not INSTANCE[entry.name] and entry.name~='g_blendRate'
                    and entry.name~='g_olIdParam' and not available[entry.name] then
                    why='the stage has no value for '..entry.name
                end
            end end
        end
        if why then problems[#problems+1]='mesh '..index..': '..why
        else
            if mesh.shader.frozen and #mesh.shader.frozen>0 then
                local text='some lit meshes have '..table.concat(mesh.shader.frozen,', ')
                    ..' of the import-time stage compiled in (pixel constant budget): the stage table does not reach them'
                if not runtime.noted[text] then runtime.noted[text]=true runtime.notes[#runtime.notes+1]=text end
            end
            if mesh.shader.unlit then
                local text='some lit meshes take no point light (pixel constant budget): their light slot is compiled as unused'
                if not runtime.noted[text] then runtime.noted[text]=true runtime.notes[#runtime.notes+1]=text end
            end
            local state=fx.state(mesh.state)
            local _,scene=fx.textures(mesh)
            state.scene=scene
            local dynamic=fx.names(mesh.shader)
            local material=model.materials[mesh.material+1]
            local mat=fx.material('storm_fx_'..P.version..'_'..runtime.name..'_'..name..'_'..index,mesh,state)
            if not fx.hostAvailable(mat,mesh) then
                problems[#problems+1]='mesh '..index..': this GMod has no '..mesh.shader.host
                    ..' (five to eight textures; GMod 2025.12.01)'
            else item.parts[#item.parts+1]={mesh=mesh,state=state,layout=mesh.shader,instance=material.instance,
                materialIndex=mesh.material+1,
                -- The shader reads point light slot 0 of the model's light set.
                lit=(dynamic.g_pointLightColor0 or dynamic.g_pointLightPos0 or dynamic.g_pointLightParam0)==true,
                -- Material format bit 5: its float replaces the x offset of UV set 2 (falloff coordinate).
                overrideX=math.floor(material.format/32)%2==1,scrolls=dynamic.g_uvOffsetScreen==true,
                mat=mat} end
        end
    end
    if #problems>0 then runtime.unsupported[name]=table.concat(problems,'; ') end
    if #item.parts>0 then runtime.items[name]=item end
end
-- One trail ribbon (storm_import.py Importer.ribbon): the shader of key 0x1F007 with the
-- constants of the DrawTrail command, the billboard's texture, its vertices sent on
-- every draw. Layer, light byte and fog follow the billboard's model (the light byte is
-- the game's: 0x141325a50 hands it to the context fill; the layer and the render state
-- are stand-ins, see the package notes).
local function addRibbon(runtime,key,definition)
    local draw=definition.draw
    local model=runtime.data.models[draw.model]
    local mesh=draw.mesh
    local item={name=key,parts={},fogged=P.stage.fogLayers[model.header.layer]==true,light=model.header.light,
        layer=model.header.layer,opacity=1}
    local available=stageValues(item,1)
    for _,group in ipairs({mesh.shader.dynamic,mesh.shader.static}) do for _,entry in ipairs(group) do
        if entry.name~='g_multColor' and entry.name~='g_commonParam' and not available[entry.name] then
            runtime.unsupported[key]='the stage has no value for '..entry.name
            return
        end
    end end
    local state=fx.state(mesh.state)
    local mat=fx.material('storm_fx_'..P.version..'_'..runtime.name..'_'..key,mesh,state)
    item.parts[1]={mesh=mesh,state=state,layout=mesh.shader,ribbon=true,mat=mat}
    runtime.ribbons[definition]=item
end
-- A package travels as content: data_static/storm_fx/<name>.txt (its Lua source), which
-- clients download from a server with the textures and shaders. A client Lua file
-- (AddCSLuaFile) may not exceed 64 KB compressed and a package is hundreds of KB. The Lua
-- file storm_fx/packages/<name>.lua is the fallback (offline harnesses, development copies).
local function readPackage(name)
    local path='data_static/storm_fx/'..name..'.txt'
    local text=file and file.Read and CompileString and file.Read(path,'GAME')
    if text then
        local chunk=CompileString(text,path,false)
        if type(chunk)~='function' then error('Storm FX package '..name..' does not compile: '..tostring(chunk)) end
        return chunk(),path
    end
    local lua='storm_fx/packages/'..name..'.lua'
    if CompileString and file.Exists and not file.Exists(lua,'LUA') then
        -- In game, without the content: say why rather than let include() fail.
        error('package '..name..' is not on this client ('..path..' missing): the Storm FX content was not '
            ..'downloaded (the Workshop content the server lists, or cl_downloadfilter "all" for the files of the server itself)',0)
    end
    return include(lua),'lua'
end
function P.load(name)
    local runtime=P.packages[name]
    if runtime then return runtime end
    local data,source=readPackage(name)
    assert(type(data)=='table' and data.format==1,'Not a storm_import.py package: '..tostring(name))
    runtime={name=name,data=data,source=source,items={},ribbons={},unsupported={},notes={},noted={}}
    for modelName,model in pairs(data.models) do addModel(runtime,modelName,model) end
    local animations={}
    for animation in pairs(data.trails or {}) do animations[#animations+1]=animation end
    table.sort(animations)
    for _,animation in ipairs(animations) do
        for index,definition in ipairs(data.trails[animation]) do
            if definition.draw then addRibbon(runtime,animation..'_trail'..index,definition) end
        end
    end
    runtime.models=modelFactory.new(data,anmModules,anmOptions)
    P.packages[name]=runtime
    return runtime
end
-- Stage values are baked into the meshes (TEXCOORD channels): a mesh is rebuilt
-- when the scale (fog distances) or the resolution (g_ScreenToUV) changes.
local function staticKey(scale) return scale..'|'..ScrW()..'x'..ScrH() end
local function buildMeshes(item,scale)
    item.stage=stageValues(item,scale)
    for _,part in ipairs(item.parts) do
        if part.buffer then part.buffer:Destroy() part.buffer=nil end
        part.static=fx.static(part.layout,item.stage)
        -- A skinned mesh has no cached buffer: its vertices are skinned on the
        -- CPU and sent on every draw (the game skins into a dynamic buffer too).
        -- Neither has a ribbon (dynamic vertices, 0x141325a50).
        if not part.mesh.skin and not part.ribbon then
            part.buffer=fx.buildMesh(part.mat,part.mesh,part.static)
            P.uploads=P.uploads+1
        end
    end
    item.staticKey=staticKey(scale)
end
local function ensureMeshes(scale)
    local key=staticKey(scale)
    for _,runtime in pairs(P.packages) do
        for _,item in pairs(runtime.items) do if item.staticKey~=key then buildMeshes(item,scale) end end
        for _,item in pairs(runtime.ribbons) do if item.staticKey~=key then buildMeshes(item,scale) end end
    end
end
function P.stop() P.instances={} P.casts={} P.lights={} end
P.cleanup=function()
    P.stop()
    for _,runtime in pairs(P.packages) do for _,item in pairs(runtime.items) do
        for _,part in ipairs(item.parts) do if part.buffer then part.buffer:Destroy() part.buffer=nil end end
        item.staticKey=nil
    end
    for _,item in pairs(runtime.ribbons) do item.staticKey=nil end end
end
local function begin(scale)
    if P.scale~=scale then P.stop() end
    P.scale=scale
    ensureMeshes(scale)
end
-- Trails (trail_core.lua). Every effect animation object launches the trails of its
-- animation (0x1412ba6f0): the effect's own animation, and the animation each particle
-- with an animated resource plays. A set of trails belongs to one such object: while it
-- lives, each of its updates samples the world positions of the edge coordinates, with
-- its animation's time in ticks for the keys (0x1412ba230 -> 0x141325090). When the
-- object goes (effect over or killed, particle dead), the set is released
-- (0x1412ba540 -> 0x14127a090(handle, 0, 0) -> group 0x141322310 -> trail +168 = 1): its
-- trails stop sampling and shrink, one sample per update, then vanish.
-- An edge is looked up in the object's coordinates (0x14132b3f0) by its parent and its
-- name, then by its name alone: the names are the instance names the animation gives
-- its clumps and their coordinates (entry target, clump name), not the chunk names.
local function edgeKey(animation,edge)
    local found
    for key,entry in ipairs(animation.entries) do
        if entry.type==1 and entry.target==edge.coord then
            local clump=entry.clump_index and entry.clump_index>=0 and animation.clumps[entry.clump_index+1]
            if edge.parent and clump and clump.name==edge.parent then return key end
            found=found or key
        end
    end
    return found
end
local function newTrailSet(data,name)
    local definitions=data.trails and data.trails[name]
    if not definitions then return nil end
    local set={animation=data.animations[name],trails={}}
    for _,def in ipairs(definitions) do
        -- Force fields (table 3): their coordinate is looked up once (0x14132b350) with the
        -- parent's key; what that key matches was not traced, so the port tries (parent,
        -- name), then the name. None found: the field sits at the origin, as in the game.
        local fields={}
        for _,field in ipairs(def.fields or {}) do
            fields[#fields+1]={field=field,key=field.coord and edgeKey(set.animation,{coord=field.coord,parent=field.parent})}
        end
        set.trails[#set.trails+1]={def=def,state=trailCore.new(),board=data.resources[def.billboard],updates=0,
            keys={edgeKey(set.animation,def.edges[1]),edgeKey(set.animation,def.edges[2])},fields=fields}
    end
    return set
end
-- One update of a set: result = the owner's evaluated entries, ticks = its animation
-- time; a released set has no time (-1) and no edges.
local NO_EDGE={0,0,0}
local function updateTrailSet(set,result,ticks)
    for _,t in ipairs(set.trails) do
        if set.released then
            t.state.ending=true
            trailCore.update(t.state,t.def,-1,NO_EDGE,NO_EDGE,1,float32)
            t.updates=t.updates+1
        else
            local m0=t.keys[1] and result[t.keys[1]] and result[t.keys[1]].worldMatrix
            local m1=t.keys[2] and result[t.keys[2]] and result[t.keys[2]].worldMatrix
            if m0 and m1 then
                local fields
                if #t.fields>0 then
                    fields={}
                    for i,field in ipairs(t.fields) do
                        fields[i]={field=field.field,matrix=field.key and result[field.key] and result[field.key].worldMatrix or nil}
                    end
                end
                trailCore.update(t.state,t.def,ticks,{m0[4],m0[8],m0[12]},{m1[4],m1[8],m1[12]},1,float32,fields)
                t.updates=t.updates+1
            else t.missing=true end
        end
    end
end
local function trailSetEmpty(set)
    for _,t in ipairs(set.trails) do if #t.state.samples>0 then return false end end
    return true
end
-- After an update of a running effect: a particle set its owner did not update (the
-- particle is gone) is released; released particle sets shrink; empty released sets go.
local function settleTrailSets(a)
    for i=#a.trailSets,1,-1 do
        local set=a.trailSets[i]
        if set.particle then
            if not set.touched then
                set.released=true
                updateTrailSet(set)
            end
            set.touched=false
        end
        if set.released and trailSetEmpty(set) then table.remove(a.trailSets,i) end
    end
end
-- One running effect. outer {pos, yaw, scale} maps game units to the Source
-- world; root is the native effect root matrix inside that space.
local function launch(runtime,effect,options)
    local data=runtime.data
    local animation=data.animations[effect]
    if not animation then return nil,'effect animation not in the package: '..tostring(effect) end
    -- The animation's entries: coordinates the emitters attach to, the models it
    -- carries itself (modelDraws) and the material instances it drives. An entry
    -- or curve kind with no recovered reader makes the effect unplayable.
    local ok,compiled=pcall(runtime.models.compiledFor,effect)
    if not ok then return nil,'animation '..effect..' not playable: '..tostring(compiled) end
    local instance={effect=effect,runtime=runtime,outer=options.outer,root=options.root or M.identity(),
        start=options.start or CurTime(),beforeUpdate=options.beforeUpdate,ticks=0,frame=0,
        modelDraws=compiled.draws,loop=animation.loop~=0,ignoredEntries=compiled.compiled.ignored}
    local provider=anmScene.new(animation,anmModules,{compiled=compiled.compiled,translationScales=compiled.scales,
        rootMatrix=M.identity(),options=anmOptions,materialInstances=runtime.models.instances(compiled)})
    instance.provider=provider
    local clock=anmModules.clock.new(animation.duration_ticks,animation.loop,0,1)
    instance.duration=animation.duration_ticks
    instance.trailSets={}
    local effectTrails=newTrailSet(data,effect)
    if effectTrails then instance.trailSets[1]=effectTrails end
    local function advance()
        if instance.beforeUpdate then instance.beforeUpdate(instance) end
        -- ccGameObjectSkill virtual +78: the actor moves, the root is rebuilt and
        -- handed to the effect, then the animation advances by the host delta (50).
        anmModules.clock.advance(clock,50,float32)
        instance.ticks=instance.ticks+50
        local coordinates=provider:evaluate(clock.ticks,instance.root)
        if effectTrails then
            -- A one-shot effect's object goes when its animation is over.
            if instance.killed or (not instance.loop and instance.ticks>=instance.duration) then effectTrails.released=true end
            updateTrailSet(effectTrails,provider.result,clock.ticks)
        end
        return coordinates
    end
    local emitters=data.effects[effect]
    instance.external={}
    if emitters and #emitters>0 then
        local ok,scene,why=pcall(driver.new,data,effect,modules,{seed=options.seed or 1,fps=FPS,
            coordinates=provider:evaluate(0,instance.root),updateCoordinates=advance,
            -- An emitter or a force attached to a node the effect does not animate
            -- (a bone of the caster, another object): the host puts it at the effect root.
            externalCoordinate=function(name)
                instance.external[name]=true
                local r=instance.root
                return {position={r[4],r[8],r[12]},rotation={r[1],r[2],r[3],r[5],r[6],r[7],r[9],r[10],r[11]}}
            end,
            -- A one-shot effect stops emitting when its animation ends; a looping
            -- one emits until its actor is killed.
            stopEmission=function() return instance.killed or (animation.loop==0 and clock.ticks>=animation.duration_ticks) end,
            afterParticleStep=function(p,rate)
                -- Clump and animated resources carry a model matrix, billboards do not.
                local resource=p.resource and data.resources[p.resource] or {}
                local kind=resource.kind
                if kind=='clump' or kind=='anm' then runtime.models:update(p,rate) end
                -- The trails of an animated resource follow the particle's animation.
                if kind=='anm' and p.modelResult then
                    if p.trailSet==nil then
                        p.trailSet=newTrailSet(data,resource.animation) or false
                        if p.trailSet then
                            p.trailSet.particle=true
                            instance.trailSets[#instance.trailSets+1]=p.trailSet
                        end
                    end
                    if p.trailSet then
                        p.trailSet.touched=true
                        updateTrailSet(p.trailSet,p.modelResult,p.modelInstance.player.clock.ticks)
                    end
                end
            end})
        if not ok then return nil,'effect '..effect..' not playable: '..tostring(scene) end
        if not scene then return nil,why end
        instance.scene=scene
    else
        instance.advance=advance
    end
    local maxTailFrames=0
    -- A released trail shrinks by one sample per update: up to maxSamples more updates.
    local trailSamples=0
    local function samplesOf(name)
        for _,def in ipairs(data.trails and data.trails[name] or {}) do trailSamples=math.max(trailSamples,def.maxSamples) end
    end
    samplesOf(effect)
    for _,e in ipairs(emitters or {}) do
        maxTailFrames=math.max(maxTailFrames,math.ceil(e.life*(1+e.lifeRandom)*FPS/(e.simulationHz or 30)))
        for _,name in ipairs(e.resources or {}) do
            local resource=data.resources[name]
            if resource and resource.kind=='anm' then samplesOf(resource.animation) end
        end
    end
    -- Looping effects run until killed; the cap only stops an effect nobody owns.
    instance.maxFrames=animation.loop~=0 and P.host.maxLoopFrames
        or math.ceil(animation.duration_ticks/50)+maxTailFrames+trailSamples+2
    P.instances[#P.instances+1]=instance
    return instance
end
-- Plays one effect at a fixed root: diagnostic use.
function P.play(packageName,effect,outer,seed)
    local runtime=P.load(packageName)
    begin(outer.scale)
    return launch(runtime,effect,{outer=outer,seed=seed})
end

-- Skill scripts -------------------------------------------------------------
-- A script is a list of actions; an action has a motion class, parameters, an
-- optional animation (the effect it shows) and events. An event fires a
-- command on its actor and may spawn other scripts with a shot type.
-- The object model is ccGameObjectSkill's: one tick is update 0x1405e5240
-- (motion from the second tick of an action on, then events, then the effect
-- root, then the frame counter); motion is storm_amt_lab/skill_actor_core.lua.
-- What the game takes from its world is the host's: the target is one point,
-- the ground and obstacles are traces, a character hit is the actor reaching
-- the target point.
local CLASSES={SKILL_ACTION_TYPE_NONE='none',SKILL_ACTION_TYPE_ARROW='arrow',SKILL_ACTION_TYPE_CRAWLER='crawler',
    SKILL_ACTION_TYPE_SINCURVE='sinCurve',SKILL_ACTION_TYPE_ELEVATOR='elevator',SKILL_ACTION_TYPE_BOUNDBALL='boundBall'}
P.supportedActions={}
for name in pairs(CLASSES) do P.supportedActions[name]=true end
-- Float parameters of an action (table 0x142060bd0); the loader 0x140a67af0
-- converts these three from the 30 Hz reference rate.
local FLOATS={'Amplitude_x','Amplitude_y','Amplitude_z','BankRollMax','BankSpring','BankStrong','Frequency_x','Frequency_y',
    'Frequency_z','Friction','Gravity','Inductivity','RandomDirection','RandomRoll','Restitution','ViewingAngle','Velocity',
    'VelocityRandomize','Rotate_x'}
local RATED={Inductivity=true,Velocity=true,VelocityRandomize=true}
local function parameter(action,name,attribute)
    local list=action.parameters[name]
    return list and list[1] and list[1][attribute or 'value'] or nil
end
local function floats(action)
    if not action.floats then
        action.floats={}
        for _,name in ipairs(FLOATS) do
            local value=float32(tonumber(parameter(action,name)) or 0)
            action.floats[name]=RATED[name] and skillShot.rateAdjustedParameter(value,FPS,float32) or value
        end
    end
    return action.floats
end
local function note(cast,text) if not cast.notes[text] then cast.notes[text]=true cast.log[#cast.log+1]=text end end
local function rootOf(actor)
    local state=actor.state
    return skillShot.effectRoot(state.position,state.orientation,state.roll,1,M,float32,anmOptions.sinf,anmOptions.cosf)
end
local function orient(state) state.orientation=skillShot.orientation(state.orientation,state.velocity,M,float32) end
local function worldPoint(cast,position)
    return cast.outer.pos+Vector(position[1],position[2],position[3])*cast.outer.scale
end
local function gamePoint(cast,point)
    local d=(point-cast.outer.pos)*(1/cast.outer.scale)
    return {float32(d.x),float32(d.y),float32(d.z)}
end
-- Stage query 0x140a620a0 of the ground-following classes: a sweep straight
-- down from just above the object. The host probes from groundProbe above it
-- (so a step up is climbed) and answers with the height of what it meets.
local function groundBelow(cast,state)
    local world=worldPoint(cast,state.position)
    local trace=util.TraceLine({start=world+Vector(0,0,P.host.groundProbe),
        endpos=world-Vector(0,0,30000*cast.outer.scale),mask=MASK_SOLID_BRUSHONLY})
    if trace.Hit and not trace.StartSolid then return float32((trace.HitPos.z-cast.outer.pos.z)/cast.outer.scale) end
    return nil
end
local function setAction(cast,actor,index)
    local action=actor.script.actions[index]
    local state=actor.state
    actor.action,actor.actionIndex,actor.fired,actor.motion=action,index,{},{}
    state.frame=0
    local class=CLASSES[action.type]
    if not class then note(cast,actor.id..': action '..tostring(action.type)..' has no translated motion, played as static') end
    local values=floats(action)
    skillActor.setup(actor.motion,state,values,cast.random,FPS,M,float32,anmOptions.sinf,anmOptions.cosf)
    if class=='elevator' then skillActor.elevatorStart(actor.motion,state,values,float32)
    elseif class=='sinCurve' then skillActor.sinCurveStart(actor.motion,state,values,float32)
    elseif class=='boundBall' then
        skillActor.boundBallStart(actor.motion,state,values,float32)
        note(cast,actor.id..': BOUNDBALL bounces on what the host traces; its rolling and floating on water are not reproduced')
    elseif class=='crawler' then
        -- 0x140a6e430: speed kept, object put on the ground, basis rebuilt.
        skillActor.crawlerStart(actor.motion,state,float32)
        local height=groundBelow(cast,state)
        if height then state.position[3]=height end
        if parameter(action,'FixedUp')=='true' then skillActor.fixedUp(state) end
        orient(state)
    end
    if parameter(action,'SkillHoming') then note(cast,actor.id..': SkillHoming (following another object) is not reproduced') end
    if parameter(action,'Animation','coord') then note(cast,actor.id..': Animation coord attribute is not reproduced') end
    -- <Animation inherite="true"/> keeps the effect of the previous action.
    if parameter(action,'Animation','inherite')=='true' then return end
    if actor.instance then actor.instance.killed=true actor.instance.beforeUpdate=nil actor.instance=nil end
    actor.animationEnded=false
    local chunk=parameter(action,'Animation','chunk')
    if chunk then
        cast.spawned=cast.spawned+1
        local instance,why=launch(cast.package,chunk,{outer=cast.outer,root=rootOf(actor),start=actor.start+actor.frame/FPS,
            seed=cast.seed+cast.spawned-1,beforeUpdate=function() actor.tick() end})
        if instance then
            actor.instance=instance
            for kind,count in pairs(instance.ignoredEntries) do
                note(cast,chunk..': '..count..' animation entries of type '..kind..' (camera, light, ...) are not played')
            end
            for name in pairs(instance.external) do
                note(cast,chunk..': attached to '..name..', a node outside the effect, placed at the effect root')
            end
        else note(cast,actor.id..': '..tostring(why)) end
    end
end
-- Source surface material -> the ground kind of the HIT_WORLD_* events.
-- Hard surfaces the game has no kind for are taken as stone (host choice); a surface
-- of no known material takes P.host.defaultGround.
local MATERIAL={}
for name,ground in pairs({MAT_DIRT='DIRT',MAT_SAND='DIRT',MAT_GRASS='GRASS',MAT_FOLIAGE='GRASS',MAT_SNOW='SNOW',
    MAT_CONCRETE='STONE',MAT_TILE='STONE',MAT_METAL='STONE',MAT_VENT='STONE',MAT_GRATE='STONE',MAT_COMPUTER='STONE',
    MAT_WOOD='STONE',MAT_GLASS='STONE',MAT_PLASTIC='STONE'}) do
    if _G[name] then MATERIAL[_G[name]]=ground end
end
-- Host stand-in for the contact of a resting or crawling object with the world below
-- it (the game's collision query is not traced): a surface within the object's
-- world-hit radius (action Hit hitRadiusWorld, else the script's hit worldHitRadius,
-- game units) above or below it. A contact is reported when it begins and whenever the
-- kind of surface changes, not on every tick: the data's ground variants switch on a
-- surface event and name their own surface again (1efc_e_ge13: action 1 changes to
-- action 1 on DIRT), which a contact reported every tick would restart forever.
local function contact(cast,actor)
    local action=actor.action
    if parameter(action,'WorldHitDisable')=='true' then return end
    local radius=tonumber(parameter(action,'Hit','hitRadiusWorld') or (actor.script.hit and actor.script.hit.worldHitRadius)) or 0
    if radius<=0 then return end
    local at=worldPoint(cast,actor.state.position)
    local reach=Vector(0,0,radius*cast.outer.scale)
    local trace=util.TraceLine({start=at+reach,endpos=at-reach,mask=MASK_SOLID_BRUSHONLY})
    local water=MASK_WATER and util.TraceLine({start=at+reach,endpos=at-reach,mask=MASK_WATER})
    local hit,position,normal
    if water and water.Hit and not water.StartSolid and (not trace.Hit or (water.Fraction or 0)<(trace.Fraction or 1)) then
        hit,position,normal={world=true,water=true,kind='water'},water.HitPos,{0,0,1}
    elseif trace.Hit and not trace.StartSolid then
        local n=trace.HitNormal
        local floor=n~=nil and n.z>.7
        local material=MATERIAL[trace.MatType] or P.host.defaultGround
        hit,position,normal={world=true,floor=floor,wall=not floor,material=material,kind=(floor and 'floor ' or 'wall ')..material},
            trace.HitPos,n and {n.x,n.y,n.z} or {0,0,1}
    end
    local kind=hit and hit.kind or 'none'
    if kind==actor.contactKind then return end
    actor.contactKind=kind
    if hit then actor.hitPosition,actor.hitNormal=gamePoint(cast,position),normal end
    return hit
end
-- Motion of one tick (actor class update, vtable +10). Returns what the host
-- saw the actor meet, or nil: {world=true, floor=, wall=, water=, material=}
-- or {character=true}.
local function move(cast,actor)
    local action,state,motion=actor.action,actor.state,actor.motion
    local class=CLASSES[action.type]
    -- A still object meets the world only by contact (the ones a hit spawns on a surface
    -- to wait for HIT_WORLD_*: 7brteff1_*_e_worldhit00, dust, splash or snow by surface).
    if class=='none' then return contact(cast,actor) end
    if not class then return end
    local values,target=floats(action),cast.target
    local before=worldPoint(cast,state.position)
    local came={state.position[1],state.position[2],state.position[3]}
    if class=='arrow' then skillActor.arrow(motion,state,values,target,orient,float32,math.acos)
    elseif class=='elevator' then skillActor.elevator(motion,state,orient,float32)
    elseif class=='sinCurve' then skillActor.sinCurve(motion,state,values,target,FPS,orient,float32,math.acos,math.sin)
    elseif class=='crawler' then
        skillActor.crawler(motion,state,target,FPS,function(s) return groundBelow(cast,s) end,orient,float32,math.acos,
            parameter(action,'FixedUp')=='true')
    elseif class=='boundBall' then
        skillActor.boundBall(motion,state,target,FPS,function(s)
            local from=worldPoint(cast,s.position)
            local step=Vector(s.velocity[1],s.velocity[2],s.velocity[3])*cast.outer.scale
            local trace=util.TraceLine({start=from,endpos=from+step,mask=MASK_SOLID_BRUSHONLY})
            if not trace.Hit or trace.StartSolid then return nil end
            local n=trace.HitNormal
            return {fraction=float32(trace.Fraction or 0),normal={float32(n.x),float32(n.y),float32(n.z)}}
        end,float32,math.acos)
        -- No orientation update in this class (its basis is the rolling one), and
        -- its contacts are bounces, not the host's hit events.
        return
    end
    local velocity=state.velocity
    local speed=skillActor.length(velocity,float32)
    if not (speed>0) then
        if class=='crawler' then return contact(cast,actor) end
        return
    end
    local hit
    if parameter(action,'WorldHitDisable')~='true' then
        -- Host stand-in for the world-hit events: a crawler only meets walls
        -- taller than a step, other projectiles anything on their path. The
        -- game tells surfaces apart by flags of the stage collision (0x1405e8af4
        -- and on); the host answers with the trace's normal and material.
        local lift=class=='crawler' and Vector(0,0,P.host.stepHeight) or Vector(0,0,0)
        local from,to=before+lift,worldPoint(cast,state.position)+lift
        local trace=util.TraceLine({start=from,endpos=to,mask=MASK_SOLID_BRUSHONLY})
        local water=MASK_WATER and util.TraceLine({start=from,endpos=to,mask=MASK_WATER})
        if water and water.Hit and not water.StartSolid and (not trace.Hit or (water.Fraction or 0)<(trace.Fraction or 1)) then
            hit={world=true,water=true}
            actor.hitPosition,actor.hitNormal=gamePoint(cast,water.HitPos),{0,0,1}
        elseif trace.Hit then
            local n=trace.HitNormal
            local floor=n~=nil and n.z>.7
            hit={world=true,floor=floor,wall=not floor,material=MATERIAL[trace.MatType] or P.host.defaultGround}
            actor.hitPosition=gamePoint(cast,trace.HitPos)
            actor.hitNormal=n and {n.x,n.y,n.z} or {0,0,1}
        end
        -- A crawler keeps to the ground: below a wall it meets the floor it runs on.
        if not hit and class=='crawler' then hit=contact(cast,actor) end
    end
    if not hit and parameter(action,'CharacterHitDisable')~='true' and target then
        -- Host stand-in for the character-hit events: the target point lies on
        -- the step just made, or is now behind the actor.
        local ahead={target[1]-state.position[1],target[2]-state.position[2],target[3]-state.position[3]}
        local behind={target[1]-came[1],target[2]-came[2],target[3]-came[3]}
        local step={state.position[1]-came[1],state.position[2]-came[2],state.position[3]-came[3]}
        local passed=ahead[1]*step[1]+ahead[2]*step[2]+ahead[3]*step[3]<=0
            and behind[1]*step[1]+behind[2]*step[2]+behind[3]*step[3]>=0
        if passed then
            hit={character=true}
            actor.hitPosition={target[1],target[2],target[3]}
            actor.hitNormal={-velocity[1]/speed,-velocity[2]/speed,-velocity[3]/speed}
        end
    end
    return hit
end
local spawnActor
-- The launches an event's <Effect> makes (spawner 0x1405e72f0, then the shot
-- handler of its shotType). The request starts from the actor's basis, or
-- from the named coordinate of its effect; planeDir puts the hit normal in
-- the up axis; targetDir aims at the target.
local function launches(cast,actor,effect,hit)
    local state=actor.state
    local o=state.orientation
    local position={state.position[1],state.position[2],state.position[3]}
    local direction,up={float32(-o[2]),float32(-o[6]),float32(-o[10])},{o[3],o[7],o[11]}
    if effect.coord and effect.coord~='' then
        local c=actor.instance and actor.instance.provider.coordinates and actor.instance.provider.coordinates[effect.coord]
        if c then
            local r=c.rotation
            position={c.position[1],c.position[2],c.position[3]}
            direction,up={float32(-r[2]),float32(-r[5]),float32(-r[8])},{r[3],r[6],r[9]}
        else note(cast,actor.id..': coordinate '..effect.coord..' is not a node of its effect, the actor itself is used') end
    end
    if effect.planeDir=='true' and hit and actor.hitNormal then up=actor.hitNormal end
    local target=cast.target
    local aimed=effect.targetDir=='true'
    local kind=effect.shotType or 'SKILL_SHOT_TYPE_DEFAULT'
    local count,second=math.floor(tonumber(effect.shotParam1) or 0),math.floor(tonumber(effect.shotParam2) or 0)
    local function planed()
        if effect.planeDir=='true' then direction,up=skillActor.planeDirection(direction,up,float32) end
        if aimed then direction=skillActor.aim(position,target,direction,float32) end
        return {{position=position,direction=direction,up=up}}
    end
    if kind=='SKILL_SHOT_TYPE_DEFAULT' then return planed()
    elseif kind=='SKILL_SHOT_TYPE_N_WAY_HORIZONTAL' then
        if aimed then direction=skillActor.aim(position,target,direction,float32) end
        return skillActor.nWay(position,direction,up,count,second,float32,anmOptions.sinf,anmOptions.cosf)
    elseif kind=='SKILL_SHOT_TYPE_RANDOM_CREATION' then
        local out=skillActor.randomCreation(position,direction,up,count,second,cast.random,float32)
        if aimed then for _,launched in ipairs(out) do launched.direction=skillActor.aim(launched.position,target,direction,float32) end end
        return out
    elseif kind=='SKILL_SHOT_TYPE_ENEMY_FOOT' or kind=='SKILL_SHOT_TYPE_HIT_FOOT' then
        -- 0x140a6abe0: the target's position, dropped on the ground below it.
        position={target[1],target[2],target[3]}
        local world=worldPoint(cast,position)
        local trace=util.TraceLine({start=world+Vector(0,0,cast.outer.scale),endpos=world-Vector(0,0,1000*cast.outer.scale),
            mask=MASK_SOLID_BRUSHONLY})
        if trace.Hit and not trace.StartSolid then position=gamePoint(cast,trace.HitPos) end
        if aimed then note(cast,actor.id..': targetDir on a foot shot is not reproduced') end
        return {{position=position,direction=direction,up=up}}
    elseif kind=='SKILL_SHOT_TYPE_ENEMY_TARGET' then
        position={target[1],target[2],target[3]}
        return planed()
    elseif kind=='SKILL_SHOT_TYPE_HIT' then
        -- The contact point the host recorded, else where the actor is.
        if actor.hitPosition then position={actor.hitPosition[1],actor.hitPosition[2],actor.hitPosition[3]} end
        return planed()
    elseif kind=='SKILL_SHOT_TYPE_CONST_AXIS_UP' then
        if aimed then direction=skillActor.aim(position,target,direction,float32) end
        direction,up=skillShot.constAxisUp(direction,anmModules.particle,float32)
        return {{position=position,direction=direction,up=up}}
    end
    note(cast,tostring(effect.name)..': shot type '..tostring(kind)..' is played as DEFAULT')
    return planed()
end
local function fire(cast,actor,event,hit)
    for _,effect in ipairs(event.effects) do
        for _,launched in ipairs(launches(cast,actor,effect,hit)) do spawnActor(cast,effect.name,launched,actor) end
    end
    -- Commands (0x1405e7dc6, enumeration 0x142060d20). KILL and STICK both end
    -- the object (STICK skips the decal KILL can leave); CHANGE_ACTION takes the
    -- action's index; a name outside the enumeration (REMOVE) does nothing.
    local command=event.command
    if command=='SKILL_EVENT_COMMAND_KILL' or command=='SKILL_EVENT_COMMAND_STICK' then
        actor.alive=false
        if actor.instance then actor.instance.killed=true actor.instance.beforeUpdate=nil end
    elseif command=='SKILL_EVENT_COMMAND_CHANGE_ACTION' then
        local index=(tonumber(event.commandParameter) or 0)+1
        if actor.script.actions[index] then setAction(cast,actor,index)
        else note(cast,actor.id..': CHANGE_ACTION to a missing action '..tostring(event.commandParameter)) end
    elseif command=='SKILL_EVENT_COMMAND_SHAKE' then
        note(cast,actor.id..': camera shake is not reproduced')
    end
end
-- World-hit events that name a surface: what the hit must be.
local SURFACE={SKILL_EVENT_TYPE_HIT_WORLD_WATER='water',SKILL_EVENT_TYPE_HIT_WORLD_WALL='wall',
    SKILL_EVENT_TYPE_HIT_WORLD_FLOOR='floor'}
local GROUND={SKILL_EVENT_TYPE_HIT_WORLD_DIRT='DIRT',SKILL_EVENT_TYPE_HIT_WORLD_STONE='STONE',
    SKILL_EVENT_TYPE_HIT_WORLD_GRASS='GRASS',SKILL_EVENT_TYPE_HIT_WORLD_SNOW='SNOW',
    SKILL_EVENT_TYPE_HIT_WORLD_IRONSAND='IRONSAND'}
-- Frame events count ticks of the action at the 30 Hz reference (0x1405e87f3).
local function ticksOf(frames) return math.floor(float32(float32(tonumber(frames) or 0)/float32(30/FPS))) end
local function tick(cast,actor)
    if not actor.alive then return end
    local action,state=actor.action,actor.state
    local hit
    if state.frame>0 then hit=move(cast,actor) end
    -- Events, 0x1405e8690. First pass: frame, animation and the hit events that
    -- name a surface. Second pass: the DEFAULT hit events; the world one only
    -- when no surface event took the hit. A hit event is fired once here (the
    -- host has one target and no hit list).
    local taken=false
    for index,event in ipairs(action.events) do
        if not actor.alive or actor.action~=action then break end
        local kind=event.type
        local now,again=false,false
        if kind=='SKILL_EVENT_TYPE_FRAME_ELAPSED' then now=state.frame==ticksOf(event.arg)
        elseif kind=='SKILL_EVENT_TYPE_FRAME_FIXED' then
            -- Every arg frames, from the first tick on.
            local period=ticksOf(event.arg)
            now,again=period~=0 and state.frame%period==0,true
        elseif kind=='SKILL_EVENT_TYPE_ANIMATION_END' then
            -- 0x1412a3c00: a looping animation never ends. loopCount replays are
            -- counted, not replayed.
            local i=actor.instance
            now=actor.animationEnded or (i~=nil and not i.loop and i.ticks>=i.duration*(tonumber(event.loopCount) or 1))
        elseif hit and hit.world and ((SURFACE[kind] and hit[SURFACE[kind]]) or (GROUND[kind] and hit.material==GROUND[kind])) then
            now,taken=true,true
        end
        if now and (again or not actor.fired[index]) then
            actor.fired[index]=true
            fire(cast,actor,event,hit)
        end
    end
    if hit then for index,event in ipairs(action.events) do
        if not actor.alive or actor.action~=action then break end
        local kind=event.type
        local now=(kind=='SKILL_EVENT_TYPE_HIT_CHARACTER_DEFAULT' and hit.character)
            or (kind=='SKILL_EVENT_TYPE_HIT_WORLD_DEFAULT' and hit.world and not taken)
        if now and not actor.fired[index] then
            actor.fired[index]=true
            fire(cast,actor,event,hit)
        end
    end end
    actor.frame=actor.frame+1
    if not actor.alive then return end
    actor.state.frame=actor.state.frame+1
    if actor.instance then actor.instance.root=rootOf(actor) end
end
-- A launched object (init 0x1405eae00): the direction is its first velocity,
-- its basis comes from the direction and the up axis, guidance is on whenever
-- it has a target, and its first action starts.
spawnActor=function(cast,skillId,launched,parent)
    local script=cast.package.data.skills[skillId]
    if not script then note(cast,'script '..tostring(skillId)..' is not in this package') return end
    if not script.actions[1] then return end
    local d=launched.direction
    local state={position={launched.position[1],launched.position[2],launched.position[3]},velocity={d[1],d[2],d[3]},
        orientation=skillActor.launchBasis(launched.up),roll=0,multiplier=1,frame=0,guidance=cast.target and 1 or 0}
    orient(state)
    local actor={id=skillId,script=script,state=state,alive=true,frame=0,start=parent.start+parent.frame/FPS}
    actor.tick=function() tick(cast,actor) end
    cast.actors[#cast.actors+1]=actor
    setAction(cast,actor,1)
    return actor
end
function P.roots(packageName)
    local data=P.load(packageName).data
    local spawned,roots={},{}
    for _,script in pairs(data.skills) do for _,action in ipairs(script.actions) do for _,event in ipairs(action.events) do
        for _,effect in ipairs(event.effects) do spawned[effect.name]=true end
    end end end
    for id in pairs(data.skills) do if not spawned[id] then roots[#roots+1]=id end end
    table.sort(roots)
    return roots
end
-- shot: {origin=Vector (where the first script starts, on the ground),
-- target=Vector (where the host reports the hit), scale, seed}.
function P.cast(packageName,skillId,shot)
    local runtime=P.load(packageName)
    skillId=skillId or P.roots(packageName)[1]
    if not runtime.data.skills[skillId] then return nil,'script not in the package: '..tostring(skillId) end
    local scale=shot.scale or P.host.scale
    begin(scale)
    local delta=(shot.target-shot.origin)*(1/scale)
    local cast={package=runtime,outer={pos=shot.origin,yaw=0,scale=scale},
        target={float32(delta.x),float32(delta.y),float32(delta.z)},
        seed=shot.seed or 1,random=skillActor.twister(shot.seed or 1),spawned=0,actors={},log={},notes={}}
    -- The first script starts at the origin, level, heading for the target.
    local direction,up=skillShot.constAxisUp({delta.x,delta.y,delta.z},anmModules.particle,float32)
    spawnActor(cast,skillId,{position={0,0,0},direction=direction,up=up},{start=shot.start or CurTime(),frame=0})
    P.casts[#P.casts+1]=cast
    return cast
end
local function castFromPlayer(packageName,skillId,scale,seed)
    local player=LocalPlayer() if not IsValid(player) then return end
    scale=math.Clamp(scale or P.host.scale,.01,5)
    local trace=player:GetEyeTrace()
    local forward=player:GetAimVector() forward.z=0 forward:Normalize()
    local feet=player:GetPos()+forward*(P.host.launchOffset*scale)
    local probe=Vector(0,0,P.host.groundProbe)
    local ground=util.TraceLine({start=feet+probe,endpos=feet-probe,mask=MASK_SOLID_BRUSHONLY})
    local cast,why=P.cast(packageName,skillId,{origin=ground.Hit and ground.HitPos or feet,target=trace.HitPos,scale=scale,seed=seed})
    if not cast then print('Storm FX: '..tostring(why)) return end
    print(string.format('Storm FX %s: %s / %s at scale %.3f',P.version,packageName,cast.actors[1] and cast.actors[1].id or '?',scale))
    return cast
end
P.castFromPlayer=castFromPlayer
concommand.Add('storm_fx_cast',function(_,_,args)
    if not args[1] then print('storm_fx_cast <package> [script] [scale] [seed]') return end
    local skillId=args[2]~='' and args[2]~='-' and args[2] or nil
    castFromPlayer(args[1],skillId,tonumber(args[3]),tonumber(args[4]))
end)
concommand.Add('storm_fx_play',function(_,_,args)
    local player=LocalPlayer() if not IsValid(player) then return end
    if not args[2] then print('storm_fx_play <package> <effect> [scale] [seed]') return end
    local trace=player:GetEyeTrace()
    P.stop()
    -- Stationary identity root at the aim point: the effect's own attachments
    -- place everything relative to it.
    local instance,why=P.play(args[1],args[2],{pos=trace.HitPos,yaw=EyeAngles().y,scale=math.Clamp(tonumber(args[3]) or 1,.01,5)},tonumber(args[4]) or 1)
    if not instance then print('Storm FX: '..tostring(why)) end
end)
concommand.Add('storm_fx_list',function(_,_,args)
    if not args[1] then print('storm_fx_list <package>') return end
    local runtime=P.load(args[1])
    print('Scripts (roots first): '..table.concat(P.roots(args[1]),', '))
    for id,script in pairs(runtime.data.skills) do
        for _,action in ipairs(script.actions) do
            print('  '..id..' action '..tostring(action.id)..' '..tostring(action.type)..' animation '..tostring(parameter(action,'Animation','chunk')))
        end
    end
    for name,emitters in pairs(runtime.data.effects) do print('Effect '..name..': '..#emitters..' emitters') end
    for name,why in pairs(runtime.unsupported) do print('No renderer for model '..name..': '..why) end
    for _,entry in ipairs(runtime.data.unsupported) do print('Not imported: '..entry.what..' ('..entry.reason..')') end
end)
concommand.Add('storm_fx_stop',function() P.stop() end)
concommand.Add('storm_fx_exact',function(_,_,args)
    P.setExact(tonumber(args[1])==1)
    print('Storm FX float32 rounding: '..(exact and 'on (as the game, slower)' or 'off (doubles)'))
end)
concommand.Add('storm_fx_tone',function(_,_,args)
    P.toneMode=math.Clamp(math.floor(tonumber(args[1]) or 0),0,2)
    print('Storm FX stage tone control: '..({[0]='off','on the effect pixels','on the whole screen while an effect plays'})[P.toneMode])
end)
concommand.Add('storm_fx_diag',function()
    print('Storm FX '..P.version..': '..#P.instances..' effects running')
    for _,a in ipairs(P.instances) do
        print('  '..a.effect..' frame='..a.frame..' particles='..(a.scene and #a.scene.particles or 0))
        if a.scene then for name,count in pairs(a.scene.births) do print('    born: '..name..' '..count) end end
        for _,set in ipairs(a.trailSets or {}) do for _,t in ipairs(set.trails) do
            print(string.format('    trail %s#%d: %s, %d samples, %d points, alpha %.2f%s',t.def.animation or '?',t.def.index,
                set.released and 'released' or (set.particle and 'on a particle' or 'on the effect'),#t.state.samples,
                #t.state.points,t.state.alpha,t.missing and ' (an edge is not in the animation: inert)' or ''))
        end end
    end
    print(string.format('CPU: simulation %.3f ms; render %.3f ms (draw list %.3f ms, %d views: %s); draws %d a view; total mesh uploads %d; vertices skinned last frame %d',
        P.updateMs,P.renderMs,P.buildMs,P.calls,table.concat(P.views,', '),P.draws,P.uploads,P.skinnedVertices))
    for index,light in ipairs(P.lights) do
        print(string.format('  light %d (%s): colour %.2f %.2f %.2f intensity %.2f radii %.0f / %.0f%s',index,light.effect,
            light.color[1],light.color[2],light.color[3],light.intensity,light.near,light.far,
            index>4 and ' (beyond the four the game looks at)' or ''))
    end
    for _,cast in ipairs(P.casts) do for _,line in ipairs(cast.log) do print('  script: '..line) end end
    for name,count in pairs(P.skipped) do print('Not rendered: '..name..' ('..count..' latest frame)') end
    for name,why in pairs(P.failed) do print('Effect dropped: '..name..' ('..why..')') end
end)
-- Point lights ---------------------------------------------------------------
-- An effect registers the lights of its animation with the scene when it starts
-- (0x1405fb550 -> ccCmnLightManager 0x14110dac0: in entry order, a light whose
-- two radii are zero being refused) and takes them back when it ends. A light
-- is an animation entry of type 6 outside the clumps, naming its nuccChunkLightPoint
-- (a page-local reference, journal R86): colour, intensity, local position and
-- radii are the entry's curves, the world position is the parent's world matrix x
-- the local position (nuccLightPoint 0x1412c9a40). No light entry of the data has a
-- parent link, so the parent is taken as the animation's root (what the game hangs
-- it on is not traced). Kept here in Source units: world position, radii scaled.
-- When the game takes a light back is not traced: an effect holds its lights as
-- long as it shows its own models.
local function collectLights()
    local lights={}
    for _,a in ipairs(P.instances) do
        local result=a.provider.result
        if result and not a.killed and (a.loop or a.ticks<a.duration) then
            local o=a.outer
            local c,s=math.cos(o.yaw*math.pi/180),math.sin(o.yaw*math.pi/180)
            a.lightAccepted=a.lightAccepted or {}
            for key,item in ipairs(result) do if item.type==6 then
                local fields=item.fields
                local light={color={fields[0x50],fields[0x54],fields[0x58]},intensity=fields[0x60],
                    near=fields[0x88],far=fields[0x8c],effect=a.effect}
                if a.lightAccepted[key]==nil then a.lightAccepted[key]=pointLight.accepted(light) end
                if a.lightAccepted[key] then
                    local m=a.root
                    local x,y,z=fields[0x70],fields[0x74],fields[0x78]
                    local gx,gy,gz=m[1]*x+m[2]*y+m[3]*z+m[4],m[5]*x+m[6]*y+m[7]*z+m[8],m[9]*x+m[10]*y+m[11]*z+m[12]
                    light.position={o.pos.x+(c*gx-s*gy)*o.scale,o.pos.y+(s*gx+c*gy)*o.scale,o.pos.z+gz*o.scale}
                    light.near,light.far=float32(light.near*o.scale),float32(light.far*o.scale)
                    lights[#lights+1]=light
                end
            end end
        end
    end
    return lights
end
-- Point light slot 0 of a model's light set (context fill 0x1413368f0): the
-- lights its light mode hands it for its position, strongest first; the lit
-- shaders read the first. position: the model's origin, in Source units.
function P.lightSlot(position,lightByte)
    local first=P.stage.pointLightModes[lightByte] and pointLight.select(P.lights,position,float32)[1]
    return first and pointLight.constants(first,float32) or pointLight.unused
end
-- Host stand-in: the game lights its stage and characters with these lights; here
-- they become Source dynamic lights, reaching as far as the far radius. Source
-- cannot subtract light, so a light of negative intensity (Amaterasu) is left out.
local function hostLights(lights)
    if not P.host.dynamicLights or not DynamicLight then return end
    for index,light in ipairs(lights) do
        if light.intensity>0 and light.far>0 then
            local d=DynamicLight(P.host.lightIndex+index)
            if d then
                d.pos=Vector(light.position[1],light.position[2],light.position[3])
                d.r,d.g,d.b=math.Clamp(light.color[1]*255,0,255),math.Clamp(light.color[2]*255,0,255),math.Clamp(light.color[3]*255,0,255)
                d.brightness=light.intensity*P.host.lightBrightness
                d.size=light.far
                d.decay=0
                d.dietime=CurTime()+.1
            end
        end
    end
end
hook.Add('Think','StormFxUpdate',function()
    if #P.instances==0 and #P.casts==0 then P.lights={} P.updateMs=0 return end
    local started=SysTime()
    -- Actors that show no effect of their own are stepped here; the others are
    -- stepped by their effect, once per effect update.
    local casts={}
    for _,cast in ipairs(P.casts) do
        local busy=false
        local index=1
        while index<=#cast.actors do
            local actor=cast.actors[index]
            -- An effect that ran out no longer steps its actor; a one-shot
            -- animation that did has ended (the game keeps it at its last frame).
            if actor.instance and actor.instance.finished then
                actor.animationEnded=not actor.instance.loop
                actor.instance=nil
            end
            if actor.alive and not actor.instance then
                local frame=math.floor((CurTime()-actor.start)*FPS)
                while actor.alive and not actor.instance and actor.frame<=frame do
                    actor.tick()
                    -- An actor with no effect and no event that ends it is dropped.
                    if actor.frame>=P.host.maxLoopFrames then actor.alive=false end
                end
            end
            if actor.alive then busy=true end
            index=index+1
        end
        if busy then casts[#casts+1]=cast else cast.finished=true end
    end
    P.casts=casts
    local alive={}
    local index=1
    -- An effect launched during another effect's update joins this same pass.
    while index<=#P.instances do
        local a=P.instances[index]
        local frame=math.floor((CurTime()-a.start)*FPS)
        -- Never discard simulation steps when rendering stalls.
        while a.frame<=frame and a.frame<a.maxFrames and not a.failed do
            -- An effect that hits something the engine cannot simulate is dropped
            -- and reported (storm_fx_diag), it does not stop the others.
            local ok,why=pcall(function()
                if a.scene then a.scene:update() else a.advance() end
                settleTrailSets(a)
            end)
            if not ok then a.failed=tostring(why) P.failed[a.effect]=a.failed end
            a.frame=a.frame+1
        end
        local drained=a.scene and a.scene.emissionStopped and a.scene:isDrained() or (not a.scene and (a.killed or a.ticks>=a.duration))
        for _,set in ipairs(a.trailSets or {}) do if not trailSetEmpty(set) then drained=false end end
        if not (drained or a.failed or a.frame>=a.maxFrames) then alive[#alive+1]=a else a.finished=true end
        index=index+1
    end
    P.instances=alive
    P.lights=collectLights()
    hostLights(P.lights)
    P.updateMs=(SysTime()-started)*1000
end)
local toneMaterial
-- The effects are drawn in the translucent pass by default; P.drawHook='opaque' draws them
-- at the end of the opaque pass instead (comparison of the depth state, storm_fx_perftest).
P.drawHook='translucent'
-- Cost attribution (storm_fx_perftest): steps of the draw loop left out, by name: blend
-- (render.OverrideBlend / OverrideDepthEnable), apply (the material constants), matrix
-- (building the model matrix: one shared matrix is pushed instead), draw (the material
-- bind and the mesh). Empty in play.
P.skip={}
-- The draw list of the frame: built once per frame (FrameNumber) from the main camera and
-- drawn in every view the hook runs for (the main view, water reflection / refraction,
-- other render targets). Offline (no FrameNumber) it is built at every call.
-- P.calls / P.views (render target of each call) / P.buildMs / P.renderMs (all calls) are
-- the frame's figures.
local NO_CONTEXT={}
-- The constant values of one part, refilled in place for every part (fx.pack copies the
-- numbers out at once): no tables made per part. Its metatable falls back on the item's
-- stage values; the optional keys are cleared before each part.
local scratch={g_multColor={0,0,0,1},g_commonParam={0,0,0,0},g_blendRate={0,0,0,0},g_olIdParam={0,0,0,0}}
for name in pairs(INSTANCE) do scratch[name]={0,0,0,0} end
local scratchMeta={}
setmetatable(scratch,scratchMeta)
-- The main view's camera of this frame (RenderScene runs once per frame, before any view
-- is drawn). The draw list is built from it: EyePos / EyeAngles give the camera of the
-- view being drawn, and the first view of a frame can be the water reflection (camera
-- mirrored under the water), which turned the billboards away from the player.
P.mainView={}
hook.Add('RenderScene','StormFxMainView',function(origin,angles)
    P.mainView={frame=FrameNumber(),origin=origin,angles=angles}
end)
local function buildEntries()
    P.skinnedVertices=0
    ensureMeshes(P.scale)
    local main=P.mainView
    local current=main.frame and FrameNumber and main.frame==FrameNumber()
    local view=current and main.angles or EyeAngles() local right,up,forward=view:Right(),view:Up(),view:Forward()
    local normal=right:Cross(up) local eye=current and main.origin or EyePos()
    -- The same as plain numbers (a GMod Vector operation is a C call and a new object).
    local rx,ry,rz,ux,uy,uz,nx,ny,nz=right.x,right.y,right.z,up.x,up.y,up.z,normal.x,normal.y,normal.z
    local ex,ey,ez,kx,ky,kz=eye.x,eye.y,eye.z,forward.x,forward.y,forward.z
    -- Camera-facing hook of a model whose header attribute bit 0 is set (facing_core.lua):
    -- the camera basis (right, up, right x up) is the one the captured camera-facing
    -- draws have. world is in GMod space (outer x game matrix), so a billboard's
    -- offset goes through outer's linear part.
    local function facing(world,board,outer)
        if board then return facingCore.billboard(world,board,right,up,normal,outer,float32) end
        return facingCore.model(world,right,up,normal)
    end
    -- Compute shared values once per rendered frame, not once per particle.
    -- Source's epoch supplies the missing original epoch (about 0.1 per real second).
    local sharedClock=materialContext.originalClock(math.floor(CurTime()*60)*50%2147483648,3000)
    P.skipped={}
    local stage=P.stage
    local entries={}
    -- One draw of a model: every part gets the constants its layout asks for.
    -- frame: billboard keys {uv=atlas rectangle, threshold=alpha threshold}, or
    -- nil. animated: material instances an animation drives (index in the
    -- model's material list -> fields by binder offset), or nil.
    -- draw: the resolved model draw (models only); it carries the skinning palette
    -- of a skinned model and keeps the skinned vertices until the next update.
    local function submit(a,item,world,frame,color,alpha,animated,p,draw)
        if draw and draw.hidden then return end
        -- A host binder can supply scrolling through this hook.
        local context=STORM_FX_SHADER_CONTEXT and STORM_FX_SHADER_CONTEXT(a,p,item) or NO_CONTEXT
        local depth=(world[4]-ex)*kx+(world[8]-ey)*ky+(world[12]-ez)*kz
        local slot      -- point light slot 0 of this model, worked out for the first part that reads it
        for index,part in ipairs(item.parts) do
            -- Material instance: the animated one, else the material's own (binder
            -- 0x1412f5ff0 reads g_uvOffset0..3, g_blendRate, the alpha threshold and
            -- g_commonParam.w from it, then the screen scroll from its uv2 / uv3 scales).
            local m=animated and animated[part.materialIndex]
            local instance=m or part.instance
            local values=scratch
            scratchMeta.__index=item.stage
            values.g_pointLightColor0,values.g_pointLightPos0,values.g_pointLightParam0,values.g_uvOffsetScreen=nil,nil,nil,nil
            local v=values.g_multColor v[1],v[2],v[3]=color[1],color[2],color[3]
            v=values.g_commonParam v[1],v[2],v[4]=frame and frame.threshold or instance[0x80],alpha,instance[0x7c]
            v=values.g_blendRate v[1],v[2]=instance[0x70],instance[0x74]
            values.g_olIdParam[1]=instance[0x84]/255
            for name,at in pairs(INSTANCE) do
                v=values[name] v[1],v[2],v[3],v[4]=instance[at[1]],instance[at[2]],instance[at[3]],instance[at[4]]
            end
            if part.overrideX then values.g_uvOffset2[1]=instance[0x78] end
            if frame and frame.uv then
                local uv=frame.uv v=values.g_uvOffset0 v[1],v[2],v[3],v[4]=uv[1],uv[2],uv[3],uv[4]
            end
            if part.lit then
                slot=slot or P.lightSlot({world[4],world[8],world[12]},item.light)
                values.g_pointLightColor0,values.g_pointLightPos0,values.g_pointLightParam0=slot.color,slot.position,slot.param
            end
            if part.scrolls then
                local clock=context.clockSeconds or sharedClock
                if context.scroll then values.g_uvOffsetScreen=context.scroll
                elseif m then
                    values.g_uvOffsetScreen=materialContext.screenScroll({scroll0={0,0,m[0x60],m[0x64]},scroll1={0,0,m[0x68],m[0x6c]}},clock)
                else
                    if part.lastClock~=clock then
                        part.lastScroll=materialContext.screenScroll({scroll0={0,0,instance[0x60],instance[0x64]},
                            scroll1={0,0,instance[0x68],instance[0x6c]}},clock)
                        part.lastClock=clock
                    end
                    values.g_uvOffsetScreen=part.lastScroll
                end
            end
            local skinned
            if part.mesh.skin and draw and draw.palette then
                draw.skinned=draw.skinned or {}
                skinned=draw.skinned[index]
                if not skinned then
                    local positions,normals=anmModules.skinning.mesh(part.mesh,draw.palette,plain)
                    skinned={positions=positions,normals=normals}
                    draw.skinned[index]=skinned
                    P.skinnedVertices=P.skinnedVertices+#positions
                end
            end
            entries[#entries+1]={item=item,part=part,state=part.state,world=world,layer=item.layer,depth=depth,
                packed=fx.pack(part.layout,values),skinned=skinned}
        end
    end
    for _,a in ipairs(P.instances) do
        local runtime=a.runtime
        local o=a.outer
        local c,s=math.cos(o.yaw*math.pi/180),math.sin(o.yaw*math.pi/180)
        local outer={c*o.scale,-s*o.scale,0,o.pos.x,s*o.scale,c*o.scale,0,o.pos.y,
            0,0,o.scale,o.pos.z,0,0,0,1}
        -- Models the effect's own animation carries: drawn at their animated
        -- coordinate, untinted, with the coordinate's animated opacity, while the
        -- animation runs (a one-shot effect's models are not held after its last
        -- frame, a killed effect's models go at once: host choices, the particles
        -- already born play on as in the captures).
        local result=a.provider.result
        if result and not a.killed and (a.loop or a.ticks<a.duration) then for _,rootDraw in ipairs(a.modelDraws) do
            local item=runtime.items[rootDraw.model]
            if not item then P.skipped[rootDraw.model]=(P.skipped[rootDraw.model] or 0)+1
            else
                -- Resolved once per update of the effect (a skinned model keeps its
                -- skinned vertices until the animation moves again).
                a.resolved=a.resolved or {}
                local kept=a.resolved[rootDraw]
                if not kept or kept.ticks~=a.ticks then
                    kept={ticks=a.ticks,draw=runtime.models.resolve(rootDraw,result,a.root,a.ticks)}
                    a.resolved[rootDraw]=kept
                end
                local draw=kept.draw
                local world=runtime.models:world(draw.matrix,outer)
                if item.facing then world=facing(world,draw.billboard,outer) end
                submit(a,item,world,nil,{1,1,1},(draw.opacity or item.opacity)*(draw.alphaScale or 1),draw.instances,nil,draw)
            end
        end end
        for _,p in ipairs(a.scene and a.scene.particles or {}) do
            -- A particle of an emitter without a resource carries nothing to draw.
            local resource=p.resource and runtime.data.resources[p.resource] or {}
            if resource.kind=='billboard' then
                local item=runtime.items[resource.model]
                if not item then P.skipped[p.resource]=(P.skipped[p.resource] or 0)+1
                else
                    local keys=curves.billboardFromParticle(resource.billboard,p.ageTicks)
                    -- Billboard channels 5 / 6 replace the atlas offset / size of UV set 0,
                    -- channel 12 the alpha threshold.
                    local base=item.parts[1].instance
                    local offset,size=keys[5] or {base[0x30],base[0x34]},keys[6] or {base[0x50],base[0x54]}
                    -- Origin: the particle position through outer (yaw, scale, position);
                    -- axes: the camera's right / up turned by the roll and scaled by the
                    -- size, and the camera normal (in plain numbers).
                    local x,y,z=p.position[1],p.position[2],p.position[3]
                    local px,py,pz=outer[1]*x+outer[2]*y+outer[4],outer[5]*x+outer[6]*y+outer[8],outer[11]*z+outer[12]
                    local roll=billboardRender.roll(p.rotation[2],float32) local rc,rs=math.cos(roll),math.sin(roll)
                    local k1,k2,k3=p.size[1]*o.scale,p.size[2]*o.scale,o.scale
                    submit(a,item,{(rx*rc+ux*rs)*k1,(ux*rc-rx*rs)*k2,nx*k3,px,(ry*rc+uy*rs)*k1,(uy*rc-ry*rs)*k2,ny*k3,py,
                        (rz*rc+uz*rs)*k1,(uz*rc-rz*rs)*k2,nz*k3,pz,0,0,0,1},
                        {uv={offset[1],offset[2],size[1],size[2]},threshold=keys[12] and keys[12][1]/255 or nil},
                        p.color,(keys[4] and keys[4][1] or 1)*p.alpha,nil,p)
                end
            elseif resource.kind=='clump' or resource.kind=='anm' then
                for _,draw in ipairs(runtime.models:draws(p) or {}) do
                    local item=runtime.items[draw.model]
                    if not item then P.skipped[draw.model]=(P.skipped[draw.model] or 0)+1
                    else
                        -- Node opacity scales the alpha of a model: the nuccChunkCoord value for
                        -- a clump, the animated value for an animated resource; billboards get
                        -- it through billboard channel 4. An animated resource is drawn
                        -- untinted (captured g_multColor is 1,1,1,1 for amt15).
                        local world=runtime.models:world(draw.matrix,outer)
                        if item.facing then world=facing(world,draw.billboard,outer) end
                        submit(a,item,world,nil,resource.kind=='anm' and {1,1,1} or p.color,
                            p.alpha*(draw.opacity or item.opacity)*(draw.alphaScale or 1),draw.instances,p,draw)
                    end
                end
            elseif p.resource then P.skipped[p.resource]=(P.skipped[p.resource] or 0)+1 end
        end
        -- Trail ribbons (0x141325a50 then DrawTrail 0x141389f40): world-space vertices
        -- under the identity, the UVs of the billboard's frame (copied during the last
        -- update, then its clock advanced: billboardFromParticle), sorted on the mean
        -- of the vertex positions (renderer 0x141248b70, flag bit 18 clear).
        for _,set in ipairs(a.trailSets or {}) do for _,t in ipairs(set.trails) do
            local item=runtime.ribbons[t.def]
            if not item then P.skipped[t.def.billboard]=(P.skipped[t.def.billboard] or 0)+1
            elseif #t.state.points>1 then
                local board=t.board and t.board.billboard
                -- The game shows the frame one billboard update earlier than one call per
                -- update of the effect gives (capture of 4efb_amt1_blt00, journal R98): as if
                -- the trail were first updated one update after its launch (its updates run
                -- as render-thread jobs; not traced). t.updates-1.
                local keys=board and t.updates>0 and curves.billboardFromParticle(board,t.updates-1) or {}
                -- Billboard +2C8..+2E4: channels 5, 6, 10, 11, or the defaults of 0x1412c8110.
                local o0,s0,o1,s1=keys[5] or {0,0},keys[6] or {1,1},keys[10] or {0,0},keys[11] or {1,1}
                local vertices=trailCore.vertices(t.state,t.def,{o0[1],o0[2],s0[1],s0[2],o1[1],o1[2],s1[1],s1[2]},float32)
                local cx,cy,cz=0,0,0
                for _,v in ipairs(vertices) do
                    local x,y,z=v.position[1],v.position[2],v.position[3]
                    v.position={outer[1]*x+outer[2]*y+outer[3]*z+outer[4],outer[5]*x+outer[6]*y+outer[7]*z+outer[8],
                        outer[9]*x+outer[10]*y+outer[11]*z+outer[12]}
                    cx,cy,cz=cx+v.position[1],cy+v.position[2],cz+v.position[3]
                end
                local n=#vertices
                local depth=(cx/n-ex)*kx+(cy/n-ey)*ky+(cz/n-ez)*kz
                local part=item.parts[1]
                -- g_multColor is the colour of the trail thread's render context (+80, not
                -- traced): white. g_commonParam.w is billboard +2F0 (channel 9), unread by 0x1F007.
                local values=setmetatable({g_multColor={1,1,1,1},
                    g_commonParam={1.1754943508222875e-38,1,1,keys[9] and keys[9][1] or 0}},{__index=item.stage})
                entries[#entries+1]={item=item,part=part,state=part.state,world=IDENTITY,layer=item.layer,depth=depth,
                    packed=fx.pack(part.layout,values),ribbon=vertices}
            end
        end end
    end
    fx.sort(entries)
    -- Model matrices, once per frame (every view of the frame pushes the same ones).
    if not P.skip.matrix then
        for _,entry in ipairs(entries) do
            local transform=Matrix()
            for row=1,4 do for col=1,4 do transform:SetField(row,col,entry.world[(row-1)*4+col]) end end
            entry.matrix=transform
        end
    end
    return entries
end
local function drawEntries(entries)
    P.draws=0
    local current,sceneCopied,masking
    local masked=P.toneMode==1
    local skip=P.skip
    for index,entry in ipairs(entries) do
        local part=entry.part
        -- Tone control on the effect's own pixels: the opaque draws mark the stencil.
        if masked and entry.state.bucket==0 and not masking then post.beginMask() masking=true end
        if masking and entry.state.bucket~=0 then post.endMask() masking=false end
        -- The game copies the scene target once when its refraction layer
        -- starts (capture 22127: event 6632, before the draw at 6763).
        if entry.state.scene and not sceneCopied then
            render.UpdateScreenEffectTexture() sceneCopied=true
        end
        if current~=entry.state then if not skip.blend then fx.begin(entry.state) end current=entry.state end
        if not skip.apply then fx.apply(part.mat,entry.packed) end
        if skip.matrix then skip.shared=skip.shared or Matrix() end
        cam.PushModelMatrix(entry.matrix or skip.shared)
        if not skip.draw then
            render.SetMaterial(part.mat)
            if entry.ribbon then fx.drawRibbon(part.mesh,part.static,entry.ribbon)
            elseif part.mesh.skin then fx.drawSkinned(part.mesh,part.static,entry.skinned) else part.buffer:Draw() end
        end
        P.draws=P.draws+1
        cam.PopModelMatrix()
    end
    if masking then post.endMask() end
    fx.finish()
    if P.toneMode>0 and #entries>0 then
        toneMaterial=toneMaterial or post.material('storm_fx_stage_tone_'..P.version)
        post.draw(toneMaterial,post.pack(P.stage.tone,ScrW(),ScrH()),masked)
    end
end
local built={}
P.calls,P.views,P.buildMs=0,{},0
-- The water's reflection and refraction views (drawn before the main view on a map with
-- water in sight): the effects are left out of them unless storm_fx_water_views is 1
-- (they then show in the water's reflection, at the cost of two more passes of draws).
local WATER_VIEWS={['_rt_waterreflection']=true,['_rt_waterrefraction']=true}
local waterViews=CreateClientConVar and CreateClientConVar('storm_fx_water_views','0',true,false,
    'Storm FX: also draw the effects in the water reflection / refraction views (costs two more passes)')
local function renderEffects(depth,sky,sky3d)
    if depth or sky or sky3d then return end
    if #P.instances==0 then P.draws=0 P.renderMs=0 P.buildMs=0 P.calls=0 built={} return end
    local started=SysTime()
    local frame=FrameNumber and FrameNumber()
    if not frame or built.frame~=frame then
        built={frame=frame,entries=buildEntries()}
        P.buildMs=(SysTime()-started)*1000
        P.calls,P.views,P.renderMs=0,{},0
    end
    P.calls=P.calls+1
    local target=render.GetRenderTarget and render.GetRenderTarget()
    local name=target and string.lower(target:GetName()) or 'frame buffer'
    if WATER_VIEWS[name] and not (waterViews and waterViews:GetBool()) then
        P.views[P.calls]=name..' (left out)'
    else
        P.views[P.calls]=name
        drawEntries(built.entries)
    end
    P.renderMs=P.renderMs+(SysTime()-started)*1000
end
hook.Add('PostDrawTranslucentRenderables','StormFxRender',function(depth,sky,sky3d)
    if P.drawHook=='translucent' then renderEffects(depth,sky,sky3d) end
end)
hook.Add('PostDrawOpaqueRenderables','StormFxRenderOpaque',function(depth,sky,sky3d)
    if P.drawHook=='opaque' then renderEffects(depth,sky,sky3d) end
end)
hook.Add('ShutDown','StormFxCleanup',P.cleanup)
-- storm_fx_selftest: casts a skill, captures the screen, writes a report (data/storm_fx_selftest/).
include('storm_fx/selftest.lua')
-- storm_fx_perftest: occlusion captures and frame times with 0-8 effects.
include('storm_fx/perftest.lua')
-- StormFX: the public interface (StormFX.Play / Cast / Precache / StopAll).
include('storm_fx/api.lua')
return P
