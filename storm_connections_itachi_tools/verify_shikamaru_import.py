"""Check the import of Shikamaru's shadow-stitching sequence (package 2sikspl1_x, effect
2sikspl1_atk: the secret technique's attack animation, without the caster).

Played offline twice, on the engine's own path and with the studio path on (Source entities
stubbed: the models are counted, not drawn):
  - both play to the end without an engine error;
  - the studio path leaves at most one skinned draw to Lua (2efb_kyj09_body: its vertex
    colours vary, a studio model has none) and draws the three tag resources kept (2efb_kyj_ptc02: the four tag wires by the cocoon, _ptc05, _ptc06) as models;
  - every .mdl, .vvd, .vtx and .vmt the package names exists in the addon;
  - the caster's own models are not in the package.
Nothing here is seen in Garry's Mod: the stub does not skin, the sequences are checked against
the engine's skinning by export_studio_anm.py when it writes them.

  python verify_shikamaru_import.py
"""

from __future__ import annotations

import json
import sys
import time
from pathlib import Path

from port_preview import Port, capture_camera

ROOT = Path(__file__).resolve().parent
LAB = ROOT.parent / 'storm_amaterasu_lab'
PKG, EFFECT = '2sikspl1_x', '2sikspl1_atk'
STUDIO_RESOURCES = ['2efb_kyj_ptc05', '2efb_kyj_ptc06']
# Host edits asked at import (the package's `edits`): the far wires with tags and the yellow flash
# silenced, the start 633 ms into the animation, nothing but the explosion drawn from 4400 ms on
SILENCED = {'2efb_kyj_ptc02', '2efb_kyj_ptc03', '2efb_kyj_ptc08', '1efc_fire03'}
SKIP_FRAMES, HIDE_TICKS = 37, 13200
AFTER_EXPLOSION = {'1efc_fire02', '1efc_ring17'}
FRAMES = 420
STUB = '''
RENDERGROUP_OTHER = 1
vector_origin, angle_zero = Vector(0, 0, 0), Angle(0, 0, 0)
render.MaterialOverride = function() end
STUDIO_DRAWS = {}
function ClientsideModel(path)
    local e = {path = path}
    function e:IsValid() return true end
    for _, n in ipairs({"SetNoDraw", "SetPos", "SetAngles", "SetRenderBounds", "SetPlaybackRate", "ResetSequence", "SetSequence",
        "SetCycle", "EnableMatrix", "InvalidateBoneCache", "SetupBones", "Remove"}) do e[n] = function() end end
    function e:DrawModel() STUDIO_DRAWS[path] = (STUDIO_DRAWS[path] or 0) + 1 end
    function e:LookupSequence() return 0 end
    return e
end
IsValid = function(x) return x ~= nil and (type(x) ~= "table" or not x.IsValid or x:IsValid()) end
Material = function(name) return {name = name, floats = {}, SetFloat = function(self, k, v) self.floats[k] = v end} end
'''


def run(studio: bool):
    port = Port(dict(capture_camera(22136), yaw=0.0), [0.0, 0.0, 0.0], (64, 64))
    lua = port.lua
    if studio:
        lua.execute(STUB)
    port.load(PKG)
    lua.execute('StormFX.Config.recordEffects = false')
    port.play(PKG, EFFECT, (0.0, 0.0, 0.0), 0.0, float(lua.eval('StormFX.Config.scale')), 1)
    kinds = lua.eval('''function()
        local out = {studio = 0, skinned = 0, other = 0, late = ""}
        local tInstance = StormFX.Engine.tInstances[1]
        local bLate = tInstance and tInstance.ticks >= ''' + str(HIDE_TICKS) + '''
        for _, e in ipairs(StormFX.Engine:BuildEntries()) do
            if e.studioParticle or e.studio then out.studio = out.studio + 1
            elseif e.split or e.skinned then out.skinned = out.skinned + 1
            else out.other = out.other + 1 end
            if bLate and e.item and not e.ribbon then out.late = out.late .. e.item.name .. ";" end
        end
        return out
    end''')
    alive = lua.eval('function() return #StormFX.Engine.tInstances end')
    first = lua.eval('StormFX.Engine.tInstances[1]')
    if int(first.frame) != SKIP_FRAMES or int(first.ticks) != SKIP_FRAMES * 50:
        raise SystemExit(f'FAIL: the effect starts at frame {int(first.frame)}, ticks {int(first.ticks)}')
    rows, spent, ended = [], 0.0, None
    late = set()
    for frame in range(1, FRAMES + 1):
        start = time.perf_counter()
        port.advance(frame)
        k = kinds()
        spent += time.perf_counter() - start
        rows.append((int(k.studio), int(k.skinned), int(k.other)))
        late.update(name for name in str(k.late).split(';') if name)
        if alive() == 0:
            ended = frame
            break
    if studio:
        # The draw pass with the stub entities: every model of the list is asked to draw
        port.collect()
    if late - AFTER_EXPLOSION:
        raise SystemExit(f'FAIL: drawn after the explosion: {sorted(late - AFTER_EXPLOSION)}')
    return port, rows, spent, ended, dict(lua.eval('StormFX.Engine.tFailed').items())


