# File-derived Amaterasu port — 2026-10-01

## Latest verified additions

### r8 performance and secondary property audit

- Original meshes now upload once per activation scale and use model matrices.
  180-frame stub check: 10,134 vertices uploaded once; no vertex submissions
  during render frames, versus 2,977,710 in the former immediate-mode path.
- Secondary fog moved to compiled `amt_secondary_r8_vs30`, using projected
  clip W and reciprocal skill scale, algebraically matching the old CPU fog.
- Simulation updates each generator's own particle list and reuses routed
  force lists. Global birth/render order and RNG sequence are preserved.
- BB sample-before-increment phase corrected. Joint UV/color/opacity audit
  matches 130/147 original secondary draws within 1e-4; 17 mismatches retained.
  Compatible property combinations are not a trajectory/pixel parity test.
- `storm_amt_procedural_diag` includes CPU simulation/submission milliseconds,
  draw count and cumulative mesh uploads. Live FPS and shader execution still
  require the user's GMod test. Secondary trajectories and final color remain
  unverified; no manual tint or trajectory tuning was substituted.

### Procedural impact runner r7 (2026-10-01)

- Attachment topology now traced through insertion 0x1413856b0 and node
  virtual +68 (0x1413852f0): file +1c is the segment break field. The scene
  preserves special index-zero and last-two-node fallback behavior.
- `procedural_scene.lua` connects emission, global deterministic diagnostic
  RNG, original attachments, original forces and particle lifetime/curves.
  360 impact updates pass; ash and lateral resources emit without captures.
- `procedural_player.lua` renders original BB inputs through the primary and
  secondary shader ports. A 180-frame API-stub run submits 12 used resource
  types, including part09b and amt02. Source GPU execution is unverified.
- This is a separate `storm_amt_procedural` diagnostic command. It does not
  replace r6 or assert final parity. Non-BB players, host control/force routing,
  material global clock and deferred effects remain incomplete.
- Reusable workflow and exact coverage boundaries are in `PORTAGE_EFFETS.md`.
- File +18 force masks now export to every emitter. The runner dispatches
  context +90/+88/+80 according to bits 0/8/16 in original order; generator
  local push to +90 is traced at 0x1412765c0. External lists remain host inputs.

The older additions below predate the r7 scene runner.

- `particle_spatial_core.lua`: original cone/axis alignment, single attachment
  circle/sphere births and segment births. Segment eligibility remains an
  explicit scene input; moving attachment flag 0x10 is rejected, not guessed.
  This flag is absent from the 24 extracted Amaterasu emitter configs.
- `scene_spatial_core.lua`: constant original ANM coordinates, parent matrix
  composition and attachment/force direction resolution. All 18 impact
  emitter create/step paths pass using original coordinate/force records.
  Animated coordinate interpolation still requires a verified sampler.
- `runtime_core.billboardFromParticle`: separate billboard clock advances
  50 ticks per whole particle simulation step, traced to 0x14130b4a0 and
  0x1412c7d48. It must replace wall-clock-only UV sampling in the new player.
- Procedural asset channel keys were incorrectly serialized as strings.
  Numeric Lua indices are now preserved and covered by a regression check.
- Seven existing RDC files now have `.secondary_reference.json` exports.
  147 secondary draws match original native texture blocks, original mesh
  positions, UV key values and opaque depth-writing render state.
- Original secondary VS/PS bytecode is disassembled and preserved under
  `shaders/original_secondary_*.asm`. Source SM3 shaders
  `amt_secondary_r7_vs30` / `amt_secondary_r7_ps30` compile successfully.
  They require vertex fog input and a separate deferred postprocess target.
- `auxiliary_assets.lua` now preserves the remaining five model inputs:
  amt15 (68 vertices), light00 (4), fire03a (48), nor_dst03 (559), shock09
  (559), original coordinates, all UV sets, material records and ptc02 ANM.
  Seven referenced texture inputs also preserve native compressed blocks.

These additions do **not** replace the installed r6 visual player. There is
no newly validated final GMod render. Resource players, full scene control,
material clock/context binding, deferred distortion and visual comparison
remain necessary. The exact skill objective is still unfinished.

## Implemented and checked

- All 17 original billboard resources, including the lateral meshes and
  part09b/part11b. Original vertex RGBA, UVs, triangle strips and key arrays
  are preserved. Eight textures convert directly from native BC blocks to
  VTF, with payload byte equality checked; no atlas painting or recompression.
- All seven force selectors, including vortex rotation. The original vortex
  displacement is added to the parent displacement accumulator before
  speed multiplication. It is not an extra persistent velocity.
- Original RNG low-bit recurrence, integer resource selection, reversed
  interval formula, lifetime/scalar and size randomization ordering.
- Radial direction selectors 0 outward / 1 inward. The obsolete diagnostic
  used the opposite mapping.
- Forward-clock emission path, including one event per update, direct bursts,
  fractional rate accumulator and duration counter. External activation,
  loop reset and stop-notification execution are not implemented.
- A procedural create/force/integrate/size module using the above helpers,
  with no captured particle coordinates or inferred snapshot identities.

## Required before it can replace the visual player

1. Finish moving attachment spawn and animated hierarchy interpolation.
   Current impact attachment selection, segment topology, cone alignment and
   constant parent transforms are now implemented and checked.
2. Recover external generator activation for stop-only event lists. Setting
   these emitters active by guess would change births and RNG ordering.
3. Implement the five referenced non-billboard resource players:
   amt1_ptc02, light00, fire03a, shock09 and nor_dst03.
4. Bind the complete resource/material set and its shader variants to the
   procedural renderer. The current r6 shader only covers the measured
   primary rendering path. Auxiliary materials are not equivalent to it.
5. Compare the resulting skill to the original captures and a live GMod test,
   including lifetime boundaries, force selection/order and camera behavior.

The installed `storm_amt_capture_replay` still plays the r6 interpolation
reference. It has not been relabelled as a full original simulation.
`verify_procedural_assets.py` and `verify_file_motion.py` pass. Their tests
establish arithmetic/data integrity, not full visual parity.
