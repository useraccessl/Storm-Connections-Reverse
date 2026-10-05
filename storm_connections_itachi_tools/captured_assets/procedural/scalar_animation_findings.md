# ANM scalar readers and direct material controller — 2026-10-02

## Recovered native chain

Loader 0x14134a350 builds 32-byte curve descriptors. Lookup 0x141391760
selects by channel index, records the descriptor as consumed and copies
format, data pointer and key count into the resource descriptor.

Material animation resource constructor 0x1413904d0 binds 23 channels at
resource+0xd0+index*0x18. The sampler factory 0x141367040 selects a reader
from a jump table at RVA 0x1367728. Channels 12..17 and 22 use the wrapper
0x141367790, which forces its factory mode argument to zero. Other channels
use a conditional mode argument: true only when global-object byte +0x952
is 0x3c and the material constructor's third argument is zero. The meaning
of that global byte and third argument is not recovered. Therefore neither
reader mode can yet be asserted to be the active Amaterasu mode.

Format 11: constant scalar, reader 0x1413677a0.
Format 22: regular keys with a loader-prepended uint32 step:
- mode zero -> 0x1413677b0, linear interpolation;
- mode nonzero -> 0x141367820, hold current key.
Format 12: timestamped scalar, reader 0x141353c80. Cached key pointer seeks
both forward and backward. Timestamps bound the supported native domain;
the caller must wrap/clamp before sampling the last timestamp.

The linear regular reader computes q = ticks / step, r = ticks % step.
At r=0 it copies the key directly. Otherwise it evaluates float32
(t*b) + ((1-t)*a), with float32 rounding at every SSE arithmetic operation.
The timestamp reader uses the same weights but adds the left product first.
No guessed smoothing curve or captured particle coordinates are used.

## Original code verification

verify_scalar_animation_native.py executes bounded original leaves in an
isolated Python process. No game process is modified. The only relocation
is a RIP-relative float literal 1.0, copied unchanged beside the code.
Code guards reject calls, external branches and unrelated memory bases.
Input clocks remain inside each native reader's domain. Output guards and
byte-exact float32 results are compared to scalar_animation_core.lua.

- Constant 11: 11,886 cases.
- Linear 22: 11,849 cases.
- Hold 22: 11,917 cases.
- Timestamp 12: 13,382 cases, including shuffled time and matching cache.
- Total: 49,034 passing cases.

This proves these reader calculations only. It does not prove caller clock,
active sampler mode, quaternion math or final visual parity.

## Important correction: ANM controller is not the packed setter

0x141390ed0 constructs a controller through 0x14139d2f0. Its evaluator
0x14139d440 calls each sampler at vtable+8, then writes material fields
directly. This explains why direct xrefs to the previously found packed
setter 0x1412f6380 were absent. An active Amaterasu invocation has not yet
been observed; these are static executable connections.

The direct evaluator shares the channel offsets with the packed setter,
but adds behavior:
- Scalar channels 0..11 then 18..21 share a temporary. If a sampler is absent,
  the previous sampled value is carried forward. Missing channel 0 leaves
  that temporary undefined; the Lua transcription refuses that input.
- Channels 12..15 default to zero if absent.
- Channel 16 divides its sampled threshold by the original float constant
  255.0 at RVA 0x179e1e0. If absent it preserves material+0x80.
- Channel 22 defaults to zero if absent and writes material+0x88.
- Channel 17 exists in the resource/controller but is NOT read or written
  by this evaluator. Material+0x84 remains unchanged on this path.

material_animation_core.lua now includes evaluateDirect as a static
transcription, separately labeled from the oracle-validated packed setter.
The earlier eight amt15 constant matches show compatibility of file values
with GPU captures; they do not validate an active packed-setter call.

## Remaining work

Recover controller clock/wrap and attach it to each live resource instance.
Recover vector and compressed quaternion readers and their normalization
and interpolation helpers. Implement amt15 with its original transform,
two-film shader and blend/depth states. Compare those results against GPU
captures before modifying the installed diagnostic renderer. These new
modules have been saved to project source but are not deployed to GMod.
