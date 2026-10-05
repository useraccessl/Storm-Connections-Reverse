"""Check the port's translated shaders against the game's on captured draws.

For every captured effect draw of the shader keys the Amaterasu captures hold,
the draw is rendered twice in software (soft_replay) on identical framebuffers:
  A. the game's own vs_4_0 / ps_4_0 bytecode with the captured constant buffer;
  B. the pair shader_port.py translates for that key, specialised with the
     captured material constants as storm_import.py does with a material's,
     compiled to vs_3_0 / ps_3_0 and fed the way GMod feeds it: constants c0-c3
     and TEXCOORD1-7 produced by the addon's engine/cl_shader_layout.lua (run under
     lupa) from the captured values, Source's standard vertex constants built
     from the captured matrices, and the address modes a VTF can offer.
A is itself validated against RenderDoc targets by replay_capture_draws.py, so
B == A means the port reproduces the game's pixels for that draw's inputs.
This checks shader translation and constant layout on real geometry, not the
port's simulation. verify_shader_port.py covers the keys no capture holds.

  1. --prepare FRAME writes gpu_captures/rd_export_job.json (textures, and the
     scene / depth copies the refraction family samples)
  2. run_renderdoc_script.ps1 -Script rd_export_textures.py
  3. run without --prepare
"""

from __future__ import annotations

import argparse
import hashlib
import json
import sys
from collections import defaultdict
from pathlib import Path

import numpy as np
from PIL import Image

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402
from addon_lua import NAMESPACE, engine_path  # noqa: E402

import soft_replay as sr  # noqa: E402
from port_preview import capture_camera  # noqa: E402
from shader_library import ShaderLibrary  # noqa: E402
from shader_port import ADDRESS, SHADERS, Translator, address_code, address_mode, address_name, build, translate  # noqa: E402
from storm_import import DRAW_CONSTANTS, STAGE_CONSTANTS  # noqa: E402
from rd_dump_tools import load, manifest  # noqa: E402
from replay_capture_draws import CAPTURES, ShaderCache, render_state, replay_draw, semantic_key, stream, triangles  # noqa: E402

ADDON = ROOT.parent / 'storm_amaterasu_lab'
# game pixel shader id prefix -> NUD shader key of the same family (film bits 19 / 20 included)
FAMILIES = {'915c5e6e': 0x9f007, 'c4ee9b55': 0x1f007, '19f007_p': 0x19f007, '19f002_p': 0x19f002, '01f002_p': 0x1f002,
            '01f008_p': 0x1f008, '4bf6e191': 0x3f009}
NUD_WRAP = {'Wrap': 1, 'Mirror': 2, 'ClampEdge': 3, 'ClampBorder': 4, 'MirrorOnce': 6}
SIZE = (3840, 2160)
# Constants a captured draw does not list (its program never reads them from the
# buffer the capture recorded): the value the engine would hand the port.
CAPTURE_DEFAULTS = {'g_ScreenToUV': [1.0 / SIZE[0], 1.0 / SIZE[1], 0.0, 0.0], 'g_commonParam': [0.0, 1.0, 1.0, 1.0],
                    'g_multColor': [1.0, 1.0, 1.0, 1.0], 'g_uvOffsetScreen': [0.0, 0.0, 0.0, 0.0],
                    'g_ambientColor': [1.0, 1.0, 1.0, 1.0], 'g_fogColor': [0.0, 0.0, 0.0, 1.0], 'g_fogParam': [0.0, 1.0, 0.0, 1.0],
                    # No scene depth in the port: these only feed the depth comparison of the refraction family.
                    'g_clip': [1.0, 1.0, 2.0, 0.0], 'g_zrange': [1.0, 0.0, 0.0, 0.0]}
FRAMES = [22082, 22102, 22127, 22136, 22149, 22171, 22200]
strip = lambda s: s.split('.', 1)[-1]


def dump_dir(frame: int) -> Path:
    return CAPTURES / 'rd_dumps' / f'frame{frame}'


