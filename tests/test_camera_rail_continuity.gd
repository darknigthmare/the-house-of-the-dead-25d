extends RefCounted

const ContinuityType := preload("res://src/rail/camera_rail_continuity.gd")
const TimingType := preload("res://src/rail/sequence_timing_policy.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	_test_transition_endpoints(checks)
	_test_mask_window(checks)
	_test_every_campaign_edge(checks)
	return checks


static func _test_transition_endpoints(checks: Array[Dictionary]) -> void:
	var from_pose := ContinuityType.pose_from_sample({"position": Vector3(1.0, 1.7, 4.0), "look_target": Vector3(0.0, 1.2, -8.0)})
	var to_pose := ContinuityType.pose_from_sample({"position": Vector3(-0.5, 1.9, 8.0), "look_target": Vector3(0.2, 1.3, -9.0)})
	var transition := ContinuityType.transition_between(from_pose, to_pose, 1.8, "room_a", "room_b")
	_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(transition, 0.0), from_pose), true, "transition begins at the exact previous camera pose")
	_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(transition, 1.8), to_pose), true, "transition ends at the exact next rail entry pose")
	var middle := ContinuityType.sample_transition(transition, 0.9)
	_add_check(checks, (middle.get("position", Vector3.ZERO) as Vector3).is_finite(), true, "Hermite connector produces a finite midpoint")


static func _test_mask_window(checks: Array[Dictionary]) -> void:
	_add_check(checks, ContinuityType.transition_mask_alpha(0.5), 0.0, "most of the physical connector remains visible")
	_add_check(checks, ContinuityType.transition_mask_alpha(0.9) > 0.0, true, "mask appears only near the local environment swap")
	_add_check(checks, is_equal_approx(ContinuityType.transition_mask_alpha(1.0), 1.0), true, "environment swap is fully hidden at the endpoint")


static func _test_every_campaign_edge(checks: Array[Dictionary]) -> void:
	var campaign := _load_campaign()
	var policy := TimingType.campaign_policy(campaign)
	var edge_count := 0
	for chapter_value: Variant in campaign.get("chapters", []) as Array:
		var chapter := chapter_value as Dictionary
		var nodes_by_id: Dictionary = {}
		for node_value: Variant in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			nodes_by_id[str(node.get("id", ""))] = node
		for node_id_value: Variant in nodes_by_id.keys():
			var node := nodes_by_id[node_id_value] as Dictionary
			var next_ids: Array[String] = []
			for key: String in ["next", "next_success", "next_failure"]:
				var next_id := str(node.get(key, ""))
				if next_id.is_empty() or next_id == "chapter_complete" or next_ids.has(next_id):
					continue
				next_ids.append(next_id)
			for next_id: String in next_ids:
				var next_node := nodes_by_id.get(next_id, {}) as Dictionary
				var from_duration := TimingType.rail_duration(node, policy)
				var to_duration := TimingType.rail_duration(next_node, policy)
				var from_pose := ContinuityType.node_exit_pose(node, from_duration, policy)
				var to_pose := ContinuityType.node_entry_pose(next_node, to_duration, policy)
				var connector := ContinuityType.transition_between(from_pose, to_pose, 1.35, str(node_id_value), next_id)
				_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(connector, 0.0), from_pose), true, "edge starts without a pose jump: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(connector, 1.35), to_pose), true, "edge reaches the next entry exactly: %s -> %s" % [str(node_id_value), next_id])
				edge_count += 1
	_add_check(checks, edge_count >= 40, true, "continuity audit covers every encoded non-terminal campaign edge")


static func _load_campaign() -> Dictionary:
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
