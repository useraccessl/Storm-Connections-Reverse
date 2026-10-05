"""Software replay of Direct3D shaders: bytecode interpreter plus rasterizer.

Purpose: an offline pixel oracle for the effect port. It executes the game's
original vs_4_0 / ps_4_0 shaders (from their D3DDisassemble listing) and the
port's compiled vs_3_0 / ps_3_0 shaders on numpy arrays, rasterizes with
Direct3D rules (top-left fill, 1/256 sub-pixel snap, perspective-correct
attributes, screen-linear depth) and applies depth, alpha-discard and blend
state. Results are compared with render targets dumped from RenderDoc.

Scope: the instruction subset used by the Storm effect shaders; an unknown
opcode raises instead of being guessed. Texture sampling is bilinear on mip 0.
"""

from __future__ import annotations

import ctypes
import re
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

D3DCOMPILER = Path(r'C:\Windows\System32\d3dcompiler_47.dll')
COMP = {'x': 0, 'y': 1, 'z': 2, 'w': 3, 'r': 0, 'g': 1, 'b': 2, 'a': 3}
TRUE_BITS = np.uint32(0xFFFFFFFF)


def disassemble(bytecode: bytes) -> str:
    dll = ctypes.WinDLL(str(D3DCOMPILER))
    fn = dll.D3DDisassemble
    fn.argtypes = (ctypes.c_void_p, ctypes.c_size_t, ctypes.c_uint, ctypes.c_char_p, ctypes.POINTER(ctypes.c_void_p))
    fn.restype = ctypes.c_long
    src = ctypes.create_string_buffer(bytecode)
    blob = ctypes.c_void_p()
    if fn(src, len(bytecode), 0, None, ctypes.byref(blob)) < 0 or not blob.value:
        raise OSError('D3DDisassemble failed')
    vtable = ctypes.cast(blob, ctypes.POINTER(ctypes.POINTER(ctypes.c_void_p))).contents
    ptr = ctypes.WINFUNCTYPE(ctypes.c_void_p, ctypes.c_void_p)(vtable[3])(blob)
    size = ctypes.WINFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p)(vtable[4])(blob)
    text = ctypes.string_at(ptr, size).decode('utf-8', 'replace')
    ctypes.WINFUNCTYPE(ctypes.c_ulong, ctypes.c_void_p)(vtable[2])(blob)
    return text


# ---------------------------------------------------------------------------
# Operands
# ---------------------------------------------------------------------------

@dataclass
class Operand:
    kind: str                 # 'reg', 'cb', 'lit', 'tex', 'samp'
    name: str = ''
    index: int = 0
    swizzle: tuple[int, ...] = (0, 1, 2, 3)
    negate: bool = False
    absolute: bool = False
    literal: np.ndarray | None = None
    explicit: bool = False    # a swizzle or mask was written
    relative: tuple[str, int] | None = None


def _split_args(text: str) -> list[str]:
    out, depth, cur = [], 0, ''
    for ch in text:
        if ch in '([':
            depth += 1
        elif ch in ')]':
            depth -= 1
        if ch == ',' and depth == 0:
            out.append(cur.strip())
            cur = ''
        else:
            cur += ch
    if cur.strip():
        out.append(cur.strip())
    return out


def _literal(token: str) -> np.uint32:
    token = token.strip()
    if token.lower().startswith('0x') or token.lower().startswith('-0x'):
        return np.uint32(int(token, 16) & 0xFFFFFFFF)
    if re.fullmatch(r'-?\d+', token):
        return np.uint32(int(token) & 0xFFFFFFFF)
    return np.float32(float(token)).view(np.uint32)


