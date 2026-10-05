# r16 effect lifetime and shader-family correction — 2026-10-02

## Effect lifetime boundary added; ash excess remains unexplained

The impact ANM `4efb_amt1_hit00` lasts 5,000 ticks. The procedural player
advances its original clock by 50 ticks per scene update, so the owning effect
ends after 100 updates at 60 Hz. The previous preview instead continued all
emitters for 360 updates. Emitters 5, 6, 8, 10 and 16 have no local stop event
in the decoded records, so the preview needs this outer ANM lifetime boundary.
This identifies a preview overrun risk; it does **not** prove that it caused
the excessive ash seen during the active-effect peak.

r16 stops every generator at the ANM endpoint, then keeps simulating existing
particles using each emitter's decoded lifetime and simulation rate. A bounded
fallback is computed from the longest file lifetime, so the preview cannot run
forever. `verify_procedural_scene.py` checks that births stop at the ANM
boundary, RNG stays deterministic, and all particles expire. The true active-
effect ash count still requires resolving emitter cadence, activation and
attachment multiplicity, spawn transforms, and visible resource/render costs.
No ash-count parity claim is made.

## Main fire shader is distinct from the legacy dual-film path

Frame 22136 has 49 screen-film draws: 47 principal atlas draws and two legacy
draws using `19f007_ps`. The main path samples the verified `4efb_maplus01`
texture, has screen UV scale `(3,1)`, alpha threshold `100/255` and film
strength 1. The two legacy draws use the reconstructed 19f007 shader and their
own dual-film setup. Therefore `19f007_ps` must not be used as the main-flame
shader.

The captured main-fire pixel shader (hash `915c5e6e…10abd`) and its vertex
shader (`612d54c9…7f23`) have now been disassembled into
`main_fire_915c5e6e_ps.asm` and `main_fire_612d54c9_vs.asm`. This reveals a more
specific render mismatch: the game computes `base * tint`, samples one screen
film and mixes it by `film.a * vertexFilmWeight`, then mixes the result with the
vertex fog color using a vertex-computed fog weight. It outputs alpha from a
separate material multiplier and writes an auxiliary second render target with
depth/fog metadata. The current `amt_motion_r6` Source shader reproduces the
single-film sample, but it has no auxiliary target and bypasses the final
fog-color mix. Original main-fire draws have fog disabled, so the latter weight
is normally 1; the lost auxiliary/deferred compositor remains a likely major
appearance gap. The single-film weight's file binding is independently
corroborated by the GPU/file audit (`g_uvOffset3.x` matches `scroll1.y`).

The capture's main draw uses the `4efb_maplus01` texture, alpha threshold
`100/255`, screen scale `(3,1)`, disabled fixed-function blending and depth
writes enabled. Those states work with the game's later deferred target; they
cannot be copied literally to a single-pass Source material and retain the same
appearance. Next: map the auxiliary target through the captured compositor,
then implement a Source-compatible alpha/deferred approximation and compare a
matching frame. No speculative shader edit was made in r16.

## Install/test

Run `install_procedural_r7.ps1` to install r16. Its client autorun registers
the command on startup. After restarting GMod, run `storm_amt_procedural 1 1`.
If GMod is already running, load `lua_openscript_cl autorun/client/storm_amt_procedural.lua`
first. The preview should stop generating at the ANM end, then fade its
remaining particles. Final visual parity is not established.
