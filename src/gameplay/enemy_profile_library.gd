class_name EnemyProfileLibrary
extends RefCounted

const DEFAULT_PATH := "res://data/enemies/enemy_profiles.json"

const PROJECTILE_ALIASES := {
	"vomit_burst": "organic_spit",
	"short_flame_jet": "magician_fireball",
	"launched_iron_claw": "iron_claw",
	"laser_dagger": "thrown_dagger",
}

var last_error: String = ""
var profiles: Dictionary = {}


func load_profiles(path: String = DEFAULT_PATH) -> bool:
	last_error = ""
	profiles.clear()
	if not FileAccess.file_exists(path):
		last_error = "Enemy profiles are missing: %s" % path
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		last_error = "Enemy profiles cannot be opened: %s" % path
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "Enemy profiles JSON is invalid"
		return false
	var payload := parsed as Dictionary
	if int(payload.get("schema_version", 0)) < 3:
		last_error = "Enemy profiles require schema 3"
		return false
	var source := payload.get("profiles", []) as Array
	if source.size() != 25:
		last_error = "Enemy roster must contain 25 profiles"
		return false
	var next_profiles := {}
	for value in source:
		if typeof(value) != TYPE_DICTIONARY:
			last_error = "Enemy profile entry must be an object"
			return false
		var profile := value as Dictionary
		var enemy_id := str(profile.get("id", ""))
		if enemy_id.is_empty() or next_profiles.has(enemy_id):
			last_error = "Enemy profile id is missing or duplicated: %s" % enemy_id
			return false
		var visual_path := str(profile.get("visual_base", ""))
		if visual_path.is_empty() or not ResourceLoader.exists(visual_path):
			last_error = "Enemy profile %s has missing visual: %s" % [enemy_id, visual_path]
			return false
		next_profiles[enemy_id] = profile.duplicate(true)
	profiles = next_profiles
	return true


func get_profile(enemy_id: String) -> Dictionary:
	return (profiles.get(enemy_id, {}) as Dictionary).duplicate(true)


func to_runtime_stats(enemy_id: String) -> Dictionary:
	var profile := get_profile(enemy_id)
	if profile.is_empty():
		return {}
	var archetype := str(profile.get("archetype", ""))
	var projectile := _projectile_profile(profile)
	# A projectile attack is only selected when the projectile can be seen and
	# intercepted. Non-destructible effects stay on their physical melee pattern.
	var has_readable_projectile := not projectile.is_empty() and bool(projectile.get("destructible", false))
	var runtime := {
		"health": float(profile.get("health", 3.0)),
		"speed": float(profile.get("speed", 1.0)),
		"scale": _runtime_scale(archetype),
		"score": int(profile.get("score", 80)),
		"behavior": _runtime_behavior(archetype, has_readable_projectile),
		"tint": "#ffffff",
		"attack_period": _attack_period(archetype),
		"attack_telegraph": _attack_telegraph(archetype),
		"melee_range": _melee_range(archetype),
		"attack_approach_speed": maxf(float(profile.get("speed", 1.0)), 1.25),
		"hitbox_profile": _hitbox_profile(archetype),
	}
	if has_readable_projectile:
		var projectile_kind := str(projectile.get("kind", ""))
		runtime["projectile_asset"] = str(PROJECTILE_ALIASES.get(projectile_kind, projectile_kind))
		runtime["projectile_destructible"] = true
		runtime["projectile_speed"] = _projectile_speed(projectile_kind)
		runtime["projectile_min_travel"] = 3.0
		runtime["projectile_contact_range"] = 1.35
	return runtime


func _runtime_behavior(archetype: String, has_readable_projectile: bool) -> String:
	if has_readable_projectile:
		return "throw_projectile"
	if archetype.contains("aquatic"):
		return "aquatic_weave"
	if archetype.contains("ceiling_drop") or archetype.contains("wall_crawling"):
		return "ceiling_drop"
	if archetype.contains("flying") or archetype.contains("swarming"):
		return "flight_swarm"
	if archetype.contains("leaping") or archetype.contains("rolling"):
		return "jump"
	if archetype.contains("charge") or archetype.contains("raider"):
		return "charge"
	if archetype.contains("heavy") or archetype.contains("brute") or archetype.contains("chainsaw"):
		return "heavy_weapon"
	return "walk"


func _projectile_profile(profile: Dictionary) -> Dictionary:
	var value: Variant = profile.get("projectile", null)
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return (value as Dictionary).duplicate(true)


func _hitbox_profile(archetype: String) -> String:
	if archetype.contains("flying") or archetype.contains("swarming"):
		return "flying_small"
	if archetype.contains("aquatic") or archetype.contains("serpentine"):
		return "low_creature"
	if archetype.contains("insectoid") or archetype.contains("wall_crawling"):
		return "crawler"
	if archetype.contains("heavy") or archetype.contains("brute") or archetype.contains("chainsaw"):
		return "heavy_humanoid"
	return "humanoid"


func _runtime_scale(archetype: String) -> float:
	match _hitbox_profile(archetype):
		"flying_small":
			return 0.52
		"low_creature":
			return 0.68
		"crawler":
			return 0.72
		"heavy_humanoid":
			return 1.2
		_:
			return 1.0


func _attack_period(archetype: String) -> float:
	if archetype.contains("flying") or archetype.contains("swarming"):
		return 1.25
	if archetype.contains("heavy") or archetype.contains("brute") or archetype.contains("chainsaw"):
		return 2.25
	return 1.75


func _attack_telegraph(archetype: String) -> float:
	if archetype.contains("heavy") or archetype.contains("brute") or archetype.contains("chainsaw"):
		return 0.9
	if archetype.contains("ceiling_drop") or archetype.contains("wall_crawling"):
		return 0.75
	if archetype.contains("flying") or archetype.contains("swarming"):
		return 0.55
	return 0.65


func _melee_range(archetype: String) -> float:
	match _hitbox_profile(archetype):
		"heavy_humanoid":
			return 2.8
		"flying_small":
			return 2.4
		"low_creature", "crawler":
			return 2.3
		_:
			return 2.5


func _projectile_speed(kind: String) -> float:
	match kind:
		"thrown_dagger", "laser_dagger":
			return 4.6
		"launched_iron_claw":
			return 4.1
		"vomit_burst", "organic_spit":
			return 3.7
		_:
			return 4.0
