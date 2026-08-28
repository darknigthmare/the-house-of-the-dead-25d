class_name EnemyPursuitController
extends RefCounted

## Deterministic spatial policy shared by every non-boss enemy. The runtime
## keeps actors on the camera-facing side of the encounter, gives ranged
## attacks enough visible travel, and resolves floor-prop penetration without
## depending on render frame rate or a navigation mesh.

const MIN_MELEE_FRONT_DEPTH := 1.15
const MIN_RANGED_STANDOFF_DEPTH := 5.2
const DEFAULT_ACTOR_RADIUS := 0.34
const DEFAULT_ENGAGEMENT_SPEED_GAIN := 1.08
const DEFAULT_ENGAGEMENT_SPEED_CAP := 3.0
const DEFAULT_ATTACK_COMMIT_HOLD_SECONDS := 0.2

const FLOOR_PROP_RADII := {
	"estate_gate": 2.15,
	"garden_lamp": 0.42,
	"dead_tree": 0.86,
	"mansion_double_door": 1.85,
	"library_bookcase": 0.92,
	"roof_gargoyle": 0.52,
	"lab_control_console": 0.82,
	"lab_specimen_tank": 0.78,
	"lab_pipe_cluster": 0.72,
}


static func flat_camera_forward(camera_forward: Vector3) -> Vector3:
	var flattened := Vector3(camera_forward.x, 0.0, camera_forward.z)
	return Vector3.FORWARD if flattened.is_zero_approx() else flattened.normalized()


static func attack_standoff_depth(
	behavior: String,
	melee_range: float,
	projectile_min_travel: float = 3.0,
	projectile_contact_range: float = 1.35
) -> float:
	if behavior == "throw_projectile":
		# The extra margin includes the launch offset and guarantees that the
		# projectile is visible and interceptable before reaching its target.
		return maxf(
			MIN_RANGED_STANDOFF_DEPTH,
			projectile_min_travel + projectile_contact_range + 0.75
		)
	return maxf(MIN_MELEE_FRONT_DEPTH, melee_range * 0.68)


static func camera_depth(
	position: Vector3,
	camera_position: Vector3,
	camera_forward: Vector3
) -> float:
	return (position - camera_position).dot(flat_camera_forward(camera_forward))


static func clamp_to_camera_front(
	position: Vector3,
	camera_position: Vector3,
	camera_forward: Vector3,
	minimum_depth: float
) -> Vector3:
	var forward := flat_camera_forward(camera_forward)
	var depth := (position - camera_position).dot(forward)
	if depth >= minimum_depth:
		return position
	return position + forward * (minimum_depth - depth)


static func attack_point(
	camera_position: Vector3,
	camera_forward: Vector3,
	minimum_depth: float,
	ground_y: float,
	lateral_offset: float = 0.0
) -> Vector3:
	var forward := flat_camera_forward(camera_forward)
	var right := Vector3(-forward.z, 0.0, forward.x)
	var target := camera_position + forward * maxf(MIN_MELEE_FRONT_DEPTH, minimum_depth)
	target += right * lateral_offset
	target.y = ground_y
	return target


static func governed_approach_speed(
	position: Vector3,
	target: Vector3,
	node_elapsed: float,
	rail_duration: float,
	telegraph_seconds: float,
	authored_speed: float,
	config: Dictionary = {}
) -> float:
	if not bool(config.get("enabled", false)):
		return maxf(0.0, authored_speed)
	var speed_gain := clampf(float(config.get(
		"speed_gain",
		DEFAULT_ENGAGEMENT_SPEED_GAIN
	)), 1.0, 2.0)
	var speed_cap := maxf(0.1, float(config.get(
		"speed_cap",
		DEFAULT_ENGAGEMENT_SPEED_CAP
	)))
	var commit_hold := maxf(0.0, float(config.get(
		"attack_commit_hold",
		DEFAULT_ATTACK_COMMIT_HOLD_SECONDS
	)))
	var deadline := maxf(0.0, rail_duration - maxf(0.0, telegraph_seconds) - commit_hold)
	var remaining := maxf(0.05, deadline - maxf(0.0, node_elapsed))
	var planar_distance := Vector2(target.x - position.x, target.z - position.z).length()
	var required_speed := planar_distance / remaining
	return minf(speed_cap, maxf(maxf(0.0, authored_speed), required_speed * speed_gain))


