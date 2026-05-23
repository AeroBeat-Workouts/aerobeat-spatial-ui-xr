# Phase 4 XR Completion + Manual Proof Packet

Date: 2026-05-23

This note defines the **next executable XR completion slice** after the audit-closed first XR runtime extraction in `aerobeat-spatial-ui-xr`, together with the **manual-verification/test-scene packet** needed so Derrick can prove the XR provider works beyond repo-local code tests.

This is a planning/execution packet only. It does **not** implement runtime behavior.

## Baseline this packet starts from

The current audit-closed XR baseline already proved a truthful first provider seam:

- provider-owned XR pointer lifecycle/runtime state
- owner continuity from press through release
- stable `source_variant` continuity for `xr_ray` / `xr_direct`
- off-surface release continuation
- `drag_end` before `press_end`
- `cancel` reserved for interrupted continuity
- repo-local semantic tests in `aerobeat-spatial-ui-xr`
- downstream packaged proof in `aerobeat-ui-kit-community`

Current gap: the lane still lacks a **human-checkable downstream XR proof surface** that uses the packaged provider while exposing provider-owned state truth without forcing the proof host to recreate XR semantics locally.

## Recommended next slice

**Recommended next provider-owned seam:** extract a provider-owned **XR interaction summary / interruption snapshot** API for downstream proof scenes.

Concretely, the next slice should add a summary layer on top of the existing XR pointer state machine so consumer scenes can read the current XR interaction truth directly from the provider instead of reconstructing it from raw runtime dictionaries.

### Why this is the right next slice

The first XR seam already moved the hard lifecycle semantics.
The next truthful step is **not** to move rig wiring, world-hit acquisition, or proof-scene composition into the provider repo.
It is to make the extracted provider usable by a manual proof scene without semantic owner drift back into `aerobeat-ui-kit-community`.

A downstream scene needs concise truth such as:

- which XR pointer is active
- whether the provider currently prefers the owner target or live hover target
- current phase (`press_begin`, `press_hold`, `drag_begin`, `drag_move`, etc.)
- locked `source_variant` (`xr_ray` / `xr_direct`)
- active button (`trigger` / `contact`)
- last release target
- whether the latest terminal event was a normal release or an interruption/cancel
- if interrupted, the interruption reason the host supplied (`tracking_lost`, `mode_switch`, `pointer_invalidated`, etc.)

That information belongs with the provider because it is a **presentation of provider-owned runtime semantics**, not a consumer-owned interpretation layer.

## Exact proposed provider-owned slice

Add a provider-facing summary seam analogous in spirit to the touch lane’s later `describe_interaction_summary()` work.

### Slice owns

`aerobeat-spatial-ui-xr` should own:

1. **XR interaction summary API**
   - preferred target path/label
   - owner target path/label
   - live target path/label
   - active phase
   - active pointer id / pointer count
   - locked source variant
   - active button
   - last release target path
   - last forwarded provider event label

2. **XR interruption snapshot truth**
   - whether the latest terminal result was release vs cancel
   - last interruption/cancel reason when present
   - provider-owned reason labels passed through from host context or pointer packet
   - no proof-host reinvention of cancel semantics

3. **Downstream-proof-facing diagnostics contract**
   - a stable dictionary/API shape that a consumer proof HUD can render directly
   - enough detail for manual verification without requiring `aerobeat-ui-kit-community` to re-derive semantics from raw state

4. **Provider-local tests for the summary seam**
   - summary truth during ray press
   - summary truth during direct press
   - summary truth while hover differs from owner
   - summary truth after release
   - summary truth after cancel/interruption

### Slice does not own

This slice must **not** pull any of the following into `aerobeat-spatial-ui-xr`:

1. XR rig wiring (`XROrigin3D`, controller node layout, action-map hookup)
2. world-hit acquisition / raycast / poke-contact collection
3. scene-specific conversion from live XR nodes into `projected_hit`
4. authored proof-scene composition or proof HUD layout
5. contract semantics or `XrUiInputAdapter` ownership
6. shared helper ownership
7. `verification_status` promotion beyond `unverified`

## What must remain outside the provider repo

The following seams stay outside `aerobeat-spatial-ui-xr` unless a later packet explicitly reopens ownership with proof:

### Still owned elsewhere

- **`aerobeat-input-core`**
  - canonical contract/event taxonomy
  - `XrUiInputAdapter`
  - verification truth source for XR status labels

- **`aerobeat-spatial-ui-core`**
  - shared projection / target-resolution helpers
  - any future cross-provider helper extracted for mouse/touch/XR together

- **`aerobeat-ui-kit-community`**
  - XR proof scene composition
  - XR rig node setup
  - controller pose sourcing
  - world-hit acquisition / raycasts / poke overlap acquisition
  - conversion from proof-host hits into the provider’s `projected_hit` input packet
  - manual-proof HUD layout and authored controls
  - actual glass-panel/example-scene ownership

## Test-scene ownership split

