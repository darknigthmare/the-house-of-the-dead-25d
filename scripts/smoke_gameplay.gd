extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	var main := packed.instantiate()
	root.add_child(main)
	await process_frame
	main.call("_launch_game", "arcade", 2, false, 1)
	await create_timer(4.2).timeout
	var game := main.get("active_game") as Node
	if game == null:
		push_error("SMOKE: gameplay did not instantiate")
		quit(1)
		return
	print("SMOKE STATE: ", game.get("state"))
	print("SMOKE PLAYERS: ", (game.get("players") as Array).size())
	print("SMOKE CHAPTERS: ", (game.get("chapters") as Array).size())
	if str(game.get("state")) != "node" or (game.get("chapters") as Array).size() != 4:
		push_error("SMOKE: campaign did not enter chapter-one gameplay")
		quit(1)
		return
	game.call("_reload", 0)
	for _shot in 6:
		game.call("_attempt_shot", 0, Vector2(640.0, 360.0))
	await create_timer(0.3).timeout
	var players := game.get("players") as Array
	print("SMOKE AMMO AFTER SIX SHOTS: ", int(players[0].ammo))
	if int(players[0].ammo) != 0:
		push_error("SMOKE: runtime magazine did not empty after six shots")
		quit(1)
		return
	game.call("_attempt_shot", 0, Vector2(10.0, 10.0))
	if int(players[0].ammo) != 6:
		push_error("SMOKE: off-screen shot did not reload")
		quit(1)
		return
	if not _exercise_gamepad_aim(game, players):
		push_error("SMOKE: P1 gamepad aim was not independent")
		quit(1)
		return
	var projectile_rules_ok: bool = await _exercise_projectile_rules(game)
	if not projectile_rules_ok:
		push_error("SMOKE: projectile destructibility/hostile lifetime rules regressed")
		quit(1)
		return
	print("SMOKE OFFSCREEN RELOAD: 6")
	print("SMOKE INDEPENDENT GAMEPAD AIM: OK")
	print("SMOKE PROJECTILE RULES: OK")
	main.free()
	await process_frame
	await process_frame
	await create_timer(0.05).timeout
	quit(0)


func _exercise_gamepad_aim(game: Node, players: Array) -> bool:
	var p1_before := Vector2(players[0].cursor)
	var p2_before := Vector2(players[1].cursor)
	var event := InputEventJoypadMotion.new()
	event.device = 0
	event.axis = JOY_AXIS_RIGHT_X
	event.axis_value = 1.0
	game.call("_unhandled_input", event)
	game.call("_update_crosshairs", 0.1)
	return Vector2(players[0].cursor).x > p1_before.x and Vector2(players[1].cursor) == p2_before


func _exercise_projectile_rules(game: Node) -> bool:
	game.call("_clear_actors")
	await process_frame
	var active := game.get("active_actors") as Array
	var armored := Node3D.new()
	game.add_child(armored)
	armored.set_meta("role", "projectile")
	armored.set_meta("destructible", false)
	active.append(armored)
	game.call("_damage_actor", armored, "body", 1.0, 0)
	if bool(armored.get_meta("dead", false)) or not active.has(armored):
		return false
	if not bool(game.call("_has_active_hostiles")):
		return false
	active.erase(armored)
	armored.free()
	var vulnerable := Node3D.new()
	game.add_child(vulnerable)
	vulnerable.set_meta("role", "projectile")
	vulnerable.set_meta("destructible", true)
	active.append(vulnerable)
	game.call("_damage_actor", vulnerable, "body", 1.0, 0)
	var destroyed := bool(vulnerable.get_meta("dead", false)) and not active.has(vulnerable)
	var none_active := not bool(game.call("_has_active_hostiles"))
	vulnerable.free()
	return destroyed and none_active
