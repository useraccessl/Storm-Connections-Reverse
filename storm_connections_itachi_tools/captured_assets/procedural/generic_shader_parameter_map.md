# Generic shader parameter accessors

Reverse target: `NSUNSC.exe`, SHA256 `cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e`.

> **Read `shader_constant_pipeline.md` first (R43–R48).** It supersedes this
> file on these points: the descriptor row is `{Program*, CBufferDef*,
> Variable*}` (no vtable, no "semantic key"); `0x1412e30a0` / `0x1412e0ed0`
> belong to NUD material loading, not to constant staging; the command classes
> are `mmDrawCommand_*` and tag `0x0d` at `0x141b8e090` is a closure command;
> context slot `+0x238` is `CSSetConstantBuffers`; GPU offsets equal the DXBC
> `RDEF` offsets; `g_matWorldViewProj`, `g_blendType` and `g_uvScaleScreen` now
> have known sources. The accessor inventory, context offsets and capture
> audits below remain valid.

## What this establishes

`shader_bindings_dispatch.json` records 72 native accessor thunks. Each has an `accessor_index` (0–71), a shader-facing semantic name, a matching `name_table_index`, and an explicit `dispatch_path`. The index selects the native accessor function; it is **not** the runtime binding ID passed to the renderer. Every thunk loads its runtime binding ID from the caller record at `+0x04 + 4*accessor_index`; the extractor asserts this formula for all 72 functions. Sixty-one accessors route values to `0x14123bf10`; eleven tail-call the separate resource binder `0x14123c0e0`.

This is a reusable inventory of the engine's parameter vocabulary and CPU-side binding paths. It does **not** by itself recover shader bytecode, constant-buffer register layouts, texture contents, render states, or the meaning of every vector component. Register mapping must come from each shader's reflection/bytecode and a draw capture. Do not equate `accessor_index` or `runtime_binding_id` with a GPU register.

## Native dispatch paths traced

### Per-shader active accessor mask (2026-10-02)

`0x141337b50` is the generic constant application loop. Its helper at
`0x141335710` is an array lookup: it bounds-checks the requested shader index
against `[object+0]`, reads the array base at `[object+8]`, and returns
`base + index*0x130`. At `record+0x124` is a 10-byte bit mask. The loop scans
all ten bytes and calls the global accessor function table only for set bits,
with valid accessor indices 0–71; the final byte's upper bits are storage, not
valid accessor entries. Thus a draw's shader record carries both the runtime
binding IDs and an explicit set of which of the 72 generic accessors apply.
This is the engine's per-shader selection mechanism, not a list of GPU slots.

The same record is consumed by the accessor thunks: the accessor index chooses
the 32-bit runtime binding-ID field at `record+0x04+4*index`. Keep these as two
separate pieces of state when reconstructing an effect: the mask determines
which semantics execute, and the per-index ID chooses the renderer descriptor.
The runtime object is populated by `0x1413352c0`, the registry initializer.
It allocates and zeroes `record_count * 0x130` bytes, stores each shader key at
record `+0`, then walks the native semantic-name table (72 entries). For each
name it resolves that shader's binding ID; a present ID is written to
`record + 4 + 4*accessor_index` and the corresponding bit is set at
`record + 0x124 + floor(accessor_index/8)`. A missing binding stays `-1` and
its mask bit remains clear. This explains the record fields and why dispatch
skips semantics absent from a shader. The source of the shader inventory and
the backend interpretation of each binding ID are still being traced.

The initializer's helpers reveal how it derives the table. `0x14123bb10`
returns the item count for a selected shader-inventory vector;
`0x14123bab0` returns the shader key at a given index. For each key,
`0x14123bb70(shader_key, semantic_name)` resolves the shader metadata object,
looks up the semantic string, creates/registers a missing descriptor when
necessary, and returns the runtime binding ID or `-1`. `0x1413352c0` writes
that result into the indexed semantic slot and sets the mask bit only when the
result is not `-1`. The loader therefore computes presence from successful
per-shader name resolution, rather than loading an opaque mask blob.

#### Name-to-runtime-ID registry (2026-10-02)

The runtime ID returned by `0x14123bb70` is a CPU descriptor index, not a GPU
register number. `0x141239390` searches a name tree rooted at manager
`+0x298`; a hit returns the descriptor's 32-bit field at `+0x48`. If no name
exists, `0x141239450` searches/registers it in the manager's global name tree
at `+0x2c8`. `0x141239510` first checks the existing descriptor registry;
on a miss it registers the name, then offsets the new local index by the
existing descriptor count (`(manager+0x2010 - manager+0x2008) / 24`). The
returned ID therefore addresses a 24-byte CPU descriptor table rooted at
`manager+0x2008`. `0x141239760(manager, id)` selects that row (negative IDs
fall back to row zero).

