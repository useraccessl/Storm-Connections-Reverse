# Findings from seven original STORM CONNECTIONS GPU captures

## Asset identification

The prior extraction used `2efb_amt.xfbin`. The captured eruption principally
uses **`4efb_amt1.xfbin`**. This is proven by byte-identical compressed GPU
texture blocks, not by screenshots or similar names:

| Captured resource | Original texture | Size | Compressed blocks |
|---|---|---|---|
| 83525 | 4efb_amt00 | 1024 × 2048 | identical |
| 83527 | 4efb_amt01 | 512 × 512 | identical |
| 83535 | 4efb_maplus01 | 512 × 512 | identical |

See `asset_matches.json` for SHA-256 evidence. PNG decoding differs by at
most three integer channel levels between GPU and Pillow BC decoding; the
compressed originals match exactly. The GMod frame probe uses GPU PNGs.

## Frame 22136

- 553 draw calls inspected.
- 49 draws have the Amaterasu screen-film constants: two legacy 19f007 draws
  and 47 atlas draws with another shader binary.
- Main pixel shader SHA-256:
  `915c5e6e56ff52ae6c9ecab0084f5e3e2f76a7a03d28fb96320c3f7ba1106abd`.
- Main shader samples one animated atlas and one screen-position film.
  Film blend strength is **1**, versus **0.05** in the previously extracted effect.
- The captured principal film is `4efb_maplus01`, not `1efc_film_clash00`.
- Initial tint is `(205/255,90/255,1)`; some subsequent draws differ slightly.
- Alpha threshold is `100/255` on principal atlas draws.
- Color blending is disabled, depth test and depth writes enabled, no culling.
- Atlas samplers use wrap addressing and linear filtering.
- Principal atlas draws disable fog; the two legacy draws retain stage fog.
- Main screen film UV scale is `(3,1)`.

`amaterasu_geometry.json` contains the actual original vertex/index inputs,
constant buffers, animated UVs, samplers and render state. The frozen Source
probe recovers world coordinates from a main-pass world/WVP pair and checks
that each recovered mesh transform is affine. It retains original draw order.

## Current GMod probe

In client console:

```text
lua_openscript_cl autorun/client/storm_amt_capture.lua
storm_amt_capture 0.3
```

Close the console to inspect the held frame. It is intentionally static even
when the game is unpaused. Hide with `storm_amt_capture_hide`.

### Rendering correction r2

The first probe used a SM3 pixel shader with the default SM2 vertex shader.
GMod documents that SM3 pixels require a SM3 vertex shader:
https://wiki.facepunch.com/gmod/Shaders/screenspace_general
The initial test printed the command message but displayed no effect.

Revision r2 supplies the compiled `amt_capture_vs30` vertex shader, using
Source's model-view-projection constants at c4. It explicitly outputs the
pixel shader's expected UV/color interpolators, enables vertex transforms,
depth writes and linear texture reads, and uses freshly named runtime
materials to avoid cached VMT state. It renders in the main translucent hook.
Compilation and generated Lua syntax were checked; visual verification is pending.

Reload `lua_openscript_cl autorun/client/storm_amt_capture.lua`, then run
`storm_amt_capture 0.3`. For a base-atlas diagnostic without the custom shader,
use `storm_amt_capture 0.3 0 1`. `storm_amt_capture_diag` prints render-hook
execution and material status. The base-atlas mode is not the shader port.

### Matrix correction r3

The r2 shader used `mul(matrix, position)`, producing long triangles attached
to the camera/player in the user's screenshots. Valve's actual
`screenspaceeffect_vs20.fxc` multiplies `mul(position, cModelViewProj)`.
The r3 vertex shader follows that convention, retaining register c4.

Official reference:
https://github.com/ValveSoftware/source-sdk-2013/blob/master/src/materialsystem/stdshaders/screenspaceeffect_vs20.fxc

The new `amt_capture_r3_vs30` filename and `storm_amt_gpu_r3_*` material names
avoid reusing the cached r2 GPU bytecode/materials. Compilation, Lua syntax
and SHA-256 of the installed files were checked. Visual confirmation is pending.

### Camera-facing billboards r4

The user confirmed r3's shape/materials looked good, but the frozen geometry
was flat when viewed from the side. r4 recovers a center for each recorded draw,
expresses its vertex offsets in the captured camera basis, and replaces that
basis with the current GMod camera Right/Up/normal during rendering. Each
center remains fixed in world space; captured size and roll remain in the
vertex offsets. Numerical reconstruction of every original vertex from the
new basis was checked within 1e-5 game units. Lua syntax and installed file
hashes were checked. The held animation frame still does not animate.

It uses 49 recorded GPU draws and the recorded inputs/constants. It does not
claim to reproduce the complete engine: original MRT postprocessing, exact
gamma/color pipeline and full animation remain unverified in Source. The
snapshot's global position, uniform scale and yaw are adapted to the test map.

## New animation data

### Sparse original capture replay r5

The user confirmed r4 now appears three dimensional when moving the camera.
Seven original RDCs have now been exported with their own recovered view
projection matrices. Native BC texture hashes select only verified
4efb_amt00/01 draws; the film binding is also hash verified. This excludes
unrelated scene particles and the two legacy flame draws in the held probe.
Draw counts at frames 22082/22102/22127/22136/22149/22171/22200 are
7/16/44/47/47/40/12. Every sample uses the same original world anchor from
frame 22136, so the advancing ground flames are not artificially recentered.

Commands after reloading autorun/client/storm_amt_capture.lua:

* storm_amt_capture_replay 0.3: plays seven recorded states, at original
  frame-number spacing with a selectable playback FPS (fourth argument,
  default 60). Original elapsed time has not been recovered; 60 is a playback
  setting. No invented particle interpolation is added.
* storm_amt_capture_sample 1 through 7: holds one state and retains the
  existing test placement so the original movement can be compared.
* storm_amt_capture: retains the previous complete held 49-draw probe.

All seven Lua data files were executed by Lua and checked for finite vertex
coordinates, triangle counts, and texture bindings; the viewer syntax was
checked. Eight installed client Lua files have identical SHA-256 hashes to
the workspace versions. Actual new replay rendering requires an in-game
check. This is a sparse capture diagnostic, not a finished continuous
simulation or a complete engine port. RenderDoc startup preferences were
restored after batch export.

`captured_assets` now contains the correctly identified effect, with 6
projectile emitters, 18 impact emitters, 15 billboards, 17 materials and 3 ANMs.
Their event times, source resources, attachment links and animation curves
are decoded. They are not yet integrated into a verified complete runtime.

The old `storm_amt_sequence` and `storm_amt_decoded` commands still use the
earlier effect/approximation and must not be used as evidence of this new port.

RenderDoc's telemetry preference was temporarily disabled for headless replay
and its original configuration was restored after the exports.
