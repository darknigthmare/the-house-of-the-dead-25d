extends RefCounted

const ContinuityType := preload("res://src/rail/camera_rail_continuity.gd")
const TimingType := preload("res://src/rail/sequence_timing_policy.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	_test_transition_endpoints(checks)
	_test_mask_window(checks)
	_test_connected_origin(checks)
	_test_transition_clamping_and_degenerate_motion(checks)
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
	_add_check(checks, _transition_is_monotonic(transition, 1.8), true, "connector advances toward its endpoint without reversing or overshooting")


static func _test_mask_window(checks: Array[Dictionary]) -> void:
	_add_check(checks, ContinuityType.transition_mask_alpha(0.75), 0.0, "most of the physical connector remains visible")
	_add_check(checks, ContinuityType.transition_mask_alpha(0.82) > 0.0, true, "mask covers the earliest authored side-wall intersection")
	_add_check(checks, is_equal_approx(ContinuityType.transition_mask_alpha(1.0), 1.0), true, "environment swap is fully hidden at the endpoint")


static func _test_connected_origin(checks: Array[Dictionary]) -> void:
	var from_pose := ContinuityType.pose_from_sample({
		"position": Vector3(2.0, 1.7, -4.0),
		"look_target": Vector3(1.0, 1.2, -12.0),
	})
	var next_local := ContinuityType.pose_from_sample({
		"position": Vector3(-0.5, 2.4, 8.0),
		"look_target": Vector3(0.0, 1.2, -9.0),
	})
	var direction := Vector3(-0.2, -0.05, -1.0).normalized()
	var origin := ContinuityType.connected_environment_origin(from_pose, next_local, direction, 9.0)
	var translated := ContinuityType.offset_pose(next_local, origin)
	var from_position := from_pose.get("position", Vector3.ZERO) as Vector3
	var translated_position := translated.get("position", Vector3.ZERO) as Vector3
	var planar_travel := Vector2(translated_position.x - from_position.x, translated_position.z - from_position.z)
	var planar_direction := Vector3(direction.x, 0.0, direction.z).normalized()
	var actual_planar_direction := Vector3(planar_travel.x, 0.0, planar_travel.y).normalized()
	_add_check(checks, is_equal_approx(planar_travel.length(), 9.0), true, "connected chunk entry owns the authored planar travel distance")
	_add_check(checks, actual_planar_direction.dot(planar_direction) > 0.9999, true, "connected chunk continues in the actual planar rail direction")
	_add_check(checks, is_zero_approx(origin.y), true, "connected chunks preserve the global floor datum")
	_add_check(checks, (translated.get("forward", Vector3.ZERO) as Vector3).dot(next_local.get("forward", Vector3.ZERO) as Vector3) > 0.9999, true, "translating a chunk never changes its entry orientation")
	var curved_node := {
		"rail": {"from": [0.0, 1.7, 8.0], "x": 2.0, "y": 2.1, "z": -8.0, "sweep": 3.5},
	}
	var curved_short := ContinuityType.node_exit_motion_direction(curved_node, 2.0, {}, Vector3.BACK)
	var curved_long := ContinuityType.node_exit_motion_direction(curved_node, 200.0, {}, Vector3.BACK)
	_add_check(checks, curved_short.is_equal_approx(curved_long), true, "rail exit tangent is geometric and independent of pacing duration")
	_add_check(checks, is_equal_approx(curved_short.length(), 1.0) and is_zero_approx(curved_short.y), true, "curved rail exit tangent is normalized on XZ")
	var points_node := {
		"rail": {
			"from": [0.0, 1.7, 8.0],
			"x": 0.0,
			"y": 1.7,
			"z": -12.0,
			"points": [
				{"at": 0.5, "position": [1.0, 2.0, -2.0], "look": [0.0, 1.2, -8.0]},
				{"at": 0.9, "position": [4.0, 2.5, -7.0], "look": [0.0, 1.2, -10.0]},
				{"at": 1.0, "position": [4.0, 2.5, -7.0], "look": [0.0, 1.2, -10.0]},
			],
		},
	}
	var points_direction := ContinuityType.node_exit_motion_direction(points_node, 12.0, {}, Vector3.BACK)
	var expected_points_direction := Vector3(3.0, 0.0, -5.0).normalized()
	_add_check(checks, points_direction.dot(expected_points_direction) > 0.9999, true, "authored-point rail uses its last distinct geometric segment")
	var boss_direction := ContinuityType.node_exit_motion_direction({"type": "boss"}, 0.0, {}, Vector3(0.2, -0.6, -1.0))
	_add_check(checks, is_equal_approx(boss_direction.length(), 1.0) and is_zero_approx(boss_direction.y), true, "static boss fallback is normalized on XZ")


static func _test_transition_clamping_and_degenerate_motion(checks: Array[Dictionary]) -> void:
	var from_pose := ContinuityType.pose_from_sample({"position": Vector3(0.0, 1.7, 0.0), "look_target": Vector3(0.0, 1.7, -8.0)})
	var to_pose := ContinuityType.pose_from_sample({"position": Vector3(0.0, 1.7, -9.0), "look_target": Vector3(0.0, 1.7, -17.0)})
	var transition := ContinuityType.transition_between(from_pose, to_pose, 1.5)
	_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(transition, -1.0), from_pose), true, "negative elapsed time clamps to the start pose")
	_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(transition, 100.0), to_pose), true, "elapsed time beyond duration clamps to the end pose")
	_add_check(checks, is_equal_approx(ContinuityType.transition_mask_alpha(-1.0), 0.0), true, "mask alpha clamps below zero")
	_add_check(checks, is_equal_approx(ContinuityType.transition_mask_alpha(2.0), 1.0), true, "mask alpha clamps above one")
	var stationary := ContinuityType.transition_between(from_pose, from_pose, 0.0)
	var midpoint := ContinuityType.sample_transition(stationary, 0.0005)
	_add_check(checks, (midpoint.get("position", Vector3.ZERO) as Vector3).is_finite(), true, "zero-length connector remains finite")
	_add_check(checks, ContinuityType.poses_match(midpoint, from_pose), true, "zero-length connector preserves its pose")
	var vertical := ContinuityType.connected_environment_origin(from_pose, to_pose, Vector3.UP, 9.0)
	_add_check(checks, is_zero_approx(vertical.y), true, "vertical exit direction never creates accumulated floor drift")
	_add_check(checks, vertical.is_finite(), true, "vertical exit fallback produces finite connected origin")


