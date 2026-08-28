extends RefCounted

const ResolverType := preload("res://src/gameplay/walkable_surface_resolver.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	_test_flat_and_overlapping_surfaces(checks)
	_test_stair_progression(checks)
	_test_sloped_surface(checks)
	_test_unreachable_surface(checks)
	return checks


static func _test_flat_and_overlapping_surfaces(checks: Array[Dictionary]) -> void:
	var surfaces: Array[Dictionary] = [
		ResolverType.make_box_surface(Transform3D(Basis.IDENTITY, Vector3(0.0, -0.25, 0.0)), Vector3(12.0, 0.5, 20.0), "base_floor"),
		ResolverType.make_box_surface(Transform3D(Basis.IDENTITY, Vector3(0.0, 0.38, -4.0)), Vector3(5.0, 0.62, 8.0), "raised_bridge"),
	]
	_add_check(checks, is_equal_approx(ResolverType.resolve_ground_height(Vector3(0.0, 0.0, -4.0), 0.0, surfaces), 0.69), true, "highest reachable bridge top wins over the base floor")
	_add_check(checks, ResolverType.resolve_ground_height(Vector3(5.0, 0.0, -4.0), 0.0, surfaces), 0.0, "actor outside bridge footprint remains on base floor")


static func _test_stair_progression(checks: Array[Dictionary]) -> void:
	var surfaces: Array[Dictionary] = []
	for step_index in 5:
		var center := Vector3(0.0, 0.11 + step_index * 0.13, -step_index * 0.58)
		surfaces.append(ResolverType.make_box_surface(Transform3D(Basis.IDENTITY, center), Vector3(5.8, 0.22, 0.72), "step_%d" % step_index))
	var ground := 0.0
	for step_index in 5:
		ground = ResolverType.resolve_ground_height(Vector3(0.0, ground, -step_index * 0.58), ground, surfaces)
	_add_check(checks, is_equal_approx(ground, 0.74), true, "successive stair boxes raise the actor without teleporting")


static func _test_sloped_surface(checks: Array[Dictionary]) -> void:
	var basis := Basis.from_euler(Vector3(0.0, 0.0, deg_to_rad(-7.0)))
	var slope := ResolverType.make_box_surface(Transform3D(basis, Vector3(0.0, 0.32, -4.0)), Vector3(4.7, 0.32, 8.0), "roof_slope")
	var left_height := ResolverType.surface_height_at(slope, Vector3(-1.5, 0.0, -4.0))
	var right_height := ResolverType.surface_height_at(slope, Vector3(1.5, 0.0, -4.0))
	_add_check(checks, not is_equal_approx(left_height, right_height), true, "oriented roof surface resolves a real lateral slope")


static func _test_unreachable_surface(checks: Array[Dictionary]) -> void:
	var high_gallery := ResolverType.make_box_surface(Transform3D(Basis.IDENTITY, Vector3(0.0, 4.0, 0.0)), Vector3(8.0, 0.4, 4.0), "high_gallery")
	_add_check(checks, ResolverType.resolve_ground_height(Vector3.ZERO, 0.0, [high_gallery]), 0.0, "actor cannot snap through the ceiling to an unreachable gallery")


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
