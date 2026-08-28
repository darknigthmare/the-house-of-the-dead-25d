class_name EncounterSpawnTimingPolicyTest
extends RefCounted

const SpawnTimingPolicyType := preload("res://src/rail/encounter_spawn_timing_policy.gd")
const SequenceTimingPolicyType := preload("res://src/rail/sequence_timing_policy.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var policy := {
		"spawn_distribution": {
			"enabled": true,
			"mode": "stretch_preserve_first",
			"target_last_ratio": 0.82,
			"minimum_last_ratio": 0.70,
			"minimum_engagement_seconds": 7.0,
		}
	}
	var encounter := {
		"duration": 8.0,
		"spawns": [
			{"delay": 0.5, "actor": "sam_a1"},
			{"delay": 2.0, "actor": "neil_a2"},
			{"delay": 4.0, "actor": "cyril_a3"},
		],
	}
	var delays := SpawnTimingPolicyType.schedule(encounter, 12.0, policy)
	_add_check(checks, is_equal_approx(delays[0], 0.5), true, "spawn distribution preserves the first contact")
	_add_check(checks, is_equal_approx(delays[delays.size() - 1], 5.0), true, "last ordinary wave keeps a seven-second engagement window")
	_add_check(checks, delays[0] <= delays[1] and delays[1] <= delays[2], true, "spawn distribution preserves authored order")
	_add_check(checks, delays[1] > 2.0, true, "middle wave retains its relative order while filling the rail")

	var boss := encounter.duplicate(true)
	boss["type"] = "boss"
	_add_check(checks, SpawnTimingPolicyType.schedule(boss, 12.0, policy), [0.5, 2.0, 4.0], "boss timing is never redistributed")
	var opted_out := encounter.duplicate(true)
	opted_out["spawn_distribution"] = {"enabled": false}
	_add_check(checks, SpawnTimingPolicyType.schedule(opted_out, 12.0, policy), [0.5, 2.0, 4.0], "explicit node opt-out keeps authored timing")
	var late_authored := encounter.duplicate(true)
	(late_authored["spawns"] as Array)[2] = {"delay": 11.0, "actor": "cyril_a3"}
	_add_check(checks, is_equal_approx(SpawnTimingPolicyType.last_scheduled_delay(late_authored, 12.0, policy), 11.0), true, "later authored timing is never compressed")

	var campaign := _load_campaign()
	var campaign_policy := SequenceTimingPolicyType.campaign_policy(campaign)
	var eligible_count := 0
	var spawn_count := 0
	for chapter_value: Variant in campaign.get("chapters", []) as Array:
		var chapter := chapter_value as Dictionary
		for node_value: Variant in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			if not SpawnTimingPolicyType.uses_distribution(node, campaign_policy):
				continue
			eligible_count += 1
			spawn_count += (node.get("spawns", []) as Array).size()
			var rail_duration := SequenceTimingPolicyType.rail_duration(node, campaign_policy)
			var scheduled := SpawnTimingPolicyType.schedule(node, rail_duration, campaign_policy)
			var spawns := node.get("spawns", []) as Array
			var authored_first := float((spawns[0] as Dictionary).get("delay", 0.0))
			_add_check(checks, is_equal_approx(scheduled[0], authored_first), true, "%s keeps its first spawn contact" % str(node.get("id", "encounter")))
			_add_check(checks, rail_duration - scheduled[scheduled.size() - 1] >= 7.0 - 0.0001, true, "%s leaves a complete seven-second engagement window" % str(node.get("id", "encounter")))
			_add_check(checks, _is_ordered(scheduled), true, "%s preserves spawn order" % str(node.get("id", "encounter")))
			_add_check(checks, _minimum_gap(scheduled) >= 0.5 - 0.0001, true, "%s keeps every wave visually separated" % str(node.get("id", "encounter")))
	_add_check(checks, eligible_count, 34, "all thirty-four ordinary multi-wave encounters use distributed timing")
	_add_check(checks, spawn_count, 98, "engagement contract covers all ninety-eight ordinary spawns")
	return checks


static func _load_campaign() -> Dictionary:
	if not FileAccess.file_exists(CAMPAIGN_PATH):
		return {}
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


static func _is_ordered(values: Array[float]) -> bool:
	for index in range(1, values.size()):
		if values[index] < values[index - 1]:
			return false
	return true


static func _minimum_gap(values: Array[float]) -> float:
	var result := 1.0e20
	for index in range(1, values.size()):
		result = minf(result, values[index] - values[index - 1])
	return result


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
