extends GutTest

const PROVIDER_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider.gd")
const RUNTIME_BOUNDARY_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd")

func test_cancel_semantics_stay_planned_until_runtime_slice_exists():
	var provider = PROVIDER_SCRIPT.new()
	var semantics := provider.describe_planned_semantics()
	var slice := RUNTIME_BOUNDARY_SCRIPT.describe_extracted_slice()

	assert_eq(semantics.get("cancel_phase"), "cancel")
	assert_false(semantics.get("runtime_implemented", true))
	assert_true(slice.get("bootstrap_boundary_frozen", false))
	assert_false(slice.get("owns_xr_lifecycle_runtime_state", true))
	assert_false(slice.get("owns_xr_publish_policy", true))
