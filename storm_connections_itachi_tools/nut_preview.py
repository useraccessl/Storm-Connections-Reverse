"""Convert the first mip of extracted NTP3 textures to PNG for visual inspection."""

from __future__ import annotations

import argparse
import io
import struct
from pathlib import Path

from PIL import Image


def dds_header(width: int, height: int, fourcc: bytes, block_size: int) -> bytes:
    linear = ((width + 3) // 4) * ((height + 3) // 4) * block_size
    header = bytearray(128)
    header[:4] = b"DDS "
    struct.pack_into("<7I", header, 4, 124, 0x81007, height, width, linear, 0, 0)
    struct.pack_into("<II4s", header, 76, 32, 4, fourcc)
    struct.pack_into("<I", header, 108, 0x1000)
    return bytes(header)


def convert(path: Path, output: Path):
    nut = path.read_bytes()
    if nut[:4] != b"NTP3" or struct.unpack_from(">H", nut, 6)[0] != 1:
        raise ValueError("expected a single-texture NTP3 file")
    data_size = struct.unpack_from(">I", nut, 24)[0]
    header_size = struct.unpack_from(">H", nut, 28)[0]
    fmt = nut[35]
    width, height = struct.unpack_from(">HH", nut, 36)
    start = 0x10 + header_size
    data = nut[start : start + data_size]
    if len(data) != data_size:
        raise ValueError("truncated texture")
    if fmt in (0, 1, 2):
        fourcc = {0: b"DXT1", 1: b"DXT3", 2: b"DXT5"}[fmt]
        block_size = 8 if fmt == 0 else 16
        first_mip = ((width + 3) // 4) * ((height + 3) // 4) * block_size
        dds = dds_header(width, height, fourcc, block_size) + data[:first_mip]
        image = Image.open(io.BytesIO(dds)).convert("RGBA")
    elif fmt == 17:
        image = Image.frombytes("RGBA", (width, height), data[: width * height * 4], "raw", "BGRA")
    elif fmt == 8:
        # NTP3 RGB565, GL_UNSIGNED_SHORT_5_6_5_REV (little-endian words).
        pixels = bytearray(width * height * 4)
        for i, (value,) in enumerate(struct.iter_unpack("<H", data[: width * height * 2])):
            r = (value & 0x1f) * 255 // 31
            g = ((value >> 5) & 0x3f) * 255 // 63
            b = ((value >> 11) & 0x1f) * 255 // 31
            pixels[i * 4:i * 4 + 4] = bytes((r, g, b, 255))
        image = Image.frombytes("RGBA", (width, height), bytes(pixels))
    else:
        raise ValueError(f"unsupported NUT pixel format {fmt}")
    output.parent.mkdir(parents=True, exist_ok=True)
    image.save(output)
    print(f"{path.name}: {width}x{height}, format {fmt} -> {output}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("inputs", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    for path in args.inputs:
        convert(path, args.output / (path.stem + ".png"))


if __name__ == "__main__":
    main()