def parse_operand(text: str) -> Operand:
    text = text.strip()
    op = Operand('reg')
    if text.startswith('-'):
        op.negate, text = True, text[1:].strip()
    if text.startswith('|') and text.endswith('|'):
        op.absolute, text = True, text[1:-1].strip()
    sm3_abs = re.fullmatch(r'([A-Za-z]+\d*)_abs(\.[xyzwrgba]+)?', text)   # SM3 source modifier
    if sm3_abs:
        op.absolute, text = True, sm3_abs.group(1) + (sm3_abs.group(2) or '')
    if text.startswith('l('):
        values = [_literal(t) for t in text[2:-1].split(',')]
        while len(values) < 4:
            values.append(values[-1])
        op.kind = 'lit'
        op.literal = np.array(values, dtype=np.uint32).view(np.float32)
        return op
    relative = re.fullmatch(r'c(\d+)\[(a\d+)\.([xyzw])\](?:\.([xyzwrgba]+))?', text)
    m = re.fullmatch(r'cb(\d+)\[(\d+)\](?:\.([xyzwrgba]+))?', text)
    if relative:
        op.kind, op.name, op.index = 'relative', 'c', int(relative.group(1))
        op.relative = (relative.group(2), COMP[relative.group(3)])
        swz = relative.group(4)
    elif m:
        op.kind, op.name, op.index = 'cb', f'cb{m.group(1)}', int(m.group(2))
        swz = m.group(3)
    else:
        m = re.fullmatch(r'([A-Za-z_]+\d*)(?:\.([xyzwrgba]+))?', text)
        if not m:
            raise ValueError(f'unsupported operand {text!r}')
        op.name, swz = m.group(1), m.group(2)
        if re.fullmatch(r't\d+', op.name):
            op.kind = 'tex'
        elif re.fullmatch(r's\d+', op.name):
            op.kind = 'samp'
    if swz:
        op.explicit = True
        op.swizzle = tuple(COMP[c] for c in swz)
    return op


@dataclass
class Instruction:
    op: str
    saturate: bool
    args: list[Operand]
    text: str


@dataclass
class Program:
    profile: str
    instructions: list[Instruction]
    inputs: dict[str, str] = field(default_factory=dict)    # semantic+index -> register
    outputs: dict[str, str] = field(default_factory=dict)
    defs: dict[str, np.ndarray] = field(default_factory=dict)        # SM3 `def cN`
    samplers: dict[str, str] = field(default_factory=dict)           # SM3 sN -> kind
    text: str = ''


SM3_DCL = re.compile(r'dcl_(\w+?)(\d*)\s+(\w+)(?:\.([xyzw]+))?$')


def parse_program(text: str) -> Program:
    """Parse a D3DDisassemble listing (SM4 or SM3)."""
    lines = [l.rstrip() for l in text.replace('\0', '').splitlines()]
    profile = next((l.strip() for l in lines if re.fullmatch(r'\s*[vp]s_\d_\d', l)), '')
    program = Program(profile, [], text=text)
    section = None
    for l in lines:
        s = l.strip()
        if s.startswith('//'):
            if 'Input signature' in s:
                section = 'in'
            elif 'Output signature' in s:
                section = 'out'
            elif 'Buffer Definitions' in s or 'Resource Bindings' in s or 'Registers:' in s or 'Parameters:' in s:
                section = None
            else:
                m = re.match(r'//\s+(\w+)\s+(\d+)\s+([xyzw ]+?)\s+(\d+)\s+(\w+)\s+\w+', s)
                if m and section:
                    target = program.inputs if section == 'in' else program.outputs
                    prefix = 'v' if section == 'in' else 'o'
                    target[f'{m.group(1)}{m.group(2)}'] = f'{prefix}{m.group(4)}'
            continue
        if not s or s == profile:
            continue
        if s.startswith('def '):
            name, *vals = _split_args(s[4:])
            program.defs[name] = np.array([float(v) for v in vals], dtype=np.float32)
            continue
        if s.startswith('dcl'):
            if profile.endswith('3_0'):
                m = SM3_DCL.match(s)
                if m:
                    usage, index, reg = m.group(1), m.group(2) or '0', m.group(3)
                    if reg.startswith('s'):
                        program.samplers[reg] = usage
                    elif reg.startswith('o'):
                        program.outputs[f'{usage.upper()}{index}'] = reg
                    else:
                        program.inputs[f'{usage.upper()}{index}'] = reg
            continue
        head, _, rest = s.partition(' ')
        saturate = head.endswith('_sat')
        op = head[:-4] if saturate else head
        if op.endswith('_pp'):
            op = op[:-3]
        program.instructions.append(Instruction(op, saturate, [parse_operand(a) for a in _split_args(rest)], s))
    return program


# ---------------------------------------------------------------------------
# Textures
# ---------------------------------------------------------------------------

@dataclass
class Texture:
    data: np.ndarray                  # (H, W, 4) float32
    address_u: str = 'Wrap'
    address_v: str = 'Wrap'
    border: tuple[float, float, float, float] = (0.0, 0.0, 0.0, 0.0)
    point: bool = False               # point minify / magnify / mip filter (else linear on the three)
    mips: tuple = ()                  # the levels below `data`, each (h, w, 4) float32
    bias: float = 0.0                 # sampler MipLODBias, added to every level of detail