static func _test_every_campaign_edge(checks: Array[Dictionary]) -> void:
	var campaign := _load_campaign()
	var policy := TimingType.campaign_policy(campaign)
	var edge_count := 0
	var node_count := 0
	for chapter_value: Variant in campaign.get("chapters", []) as Array:
		var chapter := chapter_value as Dictionary
		var nodes_by_id: Dictionary = {}
		for node_value: Variant in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			nodes_by_id[str(node.get("id", ""))] = node
			node_count += 1
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
				var exit_direction := ContinuityType.node_exit_motion_direction(node, from_duration, policy, from_pose.get("forward", Vector3.FORWARD) as Vector3)
				var connector_distance := TimingType.connector_distance(node, policy)
				var next_origin := ContinuityType.connected_environment_origin(from_pose, to_pose, exit_direction, connector_distance)
				var connected_to_pose := ContinuityType.offset_pose(to_pose, next_origin)
				var connector := ContinuityType.transition_between(from_pose, connected_to_pose, 1.35, str(node_id_value), next_id)
				_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(connector, 0.0), from_pose), true, "edge starts without a pose jump: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, ContinuityType.poses_match(ContinuityType.sample_transition(connector, 1.35), connected_to_pose), true, "edge reaches the translated next entry exactly: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, _transition_is_monotonic(connector, 1.35), true, "edge never reverses or overshoots: %s -> %s" % [str(node_id_value), next_id])
				var from_position := from_pose.get("position", Vector3.ZERO) as Vector3
				var connected_position := connected_to_pose.get("position", Vector3.ZERO) as Vector3
				var planar_delta := Vector2(connected_position.x - from_position.x, connected_position.z - from_position.z)
				var connected_direction := Vector3(planar_delta.x, 0.0, planar_delta.y).normalized()
				_add_check(checks, is_equal_approx(planar_delta.length(), connector_distance), true, "edge owns a real planar connector distance: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, connected_direction.dot(exit_direction) > 0.9999, true, "edge continues along planar rail motion: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, is_zero_approx(exit_direction.y), true, "edge exit direction never drifts the floor datum: %s -> %s" % [str(node_id_value), next_id])
				_add_check(checks, is_zero_approx(next_origin.y), true, "edge environment origin remains on the global floor datum: %s -> %s" % [str(node_id_value), next_id])
				edge_count += 1
	_add_check(checks, node_count == 43 and edge_count == 49, true, "continuity audit covers all 43 nodes and 49 encoded spatial edges exactly")


static func _transition_is_monotonic(transition: Dictionary, duration: float) -> bool:
	var start := ContinuityType.sample_transition(transition, 0.0).get("position", Vector3.ZERO) as Vector3
	var finish := ContinuityType.sample_transition(transition, duration).get("position", start) as Vector3
	var displacement := finish - start
	var distance := displacement.length()
	if distance <= 0.0001:
		return true
	var direction := displacement / distance
	var previous_projection := -0.0001
	for sample_index in 65:
		var elapsed := duration * float(sample_index) / 64.0
		var position := ContinuityType.sample_transition(transition, elapsed).get("position", start) as Vector3
		var projection := (position - start).dot(direction)
		if projection < -0.0001 or projection > distance + 0.0001:
			return false
		if projection + 0.0001 < previous_projection:
			return false
		previous_projection = projection
	return true


static func _load_campaign() -> Dictionary:
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
