@tool
extends RefCounted
class_name AeroSpatialUiXrProviderConfig

const BOOTSTRAP_PHASE := "phase_2_xr_packet_stack_bootstrap"
const DEFAULT_PROVIDER_LANE := "xr"

var contract_owner_package := "aerobeat-input-core"
var shared_helper_owner_package := "aerobeat-spatial-ui-core"
var supported_source_variants := PackedStringArray([
	"xr_ray",
	"xr_direct",
])
var verification_status_default := "unverified"
var requires_consumer_world_hit_acquisition := true

func to_boundary_snapshot() -> Dictionary:
	return {
		"provider_lane": DEFAULT_PROVIDER_LANE,
		"contract_owner_package": contract_owner_package,
		"shared_helper_owner_package": shared_helper_owner_package,
		"supported_source_variants": supported_source_variants,
		"verification_status_default": verification_status_default,
		"requires_consumer_world_hit_acquisition": requires_consumer_world_hit_acquisition,
		"bootstrap_phase": BOOTSTRAP_PHASE,
	}