static func step_toward_attack_point(
	position: Vector3,
	target: Vector3,
	speed: float,
	delta: float
) -> Vector3:
	var planar_offset := target - position
	planar_offset.y = 0.0
	var distance := planar_offset.length()
	var maximum_step := maxf(0.0, speed) * maxf(0.0, delta)
	if distance <= maximum_step or distance <= 0.00001:
		return Vector3(target.x, position.y, target.z)
	return position + planar_offset / distance * maximum_step


static func actor_radius(visual_scale: float) -> float:
	return maxf(0.18, DEFAULT_ACTOR_RADIUS * maxf(0.35, visual_scale))


static func prop_radius(prop_id: String) -> float:
	return float(FLOOR_PROP_RADII.get(prop_id, 0.0))


static func resolve_floor_prop_motion(
	origin: Vector3,
	proposed: Vector3,
	radius: float,
	blockers: Array[Dictionary]
) -> Vector3:
	var planar_distance := Vector2(proposed.x - origin.x, proposed.z - origin.z).length()
	var sweep_step := maxf(0.05, maxf(0.05, radius) * 0.45)
	var sweep_count := maxi(1, ceili(planar_distance / sweep_step))
	var resolved := origin
	var motion_step := (proposed - origin) / float(sweep_count)
	for _sweep_index in sweep_count:
		resolved = _resolve_floor_prop_endpoint(resolved, resolved + motion_step, radius, blockers)
	return resolved


static func _resolve_floor_prop_endpoint(
	origin: Vector3,
	proposed: Vector3,
	radius: float,
	blockers: Array[Dictionary]
) -> Vector3:
	var resolved := proposed
	for blocker: Dictionary in blockers:
		if not _vertical_overlap(resolved.y, radius, blocker):
			continue
		var half_extents: Vector2 = blocker.get("half_extents", Vector2.ZERO) as Vector2
		if half_extents.x > 0.0 and half_extents.y > 0.0:
			resolved = _resolve_oriented_box_motion(origin, resolved, radius, blocker)
			continue
		var blocker_radius := maxf(0.0, float(blocker.get("radius", 0.0)))
		if blocker_radius <= 0.0:
			continue
		var blocker_position: Vector3 = blocker.get("position", Vector3.ZERO) as Vector3
		var required_distance := maxf(0.01, radius + blocker_radius)
		var offset := Vector2(resolved.x - blocker_position.x, resolved.z - blocker_position.z)
		if offset.length_squared() >= required_distance * required_distance:
			continue
		var origin_offset := Vector2(origin.x - blocker_position.x, origin.z - blocker_position.z)
		var normal := offset.normalized()
		if origin_offset.length_squared() >= required_distance * required_distance - 0.00001:
			normal = origin_offset.normalized()
		elif normal.is_zero_approx():
			normal = origin_offset.normalized()
		if normal.is_zero_approx():
			normal = Vector2.RIGHT
		# A small deterministic tangent component makes an approaching actor
		# slide around a prop instead of oscillating at its front face.
		var motion := Vector2(proposed.x - origin.x, proposed.z - origin.z)
		var tangent := Vector2(-normal.y, normal.x)
		if tangent.dot(motion) < 0.0:
			tangent = -tangent
		var tangent_step := minf(motion.length(), required_distance * 0.16)
		var separated := normal * required_distance + tangent * tangent_step
		resolved.x = blocker_position.x + separated.x
		resolved.z = blocker_position.z + separated.y
	return resolved


