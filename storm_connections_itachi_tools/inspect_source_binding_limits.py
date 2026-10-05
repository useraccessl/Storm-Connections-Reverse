from pathlib import Path
import json
for name in ('game_shader_generic_garrysmod.dll','stdshader_dx9.dll'):
 b=Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\win64',name).read_bytes()
 print(name,{s:b.find(s.encode()+b'\0') for s in ('$c0_x','$c4_x','$tcsize1','c0_x','c4_x','tcsize1','C4_X')})
for number in (22082,22102):
 ds=json.loads(Path(f'gpu_captures/itachi_amaterasu_frame{number}.all_draws.json').read_text())
 for d in ds:
  if d.get('event') not in (5815,5833,5903,5921,5714,5732,5750,5768):continue
  fs=d['constants']['ShaderStage.Vertex']['perMaterialBuffer']['fields']
  print(number,d['event'],{k:v['values'] for k,v in fs.items() if k in ('g_fogParam','g_fogColor','g_commonParam','g_uvOffset2','g_uvOffset3','g_multColor','g_ambientColor')})
