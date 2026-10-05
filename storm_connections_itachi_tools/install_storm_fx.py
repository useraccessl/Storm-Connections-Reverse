"""Install the Storm FX addon and the imported skill packages into Garry's Mod or a server.

  python install_storm_fx.py                      # every package, into the game (single player)
  python install_storm_fx.py --packages 4efb_amt1_x 3efb_3ssk1_x
  python install_storm_fx.py --server --gmod C:\\SteamCMD\\solve\\garrysmod   # a dedicated server
  python install_storm_fx.py --remove             # take the addon out of the game (backed up)
  python install_storm_fx.py --dry-run            # list what would be copied

What is installed into addons/storm_fx, and nothing else:
  * the addon's code as it ships (storm_fx/lua: the autorun lua/autorun/sh_storm_fx.lua and
    every file its list names: settings, cores, engine, interface, in-game tests). The
    autorun sends the client files (AddCSLuaFile) and includes the server ones; each client
    file must stay under 64 KB once compressed, GMod's limit;
  * the chosen packages, as content: data_static/storm_fx/<package>.txt (their Lua source,
    compiled by the engine with CompileString; a package is far over 64 KB);
  * the VTFs and the translated shader pairs those packages name, and the stage tone
    shader (all from the lab addon, storm_amaterasu_lab, where storm_import.py writes them);
  * a generated server file (lua/autorun/server/sv_storm_fx_content.lua) that lists the
    textures, shaders and packages for the clients to download (resource.AddFile; those
    paths are on GMod's download whitelist, filesystem_stdio.dll), and the Workshop content
    addon when --workshop-id is given.
Into the game, shaders also go into garrysmod/shaders/fxc; with --server they do not (a
dedicated server draws nothing). Every Lua file is first compiled with the game's own LuaJIT
(bin/win64/lua_shared.dll, verify_luajit.py): nothing is copied if one does not compile.

The addon folder already there is moved, whole, to <garrysmod>/storm_fx_backups/<time>/
before anything is written, and so is the earlier lab addon (addons/storm_amaterasu_lab, the
r27 engine: two engines would fight over StormFX and the console commands), and the
storm_fx_* shaders of garrysmod/shaders/fxc that this install replaces. The script refuses to
run while the game or a dedicated server is open. A manifest with every file and its hash is
written to captured_assets/procedural/storm_fx_install_manifest[_server].json.

Nothing here proves the engine in game: the checks of this repository run
offline. After installing: start a map, then in the console
  storm_fx_list 4efb_amt1_x          scripts and effects of a package
  storm_fx_cast 4efb_amt1_x          play its first root script toward the crosshair
  storm_fx_diag                      what ran, what was skipped, engine notes
  storm_fx_selftest [package]        aim at the ground ahead, close the console: casts the skill,
                                     writes 9 screen captures and report.json to
                                     garrysmod/data/storm_fx_selftest/ (verify_selftest.py runs
                                     the same test offline)
"""

from __future__ import annotations

import argparse
import datetime
import hashlib
import json
import lzma
import re
import shutil
import subprocess
from pathlib import Path

from verify_luajit import compile_files

ROOT = Path(__file__).resolve().parent
CODE = ROOT.parent / 'storm_fx'                 # the addon's code, as it ships
ADDON = ROOT.parent / 'storm_amaterasu_lab'     # the content: packages, textures, shaders
GMOD = Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\garrysmod')
ADDON_NAME = 'storm_fx'
LEGACY_NAMES = ['storm_amaterasu_lab']          # earlier installs, moved to the backups
ENTRY = 'autorun/sh_storm_fx.lua'
SERVER_AUTORUN = 'autorun/server/sv_storm_fx_content.lua'
EXTRA_SHADERS = ['storm_tone_ps30']             # engine/cl_stage_post.lua
# GMod refuses a client Lua file over 64 KB compressed (LZMA; wiki AddCSLuaFile); this
# estimate with Python's LZMA must stay below the margin.
CLIENT_LUA_LIMIT = 60 * 1024
# The content addon for the Workshop: what clients must download (textures, shaders,
# packages). Players get Workshop content whatever their download filter; files a server
# offers itself are refused by cl_downloadfilter "mapsonly" / "none" (seen 2026-10-03).
WORKSHOP = ROOT.parent / 'workshop_storm_fx_content'
GMAD = GMOD.parent / 'bin' / 'gmad.exe'


