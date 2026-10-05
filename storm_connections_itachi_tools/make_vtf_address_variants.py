"""Write clamped copies of the port's VTFs for NUD address modes Source cannot infer.

A VTF fixes its address mode in the header, while the game picks it per NUD
material texture. For every base texture used with a non-wrap mode this writes
`<name><suffix>.vtf`, identical payload, with TEXTUREFLAGS_CLAMPS / CLAMPT set.
The suffix comes from storm_fx_render.lua (F.address), the same function the
player calls, so names cannot drift. Mirror and border are finished in the
pixel shader on top of the clamped variant.
"""

from __future__ import annotations

import json
import struct
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402

ADDON = ROOT.parent / 'storm_amaterasu_lab'
LUA = ADDON / 'lua/storm_amt_lab'
CLAMP_S, CLAMP_T = 0x4, 0x8


def uses(lua) -> set[tuple[str, int, int]]:
    """(source texture, wrap_s, wrap_t) of every material texture in the exported assets."""
    out = set()

    def collect(material, meshes, textures):
        records = list(material.texture_groups[1].textures.values())
        for mesh in meshes.values():
            for state in mesh.originalRenderState.values():
                for record, sampler in zip(records, state.textures.values()):
                    out.add((textures[record.name].sourceTexture, sampler.wrap_s, sampler.wrap_t))

    assets = lua.execute((LUA / 'procedural_assets.lua').read_text(encoding='utf-8-sig'))
    for resource in assets.resources.values():
        collect(resource.material, resource.meshes, assets.textures)
    aux = lua.execute((LUA / 'auxiliary_assets.lua').read_text(encoding='utf-8-sig'))
    for model in aux.models.values():
        collect(model.materials[1], model.meshes, aux.textures)
    return out


if __name__ == '__main__':
    lua = LuaRuntime(unpack_returned_tuples=True)
    fx = lua.execute((LUA / 'storm_fx_render.lua').read_text(encoding='utf-8'))
    written = []
    for source, wrap_s, wrap_t in sorted(uses(lua)):
        suffix, _ = fx.address(wrap_s, wrap_t, 1, 1)
        if not suffix:
            continue
        original = ADDON / 'materials' / f'{source}.vtf'
        raw = bytearray(original.read_bytes())
        flags = struct.unpack_from('<I', raw, 20)[0]
        flags |= (CLAMP_S if 's' in suffix[2:] else 0) | (CLAMP_T if 't' in suffix[2:] else 0)
        struct.pack_into('<I', raw, 20, flags)
        target = original.with_name(original.stem + suffix + '.vtf')
        target.write_bytes(raw)
        written.append({'texture': source + suffix, 'from': source, 'wrap': [wrap_s, wrap_t], 'flags': hex(flags)})
        print(f'{target.name}: wrap ({wrap_s}, {wrap_t}) flags {flags:#x}')
    (ROOT / 'captured_assets/procedural/vtf_address_variants.json').write_text(json.dumps(written, indent=2) + '\n', encoding='utf-8')
