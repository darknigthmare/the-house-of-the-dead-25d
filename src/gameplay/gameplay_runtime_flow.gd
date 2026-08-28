extends "res://src/gameplay/gameplay_runtime_base.gd"

const EnvironmentPropStateControllerScript := preload("res://src/gameplay/environment_prop_state_controller.gd")
const RouteOutcomePolicyScript := preload("res://src/rail/route_outcome_policy.gd")
const SequenceTimingPolicyScript := preload("res://src/rail/sequence_timing_policy.gd")
const CameraRailContinuityScript := preload("res://src/rail/camera_rail_continuity.gd")
const EncounterSpawnTimingPolicyScript := preload("res://src/rail/encounter_spawn_timing_policy.gd")


var node_clear_elapsed: float = 0.0
var camera_transition: Dictionary = {}


func _process(delta: float) -> void:
	if not session_started:
		return
	_update_crosshairs(delta)
	if paused_by_player:
		return
	if state != "node_transition" and flash_rect.color.a > 0.0:
		flash_rect.color.a = maxf(0.0, flash_rect.color.a - delta * 4.8)
		if flash_rect.color.a <= 0.0 and bool(flash_rect.get_meta("sequence_transition", false)):
			flash_rect.color = Color(1.0, 0.9, 0.68, 0.0)
			flash_rect.remove_meta("sequence_transition")
	if state_timer > 0.0:
		state_timer -= delta
		if state_timer <= 0.0:
			_on_state_timer_finished()
	match state:
		"node":
			_update_node(delta)
		"node_transition":
			_update_sequence_transition_camera()
		"boss":
			_update_boss(delta)
			_update_environment_prop_state_events()
		"continue":
			_update_continue(delta)
	if bool(configuration.get("demo", false)):
		_update_demo(delta)
	_update_hud()


func _physics_process(delta: float) -> void:
	if not session_started or paused_by_player:
		return
	_update_camera_rail(delta)
	_update_actors(delta)


func _unhandled_input(event: InputEvent) -> void:
	if not session_started:
		return
	if event is InputEventMouseMotion:
		players[0].cursor = event.position
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_attempt_shot(0, event.position)
		elif event.button_index == MOUSE_BUTTON_RIGHT and bool(configuration.get("button_reload", true)):
			_reload(0)
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.physical_keycode:
			KEY_1:
				_join_player(0)
			KEY_2:
				_join_player(1)
			KEY_R:
				if bool(configuration.get("button_reload", true)):
					_reload(0)
			KEY_F:
				_attempt_shot(1, players[1].cursor)
			KEY_G:
				if bool(configuration.get("button_reload", true)):
					_reload(1)
			KEY_ESCAPE:
				_toggle_pause()
			KEY_ENTER, KEY_SPACE:
				if state == "continue":
					_accept_continue()
	elif event is InputEventJoypadMotion:
		var index := 0 if event.device == 0 else 1
		if index < players.size() and bool(players[index].active):
			var velocity := cursor_velocities[index]
			if event.axis == JOY_AXIS_RIGHT_X:
				velocity.x = event.axis_value * 430.0
			elif event.axis == JOY_AXIS_RIGHT_Y:
				velocity.y = event.axis_value * 430.0
			cursor_velocities[index] = velocity
	elif event is InputEventJoypadButton and event.pressed:
		var index := 0 if event.device == 0 else 1
		if event.button_index == JOY_BUTTON_A:
			_attempt_shot(index, players[index].cursor)
		elif event.button_index == JOY_BUTTON_B and bool(configuration.get("button_reload", true)):
			_reload(index)
		elif event.button_index == JOY_BUTTON_START:
			_join_player(index)


