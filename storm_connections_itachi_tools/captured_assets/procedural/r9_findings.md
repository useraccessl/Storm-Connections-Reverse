# r9 — verified material and rendering findings

## Changes deployed

- Original material constructor/binder mapped (0x1412f5920 / 0x1412f5ff0).
- Screen scroll reads UV2.zw / UV3.zw, uses signed fractional wrap and CPU float32 arithmetic.
- Original clock input accumulation (0x1412a0500) is floor(denominator/60) per call, capped at 600 calls per accumulated update. Initial denominator is 3000. Clock updater (0x14129d760) supports pause and wraps modulo 2^31.
- Source adapter uses a shared provisional 60-call/sec clock and Source epoch; original host call scheduling and epoch are NOT recovered. Override clockSeconds through STORM_AMATERASU_SHADER_CONTEXT when independently known.
- Exact ScreenToUV equals reciprocal original display dimensions, not half reciprocal. Captured draw targets and viewport are 3840x2160. Original context +500 is ScreenToUV; +4e0 is another conversion. The factor 0.5 found in that other conversion must not be applied to ScreenToUV.
- Secondary shader r9 implements bilinear ClampEdge (4efb_amt02 spirals) and transparent ClampBorder (4efb_fire04 small flames). Primary textures and verified 1efc_part12 use Wrap. Other sampler policies remain to be individually audited. Original sampler has a strongly negative mip bias; preserved top mip is used by current Source assets.
- Shared clock/scroll calculations cached per frame/resource; GPU meshes remain static throughout playback.

## Tests

- 213 primary draws / seven captures: UV screen component mapping and independently resolution-derived ScreenToUV match.
- 1008 float32 edge/random cases match native IEEE float32 conversion; clock arithmetic matches original operation order.
- 2008 independent bilinear sampler cases verify edge and transparent-border formulas.
- 180 frames with Source API stubs: finite transforms/constants, twelve billboard resource types, no per-frame vertex uploads. This is NOT a live GPU/FPS/visual parity test.
- Shader r9 compiled and installed with SHA256 checks.

## Original postprocessing chain

Replay export: gpu_captures/material_postprocess_graph.json and captured_assets/procedural/postprocess_reference.json. Resources are reused: the graph is an ordered event/usage reference, not an immutable texture graph. The cutoff selects consumers after the effect draws of this reference frame; it is not a universal effect boundary.

Key stages in frame 22136:

1. Scene and parameter target copies at 7613/7653, scene distortion at 7746.
2. Color adjustment at 7896: channel corrections, luminance-dependent offsets and saturation change. Captured parameters are non-neutral; do not fold these constants into per-particle tint without modeling the scene pass.
3. Color and parameter downsampling at 8037/8076 into different atlas regions.
4. Glare extraction at 8185: luminance >0.5, subtract 0.3 per channel, clamp positive, multiply by sampled parameter-target RED, then multiply by 2.
5. Separable seven-tap blur: weights .05,.10,.20,.30,.20,.10,.05. Multiple scales 960x540,480x270,240x135,120x67.
6. Pyramid combination at 8944: weights .5,.5,1.5,1.5.
7. Depth/soft focus blend at 9378; captured soft-focus minimum is .3.
8. Scene + glare additive RGB composition at 9419; alpha comes from scene.
9. Edge-directed final filter at 9492, copies at 9532/10663.

Original main/secondary effect shaders write color to target0 and parameters to target1. Three attachments are bound, but target2 has no consumer in this captured frame; do not assume all three contribute.

Disassembled original shaders are saved as shaders/original_*_ps.asm. These scene passes remain analysis artifacts and are NOT yet implemented in GMod. The impact still lacks non-billboard players, projectile/host control and complete external forces. Exact final Amaterasu remains unfinished.

## Next implementation gate

Recover viewport atlas layout from the original vertex shaders for each postprocess stage, retain chronological target writes, and isolate the effect contribution before adding Source passes. Preserve GMod scene depth/occlusion and avoid applying Storm scene grading blindly to the whole map. Compare original vs port constants and intermediate images before calling it exact.
