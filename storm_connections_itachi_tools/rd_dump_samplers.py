"""RenderDoc --python entry point: full pixel-stage sampler descriptors of effect draws.

The exported draw JSON only keeps address and min/mag filter. Mip filter, LOD
clamp, LOD bias and border colour decide how minified effect textures look, so
they are read here for every distinct sampler used by the effect draws of one
capture. Output: gpu_captures/sampler_descriptors_frame<frame>.json
"""
import json
import traceback
from pathlib import Path

import renderdoc as rd

ROOT = Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
FRAME = 22136
LOG = ROOT / 'gpu_captures' / 'rd_export_progress.txt'


def plain(value, depth=0):
    if isinstance(value, (int, float, str, bool)) or value is None:
        return value
    if depth > 3:
        return str(value)
    if isinstance(value, (list, tuple)):
        return [plain(v, depth + 1) for v in value]
    out = {}
    for name in dir(value):
        if name.startswith('_') or name in ('this', 'thisown', 'acquire', 'disown', 'own', 'append', 'next'):
            continue
        try:
            attr = getattr(value, name)
        except Exception:
            continue
        if callable(attr):
            continue
        out[name] = plain(attr, depth + 1)
    return out or str(value)


def main():
    LOG.write_text('sampler script started\n', encoding='utf-8')
    draws = json.loads((ROOT / 'gpu_captures' / f'itachi_amaterasu_frame{FRAME}.effect_coverage_reference.json').read_text(encoding='utf-8'))
    capture = rd.OpenCaptureFile()
    result = capture.OpenFile(str(ROOT / 'gpu_captures' / f'itachi_amaterasu_frame{FRAME}.rdc'), '', None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    result, controller = capture.OpenCapture(rd.ReplayOptions(), None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    rows, seen = [], set()
    try:
        textures = {str(t.resourceId): t for t in controller.GetTextures()}
        for d in draws:
            key = (d['shaders']['ShaderStage.Pixel'][:8], d.get('base_asset'), len(d['textures']))
            if key in seen:
                continue
            seen.add(key)
            controller.SetFrameEvent(int(d['event']), True)
            state = controller.GetPipelineState()
            samplers = [plain(u.sampler) for u in state.GetSamplers(rd.ShaderStage.Pixel)]
            mips = {t['resource']: textures[t['resource']].mips for t in d['textures'] if t['resource'] in textures}
            rows.append({'event': d['event'], 'pixel': key[0], 'base_asset': key[1], 'samplers': samplers, 'texture_mips': mips,
                         'textures': [t['resource'] for t in d['textures']]})
    finally:
        controller.Shutdown()
        capture.Shutdown()
    (ROOT / 'gpu_captures' / f'sampler_descriptors_frame{FRAME}.json').write_text(json.dumps(rows, indent=2), encoding='utf-8')
    LOG.write_text('completed\n', encoding='utf-8')


try:
    main()
except Exception:
    LOG.write_text(traceback.format_exc(), encoding='utf-8')
raise SystemExit(0)