def build_workshop(folder: Path, content: list[tuple[Path, Path]], packages: list[str]) -> None:
    """Write the content addon (addon.json + content) and pack it with gmad.exe, which
    refuses any file outside GMod's addon whitelist."""
    if folder.exists():
        shutil.rmtree(folder)
    for source, relative in content:
        target = folder / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
    (folder / 'addon.json').write_text(json.dumps({
        'title': 'Storm FX content', 'type': 'servercontent', 'tags': ['fun', 'cartoon'], 'ignore': [],
        'description': 'Textures, shaders and effect packages of the Storm FX engine (' + ', '.join(packages) + ').'},
        indent=1) + '\n', encoding='utf-8')
    print(f'{len(content)} content files -> {folder}')
    if not GMAD.is_file():
        print(f'note: {GMAD} not found; pack it with gmad.exe create -folder "{folder}"')
        return
    out = folder.with_suffix('.gma')
    result = subprocess.run([str(GMAD), 'create', '-folder', str(folder), '-out', str(out)], capture_output=True, text=True)
    print(result.stdout.strip()[-1500:])
    if result.returncode != 0 or not out.is_file():
        raise SystemExit(f'gmad refused the content (exit {result.returncode}): {result.stderr.strip()[-800:]}')
    print(f'{out} ({out.stat().st_size // 1024} KB): publish it with gmpublish.exe create -addon "{out}" -icon <512x512 jpg>, '
          f'then install the server with --workshop-id <its id>')


def addon_lua() -> list[str]:
    """The autorun and the files its list names (relative to lua/), in load order. Every Lua
    file of the code folder must be on the list, and every listed file must exist."""
    listed = re.findall(r'"(storm_fx/[^"]+\.lua)"', (CODE / 'lua' / ENTRY).read_text(encoding='utf-8-sig'))
    present = sorted(p.relative_to(CODE / 'lua').as_posix() for p in (CODE / 'lua').rglob('*.lua'))
    missing = [name for name in listed if not (CODE / 'lua' / name).is_file()]
    stray = [name for name in present if name != ENTRY and name not in listed]
    if missing or stray:
        raise SystemExit(f'the autorun list and {CODE / "lua"} differ: missing {missing}, not listed {stray}')
    return [ENTRY] + listed


def client_side(name: str) -> bool:
    """Sent to the clients: the autorun and the cl_ / sh_ files (sv_ files stay on the server)."""
    return name == ENTRY or Path(name).name[:3] in ('cl_', 'sh_')


def package_assets(name: str) -> tuple[set[str], set[str]]:
    """(VTF names relative to materials/, shader names) a package refers to."""
    text = (ADDON / 'lua/storm_fx/packages' / f'{name}.lua').read_text(encoding='utf-8')
    textures = set(re.findall(r'\["vtf"\]="([^"]+)"', text))
    shaders = set(re.findall(r'\["(?:vertex|pixel)"\]="(storm_fx_[0-9a-z_]+)"', text))
    return textures, shaders


# The files of a compiled studio model besides its .mdl (export_studio.py)
STUDIO_PARTS = ('.mdl', '.vvd', '.dx80.vtx', '.dx90.vtx')


