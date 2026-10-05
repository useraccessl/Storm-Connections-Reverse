"""Inventory the deferred render commands of NSUNSC.exe and their D3D11 calls.

Low-level `mmDrawCommand_*` records have no RTTI: their class name comes from
vtable slot 1 (a `lea rax, "name"; ret` getter) and their execute callback is
slot 4. Producers are found from `mov dword [rax+0x28], tag` followed by the
vtable store. Each execute callback is followed to the backend vtable slot it
dispatches, then to the ID3D11DeviceContext methods that backend method calls
on the immediate context held at backend+0x50.

High-level `nuccDrawCommand` subclasses do have RTTI (slot 0 dtor, slot 1 run).
"""

from __future__ import annotations

import json
import re
import struct
from collections import defaultdict
from pathlib import Path

from d3d11_vtables import context_method
from disasm_batch import Image
from xrefs import rtti_name

ROOT = Path(__file__).resolve().parent
BACKEND_VTABLE = 0x141bae0c0  # installed by 0x141414790
CONTEXT_FIELD = '0x50'        # backend+0x50 = D3D11CreateDevice immediate context
INDIRECT = re.compile(r'(call|jmp)\s+qword ptr \[(r\w+) \+ (0x[0-9a-f]+)\]')
DIRECT = re.compile(r'(call|jmp)\s+(0x[0-9a-f]+)')


def getter_string(img: Image, fn: int) -> str | None:
    for line in img.disasm(fn, 0x30)[:6]:
        m = re.search(r'lea\s+rax, .*"(.*)"', line)
        if m:
            return m.group(1)
    return None


def function_lines(img: Image, va: int) -> list[str]:
    try:
        return img.function(va)[1]
    except ValueError:
        return img.disasm(va, 0x40)


def context_calls(img: Image, method: int, depth: int = 1) -> list[str]:
    """ID3D11DeviceContext methods called on [backend+0x50] in a backend method."""
    lines = function_lines(img, method)
    found: list[str] = []
    for i, line in enumerate(lines):
        m = INDIRECT.search(line)
        if m:
            # The receiver is whatever last wrote rcx; accept only backend+0x50.
            writer = next((w for w in reversed(lines[max(0, i - 14):i])
                           if re.search(r'(mov|lea)\s+rcx,', w)), '')
            if f'+ {CONTEXT_FIELD}]' in writer:
                name = context_method(int(m.group(3), 16))
                if name and name not in found:
                    found.append(name)
            continue
        m = DIRECT.search(line)
        if m and depth > 0:
            target = int(m.group(2), 16)
            if 0x141412000 <= target < 0x14142a000 and target != method:
                for name in context_calls(img, target, depth - 1):
                    if name not in found:
                        found.append(name)
    return found


def backend_slots(img: Image, execute: int) -> list[int]:
    """Backend vtable byte offsets an execute callback dispatches to."""
    lines = function_lines(img, execute)
    slots, seen_accessor = [], False
    for line in lines:
        m = INDIRECT.search(line)
        if not m:
            continue
        off = int(m.group(3), 16)
        if off == 0x20 and not seen_accessor:
            seen_accessor = True  # backend context -> renderer accessor
            continue
        if seen_accessor and off not in slots:
            slots.append(off)
    return slots


