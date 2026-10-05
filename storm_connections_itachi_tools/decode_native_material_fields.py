"""Map NUCC material format payloads to native parser/runtime shader fields.

The field destinations are taken from NSUNSC.exe's nuccChunkMaterial reader
and runtime material constructor, not inferred from float patterns.
"""
from __future__ import annotations

import json
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "materials.json"
OUTPUT = ROOT / "captured_assets" / "procedural" / "native_material_parameter_map.json"

# Native parser 0x14134cde0 consumes format groups in this order and writes
# each 16-byte payload to the listed pairs in its parsed resource object.
FORMAT_BLOCKS = (
    (0x01, (0x28, 0x2C, 0x48, 0x4C)),
    (0x02, (0x30, 0x34, 0x50, 0x54)),
    (0x04, (0x38, 0x3C, 0x58, 0x5C)),
    (0x08, (0x40, 0x44, 0x60, 0x64)),
    (0x10, (0x68, 0x6C)),
    (0x20, (0x74,)),
    (0x40, (0x78,)),
    (0x80, (0x7C,)),
)

# Runtime constructor 0x1412f5920 copies these source pairs to the live
# material instance. Offsets are bytes, relative to their respective object.
SOURCE_TO_RUNTIME = {
    0x28: 0x30, 0x2C: 0x34,
    0x30: 0x38, 0x34: 0x3C,
    0x38: 0x40, 0x3C: 0x44,
    0x40: 0x48, 0x44: 0x4C,
    0x48: 0x50, 0x4C: 0x54,
    0x50: 0x58, 0x54: 0x5C,
    0x58: 0x60, 0x5C: 0x64,
    0x60: 0x68, 0x64: 0x6C,
    0x68: 0x70, 0x6C: 0x74,
    0x74: 0x78, 0x78: 0x84, 0x7C: 0x88,
}

SEMANTICS = {
    0x30: "UV0_offset.x", 0x34: "UV0_offset.y",
    0x38: "UV1_offset.x", 0x3C: "UV1_offset.y",
    0x40: "UV2_offset.x", 0x44: "UV2_offset.y",
    0x48: "UV3_offset.x", 0x4C: "UV3_offset.y",
    0x50: "UV0_scale.x", 0x54: "UV0_scale.y",
    0x58: "UV1_scale.x", 0x5C: "UV1_scale.y",
    0x60: "UV2_scale.x", 0x64: "UV2_scale.y",
    0x68: "UV3_scale.x", 0x6C: "UV3_scale.y",
    0x70: "blendRate.x", 0x74: "blendRate.y",
    0x78: "conditional_override_UV2.x",
    0x84: "material_parameter_divided_by_255",
    0x88: "opaque_material_word",
}


def decode(fmt: int, packed: list[float]) -> dict[int, float]:
    result: dict[int, float] = {}
    cursor = 0
    for bit, offsets in FORMAT_BLOCKS:
        if fmt & bit:
            count = len(offsets)
            if cursor + count > len(packed):
                raise ValueError(f"format 0x{fmt:02x}: truncated block 0x{bit:02x}")
            result.update(zip(offsets, packed[cursor:cursor + count]))
            cursor += count
    if cursor != len(packed):
        raise ValueError(f"format 0x{fmt:02x}: consumed {cursor}/{len(packed)} floats")
    return result


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--materials", type=Path, default=SOURCE,
                        help="analyze_effect.py JSON for any extracted NUCC effect")
    parser.add_argument("--output", type=Path, default=OUTPUT)
    args = parser.parse_args()
    source_path = args.materials.resolve()
    output_path = args.output.resolve()
    source = json.loads(source_path.read_text(encoding="utf-8"))
    materials = []
    for material in source["materials"]:
        source_fields = decode(material["format"], material["floats"])
        fields = []
        for source_offset, value in sorted(source_fields.items()):
            runtime_offset = SOURCE_TO_RUNTIME[source_offset]
            fields.append({
                "source_object_offset": f"0x{source_offset:02x}",
                "runtime_material_offset": f"0x{runtime_offset:02x}",
                "semantic": SEMANTICS[runtime_offset],
                "value": value,
            })
        by_runtime = {int(field["runtime_material_offset"], 16): field["value"] for field in fields}
        scroll = {
            "uv2_scale": [by_runtime.get(0x60), by_runtime.get(0x64)],
            "uv3_scale": [by_runtime.get(0x68), by_runtime.get(0x6C)],
            "binder_rates_in_native_order": [
                by_runtime.get(0x60), by_runtime.get(0x64),
                by_runtime.get(0x68), by_runtime.get(0x6C),
            ],
        }
        materials.append({
            "name": material["name"],
            "format": material["format"],
            "format_hex": f"0x{material['format']:02x}",
            "serialized_floats": material["floats"],
            "native_fields": fields,
            "screen_scroll": scroll,
            "textures": [
                texture["name"]
                for group in material["texture_groups"]
                for texture in group["textures"]
            ],
        })

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps({
        "source": source.get("source", str(source_path)),
        "native_source_executable_sha256": "cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e",
        "evidence": {
            "format_reader_va": "0x14134cde0",
            "runtime_material_constructor_va": "0x1412f5920",
            "screen_scroll_binder_va": "0x1412f5ff0",
            "float_group_order": ["0x01", "0x02", "0x04", "0x08", "0x10", "0x20", "0x40", "0x80"],
            "verified_material_count": len(materials),
        },
        "materials": materials,
    }, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"PASS: decoded {len(materials)} native material records; all serialized floats consumed exactly")
    for material in materials:
        if material["name"] in {"2efb_amt00", "2efb_amt08", "2efb_amt18"}:
            print(material["name"], material["screen_scroll"]["binder_rates_in_native_order"])
    print(f"WROTE: {output_path}")


if __name__ == "__main__":
    main()
