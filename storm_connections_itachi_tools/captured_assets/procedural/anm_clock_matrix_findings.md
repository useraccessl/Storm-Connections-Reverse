# ANM local clock and model matrix math — 2026-10-02

## Class identification prevents mixing clock families

RTTI identifies vtable 0x141ba4c08 as nuccSpriteAnm. Its clock 0x14138fc30
has different fields and ownership and is NOT wired into the effect runtime.
identify_anm_classes.py and inspect_animation_clock.py preserve the probes.
nuccAnmEffect vtable is 0x141ba15d0; nuccAnm is 0x141b94bf0.

## File duration and loop flag reach the shared effect clock

0x1412a3c90 copies ANM +0xDA flags into object +0x38, initial ticks into
+0x3C, duration ANM +0x88 into +0x40 and initializes speed +0x48 to 1.
Effect update 0x14136bc90 converts signed delta to float32, multiplies by
speed, truncates to int32, adds into +0x3C, calls 0x1412a3c30, and then updates
its external attachment. nuccAnm update 0x1412af8f0 also uses this resolver
when no transition resource is active.
Effect evaluation 0x14136bb60 passes +0x3C unchanged to 0x141383690; the latter
calls each live controller's vtable+8 with those ticks in r8d. Material
controller 0x14139d440 and coordinate controller 0x1413679d0 occupy that slot.

Resolver 0x1412a3c30 does NOT add delta itself. Positive advancement only
wraps/clamps when time > duration; equality preserves the last key. Looping
returns -1. Nonlooping returns overshoot and clamps. Reverse looping uses
`duration - ((-ticks) % duration)`, so exact negative multiples resolve to
`duration`. Nonlooping reverse clamps to zero and returns the negative time.
Nonpositive delta follows the reverse branch, including zero. Reverse-loop
zero duration is an original divide-by-zero path; the Lua module rejects it.

anm_clock_core.lua translates these rules; verify_anm_clock_native.py runs
10,576 cases against the bounded original 96 bytes. Clock and return values
match exactly; other object bytes remain unchanged. The update's float32
prefix is statically transcribed, not independently executed as a whole.
A.newPlayer/A.advance connect the local clock to the generic ANM reader.

## Material mode context

Global object byte +0x952 is an update rate. Constructor 0x14129a900 sets it
to 30. Setter 0x14129f100 accepts divisors of 60 or substitutes 60, with
object+0x4A0 = 60/rate. Zero input is not a supported path. Material factory
0x1413904d0 selects hold for conditional channels when rate == 60 and its
third argument is zero; channels 12..17 and 22 are forced linear.
Loader stage-path exception flag semantics need further tracing. Normal
effect paths leave that argument zero. Capture runtime rate is not recovered;
the diagnostic explicitly chooses linear and does not claim live-mode parity.

## Model coordinate matrix path

0x1413679d0 reads translation (+0x10), rotation (+0x18), scale (+0x20), and
opacity (+0x28) samplers. Translation is multiplied componentwise by target
+0xFC/+0x100/+0x104. Copy helper 0x1411ae2c0 does not swizzle these components.
Rotation reader 0x141394710 samples quaternion then calls 0x14127e760.
Matrix wrapper 0x141280a10 invokes original multiply 0x1411e7c00 with the
current coordinate matrix on the left and sampled rotation on the right.
Scale helper 0x141281e90 then multiplies columns 0..2 by scale XYZ.
Translation setter 0x1411ee7b0 writes +0x0C/+0x1C/+0x2C (fourth column).
Scaling leaves those fields unchanged; +0x30/+0x34/+0x38 are bottom-row fields,
not translation in this packed convention.

anm_matrix_core.lua preserves multiplication float32 grouping and column
scaling. verify_anm_matrix_native.py passes 3,000 products + 3,000 scales,
all 16 output floats byte exact with guards. Full coordinate controller is
not executed; global identity initialization, opacity time quantization,
parent combination and Source matrix conversion remain separate gates.

## Scope and next concrete gates

The generic reader currently supports coord formats 5/11/17/27 and material
11/12/22. At this earlier stage other formats and entry type 6 failed explicitly. Type 6 is now proven to be point-light animation, not a generator; see anm_hierarchy_light_findings.md. Diagnostic
initial material fields are supplied by the driver, not a recovered ctor.
No captured position playback is used in these modules. No installed GMod
visual change or performance claim follows from native helper verification.

Next: verify local model matrices against independent GPU constants, recover
parent/activation inputs, add the missing model shader player, and verify
pixels and draw coverage. File-driven local math is now available for that
comparison; end-to-end Amaterasu remains unfinished.
