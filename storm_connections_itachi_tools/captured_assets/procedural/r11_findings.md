# r11 Source binding and skill placement — 2026-10-02

## Real adapter fault repaired

GMod screenspace_general exposes custom pixel constants c0..c3. Its c4 is
engine-owned reciprocal base texture dimensions; $c4_x/y/z/w are absent from
the installed stdshader_dx9.dll parameter names. The old adapter attempted to
send custom sampler policy in c4 and omitted $tcsize1=2 for the fog input.

r11 packs address mode into unused c2.w, uses automatic c4.xy/2 for half texel,
and declares the second UV channel. This is a real binding repair, not visual
curve tuning. HLSL compiled for SM3 and VCS v6 package round-tripped. Live GPU
execution and parity are NOT established by compilation or API stubs.

Primary sources:
https://wiki.facepunch.com/gmod/Shaders/screenspace_general
https://raw.githubusercontent.com/ValveSoftware/source-sdk-2013/master/src/materialsystem/stdshaders/screenspace_general.cpp
Local parameter probe: inspect_gmod_shader_parameters.py.

## Model family adapter prepared

Original amt15 two-screen-film family now has SM3 vertex/pixel shaders and
model_source_renderer.lua. It preserves original geometry, UV/vertex colors,
film weights and blend/depth policy (SrcAlpha/InvSrcAlpha, depth test, no depth
writes). COLOR1 preserves original parameter output, but Source MRT/deferred
compositing is not yet connected. Fog omission is explicitly restricted to the
eight inspected amt15 draws with fog amount zero.

Mesh vertices upload once; matrices and four pixel vectors update on draws.
180 model draws in API stubs confirm no vertex uploads and required UV1/UV2.
Caller must supply actual recovered world matrix and full shader context;
missing inputs are rejected. It is not yet connected to live projectile births.

## Skill parameter rate conversion

XML float loader 0x140a67af0 compares Velocity, Inductivity and
VelocityRandomize. Getter 0x1405911a0 returns reference rate 30. Loader multiplies
float32 parsed value by float32(30/current global byte update rate +952), then
stores action float slot +10C+index*4. At rate 60, Velocity 25 loads as 12.5;
actor position integration also multiplies actorState+164 (producer pending).

## CONST_AXIS_UP resolved to native handler

String table 0x142060d50 -> enum getter 0x140a6c8f0. Event command stores shot
index at command+40 (loader event-array offset +90 with command base +50).
Dispatcher 0x140a6c450 indexes function table 0x141974e80:
0 default 0x140a6a8f0; 1 N-way 0x140a6bb10; 2 random 0x140a6bfa0;
3 enemy foot 0x140a6abe0; 4 enemy target 0x140a6b020; 5 hit 0x140a6b840;
6 hit foot 0x140a6bb00 (tail jump to enemy foot);
7 const-axis-up 0x140a6a5f0; 8 enemy-up-random 0x140a6b2e0.

CONST_AXIS_UP retains request position +10, reads direction +34, optionally
applies aim correction 0x140a6a340 when command+50 is set, obtains unit Z from
0x140136c20, projects direction off Z using dot and subtraction, normalizes when
squared length >0, otherwise uses unit X from 0x140145f60. It stores normalized
horizontal direction at new request+34 and unit Z at +40, then creates actor.
skill_shot_core.lua translates this math with explicit rate and prior aim input.
No original actor/world matrix parity asserted yet.

Actor orientation updater 0x140a61c20 uses normalized negative velocity for
second basis column, preserves old Z when forming first cross, with old-X
fallback. Builder 0x141281640 initializes identity and assigns three columns
via 0x141282250. This is an orientation updater, not the full effect setter;
prior notes calling it final actor/effect update are superseded.

## Remaining gates

Recover actual actor->effect root and actor+164 input; connect projectile/model
births and recovered parent fields; remaining resource/render families and
original RGB binding; shader MRT/deferred composition; independent geometry,
constants and pixel comparison; live performance. Exact final visual remains
unfinished. No new screenshot request for this incomplete stage.

## Actor-to-effect root link found after initial r11 notes

ccGameObjectSkill RTTI -> vtable 0x14188e4a8, virtual +78 is 0x1405e00c0.
This routine calls effect+28, builds T(actor+70/+74/+78), right-multiplies
actor orientation+AC, right-multiplies Ry(float32(float32(actor+EC*pi)/180)),
and scales columns 0..2 by actor+160, preserving the translation column.
It passes the resulting matrix to effect virtual+48 at 0x1405e0229, then
calls effect+30 with host delta, sets effect scale metadata through 0x1412baf40,
and calls effect+38. This establishes transform-before-animation order.

Ry builder 0x1412818a0 -> 0x1411ed680 uses cosf/sinf confirmed PE import thunks
0x1414430a2/0x1414430a8, with literal pi at 0x1417617e8 and 180 at 0x1417617ec.
Native packed matrix multiplication is the already verified 0x1411e7c00 helper;
scale 0x1411aee30 scales XYZ fields of each row and preserves its fourth field,
matching scaleColumns layout. skill_shot_core.effectRoot translates this chain.

actor+164 update is also found in 0x1405e6521..0x1405e6537: owner-character
virtual+E08 enables a modifier supplied by virtual+E10; otherwise it writes
1.0. This is a host motion multiplier, separate from XML rate-adjusted velocity.
Initialization still copies request+23C, so first-frame source value remains
to confirm. No claim of independently validated complete actor simulation.

Artifacts skill_effect_transform.asm and skill_effect_root.asm were investigation
candidate names: they contain event dispatch 0x1405e8690 and effect material
handling 0x1405e6ef0, respectively. Actual recovered root is skill_tick.asm.

Supersedes the earlier 'actor->effect root not found' gate. Remaining work is
recovering full actor orientation initialization/field binding and wiring this
root into the live projectile and particle scene, then verifying against original
world geometry. Root composition alone is not original visual parity.