func _update_crosshairs(delta: float) -> void:
	if players.size() < 2:
		return
	var keyboard_motion := Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
	for index in cursor_velocities.size():
		cursor_velocities[index] = cursor_velocities[index].move_toward(Vector2.ZERO, delta * 720.0)
	if keyboard_motion.length_squared() > 0.01:
		cursor_velocities[1] = keyboard_motion.normalized() * 360.0
	for index in mini(2, crosshairs.size()):
		if bool(players[index].active):
			players[index].cursor += cursor_velocities[index] * delta
			players[index].cursor.x = clampf(float(players[index].cursor.x), active_play_rect.position.x + 8.0, active_play_rect.end.x - 8.0)
			players[index].cursor.y = clampf(float(players[index].cursor.y), 8.0, active_play_rect.end.y - 8.0)
		crosshairs[index].visible = bool(players[index].active) and state not in ["chapter_intro", "ending", "initials", "credits"]
		crosshairs[index].set_screen_position(players[index].cursor)


func _join_player(index: int) -> void:
	if index < 0 or index >= players.size():
		return
	if not bool(players[index].active):
		players[index].active = true
		players[index].ammo = MAGAZINE_SIZE
		players[index].lives = 3
		crosshairs[index].visible = true
		_feed("PLAYER %d JOINED" % (index + 1), players[index].color)
	_update_hud()


func _toggle_pause() -> void:
	if state == "ending":
		_begin_credits()
		return
	if state == "credits":
		exit_requested.emit()
		return
	paused_by_player = not paused_by_player
	if paused_by_player:
		_show_overlay("PAUSE", "Échap : reprendre • la partie reste en mémoire", -1.0)
	else:
		center_overlay.visible = false


func _on_state_timer_finished() -> void:
	match state:
		"chapter_intro":
			center_overlay.visible = false
			_enter_node(str(current_chapter.get("start", "")))
		"node_transition":
			_update_sequence_transition_camera()
			_mask_environment_swap()
			center_overlay.visible = false
			_enter_node(current_node_id)
		"chapter_result":
			center_overlay.visible = false
			_advance_after_chapter()
		"boss_rush_intro":
			center_overlay.visible = false
			_start_next_boss_rush()
		"training_intro":
			center_overlay.visible = false
			_begin_training()
		"ending":
			_begin_credits()
		"credits":
			exit_requested.emit()


func _begin_chapter(index: int) -> void:
	if chapters.is_empty():
		_show_overlay("DONNÉES MANQUANTES", "La timeline de campagne n'a pas pu être chargée.", 5.0)
		state = "credits"
		state_timer = 5.0
		return
	chapter_index = clampi(index, 0, chapters.size() - 1)
	current_chapter = chapters[chapter_index] as Dictionary
	camera_transition.clear()
	_set_music_for_chapter(chapter_index)
	chapter_scientists_saved = 0
	chapter_scientists_total = 0
	_clear_actors()
	_build_environment(str(current_chapter.get("style", "mansion")))
	state = "chapter_intro"
	state_timer = 3.2
	var roman: String = ["I", "II", "III", "IV"][chapter_index]
	var title := str(current_chapter.get("title", "UNKNOWN"))
	_show_overlay("CHAPTER %s — %s" % [roman, title], str(current_chapter.get("intro", "")), state_timer)
	chapter_label.text = _safe_ui_text("CHAPTER %s — %s" % [roman, title])
	objective_label.text = ""
	route_label.text = ""


