class_name DirectionalSpriteResolver
extends Resource

@export_range(1, 16, 1) var direction_count: int = 8
@export_range(1, 64, 1) var frames_per_direction: int = 8
@export_range(-180.0, 180.0, 0.1) var angular_offset_degrees: float = 0.0
@export var mirror_symmetric_directions: bool = false
@export var direction_order: Array[int] = [0, 1, 2, 3, 4, 5, 6, 7]


func resolve(
		actor_forward: Vector3,
		camera_position: Vector3,
		actor_position: Vector3,
		animation_frame: int = 0
) -> Dictionary:
	var count := maxi(1, direction_count)
	var forward := Vector3(actor_forward.x, 0.0, actor_forward.z).normalized()
	var to_camera := Vector3(
		camera_position.x - actor_position.x,
		0.0,
		camera_position.z - actor_position.z
	).normalized()
	if forward.is_zero_approx():
		forward = Vector3.FORWARD
	if to_camera.is_zero_approx():
		to_camera = -forward
	var angle := atan2(forward.cross(to_camera).y, forward.dot(to_camera))
	angle = fposmod(angle + deg_to_rad(angular_offset_degrees), TAU)
	var raw_direction := wrapi(int(floor((angle / TAU * float(count)) + 0.5)), 0, count)
	var flip_h := false
	var sheet_direction := raw_direction
	if mirror_symmetric_directions and raw_direction > count / 2:
		sheet_direction = count - raw_direction
		flip_h = true
	if direction_order.size() == count:
		sheet_direction = direction_order[sheet_direction]
	var local_frame := wrapi(animation_frame, 0, maxi(1, frames_per_direction))
	return {
		"direction": raw_direction,
		"sheet_direction": sheet_direction,
		"flip_h": flip_h,
		"frame": (sheet_direction * maxi(1, frames_per_direction)) + local_frame,
	}


func apply_to_sprite(
		sprite: Sprite3D,
		actor_forward: Vector3,
		camera_position: Vector3,
		actor_position: Vector3,
		animation_frame: int = 0
) -> int:
	if sprite == null:
		return -1
	var result := resolve(actor_forward, camera_position, actor_position, animation_frame)
	var frame_index := int(result.frame)
	var capacity := maxi(0, sprite.hframes * sprite.vframes)
	if frame_index < 0 or frame_index >= capacity:
		push_error("Directional sprite frame %d exceeds atlas capacity %d" % [frame_index, capacity])
		return -1
	sprite.flip_h = bool(result.flip_h)
	sprite.frame = frame_index
	return int(result.direction)