The row's first qword is a virtual dispatch pointer, `+0x08` is a 64-bit key,
and `+0x10` points at copy metadata. The value accessor path uses this key to
find the active shader-specific copy row in the thread-local render state.
That row supplies the CPU staging destination base and byte offset/size; the
actual write is `memcpy`. This closes the semantic-name -> CPU descriptor ->
active shader binding -> staging-memory path. It still does not make the
runtime ID a GPU slot: the GPU constant-buffer offsets must be read from each
shader's reflection/bytecode or measured in a draw capture.

`0x1412e30a0` builds the per-shader binding rows from parsed shader metadata.
It walks each entry's binding vector and calls `0x1412e0ed0`, then stores the
returned identifier and auxiliary data into 32-byte rows. `0x1412e0ed0`
examines four stage/type buckets while matching 64-bit keys and the compact
stage/type tag; this is the bridge between parsed shader declarations and the
runtime copy rows. Exact field names and the final stage/register encoding
remain to be proven against the corresponding shader package and capture.

The draw's 32-bit shader key is converted to this array index by
`0x1413356d0`. It walks the ordered tree rooted at `[global_registry+0x28]`
(the registry pointer is loaded from global VA `0x14974d558`), compares the
requested key against each node's key at `+0x1c`, and returns the matching
node's value at `+0x20`; missing keys return zero. The draw setup passes this
returned value to `0x141337b50`, so the runtime chain is shader key -> global
registry index -> `0x130`-byte shader record -> active accessor mask -> runtime
binding ID -> descriptor copy. This maps key-to-record selection; the record
and active mask are populated by `0x1413352c0` as described above.

Caller evidence: `0x1412f4d55` invokes `0x141337b50` after creating a draw
binding context; its fallback branch also iterates a material's list of shader
indices through the same `0x141335710` array lookup. This shows that selection
is material/draw-specific and can include multiple shader entries. It does not
prove that the 10-byte mask is serialized in a shader file; it is generated by
the runtime registry initializer from the native semantic name table and
per-shader binding lookups.

### Shader reflection/material binding construction

`0x1412e30a0` iterates a thread-local collection of shader records and builds
per-record binding rows. Its loop calls `0x1412e0ed0` with a 16-byte key and
metadata object, stores a returned 32-bit identifier and auxiliary byte in a
32-byte-stride output row, then calls `0x1413356d0` on that identifier and
stores the returned runtime index in row `+4`. The exact key fields consumed
by `0x1412e0ed0` still need a focused trace, but this is concrete evidence
that the generic `shader key -> record index` helper also participates in
building binding rows, not only at draw time.

Separately, `0x1412e29c0` builds a per-material array of shader-record indices
from a vector of 32-bit shader keys: each key is translated through
`0x1413356d0` and written to a 32-bit array. It also queries a second registry
via `0x14134fc70`, which normalizes the key with `key & 0xf0ffffff` and returns
a 16-byte value that is ORed into a 128-bit material flags field. Do not
equate that flags field with the 10-byte accessor mask at `record+0x124`; the
capture has not established that relationship.

### Value parameters (61 accessors)

1. Accessor thunk reads its semantic's value from the shared context and its runtime binding ID from the caller record at `+0x04 + 4*accessor_index`, then passes that ID and a temporary value to `0x14123bf10`.
2. `0x14123bf10` calls `0x141239760`; the latter selects a 24-byte entry from the global binding registry's range rooted at object offset `+0x2008`, indexed by the runtime binding ID (negative input selects entry zero). The entry uses `+0x00` as a virtual dispatch pointer, `+0x08` as a key, and `+0x10` as a pointer to copy metadata. These are CPU-side descriptor fields, not GPU register numbers.
3. If a descriptor exists, `0x14123bf10` passes it and the value to `0x14123ab80` through the descriptor's virtual dispatch.
4. `0x14123ab80` resolves/caches a record through `0x141239d10`, searches the active shader binding list in thread-local render state by the 64-bit key, and reads a compact copy description: destination offset, byte count (low 24 bits), and a destination base pointer.
5. The terminal thunk at `0x141442fca` resolves to the executable's imported `memcpy` (`VCRUNTIME140.dll`, IAT slot `0x141735ad0`). It copies the accessor's value bytes into the shader's parameter staging area. This call is CPU-side staging, not a direct graphics API upload.

The 61 value accessors divide into three verified conversion shapes: 46 use `0x1412a9ac0`, which copies four 32-bit words (16 bytes); 14 use `0x141283af0`, which transposes a 4x4 matrix by copying four source columns into row-major 16-byte groups; and `g_offsetTone` builds a single 32-bit value from context offset `+0x6e0`. `g_lightColor` is a special case among the first group: its accessor loops over four consecutive float4 colors, copying 64 bytes total. Thus the engine does format preparation before applying the shader-specific byte offset and size.

### Sampler/resource parameters (11 accessors)

