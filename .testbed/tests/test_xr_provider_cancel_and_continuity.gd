extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_test_harness.gd")
const RUNTIME_BOUNDARY := preload("res://../src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd")

func test_cancel_and_entry_policy_match_first_extraction_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	assert_false(provider.publish_pointer_update(
		adapter,
		surface,
		harness.make_press("xr_right", "xr_ray"),
		harness.build_off_surface_hit(Vector2(950.0, 950.0))
	))
	assert_eq(events.size(), 0)

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_right", "xr_ray"), press_hit))

	assert_true(provider.publish_pointer_update(
		adapter,
		surface,
		harness.make_cancel("xr_right", "xr_direct"),
		harness.build_off_surface_hit(Vector2(205.0, 205.0))
	))
	assert_eq(harness.event_phases(events), ["press_begin", "cancel"])
	assert_eq(str(events[1].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[1].source_variant), "xr_ray")

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(int(state.get("active_pointer_count", -1)), 0)
	assert_eq(str(state.get("last_published_phase", "")), "cancel")

	var extracted_slice: Dictionary = RUNTIME_BOUNDARY.describe_extracted_slice()
	assert_true(extracted_slice.get("owns_xr_lifecycle_runtime_state", false))
	assert_true(extracted_slice.get("owns_xr_publish_policy", false))
	assert_true(extracted_slice.get("owns_cancel_policy", false))
	assert_true(extracted_slice.get("implements_xr_runtime_behavior", false))
