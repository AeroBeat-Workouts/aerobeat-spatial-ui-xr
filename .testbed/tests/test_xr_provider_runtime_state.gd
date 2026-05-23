extends GutTest

const RUNTIME_BOUNDARY_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd")

func test_runtime_state_file_declares_bootstrap_only_boundary():
	var dependencies := RUNTIME_BOUNDARY_SCRIPT.describe_dependencies()
	var slice := RUNTIME_BOUNDARY_SCRIPT.describe_extracted_slice()

	assert_eq(dependencies.get("provider_lane"), "xr")
	assert_true(dependencies.get("supported_source_variants", PackedStringArray()).has("xr_ray"))
	assert_true(dependencies.get("supported_source_variants", PackedStringArray()).has("xr_direct"))
	assert_true(dependencies.get("requires_consumer_world_hit_acquisition", false))
	assert_false(slice.get("owns_xr_runtime_diagnostics", true))
	assert_false(slice.get("owns_scene_specific_xr_rig", true))
	assert_false(slice.get("owns_world_hit_acquisition", true))