The samplers are accessor indices 40–46, 52, 63, 65, and 67. Their thunks pass four inputs to `0x14123c0e0`: runtime sampler binding ID, integer selector, resource pointer, and a float scalar. Runtime IDs occupy the corresponding caller-record fields `+0xa4`, `+0xa8`, `+0xac`, `+0xb0`, `+0xb4`, `+0xb8`, `+0xbc`, `+0xd4`, `+0x100`, `+0x108`, and `+0x110`, as predicted by the `+4 + 4*accessor_index` rule. Context triplets carry the other three values: the standard slots span `(+0x440,+0x448,+0x44c)` through `(+0x4b0,+0x4b8,+0x4bc)`; shadow-pattern and background-shadow use `(+0x680,+0x688,+0x68c)` and `(+0x6a0,+0x6a8,+0x6ac)`. `0x141239ab0` derives the value-descriptor count from the global registry range `+0x2008..+0x2010`, subtracts it from the runtime sampler ID, and indexes the sampler descriptor pointer array at `+0x2020`. `0x14123e7f0` resolves the selector against a resource table; `0x141239d10` returns the keyed per-thread container; and `0x14123c220` appends the sampler descriptor pointer to its growable vector. This route does not use `0x14123bf10` or its `memcpy` path. The meanings of the sampler float and selector, and the eventual backend bind, still need confirmation.

The value route is therefore: context accessor -> parameter descriptor -> shader semantic lookup -> sized copy into parameter staging -> later renderer upload. The sampler route is: context accessor -> sampler descriptor -> resource resolution -> queued binding record -> later renderer bind. Exact registers, stage, vector interpretation, texture identity, and backend operations remain shader-specific. Address findings are for the executable hash above and remain subject to a second shader-family cross-check.

Additional sampler trace: `0x14123e7f0` applies the current thread's resource
namespace base from TLS offset `+0x32c8` to selectors in the low 28-bit range,
then looks the resulting key up in a bucketed resource table. The bucket count
is at table `+0x10`, bucket heads at `+0x08`, chained entries compare key `+0`,
and a hit returns the resource pointer at `+8`. `0x14123c0e0` writes that
resolved pointer into the selected sampler descriptor at `+0x30`, packs the
selector/scalar at `+0x40`, then appends the descriptor pointer to the keyed
per-thread container. This establishes selector resolution and queueing, but
the later backend consumer that turns this record into a GPU texture/sampler
bind is still not identified.

#### Sampler pointer-flow clarification (2026-10-02)

This clarification supersedes the earlier shorthand above about a “cached
sampler record.” In `0x14123c0e0`, the resolved resource pointer is written to
the selected sampler descriptor at `+0x30`, while selector/scalar data is
packed into `+0x40`. `0x141239d10` returns a keyed per-thread container; its
vector begins at `+0x20`, and `0x14123c220` appends the sampler descriptor
pointer if absent. The cache key's relationship to container lifetime remains
unresolved, as does the later GPU backend consumer. Do not interpret
`0x141239d10` as storing the resolved texture pointer based on current evidence.

The queue writer `0x14123c220` appends one pointer to a growable 8-byte-entry
vector (`begin`, `end`, `capacity`) and doubles its capacity when full. Its
verified caller inside `0x14123c0e0` first scans the vector and avoids adding
the same sampler descriptor pointer twice. Numerous effect/material routines
call `0x14123c0e0`; those call sites are binding producers, not proof of the
GPU consumer. A cleanup/reset routine also visits per-thread binding
containers, but its vector walk does not identify the draw-time texture bind.
The backend consumer remains an explicit open item.

## Capture cross-check: Amaterasu principal material

At frame 22136, draw event 5815 binds VS `612d54c9…63f23` and PS `915c5e6e…06abd`. The capture gives a concrete context-to-GPU crosswalk for this one draw:

| Semantic | Native context source offset | Captured VS buffer byte offset |
|---|---:|---:|
| `g_commonParam` | `+0x3b0` | 0 |
| `g_fogColor` | `+0x2c0` | 16 |
| `g_fogParam` | `+0x2d0` | 32 |
| `g_ambientColor` | `+0x2b0` | 48 |
| `g_uvOffset0` | `+0x510` | 128 |
| `g_multColor` | `+0x4c0` | 144 |
| `g_uvOffset1` | `+0x520` | 160 |
| `g_blendRate` | `+0x550` | 176 |
| `g_ScreenToUV` | `+0x500` | 208 |
| `g_uvOffset3` | `+0x540` | 224 |
| `g_uvOffsetScreen` | `+0x4f0` | 240 |

The captured buffer also contains `g_matWorldViewProj` at 64, `g_blendType` at 192, and `g_uvScaleScreen` at 256. Their source paths are not direct matches in the 72-accessor table and remain to be traced. This demonstrates why CPU context offsets and GPU constant-buffer offsets must be recorded separately. The machine-readable crosswalk is `generic_shader_capture_crosswalk.json`. The draw has two material textures at bindings 0 and 1, no blending, depth test `LessEqual`, depth writes enabled, and no culling. It writes three render targets, so matching only the material PS is insufficient to reproduce its complete rendering path. Full capture details remain in `gpu_captures/itachi_amaterasu_frame22136.all_draws.json` and `captured_assets/procedural/r17_mrt_chain_findings.md`.