def _address(coord: np.ndarray, size: int, mode: str) -> tuple[np.ndarray, np.ndarray]:
    """Integer texel index and validity for one axis."""
    if mode == 'Wrap':
        return np.mod(coord, size), np.ones(coord.shape, bool)
    if mode == 'Mirror':
        period = np.mod(coord, 2 * size)
        return np.where(period >= size, 2 * size - 1 - period, period), np.ones(coord.shape, bool)
    if mode == 'MirrorOnce':
        # D3D11 MIRROR_ONCE: mirrored about 0, then clamped.
        return np.minimum(np.where(coord < 0, -1 - coord, coord), size - 1), np.ones(coord.shape, bool)
    if mode == 'ClampBorder':
        valid = (coord >= 0) & (coord < size)
        return np.clip(coord, 0, size - 1), valid
    return np.clip(coord, 0, size - 1), np.ones(coord.shape, bool)   # ClampEdge


def _sample_level(tex: Texture, data: np.ndarray, u: np.ndarray, v: np.ndarray) -> np.ndarray:
    h, w = data.shape[:2]
    border = np.array(tex.border, dtype=np.float32)
    if tex.point:
        ix, vx = _address(np.floor(u * w).astype(np.int64), w, tex.address_u)
        iy, vy = _address(np.floor(v * h).astype(np.int64), h, tex.address_v)
        out = data[iy, ix]
        return np.where((vx & vy)[:, None], out, border)
    x = u.astype(np.float64) * w - 0.5
    y = v.astype(np.float64) * h - 0.5
    x0, y0 = np.floor(x).astype(np.int64), np.floor(y).astype(np.int64)
    fx, fy = (x - x0).astype(np.float32)[:, None], (y - y0).astype(np.float32)[:, None]
    result = np.zeros((len(u), 4), dtype=np.float32)
    for dy, wy in ((0, 1 - fy), (1, fy)):
        iy, vy = _address(y0 + dy, h, tex.address_v)
        for dx, wx in ((0, 1 - fx), (1, fx)):
            ix, vx = _address(x0 + dx, w, tex.address_u)
            texel = np.where((vx & vy)[:, None], data[iy, ix], border)
            result += texel * wy * wx
    return result


def sample(tex: Texture, u: np.ndarray, v: np.ndarray, lod: np.ndarray | None = None) -> np.ndarray:
    """lod: level of detail before the sampler bias, per element; None samples level 0.
    The biased level is clamped to the levels the texture has, then the two nearest
    levels are blended (linear mip filter) or the nearest one is read (point)."""
    if lod is None or not tex.mips:
        return _sample_level(tex, tex.data, u, v)
    levels = (tex.data,) + tuple(tex.mips)
    last = len(levels) - 1
    lod = np.clip(np.nan_to_num(lod.astype(np.float64) + tex.bias, nan=0.0, posinf=last, neginf=0.0), 0.0, last)
    lower = np.floor(lod + 0.5 if tex.point else lod).astype(np.int64)
    blend = (lod - lower).astype(np.float32)[:, None]
    result = np.zeros((len(u), 4), dtype=np.float32)
    for level in np.unique(lower):
        chosen = lower == level
        texel = _sample_level(tex, levels[level], u[chosen], v[chosen])
        if not tex.point and level < last:
            upper = _sample_level(tex, levels[level + 1], u[chosen], v[chosen])
            texel = texel + (upper - texel) * blend[chosen]
        result[chosen] = texel
    return result


# ---------------------------------------------------------------------------
# Interpreter
# ---------------------------------------------------------------------------

def _bits(a: np.ndarray) -> np.ndarray:
    return np.ascontiguousarray(a, dtype=np.float32).view(np.uint32)


def _from_bool(cond: np.ndarray) -> np.ndarray:
    return np.where(cond, TRUE_BITS, np.uint32(0)).astype(np.uint32).view(np.float32)


