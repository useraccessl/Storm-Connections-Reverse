"""Check the translated shaders (shader_port.py) against the game's bytecode.

For a shader key, random scenes are rendered twice in software (soft_replay):
  A. the game's vs_4_0 / ps_4_0 pair with a random constant buffer;
  B. the port's compiled vs_3_0 / ps_3_0 pair fed the way GMod feeds it:
     Source's standard vertex constants (model-view-projection, view-projection,
     model), pixel constants c0-c3 and baked TEXCOORD channels produced by
     the addon's engine/cl_shader_layout.lua from the same constant values.
A scene is a handful of random triangles with random attributes, a random
world / view / projection, random textures and random values for every
constant the pair declares. No capture is involved: this checks the
translation and the constant layout for any key, on synthetic inputs.

  python verify_shader_port.py --keys 0x3f002 0x1f00f
  python verify_shader_port.py --all            # every key shader_port.py --census translated

verify_package_shaders.py runs the same test on the shaders of an imported
skill, with each material's own constants.
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import dataclass
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402
from addon_lua import load_engine_file  # noqa: E402

import soft_replay as sr  # noqa: E402
from shader_library import ShaderLibrary  # noqa: E402
from shader_port import (ADDON, ADDRESS, OBJECT, SHADERS, SUBSTITUTED_TEXTURES, Stage, Unsupported, address_mode, build,  # noqa: E402
                         default_classify, translate)

SIZE = 96
POINT_LIGHT_SUBDIVISION = 12        # triangles of a few pixels, as an effect mesh on screen
POINT_LIGHT_DENSE = 48              # triangles of about a pixel: per vertex and per pixel then coincide
BLEND_TYPES = (0.0, 1.0, 2.0, 3.0)
ADDRESS_MODE = {'wrap': 'Wrap', 'mirror': 'Mirror', 'clamp': 'ClampEdge', 'border': 'ClampBorder', 'mirror_once': 'MirrorOnce'}
FOG_CLAMP = False       # --fog-clamp: measure the per-vertex / per-pixel difference of the fog clamp
SMOOTH_NORMALS = False  # --smooth-normals: measure the per-vertex / per-pixel difference of lighting


@dataclass(frozen=True)
class Sampling:
    """How a material texture is sampled. Game side: the NUD sampler (wrap codes, LOD
    bias, point filter) on a texture of `levels` levels. Port side: the VTF the importer
    picked (`mipped`: the levels of the NUT, else level 0 alone)."""
    wrap_s: int = 1
    wrap_t: int = 1
    width: int = 8
    height: int = 8
    levels: int = 1
    bias: float = 0.0
    point: bool = False
    mipped: bool = False


def look_at(eye, target):
    """Game convention: row vectors, view space looking down -z."""
    f = target - eye
    f /= np.linalg.norm(f)
    r = np.cross(f, [0.0, 1.0, 0.0])
    r /= np.linalg.norm(r)
    u = np.cross(r, f)
    v = np.eye(4)
    v[:3, 0], v[:3, 1], v[:3, 2] = r, u, -f
    v[3, :3] = [-r @ eye, -u @ eye, f @ eye]
    return v


def perspective(fov, near, far):
    s = 1.0 / np.tan(fov / 2)
    p = np.zeros((4, 4))
    p[0, 0], p[1, 1], p[2, 2], p[2, 3], p[3, 2] = s, s, far / (near - far), -1.0, near * far / (near - far)
    return p


def rotation(rng):
    q = rng.normal(size=4)
    q /= np.linalg.norm(q)
    w, x, y, z = q
    return np.array([[1 - 2 * (y * y + z * z), 2 * (x * y + z * w), 2 * (x * z - y * w)],
                     [2 * (x * y - z * w), 1 - 2 * (x * x + z * z), 2 * (y * z + x * w)],
                     [2 * (x * z + y * w), 2 * (y * z - x * w), 1 - 2 * (x * x + y * y)]])


def constant(name: str, rng) -> np.ndarray:
    """A plausible random value for one game constant (4 floats)."""
    if name.startswith('g_uvOffset') and name != 'g_uvOffsetScreen':
        return np.concatenate([rng.uniform(-0.5, 0.5, 2), rng.uniform(0.5, 2.0, 2)])
    if name == 'g_fogParam':
        if FOG_CLAMP:
            # Fog range inside the scene's depth range: the clamp cuts through triangles.
            start = rng.uniform(2.0, 4.0)
            return np.array([start, start + rng.uniform(0.5, 3.0), rng.uniform(0.0, 1.0), 0.0])
        # Fog range around the whole scene (clip w stays within 1..8): no clamp inside a triangle.
        return np.array([rng.uniform(0.1, 0.9), rng.uniform(9.0, 14.0), rng.uniform(0.0, 1.0), 0.0])
    if name == 'g_commonParam':
        return np.array([rng.uniform(0.0, 0.3), rng.uniform(0.3, 1.0), rng.uniform(0, 1), rng.uniform(0, 1)])
    if name == 'g_blendType':
        return np.array([rng.choice(BLEND_TYPES), 0.0, 0.0, 0.0])
    if name == 'g_ScreenToUV':
        return np.array([1.0 / SIZE, 1.0 / SIZE, 0.0, 0.0])
    if name in ('g_uvScaleScreen', 'g_uvScaleNormal', 'g_uvScaleAlpha'):
        return rng.uniform(0.5, 3.0, 4)
    if name == 'g_multColor':
        return rng.uniform(0.2, 1.5, 4)
    if name in OBJECT.values():
        direction = rng.normal(size=3)
        return np.concatenate([direction / np.linalg.norm(direction), [0.0]])
    # A point light among the triangles, reaching part of the scene.
    if name.startswith('g_pointLightPos'):
        return np.concatenate([rng.uniform(-1.5, 1.5, 3), [1.0]])
    if name.startswith('g_pointLightParam'):
        near, far = rng.uniform(0.0, 1.0), rng.uniform(1.5, 4.0)
        return np.array([rng.uniform(0.5, 3.0), near, far, 1.0 / (far - near)])
    return rng.uniform(0.0, 1.0, 4)


# What the context fill gives a point light slot no light uses (0x141336d4a).
UNUSED_POINT_LIGHT = {'g_pointLightColor': (0.0, 0.0, 0.0, 1.0), 'g_pointLightPos': (0.0, 0.0, 0.0, 1.0),
                      'g_pointLightParam': (0.0, 0.0, 1.0, 1.1920928955078125e-07)}


class Scene:
    def __init__(self, rng, triangles=5, uniform_scale=False, fixed=None, addressing=None, subdivide=1, unlit=False,
                 continuous=False):
        """fixed: (constant name, row, component) -> value compiled into the port's shader.
        addressing: game texture name -> Sampling. subdivide: each triangle is cut into
        subdivide^2 smaller ones (attributes interpolated): a dense mesh, on which a
        program run per vertex and the same program run per pixel converge. unlit: the
        point light slots hold the values of a slot no light uses. continuous: every
        texture is sampled on level 0 with the linear filter by both sides, so that a
        coordinate that differs a little gives a colour that differs a little (the test
        textures are noise: the point filter and the choice of a level turn the least
        difference of coordinate into another texel)."""
        self.rng = rng
        self.fixed = fixed or {}
        self.addressing = addressing or {}
        self.continuous = continuous
        n = triangles * 3
        centre = rng.uniform(-0.7, 0.7, (triangles, 1, 3))
        self.position = (centre + rng.uniform(-0.6, 0.6, (triangles, 3, 3))).reshape(n, 3)
        # One normal per triangle by default: a lit vertex program is then constant
        # over the triangle wherever it only depends on the normal. --smooth-normals
        # gives every vertex its own normal, the case where per-vertex and per-pixel
        # lighting differ.
        normal = rng.normal(size=(n, 3)) if SMOOTH_NORMALS else np.repeat(rng.normal(size=(triangles, 3)), 3, axis=0)
        self.normal = normal / np.linalg.norm(normal, axis=1, keepdims=True)
        self.color = np.round(rng.uniform(0.0, 1.0, (n, 4)) * 255.0) / 255.0       # Source mesh colours are bytes
        self.uv0, self.uv1 = rng.uniform(-0.5, 2.0, (n, 2)), rng.uniform(-0.5, 2.0, (n, 2))
        self.triangles = np.arange(n).reshape(-1, 3)
        scale = np.full(3, rng.uniform(0.6, 1.6)) if uniform_scale else rng.uniform(0.6, 1.6, 3)
        world = np.eye(4)
        world[:3, :3] = np.diag(scale) @ rotation(rng)
        world[3, :3] = rng.uniform(-0.3, 0.3, 3)
        eye = np.array([rng.uniform(-1.5, 1.5), rng.uniform(-1.0, 1.5), rng.uniform(3.0, 4.5)])
        view = look_at(eye, rng.uniform(-0.2, 0.2, 3))
        projection = perspective(np.radians(rng.uniform(45, 75)), 0.1, 100.0)
        self.matrices = {'g_matWorldViewProj': world @ view @ projection, 'g_matWorld': world,
                         'g_matWorldInvTrans': np.linalg.inv(world).T, 'g_matWorldViewInvTrans': np.linalg.inv(world @ view).T}
        self.world, self.view_projection = world, view @ projection
        self.values: dict[str, np.ndarray] = {}
        self.textures: dict[str, np.ndarray] = {}
        if unlit:
            for name, value in UNUSED_POINT_LIGHT.items():
                for slot in range(4):
                    self.values[f'{name}{slot}'] = np.array(value, dtype=np.float32)
        if subdivide > 1:
            self.subdivide(subdivide)

    def subdivide(self, k: int) -> None:
        """Cut every triangle into k^2: vertices on a barycentric grid, normals
        renormalised, colours rounded to bytes again."""
        weights, index = [], {}
        for i in range(k + 1):
            for j in range(k + 1 - i):
                index[(i, j)] = len(weights)
                weights.append((i / k, j / k, 1.0 - (i + j) / k))
        weights = np.array(weights)
        cells = []
        for i in range(k):
            for j in range(k - i):
                cells.append((index[(i, j)], index[(i + 1, j)], index[(i, j + 1)]))
                if i + j < k - 1:
                    cells.append((index[(i + 1, j)], index[(i + 1, j + 1)], index[(i, j + 1)]))
        cells = np.array(cells)
        corners = self.triangles                                            # (T, 3) indices of the coarse vertices
        mix = lambda a: np.einsum('gc,tcd->tgd', weights, a[corners]).reshape(-1, a.shape[1])
        normal = mix(self.normal)
        self.position, self.uv0, self.uv1 = mix(self.position), mix(self.uv0), mix(self.uv1)
        self.normal = normal / np.linalg.norm(normal, axis=1, keepdims=True)
        self.color = np.round(mix(self.color) * 255.0) / 255.0
        per = len(weights)
        self.triangles = (cells[None, :, :] + (np.arange(len(corners)) * per)[:, None, None]).reshape(-1, 3)

    def value(self, name: str) -> np.ndarray:
        if name in self.matrices:
            return self.matrices[name].reshape(-1)
        if name in OBJECT and name not in self.values:
            # What the game's context fill gives the shader: inverse(model) * the stage
            # vector (0x141280580 then 0x141283c40, checked by running them). self.world
            # is the row-vector matrix (row k = image of axis k).
            stage = self.value(OBJECT[name])[:3].astype(np.float64)
            self.values[name] = np.concatenate([np.linalg.inv(self.world[:3, :3]).T @ stage, [0.0]]).astype(np.float32)
        if name not in self.values:
            value = constant(name, self.rng).astype(np.float32)
            for (fixed_name, row, comp), fixed_value in self.fixed.items():
                if fixed_name == name:
                    if row * 4 + comp >= len(value):
                        value = np.concatenate([value, np.zeros(row * 4 + comp + 1 - len(value), dtype=np.float32)])
                    value[row * 4 + comp] = fixed_value
            self.values[name] = value
        return self.values[name]

    def levels(self, name: str) -> list[np.ndarray]:
        """The levels of a texture, each with its own random texels: a level picked
        wrongly cannot go unnoticed."""
        if name not in self.textures:
            if name in SUBSTITUTED_TEXTURES:
                # What the port assumes for a texture it does not have (documented deviation).
                self.textures[name] = [np.full((2, 2, 4), SUBSTITUTED_TEXTURES[name][0], dtype=np.float32)]
            else:
                # The border addressing and the level of detail of the port depend on the texture size.
                s = self.addressing.get(name, Sampling())
                self.textures[name] = [self.rng.uniform(0.0, 1.0, (max(s.height >> i, 1), max(s.width >> i, 1), 4)).astype(np.float32)
                                       for i in range(s.levels)]
        return self.textures[name]

    def texture(self, name: str) -> np.ndarray:
        return self.levels(name)[0]

    def game_texture(self, name: str) -> sr.Texture:
        """The texture as the game samples it: address modes, filter and LOD bias of the NUD sampler."""
        s, levels = self.addressing.get(name, Sampling()), self.levels(name)
        if self.continuous:
            return sr.Texture(levels[0], ADDRESS_MODE[address_mode(s.wrap_s)], ADDRESS_MODE[address_mode(s.wrap_t)])
        return sr.Texture(levels[0], ADDRESS_MODE[address_mode(s.wrap_s)], ADDRESS_MODE[address_mode(s.wrap_t)],
                          point=s.point, mips=tuple(levels[1:]), bias=s.bias)

    def port_texture(self, name: str) -> sr.Texture:
        """The texture as its VTF offers it: wrap, or clamp for every other mode; level 0
        alone, or the whole chain with zeros below the levels the game's texture has."""
        s, levels = self.addressing.get(name, Sampling()), self.levels(name)
        mips = ()
        if self.continuous:
            return sr.Texture(levels[0], 'Wrap' if address_mode(s.wrap_s) == 'wrap' else 'ClampEdge',
                              'Wrap' if address_mode(s.wrap_t) == 'wrap' else 'ClampEdge')
        if s.mipped:
            chain = max(s.width, s.height).bit_length()
            mips = tuple(levels[1:]) + tuple(np.zeros((max(s.height >> i, 1), max(s.width >> i, 1), 4), dtype=np.float32)
                                             for i in range(s.levels, chain))
        return sr.Texture(levels[0], 'Wrap' if address_mode(s.wrap_s) == 'wrap' else 'ClampEdge',
                          'Wrap' if address_mode(s.wrap_t) == 'wrap' else 'ClampEdge', point=s.point, mips=mips)

    def attributes(self) -> dict[str, np.ndarray]:
        n = len(self.position)
        pad = lambda a, w: np.concatenate([a, np.zeros((n, 3 - a.shape[1])), np.full((n, 1), w)], axis=1).astype(np.float32)
        return {'POSITION0': pad(self.position, 1.0), 'NORMAL0': pad(self.normal, 1.0), 'COLOR0': self.color.astype(np.float32),
                'TEXCOORD0': pad(self.uv0, 1.0), 'TEXCOORD1': pad(self.uv1, 1.0)}


