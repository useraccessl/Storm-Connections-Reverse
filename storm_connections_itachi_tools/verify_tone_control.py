"""Check the port's stage tone-control pass against the game's own pass.

The game's first post-process pass (pixel shader 81206c57...) reads the scene
copy and writes the tone-controlled image. With the input and the output of
that pass dumped by RenderDoc this compares, over the whole 3840x2160 target:
  A. the game's ps_4_0 bytecode run in software            vs the game's output
  B. the port's ps_3_0 (storm_tone_ps30.vcs), constants
     packed by storm_stage_post.lua from the captured ones  vs the game's output
A validates the software replay of this shader (it relies on D3D NaN rules),
B is the port check.

  1. --prepare            writes gpu_captures/rd_export_job.json
  2. run_renderdoc_script.ps1 -Script rd_export_textures.py
  3. run without --prepare
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402

import soft_replay as sr  # noqa: E402
from compile_source_shader import unpack  # noqa: E402
from rd_dump_tools import load, manifest  # noqa: E402

CAPTURES = ROOT / 'gpu_captures'
ADDON = ROOT.parent / 'storm_amaterasu_lab'
TONE_SHADER = '81206c57a9'
CHUNK = 1 << 20


def tone_draw(frame: int) -> dict:
    draws = json.loads((CAPTURES / f'itachi_amaterasu_frame{frame}.all_draws.json').read_text(encoding='utf-8'))
    return next(d for d in draws if d['shaders'].get('ShaderStage.Pixel', '').startswith(TONE_SHADER))


def fields(draw: dict) -> dict:
    out = {}
    for buffers in draw['constants'].values():
        for buffer in buffers.values():
            for name, field in buffer['fields'].items():
                out[name] = [float(v) for v in field['values']]
    return out


def run(program: sr.Program, registers, constants, texture: sr.Texture, output: str, count: int, sampler: str) -> np.ndarray:
    result = np.empty((count, 4), dtype=np.float32)
    for start in range(0, count, CHUNK):
        stop = min(start + CHUNK, count)
        machine = sr.Machine(program, stop - start, constants, {sampler: texture})
        for name, value in registers(start, stop).items():
            machine.reg[name] = value
        machine.run()
        result[start:stop] = machine.reg[output]
    return result


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('--frame', type=int, default=22136)
    ap.add_argument('--prepare', action='store_true')
    args = ap.parse_args()
    draw = tone_draw(args.frame)
    source, target = draw['textures'][0]['resource'], draw['targets'][0]
    directory = CAPTURES / 'rd_dumps' / f'frame{args.frame}'
    tag = f'tone_{draw["event"]}'
    if args.prepare:
        job = {'capture': f'itachi_amaterasu_frame{args.frame}.rdc', 'out_dir': str(directory),
               'dumps': [{'event': draw['event'], 'resources': [source, target], 'tag': tag}]}
        (CAPTURES / 'rd_export_job.json').write_text(json.dumps(job, indent=2), encoding='utf-8')
        print(f'event {draw["event"]}: {source} -> {target}; job written')
        raise SystemExit(0)
    dumps = {e['resource']: e for e in manifest(directory) if 'file' in e and e['tag'] == tag}
    scene, oracle = load(directory, dumps[source]), load(directory, dumps[target])
    height, width = scene.shape[:2]
    count = width * height
    texture = sr.Texture(scene, 'ClampEdge', 'ClampEdge')
    captured = fields(draw)
    ys, xs = np.divmod(np.arange(count, dtype=np.int64), width)

    # A. the game's pixel shader: v0 = SV_Position (pixel centre), v1 = g_ScreenToUV from its vertex shader.
    game = sr.load_program((CAPTURES / 'captured_shaders' / (draw['shaders']['ShaderStage.Pixel'] + '.dxbc')).read_bytes())
    buffer = np.zeros((10, 4), dtype=np.float32)
    for row, name in ((5, 'paramR'), (6, 'paramG'), (7, 'paramB'), (8, 'hparam'), (9, 'lparam')):
        buffer[row] = captured[name]
    to_uv = np.array(captured['g_ScreenToUV'], dtype=np.float32)

    def game_registers(start, stop):
        position = np.zeros((stop - start, 4), dtype=np.float32)
        position[:, 0], position[:, 1] = xs[start:stop] + 0.5, ys[start:stop] + 0.5
        return {'v0': position, 'v1': np.broadcast_to(to_uv, (stop - start, 4)).copy()}

    game_out = run(game, game_registers, {'cb0': buffer}, texture, 'o0', count, 't0')

    # B. the port's pixel shader with constants packed by the Lua module.
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute('function CreateMaterial() end')
    post = lua.execute((ADDON / 'lua/storm_amt_lab/storm_stage_post.lua').read_text(encoding='utf-8'))
    tone = lua.table_from({name: lua.table_from(captured[name]) for name in ('paramR', 'paramG', 'paramB', 'hparam', 'lparam')})
    packed = np.zeros((16, 4), dtype=np.float32)
    packed[:4] = [list(v.values()) for v in post.pack(tone, width, height).values()]
    port = sr.load_program(unpack((ADDON / 'shaders/fxc/storm_tone_ps30.vcs').read_bytes()))

    def port_registers(start, stop):
        pixel = np.zeros((stop - start, 4), dtype=np.float32)
        pixel[:, 0], pixel[:, 1] = xs[start:stop], ys[start:stop]
        return {'vPos': pixel}

    port_out = run(port, port_registers, {'c': packed}, texture, 'oC0', count, 's0')

    def quantize(values):
        return np.floor(np.clip(np.nan_to_num(values[:, :3]), 0, 1) * 255.0 + 0.5).reshape(height, width, 3)

    reference = np.round(oracle[..., :3] * 255.0)
    report = {'frame': args.frame, 'event': draw['event'], 'pixels': count, 'constants': {k: captured[k] for k in ('paramR', 'paramG', 'paramB', 'hparam', 'lparam')}}
    failed = False
    for label, values in (('game shader in software', game_out), ('port shader', port_out)):
        error = np.abs(quantize(values) - reference).max(axis=2)
        row = {'exact': int((error == 0).sum()), 'within_1': int((error <= 1).sum()), 'max_error_255': float(error.max())}
        report[label] = row
        print(f'{label} vs game output: exact {row["exact"]} / {count}, within 1/255 {row["within_1"]}, max {row["max_error_255"]:.0f}')
        failed |= row['within_1'] != count
    (ROOT / 'captured_assets/procedural/tone_control_check.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    if failed:
        raise SystemExit('FAIL: tone control differs from the game by more than 1/255 somewhere')
    print('PASS: tone control reproduces the game pass within 1/255 on every pixel')
