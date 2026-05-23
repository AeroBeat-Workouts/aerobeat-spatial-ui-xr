extends GutTest

const MANIFEST_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_manifest.gd")
const PROVIDER_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider.gd")
const CONFIG_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider_config.gd")
const RUNTIME_BOUNDARY_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd")
const BOUNDARY_DOC_PATH := "res://../docs/phase-1-boundary-freeze.md"

func before_all():
	gut.p("Starting XR bootstrap boundary tests...")

func after_all():
	gut.p("Finished XR bootstrap boundary tests.")

func test_plugin_manifest_structure():
	var manifest_path = "res://../plugin.cfg"
	assert_true(FileAccess.file_exists(manifest_path), "plugin.cfg should exist at the repo root")

	var config = ConfigFile.new()
	assert_eq(config.load(manifest_path), OK, "plugin.cfg should load")
	assert_eq(config.get_value("plugin", "name", ""), "AeroBeat Spatial UI XR", "plugin name should match XR repo identity")
	assert_eq(
		config.get_value("plugin", "description", ""),
		"Bootstrap package for the AeroBeat XR spatial UI provider lane and its frozen ownership boundary.",
		"plugin description should match XR bootstrap role"
	)

func test_xr_manifest_locks_dependency_truth_and_non_ownership():
	var summary := MANIFEST_SCRIPT.ownership_summary()

	assert_eq(summary.get("repo_role"), "xr_provider_bootstrap")
	assert_eq(summary.get("provider_lane"), "xr")
	assert_eq(summary.get("contract_owner_package"), "aerobeat-input-core")
	assert_eq(summary.get("shared_helper_owner_package"), "aerobeat-spatial-ui-core")
	assert_true(summary.get("supported_source_variants", PackedStringArray()).has("xr_ray"))
	assert_true(summary.get("supported_source_variants", PackedStringArray()).has("xr_direct"))
	assert_true(summary.get("requires_packaged_shared_helpers", false))
	assert_true(summary.get("requires_consumer_world_hit_acquisition", false))
	assert_eq(summary.get("verification_status_default", ""), "unverified")
	assert_false(summary.get("ships_runtime_behavior", true))
	assert_false(summary.get("owns_contract_definition", true))
	assert_false(summary.get("owns_native_2d_bridge", true))
	assert_false(summary.get("owns_shared_helper_layer", true))
	assert_false(summary.get("owns_scene_specific_xr_rig", true))
	assert_false(summary.get("owns_world_hit_acquisition", true))

func test_xr_placeholder_scripts_remain_inert_boundary_scaffolding():
	var provider = PROVIDER_SCRIPT.new()
	var config = CONFIG_SCRIPT.new()
	var boundary := provider.describe_boundary()
	var snapshot := config.to_boundary_snapshot()

	assert_eq(boundary.get("provider_lane"), "xr")
	assert_eq(boundary.get("contract_owner_package"), "aerobeat-input-core")
	assert_eq(boundary.get("shared_helper_owner_package"), "aerobeat-spatial-ui-core")
	assert_true(boundary.get("supported_source_variants", PackedStringArray()).has("xr_ray"))
	assert_true(boundary.get("supported_source_variants", PackedStringArray()).has("xr_direct"))
	assert_true(boundary.get("publishes_into_existing_contract", false))
	assert_false(boundary.get("implements_runtime_behavior", true))
	assert_false(boundary.get("owns_contract_definition", true))
	assert_false(boundary.get("owns_native_2d_bridge", true))
	assert_false(boundary.get("owns_shared_helper_layer", true))
	assert_false(boundary.get("owns_scene_specific_xr_rig", true))
	assert_false(boundary.get("owns_world_hit_acquisition", true))

	assert_eq(snapshot.get("provider_lane"), "xr")
	assert_eq(snapshot.get("bootstrap_phase"), "phase_2_xr_packet_stack_bootstrap")
	assert_eq(snapshot.get("contract_owner_package"), "aerobeat-input-core")
	assert_eq(snapshot.get("shared_helper_owner_package"), "aerobeat-spatial-ui-core")
	assert_eq(snapshot.get("verification_status_default", ""), "unverified")
	assert_true(snapshot.get("requires_consumer_world_hit_acquisition", false))

	var non_goals: PackedStringArray = RUNTIME_BOUNDARY_SCRIPT.describe_non_goals()
	assert_true(non_goals.has("no canonical interaction contract types"))
	assert_true(non_goals.has("no native 2D bridge logic"))
	assert_true(non_goals.has("no shared helper-layer ownership"))
	assert_true(non_goals.has("no scene-specific XR rig setup"))
	assert_true(non_goals.has("no proof-host world-hit acquisition ownership"))
	assert_true(non_goals.has("no concrete XR runtime behavior yet"))

func test_phase_1_boundary_doc_exists_and_states_xr_bootstrap_role():
	assert_true(FileAccess.file_exists(BOUNDARY_DOC_PATH), "Phase 1 boundary doc should exist")

	var doc_text := FileAccess.get_file_as_string(BOUNDARY_DOC_PATH)
	assert_string_contains(doc_text, "XR provider-lane bootstrap")
	assert_string_contains(doc_text, "aerobeat-input-core")
	assert_string_contains(doc_text, "aerobeat-spatial-ui-core")
	assert_string_contains(doc_text, "does **not** own")
	assert_string_contains(doc_text, "scene-specific XR rig setup")
	assert_string_contains(doc_text, "proof-host world-hit acquisition ownership")
