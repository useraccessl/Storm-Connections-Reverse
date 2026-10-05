# Quaternion interpolation findings — 2026-10-02

## Native chain

Format 17 factory branch 0x1413673b6 constructs compressed-rotation object
with vtable 0x141ba0b90. Its quaternion reader at vtable+0x30 is 0x1413947d0.
The loader prepends a uint32 step. The reader divides uint32 ticks by step
and decodes four signed int16 components with constant 1/16384 at RVA
0x1ba5200. Exact keys and between-key samples call 0x1412ab8b0 to convert
input quaternions; between keys then call 0x1412ab9c0.

0x1412ab9c0 wraps interpolation 0x1411f4e90. This is spherical interpolation
with a near-parallel branch, not unconditional normalized linear interpolation.
- Dot uses SIMD grouping (x*x + z*z) + (y*y + w*w), float32 each operation.
- Negative dot: abs(dot), flip the LEFT weight's sign.
- abs(dot) <= float32(0.97): acosf and sinf spherical weights.
- abs(dot) > float32(0.97): weights 1-t and t.
- Weighted sum is normalized when length >= float32(0.0001).
- No input normalization is done by the interpolation routine itself.

Imported math targets verified through PE imports:
0x1411db5c0 -> 0x1414430ae -> api-ms-win-crt-math-l1-1-0 acosf.
0x1411dbd00 -> 0x1414430a8 -> api-ms-win-crt-math-l1-1-0 sinf.

## Verification

quaternion_animation_core.lua transcribes the float32 operation order.
verify_quaternion_interpolation_native.py compares all four output components
byte for byte against the original isolated routine. It relocates original
constant literals with SSE alignment and redirects only the two known math
call targets to UCRT acosf/sinf. No game process or hooks are involved.

3,051 cases pass: random rotations, negative dot, threshold neighborhoods,
near-parallel rotations, zero length and endpoint ratios. Memory guards pass.
JSON proof: quaternion_interpolation_native_verification.json.

## Input conversion, key preparation and basis recovered — 2026-10-02

Static initializer 0x1400a4cf0 copies RVA 0x1761170 into runtime mask
RVA 0x97080f0. Literal words: 80000000,80000000,80000000,00000000.
0x1411f2000 therefore conjugates XYZ and preserves W, including signed zero.

Preprocess 0x141394b30 normalizes each signed-int16 key after /16384, then
multiplies by 16384 and truncates toward zero into signed int16. It does not
conjugate keys during preparation. Exact keys are read back quantized; do not
replace these with normalized float keys. Between-key interpolation has its
own final normalization.

0x1411bb590 writes the packed nine rotation coefficients; 0x14127e760 adapts
that basis into an existing 4x4 through 0x1411edd20. Full parent/world mapping
must still be checked separately.

verify_quaternion_keys_native.py passes 4,013 cases (including nine original
amt15 keys) against the isolated original normalization, sign conversion and
basis helpers. Recompression arithmetic follows static instructions using
the native normalization output; full preprocessing/controller was not run.
Proof: quaternion_keys_native_verification.json.

The generic anm_resource_core.lua prepares keys once and reads scalar,
material and quaternion channels from local integer ticks. The amt15 driver
runs 800 local ticks and repeated clock loops with original keys, without
captured positions. This is integration evidence, not world/render parity.

GMod trig parity, host activation/cadence, material factory mode in captures,
parent transforms and final shader/postprocessing remain unresolved. The
installed visual diagnostic has not been updated by these RE changes.
