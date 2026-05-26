extends SceneTree

const INSTALLED_XR_PACKAGE_ROOT := "res://addons/aerobeat-spatial-ui-xr"
const INSTALLED_XR_PROVIDER_SCRIPT_PATH := INSTALLED_XR_PACKAGE_ROOT + "/src/providers/xr/aero_spatial_ui_xr_provider.gd"
const INSTALLED_XR_CONFIG_SCRIPT_PATH := INSTALLED_XR_PACKAGE_ROOT + "/src/providers/xr/aero_spatial_ui_xr_provider_config.gd"
const INSTALLED_XR_MANIFEST_SCRIPT_PATH := INSTALLED_XR_PACKAGE_ROOT + "/src/providers/xr/aero_spatial_ui_xr_manifest.gd"
const INSTALLED_XR_RUNTIME_BOUNDARY_SCRIPT_PATH := INSTALLED_XR_PACKAGE_ROOT + "/src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd"
const INSTALLED_CORE_SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const INSTALLED_CORE_PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")

class AdapterRecorder:
	extends RefCounted

	var published_events: Array = []

	func publish_pointer_phase(pointer_id, phase, projected_data: Dictionary = {}, overrides: Dictionary = {}) -> bool:
		published_events.append({
			"pointer_id": pointer_id,
			"phase": phase,
			"projected_data": projected_data.duplicate(true),
			"overrides": overrides.duplicate(true),
		})
		return true

func _init() -> void:
	var failures: Array[String] = []
	var required_paths := [
		INSTALLED_XR_PROVIDER_SCRIPT_PATH,
		INSTALLED_XR_CONFIG_SCRIPT_PATH,
		INSTALLED_XR_MANIFEST_SCRIPT_PATH,
		INSTALLED_XR_RUNTIME_BOUNDARY_SCRIPT_PATH,
	]

	for script_path in required_paths:
		if not ResourceLoader.exists(script_path):
			failures.append("missing installed addon script: %s" % script_path)
			continue
		var script = load(script_path)
		if script == null:
			failures.append("failed to load installed addon script: %s" % script_path)

	if failures.is_empty():
		var manifest: Dictionary = load(INSTALLED_XR_MANIFEST_SCRIPT_PATH).ownership_summary()
		if str(manifest.get("provider_lane", "")) != "xr":
			failures.append("installed xr manifest reported unexpected provider_lane: %s" % str(manifest.get("provider_lane", "")))
		if not bool(manifest.get("implements_xr_runtime_behavior", false)):
			failures.append("installed xr manifest did not report runtime behavior ownership")

		var config = load(INSTALLED_XR_CONFIG_SCRIPT_PATH).new()
		config.drag_threshold_pixels = 12.0
		config.host_surface = "WorldUiPanel"
		config.target_resolution = "rect_target_specs"
		var provider = load(INSTALLED_XR_PROVIDER_SCRIPT_PATH).new(config)
		var adapter := AdapterRecorder.new()
		var projection_helper = INSTALLED_CORE_PROJECTION_HELPER_SCRIPT.new()
		var surface = INSTALLED_CORE_SURFACE_DESCRIPTOR_SCRIPT.new().configure({
			"surface_id": &"installed_xr_surface",
			"surface_path": NodePath("/root/WorldUiPanel"),
			"viewport_path": NodePath("/root/PanelViewport"),
			"surface_pixel_size": Vector2(1000.0, 1000.0),
			"authored_rect_normalized": Rect2(0.0, 0.0, 1.0, 1.0),
			"target_specs": [
				{
					"target_key": "primary",
					"target_name": "Primary Action Button",
					"target_path": NodePath("Root/PrimaryActionButton"),
					"rect": Rect2(100.0, 100.0, 200.0, 200.0),
				}
			],
			"metadata": {
				"host_surface": "WorldUiPanel",
				"target_resolution": "rect_target_specs",
				"surface_size": Vector2(2.93, 1.577),
			}
		})
		var hit = projection_helper.build_surface_hit(surface, Vector2(0.2, 0.2), {
			"screen_position": Vector2(320.0, 240.0),
			"world_position": Vector3(0.2, 0.2, 0.0),
			"world_normal": Vector3.UP,
			"world_direction": Vector3.FORWARD,
		})

		var press := {
			"pointer_id": "xr_right",
			"pressed": true,
			"primary": true,
			"source_variant": &"xr_ray",
			"button": &"trigger",
			"raw_event_class": &"xr_pointer_update",
			"raw_metadata": {"pointer_id": "xr_right", "source_variant": &"xr_ray"},
		}

		if not provider.publish_pointer_update(adapter, surface, press, hit):
			failures.append("installed xr provider did not publish press")
		elif adapter.published_events.size() != 1:
			failures.append("installed xr provider published unexpected event count: %d" % adapter.published_events.size())
		else:
			var published: Dictionary = adapter.published_events[0]
			var projected: Dictionary = published.get("projected_data", {})
			if str(projected.get("target_path", NodePath())) != "Root/PrimaryActionButton":
				failures.append("installed xr provider returned unexpected target path: %s" % str(projected.get("target_path", NodePath())))
			var raw_metadata: Dictionary = projected.get("raw_metadata", {})
			if str(raw_metadata.get("published_target_path", "")) != "Root/PrimaryActionButton":
				failures.append("installed xr provider raw metadata reported unexpected published_target_path: %s" % str(raw_metadata.get("published_target_path", "")))
			if str(raw_metadata.get("host_surface", "")) != "WorldUiPanel":
				failures.append("installed xr provider raw metadata reported unexpected host_surface: %s" % str(raw_metadata.get("host_surface", "")))
			if str(raw_metadata.get("target_resolution", "")) != "rect_target_specs":
				failures.append("installed xr provider raw metadata reported unexpected target_resolution: %s" % str(raw_metadata.get("target_resolution", "")))
			var summary: Dictionary = provider.describe_interaction_summary()
			if str(summary.get("locked_source_variant", "")) != "xr_ray":
				failures.append("installed xr provider reported unexpected locked_source_variant: %s" % str(summary.get("locked_source_variant", "")))
			if str(summary.get("preferred_target_path", NodePath())) != "Root/PrimaryActionButton":
				failures.append("installed xr provider reported unexpected preferred_target_path: %s" % str(summary.get("preferred_target_path", NodePath())))
			if str(summary.get("verification_status", "")) != "unverified":
				failures.append("installed xr provider reported unexpected verification_status: %s" % str(summary.get("verification_status", "")))

	if failures.is_empty():
		print("Installed-addon package smoke passed for aerobeat-spatial-ui-xr")
		quit(0)
		return

	for failure in failures:
		push_error(failure)
	quit(1)
