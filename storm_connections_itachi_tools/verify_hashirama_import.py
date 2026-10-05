"""Exercise Hashirama's forest skill and four studio models with Source API stubs."""
import json
from pathlib import Path

from port_preview import Port, capture_camera
from game_data import GameData
from skill_script import load
from storm_import import import_skill, lua
from verify_package_shaders import plain


def main():
    port = Port(dict(capture_camera(22136), yaw=0), [0, 0, 0], (640, 360))
    runtime = port.load('1fir_x')
    assert port.roots('1fir_x') == ['1fireff1_jrt_e_begin00']
    assert len(list(runtime.data.skills.values())) == 8
    assert not list(runtime.data.unsupported.values())
    assert not dict(runtime.unsupported.items())
    original = load(GameData().fetch('data/skill/1fir_x.xfbin'))
    for name, script in runtime.data.skills.items():
        assert plain(script) == plain(port.lua.execute('return ' + lua(original[name]))), name
    try:
        import_skill('1fir_x', roots=['missing_script'])
    except SystemExit:
        pass
    else:
        raise AssertionError('missing selected script accepted')
    port.lua.execute('''
        STUDIO_TEST = {}
        function Material(name) return CreateMaterial(name, "screenspace_general", {}) end
        function ClientsideModel(name)
            local m = {name = name}
            function m:SetNoDraw() end
            function m:SetPos() end
            function m:SetAngles() end
            function m:SetRenderBounds() end
            function m:SetPlaybackRate() end
            function m:LookupSequence() return 0 end
            function m:ResetSequence() end
            function m:SetSequence() end
            function m:SetCycle(c) assert(c >= 0 and c <= 1) self.cycle = c end
            function m:EnableMatrix(_, mat) self.matrix = mat end
            function m:InvalidateBoneCache() end
            function m:SetupBones() end
            function m:Remove() end
            function m:DrawModel()
                assert(self.matrix and self.cycle)
                for _, v in ipairs(self.matrix.values) do
                    assert(v == v and math.abs(v) < math.huge)
                end
                STUDIO_TEST[self.name] = (STUDIO_TEST[self.name] or 0) + 1
            end
            return m
        end
    ''')
    port.cast([0, 0, 0], [500, 0, 0], 1, 1, '1fir_x', '1fireff1_jrt_e_begin00')
    for frame in range(240):
        port.advance(frame)
        port.collect()
    assert not port.instances(), 'skill did not drain'
    port.stop()
    port.play('1fir_x', '1fireff1_ptc01', [0, 0, 0])
    for frame in range(240, 480):
        port.advance(frame)
        port.collect()
    counts = dict(port.lua.globals().STUDIO_TEST.items())
    assert len(counts) == 3, counts
    # The water-ring emitters do not spawn in these scenarios. Exercise its
    # model's entity path explicitly, without changing the original emitters.
    studio = port.fx.StudioResource(port.fx, runtime, '1efc_wtr_ptc01')[1]
    port.fx.DrawStudio(port.fx, studio, 0.5, port.lua.globals().Matrix())
    counts = dict(port.lua.globals().STUDIO_TEST.items())
    assert len(counts) == 4, counts
    assert not dict(port.fx.tFailed.items()), dict(port.fx.tFailed.items())
    for _, resource in runtime.data.resources.items():
        if resource.studio:
            assert Path('../storm_amaterasu_lab/' + resource.studio.mdl).is_file()
            for part in resource.studio.parts.values():
                material = runtime.data.models[part.model].meshes[part.mesh].studioMaterial
                assert Path('../storm_amaterasu_lab/materials/' + material + '.vmt').is_file()
    report = {'draws': counts, 'failed': {}, 'scope': 'Source entity API stub; no live GMod validation',
              'water_model': 'DrawStudio called explicitly; water-ring emitters did not spawn in these scenarios'}
    Path('captured_assets/procedural/hashirama_studio_runtime_check.json').write_text(json.dumps(report, indent=2))
    print('PASS: eight scripts, four studio models drawn, valid cycles and matrices, all VMTs present', counts)


if __name__ == '__main__':
    main()
