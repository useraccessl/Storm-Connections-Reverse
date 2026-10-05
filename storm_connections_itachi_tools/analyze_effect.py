"""Report original material-to-texture relationships from an NUCC effect."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

from xfbin_chunks import parse, read_strings, u32


def float_count(fmt: int) -> int:
    return sum(n for flag, n in ((0x80, 1), (0x40, 1), (0x20, 1), (0x10, 2),
                                  (0x08, 4), (0x04, 4), (0x02, 4), (0x01, 4)) if fmt & flag)


def analyze(path: Path, name_filter: str = "") -> dict:
    data, chunks = parse(path)
    counts = struct.unpack_from(">10I", data, 28)
    type_count, type_size, path_count, path_size, name_count, name_size, map_count, map_size, index_count, ref_count = counts
    pos = 68
    types, pos = read_strings(data, pos, type_size, type_count)
    paths, pos = read_strings(data, pos, path_size, path_count)
    names, pos = read_strings(data, pos, name_size, name_count)
    pos = (pos + 3) & ~3
    maps = [struct.unpack_from(">3I", data, pos + i * 12) for i in range(map_count)]
    pos += map_size + ref_count * 8
    global_indices = [u32(data, pos + i * 4) for i in range(index_count)]

    def resolve(page: int, local_index: int) -> dict | None:
        slot = page + local_index
        if slot >= len(global_indices):
            return None
        type_i, path_i, name_i = maps[global_indices[slot]]
        return {"type": types[type_i], "path": paths[path_i], "name": names[name_i]}
    materials = []
    for c in chunks:
        if c["type"] != "nuccChunkMaterial" or (name_filter and c["name"] not in name_filter.split(",")):
            continue
        body = data[c["offset"]:c["offset"] + c["size"]]
        group_count, field02, _, field04 = struct.unpack_from(">HBBf", body)
        fmt = body[11]
        pos = 12
        floats = struct.unpack_from(">" + "f" * float_count(fmt), body, pos)
        pos += 4 * len(floats)
        groups = []
        for _ in range(group_count):
            count, _, flag = struct.unpack_from(">hHi", body, pos)
            pos += 8
            indices = struct.unpack_from(">" + "I" * count, body, pos)
            pos += 4 * count
            refs = [resolve(c["page"], idx) for idx in indices]
            groups.append({"flag": flag, "textures": [
                {"index": idx, "name": ref["name"] if ref else None, "type": ref["type"] if ref else None}
                for idx, ref in zip(indices, refs)]})
        materials.append({"name": c["name"], "field02": field02,
                          "field04": field04, "format": fmt,
                          "floats": floats, "texture_groups": groups,
                          "unparsed_bytes": len(body) - pos})
    return {"source": str(path), "material_count": len(materials), "materials": materials}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("xfbin", type=Path)
    ap.add_argument("--output", type=Path)
    ap.add_argument("--name", default="", help="Comma-separated exact material names")
    ns = ap.parse_args()
    result = analyze(ns.xfbin, ns.name)
    encoded = json.dumps(result, ensure_ascii=False, indent=2)
    if ns.output:
        ns.output.parent.mkdir(parents=True, exist_ok=True)
        ns.output.write_text(encoded + "\n", encoding="utf-8")
    else:
        print(encoded)
