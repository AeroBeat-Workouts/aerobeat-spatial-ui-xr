extends RefCounted

const BUS_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/ui_interaction_bus.gd")
const ADAPTER_SCRIPT := preload("res://addons/aerobeat-input-core/src/ui/adapters/xr_ui_input_adapter.gd")
const SURFACE_DESCRIPTOR_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd")
const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const PROVIDER_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider.gd")
const CONFIG_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider_config.gd")
const MANIFEST_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_manifest.gd")

const SURFACE_ID: StringName = &"xr_world_ui"
const DEFAULT_SOURCE_VARIANT: StringName = &"xr_ray"
const DEFAULT_SURFACE_TYPE: StringName = &"world_3d"
const DEFAULT_POINTER_ID := "xr_right"
const DEFAULT_BUTTON := "trigger"
const TARGET_PATH := NodePath("Root/PrimaryActionButton")
const SECONDARY_TARGET_PATH := NodePath("Root/SecondaryActionButton")
const PRIMARY_TARGET_RECT := Rect2(100.0, 100.0, 200.0, 200.0)
const SECONDARY_TARGET_RECT := Rect2(650.0, 100.0, 200.0, 200.0)

var _projection_helper = PROJECTION_HELPER_SCRIPT.new()

func spawn(test_case: GutTest, threshold := 12.0) -> Dictionary:
	var host := Node.new()
	host.name = "HarnessHost"
	test_case.add_child_autofree(host)
	await test_case.get_tree().process_frame
	var runtime := await attach_runtime(host, threshold)
	await test_case.get_tree().process_frame
	return runtime

func attach_runtime(host: Node, threshold := 12.0) -> Dictionary:
	var bus = BUS_SCRIPT.new()
	bus.name = "Bus"
	host.add_child(bus)
	var adapter = ADAPTER_SCRIPT.new()
	adapter.name = "Adapter"
	adapter.bus_path = NodePath("../Bus")
	adapter.surface_id = SURFACE_ID
	adapter.surface_type = DEFAULT_SURFACE_TYPE
	adapter.default_source_variant = DEFAULT_SOURCE_VARIANT
	host.add_child(adapter)
	await host.get_tree().process_frame

	var events: Array = []
	bus.interaction_event.connect(func(event): events.append(event))

	var config = CONFIG_SCRIPT.new()
	config.drag_threshold_pixels = threshold
	config.host_surface = "WorldUiPanel"
	config.target_resolution = "rect_target_specs"
	var provider = PROVIDER_SCRIPT.new(config)
	return {
		"host": host,
		"bus": bus,
		"adapter": adapter,
		"provider": provider,
		"surface": _build_surface(),
		"events": events,
	}

