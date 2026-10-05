"""Offline preview of the GMod port, rendered with the port's own compiled shaders.

The Lua player (storm_amaterasu_lab) runs under lupa against recording stubs of
the GMod API. Every mesh draw it issues is then executed in software
(soft_replay): the port's vs_3_0 / ps_3_0 bytecode from the installed .vcs
files, Source's screenspace_general constant layout, and the material or
render.Override* state. The camera, background colour and depth come from a
game capture, so the result is directly comparable with the game's own frame.

What is emulated, not measured: screenspace_general's binding conventions
(c0-c3 custom pixel constants, c4 base-texture texel size, Source's standard
vertex constants cModelViewProj c4, cViewProj c8 and cModel[0] c58), D3D9
vPos, and Source blending for $alpha_blend. A live GMod test remains the
final check.
"""

from __future__ import annotations

import argparse
import io
import json
import math
import struct
import sys
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402

import soft_replay as sr  # noqa: E402
from compile_source_shader import unpack  # noqa: E402
from rd_dump_tools import load, manifest  # noqa: E402

ADDON = ROOT.parent / 'storm_amaterasu_lab'
# The clean addon (storm_fx/): the engine as it ships, loaded through its autorun. The
# reference engine above stays the lab tree; packages, textures and shaders are the lab's.
CLEAN = ROOT.parent / 'storm_fx'
CLEAN_ENTRY = 'autorun/sh_storm_fx.lua'
CAPTURES = ROOT / 'gpu_captures'

