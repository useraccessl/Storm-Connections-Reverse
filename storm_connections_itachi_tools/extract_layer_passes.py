"""Inventory every NSUNSC.exe function that opens a render layer (a pass).

A pass brackets its draws with 0x14121c240 (open a layer, emit the blend
toggles) and 0x14121c450 (advance the layer). For each function that calls
either, list how many times, which render-target helpers it calls, the shader
constant and sampler names it resolves through 0x14123bb70, and the RTTI class
that references it from a vtable when there is one. This is a map for decoding
pass order; it does not by itself give the order of execution.
"""

from __future__ import annotations

import json
import re
import struct
from collections import defaultdict
from pathlib import Path

from callers_tree import vtable_owner
from disasm_batch import Image
from xrefs import scan

ROOT = Path(__file__).resolve().parent
BEGIN_LAYER = 0x14121c240     # thunk -> 0x141219480
ADVANCE_LAYER = 0x14121c450   # thunk -> 0x1412191d0
RESOLVE_NAME = 0x14123bb70    # (shader key, name) -> descriptor id
TARGET_HELPERS = {
    0x141220a40: 'SetRenderTarget command',
    0x141221640: 'target begin A', 0x141222cc0: 'target begin B', 0x141223a20: 'target begin C',
    0x1412218a0: 'target bind', 0x141221470: 'target helper 0x141221470',
    0x141222be0: 'target helper 0x141222be0', 0x141222c50: 'target helper 0x141222c50',
    0x141222df0: 'target helper 0x141222df0', 0x141223e90: 'target helper 0x141223e90',
    0x141223160: 'Clear command', 0x1412238f0: 'CaptureRenderBuffer A', 0x141223f70: 'CaptureRenderBuffer B',
    0x141224ca0: 'CaptureRenderBuffer command', 0x14123f4f0: 'CaptureImageBuffer command',
}
CALL = re.compile(r'(call|jmp)\s+(0x[0-9a-f]+)')
STRING = re.compile(r'lea\s+rdx, .*"(.*)"')


def layer_classes(img: Image) -> list[dict]:
    """RTTI classes named nuccLayer* / nuccPostEffect*, with their first vtable slots."""
    data, out = img.data, []
    for m in re.finditer(rb'\.\?AV(nuccLayer\w*|nuccPostEffect\w*)@@\0', data):
        td_rva = img.pe.get_rva_from_offset(m.start()) - 16
        pos = data.find(struct.pack('<I', td_rva))
        while pos >= 0:
            col_off = pos - 12
            if col_off >= 0:
                sig, offset, _c, _t, _h, self_rva = struct.unpack_from('<6I', data, col_off)
                try:
                    col_rva = img.pe.get_rva_from_offset(col_off)
                except Exception:
                    col_rva = None
                if sig == 1 and self_rva == col_rva and offset == 0:
                    cur = data.find(struct.pack('<Q', img.base + col_rva))
                    if cur >= 0:
                        vtable = img.base + img.pe.get_rva_from_offset(cur + 8)
                        slots = []
                        for i in range(6):
                            q = img.qword(vtable + i * 8)
                            if not q or not img.is_code(q):
                                break
                            slots.append(hex(q))
                        out.append({'class_name': m.group(1).decode(), 'vtable_va': hex(vtable), 'slots': slots})
            pos = data.find(struct.pack('<I', td_rva), pos + 1)
    return sorted(out, key=lambda r: r['vtable_va'])


def main() -> None:
    img = Image()
    sites = scan(img, [BEGIN_LAYER, ADVANCE_LAYER])
    functions: dict[int, dict] = defaultdict(lambda: {'begin_layer': 0, 'advance_layer': 0})
    for target, key in ((BEGIN_LAYER, 'begin_layer'), (ADVANCE_LAYER, 'advance_layer')):
        for _site, fn in sites[target]['call'] + sites[target]['jmp']:
            if fn != '?':
                functions[int(fn, 16)][key] += 1
    owners = scan(img, list(functions))
    rows = []
    for va in sorted(functions):
        lines = img.function(va)[1]
        names, helpers = [], defaultdict(int)
        for i, line in enumerate(lines):
            m = CALL.search(line)
            if not m:
                continue
            target = int(m.group(2), 16)
            if target in TARGET_HELPERS:
                helpers[TARGET_HELPERS[target]] += 1
            elif target == RESOLVE_NAME:
                for prev in reversed(lines[max(0, i - 14):i]):
                    s = STRING.search(prev)
                    if s:
                        if s.group(1) not in names:
                            names.append(s.group(1))
                        break
        owner = next((o for o in (vtable_owner(img, p) for p in owners[va]['ptr'][:3]) if o), None)
        callers = sorted({f for _s, f in owners[va]['call'] + owners[va]['jmp'] if f != '?'})
        rows.append({'function_va': hex(va), **functions[va], 'target_helpers': dict(helpers),
                     'resolved_names': names, 'vtable_owner': owner, 'direct_callers': callers[:6]})
    classes = layer_classes(img)
    pass_functions = {r['function_va'] for r in rows}
    for c in classes:
        c['slots_that_open_layers'] = [s for s in c['slots'] if s in pass_functions]
    out = ROOT / 'captured_assets/procedural/layer_pass_inventory.json'
    out.write_text(json.dumps({'begin_layer_thunk': hex(BEGIN_LAYER), 'advance_layer_thunk': hex(ADVANCE_LAYER),
                               'functions': rows, 'layer_classes': classes}, indent=2) + '\n', encoding='utf-8')
    for c in classes:
        print(f'{c["class_name"]:44s} vt {c["vtable_va"]} slots {" ".join(c["slots"][:4])}')
    for r in rows:
        extra = ' '.join(f'[{k} x{v}]' for k, v in r['target_helpers'].items())
        print(f'{r["function_va"]} begin {r["begin_layer"]} advance {r["advance_layer"]} {extra} '
              f'{r["vtable_owner"] or ""} {", ".join(r["resolved_names"][:8])}')
    print(f'{len(rows)} functions; WROTE: {out}')


if __name__ == '__main__':
    main()
