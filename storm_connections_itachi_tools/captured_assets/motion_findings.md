# Reconstruction from the original effect files

The 180-frame recorder is not required for the next stage. It has not been
started on the original game. The seven existing captures remain references.

The correct 4efb_amt1 effect contains 24 emitter records, 15 billboard key
tables, 34 spatial bindings and 23 force bindings. These now export to
storm_amaterasu_lab/lua/storm_amt_lab/captured_runtime_data.lua, separate
from the obsolete 2efb diagnostic data. ANM transform channels include twelve
constant translation tracks and two animated rotation tracks. Impact
attachments are at Z=6, 189.6452, 287.0038 and -6.3818 original units.
Individual particle paths are produced procedurally, rather than supplied
as complete translation key sequences.

RTTI resolves nuccParticleForceFieldNode to vtable VA 0x141ba3df8.
Its update 0x141384fe0 resolves local/world direction and position. The force
application function is 0x141385ec0; dispatch at 0x14138656c has seven cases:

| Selector | Branch VA | Observed update |
| --- | --- | --- |
| 0 | 0x1413860fb | Vortex rotation, resulting displacement |
| 1 | 0x141386242 | Add to scalar speed, clamp negative result to zero |
| 2 | 0x141386290 | Add radial velocity toward field center |
| 3 | 0x141386330 | Directly translate particle along resolved direction |
| 4 | 0x14138638d | Add Euler rotation parameters |
| 5 | 0x141386404 | Add size parameters |
| 6 | 0x141386472 | Add directional velocity |

The data pointer is runtime force record +0x40, corresponding to file +0x30.
Config +0x08 is base radius, +0x0c falloff mode, +0x10 strength, +0x14 strength
modifier and +0x20 vector parameters. Radius is multiplied by the resolved
direction length. Strength is multiplied by (1+modifier), particle +0x208,
and the simulation step. A bounded field skips squared distance >= radius².
Falloff mode 1 is 1-distance/radius; mode 2 is distance/radius.
Selector 1 does not multiply its speed change by the falloff factor.
The original tiny-value threshold is FLT_MIN, VA 0x141860548.

Integration at 0x141386b70 computes step=particle simulation Hz/game FPS
times the current update factor. It adds velocity*speed*step, parent
displacement*speed, and a secondary velocity*speed*step to position.
The underlying add helper 0x1411ab760 was verified as XYZ addition.

particle_motion_core.lua now ports all seven branches. The vortex helper
0x1411f1870 forms the axis quaternion using sin(angle/2), cos(angle/2), with
the 0.5 float at VA 0x14176a448. Imports at 0x141735ef0/0x141735f40 resolve
to sinf/cosf. 0x1411bb590 builds the 3x3 matrix and 0x1411bcea0 applies its
rows. Selector 0 adds rotate(position-center)-position+center to +0x1dc;
integration multiplies this displacement by particle speed (not by step
again). Its angle is strength*falloff*scalar*step/directionLength. A zero
axis skips the force. Tests cover handedness, center, direction length,
speed and displacement reset.
verify_file_motion.py checks the extracted counts and direct translation,
velocity integration, speed clamping and bounded falloff. This is a research
module, not yet integrated into the GMod renderer. Attachment composition,
force scheduling, RNG/spawn ordering and vortex rotation still require work
before claiming an exact continuous animation. No interpolated GPU particle
identities are assumed and no new visual test command is installed here.

## File-derived resource coverage and spawn arithmetic

export_procedural_assets.py now exports all 17 referenced billboard meshes,
their original vertex colors, triangle indices, material descriptors, eight
texture NUT files and key tables. amt02/03 each have 369 vertices; amt04/06
215; shared part09b 468 and part11b 76. These were missing from r6, which only
includes amt00/01/05/07. The lateral silhouettes are actual meshes, not
texture modifications to the primary quad. Five referenced clump/animation
players remain unsupported: amt1_ptc02, light00, fire03a, shock09, nor_dst03.

particle_spawn_core.lua translates confirmed resource selection, lifetime,
scalar and size randomization. Resource selection uses integer rand modulo
count and consumes no random draw for a single resource. Interval sampling
at 0x1412cd630 is upper-u*(upper-lower), not lower+u*range. Independent size
randomization at 0x14131d4d7 samples Z, Y, X; config byte +6 bit 0 confirms
independentSizeRandom. Direction 0 at 0x14131d982 points outward from the
center; direction 1 points inward. The old decoded diagnostic had these
inverted. Direction 3 still requires the caller's original cone/attachment
transform; there is no guessed replacement.

procedural_runtime.lua connects these helpers with all seven force branches
and the original size/fade evaluator. Its required caller inputs are the
resolved spawn transform, ordered field list and parent displacement. It
does not load measured transforms. It is not yet connected to the GMod
visual player, since the scene graph and emission activation are incomplete.
The validated r6 visual command remains an interpolation-based reference.

Disassembly now follows chained PE unwind entries, including sibling regions,
to preserve complete optimized functions instead of decoding partial blocks.
