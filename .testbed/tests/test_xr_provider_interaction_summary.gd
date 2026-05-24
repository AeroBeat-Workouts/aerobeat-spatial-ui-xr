extends GutTest

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_test_harness.gd")

func test_interaction_summary_reports_hover_press_and_drag_truth() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var hover_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_release("xr_right", "xr_ray"), hover_hit))

	var hover_summary: Dictionary = provider.describe_interaction_summary()
	assert_false(bool(hover_summary.get("is_xr_active", true)))
	assert_eq(int(hover_summary.get("active_pointer_count", -1)), 0)
	assert_eq(str(hover_summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(hover_summary.get("live_target_label", "")), "PrimaryActionButton")
	assert_eq(str(hover_summary.get("locked_source_variant", "")), "xr_ray")
	assert_eq(str(hover_summary.get("state_phase", "not-empty")), "")

	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_right", "xr_ray"), hover_hit))
	var drag_hit := harness.build_hit(surface, Vector2(0.70, 0.20), Vector2(700.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_move("xr_right", "xr_direct", "contact"), drag_hit))

	var interaction_summary: Dictionary = provider.describe_interaction_summary()
	assert_true(bool(interaction_summary.get("is_xr_active", false)))
	assert_eq(int(interaction_summary.get("active_pointer_count", -1)), 1)
	assert_eq(str(interaction_summary.get("active_pointer_id", "")), "xr_right")
	assert_eq(str(interaction_summary.get("preferred_target_path", NodePath())), "Root/PrimaryActionButton")
	assert_eq(str(interaction_summary.get("preferred_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("owner_target_label", "")), "PrimaryActionButton")
	assert_eq(str(interaction_summary.get("live_target_label", "")), "SecondaryActionButton")
	assert_eq(str(interaction_summary.get("state_phase", "")), "drag_begin")
	assert_eq(str(interaction_summary.get("locked_source_variant", "")), "xr_ray")
	assert_eq(str(interaction_summary.get("active_button", "")), "trigger")
	assert_eq(str(interaction_summary.get("verification_status", "")), "unverified")


func test_interaction_summary_clears_after_release_and_tracks_terminal_state() -> void:
	var harness = HARNESS_SCRIPT.new()
	var runtime = await harness.spawn(self)
	var provider = runtime["provider"]
	var adapter = runtime["adapter"]
	var surface = runtime["surface"]

	var press_hit := harness.build_hit(surface, Vector2(0.20, 0.20), Vector2(200.0, 200.0))
	assert_true(provider.publish_pointer_update(adapter, surface, harness.make_press("xr_left", "xr_direct", "contact"), press_hit))
	assert_true(provider.publish_pointer_update(
		adapter,
		surface,
		harness.make_release("xr_left", "xr_ray", "trigger"),
		harness.build_off_surface_hit(Vector2(900.0, 900.0))
	))

	var summary: Dictionary = provider.describe_interaction_summary()
	assert_false(bool(summary.get("is_xr_active", true)))
	assert_eq(int(summary.get("active_pointer_count", -1)), 0)
	assert_eq(str(summary.get("preferred_target_label", "not-none")), "none")
	assert_eq(str(summary.get("state_phase", "not-empty")), "")
	assert_eq(str(summary.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(summary.get("last_release_target_label", "")), "PrimaryActionButton")
	assert_eq(str(summary.get("last_terminal_result", "")), "release")
	assert_eq(str(summary.get("last_interruption_reason", "not-empty")), "")
	assert_eq(str(summary.get("locked_source_variant", "")), "xr_direct")
	assert_string_contains(str(summary.get("last_forwarded_panel_event", "")), "publish xr release xr_left")