def supported(frame: int) -> list[dict]:
    draws = json.loads((CAPTURES / f'itachi_amaterasu_frame{frame}.effect_coverage_reference.json').read_text(encoding='utf-8'))
    return [d for d in draws if d['shaders']['ShaderStage.Pixel'][:8] in FAMILIES]


def is_target(texture: dict) -> bool:
    return (texture['info']['width'], texture['info']['height']) == SIZE


def prepare(frame: int) -> None:
    draws = supported(frame)
    job = {'capture': f'itachi_amaterasu_frame{frame}.rdc', 'out_dir': str(dump_dir(frame)), 'dumps': [],
           'save_png': sorted({t['resource'] for d in draws for t in d['textures'] if not is_target(t)})}
    for d in draws:
        targets = [t['resource'] for t in d['textures'] if is_target(t)]
        if targets:
            job['dumps'].append({'event': d['event'], 'resources': targets, 'tag': f'at_{d["event"]}'})
    (CAPTURES / 'rd_export_job.json').write_text(json.dumps(job, indent=2), encoding='utf-8')
    print(f'frame {frame}: {len(draws)} draws, {len(job["save_png"])} textures, {len(job["dumps"])} target dumps')


def lua_list(lua, values):
    return lua.table_from([float(v) for v in values])


class OtherModel(Exception):
    """A captured draw of a translated family whose material the port does not ship."""