UNARY = {
    'mov': lambda a: a,
    'mova': np.rint,
    'frc': lambda a: a - np.floor(a),
    'sqrt': np.sqrt,
    'rsq': lambda a: 1.0 / np.sqrt(a),
    'exp': lambda a: np.exp2(a),
    'log': lambda a: np.log2(a),
    'round_ni': np.floor, 'round_pi': np.ceil, 'round_z': np.trunc, 'round_ne': np.rint,
    'abs': np.abs,
    'rcp': lambda a: 1.0 / a,
    'itof': lambda a: _bits(a).view(np.int32).astype(np.float32),
    'utof': lambda a: _bits(a).astype(np.float32),
    'ftoi': lambda a: np.trunc(a).astype(np.int32).view(np.float32),
    'ftou': lambda a: np.trunc(np.maximum(a, 0)).astype(np.uint32).view(np.float32),
    'not': lambda a: (~_bits(a)).view(np.float32),
}
BINARY = {
    'add': np.add, 'sub': np.subtract, 'mul': np.multiply, 'div': np.divide,
    'min': np.fmin, 'max': np.fmax,     # D3D: a NaN operand yields the other operand
    'ge': lambda a, b: _from_bool(a >= b), 'lt': lambda a, b: _from_bool(a < b),
    'eq': lambda a, b: _from_bool(a == b), 'ne': lambda a, b: _from_bool(a != b),
    'and': lambda a, b: (_bits(a) & _bits(b)).view(np.float32),
    'or': lambda a, b: (_bits(a) | _bits(b)).view(np.float32),
    'xor': lambda a, b: (_bits(a) ^ _bits(b)).view(np.float32),
    'iadd': lambda a, b: (_bits(a).view(np.int32) + _bits(b).view(np.int32)).view(np.float32),
    # SM3 comparison helpers produce 1.0 / 0.0
    'sge': lambda a, b: (a >= b).astype(np.float32), 'slt': lambda a, b: (a < b).astype(np.float32),
    'pow': lambda a, b: np.power(np.abs(a), b),
}
TERNARY = {
    'mad': lambda a, b, c: a * b + c,
    'movc': lambda c, a, b: np.where(_bits(c) != 0, a, b),
    'lrp': lambda t, a, b: t * (a - b) + b,                    # SM3
    'cmp': lambda c, a, b: np.where(c >= 0, a, b),             # SM3
}


