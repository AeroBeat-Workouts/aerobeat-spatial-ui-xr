@tool
extends RefCounted
class_name AeroSpatialUiXrProvider

const PROJECTION_HELPER_SCRIPT := preload("res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd")
const RECT_TARGET_RESOLVER_SCRIPT_PATH := "res://addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd"
const INTERACTION_TYPES := preload("res://addons/aerobeat-input-core/src/ui/ui_interaction_types.gd")

const PROVIDER_LANE := "xr"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"
const SUPPORTED_SOURCE_VARIANTS := [
	"xr_ray",
	"xr_direct",
]
const DEFAULT_POINTER_ID_PREFIX := "xr_"
const DEFAULT_SOURCE_VARIANT: StringName = &"xr_ray"
const DEFAULT_DRAG_THRESHOLD_PIXELS := 12.0
const DEFAULT_BUTTON: StringName = &"trigger"

var pointer_id_prefix := DEFAULT_POINTER_ID_PREFIX
var default_source_variant: StringName = DEFAULT_SOURCE_VARIANT
var drag_threshold_pixels := DEFAULT_DRAG_THRESHOLD_PIXELS
var host_surface := ""
var target_resolution := "rect_target_specs"

var _projection_helper = PROJECTION_HELPER_SCRIPT.new()
var _target_resolver = null
var _active_pointer_state: Dictionary = {}
var _last_projected_data: Dictionary = {}
var _last_live_target_path: NodePath = NodePath()
var _last_surface_hover_hit := false
var _last_release_target_path := ""
var _last_forwarded_panel_event := ""
var _last_published_phase := ""
var _last_pointer_id: StringName = StringName()
var _last_source_variant: StringName = StringName()
var _last_button: StringName = StringName()
var _last_terminal_result := ""
var _last_interruption_reason := ""

func _init(config = null) -> void:
	_target_resolver = _build_target_resolver()
	if config != null:
		apply_config(config)
	else:
		var config_script = load(_config_script_path())
		if config_script != null:
			apply_config(config_script.new())

func apply_config(config) -> void:
	if config == null:
		return
	pointer_id_prefix = str(config.get("pointer_id_prefix", pointer_id_prefix)) if config is Dictionary else str(config.pointer_id_prefix)
	default_source_variant = StringName(config.get("default_source_variant", default_source_variant)) if config is Dictionary else StringName(config.default_source_variant)
	drag_threshold_pixels = float(config.get("drag_threshold_pixels", drag_threshold_pixels)) if config is Dictionary else float(config.drag_threshold_pixels)
	host_surface = str(config.get("host_surface", host_surface)) if config is Dictionary else str(config.host_surface)
	target_resolution = str(config.get("target_resolution", target_resolution)) if config is Dictionary else str(config.target_resolution)

func describe_boundary() -> Dictionary:
	return {
		"provider_lane": PROVIDER_LANE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"supported_source_variants": SUPPORTED_SOURCE_VARIANTS,
		"publishes_into_existing_contract": true,
		"implements_runtime_behavior": true,
		"owns_xr_provider_runtime": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_scene_specific_xr_rig": false,
		"owns_world_hit_acquisition": false,
		"expected_surface_type": "world_3d",
		"expected_verification_status": "unverified",
	}

func describe_runtime_state() -> Dictionary:
	var owner_summary := _describe_active_owner_state()
	return {
		"pointer_id_prefix": pointer_id_prefix,
		"default_source_variant": str(default_source_variant),
		"drag_threshold_pixels": drag_threshold_pixels,
		"active_pointer_count": _active_pointer_state.size(),
		"active_pointer_ids": PackedStringArray(_active_pointer_state.keys()),
		"active_pointer_state": _active_pointer_state.duplicate(true),
		"active_pointer_id": owner_summary.get("pointer_id", ""),
		"active_owner_target_path": owner_summary.get("owner_target_path", NodePath()),
		"active_live_target_path": owner_summary.get("live_target_path", NodePath()),
		"active_drag_started": owner_summary.get("drag_started", false),
		"active_source_variant": owner_summary.get("source_variant", ""),
		"active_button": owner_summary.get("button", ""),
		"has_active_owner": owner_summary.get("has_active_owner", false),
		"has_active_live_target": owner_summary.get("has_active_live_target", false),
		"last_pointer_id": _last_pointer_id,
		"last_source_variant": _last_source_variant,
		"last_button": _last_button,
		"last_published_phase": _last_published_phase,
		"last_live_target_path": _last_live_target_path,
		"last_surface_hover_hit": _last_surface_hover_hit,
		"last_release_target_path": _last_release_target_path,
		"last_terminal_result": _last_terminal_result,
		"last_interruption_reason": _last_interruption_reason,
		"last_forwarded_panel_event": _last_forwarded_panel_event,
		"last_projected_data": _last_projected_data.duplicate(true),
	}