class PortShaders:
    """The port's side of a captured draw: the shader pair shader_port.py translates
    for the draw's shader key, specialised with the captured material constants the
    way storm_import.py specialises it with the material's own."""

    def __init__(self):
        self.lua = LuaRuntime(unpack_returned_tuples=True)
        self.layout_source = engine_path('shader_layout').read_bytes()
        self.lua.execute(NAMESPACE)
        self.layout_module = self.lua.execute(self.layout_source.decode('utf-8-sig'))
        self.library = ShaderLibrary()
        self.programs: dict[str, sr.Program] = {}

    def program(self, name: str) -> sr.Program:
        if name not in self.programs:
            self.programs[name] = sr.load_program((SHADERS / f'{name}.bin').read_bytes())
        return self.programs[name]

    def table(self, value):
        if isinstance(value, dict):
            out = self.lua.table()
            for k, v in value.items():
                if v is not None:
                    out[k] = self.table(v)
            return out
        if isinstance(value, (list, tuple)):
            return self.lua.table_from([self.table(v) for v in value])
        return value

    def prepare(self, draw: dict, textures: dict[str, np.ndarray]) -> dict:
        """Translate the pair for a captured draw; returns what draw() needs and a
        digest of everything the port's result depends on."""
        key = FAMILIES[draw['shaders']['ShaderStage.Pixel'][:8]]
        fields = {}
        for stage in draw['constants'].values():
            for buf in stage.values():
                fields.update(buf['fields'])
        captured = lambda name: fields[name]['values'] if name in fields else CAPTURE_DEFAULTS.get(name)
        samplers = {s['binding']: s for s in draw['samplers']}
        # Captured textures are listed by rank in the pixel program's texture registers.
        translator = Translator(self.library, key)
        rank = {name: n for n, (_, name) in enumerate(sorted(translator.ps.textures.items(), key=lambda kv: int(kv[0][1:])))}
        by_binding = {t['binding']: t for t in draw['textures']}

        def address(name: str):
            """NUD wrap codes of a material texture (they are D3D11 address modes) and its size."""
            t = by_binding[rank[name]]
            s = samplers[t['binding']]
            height, width = textures[t['resource']].shape[:2]
            return NUD_WRAP[strip(s['u'])], NUD_WRAP[strip(s['v'])], width, height

        # Address codes per material texture, the importer's rule (shader_port.address_code).
        codes = {}
        for slot, name in enumerate(translator.material_textures()):
            if rank[name] in by_binding:
                wrap_s, wrap_t, width, height = address(name)
                codes[address_name(slot)] = [address_code(wrap_s, width), address_code(wrap_t, height)]

        def classify(name: str, row: int, comp: int):
            if name.startswith(ADDRESS):
                return 'constant', codes.get(name, [0, 0])[comp]
            if row == 0 and (name, comp) in DRAW_CONSTANTS:
                return 'draw', None
            if name in STAGE_CONSTANTS:
                return 'stage', None
            values = captured(name)
            return 'constant', float(values[row * 4 + comp]) if values is not None and row * 4 + comp < len(values) else 0.0

        port = translate(self.library, key, classify)
        digest = hashlib.sha256((port.vertex_hlsl + port.pixel_hlsl + json.dumps(port.layout, sort_keys=True)).encode()
                                + self.layout_source).hexdigest()
        return {'port': port, 'fields': fields, 'captured': captured, 'address': address, 'rank': rank,
                'by_binding': by_binding, 'digest': digest}

    def draw(self, fb: sr.Framebuffer, draw: dict, textures: dict[str, np.ndarray], camera: dict, stats: dict,
             prepared: dict | None = None) -> None:
        prepared = prepared or self.prepare(draw, textures)
        port, fields, captured = prepared['port'], prepared['fields'], prepared['captured']
        address, rank, by_binding = prepared['address'], prepared['rank'], prepared['by_binding']
        build(port)
        layout = port.layout
        values = self.lua.table()
        for entry in layout['dynamic'] + layout['static']:
            found = captured(entry['name'])
            if found is None:
                raise AssertionError(f'event {draw["event"]}: no captured value for {entry["name"]}')
            values[entry['name']] = lua_list(self.lua, found)
        layout_lua = self.table(layout)
        packed = [list(v.values()) for v in self.layout_module.Pack(layout_lua, values).values()]
        static = [list(v.values()) for v in self.layout_module.Static(layout_lua, values).values()]
        elements = {semantic_key(e['name']): e for e in draw['inputs']}
        position = stream(draw, elements['POSITION0'])
        if not np.allclose(position[:, 3], 1.0):
            raise AssertionError(f'event {draw["event"]}: position w is not 1; Source meshes cannot carry it')
        count = len(position)
        vs, ps = self.program(layout['vertex']), self.program(layout['pixel'])
        inputs = {'POSITION0': position}
        for channel, pair in enumerate(static, start=1):
            inputs[f'TEXCOORD{channel}'] = np.tile(np.array(pair + [0.0, 1.0], dtype=np.float32), (count, 1))
        if layout['attributes']['uv0']:
            inputs['TEXCOORD0'] = stream(draw, elements['TEXCOORD0'])
        if layout['attributes']['uv1']:
            inputs['TEXCOORD1'] = stream(draw, elements['TEXCOORD1'])
        if layout['attributes']['normal']:
            inputs['NORMAL0'] = stream(draw, elements['NORMAL0'])
        if layout['attributes']['color']:
            # Source mesh colours are 8-bit; NUD colours are bytes / 255 already.
            inputs['COLOR0'] = np.round(stream(draw, elements['COLOR0']) * 255.0) / 255.0
        # Source's standard vertex constants: cModelViewProj c4, cViewProj c8, cModel[0] c58.
        wvp = np.array(fields['g_matWorldViewProj']['values'], dtype=np.float64).reshape(4, 4)
        world = wvp @ np.linalg.inv(camera['vp'])
        vs_constants = np.zeros((64, 4), dtype=np.float32)
        vs_constants[4:8] = wvp.T
        vs_constants[8:12] = camera['vp'].T
        vs_constants[58:61] = world.T[:3]
        machine = sr.Machine(vs, count, {'c': vs_constants})
        for semantic, register in vs.inputs.items():
            machine.reg[register] = inputs[semantic].astype(np.float32).copy()
        machine.run()
        varyings = {ps.inputs[sem]: machine.reg[reg] for sem, reg in vs.outputs.items()
                    if sem != 'POSITION0' and sem in ps.inputs and reg in machine.reg}
        ps_constants = np.zeros((8, 4), dtype=np.float32)
        ps_constants[:4] = np.array(packed, dtype=np.float32)
        ps_textures = {}
        for n, sampler in enumerate(layout['samplers']):
            t = by_binding[rank[sampler['name']]]
            if sampler.get('system'):
                # The scene copy (the game's g_textureRefScene), clamped as a render target.
                ps_textures[f's{n}'] = sr.Texture(textures[t['resource']], 'ClampEdge', 'ClampEdge')
                continue
            wrap_s, wrap_t, _, _ = address(sampler['name'])
            # What a VTF offers: wrap, or clamp for every other mode (mirror and border run in the shader).
            ps_textures[f's{n}'] = sr.Texture(textures[t['resource']], 'Wrap' if address_mode(wrap_s) == 'wrap' else 'ClampEdge',
                                              'Wrap' if address_mode(wrap_t) == 'wrap' else 'ClampEdge')

        def pixel_shader(n, values):
            m = sr.Machine(ps, n, {'c': ps_constants}, ps_textures)
            for register, value in values.items():
                if register != 'position':
                    m.reg[register] = value
            vpos = np.zeros((n, 4), dtype=np.float32)
            vpos[:, :2] = np.floor(values['position'][:, :2])
            m.reg['vPos'] = vpos
            m.run()
            return m.reg, m.discard

        sr.draw(fb, machine.reg[vs.outputs['POSITION0']], varyings, triangles(draw), pixel_shader,
                render_state(draw), ('oC0',), stats)


