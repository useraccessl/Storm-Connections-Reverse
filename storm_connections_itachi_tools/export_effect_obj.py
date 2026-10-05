"""Export static Amaterasu NUD meshes as OBJ for geometry inspection."""

from __future__ import annotations

import json
import struct
import argparse
from pathlib import Path

from xfbin_chunks import parse
from inspect_nud import parse_nud


ROOT = Path(__file__).resolve().parent
XFBIN = ROOT / "extracted/data/effect/2efb_amt.xfbin"
INVENTORY = ROOT / "nud_inventory.json"
OUTPUT = ROOT / "geometry_obj"


def get_vertices(nud: bytes, mesh: dict) -> list[tuple[float, float, float, float, float]]:
    vtype = mesh["vertex_size"] & 0x0f
    bone = mesh["vertex_size"] & 0xf0
    uv_count = mesh["uv_size"] >> 4
    if bone == 0x10 and vtype == 1:
        aux = mesh["vertex_offset"]
        pos = mesh["extra_offset"]
        out = []
        for _ in range(mesh["vertex_count"]):
            x, y, z = struct.unpack_from(">3f", nud, pos)
            pos += 64  # position, normal, bone IDs, bone weights
            aux += 4  # vertex color
            u, v = struct.unpack_from(">2e", nud, aux)
            aux += uv_count * 4
            out.append((x, y, z, u, v))
        return out
    if bone:
        raise ValueError(f"unsupported skinning mode {bone:#x}/{vtype}")
    if vtype not in (0, 6) or uv_count < 1:
        raise ValueError(f"unsupported vertex type {vtype} uv_count {uv_count}")
    pos = mesh["vertex_offset"]
    out = []
    for _ in range(mesh["vertex_count"]):
        x, y, z = struct.unpack_from(">3f", nud, pos)
        pos += 12
        if vtype == 0:
            pos += 4
        elif vtype == 6:
            pos += 8
        if mesh["uv_size"] >= 18:
            pos += 4  # RGBA vertex color
        u, v = struct.unpack_from(">2e", nud, pos)
        pos += uv_count * 4
        out.append((x, y, z, u, v))
    return out


def triangles(strip: tuple[int, ...], vertex_count: int):
    current = []
    flip = False
    for value in strip:
        if value < 0:
            current.clear()
            flip = False
            continue
        if value >= vertex_count:
            raise ValueError(f"face index {value} >= {vertex_count}")
        current.append(value)
        if len(current) < 3:
            continue
        a, b, c = current[-3:]
        if not flip:
            b, c = c, b
        flip = not flip
        if len({a, b, c}) == 3:
            yield a, b, c


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--xfbin", type=Path, default=XFBIN)
    ap.add_argument("--inventory", type=Path, default=INVENTORY)
    ap.add_argument("--output", type=Path, default=OUTPUT)
    args = ap.parse_args()
    data, chunks = parse(args.xfbin)
    inventory = json.loads(args.inventory.read_text(encoding="utf-8"))
    by_name = {m["name"]: m for m in inventory["models"]}
    args.output.mkdir(parents=True, exist_ok=True)
    for chunk in chunks:
        if chunk["type"] not in ("nuccChunkModel", "nuccChunkModelVertex"):
            continue
        if chunk["type"] == "nuccChunkModel" and chunk["name"] not in by_name:
            continue
        if chunk["type"] == "nuccChunkModelVertex" and not chunk["name"].startswith("2efb_amt13_target"):
            continue
        body = data[chunk["offset"]:chunk["offset"] + chunk["size"]]
        nud = body[body.index(b"NDP3"):]
        model = by_name[chunk["name"]] if chunk["type"] == "nuccChunkModel" else parse_nud(nud)
        lines = [f"# Original STORM CONNECTIONS NUD geometry: {chunk['name']}"]
        vertex_base = 0
        face_total = 0
        try:
            for group in model["groups"]:
                for mesh in group["meshes"]:
                    verts = get_vertices(nud, mesh)
                    strip = struct.unpack_from(">" + "h" * mesh["face_count"], nud, mesh["poly_offset"])
                    lines.append(f"o {group['name']}")
                    for x, y, z, u, v in verts:
                        lines.append(f"v {x:.9g} {y:.9g} {z:.9g}")
                    for x, y, z, u, v in verts:
                        lines.append(f"vt {u:.9g} {1-v:.9g}")
                    for a, b, c in triangles(strip, len(verts)):
                        indices = [i + vertex_base + 1 for i in (a, b, c)]
                        lines.append("f " + " ".join(f"{i}/{i}" for i in indices))
                        face_total += 1
                    vertex_base += len(verts)
        except ValueError as exc:
            print(f"SKIP {chunk['name']}: {exc}")
            continue
        (args.output / f"{chunk['name']}.obj").write_text("\n".join(lines) + "\n", encoding="utf-8")
        print(f"{chunk['name']}: {vertex_base} vertices, {face_total} triangles")


if __name__ == "__main__":
    main()