func describe_interaction_summary() -> Dictionary:
	var owner_summary := _describe_active_owner_state()
	var owner_target_path: NodePath = owner_summary.get("owner_target_path", NodePath())
	var live_target_path: NodePath = owner_summary.get("live_target_path", NodePath())
	if live_target_path == NodePath() and _last_surface_hover_hit:
		live_target_path = _last_live_target_path
	var preferred_target_path: NodePath = owner_target_path if owner_target_path != NodePath() else live_target_path
	var has_active_pointer := not _active_pointer_state.is_empty()
	var active_phase: String = _last_published_phase if has_active_pointer else ""
	var locked_source_variant := str(owner_summary.get("source_variant", ""))
	if locked_source_variant == "":
		locked_source_variant = str(_last_source_variant)
	var active_button := str(owner_summary.get("button", ""))
	if active_button == "":
		active_button = str(_last_button)
	return {
		"is_xr_active": has_active_pointer,
		"active_pointer_count": _active_pointer_state.size(),
		"active_pointer_id": owner_summary.get("pointer_id", ""),
		"preferred_target_path": preferred_target_path,
		"preferred_target_label": _path_label(preferred_target_path),
		"owner_target_path": owner_target_path,
		"owner_target_label": _path_label(owner_target_path),
		"live_target_path": live_target_path,
		"live_target_label": _path_label(live_target_path),
		"state_phase": active_phase,
		"locked_source_variant": locked_source_variant,
		"active_button": active_button,
		"has_active_owner": owner_summary.get("has_active_owner", false),
		"has_active_live_target": owner_summary.get("has_active_live_target", false) or (live_target_path != NodePath()),
		"last_release_target_path": _last_release_target_path,
		"last_release_target_label": _path_label(_last_release_target_path),
		"last_terminal_result": _last_terminal_result,
		"last_interruption_reason": _last_interruption_reason,
		"last_forwarded_panel_event": _last_forwarded_panel_event,
		"verification_status": "unverified",
	}

func reset_runtime_state() -> void:
	_active_pointer_state = {}
	_last_projected_data = {}
	_last_live_target_path = NodePath()
	_last_surface_hover_hit = false
	_last_release_target_path = ""
	_last_forwarded_panel_event = ""
	_last_published_phase = ""
	_last_pointer_id = StringName()
	_last_source_variant = StringName()
	_last_button = StringName()
	_last_terminal_result = ""
	_last_interruption_reason = ""

func resolve_target_for_hit(surface, projected_hit: Dictionary) -> Dictionary:
	return _resolve_target_for_hit(surface, projected_hit)

func resolve_target_path_for_hit(surface, projected_hit: Dictionary) -> NodePath:
	var resolution_result := resolve_target_for_hit(surface, projected_hit)
	return resolution_result.get("target_path", NodePath())

func build_projected_data_for_hit(
	surface,
	projected_hit: Dictionary,
	context: Dictionary = {},
	previous_projected: Dictionary = {},
	owner_target_path: NodePath = NodePath(),
	live_target_path: NodePath = NodePath()
) -> Dictionary:
	var has_hit: bool = bool(projected_hit.get("hit", false))
	var resolution_result: Dictionary = resolve_target_for_hit(surface, projected_hit) if has_hit else {"target_path": NodePath(), "raw_metadata": {}}
	var resolved_live_target_path: NodePath = live_target_path if live_target_path != NodePath() else resolution_result.get("target_path", NodePath())
	return _build_projected_data(
		surface,
		projected_hit,
		previous_projected,
		owner_target_path,
		resolved_live_target_path,
		resolution_result.get("raw_metadata", {}).duplicate(true),
		context
	)

