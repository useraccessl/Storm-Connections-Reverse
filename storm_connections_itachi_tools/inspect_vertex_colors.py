"""Extract original NUD vertex RGBA bytes for the Amaterasu meshes."""

from collections import Counter
import json
from pathlib import Path

from xfbin_chunks import parse
from inspect_nud import parse_nud


root = Path(__file__).resolve().parent
result = {}
for archive in (root / "extracted/data/effect/2efb_amt.xfbin",
                root / "extracted/data/effect/1efcmn.xfbin"):
    if not archive.exists():
        continue
    data, chunks = parse(archive)
    for chunk in chunks:
        if chunk["type"] not in ("nuccChunkModel", "nuccChunkModelVertex"):
            continue
        name = chunk["name"]
        if not (name.startswith("2efb_amt") or name in ("1efc_ring09", "1efc_ring13")):
            continue
        body = data[chunk["offset"]:chunk["offset"] + chunk["size"]]
        nud = body[body.index(b"NDP3"):]
        model = parse_nud(nud)
        colors = []
        for group in model["groups"]:
            for mesh in group["meshes"]:
                vtype = mesh["vertex_size"] & 15
                bone = mesh["vertex_size"] & 0xf0
                if bone == 0x10 and vtype == 1:
                    color_offset = mesh["vertex_offset"]
                    stride = 4 + (mesh["uv_size"] >> 4) * 4
                elif mesh["uv_size"] >= 18:
                    color_offset = mesh["vertex_offset"] + 12 + (4 if vtype == 0 else 8)
                    stride = 12 + (4 if vtype == 0 else 8) + 4 + (mesh["uv_size"] >> 4) * 4
                else:
                    colors.extend([[255, 255, 255, 255]] * mesh["vertex_count"])
                    continue
                for i in range(mesh["vertex_count"]):
                    rgba = nud[color_offset + i * stride:color_offset + i * stride + 4]
                    if len(rgba) != 4:
                        raise ValueError(f"short vertex color in {name}")
                    colors.append(list(rgba))
        result[name] = colors
        print(name, len(colors), Counter(tuple(c) for c in colors).most_common(6))

output = root / "vertex_colors.json"
output.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
print("Wrote", output)
