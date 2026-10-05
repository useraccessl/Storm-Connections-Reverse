"""Fast cross-reference scan for several NSUNSC.exe VAs in one pass.

For each target reports: rel32 call/jmp sites, other RIP-relative references in
code (lea/mov), and absolute 8-byte pointers anywhere in the image (vtables,
tables). Code hits are attributed to their unwind function start. Rel32 matches
are byte-pattern candidates; confirm a surprising one in the disassembly.
"""

from __future__ import annotations

import argparse
import struct

import numpy as np

from disasm_batch import Image


def rtti_name(img: Image, vtable: int) -> str | None:
    """MSVC RTTI class name for a vtable VA, or None."""
    col = img.qword(vtable - 8)
    if col is None:
        return None
    raw = img.read(col, 24)
    if not raw or len(raw) < 24:
        return None
    sig, _off, _cd, type_rva, _hier, self_rva = struct.unpack('<6I', raw)
    if sig != 1 or img.base + self_rva != col:
        return None
    return img.cstring(img.base + type_rva + 16, 200)


def owner(img: Image, va: int) -> str:
    try:
        return f'{img.function_range(va)[0]:#x}'
    except ValueError:
        return '?'


def scan(img: Image, targets: list[int]) -> dict[int, dict[str, list]]:
    out = {t: {'call': [], 'jmp': [], 'rip': [], 'ptr': []} for t in targets}
    data = np.frombuffer(img.data, dtype=np.uint8)
    for start, _end, raw, rawsize, ch in img.sections:
        if not ch & 0x20000000:
            continue
        blob = img.data[raw:raw + rawsize]
        n = len(blob) - 4
        arr = np.frombuffer(blob, dtype=np.uint8)
        disp = (arr[:n].astype(np.int64) | (arr[1:n + 1].astype(np.int64) << 8)
                | (arr[2:n + 2].astype(np.int64) << 16) | (arr[3:n + 3].astype(np.int64) << 24))
        disp = np.where(disp >= 1 << 31, disp - (1 << 32), disp)
        resolved = img.base + start + np.arange(n, dtype=np.int64) + 4 + disp
        for t in targets:
            for i in np.nonzero(resolved == t)[0]:
                i = int(i)
                va = img.base + start + i
                prev = blob[i - 1] if i else 0
                kind = 'call' if prev == 0xe8 else 'jmp' if prev == 0xe9 else 'rip'
                site = va - 1 if kind != 'rip' else va
                out[t][kind].append((site, owner(img, site)))
    for t in targets:
        needle = struct.pack('<Q', t)
        pos = img.data.find(needle)
        while pos >= 0:
            try:
                out[t]['ptr'].append(img.base + img.pe.get_rva_from_offset(pos))
            except Exception:
                pass
            pos = img.data.find(needle, pos + 1)
    del data
    return out


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('targets', nargs='+', type=lambda s: int(s, 0))
    ap.add_argument('--limit', type=int, default=40)
    args = ap.parse_args()
    img = Image()
    res = scan(img, args.targets)
    for t in args.targets:
        r = res[t]
        print(f'== {t:#x}: {len(r["call"])} calls, {len(r["jmp"])} jmps, {len(r["rip"])} rip refs, {len(r["ptr"])} pointers')
        for kind in ('call', 'jmp', 'rip'):
            for site, fn in r[kind][:args.limit]:
                print(f'   {kind:4s} {site:#x} in {fn}')
            if len(r[kind]) > args.limit:
                print(f'   ... {len(r[kind]) - args.limit} more {kind}')
        for p in r['ptr'][:args.limit]:
            print(f'   ptr  {p:#x}')
