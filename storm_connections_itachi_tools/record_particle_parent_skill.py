from pathlib import Path
import json,xml.etree.ElementTree as E,hashlib
root=Path('.')
xmls=root/'captured_assets/skill_xml';skills={}
for path in sorted(xmls.glob('*.xml')):
 node=E.parse(path).getroot();actions=[]
 for a in node.findall('./Actions/Action'):
  actions.append({'attributes':a.attrib,'parameters':{c.tag:c.attrib for c in a if c.tag not in ('Event','SoundEffect')},'events':[{'attributes':event.attrib,'effects':[c.attrib for c in event.findall('Effect')]} for event in a.findall('Event')],'sounds':[c.attrib for c in a.findall('SoundEffect')]})
 skills[node.attrib['id']]={'source':str(path),'sha256':hashlib.sha256(path.read_bytes()).hexdigest(),'attributes':node.attrib,'files':[c.attrib for c in node.findall('./Files/File')],'actions':actions}
assert skills['4efb_amt1_e_blt00']['actions'][0]['parameters']['Velocity']['value']=='25'
assert skills['4efb_amt1_e_blt00']['actions'][0]['parameters']['Animation']['chunk']=='4efb_amt1_blt00'
assert skills['4efb_amt1_e_hit00']['actions'][0]['parameters']['Animation']['chunk']=='4efb_amt1_hit00'
(root/'captured_assets/procedural/skill_action_graph.json').write_text(json.dumps({'skills':skills,'scope':'Original XML values preserved. Frame cadence, movement scale and shot-type placement require native runtime semantics; no unit conversion assumed.'},indent=2)+'\n',encoding='utf-8')
notes='''# Particle parent matrices and original skill phase graph — 2026-10-02

## Particle parent formation

0x141386d45 retains previous travel direction when movement length is tiny.
0x141386e2a..0x14138710f constructs the non-BB parent matrix at particle+A0:
identity; optional travel basis; position; right Euler rotation; column scale.
Travel basis columns are perpendicular, negative travel direction, and their
cross product. Perpendicular is (negativeY, -negativeX, 0), with vertical
special case (-negativeZ, 0, negativeX). Zero direction uses identity when
all component magnitudes are strictly below float32(0.001).

Orientation formation uses rotation_selector_0x14 = 2 or 3 to enable travel
alignment via particle+17C. This includes projectile emitter 4 (animated amt15).
A model does not use the billboard camera-facing transform.

Rotation dirty flag +178 gates angle quantization/cached Euler +154. Quantizer
0x1412ccd80 has 1,048,576 angular units, different from billboard roll units.
Euler wrapper 0x1412c4330 swaps input args before 0x1411b8760. The module API
uses stored +94/+98/+9C order. Import thunks are UCRT cosf/sinf (confirmed PE
imports). 4x4-by-3x3 helper 0x1411e7e40 preserves the fourth column and uses
three-term scalar grouping, unlike the SIMD 4x4-by-4x4 helper.

Scale before particle+A0 is float32(float32(+1F4_i * +88_i) * +108).
If any component is <= smallest positive normal float, +218 is cleared and
scale is skipped. Lifecycle +1B0 scale is applied separately during model render.
Semantic origins of all these fields and dirty state remain required host inputs.

particle_matrix_core.lua translates these math paths. Native comparisons:
3,003 Euler, 3,003 normalization, 3,004 quantization, 3,000 right-basis products.
verify_particle_travel_native.py executes original prefix 0x141386e7a..0x141386f55
with its original setters/normalizer/cross: 3,004 byte-exact three-vector cases.
Full original particle updater was not executed; host follow/force/cadence and
world conversion are not proven by helper comparisons.

model_effect_instance.lua now joins parent + lifecycle scale + ANM clock advance
+ coordinate hierarchy. Forty file-driven amt15 updates pass, including endpoint
800 and wrap to 50. Diagnostic position/direction/scale are explicitly synthetic,
not live skill input. No captured points used. No new GMod deployment yet.

## Exact variant skill script extracted

extract_captured_skill_xml.py extracts data/skill/4efb_amt1_x.xfbin from data1.cpk
and decodes every XML payload. Paths and original attributes preserved in
skill_action_graph.json. Do not use the older 2efb_amt script as this variant.

4efb_amt1_e_begin00 is ARROW, velocity 1, collisions disabled, frame event 1
kills it and launches 4efb_amt1_e_blt00 with DEFAULT shot type.
4efb_amt1_e_blt00 is CRAWLER, animation 4efb_amt1_blt00, velocity 25,
inductivity 0.20, viewing angle 360. Character default and world wall events
kill it and launch 4efb_amt1_e_hit00 with CONST_AXIS_UP. Skill collision uses
HIT_FOOT. Frame event 120 also launches the impact with CONST_AXIS_UP. Guard
and substitution kill without launching this impact. Animation end kills it.
Impact is action NONE, animation 4efb_amt1_hit00, ends with its animation.
There is no single fixed projectile-to-impact delay covering every collision.

The same archive also contains amt2 scripts with ENEMY_FOOT placement and
15-frame behavior; do not mix these with amt1. Selecting the actual character
parameter route and original shot-type placement are still required.

## CRAWLER actor located

RTTI ccSkillActorCrawler -> vtable 0x14188e5e8. Initialization 0x140a6e430,
update 0x140a6e0d0. Initialization calls shared setup 0x140a6cb10 and saves
velocity length as actor+20. Update adds actorState+A0 velocity * actorState+164
into position +70/+74/+78. Positive vertical velocity is normalized in 3D and
scaled by initial speed; descending velocity renormalizes horizontal components
and preserves its original vertical component. Coordinate space here uses Z
for vertical; NUCC parent mapping remains a separate conversion.

Ground query 0x140a620a0 inspects up to 8 world hits. Crawler accepts geometry
whose flags masked by 0x20000002 equal that mask and snaps position Z to hit Z.
If query fails, it subtracts a literal divided by update rate from vertical
velocity except stage id 0x89. Guidance 0x140a61fa0 and final actor/effect update
0x140a61c20 are still to trace. XML Velocity getter is 0x140a61ec0, action
float slot +10C + index*4; base setup uses indices 0x10/0x11 for speed plus
randomness. Velocity-to-XML binding, actor+164 producer, ground-query shape and
CONST_AXIS_UP placement are not yet validated. No units/sec conversion claimed.

## Remaining visual gates

Connect actual skill actor/shot transforms and particle field producers; finish
all BB/model players and geometry coverage; port shader MRT/compositing/sampler
states; compare draw constants and final pixels; then measure live performance.
The thin ground trail has not yet been uniquely assigned to an original draw.
'''
(root/'captured_assets/procedural/particle_parent_skill_findings.md').write_text(notes,encoding='utf-8')
for path in (root/'../NEXT_STEPS.md',root/'../MOTEUR_EFFETS_REVERSE.md'):
 s=path.read_text(encoding='utf-8-sig');s+='\n## Particle parent and skill graph — 2026-10-02\n\nNative Euler, travel basis, angle quantization and 4x4-by-3x3 helpers are\ntranslated and verified. Model parent/size/ANM bridge is prepared. Correct\n4efb_amt1 skill XML now extracted: ARROW launch -> CRAWLER (velocity 25) ->\nhit00 on contacts/frame 120, with explicit shot-axis placement. CRAWLER RTTI\nand update are located; actual unit conversion, guidance and ground query\nremain gates. Details: storm_connections_itachi_tools/captured_assets/procedural/particle_parent_skill_findings.md.\nNo new visual deployment or final parity claim.\n';path.write_text(s,encoding='utf-8')
print('Recorded original skill graph, particle matrices and precise remaining gates.')
