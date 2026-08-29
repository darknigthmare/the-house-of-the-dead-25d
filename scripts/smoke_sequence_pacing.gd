extends SceneTree

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/gameplay.tscn"
const ContinuityType := preload("res://src/rail/camera_rail_continuity.gd")
const TimingType := preload("res://src/rail/sequence_timing_policy.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("gameplay scene could not be loaded")
		return
	var game := packed.instantiate()
	game.call("configure", {"mode": "arcade", "players": 1, "demo": false, "start_chapter": 1})
	root.add_child(game)
	await process_frame
	await process_frame
	if not bool(game.get("session_started")):
		_fail("runtime session did not start", game)
		return

	game.set("paused_by_player", true)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var chapters := game.get("chapters") as Array
	var expected_starts := ["garden_rescue", "chain_plate", "elevator_switch", "chariot_rematch"]
	var expected_layouts := ["estate_arrival", "hatch_gallery", "elevator_lobby", "rematch_arena"]
	var policy := TimingType.campaign_policy(game.get("campaign") as Dictionary)
	for chapter_index in expected_starts.size():
		game.call("_begin_chapter", chapter_index)
		var chapter := chapters[chapter_index] as Dictionary
		var expected_start := str(expected_starts[chapter_index])
		if str(game.get("current_node_id")) != expected_start:
			_fail("chapter %d intro selected the wrong start node" % (chapter_index + 1), game)
			return
		var profile := game.get("environment_scene_profile") as Dictionary
		if str(profile.get("node_id", "")) != expected_start:
			_fail("chapter %d intro built a stale boss environment" % (chapter_index + 1), game)
			return
		if str(profile.get("layout", "")) != str(expected_layouts[chapter_index]):
			_fail("chapter %d intro built the wrong authored layout" % (chapter_index + 1), game)
			return
		if _count_world_environments(game.get("world_root") as Node3D) != 1:
			_fail("chapter %d intro did not own exactly one WorldEnvironment" % (chapter_index + 1), game)
			return
		var start_node := _find_node(chapter, expected_start)
		var duration := TimingType.rail_duration(start_node, policy)
		var expected_pose := ContinuityType.node_entry_pose(start_node, duration, policy)
		var camera := game.get("camera_3d") as Camera3D
		var expected_position := expected_pose.get("position", Vector3.ZERO) as Vector3
		var expected_forward := expected_pose.get("forward", Vector3.FORWARD) as Vector3
		if camera.position.distance_to(expected_position) > 0.0001:
			_fail("chapter %d intro camera did not start on its authored rail pose" % (chapter_index + 1), game)
			return
		if (-camera.transform.basis.z).normalized().dot(expected_forward) < 0.9999:
			_fail("chapter %d intro camera kept the previous boss orientation" % (chapter_index + 1), game)
			return

	game.call("_clear_actors")
	var destination := {
		"id": "pacing_destination",
		"duration": 8.0,
		"objective": "ENTER THE CONNECTED HALL",
		"rail": {"x": 0.8, "y": 1.65, "z": 4.4, "sweep": -0.9},
		"spawns": [],
		"next": "chapter_complete",
	}
	var probe := {
		"id": "pacing_probe",
		"duration": 8.0,
		"objective": "CLEAR THE APPROACH",
		"rail": {"x": -0.7, "y": 1.6, "z": 4.7, "sweep": 1.0},
		"spawns": [],
		"next": "pacing_destination",
	}
	game.set("current_chapter", {
		"id": "pacing_smoke",
		"title": "PACING SMOKE",
		"style": "mansion",
		"start": "pacing_probe",
		"nodes": [probe, destination],
	})
	game.call("_enter_node", "pacing_probe")
	var expected_rail_duration := 12.0
	if not is_equal_approx(float(game.get("rail_duration")), expected_rail_duration):
		_fail("campaign pace scale did not extend the rail to 12 seconds", game)
		return

	game.call("_update_node", 6.0)
	if str(game.get("state")) != "node":
		_fail("node completed before half of the declared rail", game)
		return
	game.call("_update_node", 5.9)
	if str(game.get("state")) != "node":
		_fail("node completed before the full declared rail", game)
		return
	game.call("_update_node", 0.1)
	if str(game.get("state")) != "node_transition":
		_fail("cleared node did not transition after its rail and outro gate", game)
		return
	if bool(game.get("center_overlay").visible):
		_fail("ordinary connected node still used a generic center overlay", game)
		return
	var connector := game.get("connector_root") as Node3D
	if connector == null or not bool(connector.get_meta("sequence_connector_active", false)):
		_fail("node transition did not create a live physical connector", game)
		return
	if int(connector.get_meta("sequence_connector_segment_count", 0)) != 2:
		_fail("sequence connector did not preserve old/new material halves", game)
		return
	var connector_meshes := 0
	var connector_bodies := 0
	var connector_phases: Dictionary = {}
	for connector_child in connector.get_children():
		if connector_child is MeshInstance3D:
			connector_meshes += 1
			if (connector_child as MeshInstance3D).material_override == null:
				_fail("sequence connector contains an unmaterialed white mesh", game)
				return
			connector_phases[str(connector_child.get_meta("sequence_connector_phase", ""))] = true
		elif connector_child is StaticBody3D:
			connector_bodies += 1
			var collision := connector_child.get_child(0) as CollisionShape3D if connector_child.get_child_count() > 0 else null
			if collision == null or collision.shape == null:
				_fail("sequence connector body has no physical collision shape", game)
				return
	if connector_meshes < 6 or connector_bodies < 6 or not connector_phases.has("from") or not connector_phases.has("to"):
		_fail("sequence connector is missing geometry, collision or one contextual half", game)
		return

	game.call("_on_state_timer_finished")
	if str(game.get("current_node_id")) != "pacing_destination" or str(game.get("state")) != "node":
		_fail("transition did not enter the connected destination", game)
		return
	if connector.get_child_count() != 0 or bool(connector.get_meta("sequence_connector_active", false)):
		_fail("sequence connector survived after the destination chunk was built", game)
		return
	var entry_position := game.get("camera_3d").position as Vector3
	if entry_position.is_equal_approx(Vector3(0.0, 1.7, 8.0)):
		_fail("destination camera reused the old universal rail origin", game)
		return
	var connected_origin := game.get("environment_origin") as Vector3
	if connected_origin.is_zero_approx():
		_fail("destination environment did not receive a connected world origin", game)
		return
	if not (game.get("world_root") as Node3D).position.is_equal_approx(connected_origin):
		_fail("environment chunk root did not move to its connected origin", game)
		return
	if not (game.get("actor_root") as Node3D).position.is_equal_approx(connected_origin):
		_fail("actor chunk root diverged from its environment origin", game)
		return
	if entry_position.distance_to(connected_origin) < 1.0:
		_fail("camera entry pose was not translated inside the connected chunk", game)
		return
	if not is_zero_approx(connected_origin.y):
		_fail("connected environment drifted away from the shared floor datum", game)
		return
	var boss_home := Vector3(0.0, 0.0, -10.5)
	var boss_contact := game.call("_boss_melee_contact_position", boss_home) as Vector3
	var boss_contact_global := (game.get("actor_root") as Node3D).to_global(boss_contact)
	var camera := game.get("camera_3d") as Camera3D
	var camera_forward := -camera.global_transform.basis.z.normalized()
	var expected_boss_contact := camera.global_position + camera_forward * (2.8 * 0.58)
	expected_boss_contact.y = (game.get("actor_root") as Node3D).global_position.y + boss_home.y
	if boss_contact_global.distance_to(expected_boss_contact) > 0.001:
		_fail("melee boss contact mixed global and connected-chunk local coordinates", game)
		return
	game.set("node_elapsed", float(game.get("rail_duration")) * 0.5)
	game.call("_update_camera_rail", 0.0)
	var middle_position := game.get("camera_3d").position as Vector3
	if middle_position.is_equal_approx(entry_position):
		_fail("camera did not advance through its entry/combat/outro motion keys", game)
		return

	var hostile := Node3D.new()
	hostile.set_meta("role", "enemy")
	hostile.set_meta("dead", false)
	game.get("actor_root").add_child(hostile)
	(game.get("active_actors") as Array).append(hostile)
	game.set("current_node", destination)
	game.set("spawn_cursor", 0)
	game.set("node_elapsed", 0.0)
	game.set("node_clear_elapsed", 0.0)
	game.set("state", "node")
	game.call("_update_node", 40.0)
	if str(game.get("state")) != "node":
		_fail("hard timeout removed an unresolved visible hostile", game)
		return
	game.call("_set_environment_origin", Vector3(37.0, 4.0, -51.0))
	var sanitized_origin := game.get("environment_origin") as Vector3
	if not sanitized_origin.is_equal_approx(Vector3(37.0, 0.0, -51.0)):
		_fail("environment origin did not sanitize vertical drift", game)
		return
	if not (game.get("world_root") as Node3D).position.is_equal_approx(sanitized_origin) or not (game.get("actor_root") as Node3D).position.is_equal_approx(sanitized_origin):
		_fail("connected world and actor roots lost their shared transform contract", game)
		return
	if not (game.get("fx_root") as Node3D).position.is_zero_approx():
		_fail("global-space combat FX root was incorrectly translated with scene chunks", game)
		return
	camera.global_position = Vector3(37.0, 1.7, -43.0)
	camera.global_rotation = Vector3.ZERO
	boss_contact = game.call("_boss_melee_contact_position", boss_home) as Vector3
	boss_contact_global = (game.get("actor_root") as Node3D).to_global(boss_contact)
	camera_forward = -camera.global_transform.basis.z.normalized()
	expected_boss_contact = camera.global_position + camera_forward * (2.8 * 0.58)
	expected_boss_contact.y = (game.get("actor_root") as Node3D).to_global(boss_home).y
	if boss_contact_global.distance_to(expected_boss_contact) > 0.001:
		_fail("melee boss contact doubled a nonzero scene-chunk origin", game)
		return

	print("SMOKE SEQUENCE PACING: four intro sets/poses, physical two-material connector, exact planar origins, nonzero-origin boss contact, rail gate 12.0s, no hostile timeout")
	game.free()
	await process_frame
	quit(0)


func _find_node(chapter: Dictionary, node_id: String) -> Dictionary:
	for node_value: Variant in chapter.get("nodes", []) as Array:
		var node := node_value as Dictionary
		if str(node.get("id", "")) == node_id:
			return node
	return {}


func _count_world_environments(world_root: Node3D) -> int:
	var count := 0
	if world_root == null or not is_instance_valid(world_root):
		return count
	for child in world_root.get_children():
		if child is WorldEnvironment:
			count += 1
	return count


func _fail(message: String, game: Node = null) -> void:
	push_error("SMOKE SEQUENCE PACING: %s" % message)
	if game != null and is_instance_valid(game):
		game.free()
	quit(1)
