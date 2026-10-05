# Supplied Garry's Mod reference captures

The user supplied three still frames from a modder's Garry's Mod reproduction of Itachi's Amaterasu on 2026-10-01. They are visual comparison references; they do not establish the original game's emitter parameters.

1. Initial stage: several separate, short, dark purple flame pillars on grass, with small detached fragments. The user reports that these flames advance along the ground before impact.
2. Transition: a short white radial flash centered on one of the flame pillars.
3. Burst: a much taller, wider dark purple/black flame column with detached pieces rising above it.

The exact frame times, camera, emitter transforms, and shader behavior cannot be read from these stills. The current `storm_amt_sequence` command stages these three observed phases with extracted meshes, textures, vertex RGBA, and UV keys. Its ground path, white beams, color tint, offsets, scale changes, and fades are provisional. The original particle animation and shader data remain the source to decode for an exact port.

The user's first in-game comparison showed large white swirls. A follow-up after baking the dark tint and enabling the film-noise detail layer showed a saturated purple, flat column. The noise experiment is now opt-in. The sequence includes the impact's `2efb_amt00` smoke resource, which was omitted from the prior composition; its source geometry is a flat XY disk, so it is now placed on the ground instead of upright.

The next user capture, with the noise disabled and smoke disk horizontal, still showed a narrow smooth near-black column. Impact emitter 2 references only `2efb_amt02`, while emitter 5 references `2efb_amt08` through `11`. The preview had scaled `02` larger than `08`/`09` and included projectile-only `01` in the impact. The new staging reverses that size emphasis and repeats the tall branching resources at staggered times; this remains a visual hypothesis until tested in GMod and until emitter parameters are decoded.

The user tested that follow-up: the plain material showed mostly tall, thin linework with a small dark flame patch at the base. This establishes that `08`/`09` cannot substitute for the filled `02` atlas flame mask in the preview. The compiled screenmix material rendered only a few lines for about half a second and is disabled in the sequence pending shader input/blend diagnosis. The next preview layers more `02` instances across the height of the column and reduces the opacity and size of `08`/`09` so they serve as edge filaments.
