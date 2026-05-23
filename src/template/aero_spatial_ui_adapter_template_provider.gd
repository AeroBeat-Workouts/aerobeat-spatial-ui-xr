@tool
extends RefCounted
class_name AeroSpatialUiAdapterTemplateProvider

const TEMPLATE_ROLE := "concrete_spatial_adapter_template"
const CONTRACT_OWNER_PACKAGE := "aerobeat-input-core"
const SHARED_HELPER_OWNER_PACKAGE := "aerobeat-spatial-ui-core"
const PROVIDER_LANE_EXAMPLES := [
	"aerobeat-spatial-ui-mouse",
	"aerobeat-spatial-ui-touch",
	"aerobeat-spatial-ui-xr",
]

func describe_boundary() -> Dictionary:
	return {
		"template_role": TEMPLATE_ROLE,
		"contract_owner_package": CONTRACT_OWNER_PACKAGE,
		"shared_helper_owner_package": SHARED_HELPER_OWNER_PACKAGE,
		"provider_lane_examples": PROVIDER_LANE_EXAMPLES,
		"requires_packaged_shared_helpers": true,
		"expects_separate_provider_lanes": true,
		"implements_runtime_behavior": false,
		"owns_contract_definition": false,
		"owns_native_2d_bridge": false,
		"owns_shared_helper_layer": false,
		"owns_provider_local_fallbacks": false,
		"owns_consumer_repo_glue": false,
	}
