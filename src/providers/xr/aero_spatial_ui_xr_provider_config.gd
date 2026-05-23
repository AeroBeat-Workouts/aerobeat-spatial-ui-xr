@tool
extends RefCounted
class_name AeroSpatialUiXrProviderConfig

const DEFAULT_PROVIDER_LANE := "xr"
const DEFAULT_POINTER_ID_PREFIX := "xr_"
const DEFAULT_DEFAULT_SOURCE_VARIANT := "xr_ray"
const DEFAULT_DRAG_THRESHOLD_PIXELS := 12.0

var contract_owner_package := "aerobeat-input-core"
var shared_helper_owner_package := "aerobeat-spatial-ui-core"
var extraction_phase := "phase_3_first_xr_provider_extraction"
var pointer_id_prefix := DEFAULT_POINTER_ID_PREFIX
var default_source_variant := DEFAULT_DEFAULT_SOURCE_VARIANT
var drag_threshold_pixels := DEFAULT_DRAG_THRESHOLD_PIXELS
var host_surface := ""
var target_resolution := "rect_target_specs"
var enable_runtime_diagnostics := false

func to_boundary_snapshot() -> Dictionary:
	return {
		"provider_lane": DEFAULT_PROVIDER_LANE,
		"contract_owner_package": contract_owner_package,
		"shared_helper_owner_package": shared_helper_owner_package,
		"extraction_phase": extraction_phase,
		"pointer_id_prefix": pointer_id_prefix,
		"default_source_variant": default_source_variant,
		"drag_threshold_pixels": drag_threshold_pixels,
		"host_surface": host_surface,
		"target_resolution": target_resolution,
		"enable_runtime_diagnostics": enable_runtime_diagnostics,
		"verification_status_default": "unverified",
	}

func to_runtime_context() -> Dictionary:
	return {
		"pointer_id_prefix": pointer_id_prefix,
		"default_source_variant": default_source_variant,
		"drag_threshold_pixels": drag_threshold_pixels,
		"host_surface": host_surface,
		"target_resolution": target_resolution,
		"enable_runtime_diagnostics": enable_runtime_diagnostics,
	}
