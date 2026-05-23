extends GutTest

const PROVIDER_SCRIPT := preload("res://../src/providers/xr/aero_spatial_ui_xr_provider.gd")

func test_drag_semantics_are_named_before_runtime_exists():
	var provider = PROVIDER_SCRIPT.new()
	var semantics := provider.describe_planned_semantics()

	assert_eq(semantics.get("drag_begin_phase"), "drag_begin")
	assert_eq(semantics.get("drag_move_phase"), "drag_move")
	assert_eq(semantics.get("drag_end_phase"), "drag_end")
	assert_false(semantics.get("runtime_implemented", true))
