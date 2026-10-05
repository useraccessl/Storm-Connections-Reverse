"""Check generated Lua syntax and asset references without launching GMod."""

from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "vendor"))
from lupa import LuaRuntime  # type: ignore


ADDON = ROOT.parent / "storm_amaterasu_lab"
lua = LuaRuntime(unpack_returned_tuples=True)
load = lua.eval("load")
for path in (ADDON / "lua").rglob("*.lua"):
    result = load(path.read_text(encoding="utf-8"))
    if isinstance(result, tuple):
        raise ValueError(f"Lua syntax error in {path}: {result[1]}")
data = lua.execute((ADDON / "lua/storm_amt_lab/generated.lua").read_text(encoding="utf-8"))
billboards = lua.execute((ADDON / "lua/storm_amt_lab/billboard_keys.lua").read_text(encoding="utf-8"))
names = list(data.keys())
assert len(names) == 22, len(names)
assert len(list(billboards.keys())) == 14
assert all(name in data for name in billboards.keys())
assert len(billboards["2efb_amt17"]["keys"]) == 8
assert len(billboards["2efb_amt01"]["keys"]) == 61
assert all(billboards[name]["stepTicks"] == 50 for name in billboards.keys())
for name in names:
    spec = data[name]
    verts = spec["vertices"]
    assert all(len(verts[i]) == 9 for i in range(1, len(verts) + 1)), name
    triangles = spec["triangles"]
    assert len(triangles) % 3 == 0 and len(triangles) > 0, name
    assert all(1 <= triangles[i] <= len(verts) for i in range(1, len(triangles) + 1)), name
    material = spec["material"].split("/")[-1]
    assert (ADDON / "materials/storm_amt_lab" / (material + ".vtf")).exists(), name
    assert (ADDON / "materials/storm_amt_lab" / (material + ".vmt")).exists(), name
    assert (ADDON / "materials/storm_amt_lab" / (material + "_film.vmt")).exists(), name
assert data["2efb_amt00"]["vertices"][2][9] == 127
assert data["2efb_amt01"]["vertices"][1][9] == 0
assert data["2efb_amt01"]["vertices"][1][5] == 1
assert data["2efb_amt16"]["vertices"][1][6] == 0
print(f"Verified Lua syntax, {len(names)} meshes, {len(list(billboards.keys()))} billboard key arrays, triangle indices, and all referenced VTF/VMT assets")
