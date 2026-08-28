extends RefCounted

const RouteGraphType := preload("res://src/rail/route_graph.gd")
const RouteConditionType := preload("res://src/rail/route_condition.gd")

const GRAPH_SPECS := [
	{
		"path": "res://data/routes/chapter_01_route_graph.tres",
		"entry": "garden_rescue",
		"connection_count": 19,
		"edges": [
			"garden_rescue->mansion_entrance",
			"garden_rescue->under_bridge",
			"mansion_entrance->foyer_choice",
			"under_bridge->foyer_choice",
			"foyer_choice->upper_stairs",
			"foyer_choice->ground_hall",
			"upper_stairs->wall_passage_impact",
			"ground_hall->painting_corridor_impact",
			"wall_passage_impact->wall_passage_high",
			"wall_passage_impact->wall_passage_fall",
			"wall_passage_high->sophie_antechamber",
			"wall_passage_fall->sophie_antechamber",
			"painting_corridor_impact->painting_gallery_high",
			"painting_corridor_impact->painting_floor_fall",
			"painting_gallery_high->sophie_antechamber",
			"painting_floor_fall->sophie_antechamber",
			"sophie_antechamber->sophie_corridor",
			"sophie_corridor->chariot_battle",
			"chariot_battle->chapter_complete",
		],
		"branches": [
			{
				"from": "garden_rescue",
				"first_context": {"scientist_saved": true, "scientist_lost": false},
				"first_to": "mansion_entrance",
				"second_context": {"scientist_saved": false, "scientist_lost": true},
				"second_to": "under_bridge",
			},
			{
				"from": "foyer_choice",
				"first_context": {"door_lock_destroyed": true, "door_lock_intact": false},
				"first_to": "upper_stairs",
				"second_context": {"door_lock_destroyed": false, "door_lock_intact": true},
				"second_to": "ground_hall",
			},
			{
				"from": "wall_passage_impact",
				"first_context": {"wall_impact_avoided": true, "wall_impact_received": false},
				"first_to": "wall_passage_high",
				"second_context": {"wall_impact_avoided": false, "wall_impact_received": true},
				"second_to": "wall_passage_fall",
			},
			{
				"from": "painting_corridor_impact",
				"first_context": {"painting_impact_avoided": true, "painting_impact_received": false},
				"first_to": "painting_gallery_high",
				"second_context": {"painting_impact_avoided": false, "painting_impact_received": true},
				"second_to": "painting_floor_fall",
			},
		],
	},
	{
		"path": "res://data/routes/chapter_02_route_graph.tres",
		"entry": "chain_plate",
		"connection_count": 12,
		"edges": [
			"chain_plate->underground_passage",
			"chain_plate->great_doors",
			"underground_passage->library_rescue",
			"great_doors->library_rescue",
			"library_rescue->raised_bridge",
			"library_rescue->lower_stairs",
			"raised_bridge->roof_approach",
			"lower_stairs->roof_approach",
			"roof_approach->corridor_cache",
			"corridor_cache->roof_rescue",
			"roof_rescue->hangedman_battle",
			"hangedman_battle->chapter_complete",
		],
		"branches": [
			{
				"from": "chain_plate",
				"first_context": {"hatch_opened": true, "hatch_missed": false},
				"first_to": "underground_passage",
				"second_context": {"hatch_opened": false, "hatch_missed": true},
				"second_to": "great_doors",
			},
			{
				"from": "library_rescue",
				"first_context": {"scientist_saved": true, "scientist_lost": false},
				"first_to": "raised_bridge",
				"second_context": {"scientist_saved": false, "scientist_lost": true},
				"second_to": "lower_stairs",
			},
		],
	},
	{
		"path": "res://data/routes/chapter_03_route_graph.tres",
		"entry": "elevator_switch",
		"connection_count": 14,
		"edges": [
			"elevator_switch->left_elevator",
			"elevator_switch->right_elevator",
			"left_elevator->back_attack_rescue",
			"right_elevator->back_attack_rescue",
			"back_attack_rescue->security_door",
			"back_attack_rescue->vent_key_route",
			"security_door->steel_door_choice",
			"vent_key_route->steel_door_choice",
			"steel_door_choice->steel_door_upper_route",
			"steel_door_choice->steel_door_lower_route",
			"steel_door_upper_route->curien_tunnel",
			"steel_door_lower_route->curien_tunnel",
			"curien_tunnel->hermit_battle",
			"hermit_battle->chapter_complete",
		],
		"branches": [
			{
				"from": "elevator_switch",
				"first_context": {"left_elevator_selected": true, "right_elevator_selected": false},
				"first_to": "left_elevator",
				"second_context": {"left_elevator_selected": false, "right_elevator_selected": true},
				"second_to": "right_elevator",
			},
			{
				"from": "back_attack_rescue",
				"first_context": {"scientist_saved": true, "scientist_lost": false},
				"first_to": "security_door",
				"second_context": {"scientist_saved": false, "scientist_lost": true},
				"second_to": "vent_key_route",
			},
			{
				"from": "steel_door_choice",
				"first_context": {"upper_steel_door_selected": true, "lower_steel_door_selected": false},
				"first_to": "steel_door_upper_route",
				"second_context": {"upper_steel_door_selected": false, "lower_steel_door_selected": true},
				"second_to": "steel_door_lower_route",
			},
		],
	},
	{
		"path": "res://data/routes/chapter_04_route_graph.tres",
		"entry": "chariot_rematch",
		"connection_count": 8,
		"edges": [
			"chariot_rematch->hangedman_rematch",
			"hangedman_rematch->bonus_gate",
			"bonus_gate->bonus_room",
			"bonus_gate->final_waves",
			"bonus_room->final_waves",
			"final_waves->curien_confrontation",
			"curien_confrontation->magician_battle",
			"magician_battle->chapter_complete",
		],
		"branches": [
			{
				"from": "bonus_gate",
				"first_context": {"all_scientists_saved": true, "scientist_rescue_incomplete": false},
				"first_to": "bonus_room",
				"second_context": {"all_scientists_saved": false, "scientist_rescue_incomplete": true},
				"second_to": "final_waves",
			},
		],
	},
]


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	for spec_value in GRAPH_SPECS:
		var spec := spec_value as Dictionary
		var path := str(spec.path)
		var resource := load(path)
		_add_check(checks, resource != null, true, "%s loads" % path)
		if resource == null:
			continue
		_add_check(checks, resource.get_script() == RouteGraphType, true, "%s uses RouteGraph" % path)
		_add_check(checks, str(resource.entry_segment_id), str(spec.entry), "%s entry" % path)
		var connections := resource.connections as Array
		_add_check(checks, connections.size(), int(spec.connection_count), "%s connection count" % path)
		var actual_edges: Array[String] = []
		for connection_value in connections:
			var connection := connection_value as Dictionary
			actual_edges.append("%s->%s" % [connection.get("from", ""), connection.get("to", "")])
		actual_edges.sort()
		var expected_edges: Array = (spec.edges as Array).duplicate()
		expected_edges.sort()
		_add_check(checks, ",".join(actual_edges), ",".join(expected_edges), "%s edge set" % path)
		for branch_value in spec.branches as Array:
			var branch := branch_value as Dictionary
			var from_id := StringName(str(branch.from))
			var outgoing := resource.get_connections_from(from_id) as Array[Dictionary]
			_add_check(checks, outgoing.size(), 2, "%s %s has two outputs" % [path, from_id])
			var priorities: Array[int] = []
			for connection in outgoing:
				priorities.append(int(connection.get("priority", 0)))
				var conditions := connection.get("conditions", []) as Array
				_add_check(checks, conditions.size(), 1, "%s %s output has one condition" % [path, from_id])
				if conditions.size() == 1:
					var condition = conditions[0]
					_add_check(checks, condition != null and condition.get_script() == RouteConditionType, true, "%s %s condition type" % [path, from_id])
					if condition != null:
						_add_check(checks, int(condition.comparison) in [5, 6], true, "%s %s condition is boolean" % [path, from_id])
			priorities.sort()
			_add_check(checks, priorities, [90, 100], "%s %s priorities" % [path, from_id])
			_add_check(
				checks,
				str(resource.resolve_next(from_id, branch.first_context as Dictionary)),
				str(branch.first_to),
				"%s %s first output" % [path, from_id]
			)
			_add_check(
				checks,
				str(resource.resolve_next(from_id, branch.second_context as Dictionary)),
				str(branch.second_to),
				"%s %s second output" % [path, from_id]
			)
	return checks


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
