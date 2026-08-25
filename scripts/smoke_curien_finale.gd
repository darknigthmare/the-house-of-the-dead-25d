extends SceneTree


const WINDUP_OBSERVATION_SECONDS := 0.80
const HIT_OBSERVATION_SECONDS := 0.48
const GROUND_OBSERVATION_SECONDS := 1.00
const CORPSE_HOLD_OBSERVATION_SECONDS := 5.20

var failures: Array[String] = []
var assertions: int = 0


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
	_expect(game != null, "gameplay runtime instantiated")
	if game == null:
		await _finish(main)
		return
	var chapters_value: Variant = game.get("chapters")
	_expect(chapters_value is Array, "campaign chapter collection is available")
	if not chapters_value is Array:
		await _finish(main)
		return
	var chapters := chapters_value as Array
	_expect(chapters.size() == 4, "four campaign chapters are loaded")
	if chapters.size() < 4:
		await _finish(main)
		return
	game.set("chapter_index", 3)
	game.set("current_chapter", (chapters[3] as Dictionary).duplicate(true))
	game.call("_enter_node", "magician_battle")
	await process_frame
	game.set("boss_attack_timer", 999.0)

	var curien := game.get("curien_story_actor") as Node3D
	_expect(curien != null and is_instance_valid(curien), "Curien respawns at Magician battle start")
	if curien == null or not is_instance_valid(curien):
		await _finish(main)
		return
	var active_actors := game.get("active_actors") as Array
	_expect(str(game.get("state")) == "boss", "Magician battle remains the active gameplay state")
	_expect(str(curien.get_meta("actor_id", "")) == "curien", "story actor keeps the Curien identity")
	_expect(str(curien.get_meta("role", "")) == "story", "Curien uses the non-hostile story role")
	_expect(not bool(curien.get_meta("targetable", true)), "Curien is explicitly non-targetable")
	_expect(not active_actors.has(curien), "Curien is absent from the combat target registry")
	_expect(not _has_hit_area(curien), "Curien has no combat hit area")
	_expect(str(curien.get_meta("narrative_state", "")) == "awaiting_magician_attack", "Curien waits for the scripted strike")

	await create_timer(WINDUP_OBSERVATION_SECONDS).timeout
	var strike_effect := _find_story_effect(game)
	_expect(strike_effect != null and is_instance_valid(strike_effect), "Magician creates a dedicated visible story projectile")
	if strike_effect != null and is_instance_valid(strike_effect):
		var strike_sprite := strike_effect.get_node_or_null("Sprite3D") as Sprite3D
		_expect(strike_effect.visible, "Magician story projectile is visible during travel")
		_expect(bool(game.call("_actor_is_attack_visible", strike_effect)), "Magician story projectile is inside the active on-screen play area")
		_expect(str(strike_effect.get_meta("narrative_state", "")) == "in_flight", "story projectile reports its in-flight state")
		_expect(strike_sprite != null and strike_sprite.texture != null, "story projectile uses the authored Magician fireball texture")
	var boss := game.get("current_boss") as Node3D
	_expect(boss != null and str(boss.get_meta("narrative_attack", "")) == "curien_execution", "Magician visibly commits the Curien strike")

	await create_timer(HIT_OBSERVATION_SECONDS).timeout
	_expect(str(curien.get_meta("narrative_state", "")) == "hit_recoil", "Curien enters hit recoil after projectile contact")
	_expect(int(curien.get_meta("animation_state", -1)) == 6, "Curien uses the directional hit-recoil frame")
	_expect(not active_actors.has(curien) and not bool(curien.get_meta("targetable", true)), "hit recoil never exposes Curien as a hostile target")

	await create_timer(GROUND_OBSERVATION_SECONDS).timeout
	_expect(str(curien.get_meta("narrative_state", "")) == "dead_grounded", "Curien completes the death fall")
	_expect(int(curien.get_meta("animation_state", -1)) == 7, "Curien uses the directional death-fall frame")
	_expect(bool(curien.get_meta("dead", false)), "grounded Curien is marked dead")
	_expect(bool(curien.get_meta("corpse_persistent", false)), "Curien corpse is retained until scene cleanup")
	var grounded_position := curien.position

	await create_timer(CORPSE_HOLD_OBSERVATION_SECONDS).timeout
	_expect(is_instance_valid(curien), "Curien corpse remains instantiated for the minimum five-second hold")
	if is_instance_valid(curien):
		_expect(str(curien.get_meta("narrative_state", "")) == "dead_grounded", "Curien remains grounded after the hold")
		_expect(bool(curien.get_meta("corpse_hold_complete", false)), "Curien completes the deterministic corpse hold")
		_expect(curien.position.is_equal_approx(grounded_position), "Curien corpse stays fixed on the ground")
		_expect(not active_actors.has(curien) and not _has_hit_area(curien), "Curien corpse remains outside combat targeting")
	await _finish(main)


func _find_story_effect(game: Node) -> Node3D:
	for entry in game.get("story_actors") as Array:
		var actor := entry as Node3D
		if actor != null and is_instance_valid(actor) and str(actor.get_meta("role", "")) == "story_effect":
			return actor
	return null


func _has_hit_area(actor: Node3D) -> bool:
	for child in actor.get_children():
		if child is Area3D:
			return true
	return false


func _expect(condition: bool, label: String) -> void:
	assertions += 1
	if not condition:
		failures.append(label)


func _finish(main: Node) -> void:
	if is_instance_valid(main):
		var game := main.get("active_game") as Node
		if game != null and is_instance_valid(game):
			game.call("_clear_actors")
			game.call("_release_audio_resources")
		_stop_audio_players(main)
		await process_frame
		await create_timer(0.15).timeout
		main.free()
	await process_frame
	await process_frame
	await process_frame
	await create_timer(0.10).timeout
	if failures.is_empty():
		print("CURIEN FINALE SMOKE PASSED: %d assertions" % assertions)
		quit(0)
		return
	for failure in failures:
		push_error("CURIEN FINALE: %s" % failure)
	push_error("CURIEN FINALE SMOKE FAILED: %d/%d assertions" % [failures.size(), assertions])
	quit(1)


func _stop_audio_players(node: Node) -> void:
	for child in node.find_children("*", "AudioStreamPlayer", true, false):
		var player := child as AudioStreamPlayer
		if player != null:
			player.stop()
			player.stream = null
