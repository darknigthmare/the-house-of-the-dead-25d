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
	var bonus_pickups_ok: bool = await _exercise_bonus_pickups(game)
	if not bonus_pickups_ok:
		push_error("SMOKE: bonus pickups are hidden, hostile, duplicated, or award the wrong value")
		quit(1)
		return
	var attack_readability_ok: bool = await _exercise_attack_readability(game)
	if not attack_readability_ok:
		push_error("SMOKE: an attack bypassed telegraph, visibility, travel, or physical contact")
		quit(1)
		return
	print("SMOKE OFFSCREEN RELOAD: 6")
	print("SMOKE INDEPENDENT GAMEPAD AIM: OK")
	print("SMOKE PROJECTILE RULES: OK")
	print("SMOKE BONUS PICKUPS: OK")
	print("SMOKE ATTACK READABILITY: OK")
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


func _exercise_bonus_pickups(game: Node) -> bool:
	game.set_process(false)
	game.set_physics_process(false)
	game.call("_clear_actors")
	await process_frame
	var players := game.get("players") as Array
	var camera := game.get("camera_3d") as Camera3D
	if players.is_empty() or camera == null:
		game.set_process(true)
		game.set_physics_process(true)
		return false
	players[0].active = true
	players[0].score = 0
	players[0].lives = 3
	var camera_forward := -camera.global_transform.basis.z.normalized()
	var pickup_center := camera.global_position + camera_forward * 6.0
	pickup_center.y = 0.8
	var active := game.get("active_actors") as Array
	var pickups: Array[Node3D] = []
	var pickup_types: Array[String] = ["medal", "frog", "life"]
	for index in pickup_types.size():
		var position := pickup_center + Vector3((float(index) - 1.0) * 1.2, 0.0, 0.0)
		game.call("_spawn_pickup", {
			"id": "smoke_%s" % pickup_types[index],
			"pickup": pickup_types[index],
			"position": [position.x, position.y, position.z],
		})
		if active.is_empty():
			game.set_process(true)
			game.set_physics_process(true)
			return false
		pickups.append(active[active.size() - 1] as Node3D)
	var ok := not bool(game.call("_has_active_hostiles"))
	for pickup in pickups:
		var sprite := pickup.get_node_or_null("Sprite3D") as Sprite3D
		ok = ok and str(pickup.get_meta("role", "")) == "pickup"
		ok = ok and sprite != null and sprite.texture != null and sprite.visible
		ok = ok and bool(game.call("_actor_is_attack_visible", pickup))

	var medal_score_before := int(players[0].score)
	game.call("_damage_actor", pickups[0], "body", 1.0, 0)
	var medal_score_after := int(players[0].score)
	game.call("_damage_actor", pickups[0], "body", 1.0, 0)
	ok = ok and medal_score_after == medal_score_before + 200
	ok = ok and int(players[0].score) == medal_score_after and bool(pickups[0].get_meta("dead", false)) and not active.has(pickups[0])

	var frog_score_before := int(players[0].score)
	game.call("_damage_actor", pickups[1], "body", 1.0, 0)
	var frog_score_after := int(players[0].score)
	game.call("_damage_actor", pickups[1], "body", 1.0, 0)
	ok = ok and frog_score_after == frog_score_before + 1000
	ok = ok and int(players[0].score) == frog_score_after and bool(pickups[1].get_meta("dead", false)) and not active.has(pickups[1])

	var lives_before := int(players[0].lives)
	game.call("_damage_actor", pickups[2], "body", 1.0, 0)
	var lives_after := int(players[0].lives)
	game.call("_damage_actor", pickups[2], "body", 1.0, 0)
	ok = ok and lives_after == lives_before + 1
	ok = ok and int(players[0].lives) == lives_after and bool(pickups[2].get_meta("dead", false)) and not active.has(pickups[2])
	ok = ok and not bool(game.call("_has_active_hostiles"))
	game.call("_clear_actors")
	game.set_process(true)
	game.set_physics_process(true)
	return ok


