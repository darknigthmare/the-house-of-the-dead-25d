class_name WalkableSurfaceResolver
extends RefCounted

## Resolves an actor's ground height against the same oriented boxes used to
## build the procedural set. Vertical blockers and walkable tops remain two
## separate contracts: a stair can be climbed while its side still blocks.

const DEFAULT_MAX_STEP_UP := 0.82
const DEFAULT_MAX_DROP := 1.35
const DEFAULT_EDGE_TOLERANCE := 0.10


static func make_box_surface(
	transform: Transform3D,
	dimensions: Vector3,
	source: String = ""
) -> Dictionary:
	return {
		"transform": transform,
		"dimensions": dimensions.abs(),
		"source": source,
	}


static func resolve_ground_height(
	position: Vector3,
	previous_ground_y: float,
	surfaces: Array[Dictionary],
	max_step_up: float = DEFAULT_MAX_STEP_UP,
	max_drop: float = DEFAULT_MAX_DROP,
	edge_tolerance: float = DEFAULT_EDGE_TOLERANCE
) -> float:
	var resolved := previous_ground_y
	var found := false
	for surface: Dictionary in surfaces:
		var candidate := surface_height_at(surface, position, edge_tolerance)
		if is_inf(candidate):
			continue
		if candidate > previous_ground_y + maxf(0.0, max_step_up):
			continue
		if candidate < previous_ground_y - maxf(0.0, max_drop):
			continue
		# Overlapping boxes are common (base floor under a bridge or stair).
		# The highest reachable top is the physical surface under the feet.
		if not found or candidate > resolved:
			resolved = candidate
			found = true
	return resolved


static func surface_height_at(
	surface: Dictionary,
	position: Vector3,
	edge_tolerance: float = DEFAULT_EDGE_TOLERANCE
) -> float:
	var transform: Transform3D = surface.get("transform", Transform3D.IDENTITY) as Transform3D
	var dimensions: Vector3 = surface.get("dimensions", Vector3.ZERO) as Vector3
	if dimensions.x <= 0.0 or dimensions.y <= 0.0 or dimensions.z <= 0.0:
		return INF
	var top_normal := transform.basis.y.normalized()
	if top_normal.y <= 0.2:
		return INF
	var plane_point := transform * Vector3(0.0, dimensions.y * 0.5, 0.0)
	var candidate_y := plane_point.y - (
		top_normal.x * (position.x - plane_point.x)
		+ top_normal.z * (position.z - plane_point.z)
	) / top_normal.y
	var local_point := transform.affine_inverse() * Vector3(position.x, candidate_y, position.z)
	var tolerance := maxf(0.0, edge_tolerance)
	if absf(local_point.x) > dimensions.x * 0.5 + tolerance:
		return INF
	if absf(local_point.z) > dimensions.z * 0.5 + tolerance:
		return INF
	return candidate_y