### Native `g_uvOffsetScreen` material-to-GPU path (confirmed 2026-10-02)

The source path is now closed for this generic semantic. Material binder
`0x1412f5ff0` reads the four rates from its material instance at `+0x60`,
`+0x64`, `+0x68`, `+0x6c`; these are UV2 and UV3 scale channels written by
material-animation channels 20/21 and 18/19 respectively. It reads the effect
counter through `0x1412a4eb0` (counter field `+0x958`), converts it using
float32 operations `counter * 0.1f / 3000.0f`, then computes each output
component as the signed fractional part of `clockSeconds * rate`. The native
zero-rate predicate `0x141299bc0` first takes absolute value and returns true
only when `abs(rate) < 1.1920928955078125e-7f`; that channel is emitted as zero.
The four values are packed in source order and stored to render context
`+0x4f0`. Generic accessor 50 copies that vector to captured vertex-buffer
byte offset 240 (`g_uvOffsetScreen`). Thus screen/noise scroll is sourced from
material UV2/UV3 scales plus the material counter, not from a guessed shader
phase. The binary divisor is the immutable `.rdata` dword `3000` at VA `0x141b948e8`;
only the live counter value remains dynamic. The counter reset/pause scheduler
is separately traced, but the original animation epoch still needs runtime
validation.

`verify_material_context.py` passes for all 213 principal-fire draws across
seven captures and checks float32 edge cases, counter pause/wrap, and captured
ScreenToUV. This validates the binder formula and captured correspondence; it
does not independently recover the live epoch or host update schedule.

### Native `g_ScreenToUV` generation (confirmed 2026-10-02)
The matching captured main-fire vertex shader (`612d54c9`) and pixel shader
(`915c5e6e`) then apply the values as follows. The VS exports screen scale
`(scaleX/width, -scaleY/height)` and screen bias
`(offsetX*scaleX, offsetY*scaleY)`. The PS multiplies `SV_Position.xy` by that
scale, adds the bias, and samples the screen/noise texture at `(u, 1-v)`. Thus,
for this exact shader pair:

`u = SV_Position.x * scaleX/width + offsetX*scaleX`

`v = 1 - (-SV_Position.y * scaleY/height + offsetY*scaleY)`

At the captured `(scaleX,scaleY)=(3,1)`, horizontal film coordinates traverse
three screen widths, while vertical coordinates are inverted once in the VS
and once in the PS's `1-v` expression. This is shader bytecode behavior, not a
Source material guess. The unknown CPU source of the static scale vector is
still open.


Render-context setup `0x141337c60` computes the screen-normalization vector at
`context+0x500`. The caller supplies horizontal and vertical reciprocal extents
in XMM1/XMM2, zeros XMM3 and the fourth stack argument, then calls the leaf
writer `0x1412a96c0`. That writer stores those four scalars to `+0,+4,+8,+0xc`,
so the resulting vector is `(1/width, 1/height, 0, 0)`. In the seven available
Amaterasu captures (213 matching draws), every reflected `g_ScreenToUV` value
is `(1/3840, 1/2160, 0, 0)` within float32 precision. This closes the native
source and formula for accessor 32 in this shader path; dimensions remain a
per-frame input, not an Amaterasu-specific constant.

### Temporal audit of the captured Amaterasu main-fire shader (2026-10-02)

`audit_shader_capture_temporal.py` scans the seven exported GPU captures and
selects the principal-fire pixel shader by hash prefix. It verifies coverage
(7 captures, 213 draws) and writes `amaterasu_shader_temporal_audit.json`.
Grouping values rounded to 1e-6 gives:

- `g_blendType` has one value across all 213 draws: `(0,0,0,0)`.
- `g_uvScaleScreen` has one value across all 213 draws: `(3,1,1,1)`.
- `g_uvOffsetScreen` has seven values, one per sampled frame, and is uniform
  across every matching draw inside each frame.
- `g_uvOffset0` has 45 distinct values and `g_multColor` has four.
- `g_matWorldViewProj` has 213 distinct values for 213 draws; each captured
  mesh transform must be retained/reconstructed per draw.

This classifies sampled invariants versus changing draw inputs, but does not
prove the CPU source of `g_blendType` or `g_uvScaleScreen`, nor recover the
continuous clock between captures. Those two names are absent from the native
72-accessor inventory, so keep their source semantics unresolved. Reuse the
audit for other skills after substituting the captured shader hash and frame
set; do not generalize Amaterasu values to another effect.

## Parameter families

