"""Import one Storm Connections skill into a data package for the GMod engine.

  python storm_import.py 4efb_amt1_x            # data/skill/4efb_amt1_x.xfbin

Everything is read from the game's own files (game_data.GameData); nothing is
taken from GPU captures and no value is tuned. The package holds, for every
skill script of the file:

  skills           the decoded scripts (actions, parameters, events, shot types)
  effects          per animation chunk: emitters (decoded nuccChunkParticle)
  spatialRecords   emitter attachments and force fields
  animations       decoded nuccChunkAnm (effect roots and animated resources)
  resources        what an emitter spawns: billboard, clump or animation
  models           NUD geometry, NUD material state, nuccChunkMaterial values,
                   nuccChunkModel header (layer, light set) and node opacity
  textures         NUT blocks rewrapped as VTF (no recompression)
  unsupported      every reference the importer could not turn into data

The engine side decides what it can draw (shader key families, action types);
the importer only reports what the data contains.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))

import skill_script  # noqa: E402
from chunk_index import ChunkIndex  # noqa: E402
from decode_effect_animation import decode as decode_anm  # noqa: E402
from game_data import GameData  # noqa: E402
from inspect_nud import parse_nud  # noqa: E402
from inspect_page_refs import resolve, table  # noqa: E402
from nut_to_vtf import convert as nut_to_vtf  # noqa: E402
from shader_library import ShaderLibrary  # noqa: E402
from shader_port import (LEVEL_ZERO_BIAS, Unsupported, address_code, address_mode, address_name,  # noqa: E402
                         build as build_shader, lod_name, nud_filter, nud_lod_bias, size_name, translate as translate_shader)
from xfbin_chunks import parse  # noqa: E402

ADDON = ROOT.parent / 'storm_amaterasu_lab'
PACKAGES = ADDON / 'lua/storm_fx/packages'
TEXTURE_DIR = 'storm_fx'
VTF_POINTSAMPLE, VTF_TRILINEAR, VTF_CLAMPS, VTF_CLAMPT = 0x1, 0x2, 0x4, 0x8        # TEXTUREFLAGS_*
# NUD sampler record of a material texture the mesh does not describe: wrap, linear, no bias.
DEFAULT_SAMPLER = {'wrap_s': 1, 'wrap_t': 1, 'min_filter': 6, 'mag_filter': 2, 'lod_field': 0}
FILTER_KINDS = {1: 'point with a linear mip filter', 2: 'linear with a point mip filter', 4: 'anisotropic'}
BILLBOARD_WIDTHS = (12, 4, 8, 4, 8, 8, 4, 4, 4, 8, 8, 4, 4)
MATERIAL_BLOCKS = ((0x01, 4), (0x02, 4), (0x04, 4), (0x08, 4), (0x10, 2), (0x20, 1), (0x40, 1), (0x80, 1))
# Material binder 0x1412f5ff0: material instance field -> (shader constant, component).
# g_uvOffsetN = (offset.xy, scale.xy) of UV set N; g_blendRate.xy; g_commonParam.x is
# the alpha threshold and .w the header float. g_uvOffset2.x and g_olIdParam.x are
# handled where the values are built (they depend on the material format).
INSTANCE_CONSTANTS = {0x30: ('g_uvOffset0', 0), 0x34: ('g_uvOffset0', 1), 0x50: ('g_uvOffset0', 2), 0x54: ('g_uvOffset0', 3),
                      0x38: ('g_uvOffset1', 0), 0x3c: ('g_uvOffset1', 1), 0x58: ('g_uvOffset1', 2), 0x5c: ('g_uvOffset1', 3),
                      0x40: ('g_uvOffset2', 0), 0x44: ('g_uvOffset2', 1), 0x60: ('g_uvOffset2', 2), 0x64: ('g_uvOffset2', 3),
                      0x48: ('g_uvOffset3', 0), 0x4c: ('g_uvOffset3', 1), 0x68: ('g_uvOffset3', 2), 0x6c: ('g_uvOffset3', 3),
                      0x70: ('g_blendRate', 0), 0x74: ('g_blendRate', 1), 0x80: ('g_commonParam', 0), 0x7c: ('g_commonParam', 3)}
# What the engine sets per draw for every material: the atlas rectangle
# (billboard frames), the particle colour, alpha threshold and alpha, and the
# clock-driven screen scroll.
DRAW_CONSTANTS = {('g_uvOffset0', c) for c in range(4)} | {('g_multColor', c) for c in range(4)} \
    | {('g_uvOffsetScreen', c) for c in range(4)} | {('g_commonParam', 0), ('g_commonParam', 1)}
# Values of the scene an effect plays in; the engine's stage table supplies them.
# The context fill 0x1413368f0 takes them from the scene's light set, fog and
# environment (g_celShadeParam: only .x is written).
STAGE_CONSTANTS = {'g_fogParam', 'g_fogColor', 'g_ambientColor', 'g_ScreenToUV', 'g_lightColor', 'g_stageColor',
                   'g_celShadeParam', 'g_zrange', 'g_clip'}
# Stage vectors the context fill takes into the object space of each draw
# (shader_port.OBJECT): the vertex shader of the port does the same.
OBJECT_CONSTANTS = {'g_lightDirection'}
# Point lights: the effects that carry a light register it with the scene, and a
# lit model gets the first four, sorted for its position (point_light_core.lua).
# Slot 0 is the engine's, per draw; the lit shaders of the effect models read no
# other. A slot nobody uses holds these values (context fill 0x141336d4a).
UNUSED_POINT_LIGHT = {'g_pointLightColor': (0.0, 0.0, 0.0, 1.0), 'g_pointLightPos': (0.0, 0.0, 0.0, 1.0),
                      'g_pointLightParam': (0.0, 0.0, 1.0, 1.1920928955078125e-07)}
# The lit families end on a radial screen tint ("cpara"): colour 1 at the screen
# point g_cparaParam.xy, colour 2 from the radius .z to .w; the .w of the two
# colours is the inverse screen size. The captured stage has no tint (both colours
# white, radii 0 and 0.01). The pixel constants cannot carry all of it per stage,
# so those values are compiled in: a stage that tints needs a re-import. None
# marks the components the engine does supply (the inverse screen size).
FROZEN_STAGE = {'g_cparaColor1': (1.0, 1.0, 1.0, None), 'g_cparaColor2': (1.0, 1.0, 1.0, None),
                'g_cparaParam': (0.0, 0.0, 0.0, 0.01)}
# When a lit shader needs more per-draw and stage floats than screenspace_general
# can carry, these stage values are compiled in too, in this order, with the
# values of the captured stage (the engine's default stage). The package says
# which meshes are concerned; for them a host stage that changes these values
# needs a re-import.
STAGE_FREEZE_ORDER = ('g_celShadeParam', 'g_stageColor', 'g_lightColor')
# Meshes up to this many triangles get a batched shader (their per-draw values in the
# vertices): the engine then puts the vertices of many particles in one draw, placed in the
# world on the CPU, about ten calls a vertex. Bigger meshes keep their cached buffer and one
# draw each (a 32-triangle mesh sends 96 vertices a particle: dearer than its draw).
BATCH_TRIANGLES = 8


def batchable(layout: dict) -> bool:
    """A shader the engine can batch: nothing per draw left in the pixel constants, and
    nothing that needs the model matrix itself (normals, object-space stage vectors)."""
    return (not layout['dynamic'] and not layout['object'] and not layout['attributes']['normal']
            and set(layout['matrices']) <= {'g_matWorldViewProj'})
# Trail ribbons (Importer.ribbon): shader key of the descriptor 0x141327240, alpha
# threshold the draw command 0x141389f40 writes (FLT_MIN, 0x141860548), LOD bias of the
# descriptor (+2EC).
TRAIL_SHADER_KEY = 0x1F007
TRAIL_THRESHOLD = 1.1754943508222875e-38
TRAIL_LOD_BIAS = -8.0
# Render state of a ribbon: descriptor flags 0x121, the trail factory's value without a
# material (0x141325be6), as captured for 4efb_amt1_blt00 (journal R98: SrcAlpha /
# InvSrcAlpha, alpha One / Zero, depth test without writes, no culling). In the NUD terms
# of render.lua R.state: source_factor bit 0 translucent, bit 1 clear depth-sorted, bit 2
# no depth write; dest_factor colour mode 1, alpha mode 0; cull_mode not 1029.
TRAIL_STATE = {'source_factor': 5, 'dest_factor': 0x01, 'cull_mode': 0}
CAPTURED_STAGE = {'g_celShadeParam': (0.0, 0.0, 0.0, 0.0), 'g_stageColor': (143 / 255, 142 / 255, 98 / 255, 1.0),
                  'g_lightColor': (160 / 255, 160 / 255, 140 / 255, 1.0)}
# Material animation: curve index -> material instance field (evaluator 0x14139d440).
MATERIAL_CURVE_FIELDS = (0x30, 0x34, 0x38, 0x3c, 0x40, 0x44, 0x48, 0x4c, 0x50, 0x54, 0x58, 0x5c, 0x70, 0x74, 0x78, 0x7c, 0x80, 0x84,
                         0x68, 0x6c, 0x60, 0x64, 0x88)
# Constants the render context fills (the 72 accessors of shader_bindings_dispatch.json).
# Any other constant of a shader is a NUD property (NU_x -> g_x) or a field the
# material binder writes; the staging block is zero-filled after each draw, so a
# property the material does not have reads zero.
CONTEXT_CONSTANTS = {row['name'] for row in json.loads((ROOT / 'shader_bindings_dispatch.json').read_text(encoding='utf-8'))}


# Constants one Lua function of a package may hold. Garry's Mod runs LuaJIT, which refuses
# a function with more than 65536 constants ("main function has more than 65536
# constants": 1efcmn_x as one table literal); the writer counts every number and string
# (an upper bound: LuaJIT shares equal ones) and moves big parts into functions of their own.
LUA_CONSTANTS = 30000


def _lua(value) -> tuple[str, int]:
    """(Lua text, constants it adds to the function it is written in)."""
    if value is None:
        return 'nil', 0
    if isinstance(value, bool):
        return ('true' if value else 'false'), 0
    if isinstance(value, float) and (value != value or value in (float('inf'), float('-inf'))):
        # repr() gives nan / inf, which Lua reads as globals (nil): the game's data does
        # hold such values (NaN half-float UVs and normals in 2sco_x, 3hsm_x, journal R101).
        return ('(0/0)' if value != value else '(1/0)' if value > 0 else '(-1/0)'), 2
    if isinstance(value, (int, float)):
        return repr(value), 1
    if isinstance(value, str):
        # Lua has no \uXXXX escape (LuaJIT and Lua 5.3+ only take \u{...}): a chunk name
        # with full-width letters (1knk_x: "1kar00t0 bodybＬ1") would stop the package from
        # loading. Its UTF-8 bytes go out as three-digit decimal escapes, valid everywhere.
        out = []
        for byte in value.encode('utf-8', 'surrogateescape'):
            if byte in (0x22, 0x5c):
                out.append('\\' + chr(byte))
            elif 0x20 <= byte < 0x7f:
                out.append(chr(byte))
            else:
                out.append(f'\\{byte:03d}')
        return '"' + ''.join(out) + '"', 1
    listed = isinstance(value, (list, tuple))
    entries = []                                    # (key text or None, value text, constants)
    for key, item in (enumerate(value) if listed else value.items()):
        text, count = _lua(item)
        if count > LUA_CONSTANTS // 4:
            # A big part goes into a function of its own: one constant here.
            text, count = f'(function() return {text} end)()', 1
        if listed:
            entries.append((None, text, count))
        else:
            key_text, key_count = _lua(key)
            entries.append((key_text, text, count + key_count))
    total = sum(e[2] for e in entries)

    def literal(part):
        return '{' + ','.join(t if k is None else f'[{k}]={t}' for k, t, _ in part) + '}'
    if total <= LUA_CONSTANTS:
        return literal(entries), total
    # Too many entries for one function: chunks built in functions of their own, merged at
    # load (positions kept, nil included).
    chunks, part, size = [], [], 0
    for entry in entries:
        if part and size + entry[2] > LUA_CONSTANTS:
            chunks.append(part)
            part, size = [], 0
        part.append(entry)
        size += entry[2]
    chunks.append(part)
    body, offset = [], 0
    for part in chunks:
        made = f'(function() return {literal(part)} end)()'
        if listed:
            body.append(f'c={made} for i=1,{len(part)} do t[{offset}+i]=c[i] end')
            offset += len(part)
        else:
            body.append(f'for k,v in pairs({made}) do t[k]=v end')
    return '(function() local t,c={} ' + ' '.join(body) + ' return t end)()', 2 * len(chunks)


def lua(value) -> str:
    return _lua(value)[0]


class Short(float):
    """A float32 of the game written with the fewest digits that give that float32 back
    (0.3, not 0.30000001192092896): geometry only, which the engine sends to the GPU as is.
    The value Lua reads is within half a float32 step of the game's."""

    def __repr__(self) -> str:
        value = np.float32(self)
        text = min(np.format_float_positional(value, unique=True, trim='-'),
                   np.format_float_scientific(value, unique=True, trim='-'), key=len)
        return '0' if text in ('0', '-0', '0e+00', '-0e+00') else text


