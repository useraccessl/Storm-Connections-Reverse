"""Compare simulation and rendered output with a saved clean-engine baseline.

Uses both exact Lua and LuaJIT, including studio particles, transformed roots,
changing rotations, first-play recording/replay and all seven installed packages.
Performance figures exclude graphics and use a simulated scheduler clock (no
budget throttling), so they measure equal workloads, not predicted game FPS.
"""
import argparse
import json
import statistics
import time
from pathlib import Path

import port_preview
from verify_clean_engine import Pair
from lupa.lua55 import LuaRuntime as ExactLua
from lupa.luajit21 import LuaRuntime as JitLua

ROOT = Path(__file__).resolve().parent
CANDIDATE = port_preview.CLEAN
CAMERA = dict(position=[-400, 0, 80], forward=[1, 0, 0], right=[0, -1, 0], up=[0, 0, 1], yaw=0)
STUDIO = r'''
function Material(n) return PREVIEW.materials[n] or CreateMaterial(n, 'screenspace_general', {}) end
function ClientsideModel(n)
 local e={}
 for _,k in ipairs({'SetNoDraw','SetPos','SetAngles','SetRenderBounds','SetPlaybackRate','ResetSequence','SetSequence','SetCycle','Remove','InvalidateBoneCache','SetupBones'}) do e[k]=function() end end
 e.LookupSequence=function() return 0 end
 e.EnableMatrix=function(self, _, m) self.matrix=m end
 e.DrawModel=function(self)
  local values={}; for i=1,16 do values[i]=self.matrix.values[i] end
  PREVIEW.studioDraws[#PREVIEW.studioDraws+1]={mdl=n, matrix=values}
 end
 return e
end
PREVIEW.studioDraws={}
'''


def make(source, runtime=ExactLua, studio=False):
    port_preview.CLEAN, port_preview.LuaRuntime = source, runtime
    try:
        p = port_preview.Port(CAMERA, [0, 0, 80], (640, 360))
    finally:
        port_preview.CLEAN = CANDIDATE
    if studio:
        p.lua.execute(STUDIO)
    return p


def plain(v):
    if v is None or isinstance(v, (bool, int, float, str)):
        return v
    if hasattr(v, 'items'):
        return {str(k): plain(x) for k, x in v.items() if type(x).__name__ != '_LuaFunction'}
    return str(v)


def state(p):
    fields = ['resource', 'life', 'alive', 'ageTicks', 'position', 'previousPosition', 'size', 'color',
              'rotation', 'velocity', 'secondaryVelocity', 'displacement', 'alpha', 'lifecycleSize',
              'modelSize', 'modelDirection', 'modelEnabled', 'modelUpdates', 'studioPose']
    out = []
    for inst in p.instances():
        particles = []
        for part in (inst.scene.particles.values() if inst.scene else []):
            row = {k: plain(part[k]) for k in fields}
            row['modelDraws'] = [plain(d) for d in (part.modelDraws.values() if part.modelDraws else [])]
            particles.append(row)
        trails = [(s.animation.name if s.animation else None, bool(s.released), [(t.updates, plain(t.state)) for t in s.trails.values()])
                  for s in inst.trailSets.values()]
        out.append((inst.effect, inst.frame, inst.ticks, bool(inst.failed), particles, trails))
    return out


def compare(baseline, package, effect=None, script=None, frames=150, studio=False, runtime=ExactLua,
            transformed=False, changing=False, replay=False, copies=1):
    ports = [make(path, runtime, studio) for path in (baseline, CANDIDATE)]
    for p in ports:
        if effect:
            for i in range(copies):
                handle = p.play(package, effect, [0, 0, 80], scale=64/119, seed=i+1)
                assert handle and not (isinstance(handle,tuple) and handle[0] is None), (package,effect,handle)
        else:
            p.cast([0, 0, 0], [5000, 0, 0], scale=64/119, seed=1, package=package, script=script or p.roots(package)[0])
    pair = Pair.__new__(Pair)
    pair.ports, pair.static = ports, {}
    for f in range(1, frames + 1):
        for p in ports:
            if replay and f == frames // 2:
                p.stop()
                handle = p.play(package, effect, [0, 0, 80], scale=64/119, seed=1)
                if isinstance(handle,tuple): handle=handle[0]
                assert handle and handle.replay is not None, (package,effect,'recording not completed before replay')
            for inst in p.instances():
                if transformed:
                    inst.root[4], inst.root[8] = (0.0,0.0) if f % 11 < 3 else (float(f % 19),float(f % 7))
                if changing and inst.scene:
                    for part in inst.scene.particles.values():
                        if f % 7 == 0:
                            part.rotation[1] += 0.125
            p.advance(f)
        assert state(ports[0]) == state(ports[1]), (package, effect or script, f, 'simulation differs')
        if f % 5 == 0 or f <= 3:
            for p in ports:
                p.lua.globals().PREVIEW.studioDraws = p.lua.table()
            errors = pair.compare(f)
            assert not errors, errors[:3]
            assert plain(ports[0].lua.globals().PREVIEW.studioDraws) == plain(ports[1].lua.globals().PREVIEW.studioDraws), (package, f, 'studio draws differ')
    return dict(package=package, effect=effect, script=script, frames=frames, studio=studio,
                runtime='LuaJIT' if runtime is JitLua else 'exact Lua', transformed=transformed,
                changing_rotations=changing, replay=replay, copies=copies, result='PASS')