func _enter_node(node_id: String) -> void:
	var node_data := _find_node(current_chapter, node_id)
	if node_data.is_empty():
		_complete_chapter()
		return
	current_node = node_data
	current_node_id = node_id
	routes_discovered["%d:%s" % [chapter_index + 1, node_id]] = true
	node_elapsed = 0.0
	node_clear_elapsed = 0.0
	spawn_cursor = 0
	branch_success = false
	destroyed_breakable_id = ""
	route_condition_context = RouteOutcomePolicyScript.initial_context(current_node)
	active_civilian = null
	_clear_actors()
	_build_environment(str(current_node.get("style", current_chapter.get("style", "mansion"))))
	_configure_environment_prop_state_events()
	var rail := current_node.get("rail", {}) as Dictionary
	rail_origin = _rail_entry_position(rail)
	rail_target = Vector3(float(rail.get("x", 0.0)), float(rail.get("y", 1.55)), float(rail.get("z", 4.5)))
	var sequence_policy := SequenceTimingPolicyScript.campaign_policy(campaign)
	rail_duration = maxf(1.0, SequenceTimingPolicyScript.rail_duration(current_node, sequence_policy))
	camera_3d.position = rail_origin
	camera_3d.look_at(Vector3(float(rail.get("look_x", 0.0)), float(rail.get("look_y", 1.25)), -8.0), Vector3.UP)
	camera_transition.clear()
	state = "node"
	objective_label.text = _safe_ui_text(str(current_node.get("objective", "SURVIVE")))
	route_label.text = _safe_ui_text("ROUTE: %s" % node_id.to_upper().replace("_", " "))
	_set_subtitle(str(current_node.get("dialogue", "")), 3.8)
	if current_node.has("civilian"):
		_spawn_civilian(current_node.get("civilian", {}) as Dictionary)
	if current_node.has("breakable"):
		_spawn_breakable(current_node.get("breakable", {}) as Dictionary)
	for breakable_data in current_node.get("breakables", []) as Array:
		_spawn_breakable(breakable_data as Dictionary)
	for pickup_data in current_node.get("pickups", []) as Array:
		_spawn_pickup(pickup_data as Dictionary)
	if str(current_node.get("type", "")) == "boss":
		_start_boss(str(current_node.get("boss", current_chapter.get("boss", "chariot"))))


func _rail_entry_position(rail: Dictionary) -> Vector3:
	var origin_value: Variant = rail.get("origin", [])
	if typeof(origin_value) == TYPE_ARRAY:
		var origin_values := origin_value as Array
		if origin_values.size() >= 3:
			return Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	# Every procedural set is local to its sequence, but its entry composition is
	# derived from the authored rail instead of snapping to one universal origin.
	var sweep := float(rail.get("sweep", 0.0))
	var target_x := float(rail.get("x", 0.0))
	var target_y := float(rail.get("y", 1.55))
	return Vector3(-target_x * 0.32 - sweep * 0.18, 1.7 + (target_y - 1.55) * 0.2, 8.0 + absf(sweep) * 0.24)


# Runtime hook implemented by gameplay_runtime_combat.gd. Declaring it here
# keeps the data-driven flow independently parseable while preserving dispatch.
func _spawn_pickup(_data: Dictionary) -> void:
	pass


func _find_node(chapter: Dictionary, node_id: String) -> Dictionary:
	for entry in chapter.get("nodes", []) as Array:
		var candidate := entry as Dictionary
		if str(candidate.get("id", "")) == node_id:
			return candidate
	return {}


func _configure_environment_prop_state_events() -> void:
	var prop_indices: Dictionary = {}
	for placement_value in environment_scene_profile.get("props", []) as Array:
		var placement := placement_value as Dictionary
		var prop_id := str(placement.get("id", ""))
		if prop_id.is_empty():
			continue
		var instance_index := int(prop_indices.get(prop_id, 0))
		prop_indices[prop_id] = instance_index + 1
		var sprite := _find_environment_prop_sprite(prop_id, instance_index)
		if sprite == null:
			continue
		EnvironmentPropStateControllerScript.configure_sprite(sprite, prop_id, instance_index, placement)


func _find_environment_prop_sprite(prop_id: String, instance_index: int) -> Sprite3D:
	var found_index := 0
	var name_prefix := "Prop_%s" % prop_id
	for child in world_root.get_children():
		var sprite := child as Sprite3D
		if sprite == null or not str(sprite.name).begins_with(name_prefix):
			continue
		if found_index == instance_index:
			return sprite
		found_index += 1
	return null


