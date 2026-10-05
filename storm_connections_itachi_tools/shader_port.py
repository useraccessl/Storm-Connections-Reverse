"""Translate the game's material shaders into GMod screenspace_general shaders.

The game selects a vertex/pixel pair of nuccMaterial_dx11.nsh by shader key
(NUD material flags). This module turns such a pair into an SM3 pair GMod can
run, mechanically, from the game's own bytecode:

  * the port's vertex shader is the game's vertex program, instruction by
    instruction, with the game's matrices rebuilt from Source's standard
    vertex constants;
  * the port's pixel shader is the game's pixel program;
  * screenspace_general gives a shader four pixel constants (c0-c3) and no
    custom vertex constant. Every constant of the game is therefore one of:
      'draw'      changes per draw: one of the 16 floats of c0-c3;
      'stage'     a property of the scene the effect plays in (host input),
                  baked into TEXCOORD channels of the cached mesh;
      'constant'  a property of the material, known when the skill is
                  imported: compiled into the shader of that material;
      'object'    a stage vector the game takes into the object space of the
                  draw (the light direction of the lit families): the vertex
                  shader computes it from the baked stage vector and the
                  model matrix Source hands it.
    The vertex shader cannot see c0-c3, so the instructions of the vertex
    program that depend on a per-draw constant are deferred: they run at the
    start of the pixel shader, on interpolated copies of the values the vertex
    shader had computed up to that point.

What is exact by construction: everything the vertex shader still computes
(fog factor, lighting, falloff normal) and the whole pixel program. A
deferred instruction is exact wherever it is affine in what it reads from
the vertex shader (UV scale and offset, colour products, pass-through
constants); verify_shader_port.py measures every key against the game's
bytecode.

  python shader_port.py --keys 0x3f002 0x1f00f     # translate, compile, report
  python shader_port.py --census                   # every key the effect models use

storm_import.py calls translate() once per imported material, with that
material's own constants.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import math
from dataclasses import dataclass, field, replace
from pathlib import Path

import numpy as np

import soft_replay as sr
from compile_source_shader import compile as compile_hlsl, package
from shader_library import ShaderLibrary, rdef, signature

ROOT = Path(__file__).resolve().parent
ADDON = ROOT.parent / 'storm_amaterasu_lab'
SHADERS = ROOT / 'shaders' / 'auto'
XYZW = 'xyzw'
# Matrices the port's vertex shader rebuilds from Source's standard constants.
MATRICES = {'g_matWorldViewProj', 'g_matWorld', 'g_matWorldInvTrans', 'g_matWorldViewInvTrans'}
ATTRIBUTES = {'POSITION0', 'NORMAL0', 'COLOR0', 'TEXCOORD0', 'TEXCOORD1'}
# Default classification, used when no material is given (--census and the
# random materials of verify_shader_port.py): what every effect material needs
# per draw, the stage values, and 'constant' for the rest.
DRAW = {'g_uvOffset0', 'g_multColor', 'g_uvOffsetScreen', ('g_commonParam', 0), ('g_commonParam', 1)}
STAGE = {'g_fogParam', 'g_fogColor', 'g_ambientColor', 'g_ScreenToUV', 'g_lightColor', 'g_stageColor', 'g_eyePos'}
# Constants the game derives, per draw, from a stage value and the model matrix
# (context fill 0x1413368f0): constant -> the stage value it comes from.
# g_lightDirection is the light set's first directional light taken into object
# space by the inverse of the model matrix (0x141280580 is a full inverse, run
# against the game's code: the vector's length is the inverse of the model's
# scale). The port's vertex shader has the model matrix and computes the same.
OBJECT = {'g_lightDirection': 'g_lightDirectionWorld'}
# Textures the game's renderer supplies itself; every other texture of a
# program is a material texture, bound in resource-slot order.
SYSTEM_TEXTURES = {'g_textureRefScene': '_rt_FullFrameFB'}
# The port has no scene depth texture: a depth sample reads the far plane. A
# shader that fades against the scene (soft particles) also needs camera
# constants the importer has no source for, so only shaders that merely compare
# depths get through (the refraction family: it then always displaces).
SUBSTITUTED_TEXTURES = {'g_textureRefDepth': (1.0, 'no scene depth in the port: depth samples read the far plane')}
UNAVAILABLE_TEXTURES = {'g_textureRefPostEff': 'post-effect target',
                        'g_textureShadow': 'shadow map', 'g_textureRefTcDeff': 'tone-control target',
                        'g_textureBlurVelocity': 'velocity target', 'g_textureWaterEnv': 'water targets',
                        'g_textureWaterNormal': 'water targets', 'g_textureWaterShadow': 'water targets',
                        'g_textureWaterBottom': 'water targets', 'g_textureWaterHeight': 'water targets'}
ADDRESS = 'port_address'        # port_address<i>: mirror / border codes of material texture i (not a game constant)


def address_name(slot: int) -> str:
    """Constant holding the address codes of material texture `slot`, per axis:
    0 = as the VTF says (wrap, or clamp for the *_c variants), -1 = mirror,
    -2 = mirror once, texture size = border colour (0, 0, 0, 0)."""
    return f'{ADDRESS}{slot}'


# NUD wrap code -> D3D11 address mode. The game converts the code to its own enum
# (0x1412720a0) and that enum to D3D11_TEXTURE_ADDRESS_MODE (0x141412810); every
# code not listed wraps. Checked against both routines by verify_sampler_state_native.py.
NUD_ADDRESS_MODE = {1: 'wrap', 2: 'mirror', 3: 'clamp', 4: 'border', 5: 'clamp', 6: 'mirror_once', 7: 'wrap', 8: 'mirror_once'}


def address_mode(code: int) -> str:
    return NUD_ADDRESS_MODE.get(code, 'wrap')


def address_code(code: int, size: int) -> int:
    """Port address code (see address_name) of a NUD wrap code, for an axis of `size` texels."""
    return {'wrap': 0, 'clamp': 0, 'mirror': -1, 'mirror_once': -2, 'border': size}[address_mode(code)]


LOD = 'port_lod'                # port_lod<i>: mip sampling of material texture i (not a game constant)
SIZE = 'port_size'              # port_size<i>: width and height of material texture i


def lod_name(slot: int) -> str:
    """Constant holding how material texture `slot` picks its mip level: x = the
    sampler's LOD bias, y = the last level the game's texture has (0: the texture is
    sampled at level 0 only and the VTF has that level alone), z = 1 for the point filter."""
    return f'{LOD}{slot}'


def size_name(slot: int) -> str:
    return f'{SIZE}{slot}'


def nud_filter(minify: int, magnify: int) -> int:
    """Engine filter of the NUD filter codes (texture record +0x10 and +0xF), 0x141272030:
    0 point, 1 point with a linear mip filter, 2 linear with a point mip filter,
    3 linear on the three, 4 anisotropic. Checked by verify_sampler_state_native.py."""
    if minify in (1, 3):
        if magnify == 1:
            return 0
    elif minify == 5:
        if magnify == 1:
            return 1
    elif minify == 4:
        if magnify == 2:
            return 2
    elif minify in (2, 6):
        if magnify == 2:
            return 3
    elif minify in (8, 9, 10):
        return 4
    return 4 if magnify in (5, 6, 7) else 3


def nud_lod_bias(field: int) -> float:
    """Sampler MipLODBias of the 16-bit field at texture record +0x16 (0x141270a81):
    low byte / 256, plus bits 8-11, minus 16 when bit 12 is set."""
    return (field & 0xff) / 256.0 + ((field >> 8) & 0xf) + (-16.0 if field & 0x1000 else 0.0)


# A sampler biased this far never leaves level 0: the level of detail would have to
# exceed 15, the whole of a 32768-texel axis inside one pixel.
LEVEL_ZERO_BIAS = -15.0

COMPONENTWISE = {'mov': 1, 'add': 2, 'mul': 2, 'mad': 3, 'div': 2, 'min': 2, 'max': 2, 'lt': 2, 'ge': 2, 'eq': 2, 'ne': 2,
                 'and': 2, 'or': 2, 'movc': 3, 'frc': 1, 'sqrt': 1, 'rsq': 1, 'exp': 1, 'log': 1, 'round_ni': 1,
                 'round_pi': 1, 'round_z': 1, 'round_ne': 1, 'rcp': 1, 'not': 1}
DOTS = {'dp2': 2, 'dp3': 3, 'dp4': 4}
SAMPLES = {'sample', 'sample_l', 'sample_b'}
DISCARDS = {'discard_nz', 'discard_z'}
COMPARES = {'lt': '<', 'ge': '>=', 'eq': '==', 'ne': '!='}
FUNCTIONS = {'frc': 'frac', 'sqrt': 'sqrt', 'rsq': 'rsqrt', 'exp': 'exp2', 'log': 'log2', 'round_ni': 'floor',
             'round_pi': 'ceil', 'round_z': 'trunc', 'round_ne': 'round'}


class Unsupported(Exception):
    """The pair uses something the port cannot express; the message says what."""


def default_classify(name: str, row: int, comp: int):
    if name in DRAW or (name, comp) in DRAW:
        return 'draw', None
    if name in STAGE:
        return 'stage', None
    if name in OBJECT and row == 0 and comp < 3:
        return 'object', None
    return 'constant', 0.0


def swz4(op: sr.Operand) -> tuple[int, int, int, int]:
    s = tuple(op.swizzle) if op.explicit else (0, 1, 2, 3)
    if len(s) == 1:
        return s * 4
    return s + (s[-1],) * (4 - len(s))


def mask_of(op: sr.Operand) -> tuple[int, ...]:
    return tuple(op.swizzle) if op.explicit else (0, 1, 2, 3)


def letters(comps) -> str:
    return ''.join(XYZW[c] for c in comps)


def literal(value: float) -> str:
    """A float literal of the game's bytecode."""
    value = float(value)
    if math.isnan(value) or math.isinf(value) or (value != 0 and abs(value) < 1e-30):
        raise Unsupported('integer or non-finite literal in float arithmetic')
    return constant(value)


