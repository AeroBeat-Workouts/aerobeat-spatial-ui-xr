@tool
extends RefCounted
class_name AeroSpatialUiAdapterTemplateRuntimeBoundary

static func describe_non_goals() -> PackedStringArray:
	return PackedStringArray([
		"no canonical interaction contract types",
		"no native 2D bridge logic",
		"no shared helper-layer ownership",
		"no provider-local projected-target fallback ownership",
		"no consumer-repo proof glue ownership",
		"no concrete adapter runtime behavior yet",
	])

static func describe_dependencies() -> Dictionary:
	return {
		"contract_owner_package": "aerobeat-input-core",
		"shared_helper_owner_package": "aerobeat-spatial-ui-core",
		"repo_role": "template_for_concrete_spatial_adapters",
		"requires_packaged_shared_helpers": true,
		"expects_separate_provider_lanes": true,
	}