LUA_STUBS = r'''
unpack = table.unpack or unpack
local vector = {}
vector.__index = function(self, k)
    if type(k) == 'number' then return rawget(self, ({'x', 'y', 'z'})[k]) end
    return vector[k]
end
function Vector(x, y, z) return setmetatable({x = x or 0, y = y or 0, z = z or 0}, vector) end
function vector.__add(a, b) return Vector(a.x + b.x, a.y + b.y, a.z + b.z) end
function vector.__sub(a, b) return Vector(a.x - b.x, a.y - b.y, a.z - b.z) end
function vector.__unm(a) return Vector(-a.x, -a.y, -a.z) end
function vector.__mul(a, b)
    if type(a) == 'number' then return Vector(b.x * a, b.y * a, b.z * a) end
    if type(b) == 'number' then return Vector(a.x * b, a.y * b, a.z * b) end
    return Vector(a.x * b.x, a.y * b.y, a.z * b.z)
end
function vector:Dot(b) return self.x * b.x + self.y * b.y + self.z * b.z end
function vector:Cross(b) return Vector(self.y * b.z - self.z * b.y, self.z * b.x - self.x * b.z, self.x * b.y - self.y * b.x) end
function vector:Length() return math.sqrt(self:Dot(self)) end
function vector:SetUnpacked(x, y, z) self.x, self.y, self.z = x, y, z end
function vector:Rotate(a)
    local c, s = math.cos(a.y * math.pi / 180), math.sin(a.y * math.pi / 180)
    self.x, self.y = self.x * c - self.y * s, self.x * s + self.y * c
end
function Angle(p, y, r) return {p = p or 0, y = y or 0, r = r or 0} end
PREVIEW = {camera = {}, draws = {}, meshes = {}, materials = {}, now = 0, width = 1920, height = 1080,
    state = {}}
local function cameraVector(name) local v = PREVIEW.camera[name] return Vector(v[1], v[2], v[3]) end
function EyeAngles()
    return {y = PREVIEW.camera.yaw, Right = function() return cameraVector('right') end,
        Up = function() return cameraVector('up') end, Forward = function() return cameraVector('forward') end}
end
function EyePos() return cameraVector('position') end
function LocalPlayer()
    return {GetEyeTrace = function()
        local h = PREVIEW.camera.hit
        return {HitPos = Vector(h[1], h[2], h[3]), HitNormal = Vector(0, 0, 1)}
    end}
end
function IsValid(v) return v ~= nil end
-- World stand-in: one horizontal ground plane at PREVIEW.groundZ, no walls.
MASK_SOLID_BRUSHONLY = 1
util = {TraceLine = function(t)
    local z = PREVIEW.groundZ or 0
    if t.start.z >= z and t.endpos.z <= z and t.start.z ~= t.endpos.z then
        local k = (t.start.z - z) / (t.start.z - t.endpos.z)
        return {Hit = true, StartSolid = false, Fraction = k, HitNormal = Vector(0, 0, 1),
            HitPos = Vector(t.start.x + (t.endpos.x - t.start.x) * k, t.start.y + (t.endpos.y - t.start.y) * k, z)}
    end
    return {Hit = false, StartSolid = false}
end}
function ScrW() return PREVIEW.width end
function ScrH() return PREVIEW.height end
function CurTime() return PREVIEW.now end
function SysTime() return PREVIEW.now end
function RealTime() return PREVIEW.now end
function FrameTime() return 1 / 60 end
function RunConsoleCommand() end
math.Clamp = function(x, a, b) return math.max(a, math.min(b, x)) end
commands, hooks = {}, {}
concommand = {Add = function(name, fn) commands[name] = fn end}
hook = {Add = function(event, name, fn) hooks[event] = fn end, Remove = function() end}
function CreateMaterial(name, shader, params)
    local m = {name = name, shader = shader, params = params, floats = {}}
    function m:SetFloat(key, v) self.floats[key] = v end
    function m:SetTexture(key, v) self.params[key] = v end
    function m:SetInt(key, v) self.floats[key] = v end
    function m:Recompute() end
    function m:IsError() return false end
    function m:GetShader() return self.shader end
    PREVIEW.materials[name] = m
    return m
end
MATERIAL_TRIANGLES, MATERIAL_TRIANGLE_STRIP, MATERIAL_QUADS = 2, 3, 7
MATERIAL_CULLMODE_CCW, MATERIAL_CULLMODE_CW, MATERIAL_CULLMODE_NONE = 0, 1, 2
BLEND_ZERO, BLEND_ONE, BLEND_DST_COLOR, BLEND_ONE_MINUS_DST_COLOR, BLEND_SRC_ALPHA = 0, 1, 2, 3, 4
BLEND_ONE_MINUS_SRC_ALPHA, BLEND_DST_ALPHA, BLEND_ONE_MINUS_DST_ALPHA = 5, 6, 7
BLEND_SRC_ALPHA_SATURATE, BLEND_SRC_COLOR, BLEND_ONE_MINUS_SRC_COLOR = 8, 9, 10
BLENDFUNC_ADD, BLENDFUNC_SUBTRACT, BLENDFUNC_REVERSE_SUBTRACT, BLENDFUNC_MIN, BLENDFUNC_MAX = 0, 1, 2, 3, 4
STENCIL_NEVER, STENCIL_LESS, STENCIL_EQUAL, STENCIL_LESSEQUAL, STENCIL_GREATER = 1, 2, 3, 4, 5
STENCIL_NOTEQUAL, STENCIL_GREATEREQUAL, STENCIL_ALWAYS = 6, 7, 8
STENCIL_KEEP, STENCIL_ZERO, STENCIL_REPLACE = 1, 2, 3
local current, transform, building
function Matrix()
    local m = {values = {1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1}}
    function m:SetField(r, c, v) self.values[(r - 1) * 4 + c] = v end
    function m:GetField(r, c) return self.values[(r - 1) * 4 + c] end
    function m:SetUnpacked(...) local t = {...} for i = 1, 16 do self.values[i] = t[i] end end
    return m
end
-- GMod keeps a stack of model matrices (each push replaces the matrix unless told to multiply)
local transforms = {}
cam = {PushModelMatrix = function(m) transforms[#transforms + 1] = m transform = m end,
       PopModelMatrix = function() transforms[#transforms] = nil transform = transforms[#transforms] end}
render = {
    SetMaterial = function(m) current = m end,
    OverrideBlend = function(enabled, src, dst, fn, srcA, dstA, fnA)
        PREVIEW.state.blend = enabled and {src, dst, fn or 0, srcA or src, dstA or dst, fnA or fn or 0} or nil
    end,
    OverrideDepthEnable = function(enabled, write) PREVIEW.state.depthWrite = enabled and {write} or nil end,
    -- Recorded in draw order: the renderer snapshots its colour target here.
    UpdateScreenEffectTexture = function() PREVIEW.draws[#PREVIEW.draws + 1] = {sceneCopy = true} end,
    -- Stencil: only the two uses the player makes are modelled (mark with
    -- ALWAYS / REPLACE, then test EQUAL).
    ClearStencil = function() PREVIEW.draws[#PREVIEW.draws + 1] = {stencilClear = true} end,
    SetStencilEnable = function(enabled) PREVIEW.state.stencil = enabled or nil end,
    SetStencilWriteMask = function() end, SetStencilTestMask = function() end,
    SetStencilReferenceValue = function(value) PREVIEW.state.stencilReference = value end,
    SetStencilCompareFunction = function(value) PREVIEW.state.stencilCompare = value end,
    SetStencilPassOperation = function(value) PREVIEW.state.stencilPass = value end,
    SetStencilFailOperation = function() end, SetStencilZFailOperation = function() end,
    DrawScreenQuad = function()
        local constants = {}
        for k, v in pairs(current.floats) do constants[k] = v end
        local s = PREVIEW.state
        PREVIEW.draws[#PREVIEW.draws + 1] = {screenQuad = true, material = current.name, constants = constants,
            masked = s.stencil and s.stencilCompare == STENCIL_EQUAL or false}
    end,
    OverrideAlphaWriteEnable = function() end, OverrideColorWriteEnable = function() end,
    CullMode = function(mode) PREVIEW.state.cull = mode end,
    SetBlend = function() end, SetColorModulation = function() end,
    GetRenderTarget = function() return nil end,
}
function Mesh(material)
    local id = #PREVIEW.meshes + 1
    local b = {id = id, vertices = {}, valid = true}
    PREVIEW.meshes[id] = b
    function b:Destroy() self.valid = false end
    function b:IsValid() return self.valid end
    function b:Draw()
        assert(self.valid and transform, 'mesh draw needs a live mesh and a model matrix')
        local constants = {}
        for k, v in pairs(current.floats) do constants[k] = v end
        local values = {}
        for i = 1, 16 do values[i] = transform.values[i] end
        local s = PREVIEW.state
        PREVIEW.draws[#PREVIEW.draws + 1] = {material = current.name, mesh = id, matrix = values, constants = constants,
            blend = s.blend, depthWrite = s.depthWrite, cull = s.cull, tag = PREVIEW.tag,
            stencilWrite = s.stencil and s.stencilCompare == STENCIL_ALWAYS and s.stencilPass == STENCIL_REPLACE
                and s.stencilReference or nil}
    end
    return b
end
local vertex
-- slots: 1-3 position, 4-7 colour, four floats per texcoord channel 0..7, 40-42 normal
local function fresh()
    local v = {0, 0, 0, 1, 1, 1, 1}
    for i = 8, 42 do v[i] = 0 end
    return v
end
mesh = {
    -- mesh.Begin(buffer, type, count) fills a cached mesh; mesh.Begin(type, count) is a
    -- dynamic mesh, drawn at mesh.End with the bound material and model matrix.
    Begin = function(buffer, primitive)
        if type(buffer) == 'number' then
            primitive = buffer
            buffer = Mesh()
            buffer.dynamic = true
            PREVIEW.dynamicVertices = PREVIEW.dynamicVertices or 0
        end
        buffer.strip = primitive == MATERIAL_TRIANGLE_STRIP
        buffer.quads = primitive == MATERIAL_QUADS
        building = buffer vertex = fresh()
    end,
    Position = function(v) vertex[1], vertex[2], vertex[3] = v.x, v.y, v.z end,
    TexCoord = function(channel, u, v, s, t)
        assert(channel >= 0 and channel <= 7, 'texcoord channel out of range')
        local base = 8 + channel * 4
        vertex[base], vertex[base + 1], vertex[base + 2], vertex[base + 3] = u or 0, v or 0, s or 0, t or 0
    end,
    -- Source vertex colours are 8-bit.
    Color = function(r, g, b, a)
        local function q(x) return math.floor(math.max(0, math.min(255, x)) + 0.5) / 255 end
        vertex[4], vertex[5], vertex[6], vertex[7] = q(r), q(g), q(b), q(a)
    end,
    Normal = function(v) vertex[40], vertex[41], vertex[42] = v.x, v.y, v.z end,
    AdvanceVertex = function() building.vertices[#building.vertices + 1] = vertex vertex = fresh() end,
    End = function()
        local built = building
        building = nil
        if built.strip then
            -- A triangle strip, as a list: triangle i is (i, i+1, i+2), the odd ones flipped
            -- (D3D9), each rotated to start where the engine's triangle lists start (the
            -- ribbon's (a, c, b), (c, d, b)); degenerate ones (a vertex sent twice) dropped
            local s, list = built.vertices, {}
            -- Only the first triangle is dropped, when the strip starts with a vertex sent twice
            -- (the engine's parity flip): a ribbon of no width has degenerate ones, as the game's
            local function same(p, q)
                for k = 1, 42 do if p[k] ~= q[k] then return false end end
                return true
            end
            local first = (#s >= 3 and same(s[1], s[2])) and 2 or 1
            for i = first, #s - 2 do
                local a, b, c = s[i], s[i + 1], s[i + 2]
                do
                    if i % 2 == 0 then
                        list[#list + 1], list[#list + 2], list[#list + 3] = a, c, b       -- odd triangle (0-based)
                    else
                        list[#list + 1], list[#list + 2], list[#list + 3] = b, c, a
                    end
                end
            end
            built.vertices = list
        end
        if built.quads then
            -- Quads, as Source's quad index buffer splits them: (0, 1, 2), (0, 2, 3)
            local s, list = built.vertices, {}
            for i = 1, #s - 3, 4 do
                for _, k in ipairs({0, 1, 2, 0, 2, 3}) do list[#list + 1] = s[i + k] end
            end
            built.vertices = list
        end
        if built.dynamic then
            PREVIEW.dynamicVertices = PREVIEW.dynamicVertices + #built.vertices
            built:Draw()
        end
    end,
}
'''

