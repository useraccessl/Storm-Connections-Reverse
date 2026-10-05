from pathlib import Path
import lzma,struct
p=Path('../storm_amaterasu_lab/shaders/fxc/amt_motion_r6_ps30.vcs');raw=p.read_bytes()
print('header',struct.unpack_from('<13I',raw));size,packed=struct.unpack_from('<2I',raw,56);props=raw[64:69]
val=props[0];lc=val%9;val//=9;lp=val%5;pb=val//5;dictionary=struct.unpack_from('<I',props,1)[0]
decoder=lzma.LZMADecompressor(format=lzma.FORMAT_RAW,filters=[{'id':lzma.FILTER_LZMA1,'dict_size':dictionary,'lc':lc,'lp':lp,'pb':pb}])
unpacked=decoder.decompress(raw[69:69+packed],max_length=size)
print('size',len(unpacked),'expected',size,'prefix',unpacked[:32].hex());print(struct.unpack_from('<8I',unpacked))

