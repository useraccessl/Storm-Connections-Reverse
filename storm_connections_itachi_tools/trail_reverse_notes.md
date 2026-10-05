# nuccChunkTrail — reverse notes

Journal entries: R90 (format, launch, update, vertices) and R91 (draw path, port) in
`MOTEUR_EFFETS_REVERSE.md`. Proof levels are given per section; "disassembled" means read in
the executable, "native" means run in the game's own code (`native_image.py`) and compared.

Port: `storm_import.py` (`Importer.trails`, `Importer.ribbon`), `lua/storm_amt_lab/trail_core.lua`,
`lua/storm_fx/player.lua` (trail sets), `lua/storm_fx/render.lua` (`R.drawRibbon`).
Checks: `verify_trail_native.py` (core), `verify_trails.py` (engine wiring).

## Classes

`nuccTrailRoot`, `nuccTrailGroup` (0x188 bytes, ctor `0x141321e20`), `nuccTrailBase` (0x380 bytes,
ctor `0x141323330`), `nuccTrailRenderer`, `nuccTrailForceField`. Slots `+0x30`..`+0x70` of their
vtables are the particle base's (`0x141300xxx`).

## Launch and release (disassembled)

- Every effect animation object launches the trails of its animation: `0x1412ba6f0` reads the
  trail chunk at anm object `+0xE8`, calls the factory `0x14127aa20(manager 0x14127afe0, chunk,
  coordinate context +0xD0)`, keeps the handle at `+0x150`, starts the group (`0x14127b360`).
  This includes the animation each particle with an animated resource plays.
- Factory: one group, one `nuccTrailBase` per table-0 record; trail `+0x1A8` = table-0 record
  (memory) `+0x20`, `+0x1C8` = table-4 record, `0x141328130` stores the coordinate context at
  `+0x1B8`; table-1 records of the trail's index → `0x141328150` (billboard, see Draw).
- Edges: the first two table-2 records of the trail's index, resolved by `0x14132b3f0`: the
  coordinate context's lookup (vtable `+0x28`) with key = the parent reference (record `+0x30`)
  and the edge's name (record `+0x08`); on a miss, again with the default key
  (`0x14127c080`) and the name alone. Names are the instance names of the animation's clumps
  and coordinates (page reference pairs, R86), not chunk names. Edge positions are the
  translation of the coordinate's matrix (`coord +0x7C + 64 * byte +0x120`).
- Release: `0x1412ba540` → `0x14127a090(handle, 0, 0)` → group vtable `+0x108` =
  `0x141322310` (group `+0x168` = 0, `+0x148` = 1; each trail vtable `+0x108` with 1 → trail
  `+0x168` = 1, "ending"). Every release path of the anm object passes (0, 0). Called on
  restart (message handler `0x1412adeb0`) and on the object's end.

## Thread

`0x141326490` (render thread loop) pops jobs: type 0 → `0x141325090(trail, frame)` (update),
type 1 → `0x141325a50(trail)` (vertices + draw command), type 2 → destroy. The anm object's
frame setter `0x1412ba230` (`+0x158`) sends the frame to the group.

## Format (loader `0x14132b4e0`, versions 0x74..0x7B)

Header: five groups (offset u32, count u16, word u16).