func _update_environment_prop_state_events(node_completing: bool = false) -> void:
	if world_root == null:
		return
	var context := _environment_prop_state_context(node_completing)
	for child in world_root.get_children():
		var sprite := child as Sprite3D
		if sprite == null or not sprite.has_meta(EnvironmentPropStateControllerScript.META_EVENT):
			continue
		EnvironmentPropStateControllerScript.apply_pending_event(sprite, context)


func _environment_prop_state_context(node_completing: bool) -> Dictionary:
	var spawns := current_node.get("spawns", []) as Array
	var encounter_clear := (
		state == "node"
		and spawn_cursor >= spawns.size()
		and not _has_active_hostiles()
	)
	return {
		"node_elapsed": node_elapsed,
		"encounter_clear": encounter_clear,
		"node_completing": node_completing,
		"branch_success": branch_success,
		"breakable_destroyed": not destroyed_breakable_id.is_empty(),
		"breakable_id": destroyed_breakable_id,
		"boss_phase": boss_phase,
	}


func _update_node(delta: float) -> void:
	node_elapsed += delta
	var spawns := current_node.get("spawns", []) as Array
	var sequence_policy := SequenceTimingPolicyScript.campaign_policy(campaign)
	while spawn_cursor < spawns.size():
		var spawn := spawns[spawn_cursor] as Dictionary
		var scheduled_delay := EncounterSpawnTimingPolicyScript.scheduled_delay(current_node, spawn_cursor, rail_duration, sequence_policy)
		if node_elapsed < scheduled_delay:
			break
		_spawn_enemy(spawn)
		spawn_cursor += 1
	_update_environment_prop_state_events()
	var encounter_clear := spawn_cursor >= spawns.size() and not _has_active_hostiles()
	if encounter_clear:
		node_clear_elapsed += delta
	else:
		node_clear_elapsed = 0.0
	var minimum_duration := SequenceTimingPolicyScript.minimum_duration(current_node, sequence_policy)
	var clear_hold := SequenceTimingPolicyScript.post_clear_hold(current_node, sequence_policy)
	var rail_complete := (
		not SequenceTimingPolicyScript.requires_rail_complete(current_node, sequence_policy)
		or node_elapsed >= rail_duration
	)
	# Never remove a surviving encounter because an arbitrary timeout expired.
	# A node closes only after every scheduled enemy is resolved, the authored
	# camera move is complete and the post-clear composition has been readable.
	var route_resolved := RouteOutcomePolicyScript.route_is_resolved(current_node, route_condition_context)
	if encounter_clear and route_resolved and rail_complete and node_elapsed >= minimum_duration and node_clear_elapsed >= clear_hold:
		_finish_node()


func _finish_node() -> void:
	if state != "node":
		return
	if active_civilian != null and is_instance_valid(active_civilian) and not bool(active_civilian.get_meta("dead", false)):
		_rescue_civilian(active_civilian)
	_update_environment_prop_state_events(true)
	var route_success := RouteOutcomePolicyScript.branch_succeeded(current_node, branch_success, destroyed_breakable_id, route_condition_context)
	var next_id := str(current_node.get("next", "chapter_complete"))
	if current_node.has("next_success"):
		next_id = str(current_node.get("next_success")) if route_success else str(current_node.get("next_failure"))
	if next_id == "chapter_complete":
		_complete_chapter()
		return
	var next_node := _find_node(current_chapter, next_id)
	var sequence_policy := SequenceTimingPolicyScript.campaign_policy(campaign)
	var transition := SequenceTimingPolicyScript.transition_descriptor(current_node, next_node, route_success, sequence_policy)
	var transition_duration := float(transition.get("duration", 1.8))
	var next_duration := SequenceTimingPolicyScript.rail_duration(next_node, sequence_policy)
	camera_transition = CameraRailContinuityScript.transition_between(
		CameraRailContinuityScript.pose_from_camera(camera_3d),
		CameraRailContinuityScript.node_entry_pose(next_node, next_duration, sequence_policy),
		transition_duration,
		str(current_node.get("id", current_node_id)),
		next_id
	)
	current_node_id = next_id
	state = "node_transition"
	state_timer = transition_duration
	var transition_title := _safe_ui_text(str(transition.get("title", "ADVANCING")))
	var transition_body := _safe_ui_text(str(transition.get("body", "")))
	if current_node.has("next_success") or str(next_node.get("type", "")) == "boss":
		_show_overlay(transition_title, transition_body, state_timer)
	else:
		center_overlay.visible = false
		route_label.text = _safe_ui_text("%s - %s" % [transition_title, transition_body])
		_set_subtitle(transition_body, state_timer)


