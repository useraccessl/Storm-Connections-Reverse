# Main fire MRT consumer trace — 2026-10-02

## Captured attachment flow

In frame 22136, principal-fire draw event 5302 runs pixel shader hash
`915c5e6e56ff52ae6c9ecab0084f5e3e2f76a7a03d28fb96320c3f7ba1106abd` and writes
three render targets: `ResourceId::45595`, `45598`, and `45601`. The shader
output definitions in `main_fire_915c5e6e_ps.asm` show target 0 is the final
film/fire color and target 1 stores material metadata plus resulting alpha.

Target 0 is read later by events 7613, 7788, 9492, and 10663. Target 1 is read
by events 7653 and 8076. The 7020 pixel shader at events 7613/7653 is an
alpha-tested texture copy; event 8076 uses the 0392 shader, which samples
offsets around a source texture. A later global pass, event 7746, uses shader
`f826fc2c` and writes the three render targets again. Its resources are named
RefNormal, BlurVelocity, RefScene, RefPostEff and RefDepth. This establishes
that the main fire's outputs enter a multi-pass scene pipeline; it does not by
itself prove each later draw is exclusively Amaterasu-owned because the frame
contains the whole scene.

## What is decoded and what remains

The main fire VS/PS and the identified target consumers are disassembled under
this directory (`main_fire_*` and `pass_*`). The target 0/1 consumers and the
global post-effect pass are identified by event and shader hash. The exact
semantic mapping of target 1, the global pass ordering for the effect alone,
and a Source-compatible equivalent remain unresolved. The `storm_amt` Source
player currently draws the target-0 color directly and cannot reproduce the
full engine MRT chain; do not represent its color result as exact.

For another skill, repeat this trace from its principal draw's three MRT
resource IDs, follow only later texture reads of those resource IDs, then
disassemble each consumer and map its output targets recursively. Keep event
scope/frame scope explicit so scene-wide post-processing is not mistaken for
skill-specific effect logic.
