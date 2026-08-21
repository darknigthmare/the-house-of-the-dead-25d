class_name SpriteAnimationController
extends Node

signal animation_started(animation_id: StringName)
signal animation_frame_changed(animation_id: StringName, frame: int)
signal animation_finished(animation_id: StringName)

@export_category("References")
@export var target_sprite: Sprite3D
@export var directional_resolver: DirectionalSpriteResolver

@export_category("Animation Data")
@export var animations: Array[Dictionary] = []
@export var process_automatically: bool = true

var current_animation_id: StringName
var current_frame: int = 0
var playing: bool = false
var paused: bool = false
var actor_forward: Vector3 = Vector3.FORWARD
var camera_position: Vector3 = Vector3.BACK
var actor_position: Vector3 = Vector3.ZERO
var _elapsed: float = 0.0


func _ready() -> void:
	set_process(process_automatically)


func _process(delta: float) -> void:
	advance(delta)


func play(animation_id: StringName, restart: bool = false) -> bool:
	var definition := get_animation(animation_id)
	if definition.is_empty():
		return false
	if playing and current_animation_id == animation_id and not restart:
		return true
	current_animation_id = animation_id
	current_frame = 0
	_elapsed = 0.0
	paused = false
	playing = true
	animation_started.emit(current_animation_id)
	_apply_frame(definition)
	return true


func advance(delta: float) -> void:
	if not playing or paused:
		return
	var definition := get_animation(current_animation_id)
	if definition.is_empty():
		playing = false
		return
	var fps := maxf(0.01, float(definition.get("fps", 8.0)))
	_elapsed += maxf(delta, 0.0)
	var frame_duration := 1.0 / fps
	while playing and _elapsed >= frame_duration:
		_elapsed -= frame_duration
		_step_frame(definition)


func set_view_context(forward: Vector3, camera_world_position: Vector3, actor_world_position: Vector3) -> void:
	actor_forward = forward
	camera_position = camera_world_position
	actor_position = actor_world_position
	if playing:
		_apply_frame(get_animation(current_animation_id))


func seek_frame(frame: int) -> void:
	var definition := get_animation(current_animation_id)
	if definition.is_empty():
		return
	current_frame = clampi(frame, 0, maxi(0, int(definition.get("frame_count", 1)) - 1))
	_apply_frame(definition)


func set_paused(value: bool) -> void:
	paused = value


func stop() -> void:
	playing = false
	paused = false


func get_animation(animation_id: StringName) -> Dictionary:
	for definition in animations:
		if StringName(str(definition.get("id", &""))) == animation_id:
			return definition
	return {}


func _step_frame(definition: Dictionary) -> void:
	var frame_count := maxi(1, int(definition.get("frame_count", 1)))
	current_frame += 1
	if current_frame >= frame_count:
		if bool(definition.get("loop", true)):
			current_frame = 0
		else:
			current_frame = frame_count - 1
			playing = false
			_apply_frame(definition)
			animation_finished.emit(current_animation_id)
			return
	_apply_frame(definition)


func _apply_frame(definition: Dictionary) -> void:
	if target_sprite == null or definition.is_empty():
		return
	var local_frame := int(definition.get("start_frame", 0)) + current_frame
	if directional_resolver != null:
		directional_resolver.apply_to_sprite(
			target_sprite,
			actor_forward,
			camera_position,
			actor_position,
			local_frame
		)
	else:
		target_sprite.frame = clampi(local_frame, 0, maxi(0, target_sprite.hframes * target_sprite.vframes - 1))
	animation_frame_changed.emit(current_animation_id, current_frame)
