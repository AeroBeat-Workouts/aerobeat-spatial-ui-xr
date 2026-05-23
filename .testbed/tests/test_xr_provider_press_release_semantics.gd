extends GutTest

const PROVIDER_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider.gd")

func test_press_release_semantics_are_frozen_as_bootstrap_truth_only():
	var provider = PROVIDER_SCRIPT.new()
	var semantics := provider.describe_planned_semantics()

	assert_eq(semantics.get("source_type"), "xr")
	assert_true(semantics.get("source_variants", PackedStringArray()).has("xr_ray"))
	assert_true(semantics.get("source_variants", PackedStringArray()).has("xr_direct"))
	assert_eq(semantics.get("press_begin_phase"), "press_begin")
	assert_eq(semantics.get("hold_phase"), "press_hold")
	assert_eq(semantics.get("press_end_phase"), "press_end")
	assert_eq(semantics.get("verification_status_default"), "unverified")
	assert_false(semantics.get("runtime_implemented", true))