class Machine:
    """Executes a parsed program over `count` elements."""

    def __init__(self, program: Program, count: int, constants: dict[str, np.ndarray] | None = None,
                 textures: dict[str, Texture] | None = None, samplers: dict[str, dict] | None = None, quads: bool = False):
        """textures: 'tN' (SM4) or 'sN' (SM3) -> Texture. samplers: SM4 'sN' -> addressing
        overrides {'address_u', 'address_v', 'point'} applied at each sample.
        quads: the elements are 2x2 pixel quads (x, y), (x+1, y), (x, y+1), (x+1, y+1), as
        draw(quads=True) passes them: screen derivatives and mip selection then work.
        Without it every sample reads level 0."""
        self.program, self.count, self.quads = program, count, quads
        self.constants = constants or {}
        self.textures = textures or {}
        self.samplers = samplers or {}
        self.reg: dict[str, np.ndarray] = {}
        self.discard = np.zeros(count, dtype=bool)
        self.sm3 = program.profile.endswith('3_0')
        self.active: list[np.ndarray] = []      # SM3 if/else masks, innermost last

    def register(self, name: str) -> np.ndarray:
        if name not in self.reg:
            self.reg[name] = np.zeros((self.count, 4), dtype=np.float32)
        return self.reg[name]

    def read(self, op: Operand, width: int = 4) -> np.ndarray:
        if op.kind == 'lit':
            base = np.broadcast_to(op.literal, (self.count, 4))
        elif op.kind == 'cb':
            base = np.broadcast_to(self.constants[op.name][op.index], (self.count, 4))
        elif op.kind == 'relative':
            name, component = op.relative
            indices = self.register(name)[:, component].astype(np.int64) + op.index
            base = self.constants[op.name][indices]
        elif self.sm3 and re.fullmatch(r'c\d+', op.name):
            value = self.program.defs.get(op.name)
            if value is None:
                value = self.constants['c'][int(op.name[1:])]
            base = np.broadcast_to(value, (self.count, 4))
        else:
            base = self.register(op.name)
        swz = op.swizzle
        if len(swz) == 1:
            swz = swz * 4
        elif len(swz) < 4:
            swz = swz + (swz[-1],) * (4 - len(swz))
        value = base[:, list(swz)]
        if op.absolute:
            value = np.abs(value)
        if op.negate:
            value = -value
        return value

    def write(self, dst: Operand, value: np.ndarray, saturate: bool) -> None:
        # In both SM3 and SM4 listings a source swizzle yields a 4-vector and
        # the destination mask picks components of it by position.
        target = self.register(dst.name)
        mask = dst.swizzle if dst.explicit else (0, 1, 2, 3)
        if saturate:
            value = np.clip(np.nan_to_num(value, nan=0.0), 0.0, 1.0)
        for comp in mask:
            if self.active:
                target[:, comp] = np.where(self.active[-1], value[:, comp], target[:, comp])
            else:
                target[:, comp] = value[:, comp]

    def run(self) -> None:
        with np.errstate(all='ignore'):
            for ins in self.program.instructions:
                self.step(ins)

    def derivative(self, value: np.ndarray, axis: int) -> np.ndarray:
        """Screen derivative inside each 2x2 quad: along x per row, along y per column."""
        if not self.quads:
            raise NotImplementedError('screen derivative outside a quad run (draw(quads=True))')
        quad = value.reshape(-1, 4, value.shape[1])
        ahead, behind = ((1, 1, 3, 3), (0, 0, 2, 2)) if axis == 0 else ((2, 3, 2, 3), (0, 1, 0, 1))
        return (quad[:, ahead] - quad[:, behind]).reshape(value.shape)

    def implicit_lod(self, coord: np.ndarray, tex: Texture) -> np.ndarray | None:
        """Level of detail from the texel-space derivatives of the coordinate (isotropic:
        log2 of the longer of the two derivative vectors), before the sampler bias."""
        if not self.quads or not tex.mips:
            return None
        h, w = tex.data.shape[:2]
        texel = coord[:, :2].astype(np.float64) * (w, h)
        dx, dy = self.derivative(texel, 0), self.derivative(texel, 1)
        return 0.5 * np.log2(np.maximum((dx * dx).sum(axis=1), (dy * dy).sum(axis=1)))

    def step(self, ins: Instruction) -> None:
        op, a = ins.op, ins.args
        if op in ('ret', 'nop'):
            return
        if op.startswith('if_'):                                   # SM3 dynamic branch, run as a mask
            x, y = self.read(a[0])[:, 0], self.read(a[1])[:, 0]
            cond = {'gt': x > y, 'lt': x < y, 'ge': x >= y, 'le': x <= y, 'eq': x == y, 'ne': x != y}[op[3:]]
            self.active.append(cond & self.active[-1] if self.active else cond)
            return
        if op == 'else':
            inner = self.active.pop()
            outer = self.active[-1] if self.active else np.ones(self.count, bool)
            self.active.append(outer & ~inner)
            return
        if op == 'endif':
            self.active.pop()
            return
        if op in UNARY:
            self.write(a[0], np.asarray(UNARY[op](self.read(a[1])), dtype=np.float32), ins.saturate)
        elif op in BINARY:
            self.write(a[0], np.asarray(BINARY[op](self.read(a[1]), self.read(a[2])), dtype=np.float32), ins.saturate)
        elif op in TERNARY:
            self.write(a[0], np.asarray(TERNARY[op](self.read(a[1]), self.read(a[2]), self.read(a[3])), dtype=np.float32), ins.saturate)
        elif op in ('dp2', 'dp3', 'dp4'):
            n = int(op[2])
            x, y = self.read(a[1]), self.read(a[2])
            dot = np.sum(x[:, :n] * y[:, :n], axis=1, dtype=np.float32)
            self.write(a[0], np.repeat(dot[:, None], 4, axis=1), ins.saturate)
        elif op == 'dp2add':                                       # SM3
            x, y, z = self.read(a[1]), self.read(a[2]), self.read(a[3])
            dot = x[:, 0] * y[:, 0] + x[:, 1] * y[:, 1] + z[:, 0]
            self.write(a[0], np.repeat(dot[:, None], 4, axis=1), ins.saturate)
        elif op in ('sample', 'sample_l', 'sample_b', 'sample_d'):
            coord = self.read(a[1])
            tex = self.textures[a[2].name]
            override = self.samplers.get(a[3].name)
            if override:
                tex = Texture(tex.data, override.get('address_u', tex.address_u), override.get('address_v', tex.address_v),
                              override.get('border', tex.border), override.get('point', tex.point), tex.mips, tex.bias)
            if op == 'sample_l':
                lod = self.read(a[4])[:, 0] if tex.mips else None
            elif op == 'sample_d':
                lod = None
            else:
                lod = self.implicit_lod(coord, tex)
                if op == 'sample_b' and lod is not None:
                    lod = lod + self.read(a[4])[:, 0]
            texel = sample(tex, coord[:, 0], coord[:, 1], lod)
            swz = a[2].swizzle if len(a[2].swizzle) == 4 else (0, 1, 2, 3)
            self.write(a[0], texel[:, list(swz)], ins.saturate)
        elif op == 'texld':                                        # SM3
            coord = self.read(a[1])
            tex = self.textures[a[2].name]
            texel = sample(tex, coord[:, 0], coord[:, 1], self.implicit_lod(coord, tex))
            self.write(a[0], texel, ins.saturate)
        elif op in ('dsx', 'dsy', 'deriv_rtx', 'deriv_rty', 'deriv_rtx_coarse', 'deriv_rty_coarse',
                    'deriv_rtx_fine', 'deriv_rty_fine'):
            self.write(a[0], self.derivative(self.read(a[1]), 0 if 'x' in op else 1), ins.saturate)
        elif op in ('discard_nz', 'discard_z'):
            value = _bits(self.read(a[0]))[:, 0]
            self.discard |= (value != 0) if op == 'discard_nz' else (value == 0)
        elif op == 'texkill':                                      # SM3: any of xyz < 0
            kill = np.any(self.read(a[0])[:, :3] < 0, axis=1)
            self.discard |= kill & self.active[-1] if self.active else kill
        elif op == 'sincos':
            src = self.read(a[2])
            if a[0].name != 'null':
                self.write(a[0], np.sin(src), ins.saturate)
            if a[1].name != 'null':
                self.write(a[1], np.cos(src), ins.saturate)
        elif op == 'crs':                                          # SM3 cross product
            x, y = self.read(a[1]), self.read(a[2])
            out = np.zeros_like(x)
            out[:, :3] = np.cross(x[:, :3], y[:, :3])
            self.write(a[0], out, ins.saturate)
        elif op in ('texldl', 'texldb'):                           # SM3: w is the level (texldl) or a bias (texldb)
            coord = self.read(a[1])
            tex = self.textures[a[2].name]
            if op == 'texldl':
                lod = coord[:, 3] if tex.mips else None
            else:
                lod = self.implicit_lod(coord, tex)
                lod = lod + coord[:, 3] if lod is not None else None
            self.write(a[0], sample(tex, coord[:, 0], coord[:, 1], lod), ins.saturate)
        elif op == 'nrm':                                          # SM3
            v = self.read(a[1])
            length = np.sqrt(np.sum(v[:, :3] ** 2, axis=1, keepdims=True))
            self.write(a[0], v / length, ins.saturate)
        else:
            raise NotImplementedError(f'opcode {op!r} in: {ins.text}')


