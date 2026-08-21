class_name CameraRailController
extends Node

signal segment_started(segment_id: StringName)
signal progress_changed(segment_id: StringName, progress: float)
signal segment_finished(segment_id: StringName)

@export_category("References")
@export var rail_camera: Camera3D

@export_category("Playback")
@export_range(0.01, 8.0, 0.01) var speed_scale: float = 1.0
@export var update_on_physics_tick: bool = true

var active_segment: RailSegment
var progress: float = 0.0
var playing: bool = false
var paused: bool = false


func _ready() -> void:
	set_process(not update_on_physics_tick)
	set_physics_process(update_on_physics_tick)


func _process(delta: float) -> void:
	advance(delta)


func _physics_process(delta: float) -> void:
	advance(delta)


func play_segment(segment: RailSegment, start_progress: float = 0.0) -> void:
	active_segment = segment
	progress = clampf(start_progress, 0.0, 1.0)
	playing = active_segment != null
	paused = false
	if not playing:
		return
	active_segment.traversal_started.emit(active_segment.segment_id)
	segment_started.emit(active_segment.segment_id)
	_apply_camera_transform()
	progress_changed.emit(active_segment.segment_id, progress)


func advance(delta: float) -> void:
	if not playing or paused or active_segment == null:
		return
	var duration := maxf(active_segment.get_traversal_duration(), 0.001)
	progress = minf(1.0, progress + (maxf(delta, 0.0) * speed_scale / duration))
	_apply_camera_transform()
	progress_changed.emit(active_segment.segment_id, progress)
	if progress >= 1.0:
		playing = false
		active_segment.traversal_finished.emit(active_segment.segment_id)
		segment_finished.emit(active_segment.segment_id)


func seek_normalized(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	_apply_camera_transform()
	if active_segment != null:
		progress_changed.emit(active_segment.segment_id, progress)


func set_paused(value: bool) -> void:
	paused = value


func stop(reset_to_start: bool = false) -> void:
	playing = false
	paused = false
	if reset_to_start:
		seek_normalized(0.0)


func _apply_camera_transform() -> void:
	if rail_camera == null or active_segment == null:
		return
	var frame := active_segment.sample_global_transform(progress)
	rail_camera.global_position = frame.origin
	var look_target := active_segment.sample_global_look_target(progress)
	if rail_camera.global_position.distance_squared_to(look_target) > 0.0001:
		rail_camera.look_at(look_target, Vector3.UP)