| Family | Accessor names / range | Source context offsets | What can be said |
|---|---|---|---|
| Directional and point lights | `g_lightDirection`, `g_lightColor`, `g_dlightDirection`, `g_dlightColor`, `g_pointLight*0..3` (accessor indices 0–15) | `+0x40` through `+0x140`, plus an indirect `+0x80` light-direction path | Four point-light slots have color, position, and parameter accessors. Exact vector packing and shader use are per shader. |
| World and shadow transforms | `g_matWorldViewInvTrans`, `g_matShadowProj0..3`, `g_matWorld`, `g_matWorldInvTrans`, `g_matWorldView`, previous-frame matrices (accessor indices 16–21, 28–30, 38–39) | `+0x150`, `+0x1a0..+0x260`, `+0x2e0..+0x3e0` | Matrix-valued bindings; matrix convention and transpose behavior still need validation per stage. |
| Cel shading, ambient and fog | `g_celShadeParam`, `g_ambientColor`, `g_fogColor`, `g_fogParam` (accessor indices 22–25) | `+0x2a0..+0x2d0` | Named engine context fields; shader-specific interpretation is not inferred from the names alone. |
| Object/material constants | `g_outlineParam`, `g_commonParam`, `g_uvOffset0..3`, `g_blendRate`, `g_multColor`, `g_shadowColor`, `g_uvOffsetScreen`, `g_olIdParam`, `g_highLightParam` (accessor indices 31, 33–37, 47–51, 69–70) | `+0x3a0`, `+0x3b0`, `+0x510..+0x550`, `+0x4c0..+0x540`, `+0x560` | This group overlaps the material animation layout already documented in `material_animation_findings.md`; UV component meanings must follow the material/shader evidence. `g_highLightParam` and `g_uvOffset3` read the same `+0x540` source address but bind under distinct accessor indices. |
| Screen/camera transforms | `g_ScreenToUV`, `g_clipToUV`, `g_matScreenProj`, `g_mtxVI`, `g_eyePos`, `g_viewUp` (accessor indices 26–27, 32, 49, 53–54) | `+0x500`, `+0x5c0`, `+0x580` | Includes matrix and camera-vector paths. Some accessors derive from a shared view block. |
| Sampler/resource bindings | `g_samplerShadow`, `g_samplerRefScene`, `g_samplerRefPostEff`, `g_samplerDownSampScene`, `g_samplerRefPostEffROnly`, `g_samplerRefTcDeff`, `g_samplerRefDepth`, `g_samplerEnvironment`, `g_samplerShadowPattern`, `g_samplerBgShadow`, `g_samplerBlurVelocity` (accessor indices 40–46, 52, 63, 65, 67) | resource pointer + integer + float at `+0x440/+0x448/+0x44c`, then `+0x450..+0x4bc`, `+0x680/+0x688/+0x68c`, `+0x6a0/+0x6a8/+0x6ac` | These tail-call `0x14123c0e0`, a separate resource path. Runtime sampler IDs follow the caller-record offset rule, not the accessor indices. |
| Color correction and stage effects | `g_cparaColor1`, `g_cparaColor2`, `g_cparaParam`, `g_zrange`, `g_clip`, `g_dloutlineParam`, `g_stageColor`, `g_stageParam`, `g_shadowPatternParam`, `g_blindEffectParam`, `g_ghostParam`, `g_offsetTone` (accessor indices 55–62, 64, 66, 68, 71) | `+0x600..+0x6e0` | Additional post, outline, stage and color controls use value dispatch. Not every draw binds every semantic. |

## Reusable reverse procedure

For a new effect, build one draw record containing: resolved material and textures; vertex/pixel shader identifiers and bytecode/reflection; each bound semantic and captured value; vertex format and geometry source; sampler state; blend, depth, and cull state; render-target inputs/outputs; and draw order. Match captured parameter names to these accessors, then use shader reflection/disassembly to map semantics to registers and operations. Trace scene/post-effect sampler resources through later passes before writing a Source material. Keep unknown fields as unknown until a native accessor or capture establishes their meaning.

## Next native questions

1. Decode global semantic registry entry keys and copy metadata, then map runtime binding IDs through the active shader list to recover stage/register/size and any upper-byte copy flags.
2. Resolve renderer virtual slots `+0xb8`/`+0xc0` behind texture/sampler commands to concrete GPU calls, then identify scene, post-effect, depth, and velocity resources.
3. Map the render-context setup path at `0x141337c60` to per-frame/per-draw values and distinguish global from material values.
4. For each shader family, join accessor IDs to DXBC reflection, capture constants and textures, then compare with disassembly.
5. Validate both routes on at least one non-Amaterasu effect before calling them generic in practice.

## Draw command snapshots (2026-10-02)

Cross-checking a second draw producer confirmed the linked records are a mix of
render-state snapshots and bindings. `0x141400980` allocates `0x110` bytes,
sets record tag `4`, copies state into `+0x30..+0xf0`, then fills context
pointer `+0x100` and flag `+0x108`. `0x1412370a0` emits tag `6` with two
context references sourced from `+0xf8` and `+0x1e8`. Sampler packagers
`0x141236d70` emit tags `10` and `13` with selector/resource payloads. The
record writer helpers only initialize/copy these records; none examined so
far executes a D3D call.

`0x141237b80` is a cleanup path: it truncates the thread-local binding vector
and releases entries. It is not the queue consumer. The exact dispatcher,
GPU constant-buffer upload, and texture/sampler API calls remain open; these
facts are reflected in `generic_shader_record_layout.json`.

### Sampler record execute callbacks (2026-10-02)