func _update_sequence_transition_camera() -> void:
	if camera_transition.is_empty() or camera_3d == null or not is_instance_valid(camera_3d):
		return
	var duration := maxf(0.001, float(camera_transition.get("duration", 0.001)))
	var elapsed := duration - maxf(0.0, state_timer)
	var pose := CameraRailContinuityScript.sample_transition(camera_transition, elapsed)
	camera_3d.global_position = pose.get("position", camera_3d.global_position) as Vector3
	var look_target := pose.get("look_target", camera_3d.global_position + Vector3.FORWARD) as Vector3
	var up := pose.get("up", Vector3.UP) as Vector3
	if camera_3d.global_position.distance_squared_to(look_target) > 0.0001:
		camera_3d.look_at(look_target, up)
	if flash_rect != null:
		var progress := float(pose.get("progress", 0.0))
		var mask_alpha := CameraRailContinuityScript.transition_mask_alpha(progress)
		flash_rect.color = Color(0.005, 0.008, 0.012, mask_alpha)
		if mask_alpha > 0.0:
			flash_rect.set_meta("sequence_transition", true)


func _mask_environment_swap() -> void:
	if flash_rect == null:
		return
	flash_rect.color = Color(0.005, 0.008, 0.012, 1.0)
	flash_rect.set_meta("sequence_transition", true)


func _complete_chapter() -> void:
	_clear_actors()
	camera_transition.clear()
	boss_panel.visible = false
	var bonus_lives := 2 if chapter_scientists_saved >= 6 else (1 if chapter_scientists_saved >= 3 else 0)
	if bonus_lives > 0:
		for player in players:
			if bool(player.active):
				player.lives = mini(5, int(player.lives) + bonus_lives)
	_persist_chapter_progress()
	var combined := _combined_score()
	_show_overlay("CHAPTER COMPLETE", "Scientists saved: %d/%d\nScore: %06d\nLife bonus: +%d" % [chapter_scientists_saved, chapter_scientists_total, combined, bonus_lives], 4.0)
	state = "chapter_result"
	state_timer = 4.0


func _advance_after_chapter() -> void:
	var mode := str(configuration.get("mode", "arcade"))
	if mode == "chapter_select":
		_resolve_ending(true)
		return
	chapter_index += 1
	if chapter_index >= chapters.size():
		_resolve_ending(false)
	else:
		_begin_chapter(chapter_index)


func _begin_training() -> void:
	if chapters.is_empty():
		return
	current_chapter = (chapters[0] as Dictionary).duplicate(true)
	chapter_index = 0
	_set_music_for_chapter(chapter_index)
	var training := _find_node(current_chapter, "garden_rescue")
	if training.is_empty():
		training = (current_chapter.get("nodes", []) as Array)[0] as Dictionary
	current_chapter["nodes"] = [training]
	current_chapter["start"] = str(training.get("id", ""))
	current_chapter["title"] = "AMS TRAINING"
	_enter_node(str(current_chapter.get("start", "")))


func _start_next_boss_rush() -> void:
	if boss_queue.is_empty():
		_resolve_ending(true)
		return
	_build_environment("laboratory")
	_start_boss(boss_queue.pop_front())
