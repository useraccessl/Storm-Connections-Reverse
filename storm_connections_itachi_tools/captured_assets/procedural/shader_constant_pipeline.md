# Shader constant pipeline and deferred command queue

Reverse target: `NSUNSC.exe`, SHA256 `cecf0405b5ac00b9b9c95e8ff594bde5f8543413b6308f74991c701218b20d1e`.
Written 2026-10-02 (R43–R50). This file supersedes the structural descriptions in
`generic_shader_parameter_map.md` wherever they disagree; the corrections are
listed at the end. All offsets are static-disassembly facts unless marked open.

Reproduce with `disasm_batch.py`, `xrefs.py`, `callers_tree.py`,
`extract_draw_commands.py`, `dxbc_rdef.py` and `verify_constant_buffer_model.py`.

## 1. What a shader constant write really is

`0x14123ab80(program, descriptor, value)` is the single staging primitive:

```
tables    = TLS[+0x130]                       ; per-thread array of hash tables
container = lookup(tables, program)           ; 0x141239d10, key = program.group/index
entry     = first e in container.cbuffers where e.instance.def == descriptor.cbuffer_def
memcpy(entry.data + descriptor.var.offset, value, descriptor.var.size & 0xffffff)
```

The destination is CPU memory. The descriptor row (24 bytes, table at
`manager+0x2008`, manager = `[0x149708cf0]`) is **`{Program*, CBufferDef*, Variable*}`**:

- `+0x00` is a pointer to the owning shader program, not a vtable. `0x14123bf10`
  loads it into `rcx` and makes a direct call.
- `+0x08`, the "64-bit key", is a pointer to the constant-buffer definition. The
  lookup compares pointers.
- `+0x10` points at the reflected variable: `u32 StartOffset`, then
  `u32 Size | stageMask << 24`.

Rows are created by `0x141236230` when a program is loaded: one row per variable
of every constant buffer of that program. The row index is the "runtime binding
ID"; it identifies one variable of one program. Sampler IDs continue after the
last value row (`id - valueCount` indexes the sampler vector at `manager+0x2020`).

Setter variants, all ending in `0x14123ab80`:

| VA | Signature | Use |
|---|---|---|
| `0x14123bf10` | `(id, value)` | 221 call sites; 61 are the accessor thunks |
| `0x14123bf90` | `(id, value)` | model shadow path `0x1412d28b0` |
| `0x14123ac20` | `(program, id, value)`; no-op when `id == -1` | material and primitive paths |
| `0x14123ac60` / `0x14123bd90` / `0x14123be50` | by name (`0x1412396d0`) | post-process filters |

## 2. Objects

### Shader program (0x338 bytes, constructor `0x141234ad0`)

| Offset | Content |
|---:|---|
| `+0x000` | `u32` group index (0..255) |
| `+0x004` | `u32` index inside the group |
| `+0x008` | `u32` shader key (from the package entry `+8`) |
| `+0x010` | vertex stage object (vtable `0x141b8e000`); backend shader handle at `+0x0f8` |
| `+0x100` | pixel stage object (vtable `0x141b8e018`); backend shader handle at `+0x1e8` |
| `+0x1f0` | merged constant-buffer definitions (vector of `CBufferDef*`) |
| `+0x238`, `+0x268` | merged texture and sampler maps |
| `+0x298` | name → value-descriptor ID tree |
| `+0x2c8` | name → sampler tree |
| `+0x2f8..+0x308` | IDs of `g_matWorldViewProj`, `transform`, `textureSize`, `color`, `alphaTestVal` (`-1` when absent) |
| `+0x320` | vector of `CBufferInstance*`, one per merged definition |

Programs come from the shader package loader `0x14123a110` (one 0x40-byte entry
per program: key `+8`, VS size/pointer `+0x18/+0x20`, PS size/pointer
`+0x30/+0x38`). `0x141239270(manager, key)` finds a program by key in the map at
`manager+0x2050`. The manager holds 256 groups of 0x20 bytes from `manager+8`.

### Reflection

Each stage is created from bytecode by `0x141426eb0`, which calls
**`D3DReflect`** (`D3DCOMPILER_47.dll`) and walks the result in `0x1414274f0`:

- `D3D_SIT_CBUFFER` → definition `{slot = BindPoint, size = Size}` and one
  variable per `GetVariableByIndex`: `{StartOffset, Size, flag}` where
  `flag = (uFlags & D3D_SVF_USED) ? 1 << stageType : 0` (VS = 1, PS = 2).
- `D3D_SIT_TEXTURE` and `D3D_SIT_SAMPLER` → name → slot maps, plus used-slot
  bit masks consulted at bind time.

`0x141405cc0` merges the VS and PS definitions **per register slot**: size is
the maximum, variables are united by name; a same-name variable must have the
same offset and size to merge (stage flags are OR-ed).

Consequence: **GPU byte offsets are the DXBC `RDEF` offsets.** They can be read
from bytecode alone (`dxbc_rdef.py`), without a capture.

