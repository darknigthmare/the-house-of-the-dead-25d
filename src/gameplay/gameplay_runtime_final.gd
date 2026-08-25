extends "res://src/gameplay/gameplay_runtime_combat.gd"

var resume_state: String = "node"
var subtitle_expires_at: int = 0
var game_over_pending: bool = false
var session_bosses_defeated: Dictionary = {}
var completed_chapters: Dictionary = {}
var run_result_saved: bool = false
var pending_ending_id: String = ""
var initials_letters: Array[String] = ["A", "A", "A"]
var initials_cursor: int = 0
var initials_entry_index: int = 0

const INITIALS_TIMEOUT := 18.0


func _process(delta: float) -> void:
	super._process(delta)
	if state == "initials":
		_update_initials_overlay()
	if subtitle_expires_at > 0 and Time.get_ticks_msec() >= subtitle_expires_at:
		var panel := subtitle_label.get_meta("panel") as PanelContainer
		if panel != null:
			panel.visible = false
		subtitle_expires_at = 0


func _unhandled_input(event: InputEvent) -> void:
	if not session_started:
		return
	if state == "initials":
		_handle_initials_input(event)
		return
	super._unhandled_input(event)


func _on_state_timer_finished() -> void:
	if state == "initials":
		_confirm_initials()
		return
	super._on_state_timer_finished()


func _update_boss(delta: float) -> void:
	node_elapsed += delta
	super._update_boss(delta)


func _update_actors(delta: float) -> void:
	super._update_actors(delta)
	# Boss-support enemies use the same visible telegraph plus physical contact
	# contract as every other enemy. No position-only fallback may deal damage.


func _build_audio() -> void:
	super._build_audio()
	for audio_player: Variant in audio_players.values():
		if audio_player is AudioStreamPlayer:
			(audio_player as AudioStreamPlayer).bus = "Effects"


func _spawn_limb(at: Vector3) -> void:
	if not bool(configuration.get("dismemberment", true)):
		return
	super._spawn_limb(at)


func _screen_pick_actor(screen_position: Vector2) -> Dictionary:
	var direct_hit := super._screen_pick_actor(screen_position)
	var assist := clampf(float(configuration.get("aim_assist", 0.0)), 0.0, 1.0)
	if not direct_hit.is_empty() or assist <= 0.0:
		return direct_hit
	var best: Node3D
	var best_distance := 58.0 + assist * 72.0
	for actor: Node3D in active_actors:
		if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)):
			continue
		if camera_3d.is_position_behind(actor.global_position + Vector3.UP):
			continue
		var projected := camera_3d.unproject_position(actor.global_position + Vector3(0.0, 1.05, 0.0))
		var distance := projected.distance_to(screen_position)
		if distance < best_distance:
			best_distance = distance
			best = actor
	if best == null:
		return {}
	var projected_head := camera_3d.unproject_position(best.global_position + Vector3(0.0, 1.68, 0.0))
	var zone := "head" if projected_head.distance_to(screen_position) < 32.0 + assist * 16.0 else "torso"
	return {"actor": best, "zone": zone, "multiplier": 2.0 if zone == "head" else 1.0}


func _on_boss_defeated() -> void:
	if current_boss != null and is_instance_valid(current_boss):
		var boss_id := str(current_boss.get_meta("boss_id", ""))
		if not boss_id.is_empty():
			session_bosses_defeated[boss_id] = true
	super._on_boss_defeated()


func _persist_chapter_progress() -> void:
	var completed_chapter := chapter_index + 1
	completed_chapters[str(completed_chapter)] = true
	if bool(configuration.get("demo", false)):
		return
	var unlocks: Array = []
	if str(configuration.get("mode", "arcade")) == "arcade":
		unlocks.append(completed_chapter)
		if completed_chapter < chapters.size():
			unlocks.append(completed_chapter + 1)
	SaveManager.merge_progress({
		"chapters_unlocked": unlocks,
		"bosses_unlocked": session_bosses_defeated.keys(),
		"routes_discovered": routes_discovered.keys()
	})
	SaveManager.write_save()


func _persist_run_result(ending_id: String = "", initials: String = "AAA") -> void:
	if run_result_saved or bool(configuration.get("demo", false)):
		return
	run_result_saved = true
	var normalized_initials := initials.strip_edges().to_upper()
	if normalized_initials.length() != 3:
		normalized_initials = "AAA"
	var shots := 0
	var hits := 0
	var continues_used := 0
	for player: Dictionary in players:
		shots += int(player.get("shots", 0))
		hits += int(player.get("hits", 0))
		continues_used += int(player.get("continues", 0))
	var endings: Array = []
	if not ending_id.is_empty():
		endings.append(ending_id)
	SaveManager.merge_progress({
		"bosses_unlocked": session_bosses_defeated.keys(),
		"routes_discovered": routes_discovered.keys(),
		"endings_obtained": endings,
		"statistics": {
			"runs": 1,
			"shots": shots,
			"hits": hits,
			"scientists_saved": scientists_saved,
			"continues": continues_used,
			"chapters_completed": completed_chapters.size()
		},
		"high_score": {
			"score": _combined_score(),
			"initials": normalized_initials,
			"mode": str(configuration.get("mode", "arcade")),
			"players": int(configuration.get("players", 1)),
			"ending": ending_id,
			"accuracy": _session_accuracy()
		}
	})
	SaveManager.write_save()


