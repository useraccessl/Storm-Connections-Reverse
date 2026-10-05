"""Re-render captured game draws in software and compare with RenderDoc dumps.

For a range of draw events of one exported capture this runs the game's own
vertex and pixel shader bytecode (soft_replay.Machine) on the captured vertex
streams, constants and textures, applies the captured render state, and
compares the resulting colour targets with the targets RenderDoc reports after
the last event. It proves, or refutes, that shader inputs, rasterization and
state are understood well enough to reproduce the game's pixels.

  1. --prepare writes gpu_captures/rd_export_job.json
  2. run_renderdoc_script.ps1 -Script rd_export_textures.py
  3. --compare
"""

from __future__ import annotations

import argparse
import json
import re
from pathlib import Path

import numpy as np
from PIL import Image

import soft_replay as sr
from dxbc_rdef import parse_rdef
from rd_dump_tools import load, manifest

ROOT = Path(__file__).resolve().parent
CAPTURES = ROOT / 'gpu_captures'
FORMAT_COMPONENTS = {'R32G32B32A32_FLOAT': 4, 'R32G32B32_FLOAT': 3, 'R32G32_FLOAT': 2, 'R32_FLOAT': 1}


def dump_dir(frame: int) -> Path:
    return CAPTURES / 'rd_dumps' / f'frame{frame}'


def load_draws(frame: int, first: int, last: int) -> list[dict]:
    path = CAPTURES / f'itachi_amaterasu_frame{frame}.effect_coverage_reference.json'
    draws = json.loads(path.read_text(encoding='utf-8'))
    return [d for d in draws if first <= d['event'] <= last]


def prepare(frame: int, first: int, last: int, targets: list[str], depth: str) -> None:
    draws = load_draws(frame, first, last)
    textures = sorted({t['resource'] for d in draws for t in d['textures']})
    job = {
        'capture': f'itachi_amaterasu_frame{frame}.rdc', 'out_dir': str(dump_dir(frame)),
        'dumps': [
            {'event': first - 1, 'resources': targets + [depth], 'tag': f'before_{first}'},
            {'event': last, 'resources': targets + [depth], 'tag': f'after_{last}'},
        ],
        'save_png': textures,
    }
    (CAPTURES / 'rd_export_job.json').write_text(json.dumps(job, indent=2), encoding='utf-8')
    print(f'{len(draws)} draws, {len(textures)} textures; job written. Now run:')
    print('  .\\run_renderdoc_script.ps1 -Script rd_export_textures.py')


def stream(draw: dict, element: dict) -> np.ndarray:
    """(vertex count, 4) float32 for one input element, missing components (0, 0, 0, 1)."""
    buffer = draw['vertices'][element['buffer']]
    raw = np.frombuffer(bytes.fromhex(buffer['raw_hex']), dtype=np.uint8)
    stride, count = buffer['stride'], FORMAT_COMPONENTS[element['format']]
    vertices = len(raw) // stride
    floats = raw[:vertices * stride].reshape(vertices, stride)[:, element['offset']:element['offset'] + 4 * count]
    data = np.ascontiguousarray(floats).view(np.float32).reshape(vertices, count)
    out = np.zeros((vertices, 4), dtype=np.float32)
    out[:, 3] = 1.0
    out[:, :count] = data
    return out


def semantic_key(name: str) -> str:
    m = re.fullmatch(r'([A-Za-z_]+?)(\d*)', name)
    return f'{m.group(1)}{m.group(2) or 0}'