def bench(source, count, transformed):
    p = make(source, JitLua)
    p.lua.execute('function ClientsideModel() end; function tick(f) PREVIEW.now=f/60; hooks.Think() end')
    for i in range(count):
        inst = p.play('4efb_gkk1_x', '4efb_gkk1_blt00', [0, 0, 80], scale=64/119)
        if isinstance(inst, tuple):
            inst = inst[0]
        if transformed:
            inst.root[4] = float(i + 1)
    g = p.lua.globals()
    for f in range(1, 241):
        g.tick(f)
    samples = []
    for f in range(241, 481):
        t0 = time.perf_counter()
        g.tick(f)
        samples.append((time.perf_counter() - t0) * 1000)
    p.lua.execute('collectgarbage("collect");collectgarbage("stop");HEAP0=collectgarbage("count")')
    for f in range(481, 541):
        g.tick(f)
    allocated = (p.lua.eval('collectgarbage("count")') - g.HEAP0) / 1024
    p.lua.execute('collectgarbage("restart")')
    return dict(mean_tick_ms=statistics.mean(samples), p95_tick_ms=sorted(samples)[228],
                peak_tick_ms=max(samples), allocated_MiB_per_second=allocated)


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument('--baseline', type=Path, default=ROOT/'captured_assets/procedural/simulation_optimization_baseline')
    parser.add_argument('--bench-only', action='store_true')
    args = parser.parse_args()
    assert (args.baseline/'lua/autorun/sh_storm_fx.lua').is_file()
    results = []
    if not args.bench_only:
        cases = [
            dict(package='4efb_gkk1_x', effect='4efb_gkk1_blt00', frames=300, studio=True),
            dict(package='4efb_gkk1_x', effect='4efb_gkk1_blt00', frames=150, studio=True, transformed=True, changing=True),
            dict(package='4efb_gkk1_x', effect='4efb_gkk1_blt00', frames=150, studio=False),
            dict(package='4efb_gkk1_x', script='4efb_gkk1_e_begin00', frames=240, studio=True),
            dict(package='4efb_gkk1_x', effect='1efc_exp_hit01', frames=900, studio=True, replay=True),
            dict(package='4efb_amt1_x', effect='4efb_amt1_hit00', frames=900, replay=True),
            dict(package='1fir_x', script='1fireff1_jrt_e_begin00', frames=300, studio=True),
        ]
        cases += [dict(package=pkg,effect=effect,frames=150,studio=True) for pkg,effect in
                  [('2efb_rsn_x','2efb_rsn_hit00'),('2ksm_x','2ksmeff1_skl3_blt00'),
                   ('3efb_3ssk1_x','3efb_3ssk1_blt01'),('3efbtf_rsn1_x','3efbtf_rsn1_hit00')]]
        cases += [dict(package='4efb_gkk1_x',effect='4efb_gkk1_blt00',frames=180,studio=True,
                       transformed=True,copies=3)]
        cases += [dict(package='4efb_gkk1_x', effect='4efb_gkk1_blt00', frames=180, studio=True,
                       transformed=True, changing=True, runtime=JitLua)]
        for case in cases:
            row = compare(args.baseline, **case)
            results.append(row)
            print('PASS', case, flush=True)
    benchmarks = []
    for count, transformed in [(1,False),(8,False),(32,False),(8,True)]:
        old, new = (bench(src,count,transformed) for src in (args.baseline,CANDIDATE))
        row = dict(fireballs=count,transformed=transformed,baseline=old,optimized=new,
                   allocation_reduction_percent=100*(1-new['allocated_MiB_per_second']/old['allocated_MiB_per_second']),
                   mean_tick_reduction_percent=100*(1-new['mean_tick_ms']/old['mean_tick_ms']))
        benchmarks.append(row)
        print('BENCH',json.dumps(row),flush=True)
    report=ROOT/'captured_assets/procedural/simulation_optimization_verification.json'
    report.write_text(json.dumps(dict(scenarios=results,benchmarks=benchmarks,
        limitations='Offline LuaJIT, rendering absent in benchmarks, simulated clock disables budget throttling; not measured in live GMod.'),indent=2)+'\n',encoding='utf-8')


if __name__ == '__main__':
    main()
