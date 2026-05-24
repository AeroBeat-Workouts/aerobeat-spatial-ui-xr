extends Control

const HARNESS_SCRIPT := preload("res://tests/support/xr_provider_test_harness.gd")

const PRIMARY_UV := Vector2(0.20, 0.20)
const SECONDARY_UV := Vector2(0.70, 0.20)
const PRIMARY_SCREEN := Vector2(200.0, 200.0)
const SECONDARY_SCREEN := Vector2(700.0, 200.0)
const OFF_SURFACE_SCREEN := Vector2(900.0, 900.0)

@onready var status_label: RichTextLabel = get_node_or_null("Margin/Content/Status") as RichTextLabel

var _harness = HARNESS_SCRIPT.new()
var _runtime: Dictionary = {}
var _last_event = null
var _active_pointer_id := HARNESS_SCRIPT.DEFAULT_POINTER_ID
var _active_source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT
var _active_button := HARNESS_SCRIPT.DEFAULT_BUTTON

func _ready() -> void:
	await _boot_runtime()
	_connect_buttons()
	_refresh_status()

func _boot_runtime() -> void:
	_runtime = await _harness.attach_runtime(self)
	var bus = _runtime.get("bus")
	if bus != null and not bus.interaction_event.is_connected(_on_interaction_event):
		bus.interaction_event.connect(_on_interaction_event)

func describe_hud_snapshot() -> Dictionary:
	return _harness.describe_snapshot(_runtime, _last_event, _active_source_variant)

func publish_hover_primary(source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT) -> bool:
	return _publish_pointer(
		_harness.make_release(_active_pointer_id, source_variant, _active_button),
		_harness.build_hit(_runtime.get("surface"), PRIMARY_UV, PRIMARY_SCREEN),
		source_variant
	)

func publish_press_primary(source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT, button: StringName = HARNESS_SCRIPT.DEFAULT_BUTTON) -> bool:
	_active_button = button
	return _publish_pointer(
		_harness.make_press(_active_pointer_id, source_variant, button),
		_harness.build_hit(_runtime.get("surface"), PRIMARY_UV, PRIMARY_SCREEN),
		source_variant
	)

func publish_drag_to_secondary(source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT, button: StringName = HARNESS_SCRIPT.DEFAULT_BUTTON) -> bool:
	_active_button = button
	return _publish_pointer(
		_harness.make_move(_active_pointer_id, source_variant, button),
		_harness.build_hit(_runtime.get("surface"), SECONDARY_UV, SECONDARY_SCREEN),
		source_variant
	)

func publish_release_off_surface(source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT, button: StringName = HARNESS_SCRIPT.DEFAULT_BUTTON) -> bool:
	_active_button = button
	return _publish_pointer(
		_harness.make_release(_active_pointer_id, source_variant, button),
		_harness.build_off_surface_hit(OFF_SURFACE_SCREEN),
		source_variant
	)

func publish_cancel(interruption_reason := "tracking_lost", source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT, button: StringName = HARNESS_SCRIPT.DEFAULT_BUTTON) -> bool:
	_active_button = button
	return _publish_pointer(
		_harness.make_cancel(_active_pointer_id, source_variant, button),
		_harness.build_off_surface_hit(OFF_SURFACE_SCREEN),
		source_variant,
		{"interruption_reason": interruption_reason}
	)

func publish_hover_secondary(source_variant: StringName = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT) -> bool:
	return _publish_pointer(
		_harness.make_release(_active_pointer_id, source_variant, _active_button),
		_harness.build_hit(_runtime.get("surface"), SECONDARY_UV, SECONDARY_SCREEN),
		source_variant
	)

func reset_runtime_snapshot() -> void:
	var provider = _runtime.get("provider", null)
	if provider != null:
		provider.reset_runtime_state()
	_last_event = null
	_active_source_variant = HARNESS_SCRIPT.DEFAULT_SOURCE_VARIANT
	_active_button = HARNESS_SCRIPT.DEFAULT_BUTTON
	_refresh_status()

