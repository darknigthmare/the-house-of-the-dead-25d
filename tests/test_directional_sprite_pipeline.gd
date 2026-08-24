extends RefCounted

const ResolverType := preload("res://src/gameplay/directional_sprite_resolver.gd")
const SpriteActorType := preload("res://src/gameplay/sprite_actor_3d.gd")
const AtlasLibraryType := preload("res://src/gameplay/sprite_atlas_library.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var resolver = ResolverType.new()
	checks.append(_check(resolver.direction_count, 8, "resolver has eight view sectors"))
	checks.append(_check(resolver.frames_per_direction, 8, "resolver has eight frames per direction"))
	checks.append(_check(resolver.direction_order, [0, 1, 2, 3, 4, 5, 6, 7], "resolver keeps canonical row order"))

	for direction in 8:
		var angle := -float(direction) * TAU / 8.0
		var camera_position := Vector3(sin(angle), 0.0, -cos(angle)) * 10.0
		var first := resolver.resolve(Vector3.FORWARD, camera_position, Vector3.ZERO, 0) as Dictionary
		var last := resolver.resolve(Vector3.FORWARD, camera_position, Vector3.ZERO, 7) as Dictionary
		checks.append(_check(int(first.direction), direction, "direction center %d resolves" % direction))
		checks.append(_check(int(first.frame), direction * 8, "direction %d begins at its row" % direction))
		checks.append(_check(int(last.frame), direction * 8 + 7, "direction %d reaches its death cell" % direction))

	var before_boundary := resolver.resolve(Vector3.FORWARD, Vector3(sin(deg_to_rad(22.49)), 0.0, -cos(deg_to_rad(22.49))) * 10.0, Vector3.ZERO, 0) as Dictionary
	var after_boundary := resolver.resolve(Vector3.FORWARD, Vector3(sin(deg_to_rad(22.51)), 0.0, -cos(deg_to_rad(22.51))) * 10.0, Vector3.ZERO, 0) as Dictionary
	checks.append(_check(int(before_boundary.direction), 0, "sector stays front before 22.5 degree boundary"))
	checks.append(_check(int(after_boundary.direction), 7, "sector changes after 22.5 degree boundary"))

	resolver.mirror_symmetric_directions = true
	var mirrored := resolver.resolve(Vector3.FORWARD, Vector3(7.071, 0.0, -7.071), Vector3.ZERO, 3) as Dictionary
	checks.append(_check(int(mirrored.direction), 7, "mirrored sector retains its raw direction"))
	checks.append(_check(int(mirrored.sheet_direction), 1, "mirrored sector maps to the symmetric sheet row"))
	checks.append(_check(bool(mirrored.flip_h), true, "mirrored sector flips horizontally"))
	checks.append(_check(int(mirrored.frame), 11, "mirrored sector keeps the requested local frame"))
	resolver.mirror_symmetric_directions = false

	var sprite := Sprite3D.new()
	sprite.hframes = 8
	sprite.vframes = 8
	var applied_direction := resolver.apply_to_sprite(sprite, Vector3.FORWARD, Vector3(0.0, 0.0, -10.0), Vector3.ZERO, 7)
	checks.append(_check(applied_direction, 0, "resolver applies front sector to Sprite3D"))
	checks.append(_check(sprite.frame, 7, "resolver applies local frame without clamping"))
	sprite.free()

	var actor = SpriteActorType.new()
	checks.append(_check(actor.sheet_columns, 8, "SpriteActor3D defaults to eight columns"))
	checks.append(_check(actor.sheet_rows, 8, "SpriteActor3D defaults to eight rows"))
	actor.free()

	var library = AtlasLibraryType.new()
	checks.append(_check(library.load_manifest("res://data/assets/sprite_manifest.json"), true, "directional manifest loads"))
	checks.append(_check(library.actor_ids().size(), 38, "manifest exposes every dedicated organic identity"))
	checks.append(_check(library.has_actor("scientist"), true, "civilian alias resolves"))
	for scientist_id: String in ["scientist_male_blue", "scientist_male_gray", "scientist_female_lab"]:
		checks.append(_check(library.has_actor(scientist_id), true, "dedicated scientist profile resolves: %s" % scientist_id))
	checks.append(_check(library.has_actor("mutant_bat"), true, "Hangedman bat has a dedicated atlas"))
	checks.append(_check(library.get_profile("unknown_actor").is_empty(), true, "unknown actors never fall back to Sam"))
	return checks


static func _check(actual: Variant, expected: Variant, label: String) -> Dictionary:
	return {"actual": actual, "expected": expected, "label": label}
