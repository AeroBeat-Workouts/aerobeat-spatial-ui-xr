# Phase 3 First XR Provider Extraction

Date: 2026-05-23

This note records the first truthful extracted runtime seam for `aerobeat-spatial-ui-xr`.

## Extracted seam

The repo now owns a reusable **XR pointer lifecycle/runtime state machine** that:

- accepts host-supplied projected/world hit data instead of owning world-hit acquisition
- resolves authored target ownership through packaged shared helpers
- composes lifecycle publication through the existing `XrUiInputAdapter`
- preserves owner continuity from press through release
- keeps `source_variant` stable for the lifetime of a press (`xr_ray` / `xr_direct`)
- emits `drag_end` before `press_end`
- reserves `cancel` for interrupted continuity only
- reports truthful provider runtime diagnostics without re-owning proof-host seams

## What moved into this repo

The provider repo now owns:

- XR pointer runtime state and diagnostics
- XR press/hold/drag/release/cancel publication policy
- owner/live-target tracking for continuity truth
- source-variant locking for active pointer continuity
- packaged helper composition for target resolution + projected data assembly

## What intentionally stayed out

This extraction explicitly left the following seams outside the repo:

- XR rig wiring
- world-hit acquisition / raycast ownership
- authored proof-scene composition
- contract ownership and `XrUiInputAdapter` semantics
- shared helper-layer ownership

## Required runtime truth

The extracted seam must continue to preserve all of the following:

- `source_type == "xr"`
- `source_variant == "xr_ray"` or `"xr_direct"` and stable across a press lifecycle
- `verification_status == "unverified"`
- `drag_end` before `press_end`
- release-outside with continuity stays release, not cancel
- cancel only for interrupted continuity
- press ownership remains on the original press target unless a future contract change explicitly redefines that

## Validation expectation

This extraction is only considered truthful when both layers pass:

1. repo-local XR provider tests in `aerobeat-spatial-ui-xr`
2. downstream installed-addon proof in `aerobeat-ui-kit-community`

The downstream proof should exercise the packaged addon path directly rather than a consumer-local mirror.