The first pointer of each deferred record is a method table. For tag `0x0a`,
the table at `0x141b8d5e0` has execute callback `0x1413f3050` at slot
`+0x20`; nearby type data names it `Command_BindTexture`. It retrieves the
active renderer object through the backend singleton and dispatches
`(binding_id, stage/index, resource)` through that object's virtual slot
`+0xb8`.

Tag `0x0d` uses the table at `0x141b8e090`; callbacks `0x1412390e0` and
`0x141239110` read its nested payload and invoke `0x141237410`. That mapper
converts format/type bits and scalar values into internal flags, then routes
them through renderer slot `+0xc0`. This proves the sampler command records
have executable methods and reach the renderer abstraction. The implementation
behind those dynamic slots and the concrete D3D11 calls are still unknown.

### Core command families found from RTTI (2026-10-02)

The same method tables expose the core render sequence:

| Tag | Type name | Execute callback | Verified route |
|---:|---|---|---|
| `2` | `Command_RenderPolygon` | `0x1413f3570` | Selects renderer slot `+0x80` or `+0x88` from record discriminator `+0x78`; passes geometry/draw fields. |
| `4` | `Command_UpdateRenderState` | `0x1413f3ae0` | Converts the 0x110-byte snapshot with `0x141400360`, then updates renderer state through `0x141420cc0`. |
| `6` | `Command_SetShader` | `0x1413f39d0` | Sends two shader references to renderer slot `+0xa0`. |
| `10` | `Command_BindTexture` | `0x1413f3050` | Sends binding ID/index/resource to renderer slot `+0xb8`. |
| `13` | table `0x141b8e090` | `0x1412390e0` / `0x141239110` | Normalizes type/format/scalar through `0x141237410`, then renderer slot `+0xc0`. |

This identifies executable command objects for render-state, shader, texture,
sampler/resource-state, and polygon draw. It does not yet prove the native
D3D11 call names behind renderer slots or the backend constant-buffer upload.
For Amaterasu, command ordering and exact per-draw payloads still need to be
joined against the captured GPU events.

## D3D11 backend initialization (2026-10-02)

The graphics API is established from the executable's call chain rather than
inferred from RTTI strings. The command callbacks read global object
`0x149751dd0`; its initializer is `0x1413f03c0`, and setup proceeds through
`0x1413f0610`. That setup creates/configures the graphics context using the
virtual table at `0x141bacd80`. Its initialization method is
`0x1413f1070`, which calls `0x1413f1290`, then `0x141415b10`. The latter calls
thunk `0x14162dd53`; the thunk jumps through the import slot
`0x141736410`, identified by PE import metadata as
`d3d11.dll!D3D11CreateDevice`.

This confirms D3D11 device creation. It does not yet resolve the deferred
command interpreter or the implementation behind renderer virtual slots
`+0x80/+0x88`, `+0xa0`, `+0xb8`, and `+0xc0`. Those may lead through additional
engine abstractions before reaching `ID3D11DeviceContext`; do not label them
as native D3D methods until that call chain is traced. Constant-buffer upload,
the command-list traversal, and concrete texture/sampler binds remain open.

### Renderer accessor detail (2026-10-02)

The command callbacks' first virtual call is now identified more precisely.
They read the backend context from singleton `0x149751dd0+8`, call context
vtable slot `+0x20` (`0x1413f1030` in the table at `0x141bacd80`), and that
accessor returns the child pointer stored at `context+8`. The callbacks then
dispatch the command on that returned object's vtable: polygon draw at
`+0x80/+0x88`, shader set at `+0xa0`, texture bind at `+0xb8`, and sampler
mapping at `+0xc0`. This pins down the interface boundary and object nesting;
the child object's concrete implementation/vtable and its downstream D3D11
calls remain unresolved.

### Concrete D3D11 submission methods (2026-10-02)

The device wrapper allocated by `0x1413f1290` is initialized by
`0x141414790`, which installs backend vtable `0x141bae0c0`. Its field
`backend+0x50` is the immediate context output passed to
`D3D11CreateDevice` in `0x141415b10`. The command-interface methods have now
been resolved through that table:

| Engine renderer slot | Backend method | D3D11 context calls |
|---:|---:|---|
| `+0x80` | `0x141417a40` | `IASetInputLayout`, repeated `IASetVertexBuffers`, `IASetIndexBuffer`, `DrawIndexed` |
| `+0x88` | `0x1414178d0` | `IASetInputLayout`, repeated `IASetVertexBuffers`, `IASetIndexBuffer`, `Draw` |
| `+0xa0` | `0x141418360` | `VSSetShader`, `PSSetShader` |
| `+0xb8` | `0x141414fc0` | `VSSetShaderResources`, `PSSetShaderResources` |
| `+0xc0` | `0x141414e10` | `VSSetSamplers`, `PSSetSamplers` |

