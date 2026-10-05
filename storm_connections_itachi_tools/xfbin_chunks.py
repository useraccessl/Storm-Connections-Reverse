"""List XFBIN chunks and optionally export raw NUT textures for inspection."""

from __future__ import annotations

import argparse
import collections
import struct
from pathlib import Path


def u32(data: bytes, offset: int) -> int:
    return struct.unpack_from(">I", data, offset)[0]


def read_strings(data: bytes, offset: int, size: int, count: int):
    block = data[offset : offset + size]
    strings = [s.decode("cp932", errors="replace") for s in block.rstrip(b"\0").split(b"\0")]
    if len(strings) != count:
        raise ValueError(f"expected {count} strings at 0x{offset:x}, got {len(strings)}")
    return strings, offset + size


def parse(path: Path):
    data = path.read_bytes()
    if data[:4] != b"NUCC":
        raise ValueError("not an XFBIN")
    pos = 28
    counts = struct.unpack_from(">10I", data, pos)
    pos += 40
    type_count, type_size, path_count, path_size, name_count, name_size, map_count, map_size, index_count, ref_count = counts
    types, pos = read_strings(data, pos, type_size, type_count)
    paths, pos = read_strings(data, pos, path_size, path_count)
    names, pos = read_strings(data, pos, name_size, name_count)
    pos = (pos + 3) & ~3
    maps = [struct.unpack_from(">3I", data, pos + i * 12) for i in range(map_count)]
    pos += map_size
    pos += ref_count * 8
    indices = [u32(data, pos + i * 4) for i in range(index_count)]
    pos += index_count * 4
    chunks = []
    page_start = 0
    while pos + 12 <= len(data):
        size, local_index = struct.unpack_from(">2I", data, pos)
        body_start = pos + 12
        body_end = body_start + size
        if body_end > len(data) or page_start + local_index >= len(indices):
            raise ValueError(f"invalid chunk at 0x{pos:x}")
        type_i, path_i, name_i = maps[indices[page_start + local_index]]
        kind, file_path, name = types[type_i], paths[path_i], names[name_i]
        chunks.append({"type": kind, "path": file_path, "name": name, "offset": body_start, "size": size, "page": page_start, "local_index": local_index})
        if kind == "nuccChunkPage":
            page_start += u32(data, body_start)
        pos = body_end
    return data, chunks


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+", type=Path)
    parser.add_argument("--type", default="")
    parser.add_argument("--export-nut", type=Path)
    parser.add_argument("--export-chunks", type=Path)
    parser.add_argument("--name", default="")
    args = parser.parse_args()
    for path in args.files:
        data, chunks = parse(path)
        print(f"{path.name}: {len(chunks)} chunks")
        print("  " + ", ".join(f"{kind}={count}" for kind, count in collections.Counter(c["type"] for c in chunks).items()))
        for chunk in chunks:
            if args.type and args.type.lower() not in chunk["type"].lower():
                continue
            if args.name and args.name.lower() not in chunk["name"].lower():
                continue
            print(f"  {chunk['type']} {chunk['name']} ({chunk['size']} bytes) {chunk['path']}")
            if args.export_chunks:
                safe_name = chunk["name"].replace("/", "_").replace("\\", "_")
                target = args.export_chunks / path.stem / chunk["type"] / (safe_name + ".bin")
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(data[chunk["offset"] : chunk["offset"] + chunk["size"]])
            if args.export_nut and chunk["type"] == "nuccChunkTexture":
                start = chunk["offset"]
                size = u32(data, start + 8)
                nut = data[start + 12 : start + 12 + size]
                if not nut.startswith(b"NTP3"):
                    raise ValueError(f"{chunk['name']} has no NTP3 texture")
                target = args.export_nut / path.stem / (chunk["name"] + ".nut")
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(nut)


if __name__ == "__main__":
    main()