def short_geometry(models: dict) -> None:
    """Vertex rows and second UV sets of every mesh, written short (Short)."""
    for model in models.values():
        for mesh in (model or {}).get('meshes', []):
            for key in ('vertices', 'uvSets'):
                rows = mesh.get(key)
                if rows:
                    mesh[key] = [_short_row(row) for row in rows]


def _short_row(row):
    if isinstance(row, (list, tuple)):
        return [_short_row(v) for v in row]
    if isinstance(row, float) and row == row and abs(row) != float('inf') and abs(row) < 3.4e38:
        return Short(row)
    return row


class Xfbin:
    def __init__(self, name: str, path: Path):
        self.name, self.path = name, path
        self.data, self.chunks = parse(path)
        self.table = table(self.data)
        self.by_key: dict[tuple[str, str], dict] = {}
        for c in self.chunks:
            self.by_key.setdefault((c['type'], c['name']), c)
        # Path this file gives to every chunk it defines or references.
        types, paths, names, maps, _ = self.table
        self.declared: dict[tuple[str, str], str] = {}
        for t, p, n in maps:
            self.declared.setdefault((types[t], names[n]), paths[p])
        counts = struct.unpack_from('>10I', self.data, 28)
        start = ((68 + counts[1] + counts[3] + counts[5] + 3) & ~3) + counts[7]
        pairs = [struct.unpack_from('>II', self.data, start + i * 8) for i in range(counts[9])]
        self.page_refs, cursor = {}, 0
        for c in self.chunks:
            if c['type'] == 'nuccChunkPage':
                extra = struct.unpack_from('>I', self.data, c['offset'] + 4)[0]
                self.page_refs[c['page']] = pairs[cursor:cursor + extra]
                cursor += extra

    def body(self, chunk: dict) -> bytes:
        return self.data[chunk['offset']:chunk['offset'] + chunk['size']]

    def version(self, chunk: dict) -> int:
        return struct.unpack_from('>H', self.data, chunk['offset'] - 4)[0]

    def ref(self, chunk: dict, local: int) -> tuple[str, str, str]:
        """(type, path, name) of a page-local reference made by `chunk`."""
        return resolve(self.table, chunk['page'] + local)


GLOBAL_CELSHADE = 'shader/toon/celshade.nut'      # data/system/celshade.tex.xfbin, the toon ramp


class Library:
    """The xfbin files a skill loads; references resolve by (type, name), nearest file first.

    A chunk no loaded file defines is looked up in the global chunk index by the
    path the referencing file declares for it (e.g. `e\\1efcmn\\max\\...`), and
    the defining file is loaded too: the game has those common files in memory.
    """

    parsed: dict[str, Xfbin] = {}      # shared between importers: common files are large

    def __init__(self, game: GameData, index: ChunkIndex | None = None):
        self.game, self.files, self.index = game, [], index
        self.external: list[str] = []
        self.unindexed: dict[tuple[str, str], str] = {}

    def add(self, name: str) -> Xfbin | None:
        # Skill scripts write some paths with backslashes (b0201_x: "data\bossNrt/08\01\
        # b0101eff1.xfbin"); the archives name every file with forward slashes.
        name = name.replace('\\', '/')
        for xf in self.files:
            if xf.name == name:
                return xf
        if not self.game.has(name):
            return None
        xf = self.parsed.get(name)
        if xf is None:
            xf = self.parsed[name] = Xfbin(name, self.game.fetch(name))
        self.files.append(xf)
        return xf

    def get(self, kind: str, name: str, near: Xfbin | None = None) -> tuple[Xfbin, dict] | None:
        ordered = ([near] if near else []) + [f for f in self.files if f is not near]
        for xf in ordered:
            chunk = xf.by_key.get((kind, name))
            if chunk is not None:
                return xf, chunk
        if self.index is None:
            return None
        path = next((xf.declared[(kind, name)] for xf in ordered if (kind, name) in xf.declared), None)
        if path is None:
            return None
        paths = [path]
        if (kind, name) == ('nuccChunkTexture', 'celshade'):
            # Every celshade texture gets the fixed id 0x10000001 (texture chunk loader
            # 0x141339b00, journal R84): a material whose own ramp file is not shipped
            # (c/1fir/tex/celshade.nut) reads the global ramp, loaded at start-up. R103.
            paths.append(GLOBAL_CELSHADE)
        for wanted in paths:
            for packed in self.index.files(kind, name, wanted):
                xf = self.add(packed)
                chunk = xf.by_key.get((kind, name)) if xf else None
                if chunk is not None:
                    if packed not in self.external:
                        self.external.append(packed)
                    return xf, chunk
        self.unindexed[(kind, name)] = path
        return None

    def named(self, kind: str, name: str) -> tuple[Xfbin, dict] | None:
        """A chunk known by name only (a skill script names its animation, not a
        path): the loaded files first, then the index when exactly one path defines it."""
        found = self.get(kind, name)
        if found or self.index is None:
            return found
        paths = {path for path, _ in self.index.paths(kind, name)}
        if len(paths) != 1:
            return None
        for packed in self.index.files(kind, name):
            xf = self.add(packed)
            chunk = xf.by_key.get((kind, name)) if xf else None
            if chunk is not None:
                if packed not in self.external:
                    self.external.append(packed)
                return xf, chunk
        return None

    def why_missing(self, kind: str, name: str) -> str:
        path = self.unindexed.get((kind, name))
        if path is None:
            return 'chunk not found in the loaded files'
        return f'chunk not found in the loaded files nor in the chunk index (path {path})'


