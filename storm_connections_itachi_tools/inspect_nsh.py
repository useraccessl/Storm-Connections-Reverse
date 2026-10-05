"""Inventory embedded Direct3D bytecode in the game's NUP4 shader archive."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


def shaders(path: Path) -> list[dict]:
    data = path.read_bytes()
    entries = []
    pos = 0
    while True:
        offset = data.find(b"DXBC", pos)
        if offset < 0:
            break
        pos = offset + 4
        if offset + 32 > len(data):
            continue
        size, chunk_count = struct.unpack_from("<II", data, offset + 24)
        if not 32 <= size <= len(data) - offset or not 1 <= chunk_count <= 32:
            continue
        chunk_offsets = struct.unpack_from("<" + "I" * chunk_count, data, offset + 32)
        kinds = []
        for rel in chunk_offsets:
            if rel + 8 > size:
                raise ValueError(f"invalid DXBC chunk offset at {offset:x}")
            kinds.append(data[offset + rel:offset + rel + 4].decode("ascii", "replace"))
        entries.append({"offset": offset, "size": size, "chunks": kinds})
    return entries


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("nsh", type=Path)
    parser.add_argument("--json", type=Path)
    parser.add_argument("--dump", type=Path)
    args = parser.parse_args()
    entries = shaders(args.nsh)
    print(f"{args.nsh.name}: {len(entries)} valid DXBC shaders")
    print("First 20:")
    for i, entry in enumerate(entries[:20]):
        print(i, hex(entry["offset"]), entry["size"], ",".join(entry["chunks"]))
    if args.json:
        args.json.parent.mkdir(parents=True, exist_ok=True)
        args.json.write_text(json.dumps(entries, indent=2) + "\n", encoding="utf-8")
    if args.dump:
        args.dump.mkdir(parents=True, exist_ok=True)
        data = args.nsh.read_bytes()
        for i, entry in enumerate(entries):
            start = entry["offset"]
            (args.dump / f"{i:04d}_{start:08x}.dxbc").write_bytes(data[start:start + entry["size"]])