### Constant buffer objects

- `CBufferDef` (0x88): `+0x00 u8 slot`, `+0x04 u32 size`, `+0x08` name,
  `+0x38/+0x40` vector of 0x38-byte variables (`+0x00 offset`,
  `+0x04 size|flags`, `+0x10` name).
- `CBufferInstance` (0x40), one per program and buffer: `+0x00 CBufferDef*`,
  `+0x08` buffer handle (`+0x00 u64 size`, `+0x08` → backend buffer object,
  `+0x18..+0x28` pending upload: command list, sort key, payload), `+0x38` lock.
- Backend buffer object (0x60, vtable `0x141badc48`): `+0x08 u8 updated`,
  `+0x10` size, `+0x38 ID3D11Device*`, `+0x40 ID3D11Buffer*`.

Creation `0x1414019a0` → `0x141428000`: `ID3D11Device::CreateBuffer` with
`ByteWidth = max(size, 16)`, `Usage = D3D11_USAGE_DEFAULT`,
`BindFlags = D3D11_BIND_CONSTANT_BUFFER`, no CPU access, no initial data. There
is **one GPU buffer per (program, slot)**, created with the program and reused
for every draw.

### Per-thread staging

`0x141234800` builds, for each (thread, program), a container
`{+0x00 Program*, +0x08 vector<StagingEntry*>, +0x20 vector<sampler descriptor*>}`.
A `StagingEntry` (0x20) is `{CBufferInstance*, data, size, flag}` with `data`
a 16-byte-aligned, zero-initialised block of the buffer's size. Containers are
created for every registered thread when a program loads (`0x141236910`) and
for every program when a thread registers (`0x141239ee0`).

`0x141237b80(program)` zero-fills every staging block of the calling thread and
empties its sampler list. The model path calls it after each model draw
(`0x141269590` → `0x1412707d0`), so **a constant that no writer touches is
uploaded as zero**.

## 3. From staging to the GPU

`0x1412370a0(program, sortKey)` emits, in this order, into the calling thread's
command list:

1. `mmDrawCommand_SetShader` (tag 6) with the VS/PS backend handles.
2. For each staging entry (`0x141236b60`): snapshot the block into the frame
   arena, then `mmDrawCommand_UpdateConstantBuffer` (tag 0x10) and
   `mmDrawCommand_BindConstantBuffer` (tag 9).
3. Engine samplers queued by `0x14123c0e0` (`0x141236d70`).

Execution:

- Update `0x1413f3a80` → backend `+0xa8` `0x1414185d0` →
  `UpdateSubresource(buffer, 0, NULL, snapshot, 0, 0)`; it also sets the backend
  buffer's `updated` byte. The whole buffer is replaced on every draw.
- Bind `0x1413f2df0` → backend `+0xb0` `0x141414bc0(stageMask, slot, buffer)`.
  The bind is skipped while `updated == 0`. `slot` is the `CBufferDef` slot byte.
  The stage selector is: `1` VS, `2` PS, `6` CS, `7` VS and PS. The generic path
  always passes `7`; each stage is then bound only if the current shader of that
  stage uses the slot (masks behind `backend+0x110` and `backend+0x118`).
- Context slot `+0x238` is **`CSSetConstantBuffers`** (index 71). The receiver
  is the same `backend+0x50` pointer used for `VSSetConstantBuffers` and
  `PSSetConstantBuffers` in the same function, with the same
  `(StartSlot, 1, &buffer)` arguments, and the null-buffer branch unbinds all
  three stages in sequence.

## 4. Model material path (NUD)

`nuccChunkModel` (vtable slot `+0x18`, `0x1412e0a70`) builds the render model
through `0x1412a5e70` → `0x141244b20` → `0x1412695e0`; each material is built by
`0x141270830` from the NUD material record:

- program = `0x141239270(manager, materialKey)`, stored at `material+0x90`;
- one 0x30-byte sampler row per NUD texture (`material+0x10`), from the wrap,
  filter and LOD bytes of the texture entry;
- one 0x28-byte row per NUD property with a non-zero value count
  (`material+0x28`): the name is rewritten with **`"g_%s"` applied to
  `name + 3`** (`NU_uvScaleScreen` → `g_uvScaleScreen`), the floats are copied,
  and the ID is resolved with `0x1412395e0(manager, program, name)`.

Draw: `nuccDrawCmd_DrawModel::Execute` `0x141365030` → `0x1412d1870`:

1. `0x141337c60` render-context setup, `0x1412f5ff0` material binder (scroll,
   then the 72-accessor dispatch `0x141337b50`).
