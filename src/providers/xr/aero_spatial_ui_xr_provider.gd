@tool
extends RefCounted
class_name AeroSpatialUiXrProvider

const PROVIDER_LANE := "xr"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"
const SUPPORTED_SOURCE_VARIANTS := [
	"xr_ray",
	"xr_direct",
]

func describe_boundary() -> Dictionary:
	return {
		"provider_lane": PROVIDER_LANE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"supported_source_variants": SUPPORTED_SOURCE_VARIANTS,
		"publishes_into_existing_contract": true,
		"implements_runtime_behavior": false,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_scene_specific_xr_rig": false,
		"owns_world_hit_acquisition": false,
	}

func describe_planned_semantics() -> Dictionary:
	return {
		"source_type": "xr",
		"source_variants": SUPPORTED_SOURCE_VARIANTS,
		"press_begin_phase": "press_begin",
		"hold_phase": "press_hold",
		"drag_begin_phase": "drag_begin",
		"drag_move_phase": "drag_move",
		"drag_end_phase": "drag_end",
		"press_end_phase": "press_end",
		"cancel_phase": "cancel",
		"verification_status_default": "unverified",
		"runtime_implemented": false,
	}
