from pathlib import Path
root=Path('.')
p=root/'quaternion_animation_core.lua';s=p.read_text(encoding='utf-8-sig')
start=s.index('-- Packed 3x3 basis');end=s.index('\nend',start)+4
block=s[start:end]
assert s.count(block)==3
s=s.replace(block+'\n','')
pos=s.rfind('return Q\n');assert pos>0
s=s[:pos]+block+'\n'+s[pos:]
p.write_text(s,encoding='utf-8')
(root/'../storm_amaterasu_lab/lua/storm_amt_lab/quaternion_animation_core.lua').write_text(s,encoding='utf-8')
p=root/'anm_resource_core.lua';s=p.read_text(encoding='utf-8-sig')
new='''-- Original effect controller owns the local clock; host delta remains external.
function A.newPlayer(compiled, ticks, speed)
    local clock=assert(compiled.modules.clock, 'ANM clock module required')
    return {compiled=compiled, clock=clock.new(compiled.duration,compiled.loop,ticks,speed)}
end
function A.advance(player, delta, materialInstances)
    local compiled=player.compiled
    local result,step=compiled.modules.clock.advance(player.clock,delta,compiled.options.float32)
    return A.evaluate(compiled,player.clock.ticks,materialInstances),result,step
end
'''
s=s.replace('return A\n',new+'return A\n');p.write_text(s,encoding='utf-8')
(root/'../storm_amaterasu_lab/lua/storm_amt_lab/anm_resource_core.lua').write_text(s,encoding='utf-8')
p=root/'verify_anm_clock_native.py';s=p.read_text(encoding='utf-8-sig');s=s.replace(";struct.pack_into('<Hii',data,0x38,flags,0,0) if False else None",'');p.write_text(s,encoding='utf-8')
p=root/'evaluate_amt15_native_anm.py';s=p.read_text(encoding='utf-8-sig')
s=s.replace("'material':module('material_animation_core')", "'material':module('material_animation_core'),'clock':module('anm_clock_core')")
s=s.replace("'scope':'Evaluates local ANM channels and 3x3 rotation basis. Host clock, world matrix, factory mode and final rendering still require validation.'", "'scope':'Evaluates local ANM clock, channels and 3x3 basis. Caller cadence, world matrix, factory mode and rendering still require validation.'")
s=s.replace("assert instances[2][0x84]==255",'''assert instances[2][0x84]==255
player=a.newPlayer(compiled,0,1)
report['loopTimeline']=[]
for _ in range(40):
 result,overflow,step=a.advance(player,50,instances)
 report['loopTimeline'].append(player.clock.ticks)
 assert overflow==-1 and step==50
assert report['loopTimeline'][:18]==[50,100,150,200,250,300,350,400,450,500,550,600,650,700,750,800,50,100]''')
p.write_text(s,encoding='utf-8')