def package_models(name: str) -> set[str]:
    """The studio model files (relative to the addon) a package refers to."""
    text = (ADDON / 'lua/storm_fx/packages' / f'{name}.lua').read_text(encoding='utf-8')
    out = set()
    for mdl in re.findall(r'"(models/[^"]+)\.mdl"', text):
        out |= {mdl + part for part in STUDIO_PARTS}
    # Their meshes' own materials (storm_import.py write_studio_vmt), and those of the draws
    # that have their own
    out |= {f'materials/{path}.vmt' for path in re.findall(r'\["studioMaterial"\]="([^"]+)"', text)}
    out |= {f'materials/{path}.vmt' for path in re.findall(r'\["material"\]="(storm_fx/studio/[^"]+)"', text)}
    return out


def skin_test_assets() -> set[str]:
    """The skinning test variants skin_variants.py made (models, materials, vertex shaders),
    while they are in the addon folder."""
    out = set()
    for pattern in ('shaders/fxc/storm_fx_skintest_*.vcs', 'materials/storm_fx/studio_?/*.vmt'):
        out |= {p.relative_to(ADDON).as_posix() for p in ADDON.glob(pattern)}
    for vmt in ADDON.glob('materials/storm_fx/studio_?/*_mesh1.vmt'):
        variant = vmt.parent.name[-1]
        model = vmt.stem[:-len('_mesh1')]
        out |= {f'models/storm_fx/{model}_{variant}{part}' for part in STUDIO_PARTS}
    return out


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def running(server: bool = False) -> list[str]:
    """Processes open that use the target's files: a dedicated server's for --server (the game
    client has its own files), else the game's and a server's."""
    listing = subprocess.run(['tasklist', '/NH'], capture_output=True, text=True).stdout.lower()
    names = ('srcds.exe', 'srcds_win64.exe') if server else ('gmod.exe', 'srcds.exe', 'srcds_win64.exe')
    return [name for name in names if name in listing]


def move_addons(gmod: Path, backup: Path) -> list[str]:
    """Move the installed addon and the earlier lab addon to `backup`."""
    moved = []
    for name in [ADDON_NAME] + LEGACY_NAMES:
        folder = gmod / 'addons' / name
        if folder.exists():
            backup.mkdir(parents=True, exist_ok=True)
            shutil.move(str(folder), str(backup / name))
            moved.append(str(folder))
    return moved


