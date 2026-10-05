# Storm Connections reverse engineering project

Both original project folders were moved here on 2026-10-01. The installed Steam GMod addon remains a separate deployment copy. Deploy with storm_connections_itachi_tools/install_storm_fx.py (see the latest section).

## Material binding evidence

Original executable SHA256: cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e.
Constructor 0x1412f5920 and binder 0x1412f5ff0 establish UV0..3 layouts. Decoded scroll0/scroll1 names are historical: these are UV2/UV3 vectors, each offset.xy and scale.zw. g_uvOffsetScreen reads UV2.zw and UV3.zw, multiplied by global clock and wrapped with truncation toward zero, not floor.
Clock getter 0x1412a4eb0 reads global object+0x958. Update 0x14129d760 adds object+0x94c unless pause flag +0x95c is set, wrapping modulo 2^31. Producer 0x1412a0500 adds floor(denominator/60) per call, capped at 600 calls per update. Calls per host frame and original epoch remain external inputs. Clock = float(counter)*float32(0.1)/global denominator; the executable initial denominator at 0x141b948e8 is 3000. Zero-rate check uses abs(rate)<2^-23.

The pure Lua binder is reusable for other materials. Seven captures check four-channel correspondence; this is not independent recovery of the clock. Source CurTime currently provides a provisional shared clock, not the original epoch. r9 now explicitly rounds the material clock/scroll arithmetic to float32.

## Required next gates

1. Trace global counter updates and ScreenToUV setup; recover exact clock semantics and resolution scaling.
2. Compare computed shader constants with captures using independently recovered inputs, including BB frame-cache overrides and colors.
3. Implement missing non-billboard resources, projectile control and host forces; account for every original draw.
4. Trace MRT/deferred compositing, distortion and original sampler states; compare final pixels.
5. Measure live CPU/GPU performance and optimize only after correctness. Cached GPU meshes already avoid per-frame vertex uploads; FPS parity is not established.
6. Reuse the verified parsers, runtime, material binder and coverage checks for later skills.

Current output remains a diagnostic partial port. No claim of exact Amaterasu parity or full particle-engine reconstruction.

## Generic shader binding reverse — 2026-10-02

The 72 native parameter accessors now have clean boundaries in
`shader_bindings_dispatch.json`: the extractor stops at terminal jumps,
records `dispatch_path`, and checks the exact EXE SHA256. Their 0–71 accessor
indices select accessor functions; each runtime binding ID is loaded at
caller-record offset `+0x04 + 4*accessor_index`, verified for every thunk.
Verified split: 61 value accessors and 11 sampler /
resource accessors. The value path copies data into shader parameter staging;
samplers take a separate descriptor/resource resolution path and enqueue
binding records. Of the values, 46 use the four-word copy helper, 14 transpose
4x4 matrices, and one packs a scalar. The write-up and native addresses are in
`captured_assets/procedural/generic_shader_parameter_map.md`.

Next reverse action: follow where the global semantic registry at object
offsets `+0x2008..+0x2020` is constructed, decode its value descriptor and
sampler pointer table, then map runtime IDs through the active shader binding
list to DXBC reflection and captured GPU buffers/resources. This advances the
reusable renderer map; it does not change the Amaterasu visual implementation
or its 49% completion estimate.

## R19 shader parameter path — 2026-10-02

The native path is now traced from semantic names to CPU staging writes:
global name trees resolve/create 24-byte parameter descriptors; shader records
store their CPU IDs; parsed per-shader binding rows provide a 64-bit semantic
key and copy metadata; the active render-thread row supplies the staging
destination, offset, and byte count. These IDs are not GPU register indices.
See `storm_connections_itachi_tools/captured_assets/procedural/generic_shader_parameter_map.md`
and `generic_shader_record_layout.json`.

Next, find where shader metadata inventory vectors are populated, follow the
staging buffers into the Direct3D constant-buffer upload, and identify the
sampler-record consumer. Cross-check the recovered per-shader offsets against
DXBC reflection and the existing Amaterasu capture crosswalk. Static reverse
progress does not count as improved visual parity until the GMod effect changes
and is compared in game.

## r9 update

See storm_connections_itachi_tools/captured_assets/procedural/r9_findings.md. Verified sampler policies and float32 material math are installed; the original postprocessing chain is traced and its shader bytecodes disassembled. These scene passes still require a Source implementation.

## r10 geometry and coverage audit

See storm_connections_itachi_tools/captured_assets/procedural/r10_findings.md. UV3 film strength is now separated from BB common-param channel 9; original 65536-unit roll quantization is restored. Original GPU size/UV audit: 209/213 compatible, four amt01 discrepancies unresolved. Cross-shader texture/geometry coverage export is available for missing-resource investigation. This is still a partial diagnostic, not final visual parity.

Concrete missing player identified: eight early GPU draws match the 68-vertex 4efb_amt15 model exactly. Its original 19f002 shader uses two film layers, alpha blending and no depth writes. Disassembly and a D3D11 reference translation are preserved; Source integration and animation are pending.

## Generic engine work

The full staged reconstruction and evidence gates are maintained in MOTEUR_EFFETS_REVERSE.md. Prioritize generic ANM samplers/setters and per-family matrix verification before further visual tuning. Amaterasu is the validation case, and the current runtime remains incomplete.

## ANM scalar/control update — 2026-10-02

Three scalar formats (11, 12, 22) are now translated and tested against
bounded original native instructions: 49,034 byte-exact float32 cases pass.
Format 22 has both linear and hold modes selected by material context.
The direct ANM material controller 0x14139d440 is also traced: threshold /255,
channel 17 not applied on this path, and missing-channel propagation differ
from the packed setter. See scalar_animation_findings.md for addresses,
proof scope and remaining clock/quaternion/geometry gates. No visual
changes have been deployed from this investigation.

## Quaternion and repository update — 2026-10-02

The public StormRevivalClientSource commit e2ac7c17d4ec97424b758534dc49ab507632ed8b
was inspected without execution. No usable native particle/shader reconstruction
was found; assessment preserved in storm_revival_repository_assessment.md.
Native quaternion interpolation 0x1411f4e90 is now translated with 3,051
byte-exact four-component cases passing. Format 17 uses signed int16 /16384,
spherical interpolation with threshold 0.97, and final normalization. Input
conversion mask and curve preprocessing remain unresolved; no deployment.
See quaternion_animation_findings.md for scope and next gates.

## ANM keys, local clock and matrix update — 2026-10-02

Quaternion sign mask and key preprocessing recovered: 4,013 native helper
comparisons pass, including extracted amt15 keys. Actual nuccAnmEffect local
clock recovered and connected to the file evaluator: 10,576 exact cases.
Matrix multiplication and column scale: 6,000 exact cases. The evaluator runs
800 local ticks from nine original quaternion keys and repeated loops. These
proofs cover bounded math, not host scheduling, world transforms or final
rendering. Previous unresolved-mask note is superseded. No visual deployment.
See storm_connections_itachi_tools/captured_assets/procedural/anm_clock_matrix_findings.md
and quaternion_animation_findings.md for addresses, assumptions and remaining
gates. Next: independently verify model matrices, then model shader integration.

## amt15 GPU cross-check and clock bridge — 2026-10-02

Eight original amt15 draws agree with the file-driven rotation/anisotropic
shape invariant (max normalized error 1.11e-5). Texture hold mode matches all
eight, while six contradict linear UV. This is constrained shape evidence,
not full parent/world identity. Particle-to-model ANM speed math is recovered;
2,180 exact original-prefix cases pass. Model timing differs from billboard
timing. Diagnostic reader uses the capture-supported hold context and checks
both 30/60-rate timelines. No visual deployment. Details and caveats:
storm_connections_itachi_tools/captured_assets/procedural/amt15_clock_rotation_findings.md.
Next: trace particle parent through ANM vtable+48/clump transforms, then integrate
the original model shader and validate draw coverage/pixels.

## Hierarchy and point-light update — 2026-10-02