2. `0x141246060`/`0x141246140`/`0x141246240`/`0x141246260` → model manager
   `[0x149708d08]` → `0x141242660` → per mesh `0x1412428c0` → `0x14126a3b0`:
   - `0x141271ea0`: `g_matWorldViewProj` = 64 bytes at `TLS[+0x20] + 0x70`
     (refreshed through its dirty flag `+0xb0`), then every NUD property row;
   - `0x141271a50`: `UpdateRenderState` (4), `SetRenderState` (5),
     `0x1412370a0` (SetShader + buffers + engine samplers), then per NUD
     texture `BindTexture` (0xa) and `BindSampler` (0xd), both with stage 7;
   - `0x1412499b0`: `RenderPolygon` (2).
3. `0x141269590`: zero-fill the program's staging.

The other three model commands use the same manager: `DrawModelShadow`
`0x1413650c0` → `0x1412d28b0`, `DrawModelVelocity` `0x141365150` →
`0x1412d2fe0`, `DrawModelOutline` `0x1413651d0` → `0x1412d24c0`.

## 5. Deferred command queue

### Records and lists

Every record starts with: `+0x00` vtable, `+0x08 u64` sort key, `+0x10` next
record of the same group, `+0x18` group tail (valid on the group head),
`+0x20` frame arena, `+0x28` tag, `+0x30` payload. The tag is a category, not a
type: several classes share tags 4, 8, 0x0d and 0x22. The class is the vtable
(slot 1 returns the class name, slot 4 is `Execute`). The full table is in
`mm_draw_command_inventory.json`.

The per-thread list is `[[TLS+0xf0]]`: `+0x00` arena (`0x141219270` bump
allocator), `+0x18` list of group heads, `+0x48` sorted flag, `+0x50` current
key, `+0x58` current group head. A producer appends to the current group when
its key equals `+0x50`, otherwise it starts a new group (`0x1413ff910`).
Consecutive records with one key therefore stay together, in emission order.

### Frame

- Flush `0x14121b570` (game side): waits for the previous frame, **stable-sorts
  each thread list by key, ascending** (`0x1413f8cc0` → merge sort
  `0x1413f80b0`), hands the lists over and wakes the render thread.
- `RenderThread` `0x1413fc180` (created by `0x1413fbb00`, alongside
  `GPUResourceDestroyThread`): backend `+0x140`, merge every thread list into
  one queue by key (`0x1413f8990`; equal keys keep the already-merged list
  first), run `0x1413f8510` (for each group: `Execute` the head, then
  `0x1413fd740` walks `+0x10`), backend `+0x148`, reset arenas (`0x1413fc4f0`).

### Sort key

`0x141249150(flags, depth)` (also inlined in `0x1412486a0`):

```
key = layer << 35 | bucket << 32 | depth32
bucket 0: (flags & 0xf00f) == 0           no blend factors -> unsorted
bucket 3: flags bit 10
bucket 1: flags bit 11
bucket 2: otherwise, depth32 = clamp(trunc(viewZ * 512) + 0x80000000, 0, 0xffffffff)
```

`flags & 0xf` and `(flags >> 12) & 0xf` are the colour and alpha blend modes
(section 6), so bucket 0 is "both modes 0". `viewZ` is the dot product of the position with
the third row of the per-thread view matrix (`TLS[+0x20]`, elements `+0x18`,
`+0x28`, `+0x38`, `+0x48`); `0x14121b530` quantises it. The captured
`g_matWorldViewProj` has `w = -z`, so ascending order is far to near.

`layer` is `ctx+0x28` of the per-thread draw context `[TLS+0xf0]`. It is a
global counter (`[0x149708330]+0xd4`, reset to 0 at flush) advanced by
`0x1412191d0`; the public entry `0x14121c450` has 103 call sites, mostly in the
screen-filter and render-target code. Draw order is therefore: layer, then
bucket, then depth, then emission order.

## 6. Render state

Decoded tables and decoders live in `native_render_state.py` (`--verify`
re-reads them from the executable).

### Packed state block (0xd0 bytes)

| Offset | Bits | Meaning | D3D11 builder |
|---:|---|---|---|
| `+0x00` | 0 | solid fill (0 = wireframe) | rasterizer `0x141423b70` |
| | 1–2 | cull code: 0 none, 1 front, 2 back | |
| | 3 | FrontCounterClockwise | |
| | 4–35 | DepthBias (signed) | |
| | 36 | MultisampleEnable and AntialiasedLineEnable | |
| `+0x08`, `+0x0c` | | SlopeScaledDepthBias, DepthBiasClamp (float) | |
| `+0x20` | 0 | DepthEnable | depth/stencil `0x141423a40` |
| | 1 | depth write | |
| | 2–5 | DepthFunc code 0..7 = Never..Always | |
| | 6 | StencilEnable | |
| | 7–14, 15–22 | stencil read mask, write mask | |
| `+0x24`, `+0x26` | 0–3, 4–7, 8–11, 12–15 | front / back stencil: func, fail, depth-fail, pass | |
| `+0x28`, `+0x29` | | stencil reference, AlphaToCoverageEnable | |
| `+0x30 + 8*i` | 0 | BlendEnable of target `i` (0..7) | blend `0x1414238f0` |
| | 1–5, 6–10, 11–13 | SrcBlend, DestBlend, BlendOp codes | |
| | 14–18, 19–23, 24–26 | SrcBlendAlpha, DestBlendAlpha, BlendOpAlpha codes | |
| | 27–34 | RenderTargetWriteMask | |
| `+0xb8` | | primitive topology (D3D value: 4 list, 5 strip) | |
| `+0xbc` | | blend factor, 4 floats | |

