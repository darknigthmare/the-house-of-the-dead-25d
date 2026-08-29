class_name SequenceTimingPolicy
extends RefCounted

const DEFAULT_SCENE_DURATION_SCALE := 1.0
const DEFAULT_MINIMUM_DURATION_RATIO := 1.0
const DEFAULT_MINIMUM_FLOOR_SECONDS := 4.0
const DEFAULT_POST_CLEAR_HOLD_SECONDS := 0.75
const DEFAULT_TRANSITION_SECONDS := 1.8
const DEFAULT_BRANCH_TRANSITION_SECONDS := 2.2
const DEFAULT_SPAWN_SAFETY_SECONDS := 1.2
const DEFAULT_CONNECTOR_DISTANCE := 9.0


static func campaign_policy(campaign: Dictionary) -> Dictionary:
	var value: Variant = campaign.get("sequence_policy", {})
	return value as Dictionary if typeof(value) == TYPE_DICTIONARY else {}


static func effective_duration(node: Dictionary, policy: Dictionary = {}) -> float:
	var authored_duration := maxf(0.1, float(node.get("duration", 8.0)))
	var scale := float(node.get("duration_scale", policy.get("scene_duration_scale", DEFAULT_SCENE_DURATION_SCALE)))
	return authored_duration * clampf(scale, 0.25, 4.0)


static func rail_duration(node: Dictionary, policy: Dictionary = {}) -> float:
	var rail_value: Variant = node.get("rail", {})
	var rail := rail_value as Dictionary if typeof(rail_value) == TYPE_DICTIONARY else {}
	if rail.has("duration_seconds"):
		return maxf(0.1, float(rail.get("duration_seconds", 0.1)))
	return effective_duration(node, policy)


static func minimum_duration(node: Dictionary, policy: Dictionary = {}) -> float:
	var effective := effective_duration(node, policy)
	var explicit_minimum := float(node.get("minimum_duration", -1.0))
	var ratio := clampf(float(policy.get("minimum_duration_ratio", DEFAULT_MINIMUM_DURATION_RATIO)), 0.25, 2.0)
	var floor_seconds := maxf(0.0, float(policy.get("minimum_floor_seconds", DEFAULT_MINIMUM_FLOOR_SECONDS)))
	var result := maxf(floor_seconds, effective * ratio)
	if explicit_minimum >= 0.0:
		result = maxf(result, explicit_minimum)

	var latest_spawn := 0.0
	var spawns_value: Variant = node.get("spawns", [])
	if typeof(spawns_value) == TYPE_ARRAY:
		for spawn_value: Variant in spawns_value as Array:
			if typeof(spawn_value) != TYPE_DICTIONARY:
				continue
			latest_spawn = maxf(latest_spawn, float((spawn_value as Dictionary).get("delay", 0.0)))
	var spawn_safety := maxf(0.0, float(policy.get("spawn_safety_seconds", DEFAULT_SPAWN_SAFETY_SECONDS)))
	return maxf(result, latest_spawn + spawn_safety)


static func post_clear_hold(node: Dictionary, policy: Dictionary = {}) -> float:
	return maxf(0.0, float(node.get(
		"post_clear_hold",
		policy.get("post_clear_hold_seconds", DEFAULT_POST_CLEAR_HOLD_SECONDS)
	)))


static func requires_rail_complete(node: Dictionary, policy: Dictionary = {}) -> bool:
	return bool(node.get("require_rail_complete", policy.get("require_rail_complete", true)))


static func connector_distance(node: Dictionary, policy: Dictionary = {}) -> float:
	return clampf(float(node.get(
		"connector_distance",
		policy.get("connector_distance", DEFAULT_CONNECTOR_DISTANCE)
	)), 2.0, 24.0)


static func transition_descriptor(
	node: Dictionary,
	next_node: Dictionary,
	route_success: bool,
	policy: Dictionary = {}
) -> Dictionary:
	var is_branch := node.has("next_success")
	var duration := float(policy.get(
		"branch_transition_seconds" if is_branch else "transition_seconds",
		DEFAULT_BRANCH_TRANSITION_SECONDS if is_branch else DEFAULT_TRANSITION_SECONDS
	))
	var title := "ADVANCING"
	if is_branch:
		title = "ROUTE OPENED" if route_success else "ALTERNATE ROUTE"
	elif str(next_node.get("type", "")) == "boss":
		title = "BOSS APPROACH"

	var objective := str(next_node.get("objective", "")).strip_edges()
	var body := "Keep moving through Curien's estate."
	if not objective.is_empty():
		body = "NEXT: %s" % objective

	var transition_value: Variant = node.get("transition", {})
	if typeof(transition_value) == TYPE_DICTIONARY:
		var transition := transition_value as Dictionary
		var branch_key := "success" if route_success else "failure"
		var branch_value: Variant = transition.get(branch_key, {}) if is_branch else transition
		if typeof(branch_value) == TYPE_DICTIONARY:
			var selected := branch_value as Dictionary
			title = str(selected.get("title", title))
			body = str(selected.get("text", body))
			duration = float(selected.get("duration", duration))

	return {
		"title": title,
		"body": body,
		"duration": clampf(duration, 0.4, 6.0),
	}
