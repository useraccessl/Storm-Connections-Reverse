"""Run the Storm FX addon (storm_fx/, as it ships) with GMod API stubs; this is not GPU
visual validation.

Checks API usage only, on the Amaterasu package: declared vertex channels, the
four custom constants screenspace_general exposes, native blend/depth
overrides and stencil released after the pass, cached meshes, every resource
kind reaching a draw, and the skill script interpreter (begin -> crawler ->
impact). Pixels are checked by verify_port_shaders.py and port_preview.py.
The packages, shaders and textures come from the lab addon (storm_amaterasu_lab).
"""
import sys
from pathlib import Path
ROOT=Path(__file__).resolve().parent
sys.path.insert(0,str(ROOT/'vendor'))
from lupa import LuaRuntime
l=LuaRuntime(unpack_returned_tuples=True)
BASE=ROOT.parent/'storm_amaterasu_lab/lua'
CLEAN=ROOT.parent/'storm_fx/lua'
PACKAGE='4efb_amt1_x'
PREFIX='storm_fx_r28_'+PACKAGE+'_'
def include(name):
    folder=BASE if name.startswith('storm_fx/packages/') else CLEAN
    return l.execute((folder/name).read_text(encoding='utf-8-sig'))
l.globals().include=include
l.execute('''
CLIENT=true SERVER=false function AddCSLuaFile() end
net={Receive=function() end}
unpack=table.unpack or unpack
local vector={}
vector.__index=function(self,k) if type(k)=='number' then return self[({'x','y','z'})[k]] end return vector[k] end
function Vector(x,y,z) return setmetatable({x=x,y=y,z=z},vector) end
function vector.__add(a,b) return Vector(a.x+b.x,a.y+b.y,a.z+b.z) end
function vector.__sub(a,b) return Vector(a.x-b.x,a.y-b.y,a.z-b.z) end
function vector.__unm(a) return Vector(-a.x,-a.y,-a.z) end
function vector.__mul(a,b) return Vector(a.x*b,a.y*b,a.z*b) end
function vector:Dot(b) return self.x*b.x+self.y*b.y+self.z*b.z end
function vector:SetUnpacked(x,y,z) self.x,self.y,self.z=x,y,z end
function vector:Cross(b) return Vector(self.y*b.z-self.z*b.y,self.z*b.x-self.x*b.z,self.x*b.y-self.y*b.x) end
function vector:Rotate(a)
    local c,s=math.cos(a.y*math.pi/180),math.sin(a.y*math.pi/180)
    self.x,self.y=self.x*c-self.y*s,self.x*s+self.y*c
end
function Angle(x,y,z) return {y=y} end
function EyeAngles() return {y=0,Right=function() return Vector(1,0,0) end,
    Up=function() return Vector(0,0,1) end,Forward=function() return Vector(0,1,0) end} end
function EyePos() return Vector(0,-300,60) end
function LocalPlayer() return {GetEyeTrace=function() return {HitPos=Vector(0,0,0),HitNormal=Vector(0,0,1)} end} end
function IsValid(v) return v~=nil end
screenWidth=1920
function ScrW() return screenWidth end function ScrH() return 1080 end
now=0 function CurTime() return now end
function SysTime() return now end
function RunConsoleCommand() end
math.Clamp=function(x,a,b) return math.max(a,math.min(b,x)) end
commands={} hooks={}
concommand={Add=function(name,fn) commands[name]=fn end}
hook={Add=function(event,name,fn) hooks[event]=fn end}
materials={}
function CreateMaterial(name,shader,params)
    assert(shader=='screenspace_general')
    if params['$vertexshader'] then
        for channel=1,7 do local size=params['$tcsize'..channel] assert(size=='2' or size=='4','Texcoord channel '..channel..' must be declared') end
    end
    local m={name=name,params=params,SetFloat=function(self,key,v)
        local n=tonumber(key:match('^%$c(%d)_[xyzw]$'))
        assert(n and n<=3,'screenspace_general has no custom constant '..key);assert(v==v)
    end}
    materials[name]=m;return m
end
rendered={} vertices=0 draws=0 blendOverride=false depthOverride=false stencil=false screenQuads=0
writes={}
local bound,depthWrite
STENCIL_ALWAYS,STENCIL_EQUAL,STENCIL_KEEP,STENCIL_REPLACE=8,3,1,3
render={SetMaterial=function(m) rendered[m.name]=(rendered[m.name] or 0)+1 bound=m.name end,
    OverrideBlend=function(enabled,...) blendOverride=enabled
        if enabled then assert(select('#',...)==6,'Separate colour and alpha blend arguments required') end end,
    OverrideDepthEnable=function(enabled,write) depthOverride=enabled if enabled then depthWrite=write else depthWrite=nil end end,
    UpdateScreenEffectTexture=function() sceneCopies=(sceneCopies or 0)+1 end,
    ClearStencil=function() end,SetStencilEnable=function(on) stencil=on end,SetStencilWriteMask=function() end,
    SetStencilTestMask=function() end,SetStencilReferenceValue=function() end,SetStencilCompareFunction=function() end,
    SetStencilPassOperation=function() end,SetStencilFailOperation=function() end,SetStencilZFailOperation=function() end,
    DrawScreenQuad=function() assert(not blendOverride and not depthOverride,'Screen pass inside the native state') screenQuads=screenQuads+1 end}
MASK_SOLID_BRUSHONLY=1
-- Flat ground at z = 0 and no walls: only downward probes hit.
util={TraceLine=function(t)
    if t.start.z>0 and t.endpos.z<0 then
        return {Hit=true,StartSolid=false,HitPos=Vector(t.start.x,t.start.y,0),HitNormal=Vector(0,0,1),
            Fraction=t.start.z/(t.start.z-t.endpos.z)}
    end
    return {Hit=false,StartSolid=false}
end}
MATERIAL_TRIANGLES=4 MATERIAL_TRIANGLE_STRIP=6 MATERIAL_QUADS=7
local expected,count,building,transform
-- Vertices a mesh of n primitives takes
local function fnExpected(p,n) return p==MATERIAL_TRIANGLE_STRIP and n+2 or p==MATERIAL_QUADS and n*4 or n*3 end
function Matrix() return {values={},SetField=function(self,r,c,v) assert(v==v) self.values[(r-1)*4+c]=v end,
    SetUnpacked=function(self,...) local t={...} assert(select('#',...)==16) for i=1,16 do assert(t[i]==t[i]) self.values[i]=t[i] end end} end
-- A stack, as GMod's (at most two deep here: a skinned part's rigid pieces inside its draw)
local transforms={}
cam={PushModelMatrix=function(m) assert(#transforms<2) transforms[#transforms+1]=m transform=m end,
    PopModelMatrix=function() assert(#transforms>0) transforms[#transforms]=nil transform=transforms[#transforms] end}
function Mesh(material) return {valid=true,vertices=0,Destroy=function(self) self.valid=false end,
    -- Depth test from the material ($depthtest 1, $writedepth 0: GMod's $writedepth 1 makes
    -- the test always pass), depth writes from render.OverrideDepthEnable (journal R107).
    Draw=function(self) assert(self.valid and transform~=nil) assert(blendOverride,'Native blend must be bound')
        assert(depthOverride,'Depth writes must be set by the override') writes[bound]=depthWrite draws=draws+1
        if self.strip then ribbonDraws=ribbonDraws+1 end end} end
ribbonVertices=0 ribbonDraws=0
local dynamic
-- mesh.Begin(IMesh, type, count) fills a mesh (the parts' cached ones, and the batches and
-- trail ribbons of each draw list); mesh.Begin(type, count) draws at once (skinned meshes).
mesh={Begin=function(a,b,c) assert(expected==nil)
        if type(a)=='number' then expected,building,dynamic=fnExpected(a,b),nil,true
        else expected,building,dynamic=fnExpected(b,c),a,false a.strip=b==MATERIAL_TRIANGLE_STRIP end
        count=0 end,
    Position=function(v) for _,x in ipairs({v.x,v.y,v.z}) do assert(x==x and math.abs(x)<1e8) end end,
    TexCoord=function(channel,u,v,s,t)
        assert(channel>=0 and channel<=7 and u==u and v==v and (s==nil or s==s) and (t==nil or t==t))
    end,Color=function() end,
    Normal=function(v) local n=v.x*v.x+v.y*v.y+v.z*v.z assert(n>0.99 and n<1.01,'NUD normals are unit length') end,
    AdvanceVertex=function() count=count+1
        if dynamic then ribbonVertices=ribbonVertices+1 else vertices=vertices+1 end end,
    End=function() assert(count==expected)
        if dynamic then assert(blendOverride and depthOverride,'Native blend and depth writes bound') writes[bound]=depthWrite
            ribbonDraws=ribbonDraws+1
        else building.vertices=count end
        expected=nil building=nil dynamic=nil end}
''')
addon=(CLEAN/'autorun/sh_storm_fx.lua').read_text(encoding='utf-8-sig')
l.execute(addon)
l.execute('StormFX.Config["hiddenModels"]={}')     # every model drawn: hiding is a host choice
g=l.globals()
fx=g.StormFX.Engine
def frames(count,start):
    for frame in range(count):
        g.now=start+frame/60
        g.hooks.Think()
        g.hooks.PostDrawTranslucentRenderables(False,False,False)
        assert not g.blendOverride and not g.depthOverride and not g.stencil,'render overrides must be released every frame'
        yield frame