def load_program(bytecode: bytes) -> Program:
    return parse_program(disassemble(bytecode))


def takes_derivatives(program: Program) -> bool:
    """The program has explicit screen derivatives: it has to run on quads."""
    return any(ins.op in ('dsx', 'dsy') or ins.op.startswith('deriv_rt') for ins in program.instructions)


# ---------------------------------------------------------------------------
# Rasterizer
# ---------------------------------------------------------------------------

BLEND_FACTORS = {
    'Zero': lambda s, d: 0.0, 'One': lambda s, d: 1.0,
    'SrcAlpha': lambda s, d: s[:, 3:4], 'InvSrcAlpha': lambda s, d: 1.0 - s[:, 3:4],
    'DstAlpha': lambda s, d: d[:, 3:4], 'InvDstAlpha': lambda s, d: 1.0 - d[:, 3:4],
    'SrcColor': lambda s, d: s, 'InvSrcColor': lambda s, d: 1.0 - s,
    'DstColor': lambda s, d: d, 'InvDstColor': lambda s, d: 1.0 - d,
}
BLEND_OPS = {'Add': lambda s, d: s + d, 'Subtract': lambda s, d: s - d, 'ReversedSubtract': lambda s, d: d - s,
             'Min': np.minimum, 'Max': np.maximum}
