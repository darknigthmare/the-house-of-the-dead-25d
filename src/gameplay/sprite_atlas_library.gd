class_name SpriteAtlasLibrary
extends RefCounted

const REQUIRED_SCHEMA_VERSION := 2
const REQUIRED_ASSET_COUNT := 35
const REQUIRED_COLUMNS := 8
const REQUIRED_ROWS := 8
const REQUIRED_DIRECTIONS := [
	"front", "front_left", "left", "back_left",
	"back", "back_right", "right", "front_right"
]

var manifest_path: String = ""
var layout: Dictionary = {}
var aliases: Dictionary = {}
var profiles: Dictionary = {}
var last_error: String = ""


func load_manifest(path: String) -> bool:
	manifest_path = path
	_clear_public_state()
	last_error = ""
	if not FileAccess.file_exists(path):
		return _fail("Sprite manifest is missing: %s" % path)
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("Sprite manifest cannot be opened: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return _fail("Sprite manifest is invalid JSON: %s" % path)
	var manifest := parsed as Dictionary
	if int(manifest.get("schema_version", 0)) != REQUIRED_SCHEMA_VERSION:
		return _fail("Sprite manifest schema must be %d" % REQUIRED_SCHEMA_VERSION)
	var raw_layout: Variant = manifest.get("atlas_layout", {})
	if typeof(raw_layout) != TYPE_DICTIONARY:
		return _fail("Sprite manifest atlas layout must be an object")
	var next_layout: Dictionary = (raw_layout as Dictionary).duplicate(true)
	if int(next_layout.get("columns", 0)) != REQUIRED_COLUMNS or int(next_layout.get("rows", 0)) != REQUIRED_ROWS:
		return _fail("Sprite manifest must use an 8x8 atlas layout")
	if int(next_layout.get("frames_per_direction", 0)) != REQUIRED_COLUMNS:
		return _fail("Sprite manifest must declare eight frames per direction")
	var directions := next_layout.get("direction_order", []) as Array
	if directions != REQUIRED_DIRECTIONS:
		return _fail("Sprite direction order does not match the runtime contract")
	var raw_aliases: Variant = manifest.get("aliases", {})
	if typeof(raw_aliases) != TYPE_DICTIONARY:
		return _fail("Sprite manifest aliases must be an object")
	var next_aliases: Dictionary = (raw_aliases as Dictionary).duplicate(true)
	var raw_assets: Variant = manifest.get("assets", [])
	if typeof(raw_assets) != TYPE_ARRAY:
		return _fail("Sprite manifest assets must be an array")
	var assets := raw_assets as Array
	if assets.size() != REQUIRED_ASSET_COUNT:
		return _fail("Sprite manifest must contain exactly %d contract v2 assets" % REQUIRED_ASSET_COUNT)
	var next_profiles: Dictionary = {}
	for value in assets:
		if typeof(value) != TYPE_DICTIONARY:
			return _fail("Sprite manifest contains a non-object asset")
		var profile := value as Dictionary
		var actor_id := str(profile.get("id", ""))
		if actor_id.is_empty() or next_profiles.has(actor_id):
			return _fail("Sprite asset IDs must be non-empty and unique: %s" % actor_id)
		if int(profile.get("contract_version", 0)) != REQUIRED_SCHEMA_VERSION:
			return _fail("Sprite asset %s is not on contract v2" % actor_id)
		var texture_path := str(profile.get("path", ""))
		if texture_path.is_empty() or not ResourceLoader.exists(texture_path):
			return _fail("Sprite asset is missing: %s (%s)" % [actor_id, texture_path])
		next_profiles[actor_id] = profile.duplicate(true)
	for alias_value: Variant in next_aliases.keys():
		var alias_id := str(alias_value)
		var target_id := str(next_aliases[alias_value])
		if alias_id.is_empty() or target_id.is_empty():
			return _fail("Sprite aliases must use non-empty IDs")
		if next_profiles.has(alias_id):
			return _fail("Sprite alias %s collides with a canonical profile" % alias_id)
		if not next_profiles.has(target_id):
			return _fail("Sprite alias %s targets an unknown profile" % alias_id)
	layout = next_layout
	aliases = next_aliases
	profiles = next_profiles
	return true


func canonical_id(actor_id: String) -> String:
	return str(aliases.get(actor_id, actor_id))


func has_actor(actor_id: String) -> bool:
	return profiles.has(canonical_id(actor_id))


func get_profile(actor_id: String) -> Dictionary:
	var resolved := canonical_id(actor_id)
	if not profiles.has(resolved):
		return {}
	return (profiles[resolved] as Dictionary).duplicate(true)


func get_texture_path(actor_id: String) -> String:
	return str(get_profile(actor_id).get("path", ""))


func actor_ids() -> Array[String]:
	var result: Array[String] = []
	for actor_id in profiles:
		result.append(str(actor_id))
	result.sort()
	return result


func _clear_public_state() -> void:
	layout.clear()
	aliases.clear()
	profiles.clear()


func _fail(message: String) -> bool:
	last_error = message
	return false
