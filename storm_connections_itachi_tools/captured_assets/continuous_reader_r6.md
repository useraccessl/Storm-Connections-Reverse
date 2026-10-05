# Continuous reconstruction r6

The old storm_amt_capture_replay command still selected seven whole frames.
It now invokes storm_amt_motion, a separate continuous renderer. Reload
lua_openscript_cl autorun/client/storm_amt_capture.lua and use
storm_amt_capture_replay 0.3. The console must report Amaterasu continuous r6.

Original GPU input shapes collapse to three reusable meshes. The new pixel
shader takes original atlas offset/scale and recorded tint as uniforms;
no mesh rebuild is needed as the atlas changes. Main captured fog is disabled,
and the shader preserves the single film, alpha threshold, and final-alpha
arithmetic. The compiled shader is installed in the client main shaders/fxc
folder as well as the addon. The held capture probe remains separate.

The generator reconstructs every observed vertex within 1e-5 game units.
Billboard resources and keys come from matching original NUD positions and
recorded GPU UVs. A constrained resource/age/proximity matcher links particles
across observations: 79 inferred tracks, 134 linked adjacent transitions.
These are inferred identities, not recovered runtime particle IDs.

Measured centers and camera-relative transforms interpolate each rendered
frame. Atlas UVs select intermediate keys from the original Billboard chunk,
without blending coordinates across atlas cells. Unmatched births/deaths
grow/shrink between observations; the final 0.3 seconds shrinks remaining
geometry. Those transitions and the position interpolation are reconstruction
choices, not reverse-engineered force integration. Playback retains the old
frame-number spacing at 60 FPS; exact original game timing remains unresolved.

verify_motion_timeline.py executes the pure Lua evaluator: all seven observed
states retain their count, position, matrix, tint, scroll and original atlas
keys. 361 evaluated times yield 361 distinct geometry/atlas states; maximum
58 draws and three shared meshes. Lua syntax and compiled shader existence
are verified. Actual rendering/fluidity still requires an in-game test.

The original force data and particle_motion_core.lua are not yet integrated
into this reader. This fixes sparse playback and gives a continuous visual
reconstruction; it is not the final exact engine port requested by the user.