def play(scale,effect='4efb_amt1_hit00'):
    """storm_fx_play: the effect where the player aims (here the origin), seed 1."""
    g.commands.storm_fx_play(None,None,l.table_from([PACKAGE,effect,scale,'1']))
play('.3')
uploads=g.StormFX.Engine.iUploads      # the parts' cached meshes built (the draw list's own are rebuilt by design)
# One material per NUD mesh (part 1 of each single-mesh model), each with the
# shader pair shader_port.py translated from the game pair of its shader key.
material=lambda name:g.materials[PREFIX+name+'_1'].params
shaders=lambda name:(material(name)['$vertexshader'][:16],material(name)['$pixshader'][:16])
main=material('4efb_amt00')
assert shaders('4efb_amt00')==('storm_fx_09f007_','storm_fx_09f007_'),shaders('4efb_amt00')
assert main['$vertexshader'].endswith('_vs30') and main['$pixshader'].endswith('_ps30')
for file in (main['$vertexshader'],main['$pixshader']):
    assert (BASE.parent/'shaders/fxc'/(file+'.vcs')).exists(),'compiled shader missing from the addon: '+file
assert main['$alpha_blend']=='0','main fire is an opaque alpha-tested draw'
for name,m in g.materials.items():
    if m.params['$vertexshader']:
        assert m.params['$depthtest']=='1' and m.params['$writedepth']=='0',name+': depth test on, writes through the override'
