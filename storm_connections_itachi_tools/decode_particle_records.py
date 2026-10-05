"""Lossless, parser-backed inventory of the original particle records.

Field offsets and endian conversions are taken from NSUNSC.exe's
nuccChunkParticle loader (vtable slot 2, VA 0x141320290). Names describe
storage types only; particle behavior is not inferred from numeric patterns.
"""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path


def be_u16(data: bytes, off: int) -> int:
    return struct.unpack_from(">H", data, off)[0]


def be_u32(data: bytes, off: int) -> int:
    return struct.unpack_from(">I", data, off)[0]


def be_f32(data: bytes, off: int) -> float:
    return struct.unpack_from(">f", data, off)[0]


def decode_emitter(data: bytes, index: int) -> dict:
    assert len(data) == 0xD0
    # The loader converts the first three words, then specific 16/32-bit
    # fields within its 0xC0-byte substructure. The remaining bytes are
    # retained verbatim; treating them all as floats loses information.
    prefix = {f"0x{off:02x}": be_u32(data, off) for off in (0, 4, 8)}
    halfwords = {f"0x{off:02x}": be_u16(data, off)
                 for off in (0x16, 0x1C, 0x2C)}
    words = {f"0x{off:02x}": be_u32(data, off)
             for off in range(0x18, 0x5C, 4)
             if off not in (0x1C, 0x2C)}
    vectors3 = {f"0x{off:02x}": [be_f32(data, off+i) for i in (0, 4, 8)]
                for off in (0x5C, 0x68, 0x74, 0x80)}
    vectors4 = {f"0x{off:02x}": [be_f32(data, off+i) for i in (0, 4, 8, 12)]
                for off in (0x90, 0xA0, 0xB0)}
    return {
        "index": index,
        "resource_page_index": prefix["0x00"],
        "emitter_id": prefix["0x04"],
        "prefix_u32": prefix,
        "converted_u16": halfwords,
        "converted_u32": words,
        "converted_vec3": vectors3,
        "converted_vec4": vectors4,
        "converted_0x8c_u32": be_u32(data, 0x8C),
        "converted_0xc0_u32": be_u32(data, 0xC0),
        "opaque_bytes": {
            "0x0c_0x15": data[0x0C:0x16].hex(),
            "0x1e_0x1f": data[0x1E:0x20].hex(),
            "0x2e_0x2f": data[0x2E:0x30].hex(),
            "0xc4_0xcf": data[0xC4:0xD0].hex(),
        },
        "raw_hex": data.hex(),
    }


def decode(path: Path) -> dict:
    data = path.read_bytes()
    if be_u32(data, 0) != 0x28:
        raise ValueError("unexpected particle header")
    cursor = 0x28
    sections = []
    for n in range(5):
        count, length = struct.unpack_from(">HH", data, 4 + n*8)
        virtual_offset = be_u32(data, 8 + n*8)
        section = data[cursor:cursor+length]
        if len(section) != length:
            raise ValueError(f"short section {n}")
        sections.append({"index": n, "count": count, "length": length,
                         "virtual_offset": virtual_offset,
                         "file_offset": cursor, "raw_hex": section.hex()})
        cursor += length
    if cursor != len(data):
        raise ValueError("unaccounted trailing bytes")
    emit = sections[0]
    if emit["length"] != emit["count"]*0xD0:
        raise ValueError("unexpected emitter stride")
    raw = bytes.fromhex(emit.pop("raw_hex"))
    emit["stride"] = 0xD0
    emit["records"] = [decode_emitter(raw[n*0xD0:(n+1)*0xD0], n)
                       for n in range(emit["count"])]
    return {"source": str(path), "chunk_bytes": len(data), "sections": sections}


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("files", nargs="+", type=Path)
    ap.add_argument("--output", type=Path, required=True)
    args = ap.parse_args()
    result = [decode(path) for path in args.files]
    args.output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    for item in result:
        print(Path(item["source"]).name,
              [s["count"] for s in item["sections"]])
