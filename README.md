# AeroBeat Spatial UI XR

`aerobeat-spatial-ui-xr` is the AeroBeat repo for the **XR-driven spatial UI provider** lane.

This package now owns the first truthful extracted slice of reusable XR lifecycle/runtime behavior for projected and world-space UI surfaces. The repo keeps XR pointer continuity, source-variant normalization/locking, off-surface release continuation, cancel policy, and provider runtime diagnostics local to this package while leaving XR rig wiring, world-hit acquisition, and proof-scene composition outside the repo.

## Current status

This repository now contains:

- concrete XR provider runtime behavior under `src/providers/xr/`
- a provider-owned human verification harness under `.testbed/scenes/xr_provider_verification_harness.tscn`
- boundary docs that freeze repo ownership for XR lifecycle/runtime semantics only
- package/runtime manifests that pin dependency and non-goal truth
- provider-local semantic tests for press/release, drag ordering, cancel handling, runtime state, harness truth, and dependency boundaries
- a `.testbed/` workbench manifest that points at the canonical contract and shared helper owners

The current implementation is intentionally narrow:

- **included now:** XR lifecycle/runtime semantics, source-variant stability (`xr_ray` / `xr_direct`), owner continuity, off-surface release continuation, cancel publication policy, provider runtime diagnostics, the provider-owned human harness, and packaged shared-helper composition
- **still intentionally excluded:** XR rig wiring, world-hit acquisition, proof-host composition/debug UI, canonical contract ownership, and shared helper ownership changes

## Planned responsibility boundary

`aerobeat-spatial-ui-xr` owns reusable XR-specific spatial UI provider behavior such as:

- XR pointer runtime state for projected/world-space UI surfaces
- press/drag/release owner continuity for XR interaction
- source-variant normalization and continuity for `xr_ray` and `xr_direct`
- off-surface continuation using prior projected state when continuity exists
- cancel publication reserved for interrupted continuity
- provider-local runtime diagnostics for XR semantics

It is **not** intended to become:

- a second contract-definition repo
- the owner of the canonical interaction taxonomy, bus, or `XrUiInputAdapter`
- the home of the native 2D bridge path
- the owner of shared cross-provider spatial helpers
- the owner of scene-specific XR rig setup or proof-host world-hit acquisition
- a proof-scene composition repo

## Repository details

- **Type:** Spatial UI provider package
- **License:** Mozilla Public License 2.0 (MPL 2.0)
- **Dependency truth:**
  - `aerobeat-input-core` owns the canonical UI interaction contract
  - `aerobeat-spatial-ui-core` owns shared spatial-provider helper scaffolding
  - `gut` drives repo-local validation

## Runtime files

The concrete provider surface lives under:

- `src/providers/xr/aero_spatial_ui_xr_provider.gd`
- `src/providers/xr/aero_spatial_ui_xr_provider_config.gd`
- `src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd`
- `src/providers/xr/aero_spatial_ui_xr_manifest.gd`

Key repo-local docs:

- `docs/phase-1-boundary-freeze.md`
- `docs/phase-2-xr-packet-stack.md`
- `docs/phase-3-first-xr-provider-extraction.md`

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

Then open `.testbed/scenes/xr_provider_verification_harness.tscn` inside the hidden workbench to verify that:

- the active runtime seam is `AeroSpatialUiXrProvider`
- normalized events still publish `source_variant`, `phase`, `target_path`, and `verification_status` through the canonical contract path
- runtime state truth shows owner/live target continuity, release-outside truth, and interruption-only cancel behavior
- the repo is still not re-owning XR rig wiring, world-hit acquisition, or downstream proof-host composition

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
- `docs/phase-1-boundary-freeze.md` records the ownership line.
- `docs/phase-2-xr-packet-stack.md` records the packet-stack source-of-truth that drove this extraction.
- `docs/phase-3-first-xr-provider-extraction.md` records the extracted seam and parity truth.
- Provider-local tests pin semantic goals such as owner continuity, drag ordering, cancel handling, source-variant stability, runtime state, and dependency truth.
- `source_type == "xr"`, `source_variant == "xr_ray" | "xr_direct"`, `surface_type == "world_3d"`, and `verification_status == "unverified"` remain required runtime truth.
- Consumer proof in `aerobeat-ui-kit-community` remains mandatory downstream.