DEPTH_FUNCS = {'Never': lambda z, d: np.zeros(z.shape, bool), 'Less': np.less, 'Equal': np.equal,
               'LessEqual': np.less_equal, 'Greater': np.greater, 'NotEqual': np.not_equal,
               'GreaterEqual': np.greater_equal, 'AlwaysPass': lambda z, d: np.ones(z.shape, bool)}


@dataclass
class RenderState:
    depth_test: bool = True
    depth_write: bool = True
    depth_func: str = 'LessEqual'
    cull: str = 'NoCull'                        # NoCull, Front, Back (front = clockwise on screen)
    front_counter_clockwise: bool = False
    blend: bool = False
    rgb: tuple[str, str, str] = ('One', 'Zero', 'Add')
    alpha: tuple[str, str, str] = ('One', 'Zero', 'Add')
    write_mask: int = 15
    stencil_write: int | None = None            # value stored where a fragment passes (compare ALWAYS, pass REPLACE)


@dataclass
class Framebuffer:
    color: list[np.ndarray]                     # each (H, W, 4) float32 in [0, 1]
    depth: np.ndarray                           # (H, W) float32
    quantize: bool = True                       # UNORM8 targets
    stencil: np.ndarray | None = None           # (H, W) uint8, allocated by the caller when needed

    @property
    def size(self) -> tuple[int, int]:
        return self.depth.shape[1], self.depth.shape[0]


def strip_to_triangles(indices: np.ndarray, cut: int = 0xFFFF) -> np.ndarray:
    tris, run = [], []
    for value in list(indices) + [cut]:
        if value == cut:
            for i in range(len(run) - 2):
                a, b, c = run[i], run[i + 1], run[i + 2]
                if a != b and b != c and a != c:
                    tris.append((a, b, c) if i % 2 == 0 else (b, a, c))
            run = []
        else:
            run.append(int(value))
    return np.array(tris, dtype=np.int64).reshape(-1, 3)


