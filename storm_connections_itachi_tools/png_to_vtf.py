"""Write a lossless single-mip VTF 7.2 from a decoded game texture PNG."""

from __future__ import annotations

import argparse
import struct
from pathlib import Path

from PIL import Image


def convert(source: Path, target: Path):
    image = Image.open(source).convert("RGBA")
    width, height = image.size
    if width & (width - 1) or height & (height - 1):
        raise ValueError("Source 1 VTF dimensions must be powers of two")
    header = bytearray(80)
    header[:4] = b"VTF\0"
    struct.pack_into("<IIIHHIHH", header, 4, 7, 2, 80, width, height, 0x2000, 1, 0)
    struct.pack_into("<f", header, 48, 1.0)
    struct.pack_into("<I", header, 52, 0)  # RGBA8888
    header[56] = 1  # One mip level.
    struct.pack_into("<I", header, 57, 0xFFFFFFFF)  # No low resolution image.
    struct.pack_into("<H", header, 63, 1)  # Depth.
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(header + image.tobytes())
    print(f"{source.name} -> {target} ({width}x{height})")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inputs", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    for source in args.inputs:
        convert(source, args.output / (source.stem + ".vtf"))


if __name__ == "__main__":
    main()
