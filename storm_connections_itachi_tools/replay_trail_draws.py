"""Export the trail draws of the GPU captures (RenderDoc Python, run with run_renderdoc_script.ps1).

A trail draw is recognised by its context, which only the trail command writes
(0x141389f40): pixel shader c4ee9b55 (key 0x1F007) and g_commonParam.x = FLT_MIN.
For each one: topology, vertex inputs and buffers, indices, the bound texture (PNG)
and the output-merger / rasteriser state, into gpu_captures/trail_draws.json.
"""
import json
import sys
import traceback
from pathlib import Path

ROOT = Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
sys.path.insert(0, str(ROOT))
import renderdoc as rd  # noqa: E402

FOLDER = ROOT / 'gpu_captures'
LOG = FOLDER / 'trail_draws_progress.txt'
PIXEL = 'c4ee9b551b8516275d362df3e70fed099b9b0aedf43c2bd130585512dcbc2a80'
FRAMES = ('22082', '22102', '22127', '22136', '22149', '22171', '22200')


def actions(items):
    for a in items:
        yield a
        yield from actions(a.children)


def trail_events(records):
    out = {}
    for d in records:
        if d['shaders'].get('ShaderStage.Pixel') != PIXEL:
            continue
        values = d['constants'].get('ShaderStage.Vertex', {}).get('perMaterialBuffer', {}).get('fields', {}).get('g_commonParam', {}).get('values')
        if values and 0 < abs(values[0]) < 1e-30:
            out[d['event']] = d
    return out


try:
    output = []
    progress = []
    for frame in FRAMES:
        path = FOLDER / f'itachi_amaterasu_frame{frame}.rdc'
        selected = trail_events(json.loads(path.with_suffix('.all_draws.json').read_text(encoding='utf-8')))
        progress.append(f'{frame}: {len(selected)} trail draws')
        if not selected:
            continue
        capture = rd.OpenCaptureFile()
        result = capture.OpenFile(str(path), '', None)
        if result.code != rd.ResultCode.Succeeded:
            raise RuntimeError(str(result))
        result, c = capture.OpenCapture(rd.ReplayOptions(), None)
        if result.code != rd.ResultCode.Succeeded:
            raise RuntimeError(str(result))
        try:
            for a in actions(c.GetRootActions()):
                if a.eventId not in selected:
                    continue
                c.SetFrameEvent(a.eventId, True)
                p = c.GetPipelineState()
                d = {'frame': frame, 'event': a.eventId, 'record': selected[a.eventId]}
                d['action'] = {k: getattr(a, k) for k in ('numIndices', 'numInstances', 'baseVertex', 'vertexOffset', 'indexOffset')}
                d['indexed'] = bool(a.flags & rd.ActionFlags.Indexed)
                d['topology'] = str(p.GetPrimitiveTopology())
                d['inputs'] = [{'name': v.name, 'buffer': v.vertexBuffer, 'offset': v.byteOffset, 'format': v.format.Name()}
                               for v in p.GetVertexInputs() if v.used]
                d['vertices'] = []
                for b in p.GetVBuffers():
                    if b.resourceId == rd.ResourceId.Null():
                        d['vertices'].append(None)
                        continue
                    raw = bytes(c.GetBufferData(b.resourceId, b.byteOffset, b.byteSize))
                    d['vertices'].append({'stride': b.byteStride, 'size': len(raw), 'raw_hex': raw.hex()})
                if d['indexed']:
                    b = p.GetIBuffer()
                    raw = bytes(c.GetBufferData(b.resourceId, b.byteOffset + a.indexOffset * b.byteStride, a.numIndices * b.byteStride))
                    d['index'] = {'stride': b.byteStride, 'raw_hex': raw.hex()}
                d11 = c.GetD3D11PipelineState()
                rs = d11.rasterizer.state
                d['rasterizer'] = {'cull': str(rs.cullMode), 'fill': str(rs.fillMode), 'frontCCW': bool(rs.frontCCW),
                                   'depthClip': bool(rs.depthClip), 'scissor': bool(rs.scissorEnable)}
                ds = d11.outputMerger.depthStencilState
                d['depthStencil'] = {'depthEnable': bool(ds.depthEnable), 'depthWrites': bool(ds.depthWrites),
                                     'function': str(ds.depthFunction), 'stencil': bool(ds.stencilEnable)}
                bs = d11.outputMerger.blendState
                d['alphaToCoverage'] = bool(bs.alphaToCoverage)
                d['textures'] = []
                for used in p.GetReadOnlyResources(rd.ShaderStage.Pixel):
                    rid = used.descriptor.resource
                    name = 'trail_texture_' + frame + '_' + str(rid).split('::')[-1] + '.png'
                    save = rd.TextureSave()
                    save.resourceId = rid
                    save.destType = rd.FileType.PNG
                    c.SaveTexture(save, str(FOLDER / name))
                    d['textures'].append(name)
                output.append(d)
        finally:
            c.Shutdown()
            capture.Shutdown()
    (FOLDER / 'trail_draws.json').write_text(json.dumps(output, indent=1), encoding='utf-8')
    LOG.write_text('\n'.join(progress) + f'\nExported {len(output)} trail draws\n', encoding='utf-8')
except Exception:
    LOG.write_text(traceback.format_exc(), encoding='utf-8')
raise SystemExit(0)
