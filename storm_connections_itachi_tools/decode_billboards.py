"""Split STORM CONNECTIONS billboard arrays using its original loader.

NSUNSC.exe nuccChunkBillboard::load at VA 0x14134c4e0 reads a 16-byte
header, then uses thirteen 2-bit selectors from the mask at offset 4.
Selector values 0, 1, 2 choose zero, one, or header.count entries.
The array widths below follow the load routine's byte-count expression.
"""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


WIDTHS = (12, 4, 8, 4, 8, 8, 4, 4, 4, 8, 8, 4, 4)
# The loader's endian-swap loops group widths differently, but all scalars
# are floats. Actual array boundaries follow the pointer builder at
# 0x1413917e0, which walks the selectors in ascending order.
FILE_ORDER = tuple(range(13))


def decode(path: Path) -> dict:
    data = path.read_bytes()
    if len(data) < 16:
        raise ValueError("short billboard")
    resource, mask, count, unknown, scalar = struct.unpack_from(">IIHHI", data)
    counts = (0, 1, count)
    pos = 16
    arrays = []
    for group in FILE_ORDER:
        width = WIDTHS[group]
        selector = (mask >> (1 + 2*group)) & 3
        if selector == 3:
            raise ValueError(f"unknown selector 3 in group {group}")
        n = counts[selector]
        length = n * width
        payload = data[pos:pos+length]
        if len(payload) != length:
            raise ValueError(f"short group {group}")
        arrays.append({"group": group, "selector": selector,
                       "width": width, "count": n,
                       "file_offset": pos, "raw_hex": payload.hex()})
        pos += length
    if pos != len(data):
        raise ValueError(f"unaccounted billboard bytes: {len(data)-pos}")
    return {"source": str(path), "size": len(data),
            "header": {"resource_page_index": resource, "mask": f"0x{mask:08x}",
                       "count": count, "unknown_u16": unknown,
                       "unknown_u32": scalar}, "arrays": sorted(arrays, key=lambda a: a["group"])}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--output", type=Path, required=True)
    args = ap.parse_args()
    result = [decode(path) for path in args.files]
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    for item in result:
        print(Path(item["source"]).name, "keys", item["header"]["count"],
              "groups", [(g["group"], g["count"], g["width"])
                        for g in item["arrays"] if g["count"]])
