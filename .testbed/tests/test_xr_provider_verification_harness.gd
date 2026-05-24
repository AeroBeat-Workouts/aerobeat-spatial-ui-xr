extends GutTest

const SCENE := preload("res://scenes/xr_provider_verification_harness.tscn")
const VERIFICATION_STATUS := preload("res://addons/aerobeat-input-core/src/ui/ui_verification_status.gd")

func test_xr_harness_scene_exposes_packaged_provider_identity_runtime_truth_and_unpromoted_verification() -> void:
	var harness_scene = SCENE.instantiate()
	add_child_autofree(harness_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var initial_snapshot: Dictionary = harness_scene.describe_hud_snapshot()
	assert_eq(str(initial_snapshot.get("provider_lane", "")), "xr")
	assert_true(bool(initial_snapshot.get("packaged_provider_active", false)))
	assert_eq(str(initial_snapshot.get("provider_runtime_seam", "")), "installed_packaged_provider")
	assert_eq(str(initial_snapshot.get("provider_runtime_source", "")), "AeroSpatialUiXrProvider")
	assert_eq(str(initial_snapshot.get("surface_type", "")), "world_3d")
	assert_eq(StringName(initial_snapshot.get("verification_status", StringName())), VERIFICATION_STATUS.UNVERIFIED)
	assert_string_contains(str(initial_snapshot.get("verification_notes", "")), "not yet validated")

	assert_true(harness_scene.publish_hover_primary())
	assert_true(harness_scene.publish_press_primary())
	assert_true(harness_scene.publish_drag_to_secondary(&"xr_direct", &"contact"))

	var active_snapshot: Dictionary = harness_scene.describe_hud_snapshot()
	assert_eq(str(active_snapshot.get("phase", "")), "drag_begin")
	assert_eq(str(active_snapshot.get("target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(active_snapshot.get("owner_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(active_snapshot.get("live_target_path", "")), "Root/SecondaryActionButton")
	assert_eq(str(active_snapshot.get("locked_source_variant", "")), "xr_ray")
	assert_eq(str(active_snapshot.get("active_button", "")), "trigger")
	assert_eq(StringName(active_snapshot.get("verification_status", StringName())), VERIFICATION_STATUS.UNVERIFIED)
	assert_string_contains(str(active_snapshot.get("last_forwarded_panel_event", "")), "publish xr move")

	assert_true(harness_scene.publish_release_off_surface(&"xr_direct", &"contact"))
	var release_snapshot: Dictionary = harness_scene.describe_hud_snapshot()
	assert_eq(str(release_snapshot.get("phase", "")), "press_end")
	assert_eq(str(release_snapshot.get("target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(release_snapshot.get("last_release_target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(release_snapshot.get("last_terminal_result", "")), "release")
	assert_eq(str(release_snapshot.get("locked_source_variant", "")), "xr_ray")
	assert_eq(StringName(release_snapshot.get("verification_status", StringName())), VERIFICATION_STATUS.UNVERIFIED)

func test_xr_harness_cancel_button_keeps_cancel_reserved_for_interruption() -> void:
	var harness_scene = SCENE.instantiate()
	add_child_autofree(harness_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	assert_true(harness_scene.publish_press_primary())
	assert_true(harness_scene.publish_cancel("tracking_lost"))

	var snapshot: Dictionary = harness_scene.describe_hud_snapshot()
	assert_eq(str(snapshot.get("phase", "")), "cancel")
	assert_eq(str(snapshot.get("target_path", "")), "Root/PrimaryActionButton")
	assert_eq(str(snapshot.get("last_terminal_result", "")), "cancel")
	assert_eq(str(snapshot.get("last_interruption_reason", "")), "tracking_lost")
	assert_eq(str(snapshot.get("last_release_target_path", "not-empty")), "")
	assert_eq(StringName(snapshot.get("verification_status", StringName())), VERIFICATION_STATUS.UNVERIFIED)
	assert_string_contains(str(snapshot.get("last_forwarded_panel_event", "")), "tracking_lost")