DepthClipEnable and ScissorEnable are always 1; IndependentBlendEnable is
always 1. Defaults (`0x1414002e0`): solid, cull back, depth test and write on
with `Less`, stencil off, triangle list, every target `One/Zero/Add`, blend
disabled, write mask 0xf.

### Blend modes

`0x14126bc70(state, colourMode, alphaMode)` writes all eight targets from two
13-entry tables (`0x141b91150` colour, `0x141b911f0` alpha):

| Code | Colour (src, dst, op) | Alpha (src, dst, op) |
|---:|---|---|
| 0 | One, Zero, Add | One, Zero, Add |
| 1 | SrcAlpha, InvSrcAlpha, Add | same |
| 2 | SrcAlpha, One, Add | same |
| 3 | SrcAlpha, One, RevSubtract | same |
| 4 | Zero, SrcAlpha, Add | same |
| 5 | SrcAlpha, SrcAlpha, RevSubtract | same |
| 6 | DstAlpha, InvDstAlpha, Add | same |
| 7 | DstAlpha, One, Add | same |
| 8 | DstAlpha, One, RevSubtract | same |
| 9 | DstAlpha, Zero, Add | Zero, One, Add |
| 10 | DstColor, Zero, Add | Zero, Zero, Add |
| 11 | One, InvSrcAlpha, Add | same |
| 12 | One, One, Add | same |

- NUD material (`0x141270830`): colour mode = `dest_factor & 0xf`, alpha mode
  = `(dest_factor >> 4) & 0xf`; depth write = `!(source_factor & 4)`;
  `(source_factor >> 5) & 7` selects a state preset (`0x14126c0c0`, eight
  functions at `0x141b91290`); cull from `cull_mode` (`0` and `0x408` none,
  `0x404` front, anything else back); FrontCounterClockwise set; topology
  triangle strip; `unknown1` → SlopeScaledDepthBias, `trunc(unknown2)` →
  DepthBias.
- Sprite/primitive descriptor flags (`0x1412486a0`): colour mode =
  `flags & 0xf`, alpha mode = `(flags >> 12) & 0xf`, preset =
  `(flags >> 19) & 7`, cull from `(flags >> 4) & 3` through `{1, 2, 0, 0}`,
  depth write = `!(flags & 0x100)`, depth func = `LessEqual`, or `Always` when
  `flags & 0x200`.

### Pass-level overrides

`mmDrawCommand_UpdateRenderState` carries the state block (`+0x30`), the state
cache (`+0x100`) and an override mask (`+0x108`). At execution `0x141400360`
replaces every masked field with the value of the global state
`[0x149752108]`: mask bits 0–6 rasterizer fields, 7 topology, 8–12 depth and
stencil fields, 19 blend enable, 20 blend factors and ops, 21 write mask,
22 blend factor constants, 23 alpha-to-coverage.

Model and primitive draws pass `~materialFlags & 0x280000`. **Blend enable and
write mask therefore come from the global state, not from the material,**
unless the material claims them (the presets set `material+8` to `0x1800` or
`0x201800`).

Blend enable follows the sort bucket. `0x141219480` (public thunk
`0x14121c240`) opens a layer and emits two closure commands: `0x141219900`
(clear BlendEnable on all eight targets) with key `layer << 35`, and
`0x141219890` (set it on all eight) with key `layer << 35 | 1 << 32`. Inside
such a layer bucket 0 draws with blending off and buckets 1 to 3 with blending
on. On the primitive path (`0x141249150`) a draw whose colour and alpha modes
are both 0 is in bucket 0 and any other draw is in bucket 1, 2 or 3; on the
model path the bucket comes from the NUD `source_factor` (section 9). Layers
opened through `0x14121c450` emit no toggle and inherit the global state.

## 7. Verification against the captures

`verify_constant_buffer_model.py` → `constant_buffer_model_check.json`, seven
Amaterasu captures:

- 475 draws, 528 constant buffers, 6292 fields: every captured field offset
  equals the merged reflected offset and every buffer size equals the merged
  size.
- 235 fields predicted from NUD properties (`NU_x` → `g_x`) match.
- 327 fields with no native writer (not in the 72 accessors, not
  `g_matWorldViewProj`, not a NUD property) are all zero. This includes
  `g_blendType` on the main fire shader.
- All 109 blend-enabled draws use a (colour, alpha) pair of the native tables:
  (1, 11) 59 draws, (2, 9) 28, (3, 0) 12, (1, 0) 10.
