"""Cross-check serialized NUD material properties against captured shader constants."""
from __future__ import annotations
import argparse
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent

def material_properties(path: Path, prop_name: str) -> dict[str, list[float]]:
    inventory = json.loads(path.read_text(encoding="utf-8"))
    found: dict[str, list[float]] = {}
    for model in inventory.get("models", []):
        for group in model.get("groups", []):
            name = group.get("name")
            for mesh in group.get("meshes", []):
                for material in mesh.get("materials", []):
                    for prop in material.get("properties", []):
                        if prop.get("name") != prop_name:
                            continue
                        value = prop.get("values")
                        if not isinstance(name, str) or not isinstance(value, list):
                            raise ValueError(f"malformed {prop_name} record in {path}")
                        if name in found and found[name] != value:
                            raise AssertionError(f"conflicting {prop_name} values for NUD group {name}")
                        found[name] = value
    return found

def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--inventory", type=Path, default=ROOT / "captured_assets/nud_inventory.json")
    parser.add_argument("--capture-dir", type=Path, default=ROOT / "gpu_captures")
    parser.add_argument("--capture-glob", default="itachi_amaterasu_frame*.effect_coverage_reference.json")
    parser.add_argument("--pixel-hash-prefix", default="915c5e6e")
    parser.add_argument("--nud-property", default="NU_uvScaleScreen")
    parser.add_argument("--gpu-field", default="g_uvScaleScreen")
    parser.add_argument("--output", type=Path, default=ROOT / "captured_assets/procedural/nud_shader_property_crosswalk.json")
    parser.add_argument("--tolerance", type=float, default=1e-6)
    args = parser.parse_args()

    values = material_properties(args.inventory, args.nud_property)
    captures = []
    mismatches = []
    total = 0
    for capture_path in sorted(args.capture_dir.glob(args.capture_glob)):
        matched = 0
        assets: dict[str, int] = {}
        for draw in json.loads(capture_path.read_text(encoding="utf-8")):
            if not draw.get("shaders", {}).get("ShaderStage.Pixel", "").startswith(args.pixel_hash_prefix):
                continue
            asset = draw.get("base_asset")
            actual = draw["constants"]["ShaderStage.Vertex"]["perMaterialBuffer"]["fields"][args.gpu_field]["values"]
            expected = values.get(asset)
            total += 1
            matched += 1
            assets[asset] = assets.get(asset, 0) + 1
            if expected is None or len(expected) != len(actual) or any(abs(a-b) > args.tolerance for a, b in zip(expected, actual)):
                mismatches.append({"capture": capture_path.name, "event": draw["event"], "asset": asset, "nud": expected, "gpu": actual})
        if matched:
            captures.append({"capture": capture_path.name, "draw_count": matched, "assets": assets})
    if not captures:
        raise AssertionError("no matching draws found; check capture directory and pixel shader hash")
    report = {
        "inventory": str(args.inventory),
        "property_mapping": {"nud": args.nud_property, "gpu": args.gpu_field},
        "pixel_shader_hash_prefix": args.pixel_hash_prefix,
        "tolerance": args.tolerance,
        "inventory_group_values": values,
        "draw_count": total,
        "capture_count": len(captures),
        "captures": captures,
        "mismatches": mismatches,
        "finding": "serialized NUD material property values match the captured GPU constant for every selected draw" if not mismatches else "one or more selected draws differ from serialized NUD property values",
    }
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    if mismatches:
        raise AssertionError(f"{len(mismatches)} mismatches among {total} draws; report: {args.output}")
    print(f"PASS: {args.nud_property} -> {args.gpu_field}: {total} draws / {len(captures)} captures, exact within {args.tolerance:g}")
    print("Assets:", sorted({name for capture in captures for name in capture["assets"]}))
    print("WROTE:", args.output)

if __name__ == "__main__":
    main()

