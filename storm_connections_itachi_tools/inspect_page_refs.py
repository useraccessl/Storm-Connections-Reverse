"""Resolve XFBIN page-local resource indices, including referenced external chunks."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path

from xfbin_chunks import parse, read_strings, u32


def table(data: bytes):
    type_count, type_size, path_count, path_size, name_count, name_size, map_count, map_size, index_count, ref_count = struct.unpack_from(">10I", data, 28)
    pos = 68
    types, pos = read_strings(data, pos, type_size, type_count)
    paths, pos = read_strings(data, pos, path_size, path_count)
    names, pos = read_strings(data, pos, name_size, name_count)
    pos = (pos + 3) & ~3
    maps = [struct.unpack_from(">3I", data, pos + i * 12) for i in range(map_count)]
    pos += map_size + ref_count * 8
    indices = [u32(data, pos + i * 4) for i in range(index_count)]
    return types, paths, names, maps, indices


def resolve(table_data, global_index: int):
    types, paths, names, maps, indices = table_data
    t, p, n = maps[indices[global_index]]
    return types[t], paths[p], names[n]


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("xfbin", type=Path)
    ap.add_argument("--name", default="")
    args = ap.parse_args()
    data, chunks = parse(args.xfbin)
    table_data = table(data)
    seen = set()
    for c in chunks:
        if args.name and args.name not in c["name"]:
            continue
        page = c["page"]
        if page in seen:
            continue
        seen.add(page)
        end = next((x for x in chunks if x["page"] == page and x["type"] == "nuccChunkPage"), None)
        if end is None:
            continue
        count = u32(data, end["offset"])
        print(f"Page {page}: {count} local indices; selected chunk {c['type']} {c['name']}")
        for local in range(count):
            kind, path, name = resolve(table_data, page + local)
            print(f"  {local:3d} {kind:24s} {name:28s} {path}")
