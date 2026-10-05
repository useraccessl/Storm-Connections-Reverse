"""Run the engine's numeric cores under Garry's Mod's LuaJIT and under Lua 5.5, and compare.

  python verify_luajit_runtime.py [--cases 2000] [--gmod-bin "...\\GarrysMod\\bin\\win64"]

The cores are checked against the game's code under Lua 5.5 (lupa: verify_trail_native.py,
verify_facing_native.py, ...). Garry's Mod runs them under LuaJIT 2.1, which differs: no
integers, math.frexp present (MaterialContext.Float32 takes another branch there),
x^2 compiled as a product, its own string formatting. This runs one deterministic script
(pseudo-random inputs from a float-exact generator) in both: float32 over a sweep of
magnitudes, the trail core (Subdivide, Vertices, ApplyField, Update), the facing core (Model,
Billboard), and compares every number printed with %.17g. The cores are the addon's own files
(storm_fx/lua/storm_fx/core). Equal outputs mean the GMod engine computes what the
native-verified Lua 5.5 engine computes.

The LuaJIT is the game's own bin/win64/lua_shared.dll, loaded read only.
"""

from __future__ import annotations

import argparse
import ctypes
import json
import os
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / 'vendor'))
from lupa import LuaRuntime  # noqa: E402
from addon_lua import NAMESPACE, core_source  # noqa: E402

BIN = Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\win64')
OUT = ROOT / 'captured_assets' / 'procedural' / 'luajit_runtime_check.json'

