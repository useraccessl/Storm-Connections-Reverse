"""Locate MSVC RTTI descriptors and candidate vtables for an NUCC class."""

from __future__ import annotations

import argparse
import struct
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent / "vendor"))
import pefile  # type: ignore


EXE = Path(r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\NSUNSC.exe")


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("class_name")
    args = ap.parse_args()
    data = EXE.read_bytes()
    pe = pefile.PE(data=data, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    needle = (".?AV" + args.class_name + "@@").encode() + b"\0"
    name_off = data.find(needle)
    if name_off < 0:
        raise ValueError("RTTI class name absent")
    name_rva = pe.get_rva_from_offset(name_off)
    td_rva = name_rva - 16
    print("name", hex(name_off), "RVA", hex(name_rva), "TypeDescriptor RVA", hex(td_rva))
    hits = []
    pos = 0
    pattern = struct.pack("<I", td_rva)
    while True:
        pos = data.find(pattern, pos)
        if pos < 0:
            break
        hits.append(pos)
        pos += 1
    print("32-bit RVA hits", [hex(x) for x in hits[:50]], len(hits))
    for hit in hits:
        # CompleteObjectLocator has TypeDescriptor RVA at +12.
        col_off = hit - 12
        if col_off < 0:
            continue
        sig, offset, ctor_disp, type_rva, hierarchy_rva, self_rva = struct.unpack_from("<6I", data, col_off)
        col_rva = pe.get_rva_from_offset(col_off)
        if sig != 1 or self_rva != col_rva or type_rva != td_rva:
            continue
        col_va = base + col_rva
        print("COL", hex(col_off), "VA", hex(col_va), "object offset", offset)
        pointer = struct.pack("<Q", col_va)
        cur = 0
        while True:
            cur = data.find(pointer, cur)
            if cur < 0:
                break
            print("  vtable[-1]", hex(cur), "vtable VA", hex(base + pe.get_rva_from_offset(cur + 8)))
            for i in range(12):
                fn = struct.unpack_from("<Q", data, cur + 8 + i * 8)[0]
                print(f"    {i:2d} {fn:#018x}")
            cur += 8
