class_name DirectionalClipPlayerV3
extends RefCounted

## Pure presentation player for authored V3 sheets.
##
## A clip is one texture with animation frames in columns and the eight
## canonical directions in rows. This class intentionally owns no actor,
## combat, hit-zone or damage reference: gameplay remains authoritative.

const DIRECTION_COUNT := 8
const DEFAULT_DIRECTION_HYSTERESIS_DEGREES := 3.0
const MIN_DISPLAY_SCALE := 0.75
const MAX_DISPLAY_SCALE := 1.35

var direction_hysteresis_degrees: float = DEFAULT_DIRECTION_HYSTERESIS_DEGREES
var angular_offset_degrees: float = 0.0

var target_sprite: Sprite3D
var current_clip_id: StringName = &""
var current_frame: int = 0
var current_direction: int = 0
var previous_direction: int = -1
var frame_count: int = 0
var fps: float = 0.0
var display_scale: float = 1.0
var base_pixel_size: float = 0.0
var loop: bool = false
var hold_last: bool = true
var playing: bool = false
var paused: bool = false
var finished: bool = false
var last_error: String = ""

var _elapsed: float = 0.0
var _texture: Texture2D


## Binds a sprite and starts a validated clip atomically. If validation fails,
## the previous sprite and clip remain untouched.
func configure(sprite: Sprite3D, definition: Dictionary, restart: bool = true) -> bool:
	if sprite == null or not is_instance_valid(sprite):
		return _fail("Directional V3 clip requires a valid Sprite3D")
	var validated := _validate_definition(definition)
	if validated.is_empty():
		return false
	if not is_finite(sprite.pixel_size) or sprite.pixel_size <= 0.0:
		return _fail("Directional V3 clip requires a positive finite base pixel size")
	target_sprite = sprite
	base_pixel_size = sprite.pixel_size
	return _commit_clip(validated, restart)


## Changes the clip on the currently bound sprite. The definition is validated
## before any current playback state or Sprite3D layout is changed.
func play_clip(definition: Dictionary, restart: bool = true) -> bool:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return _fail("Directional V3 clip player has no valid target Sprite3D")
	var validated := _validate_definition(definition)
	if validated.is_empty():
		return false
	return _commit_clip(validated, restart)


## Advances only presentation time. It emits no attack or damage event.
func advance(delta: float) -> bool:
	if is_nan(delta) or is_inf(delta) or delta < 0.0:
		return _fail("Directional V3 clip delta must be finite and non-negative")
	if not _has_clip():
		return _fail("Directional V3 clip player has no configured clip")
	if not playing or paused or delta == 0.0:
		last_error = ""
		return true

	var frame_duration := 1.0 / fps
	_elapsed += delta
	var steps := int(floor(_elapsed / frame_duration))
	if steps <= 0:
		last_error = ""
		return true
	_elapsed -= float(steps) * frame_duration
	if _elapsed < 0.0:
		_elapsed = 0.0

	if loop:
		current_frame = wrapi(current_frame + steps, 0, frame_count)
	else:
		var advanced_frame := current_frame + steps
		if advanced_frame >= frame_count:
			finished = true
			playing = false
			_elapsed = 0.0
			current_frame = frame_count - 1 if hold_last else 0
		else:
			current_frame = advanced_frame
	return _apply_current_frame()


func set_paused(value: bool) -> void:
	paused = value


## Seeks to an exact local clip frame. Invalid seeks do not alter playback.
func seek(frame: int) -> bool:
	if not _has_clip():
		return _fail("Directional V3 clip player has no configured clip")
	if frame < 0 or frame >= frame_count:
		return _fail("Directional V3 clip frame %d is outside 0..%d" % [frame, frame_count - 1])
	current_frame = frame
	_elapsed = 0.0
	finished = false
	return _apply_current_frame()


## Resolves and applies an authored direction without changing clip frame or
## sub-frame time. Hysteresis history is private to this player instance.
func update_view(actor_forward: Vector3, camera_position: Vector3, actor_position: Vector3) -> int:
	if not _has_clip():
		_fail("Directional V3 clip player has no configured clip")
		return -1
	if not _validate_sprite_capacity():
		return -1
	var resolved_direction := _resolve_direction(
		actor_forward,
		camera_position,
		actor_position,
		previous_direction
	)
	current_direction = resolved_direction
	previous_direction = resolved_direction
	if not _apply_current_frame():
		return -1
	return resolved_direction


func reset_direction_history() -> void:
	previous_direction = -1


func stop(reset_to_first: bool = false) -> bool:
	if not _has_clip():
		return _fail("Directional V3 clip player has no configured clip")
	playing = false
	paused = false
	if reset_to_first:
		current_frame = 0
		_elapsed = 0.0
		finished = false
		return _apply_current_frame()
	last_error = ""
	return true


func frame_progress() -> float:
	if fps <= 0.0:
		return 0.0
	return clampf(_elapsed * fps, 0.0, 1.0)


