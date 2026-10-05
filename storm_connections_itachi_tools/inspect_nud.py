"""Decode NUD mesh and render-state headers from an effect XFBIN."""

from __future__ import annotations

import argparse
import json
import struct
from pathlib import Path

from xfbin_chunks import parse


def cstring(data: bytes, offset: int) -> str:
    if not 0 <= offset < len(data):
        return f"<out-of-range:{offset}>"
    end = data.find(b"\0", offset)
    return data[offset:end if end >= 0 else None].decode("cp932", "replace")


def parse_nud(data: bytes) -> dict:
    if data[:4] != b"NDP3":
        raise ValueError("not NDP3")
    file_size, version, group_count, bone_start, bone_end = struct.unpack_from(">I4H", data, 4)
    if file_size > len(data):
        raise ValueError("NUD exceeds chunk")
    poly_relative, poly_size, vert_size, vert_extra_size = struct.unpack_from(">4I", data, 16)
    poly_base = 0x30 + poly_relative
    vert_base = poly_base + poly_size
    extra_base = vert_base + vert_size
    name_base = extra_base + vert_extra_size
    groups = []
    group_offset = 0x30
    for group_i in range(group_count):
        sphere = struct.unpack_from(">8f", data, group_offset)
        name_offset = struct.unpack_from(">I", data, group_offset + 32)[0]
        unknown, bone_flags, single_bind, mesh_count = struct.unpack_from(">4H", data, group_offset + 36)
        positionb = struct.unpack_from(">I", data, group_offset + 44)[0]
        group = {"name": cstring(data, name_base + name_offset), "sphere": sphere,
                 "bone_flags": bone_flags, "single_bind": single_bind,
                 "positionb": positionb, "meshes": []}
        groups.append((group, mesh_count))
        group_offset += 0x30
    mesh_offset = group_offset
    for group, mesh_count in groups:
        for _ in range(mesh_count):
            poly_rel, vert_rel, extra_rel, vertex_count, vertex_size, uv_size = struct.unpack_from(">3IHBB", data, mesh_offset)
            mat_offsets = struct.unpack_from(">4I", data, mesh_offset + 16)
            face_count, face_size, face_flag = struct.unpack_from(">HBB", data, mesh_offset + 32)
            mesh = {"vertex_count": vertex_count, "vertex_size": vertex_size,
                    "uv_size": uv_size, "face_count": face_count,
                    "face_size": face_size, "face_flag": face_flag,
                    "poly_offset": poly_base + poly_rel,
                    "vertex_offset": vert_base + vert_rel,
                    "extra_offset": extra_base + extra_rel,
                    "materials": []}
            for material_offset in mat_offsets:
                if not material_offset:
                    continue
                flags, zero, src, texture_count, dst, alpha_test, alpha_func, ref_alpha, cull = struct.unpack_from(">IIHHHBBHH", data, material_offset)
                unknown1, unknown2, z_offset = struct.unpack_from(">ffi", data, material_offset + 20)
                textures = []
                pos = material_offset + 32
                for _ in range(texture_count):
                    # Sampler bytes as the game's material builder reads them (0x141270830):
                    # +0xC / +0xD / +0xE wrap codes of the three axes, +0xF magnify and +0x10
                    # minify filter codes, low 13 bits of the dword at +0x14 the LOD bias
                    # (shader_port.py: NUD_ADDRESS_MODE, nud_filter, nud_lod_bias).
                    unk0, unused, unused2, map_mode, wrap_s, wrap_t, wrap_r, mag_filter, min_filter, unk1, unused3, lod_high, lod_field = struct.unpack_from(">iIHH6BHHH", data, pos)
                    textures.append({"unk0": unk0, "map_mode": map_mode,
                                     "wrap_s": wrap_s, "wrap_t": wrap_t, "wrap_r": wrap_r,
                                     "mag_filter": mag_filter, "min_filter": min_filter,
                                     "unk1": unk1, "lod_field": lod_field})
                    pos += 24
                properties = []
                for _ in range(128):
                    att_size, prop_name_offset = struct.unpack_from(">II", data, pos)
                    value_count = data[pos + 11]
                    if value_count > 4:
                        raise ValueError("invalid NUD property value count")
                    values = struct.unpack_from(">" + "f" * value_count, data, pos + 16)
                    properties.append({"name": cstring(data, name_base + prop_name_offset) if prop_name_offset else "",
                                       "values": values})
                    if att_size == 0:
                        break
                    pos += att_size
                else:
                    raise ValueError("too many NUD properties")
                mesh["materials"].append({"flags": flags, "source_factor": src,
                                          "dest_factor": dst, "alpha_test": alpha_test,
                                          "alpha_function": alpha_func, "ref_alpha": ref_alpha,
                                          "cull_mode": cull, "z_buffer_offset": z_offset,
                                          "unknown1": unknown1, "unknown2": unknown2,
                                          "textures": textures, "properties": properties})
            group["meshes"].append(mesh)
            mesh_offset += 0x30
    return {"file_size": file_size, "version": version,
            "bone_start": bone_start, "bone_end": bone_end,
            "poly_base": poly_base, "vert_base": vert_base,
            "extra_base": extra_base, "name_base": name_base,
            "groups": [g for g, _ in groups]}


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("xfbin", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--name", default="", help="Comma-separated exact model names")
    args = parser.parse_args()
    data, chunks = parse(args.xfbin)
    models = []
    for c in chunks:
        if c["type"] != "nuccChunkModel" or (args.name and c["name"] not in args.name.split(",")):
            continue
        body = data[c["offset"]:c["offset"] + c["size"]]
        nud_start = body.find(b"NDP3")
        if nud_start < 0:
            raise ValueError(f"{c['name']} lacks NDP3")
        model = parse_nud(body[nud_start:])
        model["name"] = c["name"]
        model["model_flags"] = list(body[4:8])
        models.append(model)
    result = {"source": str(args.xfbin), "models": models}
    encoded = json.dumps(result, indent=2, ensure_ascii=False)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(encoded + "\n", encoding="utf-8")
    else:
        print(encoded)
    print(f"Parsed {len(models)} models, {sum(len(g['meshes']) for m in models for g in m['groups'])} meshes")
