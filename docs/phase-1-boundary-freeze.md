# Phase 1 Boundary Freeze

This repo is frozen as the **template for concrete AeroBeat spatial UI adapter repos**.

The original Phase 1 freeze still defines the boundary, but downstream repos should now read it through the post-Phase-3 architecture truth:

- `aerobeat-input-core` owns the canonical interaction contract and native 2D bridge path
- `aerobeat-spatial-ui-core` owns the shared packaged helper/provider-support layer
- concrete repos generated from this template own one provider lane at a time
- consumer/proof repos may still host temporary composition seams, but they do not become the long-term owner of packaged provider fallback behavior

## What this repo is allowed to own

This template is the place where downstream spatial adapter repos inherit:

- concrete adapter package structure
- dependency truth pointing to `aerobeat-input-core` as the contract owner
- dependency truth pointing to `aerobeat-spatial-ui-core` as the shared helper-layer owner
- placeholder runtime and configuration scaffolding for future concrete adapters
- docs and tests that make the ownership boundary obvious before real extraction work begins
- guidance that concrete touch and XR work should branch into separate provider repos rather than staying as consumer-repo glue

## What this repo is not allowed to own

This template must not turn into a real adapter implementation and must not redefine the AeroBeat UI interaction contract.

It does **not** own:

- canonical contract event types
- the interaction bus
- event/source/surface/phase taxonomy
- native 2D bridge logic
- shared cross-provider helper-layer ownership
- provider-local rect/projected-target fallback ownership
- consumer-repo proof-host glue or compatibility wrapper ownership
- concrete mouse, touch, or XR runtime behavior

Those concerns stay in their owning repos:

- `aerobeat-input-core` owns the canonical interaction contract and native 2D bridge path
- `aerobeat-spatial-ui-core` owns shared helper scaffolding used by concrete adapter repos
- repos generated from this template own their concrete provider/runtime behavior
- touch work should graduate into a dedicated `aerobeat-spatial-ui-touch` style provider repo
- XR work should graduate into a dedicated `aerobeat-spatial-ui-xr` style provider repo

## Why placeholder runtime classes exist here

The placeholder runtime classes added to this template are intentionally inert. They exist so downstream repos start from the correct boundary shape instead of the old bootstrap shape.

If future work needs real world-hit logic, projected coordinate mapping, runtime publish behavior, or provider-local hover/capture ownership, that work belongs in a concrete adapter repo created from this template rather than in the template itself.

If a consumer/proof repo still contains temporary scene glue, world-ray acquisition, or compatibility wrappers, keep those seams local there until the relevant provider lane is ready. Do not teach generated adapter repos to own that consumer glue by default.
