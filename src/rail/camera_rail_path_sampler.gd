class_name CameraRailPathSampler
extends RefCounted


static func sample(
	node: Dictionary,
	origin: Vector3,
	target: Vector3,
	elapsed: float,
	duration: float,
	policy: Dictionary = {}
) -> Dictionary:
	var linear_progress := clampf(elapsed / maxf(duration, 0.001), 0.0, 1.0)
	var rail_value: Variant = node.get("rail", {})
	var rail := rail_value as Dictionary if typeof(rail_value) == TYPE_DICTIONARY else {}
	var motion_progress := _remap_progress(linear_progress, rail, policy)
	var points_value: Variant = rail.get("points", [])
	if typeof(points_value) == TYPE_ARRAY and (points_value as Array).size() >= 2:
		return _with_orientation(_sample_authored_points(points_value as Array, motion_progress, origin, target, rail))

	var sweep := float(rail.get("sweep", 0.0))
	var control_a := origin.lerp(target, 0.3) + Vector3(sweep * 0.34, 0.08, 0.0)
	var control_b := origin.lerp(target, 0.72) + Vector3(-sweep * 0.22, -0.04, 0.0)
	var position := _cubic_bezier(origin, control_a, control_b, target, motion_progress)
	var look_target := Vector3(
		float(rail.get("look_x", 0.0)) + sin(motion_progress * PI) * sweep,
		float(rail.get("look_y", 1.25)),
		float(rail.get("look_z", -9.0)) + motion_progress * float(rail.get("look_travel_z", 2.0))
	)
	return _with_orientation({
		"position": position,
		"look_target": look_target,
		"progress": linear_progress,
		"motion_progress": motion_progress,
	})


static func _with_orientation(sample: Dictionary) -> Dictionary:
	var position := sample.get("position", Vector3.ZERO) as Vector3
	var look_target := sample.get("look_target", position + Vector3.FORWARD) as Vector3
	var offset := look_target - position
	var forward := offset.normalized() if not offset.is_zero_approx() else Vector3.FORWARD
	sample["forward"] = forward
	sample["up"] = Vector3.UP
	return sample


static func _remap_progress(linear_progress: float, rail: Dictionary, policy: Dictionary) -> float:
	var keys_value: Variant = rail.get("motion_keys", policy.get("rail_motion_keys", []))
	if typeof(keys_value) != TYPE_ARRAY:
		return _smoothstep(linear_progress)
	var keys := keys_value as Array
	if keys.size() < 2:
		return _smoothstep(linear_progress)

	var previous_at := 0.0
	var previous_progress := 0.0
	for key_value: Variant in keys:
		if typeof(key_value) != TYPE_DICTIONARY:
			continue
		var key := key_value as Dictionary
		var next_at := clampf(float(key.get("at", 1.0)), previous_at, 1.0)
		var next_progress := clampf(float(key.get("progress", 1.0)), previous_progress, 1.0)
		if linear_progress <= next_at:
			var segment := inverse_lerp(previous_at, next_at, linear_progress) if next_at > previous_at else 1.0
			return lerpf(previous_progress, next_progress, _smoothstep(segment))
		previous_at = next_at
		previous_progress = next_progress
	return 1.0


static func _sample_authored_points(
	points: Array,
	progress: float,
	fallback_origin: Vector3,
	fallback_target: Vector3,
	rail: Dictionary
) -> Dictionary:
	var previous_at := 0.0
	var previous_position := fallback_origin
	var previous_look := Vector3(
		float(rail.get("look_x", 0.0)),
		float(rail.get("look_y", 1.25)),
		float(rail.get("look_z", -9.0))
	)
	for point_value: Variant in points:
		if typeof(point_value) != TYPE_DICTIONARY:
			continue
		var point := point_value as Dictionary
		var next_at := clampf(float(point.get("at", 1.0)), previous_at, 1.0)
		var next_position := _vector3_from_value(point.get("position", []), fallback_target)
		var next_look := _vector3_from_value(point.get("look", []), previous_look)
		if progress <= next_at:
			var segment := inverse_lerp(previous_at, next_at, progress) if next_at > previous_at else 1.0
			var eased := _smoothstep(segment)
			return {
				"position": previous_position.lerp(next_position, eased),
				"look_target": previous_look.lerp(next_look, eased),
				"progress": progress,
				"motion_progress": progress,
			}
		previous_at = next_at
		previous_position = next_position
		previous_look = next_look
	return {
		"position": previous_position,
		"look_target": previous_look,
		"progress": progress,
		"motion_progress": progress,
	}


static func _vector3_from_value(value: Variant, fallback: Vector3) -> Vector3:
	if typeof(value) != TYPE_ARRAY:
		return fallback
	var values := value as Array
	if values.size() < 3:
		return fallback
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


static func _cubic_bezier(a: Vector3, b: Vector3, c: Vector3, d: Vector3, progress: float) -> Vector3:
	var inverse := 1.0 - progress
	return (
		a * inverse * inverse * inverse
		+ b * 3.0 * inverse * inverse * progress
		+ c * 3.0 * inverse * progress * progress
		+ d * progress * progress * progress
	)


static func _smoothstep(value: float) -> float:
	var clamped := clampf(value, 0.0, 1.0)
	return clamped * clamped * (3.0 - 2.0 * clamped)
