@tool
extends RefCounted
class_name AeroSpatialUiXrManifest

const PROVIDER_LANE := "xr"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"
const SUPPORTED_SOURCE_VARIANTS := [
	"xr_ray",
	"xr_direct",
]

static func ownership_summary() -> Dictionary:
	return {
		"repo_role": "xr_provider_runtime",
		"provider_lane": PROVIDER_LANE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"supported_source_variants": SUPPORTED_SOURCE_VARIANTS,
		"requires_packaged_shared_helpers": true,
		"requires_consumer_world_hit_acquisition": true,
		"ships_runtime_behavior": true,
		"verification_status_default": "unverified",
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_scene_specific_xr_rig": false,
		"owns_world_hit_acquisition": false,
		"implements_xr_runtime_behavior": true,
		"expected_surface_type": "world_3d",
	}
