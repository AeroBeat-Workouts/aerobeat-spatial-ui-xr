# AeroBeat Spatial UI XR

`aerobeat-spatial-ui-xr` is the AeroBeat repo for the **XR-driven spatial UI provider** lane.

This repository is currently an **XR bootstrap/boundary package**. It no longer represents the generic spatial adapter template; instead it establishes the honest package identity, ownership line, placeholder runtime surface, and repo-local validation needed before real XR provider extraction begins.

The current slice is intentionally narrow:

- **included now:** XR-lane package identity, boundary docs, inert provider/config/runtime/manifest scaffolding, and test guards for dependency truth
- **still deferred:** real XR lifecycle publication, pointer continuity behavior, controller/rig integration, world-hit acquisition, and installed-addon proof-host adoption

## Current status

This repository now contains:

- explicit XR provider-lane scaffolding under `src/providers/xr/`
- docs that pin `aerobeat-input-core` as the canonical UI interaction contract owner
- docs and placeholder runtime metadata that pin `aerobeat-spatial-ui-core` as the shared spatial helper-layer owner
- bootstrap truth for the planned XR source variants `xr_ray` and `xr_direct`
- repo-local validation that guards against drift back into template identity or forbidden ownership

This bootstrap repo is intentionally **not** the XR provider implementation yet. Its job in this phase is to freeze the repo boundary so future extraction work can land without reopening package ownership questions.

## Planned responsibility boundary

`aerobeat-spatial-ui-xr` is intended to own XR-specific spatial UI provider behavior such as:

- XR pointer lifecycle/runtime state
- XR interaction-mode normalization for `xr_ray` and `xr_direct`
- provider-owned continuity/cancel policy for XR-driven world/projected UI interactions
- provider-readable runtime diagnostics for downstream proof and QA flows
- composition into the canonical interaction contract already owned by `aerobeat-input-core`

It is **not** intended to become:

- a second contract-definition repo
- the owner of the canonical interaction taxonomy or `XrUiInputAdapter`
- the home of the native 2D bridge path
- the owner of shared cross-provider spatial helpers
- the owner of scene-specific XR rig setup or proof-host world-hit acquisition
- a place to silently re-home consumer/proof composition glue

## Repository details

- **Type:** Spatial UI provider bootstrap
- **License:** Mozilla Public License 2.0 (MPL 2.0)
- **Dependency truth:**
  - `aerobeat-input-core` owns the canonical UI interaction contract
  - `aerobeat-spatial-ui-core` owns shared spatial-provider helper scaffolding
  - `gut` drives repo-local validation

## Runtime files

The current bootstrap surface lives under:

- `src/providers/xr/aero_spatial_ui_xr_provider.gd`
- `src/providers/xr/aero_spatial_ui_xr_provider_config.gd`
- `src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd`
- `src/providers/xr/aero_spatial_ui_xr_manifest.gd`

Key repo-local docs:

- `docs/phase-1-boundary-freeze.md`
- `docs/phase-2-xr-packet-stack.md`

## GodotEnv development flow

This repo follows the AeroBeat GodotEnv package convention.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`
- Repo-local unit tests: `.testbed/tests/`

The repo root remains the package boundary for downstream consumers. Direct development, smoke checks, and unit validation happen from the hidden `.testbed/` workbench.

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

### Open the workbench

From the repo root:

```bash
godot --editor --path .testbed
```

### Import smoke check

From the repo root:

```bash
godot --headless --path .testbed --import
```

### Run unit tests

From the repo root:

```bash
godot --headless --path .testbed --script addons/gut/gut_cmdln.gd \
  -gdir=res://tests \
  -ginclude_subdirs \
  -gexit
```

## Validation notes

- `.testbed/addons.jsonc` is the committed dev/test dependency manifest.
- `docs/phase-1-boundary-freeze.md` records the frozen ownership line for the XR lane.
- `docs/phase-2-xr-packet-stack.md` records the bootstrap, extraction, and semantic packet truth for future implementation work.
- The current XR lane remains **bootstrap-only** and should continue to report XR verification truth as `unverified` until real runtime/device validation exists upstream.
- Consumer/proof hosts must continue owning scene-specific XR rig wiring and world-hit acquisition until a later extraction slice moves only the provider-owned XR lifecycle/runtime lane into this package.
