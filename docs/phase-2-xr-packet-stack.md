# Phase 2 XR Packet Stack

Date: 2026-05-23

This note defines the **XR packet stack** that guided the first runtime extraction for `aerobeat-spatial-ui-xr`.

It remains the planning/source-of-truth packet for scope and parity. The concrete extracted seam that implemented this plan is recorded separately in `docs/phase-3-first-xr-provider-extraction.md`.

## Packet stack summary

The XR lane should follow the same four-packet shape already used for touch:

1. **Readiness packet** — confirm what is already separable vs what still belongs to the consumer/proof host
2. **First extraction packet** — define the minimum honest provider-owned slice
3. **Parity/test packet** — define pass/fail semantics before claiming extraction success
4. **Repo bootstrap packet** — define the concrete repo/package/files/docs/tests needed so implementation can start without reopening ownership boundaries

That packet order is the important decision. It keeps the XR lane aligned with the current spatial-ui family:

- `aerobeat-input-core` keeps the canonical UI interaction contract and `XrUiInputAdapter`
- `aerobeat-spatial-ui-core` keeps shared spatial helper ownership
- `aerobeat-spatial-ui-xr` owns only XR-specific provider lifecycle/runtime behavior
- consumer/proof repos keep scene-specific world-hit acquisition, XR rig wiring, authored proof composition, and installed-addon downstream proof

## 1. XR readiness packet

**Verdict:** ready for repo-specific extraction planning, not ready for blind provider implementation.

### Ready now

The family ownership lines are already decided by current source truth:

- `aerobeat-input-core` already exposes `XrUiInputAdapter` and seeds conservative XR verification truth
- `aerobeat-spatial-ui-core` remains the shared helper layer for projected-surface/provider infrastructure
- the template/mouse family pattern already proves that a concrete provider repo should stay narrow
- this repo already exists and can be used as the XR provider lane destination

### Not ready for blind implementation

XR provider implementation should **not** start by guessing scene/runtime ownership.
The missing piece is not repo creation; it is a frozen packet that says exactly what XR owns vs what stays consumer-local.

### XR ownership boundary

`aerobeat-spatial-ui-xr` should own:

- XR pointer lifecycle/runtime state
- XR interaction-mode normalization (`xr_ray` vs `xr_direct`) at the provider layer
- owner/capture continuity for XR-driven projected/world UI interactions
- provider-readable runtime diagnostics for downstream tests and proof scenes
- adapter composition into the existing canonical contract

`aerobeat-spatial-ui-xr` should **not** own:

- canonical contract/event taxonomy
- `XrUiInputAdapter` semantics
- native 2D bridge behavior
- shared projection/resolver/helper duplication
- scene-specific XR rig setup
- proof-host world-hit acquisition and authored target composition

## 2. First extraction packet

**Recommended first slice:** extract the reusable XR provider lifecycle/runtime lane only.

That first slice should mirror the touch and mouse logic shape:

- provider owns XR-specific lifecycle semantics
- host/proof scene owns world sourcing and authored scene composition
- shared helper ownership stays shared
- contract ownership stays in `aerobeat-input-core`

### Slice 1 should own

1. XR pointer/runtime state
   - active pointer ids
   - per-pointer owner target path
   - last projected/world interaction data needed for continuity

2. XR mode-specific publish policy
   - `xr_ray` lifecycle publication
   - `xr_direct` lifecycle publication
   - press/hold/drag/release/cancel mapping into the canonical contract
   - stable pointer-id policy for XR lanes

3. XR continuity/cancel policy
   - release-outside continuation when continuity is valid
   - cancel only when continuity/interruption rules actually require it
   - owner-vs-hover separation where the interaction model needs both truths

4. Provider runtime diagnostics
   - active pointer ids
   - current mode (`xr_ray` / `xr_direct`)
   - owner target path
   - hover target path when tracked
   - last published phase
   - verification metadata surfaced truthfully downstream

### Slice 1 should not own

1. XR rig node composition in consumer scenes
2. controller pose acquisition conventions specific to one proof host
3. world raycast scene ownership
4. proof-scene debug HUD composition
5. contract definitions or phase taxonomy duplication

## 3. Parity/test packet

The XR lane should not be judged by “we can click something in VR.”
It should be judged by an explicit semantic packet, parallel to touch.

### Required semantic packet

#### Contract truth checks

1. published XR events use the existing contract fields only
2. `source_type == "xr"`
3. `source_variant` is truthful and stable:
   - `xr_ray` for ray-driven interactions
   - `xr_direct` for direct-contact interactions
4. `verification_status` remains `unverified` unless live-device validation changes upstream truth
5. no provider-local invention of alternate contract taxonomy

#### Lifecycle parity checks

1. `press_begin` publishes on valid XR engagement
2. below-threshold continuation stays `press_hold`
3. threshold crossing yields `drag_begin` once, then `drag_move`
4. release after drag publishes `drag_end` before `press_end`
5. `press_end.target_path` remains the press owner unless contract-approved semantics say otherwise
6. ordinary release-outside with valid continuity remains release, not automatic `cancel`
7. `cancel` is reserved for interrupted continuity, tracking loss, or explicit invalidation
8. idle remains derived rather than explicitly emitted

#### Structure parity checks

1. provider owns XR lifecycle/runtime state
2. consumer/proof host owns XR rig/world-hit acquisition seams
3. shared helper-layer logic stays in `aerobeat-spatial-ui-core`
4. consumer repo proves the installed addon path is the exercised code path
5. downstream runtime diagnostics are inspectable without re-owning provider state locally

### Minimum future test inventory

In `aerobeat-spatial-ui-xr`:

- `.testbed/tests/test_xr_provider_press_release_semantics.gd`
- `.testbed/tests/test_xr_provider_drag_semantics.gd`
- `.testbed/tests/test_xr_provider_cancel_and_continuity.gd`
- `.testbed/tests/test_xr_provider_runtime_state.gd`
- `.testbed/tests/test_xr_provider_dependency_boundary.gd`

In the future consumer/proof repo that adopts the packaged XR lane:

- one installed-addon proof test
- one XR release/continuity parity test
- one XR metadata/runtime truth test

## 4. Repo bootstrap packet

This repo completed the XR bootstrap pass before runtime extraction started.

The remaining value of this section is historical: it records the minimum boundary/docs/tests/package shape that had to exist before runtime work began.

## Bottom line

The XR packet stack is now defined and exercised:

- **readiness:** ready for XR-lane extraction planning
- **first extraction:** move XR lifecycle/runtime semantics only
- **parity/tests:** require contract, lifecycle, and structure checks before claiming success
- **bootstrap:** establish the truthful repo boundary before implementation
