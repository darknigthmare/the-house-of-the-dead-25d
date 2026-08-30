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
		if actor_id == "sam_a1" and game.sprite_clip_library_v3.is_runtime_ready("sam_a1"):
			_check(sprite.has_meta("directional_clip_player_v3"), "Sam activates its complete atomic V3 clip player")
			_check(str(sprite.get_meta("v3_fallback_reason", "not_empty")) == "", "active Sam V3 exposes no fallback reason")
		elif actor_id != "sam_a1":
			_check(not sprite.has_meta("directional_clip_player_v3"), "%s remains on its verified V2 actor profile" % actor_id)
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

	# Exercise the active V3 state machine, not only static row selection.
	game.camera_3d.global_position = Vector3(0.0, 1.6, 0.0)
	var animated_sam: Node3D = game._create_actor(
		"sam_a1", Vector3(0.0, 0.0, -8.0),
		{"health": 3.0, "speed": 0.0, "scale": 1.0, "score": 80}, "enemy"
	)
	var v3_sprite := animated_sam.get_node_or_null("Sprite3D") as Sprite3D
	_check(v3_sprite != null and v3_sprite.has_meta("directional_clip_player_v3"), "Sam runtime binds the V3 player")
	var v3_player = v3_sprite.get_meta("directional_clip_player_v3")
	var base_pixel_size: float = v3_sprite.pixel_size
	_check(str(v3_player.current_clip_id) == "idle", "Sam starts on the authored idle clip")
	animated_sam.set_meta("visual_motion", 1.0)
	game._animate_actor(animated_sam, 0.0)
	_check(str(v3_player.current_clip_id) == "locomotion", "movement selects the authored locomotion clip")
	_check(is_equal_approx(v3_sprite.pixel_size, base_pixel_size * 1.0282), "locomotion applies non-cumulative actor-level proportion calibration")
	animated_sam.set_meta("visual_motion", 0.0)
	animated_sam.set_meta("attack_telegraph_started", true)
	animated_sam.set_meta("attack_telegraph_complete", false)
	animated_sam.set_meta("attack_commit_age", 0.05)
	animated_sam.set_meta("attack_animation_timer", 0.05)
	var lives_before_recoil: int = int(game.players[0].lives)
	game._damage_actor(animated_sam, "torso", 1.0, 0)
	_check(not bool(animated_sam.get_meta("attack_telegraph_started", true)), "a successful hit interrupts the pending enemy windup")
	_check(float(animated_sam.get_meta("attack_ready_age", 0.0)) >= 0.36, "interrupted attack requires a fresh readable telegraph")
	game._animate_actor(animated_sam, 0.0)
	_check(str(v3_player.current_clip_id) == "hit_recoil", "damage selects the authored hit-recoil clip")
	for hit_tick in 13:
		game._update_actors(1.0 / 60.0)
	_check(float(animated_sam.get_meta("hit_timer", 0.0)) > 0.0, "60 Hz runtime still owns the hit state on its final visible tick")
	_check(v3_player.current_frame == 7, "the real timer/update order reaches all eight recoil frames at 60 Hz")
	_check(int(animated_sam.get_meta("attacks", 0)) == 0, "interrupted windup cannot commit during visible recoil")
	_check(int(game.players[0].lives) == lives_before_recoil, "visible recoil cannot hide player damage")
	animated_sam.set_meta("hit_timer", 0.0)
	animated_sam.set_meta("attack_animation_timer", 0.65)
	game._animate_actor(animated_sam, 0.0)
	_check(str(v3_player.current_clip_id) == "attack", "telegraph selects the authored attack clip")
	_check(is_equal_approx(v3_sprite.pixel_size, base_pixel_size * 1.1231), "attack preserves Sam's apparent actor height")
	game._animate_actor(animated_sam, 0.7)
	_check(v3_player.current_frame == 7 and v3_player.finished, "attack holds its final recovery frame instead of snapping to windup")
	game._kill_actor(animated_sam, 0, false)
	_check(str(v3_player.current_clip_id) == "death_fall", "death selects the authored fall clip")
	_check(is_equal_approx(v3_sprite.pixel_size, base_pixel_size * 1.0896), "death entry preserves Sam's apparent actor height")
	await create_timer(0.82).timeout
	_check(is_instance_valid(animated_sam), "Sam is retained until all eight death frames finish")
	if is_instance_valid(animated_sam):
		_check(v3_player.current_frame == 7, "death reaches the authored corpse frame")
		_check(is_equal_approx(v3_sprite.modulate.a, 1.0), "death remains opaque through the complete fall")
	await create_timer(0.72).timeout
	await process_frame
	_check(not is_instance_valid(animated_sam), "Sam retires only after fall, hold and fade")

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

	# Stop and detach looping streams while the gameplay node is still alive so
	# the audio thread can retire its three WAV playbacks before SceneTree exits.
	game.process_mode = Node.PROCESS_MODE_DISABLED
	game._release_audio_resources()
	await process_frame
	await create_timer(0.05).timeout
	game.free()
	await process_frame
	await process_frame
	await create_timer(0.05).timeout
	if failures.is_empty():
		print("DIRECTIONAL SPRITE SMOKE OK: 38 bindings, 10 representatives, 8 directions, V3 lifecycle, death and cleanup states.")
		quit(0)
		return
	for failure in failures:
		push_error(failure)
	quit(1)


func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
