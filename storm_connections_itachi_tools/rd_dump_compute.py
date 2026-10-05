"""RenderDoc --python entry point: the compute dispatches of a capture.

The game skins its NUD models on the GPU with a compute shader that is in no
file of the game (it is compiled at run time). This writes, for one capture:

  gpu_captures/compute/dispatches_frame<frame>.json   every dispatch: event, group
        counts, shader id, bound buffers (offset, size, stride) and constant blocks
  gpu_captures/compute/shader_<id>.dxbc               each distinct compute shader
  gpu_captures/compute/e<event>_<kind><slot>.bin      contents of the buffers of the
        first DUMPS dispatches of each shader, read after the dispatch has run

Run with run_renderdoc_script.ps1.
"""
import json
import traceback
from pathlib import Path

import renderdoc as rd

ROOT = Path(r'C:\Users\edenm\Desktop\Projects\Storm Connections Reverse\storm_connections_itachi_tools')
FRAME = 22136
OUT = ROOT / 'gpu_captures' / 'compute'
LOG = ROOT / 'gpu_captures' / 'rd_export_progress.txt'
DUMPS = 3
LIMIT = 8 << 20


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


def walk(actions, out):
    for action in actions:
        if action.flags & rd.ActionFlags.Dispatch:
            out.append(action)
        walk(action.children, out)


def main():
    LOG.write_text('compute script started\n', encoding='utf-8')
    OUT.mkdir(parents=True, exist_ok=True)
    capture = rd.OpenCaptureFile()
    result = capture.OpenFile(str(ROOT / 'gpu_captures' / f'itachi_amaterasu_frame{FRAME}.rdc'), '', None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    result, controller = capture.OpenCapture(rd.ReplayOptions(), None)
    if result.code != rd.ResultCode.Succeeded:
        raise RuntimeError(str(result))
    rows, shaders = [], {}
    try:
        dispatches = []
        walk(controller.GetRootActions(), dispatches)
        buffers = {str(b.resourceId): b for b in controller.GetBuffers()}
        for action in dispatches:
            controller.SetFrameEvent(action.eventId, True)
            state = controller.GetPipelineState()
            stage = rd.ShaderStage.Compute
            shader = str(state.GetShader(stage))
            reflection = state.GetShaderReflection(stage)
            row = {'event': action.eventId, 'groups': list(action.dispatchDimension), 'shader': shader, 'bound': []}
            if shader not in shaders:
                shaders[shader] = 0
                if reflection is not None:
                    (OUT / f'shader_{shader.split("::")[-1]}.dxbc').write_bytes(bytes(reflection.rawBytes))
                    row['reflection'] = {
                        'entry': reflection.entryPoint,
                        'readOnly': [plain(r) for r in reflection.readOnlyResources],
                        'readWrite': [plain(r) for r in reflection.readWriteResources],
                        'constantBlocks': [{'name': b.name, 'byteSize': b.byteSize, 'slot': b.fixedBindNumber,
                                            'variables': [{'name': v.name, 'offset': v.byteOffset, 'type': v.type.name,
                                                           'rows': v.type.rows, 'columns': v.type.columns,
                                                           'elements': v.type.elements} for v in b.variables]}
                                           for b in reflection.constantBlocks]}
            dump = shaders[shader] < DUMPS
            shaders[shader] += 1
            for kind, used in (('ro', state.GetReadOnlyResources(stage)), ('rw', state.GetReadWriteResources(stage))):
                for item in used:
                    descriptor = item.descriptor
                    rid = str(descriptor.resource)
                    slot = item.access.index
                    entry = {'kind': kind, 'slot': slot, 'resource': rid, 'byteOffset': descriptor.byteOffset,
                             'byteSize': descriptor.byteSize, 'elementByteSize': descriptor.elementByteSize,
                             'format': descriptor.format.Name(), 'bufferLength': buffers[rid].length if rid in buffers else None}
                    if dump and rid in buffers:
                        length = min(buffers[rid].length, LIMIT)
                        data = controller.GetBufferData(descriptor.resource, 0, length)
                        name = f'e{action.eventId}_{kind}{slot}.bin'
                        (OUT / name).write_bytes(bytes(data))
                        entry['file'] = name
                    row['bound'].append(entry)
            for item in state.GetConstantBlocks(stage):
                descriptor = item.descriptor
                rid = str(descriptor.resource)
                entry = {'kind': 'cb', 'slot': item.access.index, 'resource': rid, 'byteOffset': descriptor.byteOffset,
                         'byteSize': descriptor.byteSize}
                if dump and rid in buffers:
                    data = controller.GetBufferData(descriptor.resource, descriptor.byteOffset, min(descriptor.byteSize or buffers[rid].length, 65536))
                    name = f'e{action.eventId}_cb{item.access.index}.bin'
                    (OUT / name).write_bytes(bytes(data))
                    entry['file'] = name
                row['bound'].append(entry)
            rows.append(row)
            LOG.write_text(f'dispatch {action.eventId}\n', encoding='utf-8')
    finally:
        controller.Shutdown()
        capture.Shutdown()
    (OUT / f'dispatches_frame{FRAME}.json').write_text(json.dumps({'dispatches': rows, 'shaders': shaders}, indent=1), encoding='utf-8')
    LOG.write_text('completed\n', encoding='utf-8')


try:
    main()
except Exception:
    LOG.write_text(traceback.format_exc(), encoding='utf-8')
raise SystemExit(0)
