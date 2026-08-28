class_name CameraRailContinuity
extends RefCounted

const CameraRailPathSamplerScript := preload("res://src/rail/camera_rail_path_sampler.gd")

const DEFAULT_CAMERA_FORWARD := Vector3(0.0, -0.02, -1.0)
const MIN_LOOK_DISTANCE := 1.0


static func rail_entry_position(rail: Dictionary) -> Vector3:
	var origin_value: Variant = rail.get("origin", [])
	if typeof(origin_value) == TYPE_ARRAY:
		var origin_values := origin_value as Array
		if origin_values.size() >= 3:
			return Vector3(float(origin_values[0]), float(origin_values[1]), float(origin_values[2]))
	var sweep := float(rail.get("sweep", 0.0))
	var target_x := float(rail.get("x", 0.0))
	var target_y := float(rail.get("y", 1.55))
	return Vector3(
		-target_x * 0.32 - sweep * 0.18,
		1.7 + (target_y - 1.55) * 0.2,
		8.0 + absf(sweep) * 0.24
	)


static func rail_target_position(rail: Dictionary) -> Vector3:
	return Vector3(
		float(rail.get("x", 0.0)),
		float(rail.get("y", 1.55)),
		float(rail.get("z", 4.5))
	)


static func node_pose(
	node: Dictionary,
	elapsed: float,
	duration: float,
	policy: Dictionary = {}
) -> Dictionary:
	var rail_value: Variant = node.get("rail", {})
	var rail := rail_value as Dictionary if typeof(rail_value) == TYPE_DICTIONARY else {}
	var origin := rail_entry_position(rail)
	var target := rail_target_position(rail)
	var runtime_elapsed := 0.0 if str(node.get("type", "")) == "boss" else elapsed
	return pose_from_sample(CameraRailPathSamplerScript.sample(
		node,
		origin,
		target,
		runtime_elapsed,
		duration,
		policy
	))


static func node_entry_pose(node: Dictionary, duration: float, policy: Dictionary = {}) -> Dictionary:
	return node_pose(node, 0.0, duration, policy)


static func node_exit_pose(node: Dictionary, duration: float, policy: Dictionary = {}) -> Dictionary:
	return node_pose(node, duration, duration, policy)


static func pose_from_sample(sample: Dictionary) -> Dictionary:
	var position := sample.get("position", Vector3.ZERO) as Vector3
	var look_target := sample.get("look_target", position + DEFAULT_CAMERA_FORWARD) as Vector3
	var offset := look_target - position
	var forward := offset.normalized() if not offset.is_zero_approx() else DEFAULT_CAMERA_FORWARD.normalized()
	return {
		"position": position,
		"forward": forward,
		"up": Vector3.UP,
		"look_distance": maxf(MIN_LOOK_DISTANCE, offset.length()),
		"look_target": position + forward * maxf(MIN_LOOK_DISTANCE, offset.length()),
	}


static func pose_from_camera(camera: Camera3D) -> Dictionary:
	if camera == null or not is_instance_valid(camera):
		return pose_from_sample({"position": Vector3.ZERO, "look_target": DEFAULT_CAMERA_FORWARD})
	var forward := -camera.global_transform.basis.z.normalized()
	var up := camera.global_transform.basis.y.normalized()
	return {
		"position": camera.global_position,
		"forward": forward,
		"up": up,
		"look_distance": 8.0,
		"look_target": camera.global_position + forward * 8.0,
	}


static func transition_between(
	from_pose: Dictionary,
	to_pose: Dictionary,
	duration: float,
	from_node_id: String = "",
	to_node_id: String = ""
) -> Dictionary:
	return {
		"from": _normalized_pose(from_pose),
		"to": _normalized_pose(to_pose),
		"duration": maxf(0.001, duration),
		"from_node": from_node_id,
		"to_node": to_node_id,
	}


