# Phase 1 Boundary Freeze

This repo is now frozen as the **XR-driven spatial UI provider lane** in the AeroBeat spatial UI family.

## What this repo owns

`aerobeat-spatial-ui-xr` is the home of the concrete provider layer for XR interaction on projected/world-space UI surfaces.

That XR provider lane owns:

- XR pointer lifecycle/runtime state for spatial UI hosts
- XR press ownership, drag ownership, and release continuity for projected spatial surfaces
- source-variant continuity for `xr_ray` and `xr_direct`
- off-surface continuation using prior projected state when continuity exists
- explicit XR cancel publication policy
- provider-readable runtime diagnostics for XR semantics

## What this repo does **not** own

This boundary explicitly prevents the repo from drifting into other ownership lanes.

It does **not** own:

- the canonical interaction contract
- event taxonomy, event classes, or the interaction bus
- `XrUiInputAdapter` contract semantics
- the native 2D bridge path
- shared cross-provider spatial helper ownership
- proof-host XR rig wiring or world-hit acquisition from consumer repos
- scene-specific proof-host composition from consumer repos

## Dependency truth

This repo sits on top of:

- `aerobeat-input-core` — canonical contract owner
- `aerobeat-spatial-ui-core` — shared helper-layer owner

Those dependencies are represented in `.testbed/addons.jsonc`, while the runtime provider files under `src/providers/xr/` establish the concrete XR-lane boundary.

## Phase progression

- **Phase 1:** boundary freeze and truthful bootstrap scaffolding
- **Phase 2:** XR packet stack / extraction plan
- **Phase 3:** first real extracted XR-provider slice

The extraction result lives in `docs/phase-3-first-xr-provider-extraction.md`. That slice moves reusable XR lifecycle/runtime semantics only, while keeping XR rig wiring, world-hit acquisition, proof-scene composition, and canonical contract ownership outside this repo.