assert shaders('4efb_amt08')[1]=='storm_fx_19f007_'
assert material('4efb_amt02')['$basetexture'].endswith('_cst'),'border-addressed base texture needs the clamped VTF'
assert material('4efb_amt02')['$cull']=='1'
for _ in frames(180,0): pass
assert g.writes[PREFIX+'4efb_amt00_1'] is True,'main fire is drawn with depth writes'
names=list(g.rendered.keys())
assert PREFIX+'1efc_part09b_1' in names
for clump in ('4efb_light00','1efc_fire03a','1efc_shock09','1efc_nor_dst03'):
    assert PREFIX+clump+'_1' in names,clump+' (clump resource) must be drawn'
assert any('amt02' in n for n in names)
assert shaders('1efc_shock09')[1]=='storm_fx_01f008_'
assert material('1efc_shock09')['$vertexnormal']=='1'
assert material('1efc_shock09')['$texture1'].endswith('_cs'),'falloff texture clamps along U'
assert shaders('1efc_nor_dst03')[1]=='storm_fx_03f009_'
assert material('1efc_nor_dst03')['$texture1']=='_rt_FullFrameFB'
assert g.sceneCopies and g.sceneCopies>0,'refraction needs a scene copy'
assert g.vertices>0
assert g.StormFX.Engine.iUploads==uploads,'render frames must not rebuild the cached meshes'
assert g.draws>0 and g.screenQuads==0
print('PASS: 180 frames, finite transforms/constants and cached mesh draws; ZERO per-frame vertex uploads')
print('Models rendered:',len(names),'vertices uploaded once:',uploads,'draws:',g.draws)
runtime=fx.LoadPackage(fx,PACKAGE)
unsupported=dict(runtime.unsupported.items())
assert not unsupported,'every model of the package has a renderer: '+str(unsupported)
# The only note the importer may leave: the trails' render state caveat (journal R98).
left=[f"{e.what}: {e.reason}" for e in runtime.data.unsupported.values()
      if not (str(e.what).startswith('trail ') and 'render state 0x121' in str(e.reason))]