DRIVER = r'''
local cases = CASES
-- GMod's lua_shared has no dofile / load / loadstring: the host compiles the cores and
-- hands them over in MODULES.
local function load(name) return assert(MODULES[name], name) end
local mc = load('material_context')
local f = mc.Float32
local T = load('trail')
local F = load('facing')
local out = {}
local function emit(...)
    for i = 1, select('#', ...) do out[#out + 1] = string.format('%.17g', (select(i, ...))) end
end
-- Park-Miller generator: every product below 2^53, exact in doubles and in integers.
local seed = 20261003
local function rnd() seed = (seed * 16807) % 2147483647 return seed / 2147483647 end
local function r(a, b) return a + (b - a) * rnd() end
local function v3(s) return {f(r(-s, s)), f(r(-s, s)), f(r(-s, s))} end
-- float32 over magnitudes from 1e-40 to 1e30, signs, ties.
for i = 1, cases * 5 do
    local e = math.floor(r(-40, 30))
    emit(f((rnd() - 0.5) * 10 ^ e))
end
emit(f(0.1), f(1 / 3), f(16777217), f(3.4028235677973366e38), f(1.401298464324817e-45), f(-2.5), f(1e-46))
-- the trail core
for c = 1, cases do
    local a = {v3(300), v3(300)}
    local b = {{f(a[1][1] + r(-30, 30)), f(a[1][2] + r(-30, 30)), f(a[1][3] + r(-30, 30))},
               {f(a[2][1] + r(-30, 30)), f(a[2][2] + r(-30, 30)), f(a[2][3] + r(-30, 30))}}
    local d = {{f(b[1][1] + r(-30, 30)), f(b[1][2] + r(-30, 30)), f(b[1][3] + r(-30, 30))},
               {f(b[2][1] + r(-30, 30)), f(b[2][2] + r(-30, 30)), f(b[2][3] + r(-30, 30))}}
    local pts = T.Subdivide({a, b, d}, 0, math.floor(r(1, 14)), f(r(0, 2)), f(r(0, 2)), (c % 2 == 0) and 1 or f(rnd()), f, {})
    for _, p in ipairs(pts) do emit(p[1][1], p[1][2], p[1][3], p[2][1], p[2][2], p[2][3]) end
    local def = {colors = {{f(rnd()), f(rnd()), f(rnd()), f(rnd())}, {f(rnd()), f(rnd()), f(rnd()), f(rnd())},
                           {f(rnd()), f(rnd()), f(rnd()), f(rnd())}}, colorSplit = (c % 4 == 0) and 0 or f(r(0.01, 0.99))}
    local points = {}
    for k = 1, math.floor(r(2, 20)) do points[k] = {v3(400), v3(400)} end
    local rect = (c % 5 == 0) and nil or {f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2)), f(r(-1, 2))}
    for _, v in ipairs(T.Vertices({points = points, alpha = f(rnd())}, def, rect, f)) do
        emit(v.position[1], v.position[2], v.position[3], v.color[1], v.color[2], v.color[3], v.color[4], v.u, v.v)
    end
    local samples = {}
    for k = 1, math.floor(r(1, 6)) do
        samples[k] = {v3(200), v3(200), velocity = {v3(5), v3(5)}, decay = (k % 3 == 0) and 0 or f(r(-0.6, 0.6))}
    end
    local field = {direction = v3(1), decay = f(r(-0.5, 0.5)), kind = 1, radius = f(r(0, 4)), strength = f(r(-30, 30)),
                   flags = math.floor(r(0, 8)) + ((c % 2 == 0) and 16 or 0)}
    local m = nil
    if c % 3 ~= 0 then
        local s = f(r(0.3, 2))
        m = {s, 0, 0, f(r(-200, 200)), 0, s, 0, f(r(-200, 200)), 0, 0, s, f(r(-200, 200)), 0, 0, 0, 1}
    end
    T.ApplyField(field, m, samples, f)
    for _, s in ipairs(samples) do
        emit(s[1][1], s[1][2], s[1][3], s[2][1], s[2][2], s[2][3], s.velocity[1][1], s.velocity[2][3], s.decay)
    end
    -- A short trail life: keys, fades, trimming.
    local tdef = {maxSamples = 20, maxSubdivisions = 10, flags = 19, alphaFade = 10, widthFade = 7,
                  profile = {0, 255, 0}, profileSplit = 0, keys = {2147483748, 900}}
    local state = T.New()
    for k = 1, 30 do
        state.ending = k > 24
        T.Update(state, tdef, k * 50, {f(k * 3), f(r(-5, 5)), 0}, {f(k * 3), f(r(-5, 5)), 10}, 1, f)
        emit(#state.samples, #state.points, state.alpha, state.widthScale)
    end
end
-- the facing core
for c = 1, cases do
    local w = {f(r(-2, 2)), f(r(-2, 2)), f(r(-2, 2)), f(r(-500, 500)), f(r(-2, 2)), f(r(-2, 2)), f(r(-2, 2)), f(r(-500, 500)),
               f(r(-2, 2)), f(r(-2, 2)), f(r(-2, 2)), f(r(-500, 500)), 0, 0, 0, 1}
    local x, y, z = {x = f(rnd()), y = f(rnd()), z = f(rnd())}, {x = f(rnd()), y = f(rnd()), z = f(rnd())}, {x = f(rnd()), y = f(rnd()), z = f(rnd())}
    for _, v in ipairs(F.Model(w, x, y, z)) do emit(v) end
    local board = {roll = math.floor(r(-70000, 70000)), size = {f(r(0, 3)), f(r(0, 3))}, offset = v3(50)}
    for _, v in ipairs(F.Billboard(w, board, x, y, z, (c % 2 == 0) and w or nil, f)) do emit(v) end
end
return table.concat(out, '\n')
'''


NAMES = ('material_context', 'trail', 'facing')


def driver(cases: int) -> str:
    return f'CASES={cases}\n' + DRIVER


def run_lua55(cases: int) -> str:
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute(NAMESPACE)
    modules = lua.table()
    for name in NAMES:
        modules[name] = lua.execute(core_source(name))
    lua.globals().MODULES = modules
    return lua.execute(driver(cases))


