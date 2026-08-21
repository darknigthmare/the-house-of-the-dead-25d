class_name RailSegment
extends Path3D

signal traversal_started(segment_id: StringName)
signal traversal_finished(segment_id: StringName)

@export_category("Route")
@export var segment_id: StringName = &"segment"
@export var next_segment_ids: Array[StringName] = []

@export_category("Traversal")
@export_range(0.01, 120.0, 0.01) var duration_seconds: float = 4.0
@export_range(0.01, 100.0, 0.01) var fallback_speed: float = 4.0
@export_range(0.05, 20.0, 0.05) var look_ahead_distance: float = 1.5
@export var look_curve: Curve3D
@export var apply_curve_tilt: bool = false


func get_baked_length() -> float:
	return 0.0 if curve == null else curve.get_baked_length()


func get_traversal_duration() -> float:
	if duration_seconds > 0.0:
		return duration_seconds
	return get_baked_length() / maxf(fallback_speed, 0.01)


func sample_local_transform(progress: float) -> Transform3D:
	if curve == null or curve.point_count == 0:
		return Transform3D.IDENTITY
	var distance := get_baked_length() * clampf(progress, 0.0, 1.0)
	return curve.sample_baked_with_rotation(distance, true, apply_curve_tilt)


func sample_global_transform(progress: float) -> Transform3D:
	return global_transform * sample_local_transform(progress)


func sample_global_look_target(progress: float) -> Vector3:
	var clamped_progress := clampf(progress, 0.0, 1.0)
	if look_curve != null and look_curve.point_count > 0:
		var look_distance := look_curve.get_baked_length() * clamped_progress
		return global_transform * look_curve.sample_baked(look_distance, true)
	var length := get_baked_length()
	if length <= 0.001:
		return global_position - global_basis.z
	var distance := minf(length, (length * clamped_progress) + look_ahead_distance)
	return global_transform * curve.sample_baked(distance, true)


func has_exit(exit_id: StringName) -> bool:
	return next_segment_ids.has(exit_id)
