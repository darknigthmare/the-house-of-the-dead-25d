extends RefCounted

const PolicyType := preload("res://src/rail/route_outcome_policy.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	_add_check(checks, file != null, true, "campaign timeline opens for route outcome tests")
	if file == null:
		return checks
	var payload := JSON.parse_string(file.get_as_text()) as Dictionary
	var foyer := _find_node(payload, "foyer_choice")
	var hatch := _find_node(payload, "chain_plate")
	var elevator := _find_node(payload, "elevator_switch")
	var rescue := _find_node(payload, "garden_rescue")
	var wall_impact := _find_node(payload, "wall_passage_impact")
	var painting_impact := _find_node(payload, "painting_corridor_impact")
	var steel_doors := _find_node(payload, "steel_door_choice")
	_add_check(checks, not foyer.is_empty(), true, "foyer route node resolves")
	_add_check(checks, not hatch.is_empty(), true, "chain-plate route node resolves")
	_add_check(checks, not elevator.is_empty(), true, "elevator route node resolves")
	_add_check(checks, not rescue.is_empty(), true, "civilian-only route node resolves")
	_add_check(checks, not wall_impact.is_empty(), true, "wall-passage impact branch resolves")
	_add_check(checks, not painting_impact.is_empty(), true, "portrait-corridor impact branch resolves")
	_add_check(checks, not steel_doors.is_empty(), true, "two-door target branch resolves")
	_add_check(checks, PolicyType.branch_succeeded(foyer, true, ""), false, "saving the foyer scientist cannot destroy the lock")
	_add_check(checks, PolicyType.branch_succeeded(foyer, false, "c01_foyer_door_lock"), true, "destroyed foyer lock keeps the upper route after a civilian loss")
	_add_check(checks, PolicyType.branch_succeeded(hatch, true, "wrong_breakable"), false, "wrong object cannot open the chained hatch")
	_add_check(checks, PolicyType.branch_succeeded(hatch, false, "c02_chained_hatch_plate"), true, "destroyed hatch plate selects the underground route")
	_add_check(checks, PolicyType.branch_succeeded(elevator, true, ""), false, "civilian state cannot select the left elevator")
	_add_check(checks, PolicyType.branch_succeeded(elevator, false, "c03_elevator_route_switch"), true, "destroyed elevator switch selects the left elevator")
	_add_check(checks, PolicyType.branch_succeeded(rescue, true, ""), true, "civilian-only branch preserves rescue success")
	_add_check(checks, PolicyType.branch_succeeded(rescue, false, ""), false, "civilian-only branch preserves rescue failure")
	return checks
	var avoided_context := PolicyType.initial_context(wall_impact)
	_add_check(checks, PolicyType.branch_succeeded(wall_impact, false, "", avoided_context), true, "wall passage stays high when no enemy impact was received")
	_add_check(checks, PolicyType.accepts_visible_enemy_impact(wall_impact, "enemy_melee"), true, "wall branch accepts a visible melee contact")
	_add_check(checks, PolicyType.accepts_visible_enemy_impact(painting_impact, "enemy_projectile"), true, "portrait branch accepts a visible projectile contact")
	_add_check(checks, PolicyType.accepts_visible_enemy_impact(wall_impact, "civilian"), false, "civilian penalty cannot trigger a fall route")
	var hit_context := PolicyType.initial_context(wall_impact)
	hit_context["visible_enemy_impact_received"] = true
	hit_context["visible_enemy_impact_source"] = "enemy_melee"
	_add_check(checks, PolicyType.branch_succeeded(wall_impact, true, "", hit_context), false, "wall passage takes the low route only after enemy contact")
	_add_check(checks, PolicyType.branch_succeeded(painting_impact, true, "", hit_context), false, "portrait corridor takes the low route only after enemy contact")
	var door_context := PolicyType.initial_context(steel_doors)
	_add_check(checks, PolicyType.route_is_resolved(steel_doors, door_context), false, "door choice cannot auto-complete before a target is shot")
	door_context["selected_route_target_id"] = "c03_steel_door_upper"
	_add_check(checks, PolicyType.route_is_resolved(steel_doors, door_context), true, "upper steel-door target resolves the choice")
	_add_check(checks, PolicyType.branch_succeeded(steel_doors, false, "", door_context), true, "upper target selects the upper route")
	door_context["selected_route_target_id"] = "c03_steel_door_lower"
	_add_check(checks, PolicyType.branch_succeeded(steel_doors, true, "", door_context), false, "lower target selects the lower route")


static func _find_node(payload: Dictionary, node_id: String) -> Dictionary:
	for chapter_value in payload.get("chapters", []) as Array:
		var chapter := chapter_value as Dictionary
		for node_value in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			if str(node.get("id", "")) == node_id:
				return node
	return {}


static func _add_check(
	checks: Array[Dictionary],
	actual: Variant,
	expected: Variant,
	label: String
) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
