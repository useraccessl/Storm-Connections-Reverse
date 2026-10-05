# External repository assessment — 2026-10-02

Repository: https://github.com/hardkiller2565123123/StormRevivalClientSource
Inspected commit: e2ac7c17d4ec97424b758534dc49ab507632ed8b
Read-only source inspection; no build, DLL installation or repository code execution.

The Connections README lists effects/rendering research but contains copied
Storm 2 title/store references. It is not evidence of implemented effect RE.
The root README says Connections research is stuck on V1.6 and no longer
works after a recent patch. Its addresses cannot be assumed compatible.

Relevant source examined:
- NarutoStormConnectionsRevived/NSCFrameWork/XfbinInspector.cpp: extracts
  printable strings, categorizes names by substring. Not a particle/ANM parser.
- NarutoStormConnectionsRevived/NSCFrameWork/AssetTexturePreview.cpp: DDS/texture
  preview helpers. No particle shader or simulation reconstruction found.
- NarutoStormConnectionsRevived/steam_api64/CharacterRuntimeEditor.*:
  preview effect ID field; no complete effect renderer found.
- DX11OverlayCore and imgui_impl_dx11: overlay/UI rendering, not native effect math.
- NS4_GFX_CPP_SDK_Generated: ActionScript/Scaleform UI symbol registry, unrelated
  to the 3D particle/material engine.

Targeted searches for particle, billboard, emitter, Amaterasu, nuccChunkEffect,
nuccChunkAnm and gfxEffect across source/documentation did not yield a usable
particle-engine implementation. This assessment concerns the inspected commit,
not unpublished author research. No external code is imported into our runtime.
Continue original executable analysis.
