extends SceneTree

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/gameplay.tscn"
const RouteOutcomePolicyType := preload("res://src/rail/route_outcome_policy.gd")

var assertions: int = 0
var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_SCENE_PATH) as PackedScene
	_expect(packed != null, "gameplay scene loads")
	if packed == null:
		_finish(null)
		return
	var game := packed.instantiate()
	game.call("configure", {"mode": "arcade", "players": 1, "demo": false, "start_chapter": 1})
	root.add_child(game)
	await process_frame
	await process_frame
	game.set("paused_by_player", true)

	var chapters := game.get("chapters") as Array
	var wall_impact := _find_node(chapters, "wall_passage_impact")
	var painting_impact := _find_node(chapters, "painting_corridor_impact")
	var steel_choice := _find_node(chapters, "steel_door_choice")
	_expect(not wall_impact.is_empty(), "wall-passage impact scene is playable data")
	_expect(not painting_impact.is_empty(), "portrait-corridor impact scene is playable data")
	_expect(not steel_choice.is_empty(), "steel-door choice scene is playable data")

	game.set("current_node", wall_impact)
	game.set("current_node_id", "wall_passage_impact")
	game.set("state", "node")
	game.set("route_condition_context", RouteOutcomePolicyType.initial_context(wall_impact))
	var players := game.get("players") as Array[Dictionary]
	players[0].lives = 5
	game.set("players", players)
	game.call("_damage_player", 0, 1, "civilian", false)
	var context := game.get("route_condition_context") as Dictionary
	_expect(not bool(context.get("visible_enemy_impact_received", false)), "civilian damage cannot fake the wall fall trigger")
	game.call("_damage_player", 0, 1, "enemy_melee", false)
	context = game.get("route_condition_context") as Dictionary
	_expect(bool(context.get("visible_enemy_impact_received", false)), "actual visible enemy melee contact records the wall fall trigger")
	_expect(str(context.get("visible_enemy_impact_source", "")) == "enemy_melee", "wall fall records its physical attack source")
	_expect(not RouteOutcomePolicyType.branch_succeeded(wall_impact, true, "", context), "recorded melee impact selects the wall lower route")

	game.set("current_node", painting_impact)
	game.set("current_node_id", "painting_corridor_impact")
	game.set("route_condition_context", RouteOutcomePolicyType.initial_context(painting_impact))
	game.call("_damage_player", 0, 1, "enemy_projectile", false)
	context = game.get("route_condition_context") as Dictionary
	_expect(str(context.get("visible_enemy_impact_source", "")) == "enemy_projectile", "visible projectile contact records the portrait-floor trigger")
	_expect(not RouteOutcomePolicyType.branch_succeeded(painting_impact, true, "", context), "recorded projectile impact selects the portrait lower route")

	var chapter_three := _find_chapter(chapters, "chapter_03")
	game.set("current_chapter", chapter_three)
	game.call("_enter_node", "steel_door_choice")
	var targets := _route_targets(game.get("active_actors") as Array[Node3D])
	_expect(targets.size() == 2, "steel-door scene spawns two independent shootable targets")
	_expect(targets.has("c03_steel_door_upper") and targets.has("c03_steel_door_lower"), "both upper and lower steel-door targets are present")
	if targets.size() == 2:
		var upper := targets.get("c03_steel_door_upper") as Node3D
		var lower := targets.get("c03_steel_door_lower") as Node3D
		var upper_sprite := upper.get_node_or_null("Sprite3D") as Sprite3D
		var lower_sprite := lower.get_node_or_null("Sprite3D") as Sprite3D
		_expect(upper_sprite != null and upper_sprite.texture != null, "upper steel door has a real visible texture")
		_expect(lower_sprite != null and lower_sprite.texture != null, "lower steel door has a real visible texture")
		_expect(upper.position.x < 0.0 and lower.position.x > 0.0, "steel doors occupy distinct visible sides of the chamber")
		_expect(not RouteOutcomePolicyType.route_is_resolved(steel_choice, game.get("route_condition_context") as Dictionary), "door chamber waits for a physical target selection")
		game.call("_damage_actor", lower, "body", 1.0, 0)
		context = game.get("route_condition_context") as Dictionary
		_expect(str(context.get("selected_route_target_id", "")) == "c03_steel_door_lower", "shooting the lower door records the lower target")
		_expect(not RouteOutcomePolicyType.branch_succeeded(steel_choice, true, "", context), "lower door target selects the lower route")

	game.call("_enter_node", "steel_door_choice")
	targets = _route_targets(game.get("active_actors") as Array[Node3D])
	if targets.has("c03_steel_door_upper") and targets.has("c03_steel_door_lower"):
		var upper := targets.get("c03_steel_door_upper") as Node3D
		var lower := targets.get("c03_steel_door_lower") as Node3D
		game.call("_damage_actor", upper, "body", 1.0, 0)
		game.call("_damage_actor", lower, "body", 1.0, 0)
		context = game.get("route_condition_context") as Dictionary
		_expect(str(context.get("selected_route_target_id", "")) == "c03_steel_door_upper", "first destroyed door locks the route choice deterministically")
		_expect(RouteOutcomePolicyType.branch_succeeded(steel_choice, false, "", context), "upper door target selects the upper route")

	_finish(game)


func _find_node(chapters: Array, node_id: String) -> Dictionary:
	for chapter_value: Variant in chapters:
		var chapter := chapter_value as Dictionary
		for node_value: Variant in chapter.get("nodes", []) as Array:
			var node := node_value as Dictionary
			if str(node.get("id", "")) == node_id:
				return node
	return {}


func _find_chapter(chapters: Array, chapter_id: String) -> Dictionary:
	for chapter_value: Variant in chapters:
		var chapter := chapter_value as Dictionary
		if str(chapter.get("id", "")) == chapter_id:
			return chapter
	return {}


func _route_targets(actors: Array[Node3D]) -> Dictionary:
	var targets: Dictionary = {}
	for actor: Node3D in actors:
		if not is_instance_valid(actor) or str(actor.get_meta("role", "")) != "breakable":
			continue
		var target_id := str(actor.get_meta("route_target_id", ""))
		if not target_id.is_empty():
			targets[target_id] = actor
	return targets


func _expect(condition: bool, label: String) -> void:
	assertions += 1
	if not condition:
		failures.append(label)


func _finish(game: Node) -> void:
	if is_instance_valid(game):
		game.free()
	if failures.is_empty():
		print("SMOKE ROUTE DECISIONS: OK (", assertions, " assertions)")
		quit(0)
		return
	for failure: String in failures:
		push_error("SMOKE ROUTE DECISIONS: %s" % failure)
	quit(1)