func publish_pointer_update(
	adapter,
	surface,
	pointer_update: Dictionary,
	projected_hit: Dictionary,
	context: Dictionary = {}
) -> bool:
	if adapter == null or surface == null or not surface.is_configured() or pointer_update == null:
		return false

	var pointer_id := _resolve_pointer_id(pointer_update, context)
	var previous_state: Dictionary = _active_pointer_state.get(pointer_id, {})
	var previous_projected: Dictionary = previous_state.get("projected_data", {})
	var previous_owner: NodePath = previous_state.get("owner_target_path", NodePath())
	var source_variant: StringName = _resolve_source_variant(pointer_update, previous_state, context)
	var button: StringName = _resolve_button(pointer_update, previous_state)
	var primary := bool(pointer_update.get("primary", true))
	var raw_event_class := StringName(pointer_update.get("raw_event_class", &"xr_pointer_update"))
	var raw_metadata := (pointer_update.get("raw_metadata", {}) as Dictionary).duplicate(true)
	_last_pointer_id = pointer_id
	_last_source_variant = source_variant
	_last_button = button

	if bool(pointer_update.get("canceled", false)):
		if previous_projected.is_empty():
			return false
		var interruption_reason := _resolve_interruption_reason(pointer_update, context, raw_metadata)
		_publish_pointer_phase(adapter, INTERACTION_TYPES.PHASE_CANCEL, pointer_id, previous_projected, {
			"source_variant": source_variant,
			"button": button,
			"primary": primary,
			"pressed": false,
			"raw_event_class": raw_event_class,
			"raw_metadata": raw_metadata,
		})
		_active_pointer_state.erase(pointer_id)
		_last_projected_data = previous_projected.duplicate(true)
		_last_published_phase = str(INTERACTION_TYPES.PHASE_CANCEL)
		_last_release_target_path = ""
		_last_terminal_result = "cancel"
		_last_interruption_reason = interruption_reason
		_last_forwarded_panel_event = "publish xr cancel %s (%s)" % [str(pointer_id), str(source_variant)]
		if interruption_reason != "":
			_last_forwarded_panel_event += " • reason %s" % interruption_reason
		return true

	var pressed := bool(pointer_update.get("pressed", false))
	var has_hit: bool = bool(projected_hit.get("hit", false))
	var target_resolution_result: Dictionary = _resolve_target_for_hit(surface, projected_hit)
	var live_target_path: NodePath = target_resolution_result.get("target_path", NodePath()) if has_hit else NodePath()
	var resolution_metadata: Dictionary = target_resolution_result.get("raw_metadata", {}).duplicate(true) if has_hit else {}
	_last_surface_hover_hit = has_hit
	_last_live_target_path = live_target_path

	if previous_state.is_empty():
		if not pressed:
			if has_hit and live_target_path != NodePath():
				_last_projected_data = _build_projected_data(
					surface,
					projected_hit,
					previous_projected,
					NodePath(),
					live_target_path,
					resolution_metadata,
					context
				)
				_last_forwarded_panel_event = "observe xr hover %s (%s) -> %s" % [str(pointer_id), str(source_variant), _path_label(live_target_path)]
			else:
				_last_projected_data = {}
				_last_forwarded_panel_event = "observe xr hover %s (%s) -> none" % [str(pointer_id), str(source_variant)]
			_last_published_phase = ""
			return has_hit
		if not has_hit or live_target_path == NodePath():
			return false
		var press_projected_data := _build_projected_data(
			surface,
			projected_hit,
			previous_projected,
			live_target_path,
			live_target_path,
			resolution_metadata,
			context
		)
		_publish_pointer_phase(adapter, INTERACTION_TYPES.PHASE_PRESS_BEGIN, pointer_id, press_projected_data, {
			"source_variant": source_variant,
			"button": button,
			"primary": primary,
			"pressed": true,
			"raw_event_class": raw_event_class,
			"raw_metadata": raw_metadata,
		})
		_active_pointer_state[pointer_id] = {
			"projected_data": press_projected_data.duplicate(true),
			"owner_target_path": live_target_path,
			"live_target_path": live_target_path,
			"press_surface_position": press_projected_data.get("surface_position", Vector2.ZERO),
			"drag_started": false,
			"source_variant": str(source_variant),
			"button": str(button),
		}
		_last_projected_data = press_projected_data.duplicate(true)
		_last_published_phase = str(INTERACTION_TYPES.PHASE_PRESS_BEGIN)
		_last_forwarded_panel_event = "publish xr press %s (%s) -> %s" % [str(pointer_id), str(source_variant), _path_label(live_target_path)]
		return true

	var owner_target_path: NodePath = previous_owner
	var press_surface_position: Vector2 = previous_state.get("press_surface_position", Vector2.ZERO)
	var drag_started := bool(previous_state.get("drag_started", false))
	var projected_data := _build_projected_data(
		surface,
		projected_hit,
		previous_projected,
		owner_target_path,
		live_target_path,
		resolution_metadata,
		context
	)

	if pressed:
		var drag_phase: StringName = INTERACTION_TYPES.PHASE_PRESS_HOLD
		var drag_distance := Vector2(projected_data.get("surface_position", Vector2.ZERO)).distance_to(press_surface_position)
		if drag_started:
			drag_phase = INTERACTION_TYPES.PHASE_DRAG_MOVE
		elif drag_distance >= drag_threshold_pixels:
			drag_started = true
			drag_phase = INTERACTION_TYPES.PHASE_DRAG_BEGIN
		_publish_pointer_phase(adapter, drag_phase, pointer_id, projected_data, {
			"source_variant": source_variant,
			"button": button,
			"primary": primary,
			"pressed": true,
			"raw_event_class": raw_event_class,
			"raw_metadata": raw_metadata,
		})
		_active_pointer_state[pointer_id] = {
			"projected_data": projected_data.duplicate(true),
			"owner_target_path": owner_target_path,
			"live_target_path": live_target_path,
			"press_surface_position": press_surface_position,
			"drag_started": drag_started,
			"source_variant": str(source_variant),
			"button": str(button),
		}
		_last_projected_data = projected_data.duplicate(true)
		_last_published_phase = str(drag_phase)
		_last_forwarded_panel_event = "publish xr move %s (%s) -> owner %s • hover %s" % [
			str(pointer_id),
			str(source_variant),
			_path_label(owner_target_path),
			_path_label(live_target_path)
		]
		return true

	if drag_started:
		_publish_pointer_phase(adapter, INTERACTION_TYPES.PHASE_DRAG_END, pointer_id, projected_data, {
			"source_variant": source_variant,
			"button": button,
			"primary": primary,
			"pressed": false,
			"raw_event_class": raw_event_class,
			"raw_metadata": raw_metadata,
		})
	_publish_pointer_phase(adapter, INTERACTION_TYPES.PHASE_PRESS_END, pointer_id, projected_data, {
		"source_variant": source_variant,
		"button": button,
		"primary": primary,
		"pressed": false,
		"raw_event_class": raw_event_class,
		"raw_metadata": raw_metadata,
	})
	_last_projected_data = projected_data.duplicate(true)
	_last_published_phase = str(INTERACTION_TYPES.PHASE_PRESS_END)
	_last_release_target_path = str(projected_data.get("target_path", NodePath()))
	_last_terminal_result = "release"
	_last_interruption_reason = ""
	_last_forwarded_panel_event = "publish xr release %s (%s) -> %s" % [
		str(pointer_id),
		str(source_variant),
		_path_label(projected_data.get("target_path", NodePath()))
	]
	_active_pointer_state.erase(pointer_id)
	return true

