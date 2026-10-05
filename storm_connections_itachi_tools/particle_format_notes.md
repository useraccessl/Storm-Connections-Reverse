# Partial nuccChunkParticle format reconstruction

These findings come from the two original chunks in `2efb_amt.xfbin` and from resolving their page-local XFBIN reference tables. The structural checks are implemented by `inspect_particle.py` and `particle_graph.py`.

## Header and sections

The first big-endian `u32` is `40`, the header byte length. Five pairs of big-endian `u32` values follow. In the first word of each pair, the high 16 bits are a record count and the low 16 bits are the section byte length. Each of the five lengths sums with the 40-byte header to the exact chunk size. The installed `NSUNSC.exe` `nuccChunkParticle` loader at VA `0x141320290` independently confirms the section counts and the exact number of bytes read from each section.

| Section | Projectile `blt00` | Impact `hit00` | Established structure |
| --- | ---: | ---: | --- |
| 0 | 8 × 208 bytes | 5 × 208 bytes | Emitter records; second `u32` is the emitter ID, 1-based. |
| 1 | 10 × 32 bytes | 10 × 32 bytes | Resource links; first `u32` is the XFBIN page-local resource index, second is the emitter ID. |
| 2 | 8 × 56 bytes | 10 × 56 bytes | Attachments; first `u32` is a `nuccChunkCoord` page index, second is emitter ID, thirteenth is a `nuccChunkClump` page index. |
| 3 | 2 × 112 bytes | absent | Extra force-field-like records; first and second words also identify an attachment and emitter. Remaining semantics unconfirmed. |
| 4 | 8 entries / 64 bytes | 5 entries / 64 bytes | Count-prefixed emitter event lists, padded to 8 bytes; see particle_runtime_notes.md. |

## Emitter record verified against the game loader

The loader reads exactly `0xD0` (208) bytes per emitter, allocates `0xE0` bytes per runtime emitter, and calls the endian conversion helper at VA `0x14131fc90`. That helper separately converts three 16-bit values (on-disk offsets `0x16`, `0x1c`, `0x2c`), selected 32-bit values, four groups of three 32-bit values, and three groups of four 32-bit values. The loader later resolves the first word as a page-local resource reference. All 13 original records, with the confirmed storage types and original bytes, are saved in `particle_records_typed.json` by `decode_particle_records.py`. These type names do not imply that a particular vector is position, velocity, or scale.

In projectile emitter 4, on-disk offsets `0xc8`–`0xcf` contain the ASCII bytes `nuccChun`. The loader does not endian-convert that region. It is retained verbatim while its meaning is investigated; interpreting the entire record as an array of floats would hide this anomaly.

The same executable's `nuccChunkAnm` loader is at VA `0x14134a350`. For this format version it reads a 16-byte animation header, then an 8-byte descriptor per animated resource, and arrays of linked targets/keys. Four Amaterasu animation chunks have been preserved, including projectile, impact, and `ptc01`/`ptc02` subanimations. Their key semantics and time base still need confirmation.

## Billboard arrays

The executable's `nuccChunkBillboard` loader is at VA `0x14134c4e0`. All 14 original Amaterasu billboard chunks have now been extracted. Its 16-byte header contains a page-local resource index, a 32-bit packed selector mask, a 16-bit key count, and two additional values. Each of thirteen 2-bit selectors chooses either zero, one, or `key_count` records for its array. Array element widths are `[12, 4, 8, 4, 8, 8, 4, 8, 8, 4, 4, 4, 4]` bytes in loader order. `decode_billboards.py` uses this layout, and every extracted chunk consumes exactly its file length. The result is in `billboard_arrays.json`.

For these 14 chunks, groups 3–10 vary over 8, 31, 41, or 61 keys and total exactly 48 bytes per key. Some pairs in groups 4 and 5 follow regular texture-atlas coordinates (for example `2efb_amt17` advances U by 0.25 and V by 0.5). The original vertex shader applies `g_uvOffset0` as `uv * zw + xy`, matching the four values in groups 4 and 5. Shader constant binding still needs direct confirmation.

The installed executable's billboard initialization at VA `0x1412c816d` sets runtime duration to header key count times header word at offset `0x20`. The latter is 50 in all 14 Amaterasu billboards. The particle generator at VA `0x14131bc3e` converts clock ticks to milliseconds using `ticks * 1000 / 3000` (the divisor stored at VA `0x141b948e8` is 3000). The lab therefore plays billboard UV keys at 60 keys per second. This timing is grounded in the original runtime, although interpolation and emitter-level start/stop behavior remain unverified.

`particle_graph.json` contains the resolved resource and attachment names for all 13 emitters. The impact uses two shared clumps `1efc_ring09` and `1efc_ring13`, not just textures or flat sprites. These clumps, their geometry, two textures, and matching shader pair were extracted from `1efcmn.xfbin` after following the graph.

The emission mode, quantity, lifetime randomization, fade fractions and auxiliary event block are now traced in `particle_runtime_notes.md` and decoded in `particle_semantics.json`. Remaining work includes movement and spawn geometry, the 112-byte optional records, billboard behavior, and animation tracks. The raw values are kept in `particle_inventory.json` and `particle_graph.json`.