def constants(stage: Stage, scene: Scene) -> dict[str, np.ndarray]:
    out: dict[str, np.ndarray] = {}
    for (cb, register, comp), (name, row, col, _) in stage.floats.items():
        array = out.setdefault(cb, np.zeros((64, 4), dtype=np.float32))
        value = scene.value(name)
        array[register, comp] = value[row * 4 + col] if row * 4 + col < len(value) else 0.0
    return out


def blank() -> sr.Framebuffer:
    return sr.Framebuffer([np.full((SIZE, SIZE, 4), 0.5, dtype=np.float32)], np.ones((SIZE, SIZE), dtype=np.float32))


STATE = sr.RenderState(depth_test=False, depth_write=False, cull='NoCull')


def render_game(vs: Stage, ps: Stage, scene: Scene) -> sr.Framebuffer:
    attributes = scene.attributes()
    machine = sr.Machine(vs.program, len(scene.position), constants(vs, scene))
    for s in vs.inputs:
        machine.reg[f'v{s["register"]}'] = attributes[s['semantic']].copy()
    machine.run()
    position = next(f'o{s["register"]}' for s in vs.outputs if s['semantic'].startswith('SV_P'))
    screen = next((f'v{s["register"]}' for s in ps.inputs if s['semantic'].startswith('SV_P')), None)
    varyings = {'v' + name[1:]: value for name, value in machine.reg.items() if name.startswith('o') and name != position}
    ps_constants = constants(ps, scene)
    textures = {register: scene.game_texture(name) for register, name in ps.textures.items()}
    # A texture with several levels picks one from the screen derivatives: shade quads.
    quads = any(texture.mips for texture in textures.values())

    def pixel(n, values):
        m = sr.Machine(ps.program, n, ps_constants, textures, quads=quads)
        for register, value in values.items():
            if register != 'position':
                m.reg[register] = value
        if screen:
            sv = values['position'].copy()
            sv[:, 3] = 1.0 / sv[:, 3]            # SV_Position.w is the clip w
            m.reg[screen] = sv
        m.run()
        return m.reg, m.discard

    fb = blank()
    sr.draw(fb, machine.reg[position], varyings, scene.triangles, pixel, STATE, ('o0',), quads=quads)
    return fb