- 319 draws have candidate NUD groups; each captured state (blend modes when
  enabled, depth write, cull, topology) equals the native state of at least
  one candidate. On 213 of them all candidates agree, so the match is exact;
  on the other 106 the candidates differ and only one or some fit. The eight
  blended three-texture draws fit `4efb_amt15` only (`dest_factor` 0xb1 →
  colour 1, alpha 11; `source_factor` 5 → depth write off).
- Not checked: `g_uvScaleNormal` and `g_uvScaleAlpha` are non-zero on ten
  `1efc_nor_water01` draws; that model's NUD is not in the inventory. The name
  pattern fits the property rule but this is unverified.

The capture field `base_asset` names the first bound texture, not the NUD
group. Candidates are all same-family groups with the draw's texture count.

## 8. Corrections to earlier notes

| Earlier statement | Correct |
|---|---|
| Descriptor `+0x00` is a virtual dispatch pointer | Pointer to the owning program |
| Descriptor `+0x08` is a 64-bit semantic key | Pointer to the constant-buffer definition |
| `0x1412e30a0` / `0x1412e0ed0` build per-shader binding rows from shader metadata | They work on NUD material rows (32-byte materials, `NU_outlineID` map in `0x1412e0bb0`); they are not part of constant staging |
| Tag `0x0d` table `0x141b8e090` is a sampler command class | It is `mmDrawCommand_nummDrawCommand_Function`, a generic closure command; `mmDrawCommand_BindSampler` is vtable `0x141b91320` |
| Class names `Command_*` | `mmDrawCommand_*` |
| Context slot `+0x238` unidentified | `CSSetConstantBuffers` |
| GPU offsets must be measured in a capture | They equal the `RDEF` offsets; a capture is only needed for values |
| `g_matWorldViewProj`, `g_blendType`, `g_uvScaleScreen` sources unresolved | Program standard ID `+0x2f8`; never written (zero-fill); NUD property |

## 9. Draw producers and geometry (R49)

### Which producer draws what

| High-level command | Execute | Body | Geometry path |
|---|---|---|---|
| `nuccDrawCmd_DrawModel` | `0x141365030` | `0x1412d1870` | model manager, one vertex stream per attribute |
| `nuccDrawCmd_DrawModelShadow` / `Velocity` / `Outline` | `0x1413650c0` / `0x141365150` / `0x1413651d0` | `0x1412d28b0` / `0x1412d2fe0` / `0x1412d24c0` | same |
| `nuccDrawCmd_DrawPrimitive` / `DrawPrimitiveRef` | `0x1412fdaf0` / `0x1412fdb90` | inline | interleaved primitive renderer |
| `nuccDrawCmd_DrawModelPrimitive` | `0x1413686e0` | `0x1412f4c30` | interleaved primitive renderer |
| `nuccDrawCommand_DrawModelPrimitiveBatch` | `0x14136bf40` | `0x141303b10` | not read yet |
| `nuccDrawCmd_DrawTrail` | `0x141389f40` | inline | interleaved primitive renderer |

Every effect draw in the seven Amaterasu captures (475 draws, including the
`01f002` and `01f008` particle shaders) binds one vertex buffer per attribute
and is an indexed triangle strip. They are all model-manager draws: in this
skill the particles are drawn as small NUD models, not through the primitive
renderer. The primitive renderer and trail paths below are static findings
with no capture behind them yet.

### Model path: sort key

`0x1412428c0` computes one key per mesh with `0x141241450(flags, depth)`, where
`flags` is the word at `material+0x48`. `0x141270830` copies the 32-byte NUD
material header to `material+0x40`, so that word is the NUD `source_factor`:

```
bit 0 clear             key = layer << 35 | ~depth32          bucket 0, near to far
bit 0, bit 1 clear      key = layer << 35 | 2 << 32 | depth32 bucket 2, far to near
bits 0 and 1, bit 3 clear                    1 << 32          bucket 1
bits 0, 1 and 3                              3 << 32          bucket 3
```

`depth32 = clamp(trunc((viewZ + bias) * 512) + 0x80000000)` (`0x141219710`),
with the model sort position at `model+0x10` (falling back to `model+0x00` when
it is zero) and `bias = model+0x1c`. With the layer toggles of section 6, a NUD
material is blended exactly when `source_factor & 1`. Checked on the 319
captured draws that have candidate groups.

### Model path: vertex streams from the NUD

`0x141269dd0` builds one GPU vertex buffer per element (`0x14140afe0`) after
converting it with `0x14126ad50`. The element list comes from the NUD vertex
type bytes (`0x14126a970`):