def run_luajit(cases: int, gmod_bin: Path) -> str | None:
    library = gmod_bin / 'lua_shared.dll'
    if not library.is_file():
        return None
    os.add_dll_directory(str(gmod_bin))
    lua = ctypes.CDLL(str(library))
    lua.luaL_newstate.restype = ctypes.c_void_p
    lua.luaL_openlibs.argtypes = [ctypes.c_void_p]
    lua.luaL_loadbuffer.argtypes = [ctypes.c_void_p, ctypes.c_char_p, ctypes.c_size_t, ctypes.c_char_p]
    lua.lua_pcall.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int, ctypes.c_int]
    lua.lua_tolstring.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.POINTER(ctypes.c_size_t)]
    lua.lua_tolstring.restype = ctypes.c_void_p
    lua.lua_close.argtypes = [ctypes.c_void_p]
    lua.lua_createtable.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_int]
    lua.lua_setfield.argtypes = [ctypes.c_void_p, ctypes.c_int, ctypes.c_char_p]
    globals_index = -10002                          # LUA_GLOBALSINDEX (Lua 5.1 / LuaJIT)
    state = lua.luaL_newstate()
    lua.luaL_openlibs(state)

    def fail(where: str):
        size = ctypes.c_size_t()
        pointer = lua.lua_tolstring(state, -1, ctypes.byref(size))
        message = ctypes.string_at(pointer, size.value).decode(errors='replace') if pointer else '?'
        lua.lua_close(state)
        raise SystemExit(f'LuaJIT error in {where}: {message}')
    prelude = NAMESPACE.encode()
    if lua.luaL_loadbuffer(state, prelude, len(prelude), b'=namespace') != 0 or lua.lua_pcall(state, 0, 0, 0) != 0:
        fail('namespace')
    lua.lua_createtable(state, 0, len(NAMES))
    for name in NAMES:
        code = core_source(name).encode()
        if lua.luaL_loadbuffer(state, code, len(code), ('=' + name).encode()) != 0 or lua.lua_pcall(state, 0, 1, 0) != 0:
            fail(name)
        lua.lua_setfield(state, -2, name.encode())
    lua.lua_setfield(state, globals_index, b'MODULES')
    source = driver(cases).encode()
    if lua.luaL_loadbuffer(state, source, len(source), b'=driver') != 0 or lua.lua_pcall(state, 0, 1, 0) != 0:
        fail('driver')
    size = ctypes.c_size_t()
    pointer = lua.lua_tolstring(state, -1, ctypes.byref(size))
    text = ctypes.string_at(pointer, size.value).decode()
    lua.lua_close(state)
    return text


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--cases', type=int, default=2000)
    ap.add_argument('--gmod-bin', type=Path, default=BIN)
    args = ap.parse_args()
    jit = run_luajit(args.cases, args.gmod_bin)
    if jit is None:
        print(f'NO CHECK: {args.gmod_bin / "lua_shared.dll"} not found (64-bit Garry\'s Mod)')
        return 2
    plain = run_lua55(args.cases)
    a, b = plain.split('\n'), jit.split('\n')
    # Compared as doubles: %.17g of one double can end differently (the C library rounds an
    # exact ...5 tail to even, LuaJIT's own formatter up), and 17 digits identify the double.

    def same(x: str, y: str) -> bool:
        u, v = float(x), float(y)
        return u == v or (u != u and v != v)
    differ = [(i, x, y) for i, (x, y) in enumerate(zip(a, b)) if not same(x, y)]
    report = {'cases': args.cases, 'values': len(a), 'luajit_values': len(b), 'differ': len(differ),
              'first': [{'index': i, 'lua55': x, 'luajit': y} for i, x, y in differ[:20]]}
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=1) + '\n', encoding='utf-8')
    print(f'{len(a)} values under Lua 5.5, {len(b)} under GMod\'s LuaJIT, {len(differ)} differ')
    for row in report['first'][:10]:
        print('  ', row)
    print('WROTE:', OUT)
    ok = len(a) == len(b) and not differ
    print('PASS: the cores compute the same doubles under GMod\'s LuaJIT as under Lua 5.5' if ok else 'FAIL')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