func _start_continue(player_index: int) -> void:
	if state == "continue":
		return
	resume_state = state
	continuing_player = player_index
	continue_timer = 10.0
	state = "continue"
	_show_overlay("CONTINUE?", "PLAYER %d  •  %d CREDITS\nTirez ou appuyez sur Entrée" % [player_index + 1, int(players[player_index].credits)], -1.0)


func _update_continue(delta: float) -> void:
	continue_timer -= delta
	center_body.text = "PLAYER %d  •  %d CREDITS\nTirez ou Entrée  •  %02d" % [continuing_player + 1, int(players[continuing_player].credits), maxi(0, int(ceil(continue_timer)))]
	if continue_timer <= 0.0:
		_decline_continue()


func _accept_continue() -> void:
	if continuing_player < 0 or continuing_player >= players.size():
		return
	if int(players[continuing_player].credits) <= 0:
		_decline_continue()
		return
	players[continuing_player].credits = int(players[continuing_player].credits) - 1
	players[continuing_player].continues = int(players[continuing_player].continues) + 1
	players[continuing_player].score = int(players[continuing_player].score) + 1
	players[continuing_player].lives = 3
	players[continuing_player].ammo = MAGAZINE_SIZE
	center_overlay.visible = false
	state = resume_state
	continuing_player = -1
	_feed("CONTINUE!", players[_first_active_player()].color)


func _decline_continue() -> void:
	if continuing_player >= 0 and continuing_player < players.size():
		players[continuing_player].active = false
		crosshairs[continuing_player].visible = false
	continuing_player = -1
	center_overlay.visible = false
	var survivors := 0
	for player in players:
		if bool(player.active) and int(player.lives) > 0:
			survivors += 1
	if survivors > 0:
		state = resume_state
	else:
		_show_overlay("GAME OVER", "Score final : %06d\nPréparez vos initiales pour le classement local." % _combined_score(), 4.0)
		state = "ending"
		state_timer = 4.0
		game_over_pending = true
		pending_ending_id = ""


func _resolve_ending(short_result: bool) -> void:
	_clear_actors()
	boss_panel.visible = false
	var score := _combined_score()
	var ending_id := ""
	var ending_title := "MISSION COMPLETE"
	var ending_body := "The operation is over."
	if not short_result and str(configuration.get("mode", "arcade")) == "arcade":
		if score >= 62000:
			ending_id = "good"
			ending_title = "SPECIAL AGENT ENDING"
			ending_body = "Sophie survived. Rogan and G leave the estate as dawn breaks."
		elif score % 10 == 0:
			ending_id = "bad"
			ending_title = "BAD ENDING"
			ending_body = "A final silhouette emerges from the mansion: Sophie has become one of Curien's creatures."
		else:
			ending_id = "normal"
			ending_title = "NORMAL ENDING"
			ending_body = "The agents leave the ruined mansion, uncertain of Sophie's fate."
	if all_scientists_saved and not short_result:
		ending_body += "\nAll scientists were rescued; the hidden final supply room was secured."
	var accuracy := _session_accuracy()
	ending_body += "\n\nScore %06d  •  Accuracy %d%%  •  Routes %d" % [score, accuracy, routes_discovered.size()]
	_show_overlay(ending_title, ending_body, 8.0)
	state = "ending"
	state_timer = 8.0
	pending_ending_id = ending_id

func _begin_credits() -> void:
	if bool(configuration.get("demo", false)):
		_show_credits()
		return
	if game_over_pending:
		game_over_pending = false
	if not run_result_saved:
		_begin_initials_entry()
		return
	_show_credits()


func _begin_initials_entry() -> void:
	initials_letters = ["A", "A", "A"]
	initials_cursor = 0
	initials_entry_index = 0
	state = "initials"
	state_timer = INITIALS_TIMEOUT
	for crosshair: Control in crosshairs:
		crosshair.visible = false
	center_overlay.visible = true
	_update_initials_overlay()


