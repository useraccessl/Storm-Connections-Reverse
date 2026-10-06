"""Check the slim packages (slim_package.py): the installed copies without the geometry of the
meshes that are only drawn as studio models.

slim_package.py itself reads every slim package back and compares it with its source value by
value (everything but the stripped geometry is the same). Here each package that lost meshes is
played offline, whole and slim, with the studio path on (Source entities stubbed: the models are
counted, not drawn): every skill script cast and every effect that is played on its own.
  - the slim copy plays without an engine error, on the studio path and without it;
  - frame by frame the draw list is the same as the whole package's: the same studio models, the
    same meshes left to the engine, in the same number;
  - no entry of the list is a stripped mesh without its studio model, and no mesh is built for one.
Without studio models a stripped mesh is not drawn (no fallback): that run only checks for errors.
Nothing here is seen in Garry's Mod.

  python verify_slim_packages.py
"""

from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

import slim_package as sp
from port_preview import Port, capture_camera
from verify_shikamaru_import import STUB

ROOT = Path(__file__).resolve().parent
FRAMES = 420
ORIGIN = [209.65, -476.38, -0.68]


def run(package: str, slim: bool, studio: bool):
    """Per play (script or effect), the draw list of every frame as counts by kind and name."""
    port = Port(dict(capture_camera(22136), yaw=0.0), ORIGIN, (64, 64), packages=sp.OUT if slim else None)
    lua = port.lua
    if studio:
        lua.execute(STUB)
    runtime = port.load(package)
    lua.execute('StormFX.Config.recordEffects = false; StormFX.Config.simulationBudgetMs = 0')
    scale = float(lua.eval('StormFX.Config.scale'))
    entries = lua.eval('''function()
        local out, bad = {}, 0
        for _, e in ipairs(StormFX.Engine:BuildEntries()) do
            local sKey
            if e.studioParticle then sKey = "studio particle " .. e.studioParticle.mdl
            elseif e.studio then sKey = "studio " .. e.item.name
            elseif e.ribbon then sKey = "ribbon"
            else
                sKey = "mesh " .. e.item.name
                if e.part.mesh.stripped then bad = bad + 1 end
            end
            out[#out + 1] = sKey
        end
        return table.concat(out, ";"), bad
    end''')
    busy = lua.eval('function() return #StormFX.Engine.tInstances + #StormFX.Engine.tCasts end')
    data = runtime.data
    resource_animations = {str(r.animation) for r in data.resources.values() if r and str(r.kind) == 'anm'}
    plays = [('script', name) for name in sorted(map(str, port.roots(package)))]
    plays += [('effect', name) for name in sorted(map(str, data.effects.keys())) if name not in resource_animations]
    out, bad, clock = {}, 0, 0
    for kind, name in plays:
        if kind == 'script':
            port.cast(ORIGIN, [ORIGIN[0] + 430.0, ORIGIN[1], ORIGIN[2]], scale, 1, package, name)
        else:
            port.play(package, name, ORIGIN, 0.0, scale, 1)
        rows = []
        for _ in range(FRAMES):
            clock += 1
            port.advance(clock)
            text, wrong = entries()
            bad += int(wrong)
            rows.append(Counter(item for item in str(text).split(';') if item))
            if busy() == 0:
                break
        port.stop()
        clock += 5
        out[f'{kind} {name}'] = rows
    built = int(lua.eval('''(function()
        local n = 0
        for _, tRuntime in pairs(StormFX.Engine.tPackages) do
            for _, tItem in pairs(tRuntime.items) do
                for _, tPart in ipairs(tItem.parts) do
                    if tPart.mesh.stripped and (tPart.buffer or tPart.rigidMeshes) then n = n + 1 end
                end
            end
        end
        return n
    end)()'''))
    return out, bad, built, dict(lua.eval('StormFX.Engine.tFailed').items()), int(lua.eval('StormFX.Engine.iUploads'))


if __name__ == '__main__':
    failures, report = [], {}
    source = sp.ADDON / 'lua/storm_fx/packages'
    for path in sorted(source.glob('*.lua')):
        package = path.stem
        slim_path = sp.OUT / 'lua/storm_fx/packages' / path.name
        if not slim_path.is_file() or slim_path.stat().st_mtime < path.stat().st_mtime:
            failures.append(f'{package}: no slim copy newer than the package (run slim_package.py)')
            continue
        stripped = sp.strippable(sp.read_package(path))
        if not stripped:
            continue
        whole, _, _, whole_failed, whole_uploads = run(package, False, True)
        slim, bad, built, slim_failed, slim_uploads = run(package, True, True)
        _, plain_bad, plain_built, plain_failed, _ = run(package, True, False)
        if whole_failed or slim_failed or plain_failed:
            failures.append(f'{package}: engine errors {whole_failed} {slim_failed} {plain_failed}')
        if bad or plain_bad:
            failures.append(f'{package}: {bad + plain_bad} stripped meshes in a draw list without their studio model')
        if built or plain_built:
            failures.append(f'{package}: {built + plain_built} meshes built for stripped parts')
        different = [name for name in whole if whole[name] != slim.get(name)]
        if different or set(whole) != set(slim):
            failures.append(f'{package}: the draw lists differ in {different}')
        studio_draws = sum(count for rows in slim.values() for row in rows for key, count in row.items() if key.startswith('studio'))
        if not studio_draws:
            failures.append(f'{package}: no studio model drawn in any play')
        report[package] = {
            'stripped meshes': [f'{model}#{index + 1}' for model, index in sorted(stripped)],
            'KB': {'whole': round(path.stat().st_size / 1024), 'slim': round(slim_path.stat().st_size / 1024)},
            'plays': len(whole), 'frames': sum(len(rows) for rows in whole.values()),
            'studio draws': studio_draws, 'mesh uploads': {'whole': whole_uploads, 'slim': slim_uploads}}
    report['failures'] = failures
    report['scope'] = 'Source entity API stub; no live GMod validation'
    (ROOT / 'captured_assets/procedural/slim_packages_check.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
    print(json.dumps(report, indent=1))
    print('FAIL' if failures else 'PASS: the slim packages draw what the whole ones draw, their stripped meshes only as studio models')
    sys.exit(1 if failures else 0)
