from pathlib import Path
for name in ('game_shader_generic_garrysmod.dll','stdshader_dx9.dll'):
 b=Path(r'C:\Program Files (x86)\Steam\steamapps\common\GarrysMod\bin\win64',name).read_bytes()
 print(name,len(b),{s:b.find(s.encode()) for s in ('C0_X','C3_X','C4_X','TCSIZE1','screenspace_general','PIXSHADER')})
