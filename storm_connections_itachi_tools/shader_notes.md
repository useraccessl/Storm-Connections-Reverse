# Amaterasu shader findings

The game's `data/system/nuccMaterial_dx11.nsh` is a `NUP4` archive. It contains 224 pairs of Direct3D 11 `DXBC` shaders: a vertex shader followed by a pixel shader. The 32-bit key before each vertex shader matches the `flags` field in the original NUD material. `extract_used_shaders.py` identified and disassembled seven pairs used by `2efb_amt.xfbin` plus one used by the two shared impact rings; see `used_shaders/manifest.json` and the `.asm` files.

| Key | Original models |
| --- | --- |
| `0x1bf007` | `00`, `08`, `09`, `10`, `11`, `20` |
| `0x19f007` | `01`, `02`, `04`, `05`, `06`, `07`, `17`, `18` |
| `0x19f002` | `03` |
| `0x02f00a` | `12`, first material |
| `0x00e000` | `12`, second material |
| `0x00e001` | `12`, third material |
| `0x01f002` | `13_base`, `16` |
| `0x01f008` | shared impact rings `1efc_ring09`, `1efc_ring13` |

## Pixel shader `0x1bf007`

This shader samples two primary textures, combines them according to a mode parameter (including mix, multiply, and modulated combinations), multiplies by vertex color, applies an alpha threshold, blends two screen textures using projected screen coordinates, applies a final color interpolation, and writes two render targets. The exact instructions and register bindings are preserved in `used_shaders/1bf007_ps.asm`.

The two projected screen-coordinate samplers are real shader inputs. In the Amaterasu material references, both are bound to the extracted `1efc_film_clash00` noise texture; the shader does not necessarily require live framebuffer colors for these slots. A Source material that only displays the first flame atlas cannot reproduce this shader. Its appearance also depends on projected UVs, constant buffers, blend state, depth state, and particle data.

## Pixel shader `0x19f007`

This variant samples one primary texture, multiplies it by vertex color, performs an alpha test, then does the same two projected screen texture blends and final color interpolation. See `used_shaders/19f007_ps.asm`.

The first GMod inspection builder discarded NUD vertex colors and used white opaque vertices. The extracted flame models actually contain varying alpha, and `2efb_amt00` has 37 vertices each at alpha 0, 127, and 255. `inspect_vertex_colors.py` now preserves all vertex RGBA in `vertex_colors.json` and the lab passes those colors to its Source mesh. The OBJ exporter also flipped V for OBJ convention; the lab now reverses that flip before applying the original billboard UV keys. These were concrete conversion errors, separate from the remaining shader-port work.

The second comparison capture showed white swirls instead of dark flame masses. The lab sequence now bakes a dark purple color into its mesh vertices, uses `$model 1` with `UnlitGeneric`, and offers a Source detail layer driven by the original `1efc_film_clash00` noise texture. That layer uses model UVs rather than the game's projected screen UVs, so it is a material experiment and still requires in-game comparison. The plain inspection material remains available through `storm_amt_inspect`.

## Remaining shader work

`shaders/original_19f007_reference.hlsl` now expresses the original pixel
shader arithmetic directly from the DXBC disassembly, preserving its input
semantics, screen-pixel-coordinate sampling, equality-discard alpha test,
and second render target. It is a DX11 reference, not a compiled Source
shader. No guessed material constants are substituted into this reference.
It still requires the original vertex-shader bindings and render states.

An experimental `screenspace_general` Source pixel shader is now in `shaders/amt_screenmix_ps2x.hlsl` with compiled `amt_screenmix_ps20b.vcs`. It follows the mask/vertex-color/noise blend operations visible in the original `0x19f007` disassembly. The user's game-side test showed only a few brief lines, so the sequence no longer selects it. The Source wrapper currently passes the model UV but no matching projected screen UV, so its two noise samples are still approximate. Its vertex input, material constants, and blend/depth behavior need diagnosis. This source is a starting port, not a claim of pixel equivalence.

- Recover the complete mapping of shader constant registers to the game's runtime values for these effects.
- Reimplement the eight shader programs in a shader profile Source 1 can load, including both screen samplers and the render-target behavior where used.
- Verify blend/depth/cull state for every mesh against original gameplay frames.
- Compile and test the custom shaders in Garry's Mod. DirectX 11 `DXBC` bytecode from this game cannot be used as a Source 1 `.vcs` file directly.