func _exercise_attack_readability(game: Node) -> bool:
	game.set_process(false)
	game.set_physics_process(false)
	game.call("_clear_actors")
	await process_frame
	var players := game.get("players") as Array
	var camera := game.get("camera_3d") as Camera3D
	if players.is_empty() or camera == null:
		game.set_process(true)
		game.set_physics_process(true)
		return false
	players[0].active = true
	players[0].lives = 12
	var camera_forward := -camera.global_transform.basis.z.normalized()
	var far_position := camera.global_position + camera_forward * 8.0
	far_position.y = 0.0
	var close_position := camera.global_position + camera_forward * 1.5
	close_position.y = 0.0
	var ok := true

	# Even a forged completed telegraph cannot make a distant melee actor hit.
	var far_melee := game.call("_spawn_enemy", {
		"actor": "sam_a1",
		"position": [far_position.x, far_position.y, far_position.z],
		"attack_delay": 0.0,
	}) as Node3D
	far_melee.set_meta("attack_telegraph_started", true)
	far_melee.set_meta("attack_telegraph_complete", true)
	var lives_before := int(players[0].lives)
	ok = ok and not bool(game.call("_actor_attack", far_melee)) and int(players[0].lives) == lives_before

	# Matching X/Z is not contact when the attacker is still above the player.
	var high_position := close_position + Vector3.UP * 5.0
	var high_melee := game.call("_spawn_enemy", {
		"actor": "sam_a1",
		"position": [high_position.x, high_position.y, high_position.z],
		"attack_delay": 0.0,
	}) as Node3D
	high_melee.set_meta("ground_y", high_position.y)
	high_melee.set_meta("attack_telegraph_started", true)
	high_melee.set_meta("attack_telegraph_complete", true)
	ok = ok and not bool(game.call("_actor_attack", high_melee)) and int(players[0].lives) == lives_before

	# Contact alone is harmless until a visible telegraph has completed.
	var close_melee := game.call("_spawn_enemy", {
		"actor": "sam_a1",
		"position": [close_position.x, close_position.y, close_position.z],
		"attack_delay": 0.0,
	}) as Node3D
	ok = ok and not bool(game.call("_actor_attack", close_melee)) and int(players[0].lives) == lives_before
	ok = ok and not bool(game.call("_update_enemy_attack", close_melee, 0.0))
	ok = ok and bool(close_melee.get_meta("attack_telegraph_started", false)) and int(players[0].lives) == lives_before
	var commit_age := float(close_melee.get_meta("attack_commit_age", 1.0))
	ok = ok and bool(game.call("_update_enemy_attack", close_melee, commit_age + 0.01))
	ok = ok and int(players[0].lives) == lives_before - 1

	# Hiding the billboard invalidates a melee strike even at contact range.
	var hidden_melee := game.call("_spawn_enemy", {
		"actor": "sam_a1",
		"position": [close_position.x, close_position.y, close_position.z],
		"attack_delay": 0.0,
	}) as Node3D
	var hidden_sprite := hidden_melee.get_node_or_null("Sprite3D") as Sprite3D
	hidden_melee.set_meta("attack_telegraph_started", true)
	hidden_melee.set_meta("attack_telegraph_complete", true)
	hidden_sprite.visible = false
	lives_before = int(players[0].lives)
	ok = ok and not bool(game.call("_actor_attack", hidden_melee)) and int(players[0].lives) == lives_before

	# A runtime projectile must be destructible before it can even launch.
	var projectile_owner := game.call("_spawn_enemy", {
		"actor": "cyril_a3",
		"position": [far_position.x, far_position.y, far_position.z],
		"attack_delay": 0.0,
	}) as Node3D
	projectile_owner.set_meta("attack_telegraph_started", true)
	projectile_owner.set_meta("attack_telegraph_complete", true)
	projectile_owner.set_meta("projectile_destructible", false)
	ok = ok and game.call("_spawn_enemy_projectile", projectile_owner) == null
	projectile_owner.set_meta("projectile_destructible", true)
	var projectile := game.call("_spawn_enemy_projectile", projectile_owner) as Node3D
	ok = ok and projectile != null
	if projectile != null:
		var projectile_sprite := projectile.get_node_or_null("Sprite3D") as Sprite3D
		var visual_scale := float(projectile.get_meta("visual_scale", 1.0))
		projectile.global_position = camera.global_position + camera_forward * 0.65 - Vector3.UP * (0.85 * visual_scale)
		lives_before = int(players[0].lives)
		projectile.set_meta("seen_by_camera", true)
		projectile.set_meta("visible_travel_distance", 0.0)
		ok = ok and not bool(game.call("_resolve_projectile_contact", projectile)) and int(players[0].lives) == lives_before
		projectile.set_meta("visible_travel_distance", float(projectile.get_meta("minimum_visible_travel", 3.0)) + 0.1)
		projectile_sprite.visible = false
		ok = ok and not bool(game.call("_resolve_projectile_contact", projectile)) and int(players[0].lives) == lives_before
		projectile_sprite.visible = true
		ok = ok and bool(game.call("_resolve_projectile_contact", projectile)) and int(players[0].lives) == lives_before - 1

	# A rescue deadline cannot kill by itself. It may only accelerate a real,
	# visible assailant, so an empty encounter leaves the civilian alive.
	game.call("_clear_actors")
	game.set("state", "node")
	game.set("node_elapsed", 10.0)
	var unthreatened_position := far_position + Vector3(1.0, 0.0, 0.0)
	game.call("_spawn_civilian", {
		"actor_id": "scientist_male_blue",
		"position": [unthreatened_position.x, unthreatened_position.y, unthreatened_position.z],
		"deadline": -1.0,
	})
	var unthreatened_civilian := game.get("active_civilian") as Node3D
	game.call("_update_actors", 0.0)
	ok = ok and is_instance_valid(unthreatened_civilian)
	ok = ok and not bool(unthreatened_civilian.get_meta("dead", false))
	ok = ok and bool(unthreatened_civilian.get_meta("deadline_expired", false))

	# A civilian-targeted melee enemy must physically approach, telegraph in
	# view, and reach its 3D contact range before the rescue can fail.
	game.call("_clear_actors")
	game.set("node_elapsed", 0.0)
	var melee_civilian_position := far_position + Vector3(1.4, 0.0, 0.0)
	game.call("_spawn_civilian", {
		"actor_id": "scientist_male_gray",
		"position": [melee_civilian_position.x, melee_civilian_position.y, melee_civilian_position.z],
		"deadline": 99.0,
	})
	var melee_civilian := game.get("active_civilian") as Node3D
	var civilian_attacker_position := far_position + Vector3(-2.8, 0.0, -0.4)
	var civilian_attacker := game.call("_spawn_enemy", {
		"actor": "sam_a1",
		"position": [civilian_attacker_position.x, civilian_attacker_position.y, civilian_attacker_position.z],
		"attack_delay": 0.0,
		"targets_civilian": true,
	}) as Node3D
	var melee_steps := 0
	while is_instance_valid(melee_civilian) and not bool(melee_civilian.get_meta("dead", false)) and melee_steps < 240:
		game.call("_update_actors", 0.025)
		melee_steps += 1
	ok = ok and bool(melee_civilian.get_meta("dead", false))
	ok = ok and int(civilian_attacker.get_meta("attacks", 0)) == 1

	# Civilian-targeted projectiles must travel toward the civilian in full 3D,
	# remain shootable, and be the actual physical cause of a failed rescue.
	game.call("_clear_actors")
	game.set("node_elapsed", 0.0)
	var civilian_position := far_position + Vector3(1.6, 0.0, 0.0)
	game.call("_spawn_civilian", {
		"actor_id": "scientist_female_lab",
		"position": [civilian_position.x, civilian_position.y, civilian_position.z],
		"deadline": 99.0,
	})
	var threatened_civilian := game.get("active_civilian") as Node3D
	var thrower_position := far_position + Vector3(-1.8, 0.0, -0.4)
	var civilian_thrower := game.call("_spawn_enemy", {
		"actor": "cyril_a3",
		"position": [thrower_position.x, thrower_position.y, thrower_position.z],
		"attack_delay": 999.0,
		"targets_civilian": true,
	}) as Node3D
	civilian_thrower.set_meta("attack_telegraph_started", true)
	civilian_thrower.set_meta("attack_telegraph_complete", true)
	var civilian_projectile := game.call("_spawn_enemy_projectile", civilian_thrower) as Node3D
	ok = ok and civilian_projectile != null
	if civilian_projectile != null:
		var expected_direction := (threatened_civilian.global_position + Vector3.UP - civilian_projectile.global_position).normalized()
		var actual_direction: Vector3 = civilian_projectile.get_meta("travel_direction", Vector3.ZERO) as Vector3
		ok = ok and actual_direction.dot(expected_direction) > 0.999
		ok = ok and bool(civilian_projectile.get_meta("destructible", false))
		var safety_steps := 0
		while is_instance_valid(threatened_civilian) and not bool(threatened_civilian.get_meta("dead", false)) and safety_steps < 160:
			game.call("_update_actors", 0.025)
			safety_steps += 1
		ok = ok and bool(threatened_civilian.get_meta("dead", false))
		ok = ok and bool(civilian_projectile.get_meta("seen_by_camera", false))
		ok = ok and float(civilian_projectile.get_meta("visible_travel_distance", 0.0)) >= float(civilian_projectile.get_meta("minimum_visible_travel", 0.5))

	# Once a civilian is rescued, a projectile already aimed at that civilian
	# dissipates at its original target instead of silently retargeting a player.
	game.call("_clear_actors")
	game.set("node_elapsed", 0.0)
	game.call("_spawn_civilian", {
		"actor_id": "scientist_male_blue",
		"position": [civilian_position.x, civilian_position.y, civilian_position.z],
		"deadline": 99.0,
	})
	var saved_civilian := game.get("active_civilian") as Node3D
	var diverted_thrower := game.call("_spawn_enemy", {
		"actor": "cyril_a3",
		"position": [thrower_position.x, thrower_position.y, thrower_position.z],
		"attack_delay": 999.0,
		"targets_civilian": true,
	}) as Node3D
	diverted_thrower.set_meta("attack_telegraph_started", true)
	diverted_thrower.set_meta("attack_telegraph_complete", true)
	var diverted_projectile := game.call("_spawn_enemy_projectile", diverted_thrower) as Node3D
	ok = ok and diverted_projectile != null
	game.call("_rescue_civilian", saved_civilian)
	lives_before = int(players[0].lives)
	if diverted_projectile != null:
		var saved_target: Vector3 = diverted_projectile.get_meta("target_position", diverted_projectile.global_position) as Vector3
		diverted_projectile.global_position = saved_target
		diverted_projectile.set_meta("seen_by_camera", true)
		diverted_projectile.set_meta("visible_travel_distance", float(diverted_projectile.get_meta("minimum_visible_travel", 0.5)) + 0.1)
		var diverted_sprite := diverted_projectile.get_node_or_null("Sprite3D") as Sprite3D
		diverted_sprite.visible = true
		ok = ok and not bool(game.call("_resolve_projectile_contact", diverted_projectile))
		ok = ok and int(players[0].lives) == lives_before
		ok = ok and bool(saved_civilian.get_meta("rescued", false))
		ok = ok and not bool(saved_civilian.get_meta("dead", false))
		ok = ok and bool(diverted_projectile.get_meta("dead", false))

	# Chariot is also forbidden from damaging at its home position; its visible
	# lunge must reach the camera contact radius first.
	game.call("_clear_actors")
	game.call("_start_boss", "chariot")
	var boss := game.get("current_boss") as Node3D
	boss.set_meta("attack_telegraph_started", true)
	boss.set_meta("attack_telegraph_complete", true)
	lives_before = int(players[0].lives)
	ok = ok and not bool(game.call("_boss_attack", "chariot")) and int(players[0].lives) == lives_before
	boss.position = game.call("_boss_melee_contact_position", boss.position) as Vector3
	ok = ok and bool(game.call("_boss_attack", "chariot")) and int(players[0].lives) == lives_before - 1

	# Regression: the former final-runtime shortcut damaged any boss-support
	# enemy crossing a fixed Z coordinate, even if it was hidden and had neither
	# a completed telegraph nor contact. That position alone must stay harmless.
	game.call("_clear_actors")
	var boss_support := game.call("_spawn_enemy", {
		"actor": "mutant_bat",
		"position": [0.0, 0.0, 2.3],
		"attack_delay": 999.0,
	}) as Node3D
	var support_sprite := boss_support.get_node_or_null("Sprite3D") as Sprite3D
	support_sprite.visible = false
	game.set("state", "boss")
	lives_before = int(players[0].lives)
	game.call("_update_actors", 0.0)
	ok = ok and int(players[0].lives) == lives_before
	ok = ok and not bool(boss_support.get_meta("dead", false))

	game.call("_clear_actors")
	await process_frame
	await process_frame
	await create_timer(0.05).timeout
	game.set_process(true)
	game.set_physics_process(true)
	return ok
