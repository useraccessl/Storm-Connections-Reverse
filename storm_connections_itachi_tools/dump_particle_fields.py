"""Dump every on-disk word in an Amaterasu emitter record for format study."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path


def dump(path: Path) -> None:
    data = path.read_bytes()
    count_size = struct.unpack_from(">I", data, 4)[0]
    count, size = count_size >> 16, count_size & 0xFFFF
    assert count and size == count * 208
    print(f"{path.name}: {count} emitters, {size} bytes")
    for n in range(count):
        record = data[40 + 208*n:40 + 208*(n+1)]
        print(f"  emitter {n+1}")
        for off in range(0, 208, 16):
            words = [struct.unpack_from(">I", record, off+i)[0] for i in (0,4,8,12)]
            floats = [struct.unpack_from(">f", record, off+i)[0] for i in (0,4,8,12)]
            fmt = " ".join(f"{w:08x}" for w in words)
            vals = " ".join(f"{f:8.3g}" for f in floats)
            print(f"    {off:03x}: {fmt} | {vals}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("files", nargs="+", type=Path)
    args = parser.parse_args()
    for file in args.files:
        dump(file)
