"""Check the staged VTF headers and exact decoded pixel bytes."""

from pathlib import Path
import struct

from PIL import Image


ROOT = Path(__file__).resolve().parent
VTF_DIR = ROOT / "source_textures"
files = sorted(VTF_DIR.glob("*.vtf"))
assert len(files) == 15, len(files)
for path in files:
    data = path.read_bytes()
    assert data[:4] == b"VTF\0", path
    assert struct.unpack_from("<III", data, 4) == (7, 2, 80), path
    width, height = struct.unpack_from("<HH", data, 16)
    folder = "system" if path.stem == "celshade" else ("1efcmn" if path.stem.startswith("1efc") else "")
    preview = ROOT / "preview" / folder / (path.stem + ".png")
    with Image.open(preview) as image:
        rgba = image.convert("RGBA")
        assert rgba.size == (width, height), path
        assert data[80:] == rgba.tobytes(), path
print(f"Verified {len(files)} VTF images and their lossless pixel payloads")