def blank() -> sr.Framebuffer:
    color = np.full((SIZE[1], SIZE[0], 4), 0.5, dtype=np.float32)
    depth = np.ones((SIZE[1], SIZE[0]), dtype=np.float32)
    return sr.Framebuffer([color], depth)


class Textures:
    """Decoded source textures (PNG) and, for the refraction family, target dumps at the draw's event."""

    def __init__(self, frame: int):
        self.directory = dump_dir(frame)
        self.cache: dict[str, np.ndarray] = {}
        self.dumps = {(e['tag'], e['resource']): e for e in manifest(self.directory) if 'file' in e} \
            if (self.directory / 'manifest.json').exists() else {}

    def get(self, draw: dict, texture: dict) -> np.ndarray | None:
        resource = texture['resource']
        if is_target(texture):
            entry = self.dumps.get((f'at_{draw["event"]}', resource))
            if entry is None:
                return None
            data = load(self.directory, entry)
            if data.dtype != np.float32:     # R32_FLOAT arrives as raw bytes
                data = np.ascontiguousarray(data[..., :4]).view(np.float32)
            if data.shape[2] < 4:
                data = np.concatenate([data[..., :1]] + [np.zeros_like(data[..., :1])] * 2 + [np.ones_like(data[..., :1])], axis=2)
            return data.astype(np.float32)
        if resource not in self.cache:
            for base in (self.directory, CAPTURES):
                path = base / f'texture_{resource.split("::")[-1]}.png'
                if path.exists():
                    self.cache[resource] = np.asarray(Image.open(path).convert('RGBA'), dtype=np.float32) / 255.0
                    break
            else:
                return None
        return self.cache[resource]


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--frames', type=int, nargs='+', default=FRAMES)
    ap.add_argument('--prepare', type=int, metavar='FRAME', help='write the RenderDoc export job for one capture and exit')
    ap.add_argument('--limit', type=int, default=0, help='max draws per shader family per capture (0 = all)')
    ap.add_argument('--families', nargs='+', help='restrict to these pixel shader id prefixes')
    ap.add_argument('--output', type=Path, default=ROOT / 'captured_assets/procedural/port_shader_check.json')
    ap.add_argument('--refresh', action='store_true', help='recompute captures even when a result for the current shaders is stored')
    args = ap.parse_args()
    if args.prepare:
        prepare(args.prepare)
        raise SystemExit(0)
    port = PortShaders()
    shaders = ShaderCache(CAPTURES / 'captured_shaders')
    empty = lambda: {'draws': 0, 'pixels': 0, 'exact': 0, 'within_1': 0, 'max_error_255': 0.0, 'coverage_mismatch': 0,
                     'skipped_missing_texture': 0}
    # A full run takes hours. Each draw's result is kept with a digest of what the
    # port's side depends on (the generated shader pair, its layout and
    # cl_shader_layout.lua): a later run only redoes the draws whose shaders changed.
    cache_dir = args.output.with_suffix('')
    cache_dir.mkdir(parents=True, exist_ok=True)
    total: dict[str, dict] = defaultdict(empty)
    over = []
    for frame in args.frames:
        cached = cache_dir / f'draws_{frame}.json'
        stored = json.loads(cached.read_text(encoding='utf-8')) if cached.exists() and not args.refresh else {}
        camera = capture_camera(frame)
        source = Textures(frame)
        counted: dict[str, int] = defaultdict(int)
        reused = computed = 0
        for d in supported(frame):
            family = d['shaders']['ShaderStage.Pixel'][:8]
            if (args.families and family not in args.families) or (args.limit and counted[family] >= args.limit):
                continue
            textures = {t['resource']: source.get(d, t) for t in d['textures']}
            if any(v is None for v in textures.values()):
                total[family]['skipped_missing_texture'] += 1
                continue
            counted[family] += 1
            prepared = port.prepare(d, textures)
            row = stored.get(str(d['event']))
            if row is None or row['digest'] != prepared['digest']:
                game, ours = blank(), blank()
                port.draw(ours, d, textures, camera, {}, prepared)
                replay_draw(game, d, shaders, textures, {})
                drawn_game, drawn_ours = np.any(game.color[0] != 0.5, axis=2), np.any(ours.color[0] != 0.5, axis=2)
                touched = drawn_game | drawn_ours
                diff = (np.abs(game.color[0] - ours.color[0]) * 255.0).max(axis=2)
                row = {'digest': prepared['digest'], 'family': family, 'pixels': int(touched.sum()),
                       'exact': int((diff[touched] < 0.5).sum()), 'within_1': int((diff[touched] < 1.5).sum()),
                       'coverage_mismatch': int((drawn_game != drawn_ours).sum()), 'max_error_255': float(diff.max()),
                       'pixels_over_1': int((diff >= 1.5).sum())}
                stored[str(d['event'])] = row
                computed += 1
                if computed % 5 == 0:
                    cached.write_text(json.dumps(stored, indent=1) + '\n', encoding='utf-8')
            else:
                reused += 1
            summary = total[family]
            summary['draws'] += 1
            for name in ('pixels', 'exact', 'within_1', 'coverage_mismatch'):
                summary[name] += row[name]
            summary['max_error_255'] = max(summary['max_error_255'], row['max_error_255'])
            if row['max_error_255'] >= 1.5:
                over.append({'frame': frame, 'event': d['event'], 'family': family, 'max_error_255': row['max_error_255'],
                             'pixels_over_1': row['pixels_over_1'], 'pixels': row['pixels']})
        cached.write_text(json.dumps(stored, indent=1) + '\n', encoding='utf-8')
        print(f'frame {frame}: {computed} draws rendered, {reused} reused', dict(counted), flush=True)
    over = sorted(over, key=lambda r: -r['max_error_255'])[:40]
    if not (args.limit or args.families):
        args.output.write_text(json.dumps({'frames': args.frames, 'families': dict(total), 'draws_over_1': over}, indent=2) + '\n',
                               encoding='utf-8')
        print('WROTE:', args.output)
    for family, row in total.items():
        share = 100.0 * row['within_1'] / max(row['pixels'], 1)
        print(f'{family}: {row["draws"]} draws, {row["pixels"]} px, exact {row["exact"]}, within 1/255 {share:.4f}%, '
              f'max {row["max_error_255"]:.1f}, coverage mismatch {row["coverage_mismatch"]}, '
              f'skipped: {row["skipped_missing_texture"]} missing texture')