func build_hit(surface, authored_uv: Vector2, screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	var panel_uv := authored_uv
	return _projection_helper.build_surface_hit(surface, panel_uv, {
		"screen_position": screen_position,
		"world_position": Vector3(authored_uv.x, authored_uv.y, 0.0),
		"world_normal": Vector3.UP,
		"world_direction": Vector3.FORWARD,
		"surface_size": surface.metadata.get("surface_size", Vector2.ZERO),
	})

func build_off_surface_hit(screen_position: Vector2 = Vector2.ZERO) -> Dictionary:
	return {
		"hit": false,
		"screen_position": screen_position,
		"world_direction": Vector3.FORWARD,
	}

func make_press(pointer_id := DEFAULT_POINTER_ID, source_variant := DEFAULT_SOURCE_VARIANT, button := DEFAULT_BUTTON) -> Dictionary:
	return {
		"pointer_id": pointer_id,
		"pressed": true,
		"primary": true,
		"source_variant": source_variant,
		"button": button,
		"raw_event_class": &"xr_pointer_update",
		"raw_metadata": {"pointer_id": pointer_id, "source_variant": source_variant},
	}

func make_move(pointer_id := DEFAULT_POINTER_ID, source_variant := DEFAULT_SOURCE_VARIANT, button := DEFAULT_BUTTON) -> Dictionary:
	return {
		"pointer_id": pointer_id,
		"pressed": true,
		"primary": true,
		"source_variant": source_variant,
		"button": button,
		"raw_event_class": &"xr_pointer_update",
		"raw_metadata": {"pointer_id": pointer_id, "source_variant": source_variant},
	}

func make_release(pointer_id := DEFAULT_POINTER_ID, source_variant := DEFAULT_SOURCE_VARIANT, button := DEFAULT_BUTTON) -> Dictionary:
	return {
		"pointer_id": pointer_id,
		"pressed": false,
		"primary": true,
		"source_variant": source_variant,
		"button": button,
		"raw_event_class": &"xr_pointer_update",
		"raw_metadata": {"pointer_id": pointer_id, "source_variant": source_variant},
	}

func make_cancel(pointer_id := DEFAULT_POINTER_ID, source_variant := DEFAULT_SOURCE_VARIANT, button := DEFAULT_BUTTON) -> Dictionary:
	return {
		"pointer_id": pointer_id,
		"pressed": false,
		"canceled": true,
		"primary": true,
		"source_variant": source_variant,
		"button": button,
		"raw_event_class": &"xr_pointer_update",
		"raw_metadata": {"pointer_id": pointer_id, "source_variant": source_variant, "canceled": true},
	}

func event_phases(events: Array) -> Array[String]:
	var phases: Array[String] = []
	for event in events:
		phases.append(str(event.phase))
	return phases

func describe_snapshot(runtime: Dictionary, last_event = null, source_variant: StringName = DEFAULT_SOURCE_VARIANT) -> Dictionary:
	var provider = runtime.get("provider", null)
	var bus = runtime.get("bus", null)
	var runtime_state: Dictionary = provider.describe_runtime_state() if provider != null else {}
	var interaction_summary: Dictionary = provider.describe_interaction_summary() if provider != null else {}
	var manifest: Dictionary = MANIFEST_SCRIPT.ownership_summary()
	var effective_source_variant: StringName = source_variant
	if last_event != null:
		effective_source_variant = StringName(last_event.source_variant)
	elif str(interaction_summary.get("locked_source_variant", "")) != "":
		effective_source_variant = StringName(interaction_summary.get("locked_source_variant", ""))
	var verification: Dictionary = bus.get_source_verification(effective_source_variant, DEFAULT_SURFACE_TYPE) if bus != null else {}
	var verification_status: String = str(verification.get("status", interaction_summary.get("verification_status", "waiting")))
	var verification_notes: String = str(verification.get("notes", "No canonical verification notes available."))
	if last_event != null:
		verification_status = str(last_event.verification_status)
		verification_notes = str(last_event.verification_notes)
	return {
		"provider_lane": "xr",
		"packaged_provider_active": provider != null,
		"provider_runtime_source": "AeroSpatialUiXrProvider",
		"provider_runtime_seam": "installed_packaged_provider" if provider != null else "missing",
		"source_variant": str(effective_source_variant),
		"phase": str(last_event.phase) if last_event != null else "waiting",
		"target_path": str(last_event.target_path) if last_event != null else "",
		"surface_type": str(manifest.get("expected_surface_type", DEFAULT_SURFACE_TYPE)),
		"verification_status": verification_status,
		"verification_notes": verification_notes,
		"active_pointer_id": str(interaction_summary.get("active_pointer_id", "")),
		"active_pointer_count": int(interaction_summary.get("active_pointer_count", 0)),
		"preferred_target_path": str(interaction_summary.get("preferred_target_path", NodePath())),
		"preferred_target_label": str(interaction_summary.get("preferred_target_label", "none")),
		"owner_target_path": str(interaction_summary.get("owner_target_path", NodePath())),
		"owner_target_label": str(interaction_summary.get("owner_target_label", "none")),
		"live_target_path": str(interaction_summary.get("live_target_path", NodePath())),
		"live_target_label": str(interaction_summary.get("live_target_label", "none")),
		"state_phase": str(interaction_summary.get("state_phase", "")),
		"locked_source_variant": str(interaction_summary.get("locked_source_variant", "")),
		"active_button": str(interaction_summary.get("active_button", "")),
		"last_release_target_path": str(interaction_summary.get("last_release_target_path", "")),
		"last_release_target_label": str(interaction_summary.get("last_release_target_label", "none")),
		"last_terminal_result": str(interaction_summary.get("last_terminal_result", "")),
		"last_interruption_reason": str(interaction_summary.get("last_interruption_reason", "")),
		"last_forwarded_panel_event": str(interaction_summary.get("last_forwarded_panel_event", "waiting for synthetic XR input")),
		"runtime_state": runtime_state,
	}

func _build_surface():
	var surface = SURFACE_DESCRIPTOR_SCRIPT.new()
	surface.configure({
		"surface_id": SURFACE_ID,
		"surface_path": NodePath("/root/WorldUiPanel"),
		"viewport_path": NodePath("/root/PanelViewport"),
		"surface_pixel_size": Vector2(1000.0, 1000.0),
		"authored_rect_normalized": Rect2(0.0, 0.0, 1.0, 1.0),
		"target_specs": [
			{
				"target_key": "primary",
				"target_name": "Primary Action Button",
				"target_path": TARGET_PATH,
				"rect": PRIMARY_TARGET_RECT,
			},
			{
				"target_key": "secondary",
				"target_name": "Secondary Action Button",
				"target_path": SECONDARY_TARGET_PATH,
				"rect": SECONDARY_TARGET_RECT,
			}
		],
		"metadata": {
			"host_surface": "WorldUiPanel",
			"target_resolution": "rect_target_specs",
			"surface_size": Vector2(2.93, 1.577),
		},
	})
	return surface
