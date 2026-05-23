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
		"no concrete XR runtime behavior yet",
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
	}

static func describe_extracted_slice() -> Dictionary:
	return {
		"owns_xr_lifecycle_runtime_state": false,
		"owns_xr_publish_policy": false,
		"owns_xr_runtime_diagnostics": false,
		"bootstrap_boundary_frozen": true,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_scene_specific_xr_rig": false,
		"owns_world_hit_acquisition": false,
	}
