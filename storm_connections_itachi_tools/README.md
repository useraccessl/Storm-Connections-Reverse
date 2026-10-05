# Itachi Amaterasu: extraction from STORM CONNECTIONS

Status: original game data extracted and mapped; exact Garry's Mod effect **not implemented**.

## Provenance

- Game installation: `C:\Program Files (x86)\Steam\steamapps\common\NARUTO X BORUTO Ultimate Ninja STORM CONNECTIONS`
- Archive: `data\launch\data1.cpk`
- Itachi identifier: `2itc`
- Skill files: `data\skill\2efb_amt_x.xfbin`
- Visual file: `data\effect\2efb_amt.xfbin`
- Common visual dependencies: `data\effect\1efcmn.xfbin`

The decoded `2efb_amt_e_begin00.xml` has `DAMAGE_ID_2ITC_AMATERASU`, loads `2efb_amt.xfbin`, plays `2efb_amt_blt00`, then uses `2efb_amt_e_hit00` and `2efb_amt_hit00` at impact. See `skill_xml/`.

## Extracted content

- 7 effect-specific NUT textures in `textures/2efb_amt/`.
- 7 referenced common NUT textures in `textures/1efcmn/` and the global `celshade` texture in `textures/celshade.tex/`.
- Decoded PNGs in `preview/` and lossless RGBA8888 VTF 7.2 versions in `source_textures/` (15 textures).
- Raw `nuccChunkParticle` payloads for projectile and hit in `chunks/2efb_amt/nuccChunkParticle/`.
- 18 parsed material descriptors and texture references in `materials.json`.
- The source XFBIN contains 18 models, 14 billboards, 4 animations, 2 particle chunks, and 1 trail chunk.
- All 18 original base meshes, both morph targets, and both common impact ring meshes are exported as OBJ in `geometry_obj/`.
- Original NUD vertex RGBA is exported to `vertex_colors.json`. The GMod builder now restores the OBJ-exported V axis to the game's texture-coordinate direction and keeps the original per-vertex alpha. These fixes address a concrete source of incorrect filled circles and flame silhouettes in the first preview.
- The 18 NUD model render states, mesh descriptors, and material attributes are in `nud_inventory.json`.
- All eight shader pairs used by those model materials and common impact rings have been identified and disassembled in `used_shaders/`; see `shader_notes.md`.
- The particle chunks have been split into their five exact-size sections; see `particle_inventory.json`. `particle_graph.json` resolves the eight projectile emitters and five impact emitters to their original billboard/model/animation resources and attachment chunks.
- The installed game's particle loader and endian conversion helper have been located and disassembled. `particle_records_typed.json` records every original emitter byte and the confirmed storage types; see `particle_format_notes.md`.
- All 14 billboard chunks are extracted. Their header masks and exact key-array boundaries are decoded in `billboard_arrays.json`; see `particle_format_notes.md`.
- An opt-in Garry's Mod geometry inspector was built in the sibling addon `storm_amaterasu_lab`. The user confirmed that its mesh and UV playback work in game. The first `storm_amt_sequence` comparison rendered as white swirls. A later film-noise experiment produced an overly purple, flat mass. The following comparison was a narrow, smooth, dark column. Giving `08`/`09` dominant size produced only tall linework around a tiny body in the latest comparison. The compiled Source screenmix shader showed only a few brief lines; it is disabled in the sequence until diagnosed. The current revision layers the filled `2efb_amt02` atlas mask across the body and uses `08`/`09` as lower-opacity edge filaments. This revision awaits an in-game comparison.

The `celshade` dependency was located in `data/system/celshade.tex.xfbin`.

## What is still needed for an exact port

1. Decode the remaining meanings of `nuccChunkParticle`, `nuccChunkBillboard`, `nuccChunkTrail`, and `nuccChunkAnm` fields into emitter behavior and animation keys. Billboard UV key values and cadence are identified, but emitter behavior and the other animation tracks are not fully decoded.
2. Reconstruct the morph animation and convert the OBJ geometry to a Garry's Mod runtime representation.
3. Reimplement the eight identified DX11 shaders in Source 1, including screen texture sampling, blending, depth, and render-target behavior.
4. Reconstruct projectile/impact timing and emitter transforms, then compare the integrated effect frame by frame with the supplied reference captures and, if available, a capture from the original game.

No source `.pcf` or Source `.mdl` can be produced by renaming XFBIN chunks. Installing these textures alone would show incomplete or incorrect visuals, so this directory contains research assets only and no active GMod effect.

## Scripts and validation

- `cpk_index.py`: inspect archives and selectively extract encrypted/compressed XFBIN files.
- `xfbin_chunks.py`: list and extract XFBIN chunks and NUT textures.
- `analyze_effect.py`: map material parameters and texture references.
- `nut_preview.py`: decode NUT texture pixels.
- `png_to_vtf.py`: write Source VTF images.
- `verify_vtf.py`: verify the 15 VTF headers and byte-identical decoded pixel payloads.
- `decode_skill_xml.py`: decode the two skill XML payloads.
- `inspect_nsh.py`, `disassemble_dxbc.py`, `extract_used_shaders.py`: extract and disassemble matching game shaders.
- `inspect_nud.py`, `export_effect_obj.py`: parse original render states and export geometry.
- `inspect_vertex_colors.py`: extract and check the original vertex RGBA arrays for every exported mesh.
- `inspect_particle.py`: parse particle chunk section sizes and retain emitter words for analysis.
- `decode_particle_records.py`: preserve and type all 13 emitter records using the original loader's field conversions.
- `decode_billboards.py`: split all 14 original billboards into the key arrays read by the game's loader.
- `inspect_page_refs.py`, `particle_graph.py`: resolve emitters to their source models, billboards, animations, and attachments.
- `build_gmod_lab.py`: generate the opt-in Garry's Mod geometry inspection addon from original textures and meshes.

The VTF check verifies file structure and pixels. The user confirmed that static mesh and UV playback render in Garry's Mod; the combined approximations failed visual comparison.

## Current diagnostic version

`2026-10-01-decoded-runtime-10` adds a separate decoded playback probe. All
13 emitters, 14 billboard channel tables and 23 animation entries are exported
from the game. Original emission/size/alpha/UV behavior is evaluated by a pure
Lua module and verified against the binary data and reverse-engineered code.
The Source SM3 shaders use the actual pixel position and distinct secondary
UVs; the previous `$copyalpha` mistake is corrected. Both shaders compile.
This is still **not** an exact complete reproduction or an in-game verified
shader port. See `gpu_capture_instructions.md` for the pending original-frame
capture, the diagnostic commands and the explicit remaining gaps.

The version is installed in both the server addon and the actual Steam GMod
client; 88 files were checked with SHA-256 after installation. The two new VCS
files are also installed in the client's main `garrysmod/shaders/fxc` folder.
