# Original runtime evidence: emitter behavior

Analysis of the installed NSUNSC.exe, 2026-10-01. Addresses are virtual
addresses for this build. This is a partial reconstruction; the current GMod
sequence still uses manual staging and has not been replaced by this decoder.

## File-to-runtime mapping

The loader at `0x141320290` reads 208-byte emitter records. Starting at
`0x141320434`, it copies the 192-byte file substructure at offset `0x10`
to runtime emitter offset `0x20`. Runtime records have stride `0xE0`.
The caller at `0x141276c7b` selects that record and adds `0x20`, then
calls `0x14131c440`, which stores this pointer at generator offset `0x98`.
Consequently every config-relative offset below corresponds to file offset
`config_offset + 0x10`.

| File offset | Confirmed runtime use | Evidence VA |
| --- | --- | --- |
| 0x10, byte | Value 1 uses a direct spawn count; other values use a fractional emission accumulator | 0x14131be12–0x14131be74; esi=1 at 0x14131bbd8 |
| 0x11, byte | Spawn shape dispatch selector; geometry names pending | 0x14131b5c0 spawn routine |
| 0x15, byte & 63 | Nonzero overrides generator step parameter +0x60; units pending | 0x14131c440 |
| 0x1c, signed16 | Emission duration counter limit; -1 bypasses limit | 0x14131be79–0x14131beaf |
| 0x20, float | Direct quantity, or rate divided by global byte +0x952 then multiplied by update factor | 0x14131be12–0x14131be74 |
| 0x2c, signed16 | Base lifetime counter | 0x14131b6c7 onward |
| 0x30, float | Lifetime random multiplier: trunc(base + base * random(range)) | 0x14131b6c7 onward |
| 0x4c, float | Fade-in fraction of lifetime, used to calculate inverse fade duration | 0x14131b5c0 caller; 0x14130c350 setter |
| 0x50, float | Fade-out fraction, inverse fade duration and lifetime minus fade duration | 0x14130c350 |
| 0x54, float | Base scalar stored at particle +0x208; physical meaning pending | 0x14131b5c0 |
| 0x58, float | Positive random range added to that scalar | 0x14131b5c0 |

Lifetime and duration values are kept as counters, not converted to seconds
until the integration step and clock binding are confirmed. Resource lists
are randomly selected by the spawn routine, rather than necessarily creating
every listed resource on each spawn.

## Section 4 is an emitter event table

Loader `0x141321209` reads the auxiliary section. Each entry has a big-endian
u32 count followed by count u32 events, padded to an 8-byte boundary:
`size = (4 + count * 4 + 7) & ~7`. Empty entries occupy 8 bytes.
All 64 bytes are consumed for both Amaterasu chunks by the decoder.

Update `0x14131bcd6` compares `event & 0x0fffffff` with the animation clock
converted to milliseconds (`ticks * 1000 / 3000`). On a clock advance:

- Bit 31: start emission (unless generator +0x74 blocks it), and reset +0x5c to 1.
- Otherwise bit 30: stop emission and notify existing particles, conditionally
  on generator state. See `0x14131bd1d` through `0x14131bd80`.
- Otherwise: stop emission unless generator +0x74 blocks it. This includes
  plain positive words, not just words carrying bit 30. See `0x14131bd82`.

Both effects start at a threshold of 33 ms in their own animation clock.
Impact emitters 3, 4 and 5 stop emission at 266 ms. Their existing particles
continue according to their lifetimes. Projectile emitter 7 contains a stop
event at 33 ms and no start event in this table; other control paths remain
to be investigated. These thresholds are not the projectile-to-impact delay.

## Reproducible extraction

Run `decode_particle_semantics.py` to produce `particle_semantics.json` from
the preserved typed records and resolved graph. It asserts full auxiliary
section consumption and matching emitter counts and preserves event flags.
Unknown fields remain in `particle_records_typed.json` without guessed names.

## Still required for the requested visual

Attachment rotation composition, force integration, exact RGB rendering
context, the remaining shader variants, and original blend/depth/cull state
remain unverified. Decoding emission alone cannot establish visual parity.

## 2026-10-01: decoded diagnostic runtime

`build_runtime_data.py` now exports all 13 emitters, 14 billboard channel
tables, 18 material descriptors and 23 resolved ANM entries. The ANM chunks
have modern 20-byte headers. Versions above 0x67 refer to the separate page
reference table, including its name aliases, rather than page chunk indices.
Using the latter incorrectly resolved one bone as `Page0`; this is fixed.