def constant(value: float) -> str:
    value = float(np.float32(value))
    if math.isnan(value) or math.isinf(value):
        raise Unsupported('non-finite material constant')
    return f'{int(value)}' if value == int(value) and abs(value) < 1e6 else repr(value)


class Stage:
    """One program of the pair with what it declares."""

    def __init__(self, bytecode: bytes):
        self.program = sr.load_program(bytecode)
        info = rdef(bytecode)
        slots = {b['name']: b['slot'] for b in info['bindings'] if b['kind'] == 'cbuffer'}
        # (cb name, register, component) -> (variable, row, component of the row, is a matrix)
        self.floats: dict[tuple[str, int, int], tuple[str, int, int, bool]] = {}
        for buffer in info['buffers']:
            cb = f'cb{slots[buffer["name"]]}'
            for v in buffer['variables']:
                for f in range(v['size'] // 4):
                    at = v['offset'] + 4 * f
                    self.floats[(cb, at // 16, (at % 16) // 4)] = (v['name'], f // 4, f % 4, v['rows'] > 1)
        self.textures = {f't{b["slot"]}': b['name'] for b in info['bindings'] if b['kind'] == 'texture'}
        self.inputs = signature(bytecode, 'ISGN')
        self.outputs = signature(bytecode, 'OSGN')

    def positions(self, ins: sr.Instruction) -> list[tuple[sr.Operand, tuple[int, ...]]]:
        """Source operands of an instruction with the positions of their 4-component
        swizzle it reads (destination component c reads position c)."""
        op, args = ins.op, ins.args
        if op in DISCARDS:
            return [(args[0], (0,))]
        if op == 'sincos':
            return [(args[2], tuple(sorted({c for d in args[:2] if d.name != 'null' for c in mask_of(d)})))]
        out = []
        for index, a in enumerate(args[1:], start=1):
            if op in DOTS:
                out.append((a, tuple(range(DOTS[op]))))
            elif op in SAMPLES:
                out.append((a, (0, 1) if index == 1 else ((0,) if index == 4 else ())))
            else:
                out.append((a, mask_of(args[0])))
        return out

    def reads(self, ins: sr.Instruction) -> list[tuple[sr.Operand, tuple[int, ...]]]:
        """Source operands of an instruction with the components it reads from each."""
        return [(a, tuple(swz4(a)[p] for p in positions)) for a, positions in self.positions(ins)]

    def writes(self, ins: sr.Instruction) -> list[tuple[str, int]]:
        if ins.op in DISCARDS:
            return []
        targets = [d for d in ins.args[:2] if d.name != 'null'] if ins.op == 'sincos' else [ins.args[0]]
        return [(d.name, c) for d in targets for c in mask_of(d)]


def analyse(stage: Stage, live_out: set) -> tuple[list[sr.Instruction], set]:
    """Dead-code elimination: the instructions that reach `live_out` (register,
    component) pairs or a discard, each narrowed to the destination components
    that are live, and the register pairs live on entry."""
    live, kept = set(live_out), []
    for ins in reversed(stage.program.instructions):
        op = ins.op
        if op in ('ret', 'nop'):
            continue
        if op not in COMPONENTWISE and op not in DOTS and op not in SAMPLES and op not in DISCARDS and op != 'sincos':
            raise Unsupported(f'instruction {op}')
        if op not in DISCARDS:
            written = stage.writes(ins)
            if not any(w in live for w in written):
                continue
            # Destination components are independent of each other: drop the dead ones.
            args = list(ins.args)
            for n in range(2 if op == 'sincos' else 1):
                d = args[n]
                if d.name != 'null':
                    used = tuple(c for c in mask_of(d) if (d.name, c) in live)
                    args[n] = replace(d, swizzle=used, explicit=True) if used else replace(d, name='null')
            ins = replace(ins, args=args)
            live -= set(written)
        for a, comps in stage.reads(ins):
            if a.kind == 'reg':
                live |= {(a.name, c) for c in comps}
        kept.append(ins)
    kept.reverse()
    return kept, live


@dataclass
class Port:
    key: int
    vertex_hlsl: str = ''
    pixel_hlsl: str = ''
    layout: dict = field(default_factory=dict)
    notes: list[str] = field(default_factory=list)


class Translator:
    stages: dict[int, tuple[Stage, Stage]] = {}       # disassembled once per key

    def __init__(self, library: ShaderLibrary, key: int, classify=None, unbound=(), studio=None):
        """unbound: material texture slots the material supplies no texture for. The
        port reads them as zero; what the game binds there is not traced, so such a
        translation is only valid when its output does not depend on the texture
        (verify_package_shaders.py gives the game side a random one).
        studio: a variant for a Source studio model, whose vertices have a position, a normal
        and one UV set only: {'color': (r, g, b, a)} the mesh's one vertex colour, compiled
        in; the second UV set is read from the first (the caller checked they are the same);
        no stage value may ride in a vertex channel (the classifier compiles them in)."""
        self.key = key
        self.unbound = set(unbound)
        self.studio = studio
        self.classify = classify or default_classify
        if not library.has(key):
            raise Unsupported('shader key not in the game archive')
        if key not in self.stages:
            self.stages[key] = tuple(Stage(code) for code in library.pairs[key])
        self.vs, self.ps = self.stages[key]
        self.kind: dict[tuple[str, int, int], str] = {}           # scalar -> 'draw' | 'stage' | 'constant'
        self.used = {'v': {}, 'p': {}}                            # scalars each port shader reads (insertion ordered)
        self.matrices: dict[str, None] = {}
        self.textures: dict[str, int] = {}                        # game texture name -> port sampler
        self.notes: list[str] = []

    # -- operands ----------------------------------------------------------------
    def register(self, program: str, name: str) -> str:
        if program == 'v' and name in self.input_semantic:
            return f'A_{self.input_semantic[name]}'
        return program + name

    def operand(self, stage: Stage, program: str, side: str, op: sr.Operand, positions) -> str:
        """HLSL float4 for a source operand. program: 'v' / 'p' (whose registers);
        side: which port shader the statement lands in; positions: the swizzle
        positions the instruction reads (the others are filled with 0)."""
        s = swz4(op)
        if op.kind == 'lit':
            text = 'float4(' + ', '.join(literal(v) if n in positions else '0' for n, v in enumerate(op.literal)) + ')'
        elif op.kind == 'cb':
            parts = []
            for n, c in enumerate(s):
                if n not in positions:
                    parts.append('0')
                    continue
                info = stage.floats.get((op.name, op.index, c))
                if info is None:
                    raise Unsupported(f'constant {op.name}[{op.index}] outside the declared variables')
                name, row, col, is_matrix = info
                if is_matrix:
                    if side != 'v':
                        raise Unsupported(f'matrix {name} needed per pixel')
                    if name not in MATRICES:
                        raise Unsupported(f'matrix {name} has no Source equivalent in the port')
                    self.matrices.setdefault(name)
                    parts.append(f'M_{name}[{row}].{XYZW[col]}')
                else:
                    self.used[side].setdefault((name, row, col))
                    parts.append(f'U_{name}_{row}_{XYZW[col]}')
            text = 'float4(' + ', '.join(parts) + ')'
        else:
            text = f'{self.register(program, op.name)}.{letters(s)}'
        if op.absolute:
            text = f'abs({text})'
        if op.negate:
            text = f'(-{text})'
        return text

    def statement(self, stage: Stage, program: str, side: str, ins: sr.Instruction, masks: set) -> list[str]:
        """HLSL for one instruction. masks: (register, component) pairs holding a
        comparison result (all-ones / zero in the game, 1 / 0 here)."""
        op, args = ins.op, ins.args

        def is_mask(a: sr.Operand, comps) -> bool:
            if a.kind != 'reg':
                return False
            flags = {(a.name, c) in masks for c in comps}
            if len(flags) > 1:
                raise Unsupported('operand mixing comparison results and numbers')
            return flags.pop() if flags else False

        reads, positions = stage.reads(ins), stage.positions(ins)
        if op in DISCARDS:
            test = f'{self.operand(stage, program, side, args[0], (0,))}.x != 0'
            return [f'    clip(({test}) ? {"-1 : 1" if op == "discard_nz" else "1 : -1"});']
        if op == 'sincos':
            if is_mask(*reads[0]):
                raise Unsupported('comparison result used as a number by sincos')
            # The source is read once, before either destination is written.
            lines = [f'    {{ float4 angle = {self.operand(stage, program, side, args[2], positions[0][1])};']
            for d, function in ((args[0], 'sin'), (args[1], 'cos')):
                if d.name != 'null':
                    expr = f'{function}(angle)'
                    lines.append(f'      {self.register(program, d.name)}.{letters(mask_of(d))} = '
                                 f'{f"saturate({expr})" if ins.saturate else expr}.{letters(mask_of(d))};')
                    masks.difference_update((d.name, c) for c in mask_of(d))
            return lines + ['    }']
        dst, sources = args[0], args[1:]
        mask = mask_of(dst)
        A = [self.operand(stage, program, side, a, where) if a.kind in ('reg', 'cb', 'lit') else None
             for a, (_, where) in zip(sources, positions)]
        kinds = [is_mask(a, comps) for a, comps in reads]
        result_mask = False
        if op in COMPARES:
            if any(kinds):
                raise Unsupported('comparison of comparison results')
            expr, result_mask = f'float4({A[0]} {COMPARES[op]} {A[1]})', True
        elif op == 'not':
            if not kinds[0]:
                raise Unsupported('bitwise not of a number')
            expr, result_mask = f'(1 - {A[0]})', True
        elif op in ('and', 'or'):
            if all(kinds):
                expr, result_mask = (f'({A[0]} * {A[1]})' if op == 'and' else f'max({A[0]}, {A[1]})'), True
            elif op == 'and' and any(kinds):
                expr = f'({A[0]} * {A[1]})'              # select: mask ? value : 0
            else:
                raise Unsupported(f'integer {op}')
        elif op == 'movc':
            expr = f'({A[0]} != 0 ? {A[1]} : {A[2]})'
            result_mask = bool(kinds[1] and kinds[2])
        else:
            if any(kinds):
                raise Unsupported(f'comparison result used as a number by {op}')
            if op == 'mov':
                expr = A[0]
            elif op in ('add', 'mul', 'div'):
                expr = f'({A[0]} {dict(add="+", mul="*", div="/")[op]} {A[1]})'
            elif op == 'mad':
                expr = f'({A[0]} * {A[1]} + {A[2]})'
            elif op in ('min', 'max'):
                expr = f'{op}({A[0]}, {A[1]})'
            elif op == 'rcp':
                expr = f'(1 / {A[0]})'
            elif op in FUNCTIONS:
                expr = f'{FUNCTIONS[op]}({A[0]})'
            elif op in DOTS:
                n = letters(range(DOTS[op]))
                expr = f'dot({A[0]}.{n}, {A[1]}.{n}).xxxx'
            elif op in SAMPLES:
                if side != 'p':
                    raise Unsupported('texture sampled by the vertex program')
                name = stage.textures[sources[1].name]
                expr = self.sample(name, f'{A[0]}.xy', op, A[3] if op != 'sample' else None) + f'.{letters(swz4(sources[1]))}'
            else:
                raise Unsupported(f'instruction {op}')
        if ins.saturate:
            expr = f'saturate({expr})'
        for c in mask:
            (masks.add if result_mask else masks.discard)((dst.name, c))
        return [f'    {self.register(program, dst.name)}.{letters(mask)} = {expr}.{letters(mask)};']

    def sample(self, name: str, uv: str, op: str, extra: str | None) -> str:
        if name in SUBSTITUTED_TEXTURES:
            value, note = SUBSTITUTED_TEXTURES[name]
            if note not in self.notes:
                self.notes.append(note)
            return f'float4({value}, {value}, {value}, {value})'
        slot = self.material_slot(name)
        if slot in self.unbound:
            note = f'material texture {slot} is not supplied by the material: read as zero'
            if note not in self.notes:
                self.notes.append(note)
            return 'float4(0, 0, 0, 0)'
        sampler = f'S{self.textures[name]}'

        def fixed(scalar):
            return self.compiled[scalar] if self.kind[scalar] == 'constant' else None

        def ref(scalar) -> str:
            self.used['p'].setdefault(scalar)
            return f'U_{scalar[0]}_{scalar[1]}_{XYZW[scalar[2]]}'

        codes = [(address_name(slot), 0, c) for c in (0, 1)] if slot is not None else []
        # Codes compiled in as 0 (wrap or clamp, which the VTF does): the coordinate as it is.
        plain = all(fixed(s) == 0 for s in codes)
        border = any(fixed(s) is None or fixed(s) > 0 for s in codes)
        address = None if plain else f'float2({ref(codes[0])}, {ref(codes[1])})'
        bias, last, point = ((lod_name(slot), 0, c) for c in (0, 1, 2)) if slot is not None else (None, None, None)
        if slot is not None and None in (fixed(bias), fixed(last), fixed(point)):
            raise Unsupported(f'{lod_name(slot)} is not compiled in')
        if slot is None:
            # A system texture (a render target): one level, sampled as the hardware sees fit.
            if op == 'sample_l':
                return f'tex2Dlod({sampler}, float4({uv}, 0, {extra}.x))'
            if op == 'sample_b':
                return f'tex2Dbias({sampler}, float4({uv}, 0, {extra}.x))'
            return f'tex2D({sampler}, {uv})'
        if fixed(last) == 0:
            # The game stays on level 0 (one level, or a bias that never leaves it) and
            # the VTF has that level alone. The level is named so that a filter forced by
            # the player's settings (anisotropy) cannot minify it another way.
            if plain:
                return f'tex2Dlod({sampler}, float4({uv}, 0, 0))'
            if border and fixed(point):
                self.helpers.update(('Folded', 'InsidePoint'))
                return f'(tex2Dlod({sampler}, float4(Folded({uv}, {address}), 0, 0)) * InsidePoint({uv}, {address}))'
            self.helpers.add('Addressed')
            return f'Addressed({sampler}, {uv}, {address})'
        # The game's level of detail, computed here: the sampler bias and the number of
        # levels of the game's texture are not something a VTF can carry.
        if op == 'sample_l':
            level = f'clamp({extra}.x + {ref(bias)}, 0, {ref(last)})'
        else:
            size = f'float2({ref((size_name(slot), 0, 0))}, {ref((size_name(slot), 0, 1))})'
            offset = ref(bias) + (f' + {extra}.x' if op == 'sample_b' else '')
            self.helpers.add('Level')
            level = f'Level({uv}, {size}, {offset}, {ref(last)})'
        if plain:
            return f'tex2Dlod({sampler}, float4({uv}, 0, {level}))'
        self.helpers.add('Folded')
        if not border:
            return f'tex2Dlod({sampler}, float4(Folded({uv}, {address}), 0, {level}))'
        if fixed(point):
            self.helpers.add('InsidePoint')
            return f'(tex2Dlod({sampler}, float4(Folded({uv}, {address}), 0, {level})) * InsidePoint({uv}, {address}))'
        self.helpers.add('Bordered')
        return f'Bordered({sampler}, Folded({uv}, {address}), {address}, {level}, {ref(last)})'

    def material_textures(self) -> list[str]:
        """Textures the material supplies, in resource-slot order: NUD texture i binds to entry i."""
        return [n for _, n in sorted(self.ps.textures.items(), key=lambda kv: int(kv[0][1:]))
                if n not in SYSTEM_TEXTURES and n not in UNAVAILABLE_TEXTURES and n not in SUBSTITUTED_TEXTURES]

    def material_slot(self, name: str) -> int | None:
        return None if name in SYSTEM_TEXTURES else self.material_textures().index(name)

    # -- the pair ------------------------------------------------------------------
    def scalars(self, stage: Stage, instructions) -> dict:
        out = {}
        for ins in instructions:
            for a, comps in stage.reads(ins):
                if a.kind == 'cb':
                    for c in comps:
                        info = stage.floats.get((a.name, a.index, c))
                        if info is None:
                            raise Unsupported(f'constant {a.name}[{a.index}] outside the declared variables')
                        if not info[3]:
                            out.setdefault(info[:3])
        return out

    def translate(self) -> Port:
        vs, ps = self.vs, self.ps
        if any(i.op in ('if_nz', 'if_z', 'loop') for i in ps.program.instructions + vs.program.instructions):
            raise Unsupported('control flow')
        self.input_semantic = {f'v{s["register"]}': s['semantic'] for s in vs.inputs}
        if not any(a.name == 'o0' for i in ps.program.instructions for a in i.args[:1] if a.kind == 'reg'):
            raise Unsupported('no colour output (depth-only pass: shadow caster)')
        position = next((s for s in ps.inputs if s['semantic'].startswith('SV_P')), None)
        screen_register = f'v{position["register"]}' if position else None
        ps_kept, ps_live = analyse(ps, {('o0', c) for c in range(4)})
        vs_out = {('o' + name[1:], c) for name, c in ps_live if name.startswith('v') and name != screen_register}
        clip_live = {c for name, c in ps_live if name == screen_register}
        vs_kept, vs_live = analyse(vs, vs_out | {('o0', c) for c in range(4)})
        for name, comp in vs_live:
            if name not in self.input_semantic:
                raise Unsupported(f'vertex program reads {name} before writing it')
        semantics = {self.input_semantic[name] for name, _ in vs_live}
        if semantics - ATTRIBUTES:
            raise Unsupported(f'vertex attributes {sorted(semantics - ATTRIBUTES)}')
        if any(self.input_semantic[name] == 'NORMAL0' and comp == 3 for name, comp in vs_live):
            raise Unsupported('vertex program reads NORMAL.w')
        # Port samplers follow the game's resource slots, so material texture 0 is $basetexture.
        for register in sorted({i.args[2].name for i in ps_kept if i.op in SAMPLES}, key=lambda t: int(t[1:])):
            name = ps.textures[register]
            if name in UNAVAILABLE_TEXTURES:
                raise Unsupported(f'samples the {UNAVAILABLE_TEXTURES[name]} ({name})')
            if name not in SUBSTITUTED_TEXTURES and self.material_slot(name) not in self.unbound:
                self.textures.setdefault(name, len(self.textures))
        # screenspace_general binds four samplers; screenspace_general_8tex (GMod 2025.12.01,
        # the same shader with eight) takes the pairs that sample five to eight.
        if len(self.textures) > 8:
            raise Unsupported(f'{len(self.textures)} textures (screenspace_general_8tex binds eight)')

        # ---- where every constant comes from ----
        vertex_scalars = self.scalars(vs, vs_kept)
        scalars = dict(vertex_scalars)
        scalars.update(self.scalars(ps, ps_kept))
        for name in self.textures:
            slot = self.material_slot(name)
            if slot is not None:
                scalars.update({(address_name(slot), 0, 0): None, (address_name(slot), 0, 1): None})
                scalars.update({(lod_name(slot), 0, c): None for c in range(3)})
                scalars.update({(size_name(slot), 0, c): None for c in range(2)})
        draw, stage_values, compiled, objects = [], [], {}, []
        for scalar in sorted(scalars):
            kind, value = self.classify(*scalar)
            if kind == 'draw':
                draw.append(scalar)
            elif kind == 'stage':
                stage_values.append(scalar)
            elif kind == 'constant':
                compiled[scalar] = float(value)
            elif kind == 'object' and scalar[0] in OBJECT and scalar[1] == 0 and scalar[2] < 3:
                objects.append(scalar)
            else:
                raise Unsupported(f'no source for constant {scalar[0]}.{XYZW[scalar[2]]}')
        # An object-space constant needs the three components of its stage vector,
        # where the vertex shader can read them.
        object_sources = sorted({(OBJECT[name], 0, c) for name, _, _ in objects for c in range(3)})
        if self.studio is not None:
            for scalar in object_sources:
                kind, value = self.classify(*scalar)
                if kind != 'constant':
                    raise Unsupported(f'studio variant: no compiled object source {scalar[0]}')
                compiled[scalar] = float(value)
        else:
            stage_values = sorted(set(stage_values) | set(object_sources))
        second_uv = 'TEXCOORD1' in semantics
        if self.studio is not None and stage_values:
            raise Unsupported(f'studio variant: stage values left in vertex channels {sorted({s[0] for s in stage_values})}')
        channels = [c for c in range(1, 8) if not (second_uv and c == 1)]
        if len(draw) > 16:
            raise Unsupported(f'{len(draw)} per-draw constants (screenspace_general has 16 pixel constant floats)')
        # A baked channel holds two floats, or four when the stage values need the room
        # (screenspace_general $tcsize<n>, the optional third and fourth components of
        # mesh.TexCoord). Stage values that still do not fit ride in the pixel constants
        # left over; the vertex shader then no longer sees them. Those it does not read go first.
        size = 2 if len(stage_values) <= 2 * len(channels) else 4
        spill = max(0, len(stage_values) - size * len(channels))
        if spill > 16 - len(draw):
            raise Unsupported(f'{len(draw)} per-draw and {len(stage_values)} stage constants '
                              f'(16 pixel constant floats, {size * len(channels)} baked into the mesh)')
        if spill:
            order = sorted(stage_values, key=lambda s: (s in vertex_scalars or s in object_sources, s))
            draw, stage_values = draw + order[:spill], sorted(order[spill:])
            if any(s in draw for s in object_sources):
                raise Unsupported('the stage vector of an object-space constant does not fit in the mesh')
        self.kind = {**{s: 'draw' for s in draw}, **{s: 'stage' for s in stage_values}, **{s: 'constant' for s in compiled},
                     **{s: 'object' for s in objects}}
        self.compiled, self.helpers = compiled, set()
        pixel_source = {s: f'C{n // 4}.{XYZW[n % 4]}' for n, s in enumerate(draw)}
        baked_source = {s: f'i.s{channels[n // size]}.{XYZW[n % size]}' for n, s in enumerate(stage_values)}
        if self.studio is not None:
            baked_source.update({s: constant(compiled[s]) for s in object_sources})

        # ---- vertex program: what the vertex shader keeps, what the pixel shader finishes ----
        carried: list[tuple[str, str]] = []           # (pixel-side symbol, vertex-side expression)
        carried_symbols: set[str] = set()

        def carry(symbol: str, expression: str) -> str:
            if symbol not in carried_symbols:
                carried_symbols.add(symbol)
                carried.append((symbol, expression))
            return symbol

        vertex_lines, deferred_lines = [], []
        tainted: set[tuple[str, int]] = set()         # register components only the pixel shader has
        snapshot: dict[tuple[str, int], str] = {}     # current vertex-side value -> its carried symbol
        loaded: dict[tuple[str, int], str] = {}       # pixel-side copy of a vertex register component
        masks: set[tuple[str, int]] = set()
        pixel_attributes: dict[tuple[str, int], None] = {}

        def load(name: str, comp: int) -> None:
            """Give the pixel side the vertex shader's current value of a register component."""
            symbol = snapshot.get((name, comp))
            if symbol is None:
                symbol = snapshot[(name, comp)] = f'K{len(carried)}'
                vertex_lines.append(f'    float {symbol} = v{name}.{XYZW[comp]};')
                carry(symbol, symbol)
            if loaded.get((name, comp)) != symbol:
                deferred_lines.append(f'    v{name}.{XYZW[comp]} = {symbol};')
                loaded[(name, comp)] = symbol

        for ins in vs_kept:
            reads = vs.reads(ins)
            deferred = False
            for a, comps in reads:
                if a.kind == 'reg' and any((a.name, c) in tainted for c in comps):
                    deferred = True
                if a.kind == 'cb':
                    for c in comps:
                        info = vs.floats[(a.name, a.index, c)]
                        if not info[3] and self.kind[info[:3]] == 'draw':
                            deferred = True
            if deferred:
                for a, comps in reads:
                    if a.kind != 'reg':
                        continue
                    for c in comps:
                        if a.name in self.input_semantic:
                            pixel_attributes.setdefault((self.input_semantic[a.name], c))
                        elif (a.name, c) not in tainted:
                            load(a.name, c)
                deferred_lines += self.statement(vs, 'v', 'p', ins, masks)
            else:
                vertex_lines += self.statement(vs, 'v', 'v', ins, masks)
            for name, comp in vs.writes(ins):
                snapshot.pop((name, comp), None)
                loaded.pop((name, comp), None)
                (tainted.add if deferred else tainted.discard)((name, comp))
        if any(('o0', c) in tainted for c in range(4)):
            raise Unsupported('the clip position depends on a per-draw constant')
        for name, comp in sorted(vs_out):
            if (name, comp) not in tainted:
                load(name, comp)
        # SV_Position: pixel centre, depth, clip w.
        screen_lines = []
        if clip_live:
            parts = ['i.pixel.x + 0.5', 'i.pixel.y + 0.5', '0', '0']
            if clip_live & {2, 3}:
                vertex_lines += ['    float CLIP_z = vo0.z;', '    float CLIP_w = vo0.w;']
                carry('CLIP_z', 'CLIP_z')
                carry('CLIP_w', 'CLIP_w')
                parts[2:] = ['CLIP_z / CLIP_w', 'CLIP_w']
            if 2 in clip_live:
                self.notes.append('reads SV_Position.z: Source depth, not the game projection')
            screen_lines.append(f'    float4 p{screen_register} = float4({", ".join(parts)});')
        for register in sorted({name for name, _ in vs_out}):
            screen_lines.append(f'    float4 pv{register[1:]} = v{register};')
        pixel_masks: set[tuple[str, int]] = set()
        pixel_lines = [line for ins in ps_kept for line in self.statement(ps, 'p', 'p', ins, pixel_masks)]

        # ---- interpolators ----
        for semantic, comp in sorted(pixel_attributes):
            carry(f'A_{semantic}_{XYZW[comp]}', f'A_{semantic}.{XYZW[comp]}')
        for scalar in list(self.used['p']):
            symbol = f'U_{scalar[0]}_{scalar[1]}_{XYZW[scalar[2]]}'
            if self.kind[scalar] == 'stage':
                carry(symbol, baked_source[scalar])
            elif self.kind[scalar] == 'object':
                # The same for every vertex of a draw: carried as is.
                self.used['v'].setdefault(scalar)
                carry(symbol, symbol)
        if len(carried) > 40:
            raise Unsupported(f'{len(carried)} interpolated values (SM3 carries 40)')
        interpolators = [f'TEXCOORD{n}' for n in range(8)] + ['COLOR0', 'COLOR1']
        fields = (len(carried) + 3) // 4
        registers = lambda stage, kinds: sorted({a.name for i in stage.program.instructions for a in i.args
                                                 if a.kind == 'reg' and a.name[0] in kinds and a.name != 'null'})

        # ---- vertex shader ----
        studio = self.studio
        # A studio variant skinned on the GPU. Source hands a screenspace_general vertex shader
        # the bones of a studio model (hardware skinning) and its vertices compressed
        # (common_vs_fxc.h, COMPRESSED_VERTS): the bone indices as a D3DCOLOR, times 3 (float4x3
        # cModel[53] at c58), two SHORT2 weights to decompress, (w + 1) / 32768, the third the
        # rest, the normal in four bytes (_DecompressUByte4Normal). Found in game: of the
        # variants of skin_variants.py only this layout drew the model where it is and posed.
        gpu_skin = studio is not None and studio.get('skinning')
        v = ['// Generated by shader_port.py from the game pair of shader key %#08x. Do not edit.' % self.key,
             'float4 cMVP[4] : register(c4);', 'float4 cVP[4] : register(c8);',
             'float4 cModel[53] : register(c58);' if gpu_skin else 'float4 cModel0[3] : register(c58);',
             'struct VS_INPUT {', '    float4 position : POSITION;']
        if gpu_skin:
            v += ['    float4 boneWeights : BLENDWEIGHT;', '    float4 boneIndices : BLENDINDICES;']
        if 'NORMAL0' in semantics:
            v.append('    float4 normal : NORMAL;' if gpu_skin else '    float3 normal : NORMAL;')
        if 'COLOR0' in semantics and studio is None:
            v.append('    float4 color : COLOR0;')
        if 'TEXCOORD0' in semantics or (studio is not None and second_uv):
            v.append('    float2 uv0 : TEXCOORD0;')
        if second_uv and studio is None:
            v.append('    float2 uv1 : TEXCOORD1;')
        v += [f'    float{size} s{c} : TEXCOORD{c};' for c in channels[:(len(stage_values) + size - 1) // size]]
        v += ['};', 'struct VS_OUTPUT {', '    float4 position : POSITION;']
        v += [f'    float4 t{n} : {interpolators[n]};' for n in range(fields)]
        v += ['};', 'VS_OUTPUT main(VS_INPUT i) {', '    VS_OUTPUT o;']
        if gpu_skin:
            # The vertex into the world by its bones; the game program then sees a model
            # already in the world (identity model matrix, view-projection only)
            v += ['    int4 bi = D3DCOLORtoUBYTE4(i.boneIndices) * 3;',
                  '    float2 bw = (i.boneWeights.xy + 1.0) / 32768.0;',
                  '    float3x4 skin = float3x4(cModel[bi.x], cModel[bi.x + 1], cModel[bi.x + 2]) * bw.x'
                  ' + float3x4(cModel[bi.y], cModel[bi.y + 1], cModel[bi.y + 2]) * bw.y'
                  ' + float3x4(cModel[bi.z], cModel[bi.z + 1], cModel[bi.z + 2]) * (1 - bw.x - bw.y);',
                  '    float4 A_POSITION0 = float4(mul(skin, float4(i.position.xyz, 1)), 1);']
            if 'NORMAL0' in semantics:
                # _DecompressUByte4Normal (common_vs_fxc.h)
                v += ['    float2 ztSigns = (i.normal.xy - 128.0) < 0;',
                      '    float2 xyAbs = abs(i.normal.xy - 128.0) - ztSigns;',
                      '    float2 xySigns = (xyAbs - 64.0) < 0;',
                      '    float3 modelNormal;',
                      '    modelNormal.xy = (abs(xyAbs - 64.0) - xySigns) / 63.0;',
                      '    modelNormal.z = 1.0 - modelNormal.x - modelNormal.y;',
                      '    modelNormal = normalize(modelNormal);',
                      '    modelNormal.xy *= lerp(float2(1, 1), float2(-1, -1), xySigns);',
                      '    modelNormal.z *= lerp(1.0, -1.0, ztSigns.x);',
                      '    float4 A_NORMAL0 = float4(mul((float3x3)skin, modelNormal), 0);']
                if studio.get('rigid'):
                    # Each exported rigid part has one bone. Transform its
                    # normal by the inverse transpose, including the particle's
                    # scale, since the original shader now sees world vertices.
                    v += ['    float3 sn0 = cross(skin[1].xyz, skin[2].xyz);',
                          '    float3 sn1 = cross(skin[2].xyz, skin[0].xyz);',
                          '    float3 sn2 = cross(skin[0].xyz, skin[1].xyz);',
                          '    A_NORMAL0.xyz = float3(dot(sn0, modelNormal), dot(sn1, modelNormal), dot(sn2, modelNormal)) / dot(skin[0].xyz, sn0);']
        else:
            v.append('    float4 A_POSITION0 = float4(i.position.xyz, 1);')
            if 'NORMAL0' in semantics:
                v.append('    float4 A_NORMAL0 = float4(i.normal, 0);')
        if 'COLOR0' in semantics:
            if studio is None:
                v.append('    float4 A_COLOR0 = i.color;')
            else:
                v.append(f'    float4 A_COLOR0 = float4({", ".join(constant(float(c)) for c in studio["color"])});')
        if 'TEXCOORD0' in semantics:
            v.append('    float4 A_TEXCOORD0 = float4(i.uv0, 0, 1);')
        if second_uv:
            v.append(f'    float4 A_TEXCOORD1 = float4(i.{"uv1" if studio is None else "uv0"}, 0, 1);')
        used_matrices = list(self.matrices)
        if 'g_matWorldViewProj' in used_matrices:
            # Source's cModelViewProj takes a row vector on the left: clip.c = dot(position, c[4 + c]).
            # Game layout: row k, column c of a row-major matrix used as position x M. A model
            # skinned here is already in the world: the view-projection alone.
            mvp = 'cVP' if gpu_skin else 'cMVP'
            v.append('    float4 M_g_matWorldViewProj[4];')
            v += [f'    M_g_matWorldViewProj[{k}] = float4({mvp}[0].{XYZW[k]}, {mvp}[1].{XYZW[k]}, {mvp}[2].{XYZW[k]}, {mvp}[3].{XYZW[k]});'
                  for k in range(4)]
        object_used = [s for s in self.used['v'] if self.kind[s] == 'object']
        if object_used or any(m in used_matrices for m in ('g_matWorld', 'g_matWorldInvTrans', 'g_matWorldViewInvTrans')):
            if gpu_skin:
                v += [f'    float3 w{k} = float3({", ".join("1" if r == k else "0" for r in range(3))});' for k in range(3)]
                v.append('    float3 w3 = float3(0, 0, 0);')
            else:
                v += [f'    float3 w{k} = float3(cModel0[0].{XYZW[k]}, cModel0[1].{XYZW[k]}, cModel0[2].{XYZW[k]});' for k in range(4)]
        for name in sorted({OBJECT[s[0]] for s in object_used}):
            v.append(f'    float3 O_{name} = float3({", ".join(baked_source[(name, 0, c)] for c in range(3))});')
        if 'g_matWorld' in used_matrices:
            v.append('    float4 M_g_matWorld[4];')
            v += [f'    M_g_matWorld[{k}] = float4(w{k}, {1 if k == 3 else 0});' for k in range(4)]
        if object_used or 'g_matWorldInvTrans' in used_matrices or 'g_matWorldViewInvTrans' in used_matrices:
            v += ['    float det = dot(w0, cross(w1, w2));',
                  '    float3 it0 = cross(w1, w2) / det, it1 = cross(w2, w0) / det, it2 = cross(w0, w1) / det;']
        if 'g_matWorldInvTrans' in used_matrices:
            v.append('    float4 M_g_matWorldInvTrans[4];')
            v += [f'    M_g_matWorldInvTrans[{k}] = float4(it{k}, 0);' for k in range(3)]
            v.append('    M_g_matWorldInvTrans[3] = float4(0, 0, 0, 1);')
        if 'g_matWorldViewInvTrans' in used_matrices:
            # View axes from Source's view-projection: clip x runs along the camera's
            # right, clip y along its up, clip w along its forward. The game's view
            # space looks down -z (its captured projection has w = -z).
            v += ['    float3 vx = normalize(cVP[0].xyz), vy = normalize(cVP[1].xyz), vz = -normalize(cVP[3].xyz);',
                  '    float4 M_g_matWorldViewInvTrans[4];']
            v += [f'    M_g_matWorldViewInvTrans[{k}] = float4(dot(it{k}, vx), dot(it{k}, vy), dot(it{k}, vz), 0);' for k in range(3)]
            v.append('    M_g_matWorldViewInvTrans[3] = float4(0, 0, 0, 1);')
        for scalar in self.used['v']:
            kind = self.kind[scalar]
            if kind == 'object':
                # Component k of inverse(model) * stage vector: it<k> is row k of the inverse.
                value = f'dot(O_{OBJECT[scalar[0]]}, it{scalar[2]})'
            else:
                value = baked_source[scalar] if kind == 'stage' else constant(compiled[scalar])
            v.append(f'    float U_{scalar[0]}_{scalar[1]}_{XYZW[scalar[2]]} = {value};')
        v += [f'    float4 v{name} = 0;' for name in registers(vs, 'ro')]
        v += vertex_lines + ['    o.position = vo0;']
        values = [expr for _, expr in carried] + ['0'] * (fields * 4 - len(carried))
        v += [f'    o.t{n} = float4({", ".join(values[n * 4:n * 4 + 4])});' for n in range(fields)]
        v += ['    return o;', '}']

        # ---- pixel shader ----
        p = ['// Generated by shader_port.py from the game pair of shader key %#08x. Do not edit.' % self.key]
        p += [f'sampler S{n} : register(s{n});' for n in range(len(self.textures))]
        p += [f'float4 C{n} : register(c{n});' for n in range(4)]
        # Addressing a VTF cannot express, per axis: 0 = as the VTF says (wrap, or clamp
        # for the *_c variants), -1 = mirror, -2 = mirror once (|uv| on a clamped VTF),
        # > 0 = border (0,0,0,0) with the value being the axis size in texels.
        if 'Addressed' in self.helpers:
            # Bilinear filtering of a texture that has one level.
            p += ['float4 Addressed(sampler s, float2 uv, float2 address) {',
                  '    float2 mirrored = 1 - abs(frac(uv * 0.5) * 2 - 1);',
                  '    uv = address < -1.5 ? abs(uv) : (address < 0 ? mirrored : uv);',
                  '    float2 inside = saturate(uv * address + 0.5) * saturate((1 - uv) * address + 0.5);',
                  '    inside = address > 0 ? inside : 1;',
                  '    return tex2Dlod(s, float4(uv, 0, 0)) * (inside.x * inside.y);', '}']
        if 'Folded' in self.helpers:
            p += ['float2 Folded(float2 uv, float2 address) {',
                  '    float2 mirrored = 1 - abs(frac(uv * 0.5) * 2 - 1);',
                  '    return address < -1.5 ? abs(uv) : (address < 0 ? mirrored : uv);', '}']
        if 'InsidePoint' in self.helpers:
            # Point filter: the border colour takes over where the texel is outside.
            p += ['float InsidePoint(float2 uv, float2 address) {',
                  '    float2 inside = step(0, uv) * (1 - step(1, uv));',
                  '    inside = address > 0 ? inside : 1;',
                  '    return inside.x * inside.y;', '}']
        if 'Level' in self.helpers:
            # D3D11 level of detail without anisotropy: log2 of the longer screen derivative
            # in texels, plus the bias, clamped to the levels the game's texture has.
            p += ['float Level(float2 uv, float2 size, float bias, float last) {',
                  '    float2 dx = ddx(uv) * size, dy = ddy(uv) * size;',
                  '    return clamp(0.5 * log2(max(max(dot(dx, dx), dot(dy, dy)), 1e-30)) + bias, 0, last);', '}']
        if 'Bordered' in self.helpers:
            # Linear filter across two levels, each fading to the border over its own texel.
            p += ['float4 BorderedLevel(sampler s, float2 uv, float2 address, float level) {',
                  '    float2 size = max(address * exp2(-level), 1);',
                  '    float2 inside = saturate(uv * size + 0.5) * saturate((1 - uv) * size + 0.5);',
                  '    inside = address > 0 ? inside : 1;',
                  '    return tex2Dlod(s, float4(uv, 0, level)) * (inside.x * inside.y);', '}',
                  'float4 Bordered(sampler s, float2 uv, float2 address, float level, float last) {',
                  '    float lower = floor(level);',
                  '    return lerp(BorderedLevel(s, uv, address, lower), BorderedLevel(s, uv, address, min(lower + 1, last)),',
                  '                level - lower);', '}']
        p += ['struct PS_INPUT {'] + [f'    float4 t{n} : {interpolators[n]};' for n in range(fields)]
        p += ['    float2 pixel : VPOS;', '};', 'float4 main(PS_INPUT i) : COLOR {']
        p += [f'    float {symbol} = i.t{n // 4}.{XYZW[n % 4]};' for n, (symbol, _) in enumerate(carried)]
        for scalar in self.used['p']:
            if self.kind[scalar] in ('draw', 'constant'):
                value = pixel_source[scalar] if self.kind[scalar] == 'draw' else constant(compiled[scalar])
                p.append(f'    float U_{scalar[0]}_{scalar[1]}_{XYZW[scalar[2]]} = {value};')
        for semantic in sorted({s for s, _ in pixel_attributes}):
            default = '1' if semantic in ('POSITION0', 'TEXCOORD0', 'TEXCOORD1') else '0'
            comps = [f'A_{semantic}_{XYZW[c]}' if (semantic, c) in pixel_attributes else ('0' if c < 3 else default) for c in range(4)]
            p.append(f'    float4 A_{semantic} = float4({", ".join(comps)});')
        p += [f'    float4 v{name} = 0;' for name in registers(vs, 'ro')]
        p += ['    // ---- game vertex program: the part that needs per-draw constants ----'] + deferred_lines
        p += ['    // ---- game pixel program ----'] + screen_lines
        p += [f'    float4 p{name} = 0;' for name in registers(ps, 'ro')]
        p += pixel_lines + ['    return po0;', '}']

        port = Port(self.key, '\n'.join(v) + '\n', '\n'.join(p) + '\n', notes=self.notes)
        samplers = [None] * len(self.textures)
        for name, index in self.textures.items():
            samplers[index] = {'name': name, 'material': self.material_slot(name), 'system': SYSTEM_TEXTURES.get(name)}
        entry = lambda s: {'name': s[0], 'row': s[1], 'component': s[2]}
        # One file per distinct program: materials with the same key and constants share it.
        digest = lambda text: hashlib.sha1(text.encode('ascii')).hexdigest()[:10]
        port.layout = {
            'key': self.key, 'vertex': f'storm_fx_{self.key:06x}_{digest(port.vertex_hlsl)}_vs30',
            'pixel': f'storm_fx_{self.key:06x}_{digest(port.pixel_hlsl)}_ps30',
            'attributes': {'normal': 'NORMAL0' in semantics, 'color': 'COLOR0' in semantics,
                           'uv0': 'TEXCOORD0' in semantics, 'uv1': second_uv},
            'materialTextures': self.material_textures(), 'samplers': samplers,
            'dynamic': [dict(entry(s), register=n // 4, slot=n % 4) for n, s in enumerate(draw)],
            'static': [dict(entry(s), channel=channels[n // size], slot=n % size) for n, s in enumerate(stage_values)],
            'channelSize': size,
            'host': 'screenspace_general' if len(self.textures) <= 4 else 'screenspace_general_8tex',
            'compiled': [dict(entry(s), value=value) for s, value in sorted(compiled.items())],
            'object': [dict(entry(s), source=OBJECT[s[0]]) for s in objects],
            'deferred': len(deferred_lines), 'matrices': used_matrices, 'notes': self.notes}
        if self.studio is not None:
            port.layout['studio'] = True
            if self.studio.get('skinning'):
                port.layout['gpuSkin'] = True
        return port


def translate(library: ShaderLibrary, key: int, classify=None, unbound=(), studio=None) -> Port:
    """classify(name, row, component) -> ('draw' | 'stage' | 'constant', value); see the module text.
    unbound: material texture slots without a texture; studio: a studio model variant (see Translator)."""
    return Translator(library, key, classify, unbound, studio).translate()


def build(port: Port, addon: Path | None = None) -> None:
    """Compile one translated pair (shaders/auto/*.bin); with `addon`, also write
    the .vcs packages GMod loads into its shaders/fxc folder."""
    SHADERS.mkdir(parents=True, exist_ok=True)
    for name, text, target in ((port.layout['vertex'], port.vertex_hlsl, 'vs_3_0'), (port.layout['pixel'], port.pixel_hlsl, 'ps_3_0')):
        source = SHADERS / f'{name}.hlsl'
        binary = source.with_suffix('.bin')
        if not binary.exists() or not source.exists() or source.read_text(encoding='ascii') != text:
            source.write_text(text, encoding='ascii')
            try:
                binary.write_bytes(compile_hlsl(source, target))
            except RuntimeError as error:       # fxc refused the generated source
                source.unlink()
                raise Unsupported(f'generated HLSL does not compile ({error})')
        if addon is not None:
            (addon / 'shaders/fxc').mkdir(parents=True, exist_ok=True)
            (addon / 'shaders/fxc' / f'{name}.vcs').write_bytes(package(binary.read_bytes(), source.read_bytes()))


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--keys', nargs='*', default=[], help='shader keys (hex)')
    ap.add_argument('--census', action='store_true', help='every key of captured_assets/shader_key_census.json')
    ap.add_argument('--no-build', action='store_true', help='translate only')
    ap.add_argument('--print', action='store_true', help='print the generated HLSL')
    args = ap.parse_args()
    library = ShaderLibrary()
    keys = [int(k, 16) for k in args.keys]
    counts = {}
    if args.census:
        census = json.loads((ROOT / 'captured_assets/shader_key_census.json').read_text(encoding='utf-8'))
        counts = {int(k, 16): n for k, n in census['first_pass'].items() if k.startswith('0x')}
        keys += [k for k in counts if k not in keys]
    done, failed = {}, {}
    for key in keys:
        if not library.has(key):
            failed[key] = 'not in the shader archive'
            continue
        try:
            port = translate(library, key)
            if not args.no_build:
                build(port)
            done[key] = port
        except Unsupported as error:
            failed[key] = str(error)
        if args.print and key in done:
            print(done[key].vertex_hlsl)
            print(done[key].pixel_hlsl)
    for key, port in done.items():
        l = port.layout
        print(f'{key:#08x}: ok, {len(l["dynamic"])} per-draw + {len(l["static"])} baked + {len(l["compiled"])} compiled constants, '
              f'{l["deferred"]} deferred lines, textures {[s["name"] for s in l["samplers"]]}, matrices {l["matrices"]}'
              + (f', notes {port.notes}' if port.notes else '') + (f' [{counts[key]} meshes]' if key in counts else ''))
    for key, why in failed.items():
        print(f'{key:#08x}: NOT TRANSLATED: {why}' + (f' [{counts[key]} meshes]' if key in counts else ''))
    if counts:
        total = sum(counts.values())
        print(f'colour pass of {sum(n for k, n in counts.items() if k in done)} / {total} effect meshes has a translated shader')