func _publish_pointer(pointer_update: Dictionary, projected_hit: Dictionary, source_variant: StringName, context: Dictionary = {}) -> bool:
	var provider = _runtime.get("provider", null)
	var adapter = _runtime.get("adapter", null)
	var surface = _runtime.get("surface", null)
	if provider == null or adapter == null or surface == null:
		return false
	_active_source_variant = source_variant
	var publish_context := {
		"host_surface": "WorldUiPanel",
		"target_resolution": "rect_target_specs",
	}
	publish_context.merge(context, true)
	var published: bool = provider.publish_pointer_update(adapter, surface, pointer_update, projected_hit, publish_context)
	_refresh_status()
	return published

func _on_interaction_event(event) -> void:
	_last_event = event
	_refresh_status()

func _connect_buttons() -> void:
	_connect_button("Margin/Content/ButtonRows/HoverRow/HoverPrimaryButton", func(): publish_hover_primary())
	_connect_button("Margin/Content/ButtonRows/HoverRow/HoverSecondaryButton", func(): publish_hover_secondary())
	_connect_button("Margin/Content/ButtonRows/PressRow/PressPrimaryButton", func(): publish_press_primary())
	_connect_button("Margin/Content/ButtonRows/PressRow/DragToSecondaryButton", func(): publish_drag_to_secondary())
	_connect_button("Margin/Content/ButtonRows/PressRow/ReleaseOffSurfaceButton", func(): publish_release_off_surface())
	_connect_button("Margin/Content/ButtonRows/TerminalRow/CancelButton", func(): publish_cancel())
	_connect_button("Margin/Content/ButtonRows/TerminalRow/ResetButton", reset_runtime_snapshot)

func _connect_button(path: NodePath, callback: Callable) -> void:
	var button := get_node_or_null(path) as Button
	if button != null and not button.pressed.is_connected(callback):
		button.pressed.connect(callback)

func _refresh_status() -> void:
	if status_label == null:
		return
	var snapshot := describe_hud_snapshot()
	var lines := [
		"[b]XR provider verification harness[/b]",
		"[color=#cbd5e1]provider lane:[/color] %s" % snapshot.get("provider_lane", "xr"),
		"[color=#cbd5e1]packaged provider seam:[/color] %s" % snapshot.get("provider_runtime_seam", "missing"),
		"[color=#cbd5e1]provider runtime source:[/color] %s" % snapshot.get("provider_runtime_source", "missing"),
		"[color=#cbd5e1]source variant:[/color] %s" % snapshot.get("source_variant", "waiting"),
		"[color=#cbd5e1]surface type:[/color] %s" % snapshot.get("surface_type", "world_3d"),
		"[color=#cbd5e1]phase:[/color] %s" % snapshot.get("phase", "waiting"),
		"[color=#cbd5e1]target path:[/color] %s" % _path_label(snapshot.get("target_path", "")),
		"[color=#cbd5e1]verification status:[/color] %s" % snapshot.get("verification_status", "waiting"),
		"[color=#cbd5e1]verification notes:[/color] %s" % snapshot.get("verification_notes", "No canonical verification notes available."),
		"",
		"[b]xr runtime snapshot[/b]",
		"active_pointer_id = %s" % snapshot.get("active_pointer_id", "none"),
		"active_pointer_count = %s" % str(snapshot.get("active_pointer_count", 0)),
		"preferred_target_path = %s" % _path_label(snapshot.get("preferred_target_path", "")),
		"owner_target_path = %s" % _path_label(snapshot.get("owner_target_path", "")),
		"live_target_path = %s" % _path_label(snapshot.get("live_target_path", "")),
		"state_phase = %s" % snapshot.get("state_phase", "waiting"),
		"locked_source_variant = %s" % snapshot.get("locked_source_variant", "waiting"),
		"active_button = %s" % snapshot.get("active_button", "waiting"),
		"last_release_target_path = %s" % _path_label(snapshot.get("last_release_target_path", "")),
		"last_terminal_result = %s" % snapshot.get("last_terminal_result", "none"),
		"last_interruption_reason = %s" % snapshot.get("last_interruption_reason", ""),
		"last_forwarded_panel_event = %s" % snapshot.get("last_forwarded_panel_event", "waiting for synthetic XR input"),
	]
	status_label.text = "\n".join(lines)

func _path_label(path: Variant) -> String:
	var path_text := str(path)
	if path_text == "":
		return "none"
	if path is NodePath and path == NodePath():
		return "none"
	return path_text