func _validate_definition(definition: Dictionary) -> Dictionary:
	var clip_id := StringName(str(definition.get("id", "")))
	if clip_id == &"":
		_fail("Directional V3 clip id must be non-empty")
		return {}
	var texture_value: Variant = definition.get("texture")
	if not texture_value is Texture2D:
		_fail("Directional V3 clip %s requires a Texture2D" % clip_id)
		return {}
	var texture := texture_value as Texture2D
	if texture == null or not is_instance_valid(texture):
		_fail("Directional V3 clip %s texture is invalid" % clip_id)
		return {}
	var next_frame_count := int(definition.get("frame_count", 0))
	if next_frame_count <= 0:
		_fail("Directional V3 clip %s frame_count must be positive" % clip_id)
		return {}
	var next_fps := float(definition.get("fps", 0.0))
	if is_nan(next_fps) or is_inf(next_fps) or next_fps <= 0.0:
		_fail("Directional V3 clip %s fps must be finite and positive" % clip_id)
		return {}
	var next_display_scale := float(definition.get("display_scale", 1.0))
	if (
		is_nan(next_display_scale) or is_inf(next_display_scale)
		or next_display_scale < MIN_DISPLAY_SCALE or next_display_scale > MAX_DISPLAY_SCALE
	):
		_fail("Directional V3 clip %s display_scale must be from %.2f to %.2f" % [clip_id, MIN_DISPLAY_SCALE, MAX_DISPLAY_SCALE])
		return {}
	var texture_width := texture.get_width()
	var texture_height := texture.get_height()
	if texture_width <= 0 or texture_height <= 0:
		_fail("Directional V3 clip %s texture dimensions must be positive" % clip_id)
		return {}
	if texture_width % next_frame_count != 0:
		_fail("Directional V3 clip %s texture width is not divisible by frame_count" % clip_id)
		return {}
	if texture_height % DIRECTION_COUNT != 0:
		_fail("Directional V3 clip %s texture height is not divisible by eight directions" % clip_id)
		return {}
	return {
		"id": clip_id,
		"texture": texture,
		"frame_count": next_frame_count,
		"fps": next_fps,
		"display_scale": next_display_scale,
		"loop": bool(definition.get("loop", false)),
		"hold_last": bool(definition.get("hold_last", true)),
	}


func _commit_clip(definition: Dictionary, restart: bool) -> bool:
	var next_frame_count := int(definition.frame_count)
	var next_fps := float(definition.fps)
	var next_frame := 0
	var next_elapsed := 0.0
	if not restart and _has_clip():
		next_frame = clampi(current_frame, 0, next_frame_count - 1)
		var prior_subframe_phase := clampf(_elapsed * fps, 0.0, 0.999999)
		next_elapsed = prior_subframe_phase / next_fps

	current_clip_id = definition.id as StringName
	_texture = definition.texture as Texture2D
	frame_count = next_frame_count
	fps = next_fps
	display_scale = float(definition.display_scale)
	loop = bool(definition.loop)
	hold_last = bool(definition.hold_last)
	current_frame = next_frame
	_elapsed = next_elapsed
	playing = true
	paused = false
	finished = false

	# Sprite3D may reset frame when hframes/vframes changes. Reset deliberately,
	# configure the complete grid, then apply the final frame coordinates.
	target_sprite.frame = 0
	target_sprite.texture = _texture
	target_sprite.region_enabled = false
	target_sprite.hframes = frame_count
	target_sprite.vframes = DIRECTION_COUNT
	target_sprite.flip_h = false
	# Source sheets have different internal figure scales. Apply the reviewed
	# actor-level calibration from the immutable base size; never multiply the
	# already-scaled value during repeated clip swaps.
	target_sprite.pixel_size = base_pixel_size * display_scale
	return _apply_current_frame()


func _apply_current_frame() -> bool:
	if not _validate_sprite_capacity():
		return false
	if current_direction < 0 or current_direction >= DIRECTION_COUNT:
		return _fail("Directional V3 direction %d is outside 0..7" % current_direction)
	if current_frame < 0 or current_frame >= frame_count:
		return _fail("Directional V3 frame %d exceeds clip capacity %d" % [current_frame, frame_count])
	target_sprite.flip_h = false
	target_sprite.frame_coords = Vector2i(current_frame, current_direction)
	last_error = ""
	return true


func _validate_sprite_capacity() -> bool:
	if target_sprite == null or not is_instance_valid(target_sprite):
		return _fail("Directional V3 clip player has no valid target Sprite3D")
	if target_sprite.texture != _texture:
		return _fail("Directional V3 target texture no longer matches the active clip")
	var expected_capacity := frame_count * DIRECTION_COUNT
	var actual_capacity := target_sprite.hframes * target_sprite.vframes
	if target_sprite.hframes != frame_count or target_sprite.vframes != DIRECTION_COUNT or actual_capacity != expected_capacity:
		return _fail(
			"Directional V3 Sprite3D capacity mismatch: expected %d (%dx8), got %d (%dx%d)" % [
				expected_capacity,
				frame_count,
				actual_capacity,
				target_sprite.hframes,
				target_sprite.vframes,
			]
		)
	return true


func _resolve_direction(
		actor_forward: Vector3,
		camera_position: Vector3,
		actor_position: Vector3,
		prior_direction: int
) -> int:
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
	var candidate := wrapi(int(floor((angle / TAU * float(DIRECTION_COUNT)) + 0.5)), 0, DIRECTION_COUNT)
	return _resolve_hysteretic_direction(angle, candidate, prior_direction)


func _resolve_hysteretic_direction(angle: float, candidate: int, prior_direction: int) -> int:
	if prior_direction < 0 or prior_direction >= DIRECTION_COUNT or candidate == prior_direction:
		return candidate
	var sector_size := TAU / float(DIRECTION_COUNT)
	var hysteresis := minf(
		deg_to_rad(maxf(0.0, direction_hysteresis_degrees)),
		sector_size * 0.49
	)
	if hysteresis <= 0.0:
		return candidate
	var prior_center := sector_size * float(prior_direction)
	var signed_delta := fposmod(angle - prior_center + PI, TAU) - PI
	if absf(signed_delta) <= sector_size * 0.5 + hysteresis:
		return prior_direction
	return candidate


func _has_clip() -> bool:
	return current_clip_id != &"" and frame_count > 0 and fps > 0.0 and _texture != null


func _fail(message: String) -> bool:
	last_error = message
	return false
