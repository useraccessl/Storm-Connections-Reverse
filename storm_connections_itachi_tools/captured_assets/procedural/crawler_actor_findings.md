# CRAWLER actor tick — 2026-10-02

## What the executable establishes

The 4efb_amt1 graph uses ARROW -> CRAWLER -> hit00. XML velocity 25 is
converted by the skill loader to `float32(30 / updateRate) * 25` (12.5 at
60 Hz). The CRAWLER update at `0x140a6e0d0` then performs one actor tick:

1. Advance position `+0x70` by velocity `+0xa0 * motionMultiplier(+0x164)`.
2. If vertical velocity is positive, normalize all three components and
   multiply by the launch speed saved at `+0x20`.
3. Otherwise normalize only horizontal X/Y, multiply those by launch speed,
   and preserve vertical velocity unchanged.
4. Query up to eight world hits. Select the first hit whose flags satisfy
   `(flags & 0x20000002) == 0x20000002`; snap actor Z to its hit Z.
5. If the query fails, subtract the native gravity step from vertical velocity,
   except on stage `0x89`.
6. If actor `+0x3b0` enables guidance, call the steering routine with action
   values at `+0x14/+0x18`; a false return disables further guidance. Refresh
   orientation from the updated velocity.

The actor-to-effect root is the separate `ccGameObjectSkill` virtual `+0x78`
(`0x1405e00c0`), documented in `r11_findings.md`. It builds translation,
orientation, extra Y rotation and uniform actor scale, assigns the matrix to the
effect, then advances the effect. These are now discrete native stages rather
than a fitted path.

## Reusable implementation

`storm_connections_itachi_tools/crawler_actor_core.lua` translates the actor
integration, eight-hit selection, ground snap/gravity branch, and guidance
callback contract. It injects the project float32 helper so it stays compatible
with GMod Lua. It is not yet wired to the effect player.

## Still required for the actual Amaterasu root

- Recover exact actor initialization and bind the XML/owner fields to `+0x20`,
  `+0x70`, `+0xa0`, `+0x164`, `+0x3b0`, `+0x14/+0x18`.
- Disassemble steering `0x140a61fa0`, the native ground-query construction and
  the gravity constant/rate semantics; supply the original stage collision
  shape and accepted geometry to the GMod adapter.
- Recover hit/guard/substitution and frame-120 event scheduling. A collision
  does not imply a fixed delay; the graph launches hit00 on collision or timeout.
- Validate actor coordinate conversion and root matrix against a capture before
  connecting this motion to scene draws.

No player deployment, screenshot comparison, visual-parity claim, or timing
claim is made by this math module.

## Target guidance disassembly update

The wrapper `0x140a61fa0` calls `0x140a62320` with the two action values. The
full native function is preserved in `crawler_guidance.asm`; shared actor setup
is in `crawler_shared_init.asm`. Setup maps action getter 13 to the guidance
enable flag at actor `+0x3b0`, getter 11 to `+0x14`, and getter 15 to `+0x18`.
The CRAWLER tick calls guidance after position integration, ground response,
and orientation update, then recomputes orientation if guidance changed the
velocity. A failed guidance call clears `+0x3b0`.

The guidance routine consults the engine's global character/target registries,
filters candidates using native state checks, transforms a candidate position,
and steers the CRAWLER velocity. This proves the movement depends on live world
and target state. The math path is available for continued translation, but the
registry semantics, all target filters, angular thresholds and scene coordinate
mapping have not yet been independently decoded. The current callback in
`crawler_actor_core.lua` remains a seam; it does not emulate the native target
search.

## Updated state

The actor tick, terrain-hit predicate, update order, and action-slot binding are
now recorded. The attack is still not connected to GMod's player/world adapter,
and the native target search and exact collision geometry remain outstanding.
