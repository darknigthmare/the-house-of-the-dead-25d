class_name EnvironmentLayoutClassifier
extends RefCounted

## Deterministic layout taxonomy for the 33 authored campaign sequences.
##
## Keep this table explicit: substring rules made every layout containing
## "arena" inherit laboratory geometry, including Chariot and Hangedman.

const FAMILY_ESTATE: StringName = &"estate"
const FAMILY_MANSION: StringName = &"mansion"
const FAMILY_SEWER: StringName = &"sewer"
const FAMILY_LIBRARY: StringName = &"library"
const FAMILY_ROOF: StringName = &"roof"
const FAMILY_CHARIOT_ARENA: StringName = &"chariot_arena"
const FAMILY_HERMIT_TUNNEL: StringName = &"hermit_tunnel"
const FAMILY_LABORATORY: StringName = &"laboratory"
const FAMILY_UNKNOWN: StringName = &"unknown"

const LAYOUT_FAMILIES: Dictionary = {
	"estate_arrival": FAMILY_ESTATE,
	"front_steps": FAMILY_ESTATE,
	"bridge_channel": FAMILY_SEWER,
	"foyer_crossroad": FAMILY_MANSION,
	"upper_staircase": FAMILY_MANSION,
	"collapsed_hall": FAMILY_MANSION,
	"portrait_antechamber": FAMILY_MANSION,
	"narrow_corridor": FAMILY_MANSION,
	"chariot_arena": FAMILY_CHARIOT_ARENA,
	"hatch_gallery": FAMILY_SEWER,
	"low_tunnel": FAMILY_SEWER,
	"great_doors": FAMILY_MANSION,
	"library": FAMILY_LIBRARY,
	"raised_bridge": FAMILY_MANSION,
	"lower_stairs": FAMILY_SEWER,
	"roof_approach": FAMILY_ROOF,
	"roof_ledge": FAMILY_ROOF,
	"hangedman_arena": FAMILY_ROOF,
	"elevator_lobby": FAMILY_LABORATORY,
	"upper_research": FAMILY_LABORATORY,
	"service_lift": FAMILY_SEWER,
	"specimen_bay": FAMILY_LABORATORY,
	"high_bridge": FAMILY_LABORATORY,
	"vent_conduit": FAMILY_SEWER,
	"curien_tunnel": FAMILY_LABORATORY,
	"hermit_tunnel": FAMILY_HERMIT_TUNNEL,
	"rematch_arena": FAMILY_LABORATORY,
	"rematch_roof": FAMILY_ROOF,
	"bonus_gate": FAMILY_LABORATORY,
	"supply_cache": FAMILY_LABORATORY,
	"final_horde": FAMILY_LABORATORY,
	"bioreactor": FAMILY_LABORATORY,
	"magician_arena": FAMILY_LABORATORY,
}


static func classify(layout: String) -> StringName:
	return LAYOUT_FAMILIES.get(layout, FAMILY_UNKNOWN) as StringName


static func is_laboratory(layout: String) -> bool:
	return classify(layout) == FAMILY_LABORATORY


static func is_known(layout: String) -> bool:
	return classify(layout) != FAMILY_UNKNOWN


static func authored_layout_count() -> int:
	return LAYOUT_FAMILIES.size()
