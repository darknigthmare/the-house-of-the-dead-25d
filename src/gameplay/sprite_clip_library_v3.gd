class_name SpriteClipLibraryV3
extends RefCounted

const REQUIRED_SCHEMA_VERSION := 3
const REQUIRED_DIRECTION_COUNT := 8
const MAX_FRAME_COUNT := 64
const MAX_FPS := 120.0
const MIN_DISPLAY_SCALE := 0.75
const MAX_DISPLAY_SCALE := 1.35
const REQUIRED_DIRECTIONS: Array[String] = [
	"front", "front_left", "left", "back_left",
	"back", "back_right", "right", "front_right",
]

var manifest_path: String = ""
var direction_order: Array[String] = []
var required_clips: Array[String] = []
var last_error: String = ""

var _aliases: Dictionary = {}
var _profiles: Dictionary = {}
var _fallback_reasons: Dictionary = {}


func load_manifest(path: String) -> bool:
	manifest_path = path
	_clear_public_state()
	last_error = ""
	if not FileAccess.file_exists(path):
		return _fail("Sprite V3 manifest is missing: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("Sprite V3 manifest cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return _fail("Sprite V3 manifest is invalid JSON: %s" % path)
	var manifest := parsed as Dictionary
	if int(manifest.get("schema_version", 0)) != REQUIRED_SCHEMA_VERSION:
		return _fail("Sprite V3 manifest schema must be %d" % REQUIRED_SCHEMA_VERSION)

	var direction_result := _validate_identifier_array(
		manifest.get("direction_order", []),
		"direction_order",
		false
	)
	if not bool(direction_result.get("ok", false)):
		return _fail(str(direction_result.get("error", "Invalid Sprite V3 direction order")))
	var next_directions := direction_result.get("values", []) as Array[String]
	if next_directions != REQUIRED_DIRECTIONS:
		return _fail("Sprite V3 direction_order must contain the canonical eight directions in exact order")

	var required_result := _validate_identifier_array(
		manifest.get("required_clips", []),
		"required_clips",
		false
	)
	if not bool(required_result.get("ok", false)):
		return _fail(str(required_result.get("error", "Invalid Sprite V3 required clips")))
	var next_required_clips := required_result.get("values", []) as Array[String]
	if next_required_clips.is_empty():
		return _fail("Sprite V3 required_clips must not be empty")

	var raw_profiles: Variant = manifest.get("profiles", [])
	if typeof(raw_profiles) != TYPE_ARRAY:
		return _fail("Sprite V3 profiles must be an array when present")
	var next_profiles: Dictionary = {}
	var next_fallback_reasons: Dictionary = {}
	for profile_value: Variant in raw_profiles as Array:
		if typeof(profile_value) != TYPE_DICTIONARY:
			return _fail("Sprite V3 profiles must contain objects only")
		var profile_result := _validate_profile(
			profile_value as Dictionary,
			next_required_clips,
			next_directions
		)
		if not bool(profile_result.get("ok", false)):
			return _fail(str(profile_result.get("error", "Invalid Sprite V3 profile")))
		var profile := profile_result.get("profile", {}) as Dictionary
		var actor_id := str(profile.get("id", ""))
		if next_profiles.has(actor_id):
			return _fail("Sprite V3 profile IDs must be unique: %s" % actor_id)
		next_profiles[actor_id] = profile
		next_fallback_reasons[actor_id] = str(profile_result.get("fallback_reason", ""))

	var raw_aliases: Variant = manifest.get("aliases", {})
	if typeof(raw_aliases) != TYPE_DICTIONARY:
		return _fail("Sprite V3 aliases must be an object when present")
	var next_aliases: Dictionary = {}
	for alias_value: Variant in (raw_aliases as Dictionary).keys():
		if typeof(alias_value) != TYPE_STRING:
			return _fail("Sprite V3 alias IDs must be strings")
		var alias_id := str(alias_value)
		var target_value: Variant = (raw_aliases as Dictionary)[alias_value]
		if not _is_valid_id(alias_id):
			return _fail("Sprite V3 alias ID is invalid: %s" % alias_id)
		if typeof(target_value) != TYPE_STRING or not _is_valid_id(str(target_value)):
			return _fail("Sprite V3 alias target is invalid: %s" % alias_id)
		var target_id := str(target_value)
		if next_profiles.has(alias_id):
			return _fail("Sprite V3 alias collides with a canonical profile: %s" % alias_id)
		if not next_profiles.has(target_id):
			return _fail("Sprite V3 alias %s targets an unknown profile: %s" % [alias_id, target_id])
		next_aliases[alias_id] = target_id

	# Publish only after every profile and every late alias has passed validation.
	direction_order = next_directions
	required_clips = next_required_clips
	_profiles = next_profiles
	_aliases = next_aliases
	_fallback_reasons = next_fallback_reasons
	return true


func has_actor(actor_id: String) -> bool:
	return _profiles.has(_canonical_id(actor_id))


func get_profile(actor_id: String) -> Dictionary:
	var canonical := _canonical_id(actor_id)
	if not _profiles.has(canonical):
		return {}
	return (_profiles[canonical] as Dictionary).duplicate(true)


func get_clip(actor_id: String, clip_id: String) -> Dictionary:
	var profile := get_profile(actor_id)
	if profile.is_empty():
		return {}
	var clips := profile.get("clips", {}) as Dictionary
	if not clips.has(clip_id):
		return {}
	return (clips[clip_id] as Dictionary).duplicate(true)


func actor_ids() -> Array[String]:
	var result: Array[String] = []
	for actor_id: Variant in _profiles.keys():
		result.append(str(actor_id))
	result.sort()
	return result


func is_runtime_ready(actor_id: String) -> bool:
	var canonical := _canonical_id(actor_id)
	return _profiles.has(canonical) and str(_fallback_reasons.get(canonical, "")) == ""


func fallback_reason(actor_id: String) -> String:
	var canonical := _canonical_id(actor_id)
	if not _profiles.has(canonical):
		return "unknown_actor:%s" % actor_id
	return str(_fallback_reasons.get(canonical, ""))


func _validate_profile(
		profile_value: Dictionary,
		default_required_clips: Array[String],
		expected_directions: Array[String]
) -> Dictionary:
	var actor_value: Variant = profile_value.get("id", "")
	if typeof(actor_value) != TYPE_STRING or not _is_valid_id(str(actor_value)):
		return _validation_error("Sprite V3 profile ID is invalid: %s" % str(actor_value))
	var actor_id := str(actor_value)

	var fallback_value: Variant = profile_value.get("fallback_v2_id", "")
	if typeof(fallback_value) != TYPE_STRING or not _is_valid_id(str(fallback_value)):
		return _validation_error("Sprite V3 fallback_v2_id is invalid for %s" % actor_id)

	var profile_required := default_required_clips.duplicate()
	if profile_value.has("required_clips"):
		var required_result := _validate_identifier_array(
			profile_value.get("required_clips", []),
			"profile %s required_clips" % actor_id,
			false
		)
		if not bool(required_result.get("ok", false)):
			return required_result
		profile_required = required_result.get("values", []) as Array[String]
		if profile_required.is_empty():
			return _validation_error("Sprite V3 profile required_clips must not be empty: %s" % actor_id)

	var raw_clips: Variant = profile_value.get("clips", {})
	if typeof(raw_clips) != TYPE_DICTIONARY:
		return _validation_error("Sprite V3 clips must be an object for %s" % actor_id)
	var next_clips: Dictionary = {}
	for clip_key: Variant in (raw_clips as Dictionary).keys():
		if typeof(clip_key) != TYPE_STRING or not _is_valid_id(str(clip_key)):
			return _validation_error("Sprite V3 clip ID is invalid for %s: %s" % [actor_id, str(clip_key)])
		var clip_id := str(clip_key)
		var clip_value: Variant = (raw_clips as Dictionary)[clip_key]
		if typeof(clip_value) != TYPE_DICTIONARY:
			return _validation_error("Sprite V3 clip must be an object: %s/%s" % [actor_id, clip_id])
		var clip_result := _validate_clip(actor_id, clip_id, clip_value as Dictionary, expected_directions)
		if not bool(clip_result.get("ok", false)):
			return clip_result
		next_clips[clip_id] = clip_result.get("clip", {}) as Dictionary

	var missing: Array[String] = []
	for clip_id: String in profile_required:
		if not next_clips.has(clip_id):
			missing.append(clip_id)
	var reason := ""
	if not missing.is_empty():
		reason = "missing_required_clips:%s" % ",".join(PackedStringArray(missing))

	var normalized := profile_value.duplicate(true)
	normalized["id"] = actor_id
	normalized["fallback_v2_id"] = str(fallback_value)
	normalized["required_clips"] = profile_required
	normalized["clips"] = next_clips
	return {
		"ok": true,
		"profile": normalized,
		"fallback_reason": reason,
	}


func _validate_clip(
		actor_id: String,
		clip_id: String,
		clip_value: Dictionary,
		expected_directions: Array[String]
) -> Dictionary:
	var label := "%s/%s" % [actor_id, clip_id]
	var path_value: Variant = clip_value.get("path", "")
	if typeof(path_value) != TYPE_STRING:
		return _validation_error("Sprite V3 clip path must be a string: %s" % label)
	var texture_path := str(path_value)
	if not _is_safe_resource_path(texture_path):
		return _validation_error("Sprite V3 clip path is invalid: %s (%s)" % [label, texture_path])
	if not ResourceLoader.exists(texture_path):
		return _validation_error("Sprite V3 clip path is missing: %s (%s)" % [label, texture_path])

	var frame_value: Variant = clip_value.get("frame_count", null)
	if typeof(frame_value) not in [TYPE_INT, TYPE_FLOAT]:
		return _validation_error("Sprite V3 frame_count must be numeric: %s" % label)
	var frame_number := float(frame_value)
	var frame_count := int(frame_number)
	if not is_equal_approx(frame_number, float(frame_count)) or frame_count < 2 or frame_count > MAX_FRAME_COUNT:
		return _validation_error("Sprite V3 frame_count must be an integer from 2 to %d: %s" % [MAX_FRAME_COUNT, label])

	var fps_value: Variant = clip_value.get("fps", null)
	if typeof(fps_value) not in [TYPE_INT, TYPE_FLOAT]:
		return _validation_error("Sprite V3 fps must be numeric: %s" % label)
	var fps := float(fps_value)
	if not is_finite(fps) or fps <= 0.0 or fps > MAX_FPS:
		return _validation_error("Sprite V3 fps must be greater than zero and at most %.1f: %s" % [MAX_FPS, label])

	if typeof(clip_value.get("loop", null)) != TYPE_BOOL:
		return _validation_error("Sprite V3 loop must be boolean: %s" % label)
	if typeof(clip_value.get("hold_last", null)) != TYPE_BOOL:
		return _validation_error("Sprite V3 hold_last must be boolean: %s" % label)
	var display_scale_value: Variant = clip_value.get("display_scale", null)
	if typeof(display_scale_value) not in [TYPE_INT, TYPE_FLOAT]:
		return _validation_error("Sprite V3 display_scale must be numeric: %s" % label)
	var display_scale := float(display_scale_value)
	if not is_finite(display_scale) or display_scale < MIN_DISPLAY_SCALE or display_scale > MAX_DISPLAY_SCALE:
		return _validation_error(
			"Sprite V3 display_scale must be from %.2f to %.2f: %s" % [MIN_DISPLAY_SCALE, MAX_DISPLAY_SCALE, label]
		)

	var sha_value: Variant = clip_value.get("sha256", "")
	if typeof(sha_value) != TYPE_STRING or not _is_valid_sha256(str(sha_value)):
		return _validation_error("Sprite V3 sha256 is invalid: %s" % label)
	var declared_sha := str(sha_value)
	# Imported source PNG bytes are directly readable in editor/CI runs, but a
	# standalone PCK may contain only Godot's imported texture resource. Verify
	# source bytes strictly whenever the editor feature is present; exported
	# builds rely on the dependency-free Node verifier run before packaging and
	# still validate ResourceLoader presence, Texture2D type and grid dimensions.
	if OS.has_feature("editor"):
		var actual_sha := FileAccess.get_sha256(texture_path)
		if actual_sha.is_empty() or actual_sha != declared_sha:
			return _validation_error("Sprite V3 sha256 mismatch: %s" % label)

	var provenance_value: Variant = clip_value.get("provenance", {})
	if typeof(provenance_value) != TYPE_DICTIONARY or (provenance_value as Dictionary).is_empty():
		return _validation_error("Sprite V3 provenance must be a non-empty object: %s" % label)
	if (provenance_value as Dictionary).has("direction_order"):
		var provenance_directions := _validate_identifier_array(
			(provenance_value as Dictionary).get("direction_order", []),
			"clip %s provenance direction_order" % label,
			false
		)
		if not bool(provenance_directions.get("ok", false)):
			return provenance_directions
		if (provenance_directions.get("values", []) as Array[String]) != expected_directions:
			return _validation_error("Sprite V3 provenance direction_order is invalid: %s" % label)

	var texture := ResourceLoader.load(texture_path) as Texture2D
	if texture == null:
		return _validation_error("Sprite V3 clip is not a Texture2D: %s" % label)
	var width := texture.get_width()
	var height := texture.get_height()
	if width <= 0 or height <= 0 or width % frame_count != 0 or height % REQUIRED_DIRECTION_COUNT != 0:
		return _validation_error("Sprite V3 clip dimensions do not divide into %d directions x %d frames: %s" % [REQUIRED_DIRECTION_COUNT, frame_count, label])
	var cell_width := width / frame_count
	var cell_height := height / REQUIRED_DIRECTION_COUNT
	if cell_width != cell_height:
		return _validation_error("Sprite V3 clip cells must be square: %s" % label)

	var normalized := clip_value.duplicate(true)
	normalized["path"] = texture_path
	normalized["frame_count"] = frame_count
	normalized["fps"] = fps
	normalized["display_scale"] = display_scale
	normalized["sha256"] = declared_sha
	normalized["sheet_columns"] = frame_count
	normalized["sheet_rows"] = REQUIRED_DIRECTION_COUNT
	normalized["cell_px"] = cell_width
	return {"ok": true, "clip": normalized}


func _validate_identifier_array(value: Variant, label: String, allow_empty: bool) -> Dictionary:
	if typeof(value) != TYPE_ARRAY:
		return _validation_error("Sprite V3 %s must be an array" % label)
	var result: Array[String] = []
	for entry: Variant in value as Array:
		if typeof(entry) != TYPE_STRING or not _is_valid_id(str(entry)):
			return _validation_error("Sprite V3 %s contains an invalid ID: %s" % [label, str(entry)])
		var identifier := str(entry)
		if result.has(identifier):
			return _validation_error("Sprite V3 %s contains a duplicate ID: %s" % [label, identifier])
		result.append(identifier)
	if result.is_empty() and not allow_empty:
		return _validation_error("Sprite V3 %s must not be empty" % label)
	return {"ok": true, "values": result}


func _canonical_id(actor_id: String) -> String:
	return str(_aliases.get(actor_id, actor_id))


func _is_valid_id(value: String) -> bool:
	if value.is_empty() or value != value.strip_edges():
		return false
	for index in value.length():
		var code := value.unicode_at(index)
		var is_lowercase := code >= 97 and code <= 122
		var is_digit := code >= 48 and code <= 57
		var is_underscore := code == 95 and index > 0
		if not is_lowercase and not is_digit and not is_underscore:
			return false
	return true


func _is_safe_resource_path(path: String) -> bool:
	return path.begins_with("res://") and not path.contains("\\") and not path.contains("..")


func _is_valid_sha256(value: String) -> bool:
	if value.length() != 64:
		return false
	for index in value.length():
		var code := value.unicode_at(index)
		if not ((code >= 48 and code <= 57) or (code >= 97 and code <= 102)):
			return false
	return true


func _clear_public_state() -> void:
	direction_order.clear()
	required_clips.clear()
	_aliases.clear()
	_profiles.clear()
	_fallback_reasons.clear()


func _validation_error(message: String) -> Dictionary:
	return {"ok": false, "error": message}


func _fail(message: String) -> bool:
	last_error = message
	return false