func _handle_initials_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_ENTER, KEY_KP_ENTER:
				_confirm_initials()
			KEY_BACKSPACE:
				_backspace_initial()
			KEY_LEFT:
				initials_cursor = maxi(0, initials_cursor - 1)
				initials_entry_index = initials_cursor
			KEY_RIGHT:
				initials_cursor = mini(2, initials_cursor + 1)
				initials_entry_index = initials_cursor
			KEY_UP:
				_cycle_initial(1)
			KEY_DOWN:
				_cycle_initial(-1)
			_:
				var code := int(event.unicode)
				if code >= 97 and code <= 122:
					code -= 32
				if code >= 65 and code <= 90:
					_type_initial(String.chr(code))
		get_viewport().set_input_as_handled()
	elif event is InputEventJoypadButton and event.pressed:
		match event.button_index:
			JOY_BUTTON_A:
				_confirm_initials()
			JOY_BUTTON_DPAD_LEFT:
				initials_cursor = maxi(0, initials_cursor - 1)
				initials_entry_index = initials_cursor
			JOY_BUTTON_DPAD_RIGHT:
				initials_cursor = mini(2, initials_cursor + 1)
				initials_entry_index = initials_cursor
			JOY_BUTTON_DPAD_UP:
				_cycle_initial(1)
			JOY_BUTTON_DPAD_DOWN:
				_cycle_initial(-1)
		get_viewport().set_input_as_handled()


func _type_initial(letter: String) -> void:
	var target := clampi(initials_entry_index, 0, 2)
	initials_letters[target] = letter
	initials_entry_index = mini(3, target + 1)
	initials_cursor = mini(2, target + 1)


func _backspace_initial() -> void:
	if initials_entry_index > 0:
		initials_entry_index -= 1
	initials_cursor = clampi(initials_entry_index, 0, 2)
	initials_letters[initials_cursor] = "A"


func _cycle_initial(direction: int) -> void:
	var current := initials_letters[initials_cursor].unicode_at(0) - 65
	current = posmod(current + direction, 26)
	initials_letters[initials_cursor] = String.chr(65 + current)
	initials_entry_index = maxi(initials_entry_index, initials_cursor + 1)


func _update_initials_overlay() -> void:
	var slots: Array[String] = []
	for index in 3:
		var letter := initials_letters[index]
		slots.append("[%s]" % letter if index == initials_cursor else " %s " % letter)
	center_title.text = "ENTER INITIALS / ENTREZ VOS INITIALES"
	center_body.text = "SCORE  %07d\n\n%s\n\nClavier : lettres, flèches, retour arrière, Entrée\nManette : croix directionnelle, A\nValidation automatique : %02d" % [_combined_score(), "   ".join(slots), maxi(0, int(ceil(state_timer)))]
	center_overlay.visible = true


func _confirm_initials() -> void:
	if run_result_saved:
		_show_credits()
		return
	var initials := "%s%s%s" % [initials_letters[0], initials_letters[1], initials_letters[2]]
	_persist_run_result(pending_ending_id, initials)
	_show_credits()


func _show_credits() -> void:
	state = "credits"
	state_timer = 12.0
	_show_overlay("THE HOUSE OF THE DEAD 2.5D", "Original fan-made recreation\n\nDesign & engineering — Codex collaboration\nOriginal project art — OpenAI ImageGen\nArcade reference — SEGA Model 2 (1997)\n\nNo ROM, commercial audio, logo or extracted asset is included.\n\nPress Escape to return", state_timer)


func _combined_score() -> int:
	var total := 0
	for player in players:
		if bool(player.active) or int(player.score) > 0:
			total += int(player.score)
	return total


func _session_accuracy() -> int:
	var shots := 0
	var hits := 0
	for player in players:
		shots += int(player.shots)
		hits += int(player.hits)
	return 0 if shots == 0 else int(round(float(hits) / float(shots) * 100.0))


func _update_hud() -> void:
	if players.size() < 2 or p1_status == null:
		return
	_update_support_hud()
	p1_status.text = _player_status_text(0)
	p2_status.text = _player_status_text(1) if bool(players[1].active) else "P2  PRESS 2 TO JOIN"
	if current_boss != null and is_instance_valid(current_boss):
		boss_health_bar.value = float(current_boss.get_meta("health", 0.0))


func _player_status_text(index: int) -> String:
	var player := players[index]
	var life_icons := ""
	for _life in int(player.lives):
		life_icons += "◆"
	var bullets := ""
	for bullet in MAGAZINE_SIZE:
		bullets += "●" if bullet < int(player.ammo) else "○"
	return "P%d  %06d\n%s  %s" % [index + 1, int(player.score), life_icons, bullets]


func _show_overlay(title: String, body: String, duration: float) -> void:
	center_title.text = title
	center_body.text = body
	center_overlay.visible = true
	if duration >= 0.0:
		state_timer = duration


func _set_subtitle(text_value: String, duration: float) -> void:
	var panel := subtitle_label.get_meta("panel") as PanelContainer
	if panel == null:
		return
	if text_value.strip_edges().is_empty():
		panel.visible = false
		return
	subtitle_label.text = text_value
	panel.visible = true
	subtitle_expires_at = Time.get_ticks_msec() + int(duration * 1000.0)
	_play_subtitle_punctuation(text_value)


func _feed(message: String, color: Color) -> void:
	var label := Label.new()
	label.text = message
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", color)
	score_feed.add_child(label)
	var overflow := maxi(0, score_feed.get_child_count() - 5)
	for index in overflow:
		score_feed.get_child(index).queue_free()
	var tween := create_tween()
	tween.tween_interval(1.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.45)
	tween.tween_callback(label.queue_free)