func _publish_pointer_phase(
	adapter,
	phase: StringName,
	pointer_id: StringName,
	projected_data: Dictionary,
	overrides: Dictionary
) -> void:
	adapter.publish_pointer_phase(pointer_id, phase, projected_data, overrides)

func _describe_active_owner_state() -> Dictionary:
	if _active_pointer_state.is_empty():
		return {
			"pointer_id": "",
			"owner_target_path": NodePath(),
			"live_target_path": NodePath(),
			"drag_started": false,
			"source_variant": "",
			"button": "",
			"has_active_owner": false,
			"has_active_live_target": false,
		}
	var pointer_id = _active_pointer_state.keys()[0]
	var pointer_state: Dictionary = _active_pointer_state.get(pointer_id, {})
	var owner_target_path: NodePath = pointer_state.get("owner_target_path", NodePath())
	var live_target_path: NodePath = pointer_state.get("live_target_path", NodePath())
	return {
		"pointer_id": str(pointer_id),
		"owner_target_path": owner_target_path,
		"live_target_path": live_target_path,
		"drag_started": bool(pointer_state.get("drag_started", false)),
		"source_variant": str(pointer_state.get("source_variant", "")),
		"button": str(pointer_state.get("button", "")),
		"has_active_owner": owner_target_path != NodePath(),
		"has_active_live_target": live_target_path != NodePath(),
	}

func _build_target_resolver():
	var resolver_script = load(RECT_TARGET_RESOLVER_SCRIPT_PATH)
	if resolver_script == null:
		push_error("AeroSpatialUiXrProvider could not load packaged rect-target resolver: %s" % RECT_TARGET_RESOLVER_SCRIPT_PATH)
		return null
	return resolver_script.new()

