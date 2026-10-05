# STORM Amaterasu geometry lab

This is an opt-in in-game inspection tool for original STORM CONNECTIONS Amaterasu meshes and textures. It is not the final animated effect and does not reproduce the original DX11 shaders.

Client console: `storm_amt_inspect 2efb_amt00 1` shows a mesh at the aimed point. Use `storm_amt_inspect 1efc_ring09 1` for an impact ring. Optional arguments after scale are pitch, yaw, roll in degrees. `storm_amt_hide` hides it. For billboard meshes, `storm_amt_frame 2` selects a UV key, and `storm_amt_playkeys` plays the original UV keys once. The final key remains visible until hidden.

`storm_amt_sequence 1 1` plays a provisional composition at the aimed point: smaller projectile flames move along the ground toward the target, followed by a short white impact flash, layered flame masks, branching filaments, impact smoke, scattered fragments, and two subdued rings. Arguments are scale, delay to impact in seconds, and the old film-detail toggle (`0` plain by default, `1` to compare). A fourth argument freezes the effect at an exact number of seconds from the start; for example, `storm_amt_sequence 1 1 0 1.6` holds the impact at age 0.6 seconds until hidden. The compiled screenmix shader probe is disabled after it rendered only brief lines in GMod. `storm_amt_sequence_hide` clears the effect. The white beams, color tint, emitter placement, motion, and fades are staged from the supplied screenshots; they are not yet decoded from game animation data. Original vertex RGBA and UVs are retained.

`storm_amt_version` prints the loaded lab version in the client console.

Version `2026-10-01-decoded-runtime-10` adds `storm_amt_decoded` as a separate
diagnostic. Arguments: effect (`0` impact, `1` projectile), scale, optional
held time in seconds, deterministic seed, and optional particle RGB (`1`).
For example, `storm_amt_decoded 0 1 0.6 1 1`. It evaluates decoded emission,
lifetimes, XYZ sizes, alpha and both animated UVs, with the new SM3 screen
shaders. Attachment rotations, forces, animation/model resources and original
RGB/blend/depth/MRT context remain incomplete or unverified. It is not the
finished reproduction. `storm_amt_decoded_hide` hides this diagnostic.

The VTF textures and billboard UV keys come from the user's installed game. The billboard runtime uses `count * stepTicks` for duration, and the particle clock converts ticks to milliseconds at 3000 ticks per second. The Source `UnlitGeneric` materials retain source vertex alpha. The optional `1efc_film_clash00` detail layer uses model UVs and looked too purple in the first comparison, so it is off by default. The compiled Source pixel shader remains in the research files for diagnosis; its failed in-game probe is no longer selected by this command. The `2efb_amt00` impact smoke mesh is a horizontal disk and is placed on the ground. Emitter spawning, motion, exact shader bindings, and the complete effect are still being reconstructed.
