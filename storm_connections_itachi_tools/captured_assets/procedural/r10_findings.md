# r10 — billboard geometry audit and channel correction

## Verified changes

- The primary vertex shader reads its film strength from g_uvOffset3.x. Material constructor 0x1412f5920 copies resource +40 to instance +48; binder 0x1412f5ff0 exports instance +48 as UV3.x. The billboard draw function copies BB +2f0 to material +7c, i.e. g_commonParam.w. Channel 9 therefore must not supply film strength.
- 4efb_amt08 contains UV3.x=0.05000000074505806, whereas its BB channel 9 and material header field04 equal 1. Previous adapter conflated these fields. Other primary resources in this effect use film strength 1, so this correction cannot explain every visible mismatch. The 213 captured primary draws have file-compatible film strengths; this is a channel audit, not proof that amt08 occurs in those draws.
- CPU billboard roll uses 65536 integer units per turn, NOT integer degrees. 0x14130b55c rounds radians*65536/float32(2*pi), then 0x1412c855e converts back. Adapter now follows this order with float32 intermediates. Continuous-roll error was small; it is not presented as a remedy for the missing silhouette.

## Independent geometry/property comparison

Run audit_billboard_geometry.py. Recover camera basis and world matrix from original GPU world/WVP constants. Constrain candidate ages using captured atlas UV keys, then compare X/Y sizes with file curve/random bounds. No captured positions enter the procedural runtime.

209/213 captured primary draws have compatible size candidates; four amt01 draws in frame 22149 (6065,6080,6095,6125) remain incompatible under this diagnostic. The comparison does not prove particle identities, exact RNG, birth times, host scheduling, force-scale or trajectories. Matching size bounds does not prove matching silhouettes or final pixels.

The impact attachment scales and current force-direction lengths are all 1. This rules out simply multiplying the impact by a larger attachment scale as an evidence-based fix. Do not enlarge flames or reduce ash counts by visual guesswork.

## Coverage investigation

replay_effect_coverage.py matches original texture bytes by SHA256 across ALL recorded passes and pixel shaders, rather than filtering to the two already ported shaders. Exports *.effect_coverage_reference.json, including original mesh buffers, constants, depth and blend states. Texture match alone is not a particle/resource identity: shared atlases must be disambiguated by original geometry and UVs.

Frame 22136 has 93 matching original draws, including shock/light materials and distortion sampled later. The texture-only inventory does not find 1efc_part11 or 1efc_fire03 in that frame. Do not infer these effects are absent throughout the skill from one instant. Some resources have very short lifetimes.

The procedural command still skips 1efc_part11b and five non-billboard players. Projectile control, exact host inputs, material clock epoch and scene postprocessing remain incomplete. No final visual parity claim.

## Verification

- verify_billboard_render.py: original film mapping in 213 draws, file-level nonunit amt08 regression, 1006 native float32 roll cases.
- verify_procedural_player.py: 180 stub frames, twelve rendered billboard resources, 10134 uploaded vertices once, 6228 submissions; no per-frame geometry uploads.
- Live Source pixels and FPS have not been validated by these checks.

## Next specific work

1. Disambiguate matched GPU draws by auxiliary model geometry and UVs across the seven frames; export the original shader for each missing resource/pass.
2. Resolve the four amt01 size mismatches with particle cache/host state evidence, including BB start-clock and original emitter control.
3. Implement the corresponding resource players and original blend/depth behavior. Trace cinder and small-flame trajectories against captures using independently recovered inputs.
4. Validate final pixels after original deferred/postprocess operations, then measure live performance.

## Expanded capture result

All seven captures now contain 475 draws whose top-mip texture bytes match effect assets, across all recorded passes/shaders (effect_coverage_inventory.json). This is not a 475-particle count or proof of exhaustive effect coverage; shared textures and later pass sampling are included.

Eight early draws with texture 4efb_amt03 (four each in frames 22082/22102) match all 68 positions of exported model 4efb_amt15 exactly, with zero error. These use original shader pair 19f002_vs/19f002_ps, alpha blending SrcAlpha/InvSrcAlpha and NO depth writes. They are absent from the procedural billboard player. Geometry correspondence is saved in amt15_geometry_matches.json; full GPU mesh inputs/constants are preserved in the coverage exports.

19f002 shader disassembly is saved as shaders/original_amt15_vs.asm and original_amt15_ps.asm. A D3D11 reference translation, original_amt15_reference.hlsl, records both screen-space film layers, original atlas/color/fog logic, and TWO output targets. The currently ported primary shader has one film layer and opaque depth writes, so using it for this model would be incorrect. The reference is not yet compiled/validated or integrated into Source. Original animation sampling and resource/skill activation still need implementation.