| table | record (file / memory) | fields |
|---|---|---|
| 0 | 0x60 / 0x70, one per trail | +0 ref (the effect's nuccChunkAnm), +4 trail index, +0x14 kept duration (samples kept = trunc(+0x14 / dt)), +0x18 subdivisions (trunc(+0x18 * dt), at least 1), +0x1D flags (bit 0 alpha fade, bit 1 width fade, 0x10 width profile), +0x1E / +0x1F fade speeds (byte / 255 per update), +0x20 / +0x30 / +0x40 RGBA colours C0 / C1 / C2, +0x50 colour split, +0x54 / +0x56 / +0x58 profile words (/ 255), +0x5A profile split (byte / 255) |
| 1 | 0x20 / 0x30, one per trail | +0 ref (nuccChunkBillboard; also looked up among loaded resources by name / path), +4 trail index |
| 2 | 0x30 (0x20 up to version 0x78) / 0x40, two per trail | +0 ref (edge coordinate), +4 trail index, +0x20 = 1, +0x28 ref (parent, version > 0x78) |
| 3 | 0x40 (0x30 up to 0x78) / 0x50 | force fields, see below |
| 4 | 0x18 / 0x20 / 0x28, one per trail (table-0 order) | +4 trail index, +0x10 key count, +0x14 keys (bit 31 emission on, low bits a time in anm ticks) |

Loader defaults: no flag bit 0 or 1 → both fades on, speed 0; no flag 0x10 → profile 255 × 3,
split 0. dt = trail `+0x138` = 1.

## Update `0x141325090` (translated; trail_core.lua `T.update`)

- frame -1: emission off; returns unless ending. Otherwise, when the frame changed (going back
  resets the key index), at most one key per update: reached → bit 31 sets emission (and, when
  not ending, alpha and width scale back to 1).
- Not ending: the force fields act on the kept samples (list `+0x330`), then the newest
  sample (two edge positions, no velocity, no decay) goes to the front of the deque (`+0x1E0`,
  MSVC deque, 0x3C bytes per sample: positions `+0x00` / `+0x0C`, lengths `+0x18`, velocities
  `+0x20` / `+0x2C`, decay `+0x38`).
- Ending or not emitting: alpha `+0x33C` -= fade / 255 (flag bit 0), width scale `+0x340` -=
  fade / 255 (bit 1), both clamped at 0.
- Points: for each segment i < min(kept, samples - 2): widths from the profile, then
  `0x1413248a0` (adaptive subdivision, spline `0x1412cd3c0`, width fade).
- Trim: ending → drop one sample; not emitting → two; then at most `kept` samples; points
  limited to subdivisions * kept.
- Billboard: `0x1412c7b00(billboard, 1)` copies frame floor(clock +0x300 / step), then advances
  the clock by 50 (global / 60), wrapping when the chunk loops, else holding at the total.

## Force fields (native: verify_trail_native.py; journal R92)

- Factory: per table-3 record of the trail's index, `0x14132b350` looks the coordinate up once
  (key of the parent reference at memory `+0x40`, name of `+0x08`; no fallback), then
  `0x14132c740` builds the field (0x80 bytes: `+0x18` trail, `+0x20` field record = memory
  record `+0x18`, `+0x28` coordinate or null, `+0x30` matrix, `+0x70` centre, `+0x7C` 0) and
  appends it to the trail's list (`0x141324fd0`, tail).
- Memory record (0x50): `+0x00` coord ref → `+0x08` entry, `+0x04` trail index, `+0x18`..`+0x37`
  = file `+0x10`..`+0x2F` (version > 0x78), `+0x38` parent ref (file `+0x30`) → `+0x40` entry.
  Up to 0x78 the 0x30-byte file record is copied as is: the field record starts at file `+0x18`
  and its strength / flags (memory `+0x30` / `+0x34`) are never written by the loader.
- Field record: `+0x00` direction (3f), `+0x0C` decay, `+0x10` kind (1 acts), `+0x14` radius
  (× 100), `+0x18` strength, `+0x1C` flags (bits 0-2 clear → 1; 1 = k 0.5, 2 = 1 - |d/r|,
  4 = 1 - (1 - |d/r|), none = 0.5; 0x10 = direction in world space).
- `0x14132c830(ff, deque, dt)` (dt unused): direction normalized (0, 0, 1 if null), rotated
  by the coordinate's matrix (`0x1411efdf0`) unless flag 0x10, normalized, × strength;
  centre = coordinate translation or origin; per sample edge: inside (FLT_MIN < d < r):
  position += force × k, velocity (`+0x20` / `+0x2C`) = that, sample decay (`+0x38`) = field
  decay; outside with velocity and decay: velocity += velocity × decay, position += velocity.
- Called in the update before the new sample is pushed, only when the trail is not ending.

## Vertices `0x141325a50` (native: verify_trail_native.py)

- Cumulative length along each edge; colour gradient: t = length fraction, split m: m = 0 →
  lerp(C1, C2); t < m → lerp(C0, C1, t / m); else lerp(C1, C2, (t - m) / (1 - m)).
- Alpha × trail `+0x33C`; u / v from the billboard's UV values `+0x2C8`..`+0x2E4` (channels 5,
  6, 10, 11; defaults (0, 0), (1, 1), (0, 0), (1, 1) from `0x1412c8110`); two vertices per
  point (edge 0, edge 1), 0x40 bytes each.