## Primary decision

**The new human-verification XR proof scene should live in `aerobeat-ui-kit-community`, not in `aerobeat-spatial-ui-xr`.**

### Why

Any scene that truthfully proves XR in a headset or runtime will necessarily own:

- rig wiring
- world-hit acquisition
- proof-scene composition
- authored panel placement
- proof HUD composition

Those are all explicitly outside the provider repo boundary.

### Provider-repo scene allowance

If desired, `aerobeat-spatial-ui-xr` may later add a **minimal synthetic non-rig probe scene** under its own `.testbed/` for package-local debugging, but that is optional and **not** the primary manual-proof target for this packet.

A synthetic provider-local scene is lower value than the downstream proof because it still would not prove real XR rig/world-hit wiring.

### Recommended split

- **`aerobeat-spatial-ui-xr`**
  - owns the new summary/interruption seam
  - owns repo-local summary tests
  - may keep/extend synthetic harnesses only

- **`aerobeat-ui-kit-community`**
  - owns the actual reusable XR proof scene Derrick opens to verify behavior manually
  - owns host-side XR hit sourcing
  - owns HUD/debug rendering that displays provider summary output
  - owns installed-addon downstream proof tests against that scene/host

## Proposed downstream proof-scene packet

Create a dedicated XR proof scene in `aerobeat-ui-kit-community` rather than folding XR into the existing hybrid mouse/touch proof host.

### Recommended downstream files

In `aerobeat-ui-kit-community`:

- `.testbed/scenes/glass-shader-xr-provider-proof.tscn`
- `.testbed/scripts/glass_shader_xr_provider_proof.gd`
- `.testbed/tests/test_packaged_xr_provider_summary_flow.gd`
- `.testbed/tests/test_packaged_xr_provider_proof_host_flow.gd`
- `.testbed/tests/support/xr_provider_proof_host_harness.gd`

### Why a dedicated scene instead of reusing `glass_shader_gui_3d_test.gd`

The existing hybrid proof host is already doing mouse/touch proof work and is intentionally centered on desktop/mobile-style forwarding.
A dedicated XR proof scene is cleaner because it:

- keeps XR rig assumptions isolated
- avoids mixing XR host wiring with the current touch/mouse proof scene
- makes manual headset verification steps obvious
- preserves the current ownership line that proof-scene composition is consumer-owned

### Scene responsibilities

The downstream XR proof scene should:

1. instantiate the packaged `AeroSpatialUiXrProvider`
2. instantiate `AeroUiInteractionBus` + `XrUiInputAdapter`
3. mount the existing glass panel target composition as the proof UI surface
4. own the XR rig and the hit-sourcing path
5. translate rig hits into provider input packets
6. render provider summary output on-screen in a human-readable debug block
7. keep `verification_status` labels displayed as `unverified`

### Recommended proof HUD contents

The scene’s debug/status block should show at least:

- active pointer id
- active phase
- active source variant
- active button
- preferred target label
- owner target label
- live target label
- last release target
- last terminal result (`release` / `cancel`)
- last interruption reason
- current `verification_status`
- latest forwarded provider event label

That HUD should be a **consumer presentation of provider summary output**, not a second local XR-state machine.

## Exact human verification steps the scene should enable

The point of this packet is that Derrick can open one scene and honestly verify the packaged provider with a real XR runtime.

### Manual verification flow

1. **Boot the dedicated XR proof scene**
   - scene loads with packaged `aerobeat-spatial-ui-xr`
   - debug HUD shows no active pointer
   - displayed verification truth remains `unverified`

2. **Ray hover over the primary action**
   - HUD shows `xr_ray`
   - live/preferred target labels change to `PrimaryActionButton`
   - no press is published yet

3. **Ray press and release on the primary action**
   - HUD shows `press_begin` then `press_end`
   - provider summary keeps `xr_ray`
   - action visibly triggers/toggles in the proof scene
   - last release target remains `PrimaryActionButton`

4. **Ray drag beyond threshold**
   - press on the primary action
   - move far enough to cross drag threshold
   - HUD shows `drag_begin` then `drag_move`
   - owner target remains the original press owner
   - if hover moves to a secondary target, live target may change while owner stays stable

5. **Release after drag**
   - HUD/event log makes `drag_end` visible before `press_end`
   - both terminal target labels remain the original owner

6. **Release off-surface with continuity**
   - start press on the primary target
   - move off the panel and release
   - proof still ends as ordinary release, not `cancel`
   - last release target remains the original owner

7. **Direct-contact interaction pass**
   - switch to a direct-touch/poke path on the same panel
   - HUD shows `xr_direct`
   - press/release works through the packaged provider
   - direct path does not silently relabel itself as `xr_ray`

8. **Interruption/cancel proof**
   - while pressed, intentionally trigger a host interruption path if available
     - e.g. synthetic tracking-loss toggle in the proof scene, controller invalidation toggle, or explicit debug button
   - HUD shows terminal result `cancel`
   - last interruption reason is visible
   - active pointer clears

