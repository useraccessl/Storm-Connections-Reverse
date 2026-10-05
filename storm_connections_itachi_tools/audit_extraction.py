"""Cross-check that every original Amaterasu asset reference is accounted for."""

import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent
materials = json.loads((ROOT / "materials.json").read_text(encoding="utf-8"))["materials"]
materials += json.loads((ROOT / "common_ring_materials.json").read_text(encoding="utf-8"))["materials"]
models = json.loads((ROOT / "nud_inventory.json").read_text(encoding="utf-8"))["models"]
models += json.loads((ROOT / "common_ring_nud.json").read_text(encoding="utf-8"))["models"]
shaders = json.loads((ROOT / "used_shaders/manifest.json").read_text(encoding="utf-8"))
particle = json.loads((ROOT / "particle_inventory.json").read_text(encoding="utf-8"))
material_names = {m["name"] for m in materials}
model_names = {m["name"].removesuffix("_base") for m in models}
assert material_names == model_names, (material_names - model_names, model_names - material_names)
needed = {ref["name"] for mat in materials for group in mat["texture_groups"]
          for ref in group["textures"] if ref["name"]}
available = {p.stem for p in (ROOT / "source_textures").glob("*.vtf")}
assert needed <= available, sorted(needed - available)
keys = {f"0x{mat['flags']:06x}" for model in models for group in model["groups"]
        for mesh in group["meshes"] for mat in mesh["materials"]}
shader_keys = {s["key"] for s in shaders}
assert keys == shader_keys, (keys - shader_keys, shader_keys - keys)
obj = {p.stem for p in (ROOT / "geometry_obj").glob("*.obj")}
assert {m["name"] for m in models} <= obj
assert {"2efb_amt13_target01", "2efb_amt13_target02"} <= obj
assert len(particle) == 2
graph = json.loads((ROOT / "particle_graph.json").read_text(encoding="utf-8"))
assert [len(x["emitters"]) for x in graph] == [8, 5]
typed = json.loads((ROOT / "particle_records_typed.json").read_text(encoding="utf-8"))
assert [len(x["sections"][0]["records"]) for x in typed] == [8, 5]
billboards = json.loads((ROOT / "billboard_arrays.json").read_text(encoding="utf-8"))
assert len(billboards) == 14
for billboard in billboards:
    assert sum(a["width"] * a["count"] for a in billboard["arrays"]) + 16 == billboard["size"]
print(f"Audit passed: {len(models)} models, {len(needed)} unique textures, {len(shaders)} shader pairs, {len(obj)} OBJ meshes, {len(particle)} particle chunks, {len(billboards)} billboards")