All original hit00/blt00 file ANM entries evaluate, including format-10 rotations
and point-light RGB/position/scalars. Coordinate parent order is parent * local.
Type 6 was provisionally mislabelled generator; native loader/RTTI prove point
light. It supplies no particle emission curves. Next trace particle+A0 orientation
formation and connect recovered matrices, then original shader/compositing.
Details: storm_connections_itachi_tools/captured_assets/procedural/anm_hierarchy_light_findings.md.
No visual deployment; complete ANM entry coverage is not complete effect coverage.

## Particle parent and skill graph — 2026-10-02

Native Euler, travel basis, angle quantization and 4x4-by-3x3 helpers are
translated and verified. Model parent/size/ANM bridge is prepared. Correct
4efb_amt1 skill XML now extracted: ARROW launch -> CRAWLER (velocity 25) ->
hit00 on contacts/frame 120, with explicit shot-axis placement. CRAWLER RTTI
and update are located; actual unit conversion, guidance and ground query
remain gates. Details: storm_connections_itachi_tools/captured_assets/procedural/particle_parent_skill_findings.md.
No new visual deployment or final parity claim.

## r11 Source binding and skill placement — 2026-10-02

Repaired an actual Source interface bug: custom sampler policy was sent to
engine-owned c4, and the second UV channel was undeclared. Sampler mode now
uses c2.w and $tcsize1=2 is set. amt15 two-film SM3 shaders and cached model
renderer are ready, with explicit native-context requirements. No projectile
integration or GPU parity claim. XML rate conversion (reference 30) and native
CONST_AXIS_UP projection have been recovered. Actor/root linkage remains.
See storm_connections_itachi_tools/captured_assets/procedural/r11_findings.md.

Actor-to-effect matrix link now recovered: ccGameObjectSkill virtual +78
0x1405e00c0 forms T(position)*orientation*Ry(extra angle), applies actor scale,
passes effect virtual+48, then advances animation. skill_shot_core.effectRoot
preserves this order. Actor motion multiplier +164 normally resets to 1; an
owner-character override supplies alternatives. Actual actor field binding and
live scene integration remain; no final parity assertion.

## r12 integration — 2026-10-02

Native-derived ANM readers now drive scene attachment matrices in the Source
player; the blt animated-coordinate rejection is resolved. amt15 model geometry,
parent math, model ANM and two-film shader are connected, using cached meshes.
120 blt resource frames execute in API stubs without per-frame vertex uploads.
This is an explicitly stationary unit-root resource preview, not the complete
CRAWLER skill. Inherited scale/direction initialization, moving root, remaining
families and MRT/compositing need completion. Installed 53 SHA256-checked files.
See storm_connections_itachi_tools/captured_assets/procedural/r12_findings.md.

## CRAWLER motion update — 2026-10-02

See `storm_connections_itachi_tools/captured_assets/procedural/crawler_actor_findings.md`.
Native per-tick integration, ascent/descent normalization, eight-hit ground
filter, gravity exception and guidance call order are recorded; reusable Lua
math is in `storm_connections_itachi_tools/crawler_actor_core.lua`. Native
guidance consults global target/character state and is not yet emulated, so the
Amaterasu player is not yet wired to this root. No visual parity claim.

## Current visual checkpoint r13 — 2026-10-02

A dedicated dual-projected-film shader is compiled and wired into the procedural
player/installer for the captured three-texture fire04 material. It uses both
film-clash maps, the two captured screen transforms and material weights, dynamic
particle tint, animated atlas UV, and alpha cutout. One-texture fire04 draws no
longer inherit this shader by texture format alone. Do not describe this as final
parity: global material epoch, fog/compositor behavior, remaining secondary
materials, and live visual comparison still need resolution. The user's current
scope is the main visual only; projectile targeting/guidance is deferred.

Next visual work: install r13 and compare the main flame against a matching game
frame; then correct shader epoch/film projection and remaining visual layers
from captured draws. The relevant shader source is
`storm_connections_itachi_tools/shaders/amt_projected_anim_ps30.hlsl`; the GMod
reader is `storm_amaterasu_lab/lua/storm_amt_lab/procedural_player.lua`.
## r14 scale checkpoint — 2026-10-02

The local visual preview no longer defaults to a 0.3 scene scale. This scales
particle mesh dimensions and local travel together; the recovered skill's
attachment scale is unit scale. Use `storm_amt_procedural 1 1` for the unit
preview. Do not interpret explicit smaller first arguments as recovered skill
parameters. `1efc_part11b` cinders remain omitted until NUD destination blend
value 146 is mapped to Source blending.
## r15 main flame and ash update — 2026-10-02

Default visual scale is 1.0, preserving the decoded attachment scale and force-
driven rise. `1efc_part11b` no longer gets skipped: its existing mesh/atlas,
secondary shader and particle size/fade curves are drawn using standard alpha
blending with depth writes off. Native NUD source factor 5 supports source-alpha
blending; destination code 146 still needs exact native translation. Use
`storm_amt_procedural 1 1` after restarting GMod for a unit-scale preview.

## r16 effect lifetime and shader-family correction — 2026-10-02

Impact emitters now stop at the owning ANM endpoint rather than a hard-coded
six-second preview limit. The captured impact ANM is 5,000 ticks; the adapter
advances it 50 ticks per simulation frame, so births stop after 100 updates.
Already-born particles continue to age using their decoded lifetimes. This
keeps the preview inside the recovered effect lifetime; it does not explain
the excess ash visible at the active-effect peak. The main-fire shader remains
open: capture 22136 shows 47 principal atlas draws with a single projected
`4efb_maplus01` film path; `19f007_ps` is only two legacy draws. See
`storm_connections_itachi_tools/captured_assets/procedural/r16_findings.md`.

The next-stage capture trace follows the main fire's three output resources to
their later consumers and disassembles the copy/filter/global post-effect
passes. Full target-1 meaning and a Source-compatible equivalent are still
unknown. Details: `storm_connections_itachi_tools/captured_assets/procedural/r17_mrt_chain_findings.md`.

The client preview now enables Source alpha compositing for main single-film
draws and keeps depth writes off, using the original shader's output-alpha
channel in lieu of the deferred attachments. This is a testable approximation;
the exact compositor remains open. See
`storm_connections_itachi_tools/captured_assets/procedural/r17_source_alpha_findings.md`.

## r18 per-shader accessor activation — 2026-10-02

Recovered how a runtime shader record selects generic binding accessors:
records are `0x130` bytes, the active mask is at `+0x124` (10 bytes), and
enabled bits dispatch through the 72-entry function table. Accessor thunks
read their separate runtime binding IDs at `+0x04+4*accessor_index`. The
initializer at `0x1413352c0` is now traced: for every shader key it queries all
72 semantic names, writes available binding IDs and sets the mask. Next locate
the source of the shader-key inventory, map those IDs to backend slots, and
follow sampler bindings into backend state. Do not infer serialized file
fields from this runtime layout yet. See
`storm_connections_itachi_tools/captured_assets/procedural/generic_shader_parameter_map.md`.

The global shader-registry key lookup is now identified at `0x1413356d0`:
ordered tree key `+0x1c` maps to runtime record index `+0x20`, which selects the
`0x130`-byte record. The record initializer is `0x1413352c0`; find the source
that enumerates its shader keys, then trace queued sampler records to the
graphics backend.

Also documented the reflection-side builder at `0x1412e30a0`: it derives
semantic identifiers, stores 32-byte binding rows, and maps them through the
shader-key tree. `0x1412e29c0` builds a separate material shader-index array and
128-bit feature mask. Decode the unresolved key fields and locate the loader
that populates the global shader records; do not conflate feature flags with
the 10-byte accessor mask.

Sampler selector resolution now has a concrete route: TLS namespace base
`+0x32c8`, resource hash-table lookup, cached resolved pointer, then a sampler
record queued in current render state. Follow that queue into the draw/backend
resource bind to recover sampler state and texture identity end to end.

Pointer-flow correction: `0x14123c0e0` writes the resolved resource into the
selected descriptor at `+0x30` and queues that descriptor in a per-thread
container; it does not establish that `0x141239d10` stores the texture pointer.
Follow the container's backend consumer and prove its cache key/lifetime.

## r19 native material file-to-runtime bridge — 2026-10-02