| Usage code | Semantic | NUD source → GPU element |
|---:|---|---|
| `0x01` | POSITION | 4 floats (stride 16) or 3 floats (stride 12), depending on the NUD vertex type |
| `0x32` | NORMAL | 3 floats, 3 half floats, or a single packed element (type `0x1f`) |
| `0x42`, `0x52` | two more vectors with the same choices as NORMAL; names not verified | |
| `0x12` | COLOR | type 1: 4 bytes, **each divided by 255.0**; type 2: 4 half floats; GPU element is 4 floats |
| `0x22 + n` | TEXCOORDn | type 1: 2 half floats; type 2: 2 floats; GPU element is 2 floats |
| `0x62`, `0x72` | per-vertex skinning data (inferred from the separate code path) | |

Source encodings are `0` copy, `1` unsigned byte / 255, `2` half float
(`0x141266b60`). The captured strides agree: position 16 or 12, colour 16,
texcoord 8.

A mesh (`0x14126a3b0`) then emits one `RenderPolygon` (`0x1412499b0`, 0x98
bytes) with the mesh declaration, its vertex buffers (`mesh+0x10`), its index
buffer (`mesh+0x08`, count at `+0x3c`), first index 0. Skinned or overridden
meshes take `0x14126a5c0` instead.

### Interleaved primitive renderer

`0x141248b70(renderer, desc, vertices, vertexCount, indices, indexCount)`,
renderer = `[0x149708d18]`, entered through `0x141249850` (no indices) or
`0x141249880`.

Descriptor: `+0x00` primitive type (topology table `0x141b8e300`: 0 strip,
1 list), `+0x04` vertex format 0..4, `+0x08` flags, `+0x0c` shader key,
`+0x10` texture selector, `+0x28` / `+0x30` / `+0x38` pointers to a
pre-uploaded vertex offset, index offset and sort position (flag bits 16, 17,
18), `+0x44` slope-scaled depth bias, `+0x48` depth bias.

Vertex formats (`0x141249260`), every element 4 floats, interleaved:

| Format | Elements (usage codes) | Stride |
|---:|---|---:|
| 0 | `0x01`, `0x32`, `0x12`, `0x22` | 64 |
| 1 | `0x01`, `0x32`, `0x22` | 48 |
| 2 | `0x01`, `0x12`, `0x22` | 48 |
| 3 | `0x01`, `0x22` | 32 |
| 4 | `0x01`, `0x12`, `0x13`, `0x22`, `0x23` | 80 |

Steps: copy the vertices into the dynamic vertex ring `[0x149708d20]`
(`0x14124a160`, `0x14124b740`) unless flag bit 16; sort position = average of
the vertex positions unless flag bit 18; force `w = 1` on every position
except in format 4; `0x1412486a0` builds state, key (`0x141249150`),
`g_matWorldViewProj` and `SetShader`; then `RenderPolygon` indexed
(`0x14124a860`, 16-bit indices copied to the ring) or not (`0x14124a9a0`).

- `DrawPrimitive`: descriptor at `cmd+0x20`, shader key `cmd+0x78`, vertex
  count `cmd+0x70`, world matrix `cmd+0x360`, vertices inline at `cmd+0x780`
  (`DrawPrimitiveRef`: pointer at `cmd+0x778`). The 72-accessor dispatch runs
  first.
- `DrawModelPrimitive` (`0x1412f4c30`): descriptor at `obj+0x30`, vertices
  `obj+0x80`, count `obj+0xc0`, indices `obj+0xb0` / `obj+0xb8`. Without a
  material it uses shader key **`0x1f002`**; with one it runs the material
  binder `0x1412f5ff0` for each material instance.
- `DrawTrail`: descriptor pointer `cmd+0x20` (shader key at `desc+0x0c`),
  vertices `cmd+0x28`, count `cmd+0x40`; accessor dispatch, then the same
  renderer. Trails are plain interleaved primitives at this level.

## 10. Open

- `DrawModelPrimitiveBatch` (`0x141303b10`) and the skinned mesh draw
  (`0x14126a5c0`).
- Which particle types go to the model manager and which to the primitive
  renderer (the captures only show the first).
- The eight state presets behind `0x14126c0c0` (stencil setups) and
  `mmDrawCommand_SetRenderState` (`0x14126c0d0`).
- Which pass each `0x14121c450` / `0x14121c240` call site opens (layer →
  render target): this gives the MRT and post-process order.
  `extract_layer_passes.py` → `layer_pass_inventory.json` is the starting map:
  63 functions bracket their draws with those two calls, among them the render
  methods (vtable slot `+0x08`) of the RTTI classes `nuccLayerZPrePass`,
  `nuccLayerOutline`, `nuccLayerReduction2`, `nuccLayerOpaqueClearZ`,
  `nuccLayerRefraction`, `nuccLayerAfterImage`, `nuccLayerToneControl` and the
  base `nuccLayer` (`0x1412fe860`), plus the screen filters with their named
  constants. The file also lists all 33 `nuccLayer*` / `nuccPostEffect*`
  classes (`Shadow`, `Opaque`, `Transparent`, `PostDecal`, `Stencil`,
  `MotionBlur`, ...). The order in which `nuccLayerManager` runs them is not
  established.