## Draw (disassembled; R91)

- Descriptor at trail `+0x2D0` (init `0x141327240`): +0 primitive type 0 (strip), +4 vertex
  format 0 (position, normal, colour, uv; four floats each), +8 flags `+0x2D8`, +0xC shader key
  `0x1F007`, +0x10 texture id `+0x2E0`, +0x14 sampler flags 0, +0x1C LOD bias -8.0.
- Command `0x141389eb0` → execute `0x141389f40`: context `+0x3B0` (`g_commonParam`) =
  (FLT_MIN, 1, 1, billboard alpha), accessor dispatch for the 0x1F007 record, renderer
  `0x141248b70` (copy to the dynamic ring, sort position = mean of positions, state
  `0x1412486a0`, `g_matWorldViewProj`, texture bind with the descriptor's sampler).
- Context fill `0x1413368f0`: `g_uvOffset0` / `1` = (0, 0, 1, 1), `g_uvOffset2` / `3` /
  `g_blendRate` = 0, `g_multColor` = render context `+0x80` colour (value not traced), w 1.
- Texture: billboard model's last material instance, group 0 texture 0 (`0x14138a020`:
  `+0x310`), plus image index `+0x1DC` when valid.
- Sampler (`0x141237410`, `0x141425e50`): wrap ×3, trilinear, MipLODBias -8, LOD 0..16.
- Flags come from words `+0x80` / `+0x82` / `+0x86` of the billboard model's first
  nuccChunkMaterial (`0x1412c8070` → `0x1412e1110`: slot 1 of the group-0 material record's
  handle; `+0x82 & ~0xC0`, `+0x80` bit 0 clear → bit 10, bit 1 → 0x200 else 0x100, `+0x86`
  0 / 3 → 0x20, 2 → 0x10). Default without a material: 0x121. The chunk (vtable 0x141b9f748,
  0x90 bytes, factory `0x1412984d0`; slot 0 makes a `nuccMaterial`, slot 1 destroys) is written
  up to `+0x7C` by its loader `0x14134cde0` and not beyond; the `nuccMaterial` ctor
  `0x1412f5920` / refresh `0x1412f5ed0` copy chunk `+0x24` → `+0x80` and `+0x78` → `+0x84` of
  the *instance*. No writer of the chunk's words found. Zero words would give 0x520 (opaque).
- **Captured (R98):** `4efb_amt1_blt00`'s two trails in frames 22082 / 22102
  (`gpu_captures/trail_draws.json`, `replay_trail_draws.py`): SrcAlpha / InvSrcAlpha, alpha One
  / Zero, depth test LessEqual without writes, no cull = 0x121; `g_multColor` (1, 1, 1, 1);
  `g_commonParam` (FLT_MIN, 1, 1, billboard alpha). The port uses 0x121 for every trail.
- **Billboard frame (R98):** at the age the geometry fits (19, 39, with the root oriented as
  the engine's skill actor orients the projectile, confirmed by the effect's point light: its
  lateral offset, and its animated intensity bit for bit at those ages), the
  game shows billboard frame `(age - 2) mod count`, one update earlier than one `0x1412c7b00`
  call per effect update gives; the player uses `t.updates - 1`. Why is not traced (a first
  update one update after launch, as a render-thread job, would do it).
- `verify_trail_capture.py`: state, constants, topology, shape (field rise 7.5 / update, width,
  cross-section), ages, colours and UVs, point light offset against the capture.