The `nuccChunkMaterial` format reader (`0x14134cde0`) and material instance
constructor (`0x1412f5920`) now map serialized float blocks to runtime fields.
The reusable decoder and 18-record Amaterasu report are
`storm_connections_itachi_tools/decode_native_material_fields.py` and
`storm_connections_itachi_tools/captured_assets/procedural/native_material_parameter_map.json`.

That static bridge is now applied to the correct capture assets in R37:
`4efb_amt00/01` resolve by GPU texture hash to `4efb_amt1.xfbin`, and their
`(0,1,1,1)` rates match all 213 captured scroll vectors. Continue with the
remaining unknown shader input `g_uvScaleScreen`: find the CPU producer or
shader metadata default behind `(3,1,1,1)`. Then close the shader-key inventory,
sampler queue-to-D3D bind path and constant-buffer upload path so the material
pipeline can be generalized to other effects.

## r20 NUD property to GPU constant crosswalk — 2026-10-02

The open `g_uvScaleScreen` input is now traced to per-material NUD property
`NU_uvScaleScreen`: `4efb_amt00/01` hold `(3,1,1,1)`, matching the capture.
`audit_nud_shader_properties.py` proves the match on 213 draws in seven frames.
Continue by locating the native NUD-property copy site, then complete shader-key
loading, sampler backend bind and constant-buffer upload tracing. Preserve NUD
material properties in the reusable effect extraction stage.

## r21 NUD constant path narrowed — 2026-10-02

The 72-entry generic accessor table does not contain `g_uvScaleScreen`; only
`g_uvOffsetScreen` is accessor 50, sourced from context `+0x4f0`. The material
binder `0x1412f5ff0` computes scroll and dispatches generic shader inputs, while
the NUD scale property reaches the captured VS buffer by another path. Trace
NUD property reflection/packing and the native copy site; then follow the
shader-specific constant-buffer upload to the D3D backend.


## r22 shader values -> D3D11 constant buffers — 2026-10-02

The generic value path is now closed through `UpdateSubresource` and stage-specific `*SetConstantBuffers` (R42; see `MOTEUR_EFFETS_REVERSE.md` and `captured_assets/procedural/generic_shader_record_layout.json`). Next trace the full deferred-command traversal/order and the native sources of constant-buffer allocation/layout; then map particle, trail, and postprocess command families independently. Preserve per-shader reflection/capture for GPU register and byte-layout semantics.

## r23 constants, queue and render state closed; producers next — 2026-10-02

Closed in R43–R48 (authoritative text: `storm_connections_itachi_tools/captured_assets/procedural/shader_constant_pipeline.md`):

- `0x14123ab80` and its callers; descriptor = `{Program*, CBufferDef*, Variable*}`.
- Constant-buffer layout = `D3DReflect` offsets merged per slot over VS+PS (`dxbc_rdef.py`); one `USAGE_DEFAULT` buffer per (program, slot); zero-filled staging.
- Context slot `+0x238` = `CSSetConstantBuffers`.
- Deferred queue: per-thread lists, stable sort by 64-bit key, merge and execution on `RenderThread`; key = layer / bucket / depth.
- NUD model material path: `NU_x` → `g_x`, `g_matWorldViewProj`, textures and samplers.
- Packed render state, 13 native blend modes, pass-level blend enable by sort bucket.
- All of it checked on 475 captured draws (`verify_constant_buffer_model.py`).

New tools: `disasm_batch.py` (annotated multi-function disassembly), `xrefs.py`, `callers_tree.py`, `extract_draw_commands.py`, `d3d11_vtables.py`, `dxbc_rdef.py`, `native_render_state.py`, `verify_constant_buffer_model.py`.

Also closed in R49–R50: command routing (models vs interleaved primitives vs trails), the primitive renderer and its five vertex formats, the model-path sort key (NUD `source_factor` bits), NUD vertex stream conversion (colour bytes / 255). All captured Amaterasu effect draws are model-manager draws; the primitive and trail paths are static findings with no capture yet.

Next, in this order:

