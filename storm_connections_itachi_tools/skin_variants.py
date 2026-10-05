"""Test variants of a studio model's GPU skinning, to find in game how Source hands a
screenspace_general vertex shader the bones of a hardware-skinned model.

From the GPU-skinned shader variant of a mesh (storm_import.py, studioGpuShader) it makes one
vertex shader per hypothesis on the vertex data (bone index order and scale, weight format),
and for each a copy of the model (models/storm_fx/<model>_<v>.mdl) whose own material
(materials/storm_fx/studio_<v>/) uses it. In game: storm_fx_studiotest <package> <model> 6 <v>.

  python skin_variants.py <package> <model>
"""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

from shader_port import SHADERS, compile_hlsl, package

ROOT = Path(__file__).resolve().parent
ADDON = ROOT.parent / 'storm_amaterasu_lab'
WORK = ROOT / 'game_cache' / 'studio'
STUDIOMDL = Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\studiomdl.exe')

# Bone indices (int4 bi) and the three weights (w0, w1, w2) of a vertex, by hypothesis
INDEX = {'color3': 'D3DCOLORtoUBYTE4(i.boneIndices) * 3', 'color1': 'D3DCOLORtoUBYTE4(i.boneIndices)',
         'byte3': '(int4)(i.boneIndices * 255.0 + 0.5) * 3'}
WEIGHTS = {'float': 'float2 bw = i.boneWeights.xy;', 'short': 'float2 bw = (i.boneWeights.xy + 1.0) / 32768.0;'}
VARIANTS = {'a': ('color3', 'short'), 'b': ('color1', 'short'), 'c': ('byte3', 'float'), 'd': ('byte3', 'short')}
# Material variants with the shader that does not skin (King's way: Source poses the model from
# its sequence): which .vmt parameter makes Source hand the bones to the shader instead
VMT_VARIANTS = {'e': ('$model',), 'f': ('$vertextransform',), 'g': ('$model', '$vertextransform'),
                'h': ('$model', '$vertextransform', '$vertexnormal', '$linearwrite', '$writealpha')}


def main() -> int:
    stem, model = sys.argv[1], sys.argv[2]
    text = (ADDON / 'lua/storm_fx/packages' / f'{stem}.lua').read_text(encoding='utf-8')
    match = re.search(r'\["studioGpuShader"\]=\{\["key"\]=\d+,\["vertex"\]="([^"]+)"', text)
    if not match:
        raise SystemExit('no GPU-skinned variant in the package')
    source = (SHADERS / f'{match.group(1)}.hlsl').read_text(encoding='ascii')
    skin = re.search(r'    int4 bi = .*?\n.*?float3x4 skin = [^\n]*\n', source, re.S)
    if not skin:
        raise SystemExit('skinning lines not found in ' + match.group(1))
    vmt = (ADDON / 'materials/storm_fx/studio' / f'{model}_mesh1.vmt').read_text(encoding='ascii')
    qc = (WORK / f'{model}.qc').read_text(encoding='ascii')
    game = WORK / 'game'
    for name, (index, weights) in VARIANTS.items():
        block = (f'    int4 bi = {INDEX[index]};\n    {WEIGHTS[weights]}\n'
                 '    float3x4 skin = float3x4(cModel[bi.x], cModel[bi.x + 1], cModel[bi.x + 2]) * bw.x'
                 ' + float3x4(cModel[bi.y], cModel[bi.y + 1], cModel[bi.y + 2]) * bw.y'
                 ' + float3x4(cModel[bi.z], cModel[bi.z + 1], cModel[bi.z + 2]) * (1 - bw.x - bw.y);\n')
        shader = f'storm_fx_skintest_{name}_vs30'
        hlsl = SHADERS / f'{shader}.hlsl'
        hlsl.write_text(source[:skin.start()] + block + source[skin.end():], encoding='ascii')
        binary = compile_hlsl(hlsl, 'vs_3_0')
        (ADDON / 'shaders/fxc' / f'{shader}.vcs').write_bytes(package(binary, hlsl.read_bytes()))
        folder = ADDON / 'materials/storm_fx' / f'studio_{name}'
        folder.mkdir(parents=True, exist_ok=True)
        (folder / f'{model}_mesh1.vmt').write_text(re.sub(r'"\$vertexshader" "[^"]+"', f'"$vertexshader" "{shader}"', vmt), encoding='ascii')
        variant_qc = WORK / f'{model}_{name}.qc'
        variant_qc.write_text(qc.replace(f'storm_fx/{model}.mdl', f'storm_fx/{model}_{name}.mdl')
                              .replace('"storm_fx/studio/"', f'"storm_fx/studio_{name}/"'), encoding='ascii')
        result = subprocess.run([str(STUDIOMDL), '-game', str(game), '-nop4', '-nox360', str(variant_qc)],
                                cwd=WORK, capture_output=True, text=True)
        if 'Completed' not in result.stdout:
            raise SystemExit(f'studiomdl failed for {name}:\n' + result.stdout[-2000:])
        for path in (game / 'models' / 'storm_fx').glob(f'{model}_{name}.*'):
            shutil.copyfile(path, ADDON / 'models' / 'storm_fx' / path.name)
        print(f'variant {name}: index {INDEX[index]}, weights {WEIGHTS[weights]} -> models/storm_fx/{model}_{name}.mdl')
    for name, dropped in VMT_VARIANTS.items():
        lines = [line for line in vmt.splitlines() if not any(f'"{p}"' in line for p in dropped)]
        folder = ADDON / 'materials/storm_fx' / f'studio_{name}'
        folder.mkdir(parents=True, exist_ok=True)
        (folder / f'{model}_mesh1.vmt').write_text('\n'.join(lines) + '\n', encoding='ascii')
        variant_qc = WORK / f'{model}_{name}.qc'
        variant_qc.write_text(qc.replace(f'storm_fx/{model}.mdl', f'storm_fx/{model}_{name}.mdl')
                              .replace('"storm_fx/studio/"', f'"storm_fx/studio_{name}/"'), encoding='ascii')
        result = subprocess.run([str(STUDIOMDL), '-game', str(game), '-nop4', '-nox360', str(variant_qc)],
                                cwd=WORK, capture_output=True, text=True)
        if 'Completed' not in result.stdout:
            raise SystemExit(f'studiomdl failed for {name}:\n' + result.stdout[-2000:])
        for path in (game / 'models' / 'storm_fx').glob(f'{model}_{name}.*'):
            shutil.copyfile(path, ADDON / 'models' / 'storm_fx' / path.name)
        print(f'variant {name}: shader without skinning, .vmt without {", ".join(dropped)} -> models/storm_fx/{model}_{name}.mdl')
    return 0


if __name__ == '__main__':
    sys.exit(main())