class PortRunner:
    def __init__(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.lua.globals().include = lambda name: self.lua.execute((ADDON / 'lua' / name).read_text(encoding='utf-8-sig'))
        self.layout_module = load_engine_file(self.lua, 'shader_layout')
        self.programs: dict[str, sr.Program] = {}

    def table(self, value):
        """Python layout (lists / dicts) -> the Lua table the engine reads from a package."""
        if isinstance(value, dict):
            out = self.lua.table()
            for k, v in value.items():
                if v is not None:
                    out[k] = self.table(v)
            return out
        if isinstance(value, (list, tuple)):
            return self.lua.table_from([self.table(v) for v in value])
        return value

    def program(self, name: str) -> sr.Program:
        if name not in self.programs:
            self.programs[name] = sr.load_program((SHADERS / f'{name}.bin').read_bytes())
        return self.programs[name]

    def render(self, layout: dict, scene: Scene) -> sr.Framebuffer:
        vs, ps = self.program(layout['vertex']), self.program(layout['pixel'])
        layout_lua = self.table(layout)
        values = self.lua.table()
        for entry in layout['dynamic'] + layout['static']:
            name = entry['name']
            values[name] = self.lua.table_from([0.0, 0.0] if name.startswith(ADDRESS) else [float(x) for x in scene.value(name)])
        packed = [list(v.values()) for v in self.layout_module.Pack(layout_lua, values).values()]
        static = [list(v.values()) for v in self.layout_module.Static(layout_lua, values).values()]
        attributes = scene.attributes()
        n = len(scene.position)
        inputs = {'POSITION0': attributes['POSITION0'], 'NORMAL0': attributes['NORMAL0'], 'COLOR0': attributes['COLOR0'],
                  'TEXCOORD0': attributes['TEXCOORD0']}
        for channel, baked in enumerate(static, start=1):      # two or four floats per channel
            inputs[f'TEXCOORD{channel}'] = np.tile(np.array((baked + [0.0, 1.0])[:4], dtype=np.float32), (n, 1))
        if layout['attributes']['uv1']:
            inputs['TEXCOORD1'] = attributes['TEXCOORD1']
        if layout.get('gpuSkin'):
            # A rigid studio vertex: one bone, normal +Z in Source's
            # compressed UBYTE4 format, weights in SHORT2 format.
            inputs['BLENDWEIGHT0'] = np.tile(np.array([32767, -1, 0, 0], dtype=np.float32), (n, 1))
            inputs['BLENDINDICES0'] = np.zeros((n, 4), dtype=np.float32)
            inputs['NORMAL0'] = np.tile(np.array([192, 192, 0, 0], dtype=np.float32), (n, 1))
        c = np.zeros((256 if layout.get('gpuSkin') else 64, 4), dtype=np.float32)
        c[4:8] = scene.matrices['g_matWorldViewProj'].T
        c[8:12] = scene.view_projection.T
        c[58:61] = scene.world.T[:3]
        machine = sr.Machine(vs, n, {'c': c})
        for semantic, register in vs.inputs.items():
            machine.reg[register] = inputs[semantic].copy()
        machine.run()
        self.vertex_outputs = {semantic: machine.reg[register].copy() for semantic, register in vs.outputs.items()}
        varyings = {ps.inputs[sem]: machine.reg[reg] for sem, reg in vs.outputs.items()
                    if sem != 'POSITION0' and sem in ps.inputs and reg in machine.reg}
        ps_constants = np.zeros((8, 4), dtype=np.float32)
        ps_constants[:4] = np.array(packed, dtype=np.float32)
        textures = {f's{i}': scene.port_texture(s['name']) for i, s in enumerate(layout['samplers'])}
        quads = sr.takes_derivatives(ps)

        def pixel(count, values_in):
            m = sr.Machine(ps, count, {'c': ps_constants}, textures, quads=quads)
            for register, value in values_in.items():
                if register != 'position':
                    m.reg[register] = value
            vpos = np.zeros((count, 4), dtype=np.float32)
            vpos[:, :2] = np.floor(values_in['position'][:, :2])
            m.reg['vPos'] = vpos
            m.run()
            return m.reg, m.discard

        fb = blank()
        sr.draw(fb, machine.reg[vs.outputs['POSITION0']], varyings, scene.triangles, pixel, STATE, ('oC0',), quads=quads)
        return fb


STAGES: dict[int, tuple[Stage, Stage]] = {}


def check(library: ShaderLibrary, runner: PortRunner, layout: dict, scenes: int, seed: int, addressing=None) -> dict:
    """Differential test of one translated pair (a layout written by shader_port.py)."""
    key = layout['key']
    if key not in STAGES:
        STAGES[key] = tuple(Stage(code) for code in library.pairs[key])
    vs, ps = STAGES[key]
    fixed = {(c['name'], c['row'], c['component']): c['value'] for c in layout.get('compiled', [])}

    def measure(**scene_options) -> dict:
        row = {'scenes': scenes, 'pixels': 0, 'exact': 0, 'within_1': 0, 'within_2': 0, 'max_error_255': 0.0, 'coverage_mismatch': 0}
        for n in range(scenes):
            scene = Scene(np.random.default_rng(seed * 1000 + n), fixed=fixed, addressing=addressing, **scene_options)
            game, ours = render_game(vs, ps, scene), runner.render(layout, scene)
            drawn_game, drawn_ours = np.any(game.color[0] != 0.5, axis=2), np.any(ours.color[0] != 0.5, axis=2)
            touched = drawn_game | drawn_ours
            diff = (np.abs(game.color[0] - ours.color[0]) * 255.0).max(axis=2)
            both = drawn_game & drawn_ours
            row['pixels'] += int(touched.sum())
            row['exact'] += int((diff[touched] < 0.5).sum())
            row['within_1'] += int((diff[touched] < 1.5).sum())
            row['within_2'] += int((diff[touched] < 2.5).sum())
            row['coverage_mismatch'] += int((drawn_game != drawn_ours).sum())
            if both.any():
                row['max_error_255'] = max(row['max_error_255'], float(diff[both].max()))
        return row

    # A shader whose point light is set per draw runs the light's part of the game's
    # vertex program per pixel (the vertex shader has no per-draw constant). The main
    # row is the scene with no light on the mesh, where both are the same. With a light
    # the two agree in the limit of small triangles: measured on the scene as it is
    # (coarse), cut POINT_LIGHT_SUBDIVISION^2 times finer (fine), and cut
    # POINT_LIGHT_DENSE^2 times finer with continuous texture sampling (dense), the
    # measurement the verdict uses.
    lit = any(e['name'].startswith('g_pointLight') for e in layout.get('dynamic', []))
    row = dict(measure(unlit=True) if lit else measure(), key=f'{key:#08x}', pixel=layout['pixel'], notes=layout.get('notes', []))
    if lit:
        row['point_light'] = {'coarse': measure(), 'fine': measure(subdivide=POINT_LIGHT_SUBDIVISION),
                              'dense': measure(subdivide=POINT_LIGHT_DENSE, continuous=True),
                              'subdivision': POINT_LIGHT_SUBDIVISION, 'dense_subdivision': POINT_LIGHT_DENSE}
    return row


def merge(total: dict, row: dict) -> None:
    for name in ('scenes', 'pixels', 'exact', 'within_1', 'within_2', 'coverage_mismatch'):
        total[name] = total.get(name, 0) + row[name]
    total['max_error_255'] = max(total.get('max_error_255', 0.0), row['max_error_255'])


def describe(row: dict) -> str:
    share = lambda k, r=row: 100.0 * r[k] / max(r['pixels'], 1)
    text = (f'{row["pixels"]} px, exact {share("exact"):.2f}%, within 1/255 {share("within_1"):.2f}%, '
            f'within 2/255 {share("within_2"):.2f}%, max {row["max_error_255"]:.1f}, coverage mismatch {row["coverage_mismatch"]}')
    light = row.get('point_light')
    if light:
        coarse, fine, dense = light['coarse'], light['fine'], light['dense']
        text += (f'; with a point light (run per pixel): within 2/255 {share("within_2", coarse):.1f}% on these triangles, '
                 f'{share("within_2", fine):.1f}% cut {light["subdivision"]}x finer, '
                 f'{share("within_2", dense):.2f}% cut {light["dense_subdivision"]}x with continuous textures '
                 f'(max {dense["max_error_255"]:.0f})')
    return text


def random_material(rng):
    """A classify callback (see shader_port.py) giving a made-up material: random
    values for every constant that is neither per draw nor a stage value."""
    values: dict[str, np.ndarray] = {}

    def classify(name, row, comp):
        kind, _ = default_classify(name, row, comp)
        if kind != 'constant':
            return kind, None
        if name in OBJECT:
            return 'constant', 0.0          # the w the context fill writes
        if name.startswith('port_'):
            return 'constant', 0.0          # addressing and mips are checked with real materials (verify_package_shaders.py)
        if name not in values:
            values[name] = constant(name, rng)
        return 'constant', float(np.float32(values[name][(row * 4 + comp) % 4]))
    return classify


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--keys', nargs='*', default=[])
    ap.add_argument('--all', action='store_true', help='every key the effect models use (shader_key_census.json)')
    ap.add_argument('--materials', type=int, default=3, help='random materials per key (compiled-in constants)')
    ap.add_argument('--scenes', type=int, default=4, help='random scenes per material')
    ap.add_argument('--seed', type=int, default=1)
    ap.add_argument('--fog-clamp', action='store_true',
                    help='put the fog range inside the scene: measures what the per-pixel fog clamp changes')
    ap.add_argument('--smooth-normals', action='store_true',
                    help='a different normal per vertex: measures what per-pixel lighting changes')
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/shader_port_check.json')
    args = ap.parse_args()
    FOG_CLAMP, SMOOTH_NORMALS = args.fog_clamp, args.smooth_normals
    library = ShaderLibrary()
    runner = PortRunner()
    keys = [int(k, 16) for k in args.keys]
    if args.all:
        census = json.loads((ROOT / 'captured_assets/shader_key_census.json').read_text(encoding='utf-8'))
        keys += [int(k, 16) for k in census['first_pass'] if k.startswith('0x') and int(k, 16) not in keys]
    report = {'fog_clamp': FOG_CLAMP, 'smooth_normals': SMOOTH_NORMALS, 'keys': {}, 'untranslated': {}}
    for key in keys:
        if not library.has(key):
            report['untranslated'][f'{key:#08x}'] = 'not in the shader archive'
            continue
        total = {'notes': []}
        try:
            for m in range(args.materials):
                port = translate(library, key, random_material(np.random.default_rng(args.seed * 7919 + m)))
                build(port)
                merge(total, check(library, runner, port.layout, args.scenes, args.seed + m))
                total['notes'] = port.notes
        except Unsupported as error:
            report['untranslated'][f'{key:#08x}'] = str(error)
            print(f'{key:#08x}: NOT TRANSLATED: {error}', flush=True)
            continue
        report['keys'][f'{key:#08x}'] = total
        print(f'{key:#08x}: {describe(total)}' + (f', notes {total["notes"]}' if total['notes'] else ''), flush=True)
    if args.all:
        args.output.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
        print('WROTE:', args.output)