static func sample_transition(transition: Dictionary, elapsed: float) -> Dictionary:
	var from_pose := _normalized_pose(transition.get("from", {}) as Dictionary)
	var to_pose := _normalized_pose(transition.get("to", {}) as Dictionary)
	var duration := maxf(0.001, float(transition.get("duration", 0.001)))
	var progress := clampf(elapsed / duration, 0.0, 1.0)
	var eased := _smoothstep(progress)
	var from_position := from_pose.get("position", Vector3.ZERO) as Vector3
	var to_position := to_pose.get("position", from_position) as Vector3
	var from_forward := from_pose.get("forward", DEFAULT_CAMERA_FORWARD) as Vector3
	var to_forward := to_pose.get("forward", DEFAULT_CAMERA_FORWARD) as Vector3
	var displacement := to_position - from_position
	var distance := displacement.length()
	var movement_direction := displacement / distance if distance > 0.0001 else Vector3.ZERO
	var tangent_length := minf(3.0, distance * 0.35)
	var position := _cubic_hermite(
		from_position,
		to_position,
		movement_direction * tangent_length,
		movement_direction * tangent_length,
		eased
	)
	var forward := _slerp_direction(from_forward, to_forward, eased)
	var from_up := from_pose.get("up", Vector3.UP) as Vector3
	var to_up := to_pose.get("up", Vector3.UP) as Vector3
	var up := _safe_up(forward, from_up.lerp(to_up, eased).normalized())
	var look_distance := lerpf(
		float(from_pose.get("look_distance", 8.0)),
		float(to_pose.get("look_distance", 8.0)),
		eased
	)
	return {
		"position": position,
		"forward": forward,
		"up": up,
		"look_distance": maxf(MIN_LOOK_DISTANCE, look_distance),
		"look_target": position + forward * maxf(MIN_LOOK_DISTANCE, look_distance),
		"progress": progress,
		"motion_progress": eased,
	}


static func transition_mask_alpha(progress: float) -> float:
	# Keep the connected camera movement visible, then hide only the instant at
	# which the scene-local procedural set is replaced.
	return _smoothstep(inverse_lerp(0.72, 1.0, clampf(progress, 0.0, 1.0)))


static func poses_match(a: Dictionary, b: Dictionary, position_tolerance: float = 0.001, direction_tolerance: float = 0.0001) -> bool:
	var a_pose := _normalized_pose(a)
	var b_pose := _normalized_pose(b)
	var a_position := a_pose.get("position", Vector3.ZERO) as Vector3
	var b_position := b_pose.get("position", Vector3.ZERO) as Vector3
	var a_forward := a_pose.get("forward", DEFAULT_CAMERA_FORWARD) as Vector3
	var b_forward := b_pose.get("forward", DEFAULT_CAMERA_FORWARD) as Vector3
	return a_position.distance_to(b_position) <= position_tolerance and a_forward.dot(b_forward) >= 1.0 - direction_tolerance


static func _normalized_pose(pose: Dictionary) -> Dictionary:
	var position := pose.get("position", Vector3.ZERO) as Vector3
	var forward := pose.get("forward", DEFAULT_CAMERA_FORWARD) as Vector3
	if forward.is_zero_approx():
		forward = DEFAULT_CAMERA_FORWARD
	forward = forward.normalized()
	var up := pose.get("up", Vector3.UP) as Vector3
	up = _safe_up(forward, up)
	var look_distance := maxf(MIN_LOOK_DISTANCE, float(pose.get("look_distance", 8.0)))
	return {
		"position": position,
		"forward": forward,
		"up": up,
		"look_distance": look_distance,
		"look_target": position + forward * look_distance,
	}


static func _slerp_direction(from_direction: Vector3, to_direction: Vector3, weight: float) -> Vector3:
	var from_normal := from_direction.normalized() if not from_direction.is_zero_approx() else DEFAULT_CAMERA_FORWARD.normalized()
	var to_normal := to_direction.normalized() if not to_direction.is_zero_approx() else DEFAULT_CAMERA_FORWARD.normalized()
	# Antiparallel vectors do not define one unique spherical path. A stable
	# camera-friendly fallback avoids a zero vector at the midpoint.
	if from_normal.dot(to_normal) < -0.999:
		var axis := from_normal.cross(Vector3.UP)
		if axis.is_zero_approx():
			axis = from_normal.cross(Vector3.RIGHT)
		return from_normal.rotated(axis.normalized(), PI * weight).normalized()
	return from_normal.slerp(to_normal, weight).normalized()


static func _safe_up(forward: Vector3, candidate: Vector3) -> Vector3:
	var up := candidate if not candidate.is_zero_approx() else Vector3.UP
	up = up.normalized()
	if absf(forward.dot(up)) > 0.995:
		up = Vector3.RIGHT if absf(forward.dot(Vector3.RIGHT)) < 0.995 else Vector3.BACK
	return up


static func _cubic_hermite(a: Vector3, b: Vector3, tangent_a: Vector3, tangent_b: Vector3, progress: float) -> Vector3:
	var t := clampf(progress, 0.0, 1.0)
	var t2 := t * t
	var t3 := t2 * t
	return (
		a * (2.0 * t3 - 3.0 * t2 + 1.0)
		+ tangent_a * (t3 - 2.0 * t2 + t)
		+ b * (-2.0 * t3 + 3.0 * t2)
		+ tangent_b * (t3 - t2)
	)


static func _smoothstep(value: float) -> float:
	var clamped := clampf(value, 0.0, 1.0)
	return clamped * clamped * (3.0 - 2.0 * clamped)
