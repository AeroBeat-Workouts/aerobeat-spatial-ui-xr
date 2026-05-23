extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_test_harness.gd")

func test_press_release_semantics_preserve_press_owner_and_unverified_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]
	var events: Array = runtime["events"]

	var boundary: Dictionary = provider.describe_boundary()
	assert_true(boundary.get("implements_runtime_behavior", false))
	assert_true(boundary.get("owns_xr_provider_runtime", false))
	assert_false(boundary.get("owns_world_hit_acquisition", true))
	assert_eq(boundary.get("expected_verification_status"), "unverified")

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_right", "xr_ray"), press_hit))
	assert_eq(events.size(), 1)
	assert_eq(str(events[0].phase), "press_begin")
	assert_eq(str(events[0].pointer_id), "xr_right")
	assert_eq(str(events[0].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[0].source_type), "xr")
	assert_eq(str(events[0].source_variant), "xr_ray")
	assert_eq(str(events[0].surface_type), "world_3d")
	assert_eq(str(events[0].verification_status), "unverified")

	assert_true(provider.publish_pointer_update(
		adapter,
		surface,
		harness.make_release("xr_right", "xr_direct"),
		harness.build_off_surface_hit(Vector2(900.0, 900.0))
	))
	assert_eq(events.size(), 2)
	assert_eq(str(events[1].phase), "press_end")
	assert_eq(str(events[1].target_path), "Root/PrimaryActionButton")
	assert_eq(str(events[1].source_variant), "xr_ray")

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(int(state.get("active_pointer_count", -1)), 0)
	assert_eq(str(state.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(state.get("last_published_phase", "")), "press_end")
	assert_eq(str(state.get("last_source_variant", "")), "xr_ray")
	var projected_data: Dictionary = state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_true(bool(raw_metadata.get("off_surface_continuation", false)))
	assert_eq(str(raw_metadata.get("published_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("host_surface", "")), "WorldUiPanel")
	assert_eq(str(raw_metadata.get("target_resolution", "")), "rect_target_specs")
