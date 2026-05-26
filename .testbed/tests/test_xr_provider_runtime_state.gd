extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_test_harness.gd")
const INSTALLED_XR_PACKAGE_ROOT := "res://addons/aerobeat-spatial-ui-xr"
const MANIFEST_SCRIPT_PATH := INSTALLED_XR_PACKAGE_ROOT + "/src/providers/xr/aero_spatial_ui_xr_manifest.gd"

func test_runtime_state_reports_owner_hover_and_manifest_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_right", "xr_ray"), press_hit))

	var drag_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_move("xr_right", "xr_ray"), drag_hit))

	var state: Dictionary = provider.describe_runtime_state()
	assert_eq(int(state.get("active_pointer_count", -1)), 1)
	assert_eq(str(state.get("last_pointer_id", "")), "xr_right")
	assert_eq(str(state.get("active_pointer_id", "")), "xr_right")
	assert_eq(str(state.get("active_owner_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(state.get("active_live_target_path", NodePath())), "Root/SecondaryActionButton")
	assert_true(bool(state.get("active_drag_started", false)))
	assert_eq(str(state.get("active_source_variant", "")), "xr_ray")
	assert_true(bool(state.get("has_active_owner", false)))
	assert_true(bool(state.get("has_active_live_target", false)))
	assert_eq(str(state.get("last_published_phase", "")), "drag_begin")
	assert_eq(str(state.get("last_live_target_path", "")), "Root/SecondaryActionButton")
	assert_true(bool(state.get("last_surface_hover_hit", false)))

	var active_state: Dictionary = state.get("active_pointer_state", {})
	var pointer_state: Dictionary = active_state.get("xr_right", {})
	assert_eq(str(pointer_state.get("owner_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(pointer_state.get("live_target_path", NodePath())), "Root/SecondaryActionButton")
	assert_true(bool(pointer_state.get("drag_started", false)))
	assert_eq(str(pointer_state.get("source_variant", "")), "xr_ray")

	var projected_data: Dictionary = state.get("last_projected_data", {})
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("hover_target_path", "")), "Root/SecondaryActionButton")
	assert_eq(str(raw_metadata.get("host_surface", "")), "WorldUiPanel")
	assert_eq(str(raw_metadata.get("target_resolution", "")), "rect_target_specs")
	assert_eq(str(raw_metadata.get("source_variant", "")), "xr_ray")

	var interaction_summary: Dictionary = provider.describe_interaction_summary()
	assert_true(bool(interaction_summary.get("is_xr_active", false)))
	assert_eq(str(interaction_summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(interaction_summary.get("state_phase", "")), "drag_begin")
	assert_eq(str(interaction_summary.get("locked_source_variant", "")), "xr_ray")
	assert_eq(str(interaction_summary.get("active_button", "")), "trigger")
	assert_eq(str(interaction_summary.get("last_terminal_result", "not-empty")), "")
	assert_eq(str(interaction_summary.get("verification_status", "")), "unverified")

	var summary: Dictionary = load(MANIFEST_SCRIPT_PATH).ownership_summary()
	assert_true(summary.get("implements_xr_runtime_behavior", false))
	assert_true(summary.get("supported_source_variants", PackedStringArray()).has("xr_ray"))
	assert_true(summary.get("supported_source_variants", PackedStringArray()).has("xr_direct"))
	assert_eq(summary.get("expected_surface_type"), "world_3d")
	assert_eq(summary.get("verification_status_default"), "unverified")

func test_provider_exposes_packaged_probe_helpers_for_target_resolution_and_projected_data() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var surface = runtime["surface"]

	var primary_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_eq(str(provider.resolve_target_path_for_hit(surface, primary_hit)), "Root/PrimaryActionButton")

	var projected_data: Dictionary = provider.build_projected_data_for_hit(
		surface,
		primary_hit,
		{"host_surface": "WorldUiPanel", "target_resolution": "rect_target_specs"},
		{},
		NodePath("Root/PrimaryActionButton")
	)
	var raw_metadata: Dictionary = projected_data.get("raw_metadata", {})
	assert_eq(str(projected_data.get("target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("published_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("live_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(raw_metadata.get("host_surface", "")), "WorldUiPanel")
	assert_eq(str(raw_metadata.get("target_resolution", "")), "rect_target_specs")
