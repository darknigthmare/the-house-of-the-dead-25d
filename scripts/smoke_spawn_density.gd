extends SceneTree

const SpawnTimingPolicyType := preload("res://src/rail/encounter_spawn_timing_policy.gd")
const SequenceTimingPolicyType := preload("res://src/rail/sequence_timing_policy.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"


func _initialize() -> void:
	var campaign := _load_campaign()
	if campaign.is_empty():
		_fail("campaign timeline could not be loaded")
		return
	var policy := SequenceTimingPolicyType.campaign_policy(campaign)
	var eligible_count := 0
	var spawn_count := 0
	var lowest_engagement_window := 1.0e20
	var smallest_wave_gap := 1.0e20
	for chapter_value: Variant in campaign.get("chapters", []) as Array:
		var chapter := chapter_value as Dictionary
		for node_value: Variant in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			var spawns := node.get("spawns", []) as Array
			if str(node.get("type", "")) == "boss" or spawns.size() < 2:
				continue
			if not SpawnTimingPolicyType.uses_distribution(node, policy):
				var config := SpawnTimingPolicyType.distribution_config(node, policy)
				if bool(config.get("enabled", true)) and str(config.get("mode", "")) != "authored":
					_fail("%s unexpectedly bypasses spawn distribution" % str(node.get("id", "encounter")))
					return
				continue
			eligible_count += 1
			spawn_count += spawns.size()
			var rail_duration := SequenceTimingPolicyType.rail_duration(node, policy)
			var schedule := SpawnTimingPolicyType.schedule(node, rail_duration, policy)
			var authored_first := float((spawns[0] as Dictionary).get("delay", 0.0))
			if not is_equal_approx(schedule[0], authored_first):
				_fail("%s moved its first contact" % str(node.get("id", "encounter")))
				return
			for spawn_index in range(1, schedule.size()):
				var wave_gap := schedule[spawn_index] - schedule[spawn_index - 1]
				smallest_wave_gap = minf(smallest_wave_gap, wave_gap)
				if wave_gap < 0.5 - 0.0001:
					_fail("%s changed authored spawn order" % str(node.get("id", "encounter")))
					return
			var remaining_engagement := rail_duration - schedule[schedule.size() - 1]
			lowest_engagement_window = minf(lowest_engagement_window, remaining_engagement)
			var required_engagement := SpawnTimingPolicyType.engagement_window_seconds(node, policy)
			if remaining_engagement < required_engagement - 0.0001:
				_fail("%s leaves only %.2fs for visible engagement" % [str(node.get("id", "encounter")), remaining_engagement])
				return
	if eligible_count != 34:
		_fail("expected 34 distributed ordinary encounters, got %d" % eligible_count)
		return
	if spawn_count != 98:
		_fail("expected 98 ordinary spawns, got %d" % spawn_count)
		return
	print("SMOKE ENGAGEMENT PACING: 34 encounters / 98 spawns, minimum window %.2fs, minimum wave gap %.3fs" % [
		lowest_engagement_window,
		smallest_wave_gap,
	])
	quit(0)


func _load_campaign() -> Dictionary:
	if not FileAccess.file_exists(CAMPAIGN_PATH):
		return {}
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _fail(message: String) -> void:
	push_error("SMOKE SPAWN DENSITY: %s" % message)
	quit(1)