static func position_overlaps_floor_prop(
	position: Vector3,
	radius: float,
	blockers: Array[Dictionary]
) -> bool:
	for blocker: Dictionary in blockers:
		if not _vertical_overlap(position.y, radius, blocker):
			continue
		var half_extents: Vector2 = blocker.get("half_extents", Vector2.ZERO) as Vector2
		var blocker_position: Vector3 = blocker.get("position", Vector3.ZERO) as Vector3
		if half_extents.x > 0.0 and half_extents.y > 0.0:
			var expanded := half_extents + Vector2.ONE * maxf(0.0, radius)
			var local := Vector2(position.x - blocker_position.x, position.z - blocker_position.z).rotated(-float(blocker.get("rotation_y", 0.0)))
			if absf(local.x) < expanded.x and absf(local.y) < expanded.y:
				return true
			continue
		var blocker_radius := maxf(0.0, float(blocker.get("radius", 0.0))) + maxf(0.0, radius)
		if blocker_radius <= 0.0:
			continue
		var offset := Vector2(position.x - blocker_position.x, position.z - blocker_position.z)
		if offset.length_squared() < blocker_radius * blocker_radius:
			return true
	return false


static func resolve_camera_front_motion(
	origin: Vector3,
	proposed: Vector3,
	camera_position: Vector3,
	camera_forward: Vector3,
	minimum_depth: float,
	radius: float,
	blockers: Array[Dictionary]
) -> Vector3:
	var forward := flat_camera_forward(camera_forward)
	var clamped := clamp_to_camera_front(proposed, camera_position, forward, minimum_depth)
	var resolved := resolve_floor_prop_motion(origin, clamped, radius, blockers)
	if camera_depth(resolved, camera_position, forward) >= minimum_depth - 0.0001:
		return resolved
	# When the front plane intersects a blocker, search laterally on that plane.
	# Reapplying the clamp without this search would push the actor back inside
	# the prop that was just resolved.
	var right := Vector3(-forward.z, 0.0, forward.x)
	var front_base := clamp_to_camera_front(resolved, camera_position, forward, minimum_depth)
	var lateral_step := maxf(0.22, radius * 0.8)
	for ring in 8:
		for sign_value: float in [-1.0, 1.0]:
			var candidate: Vector3 = front_base + right * sign_value * lateral_step * float(ring + 1)
			if not position_overlaps_floor_prop(candidate, radius, blockers):
				return candidate
	# Obstacle safety wins if no point on the minimum plane is available. The
	# actor remains on the encounter side instead of being embedded or deleted.
	return resolved


static func segment_hits_floor_prop(
	from: Vector3,
	to: Vector3,
	radius: float,
	blockers: Array[Dictionary]
) -> bool:
	var start := Vector2(from.x, from.z)
	var finish := Vector2(to.x, to.z)
	var segment := finish - start
	var segment_length_squared := segment.length_squared()
	for blocker: Dictionary in blockers:
		if not _segment_vertical_overlap(from.y, to.y, radius, blocker):
			continue
		var half_extents: Vector2 = blocker.get("half_extents", Vector2.ZERO) as Vector2
		if half_extents.x > 0.0 and half_extents.y > 0.0:
			if _segment_hits_oriented_box(from, to, radius, blocker):
				return true
			continue
		var blocker_radius := maxf(0.0, float(blocker.get("radius", 0.0))) + radius
		if blocker_radius <= 0.0:
			continue
		var position: Vector3 = blocker.get("position", Vector3.ZERO) as Vector3
		var center := Vector2(position.x, position.z)
		var factor := 0.0
		if segment_length_squared > 0.000001:
			factor = clampf((center - start).dot(segment) / segment_length_squared, 0.0, 1.0)
		var nearest := start + segment * factor
		if nearest.distance_squared_to(center) <= blocker_radius * blocker_radius:
			return true
	return false


