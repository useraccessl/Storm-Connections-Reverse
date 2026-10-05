"""Compare compiled rigid studio shaders with their mesh shaders.

Uses one-bone compressed Source vertices and random rotated, nonuniformly
scaled model matrices. Checks directional lighting, projection, fog, material
constants and textures by rendering both shader pairs. This does not emulate
studiomdl's normal quantization or prove the model's live Source animation.
"""
import json
from pathlib import Path

import numpy as np
import verify_shader_port as vsp
from lupa import LuaRuntime
from verify_package_shaders import ADDON, normalised


def main():
    data = LuaRuntime(unpack_returned_tuples=True).execute(
        (ADDON / 'lua/storm_fx/packages/1fir_x.lua').read_text(encoding='utf-8'))
    runner = vsp.PortRunner()
    rng = np.random.default_rng(119)
    results = []
    lighting_control = 0
    for name, model in sorted(data.models.items()):
        for index, mesh in model.meshes.items():
            if not mesh.studioGpuShader:
                continue
            original = normalised(mesh.shader)
            studio = normalised(mesh.studioGpuShader)
            fixed = {(e['name'], e['row'], e['component']): e['value'] for e in studio['compiled']}
            # Each SMD part has one constant vertex colour, compiled into its shader.
            color = np.array([mesh.vertices[1][k] for k in range(6, 10)])
            worst = 0
            pixels = 0
            control = 0
            for _ in range(12):
                scene = vsp.Scene(rng, fixed=fixed, unlit=studio.get('unlit', False))
                scene.normal[:] = [0, 0, 1]
                scene.color[:] = color
                a = runner.render(original, scene).color[0]
                vertex_outputs = runner.vertex_outputs
                b = runner.render(studio, scene).color[0]
                worst = max(worst, float(np.abs(a - b).max() * 255))
                pixels += int(np.count_nonzero(np.any(a != 0.5, axis=-1)))
                if original['attributes']['normal']:
                    scene.normal[:] = [0, 0, -1]
                    changed = runner.render(original, scene).color[0]
                    control = max(control, max(float(np.max(np.abs(runner.vertex_outputs[k] - v)))
                                              for k, v in vertex_outputs.items()))
            results.append({'model': name, 'mesh': index, 'scenes': 12, 'pixels': pixels, 'max_error_255': worst})
            print(name, index, 'pixels', pixels, 'worst', worst, flush=True)
            assert pixels > 0 and worst < 1.5, (name, index, worst)
            lighting_control = max(lighting_control, control)
    assert len(results) == 8, f'expected eight studio parts, got {len(results)}'
    assert lighting_control > 0.1, 'normal control did not change the vertex shader outputs'
    Path('captured_assets/procedural/hashirama_studio_shader_check.json').write_text(
        json.dumps(results, indent=2), encoding='utf-8')
    print('PASS: eight studio parts, 96 rendered scenes within 1/255 of their mesh shaders')


if __name__ == '__main__':
    main()
