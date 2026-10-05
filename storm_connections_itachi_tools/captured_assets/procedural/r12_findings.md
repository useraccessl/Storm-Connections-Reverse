# r12 integration — 2026-10-02

## Changes now connected to the GMod adapter

- anm_scene_adapter translates recovered ANM world matrices into attachment
  coordinates. procedural_scene refreshes attachments, segments and fields
  once per simulation frame. The old quaternion/animated-coordinate rejection
  no longer blocks the blt resource scene.
- procedural_player uses the recovered quaternion/scalar/matrix/hierarchy
  readers for both hit00 and blt00. Point-light channels evaluate and are
  retained; their deferred lighting output is not rendered yet.
- model_particle_adapter connects original amt15 geometry, native-derived
  particle parent math, model ANM advance-before-sample, held UV animation and
  two-film shader to model_source_renderer.
- Particle runtime retains birth attachment scale, previous position and the
  size curve before force scale, allowing the model branch to compose these.
- Film screen Y is negated before the original 1-y operation, matching the
  original 19f002 pixel shader. Tint is white for the inspected amt15 profile;
  particle fade alpha is applied separately. All model mesh vertices stay cached.

## Explicit diagnostic profile / remaining uncertainty

Current scene is local identity-root with unit target translation scales,
rate 60 and outer ANM delta 50. blt mode previews the resource set in place;
it does not claim to follow the original CRAWLER actor or launch the full skill.
Original actor root helper exists separately but has not been wired to it.
Particle model parent uses unit inherited scale and zero initial persistent
travel direction; their native field producers still require confirmation.
Per-particle attachment scale +108 is statically recovered from
0x14131c560: transformed unit X length; segment counterpart 0x14131cbf0
is not independently bound by this change. Clock epoch, generator event clock
binding, missing material families and postprocessing remain open.

Lua math trig results are rounded to float32; this is not an independently
verified UCRT trig replacement in live GMod. Bounded native helper test results
must not be extended to a full GPU fidelity claim.

## Verification and deployment

verify_procedural_player.py: 180 impact frames and 120 blt resource frames,
finite transforms/constants, model updates and draws, reload cleanup, scale
rebuild, no per-frame vertex uploads. This uses API stubs, not live Source GPU.
Missing native model context is rejected by the lower-level renderer.
Installation copies and SHA256-checks 53 payloads; r12_install_manifest.json.
No live screenshot, visual parity or performance proof claimed.

Developer resource inspection (not a finished attack):
lua_openscript_cl storm_amt_lab/procedural_player.lua
storm_amt_procedural 0.3 1 blt
The existing two-argument command still selects impact. Do not label this
resource inspection mode an exact complete skill or use it as an acceptance test.

Next: confirm actor orientation and inherited scale producer inputs, bind
moving root/ground collision and phase transitions; finish other model families,
part11b blend, distortion and original MRT/compositing; independent live pixel
and performance comparison. No request for another user screenshot at this stage.