func _resolve_target_for_hit(surface, projected_hit: Dictionary) -> Dictionary:
	if _target_resolver == null:
		return {"target_path": NodePath(), "raw_metadata": {"resolution_mode": "rect_target_specs"}}
	var resolution_result = _target_resolver.resolve_target(surface, projected_hit)
	if resolution_result == null:
		return {"target_path": NodePath(), "raw_metadata": {"resolution_mode": "rect_target_specs"}}
	return {
		"target_path": resolution_result.target_path,
		"raw_metadata": resolution_result.raw_metadata.duplicate(true),
	}

func _build_projected_data(
	surface,
	projected_hit: Dictionary,
	previous_projected: Dictionary,
	owner_target_path: NodePath,
	live_target_path: NodePath,
	resolution_metadata: Dictionary,
	context: Dictionary
) -> Dictionary:
	var published_target_path: NodePath = owner_target_path if owner_target_path != NodePath() else live_target_path
	var extra_raw_metadata := resolution_metadata.duplicate(true)
	extra_raw_metadata["host_surface"] = _resolve_host_surface(surface, context)
	extra_raw_metadata["target_resolution"] = _resolve_target_resolution(surface, context)
	extra_raw_metadata["live_target_path"] = str(live_target_path)
	extra_raw_metadata["published_target_path"] = str(published_target_path)
	extra_raw_metadata["hover_target_path"] = str(live_target_path)
	extra_raw_metadata["owner_target_path"] = str(owner_target_path)
	extra_raw_metadata["pointer_id"] = str(_last_pointer_id)
	extra_raw_metadata["source_variant"] = str(_last_source_variant)
	return _projection_helper.build_projected_data(
		surface,
		projected_hit,
		previous_projected if not previous_projected.is_empty() else _last_projected_data,
		published_target_path,
		live_target_path,
		extra_raw_metadata
	)

func _resolve_pointer_id(pointer_update: Dictionary, context: Dictionary) -> StringName:
	if context.has("pointer_id"):
		return StringName(context.get("pointer_id", ""))
	if pointer_update.has("pointer_id"):
		return StringName(pointer_update.get("pointer_id", ""))
	var hand := str(pointer_update.get("hand", "0"))
	var prefix := str(context.get("pointer_id_prefix", pointer_id_prefix))
	return StringName("%s%s" % [prefix, hand])

func _resolve_source_variant(pointer_update: Dictionary, previous_state: Dictionary, context: Dictionary) -> StringName:
	if not previous_state.is_empty() and previous_state.has("source_variant"):
		return StringName(previous_state.get("source_variant", default_source_variant))
	var candidate := StringName(pointer_update.get("source_variant", context.get("source_variant", default_source_variant)))
	if INTERACTION_TYPES.is_valid_source_variant(candidate) and SUPPORTED_SOURCE_VARIANTS.has(str(candidate)):
		return candidate
	return default_source_variant

func _resolve_button(pointer_update: Dictionary, previous_state: Dictionary) -> StringName:
	if not previous_state.is_empty() and previous_state.has("button"):
		return StringName(previous_state.get("button", DEFAULT_BUTTON))
	var candidate := StringName(pointer_update.get("button", DEFAULT_BUTTON))
	return candidate if INTERACTION_TYPES.is_valid_button(candidate) else DEFAULT_BUTTON

func _resolve_interruption_reason(pointer_update: Dictionary, context: Dictionary, raw_metadata: Dictionary) -> String:
	for key in ["interruption_reason", "cancel_reason", "reason"]:
		if pointer_update.has(key):
			return str(pointer_update.get(key, ""))
		if context.has(key):
			return str(context.get(key, ""))
		if raw_metadata.has(key):
			return str(raw_metadata.get(key, ""))
	return ""

func _resolve_host_surface(surface, context: Dictionary) -> String:
	if context.has("host_surface"):
		return str(context.get("host_surface", ""))
	if host_surface != "":
		return host_surface
	return str(surface.metadata.get("host_surface", ""))

func _resolve_target_resolution(surface, context: Dictionary) -> String:
	if context.has("target_resolution"):
		return str(context.get("target_resolution", ""))
	if target_resolution != "":
		return target_resolution
	return str(surface.metadata.get("target_resolution", "rect_target_specs"))

func _config_script_path() -> String:
	var script_path := String(get_script().resource_path)
	return script_path.get_base_dir().path_join("aero_spatial_ui_xr_provider_config.gd")

func _path_label(path: Variant) -> String:
	if path is NodePath and path == NodePath():
		return "none"
	var path_text := str(path)
	if path_text == "":
		return "none"
	return path_text.get_file()