def draw(fb: Framebuffer, position: np.ndarray, varyings: dict[str, np.ndarray], triangles: np.ndarray,
         pixel_shader, state: RenderState, outputs: tuple[str, ...] = ('o0',), stats: dict | None = None,
         quads: bool = False) -> None:
    """Rasterize triangles.

    position: (V, 4) clip-space. varyings: register -> (V, 4). pixel_shader(count, inputs)
    receives interpolated registers plus 'position' (pixel centre x, y, depth, 1/w) and returns
    (dict register -> (count, 4), discard mask).

    quads: shade the whole 2x2 quad (even-aligned) of every covered pixel, four elements
    per pixel in the order (x, y), (x+1, y), (x, y+1), (x+1, y+1), the inputs of the
    uncovered ones extrapolated from the triangle's plane as the hardware does. The pixel
    shader (Machine(quads=True)) can then take screen derivatives; only the covered
    pixel's result is kept.
    """
    width, height = fb.size
    w = position[:, 3].astype(np.float64)
    ndc = position[:, :3].astype(np.float64) / w[:, None]
    sx = np.round(((ndc[:, 0] * 0.5 + 0.5) * width) * 256.0) / 256.0
    sy = np.round(((1.0 - (ndc[:, 1] * 0.5 + 0.5)) * height) * 256.0) / 256.0
    sz = ndc[:, 2]
    names = list(varyings)
    for tri in triangles:
        i0, i1, i2 = (int(t) for t in tri)
        if min(w[i0], w[i1], w[i2]) <= 0:
            if stats is not None:
                stats['near_clipped'] = stats.get('near_clipped', 0) + 1
            continue
        area = (sx[i1] - sx[i0]) * (sy[i2] - sy[i0]) - (sy[i1] - sy[i0]) * (sx[i2] - sx[i0])
        if area == 0:
            continue
        clockwise = area > 0
        front = clockwise != state.front_counter_clockwise
        if (state.cull == 'Back' and not front) or (state.cull == 'Front' and front):
            continue
        if not clockwise:
            i1, i2 = i2, i1
            area = -area
        xs, ys = (sx[i0], sx[i1], sx[i2]), (sy[i0], sy[i1], sy[i2])
        x_min, x_max = max(int(np.floor(min(xs) - 0.5)), 0), min(int(np.ceil(max(xs) - 0.5)), width - 1)
        y_min, y_max = max(int(np.floor(min(ys) - 0.5)), 0), min(int(np.ceil(max(ys) - 0.5)), height - 1)
        if x_min > x_max or y_min > y_max:
            continue
        px = np.arange(x_min, x_max + 1, dtype=np.float64) + 0.5
        py = np.arange(y_min, y_max + 1, dtype=np.float64) + 0.5
        gx, gy = np.meshgrid(px, py)

        def edge(a, b):
            value = (xs[b] - xs[a]) * (gy - ys[a]) - (ys[b] - ys[a]) * (gx - xs[a])
            top_left = (ys[a] == ys[b] and xs[b] > xs[a]) or (ys[b] < ys[a])
            return value, (value > 0) | ((value == 0) & top_left)

        e0, in0 = edge(1, 2)
        e1, in1 = edge(2, 0)
        e2, in2 = edge(0, 1)
        inside = in0 & in1 & in2
        if not inside.any():
            continue
        rows, cols = np.nonzero(inside)
        l0, l1, l2 = e0[rows, cols] / area, e1[rows, cols] / area, e2[rows, cols] / area
        depth = (l0 * sz[i0] + l1 * sz[i1] + l2 * sz[i2]).astype(np.float32)
        yy, xx = rows + y_min, cols + x_min
        if state.depth_test:
            keep = DEPTH_FUNCS[state.depth_func](depth, fb.depth[yy, xx])
            if not keep.any():
                continue
            l0, l1, l2, depth, yy, xx = l0[keep], l1[keep], l2[keep], depth[keep], yy[keep], xx[keep]
        if quads:
            own = np.arange(len(xx)) * 4 + (xx & 1) + 2 * (yy & 1)
            qx = ((xx & ~1)[:, None] + np.array([0, 1, 0, 1])).reshape(-1)
            qy = ((yy & ~1)[:, None] + np.array([0, 0, 1, 1])).reshape(-1)
            cx, cy = qx + 0.5, qy + 0.5

            def weight(a, b):
                return ((xs[b] - xs[a]) * (cy - ys[a]) - (ys[b] - ys[a]) * (cx - xs[a])) / area

            q0, q1, q2 = weight(1, 2), weight(2, 0), weight(0, 1)
            q_depth = (q0 * sz[i0] + q1 * sz[i1] + q2 * sz[i2]).astype(np.float32)
        else:
            own, qx, qy, q0, q1, q2, q_depth = None, xx, yy, l0, l1, l2, depth
        p0, p1, p2 = q0 / w[i0], q1 / w[i1], q2 / w[i2]
        inv = p0 + p1 + p2
        inputs = {name: ((p0[:, None] * varyings[name][i0] + p1[:, None] * varyings[name][i1]
                          + p2[:, None] * varyings[name][i2]) / inv[:, None]).astype(np.float32) for name in names}
        inputs['position'] = np.stack([qx + 0.5, qy + 0.5, q_depth, inv], axis=1).astype(np.float32)
        result, discard = pixel_shader(len(qx), inputs)
        if own is not None:
            result, discard = {name: value[own] for name, value in result.items() if len(value) == len(qx)}, discard[own]
        live = ~discard
        if stats is not None:
            stats['pixels'] = stats.get('pixels', 0) + int(live.sum())
        if not live.any():
            continue
        yy, xx, depth = yy[live], xx[live], depth[live]
        if state.stencil_write is not None and fb.stencil is not None:
            fb.stencil[yy, xx] = state.stencil_write
        for slot, name in enumerate(outputs):
            if slot >= len(fb.color) or name not in result:
                continue
            src = np.clip(np.nan_to_num(result[name][live]), 0.0, 1.0)
            dst = fb.color[slot][yy, xx]
            if state.blend:
                rgb = BLEND_OPS[state.rgb[2]](src * BLEND_FACTORS[state.rgb[0]](src, dst), dst * BLEND_FACTORS[state.rgb[1]](src, dst))
                alpha = BLEND_OPS[state.alpha[2]](src * BLEND_FACTORS[state.alpha[0]](src, dst), dst * BLEND_FACTORS[state.alpha[1]](src, dst))
                out = np.concatenate([rgb[:, :3], alpha[:, 3:4]], axis=1)
            else:
                out = src
            out = np.clip(out, 0.0, 1.0)
            if fb.quantize:
                out = np.floor(out * 255.0 + 0.5) / 255.0
            for c in range(4):
                if state.write_mask >> c & 1:
                    dst[:, c] = out[:, c]
            fb.color[slot][yy, xx] = dst
        if state.depth_write and state.depth_test:
            fb.depth[yy, xx] = depth
