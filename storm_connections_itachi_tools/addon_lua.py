"""Files of the Storm FX addon (storm_fx/, as it ships) for the offline checks that run one
routine at a time in a lupa (or LuaJIT) state.

Every core file (lua/storm_fx/core/cl_<name>.lua) stands alone: it fills
StormFX.Core.<Module> and returns it, and takes the other modules it works with as
parameters. The engine files of lua/storm_fx/engine/ that hold routines (cl_shader_layout.lua,
cl_render.lua, cl_stage_post.lua) are loaded the same way.
"""

from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parent
LUA = ROOT.parent / 'storm_fx' / 'lua'
CORE = LUA / 'storm_fx' / 'core'
ENGINE = LUA / 'storm_fx' / 'engine'

# A state with the addon's namespace, as the autorun makes it
NAMESPACE = 'StormFX = StormFX or {} StormFX.Core = StormFX.Core or {}'


def core_path(name: str) -> Path:
    """core/cl_<name>.lua (name: 'trail', 'skill_actor', ...)."""
    return CORE / f'cl_{name}.lua'


def core_source(name: str) -> str:
    return core_path(name).read_text(encoding='utf-8-sig')


def load_core(lua, name: str):
    """StormFX.Core.<Module> of core/cl_<name>.lua, run in `lua`."""
    lua.execute(NAMESPACE)
    return lua.execute(core_source(name))


def engine_path(name: str) -> Path:
    """engine/cl_<name>.lua (name: 'shader_layout', 'render', 'stage_post')."""
    return ENGINE / f'cl_{name}.lua'


def load_engine_file(lua, name: str):
    """Run engine/cl_<name>.lua in `lua`; returns what it returns (nil for most)."""
    lua.execute(NAMESPACE)
    return lua.execute(engine_path(name).read_text(encoding='utf-8-sig'))