Billboard channel widths, by selector, are
`12,4,8,4,8,8,4,4,4,8,8,4,4`. The definitive boundary evidence is the pointer
builder at `0x1413917e0`; the load routine merely endian-swaps contiguous
floats in loops with another grouping. Channels 6/7/8 are scalar blend/glare
values, 9/10 are the secondary two-component UV offset/scale. In particular,
`2efb_amt08` starts with blendRate.x=0.5, UV1 offset=(0,-1.3), scale=(1,1.5).

Size interpolation is at `0x14130b2a0` through `0x14130b32b`. A zero split
skips size interpolation. Color interpolation is at `0x14130b330` through
`0x14130b393`; a zero split instead interpolates middle-to-end. The billboard
update path at `0x14130b57a` writes alpha at billboard+0x2f4, but does not
copy particle RGB there. Therefore applying particle RGB to the Source mesh
is only a diagnostic hypothesis, not a confirmed rendering-context binding.

`runtime_core.lua` evaluates emission, sizes, colors, fades, all billboard
channels and animation curve formats without dependence on Source. Its
behavior is checked by `verify_runtime_decode.py`. `decoded_client.lua`
is a diagnostic renderer, not the finished effect: attachment transforms,
forces and model/animation resources are not fully integrated; random draw
ordering and cone composition remain provisional. Existing scene staging is
preserved under `storm_amt_sequence`; `storm_amt_decoded` is separate.

## Renderer subsystem inventory (2026-10-02)

The executable RTTI contains separate types for
`nuccParticleManagerRenderer` (primary vtable `0x141b914f0`),
`nuccParticleNodeListRenderer` (`0x141b9a7a0`), and `nuccTrailRenderer`
(`0x141b9c010`), plus `nuccParticleRenderThread` (`0x141b9a830`) and
`nuccTrailRenderThread` (`0x141b9c170`). This proves distinct engine
subsystems exist; it does not by itself map every effect emitter to one of
them.

`nuccDrawCmd_DrawPrimitive` has draw callbacks at `0x1412fdaf0` and
`0x1412fdb90`. They resolve the shader key, initialize generic shader context,
run the active semantic accessors, and reach common draw preparation at
`0x141249850`.

The `nuccDrawCmd_DrawTrail` path includes `0x1412d2b90` and `0x1412d2630`.
These traverse the per-thread render context, resolve shader/material entries,
and queue request references through `0x1412fe4c0`. The latter appends an
8-byte request pointer to the trail object's list at `object+0x58`, increments
its count at `object+0x38`, and holds a global lock at
`0x14974b530+0x58` during the update. The trail render thread has a separate
work ring (object fields around `+0x248..+0x260`); its exact handoff to the
per-object request lists remains to be matched. `0x1412d3c40` composes and
writes a 4x4 matrix, choosing a transform source branch from a context flag;
exact meanings of those fields remain open. `0x1412c7dd0` copies
material values into request data using per-channel presence pointers, then
temporarily scales a scalar before calling `0x1412d1d10`; channel names are
not yet confirmed. Follow these trail commands separately from the generic
particle-node draw route when rebuilding effects with side trails.

### Trail render-thread handoff (2026-10-02)

The `nuccTrailRenderThread` tick at `0x141326490` consumes a ring item using
the thread fields `+0x248` (ring pointer), `+0x250` (capacity), `+0x258`
(read cursor), and `+0x260` (pending count). The ring item contains a
discriminator at `+0x58`; the tick dispatches distinct cases to
`0x141325090` (case 0), `0x141325a50` (case 1), and the callback path through
`0x14127afe0`/`0x141279fb0`/`0x141300370` (case 2). It then releases the ring
item and advances the cursor under the thread lock. This establishes the
ring as a work queue, not a GPU geometry buffer.

Case 1 (`0x141325a50`) walks the trail object's packed records from
`object+0x238` to `object+0x240` in `0x3c`-byte steps. It derives neighboring
segment deltas, expands each segment into two `0x40`-byte generated records
in a buffer referenced at `object+0x320`, interpolates per-segment values,
and calls `0x141389eb0` to obtain a prepared render request. It copies the
generated data into that request and calls `0x1412fe4c0`, which appends the
request pointer to the trail object's linked list under the manager lock.
Thus the verified chain is: trail-thread ring work item -> trail geometry
expansion/preparation -> queued per-object render request. The request is
still not traced all the way through `nuccDrawCmd_DrawTrail` to concrete
D3D11 context calls; the two CPU-side queues must not be conflated.

This provides a geometric clue for trail replication: native trails are
generated from an ordered sequence of packed points/records with
neighbor-based segment deltas and paired output records. They are not just
camera-facing copies of a generic particle quad. The exact semantics of the
`0x3c` source record and `0x40` output record fields, shader input layout,
blend state, and camera-facing math remain unresolved.
