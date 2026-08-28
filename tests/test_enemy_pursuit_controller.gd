extends RefCounted

const PursuitType := preload("res://src/gameplay/enemy_pursuit_controller.gd")
const RuntimeCombatType := preload("res://src/gameplay/gameplay_runtime_combat.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	_test_camera_front_constraint(checks)
	_test_attack_standoff(checks)
	_test_lateral_pursuit(checks)
	_test_prop_collision(checks)
	_test_projectile_collision(checks)
	_test_swept_collision(checks)
	_test_front_plane_collision(checks)
	_test_repeating_attack_cycle(checks)
	_test_coop_threat_targeting(checks)
	_test_boss_telegraph_contract(checks)
	return checks


static func _test_camera_front_constraint(checks: Array[Dictionary]) -> void:
	var camera_position := Vector3(0.0, 1.7, 5.0)
	var camera_forward := Vector3(0.0, -0.1, -1.0).normalized()
	var behind_camera := Vector3(0.0, 0.0, 6.0)
	var clamped := PursuitType.clamp_to_camera_front(behind_camera, camera_position, camera_forward, 1.7)
	_add_check(
		checks,
		PursuitType.camera_depth(clamped, camera_position, camera_forward) >= 1.7 - 0.0001,
		true,
		"enemy is clamped to the encounter side of the rail camera"
	)
	var already_safe := Vector3(1.0, 0.0, -8.0)
	_add_check(
		checks,
		PursuitType.clamp_to_camera_front(already_safe, camera_position, camera_forward, 1.7),
		already_safe,
		"enemy already in front keeps its authored position"
	)


static func _test_attack_standoff(checks: Array[Dictionary]) -> void:
	var melee_depth := PursuitType.attack_standoff_depth("walk", 2.5)
	var ranged_depth := PursuitType.attack_standoff_depth("throw_projectile", 2.5, 3.0, 1.35)
	_add_check(checks, is_equal_approx(melee_depth, 1.7), true, "melee hunter waits at physical striking depth")
	_add_check(checks, ranged_depth >= 5.2, true, "ranged hunter keeps a readable projectile lane")
	_add_check(checks, ranged_depth - 1.35 >= 3.0, true, "ranged lane guarantees minimum interceptable travel")


static func _test_lateral_pursuit(checks: Array[Dictionary]) -> void:
	var camera_position := Vector3(0.0, 1.7, 3.0)
	var camera_forward := Vector3.FORWARD
	var target := PursuitType.attack_point(camera_position, camera_forward, 1.7, 0.0, 0.25)
	var position := Vector3(5.6, 0.0, -9.0)
	for _step in 360:
		position = PursuitType.step_toward_attack_point(position, target, 2.4, 1.0 / 60.0)
	_add_check(checks, position.distance_to(target) <= 0.0001, true, "wide melee spawn converges laterally and in depth on its attack slot")
	_add_check(checks, absf(position.x) <= 0.26, true, "melee hunter returns inside the visible player lane")
	_add_check(
		checks,
		PursuitType.camera_depth(position, camera_position, camera_forward) >= PursuitType.MIN_MELEE_FRONT_DEPTH,
		true,
		"lateral convergence never moves the hunter behind the camera"
	)


static func _test_prop_collision(checks: Array[Dictionary]) -> void:
	var blockers: Array[Dictionary] = [{
		"position": Vector3(0.0, 1.0, -5.0),
		"radius": 0.8,
		"min_y": 0.0,
		"max_y": 2.0,
	}]
	var origin := Vector3(0.0, 0.0, -7.0)
	var proposed := Vector3(0.0, 0.0, -5.2)
	var resolved := PursuitType.resolve_floor_prop_motion(origin, proposed, 0.35, blockers)
	var planar_distance := Vector2(resolved.x, resolved.z).distance_to(Vector2(0.0, -5.0))
	_add_check(checks, planar_distance >= 1.15 - 0.0001, true, "pursuer cannot penetrate a solid floor prop")
	_add_check(checks, absf(resolved.x) > 0.0, true, "blocked pursuer receives a deterministic sidestep")
	var overhead := Vector3(0.0, 3.2, -5.2)
	_add_check(
		checks,
		PursuitType.resolve_floor_prop_motion(Vector3(0.0, 3.2, -7.0), overhead, 0.2, blockers).is_equal_approx(overhead),
		true,
		"actor above a low prop is not falsely blocked"
	)
	_add_check(checks, PursuitType.prop_radius("lab_specimen_tank") > 0.0, true, "solid specimen tank has a collision footprint")
	_add_check(checks, PursuitType.prop_radius("mansion_chandelier"), 0.0, "hanging prop does not block floor pursuit")
	var wall_blockers: Array[Dictionary] = [{
		"position": Vector3(0.0, 1.5, -4.0),
		"half_extents": Vector2(2.0, 0.2),
		"rotation_y": deg_to_rad(24.0),
		"min_y": 0.0,
		"max_y": 3.0,
	}]
	var wall_origin := Vector3(0.0, 0.0, -5.0)
	var wall_proposed := Vector3(0.0, 0.0, -4.0)
	var wall_resolved := PursuitType.resolve_floor_prop_motion(wall_origin, wall_proposed, 0.35, wall_blockers)
	_add_check(checks, wall_resolved.distance_to(wall_proposed) > 0.2, true, "pursuer is expelled from an oriented procedural wall")
	_add_check(
		checks,
		PursuitType.segment_hits_floor_prop(Vector3(0.0, 1.1, -6.0), Vector3(0.0, 1.1, -2.0), 0.12, wall_blockers),
		true,
		"visible projectile is stopped by an oriented procedural wall"
	)


static func _test_projectile_collision(checks: Array[Dictionary]) -> void:
	var blockers: Array[Dictionary] = [{
		"position": Vector3(0.0, 1.0, -4.0),
		"radius": 0.65,
		"min_y": 0.0,
		"max_y": 2.1,
	}]
	_add_check(
		checks,
		PursuitType.segment_hits_floor_prop(Vector3(0.0, 1.1, -7.0), Vector3(0.0, 1.1, -1.0), 0.12, blockers),
		true,
		"visible projectile is stopped by a solid prop before reaching the player"
	)
	_add_check(
		checks,
		PursuitType.segment_hits_floor_prop(Vector3(2.0, 1.1, -7.0), Vector3(2.0, 1.1, -1.0), 0.12, blockers),
		false,
		"projectile clear of props keeps its visible trajectory"
	)


static func _test_swept_collision(checks: Array[Dictionary]) -> void:
	var circular_blockers: Array[Dictionary] = [{
		"position": Vector3.ZERO,
		"radius": 0.65,
		"min_y": -0.5,
		"max_y": 2.0,
	}]
	var circular_result := PursuitType.resolve_floor_prop_motion(
		Vector3(0.0, 0.0, -3.0),
		Vector3(0.0, 0.0, 3.0),
		0.35,
		circular_blockers
	)
	_add_check(
		checks,
		not PursuitType.position_overlaps_floor_prop(circular_result, 0.35, circular_blockers),
		true,
		"swept pursuer never finishes inside a circular prop"
	)
	_add_check(
		checks,
		circular_result.z <= -1.0 or absf(circular_result.x) >= 1.0,
		true,
		"large movement cannot tunnel straight through a circular prop"
	)
	var wall_blockers: Array[Dictionary] = [{
		"position": Vector3.ZERO,
		"half_extents": Vector2(2.0, 0.08),
		"rotation_y": 0.0,
		"min_y": -0.5,
		"max_y": 2.5,
	}]
	var wall_result := PursuitType.resolve_floor_prop_motion(
		Vector3(0.0, 0.0, -4.0),
		Vector3(0.0, 0.0, 4.0),
		0.35,
		wall_blockers
	)
	_add_check(checks, wall_result.z <= -0.43 + 0.0001, true, "large movement cannot tunnel through a thin wall")


static func _test_front_plane_collision(checks: Array[Dictionary]) -> void:
	var blockers: Array[Dictionary] = [{
		"position": Vector3(0.0, 0.0, -1.7),
		"radius": 0.7,
		"min_y": -0.5,
		"max_y": 2.5,
	}]
	var camera_position := Vector3(0.0, 1.7, 0.0)
	var result := PursuitType.resolve_camera_front_motion(
		Vector3(0.0, 0.0, -3.5),
		Vector3(0.0, 0.0, -1.1),
		camera_position,
		Vector3.FORWARD,
		1.7,
		0.35,
		blockers
	)
	_add_check(checks, PursuitType.camera_depth(result, camera_position, Vector3.FORWARD) >= 1.7 - 0.0001, true, "front-plane collision keeps the enemy ahead of camera")
	_add_check(checks, not PursuitType.position_overlaps_floor_prop(result, 0.35, blockers), true, "front-plane clamp never re-embeds the enemy")


static func _test_repeating_attack_cycle(checks: Array[Dictionary]) -> void:
	var runtime = RuntimeCombatType.new()
	var actor := Node3D.new()
	actor.set_meta("age", 2.0)
	actor.set_meta("attack_period", 1.25)
	actor.set_meta("attacks", 0)
	actor.set_meta("dead", false)
	for attack_index in 4:
		actor.set_meta("age", 2.0 + float(attack_index) * 1.25)
		runtime._finish_enemy_attack_cycle(actor)
	_add_check(checks, int(actor.get_meta("attacks", 0)), 4, "hunter records every repeated attack")
	_add_check(checks, str(actor.get_meta("attack_state", "")), "recovery", "hunter waits in recovery after striking")
	_add_check(checks, bool(actor.get_meta("dead", false)), false, "hunter is never despawned by an arbitrary attack count")
	_add_check(
		checks,
		float(actor.get_meta("recovery_until", 0.0)) > float(actor.get_meta("age", 0.0)),
		true,
		"repeated attack schedules a positive recovery window"
	)
	actor.free()
	runtime.free()


static func _add_check(
	checks: Array[Dictionary],
	actual: Variant,
	expected: Variant,
	label: String
) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})

