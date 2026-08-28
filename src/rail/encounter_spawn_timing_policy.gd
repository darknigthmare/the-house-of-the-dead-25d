class_name EncounterSpawnTimingPolicy
extends RefCounted

## Deterministic runtime schedule for ordinary encounter spawns.
##
## Authored delays remain the source of ordering and relative wave spacing. The
## first contact is never moved. Later waves are stretched so the last one
## occupies the configured portion of the effective camera rail instead of
## being exhausted during its opening seconds.

const DEFAULT_ENABLED := true
const DEFAULT_MODE := "stretch_preserve_first"
const DEFAULT_TARGET_LAST_RATIO := 0.82
const DEFAULT_MINIMUM_LAST_RATIO := 0.70


static func uses_distribution(node: Dictionary, policy: Dictionary = {}) -> bool:
	if str(node.get("type", "")) == "boss":
		return false
	var spawns_value: Variant = node.get("spawns", [])
	if typeof(spawns_value) != TYPE_ARRAY or (spawns_value as Array).size() < 2:
		return false
	var config := distribution_config(node, policy)
	return bool(config.get("enabled", DEFAULT_ENABLED)) and str(config.get("mode", DEFAULT_MODE)) != "authored"


static func distribution_config(node: Dictionary, policy: Dictionary = {}) -> Dictionary:
	var config: Dictionary = {}
	var global_value: Variant = policy.get("spawn_distribution", {})
	if typeof(global_value) == TYPE_DICTIONARY:
		config = (global_value as Dictionary).duplicate(true)
	var node_value: Variant = node.get("spawn_distribution", {})
	if typeof(node_value) == TYPE_DICTIONARY:
		config.merge(node_value as Dictionary, true)
	if node.has("spawn_timing_mode"):
		config["mode"] = str(node.get("spawn_timing_mode", DEFAULT_MODE))
	if node.has("spawn_distribution_enabled"):
		config["enabled"] = bool(node.get("spawn_distribution_enabled", DEFAULT_ENABLED))
	return config


static func target_last_ratio(node: Dictionary, policy: Dictionary = {}) -> float:
	var config := distribution_config(node, policy)
	var minimum := clampf(float(config.get("minimum_last_ratio", DEFAULT_MINIMUM_LAST_RATIO)), 0.0, 0.95)
	return clampf(float(config.get("target_last_ratio", DEFAULT_TARGET_LAST_RATIO)), minimum, 0.95)


static func minimum_last_ratio(node: Dictionary, policy: Dictionary = {}) -> float:
	var config := distribution_config(node, policy)
	return clampf(float(config.get("minimum_last_ratio", DEFAULT_MINIMUM_LAST_RATIO)), 0.0, 0.95)


static func schedule(node: Dictionary, effective_rail_duration: float, policy: Dictionary = {}) -> Array[float]:
	var result: Array[float] = []
	var spawns_value: Variant = node.get("spawns", [])
	if typeof(spawns_value) != TYPE_ARRAY:
		return result
	var spawns := spawns_value as Array
	for spawn_value: Variant in spawns:
		var spawn := spawn_value as Dictionary if typeof(spawn_value) == TYPE_DICTIONARY else {}
		result.append(maxf(0.0, float(spawn.get("delay", 0.0))))
	if not uses_distribution(node, policy):
		return result

	var first_delay := result[0]
	var authored_last := result[0]
	for authored_delay: float in result:
		authored_last = maxf(authored_last, authored_delay)
	var desired_last := maxf(
		authored_last,
		maxf(0.0, effective_rail_duration) * target_last_ratio(node, policy)
	)
	var authored_span := authored_last - first_delay
	var output: Array[float] = []
	for spawn_index in result.size():
		if spawn_index == 0:
			output.append(first_delay)
			continue
		var authored_delay := result[spawn_index]
		var authored_progress := (
			clampf((authored_delay - first_delay) / authored_span, 0.0, 1.0)
			if authored_span > 0.0001
			else float(spawn_index) / float(maxi(1, result.size() - 1))
		)
		output.append(lerpf(first_delay, desired_last, authored_progress))
	return output


static func scheduled_delay(
	node: Dictionary,
	spawn_index: int,
	effective_rail_duration: float,
	policy: Dictionary = {}
) -> float:
	var delays := schedule(node, effective_rail_duration, policy)
	if spawn_index < 0 or spawn_index >= delays.size():
		return 0.0
	return delays[spawn_index]


static func last_scheduled_delay(node: Dictionary, effective_rail_duration: float, policy: Dictionary = {}) -> float:
	var delays := schedule(node, effective_rail_duration, policy)
	return delays[delays.size() - 1] if not delays.is_empty() else 0.0
