"""Rewrap a NUT texture as a Source VTF 7.2.

Block-compressed textures (NUT formats 0 / 1 / 2 = BC1 / BC2 / BC3) keep their
original blocks: no recompression. The uncompressed formats are stored
big-endian in the NUT and rewritten as 32-bit BGRA:

  6   A1R5G5B5, 16 bits   round(v * 255 / 31), alpha 255 or 0 from bit 15: within
                          0.2 % of the 16-bit value, not exact
  7   A4R4G4B4, 16 bits   each nibble * 17 (exact: n / 15 = n * 17 / 255)
  8   R5G6B5, 16 bits     round(v * 255 / 31), round(v * 255 / 63): within
                          0.2 % of the 16-bit value, not exact
  14  X8R8G8B8, 32 bits   bytes X, R, G, B in the file; alpha forced to 255
  17  A8R8G8B8, 32 bits   bytes A, R, G, B in the file

The channel layouts were identified on the game's own textures (the toon ramp
celshade and the substitution scroll for format 8, a leaf for 14); no other
layout gives a plausible image. Format 6 was identified on 3nrvbody, whose second
image is the same picture in DXT5: this layout correlates at 0.9998 with it on each
channel and its alpha bit equals the DXT5 alpha on every pixel.

Mip levels. The NUT lists the size of each level at 0x40 (one level: the data
size at 0x18); a level is padded to 16 bytes in the file. Which level the game
reads is the sampler's business (LOD bias and filter come from the NUD material,
see shader_port.nud_lod_bias), so two VTFs can be written:

  convert(source, target)                level 0 alone, for the samplers that never
                                         leave it
  convert(source, target, mipped=True)   every level of the NUT. A VTF holds the whole
                                         chain down to 1x1, so the levels the NUT does
                                         not have are written as zeros: the translated
                                         shader clamps its level of detail to the last
                                         level of the NUT and never reads them.
"""
import struct
from pathlib import Path

import numpy as np

BLOCK = {0: (13, 8), 1: (14, 16), 2: (15, 16)}      # NUT format -> (VTF image format, bytes per 4x4 block)
BGRA8888 = 12
POINTSAMPLE, TRILINEAR, CLAMPS, CLAMPT, NOLOD, EIGHTBITALPHA = 0x1, 0x2, 0x4, 0x8, 0x200, 0x2000