def low_level_commands(img: Image) -> list[dict]:
    found: dict[tuple[int, int], set[int]] = defaultdict(set)
    for start, _end, raw, rawsize, ch in img.sections:
        if not ch & 0x20000000:
            continue
        blob = img.data[raw:raw + rawsize]
        for m in re.finditer(rb'\xc7\x40\x28(.)\x00\x00\x00', blob, re.S):
            va = img.base + start + m.start()
            window = blob[m.end():m.end() + 0x40]
            for k in re.finditer(rb'[\x48\x4c]\x8d[\x05\x0d\x15\x1d\x25\x2d\x35\x3d]', window):
                if k.end() + 4 > len(window):
                    continue
                target = va + 7 + k.end() + 4 + struct.unpack_from('<i', window, k.end())[0]
                slot0 = img.qword(target)
                if slot0 and img.is_code(slot0) and 0x141b00000 <= target < 0x141c00000:
                    try:
                        found[(m.group(1)[0], target)].add(img.function_range(va)[0])
                    except ValueError:
                        pass
                    break
    out = []
    for (tag, vtable), producers in sorted(found.items()):
        slots = [img.qword(vtable + i * 8) for i in range(5)]
        class_name = getter_string(img, slots[1])
        if not class_name or not class_name.startswith('mmDrawCommand'):
            continue
        row = {
            'tag': tag, 'class_name': class_name, 'name': getter_string(img, slots[2]),
            'vtable_va': hex(vtable), 'execute_va': hex(slots[4]),
            'producer_vas': [hex(p) for p in sorted(producers)], 'backend': [],
        }
        if class_name != 'mmDrawCommand_nummDrawCommand_Function':
            for off in backend_slots(img, slots[4]):
                method = img.qword(BACKEND_VTABLE + off)
                if method and img.is_code(method):
                    # Auto-detected lower bound; a call whose receiver is set
                    # further back (loops, saved registers) is not listed.
                    row['backend'].append({'slot': hex(off), 'method_va': hex(method),
                                           'd3d11_context_calls': context_calls(img, method)})
        out.append(row)
    return out


def high_level_commands(img: Image) -> list[dict]:
    data, out = img.data, []
    for m in re.finditer(rb'\.\?AV(nuccDrawCmd_\w+|nuccDrawCommand\w*)@@\0', data):
        td_rva = img.pe.get_rva_from_offset(m.start()) - 16
        pos = data.find(struct.pack('<I', td_rva))
        while pos >= 0:
            col_off = pos - 12
            sig, _o, _c, _t, _h, self_rva = struct.unpack_from('<6I', data, col_off)
            try:
                col_rva = img.pe.get_rva_from_offset(col_off)
            except Exception:
                col_rva = None
            if sig == 1 and self_rva == col_rva:
                cur = data.find(struct.pack('<Q', img.base + col_rva))
                while cur >= 0:
                    vtable = img.base + img.pe.get_rva_from_offset(cur + 8)
                    if rtti_name(img, vtable):
                        out.append({'class_name': m.group(1).decode(), 'vtable_va': hex(vtable),
                                    'destructor_va': hex(img.qword(vtable)),
                                    'execute_va': hex(img.qword(vtable + 8))})
                    cur = data.find(struct.pack('<Q', img.base + col_rva), cur + 1)
            pos = data.find(struct.pack('<I', td_rva), pos + 1)
    return sorted(out, key=lambda r: r['vtable_va'])


if __name__ == '__main__':
    image = Image()
    report = {
        'record_header': {
            'vtable': '+0x00 (slot0 dtor, slot1 class name, slot2 short name, slot3 arena alloc, slot4 execute)',
            'sort_key': '+0x08 (u64, ascending)', 'next_in_group': '+0x10', 'group_tail': '+0x18 (valid on group head)',
            'frame_arena': '+0x20', 'tag': '+0x28 (category, not a unique type id)', 'payload': '+0x30...',
        },
        'low_level_commands': low_level_commands(image),
        'high_level_commands': high_level_commands(image),
    }
    path = ROOT / 'captured_assets/procedural/mm_draw_command_inventory.json'
    path.write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    for row in report['low_level_commands']:
        calls = '; '.join(f'{b["slot"]}->{b["method_va"]} {",".join(b["d3d11_context_calls"]) or "-"}' for b in row['backend'])
        print(f'tag {row["tag"]:#04x} {row["class_name"]:42s} exec {row["execute_va"]} {calls}')
    for row in report['high_level_commands']:
        print(f'{row["class_name"]:40s} vt {row["vtable_va"]} exec {row["execute_va"]}')
    print('WROTE:', path)