assert not left,'the importer left something behind for this skill: '+str(left)
play('.3')
assert g.StormFX.Engine.iUploads==uploads,'same scale replay must reuse meshes'
g.screenWidth=2560
g.hooks.PostDrawTranslucentRenderables(False,False,False)
assert g.StormFX.Engine.iUploads>uploads,'a resolution change must rebuild the baked ScreenToUV channel'
g.screenWidth=1920
l.execute(addon)
fx=g.StormFX.Engine
play('.5')
g.hooks.PostDrawTranslucentRenderables(False,False,False)
print('PASS: same-scale replay reuses meshes; resolution change, reload cleanup and changed scale rebuild succeed')

play('.3','4efb_amt1_blt00')
uploaded=g.StormFX.Engine.iUploads
before=dict(g.rendered.items()).get(PREFIX+'4efb_amt15_1',0)
for _ in frames(120,g.now): pass
assert fx.LoadPackage(fx,PACKAGE).models.updates>0
assert dict(g.rendered.items()).get(PREFIX+'4efb_amt15_1',0)>before,'animated amt15 model must be drawn'
assert shaders('4efb_amt15')[1]=='storm_fx_19f002_'
assert g.StormFX.Engine.iUploads==uploaded,'animated model must keep uploaded geometry'
assert not list(fx.tSkipped.keys()),dict(fx.tSkipped.items())
assert g.ribbonDraws>0,'the projectile trails (journal R98) must be drawn'
print('PASS: projectile effect alone, animated amt15 model updates/draws, zero per-frame vertex uploads;',
      int(g.ribbonDraws),'trail ribbon draws')

# Whole skill through the script interpreter: begin00 (one frame) -> crawler -> impact.
fx.StopAll(fx)
roots=list(fx.RootScripts(fx,PACKAGE).values())
assert roots==['4efb_amt1_e_begin00','4efb_amt2_e_begin00'],roots
shot=l.table()
shot.origin,shot.target,shot.scale,shot.seed=g.Vector(0,0,0),g.Vector(500,0,0),1,1
cast=fx.CastSkill(fx,PACKAGE,'4efb_amt1_e_begin00',shot)
effects=set();impact=None;most=0;start=g.now
for frame in frames(600,start):
    running=[i.effect for i in fx.tInstances.values()]
    effects.update(running);most=max(most,len(running))
    if impact is None and '4efb_amt1_hit00' in running: impact=frame
    if frame>60 and not running: break
assert effects=={'4efb_amt1_blt00','4efb_amt1_hit00'},effects
# Velocity 25 at the 30 Hz reference is 12.5 units per 60 Hz tick: 500 units take 40 ticks,
# after begin00 (FRAME_ELAPSED 1 is tick 2 at 60 Hz) and the crawler's first tick, which
# does not move (update 0x1405e5240 skips the motion while the action frame is 0).
assert impact is not None and 40<=impact<=43,impact
assert most==2,'projectile particles outlive the kill while the impact plays'
assert not list(fx.tInstances.values()) and not list(fx.tCasts.values()),'the skill must end on its own'
order=[a.id for a in cast.actors.values()]
assert order==['4efb_amt1_e_begin00','4efb_amt1_e_blt00','4efb_amt1_e_hit00'],order
crawler=cast.actors[2]
where=list(crawler.state.position.values())
assert abs(where[0]-500)<13 and abs(where[1])<1e-3 and where[2]==0,where
print('PASS: skill script chain',' -> '.join(order),'; impact at frame',impact,'; everything drains')
print('script notes:',list(cast.log.values()))

