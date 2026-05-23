@tool
extends RefCounted
class_name AeroSpatialUiXrRuntimeBoundary

static func describe_non_goals() -> PackedStringArray:
	return PackedStringArray([
		"no canonical interaction contract types",
		"no native 2D bridge logic",
		"no shared helper-layer ownership",
		"no scene-specific XR rig setup",
		"no proof-host world-hit acquisition ownership",
		"no proof-scene composition ownership",
	])

static func describe_dependencies() -> Dictionary:
	return {
		"contract_owner_package": "aerobeat-input-core",
		"shared_helper_owner_package": "aerobeat-spatial-ui-core",
		"provider_lane": "xr",
		"supported_source_variants": PackedStringArray([
			"xr_ray",
			"xr_direct",
		]),
		"requires_consumer_world_hit_acquisition": true,
		"helper_dependency_expectations": PackedStringArray([
			"XrUiInputAdapter",
			"AeroSpatialProjectionHelper",
			"AeroSpatialRectTargetResolver",
		]),
	}

static func describe_extracted_slice() -> Dictionary:
	return {
		"owns_xr_lifecycle_runtime_state": true,
		"owns_xr_publish_policy": true,
		"owns_xr_runtime_diagnostics": true,
		"owns_owner_continuity": true,
		"owns_off_surface_release_continuation": true,
		"owns_cancel_policy": true,
		"implements_xr_runtime_behavior": true,
		"bootstrap_boundary_frozen": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_scene_specific_xr_rig": false,
		"owns_world_hit_acquisition": false,
	}