9. **Mode isolation truth**
   - `xr_ray` and `xr_direct` each produce truthful labels
   - active press keeps its original source variant for the lifecycle even if host hover mode changes mid-press

10. **Verification truth remains conservative**
   - scene never claims `verified`
   - HUD and event output continue to show `verification_status == unverified`
   - manual success here is evidence for future upstream truth changes, not an automatic truth-label rewrite

## Automated tests that should accompany this packet

## A. Provider-repo tests in `aerobeat-spatial-ui-xr`

Add or extend tests for the new summary seam:

1. `.testbed/tests/test_xr_provider_interaction_summary.gd`
   - ray press populates preferred/owner/live target labels truthfully
   - direct press reports `xr_direct`
   - active phase reports hold/drag truthfully
   - last release target populates after release

2. extend `.testbed/tests/test_xr_provider_runtime_state.gd`
   - summary output stays aligned with raw runtime state
   - preferred target follows owner first, then live target when no owner exists

3. extend `.testbed/tests/test_xr_provider_cancel_and_continuity.gd`
   - interruption reason appears in the summary after cancel
   - ordinary off-surface release does not populate cancel-only interruption state

4. keep `.testbed/tests/test_xr_provider_dependency_boundary.gd`
   - explicitly assert the new summary seam still does not imply rig/world-hit/proof-scene ownership drift

### Provider must-pass assertions

- no summary field requires the consumer to rebuild XR semantics locally
- `xr_ray` / `xr_direct` remain truthful and stable through a press lifecycle
- summary prefers owner target over hover target when an owner exists
- last terminal result distinguishes release vs cancel
- interruption reason is empty for normal release and populated only when applicable
- `verification_status` remains `unverified`

## B. Consumer proof tests in `aerobeat-ui-kit-community`

Add scene/host-focused downstream tests:

1. `.testbed/tests/test_packaged_xr_provider_summary_flow.gd`
   - installed provider exposes the summary API from `res://addons/...`
   - consumer proof host reads provider summary directly
   - host does not reconstruct preferred/owner/live target semantics itself

2. `.testbed/tests/test_packaged_xr_provider_proof_host_flow.gd`
   - proof host creates the packaged provider and adapter/bus stack
   - synthetic host-owned hits route through the installed addon
   - summary/HUD fields update after press/drag/release/cancel
   - proof host still owns world-hit acquisition seams

3. optional focused host-wiring test
   - prove an explicit debug interruption toggle or synthetic interruption path causes provider `cancel`
   - prove the host passes the interruption reason through rather than inventing provider-local status after the fact

### Consumer must-pass assertions

- installed XR provider is the code path actually exercised
- provider summary is read from the package, not reassembled locally
- proof host still contains XR rig/world-hit ownership seams
- proof host does not move those seams into the provider repo
- displayed verification truth remains `unverified`

## Recommended execution order

1. implement the provider-owned XR interaction summary / interruption snapshot in `aerobeat-spatial-ui-xr`
2. add/extend provider-local tests there first
3. create the dedicated downstream XR proof scene in `aerobeat-ui-kit-community`
4. wire the proof scene to consume the packaged provider summary API
5. add consumer proof tests that exercise the installed addon path
6. perform manual XR verification in the proof scene
7. keep truth labels conservative until any upstream verification-status change is explicitly approved in the contract-owning lane

## Risks / decision points

1. **Real XR runtime availability**
   - the proof packet is only fully valuable if Derrick can run an XR runtime/device against the downstream scene
   - without hardware/runtime access, automated proof remains limited to synthetic host wiring

2. **Ray vs direct acquisition split**
   - the provider seam should stay agnostic
   - the downstream proof host must decide whether both `xr_ray` and `xr_direct` can be exercised in one scene or whether direct needs an explicit debug-mode shim first

3. **Interruption-source shape**
   - the next slice should settle a small host-to-provider convention for interruption reasons
   - recommendation: keep it as host-supplied metadata/context, not a new contract-owner move into `aerobeat-input-core`

4. **Do not overload the existing hybrid scene**
   - adding XR into `glass_shader_gui_3d_test.gd` would create unnecessary multi-lane host complexity
   - a dedicated XR proof scene is the cleaner and more durable choice

5. **No truth-label inflation**
   - even after manual headset success, do not change published `verification_status` inside the provider repo by default
   - any truth-label promotion must be deliberate and upstream-approved

## Bottom line

The next honest XR completion slice is **not** more rig ownership in the provider repo.
It is a **provider-owned XR interaction summary / interruption snapshot seam** that lets a downstream XR proof scene display packaged-provider truth directly.

The actual manual-verification scene should live in `aerobeat-ui-kit-community`, where XR rig wiring, world-hit acquisition, and proof-scene composition already belong.

That split gives Derrick a believable headset-checkable XR proof without reopening the repo-family ownership boundaries that were just audit-closed.
