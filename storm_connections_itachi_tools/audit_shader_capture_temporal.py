"""Summarize temporal/per-draw fields for a selected captured Storm shader."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parent
CAPTURES = ROOT / "gpu_captures"
PROCEDURAL = ROOT / "captured_assets" / "procedural"
PIXEL_SHADER_PREFIX = "915c5e6e"
FIELD_NAMES = (
    "g_matWorldViewProj",
    "g_blendType",
    "g_uvScaleScreen",
    "g_uvOffsetScreen",
    "g_uvOffset0",
    "g_multColor",
)

def normalized(values):
    return tuple(round(float(value), 6) for value in values)

result = {
    "shader_pixel_hash_prefix": PIXEL_SHADER_PREFIX,
    "scope": "captured principal Amaterasu shader draws only; values rounded to 1e-6 for grouping",
    "frames": [],
}
aggregate = {name: set() for name in FIELD_NAMES}
draw_total = 0
for path in sorted(CAPTURES.glob("itachi_amaterasu_frame*.all_draws.json")):
    draws = json.loads(path.read_text(encoding="utf-8"))
    frame_draws = []
    for draw in draws:
        if not draw.get("shaders", {}).get("ShaderStage.Pixel", "").startswith(PIXEL_SHADER_PREFIX):
            continue
        fields = draw.get("constants", {}).get("ShaderStage.Vertex", {}).get("perMaterialBuffer", {}).get("fields", {})
        selected = {name: normalized(fields[name]["values"]) for name in FIELD_NAMES if name in fields}
        for name, value in selected.items():
            aggregate[name].add(value)
        frame_draws.append({"event": draw["event"], "fields": selected})
    if not frame_draws:
        continue
    draw_total += len(frame_draws)
    names = set.intersection(*(set(row["fields"]) for row in frame_draws))
    result["frames"].append({
        "capture": path.name,
        "draw_count": len(frame_draws),
        "per_frame_fields": {
            name: {
                "unique_value_count": len({row["fields"][name] for row in frame_draws}),
                "shared_value": list(frame_draws[0]["fields"][name]) if len({row["fields"][name] for row in frame_draws}) == 1 else None,
            }
            for name in sorted(names)
        },
    })
result["draw_total"] = draw_total
result["aggregate_fields"] = {
    name: {
        "unique_value_count": len(values),
        "single_shared_value": list(next(iter(values))) if len(values) == 1 else None,
    }
    for name, values in aggregate.items()
}
if len(result["frames"]) != 7 or draw_total != 213:
    raise SystemExit(f"Unexpected capture coverage: {len(result['frames'])} frames, {draw_total} draws")
out = PROCEDURAL / "amaterasu_shader_temporal_audit.json"
out.write_text(json.dumps(result, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"PASS: {len(result['frames'])} captures / {draw_total} shader draws -> {out}")
for name, item in result["aggregate_fields"].items():
    print(f"{name}: {item['unique_value_count']} unique values; shared={item['single_shared_value']}")