static func _resolve_oriented_box_motion(
	origin: Vector3,
	proposed: Vector3,
	radius: float,
	blocker: Dictionary
) -> Vector3:
	var blocker_position: Vector3 = blocker.get("position", Vector3.ZERO) as Vector3
	var half_extents: Vector2 = blocker.get("half_extents", Vector2.ZERO) as Vector2
	var expanded := half_extents + Vector2.ONE * maxf(0.0, radius)
	var rotation_y := float(blocker.get("rotation_y", 0.0))
	var local := Vector2(proposed.x - blocker_position.x, proposed.z - blocker_position.z).rotated(-rotation_y)
	if absf(local.x) >= expanded.x or absf(local.y) >= expanded.y:
		return proposed
	var origin_local := Vector2(origin.x - blocker_position.x, origin.z - blocker_position.z).rotated(-rotation_y)
	if origin_local.x <= -expanded.x:
		local.x = -expanded.x
	elif origin_local.x >= expanded.x:
		local.x = expanded.x
	elif origin_local.y <= -expanded.y:
		local.y = -expanded.y
	elif origin_local.y >= expanded.y:
		local.y = expanded.y
	else:
		return _resolve_oriented_box_embedded(origin_local, local, expanded, blocker_position, proposed, rotation_y)
	var world_offset := local.rotated(rotation_y)
	return Vector3(blocker_position.x + world_offset.x, proposed.y, blocker_position.z + world_offset.y)


static func _resolve_oriented_box_embedded(origin_local: Vector2, local: Vector2, expanded: Vector2, blocker_position: Vector3, proposed: Vector3, rotation_y: float) -> Vector3:
	var penetration_x := expanded.x - absf(local.x)
	var penetration_z := expanded.y - absf(local.y)
	if penetration_x <= penetration_z:
		var side_x := local.x
		if absf(side_x) <= 0.00001:
			side_x = origin_local.x
		if absf(side_x) <= 0.00001:
			side_x = 1.0
		local.x = expanded.x if side_x >= 0.0 else -expanded.x
	else:
		var side_z := local.y
		if absf(side_z) <= 0.00001:
			side_z = origin_local.y
		if absf(side_z) <= 0.00001:
			side_z = 1.0
		local.y = expanded.y if side_z >= 0.0 else -expanded.y
	var world_offset := local.rotated(rotation_y)
	return Vector3(blocker_position.x + world_offset.x, proposed.y, blocker_position.z + world_offset.y)


static func _segment_hits_oriented_box(
	from: Vector3,
	to: Vector3,
	radius: float,
	blocker: Dictionary
) -> bool:
	var blocker_position: Vector3 = blocker.get("position", Vector3.ZERO) as Vector3
	var half_extents: Vector2 = blocker.get("half_extents", Vector2.ZERO) as Vector2
	var expanded := half_extents + Vector2.ONE * maxf(0.0, radius)
	var rotation_y := float(blocker.get("rotation_y", 0.0))
	var start := Vector2(from.x - blocker_position.x, from.z - blocker_position.z).rotated(-rotation_y)
	var finish := Vector2(to.x - blocker_position.x, to.z - blocker_position.z).rotated(-rotation_y)
	var bounds := Rect2(-expanded, expanded * 2.0)
	if bounds.has_point(start) or bounds.has_point(finish):
		return true
	var corners := PackedVector2Array([
		Vector2(-expanded.x, -expanded.y),
		Vector2(expanded.x, -expanded.y),
		Vector2(expanded.x, expanded.y),
		Vector2(-expanded.x, expanded.y),
	])
	for edge_index in 4:
		if Geometry2D.segment_intersects_segment(start, finish, corners[edge_index], corners[(edge_index + 1) % 4]) != null:
			return true
	return false


static func _vertical_overlap(y: float, radius: float, blocker: Dictionary) -> bool:
	var minimum_y := float(blocker.get("min_y", -1.0e20)) - radius
	var maximum_y := float(blocker.get("max_y", 1.0e20)) + radius
	return y >= minimum_y and y <= maximum_y


static func _segment_vertical_overlap(
	from_y: float,
	to_y: float,
	radius: float,
	blocker: Dictionary
) -> bool:
	var segment_minimum := minf(from_y, to_y) - radius
	var segment_maximum := maxf(from_y, to_y) + radius
	var blocker_minimum := float(blocker.get("min_y", -1.0e20))
	var blocker_maximum := float(blocker.get("max_y", 1.0e20))
	return segment_maximum >= blocker_minimum and segment_minimum <= blocker_maximum
