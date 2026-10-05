"""Split an Amaterasu nuccChunkParticle payload into its five sections."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


def parse_particle(path: Path) -> dict:
    data = path.read_bytes()
    header_size = struct.unpack_from(">I", data)[0]
    if header_size != 40:
        raise ValueError(f"unexpected particle header size: {header_size}")
    sections = []
    pos = header_size
    for index in range(5):
        count_and_size, virtual_offset = struct.unpack_from(">II", data, 4 + index * 8)
        count, size = count_and_size >> 16, count_and_size & 0xffff
        if pos + size > len(data):
            raise ValueError("section exceeds particle chunk")
        entry = {"index": index, "count": count, "size": size,
                 "virtual_offset": virtual_offset, "file_offset": pos}
        if index == 0 and count:
            if size % count:
                raise ValueError("uneven emitter records")
            entry["stride"] = size // count
            entry["emitters"] = []
            for n in range(count):
                record = data[pos + n * entry["stride"]:pos + (n + 1) * entry["stride"]]
                entry["emitters"].append({"index": n,
                                          "words_0_64": struct.unpack_from(">16I", record),
                                          "floats_64_128": struct.unpack_from(">16f", record, 64)})
        sections.append(entry)
        pos += size
    if pos != len(data):
        raise ValueError(f"{len(data)-pos} unaccounted bytes")
    return {"file": str(path), "size": len(data), "header_size": header_size, "sections": sections}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--output", type=Path)
    args = ap.parse_args()
    result = [parse_particle(path) for path in args.files]
    for item in result:
        print(Path(item["file"]).name, [(s["count"], s["size"], s.get("stride")) for s in item["sections"]])
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