class Importer:
    shader_library: ShaderLibrary | None = None        # the game's shader archive, shared between importers
    without: tuple[str, ...] = ()                      # clump name prefixes whose models are not imported (--without)

    def __init__(self, game: GameData, package: str, addon: Path = ADDON, index: ChunkIndex | None = None):
        self.library = Library(game, index if index is not None else ChunkIndex(game))
        self.package = package
        self.addon = addon
        self.out = {'format': 1, 'name': package, 'skills': {}, 'effects': {}, 'spatialRecords': {}, 'animations': {},
                    'resources': {}, 'models': {}, 'textures': {}, 'unsupported': []}
        self.texture_dir = addon / 'materials' / TEXTURE_DIR

    def unsupported(self, what: str, reason: str) -> None:
        entry = {'what': what, 'reason': reason}
        if entry not in self.out['unsupported']:
            self.out['unsupported'].append(entry)

    # -- textures and materials --------------------------------------------
    def texture(self, name: str, near: Xfbin) -> bool:
        if name in self.out['textures']:
            return self.out['textures'][name] is not False
        found = self.library.get('nuccChunkTexture', name, near)
        if not found:
            self.unsupported(f'texture {name}', self.library.why_missing('nuccChunkTexture', name))
            self.out['textures'][name] = False
            return False
        xf, chunk = found
        raw = xf.body(chunk)
        nut = raw[12:12 + struct.unpack_from('>I', raw, 8)[0]]
        scratch = ROOT / 'game_cache' / 'nut' / f'{name}.nut'
        scratch.parent.mkdir(parents=True, exist_ok=True)
        scratch.write_bytes(nut)
        try:
            native = nut_to_vtf(scratch, self.texture_dir / f'{name}.vtf')
        except (ValueError, struct.error) as error:
            self.unsupported(f'texture {name}', f'NUT not converted: {error}')
            self.out['textures'][name] = False
            return False
        self.out['textures'][name] = {'vtf': f'{TEXTURE_DIR}/{name}', 'width': native['width'], 'height': native['height'],
                                      'format': native['format'], 'levels': native['levels'], 'sha256': hashlib.sha256(nut).hexdigest()}
        if native['images'] > 1:
            # Colour variants of one picture; the game binds image 0 unless a colour
            # index is set at run time (nut_to_vtf.read).
            self.out['textures'][name]['images'] = native['images']
            self.unsupported(f'texture {name}', f'{native["images"]} colour variants in the NUT: image 0 converted, '
                                                'the others (model colour index +0xD0, trail image index +0x1DC) are not')
        return True

    def texture_variant(self, name: str, clamp: str, mipped: bool, point: bool) -> str:
        """VTF of texture `name` as one material samples it, written on first use: with
        the levels of the NUT (`mipped`, else level 0 alone), clamped on the axes of
        `clamp` ('', 's', 't' or 'st'), point filtered. Returns its materials/ path."""
        record = self.out['textures'][name]
        variants = record.setdefault('variants', [])
        base = '_m' if mipped else ''
        if mipped and base not in variants:
            nut_to_vtf(ROOT / 'game_cache' / 'nut' / f'{name}.nut', self.texture_dir / f'{name}{base}.vtf', mipped=True)
            variants.append(base)
        suffix = base + ('_c' + clamp if clamp else '') + ('_p' if point else '')
        if suffix != base and suffix not in variants:
            raw = bytearray((self.texture_dir / f'{name}{base}.vtf').read_bytes())
            flags = struct.unpack_from('<I', raw, 20)[0] | (VTF_CLAMPS if 's' in clamp else 0) | (VTF_CLAMPT if 't' in clamp else 0)
            if point:
                flags = (flags | VTF_POINTSAMPLE) & ~VTF_TRILINEAR
            struct.pack_into('<I', raw, 20, flags)
            (self.texture_dir / f'{name}{suffix}.vtf').write_bytes(raw)
            variants.append(suffix)
        return record['vtf'] + suffix

    def material(self, xf: Xfbin, chunk: dict) -> dict:
        body = xf.body(chunk)
        group_count, field02, _, field04 = struct.unpack_from('>HBBf', body)
        fmt = body[11]
        pos, blocks = 12, {}
        for flag, count in MATERIAL_BLOCKS:
            if fmt & flag:
                blocks[flag] = list(struct.unpack_from(f'>{count}f', body, pos))
                pos += 4 * count
        groups = []
        for _ in range(group_count):
            count, _, flag = struct.unpack_from('>hHi', body, pos)
            pos += 8
            indices = struct.unpack_from(f'>{count}I', body, pos)
            pos += 4 * count
            groups.append({'flag': flag, 'textures': [xf.ref(chunk, i)[2] for i in indices]})
        if pos != len(body):
            raise ValueError(f'material {chunk["name"]}: {len(body) - pos} unparsed bytes')
        # Material instance fields as the loader 0x14134cde0 leaves them (an absent
        # block keeps its default: offsets 0, scales 1, the rest 0), keyed by the
        # instance offsets the binder 0x1412f5ff0 and the animation evaluator use.
        uv = [blocks.get(flag) or [0.0, 0.0, 1.0, 1.0] for flag in (1, 2, 4, 8)]
        blend = blocks.get(0x10) or [0.0, 0.0]
        instance = {0x70: blend[0], 0x74: blend[1], 0x78: (blocks.get(0x20) or [0.0])[0], 0x7c: field04,
                    0x80: field02 / 255, 0x84: (blocks.get(0x40) or [0.0])[0], 0x88: (blocks.get(0x80) or [0.0])[0]}
        for n, block in enumerate(uv):
            instance.update({0x30 + 8 * n: block[0], 0x34 + 8 * n: block[1], 0x50 + 8 * n: block[2], 0x54 + 8 * n: block[3]})
        return {'name': chunk['name'], 'format': fmt, 'field02': field02, 'field04': field04,
                'uv0': blocks.get(1), 'uv1': blocks.get(2), 'uv2': blocks.get(4), 'uv3': blocks.get(8),
                'blend': blocks.get(0x10), 'falloff': (blocks.get(0x20) or [None])[0],
                'tail': (blocks.get(0x40) or [None])[0], 'extra80': (blocks.get(0x80) or [None])[0],
                'instance': {k: instance[k] for k in sorted(instance)},
                'textures': groups[0]['textures'] if groups else [], 'textureGroups': groups}

    # -- models -------------------------------------------------------------
    @staticmethod
    def mesh(nud: bytes, mesh: dict, group: dict) -> dict:
        vertex_type, bone_type = mesh['vertex_size'] & 0x0f, mesh['vertex_size'] & 0xf0
        color_type, uv_count = mesh['uv_size'] & 0x0f, mesh['uv_size'] >> 4
        # A skinned mesh keeps colours and texture coordinates in the first vertex buffer
        # and, in the second, 64 bytes per vertex: position xyzw, normal xyz and a pad,
        # four bone indices (into the clump's coordinates), four weights. The game hands
        # them to its skinning compute shader as they are (skinning_core.lua). The 35
        # skinned effect models surveyed all use float indices / weights (0x10) and
        # float normals (1); their buffer sizes match this layout.
        skinned = bone_type != 0
        if skinned and (bone_type != 0x10 or vertex_type != 1):
            raise ValueError(f'skinned NUD vertices (bone type {bone_type:#x}, vertex type {vertex_type})')
        if not skinned and vertex_type not in (0, 6):
            raise ValueError(f'NUD vertex type {vertex_type}')
        if color_type not in (0, 2, 4):
            raise ValueError(f'NUD colour type {color_type}')
        if uv_count < 1:
            raise ValueError('NUD mesh without texture coordinates')
        pos, vertices, normals, uv_sets = mesh['vertex_offset'], [], [], []
        skin = {'positionW': [], 'normals': [], 'indices': [], 'weights': []}
        for index in range(mesh['vertex_count']):
            if skinned:
                at = mesh['extra_offset'] + index * 64
                x, y, z, w = struct.unpack_from('>4f', nud, at)
                skin['positionW'].append(w)
                skin['normals'].append(list(struct.unpack_from('>3f', nud, at + 16)))
                skin['indices'].append(list(struct.unpack_from('>4i', nud, at + 32)))
                skin['weights'].append(list(struct.unpack_from('>4f', nud, at + 48)))
            else:
                x, y, z = struct.unpack_from('>3f', nud, pos)
                pos += 12
                if vertex_type == 0:
                    pos += 4
                else:
                    normals.append(nud[pos:pos + 8].hex())
                    pos += 8
            if color_type == 2:
                color = [c / 255 for c in nud[pos:pos + 4]]      # 0x14126ad50: bytes / 255.0
                pos += 4
            elif color_type == 4:
                color = list(struct.unpack_from('>4e', nud, pos))
                pos += 8
            else:
                color = [1.0, 1.0, 1.0, 1.0]
            uvs = [list(struct.unpack_from('>2e', nud, pos + i * 4)) for i in range(uv_count)]
            pos += uv_count * 4
            vertices.append([x, y, z, uvs[0][0], uvs[0][1], *color])
            uv_sets.append(uvs)
        indices = struct.unpack_from(f'>{mesh["face_count"]}h', nud, mesh['poly_offset'])
        triangles = []
        if mesh['face_size'] & 0xf0 == 0:
            # Strip with -1 restarts (every effect model seen so far). Emitted with the
            # parity opposite to D3D's, so a game front face (counter-clockwise) arrives
            # clockwise, Source's front face.
            run, flip = [], False
            for value in indices:
                if value < 0:
                    run, flip = [], False
                    continue
                run.append(value)
                if len(run) >= 3:
                    a, b, c = run[-3:]
                    if not flip:
                        b, c = c, b
                    flip = not flip
                    if len({a, b, c}) == 3:
                        triangles.append([a, b, c])
        elif mesh['face_size'] & 0xf0 == 0x40:
            # Triangle list (NUD convention; not met in the effect files checked so far).
            for i in range(0, len(indices) - 2, 3):
                a, b, c = indices[i:i + 3]
                triangles.append([a, c, b])
        else:
            raise ValueError(f'NUD primitive type {mesh["face_size"]:#x}')
        if any(i >= len(vertices) for t in triangles for i in t):
            raise ValueError('NUD face index out of range')
        # A NUD mesh carries one material per render pass; the pass index picks it
        # (0x14126ac30 reads TLS +32D0: 0 for the colour pass, 1 for the outline
        # pass, the shadow and velocity commands use the following ones).
        out = {'vertices': vertices, 'triangles': triangles, 'state': mesh['materials'][0],
               'passes': [m['flags'] for m in mesh['materials']],
               'group': group['name'], 'singleBind': group['single_bind']}
        if normals:
            out['normalHalfRaw'] = normals
        if uv_count > 1:
            out['uvSets'] = uv_sets
        if skinned:
            if any(i < 0 for row in skin['indices'] for i in row):
                raise ValueError('skinned NUD mesh with a negative bone index')
            if all(w == 1.0 for w in skin['positionW']):
                del skin['positionW']       # the usual case; the shader copies w through
            out['skin'] = skin
        return out

    def model(self, name: str, near: Xfbin) -> bool:
        if name in self.out['models']:
            return self.out['models'][name] is not False
        self.out['models'][name] = False
        found = self.library.get('nuccChunkModel', name, near)
        if not found:
            self.unsupported(f'model {name}', self.library.why_missing('nuccChunkModel', name))
            return False
        xf, chunk = found
        body = xf.body(chunk)
        at = body.find(b'NDP3')
        if at < 0:
            self.unsupported(f'model {name}', 'no NDP3 payload')
            return False
        nud_size = struct.unpack_from('>I', body, at + 4)[0]
        nud = body[at:at + nud_size]
        try:
            parsed = parse_nud(nud)
            meshes = [self.mesh(nud, m, g) for g in parsed['groups'] for m in g['meshes']]
        except (ValueError, struct.error) as error:
            self.unsupported(f'model {name}', str(error))
            return False
        tail = at + nud_size
        material_count = struct.unpack_from('>H', body, tail)[0]
        material_refs = struct.unpack_from(f'>{material_count}I', body, tail + 2)
        materials = []
        for local in material_refs:
            kind, _, material_name = xf.ref(chunk, local)
            target = self.library.get(kind, material_name, xf) if kind == 'nuccChunkMaterial' else None
            if not target:
                self.unsupported(f'model {name}', f'material reference {kind} {material_name} not found')
                return False
            materials.append(self.material(*target))
        # The model lists one nuccChunkMaterial per NUD mesh, in mesh order (18084
        # single-mesh and 1156 multi-mesh effect models all have equal counts).
        if len(materials) != len(meshes):
            self.unsupported(f'model {name}', f'{len(materials)} materials for {len(meshes)} meshes')
            return False
        for index, (mesh, material) in enumerate(zip(meshes, materials)):
            mesh['material'] = index
            mesh['textures'] = []
            for slot, texture in enumerate(material['textures']):
                if not self.texture(texture, xf):
                    self.unsupported(f'model {name}', f'texture {texture} unavailable')
                    return False
                # The sampler of a material texture comes from its NUD record (0x141270830).
                # NUD wrap codes stand for D3D11 address modes (shader_port.NUD_ADDRESS_MODE):
                # a VTF can wrap or clamp; mirror, mirror once and border run in the shader
                # on a clamped VTF (shader_port.address_code).
                sampler = mesh['state']['textures'][slot] if slot < len(mesh['state']['textures']) else DEFAULT_SAMPLER
                record = self.out['textures'][texture]
                clamp = ('s' if address_mode(sampler['wrap_s']) != 'wrap' else '') + ('t' if address_mode(sampler['wrap_t']) != 'wrap' else '')
                codes = [address_code(sampler['wrap_s'], record['width']), address_code(sampler['wrap_t'], record['height'])]
                # Filter and level of detail. The game's linear filter is linear on the three
                # (minify, magnify, mip), its point filter point on the three; a sampler whose
                # bias keeps it on level 0, or a texture with one level, gets the VTF that has
                # level 0 alone, the others the VTF with the NUT's levels and a shader that
                # computes the level (shader_port.lod_name).
                kind = nud_filter(sampler['min_filter'], sampler['mag_filter'])
                if kind not in (0, 3):
                    self.unsupported(f'model {name}', f'material texture {slot} filter {kind} '
                                                      f'({FILTER_KINDS[kind]}) drawn with the linear filter')
                bias = nud_lod_bias(sampler['lod_field'])
                mipped = record['levels'] > 1 and bias > LEVEL_ZERO_BIAS
                mesh['textures'].append({'name': texture, 'vtf': self.texture_variant(texture, clamp, mipped, kind == 0),
                                         'address': codes, 'size': [record['width'], record['height']],
                                         'mipped': mipped, 'point': kind == 0,
                                         'lod': [bias, record['levels'] - 1 if mipped else 0, 1 if kind == 0 else 0]})
        coord = self.library.get('nuccChunkCoord', name, xf)
        node = None
        if coord and coord[1]['size'] >= 40:
            values = struct.unpack_from('>10f', coord[0].body(coord[1]))
            # Position, Euler rotation in degrees (x, y, z; the constructor 0x1412892a0 builds
            # translation * Rx * Ry * Rz * scale), scale, opacity.
            node = {'position': values[0:3], 'rotation': values[3:6], 'scale': values[6:9], 'opacity': values[9]}
        skeleton = None
        if any('skin' in mesh for mesh in meshes):
            skeleton = self.skeleton(name, xf, chunk, body, meshes)
            if skeleton is None:
                return False
        self.out['models'][name] = {
            'meshes': meshes, 'materials': materials,
            # Header fields and the parent bone index. Runtime copies (0x1412d40c0): the word
            # at +2 at chunk +A8, the word at +4 at model +2C (attributes is its low byte;
            # bit 0 = camera-facing hook at draw), layer at model +2A, light at model +2B.
            'header': {'rigging': struct.unpack_from('>H', body, 2)[0], 'attributes': body[5], 'layer': body[6], 'light': body[7],
                       'bone': struct.unpack_from('>I', body, 20)[0]},
            'node': node, 'source': xf.name}
        if skeleton:
            self.out['models'][name]['skeleton'] = skeleton
        return True

    def skeleton(self, name: str, xf: Xfbin, chunk: dict, body: bytes, meshes: list) -> dict | None:
        """Rest pose of the clump a skinned model belongs to. A NUD bone index is the
        index of a coordinate of that clump (the skinning palette has one matrix per
        coordinate: verify_skin_palette_capture.py); `rest` holds the nuccChunkCoord
        values of each coordinate: position, Euler rotation in degrees, scale."""
        kind, _, clump_name = xf.ref(chunk, struct.unpack_from('>I', body, 12)[0])
        found = self.library.get('nuccChunkClump', clump_name, xf) if kind == 'nuccChunkClump' else None
        if not found:
            self.unsupported(f'model {name}', f'skinned model without its clump ({kind} {clump_name})')
            return None
        clump = self.clump(*found)
        used = max(i for mesh in meshes for row, weights in zip(mesh.get('skin', {}).get('indices', []),
                                                               mesh.get('skin', {}).get('weights', []))
                   for i, w in zip(row, weights) if w)
        if used >= len(clump['coords']):
            self.unsupported(f'model {name}', f'skinned model bound to bone {used}, its clump has {len(clump["coords"])} coordinates')
            return None
        rest = []
        for index in range(used + 1):
            coord = self.library.get('nuccChunkCoord', clump['coords'][index], found[0])
            if not coord or coord[1]['size'] < 36 or clump['parents'][index] >= index:
                self.unsupported(f'model {name}', f'skinned model: coordinate {clump["coords"][index]} of its clump is not usable')
                return None
            rest.append(list(struct.unpack_from('>9f', coord[0].body(coord[1]))))
        return {'clump': clump_name, 'coords': clump['coords'][:used + 1], 'parents': clump['parents'][:used + 1], 'rest': rest}

    # -- emitter resources --------------------------------------------------
    def clump(self, xf: Xfbin, chunk: dict) -> dict:
        body = xf.body(chunk)
        coord_count = struct.unpack_from('>H', body, 4)[0]
        pos = 8
        parents = struct.unpack_from(f'>{coord_count}h', body, pos)
        pos += 2 * coord_count
        coords = [xf.ref(chunk, i) for i in struct.unpack_from(f'>{coord_count}I', body, pos)]
        pos += 4 * coord_count
        model_count = struct.unpack_from('>H', body, pos)[0]
        pos += 8                                    # count, two flag bytes, one unused word
        members = [xf.ref(chunk, i) for i in struct.unpack_from(f'>{model_count}I', body, pos)]
        return {'coords': [c[2] for c in coords], 'parents': list(parents), 'members': [(m[0], m[2]) for m in members]}

    def billboard(self, xf: Xfbin, chunk: dict) -> tuple[dict, tuple[str, str, str]]:
        data = xf.body(chunk)
        resource, mask, count, _, step = struct.unpack_from('>IIHHI', data)
        pos, channels, rolls = 16, {}, None
        for group, width in enumerate(BILLBOARD_WIDTHS):
            selector = (mask >> (1 + 2 * group)) & 3
            if selector == 3:
                raise ValueError(f'billboard selector 3 in group {group}')
            n = (0, 1, count)[selector]
            if n:
                channels[group + 1] = [list(struct.unpack_from(f'>{width // 4}f', data, pos + i * width)) for i in range(n)]
                if group == 1:
                    # Channel 2 is the roll, a 32-bit integer (0x1412c7b00 copies it to
                    # +2BC; the facing hook 0x1412c84b0 turns it into value * 2pi / 65536).
                    rolls = list(struct.unpack_from(f'>{n}i', data, pos))
            pos += n * width
        if pos != len(data):
            raise ValueError(f'{len(data) - pos} unaccounted billboard bytes')
        board = {'channels': channels, 'count': count, 'stepTicks': step, 'loop': bool(mask & 1)}
        if rolls is not None:
            board['rolls'] = rolls
        return board, xf.ref(chunk, resource)

    def animation(self, xf: Xfbin, chunk: dict) -> bool:
        name = chunk['name']
        if name in self.out['animations']:
            return self.out['animations'][name] is not False
        self.out['animations'][name] = False
        types, _, names, maps, _ = xf.table
        # Two kinds of reference (reader 0x14134a350): a page-local index into the
        # file's chunk map (0x1412864d0), or an index into the page's reference pairs
        # (name index, chunk map index; 0x1412864a0) whose name is the instance name
        # the animation uses (the particle chunk attaches to it; one clump can be
        # instanced several times). A clump block's clump is page-local up to version
        # 0x67 and a pair above; its coordinates / materials and models are always
        # pairs; objects outside the clumps (cameras, lights) and the extra
        # coordinates are always page-local.
        pairs = xf.page_refs.get(chunk['page'], [])
        local = (lambda i: xf.ref(chunk, i)[2], lambda i: (xf.ref(chunk, i)[0], xf.ref(chunk, i)[2]))
        paired = (lambda i: names[pairs[i][0]], lambda i: (types[maps[pairs[i][1]][0]], names[maps[pairs[i][1]][2]]))
        resolvers = {'clump': local if xf.version(chunk) <= 0x67 else paired, 'member': paired, 'other': local}
        try:
            decoded = json.loads(json.dumps(decode_anm(xf.body(chunk), *paired, legacy=xf.version(chunk) <= 0x65,
                                                       resolvers=resolvers)))
        except (ValueError, struct.error, IndexError) as error:
            self.unsupported(f'animation {name}', str(error))
            return False
        # Models an animated clump carries: drawn at their parent bone's animated matrix.
        # An animation's per-clump reference list mixes coordinates and materials (an entry
        # of type 1 targets a coordinate, of type 4 a material); `coords` is the clump
        # chunk's own coordinate order, which a model's parent-bone index refers to.
        for clump in decoded['clumps']:
            chunk_found = self.library.get('nuccChunkClump', clump['chunk'], xf)
            clump['coords'] = self.clump(*chunk_found)['coords'] if chunk_found else []
            # Rest transform of each coordinate the animation lists for this clump
            # (position, Euler rotation in degrees, scale): a coordinate the animation
            # does not animate keeps it (nuccCoord 0x1412892a0), under its parent's pose.
            clump['rest'] = []
            for kind, bone in clump['boneChunks']:
                coord = self.library.get('nuccChunkCoord', bone, chunk_found[0] if chunk_found else xf) if kind == 'nuccChunkCoord' else None
                clump['rest'].append(list(struct.unpack_from('>9f', coord[0].body(coord[1])))
                                     if coord and coord[1]['size'] >= 36 else False)
            clump['drawn'] = []
            near = chunk_found[0] if chunk_found else xf
            # The clump's nuccChunkDynamics (spring bones the game simulates, nuccDynamics.cpp,
            # journal R127): its chains, each four coefficients (node +8C, +90, +94, +98 in
            # the order the chunk has them: not confirmed), the first coordinate and the count
            dynamics = self.library.get('nuccChunkDynamics', clump['chunk'], near) if chunk_found else None
            if dynamics:
                body = dynamics[0].body(dynamics[1])
                chains, at = [], 8
                try:
                    for _ in range(struct.unpack_from('>H', body, 0)[0]):
                        coefficients = list(struct.unpack_from('>4f', body, at))
                        first, count = struct.unpack_from('>HH', body, at + 16)
                        chains.append({'coefficients': coefficients, 'first': first, 'count': count,
                                       'flags': list(struct.unpack_from(f'>{count}H', body, at + 20))})
                        at += 20 + 2 * count
                    clump['dynamics'] = chains
                except struct.error:
                    self.unsupported(f'animation {name}', f'dynamics of {clump["chunk"]}: {len(body)} bytes not understood')
            # Clumps left out on request (--without: the caster's own body in a cinematic
            # animation): their coordinates stay, animated, their models are not imported
            left_out = any(str(clump.get(key, '')).startswith(prefix) for key in ('name', 'chunk') for prefix in self.without)
            clump['leftOut'] = left_out
            for kind, model in ([] if left_out else clump['modelChunks']):
                if kind == 'nuccChunkBillboard':
                    # A nuccBillboard member: a model (it hangs on the coordinate its
                    # header indexes, like any member) whose material fields, opacity,
                    # position offset and size are keyed over the billboard's own clock;
                    # the clump advances that clock by the animation's delta and copies
                    # the keys afterwards (0x14128c890: 0x1412c7f90, then 0x1412c7b00).
                    found = self.library.get(kind, model, near)
                    try:
                        board, (model_kind, _, model_name) = self.billboard(*found) if found else (None, (None, None, None))
                    except (ValueError, struct.error) as error:
                        self.unsupported(f'animation {name}', f'clump member billboard {model}: {error}')
                        continue
                    if not found:
                        self.unsupported(f'animation {name}', f'clump member billboard {model}: '
                                                              f'{self.library.why_missing(kind, model)}')
                    elif model_kind != 'nuccChunkModel':
                        self.unsupported(f'animation {name}', f'clump member billboard {model} draws a {model_kind}')
                    elif self.model(model_name, found[0]):
                        clump['drawn'].append(model_name)
                        clump.setdefault('billboards', {})[model_name] = board
                elif kind != 'nuccChunkModel':
                    self.unsupported(f'animation {name}', f'clump member {model} is a {kind}')
                elif self.model(model, near):
                    clump['drawn'].append(model)
        # A clump left out that no other clump hangs on: its curves are not evaluated either
        # (parent links: parent clump, parent coordinate, child clump, child coordinate)
        for index, clump in enumerate(decoded['clumps']):
            if clump.pop('leftOut') and not any(link[0] == index and link[2] != index for link in decoded['parents']):
                decoded['entries'] = [entry for entry in decoded['entries'] if entry.get('clump_index') != index]
                decoded['parents'] = [link for link in decoded['parents'] if link[2] != index]
        self.out['animations'][name] = decoded
        trail = self.library.get('nuccChunkTrail', name, xf)
        if trail:
            self.trails(name, *trail)
        return True

    def trails(self, animation: str, xf: Xfbin, chunk: dict) -> None:
        """nuccChunkTrail of an effect animation (loader 0x14132b4e0, factory 0x14127aa20;
        journal R90, trail_reverse_notes.md): one record per trail in table 0, its billboard
        in table 1, its two edge coordinates in table 2 (the first two of its index), its
        emission keys in table 4 (in table-0 order)."""
        body, version = xf.body(chunk), xf.version(chunk)
        groups = [struct.unpack_from('>IHH', body, 8 * i) for i in range(5)]
        ends = [g[0] for g in groups[1:]] + [len(body)]
        size = [(end - offset) // count if count else 0 for (offset, count, _), end in zip(groups, ends)]
        if groups[0][1] and size[0] != 0x60 or groups[1][1] and size[1] != 0x20 \
                or groups[2][1] and size[2] != (0x30 if version > 0x78 else 0x20):
            self.unsupported(f'trail {animation}', f'record sizes {size} (version {version:#x})')
            return

        def ref(word: int):
            return None if word == 0xffffffff else xf.ref(chunk, word)

        # Table 4: one record per trail, 0x14 bytes then its keys (a count at +0x10), padded to
        # 8 bytes: the records of one chunk differ in size when their key counts do
        key_records, cursor = [], groups[4][0]
        for _ in range(groups[4][1]):
            if cursor + 0x14 > len(body):
                break
            count = struct.unpack_from('>I', body, cursor + 0x10)[0]
            if cursor + 0x14 + 4 * count > len(body):
                break
            key_records.append((cursor, count))
            cursor += (0x14 + 4 * count + 7) // 8 * 8
        if len(key_records) != groups[4][1] or cursor != len(body):
            self.unsupported(f'trail {animation}', f'key table not understood ({len(key_records)} of {groups[4][1]} records, '
                                                   f'{len(body) - cursor} bytes left)')
            return

        defs = []
        for r in range(groups[0][1]):
            at = groups[0][0] + 0x60 * r
            target = ref(struct.unpack_from('>I', body, at)[0])
            index, max_samples, max_sub = struct.unpack_from('>I', body, at + 4)[0], *struct.unpack_from('>II', body, at + 0x14)
            flags, alpha_fade, width_fade = body[at + 0x1d], body[at + 0x1e], body[at + 0x1f]
            profile = list(struct.unpack_from('>HHH', body, at + 0x54))
            profile_split = body[at + 0x5a]
            # Loader defaults: no fade flag -> both, at speed 0; no profile flag -> 255 x 3.
            if not flags & 3:
                flags, alpha_fade, width_fade = flags | 3, 0, 0
            if not flags & 0x10:
                flags, profile, profile_split = flags | 0x10, [255, 255, 255], 0
            definition = {
                'index': index, 'animation': target[2] if target else None,
                'maxSamples': max_samples, 'maxSubdivisions': max_sub, 'flags': flags,
                'alphaFade': alpha_fade, 'widthFade': width_fade,
                'colors': [list(struct.unpack_from('>4f', body, at + 0x20 + 16 * k)) for k in range(3)],
                'colorSplit': struct.unpack_from('>f', body, at + 0x50)[0],
                'profile': profile, 'profileSplit': profile_split}
            for b in range(groups[1][1]):
                record = groups[1][0] + 0x20 * b
                if struct.unpack_from('>I', body, record + 4)[0] == index:
                    kind, _, board = ref(struct.unpack_from('>I', body, record)[0])
                    definition['billboard'] = board
                    self.resource(kind, board, xf)
                    break
            edges = []
            for e in range(groups[2][1]):
                record = groups[2][0] + size[2] * e
                if struct.unpack_from('>I', body, record + 4)[0] == index and len(edges) < 2:
                    coord = ref(struct.unpack_from('>I', body, record)[0])
                    parent = ref(struct.unpack_from('>I', body, record + 0x28)[0]) if version > 0x78 else None
                    edges.append({'coord': coord[2], 'parent': parent[2] if parent else None})
            definition['edges'] = edges
            if r < len(key_records):
                record, count = key_records[r]
                definition['keys'] = list(struct.unpack_from(f'>{count}I', body, record + 0x14))
            # Force fields (table 3) of this trail, in table order (0x141324fd0 appends). The
            # field record is the file record from +0x10 (version > 0x78): direction, decay,
            # kind, radius, strength, flags (bits 0-2 clear -> 1), then the parent reference.
            # Up to 0x78 the loader reads 0x30 bytes and takes the field record from +0x18:
            # its strength and flags come from memory the loader never wrote.
            fields = []
            for t3 in range(groups[3][1] if size[3] == (0x40 if version > 0x78 else 0x30) else 0):
                record = groups[3][0] + size[3] * t3
                if struct.unpack_from('>I', body, record + 4)[0] != index:
                    continue
                if version <= 0x78:
                    self.unsupported(f'trail {animation}', f'trail {index}: force field of a version {version:#x} chunk '
                                                           f'(its strength and flags are undefined in the game)')
                    continue
                coord = ref(struct.unpack_from('>I', body, record)[0])
                parent = ref(struct.unpack_from('>I', body, record + 0x30)[0])
                direction = list(struct.unpack_from('>3f', body, record + 0x10))
                decay, kind, radius, strength, flags = struct.unpack_from('>fiffi', body, record + 0x1c)
                fields.append({'coord': coord[2] if coord else None, 'parent': parent[2] if parent else None,
                               'direction': direction, 'decay': decay, 'kind': kind, 'radius': radius,
                               'strength': strength, 'flags': flags if flags & 7 else flags | 1})
            if fields:
                definition['fields'] = fields
            # With fewer than two edge records the factory 0x14127aa20 destroys the trail: the
            # game has none. An edge whose coordinate the animation lacks gives a trail that
            # never samples (0x141325090 returns at once): kept, it stays empty.
            # Without a billboard its texture id stays 0 and 0x141325a50 issues no draw.
            if len(edges) < 2 or 'billboard' not in definition:
                continue
            defs.append(definition)
        if groups[3][1] and size[3] != (0x40 if version > 0x78 else 0x30):
            self.unsupported(f'trail {animation}', f'force field records of {size[3]} bytes (version {version:#x})')
        if defs:
            self.out.setdefault('trails', {})[animation] = defs

    def ribbon(self, animation: str, definition: dict) -> None:
        """Draw description of a trail ribbon (journal R91). The command DrawTrail
        (0x141389eb0 / 0x141389f40) sends the vertices of 0x141325a50 through the
        interleaved primitive renderer 0x141248b70 with the descriptor at trail +2D0
        (initialised by 0x141327240): strip, vertex format 0, shader key 0x1F007, no NUD
        material. The per-draw context (0x1413368f0, then +3B0 rewritten by 0x141389f40)
        gives that program g_commonParam = (FLT_MIN, 1, 1, billboard alpha), g_uvOffset0 =
        (0, 0, 1, 1) (the vertices carry the billboard's UVs) and g_multColor = the colour
        of the render context (+80 of the thread's context, not traced: host value). The
        texture is the first texture of the last material of the billboard's model
        (0x14138a020 -> trail +190); its sampler is the descriptor's (+2E4 = 0, +2EC = -8):
        wrap on the three axes, trilinear, MipLODBias -8, LOD 0 to 16 (0x141237410,
        0x141425e50). The blend, depth and cull flags come from the words +80/+82/+86 of
        the model's first nuccChunkMaterial (0x1412c8070), which neither its loader nor its
        constructor writes, or are 0x121 without a material. The capture of 4efb_amt1_blt00
        shows 0x121's state, not the billboard model's NUD state (that one writes depth):
        the port uses 0x121 for every trail (journal R98)."""
        resource = self.out['resources'].get(definition['billboard'], {})
        model = self.out['models'].get(resource.get('model')) if resource.get('kind') == 'billboard' else None
        if not model or not model['materials'] or not model['materials'][-1]['textures']:
            self.unsupported(f'trail {animation}', f'trail {definition["index"]}: billboard {definition["billboard"]} has no textured model')
            return
        texture = model['materials'][-1]['textures'][0]
        record = self.out['textures'].get(texture)
        if not record:
            self.unsupported(f'trail {animation}', f'trail {definition["index"]}: texture {texture} unavailable')
            return
        bias = TRAIL_LOD_BIAS
        mipped = record['levels'] > 1 and bias > LEVEL_ZERO_BIAS
        textures = [{'name': texture, 'vtf': self.texture_variant(texture, '', mipped, False), 'address': [0, 0],
                     'size': [record['width'], record['height']], 'mipped': mipped, 'point': False,
                     'lod': [bias, record['levels'] - 1 if mipped else 0, 0]}]
        values = {('g_commonParam', 0): TRAIL_THRESHOLD, ('g_commonParam', 1): 1.0, ('g_commonParam', 2): 1.0,
                  ('g_uvOffset0', 0): 0.0, ('g_uvOffset0', 1): 0.0, ('g_uvOffset0', 2): 1.0, ('g_uvOffset0', 3): 1.0,
                  ('g_uvOffset1', 0): 0.0, ('g_uvOffset1', 1): 0.0, ('g_uvOffset1', 2): 1.0, ('g_uvOffset1', 3): 1.0,
                  ('g_highLightParam', 0): 1.0}
        values[(address_name(0), 0)], values[(address_name(0), 1)] = textures[0]['address']
        for comp, value in enumerate(textures[0]['lod']):
            values[(lod_name(0), comp)] = value
        values[(size_name(0), 0)], values[(size_name(0), 1)] = textures[0]['size']

        def classify(name: str, row: int, comp: int):
            if row == 0 and (name == 'g_multColor' or (name, comp) == ('g_commonParam', 3)):
                return 'draw', None
            if name in STAGE_CONSTANTS:
                return 'stage', None
            if name in OBJECT_CONSTANTS:
                return ('object', None) if row == 0 and comp < 3 else ('constant', 0.0)
            if name[:-1] in UNUSED_POINT_LIGHT and name[-1] in '0123' and row == 0:
                return 'constant', UNUSED_POINT_LIGHT[name[:-1]][comp]
            value = values.get((name, comp), 0.0) if row == 0 else 0.0
            return 'constant', value
        mesh = {'textures': textures,
                'state': dict(model['meshes'][0]['state'], **TRAIL_STATE, flags=TRAIL_SHADER_KEY, properties=[])}
        try:
            port = translate_shader(self.shader_library, TRAIL_SHADER_KEY, classify, unbound=range(1, 16))
            self.bind(mesh, port.layout)
            build_shader(port, self.addon)
        except Unsupported as error:
            self.unsupported(f'trail {animation}', f'trail {definition["index"]}: shader {TRAIL_SHADER_KEY:#x}: {error}')
            return
        mesh['shader'] = dict(port.layout, frozen=[], unlit=False)
        definition['draw'] = {'model': resource['model'], 'mesh': mesh}
        self.unsupported(f'trail {animation}', f'trail {definition["index"]}: render state 0x121 and white render '
                                               f'context colour, as captured for 4efb_amt1_blt00; the material words '
                                               f'+80/+82/+86 that could change them have no writer found')

    def resource(self, kind: str, name: str, near: Xfbin) -> None:
        if name in self.out['resources']:
            return
        found = self.library.get(kind, name, near)
        if not found:
            self.out['resources'][name] = {'kind': 'missing', 'type': kind}
            self.unsupported(f'resource {name}', f'{kind}: {self.library.why_missing(kind, name)}')
            return
        xf, chunk = found
        entry = {'kind': 'unsupported', 'type': kind}
        try:
            if kind == 'nuccChunkBillboard':
                board, (model_kind, _, model_name) = self.billboard(xf, chunk)
                if model_kind != 'nuccChunkModel':
                    raise ValueError(f'billboard resource is a {model_kind}')
                if self.model(model_name, xf):
                    entry = {'kind': 'billboard', 'type': kind, 'billboard': board, 'model': model_name}
            elif kind == 'nuccChunkClump':
                clump = self.clump(xf, chunk)
                models, billboards = [], {}
                for member_kind, member in clump['members']:
                    if member_kind == 'nuccChunkModel':
                        models.append(member)
                    elif member_kind == 'nuccChunkBillboard':
                        # A billboard member of an emitter's clump: nothing advances its
                        # clock (0x1412c7f90 has one caller, 0x14128c890, which runs for the
                        # clumps of an animation object), so it keeps the keys of frame 0
                        # that its initialisation copies (0x1412c8110). Journal R102.
                        found_board = self.library.get(member_kind, member, xf)
                        if not found_board:
                            raise ValueError(f'clump member billboard {member}: {self.library.why_missing(member_kind, member)}')
                        board, (model_kind, _, model_name) = self.billboard(*found_board)
                        if model_kind != 'nuccChunkModel':
                            raise ValueError(f'clump member billboard {member} draws a {model_kind}')
                        models.append(model_name)
                        billboards[model_name] = board
                    else:
                        raise ValueError(f'clump members {clump["members"]}')
                if all(self.model(m, xf) for m in models):
                    entry = {'kind': 'clump', 'type': kind, 'models': models, 'coords': clump['coords'], 'parents': clump['parents']}
                    if billboards:
                        entry['billboards'] = billboards
            elif kind == 'nuccChunkAnm':
                if self.animation(xf, chunk):
                    entry = {'kind': 'anm', 'type': kind, 'animation': name}
                    # An animated resource can carry a particle chunk of its own (2efb_kyj_ptc07:
                    # the tags that hang on the cocoon): emitters attached to the coordinates of
                    # the resource's animation, played by every particle of the resource
                    if self.library.get('nuccChunkParticle', name, xf):
                        self.out['resources'][name] = entry
                        self.effect(name, xf)
                        if self.out['effects'].get(name):
                            entry['nested'] = True
            else:
                self.unsupported(f'resource {name}', f'no importer for {kind}')
        except (ValueError, struct.error) as error:
            self.unsupported(f'resource {name}', str(error))
        self.out['resources'][name] = entry

    # -- particle chunks ----------------------------------------------------
    @staticmethod
    def sprite_meshes(trailer: bytes, resource_count: int) -> list | None:
        """Data that follows the five sections in version 0x7B chunks (loader
        0x141320290 reads it when an emitter's byte +1E is non-zero): a u64 size,
        then per resource record a list of meshes, one per billboard frame. A mesh
        is vertices {position 3f, uv 2f, second uv 2f (FLT_MAX when unused), colour
        4f}, strip indices (u16) and an index: -1 own geometry, else the mesh it
        shares. Positions are the frame's uv in a 100-unit quad:
        ((u - 0.5) * 100, (0.5 - v) * 100)."""
        if not trailer:
            return None
        size = struct.unpack_from('>Q', trailer)[0]
        if size != len(trailer) - 8:
            raise ValueError(f'trailer of {len(trailer)} bytes announces {size}')
        pos = 8
        if struct.unpack_from('>I', trailer, pos)[0] != resource_count:
            raise ValueError('trailer does not list one entry per resource record')
        pos += 4
        out = []
        for _ in range(resource_count):
            frames = struct.unpack_from('>I', trailer, pos)[0]
            pos += 4
            meshes = []
            for _ in range(frames):
                vertex_count = struct.unpack_from('>I', trailer, pos)[0]
                vertices = [list(struct.unpack_from('>11f', trailer, pos + 4 + n * 44)) for n in range(vertex_count)]
                pos += 4 + vertex_count * 44
                index_count = struct.unpack_from('>I', trailer, pos)[0]
                indices = list(struct.unpack_from(f'>{index_count}H', trailer, pos + 4))
                pos += 4 + index_count * 2
                share = struct.unpack_from('>i', trailer, pos)[0]
                pos += 4
                meshes.append({'share': share} if share >= 0 and not vertex_count else
                              {'vertices': vertices, 'indices': indices})
            out.append(meshes)
        if pos != len(trailer):
            raise ValueError(f'{len(trailer) - pos} trailer bytes left')
        return out

    def effect(self, name: str, near: Xfbin) -> None:
        if name in self.out['effects']:
            return
        anm = self.library.get('nuccChunkAnm', name, near) or self.library.named('nuccChunkAnm', name)
        if not anm:
            self.unsupported(f'effect {name}', 'animation chunk not found in the files of the script nor, under one path, in the chunk index')
            return
        self.animation(*anm)
        particle = self.library.get('nuccChunkParticle', name, anm[0])
        if not particle:
            self.out['effects'][name] = []
            return
        xf, chunk = particle
        body = xf.body(chunk)
        if struct.unpack_from('>I', body)[0] != 0x28:
            self.unsupported(f'effect {name}', 'unexpected particle header')
            return
        sections, cursor = [], 0x28
        for n in range(5):
            count, length = struct.unpack_from('>HH', body, 4 + n * 8)
            sections.append((count, cursor, body[cursor:cursor + length]))
            cursor += length
        if cursor > len(body) or len(sections[0][2]) != sections[0][0] * 0xd0:
            self.unsupported(f'effect {name}', 'particle section sizes do not add up')
            return
        try:
            sprite_meshes = self.sprite_meshes(body[cursor:], sections[1][0])
        except (ValueError, struct.error) as error:
            self.unsupported(f'effect {name}', f'data after the particle sections not understood: {error}')
            return
        emitters = {}
        for n in range(sections[0][0]):
            raw = sections[0][2][n * 0xd0:(n + 1) * 0xd0]
            f = lambda off, raw=raw: struct.unpack_from('>f', raw, off)[0]
            v = lambda off, count, raw=raw: list(struct.unpack_from(f'>{count}f', raw, off))
            flags = struct.unpack_from('>H', raw, 0x16)[0]
            emitter_id = struct.unpack_from('>I', raw, 4)[0]
            emitters[emitter_id] = {
                'id': emitter_id, 'resources': [], 'attachments': [], 'forces': [],
                'direct': raw[0x10] == 1, 'shape': raw[0x11], 'direction': raw[0x12], 'orientation': raw[0x13],
                'rotation': raw[0x14], 'simulationHz': raw[0x15] & 0x3f,
                'independentSizeRandom': bool(flags & 1), 'motionSegment': bool(flags & 0x10),
                'forceMask': struct.unpack_from('>I', raw, 0x18)[0],
                'durationCounter': struct.unpack_from('>h', raw, 0x1c)[0], 'quantity': f(0x20),
                'radius': f(0x24), 'radiusRandom': f(0x28), 'life': struct.unpack_from('>h', raw, 0x2c)[0],
                'lifeRandom': f(0x30), 'speed': f(0x34), 'speedRandom': f(0x38),
                'angles': v(0x3c, 2), 'angleRanges': v(0x44, 2), 'fadeIn': f(0x4c), 'fadeOut': f(0x50),
                'scalarBase': f(0x54), 'scalarRandom': f(0x58),
                'sizeStart': v(0x5c, 3), 'sizeRandom': v(0x68, 3), 'sizeMiddle': v(0x74, 3), 'sizeEnd': v(0x80, 3),
                'sizeSplit': f(0x8c), 'colorStart': v(0x90, 4), 'colorMiddle': v(0xa0, 4), 'colorEnd': v(0xb0, 4),
                'colorSplit': f(0xc0), 'events': [], 'raw_hex': raw.hex()}
            if raw[0x1e]:
                emitters[emitter_id]['spriteTrim'] = raw[0x1e]
        ordered = [emitters[k] for k in sorted(emitters)]
        if [e['id'] for e in ordered] != list(range(1, len(ordered) + 1)):
            self.unsupported(f'effect {name}', 'emitter ids are not 1..n')
            return
        # Section 1: what each emitter spawns.
        count, offset, raw = sections[1]
        for n in range(count):
            local, emitter_id = struct.unpack_from('>2I', raw, n * 32)
            kind, _, resource_name = xf.ref(chunk, local)
            emitters[emitter_id]['resources'].append(resource_name)
            self.resource(kind, resource_name, xf)
            if sprite_meshes and sprite_meshes[n]:
                # Trimmed sprite outlines the game draws instead of the full billboard quad
                # (chunk version 0x7B, emitter byte +1E non-zero), one per billboard frame.
                # The engine draws the full quad, which covers the same texels plus the
                # trimmed margin; the package only records that the outlines exist.
                own = [m for m in sprite_meshes[n] if 'vertices' in m]
                emitters[emitter_id].setdefault('spriteMeshes', {})[resource_name] = {
                    'frames': len(sprite_meshes[n]), 'outlines': len(own), 'vertices': sum(len(m['vertices']) for m in own)}
        # Section 2: attachments (coordinate of a clump), section 3: force fields. Up to
        # chunk version 0x77 both records lack their last words - the clump reference
        # and one more: the reader 0x141320290 takes 0x30 / 0x60 bytes instead of
        # 0x38 / 0x70 and sets the clump reference to "none".
        old = xf.version(chunk) <= 0x77
        attachment_size, force_size = (48, 96) if old else (56, 112)
        spatial = {'attachments': [], 'forces': []}
        count, offset, raw = sections[2]
        if len(raw) != count * attachment_size:
            self.unsupported(f'effect {name}', f'attachment stride (chunk version {xf.version(chunk):#x}, '
                                               f'{len(raw)} bytes for {count} records)')
            return
        for n in range(count):
            record = raw[n * attachment_size:(n + 1) * attachment_size]
            words = struct.unpack_from('>12I', record) + ((0xffffffff, 0) if old else struct.unpack_from('>2I', record, 48))
            # The clump reference is 0xFFFFFFFF when the coordinate is named without its clump
            # (5efb_9ind1_x: the root node 1efc_dmy00 of an attachment helper).
            coord = xf.ref(chunk, words[0])
            clump = xf.ref(chunk, words[12]) if words[12] != 0xffffffff else (None, None, None)
            emitters[words[1]]['attachments'].append({'coord': coord[2], 'clump': clump[2]})
            spatial['attachments'].append({'emitter': words[1], 'coord': coord[2], 'clump': clump[2], 'raw_hex': record.hex(),
                                           'direction': list(struct.unpack_from('>3f', record, 0x10)),
                                           'world_direction': bool(struct.unpack_from('>I', record, 0x20)[0]),
                                           'original_connection_field': struct.unpack_from('>I', record, 0x1c)[0]})
        count, offset, raw = sections[3]
        if len(raw) != count * force_size:
            self.unsupported(f'effect {name}', f'force-field stride (chunk version {xf.version(chunk):#x}, '
                                               f'{len(raw)} bytes for {count} records)')
            return
        for n in range(count):
            record = raw[n * force_size:(n + 1) * force_size]
            local, emitter_id = struct.unpack_from('>2I', record)
            kind, _, coord_name = xf.ref(chunk, local)
            emitters[emitter_id]['forces'].append({'type': kind, 'name': coord_name})
            spatial['forces'].append({'emitter': emitter_id, 'coord': coord_name, 'raw_hex': record.hex(),
                                      'direction': list(struct.unpack_from('>3f', record, 0x10)),
                                      'selector': record[0x30], 'world_direction': bool(record[0x31]),
                                      'limit_radius': bool(record[0x32]), 'radius_base': struct.unpack_from('>f', record, 0x38)[0],
                                      'falloff_mode': struct.unpack_from('>I', record, 0x3c)[0],
                                      'strength': struct.unpack_from('>f', record, 0x40)[0],
                                      'strength_multiplier': struct.unpack_from('>f', record, 0x44)[0],
                                      'vector_parameter': list(struct.unpack_from('>3f', record, 0x50))})
        # Section 4: per-emitter event words.
        count, offset, raw = sections[4]
        cursor = 0
        for index in range(count):
            events = struct.unpack_from('>I', raw, cursor)[0]
            size = (4 + events * 4 + 7) & ~7
            for n in range(events):
                word = struct.unpack_from('>I', raw, cursor + 4 + n * 4)[0]
                emitters[index + 1]['events'].append({
                    'raw': f'0x{word:08x}', 'clock_threshold_ms': word & 0x0fffffff,
                    'action': 'start_emission' if word & 0x80000000 else
                              'stop_emission_and_notify_particles' if word & 0x40000000 else 'stop_emission',
                    'start_flag': bool(word & 0x80000000), 'stop_flag': bool(word & 0x40000000),
                    'other_flags': f'0x{word & 0x30000000:08x}'})
            cursor += size
        if cursor != len(raw):
            self.unsupported(f'effect {name}', 'unconsumed event bytes')
            return
        self.out['effects'][name] = ordered
        self.out['spatialRecords'][name] = spatial

    # -- skill file ---------------------------------------------------------
    def skill_file(self, packed_name: str, roots: list[str] | None = None) -> None:
        game = self.library.game
        scripts = skill_script.load(game.fetch(packed_name))
        own_scripts = scripts
        if roots is not None:
            missing = [name for name in roots if name not in scripts]
            if missing:
                raise SystemExit(f'scripts not in {packed_name}: {missing}')
            scripts = {name: scripts[name] for name in roots}
        self.out['source'] = packed_name
        # Scripts an event spawns that live in another skill file (shared hit and
        # common scripts): pulled in, with whatever they spawn in turn.
        index, loaded, self.out['borrowed'] = None, {packed_name: own_scripts}, {}
        pending = [e['name'] for s in scripts.values() for a in s['actions'] for ev in a['events'] for e in ev['effects']]
        while pending:
            wanted = pending.pop()
            if wanted in scripts:
                continue
            if wanted in own_scripts:
                scripts[wanted] = own_scripts[wanted]
                pending += [e['name'] for a in scripts[wanted]['actions'] for ev in a['events'] for e in ev['effects']]
                continue
            index = index if index is not None else skill_script.script_index(game)
            sources = sorted(index.get(wanted, []))
            for source in sources:
                if source not in loaded:
                    loaded[source] = skill_script.load(game.fetch(source))
            # Several skill files can carry the same shared script (weapon hits, guards):
            # which one the game holds depends on the files loaded, so it is taken only
            # when every copy is the same.
            if not sources or any(loaded[s][wanted] != loaded[sources[0]][wanted] for s in sources[1:]):
                self.unsupported(f'script {wanted}', 'spawned by an event; ' + ('no skill file defines it' if not sources else
                                                                             f'{len(sources)} skill files define it differently'))
                scripts[wanted] = None
                continue
            scripts[wanted] = loaded[sources[0]][wanted]
            self.out['borrowed'][wanted] = sources[0] if len(sources) == 1 else sources
            pending += [e['name'] for a in scripts[wanted]['actions'] for ev in a['events'] for e in ev['effects']]
        scripts = {k: v for k, v in scripts.items() if v is not None}
        for skill_id, script in scripts.items():
            self.out['skills'][skill_id] = script
        # Every file any script of the skill names is loaded; references cross between them.
        for script in scripts.values():
            for file_name in script['files']:
                if self.library.add(file_name) is None:
                    self.unsupported(f'file {file_name}', 'not in the game archives')
        for skill_id, script in scripts.items():
            own = [f for f in (self.library.add(n) for n in script['files']) if f]
            for action in script['actions']:
                for parameter in action['parameters'].get('Animation', []):
                    chunk = parameter.get('chunk')
                    if chunk:
                        self.effect(chunk, own[0] if own else None)

    # -- shaders --------------------------------------------------------------
    def shaders(self) -> None:
        """One translated shader pair per mesh (shader_port.py), with the material's
        own constants compiled in. Runs once everything is imported: a material an
        animation drives gets its animated fields as per-draw constants."""
        if Importer.shader_library is None:
            Importer.shader_library = ShaderLibrary()
        # What the animations of the package do to each material they drive:
        # field -> the one value every animation holds it at, or None when it moves.
        animated: dict[str, dict[int, float | None]] = {}
        for animation in self.out['animations'].values():
            for entry in (animation['entries'] if animation else []):
                if entry['type'] == 4:
                    held = animated.setdefault(entry.get('chunk', entry['target']), {})
                    for offset, value in self.animated_fields(entry).items():
                        held[offset] = value if held.get(offset, value) == value else None
        for name, model in self.out['models'].items():
            if not model:
                continue
            for index, mesh in enumerate(model['meshes']):
                if 'shader' in mesh:
                    continue
                material = model['materials'][mesh['material']]
                mesh['shader'] = None
                frozen: list[str] = []
                lights = True
                # Small meshes (particles: billboards, clump members) are drawn many at once
                batched = (len(mesh['triangles']) <= BATCH_TRIANGLES and not mesh.get('skin')
                           and (name, index + 1) not in self.rigid_parts())
                while True:
                    try:
                        # A NUD material can have more texture records than its nuccChunkMaterial
                        # has textures (5efb_9ind1_bd_amt04: a film slot whose weight is zero).
                        port = translate_shader(self.shader_library, mesh['state']['flags'],
                                                self.classifier(mesh, material, animated.get(material['name']), frozen, lights, batched),
                                                unbound=range(len(mesh['textures']), 16))
                        if batched and not batchable(port.layout):
                            raise Unsupported('batched: the shader needs the model matrix or the normals')
                        self.bind(mesh, port.layout)
                        build_shader(port, self.addon)
                        reads_light = any(c['name'].startswith('g_pointLight') for c in port.layout['dynamic'] + port.layout['static']
                                          + port.layout['compiled'])
                        mesh['shader'] = dict(port.layout, frozen=list(frozen), unlit=reads_light and not lights, batched=batched)
                    except Unsupported as error:
                        # A batched shader over the budget is made again unbatched
                        if batched:
                            batched = False
                            continue
                        # Over the constant budget: give up the point light first (its slot is
                        # compiled as unused), then compile one more stage value in, and retry.
                        if 'pixel constant floats' in str(error) and lights:
                            lights = False
                            continue
                        if 'stage constants' in str(error) and len(frozen) < len(STAGE_FREEZE_ORDER):
                            frozen.append(STAGE_FREEZE_ORDER[len(frozen)])
                            continue
                        mesh['shaderProblem'] = str(error)
                        self.unsupported(f'model {name}', f'mesh {index} (shader key {mesh["state"]["flags"]:#x}): {error}')
                    break
                if mesh['shader'] and not batched:
                    self.studio_shader(name, model, index, mesh, material, animated.get(material['name']), frozen, lights)
        for animation, definitions in self.out.get('trails', {}).items():
            for definition in definitions:
                if 'draw' not in definition:
                    self.ribbon(animation, definition)

    def studio_shader(self, name: str, model: dict, index: int, mesh: dict, material: dict, animated, frozen, lights) -> None:
        """The shader variant of a mesh drawn as a Source studio model (export_studio.py left
        a description: addon/studio/<model>.json): the stage values compiled in (the
        engine's at the default scale), the vertex colour compiled in, the second UV set read
        from the first. The model records its .mdl, sequence and duration."""
        path = self.addon / 'studio' / f'{name}.json'
        rigid = self.rigid_parts().get((name, index + 1))
        if path.is_file():
            description = json.loads(path.read_text(encoding='utf-8'))
            kept = description['meshes'].get(str(index + 1))
            stage = description['stage']
        elif rigid:
            description, kept = None, rigid[1]
            stage = rigid[0]['stage'][name]
        else:
            return
        if kept is None:
            return
        plain = Importer.classifier_plain(mesh, material, animated, frozen, lights)

        def classify(constant: str, row: int, comp: int):
            # Object-space lighting also needs its world-space source, which
            # studio vertices cannot carry in an extra texture coordinate.
            if constant == 'g_lightDirectionWorld':
                values = stage.get(constant)
                if values is None:
                    raise Unsupported(f'studio variant: no stage value {constant}')
                return 'constant', values[row * 4 + comp]
            kind, value = plain(constant, row, comp)
            if kind != 'stage':
                return kind, value
            values = stage.get(constant)
            if values is None:
                raise Unsupported(f'studio variant: no stage value {constant}')
            at = row * 4 + comp
            return 'constant', values[at] if at < len(values) else 0.0
        # Two variants: Source skins the vertices before the shader ($softwareskin), or the
        # vertex shader skins them from the bone matrices Source loads (hardware skinning)
        layouts = {}
        for key, skinning in (('studioShader', False), ('studioGpuShader', True)):
            try:
                port = translate_shader(self.shader_library, mesh['state']['flags'], classify, unbound=range(len(mesh['textures']), 16),
                                        studio={'color': kept['color'], 'skinning': skinning, 'rigid': bool(rigid)})
                build_shader(port, self.addon)
            except Unsupported as error:
                self.unsupported(f'model {name}', f'mesh {index} studio variant: {error}')
                return
            if [d['name'] for d in port.layout['dynamic']] != [d['name'] for d in mesh['shader']['dynamic']]:
                self.unsupported(f'model {name}', f'mesh {index} studio variant: its per-draw constants differ')
                return
            layouts[key] = dict(port.layout, frozen=list(frozen), unlit=mesh['shader']['unlit'], batched=False)
        mesh.update(layouts)
        if description is not None:
            model['studio'] = {'mdl': description['mdl'], 'animation': description['animation'], 'duration': description['duration']}
        # The model's own material (the SMD names it, $cdmaterials storm_fx/studio/): Source
        # builds the model's vertex buffers for the material it loads with the model, so the
        # shader has to be there, not set from Lua afterwards (an in-game test drew nothing).
        # Source hands screenspace_general the bones (hardware skinning): the variant whose
        # vertex shader skins (found in game with skin_variants.py: shader_port.py).
        material_path = f'storm_fx/studio/{name}_mesh{index + 1}'
        self.write_studio_vmt(material_path, layouts['studioGpuShader'], mesh, material)
        mesh['studioMaterial'] = material_path

    def rigid_parts(self) -> dict:
        """(model, 1-based mesh index) -> (description, part) of the animated resources
        export_studio_anm.py made studio models of (addon/studio/<animation>.json, kind rigid)."""
        if getattr(self, '_rigid_parts', None) is None:
            self._rigid_parts, self._rigid_descriptions = {}, {}
            for path in sorted((self.addon / 'studio').glob('*.json')):
                description = json.loads(path.read_text(encoding='utf-8'))
                if description.get('kind') != 'rigid':
                    continue
                # Several animations can draw one mesh: every description is kept by its animation
                self._rigid_descriptions[description['animation']] = description
                for part in description['parts']:
                    self._rigid_parts[(part['model'], part['mesh'])] = (description, part)
        return self._rigid_parts

    def studio_resources(self) -> None:
        """An animated resource whose animation has a studio model with every part's shader
        variants made: its .mdl, sequence, duration, parts and per-frame values recorded on it
        (engine/cl_studio.lua draws its particles with it)."""
        self.rigid_parts()
        done = self._rigid_descriptions
        for name, resource in self.out['resources'].items():
            if not resource or resource.get('kind') != 'anm' or resource.get('animation') not in done:
                continue
            description = done[resource['animation']]
            parts = []
            for part in description['parts']:
                model = self.out['models'].get(part['model'])
                mesh = model and model['meshes'][part['mesh'] - 1]
                if not mesh or 'studioMaterial' not in mesh:
                    self.unsupported(f'resource {name}', f'studio model left out: {part["model"]} mesh {part["mesh"]} has no studio shader')
                    parts = None
                    break
                entry = {'draw': part['draw'], 'model': part['model'], 'mesh': part['mesh'], 'group': part.get('group', 1)}
                # A draw with materials of its own (draws of one model the animation gives
                # different values): the mesh's .vmt again under the name the .mdl uses
                default = f'{part["model"]}_mesh{part["mesh"]}'
                if part.get('material', default) != default:
                    entry['material'] = f'storm_fx/studio/{part["material"]}'
                    self.write_studio_vmt(entry['material'], mesh['studioGpuShader'], mesh, model['materials'][mesh['material']])
                parts.append(entry)
            if parts:
                # The values per frame, keys back to numbers (material index, field offset):
                # the engine reads them as the animation's own instances
                frames = [{'opacity': {i + 1: value for i, value in enumerate(frame['opacity']) if value is not None},
                           'instances': [{int(k): {int(o): v for o, v in fields.items()} for k, fields in draw.items()}
                                         for draw in frame['instances']]} for frame in description['frames']]
                resource['studio'] = {'mdl': description['mdl'], 'mdls': description.get('mdls', [description['mdl']]),
                                      'hung': bool(description.get('hung')),
                                      'animation': description['animation'], 'duration': description['duration'],
                                      'ticksPerFrame': description['ticksPerFrame'], 'parts': parts, 'frames': frames}

    @staticmethod
    def rest_constants(layout: dict, material: dict) -> dict[str, float]:
        """$c<register>_<x..w> of the per-draw constants at rest: the material's own instance,
        white, opaque, no screen scroll, the unused point light. The engine sets them before
        every draw; these only let the model show on its own (a model spawned from the menu)."""
        instance = material['instance']
        fields = {target: offset for offset, target in INSTANCE_CONSTANTS.items()}
        out = {}
        for entry in layout['dynamic']:
            name, row, comp = entry['name'], entry['row'], entry['component']
            value = 0.0
            if row == 0 and (name, comp) in fields:
                value = float(instance[fields[(name, comp)]])
            if name == 'g_multColor' or (name == 'g_commonParam' and comp == 1):
                value = 1.0
            if name[:-1] in UNUSED_POINT_LIGHT and name[-1] == '0':
                value = UNUSED_POINT_LIGHT[name[:-1]][comp]
            if name == 'g_olIdParam' and comp == 0:
                value = float(instance[0x84]) / 255
            out[f'$c{entry["register"]}_{"xyzw"[entry["slot"]]}'] = value
        return out

    def write_studio_vmt(self, path: str, layout: dict, mesh: dict, material: dict | None = None) -> None:
        """A screenspace_general .vmt with the parameters engine/cl_render.lua RENDER.Material
        gives a mesh, for a studio model's mesh (no vertex colour, no baked channel), and the
        per-draw constants at rest (rest_constants)."""
        textures = []
        for sampler in layout['samplers']:
            textures.append(sampler['system'] if sampler.get('system') else mesh['textures'][sampler['material']]['vtf'])
        params = {'$pixshader': layout['pixel'], '$vertexshader': layout['vertex'], '$basetexture': textures[0],
                  '$vertexcolor': '0', '$vertextransform': '1', '$copyalpha': '0', '$alpha_blend': '0', '$writealpha': '1',
                  '$depthtest': '1', '$writedepth': '0', '$cull': '1' if mesh['state'].get('cull_mode') == 1029 else '0',
                  '$linearread_basetexture': '1', '$linearwrite': '1', '$model': '1'}
        if layout['attributes']['normal']:
            params['$vertexnormal'] = '1'
        for i, texture in enumerate(textures[1:], start=1):
            params[f'$texture{i}'] = texture
            params[f'$linearread_texture{i}'] = '1'
        if material is not None:
            params.update({k: f'{v:.9g}' for k, v in self.rest_constants(layout, material).items()})
        lines = [f'"{layout.get("host", "screenspace_general")}"', '{'] + [f'    "{k}" "{v}"' for k, v in params.items()] + ['}']
        target = self.addon / 'materials' / f'{path}.vmt'
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text('\n'.join(lines) + '\n', encoding='ascii')

    @staticmethod
    def animated_fields(entry: dict) -> dict[int, float | None]:
        """Material instance field -> the constant a material animation entry holds
        it at, or None when the entry moves it. The evaluator 0x14139d440 rewrites
        the fields on every update: UV offsets and scales take their curve, or the
        value of the previous field when they have none; the four fields at +70
        take their curve or 0; the threshold is written only when it has a curve."""
        curves = {c['index']: c for c in entry['curves']}

        def held(index: int):
            curve = curves.get(index)
            if curve is None:
                return 'absent'
            rows = curve['values']
            if rows and (curve['format'] == 11 or (curve['format'] in (22, 24) and all(r == rows[0] for r in rows))):
                return float(np.float32(rows[0][0]))
            return None
        out: dict[int, float | None] = {}
        carry = None            # without a first curve the original reads an undefined value: treated as moving
        for index in list(range(12)) + [18, 19, 20, 21]:
            value = held(index)
            if value != 'absent':
                carry = value
            out[MATERIAL_CURVE_FIELDS[index]] = carry
        for index in (12, 13, 14, 15, 22):
            value = held(index)
            out[MATERIAL_CURVE_FIELDS[index]] = 0.0 if value == 'absent' else value
        threshold = held(16)
        if threshold != 'absent':
            out[0x80] = None if threshold is None else float(np.float32(threshold / 255))
        return out

    @staticmethod
    def classifier(mesh: dict, material: dict, animated: dict | None, frozen=(), lights=True, batched=False):
        """Where each constant of the mesh's shader comes from (shader_port.py classes).
        animated: what the animations do to the material (animated_fields merged),
        None when no animation drives it. frozen: stage values compiled in. lights:
        point light slot 0 is set per draw (else compiled as unused). batched: the
        per-draw values travel in the vertices too (TEXCOORD channels, like the stage
        values), so that the engine can draw many particles of the material at once."""
        plain = Importer.classifier_plain(mesh, material, animated, frozen, lights)
        if not batched:
            return plain

        def classify(name: str, row: int, comp: int):
            kind, value = plain(name, row, comp)
            return ('stage', None) if kind == 'draw' else (kind, value)
        return classify

    @staticmethod
    def classifier_plain(mesh: dict, material: dict, animated: dict | None, frozen=(), lights=True):
        """Importer.classifier without batching."""
        instance = material['instance']
        values: dict[tuple[str, int], float] = {}
        for offset, (constant, comp) in INSTANCE_CONSTANTS.items():
            values[(constant, comp)] = instance[offset]
        if material['format'] & 0x20:
            values[('g_uvOffset2', 0)] = instance[0x78]         # binder: the bit-5 float replaces uv2's x offset
        values[('g_olIdParam', 0)] = instance[0x84] / 255
        # NUD properties: NU_x is written to g_x after the binder, count * 4 bytes; a
        # constant nothing writes is uploaded as zero.
        for prop in mesh['state']['properties']:
            if prop['name'].startswith('NU_') and prop['values']:
                for comp in range(4):
                    values[('g_' + prop['name'][3:], comp)] = prop['values'][comp] if comp < len(prop['values']) else 0.0
        for slot, texture in enumerate(mesh['textures']):
            values[(address_name(slot), 0)], values[(address_name(slot), 1)] = texture['address']
            for comp, value in enumerate(texture['lod']):
                values[(lod_name(slot), comp)] = value
            values[(size_name(slot), 0)], values[(size_name(slot), 1)] = texture['size']
        # Field behind each constant component (g_uvOffset2.x is the bit-5 float +78 when the material has it).
        fields: dict[tuple[str, int], list[int]] = {}
        for offset, target in INSTANCE_CONSTANTS.items():
            fields.setdefault(target, []).append(offset)
        if material['format'] & 0x20:
            fields[('g_uvOffset2', 0)] = [0x78]

        def moves(name: str, comp: int) -> bool:
            """An animation gives this component a value the compiled shader would not have."""
            for offset in fields.get((name, comp), ()):
                if offset in animated:
                    held = animated[offset]
                    if held is None or float(np.float32(held)) != float(np.float32(instance[offset])):
                        return True
            return False

        def classify(name: str, row: int, comp: int):
            if row == 0 and ((name, comp) in DRAW_CONSTANTS or (animated is not None and moves(name, comp))):
                return 'draw', None
            if name in frozen:
                return 'constant', CAPTURED_STAGE[name][comp] if row == 0 else (1.0 if comp == 3 else 0.0)
            if name in STAGE_CONSTANTS:
                return 'stage', None
            if name in OBJECT_CONSTANTS:
                return ('object', None) if row == 0 and comp < 3 else ('constant', 0.0)
            if name[:-1] in UNUSED_POINT_LIGHT and name[-1] in '0123' and row == 0:
                if lights and name[-1] == '0':
                    return 'draw', None
                return 'constant', UNUSED_POINT_LIGHT[name[:-1]][comp]
            if name in FROZEN_STAGE and row == 0:
                fixed = FROZEN_STAGE[name][comp]
                return ('stage', None) if fixed is None else ('constant', fixed)
            value = values.get((name, comp)) if row == 0 else None
            if value is None and name not in CONTEXT_CONSTANTS:
                value = 0.0
            return ('constant', value) if value is not None else (None, None)
        return classify

    @staticmethod
    def bind(mesh: dict, layout: dict) -> None:
        """Check the mesh's material offers what the translated shader samples."""
        for sampler in layout['samplers']:
            index = sampler.get('material')
            if index is None:
                continue
            if index >= len(mesh['textures']):
                raise Unsupported(f'shader samples material texture {index}, the material has {len(mesh["textures"])}')

    # Sections of a package whose entries are found by name
    NAMED_SECTIONS = ('effects', 'spatialRecords', 'animations', 'resources', 'models', 'textures', 'trails')

    def keep_only(self, effects: list[str]) -> None:
        """Keep the given effect animations and whatever they reach (their emitters, resources,
        models, nested animations, textures, trails), found by name through every string the
        kept entries hold; drop the rest and the skill scripts. A name the data happens to hold
        keeps that entry too: at worst more than needed, never less."""
        missing = [e for e in effects if e not in self.out['animations']]
        if missing:
            raise SystemExit(f'not in {self.package}: {missing}')

        def strings(value):
            if isinstance(value, str):
                yield value
            elif isinstance(value, dict):
                for k, v in value.items():
                    yield from strings(k)
                    yield from strings(v)
            elif isinstance(value, (list, tuple)):
                for v in value:
                    yield from strings(v)

        reached, pending = set(effects), list(effects)
        while pending:
            name = pending.pop()
            for section in self.NAMED_SECTIONS:
                entry = self.out.get(section, {}).get(name)
                if entry is None:
                    continue
                for text in strings(entry):
                    if text not in reached:
                        reached.add(text)
                        pending.append(text)
        for section in self.NAMED_SECTIONS:
            if section in self.out:
                self.out[section] = {k: v for k, v in self.out[section].items() if k in reached}
        self.out['skills'] = {}
        self.out['kept'] = list(effects)

    def write(self) -> Path:
        self.shaders()
        self.studio_resources()
        out = dict(self.out)
        out['textures'] = {k: v for k, v in out['textures'].items() if v}
        out['models'] = {k: v for k, v in out['models'].items() if v}
        short_geometry(out['models'])
        out['animations'] = {k: v for k, v in out['animations'].items() if v}
        out['files'] = [xf.name for xf in self.library.files]
        out['externalFiles'] = list(self.library.external)
        packages = self.addon / 'lua/storm_fx/packages'
        packages.mkdir(parents=True, exist_ok=True)
        target = packages / f'{self.package}.lua'
        header = ('-- Generated by storm_import.py from the game files. Decoded values only;\n'
                  '-- do not tune these numbers by eye.\n')
        if out.get('edits'):
            header += '-- `edits` holds host edits asked at import (silenced emitters, start, end): not game data.\n'
        # No JSON round trip here: billboard channel numbers must stay integer keys.
        target.write_text(header + 'return ' + lua(out) + '\n', encoding='utf-8')
        return target


def import_skill(stem: str, game: GameData | None = None, addon: Path = ADDON,
                 roots: list[str] | None = None) -> Importer:
    game = game or GameData()
    packed = f'data/skill/{stem}.xfbin'
    if not game.has(packed):
        raise SystemExit(f'{packed} is not in the game archives')
    importer = Importer(game, stem, addon)
    importer.skill_file(packed, roots)
    return importer


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('skill', help='skill file stem, e.g. 4efb_amt1_x')
    ap.add_argument('--addon', type=Path, default=ADDON, help='addon folder to write into (default: the project addon)')
    ap.add_argument('--script', action='append', help='import only this script and its spawned scripts; repeat for several roots')
    ap.add_argument('--keep', help='comma-separated effect animations to keep (with what they use); default: all')
    ap.add_argument('--add', help='comma-separated effect animations to import besides the scripts\' own (an impact '
                    'another script plays): looked up in the loaded files, then in the chunk index')
    ap.add_argument('--without', help='comma-separated clump name prefixes whose models are left out of the animations '
                    '(a cinematic animation\'s own character); their coordinates stay')
    ap.add_argument('--without-resources', help='comma-separated resources whose emitters are silenced in every effect '
                    '(host edit: the emitter stays, without events or resources)')
    ap.add_argument('--life', help='host edit, "<resource>:<frames>[,...]": the life of the particles of the emitters that '
                    'launch only that resource (the game\'s value is kept in the package\'s edits)')
    ap.add_argument('--start-ms', type=int, help='host edit of the --add effects: they start this far into their animation '
                    '(the engine steps over the frames before it)')
    ap.add_argument('--end-ms', help='host edit of the --add effects, "<ms>[:resource,...]": from that time of their animation '
                    'on, only the particles of the listed resources are drawn')
    args = ap.parse_args()
    Importer.without = tuple(p.strip() for p in (args.without or '').split(',') if p.strip())
    importer = import_skill(args.skill, addon=args.addon, roots=args.script)
    added = [name.strip() for name in (args.add or '').split(',') if name.strip()]
    for name in added:
        importer.effect(name, None)
    # Host edits: choices of the person importing, not data of the game. They are written in
    # the package under `edits` so that the engine and a reader can tell them from the data.
    silenced = {r.strip() for r in (args.without_resources or '').split(',') if r.strip()}
    for name, emitters in importer.out['effects'].items():
        for emitter in emitters or []:
            if silenced and emitter['resources'] and set(emitter['resources']) <= silenced:
                importer.out.setdefault('edits', {}).setdefault(name, {}).setdefault('silenced', []).append(
                    {'emitter': emitter['id'], 'resources': emitter['resources']})
                emitter['resources'], emitter['events'] = [], []
    for item in (args.life or '').split(','):
        resource, _, frames = item.strip().partition(':')
        for name, emitters in importer.out['effects'].items():
            for emitter in emitters or []:
                if resource and emitter['resources'] == [resource]:
                    importer.out.setdefault('edits', {}).setdefault(name, {}).setdefault('lives', []).append(
                        {'emitter': emitter['id'], 'resource': resource, 'gameLife': emitter['life'], 'life': int(frames)})
                    emitter['life'] = int(frames)
    for name in added:
        edit = {}
        if args.start_ms:
            # 3000 ticks a second, 50 ticks an update
            edit['skipFrames'] = args.start_ms * 3 // 50
        if args.end_ms:
            at, _, keep = args.end_ms.partition(':')
            edit['hideAfterTicks'] = int(at) * 3
            edit['hideKeep'] = {r.strip(): True for r in keep.split(',') if r.strip()}
        if edit:
            importer.out.setdefault('edits', {}).setdefault(name, {}).update(edit)
    if args.keep:
        importer.keep_only([e.strip() for e in args.keep.split(',') if e.strip()])
    target = importer.write()
    out = importer.out
    kinds = {}
    for r in out['resources'].values():
        kinds[r['kind']] = kinds.get(r['kind'], 0) + 1
    print(f'{args.skill}: {len(out["skills"])} scripts, {len([e for e in out["effects"].values() if e])} particle effects, '
          f'{sum(len(e) for e in out["effects"].values())} emitters, resources {kinds}, '
          f'{len([m for m in out["models"].values() if m])} models, {len([t for t in out["textures"].values() if t])} textures')
    for entry in out['unsupported']:
        print(f'  UNSUPPORTED {entry["what"]}: {entry["reason"]}')
    print('WROTE:', target, f'({target.stat().st_size} bytes)')
