"""Load raw texture dumps written by rd_export_textures.py as numpy arrays."""

from __future__ import annotations

import json
from pathlib import Path

import numpy as np

DTYPES = {('UNorm', 1): np.uint8, ('UNormSRGB', 1): np.uint8, ('Float', 2): np.float16,
          ('Float', 4): np.float32, ('UInt', 1): np.uint8, ('UNorm', 2): np.uint16,
          ('Depth', 4): np.float32, ('Typeless', 1): np.uint8, ('Typeless', 4): np.float32}


def manifest(directory: Path) -> list[dict]:
    return json.loads((Path(directory) / 'manifest.json').read_text(encoding='utf-8'))


def load(directory: Path, entry: dict) -> np.ndarray:
    """Array of shape (height, width, components) as float32 in native units."""
    raw = (Path(directory) / entry['file']).read_bytes()
    kind = entry['comp_type'].split('.')[-1]
    count, width, height = entry['comp_count'], entry['width'], entry['height']
    per_pixel = len(raw) // (width * height)
    dtype = DTYPES.get((kind, entry['comp_bytes']))
    if dtype is None or per_pixel != count * entry['comp_bytes']:
        # Packed or depth formats: expose the raw bytes per pixel.
        return np.frombuffer(raw, dtype=np.uint8).reshape(height, width, per_pixel)
    data = np.frombuffer(raw, dtype=dtype).reshape(height, width, count).astype(np.float32)
    if dtype == np.uint8:
        data /= 255.0
    elif dtype == np.uint16:
        data /= 65535.0
    if 'B8G8R8' in entry['format'] or entry['format'].startswith('B'):
        data = data[..., [2, 1, 0] + list(range(3, count))]
    return data


def find(entries: list[dict], tag: str, label: str) -> dict:
    return next(e for e in entries if e['tag'] == tag and e['label'] == label)
