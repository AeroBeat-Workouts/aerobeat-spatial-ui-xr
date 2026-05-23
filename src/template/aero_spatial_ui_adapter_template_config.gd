@tool
extends RefCounted
class_name AeroSpatialUiAdapterTemplateConfig

const EXTRACTION_PHASE := "phase_4_post_phase_3_boundary_truth"
const DEFAULT_TEMPLATE_ROLE := "concrete_spatial_adapter_template"

var contract_owner_package := "aerobeat-input-core"
var shared_helper_owner_package := "aerobeat-spatial-ui-core"
var adapter_examples := PackedStringArray([
	"aerobeat-spatial-ui-mouse",
	"aerobeat-spatial-ui-touch",
	"aerobeat-spatial-ui-xr",
])
var requires_packaged_shared_helpers := true
var expects_separate_provider_lanes := true

func to_boundary_snapshot() -> Dictionary:
	return {
		"template_role": DEFAULT_TEMPLATE_ROLE,
		"contract_owner_package": contract_owner_package,
		"shared_helper_owner_package": shared_helper_owner_package,
		"adapter_examples": adapter_examples,
		"requires_packaged_shared_helpers": requires_packaged_shared_helpers,
		"expects_separate_provider_lanes": expects_separate_provider_lanes,
		"extraction_phase": EXTRACTION_PHASE,
	}
