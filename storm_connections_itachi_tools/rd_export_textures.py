"""RenderDoc --python entry point: dump raw texture contents at chosen events.

Driven by a job file `gpu_captures/rd_export_job.json`:
  {"capture": "itachi_amaterasu_frame22136.rdc", "out_dir": "<abs dir>",
   "dumps": [{"event": 6156, "targets": [0, 1, 2], "depth": false, "tag": "after_main_fire"},
             {"event": 10663, "resource": "ResourceId::45591", "tag": "final"}]}
For each dump it replays up to and including `event`, then writes
`<tag>_<n>.raw` (tightly packed mip 0) and records format, size and the
pipeline's output target ids in `<out_dir>/manifest.json`.
Run through run_renderdoc_analysis.ps1 (qrenderdoc must not keep its UI open).
"""
import json
import traceback
from pathlib import Path

import renderdoc as rd

ROOT = Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
JOB = ROOT / 'gpu_captures' / 'rd_export_job.json'
LOG = ROOT / 'gpu_captures' / 'rd_export_progress.txt'


def main():
    LOG.write_text('script started\n', encoding='utf-8')
    job = json.loads(JOB.read_text(encoding='utf-8-sig'))
    out_dir = Path(job['out_dir'])
    out_dir.mkdir(parents=True, exist_ok=True)
    capture = rd.OpenCaptureFile()
    result = capture.OpenFile(str(ROOT / 'gpu_captures' / job['capture']), '', None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    result, controller = capture.OpenCapture(rd.ReplayOptions(), None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    manifest = []
    try:
        textures = {str(t.resourceId): t for t in controller.GetTextures()}
        for dump in job['dumps']:
            controller.SetFrameEvent(int(dump['event']), True)
            state = controller.GetPipelineState()
            outputs = [str(t.resource) for t in state.GetOutputTargets()]
            depth = str(state.GetDepthTarget().resource)
            wanted = []
            if 'resource' in dump:
                wanted.append(('res', dump['resource']))
            for rid in dump.get('resources', []):
                wanted.append(('res' + rid.split('::')[-1], rid))
            for index in dump.get('targets', []):
                if index < len(outputs):
                    wanted.append((f'rt{index}', outputs[index]))
            if dump.get('depth'):
                wanted.append(('depth', depth))
            for label, rid in wanted:
                tex = textures.get(rid)
                if tex is None:
                    manifest.append({'tag': dump['tag'], 'label': label, 'resource': rid, 'error': 'unknown texture'})
                    continue
                data = controller.GetTextureData(tex.resourceId, rd.Subresource(0, 0, 0))
                name = f'{dump["tag"]}_{label}.raw'
                (out_dir / name).write_bytes(bytes(data))
                manifest.append({
                    'tag': dump['tag'], 'label': label, 'event': dump['event'], 'resource': rid, 'file': name,
                    'width': tex.width, 'height': tex.height, 'format': tex.format.Name(),
                    'comp_count': tex.format.compCount, 'comp_bytes': tex.format.compByteWidth,
                    'comp_type': str(tex.format.compType), 'bytes': len(data),
                    'outputs': outputs, 'depth_target': depth,
                })
                LOG.write_text(f'dumped {name}\n', encoding='utf-8')
        # Decoded mip 0 of source textures (block-compressed ones included).
        for rid in job.get('save_png', []):
            tex = textures.get(rid)
            if tex is None:
                continue
            save = rd.TextureSave()
            save.resourceId = tex.resourceId
            save.mip = 0
            save.slice.sliceIndex = 0
            save.alpha = rd.AlphaMapping.Preserve
            save.destType = rd.FileType.PNG
            controller.SaveTexture(save, str(out_dir / ('texture_' + rid.split('::')[-1] + '.png')))
    finally:
        controller.Shutdown()
        capture.Shutdown()
    # Keep the entries of earlier jobs for this capture; a re-dumped (tag, label) replaces its old row.
    path = out_dir / 'manifest.json'
    fresh = {(e['tag'], e['label']) for e in manifest}
    if path.exists():
        kept = [e for e in json.loads(path.read_text(encoding='utf-8')) if (e['tag'], e['label']) not in fresh]
        manifest = kept + manifest
    path.write_text(json.dumps(manifest, indent=2), encoding='utf-8')
    LOG.write_text('completed\n', encoding='utf-8')


try:
    main()
except Exception:
    LOG.write_text(traceback.format_exc(), encoding='utf-8')
raise SystemExit(0)