- Particle, trail, sprite and screen-filter producers: their constants go
  through the same staging primitive, but their writers and vertex formats are
  not mapped here.

## 11. Shader key and translated families (R53)

The NUD material `flags` word is the key of the vertex / pixel pair. Observed
pairs (listings in `effect_shaders/`):

| key | game pair | what it adds |
| --- | --- | --- |
| `0x1f002`, `0x1f007` | `01f002`, `f65da7b4` / `c4ee9b55` | base |
| `0x9f007` | `612d54c9` / `915c5e6e` | one screen film (bit 19) |
| `0x19f007`, `0x19f002` | `19f007`, `19f002` | two screen films (bits 19, 20) |
| `0x1f008` | `01f008` | falloff texture indexed by view-space normal |
| `0x3f009` | `3dc10cf4` / `4bf6e191` | screen refraction |

Base maths, all families of the first three rows:

```
VS  clip   = pos * g_matWorldViewProj
    colour = (vertex.rgb * g_multColor.rgb * g_ambientColor.rgb, vertex.a)
    uv     = uv * g_uvOffset0.zw + g_uvOffset0.xy
    fog    = 1 + g_fogParam.z * (saturate((g_fogParam.y - clip.w) / (g_fogParam.y - g_fogParam.x)) - 1)
PS  tex    = sample(base, uv);  alpha = tex.a * colour.a
    discard if g_commonParam.x >= alpha
    rgb    = tex.rgb * colour.rgb
    film i : uvF = SV_Position.xy * g_ScreenToUV.xy * (sx, -sy) + g_uvOffsetScreen * g_uvScaleScreen; uvF.y = 1 - uvF.y
             rgb = lerp(rgb, film.rgb, film.a * g_uvOffset3[i])
    out0   = (g_fogColor + fog * (rgb - g_fogColor), alpha * g_commonParam.y)
    out1   = (g_commonParam.w, g_commonParam.z, 0.99, alpha)
```

`0x1f008`: `n = normal * g_matWorldViewInvTrans`, `u = min(|n.z| / |n|, 1)`,
`alpha *= sample(falloff, (u, g_uvOffset2.x)).g`.

`0x3f009`: `d = (nA.xy + nB.xy - 1) * (g_commonParam.y * g_uvOffset1.z * vertex.r) * mask.a * 2`
with `nA = sample(normal, uv0 * g_uvScaleNormal.xy + (g_uvOffset0.x, -g_uvOffset0.y))`,
`nB = sample(normal, (uv0.y * g_uvScaleNormal.w - g_uvOffset1.y, uv0.x * g_uvScaleNormal.z + g_uvOffset1.x))`,
`mask = sample(normal, uv1 * g_uvScaleAlpha.xy + (g_uvOffset0.z, -g_uvOffset0.w))`;
the output is the scene copy at `SV_Position.xy * g_ScreenToUV.xy + (d.x, -d.y)`
when the scene depth there is behind the fragment, at the undisplaced position
otherwise; alpha = vertex alpha. The scene copy is made once when the
refraction layer starts (capture 22127: copy at event 6632, draw at 6763).

## 12. Effect samplers (R54)

- NUD texture `wrap_s` / `wrap_t` are D3D11 address modes: 1 wrap, 2 mirror,
  3 clamp, 4 border.
- Effect-model samplers: linear min / mag / mip, **LOD bias -15.996**, LOD
  range 0..16, border colour (0, 0, 0, 0). Mip 0 is the only level sampled.
  The `0x1f008` family uses bias 0.
- The exported draw JSON numbers textures and samplers 0..n-1 in register
  order; shaders may skip registers (`4bf6e191` uses t0, t2, t3, t4).

## 13. Per-model context from the xfbin chunks (R55, R56)

`nuccChunkModel` header (bytes before `NDP3`): `u16 1`, `u16 flags`, then four
bytes `0, attributes, layer, light`. Correlation with every captured draw:

| attributes | layer | light | models | fog | ambient |
| --- | --- | --- | --- | --- | --- |
| 3 | 18 | 1 | amt00-07, 09, 10 | off | white |
| 1 | 2 | 1 | amt08, amt11-14 | stage | white |
| 1 | 0 | 4 | part09b (ash) | stage | stage |
| 6 | 1 | 1 | amt15, light00, shock09 | off | white |
| 3 | 1 | 1 | part11b (its emitters have no start event: never drawn) | not observed | not observed |
| 6 | 3 | 1 | fire03a (alive 6 frames, in no capture) | not observed | not observed |
| 4 | 14 | 0 | nor_dst03 | no fog constants in this shader | |

Native mechanism (model draw `0x1412d1d10`, context init `0x1413368f0`, R61):

- the light byte (`model+0x2B`) indexes a light set of the render context
  (`0x141312a90` on `context+0x38`); the shader's ambient is read at
  `set+0x20`. Set 4 held the stage ambient, set 1 white.