VTF_FORMATS = {13: b'DXT1', 14: b'DXT3', 15: b'DXT5'}
SOURCE_BLEND = {0: 'Zero', 1: 'One', 2: 'DstColor', 3: 'InvDstColor', 4: 'SrcAlpha', 5: 'InvSrcAlpha',
                6: 'DstAlpha', 7: 'InvDstAlpha', 9: 'SrcColor', 10: 'InvSrcColor'}
SOURCE_BLEND_OP = {0: 'Add', 1: 'Subtract', 2: 'ReversedSubtract', 3: 'Min', 4: 'Max'}


def vtf_address(path: Path) -> tuple[str, str]:
    """Address modes a VTF header asks for (TEXTUREFLAGS_CLAMPS 0x4, CLAMPT 0x8)."""
    flags = struct.unpack_from('<I', path.read_bytes()[:24], 20)[0]
    return ('ClampEdge' if flags & 0x4 else 'Wrap'), ('ClampEdge' if flags & 0x8 else 'Wrap')


def vtf_point(path: Path) -> bool:
    """TEXTUREFLAGS_POINTSAMPLE (0x1): point minify, magnify and mip filter."""
    return bool(struct.unpack_from('<I', path.read_bytes()[:24], 20)[0] & 0x1)


def load_vtf_levels(path: Path) -> list[np.ndarray]:
    """Every level of a VTF written by nut_to_vtf.py, largest first (the file stores the smallest first)."""
    raw = path.read_bytes()
    width, height = struct.unpack_from('<HH', raw, 16)
    header_size = struct.unpack_from('<I', raw, 12)[0]
    image_format, count = struct.unpack_from('<I', raw, 52)[0], raw[56]
    block = {13: 8, 14: 16, 15: 16}.get(image_format)
    end, levels = len(raw), []
    for index in range(count):
        w, h = max(width >> index, 1), max(height >> index, 1)
        size = ((w + 3) // 4) * ((h + 3) // 4) * block if block else w * h * 4
        payload = raw[end - size:end]
        end -= size
        if image_format == 12:      # IMAGE_FORMAT_BGRA8888 (nut_to_vtf.py, uncompressed NUTs)
            pixels = np.frombuffer(payload, dtype=np.uint8).reshape(h, w, 4)
            levels.append(pixels[..., [2, 1, 0, 3]].astype(np.float32) / 255.0)
            continue
        dds = bytearray(128)
        dds[:4] = b'DDS '
        struct.pack_into('<7I', dds, 4, 124, 0x1007 | 0x80000, h, w, size, 0, 1)
        struct.pack_into('<2I', dds, 76, 32, 4)
        dds[84:88] = VTF_FORMATS[image_format]
        struct.pack_into('<I', dds, 108, 0x1000)
        image = Image.open(io.BytesIO(bytes(dds) + payload)).convert('RGBA')
        levels.append(np.asarray(image, dtype=np.float32) / 255.0)
    if end != header_size:
        raise ValueError(f'{path.name}: {end - header_size} bytes between the header and the levels')
    return levels


def load_vtf(path: Path) -> np.ndarray:
    return load_vtf_levels(path)[0]


def capture_camera(frame: int) -> dict:
    """Row-vector view-projection of a capture and the derived Source-style camera."""
    records = json.loads((CAPTURES / f'itachi_amaterasu_frame{frame}.all_draws.json').read_text(encoding='utf-8'))
    for d in records:
        fields = d.get('constants', {}).get('ShaderStage.Vertex', {}).get('perMaterialBuffer', {}).get('fields', {})
        if 'g_matWorld' in fields and 'g_matWorldViewProj' in fields:
            world = np.array(fields['g_matWorld']['values'], dtype=np.float64).reshape(4, 4)
            wvp = np.array(fields['g_matWorldViewProj']['values'], dtype=np.float64).reshape(4, 4)
            vp = np.linalg.inv(world) @ wvp
            break
    else:
        raise RuntimeError('no draw with both g_matWorld and g_matWorldViewProj')
    inverse = np.linalg.inv(vp)
    eye = np.array([0, 0, 1, 0]) @ inverse
    eye = eye[:3] / eye[3]
    far = np.array([0, 0, 0.99, 1]) @ inverse
    forward = far[:3] / far[3] - eye
    forward /= np.linalg.norm(forward)
    right = inverse[0, :3] / np.linalg.norm(inverse[0, :3])
    up = inverse[1, :3] - right * np.dot(inverse[1, :3], right)
    up /= np.linalg.norm(up)
    return {'vp': vp, 'position': eye, 'forward': forward, 'right': right, 'up': up,
            'yaw': math.degrees(math.atan2(forward[1], forward[0]))}


class Port:
    def __init__(self, camera: dict, hit, size: tuple[int, int], player: str = 'storm_amt_lab/procedural_player.lua',
                 packages: Path | None = None, engine: str = 'clean'):
        """packages: another addon folder whose lua/ is searched first (survey imports
        go to a scratch addon; the engine itself always comes from the real one).
        engine: 'clean' (storm_fx/, the addon as it ships, loaded through its autorun as a
        client) or 'reference' (the lab tree, storm_amaterasu_lab, kept frozen for
        verify_clean_engine.py); packages come from the lab in both."""
        self.packages = packages
        self.engine = engine
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.execute(LUA_STUBS)
        g = self.lua.globals()

        def include(name):
            if engine == 'clean' and not name.startswith('storm_fx/packages/'):
                path = CLEAN / 'lua' / name
            else:
                path = packages / 'lua' / name if packages and (packages / 'lua' / name).exists() else ADDON / 'lua' / name
            return self.lua.execute(path.read_text(encoding='utf-8-sig'))
        g.include = include
        if engine == 'clean':
            # A client state; the net library only receives here (verify_api feeds it messages).
            self.lua.execute('CLIENT = true SERVER = false function AddCSLuaFile() end '
                             'net = net or {Receive = function(name, fn) NET_RECEIVERS = NET_RECEIVERS or {} NET_RECEIVERS[name] = fn end}')
            player = CLEAN_ENTRY
        cam = g.PREVIEW.camera
        for key in ('position', 'forward', 'right', 'up'):
            cam[key] = self.lua.table_from([float(x) for x in camera[key]])
        cam.yaw = float(camera['yaw'])
        cam.hit = self.lua.table_from([float(x) for x in hit])
        g.PREVIEW.width, g.PREVIEW.height = size
        self.camera = camera
        self.lua.execute(((CLEAN if engine == 'clean' else ADDON) / 'lua' / player).read_text(encoding='utf-8-sig'))
        if engine == 'clean':
            # The checks draw every model: hiding some is a host choice (Config hiddenModels)
            self.lua.execute('StormFX.Config["hiddenModels"] = {}')
        self.programs: dict[str, sr.Program] = {}
        self.textures: dict[str, np.ndarray] = {}
        self.meshes: dict[int, np.ndarray] = {}

    @property
    def fx(self):
        """The engine's own table: STORM_FX (reference) or StormFX.Engine (clean)."""
        g = self.lua.globals()
        return g.StormFX.Engine if self.engine == 'clean' else g.STORM_FX

    def start(self, *args: str, command: str = 'storm_amt_procedural') -> None:
        """The lab's Amaterasu shortcut: storm_amt_procedural <scale> <seed> [blt] plays
        4efb_amt1_hit00 (or blt00) where the player aims; storm_fx_play on the clean addon."""
        commands = self.lua.globals().commands
        if self.engine == 'clean' and command == 'storm_amt_procedural':
            effect = '4efb_amt1_blt00' if len(args) > 2 and args[2] == 'blt' else '4efb_amt1_hit00'
            args, command = ('4efb_amt1_x', effect, *args[:2]), 'storm_fx_play'
        commands[command](None, None, self.lua.table_from(list(args)))

    def load(self, package: str):
        """A package's runtime table (loaded once)."""
        return self.call('LoadPackage', 'load', package)

    def set_tone(self, mode: int) -> None:
        """Stage tone control: 0 off, 1 the effect pixels, 2 the whole screen."""
        if self.engine == 'clean':
            self.fx.iToneMode = mode
        else:
            self.fx.toneMode = mode

    def launch_offset(self) -> float:
        """How far in front of the caster a skill starts (game units)."""
        g = self.lua.globals()
        return float(g.StormFX.Config['launchOffset'] if self.engine == 'clean' else g.STORM_FX.host.launchOffset)

    def cast(self, origin, target, scale: float = 1.0, seed: int = 1, package: str = '4efb_amt1_x', script: str | None = None):
        """Play a whole skill script chain from `origin` (on the ground) toward `target`."""
        g = self.lua.globals()
        g.PREVIEW.groundZ = float(origin[2])
        vector = g.Vector
        shot = self.lua.table()
        shot.origin, shot.target = vector(*map(float, origin)), vector(*map(float, target))
        shot.scale, shot.seed = scale, seed
        cast = self.call('CastSkill', 'cast', package, script, shot)
        if not cast or isinstance(cast, tuple) and cast[0] is None:
            raise RuntimeError(f'skill rejected: {cast}')
        return cast

    def call(self, method: str, function: str, *args):
        """An engine call: the clean engine's method (StormFX.Engine:<method>), else the
        reference engine's function (STORM_FX.<function>)."""
        fx = self.fx
        if self.engine == 'clean' and fx[method] is not None:
            return fx[method](fx, *args)
        return fx[function](*args)

    def field(self, clean: str, reference: str):
        """An engine field: tInstances on the clean engine, instances on the reference."""
        fx = self.fx
        return fx[clean] if self.engine == 'clean' and fx[clean] is not None else fx[reference]

    def play(self, package: str, effect: str, pos, yaw: float = 0.0, scale: float = 1.0, seed: int = 1):
        """Play one effect of a package at `pos` (Source units) with a yaw and a scale."""
        g = self.lua.globals()
        outer = self.lua.table()
        outer.pos, outer.yaw, outer.scale = g.Vector(*map(float, pos)), float(yaw), float(scale)
        return self.call('PlayEffect', 'play', package, effect, outer, seed)

    def roots(self, package: str) -> list[str]:
        return list(self.call('RootScripts', 'roots', package).values())

    def stop(self) -> None:
        self.call('StopAll', 'stop')

    def packages_loaded(self):
        """The engine's loaded packages (runtime tables, by name)."""
        return self.field('tPackages', 'packages')

    def instances(self) -> list:
        return list(self.field('tInstances', 'instances').values())

    def advance(self, frame: int, fps: float = 60.0) -> None:
        g = self.lua.globals()
        g.PREVIEW.now = frame / fps
        g.hooks.Think()

    def collect(self, hook: str = 'PostDrawTranslucentRenderables') -> list[dict]:
        g = self.lua.globals()
        g.PREVIEW.draws = self.lua.table()
        g.PREVIEW.state = self.lua.table()
        for name in ('PreDrawTranslucentRenderables', 'PostDrawOpaqueRenderables'):
            if g.hooks[name]:
                g.PREVIEW.tag = name
                g.hooks[name](False, False, False)
        g.PREVIEW.tag = hook
        g.hooks[hook](False, False, False)
        out = []
        for d in g.PREVIEW.draws.values():
            if d.sceneCopy or d.stencilClear:
                out.append({'sceneCopy': bool(d.sceneCopy), 'stencilClear': bool(d.stencilClear), 'material': '', 'marker': True})
                continue
            if d.screenQuad:
                out.append({'screenQuad': True, 'material': d.material, 'constants': dict(d.constants.items()),
                            'masked': bool(d.masked), 'marker': True})
                continue
            out.append({'material': d.material, 'mesh': d.mesh, 'matrix': np.array(list(d.matrix.values()), dtype=np.float64).reshape(4, 4),
                        'constants': dict(d.constants.items()),
                        'blend': list(d.blend.values()) if d.blend else None,
                        'depthWrite': list(d.depthWrite.values()) if d.depthWrite else None, 'cull': d.cull, 'tag': d.tag,
                        'stencilWrite': d.stencilWrite})
        return out

    def parts(self):
        """(model item, part) for every mesh the loaded packages can draw, trail ribbons
        included (their part has no static mesh: part.ribbon)."""
        for runtime in self.packages_loaded().values():
            for group in ('items', 'ribbons'):          # ['items']: .items is lupa's own method
                for item in (runtime[group] or {}).values():
                    for part in item.parts.values():
                        yield item, part

    def layers(self) -> dict[str, int]:
        """Material name -> nuccChunkModel layer, for every mesh of the loaded packages."""
        return {part.mat.name: item.layer for item, part in self.parts()}

    def named(self, draw: dict) -> dict[str, list]:
        """The per-draw constants of a recorded draw by the game's constant names
        (components the shader does not read stay None). A batched part carries them in its
        vertices: they are read from the draw's first vertex (one particle per draw with the
        batches off, Config batchParticles false)."""
        if not hasattr(self, 'layouts') or draw['material'] not in self.layouts:
            self.layouts = {}
            for _, part in self.parts():
                if part.layout.batched:
                    self.layouts[part.mat.name] = [('vertex', e.name, e.component, e.channel, e.slot) for e in part.layout.static.values()]
                else:
                    self.layouts[part.mat.name] = [('constant', e.name, e.component, e.register, e.slot) for e in part.layout.dynamic.values()]
        out: dict[str, list] = {}
        for source, name, component, where, slot in self.layouts[draw['material']]:
            if source == 'vertex':
                value = float(self.mesh(draw['mesh'])[0][7 + where * 4 + slot])     # mesh rows: 0-based, TEXCOORD n at 8 + 4n (1-based)
            else:
                value = float(draw['constants'][f'$c{where}_{"xyzw"[slot]}'])
            out.setdefault(name, [None] * 4)[component] = value
        return out

    # -- resources -----------------------------------------------------------
    def asset(self, relative: str) -> Path:
        """A shader or texture file: the package addon's copy first, as for the Lua."""
        if self.packages and (self.packages / relative).exists():
            return self.packages / relative
        return ADDON / relative

    def program(self, name: str) -> sr.Program:
        if name not in self.programs:
            self.programs[name] = sr.load_program(unpack(self.asset(f'shaders/fxc/{name}.vcs').read_bytes()))
        return self.programs[name]

    def texture(self, source: str) -> sr.Texture:
        if source not in self.textures:
            path = self.asset(f'materials/{source}.vtf')
            levels = load_vtf_levels(path)
            self.textures[source] = sr.Texture(levels[0], *vtf_address(path), point=vtf_point(path), mips=tuple(levels[1:]))
        return self.textures[source]

    def mesh(self, mesh_id: int) -> np.ndarray:
        if mesh_id not in self.meshes:
            vertices = self.lua.globals().PREVIEW.meshes[mesh_id].vertices
            self.meshes[mesh_id] = np.array([list(v.values()) for v in vertices.values()], dtype=np.float32)
        return self.meshes[mesh_id]

    # -- rendering -----------------------------------------------------------
    def render(self, fb: sr.Framebuffer, draws: list[dict], stats: dict | None = None) -> None:
        materials = self.lua.globals().PREVIEW.materials
        scene = None
        for d in draws:
            if d.get('sceneCopy'):
                # render.UpdateScreenEffectTexture: _rt_FullFrameFB, clamped like any render target.
                scene = sr.Texture(fb.color[0].copy(), 'ClampEdge', 'ClampEdge')
                continue
            if d.get('stencilClear'):
                fb.stencil = np.zeros(fb.depth.shape, dtype=np.uint8)
                continue
            if d.get('screenQuad'):
                self.screen_quad(fb, d, materials[d['material']], scene)
                continue
            material = materials[d['material']]
            params = dict(material.params.items())
            vs = self.program(params['$vertexshader'])
            ps = self.program(params['$pixshader'])
            data = self.mesh(d['mesh'])
            count = len(data)
            ones = np.ones((count, 1), dtype=np.float32)
            streams = {'POSITION0': np.concatenate([data[:, 0:3], ones], axis=1), 'COLOR0': data[:, 3:7],
                       'NORMAL0': np.concatenate([data[:, 39:42], ones], axis=1)}
            for channel in range(8):
                streams[f'TEXCOORD{channel}'] = data[:, 7 + channel * 4:11 + channel * 4]
            # Source's standard vertex constants: cModelViewProj (c4), cViewProj (c8), cModel[0] (c58),
            # each used with a row vector on the left. d['matrix'] is the pushed model matrix.
            m_row = d['matrix'].T @ self.camera['vp']
            vs_constants = np.zeros((64, 4), dtype=np.float32)
            vs_constants[4:8] = m_row.T
            vs_constants[8:12] = self.camera['vp'].T
            vs_constants[58:61] = d['matrix'][:3]
            machine = sr.Machine(vs, count, {'c': vs_constants})
            for semantic, register in vs.inputs.items():
                machine.reg[register] = streams[semantic].copy()
            machine.run()
            position = machine.reg[vs.outputs['POSITION0']]
            varyings = {ps.inputs[sem]: machine.reg[reg] for sem, reg in vs.outputs.items()
                        if sem != 'POSITION0' and sem in ps.inputs and reg in machine.reg}
            ps_constants = np.zeros((32, 4), dtype=np.float32)
            for key, value in d['constants'].items():
                index, axis = int(key[2]), 'xyzw'.index(key[4])
                ps_constants[index, axis] = value
            textures = {}
            for sampler, key in [('s0', '$basetexture')] + [(f's{n}', f'$texture{n}') for n in range(1, 8)]:
                if key in params:
                    if params[key] == '_rt_FullFrameFB':
                        if scene is None:
                            raise RuntimeError('scene texture sampled before render.UpdateScreenEffectTexture')
                        textures[sampler] = scene
                    else:
                        textures[sampler] = self.texture(params[key])
            if 's0' in textures:
                h, w = textures['s0'].data.shape[:2]
                ps_constants[4] = (1.0 / w, 1.0 / h, 0, 0)   # a shader `def c4` wins (soft_replay.Machine.read)

            # A shader that computes its own mip level takes screen derivatives: shade quads.
            quads = sr.takes_derivatives(ps)

            def pixel_shader(n, inputs, ps=ps, ps_constants=ps_constants, textures=textures, quads=quads):
                m = sr.Machine(ps, n, {'c': ps_constants}, textures, quads=quads)
                for register, value in inputs.items():
                    if register != 'position':
                        m.reg[register] = value
                vpos = np.zeros((n, 4), dtype=np.float32)
                vpos[:, :2] = np.floor(inputs['position'][:, :2])
                m.reg['vPos'] = vpos
                m.run()
                return m.reg, m.discard

            # GMod's screenspace_general (win64 stdshader_dx9.dll, shadow state at
            # 0x18004e8e8): $writedepth 1 also sets DepthFunc(ALWAYS), the test always passes.
            state = sr.RenderState(depth_test=params.get('$depthtest', '1') == '1' and params.get('$writedepth', '0') != '1',
                                   depth_write=params.get('$writedepth', '0') == '1',
                                   cull='NoCull' if params.get('$cull', '0') == '0' else 'Back',
                                   blend=params.get('$alpha_blend', '0') == '1',
                                   rgb=('SrcAlpha', 'InvSrcAlpha', 'Add'), alpha=('SrcAlpha', 'InvSrcAlpha', 'Add'))
            if d['blend']:
                b = d['blend']
                state.blend = True
                state.rgb = (SOURCE_BLEND[b[0]], SOURCE_BLEND[b[1]], SOURCE_BLEND_OP[b[2]])
                state.alpha = (SOURCE_BLEND[b[3]], SOURCE_BLEND[b[4]], SOURCE_BLEND_OP[b[5]])
            if d['depthWrite'] is not None:
                state.depth_write = bool(d['depthWrite'][0])
            if d['cull'] is not None:
                state.cull = {0: 'Back', 1: 'Front', 2: 'NoCull'}[d['cull']]
            if d.get('stencilWrite') is not None:
                state.stencil_write = int(d['stencilWrite'])
            triangles = np.arange(count, dtype=np.int64).reshape(-1, 3)
            sr.draw(fb, position, varyings, triangles, pixel_shader, state, ('oC0',), stats, quads=quads)

    def screen_quad(self, fb: sr.Framebuffer, d: dict, material, scene: sr.Texture | None) -> None:
        """render.DrawScreenQuad with a screenspace_general pixel shader, optionally stencil-masked."""
        params = dict(material.params.items())
        ps = self.program(params['$pixshader'])
        if params.get('$basetexture') != '_rt_FullFrameFB' or scene is None:
            raise RuntimeError('screen pass without a scene copy')
        height, width = fb.depth.shape
        selected = (fb.stencil == 1) if d['masked'] else np.ones((height, width), dtype=bool)
        ys, xs = np.nonzero(selected)
        constants = np.zeros((32, 4), dtype=np.float32)
        for key, value in d['constants'].items():
            constants[int(key[2]), 'xyzw'.index(key[4])] = value
        for start in range(0, len(xs), 1 << 20):
            stop = min(start + (1 << 20), len(xs))
            machine = sr.Machine(ps, stop - start, {'c': constants}, {'s0': scene})
            pixel = np.zeros((stop - start, 4), dtype=np.float32)
            pixel[:, 0], pixel[:, 1] = xs[start:stop], ys[start:stop]
            machine.reg['vPos'] = pixel
            machine.run()
            out = np.clip(np.nan_to_num(machine.reg['oC0']), 0.0, 1.0)
            out = np.floor(out * 255.0 + 0.5) / 255.0
            fb.color[0][ys[start:stop], xs[start:stop], :3] = out[:, :3]     # $writealpha 0


def background(frame: int, tag: str, color_id: str, depth_id: str) -> sr.Framebuffer:
    directory = CAPTURES / 'rd_dumps' / f'frame{frame}'
    by = {(e['tag'], e['resource']): e for e in manifest(directory) if 'file' in e}
    color = load(directory, by[(tag, color_id)]).copy()
    depth = np.ascontiguousarray(load(directory, by[(tag, depth_id)])[..., :4]).view(np.float32)[..., 0].copy()
    return sr.Framebuffer([color], depth)


def save_crop(color: np.ndarray, crop, path: Path, factor: int = 2) -> None:
    """Crop (x0, y0, x1, y1) of an RGBA float target, box-filtered down by `factor`."""
    x0, y0, x1, y1 = crop
    region = np.clip(color[y0:y1, x0:x1, :3], 0, 1)
    h, w = region.shape[0] // factor * factor, region.shape[1] // factor * factor
    region = region[:h, :w].reshape(h // factor, factor, w // factor, factor, 3).mean(axis=(1, 3))
    Image.fromarray((region * 255 + 0.5).astype(np.uint8)).save(path)


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--game-raw', nargs=2, action='append', metavar=('NAME', 'RAW'),
                    help='also crop a raw R8G8B8A8 3840x2160 game target dump the same way')
    ap.add_argument('--detail', type=int, nargs=4, metavar=('X0', 'Y0', 'X1', 'Y1'), help='extra 1:1 crop')
    ap.add_argument('--package', default='4efb_amt1_x', help='storm_import.py package played by --skill')
    ap.add_argument('--script', help='script of the package to start with (default: its first root)')
    ap.add_argument('--impact-effect', default='4efb_amt1_hit00', help='effect whose launch is frame 0 for --port-frame')
    ap.add_argument('--tone', type=int, choices=[0, 1, 2], default=0, help='stage tone control: 1 effect pixels, 2 whole screen')
    ap.add_argument('--only', nargs='+', help='keep only draws whose material name contains one of these')
    ap.add_argument('--skip-layers', type=int, nargs='+', help='drop port draws of these nuccChunkModel layers')
    ap.add_argument('--game-tag', nargs='+', help='also crop the game scene target dumped under this manifest tag')
    ap.add_argument('--suffix', default='', help='appended to output file names')
    ap.add_argument('--capture-frame', type=int, default=22136)
    ap.add_argument('--background-tag', default='before_5302')
    ap.add_argument('--port-frame', type=int, nargs='+', default=[60], help='60 Hz frames since the effect started')
    ap.add_argument('--seed', default='1')
    ap.add_argument('--no-batch', action='store_true', help='clean engine: draw the small particles one by one (Config batchParticles false)')
    ap.add_argument('--out', type=Path, default=CAPTURES / 'rd_dumps' / 'port_preview')
    ap.add_argument('--crop', type=int, nargs=4, default=[1300, 0, 3100, 1900], metavar=('X0', 'Y0', 'X1', 'Y1'))
    # Impact root of the captured cast: the light00 ground discs (events 6631-6659
    # of frame 22136) sit at (209.65, -476.38, 5.33) and their attachment is 6
    # units above the effect root.
    ap.add_argument('--root', type=float, nargs=3, default=[209.65, -476.38, -0.68])
    ap.add_argument('--yaw', type=float, default=0.0, help='outer yaw of the stationary diagnostic effect')
    ap.add_argument('--skill', action='store_true',
                    help='play the whole skill from --caster to --root; --port-frame then counts from the impact')
    # Caster of the captured cast: Itachi's eye effect (frame 22136, event 7004) is at (-415.7, -701.2).
    ap.add_argument('--caster', type=float, nargs=2, default=[-415.7, -701.2])
    args = ap.parse_args()
    camera = capture_camera(args.capture_frame)
    effect_camera = dict(camera, yaw=args.yaw)
    port = Port(effect_camera, args.root, (3840, 2160))
    args.out.mkdir(parents=True, exist_ok=True)
    x0, y0, x1, y1 = args.crop
    current = 0
    if args.no_batch:
        port.lua.globals().StormFX.Config['batchParticles'] = False
    if args.tone:
        port.set_tone(args.tone)
    if args.skill:
        offset = port.launch_offset()
        heading = np.array(args.root[:2]) - np.array(args.caster)
        launch = np.array(args.caster) + heading / np.linalg.norm(heading) * offset
        port.cast([launch[0], launch[1], args.root[2]], args.root, 1.0, int(args.seed), args.package, args.script)
        while not any(i.effect == args.impact_effect for i in port.instances()):
            port.advance(current)
            current += 1
            if current > 3600:
                raise SystemExit(f'{args.impact_effect} was never launched')
        impact = current - 1
        print(f'{args.impact_effect} launched at port frame {impact}')
    else:
        port.start('1', args.seed)
        impact = 0
    for target in sorted(args.port_frame):
        while current <= impact + target:
            port.advance(current)
            current += 1
        draws = port.collect()
        if args.only:
            draws = [d for d in draws if d.get('marker') or any(key in d['material'] for key in args.only)]
        if args.skip_layers:
            # Layers the capture's background already contains (the game drew them before the dump).
            layers = port.layers()
            draws = [d for d in draws if d.get('marker') or layers[d['material']] not in args.skip_layers]
        fb = background(args.capture_frame, args.background_tag, 'ResourceId::45595', 'ResourceId::45604')
        stats: dict = {}
        port.render(fb, draws, stats)
        by_material: dict[str, int] = {}
        for d in draws:
            if not d.get('marker'):
                by_material[d['material']] = by_material.get(d['material'], 0) + 1
        print(f'port frame {target}: {len(draws)} draws, {stats.get("pixels", 0)} pixels', by_material)
        save_crop(fb.color[0], args.crop, args.out / f'port_f{target:03d}{args.suffix}.png')
        if args.detail:
            save_crop(fb.color[0], args.detail, args.out / f'port_f{target:03d}{args.suffix}_detail.png', 1)
    for name, raw in (args.game_raw or []):
        game = np.frombuffer(Path(raw).read_bytes(), dtype=np.uint8).reshape(2160, 3840, 4).astype(np.float32) / 255.0
        save_crop(game, args.crop, args.out / f'game_{name}.png')
        if args.detail:
            save_crop(game, args.detail, args.out / f'game_{name}_detail.png', 1)
    for tag in (args.game_tag or []):
        directory = CAPTURES / 'rd_dumps' / f'frame{args.capture_frame}'
        entry = next(e for e in manifest(directory) if 'file' in e and e['tag'] == tag and e['resource'] == 'ResourceId::45595')
        game = load(directory, entry)
        save_crop(game, args.crop, args.out / f'game_{args.capture_frame}_{tag}.png')
        if args.detail:
            save_crop(game, args.detail, args.out / f'game_{args.capture_frame}_{tag}_detail.png', 1)
