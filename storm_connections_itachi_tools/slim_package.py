"""Make the installed copy of a package lighter: the geometry of the models that are only ever drawn
as Source studio models (.mdl) is taken out of the package's Lua (vertices, triangles, second UV
sets, normals, skin). Their meshes keep everything else (shader layouts, state, textures) and gain
`stripped = true`; the engine builds no mesh for them and never draws them itself. The package is
read as a table and written again with the importer's writer; the result is read back and compared
with its source, value by value.

The package in the lab addon stays whole: the exporters and the offline checks read its geometry.

A mesh is left alone unless it has a studio material and shader and every animation that draws its
model is either the one baked in the model's own studio model, or a particle resource the package
has as a studio model with this mesh in it (never a clump or billboard resource, never a trail).
Without studio models (Config useStudioModels false) a stripped mesh is not drawn at all.

  python slim_package.py [<package> ...] [--out <addon folder>]     (default: every package)
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import port_preview  # noqa: F401  puts the vendored lupa on the path

import lupa  # noqa: E402
from lupa import LuaRuntime  # noqa: E402

from storm_import import lua, short_geometry  # noqa: E402

ROOT = Path(__file__).resolve().parent
ADDON = ROOT.parent / 'storm_amaterasu_lab'
OUT = ROOT / 'game_cache' / 'slim_addon'
GEOMETRY = ('vertices', 'triangles', 'uvSets', 'normalHalfRaw', 'skin')


def strippable(data: dict) -> set[tuple[str, int]]:
    """The (model, mesh index from 0) of a package (read_package) that the engine only draws as a
    studio model, whatever animation draws the model."""
    resource_animations: dict[str, list] = {}
    blocked: set[str] = set()
    for resource in data['resources'].values():
        if not resource:
            continue
        if resource.get('kind') == 'anm':
            resource_animations.setdefault(resource['animation'], []).append(resource)
        elif resource.get('kind') == 'clump':
            blocked.update(resource.get('models') or [])
        elif resource.get('model'):
            blocked.add(resource['model'])
    for definitions in (data.get('trails') or {}).values():
        for definition in definitions:
            if (definition.get('draw') or {}).get('model'):
                blocked.add(definition['draw']['model'])
    # Animations played on their own: the effects kept, the script animations, and every effect
    # that is not a resource's
    roots = set(data.get('kept') or [])
    for script in (data.get('skills') or {}).values():
        for action in script['actions']:
            for entry in (action['parameters'].get('Animation') or []):
                if isinstance(entry, dict) and entry.get('chunk'):
                    roots.add(entry['chunk'])
    roots.update(name for name in data['effects'] if name not in resource_animations)
    users: dict[str, set[str]] = {}
    for name, animation in data['animations'].items():
        for clump in animation['clumps']:
            for model in (clump.get('drawn') or []):
                users.setdefault(model, set()).add(name)
    out = set()
    for name, model in data['models'].items():
        if name in blocked or name not in users:
            continue
        own = (model.get('studio') or {}).get('animation') if model.get('skeleton') else None
        for index, mesh in enumerate(model['meshes']):
            if not (mesh.get('studioShader') and mesh.get('studioMaterial')):
                continue
            ok = True
            for animation in users[name]:
                # The model's own studio model, posed by this animation (cl_draw.lua fnSubmit)
                single = own == animation and bool(mesh.get('skin'))
                # Or the studio models of every resource that plays the animation (fnAddParticles)
                resources = resource_animations.get(animation, [])
                whole = animation not in roots and bool(resources) and all(
                    r.get('studio') and any(p['model'] == name and p['mesh'] == index + 1 for p in r['studio']['parts'])
                    for r in resources)
                ok = ok and (single or whole)
            if ok:
                out.add((name, index))
    return out


def to_python(value):
    """A Lua value as the importer's writer takes it: a table with keys 1..n is a list, any
    other a dict (integer keys stay integers), numbers keep their kind (integer or float)."""
    if lupa.lua_type(value) != 'table':
        return value
    keys = list(value.keys())
    count = len(keys)
    if count and all(isinstance(k, int) for k in keys) and set(keys) == set(range(1, count + 1)):
        return [to_python(value[i]) for i in range(1, count + 1)]
    return {key: to_python(value[key]) for key in keys}


def same(a, b, path: str, stripped: set[tuple[str, int]]) -> str | None:
    """None when two packages (as Python values) hold the same thing but the stripped geometry,
    else where they first differ."""
    if isinstance(a, dict) and isinstance(b, dict):
        at = path.split('/')
        in_stripped = len(at) == 5 and at[1] == 'models' and at[3] == 'meshes' and (at[2], int(at[4])) in stripped
        for key in sorted(set(a) | set(b), key=str):
            if in_stripped and (key in GEOMETRY or key == 'stripped'):
                continue
            if key not in a or key not in b:
                return f'{path}/{key}: in one only'
            found = same(a[key], b[key], f'{path}/{key}', stripped)
            if found:
                return found
        return None
    if isinstance(a, list) and isinstance(b, list):
        if len(a) != len(b):
            return f'{path}: {len(a)} and {len(b)} entries'
        for index, (x, y) in enumerate(zip(a, b)):
            found = same(x, y, f'{path}/{index}', stripped)
            if found:
                return found
        return None
    if isinstance(a, (dict, list)) or isinstance(b, (dict, list)):
        # An empty table is a list or a dict alike
        return None if not a and not b else f'{path}: a table and a value'
    if a != b and not (a != a and b != b):
        return f'{path}: {a!r} and {b!r}'
    return None


def read_package(path: Path):
    """The table a package file returns, as Python values."""
    return to_python(LuaRuntime(unpack_returned_tuples=True).execute(path.read_text(encoding='utf-8')))


def slim(source: Path, target: Path) -> list[tuple[str, int]]:
    """Write the package at `source` to `target` without the geometry of its strippable meshes;
    returns them. The result is read back and compared with the source."""
    data = read_package(source)
    meshes = strippable(data)
    for name, index in meshes:
        mesh = data['models'][name]['meshes'][index]
        for key in GEOMETRY:
            mesh.pop(key, None)
        mesh['stripped'] = True
    short_geometry(data['models'])
    header = ('-- Generated by slim_package.py from the package storm_import.py made: the same data without the\n'
              '-- geometry of the meshes that are only drawn as studio models. Decoded values only.\n')
    target.write_bytes((header + 'return ' + lua(data) + '\n').encode('utf-8'))
    difference = same(read_package(source), read_package(target), '', meshes)
    if difference:
        raise SystemExit(f'{source.name}: the slim package differs from its source at {difference}')
    return sorted(meshes)


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('packages', nargs='*')
    ap.add_argument('--out', type=Path, default=OUT)
    args = ap.parse_args()
    source = ADDON / 'lua/storm_fx/packages'
    names = args.packages or sorted(p.stem for p in source.glob('*.lua'))
    target = args.out / 'lua/storm_fx/packages'
    target.mkdir(parents=True, exist_ok=True)
    before = after = 0
    for name in names:
        meshes = slim(source / f'{name}.lua', target / f'{name}.lua')
        size, slimmed = (source / f'{name}.lua').stat().st_size, (target / f'{name}.lua').stat().st_size
        before, after = before + size, after + slimmed
        print(f'{name}: {size / 1024:.0f} KB -> {slimmed / 1024:.0f} KB, {len(meshes)} meshes stripped '
              f'{[f"{model}#{index + 1}" for model, index in meshes]}')
    print(f'all: {before / 1024:.0f} KB -> {after / 1024:.0f} KB; written to {target}')
    return 0


if __name__ == '__main__':
    sys.exit(main())