# Depth writes of every material drawn so far follow its NUD state (source_factor bit 2).
runtime=fx.LoadPackage(fx,PACKAGE)
checked={True:0,False:0}
for group in (runtime['items'],runtime['ribbons']):
    for item in group.values():
        for part in item.parts.values():
            written=g.writes[part.mat.name]
            if written is not None:
                assert written==bool(part.state.depthWrite),part.mat.name+': depth writes differ from the NUD state'
                checked[written]+=1
assert checked[True] and checked[False],checked
print('PASS: depth writes follow the NUD state through the override:',checked)

# One draw list per frame, built from the main view's camera (RenderScene), also when the
# first view drawn is another one (the water reflection's mirrored camera, journal R107).
fx.StopAll(fx)
play('.3')
for _ in frames(40,g.now): pass
l.execute('''
-- A list per frame here (Config drawRate 0): this checks the camera a list is built from
StormFX.Config["drawRate"]=0
frameNo=100 function FrameNumber() return frameNo end
local push=cam.PushModelMatrix
cam.PushModelMatrix=function(m) pushed[#pushed+1]=m push(m) end
mainEye,mainAngles=EyePos,EyeAngles
function mirroredAngles() return {y=0,Right=function() return Vector(1,0,0) end,
    Up=function() return Vector(0,0.6,0.8) end,Forward=function() return Vector(0,0.8,-0.6) end} end
function mirroredEye() return Vector(0,-300,-60) end
function drawFrame(renderScene,eye,angles)
    frameNo=frameNo+1 pushed={} builds=0
    if renderScene then hooks.RenderScene(mainEye(),mainAngles()) end
    EyePos,EyeAngles=eye,angles
    hooks.PostDrawTranslucentRenderables(false,false,false)     -- first view: the reflection
    local first=#pushed
    EyePos,EyeAngles=mainEye,mainAngles
    hooks.PostDrawTranslucentRenderables(false,false,false)     -- then the main view
    local out={}
    for i,m in ipairs(pushed) do out[i]=table.concat(m.values,',') end
    return table.concat(out,';'),first,#pushed,StormFX.Engine.iCalls
end
''')
mirrored_first,n1,total,calls=g.drawFrame(True,g.mirroredEye,g.mirroredAngles)
main_only,_,_,_=g.drawFrame(False,g.mainEye,g.mainAngles)
wrong,_,_,_=g.drawFrame(False,g.mirroredEye,g.mirroredAngles)
assert calls==2 and total==2*n1 and n1>0,(calls,n1,total)
assert mirrored_first==main_only,'the draw list must come from the main camera, not the first view drawn'
assert wrong!=main_only,'the check must see a camera change'
print('PASS: one draw list per frame,',n1,'draws a view, built from the main camera (RenderScene) whatever view comes first')
# The water's reflection view is left out (storm_fx_water_views 0, the default).
l.execute('''
render.GetRenderTarget=function() return {GetName=function() return '_rt_WaterReflection' end} end
frameNo=frameNo+1 pushed={}
hooks.PostDrawTranslucentRenderables(false,false,false)
waterPushed=#pushed
render.GetRenderTarget=function() return nil end
hooks.PostDrawTranslucentRenderables(false,false,false)
mainPushed=#pushed-waterPushed
''')
assert g.waterPushed==0 and g.mainPushed==n1,(g.waterPushed,g.mainPushed)
assert list(fx.tViews.values())==['_rt_waterreflection (left out)','frame buffer'],list(fx.tViews.values())
print('PASS: the water reflection view is left out by default, the main view draws',g.mainPushed)

# Stage tone control is opt-in and must leave no render state behind.
fx.iToneMode=1
play('.3')
for _ in frames(30,g.now): pass
assert g.screenQuads>0,'tone pass must run when enabled'
fx.iToneMode=0
print('PASS: optional tone pass runs after the native state is released and clears the stencil')
print('LIMIT: API-stub verification only; a live GMod test remains the final check')
