# r17 Source alpha approximation — 2026-10-02

## Adapter change

The principal fire pixel shader writes `base.a * alphaMultiplier` as target-0
alpha. The original draw disables fixed-function blending because it also writes
deferred MRT data. GMod's direct `screenspace_general` path has no matching MRT
attachment, so r17 enables Source alpha compositing for the main single-film
material family and disables depth writes. The same approximation applies to
the restored `1efc_part11b` family. The exact original blend equation remains
deferred/compositor-dependent; standard Source alpha is not asserted to match it.

The player verifier now checks that main-fire materials enable alpha blending
and disable depth writes, then checks cached draws and finite constants. This
is an executable approximation whose visual quality requires an in-game check.
The expected test is `storm_amt_procedural 1 1` after restarting/reloading the
client Lua. Compare the main flame silhouette, brightness, and overlap with the
previous build. If it becomes washed out, the target-alpha meaning or blend
factor must be revisited from the consumer/compositor data.

## Remaining exactness gates

The full scene-wide render target chain is recorded in
`r17_mrt_chain_findings.md`. Target 1's semantic meaning and which of the later
passes are responsible for the Amaterasu color remain unresolved. The current
Source alpha path is a fallback to make the game's output alpha visible in a
single-target renderer, not a full port of the game's particle renderer.
