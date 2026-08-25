class_name EnvironmentAssetLibrary
extends RefCounted

const DEFAULT_MANIFEST_PATH := "res://data/assets/environment_manifest.json"

var last_error: String = ""
var manifest: Dictionary = {}
var materials: Dictionary = {}
var styles: Dictionary = {}
var nodes: Dictionary = {}
var destructibles: Dictionary = {}
var props: Dictionary = {}
var animated_effects: Dictionary = {}
var _material_cache: Dictionary = {}


func load_manifest(path: String = DEFAULT_MANIFEST_PATH) -> bool:
	last_error = ""
	manifest.clear()
	materials.clear()
	styles.clear()
	nodes.clear()
	destructibles.clear()
	props.clear()
	animated_effects.clear()
	_material_cache.clear()
	if not FileAccess.file_exists(path):
		last_error = "Environment manifest is missing: %s" % path
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Environment manifest cannot be opened: %s" % path
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Environment manifest is invalid JSON"
		return false
	var candidate := parsed as Dictionary
	if int(candidate.get("schema_version", 0)) != 1:
		last_error = "Unsupported environment manifest schema"
		return false
	for key in ["materials", "styles", "nodes", "destructibles", "props", "animated_effects"]:
		if typeof(candidate.get(key, {})) != TYPE_DICTIONARY:
			last_error = "Environment manifest field '%s' must be an object" % key
			return false
	manifest = candidate
	materials = (candidate.get("materials", {}) as Dictionary).duplicate(true)
	styles = (candidate.get("styles", {}) as Dictionary).duplicate(true)
	nodes = (candidate.get("nodes", {}) as Dictionary).duplicate(true)
	destructibles = (candidate.get("destructibles", {}) as Dictionary).duplicate(true)
	props = (candidate.get("props", {}) as Dictionary).duplicate(true)
	animated_effects = (candidate.get("animated_effects", {}) as Dictionary).duplicate(true)
	return _validate_paths()


func get_scene_profile(node_id: String, fallback_style: String) -> Dictionary:
	var style_id := fallback_style
	var profile := {}
	if nodes.has(node_id):
		profile = (nodes[node_id] as Dictionary).duplicate(true)
		style_id = str(profile.get("style", fallback_style))
	var style_profile := (styles.get(style_id, {}) as Dictionary).duplicate(true)
	for key in profile:
		style_profile[key] = profile[key]
	style_profile["style"] = style_id
	style_profile["node_id"] = node_id
	return style_profile


func get_destructible(asset_id: String) -> Dictionary:
	if not destructibles.has(asset_id):
		return {}
	return (destructibles[asset_id] as Dictionary).duplicate(true)


func get_prop(prop_id: String) -> Dictionary:
	if not props.has(prop_id):
		return {}
	return (props[prop_id] as Dictionary).duplicate(true)


func get_animated_effect(effect_id: String) -> Dictionary:
	if not animated_effects.has(effect_id):
		return {}
	return (animated_effects[effect_id] as Dictionary).duplicate(true)


func create_material(material_id: String) -> StandardMaterial3D:
	if _material_cache.has(material_id):
		return (_material_cache[material_id] as StandardMaterial3D).duplicate() as StandardMaterial3D
	if not materials.has(material_id):
		return StandardMaterial3D.new()
	var profile := materials[material_id] as Dictionary
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(str(profile.get("tint", "#ffffff")))
	material.roughness = clampf(float(profile.get("roughness", 0.82)), 0.0, 1.0)
	material.metallic = clampf(float(profile.get("metallic", 0.0)), 0.0, 1.0)
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	var albedo := load(str(profile.get("albedo", ""))) as Texture2D
	if albedo != null:
		material.albedo_texture = albedo
	var normal := load(str(profile.get("normal", ""))) as Texture2D
	if normal != null:
		material.normal_enabled = true
		material.normal_texture = normal
		material.normal_scale = float(profile.get("normal_scale", 0.65))
	var orm := load(str(profile.get("orm", ""))) as Texture2D
	if orm != null:
		material.ao_enabled = true
		material.ao_texture = orm
		material.ao_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
		material.roughness_texture = orm
		material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_GREEN
		material.metallic_texture = orm
		material.metallic_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_BLUE
	var uv_scale := profile.get("uv_scale", [1.0, 1.0]) as Array
	if uv_scale.size() >= 2:
		material.uv1_scale = Vector3(float(uv_scale[0]), float(uv_scale[1]), 1.0)
	_material_cache[material_id] = material
	return material.duplicate() as StandardMaterial3D


func _validate_paths() -> bool:
	for material_id in materials:
		var profile := materials[material_id] as Dictionary
		for key in ["albedo", "normal", "orm"]:
			var path := str(profile.get(key, ""))
			if path.is_empty() or not ResourceLoader.exists(path):
				last_error = "Environment material %s has missing %s: %s" % [material_id, key, path]
				return false
	for destructible_id in destructibles:
		var profile := destructibles[destructible_id] as Dictionary
		for key in ["intact", "broken"]:
			var path := str(profile.get(key, ""))
			if path.is_empty() or not ResourceLoader.exists(path):
				last_error = "Destructible %s has missing %s: %s" % [destructible_id, key, path]
				return false
	for prop_id in props:
		var profile := props[prop_id] as Dictionary
		var path := str(profile.get("path", ""))
		if not path.is_empty() and not ResourceLoader.exists(path):
			last_error = "Environment prop %s has missing path: %s" % [prop_id, path]
			return false
	for effect_id in animated_effects:
		var profile := animated_effects[effect_id] as Dictionary
		var path := str(profile.get("path", ""))
		if path.is_empty() or not ResourceLoader.exists(path):
			last_error = "Animated environment effect %s has missing path: %s" % [effect_id, path]
			return false
	return true