1. **Layers and targets.** Map each `0x14121c450` / `0x14121c240` call site to its pass and `SetRenderTarget` (`0x141220a40`); join with `material_postprocess_graph.json`. This gives the MRT and post-process order, the last missing piece between a correct draw and a correct frame. Start from `captured_assets/procedural/layer_pass_inventory.json` (`extract_layer_passes.py`): 63 pass functions and the 33 `nuccLayer*` / `nuccPostEffect*` classes. First target: the order in which `nuccLayerManager` (vtable `0x141b995d0`) / `nuccLayerSet` (`0x141b98ee0`) run the layers, then which layer the effect models are queued into (the `DrawModel` commands' owner).
2. **Screen filters.** The named constants per filter are inventoried (soft focus, DOF, glare, sunshafts, fringe, fisheye, HDR: functions `0x141355880`–`0x14135e090`); decode each filter's pass list and shader keys.
3. **Importer.** Feed the Amaterasu importer from the native rules instead of capture-measured values: RDEF layout (`dxbc_rdef.py`), NUD properties, blend modes and bucket (`native_render_state.py`), vertex colours / 255, zero for unwritten constants. Then run a second skill through the same path.
4. **Upstream of the model draw.** How a particle node selects its NUD model and fills the 72-accessor context per instance (`0x1412d1870` inputs: `model+0x10` sort position, world matrix, `0x14130e0d0`), so instance colour, UV and scroll come from the effect data rather than from captures.
5. **Remaining producers.** `DrawModelPrimitiveBatch` (`0x141303b10`), skinned mesh draw (`0x14126a5c0`), the eight state presets (`0x141b91290`); get a capture of a skill that uses trails or interleaved primitives to validate section 9 of `shader_constant_pipeline.md`.

Do not present the engine as fully reversed: items 1–5 are open, and no GMod render has been compared to the game pixel for pixel.

## r24 pixel oracle, native-rule port (r18), skill sequence — 2026-10-02

Journal entries R52–R60 in `MOTEUR_EFFETS_REVERSE.md`; technical reference in sections 11–16 of `storm_connections_itachi_tools/captured_assets/procedural/shader_constant_pipeline.md`.

Closed:

- **Pixel oracle.** RenderDoc headless dumps (`run_renderdoc_script.ps1`, `rd_export_textures.py`, `rd_dump_samplers.py`) and a software replay of the game's own bytecode (`soft_replay.py`, `replay_capture_draws.py`): the main fire layer of capture 22136 reproduces to ±1/255 on 99.99 % of 1.46 M pixels.
- **Shader key = NUD material `flags`**; three translated families (F002/F007 with 0–2 screen films, F008 falloff, 3F009 refraction) as SM3 shaders built by `build_storm_fx_shaders.py`.
- **Sampler rules**: NUD wrap codes are D3D11 address modes, LOD bias −16 (mip 0 only), border colour 0.
- **Per-model context**: `nuccChunkModel` header bytes 6/7 are the draw layer and the light-set index (R55, native mechanism in R61); `nuccChunkCoord` tenth float is node opacity.
- **Particle rules**: native fade state machine, one-update size lag for model particles, no draw on the birth frame.
- **Skill actor**: orientation updater `0x140a61c20`, shared setup `0x140a6cb10`.
- **Port r18** (`storm_amaterasu_lab`): `storm_fx_render.lua` + rewritten `procedural_player.lua`; every resource of `hit00` and `blt00` has a renderer; `storm_amt_skill` plays crawler then impact.

Verification commands (run from `storm_connections_itachi_tools`, bundled Python):

- `verify_port_shaders.py` — port shaders vs game shaders, per captured draw (needs the RenderDoc texture exports: `--prepare FRAME` then `run_renderdoc_script.ps1 -Script rd_export_textures.py`).
- `verify_port_constants.py` — captured deterministic constants reproduced by the port's simulation.
- `verify_port_winding.py` — culled meshes front-facing for Source.
- `verify_procedural_player.py` — GMod API usage with stubs, including the skill sequence.
- `port_preview.py [--skill] --port-frame N` — offline image of the port inside a captured game frame.

Next, in this order:

1. **Live GMod test of r18.** Nothing has run in GMod yet. Install with `install_procedural_r7.ps1`, restart GMod, run `storm_amt_skill` and `storm_amt_procedural 1 1`; compare with the offline previews in `gpu_captures/rd_dumps/port_preview/`. If something is missing or black, the first suspects are the `screenspace_general` conventions that are emulated, not measured: `$vertexnormal`, eight texcoord channels, `render.OverrideBlend` with separate alpha factors, `_rt_FullFrameFB` in `$texture1`, and `$cull 1` winding.
2. **Refraction depth test.** The game keeps the undisplaced pixel when the displaced sample is in front of the surface. The port has no scene depth, so foreground objects ghost for ~12 frames (0.77 % of pixels on capture 22127). Needs a GMod depth source validated live.
3. **Layer → render context.** R61 closed the fog / ambient question at the model level: ambient comes from the context light set indexed by the header's light byte, fog from the object at `context+0x20` of the context the model is submitted in, and the mask given to `0x1413368f0` is only the shaders' declared accessors. Still open: what binds the layer byte (`model+0x2A`) to a render context and to a `nuccLayer*` class (item 1 of r23), and what the attribute bits (`model+0x29`) do.
4. **Crawler guidance and launch point.** Translate `0x140a62320` (target search and steering) and find where `begin00` places the projectile; both are host stand-ins today.
5. **Point light and post chain.** `blt00` carries a point light (intensity −1, radii 150 / 300); the binder and the three scalars' meaning are not traced. The post-process chain (glare, tone control) is inventoried (R51) but not ported.
6. **Second skill.** Run another skill through the same generic path to find what is still Amaterasu-specific (items 3–5 of r23 still apply).

Do not present the render as exact: the shader maths and the deterministic constants are verified offline, the GMod-side behaviour is not, and particle placement is random by nature.

## r25 generic import pipeline, skill behaviours, lit families — 2026-10-02

Journal entries R62–R79 in `MOTEUR_EFFETS_REVERSE.md`. The goal changed from "Amaterasu" to "any skill": extract parameters, materials, textures, shaders, animations and behaviours per skill and replay them in GMod through a reimplemented engine. Amaterasu is the validation case.

State (everything below is checked offline; see "Not verified" at the end):

- **Import**: `storm_import.py <skill stem>` writes `lua/storm_fx/packages/<stem>.lua`, the VTFs and one translated shader pair per material. External chunks resolve through `chunk_index.py` (7 058 files indexed in `game_cache/`).
- **Shaders**: `shader_port.py` translates the game's SM4 pairs (`nuccMaterial_dx11.nsh`, by NUD shader key) to SM3 for `screenspace_general`. Constant classes: per draw (c0–c3), stage (baked TEXCOORDs), material (compiled in), object (stage vector taken into object space by the vertex shader — the light direction of the lit families). Hand-written `storm_fx_*` shaders are no longer used.
- **Engine r21**: `lua/storm_fx/player.lua` follows `ccGameObjectSkill` (update order, events, commands, shot types), motion is `lua/storm_amt_lab/skill_actor_core.lua` (ARROW, ELEVATOR, CRAWLER, SINCURVE, BOUNDBALL, guidance, bank roll, N-way and random-creation shots, MT19937). Lit (toon) meshes draw with the captured stage's light, stage colour and cel-shade offset.
- **Native execution**: `native_image.py` maps `NSUNSC.exe` in the Python process; game routines are called directly. A translation checked this way is "native-verified" (bit-identical outputs).

Verification commands (from `storm_connections_itachi_tools`, bundled Python):

| command | what it proves |
|---|---|
| `verify_skill_actor_native.py` | motion core == game code, bit for bit: random spread, shared init, ARROW / ELEVATOR / SINCURVE / CRAWLER inits and updates (guidance, bank, orientation), N_WAY and RANDOM_CREATION |
| `verify_anm_keys_native.py`, `verify_scalar_animation_native.py` | every scalar / vector table key reader == game code |
| `verify_light_direction_native.py` | `g_lightDirection` = inverse(model) × light direction |
| `verify_shader_port.py --all [--fog-clamp --smooth-normals]` | translated pair vs game bytecode, synthetic scenes, any key |
| `verify_package_shaders.py <stem> [--addon game_cache/survey_addon]` | every mesh of an imported skill, real constants and addressing |
| `verify_port_shaders.py` | captured Amaterasu draws (needs the RenderDoc texture exports) |
| `verify_port_constants.py`, `verify_import_equivalence.py` | Amaterasu constants and data unchanged |
| `verify_procedural_player.py` | GMod API usage with stubs, skill chain timing |
| `verify_skill_behaviours.py` | each behaviour on a real script of the game, in the engine |
| `play_package.py <stem>`, `survey_play.py --count N --seed S` | packages play to the end without Lua error; lists what is missing |

Not verified, say so whenever results are reported:

- **Nothing of r21 has run in Garry's Mod.** A copy of the r20 addon was in GMod with the game open during the session (not installed by these tools); r21 is only in the project folder. Install with `install_storm_fx.py` (moves the installed addon to `garrysmod/storm_fx_backups/` first, refuses to run while the game is open), then `storm_fx_list <package>`, `storm_fx_cast <package>`, `storm_fx_diag`.
- The lit families are bytecode-equivalent on synthetic inputs; no captured toon draw was replayed. Stage inputs (light, colours) are those of the one captured stage.
- Everything the game takes from its world is a host stand-in in the engine: target = one point, ground / walls = traces, character hit = reaching the target point, surface kind = Source material.

Next, in this order:

1. **Live GMod test of r21** with the list above; first suspects if something is wrong are unchanged from r24 item 1 (`$vertexnormal`, eight texcoord channels, `render.OverrideBlend`, `_rt_FullFrameFB`, culling), plus: do shaders load from the addon's `shaders/fxc`, and does a client `include()` need the generated `AddCSLuaFile` list.
2. **Effect point lights → lit materials.** ANM light entries (type 6) and light clumps (`4efb_light00`) exist in the packages; the lit shaders read `g_pointLight*0..3` from the light set. The engine compiles "unused slot" values today.
3. **Outline.** The toon pixel shaders write `o1` / `o2` (outline id, `g_olIdParam`); the outline is a later screen pass. Trace it (r23 item 1, layers and targets) before porting.
4. **Skinned NUD meshes** (31 of 30 surveyed skills' gaps): bone-weighted vertices need the skeleton animation of the effect; decide between CPU skinning per frame and a bind-pose import.
5. **Importer gaps by frequency** (`captured_assets/skill_play_survey.json`): animation chunk in a file the script does not list (19), billboard / primitive-batch / clump members of a clump (13), scripts defined in several skill files (4) or in none (7), attachment stride (5), NUD address mode outside 1–4 (3), more than four textures, control flow, trails, non power-of-two textures, soft-particle depth.
6. **Behaviours left**: `SkillHoming` (following another object), `HitAttach`, `SkillDecal`, `CameraQuake`, `<Animation coord>`, skill-to-skill hits, BOUNDBALL rolling and water, the range / lifetime limit of an object nothing ends.
7. Layers, targets and screen filters (r23 items 1–2, r24 items 2, 3, 5) are unchanged.

Do not present the engine as complete or the render as exact: the list above is open, and no GMod frame has been compared with the game.

## r26 sampler state, mips, point lights, four-float channels, skinned meshes — 2026-10-03

Journal entries R80–R82. Engine **r22** (project folder only).

What changed since r25:

- **Sampler state per texture** (R80): NUD wrap codes 1–8 (5 clamp, 6 / 8 mirror once, 7 wrap), filter codes and LOD bias are read from the NUD texture record as the game's material builder does (`0x141270830`); `verify_sampler_state_native.py` runs the game's converters. The earlier "effect samplers have LOD bias −16, mip 0 only" was a generalisation of the Amaterasu captures and is withdrawn: about half the effect textures are mip-mapped, and the toon ramp is point filtered.
- **Mips**: `nut_to_vtf.py` writes a second VTF (`<name>_m`) with the NUT's levels when a material's sampler reaches them; the translated shader computes the level itself (`Level()` = D3D11 reference formula, bias and last level compiled per material) and samples with `tex2Dlod`. A sampler that stays on level 0 names level 0 explicitly.
- **Verification rasterizer** (`soft_replay.py`): mip levels, bias, point filter, screen derivatives on 2×2 quads, mirror once.
- **Point lights** (R81): effect lights (animation entries of type 6, hanging from a coordinate) register with the scene; a lit model gets the first four registered, sorted by −attenuated intensity × distance; the lit shaders read slot 0. `point_light_core.lua` is native-verified (`verify_point_light_native.py`); `verify_point_lights.py` checks the engine wiring on real data. Light bytes 0 / 1 / 3 are light *modes* (callbacks), not light sets.
- **Four-float baked channels**: `$tcsize<n>` = 4 and `mesh.TexCoord(set, s, t, u, v)` (GMod documentation) double the stage values a mesh can carry (28). Stage values no longer spill into the pixel constants of the lit shaders, no stage value is frozen any more in `cw0_x`, and the nine floats of point light slot 0 fit per draw (37 of 38 lit meshes there).
- **Host stand-in**: lights of positive intensity become Source dynamic lights (`STORM_FX.host.dynamicLights`, `lightBrightness`).
- **Skinned NUD meshes** (R82): the game skins on the GPU with a compute shader that is in no game file; it was taken from a RenderDoc capture (`rd_dump_compute.py`, `gpu_captures/compute/`). Arithmetic and palette rule (`transpose(pose × inverse(rest))`, one matrix per clump coordinate, NUD bone index = clump coordinate index) are capture-verified. The importer reads skinned vertices and the clump's rest pose; the engine builds the palette per update, skins on the CPU (`skinning_core.lua`) and draws a dynamic mesh.
- **Animation hierarchy**: a coordinate an animation lists but does not animate keeps its rest transform under its parent's pose (was a Lua error for such effects); one clump chunk can appear as several clumps of an animation, or twice as two copies.
- **Material texture slot without a texture** (`0x9f007` with one texture): read as zero; `verify_package_shaders.py` gives the game side a random texture there, so a PASS proves the output does not depend on it.
- **Old particle chunks** (version ≤ 0x77): 48-byte attachment and 96-byte force records, as the reader `0x141320290` takes them.
- Importer: an attachment without a clump no longer crashes the import; `storm_import.py --addon`.

Verification commands added to the r25 table:

| command | what it proves |
|---|---|
| `verify_sampler_state_native.py` | NUD wrap and filter codes → D3D11 state, against the game's converters |
| `verify_point_light_native.py` | light sort key (bit-exact) and selection order == game code |
| `verify_point_lights.py` | the engine registers an effect's light and hands lit meshes the constants the rule gives |
| `verify_package_shaders.py <stem>` | now also: mip selection (each level has its own random texels), point filter, and for meshes lit by a point light the per-vertex / per-pixel difference on a dense mesh |
| `verify_skinning_capture.py` | skinning arithmetic == output buffer of the captured compute dispatches (needs `gpu_captures/compute/`, written by `run_renderdoc_script.ps1 -Script rd_dump_compute.py`) |
| `verify_skin_palette_capture.py` | what the palette holds, by the bone lengths of Itachi's skeleton in the captured frame |
| `verify_skinned_models.py <stem ...>` | the engine's skinned vertices == linear blend skinning written from the package data, every frame |

Not verified, say so whenever results are reported:

- **Nothing of r22 has run in Garry's Mod.** New things a live test has to show: VTFs with a full mip chain whose last levels are zeros, `tex2Dlod` / `ddx` / `ddy` in `screenspace_general`, four-component texture coordinates, dynamic lights, dynamic meshes (`mesh.Begin` without a cached mesh) under `screenspace_general`, and the cost of Lua skinning on large models.
- Skinned models: the palette rule comes from a character of the capture, no skinned *effect* model was captured; the draw matrix of a skinned effect model is the one that makes the root palette entry the identity (positions do not depend on it).
- The level-of-detail formula is the D3D11 reference; the game's actual level comes from the GPU driver. No captured draw was replayed with its mips.
- A mesh lit by a point light is shaded per pixel where the game shades per vertex (the vertex shader has no per-draw constant): equal with no light, converging on dense meshes, not equal on coarse ones.
- When the game takes an effect's light back, the light's outer matrix (`+0x28`), the stage's default light set and the mode-3 ambient / directional values are not traced.

Next, in this order:

1. **Live GMod test of r22** (r25 item 1, plus the list above). `install_storm_fx.py` has still not been run; the copy in GMod is r20.
2. **Outline** (r25 item 3): the toon pixel shaders write `o1` / `o2`; trace the screen pass before porting.
3. **Billboard and clump members of an animated clump** ("clump member X is a nuccChunkBillboard / nuccChunkClump"): find how the game draws a billboard that hangs from a clump coordinate.
4. **More than four textures** (`0x20f001` and friends, 21 meshes in 120 skills): `screenspace_general` binds four; needs either a texture atlas or a split pass.
5. Importer gaps and behaviours of r25 items 5–7, unchanged (scripts defined in several skill files or in none, trails, control flow in a shader, non power-of-two textures, SkillHoming, HitAttach, SkillDecal, CameraQuake).
6. Capture checks now within reach with `run_renderdoc_script.ps1`: the mip level of a bias-0 draw (`1efc_board01`, event 6812 of frame 22136) with its exported mip chain; the toon draws of the captured characters, now that their skinned vertices can be taken from the compute output.
7. What the game binds to a material texture slot the material has no texture for (R82 note in `shader_port.py`).

Do not present the engine as complete or the render as exact: the list above is open, and no GMod frame has been compared with the game.

### r26 addendum — multi-image NUTs, NUT pixel format 6 (R84, 2026-10-03)

- A NUT can hold several images: colour variants of one picture (cache: 10 NUTs with two, 7 with four). The game registers image *i* under the chunk's texture id + *i*; on the paths found (model draw, particles) image 0 is bound unless a colour index is set at run time, and no model of the 3 319 imported nor of 1 968 sampled character models has the header flag 0x80 that enables the model colour offset. `nut_to_vtf.read(source, image)` reads one image; the importer converts image 0 and lists the other variants under "unsupported". Character meshes that were refused for this (`3efb_3nrtawa2_x`: twelve models) now import; `verify_package_shaders.py` and `verify_skinned_models.py` pass on that package.
- NUT pixel format 6 = A1R5G5B5 big-endian, identified on `3nrvbody` against its DXT5 variant (0.9998 correlation per channel, alpha bit = DXT5 alpha on every pixel).
- Not found: the routine that turns the texture id 0 of a NUD texture record into the material's texture chunk id (slot *i* ← *i*-th texture of the group is capture-verified only for one-image textures), and so how the game picks a character's alternate colour.

## r27 camera-facing models, billboard members of animated clumps (engine r23) — 2026-10-03

Journal entries R84–R85. Engine **r23** (project folder only; the copy in GMod is still r20).

What changed since r26:

- **Multi-image NUTs and NUT pixel format 6** (R84, see the r26 addendum above).
- **Camera-facing models** (R85): header attribute bit 0 (the word at +4 of the nuccChunkModel header, model +2C) makes the model draw apply slot +68 once per draw. nuccModel `0x1412d4f40` replaces the rotation by the camera's and keeps axis lengths and translation; nuccBillboard `0x1412c84b0` adds roll (binary angle), size and a world-space offset. `facing_core.lua` is native-verified (`verify_facing_native.py`); the camera basis (right, up, right × up) comes from 94 captured camera-facing draws. Every billboard resource model has the bit; 164 animation-drawn and 31 clump-resource models have it too and were drawn in their coordinate's orientation before.
- **Billboard members of an animated clump** (R85): imported (`clump.billboards`) and drawn: own clock (the animation's accumulated delta; wraps if the chunk loops, else holds), keys copied into the material instances (UV sets 0 / 1, blend, header float, threshold, outline id), opacity × channel 4, facing hook with offset / roll / size.

Verification commands added:

| command | what it proves |
|---|---|
| `verify_facing_native.py` | `facing_core.lua` == the two camera-facing hooks of the game (2 000 random cases each) |
| `verify_billboard_members.py [stem ...]` | every animation of seven packages that draws a camera-facing model or a billboard member: world matrix, UV set 0, threshold and alpha of each draw == what the package data and the game rule give; negative control with the hook off |

Not verified, say so whenever results are reported:

- **Nothing of r22 / r23 has run in Garry's Mod** (r26 list, plus camera-facing models and billboard members).
- Billboard members of an *emitter-resource* clump (two in `2mkg_x`) are still refused: who advances their clock was not traced.
- The colour variant a character uses (multi-image NUTs, R84) and the routine that maps a NUD texture record's id 0 to the material's texture chunk.

Next, in this order:

1. **Live GMod test of r23** (r26 item 1 and the lists above). `install_storm_fx.py` has still not been run.
2. **Outline** (toon `o1` / `o2`, r25 item 3).
3. **More than four textures** (r26 item 4).
4. Importer gaps of the latest survey (`captured_assets/skill_play_survey_r23.json`): clump members that are clumps (`1efc_leaf01`) or primitive batches (`2nejeff1_07`), emitter-resource clumps with billboards, and the r25 items 5–7.
5. Capture checks of r26 item 6.

Do not present the engine as complete or the render as exact: the list above is open, and no GMod frame has been compared with the game.

### r27 addendum — animation references (R86, 2026-10-03)

- The animation reader `0x14134a350` resolves each field its own way: a clump block's clump page-local up to version 0x67 (pairs above), its coordinates / materials / models always through the page's reference pairs, objects outside the clumps and the extra coordinates always page-local. The importer now does the same (`decode_effect_animation.decode(..., resolvers=)`). Effects: light / camera / ambient entries now name their own chunk (R81's "a light names a coordinate" was a misread reference; light positions are unchanged on the two checked animations, the engine hangs lights on the animation root); the old-format animations (0x63 / 0x65, e.g. the dodge leaves `1efc_leaf_ptc01`) now decode their members.
- Packages imported before this keep the old names of outside-clump entries; re-import them to get the chunk names (the engine does not depend on those names any more).

### r27 addendum — shared scripts, outline pass, more than four textures (R87–R89, 2026-10-03)

- **Shared scripts** (R87): a script several skill files define is imported when every copy is the same; `wskn_e_hitWorld00` (two different copies) stays refused.
- **Outline** (R88): the 0xF001 pass is an inverted hull, but every captured outline draw has `g_dloutlineParam` = 0, so the hull is not inflated; the visible outline is a screen pass not yet identified (the pass that reads the toon draws' second target, `f826fc2c`, is a distortion pass). Nothing ported.
- **Five to eight textures** (R89): pairs that sample them use `screenspace_general_8tex` (GMod 2025.12.01; the player drops the mesh with a note when the shader is missing). Check in the live test that this GMod has it.
- Next list of r27 unchanged otherwise: live GMod test of r23 first.

### r27 addendum — trails (R90–R91, 2026-10-03) — engine r24

Engine **r24** in the project folder (material names `storm_fx_r24_*`); the copy in GMod is still r20, and `install_storm_fx.py` has still not been run. Packages exported before this addendum may contain `\uXXXX` escapes that Lua cannot read (only `1knk_x` in the survey had them; fixed in the exporter, re-import any other package that fails to load).

- **Trails** (`nuccChunkTrail`, 2 027 chunks in the game) are now imported and played. Every effect animation object carries the trails of its animation: the effect's own, and the one each particle with an animated resource plays (in `1efcmn_x` the debris of `1efc_exp_hit01`, `1efc_hitm01`… each trail a ribbon). A trail samples its two edge coordinates once per update of its owner, fades and trims by the game's rules, and shrinks to nothing once its owner is gone.
- `trail_core.lua` (subdivision `0x1413248a0`, vertices `0x141325a50`) is native-verified; the update `0x141325090` is translated, not run.
- The ribbon is drawn with the game's trail program (shader key 0x1F007, no NUD material, the DrawTrail constants), the billboard model's texture with the trail's own sampler (wrap, trilinear, LOD bias −8), and the UVs of the billboard's frame.
- `verify_trails.py` rebuilds every ribbon the engine draws through the game's vertex routine and compares the emitted mesh (effect root moving on a circle): `1efcmn_x` 532 ribbons / 400 764 vertices, `1hak_x` 42 / 2 220 (animated billboard UVs; the negative control is caught), `2cyb_x` 63 / 4 062, `1sin_x` 18 / 1 620 — all identical at the stub's float32 / 8-bit colour precision.
- Trails the game never runs are not imported (fewer than two edge records: the factory destroys them; no billboard: no draw); a trail whose edge coordinate its animation lacks stays empty, in the game too.
- Side finding: emitters 11–13 of `1efc_hitm01` / `hitl01` / `hits01` (sparks with trails) have only a stop event; emitters start inactive, so they never emit in the engine. Their activation in the game (external?) is not traced.

Not verified, say so whenever results are reported:

- **The render state of a ribbon** (blend modes, depth write, cull, sort bucket): the game takes it from three words of the billboard model's nuccChunkMaterial object whose writer was not found. The port uses the billboard model's NUD state instead; every package with trails lists this under "not imported". A capture of a skill with a trail would settle it.
- The render context colour (`g_multColor` of the trail draw) is assumed white; the ribbon's layer is the billboard model's.
- Trail force fields (table 3, R92) are ported and native-verified (`verify_trail_native.py`: 3 000 cases, both branches); the key the game uses to find a field's coordinate is not traced (the port tries parent + name, then the name). Fields of version ≤ 0x78 chunks have undefined strength and flags in the game: not imported, reported.
- Nothing of this has run in Garry's Mod.

| command | what it proves |
|---|---|
| `verify_trail_native.py` | `trail_core.lua` subdivision and vertices == the game's routines (3 000 random cases, bit for bit) |
| `verify_package_shaders.py <stem> --addon ...` | now also checks each trail's ribbon pair (0x1F007 with the DrawTrail constants, the trail's sampler): exact on `1hak_x` |
| `verify_trails.py [--package 1efcmn_x] [--control]` | every edge of every trail resolves to one coordinate entry; every ribbon the engine draws == the game's vertex routine on the trail's points, the billboard frame the game shows, the effect's world transform and the strip's triangles |

Play survey r24 (`captured_assets/skill_play_survey_r24.json`, 30 random skills, R93): all imported and played, no Lua error. The animations still missing are absent from the shipped data (demo effects, `b02cmneff1`, `1inoeff1_wpn02_hit03`); script paths with backslashes are now normalised (`bossNrt` files load).

Ground contact (R94, host stand-in): a still or crawling object meets the floor within its world-hit radius, reported when contact begins and when the kind of surface changes; unknown materials count as `P.host.defaultGround` (DIRT). The surface-variant scripts (`1efc_e_ge12`…`19`, `7brteff1_*_worldhit00`, `5jrbeff1_*_ge00`) now launch their effects; `verify_skill_behaviours.py` checks it ("Ground contact"). The game's collision query itself is not traced.

Light bytes (R95): every model light byte without a light mode in the effects' table (all but 0, 1, 3) takes the context's default light set, the one captured under byte 4; only mode 3 (light manager ambient) stays a host default. Play survey r24b (30 more skills, after R94/R95): all played, no Lua error, remaining gaps are data absent from the game (`7yrieff1`, `b1102` animations).

**GMod's LuaJIT (R96).** Big packages did not compile in Garry's Mod's LuaJIT ("main function has more than 65536 constants": 31 of the survey's packages, every big one); the offline Lua 5.5 accepts them. The package writer now splits big tables into functions of their own (data unchanged: 492 237 values compared on `1efcmn_x`). `verify_luajit.py` compiles every Lua file of an addon with the game's own `lua_shared.dll` (read only): the project addon's 59 files pass. **Re-import any package written before this** (all of `game_cache/survey_addon` predates it) before copying it into GMod. `verify_luajit_runtime.py` runs float32, `trail_core` and `facing_core` under both LuaJIT and Lua 5.5 on one deterministic script: 837 015 values, none differ (compared as doubles).

**Coordinate hierarchy (R97).** `anm_resource_core.coordinateMatrices` resolved the coordinates with `pairs()` over a table it was adding rest parents to (undefined in Lua): with some string-hash seeds a coordinate kept no world matrix (`3efbtf_2mkg2_blt00`, the one Lua error of survey r24c, not reproducible from run to run). It now resolves in entry order. `verify_anm_hierarchy.py [--addon ...]` requires a world matrix for every coordinate of every animation at three ticks, equal bit for bit to the parent chain walked independently: survey addon 220 packages / 3 525 animations / 65 151 coordinate evaluations, project addon 7 animations, no miss, no difference (control: ignoring the parent links differs). It checks the hierarchy's consistency, not the game.

**Trails on a capture (R98).** The Amaterasu captures hold four trail draws (frames 22082 / 22102): the two black trails of `4efb_amt1_blt00`, the projectile. The project's `4efb_amt1_x` predated trail import and is re-imported (with `3efb_3ssk1_x`). Against the capture (`verify_trail_capture.py`, data from `replay_trail_draws.py`):

- render state: the game draws them with 0x121 (SrcAlpha / InvSrcAlpha, depth test without writes, no cull), not with the billboard model's NUD state (which writes depth); every trail now takes 0x121;
- constants: `g_multColor` is white there, `g_commonParam` (FLT_MIN, 1, 1, billboard alpha), as the port sends;
- shape: 12.5 a update of travel (the engine's CRAWLER speed), 7.5 of rise from the force field, width 80, perpendicular trails; the engine with a straight-moving root, oriented as its skill actor orients the projectile (local −y forward), matches every vertex within 0.44 units after alignment, at a determined age (19 / 39, next age 2.03 away);
- the effect's point light in the same frames: lateral offset and height from the newest trail point equal the engine's within 0.005 (this fixes the root's orientation; a root turned 90° would fit the ribbons 30 updates away), and its animated intensity (keys differing in the last bits) equals the engine's bit for bit at ages 19 / 39, not at 49 / 69;
- billboard frame: the game shows one frame earlier than one call per effect update gives; the player now uses `t.updates − 1` (why is not traced; a first, wrongly oriented fit had suggested +1);
- colours and UVs: bit-exact from the captured positions with the player's frame.

Travel is an input; one trail definition is captured, the 0x121 rule and the −1 frame are applied to all trails without further proof. The material words' writer is still not found. Engine **r25** (materials `storm_fx_r25_*`): the ribbons' state and frame changed, so a copy of r24 made by hand must not be mixed with it; the installed copy is still r20 as far as known.

**Seen in Garry's Mod (R105, 2026-10-03).** Installed at the user's request (r25, both project packages). Unattended run on `gm_construct` (`data/storm_fx_selftest/autostart.txt` starts `storm_fx_selftest` once the map has loaded; the game is closed from outside, `quit` is blocked from Lua): no Lua error from the engine, 25 materials on `screenspace_general_dx9` with no error material, the Amaterasu projectile running with its particles (up to 35) and both trails (up to 37 draws), the black flames visible and consistent by eye with the game's frame 22102. Results in `captured_assets/gmod_selftest/20261003_1117_r25/`. A second run (view pitched 12° down before the cast, `.../20261003_1120_r25_impact/`) shows the whole skill: projectile with trails, impact at 0.9 s (up to 70 particles, 80 draws), black-and-purple flame pillar, fade-out by 3.5 s, no error. Visible gap: the refraction dome looks milky (scene depth unavailable, R67). Not done in game yet: other skills, a comparison at an equivalent camera.

**Library and first fixes from play (R106).** The user's goal: a library addon that renders the game's effects, called like `ParticleEffect`, with no notable cost. Reported in game: effects show through walls / the player; each effect halves the frame rate. Done (offline-verified, not yet measured in game):
- depth: no more `render.OverrideDepthEnable` (it appears to switch the depth test off with the writes); the material's `$depthtest` / `$writedepth` hold the state (`storm_fx_depthoverride 1` for the old behaviour);
- cost: no float32 rounding in GMod (`storm_fx_exact 1` to restore), draw constants sent only when they change, no string building per draw;
- `StormFX.Play("package/effect", pos, ang, {scale, seed, parent, attachment})` → handle (`IsValid`, `Stop`, `Remove`, `SetPos`, `SetAngles`), `StormFX.Cast`, `StormFX.Precache`, `StormFX.StopAll`, `StormFX.Effects` / `Scripts`; server calls go to the clients (`storm_fx/net.lua`). `verify_api.py`.
- To measure in game (GMod closed): install, write `garrysmod/data/storm_fx_selftest/autostart.txt` = `perftest`, start `gm_construct`; `perf.json` + `occlusion_*.png`. (The depth hypothesis above was wrong, see R107.)

**Depth and cost fixed in game (R107, engine r26).**
- Depth: GMod's `screenspace_general` (`bin/win64/stdshader_dx9.dll`, shadow state at 0x18004e8e8) sets `DepthFunc(ALWAYS)` when `$writedepth` is 1, so 16 of Amaterasu's 23 materials were drawn over everything. Materials now always have `$writedepth 0` / `$depthtest 1`; the NUD state's depth writes go through `render.OverrideDepthEnable` (writes only). `$x360appchooser` is not a parameter of that shader (removed). Seen in game: an opaque plate hides the effect; without the plate it is drawn. The visible change (flames cut by the ground and by their own opaque parts, no milky dome at the impact) brings it closer to the game's capture 22127 (`captured_assets/gmod_selftest/20261003_1219_r26/`).
- Cost: `PostDrawTranslucentRenderables` ran three times a frame on gm_construct (water reflection, water refraction, screen) and the engine rebuilt the draw list each time. Now built once per frame from the main camera (`RenderScene`), drawn per view, water views left out unless `storm_fx_water_views 1`; billboard math in plain numbers; one reused constants table. Measured: 1 effect +0.40 ms a frame (was +1.8), 8 effects +2.5 ms (was +10.6); 8 with water views +3.9.
- In-game tests: `perftest` now writes occlusion captures (effect, opaque pass, sphere reference, without other addons' hooks, without the plate), frame-time cases 0/1/2/4/8 + far + cost attribution (`P.skip`) + water views, the views seen per frame (`P.views`) and the other addons' render hooks. `storm_fx_diag` prints the views and the draw-list time.
- Next, if the cost must go lower: the draw list (1.34 ms for 8 effects: `fx.pack` and the entries are still tables per draw), the simulation (0.56 ms), then batching one material's billboards into one dynamic mesh (draw constants would have to become vertex data: they are pixel-shader constants today, 16 floats, and SM3 carries 40 interpolated values). Unexplained: worst frames up to 28 ms with 8 effects (2.4 ms without). Not checked in game yet: the library API (`StormFX.Play` from another addon), a third-person view, other skills. Full offline suite on the final r26 code: 33 / 33 exit 0 (2026-10-03 12:40).

**On a dedicated server (R108, engine r27).** Deploy only with the installer, never by copying the project folder (lab scripts; a server does not send big Lua files): `python install_storm_fx.py --server --gmod C:\SteamCMD\solve\garrysmod` (refuses while gmod.exe / srcds.exe run; backs up the previous folder to `<garrysmod>/storm_fx_backups/`). The user's server has r27 since 2026-10-03 12:57; the addon is no longer in the user's game files (`--remove`, backed up). Packages now travel as content (`data_static/storm_fx/<package>.txt`, `CompileString`): a client Lua file may not exceed 64 KB compressed and the packages are 75–100 KB. Clients must have the content (textures 3.7 MB, packages 1.4 MB, shaders): server downloads are refused by `cl_downloadfilter "mapsonly"` (the user's client, and many players'), so the robust way is the Workshop: `python install_storm_fx.py --workshop` builds `workshop_storm_fx_content.gma` (gmad accepted all 81 files); once the user has published it (`gmpublish.exe create -addon … -icon …`, the user's Steam account), reinstall the server with `--workshop-id <id>` (`resource.AddWorkshop`), or add the content to the user's own content pack. Seen on the server: the server → client calls arrive (three `StormFX.Play` from `server_test.lua`); not yet seen: a client with the content and the effect drawn in multiplayer. Next: that test (client `cl_downloadfilter all` + `retry`, or the Workshop addon), then redeploy the server with the clearer missing-content message (in the project since 13:05, installed copy predates it).

**First test in Garry's Mod (user side, superseded by R105).** Installing was attempted on 2026-10-03 and refused by the session's permission check (it moves the installed r20 addon to `garrysmod/storm_fx_backups/` and copies r25): it is left to the user. With Garry's Mod closed: `python storm_connections_itachi_tools/install_storm_fx.py` (backs up, compiles every Lua file with GMod's LuaJIT first, writes a manifest). Then in game, on any map (`gm_construct`): aim at the ground some 10 m ahead, run `storm_fx_selftest` in the console and close the console. The command casts `4efb_amt1_x`, captures the screen before and 0.15–3.5 s after, and writes `garrysmod/data/storm_fx_selftest/` (`report.json` + nine PNGs: effects, particles, trail points, draws, skipped resources, dropped effects, Lua errors, material and shader state). Those files are what the next session analyses. `verify_selftest.py` runs the same command in the offline stubs (PASS: cast after the console closes, nine captures, effects and trails drawn, 25 materials, no error).

**Non-finite values, emitter-clump billboards (R101–R102).** Play survey r25b (`--count 80 --seed 53`): 80 played, one script error, fixed: the package writer turned NaN / inf into Lua globals (nil); the game's data holds NaN half-float UVs and normals (10 values, `2sco_x`, `3hsm_x`, `3efawa2_3hsm1_x`), now written `(0/0)` / `(±1/0)`. Billboard members of an emitter's clump resource (7 packages) were refused; the game never advances their clock (0x1412c7f90 is reached only from an animation object's clumps), so they hold the keys of frame 0 that their initialisation copies; imported and drawn so, `verify_resource_billboards.py` (17 334 draws of 8 members equal frame 0; control on the one member whose frame 1 differs).

**Missing toon ramp (R103).** A material whose own `celshade` file is not shipped (`c/1fir/tex/celshade.nut`, `3efawa2_3mdr1_2_x`) now resolves to the global ramp (`shader/toon/celshade.nut`): every celshade texture gets the fixed id 0x10000001 in the game.

**All offline checks in one run:** `powershell -ExecutionPolicy Bypass -File storm_connections_itachi_tools/run_verification_suite.ps1` (33 commands, about 10 minutes; summary in `captured_assets/procedural/verification_suite_log.txt`, every line must say exit 0; do not edit the Lua while it runs, it reads files as it goes). Last full run: see the R107 note at the end of this list.

**Emitters without a resource (R99).** Four emitters of the survey have an empty resource list (`1kdm_x`, `1nej_x`, `2efb_edn_x`, `7brn_x`); the port drew a random index modulo 0 and dropped the effect. The game draws no number below two resources and makes the particle without a resource (nothing drawn); the port now does the same. Play survey r25a (`--count 40 --seed 41`, 40 new skills): all played, no script error; its only dropped effect was this one.

Next list of r27 unchanged otherwise (live GMod test first, now of r24); add a capture of a skill with a trail to the capture checks. For a live look at trails: import `1efcmn_x` into the project addon and `storm_fx_play 1efcmn_x 1efc_exp_hit01` (debris trails), `storm_fx_diag` lists every trail's state.

**Clean addon (R109, engine r28).** The code that ships is now `storm_fx/` (project root), rewritten in the style of the user's own addon (`dev_solve_naruto_base`): namespaces (`StormFX.Core.*`, `StormFX.Engine`, `StormFX.Render`, `StormFX.Config`), Hungarian prefixes, one job per file, `cl_` / `sv_` / `sh_` files loaded in an explicit order by `lua/autorun/sh_storm_fx.lua`, settings in `storm_fx/sh_config.lua`, hooks `StormFX:<Part>:<Event>`, net message `StormFX:Call`.
- `core/` (27 files): the game's routines, one module each, standalone (other modules are passed in), float32 operation order unchanged. `engine/`: render rules (`cl_shader_layout`, `cl_render`, `cl_stage_post`), state (`cl_engine`), stage (`cl_stage`), packages (`cl_packages`), trails, effects (`Launch`, `PlayEffect`), skill scripts (`CastSkill`, `RootScripts`, `CastFromPlayer`), lights, update, drawing, console commands. `api/`: `cl_api.lua` (unchanged public calls), `sv_network.lua` / `cl_network.lua`. `debug/`: self test, perf test, server test.
- Host-visible renames: `STORM_FX_SHADER_CONTEXT` → `StormFX.Engine.ShaderContext`; `STORM_FX.netCalls` → `StormFX.Engine.iNetCalls`; material names `storm_fx_r28_*`. `StormFX.Play / Cast / Precache / StopAll / Effects / Scripts` are unchanged.
- `storm_amaterasu_lab/` keeps the content (the importer writes there) and the r27 engine, frozen as the reference: do not change it any more.
- Equivalence: `verify_clean_engine.py` runs the same scenarios in both engines and compares the skill objects and every draw (material, render state, constants, matrix, vertices) each frame. Full: 11 packages, 44 scenarios, 130 602 draws identical. `--wide 60`: 171 scenarios, 526 770 draws identical. Negative control: a 1e-6 change of the billboard width is caught. In the suite as `--quick`; an intended engine change makes it fail by design (re-baseline or retire it then).
- The offline checks now run on the clean addon: `port_preview.Port` loads it by default (`engine='reference'` for the lab), native checks load its cores through `addon_lua.py`. Suite: 33 / 34 exit 0; the failure was a missed rename in verify_skill_actor_native.py itself, fixed (passes).
- Install: `install_storm_fx.py` now installs `addons/storm_fx` (code from `storm_fx/`, content from the lab) and moves an existing `addons/storm_amaterasu_lab` (r27) to the backups (two engines would fight over `StormFX` and the commands); its generated `autorun/server/sv_storm_fx_content.lua` only lists the content. Installed 2026-10-03: content only into the user's game (`--content`), r28 on the user's server (`--server`). `4efb_amt1_blt00` is the looping projectile; the big flame is `4efb_amt1_hit00`.
- Not seen in game yet: anything of r28.
- Cost (offline, 8 impacts, ~540 particles): ~2.3 MB of Lua tables per frame, 544 draws (one per particle), ~7 500 `Matrix:SetField` a frame. Next: zero allocation per frame, billboards batched per material, no simulation out of view, compact binary packages (87 % of a package is geometry written as decimals).

**Lighter frames and particles batched per material (R110).** Per-frame tables removed from the draw list and the particle step (~2.3 MB a frame for 8 impacts down to ~0.6 MB; identical draws). Meshes of up to 8 triangles get a batched shader at import (their per-draw constants travel in TEXCOORD channels, `storm_import.BATCH_TRIANGLES`, `batchable`); the engine draws all particles of such a material in one dynamic mesh placed in world space (`Render.DrawBatch`), a group sorted as one object at its farthest (blended) / nearest (opaque) member; `Config["batchParticles"] = false` gives the game's order exactly. 8 impacts: 544 -> ~225 draws; renders batched vs single identical, vs pre-batch 157 / 855 000 pixels differ (max 15/255); shaders still within 1/255 of the game. `Config["hiddenModels"]` hides models per package (Amaterasu: dome `1efc_nor_dst03`, ground disc `4efb_light00`, at the user's request). Geometry written short (float32 shortest digits): Amaterasu 747 -> 584 KB. `verify_clean_engine.py` retired (the reference engine cannot draw batched packages). Suite 34/34. Installed in the user's game (content) and server (addon) 2026-10-03 16:01; not measured in game yet (`storm_fx_perftest` has an 8-effects-unbatched case). Next: in-game numbers, then detail levels, binary package format with shared common models, no simulation out of view.


**Hashirama — 2026-10-04 (R119).** Destruction par la forêt importée dans `1fir_x`, script racine `1fireff1_jrt_e_begin00` ; quatre ressources animées converties en MDL, meshes conservés pour les autres. Import reproductible : `python storm_import.py 1fir_x --script 1fireff1_jrt_e_begin00`. Contenu installé dans le GMod local et addon sur `C:\SteamCMD\solve\garrysmod`, avec les six paquets précédents. Vérifications du skill, des scripts XML, des shaders normaux et studio et du chemin DrawModel simulé passent. Prochaine vérification : en jeu, `storm_fx_cast 1fir_x 1fireff1_jrt_e_begin00`, puis `storm_fx_diag` ; comparer les racines et leur impact au jeu, notamment les normales comprimées et la séquence des MDL. Détails et limites dans la dernière section du journal.