The COM vtable byte offsets in the disassembly match the corresponding
`ID3D11DeviceContext` methods. The indexed draw selects index format from the
command (`DXGI_FORMAT_R16_UINT` value `0x39` or `DXGI_FORMAT_R32_UINT` value
`0x2a`) and passes the command's index count and base vertex into
`DrawIndexed`; the other branch ends in non-indexed `Draw`. Microsoft documents
these methods as binding the input-assembler state and issuing indexed or
non-indexed primitives ([`ID3D11DeviceContext`](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nn-d3d11-id3d11devicecontext)).

This closes the command callback -> renderer abstraction -> D3D11 context
boundary for draw, shader, texture, and sampler operations. The immediate next
target is state tag 4 (`0x141420cc0`) and the generic semantic upload path:
identify blend/depth/rasterizer state creation and constant-buffer updates,
then join the resulting pipeline state with the particle shader records.

### Depth-stencil state path and unresolved blend route (2026-10-02)

Backend vtable slot `+0xe0` resolves to `0x141417d00`. It reads the raw
immediate context from `backend+0x50` and calls context vtable byte offset
`+0x118` with a state pointer and a stencil reference. On
`ID3D11DeviceContext`, this slot is `OMSetDepthStencilState`; the two arguments
match the official method signature. See Microsoft's
[`OMSetDepthStencilState` reference](https://learn.microsoft.com/en-us/windows/win32/api/d3d11/nf-d3d11-id3d11devicecontext-omsetdepthstencilstate).

The backend method at slot `+0x158` (`0x141416250`) calls byte offset `+0x148`
on the same context field, but its three 32-bit arguments do not match the
expected `RSSetState` signature. Keep this mapping unresolved until its
effective interface/base pointer is confirmed. The full-code scan also finds
calls at offset `+0x110`, but those call sites use different object bases;
they are not yet evidence for `OMSetBlendState` on this immediate context.
No backend vtable method scanned so far calls context `Map`, `Unmap`,
`VSSetConstantBuffers`, or `PSSetConstantBuffers`; constant-buffer upload
remains open. The reproducible offset scan is
`audit_backend_context_calls.py` (base-object validation is required for its
`--all-code` results).

### D3D11 state descriptor builders (2026-10-02)

Three native state builders are now confirmed from their input fields, stack
descriptors, device vtable calls, and output pointers:

- `0x1414238f0` builds a `D3D11_BLEND_DESC` (`0x108` bytes). It reads the
  Storm render state at `arg+0x30` as eight 8-byte packed target entries,
  converts the blend factors/operations/write mask into eight
  `D3D11_RENDER_TARGET_BLEND_DESC` rows, sets
  `IndependentBlendEnable=TRUE`, and takes `AlphaToCoverageEnable` from
  `arg+0x29`. It calls the device vtable at `+0xa0` (`CreateBlendState`) and
  stores the returned state pointer at `this+0x10`.
- `0x141423a40` builds a depth/stencil descriptor from packed fields beginning
  at `arg+0x20`, converting the depth function/write mode and stencil-face
  operations. It calls device vtable `+0xa8` (`CreateDepthStencilState`) and
  stores the result at `this+0x10`.
- `0x141423b70` builds a rasterizer descriptor from the packed state and two
  float biases at `arg+8` and `arg+0xc`. The observed descriptor enables
  depth clipping and scissor, derives the remaining flags from packed bits,
  calls device vtable `+0xb0` (`CreateRasterizerState`), and stores the result
  at `this+0x10`.

The state update/cache path begins at `0x141420cc0`; it snapshots the packed
record and indexes separate state maps. The backend apply calls are now resolved
against the actual `ID3D11DeviceContext` method order:

- Backend slot `+0xd8`, method `0x141417d70`, calls context slot `+0x120`
  (`OMSetDepthStencilState`) with the state pointer and stencil reference.
- Backend slot `+0xe0`, method `0x141417d00`, calls context slot `+0x118`
  (`OMSetBlendState`) with the state pointer, the incoming blend-factor array,
  and sample mask `0xffffffff`.
- Backend slot `+0xe8`, method `0x141417e50`, calls context slot `+0x158`
  (`RSSetState`) with the rasterizer state pointer.
- Backend slot `+0x158`, method `0x141416250`, calls context slot `+0x148`
  (`Dispatch`) with the three incoming unsigned dimensions `(x,y,z)`; it is a
  compute dispatch path, not a rasterizer setter.

The mapping is supported by each call's argument setup and the WinSDK
`ID3D11DeviceContext` vtable order. Remaining work includes tracing the source
of the blend-factor array, packed-state field provenance, cache-to-draw timing,
and constant-buffer upload/bind behavior.

#### Native enum conversion tables (confirmed 2026-10-02)

The converter helpers used by the builders were checked against their
read-only jump tables, so the descriptor values can be reproduced rather than
approximated:

- Blend factor helper `0x141412940`, raw inputs `0..18` ->
  `[1,2,3,4,5,6,9,10,7,8,11,14,15,14,15,16,17,18,19]`; out-of-range -> `2`.
- Blend op helper `0x141412a80`: `0..4` -> `1..5`; otherwise -> `1`.
- Comparison helper `0x141412b50`: `0..7` -> `1..8`; otherwise -> `2`.
- Stencil op helper `0x141412f50`: `0..7` -> `1..8`; otherwise -> `1`.
- Raster fill helper `0x141412e20`: `0` -> `2`, nonzero -> `3`. Cull helper
  `0x141412c00`: `0` -> `1`, `1` -> `2`, other values -> `3`.
  Front-counter-clockwise helper `0x141412e50` and the boolean helpers
  normalize their supported fields to 0/1.

These are the numeric D3D11 enum/BOOL values written into the native descriptors.
They are proven conversions; semantic names for the packed Storm codes should
still be checked against the game’s serialized/state-format documentation.

### Asset-to-capture verification for the screen-scroll binder (2026-10-02)

The principal-fire capture assets are `4efb_amt00` and `4efb_amt01`, identified
from the SHA256 of the first bound GPU texture and confirmed by their same-name
material records in `captured_assets/data/effect/4efb_amt1.xfbin`. The native
format reader/constructor decode both materials' UV2/UV3 scale rates as
`(0,1,1,1)`. `audit_native_material_scroll_capture.py` checks the source
material identity, all four rates and the captured `g_uvOffsetScreen` value
for every one of 213 shader draws across seven captures. Every vector has the
expected `(0,t,t,t)` shape.

Because three rates are exactly one, `t` exposes the binder's clock fraction
directly. Inverting `float32(counter * 0.1f / 3000)` recovers the counter modulo
30000 at the seven capture points: 14100, 16700, 19300, 21050, 23050, 25250,
and 27700 ticks. Each phase lies on the native 50-tick scheduler increment.
This proves the static material-to-capture connection and the sampled clock
phase modulo one cycle; the unwrapped counter origin remains unknown.

The separate `g_uvScaleScreen=(3,1,1,1)` input remains open. Its CPU producer
does not appear among the 72 generic accessors, so keep it distinct from the
now-verified `g_uvOffsetScreen` path.

The remaining `(3,1,1,1)` input is not a shader default: the NUD groups
`4efb_amt00/01` serialize `NU_uvScaleScreen=(3,1,1,1)`, which matches the GPU
`g_uvScaleScreen` value in all 213 selected draws across seven captures. The NUD
also carries different values `(1,1,3,3)` for groups `amt08/amt15`, so importers
must preserve each material's property instead of baking a shared constant.
`audit_nud_shader_properties.py` and
`captured_assets/procedural/nud_shader_property_crosswalk.json` provide the
reusable audit. The serialized source is confirmed; the native loader's exact
copy site is still open. The scroll phase's unwrapped counter origin also stays
unknown.

### NUD property path versus the generic accessor table (2026-10-02)

The extracted 72-entry accessor inventory has no `g_uvScaleScreen` accessor;
`g_uvOffsetScreen` is accessor 50 and comes from render-context `+0x4f0`.
`0x1412f5ff0` computes that scroll value and then calls the generic shader
accessor dispatcher. Since captured `g_uvScaleScreen` still matches the NUD
property exactly, its material value enters the draw through a distinct route.
The exact native copy/packing site is not yet identified. Keep the now-proven
asset-to-GPU relation separate from the still-open native transfer function.

### Value and sampler queues are both captured by `Command_SetShader` (2026-10-02)

`0x1412370a0` creates the tag-6 shader command, then looks up the active
per-thread binding container through `0x141239d10`. It calls `0x141236b60` to
clone and queue the container's value-binding entries, then repeats the lookup
and calls `0x141236d70` for sampler entries. This is the concrete bridge from
semantic staging into the deferred draw list. It does not yet prove which
consumer turns the value entries into a constant-buffer update; keep that
separate from the now-confirmed sampler callbacks and their D3D11 resource
bind methods.


### Generic value staging to D3D11 constant-buffer upload and binding (2026-10-02)

`0x1412370a0` collects active value entries and `0x141236b60` clones each eligible binding record. That function queues tag 16 `mmDrawCommand_UpdateConstantBuffer` (`0x1414032b0` / initializer `0x1413f4330`) followed by tag 9 `mmDrawCommand_BindConstantBuffer` (`0x141401340` / enqueue `0x1413f3c30`). The tag-16 executor `0x1413f3a80` calls backend slot `+0xa8`; `0x1414185d0` calls D3D11 `UpdateSubresource` with the source bytes and resource from its payload. The tag-9 executor `0x1413f2df0` calls backend slot `+0xb0`; `0x141414bc0` routes confirmed paths to `VSSetConstantBuffers` and `PSSetConstantBuffers`; another branch uses context slot `+0x238`, whose interface/method identity remains unresolved.

For generic import, preserve both commands and their order: upload the staged bytes first, then bind the associated buffer for the correct shader stage and binding ID. The semantic accessor index, binding ID, D3D register, and reflected byte offset are different namespaces. Continue to obtain the final register/byte layout from each shader's reflection and a GPU capture; this path explains transfer and binding, not the meaning of every constant.