def remove(gmod: Path) -> None:
    """Move the installed addon and its root shaders to <gmod>/storm_fx_backups/<time>/."""
    stamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    backup = gmod / 'storm_fx_backups' / stamp
    moved = move_addons(gmod, backup)
    root = gmod / 'shaders' / 'fxc'
    for shader in sorted(root.glob('storm_fx_*.vcs')) + [root / f'{name}.vcs' for name in EXTRA_SHADERS]:
        if shader.is_file():
            kept = backup / 'shaders_fxc' / shader.name
            kept.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(str(shader), str(kept))
            moved.append(str(shader))
    print(f'{len(moved)} entries moved to {backup}' if moved else 'nothing installed there')


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--gmod', type=Path, default=GMOD, help='the garrysmod folder (the one holding addons/)')
    ap.add_argument('--packages', nargs='*', help='package names; default: every package of the addon folder')
    ap.add_argument('--server', action='store_true', help='a dedicated server: no copy into garrysmod/shaders/fxc')
    ap.add_argument('--workshop-id', help='Workshop id of the published content addon: the server autorun lists it '
                    '(resource.AddWorkshop), which clients download whatever their cl_downloadfilter')
    ap.add_argument('--workshop', type=Path, nargs='?', const=WORKSHOP, metavar='FOLDER',
                    help=f'only build the content addon to publish on the Workshop (default {WORKSHOP}) and its .gma')
    ap.add_argument('--content', action='store_true',
                    help='only the content (textures, shaders, packages as data_static), straight into the garrysmod '
                    'folder itself (materials/, shaders/fxc/, data_static/); no Lua, no addon folder')
    ap.add_argument('--remove', action='store_true', help='move the installed addon and its shaders to the backups')
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()
    if not (args.gmod / 'addons').is_dir():
        raise SystemExit(f'{args.gmod} has no addons folder: pass --gmod')
    if not args.dry_run and not args.workshop and running(args.server):
        raise SystemExit(f'{", ".join(running(args.server))} is running: close it first (files in use, and the addon folder is moved aside)')
    if args.remove:
        remove(args.gmod)
        raise SystemExit(0)
    packages = args.packages or sorted(p.stem for p in (ADDON / 'lua/storm_fx/packages').glob('*.lua'))
    code_lua = addon_lua()
    client_lua = [name for name in code_lua if client_side(name)]
    textures, shaders, models = set(), set(EXTRA_SHADERS), set()
    for name in packages:
        t, s = package_assets(name)
        textures |= t
        shaders |= s
        models |= package_models(name)
    # A client Lua file over GMod's limit is not sent: the engine would fail on the clients.
    too_big = {}
    for name in client_lua:
        size = len(lzma.compress((CODE / 'lua' / name).read_bytes(), format=lzma.FORMAT_ALONE))
        if size > CLIENT_LUA_LIMIT:
            too_big[name] = size
    if too_big:
        raise SystemExit('client Lua files over GMod\'s 64 KB compressed limit:\n  '
                         + '\n  '.join(f'{name}: {size} bytes' for name, size in too_big.items()))
    plan: list[tuple[Path, Path]] = [(CODE / 'lua' / name, Path('lua') / name) for name in code_lua]
    plan += [(ADDON / 'lua/storm_fx/packages' / f'{name}.lua', Path('data_static/storm_fx') / f'{name}.txt') for name in packages]
    plan += [(ADDON / 'materials' / f'{name}.vtf', Path('materials') / f'{name}.vtf') for name in sorted(textures)]
    plan += [(ADDON / 'shaders/fxc' / f'{name}.vcs', Path('shaders/fxc') / f'{name}.vcs') for name in sorted(shaders)]
    plan += [(ADDON / name, Path(name)) for name in sorted(models | skin_test_assets())]
    missing = [str(source) for source, _ in plan if not source.is_file()]
    if missing:
        raise SystemExit('missing source files:\n  ' + '\n  '.join(missing[:20]))
    # The server's content list: what the clients download (the code itself is sent by the
    # addon's autorun).
    server = '-- Generated by install_storm_fx.py: the content of Storm FX the clients download.\n'
    if args.workshop_id:
        # Clients download the content addon from the Workshop (not blocked by cl_downloadfilter).
        server += f'resource.AddWorkshop("{args.workshop_id}")\n'
    # The same files offered by the server itself: for clients whose cl_downloadfilter is "all"
    # (a client that has them from the Workshop downloads nothing).
    server += ''.join(f'resource.AddFile("{relative.as_posix()}")\n' for _, relative in plan if relative.parts[0] != 'lua')
    # Garry's Mod runs LuaJIT: a file it cannot compile (more than 65536 constants in a
    # function, Lua 5.3+ operators) is refused here, with the game's own compiler
    # (verify_luajit.py, journal R96), before anything is copied. A server without a
    # 64-bit lua_shared.dll is checked with the game's.
    lua_files = [(relative.as_posix(), source) for source, relative in plan if source.suffix == '.lua']
    compiled = compile_files(lua_files, args.gmod.parent / 'bin' / 'win64')
    if compiled is None:
        compiled = compile_files(lua_files, GMOD.parent / 'bin' / 'win64')
    if compiled is None:
        print('note: no 64-bit lua_shared.dll found; LuaJIT compilation not checked')
    elif compiled['failed']:
        raise SystemExit('these files do not compile in Garry\'s Mod\'s LuaJIT (re-import the packages):\n  '
                         + '\n  '.join(f'{name}: {why}' for name, why in list(compiled['failed'].items())[:20]))
    else:
        print(f'{len(compiled["ok"])} Lua files compile with Garry\'s Mod\'s LuaJIT')
    if args.workshop:
        build_workshop(args.workshop, [(s, r) for s, r in plan if r.parts[0] != 'lua'], packages)
        raise SystemExit(0)
    if args.content:
        # The content alone, into the game's own folders: a file there that differs is moved to
        # <garrysmod>/storm_fx_backups/<time>/content/ first.
        content = [(s, r) for s, r in plan if r.parts[0] != 'lua']
        print(f'{len(packages)} packages, {len(textures)} textures, {len(shaders)} shaders -> {args.gmod}')
        if args.dry_run:
            for _, relative in content:
                print('  ', relative.as_posix())
            raise SystemExit(0)
        stamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
        backup = args.gmod / 'storm_fx_backups' / stamp / 'content'
        manifest, replaced = [], 0
        for source, relative in content:
            target = args.gmod / relative
            if target.exists():
                if sha256(target) == sha256(source):
                    manifest.append({'source': str(source), 'destination': str(target), 'sha256': sha256(target)})
                    continue
                kept = backup / relative
                kept.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(target), str(kept))
                replaced += 1
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            if sha256(target) != sha256(source):
                raise SystemExit(f'hash mismatch after copy: {target}')
            manifest.append({'source': str(source), 'destination': str(target), 'sha256': sha256(target)})
        record = ROOT / 'captured_assets/procedural/storm_fx_install_manifest_content.json'
        record.write_text(json.dumps({'installedAt': stamp, 'gmod': str(args.gmod), 'packages': packages,
                                      'backup': str(backup) if backup.exists() else None, 'files': manifest}, indent=1) + '\n',
                          encoding='utf-8')
        print(f'{len(manifest)} content files in place and hash-checked ({replaced} older ones moved to {backup}); manifest: {record}')
        raise SystemExit(0)
    destination = args.gmod / 'addons' / ADDON_NAME
    print(f'{len(packages)} packages, {len(code_lua)} Lua files ({len(client_lua)} sent to the clients), {len(textures)} textures, '
          f'{len(shaders)} shaders{" (server)" if args.server else ""} -> {destination}')
    if args.dry_run:
        for source, relative in plan:
            print('  ', relative.as_posix())
        print(server)
        raise SystemExit(0)
    stamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    backup = args.gmod / 'storm_fx_backups' / stamp
    for folder in move_addons(args.gmod, backup):
        print(f'{folder} moved to {backup}')
    manifest = []
    for source, relative in plan:
        targets = [destination / relative]
        if relative.parts[0] == 'shaders' and not args.server:
            targets.append(args.gmod / relative)
        for target in targets:
            if target.exists() and sha256(target) != sha256(source):       # only a root shader can already exist
                kept = backup / 'shaders_fxc' / target.name
                kept.parent.mkdir(parents=True, exist_ok=True)
                shutil.move(str(target), str(kept))
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(source, target)
            if sha256(target) != sha256(source):
                raise SystemExit(f'hash mismatch after copy: {target}')
            manifest.append({'source': str(source), 'destination': str(target), 'sha256': sha256(target)})
    target = destination / 'lua' / SERVER_AUTORUN
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(server, encoding='ascii', newline='\n')
    manifest.append({'source': 'generated', 'destination': str(target), 'sha256': sha256(target)})
    record = ROOT / ('captured_assets/procedural/storm_fx_install_manifest' + ('_server' if args.server else '') + '.json')
    record.write_text(json.dumps({'installedAt': stamp, 'gmod': str(args.gmod), 'server': args.server, 'packages': packages,
                                  'backup': str(backup) if backup.exists() else None, 'files': manifest}, indent=1) + '\n',
                      encoding='utf-8')
    print(f'installed and hash-checked {len(manifest)} files; manifest: {record}')
    print('Not verified in game. Start a map, then: storm_fx_list <package>, storm_fx_cast <package>, storm_fx_diag')
