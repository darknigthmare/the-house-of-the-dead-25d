class_name GameplaySupportLibrary
extends RefCounted

const DEFAULT_MANIFEST_PATH := "res://data/assets/gameplay_support_manifest.json"

var last_error: String = ""
var projectiles: Dictionary = {}
var ui: Dictionary = {}
var weakpoints: Dictionary = {}


func load_manifest(path: String = DEFAULT_MANIFEST_PATH) -> bool:
	last_error = ""
	projectiles.clear()
	ui.clear()
	weakpoints.clear()
	if not FileAccess.file_exists(path):
		last_error = "Gameplay support manifest is missing: %s" % path
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Gameplay support manifest cannot be opened: %s" % path
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Gameplay support manifest is invalid JSON"
		return false
	var candidate := parsed as Dictionary
	if int(candidate.get("schema_version", 0)) != 1:
		last_error = "Unsupported gameplay support manifest schema"
		return false
	for key in ["projectiles", "ui", "weakpoints"]:
		if typeof(candidate.get(key, {})) != TYPE_DICTIONARY:
			last_error = "Gameplay support field '%s' must be an object" % key
			return false
	var next_projectiles := (candidate.get("projectiles", {}) as Dictionary).duplicate(true)
	var next_ui := (candidate.get("ui", {}) as Dictionary).duplicate(true)
	var next_weakpoints := (candidate.get("weakpoints", {}) as Dictionary).duplicate(true)
	for group: Dictionary in [next_projectiles, next_ui, next_weakpoints]:
		for asset_id in group:
			var profile := group[asset_id] as Dictionary
			var asset_path := str(profile.get("path", ""))
			if asset_path.is_empty() or not ResourceLoader.exists(asset_path):
				last_error = "Gameplay support asset %s has missing path: %s" % [asset_id, asset_path]
				return false
	projectiles = next_projectiles
	ui = next_ui
	weakpoints = next_weakpoints
	return true


func get_projectile(asset_id: String) -> Dictionary:
	return (projectiles.get(asset_id, {}) as Dictionary).duplicate(true)


func get_ui(asset_id: String) -> Dictionary:
	return (ui.get(asset_id, {}) as Dictionary).duplicate(true)


func get_weakpoint(boss_id: String) -> Dictionary:
	return (weakpoints.get(boss_id, {}) as Dictionary).duplicate(true)


func load_texture(profile: Dictionary) -> Texture2D:
	var asset_path := str(profile.get("path", ""))
	if asset_path.is_empty():
		return null
	return load(asset_path) as Texture2D
