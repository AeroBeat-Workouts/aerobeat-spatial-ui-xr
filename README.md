# AeroBeat Spatial UI Adapter Template

This is the official template for creating a **spatial UI adapter** repository within the AeroBeat ecosystem.

A spatial UI adapter turns host-driven world, projected, or hybrid pointer detection into AeroBeat's shared UI interaction contract. Use this template for concrete adapter repos such as desktop mouse, touch, or XR providers that publish into the canonical contract owned by `aerobeat-input-core`.

This template stays intentionally bounded:

- `aerobeat-input-core` remains the canonical owner of the UI interaction contract and bus.
- `aerobeat-spatial-ui-core` remains the shared helper layer for spatial provider infrastructure, including packaged resolver/projection seams reused by concrete providers.
- Repos created from this template should implement one concrete spatial provider lane, not redefine the contract and not absorb shared helper ownership.
- Consumer repos should compose packaged providers and helpers; they should not become the long-term home of provider-local fallback ownership or cross-provider glue.
- Native 2D bridge work belongs in `aerobeat-input-core`, not in repos generated from this template.

## Post-Phase-3 architecture status

This repository now includes the minimum scaffolding needed to template the post-Phase-3 ownership boundary correctly.

That currently means:

- placeholder runtime/configuration classes under `src/template/`
- a boundary note in `docs/phase-1-boundary-freeze.md`
- tests that pin `aerobeat-input-core` as the contract owner
- tests and docs that pin `aerobeat-spatial-ui-core` as the shared packaged helper-layer owner
- inert template metadata that tells downstream repos to keep concrete provider behavior in their own lane
- explicit guidance that touch and XR work should grow into separate provider repos instead of consumer-repo glue

Current non-goals for this template:

- no concrete adapter runtime behavior here
- no canonical interaction contract definitions here
- no native 2D bridge logic here
- no shared cross-provider helper ownership here
- no provider-local projected-target fallback ownership here
- no consumer-repo proof-host glue ownership here
- no direct extraction of proof-scene behavior into the template

## 📋 Repository Details

- **Type:** Spatial UI Adapter Template
- **License:** **Mozilla Public License 2.0 (MPL 2.0)**
- **Current baseline dependencies:**
  - `aerobeat-input-core` (canonical UI interaction contract)
  - `aerobeat-spatial-ui-core` (shared spatial provider helpers)
  - `gut` (repo-local validation)
- **Template scaffolding:**
  - `src/template/` (placeholder runtime/configuration surface for downstream concrete adapters)
  - `docs/phase-1-boundary-freeze.md` (repo boundary contract)
- **Intended downstream examples:**
  - `aerobeat-spatial-ui-mouse`
  - future `aerobeat-spatial-ui-touch`
  - future `aerobeat-spatial-ui-xr`

## Provider-lane guidance for downstream repos

Repos created from this template should stay narrow and truthful:

- a mouse repo owns mouse-specific spatial lifecycle behavior
- a touch repo owns touch-specific spatial lifecycle behavior
- an XR repo owns XR-specific spatial lifecycle behavior
- shared resolver/projection/helper ownership stays packaged in `aerobeat-spatial-ui-core`
- the canonical interaction contract stays in `aerobeat-input-core`

If a consumer/proof repo still needs temporary world-hit composition, compatibility wrappers, or experiment-specific scene glue, keep that as consumer-side composition until it is ready to move into a dedicated provider lane. Do not normalize that glue back into a generated adapter repo.

## GodotEnv development flow

This repo uses the AeroBeat GodotEnv package convention.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`
- Repo-local unit tests: `.testbed/tests/`

The repo root remains the package/published boundary for downstream consumers. Day-to-day development, debugging, and validation happen from the hidden `.testbed/` workbench using the pinned OpenClaw toolchain: Godot `4.6.2 stable standard`.

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

That restores this repo's current dev/test manifest into `.testbed/addons/`.

### Open the workbench

From the repo root:

```bash
godot --editor --path .testbed
```

Use this `.testbed/` project as the canonical direct-development and bugfinding surface for spatial adapter work.

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

### Validation notes

- `.testbed/addons.jsonc` is the committed dev/test dependency contract.
- The current template baseline pins the canonical UI interaction contract, the shared spatial helper layer, and GUT.
- Repo-local unit tests live under `.testbed/tests/`.
- The current package shape is consumed from the repo root (`subfolder: "/"`) for downstream installs.
- `src/template/` exists only to template the ownership boundary; it is not a real adapter implementation.
- Repos created from this template should publish concrete spatial-provider behavior without expanding into new contract ownership.
- Repos created from this template should inherit the packaged helper/provider split directly instead of reintroducing provider-local fallback seams in consumer repos.
