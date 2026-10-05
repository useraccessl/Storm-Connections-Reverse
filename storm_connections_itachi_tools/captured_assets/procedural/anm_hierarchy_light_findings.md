# Coordinate hierarchy, timestamp rotations and point lights — 2026-10-02

## Hierarchy and parent injection

RTTI: nuccCoord vtable 0x141b924d8, update 0x141289db0; nuccClump
vtable 0x141b926f8, update 0x14128d0b0. Coordinate world = parent world
multiplied by local matrix. Root clumps copy their local matrix. Active world
storage is double-buffered at +7C + (byte +120 << 6), local matrix at +3C.
Identity initializer 0x1400a4ad0 populates runtime 0x149707f10 from literal
identity rows. Local controller composition is translation * rotation followed
by column scale. Target translation scale +FC/+100/+104 is a required input.
Particle render 0x14130b5a2 scales particle+A0 columns by +1B0, then injects
through ANM vtable+48, nuccAnmEffect 0x1412baeb0. Parent formation before this
injection and host placement still require integration/independent verification.

anm_matrix_core.lua and anm_resource_core.lua now assemble local and hierarchical
world matrices. Diagnostic identity root/unit translation scale are explicit
caller assumptions, not recovered host transforms. No captured position input.

## Timestamp quaternion format 10

Reader 0x141391db0 uses 20-byte records: uint32 time plus quaternion float4.
Signed exported -1 is the unsigned UINT32_MAX sentinel. Cached forward/reverse
search advances at exact next-key times. Inputs conjugate XYZ; interpolation
always invokes the original slerp, including zero weight. Do not substitute the
compressed-reader endpoint policy. verify_timestamp_quaternion.py compares
5,000 ratios against original prefix 0x141391e0a..0x141391e31. Another 100 file
samples exercise statically translated traversal/conjugation using the previously
verified slerp; the full original timestamp reader was not executed.

## Type 6 is a point light: correction to provisional generator label

Loader construction 0x14134b8ed calls factory 0x141390240. RTTI names its
controller nuccChunkAnmCtrlLightPoint. Constructor 0x14139cdc0 uses five forced
linear samplers, not material hold context. Runtime 0x14139cfa0 writes:

- channel 0 RGB -> +50/+54/+58, alpha +5C = 1;
- channel 1 scalar -> +60;
- channel 2 position XYZ -> +70/+74/+78;
- channel 3 scalar -> +88;
- channel 4 scalar -> +8C;
- target virtual +20 is then invoked for update/invalidation.

Physical meanings of the three scalars are not assigned before light binder
tracing. Target named 4efb_amt1_blt00 does not make this an emission generator.
Earlier references to generator ANM entries are superseded by this evidence.
Actual emitter activation/projectile trajectory remain separate gates.

Color format 20 reader 0x141395000 is translated in color_animation_core.lua.
RGB byte interpolation occurs before /255, with float32 rounding each operation.
verify_color_animation_native.py passes 4,121 byte-exact original-reader cases,
including 121 file samples. Original tail setter is preserved and guards checked.

## Complete file ANM diagnostic coverage, not complete effect coverage

evaluate_effect_anm.py evaluates all 4 hit00 entries over 101 ticks and all 8
blt00 entries over 121 ticks (50-tick increment, endpoints included). Formats
5,10,11,12,17,20,22,27 are supported where recovered. This includes the point
light and parent coordinate rotations, including nonidentity projectile quaternions.
All matrices are finite. Host inputs, particles, rendering and final compositing
are not established by this diagnostic. No new GMod visual deployment yet.
