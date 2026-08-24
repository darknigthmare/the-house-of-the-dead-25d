extends SceneTree

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var gameplay_scene := load("res://scenes/gameplay/gameplay.tscn") as PackedScene
	var game = gameplay_scene.instantiate()
	root.add_child(game)
	game.configure({"mode": "arcade", "players": 1, "demo": true})
	for frame in 4:
		await process_frame
	_check(game.sprite_atlas_library.actor_ids().size() == 38, "all dedicated identities resolve through the library")
	for alias_id in ["scientist", "sophie", "curien", "axe_creature"]:
		_check(game.sprite_atlas_library.has_actor(alias_id), "alias resolves: %s" % alias_id)

	var representatives := ["sam_a1", "devilon_f4", "mutant_bat", "dbr_scientist", "scientist_male_blue", "scientist_male_gray", "scientist_female_lab", "hangedman", "hermit", "magician"]
	for index in representatives.size():
		var actor_id: String = representatives[index]
		var actor: Node3D = game._create_actor(
			actor_id,
			Vector3(float(index) * 0.4, 0.0, -9.0),
			{"health": 3.0, "speed": 0.0, "scale": 1.0, "score": 80},
			"enemy"
		)
		var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
		_check(sprite != null and sprite.texture != null, "%s loads its dedicated texture" % actor_id)
		_check(sprite != null and sprite.hframes == 8 and sprite.vframes == 8, "%s uses an 8x8 Sprite3D" % actor_id)
		_check(sprite != null and not sprite.region_enabled, "%s has no legacy region rectangle" % actor_id)
		var hit_zone := actor.get_node_or_null("HitZone_head") as Area3D
		var hit_transform := hit_zone.transform if hit_zone != null else Transform3D.IDENTITY
		actor.set_meta("visual_forward", Vector3.FORWARD)
		for direction in 8:
			var angle := -float(direction) * TAU / 8.0
			game.camera_3d.global_position = actor.global_position + Vector3(sin(angle), 0.15, -cos(angle)) * 8.0
			game._apply_directional_sprite_frame(actor, 7)
			_check(sprite.frame == direction * 8 + 7, "%s direction %d selects its death cell" % [actor_id, direction])
		_check(hit_zone == null or hit_zone.transform == hit_transform, "%s direction changes leave hitboxes unchanged" % actor_id)
		game.active_actors.erase(actor)
		actor.queue_free()

	game.camera_3d.global_position = Vector3(0.0, 1.6, 0.0)
	var civilian: Node3D = game._create_actor("dbr_scientist", Vector3(0.0, 0.0, -8.0), {"health": 1.0, "speed": 0.0, "scale": 1.0, "score": 0}, "civilian")
	game.active_civilian = civilian
	game._kill_civilian(civilian, false)
	var civilian_sprite := civilian.get_node_or_null("Sprite3D") as Sprite3D
	_check(bool(civilian.get_meta("dead", false)), "civilian death reaches the shared death state")
	_check(int(civilian.get_meta("animation_state", -1)) == 7, "civilian death selects the death column")
	_check(civilian_sprite != null and civilian_sprite.frame % 8 == 7, "civilian death applies a directional death frame")
	_check(not game.active_actors.has(civilian), "dead civilian leaves the active actor list")
	await process_frame
	var civilian_zone := civilian.get_node_or_null("HitZone_body") as Area3D
	_check(civilian_zone == null or (not civilian_zone.monitorable and civilian_zone.collision_layer == 0), "dead civilian hit zone is disabled")

	var breakable: Node3D = game._create_actor("medal", Vector3(1.0, 0.0, -8.0), {"health": 1.0, "speed": 0.0, "scale": 1.0, "score": 200}, "breakable")
	var breakable_sprite := breakable.get_node_or_null("Sprite3D") as Sprite3D
	game._kill_actor(breakable, 0, false)
	_check(bool(breakable.get_meta("dead", false)), "breakable enters its death state")
	_check(breakable_sprite != null and breakable_sprite.frame == 0, "static breakable never receives a directional frame")
	_check(not game.active_actors.has(breakable), "destroyed breakable leaves the active actor list")

	game._spawn_story_actor("curien", Vector3(0.0, 0.0, -9.0), 1.0)
	_check(game.story_actors.size() == 1, "story actor is tracked for scene cleanup")
	game._clear_actors()
	_check(game.story_actors.is_empty(), "story actors are cleared with gameplay actors")

	game.queue_free()
	await process_frame
	if failures.is_empty():
		print("DIRECTIONAL SPRITE SMOKE OK: 38 bindings, 10 representatives, 8 directions, death and cleanup states.")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
