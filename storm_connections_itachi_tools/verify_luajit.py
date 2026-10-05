"""Compile every Lua file of the addons with Garry's Mod's own LuaJIT, without running it.

  python verify_luajit.py [--addon ../storm_fx ../storm_amaterasu_lab] [--gmod-bin "...\\GarrysMod\\bin\\win64"]

By default: the addon as it ships (storm_fx/: autorun, engine, cores) and the lab addon (the
packages it ships as content, the reference engine).

The offline checks run the engine under Lua 5.5 (lupa). Garry's Mod runs LuaJIT 2.1, which
refuses things Lua 5.5 accepts: a function with more than 65536 constants (a big package as
one table literal: 1efcmn_x before the writer split it, storm_import.LUA_CONSTANTS), and the
operators of Lua 5.3+ (//, &, |, ~, <<, >>). This loads the game's lua_shared.dll (read only,
nothing in the installation is changed) and compiles each file with luaL_loadbuffer. It
proves the files compile in GMod's Lua; it does not run them.
"""

from __future__ import annotations

import argparse
import ctypes
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
ADDON = ROOT.parent / 'storm_amaterasu_lab'
CLEAN = ROOT.parent / 'storm_fx'
BIN = Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\win64')
OUT = ROOT / 'captured_assets' / 'procedural' / 'luajit_compile_check.json'


def compile_files(paths: list[tuple[str, Path]], gmod_bin: Path = BIN) -> dict | None:
    """Compile (label, path) pairs with GMod's LuaJIT: {'ok': [labels], 'failed': {label: error}},
    or None when the 64-bit lua_shared.dll is not there."""
    library = gmod_bin / 'lua_shared.dll'
    if not library.is_file():
        return None
    os.add_dll_directory(str(gmod_bin))
    lua = ctypes.CDLL(str(library))
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
    lua.luaL_loadbuffer.restype = ctypes.c_int
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
    lua.lua_tolstring.restype = ctypes.c_char_p
    lua.lua_settop.argtypes = [ctypes.c_void_p, ctypes.c_int]
    lua.lua_close.argtypes = [ctypes.c_void_p]
    state = lua.luaL_newstate()
    report = {'ok': [], 'failed': {}}
    for label, path in paths:
        data = path.read_bytes()
        if data.startswith(b'\xef\xbb\xbf'):
            data = data[3:]                         # GMod strips a UTF-8 BOM
        if lua.luaL_loadbuffer(state, data, len(data), ('=' + label).encode()) != 0:
            message = lua.lua_tolstring(state, -1, None)
            report['failed'][label] = message.decode(errors='replace') if message else '?'
        else:
            report['ok'].append(label)
        lua.lua_settop(state, 0)
    lua.lua_close(state)
    return report


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--addon', type=Path, nargs='+', default=[CLEAN, ADDON])
    ap.add_argument('--gmod-bin', type=Path, default=BIN)
    args = ap.parse_args()
    paths = [(f'{addon.name}/{path.relative_to(addon).as_posix()}', path)
             for addon in args.addon for path in sorted((addon / 'lua').rglob('*.lua'))]
    report = compile_files(paths, args.gmod_bin)
    if report is None:
        print(f'NO CHECK: {args.gmod_bin / "lua_shared.dll"} not found (64-bit Garry\'s Mod)')
        return 2
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print(f'{len(report["ok"])} files compile with GMod\'s LuaJIT, {len(report["failed"])} do not')
    for name, why in list(report['failed'].items())[:20]:
        print(f'  FAIL {name}: {why}')
    print('WROTE:', OUT)
    print('PASS: every Lua file compiles in Garry\'s Mod\'s LuaJIT' if not report['failed'] else 'FAIL')
    return 1 if report['failed'] else 0


if __name__ == '__main__':
    sys.exit(main())
