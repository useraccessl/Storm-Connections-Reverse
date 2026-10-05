from pathlib import Path
import json,struct,sys
sys.stdout.reconfigure(encoding='utf-8')
from cpk_index import list_archive,extract_entry
from xfbin_chunks import parse
root=Path('captured_assets')
archive=Path(r'C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS\data\launch\data1.cpk')
header,entries=list_archive(archive)
entry=next(e for e in entries if str(e.get('DirName',''))+'/'+str(e['FileName'])=='data/skill/4efb_amt1_x.xfbin')
path=extract_entry(archive,header,entry,root);data,chunks=parse(path)
out=root/'skill_xml';out.mkdir(exist_ok=True)
for c in chunks:
 if c['type']!='nuccChunkBinary':continue
 raw=data[c['offset']:c['offset']+c['size']];n=struct.unpack_from('>I',raw)[0];assert n<=len(raw)-4
 s=raw[4:4+n].decode('cp932');assert s.lstrip().startswith('<?xml')
 s=s.replace('encoding="Shift_JIS"','encoding="UTF-8"',1)
 (out/(c['name']+'.xml')).write_text(s,encoding='utf-8')
 print(c['name']);print(s)