def constant_buffers(draw: dict, stage: str, bytecode: bytes) -> dict[str, np.ndarray]:
    slots = {b['name']: b['slot'] for b in parse_rdef(bytecode)['buffers'] if b['slot'] is not None}
    out = {}
    for name, buf in draw['constants'].get(stage, {}).items():
        data = np.frombuffer(bytes.fromhex(buf['raw_hex']), dtype=np.float32)
        out[f'cb{slots[name]}'] = data[:len(data) // 4 * 4].reshape(-1, 4)
    return out


def triangles(draw: dict) -> np.ndarray:
    action = draw['action']
    if draw['indexed']:
        dtype = np.uint16 if draw['index']['stride'] == 2 else np.uint32
        indices = np.frombuffer(bytes.fromhex(draw['index']['raw_hex']), dtype=dtype)[:action['numIndices']]
        indices = indices.astype(np.int64)
        cut = 0xFFFF if dtype == np.uint16 else 0xFFFFFFFF
    else:
        indices, cut = np.arange(action['numIndices'], dtype=np.int64), -1
    if draw['topology'].endswith('TriangleStrip'):
        tris = sr.strip_to_triangles(indices, cut)
    elif draw['topology'].endswith('TriangleList'):
        tris = indices[:len(indices) // 3 * 3].reshape(-1, 3)
    else:
        raise NotImplementedError(draw['topology'])
    return tris + action.get('baseVertex', 0)


def render_state(draw: dict) -> sr.RenderState:
    blend, depth = draw['blend'][0], draw['depth']
    strip = lambda s: s.split('.', 1)[-1]
    return sr.RenderState(
        depth_test=depth['enable'], depth_write=depth['writes'], depth_func=strip(depth['function']),
        cull=strip(draw['cull']), front_counter_clockwise=True, blend=blend['enabled'],
        rgb=tuple(strip(x) for x in blend['rgb']), alpha=tuple(strip(x) for x in blend['alpha']),
        write_mask=blend.get('writeMask', 15))


def registers(listing: str, pattern: str) -> list[str]:
    """Register names declared by a shader listing, in register order."""
    return sorted(set(re.findall(pattern, listing)), key=lambda name: int(name[1:]))


class ShaderCache:
    def __init__(self, directory: Path):
        self.directory, self.cache = directory, {}

    def get(self, shader_id: str) -> tuple[bytes, sr.Program]:
        if shader_id not in self.cache:
            bytecode = (self.directory / f'{shader_id}.dxbc').read_bytes()
            self.cache[shader_id] = (bytecode, sr.load_program(bytecode))
        return self.cache[shader_id]


def replay_draw(fb: sr.Framebuffer, draw: dict, shaders: ShaderCache, textures: dict[str, np.ndarray],
                stats: dict) -> None:
    vs_code, vs = shaders.get(draw['shaders']['ShaderStage.Vertex'])
    ps_code, ps = shaders.get(draw['shaders']['ShaderStage.Pixel'])
    machine = None
    for element in draw['inputs']:
        data = stream(draw, element)
        machine = machine or sr.Machine(vs, len(data), constant_buffers(draw, 'ShaderStage.Vertex', vs_code))
        register = vs.inputs.get(semantic_key(element['name']))
        if register:
            machine.reg[register] = data.copy()
    machine.run()
    position = machine.reg[vs.outputs['SV_Position0']]
    varyings = {ps.inputs[sem]: machine.reg[reg] for sem, reg in vs.outputs.items()
                if sem != 'SV_Position0' and sem in ps.inputs and reg in machine.reg}
    ps_constants = constant_buffers(draw, 'ShaderStage.Pixel', ps_code)
    # The export numbers bound textures and samplers 0..n-1 in register order;
    # shaders may skip registers (the refraction pair uses t0, t2, t3, t4).
    texture_registers = registers(ps.text, r'dcl_resource_texture\w+\s*\([^)]*\)\s*(t\d+)')
    sampler_registers = registers(ps.text, r'dcl_sampler\s+(s\d+)')
    ps_textures = {texture_registers[rank]: sr.Texture(textures[t['resource']])
                   for rank, t in enumerate(sorted(draw['textures'], key=lambda t: t['binding']))}
    strip = lambda s: s.split('.', 1)[-1]
    ps_samplers = {sampler_registers[rank]: {'address_u': strip(s['u']), 'address_v': strip(s['v']),
                                             'point': strip(s.get('mag', 'Linear')) == 'Point'}
                   for rank, s in enumerate(sorted(draw['samplers'], key=lambda s: s['binding']))}
    position_register = ps.inputs.get('SV_Position0')
    outputs = tuple(ps.outputs.get(f'SV_Target{i}', f'o{i}') for i in range(len(fb.color)))

    def pixel_shader(count: int, inputs: dict[str, np.ndarray]):
        m = sr.Machine(ps, count, ps_constants, ps_textures, ps_samplers)
        for register, value in inputs.items():
            if register != 'position':
                m.reg[register] = value
        if position_register:
            m.reg[position_register] = inputs['position']
        m.run()
        return m.reg, m.discard

    sr.draw(fb, position, varyings, triangles(draw), pixel_shader, render_state(draw), outputs, stats)


def compare(frame: int, first: int, last: int, targets: list[str], depth: str, save: bool) -> dict:
    directory = dump_dir(frame)
    entries = manifest(directory)
    by = {(e['tag'], e['resource']): e for e in entries if 'file' in e}
    before, after = f'before_{first}', f'after_{last}'
    color = [load(directory, by[(before, t)]).copy() for t in targets]
    depth_raw = np.ascontiguousarray(load(directory, by[(before, depth)])[..., :4]).view(np.float32)[..., 0].copy()
    fb = sr.Framebuffer(color, depth_raw)
    draws = load_draws(frame, first, last)
    textures = {}
    for d in draws:
        for t in d['textures']:
            if t['resource'] not in textures:
                png = directory / f'texture_{t["resource"].split("::")[-1]}.png'
                textures[t['resource']] = np.asarray(Image.open(png).convert('RGBA'), dtype=np.float32) / 255.0
    shaders = ShaderCache(CAPTURES / 'captured_shaders')
    stats: dict = {}
    for d in draws:
        replay_draw(fb, d, shaders, textures, stats)
    report = {'frame': frame, 'first': first, 'last': last, 'draws': len(draws), 'stats': stats, 'targets': []}
    initial = [load(directory, by[(before, t)]) for t in targets]
    for slot, target in enumerate(targets):
        oracle = load(directory, by[(after, target)])
        changed = np.any(np.abs(oracle - initial[slot]) > 0.5 / 255, axis=2) | np.any(np.abs(fb.color[slot] - initial[slot]) > 0.5 / 255, axis=2)
        diff = np.abs(fb.color[slot] - oracle) * 255.0
        worst = diff.max(axis=2)
        touched = int(changed.sum())
        row = {
            'target': target, 'pixels_changed_by_layer': touched,
            'exact': int((worst[changed] < 0.5).sum()), 'within_1': int((worst[changed] < 1.5).sum()),
            'within_2': int((worst[changed] < 2.5).sum()), 'max_error_255': float(worst.max()),
            'mean_error_255': float(diff[changed].mean()) if touched else 0.0,
            'mismatch_outside_layer': int((worst[~changed] >= 0.5).sum()),
        }
        report['targets'].append(row)
        if save:
            ys, xs = np.nonzero(changed)
            if len(ys):
                y0, y1, x0, x1 = ys.min(), ys.max() + 1, xs.min(), xs.max() + 1
                step = max(1, (x1 - x0) // 1200)
                for name, image in (('soft', fb.color[slot]), ('game', oracle)):
                    crop = (image[y0:y1:step, x0:x1:step, :3] * 255).astype(np.uint8)
                    Image.fromarray(crop).save(directory / f'compare_{first}_{last}_rt{slot}_{name}.png')
                heat = np.clip(worst[y0:y1:step, x0:x1:step] * 8, 0, 255).astype(np.uint8)
                Image.fromarray(heat).save(directory / f'compare_{first}_{last}_rt{slot}_error_x8.png')
    oracle_depth = np.ascontiguousarray(load(directory, by[(after, depth)])[..., :4]).view(np.float32)[..., 0]
    report['depth'] = {'max_abs_error': float(np.abs(fb.depth - oracle_depth).max()),
                       'pixels_differing': int((np.abs(fb.depth - oracle_depth) > 1e-6).sum())}
    return report


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--frame', type=int, default=22136)
    ap.add_argument('--first', type=int, default=5302)
    ap.add_argument('--last', type=int, default=6156)
    ap.add_argument('--targets', nargs='+', default=['ResourceId::45595', 'ResourceId::45598', 'ResourceId::45601'])
    ap.add_argument('--depth', default='ResourceId::45604')
    ap.add_argument('--prepare', action='store_true')
    ap.add_argument('--compare', action='store_true')
    ap.add_argument('--save-images', action='store_true')
    args = ap.parse_args()
    if args.prepare:
        prepare(args.frame, args.first, args.last, args.targets, args.depth)
    if args.compare:
        result = compare(args.frame, args.first, args.last, args.targets, args.depth, args.save_images)
        print(json.dumps(result, indent=2))
        out = ROOT / 'captured_assets/procedural' / f'soft_replay_{args.frame}_{args.first}_{args.last}.json'
        out.write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
        print('WROTE:', out)
