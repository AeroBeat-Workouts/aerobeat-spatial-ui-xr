# Phase 1 Boundary Freeze

This repo is frozen as the **XR provider-lane bootstrap for AeroBeat spatial UI**.

The bootstrap boundary should now be read through the XR packet-stack truth:

- `aerobeat-input-core` owns the canonical interaction contract and the upstream `XrUiInputAdapter` contract surface
- `aerobeat-spatial-ui-core` owns the shared packaged helper/provider-support layer
- `aerobeat-spatial-ui-xr` owns only the XR provider lane and its future lifecycle/runtime extraction work
- consumer/proof repos keep scene-specific XR rig wiring, world-hit acquisition, authored proof composition, and installed-addon adoption until later extraction packets land

## What this repo is allowed to own

This bootstrap repo is the place where XR-provider work may grow into:

- XR-specific package identity and docs
- dependency truth pointing to `aerobeat-input-core` as the contract owner
- dependency truth pointing to `aerobeat-spatial-ui-core` as the shared helper-layer owner
- inert provider/config/runtime/manifest scaffolding for the XR lane
- future XR pointer lifecycle/runtime state
- future XR interaction-mode normalization for `xr_ray` and `xr_direct`
- future provider-readable runtime diagnostics for downstream proof and QA flows
- future adapter composition into the existing canonical contract

## What this repo is not allowed to own

This bootstrap repo must not claim XR implementation completion before the provider slice is actually extracted, and it must not redefine the AeroBeat UI interaction contract.

It does **not** own:

- canonical contract event types
- the interaction bus
- `XrUiInputAdapter` contract semantics
- native 2D bridge logic
- shared cross-provider helper-layer ownership
- scene-specific XR rig setup
- proof-host world-hit acquisition ownership
- proof-scene debug HUD composition
- consumer/proof compatibility-wrapper glue

Those concerns stay in their owning repos:

- `aerobeat-input-core` owns the canonical interaction contract and native 2D bridge path
- `aerobeat-spatial-ui-core` owns shared helper scaffolding used by concrete provider repos
- `aerobeat-spatial-ui-xr` should eventually own XR lifecycle/runtime semantics only
- consumer/proof repos keep XR rig/world-hit/composition seams until a later packet explicitly extracts them

## Why placeholder runtime classes exist here

The placeholder XR runtime classes in this repo are intentionally inert. They exist so the XR lane begins from a truthful package boundary instead of continuing to masquerade as the generic adapter template.

If future work needs real XR lifecycle publication, owner/capture continuity, cancel semantics, or runtime diagnostics backed by live provider state, that work belongs in a later extraction slice inside this repo rather than in this bootstrap pass.

If a consumer/proof repo still contains XR rig helpers, raycast ownership, or authored world-target composition, keep those seams local there until the relevant extraction packet explicitly moves XR provider ownership into this package.
