class_name RouteOutcomePolicy
extends RefCounted


static func branch_succeeded(
	node_data: Dictionary,
	civilian_success: bool,
	destroyed_breakable_id: String,
	route_context: Dictionary = {}
) -> bool:
	var route_condition := node_data.get("route_condition", {}) as Dictionary
	match str(route_condition.get("kind", "")):
		"enemy_impact":
			var impact_received := bool(route_context.get("visible_enemy_impact_received", false))
			return not impact_received if str(route_condition.get("success_when", "avoided")) == "avoided" else impact_received
		"target_choice":
			return str(route_context.get("selected_route_target_id", "")) == str(route_condition.get("success_target", ""))
	if not node_data.has("breakable"):
		return civilian_success
	var breakable := node_data.get("breakable", {}) as Dictionary
	var expected_id := str(breakable.get("asset", ""))
	return (
		not expected_id.is_empty()
		and destroyed_breakable_id == expected_id
	)


static func initial_context(_node_data: Dictionary) -> Dictionary:
	return {
		"visible_enemy_impact_received": false,
		"visible_enemy_impact_source": "",
		"selected_route_target_id": "",
		"destroyed_route_targets": [],
	}


static func route_is_resolved(node_data: Dictionary, route_context: Dictionary) -> bool:
	var route_condition := node_data.get("route_condition", {}) as Dictionary
	if str(route_condition.get("kind", "")) != "target_choice":
		return true
	var selected_target := str(route_context.get("selected_route_target_id", ""))
	return selected_target in [
		str(route_condition.get("success_target", "")),
		str(route_condition.get("failure_target", "")),
	]


static func accepts_visible_enemy_impact(node_data: Dictionary, source: String) -> bool:
	var route_condition := node_data.get("route_condition", {}) as Dictionary
	if str(route_condition.get("kind", "")) != "enemy_impact":
		return false
	var accepted_sources := route_condition.get("accepted_sources", ["enemy_melee", "enemy_projectile"]) as Array
	return accepted_sources.has(source)


static func accepts_route_target(node_data: Dictionary, target_id: String) -> bool:
	var route_condition := node_data.get("route_condition", {}) as Dictionary
	if str(route_condition.get("kind", "")) != "target_choice":
		return false
	return target_id in [
		str(route_condition.get("success_target", "")),
		str(route_condition.get("failure_target", "")),
	]