if __name__ == '__main__':
    failures = []
    plain_port, plain, plain_time, plain_end, plain_failed = run(False)
    studio_port, studio, studio_time, studio_end, studio_failed = run(True)
    if plain_failed or studio_failed:
        failures.append(f'engine errors: {plain_failed} {studio_failed}')
    if plain_end is None or studio_end != plain_end:
        failures.append(f'the effect ends at frame {plain_end} on the engine path, {studio_end} on the studio path')
    if any(row[0] for row in plain):
        failures.append('the engine path drew a studio model')
    if max(row[1] for row in studio) > 1:
        failures.append(f'the studio path left {max(row[1] for row in studio)} skinned draws to Lua in one frame')
    if [a[2] - b[2] for a, b in zip(plain, studio) if a[2] < b[2]]:
        failures.append('the studio path draws more plain meshes than the engine path')
    data = studio_port.lua.eval('StormFX.Engine.tPackages["' + PKG + '"].data')
    studio_resources = sorted(str(n) for n, r in data.resources.items() if r and r.studio)
    if studio_resources != STUDIO_RESOURCES:
        failures.append(f'studio resources {studio_resources}')
    missing = []
    for name, resource in data.resources.items():
        if not resource or not resource.studio:
            continue
        for mdl in resource.studio.mdls.values():
            for suffix in ('.mdl', '.vvd', '.dx80.vtx', '.dx90.vtx'):
                if not Path(str(LAB / str(mdl))[:-4] + suffix).is_file():
                    missing.append(str(mdl)[:-4] + suffix)
        for part in resource.studio.parts.values():
            material = part.material or data.models[part.model].meshes[part.mesh].studioMaterial
            if not (LAB / 'materials' / (str(material) + '.vmt')).is_file():
                missing.append(str(material) + '.vmt')
    if missing:
        failures.append(f'missing files: {sorted(set(missing))}')
    caster = sorted(str(n) for n in data.models if str(n).startswith('2sik00t0'))
    if caster:
        failures.append(f'the caster\'s models are in the package: {caster}')
    # The cocoon's own emitters (the particle chunk of 2efb_kyj_ptc07): fifteen tags hang on it
    if not data.resources['2efb_kyj_ptc07'].nested or len(list(data.effects['2efb_kyj_ptc07'].values())) != 6:
        failures.append('the cocoon resource has no emitters of its own')
    if max(row[0] for row in studio) < 15:
        failures.append(f'at most {max(row[0] for row in studio)} studio models in a frame: the cocoon\'s fifteen tags are not all drawn')
    left = sorted(SILENCED & {str(n) for n in data.resources})
    if left:
        failures.append(f'silenced resources still in the package: {left}')
    report = {
        'ends at frame': plain_end, 'engine path (largest per frame)': {'skinned': max(r[1] for r in plain), 'plain': max(r[2] for r in plain)},
        'studio path (largest per frame)': {'studio': max(r[0] for r in studio), 'skinned': max(r[1] for r in studio),
                                            'plain': max(r[2] for r in studio)},
        'offline update and list time, ms': {'engine path': round(plain_time * 1000), 'studio path': round(studio_time * 1000)},
        'studio resources': studio_resources, 'failures': failures,
        'scope': 'Source entity API stub; no live GMod validation'}
    (ROOT / 'captured_assets/procedural/shikamaru_import_check.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=1))
    print('FAIL' if failures else 'PASS: the sequence plays on both paths, the tag resources of the cocoon are studio models, every file is present')
    sys.exit(1 if failures else 0)
