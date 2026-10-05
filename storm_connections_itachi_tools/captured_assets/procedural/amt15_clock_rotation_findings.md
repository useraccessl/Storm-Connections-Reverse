# amt15 GPU rotation and particle clock bridge — 2026-10-02

## Independent camera removal and shape check

audit_amt15_rotation_gpu.py removes the captured camera using world and WVP
constants from a DIFFERENT draw in the same target pass. The amt15 world
matrix then gives a normalized row Gram matrix G = W W^T / trace(W W^T).
This removes parent orthogonal rotation and uniform random size. File emitter
4 in 4efb_amt1_blt00 owns 4efb_amt1_ptc02, with birth size (.2,.3,.2), common
sizeRandom (1,1,1), independentSizeRandom false, sizeSplit zero, life 8,
simulationHz 30. The ANM binds its coordinate entry to 4efb_amt15.

Compare G with R^T diag(.2^2,.3^2,.2^2) R / trace, using the recovered original
quaternion sampler. All eight captured draws match at normalized max errors
2.88e-6..1.11e-5. The inferred local ticks are 150,350,550,750 in both frames
22082 and 22102. No translation or orientation was fitted into the runtime.
This invariant cannot recover full parent orientation (two size axes are
identical); it verifies a constrained rotation/shape relationship, not all
16 world matrix entries. Candidate ticks are inferred from captures, not
independently proven activation times.

## Texture mode is different from rotation interpolation

Captured UV0.y is .125,.375,.625,.875. The same ticks reproduce these values
with HOLD, while rotation uses original spherical interpolation. Linear UV
can match only the last two draws where last keys have equal UV values.
For the other six, normalized Gram error is .00743..07044 when constrained
to the times allowed by linear UV. Thus hold is compatible with all eight;
linear is contradicted by six. See amt15_rotation_gpu_audit.json.

The material factory uses hold when global update rate +952 equals 60 and
its force-linear flag is zero. This is consistent with these captures. Do
not make hold the unconditional policy for every animation or material.
A.materialHoldFromContext implements the actual selector; fixed channels
12..17 and22 stay linear. The amt15 diagnostic now uses this capture-supported
context instead of the former provisional linear context.

## Particle-to-model clock bridge

Motion update 0x141386b70 writes particle +198 = float32(simulationHz/rate)
and +19C = host context +5C (copied as float bits). Render update 0x14130b200
forms ageStep = float32(+19C * +198). This advances particle age and then:

- 0x14130b5D3..0x14130b601 sets ANM speed = float32(float32(rate/30)*ageStep).
- 0x14130b61F..0x14130b62D passes integer 3000/rate to ANM vtable+30.
- Then vtable+38 evaluates the updated local clock. This differs from the
  billboard path that reads old keys before its counter increment.

anm_clock_core.lua particleStep preserves the float32 operation order.
verify_model_particle_clock.py executes the original speed prefix with an
ABI wrapper and relocated data only: 2,180 byte-exact cases, other fields
unchanged. Motion factor producer and integer division are static translations;
full original motion/render routines were not executed.

For simHz30 and host factor1: rate60 gives ageStep .5, ANM speed1 and delta50;
rate30 gives ageStep1, speed1 and delta100. These model steps must not be
replaced with billboard sampling rules. The amt15 integration driver now
checks both timelines and intermediate rotations with held texture keys.

## Parent and rendering remain pending

0x14130b5A2..0x14130b5D0 copies particle +A0 matrix, scales its first three
columns by +1B0 size, and passes it to ANM vtable+48. nuccAnmEffect maps this
to 0x1412baeb0, which updates clump/control parents. The matrix and its host
attachment must be reconstructed and compared independently before claiming
full world transform parity. Shader19f002's two film layers, alpha blending,
MRT outputs and final postprocessing are still not integrated in Source.

The installed GMod player remains the previous partial diagnostic. These
modules do not replay captured positions. No visual parity/performance claim.