static func _test_coop_threat_targeting(checks: Array[Dictionary]) -> void:
	var player_states: Array[Dictionary] = [
		{"active": true, "lives": 3, "cursor": Vector2(160.0, 320.0)},
		{"active": true, "lives": 3, "cursor": Vector2(960.0, 320.0)},
	]
	_add_check(
		checks,
		RuntimeCombatType.select_threat_target_player(player_states, Vector2(900.0, 330.0)),
		1,
		"right-side threat selects living P2 instead of always damaging P1"
	)
	_add_check(
		checks,
		RuntimeCombatType.select_threat_target_player(player_states, Vector2(900.0, 330.0), 0),
		0,
		"locked projectile keeps its original living player target"
	)
	player_states[0]["lives"] = 0
	_add_check(
		checks,
		RuntimeCombatType.select_threat_target_player(player_states, Vector2(160.0, 320.0), 0),
		1,
		"dead P1 cannot absorb a threat intended for the surviving P2"
	)
	player_states[1]["lives"] = 0
	_add_check(
		checks,
		RuntimeCombatType.select_threat_target_player(player_states, Vector2(640.0, 320.0)),
		-1,
		"no hostile target exists when both players are out"
	)


static func _test_boss_telegraph_contract(checks: Array[Dictionary]) -> void:
	var overshoot := RuntimeCombatType.boss_telegraph_step(-1.5, false, true, 2.0)
	_add_check(checks, bool(overshoot.started), true, "boss cooldown overshoot starts a visible telegraph")
	_add_check(checks, float(overshoot.timer), 0.9, "boss cooldown overshoot restores the full telegraph duration")
	_add_check(checks, bool(overshoot.ready), false, "boss cannot attack on the tick its telegraph starts")
	var interrupted := RuntimeCombatType.boss_telegraph_step(0.4, true, false, 0.1)
	_add_check(checks, bool(interrupted.started), false, "off-screen boss loses telegraph progress")
	_add_check(checks, float(interrupted.timer), 0.9, "off-screen boss rearms the full warning duration")
	var almost_ready := RuntimeCombatType.boss_telegraph_step(0.9, true, true, 0.89)
	_add_check(checks, bool(almost_ready.ready), false, "boss remains harmless before the complete warning elapses")
	var ready := RuntimeCombatType.boss_telegraph_step(float(almost_ready.timer), true, true, 0.02)
	_add_check(checks, bool(ready.ready), true, "boss commits only after the complete visible warning")