def level_bytes(fmt: int, width: int, height: int) -> int:
    """Size of one level in the NUT."""
    if fmt in BLOCK:
        return ((width + 3) // 4) * ((height + 3) // 4) * BLOCK[fmt][1]
    if fmt in (6, 7, 8):
        return width * height * 2
    if fmt in (14, 17):
        return width * height * 4
    raise ValueError(f'NUT pixel format {fmt}')


def level_payload(fmt: int, raw: bytes) -> bytes:
    """One NUT level as the VTF stores it."""
    if fmt in BLOCK:
        return raw
    if fmt in (6, 7, 8):
        pixels = np.frombuffer(raw, dtype='>u2').astype(np.uint32)
        if fmt == 6:
            r, g, b = ((pixels >> shift) & 31 for shift in (10, 5, 0))
            channels = [(b * 255 + 15) // 31, (g * 255 + 15) // 31, (r * 255 + 15) // 31, ((pixels >> 15) & 1) * 255]
        elif fmt == 7:
            a, r, g, b = ((pixels >> shift) & 15 for shift in (12, 8, 4, 0))
            channels = [b * 17, g * 17, r * 17, a * 17]
        else:
            r, g, b = (pixels >> 11) & 31, (pixels >> 5) & 63, pixels & 31
            channels = [(b * 255 + 15) // 31, (g * 255 + 31) // 63, (r * 255 + 15) // 31, np.full(pixels.shape, 255, dtype=np.uint32)]
        return np.stack(channels, axis=1).astype(np.uint8).tobytes()
    pixels = np.frombuffer(raw, dtype=np.uint8).reshape(-1, 4)
    alpha = pixels[:, 0] if fmt == 17 else np.full(len(pixels), 255, dtype=np.uint8)
    return np.stack([pixels[:, 3], pixels[:, 2], pixels[:, 1], alpha], axis=1).tobytes()


def read(source: Path, image: int = 0) -> dict:
    """Header and levels of one image of a NUT: {'width', 'height', 'format', 'levels',
    'images'}, levels being the raw bytes of each level the image has, largest first,
    and images the number of images in the file.

    A NUT can hold several images one after the other, each with its own header (its
    first word is the size of header and data). They are colour variants of one
    picture (same size and layout, other colours). The texture chunk loader 0x141339b00
    registers image i under the chunk's texture id + i (0x14123f040); a lookup adds the
    per-thread offset TLS[0x32c8] to ids up to 0x0FFFFFFF (0x14123e7f0), and the model
    draw sets that offset from the model's colour byte (+0xD0) only when its header
    flag 0x80 is set (0x1412d1870), a byte its constructors set to 0. Trails add
    their image index (+0x1DC, -1 from the nuccTrailBase constructor 0x141323330: image 0). So image
    0 is the one the game binds unless a colour index is set at run time."""
    nut = source.read_bytes()
    if nut[:4] != b'NTP3':
        raise ValueError(f'not a NTP3 texture ({nut[:4]!r})')
    images = struct.unpack_from('>H', nut, 6)[0]
    if not 0 <= image < images:
        raise ValueError(f'image {image} of a NUT with {images}')
    at = 0x10
    for _ in range(image):
        at += struct.unpack_from('>I', nut, at)[0]
    count, fmt = nut[at + 0x11], nut[at + 0x13]
    width, height = struct.unpack_from('>HH', nut, at + 0x14)
    if struct.unpack_from('>I', nut, at + 0x1c)[0]:
        raise ValueError('cube map')
    if width <= 0 or height <= 0 or width & (width - 1) or height & (height - 1):
        raise ValueError(f'{width}x{height} is not a power of two (VTF requires it)')
    start = at + struct.unpack_from('>H', nut, at + 0xc)[0]
    stored = struct.unpack_from(f'>{count}I', nut, at + 0x30) if count > 1 else (struct.unpack_from('>I', nut, at + 8)[0],)
    levels = []
    for index in range(max(count, 1)):
        size = level_bytes(fmt, max(width >> index, 1), max(height >> index, 1))
        if size > stored[index] or len(nut) < start + size:
            raise ValueError('truncated NUT payload')
        levels.append(nut[start:start + size])
        start += stored[index]
    return {'width': width, 'height': height, 'format': fmt, 'levels': levels, 'images': images}


def convert(source: Path, target: Path, mipped: bool = False):
    """VTF of image 0 of a NUT (read)."""
    nut = read(source)
    fmt, width, height = nut['format'], nut['width'], nut['height']
    image_format = BLOCK[fmt][0] if fmt in BLOCK else BGRA8888
    levels = [level_payload(fmt, raw) for raw in nut['levels']]
    flags = EIGHTBITALPHA
    if mipped:
        chain = max(width, height).bit_length()
        for index in range(len(levels), chain):
            w, h = max(width >> index, 1), max(height >> index, 1)
            levels.append(bytes(level_bytes(fmt, w, h) if fmt in BLOCK else w * h * 4))
        # All levels at full resolution whatever the texture quality setting, blended
        # between levels as the game's linear mip filter does.
        flags |= NOLOD | TRILINEAR
    else:
        levels = levels[:1]
    header = bytearray(80)
    header[:4] = b'VTF\0'
    # Clamp and point sampling are a material choice (flag variants written by the importer).
    struct.pack_into('<IIIHHIHH', header, 4, 7, 2, 80, width, height, flags, 1, 0)
    struct.pack_into('<f', header, 48, 1.0)
    struct.pack_into('<I', header, 52, image_format)
    header[56] = len(levels)
    struct.pack_into('<I', header, 57, 0xffffffff)
    struct.pack_into('<H', header, 63, 1)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(bytes(header) + b''.join(reversed(levels)))        # a VTF stores the smallest level first
    return {'width': width, 'height': height, 'format': fmt, 'payloadBytes': sum(len(level) for level in levels),
            'recompressed': False, 'exact': fmt not in (6, 8), 'levels': len(nut['levels']), 'images': nut['images']}