- fog colour and parameters are read from the object at `context+0x20` of the
  render context current when the model is submitted (`TLS[+0x3400]`). The
  layer byte (`model+0x2A`) is what `0x1413651e0` receives to create the draw
  command. Observed: layers 0 and 2 are submitted with the stage fog, layers 1
  and 18 with fog disabled. What binds a layer to its context is not traced.
- the 128-bit mask given to the context init is `resource+0x100`, the generic
  accessors the model's shaders declare (bits 23 ambient, 24 fog colour, 25 fog
  parameters); with the global flag `[0x1420ce610]` set, only declared fields
  are computed. It is not a per-model switch.
- the attribute bits (`model+0x29`) are not decoded.

The layer byte orders the frame: 2, 18, 0, 1, 14 by event number (layer 3,
`fire03a`, was never captured). Within an opaque layer draws go near to far,
within a translucent one far to near (checked on three captures, no exception).

`nuccChunkCoord` of a model: position, rotation, scale (three floats each),
then one float that multiplies the model's alpha. `light00` 0.9, `nor_dst03`
0.5, `shock09` 1.0, each confirmed by captured `g_commonParam.y`. Billboards
receive the same value as billboard channel 4.

`nuccChunkMaterial` float block: format bits 0-3 announce uv0-uv3 (four floats
each: offset.xy, scale.zw), bit 5 one float (captured as `g_uvOffset2.x`, the
falloff coordinate), bit 6 one float (1.0 in every material seen; captured
`g_commonParam.z` is also always 1.0, so the link is unproven). `field02 / 255`
equals the captured `g_commonParam.x` and `field04` the captured
`g_commonParam.w` on every draw.

## 14. Particle update rules (R57, R59)

Per-particle update `0x14130b200` (life fraction `t = min(1, age / life)`):

- size curve output to `+0x88`, colour curve to `+0x110`, alpha = colour.a *
  fade value `+0x68`;
- fade state `+0x184` (initializer `0x14130c350`): 0 rising by
  `step / (life * fadeIn)`, 1 holding until `age > life - int(life * fadeOut)`,
  2 falling by `step / (life * fadeOut)` starting on the *next* update, 3 done;
- dispatch on `+0x50`: 1 clump (matrix `+0xA0` scaled by `+0x1B0`, alpha to
  `model+0x38`), 2 animation, 5 billboard (position, size `+0x1B0 * +0x88`,
  roll, alpha to `billboard+0x2F4`).

A model receives the matrix built before the size curve was rewritten, so its
size is one update old; a model particle is not drawn on its birth frame.

Screen-film scroll: `g_uvOffsetScreen[i] = signed fraction(clock * rate[i])`,
rates = the material instance's uv2 / uv3 scales (`+0x60..+0x6C`), clock about
0.1 per real second. Animated instances can override the file's rates
(`amt15`: all four are 1 at run time).

## 15. Skill actor (R58)

`0x140a61c20` (orientation at `actor+0xAC` from the velocity at `+0xA0`):
`Y = normalize(-velocity)`, `X = normalize(Y x oldZ)`, `Z = normalize(X x Y)`,
fallback `Z = normalize(oldX x Y)`, `X = normalize(Y x Z)`; every length test is
`> FLT_EPSILON`, a failed test keeps the stored matrix. `0x140a6cb10` (shared
setup): two parameter-driven rotations of the orientation, then
`velocity = -Y * (speed + random)`, gravity step, guidance flag and values.

## 16. GMod port bindings (R60)

`screenspace_general` offers pixel constants c0-c3 only and no custom vertex
constants. `storm_fx_render.lua` therefore packs:

| slot | base / film variants | falloff | refraction |
| --- | --- | --- | --- |
| c0 | `g_uvOffset0` | same | `g_uvOffset0` |
| c1 | (multColor * ambient).rgb, `g_commonParam.x` | same | `g_uvOffset1.xy`, `g_commonParam.y * g_uvOffset1.z` |
| c2 | `g_uvOffsetScreen` | view axis in model space, `g_uvOffset2.x` | `g_uvScaleNormal` |
| c3 | `g_fogColor.rgb`, `g_commonParam.y` | same | `g_uvScaleAlpha.xy` |

and bakes per-material values into TEXCOORD1-7 of the cached mesh
(`g_uvScaleScreen`, film weights, fog range and strength scaled to Source
units, 1 / screen size, base-texture address codes). Blend factors go through
`render.OverrideBlend`, depth write through `render.OverrideDepthEnable`.
Mirror and border addressing run in the pixel shader on a clamped VTF copy and
equal D3D bilinear filtering at mip 0. The falloff variant uses
`dot(N, axis) / |N|`, equal to the game's `n.z / |n|` for uniformly scaled
models (asserted). The refraction variant has no depth test (see section 11).

Checks: `verify_port_shaders.py` (pixels, per captured draw),
`verify_port_constants.py`, `verify_port_winding.py`,
`verify_procedural_player.py`, `port_preview.py`. None of them runs GMod.
