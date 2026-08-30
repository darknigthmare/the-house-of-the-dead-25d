extends SceneTree

const ClipPlayerType := preload("res://src/gameplay/directional_clip_player_v3.gd")

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var sprite := Sprite3D.new()
	sprite.pixel_size = 0.01
	var player = ClipPlayerType.new()
	var loop_five := _clip(&"loop_five", 5, 4.0, true, true)

	_expect_false(player.play_clip(loop_five), "clip cannot start before a Sprite3D is bound")
	_expect_contains(player.last_error, "no valid target", "missing-target error is explicit")
	_expect_true(player.configure(sprite, loop_five), "valid five-frame clip configures")
	_expect_equal(player.current_clip_id, &"loop_five", "configured clip id is retained")
	_expect_equal(sprite.hframes, 5, "clip frame count configures Sprite3D columns")
	_expect_equal(sprite.vframes, 8, "V3 clip configures eight direction rows")
	_expect_equal(sprite.hframes * sprite.vframes, 40, "Sprite3D exposes the exact V3 capacity")
	_expect_equal(sprite.frame_coords, Vector2i(0, 0), "clip starts at its first front frame")
	_expect_false(player.has_method("take_damage"), "visual player exposes no damage method")
	for direction in 8:
		player.reset_direction_history()
		_expect_equal(
			player.update_view(Vector3.FORWARD, _camera_for_direction(direction), Vector3.ZERO),
			direction,
			"authored direction %d resolves independently" % direction
		)
		_expect_equal(sprite.frame_coords, Vector2i(0, direction), "authored direction %d uses its own row" % direction)
	player.reset_direction_history()
	_expect_equal(player.update_view(Vector3.FORWARD, Vector3(0.0, 0.0, -10.0), Vector3.ZERO), 0, "front row is restored after direction sweep")

	_expect_true(player.advance(2.75), "large delta advances deterministically")
	_expect_equal(player.current_frame, 1, "eleven steps wrap to frame one of five")
	_expect_equal(sprite.frame_coords, Vector2i(1, 0), "large-delta frame is applied to the sprite")

	player.set_paused(true)
	_expect_true(player.advance(10.0), "paused advance is accepted without playback")
	_expect_equal(player.current_frame, 1, "pause freezes the current frame")
	player.set_paused(false)
	_expect_true(player.advance(0.25), "unpaused player resumes from its retained phase")
	_expect_equal(player.current_frame, 2, "resume advances by one frame")

	_expect_true(player.seek(4), "seek accepts the last local frame")
	_expect_equal(sprite.frame_coords, Vector2i(4, 0), "seek applies an exact local frame")
	_expect_false(player.seek(5), "seek rejects a frame outside clip capacity")
	_expect_equal(player.current_frame, 4, "invalid seek does not change the current frame")
	_expect_contains(player.last_error, "outside 0..4", "seek range error reports the valid capacity")

	# A half-frame of playback survives direction changes. The second half-frame
	# advances immediately after the view update instead of restarting the clip.
	_expect_true(player.play_clip(loop_five), "loop clip restarts for direction test")
	_expect_true(player.advance(0.125), "half-frame phase accumulates")
	_expect_equal(player.current_frame, 0, "half-frame phase does not advance prematurely")
	_expect_equal(player.update_view(Vector3.FORWARD, _camera_for_direction(7), Vector3.ZERO), 7, "authored right-front row resolves")
	_expect_equal(player.current_frame, 0, "direction change preserves local frame")
	_expect_true(player.advance(0.125), "retained half-frame completes after direction change")
	_expect_equal(player.current_frame, 1, "direction change preserves sub-frame phase")
	_expect_equal(sprite.frame_coords, Vector2i(1, 7), "same animation phase is applied on the new row")
	_expect_false(sprite.flip_h, "V3 authored directions never use runtime mirroring")

	# Hysteresis belongs to each player. One instance retains front inside the
	# three-degree margin while a fresh instance resolves the raw neighboring row.
	player.reset_direction_history()
	_expect_equal(player.update_view(Vector3.FORWARD, Vector3(0.0, 0.0, -10.0), Vector3.ZERO), 0, "front direction seeds instance history")
	var boundary_camera := _camera_at_degrees(25.49)
	_expect_equal(player.update_view(Vector3.FORWARD, boundary_camera, Vector3.ZERO), 0, "instance hysteresis keeps front inside its margin")
	var second_sprite := Sprite3D.new()
	var second_player = ClipPlayerType.new()
	_expect_true(second_player.configure(second_sprite, loop_five), "second player configures independently")
	_expect_equal(second_player.update_view(Vector3.FORWARD, boundary_camera, Vector3.ZERO), 7, "fresh player has independent direction history")
	_expect_equal(player.current_direction, 0, "second player cannot mutate first player direction")
	_expect_equal(player.update_view(Vector3.FORWARD, _camera_at_degrees(25.51), Vector3.ZERO), 7, "first player changes row after crossing hysteresis")

	var loop_three := _clip(&"loop_three", 3, 6.0, true, true)
	_expect_true(player.play_clip(loop_three), "different-size clip configures atomically")
	_expect_equal(sprite.hframes, 3, "new clip replaces the column count")
	_expect_equal(sprite.vframes, 8, "new clip retains eight rows")
	_expect_equal(sprite.hframes * sprite.vframes, 24, "different-size clip has exact capacity")
	_expect_equal(player.current_frame, 0, "clip change restarts local animation")
	_expect_equal(player.current_direction, 7, "clip change preserves authored direction")
	_expect_equal(sprite.frame_coords, Vector2i(0, 7), "clip change reapplies the preserved direction safely")

	var scaled_attack := _clip(&"scaled_attack", 3, 6.0, false, true, 1.12)
	_expect_true(player.play_clip(scaled_attack), "calibrated clip starts")
	_expect_true(is_equal_approx(player.display_scale, 1.12), "player exposes the active display calibration")
	_expect_true(is_equal_approx(sprite.pixel_size, 0.0112), "calibrated clip scales from the immutable base pixel size")
	_expect_true(player.play_clip(loop_three), "uncalibrated clip resumes")
	_expect_true(is_equal_approx(sprite.pixel_size, 0.01), "clip swaps restore base scale without cumulative drift")

	var held_once := _clip(&"held_once", 3, 2.0, false, true)
	_expect_true(player.play_clip(held_once), "non-looping hold clip starts")
	_expect_true(player.advance(1.5), "non-looping clip consumes a completion-sized delta")
	_expect_equal(player.current_frame, 2, "hold-last clip remains on its final frame")
	_expect_equal(sprite.frame_coords, Vector2i(2, 7), "held frame keeps the active direction row")
	_expect_false(player.playing, "completed non-looping clip stops playback")
	_expect_true(player.finished, "completed non-looping clip reports completion")
	_expect_true(player.advance(20.0), "finished held clip ignores later delta safely")
	_expect_equal(player.current_frame, 2, "held clip remains stable after completion")

	var reset_once := _clip(&"reset_once", 3, 2.0, false, false)
	_expect_true(player.play_clip(reset_once), "non-holding one-shot starts")
	_expect_true(player.advance(1.5), "non-holding one-shot completes")
	_expect_equal(player.current_frame, 0, "non-holding one-shot resets to its first frame")
	_expect_true(player.finished, "non-holding one-shot still reports completion")

	var prior_clip_id: StringName = player.current_clip_id
	var prior_capacity := sprite.hframes * sprite.vframes
	_expect_false(player.play_clip({"id": &"bad_count", "texture": _texture(1), "frame_count": 0, "fps": 8.0}), "zero frame count is rejected")
	_expect_contains(player.last_error, "frame_count", "frame-count error is explicit")
	_expect_equal(player.current_clip_id, prior_clip_id, "invalid count leaves prior clip committed")
	_expect_equal(sprite.hframes * sprite.vframes, prior_capacity, "invalid count leaves Sprite3D capacity unchanged")
	_expect_false(player.play_clip({"id": &"bad_fps", "texture": _texture(2), "frame_count": 2, "fps": 0.0}), "zero fps is rejected")
	_expect_contains(player.last_error, "fps", "fps error is explicit")
	var prior_pixel_size := sprite.pixel_size
	_expect_false(player.play_clip({"id": &"bad_scale", "texture": _texture(2), "frame_count": 2, "fps": 8.0, "display_scale": 2.0}), "unsafe display scale is rejected")
	_expect_contains(player.last_error, "display_scale", "display-scale error is explicit")
	_expect_true(is_equal_approx(sprite.pixel_size, prior_pixel_size), "invalid scale leaves prior presentation size untouched")
	_expect_false(player.play_clip({"id": &"bad_texture", "texture": null, "frame_count": 2, "fps": 8.0}), "missing texture is rejected")
	_expect_contains(player.last_error, "Texture2D", "texture error is explicit")
	_expect_false(player.play_clip({"id": &"bad_grid", "texture": _pixel_texture(13, 16), "frame_count": 3, "fps": 8.0}), "non-divisible texture grid is rejected")
	_expect_contains(player.last_error, "width", "grid-width error is explicit")

	_expect_true(player.play_clip(loop_three), "valid clip recovers after validation errors")
	_expect_equal(player.last_error, "", "successful configuration clears prior error")
	var prior_direction: int = int(player.previous_direction)
	sprite.hframes = 1
	_expect_equal(player.update_view(Vector3.FORWARD, Vector3(0.0, 0.0, -10.0), Vector3.ZERO), -1, "external capacity corruption is rejected")
	_expect_contains(player.last_error, "capacity mismatch", "capacity error reports expected and actual layouts")
	_expect_equal(player.previous_direction, prior_direction, "failed view update does not mutate direction history")
	_expect_false(player.advance(-0.1), "negative delta is rejected")
	_expect_contains(player.last_error, "non-negative", "negative-delta error is explicit")

	sprite.free()
	second_sprite.free()
	if _failures == 0:
		print("DIRECTIONAL CLIP PLAYER V3 TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("DIRECTIONAL CLIP PLAYER V3 TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _clip(id: StringName, frames: int, clip_fps: float, loops: bool, holds_last: bool, clip_display_scale: float = 1.0) -> Dictionary:
	return {
		"id": id,
		"texture": _texture(frames),
		"frame_count": frames,
		"fps": clip_fps,
		"display_scale": clip_display_scale,
		"loop": loops,
		"hold_last": holds_last,
	}


func _texture(frames: int) -> Texture2D:
	return _pixel_texture(maxi(1, frames) * 2, 16)


func _pixel_texture(width: int, height: int) -> Texture2D:
	var image := Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


func _camera_for_direction(direction: int) -> Vector3:
	var angle := -float(direction) * TAU / 8.0
	return Vector3(sin(angle), 0.0, -cos(angle)) * 10.0


func _camera_at_degrees(degrees: float) -> Vector3:
	var angle := deg_to_rad(degrees)
	return Vector3(sin(angle), 0.0, -cos(angle)) * 10.0


func _expect_true(actual: bool, label: String) -> void:
	_expect_equal(actual, true, label)


func _expect_false(actual: bool, label: String) -> void:
	_expect_equal(actual, false, label)


func _expect_contains(actual: String, expected_fragment: String, label: String) -> void:
	_expect_equal(actual.contains(expected_fragment), true, label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual == expected:
		return
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
