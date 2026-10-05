"""Verify Amaterasu material UV scroll defaults against identified GPU draws."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent
PROC = ROOT / "captured_assets" / "procedural"
PARAM_MAP = json.loads((PROC / "4efb_amt1_native_materials.json").read_text(encoding="utf-8"))
materials = {material["name"]: material for material in PARAM_MAP["materials"]}

captures = []
total = 0
for path in sorted((ROOT / "gpu_captures").glob("itachi_amaterasu_frame*.effect_coverage_reference.json")):
    rows = []
    for draw in json.loads(path.read_text(encoding="utf-8")):
        if not draw.get("shaders", {}).get("ShaderStage.Pixel", "").startswith("915c5e6e"):
            continue
        asset = draw.get("base_asset")
        material = materials.get(asset)
        if material is None or asset not in material["textures"]:
            raise AssertionError(f"no same-name XFBIN material/texture for captured asset {asset}")
        fields = draw["constants"]["ShaderStage.Vertex"]["perMaterialBuffer"]["fields"]
        actual = fields["g_uvOffsetScreen"]["values"]
        rates = material["screen_scroll"]["binder_rates_in_native_order"]
        # A zero-rate channel is exactly zero. The three unit-rate channels
        # must share one signed-fraction phase for the material counter.
        assert abs(rates[0]) < 1e-7 and rates[1:] == [1.0, 1.0, 1.0], (asset, rates)
        assert abs(actual[0]) < 1e-7, (path.name, draw["event"], actual, rates)
        assert max(actual[1:]) - min(actual[1:]) < 1e-6, (path.name, draw["event"], actual, rates)
        rows.append({"asset": asset, "event": draw["event"], "rates": rates, "captured": actual})
    if not rows:
        continue
    total += len(rows)
    phases = [row["captured"][1] for row in rows]
    counter_modulos = {round(phase * 30000.0) % 30000 for phase in phases}
    assert len(counter_modulos) == 1, (path.name, sorted(counter_modulos))
    counter_modulo = next(iter(counter_modulos))
    assert counter_modulo % 50 == 0, (path.name, counter_modulo)
    by_asset = {}
    for row in rows:
        by_asset.setdefault(row["asset"], []).append(row)
    captures.append({"capture": path.name, "draw_count": len(rows),
      "captured_phase": phases[0], "counter_modulo_30000": counter_modulo,
      "assets": {
        name: {"draw_count": len(group), "rates": group[0]["rates"],
               "first_event": group[0]["event"], "first_captured_vector": group[0]["captured"]}
        for name, group in sorted(by_asset.items())
    }})

assert len(captures) == 7 and total == 213, (len(captures), total)
for previous, current in zip(captures, captures[1:]):
    delta = (current["counter_modulo_30000"] - previous["counter_modulo_30000"]) % 30000
    assert delta % 50 == 0, (previous, current, delta)
    current["phase_delta_ticks_mod_30000"] = delta
    current["equivalent_50_tick_updates"] = delta // 50
report = {
    "scope": "captured pixel shader 915c5e6e draws, identified by first texture SHA256 and same-name material in 4efb_amt1.xfbin",
    "draw_total": total,
    "captures": captures,
    "material_animation_scope": "4efb_amt1 ANM targets type-4 material 4efb_amt15 only; the principal amt00/amt01 billboard materials are not material-ANM targets in this file.",
    "finding": "All 213 draws use base assets 4efb_amt00/4efb_amt01. Both corresponding XFBIN materials decode to binder rates (0,1,1,1), matching every captured g_uvOffsetScreen vector shape (0,t,t,t). Since the rate-one channels expose the signed-fraction clock directly, each capture recovers counter modulo 30000; all seven phases align to 50-tick scheduler increments.",
    "open": "The NUD source of g_uvScaleScreen is confirmed; the exact native copy site and unwrapped counter origin remain open.",
}
out = PROC / "native_material_scroll_capture_audit.json"
out.write_text(json.dumps(report, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
print(f"PASS: {total} draws / {len(captures)} captures inspected")
print("Assets:", sorted({asset for capture in captures for asset in capture["assets"]}))
print("First capture:", captures[0])
print("Recovered counter modulo 30000:", [(x["capture"].split("frame")[1].split(".")[0], x["counter_modulo_30000"]) for x in captures])
print("LIMIT: exact NUD-property copy site and unwrapped counter origin remain unresolved")
print(f"WROTE: {out}")

