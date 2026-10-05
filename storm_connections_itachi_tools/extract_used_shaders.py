"""Match NUD material flag keys to NUP4 DXBC pairs and disassemble them."""

from __future__ import annotations

import json
import struct
from pathlib import Path

from disassemble_dxbc import disassemble
from inspect_nsh import shaders


ROOT = Path(__file__).resolve().parent
GAME = Path(r"C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS")
NSH = GAME / "data/system/nuccMaterial_dx11.nsh"
COMPILER = GAME / "d3dcompiler_47.dll"
OUTPUT = ROOT / "used_shaders"


def main() -> None:
    model_data = json.loads((ROOT / "nud_inventory.json").read_text(encoding="utf-8"))
    ring_data = json.loads((ROOT / "common_ring_nud.json").read_text(encoding="utf-8"))
    wanted: dict[int, set[str]] = {}
    for model in model_data["models"] + ring_data["models"]:
        for group in model["groups"]:
            for mesh in group["meshes"]:
                for mat in mesh["materials"]:
                    wanted.setdefault(mat["flags"], set()).add(model["name"])
    data = NSH.read_bytes()
    programs = shaders(NSH)
    if len(programs) % 2:
        raise ValueError("unpaired shaders")
    OUTPUT.mkdir(parents=True, exist_ok=True)
    manifest = []
    for pair_index in range(len(programs) // 2):
        vs, ps = programs[pair_index * 2:pair_index * 2 + 2]
        key = struct.unpack_from("<I", data, vs["offset"] - 8)[0]
        if key not in wanted:
            continue
        record = {"key": f"0x{key:06x}", "pair_index": pair_index,
                  "models": sorted(wanted[key]), "programs": []}
        for stage, program in (("vs", vs), ("ps", ps)):
            start = program["offset"]
            bytecode = data[start:start + program["size"]]
            stem = f"{key:06x}_{stage}"
            (OUTPUT / f"{stem}.dxbc").write_bytes(bytecode)
            text = disassemble(bytecode, COMPILER)
            (OUTPUT / f"{stem}.asm").write_text(text, encoding="utf-8")
            if f"{stage}_4_0" not in text:
                raise ValueError(f"unexpected shader stage for {stem}")
            record["programs"].append({"stage": stage, "offset": start, "size": len(bytecode)})
        manifest.append(record)
    missing = wanted.keys() - {int(x["key"], 16) for x in manifest}
    if missing:
        raise ValueError(f"missing shader keys: {list(map(hex, missing))}")
    (OUTPUT / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    for item in manifest:
        print(item["key"], "pair", item["pair_index"], "models", len(item["models"]))


if __name__ == "__main__":
    main()
