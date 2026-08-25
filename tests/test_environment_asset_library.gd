extends SceneTree

const EnvironmentLibraryType := preload("res://src/gameplay/environment_asset_library.gd")
const MotionControllerType := preload("res://src/gameplay/environment_motion_controller.gd")
const PropStateControllerType := preload("res://src/gameplay/environment_prop_state_controller.gd")
const MANIFEST_PATH := "res://data/assets/environment_manifest.json"

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library: EnvironmentAssetLibrary = EnvironmentLibraryType.new()
	_expect_true(library.load_manifest(MANIFEST_PATH), "environment manifest loads with every generated path present (%s)" % library.last_error)
	_expect_equal(library.materials.size(), 20, "library exposes twenty individual materials")
	_expect_equal(library.styles.size(), 5, "library exposes five environment styles")
	_expect_equal(library.nodes.size(), 33, "library exposes all campaign sequence profiles")
	_expect_equal(library.destructibles.size(), 4, "library exposes four active two-state destructibles")
	_expect_equal(library.props.size(), 14, "library exposes fourteen environment props")
	_expect_equal(library.animated_effects.size(), 4, "library exposes four authored animated environment effects")
	for effect_id: String in ["drips", "water_flow", "electrical_arc", "monitor_scan"]:
		var effect_profile := library.get_animated_effect(effect_id)
		_expect_true(not effect_profile.is_empty(), "animated effect resolves: %s" % effect_id)
		_expect_true(FileAccess.file_exists(str(effect_profile.get("path", ""))), "animated effect strip exists: %s" % effect_id)
		_expect_equal(int(effect_profile.get("hframes", 0)), 8, "animated effect exposes eight frames: %s" % effect_id)
	_expect_true(library.get_animated_effect("missing_effect").is_empty(), "unknown animated effect never receives a proxy")
	for prop_id: String in ["mansion_chandelier", "mansion_sconce", "mansion_double_door", "library_bookcase", "mansion_portrait", "lab_control_console"]:
		var profile := library.get_prop(prop_id)
		_expect_true(not profile.is_empty(), "new authored prop resolves: %s" % prop_id)
		_expect_true(FileAccess.file_exists(str(profile.get("path", ""))), "new authored prop atlas exists: %s" % prop_id)
	for prop_id_variant: Variant in library.props.keys():
		var prop_id := str(prop_id_variant)
		var profile := library.get_prop(prop_id)
		var plane_height := float(profile.get("pixel_size", 0.0)) * float(profile.get("world_scale", 0.0)) * 1024.0
		_expect_true(
			plane_height >= 0.8 and plane_height <= 5.2,
			"prop world height stays plausible: %s (%0.3f m)" % [prop_id, plane_height]
		)

	var garden := library.get_scene_profile("garden_rescue", "mansion")
	_expect_equal(str(garden.get("style", "")), "garden", "node profile overrides the fallback style")
	_expect_equal(str(garden.get("floor", "")), "garden_mud_moss", "garden profile inherits its style floor")
	_expect_equal(str(garden.get("layout", "")), "estate_arrival", "garden sequence keeps its node-specific layout")
	_expect_equal((garden.get("props", []) as Array).size(), 3, "garden sequence carries three authored prop placements")

	var library_scene := library.get_scene_profile("library_rescue", "garden")
	_expect_equal(str(library_scene.get("wall", "")), "library_dark_oak_shelf", "library node overrides the mansion wall material")
	_expect_equal(str(library_scene.get("floor", "")), "mansion_marble_floor", "library node inherits the remaining mansion material set")
	_expect_equal((library_scene.get("props", []) as Array).size(), 3, "library sequence carries bookcases and chandelier")
	var unknown := library.get_scene_profile("not_a_campaign_node", "roof")
	_expect_equal(str(unknown.get("style", "")), "roof", "unknown node safely falls back to the requested style")
	_expect_equal(str(unknown.get("floor", "")), "roof_weathered_slate", "fallback style remains complete")

	var garden_gate := (garden.get("props", []) as Array)[0] as Dictionary
	var garden_gate_event := garden_gate.get("state_event", {}) as Dictionary
	_expect_equal(str(garden_gate_event.get("trigger", "")), "node_complete_success", "garden gate opens only on successful node completion")
	var garden_gate_sprite := Sprite3D.new()
	garden_gate_sprite.hframes = 2
	PropStateControllerType.configure_sprite(garden_gate_sprite, "estate_gate", 0, garden_gate)
	_expect_equal(garden_gate_sprite.frame, 0, "garden gate starts closed")
	_expect_false(PropStateControllerType.apply_pending_event(garden_gate_sprite, {"branch_success": true, "node_completing": false}), "garden gate does not open before route completion")
	_expect_true(PropStateControllerType.apply_pending_event(garden_gate_sprite, {"branch_success": true, "node_completing": true}), "garden gate opens on successful route completion")
	_expect_equal(garden_gate_sprite.frame, 1, "garden gate displays its open frame")

	var entrance := library.get_scene_profile("mansion_entrance", "garden")
	var entrance_gate := (entrance.get("props", []) as Array)[0] as Dictionary
	var entrance_gate_sprite := Sprite3D.new()
	entrance_gate_sprite.hframes = 2
	PropStateControllerType.configure_sprite(entrance_gate_sprite, "estate_gate", 0, entrance_gate)
	_expect_equal(entrance_gate_sprite.frame, 1, "mansion entrance preserves the previously opened gate")

	var foyer := library.get_scene_profile("foyer_choice", "mansion")
	var foyer_door := (foyer.get("props", []) as Array)[0] as Dictionary
	var foyer_door_event := foyer_door.get("state_event", {}) as Dictionary
	_expect_equal(str(foyer_door_event.get("breakable_id", "")), "c01_foyer_door_lock", "foyer door targets its explicit lock event")
	var foyer_door_sprite := Sprite3D.new()
	foyer_door_sprite.hframes = 2
	PropStateControllerType.configure_sprite(foyer_door_sprite, "mansion_double_door", 0, foyer_door)
	_expect_false(PropStateControllerType.apply_pending_event(foyer_door_sprite, {"branch_success": true, "breakable_destroyed": false, "node_completing": false, "breakable_id": "c01_foyer_door_lock"}), "civilian success alone cannot open the foyer door")
	_expect_false(PropStateControllerType.apply_pending_event(foyer_door_sprite, {"branch_success": false, "breakable_destroyed": true, "node_completing": false, "breakable_id": "wrong_lock"}), "unrelated breakable cannot open the foyer door")
	_expect_true(PropStateControllerType.apply_pending_event(foyer_door_sprite, {"branch_success": false, "breakable_destroyed": true, "node_completing": false, "breakable_id": "c01_foyer_door_lock"}), "destroying the foyer lock opens its door without a shared branch flag")
	_expect_equal(foyer_door_sprite.frame, 1, "foyer door displays its open frame")
	_expect_false(PropStateControllerType.apply_pending_event(foyer_door_sprite, {"branch_success": false, "breakable_destroyed": true, "node_completing": false, "breakable_id": "c01_foyer_door_lock"}), "door state event is one-shot")

	var specimen_bay := library.get_scene_profile("back_attack_rescue", "laboratory")
	var specimen_props := specimen_bay.get("props", []) as Array
	var intact_tank := specimen_props[0] as Dictionary
	var breached_tank := specimen_props[1] as Dictionary
	_expect_true(not intact_tank.has("state_event"), "first specimen-bay tank remains explicitly intact")
	var tank_sprite := Sprite3D.new()
	tank_sprite.hframes = 2
	PropStateControllerType.configure_sprite(tank_sprite, "lab_specimen_tank", 1, breached_tank)
	_expect_false(PropStateControllerType.apply_pending_event(tank_sprite, {"node_elapsed": 3.29}), "specimen tank stays intact before its breach timestamp")
	_expect_equal(tank_sprite.frame, 0, "specimen tank still displays intact frame before event")
	_expect_true(PropStateControllerType.apply_pending_event(tank_sprite, {"node_elapsed": 3.3}), "specimen tank breaks at its exact authored timestamp")
	_expect_equal(tank_sprite.frame, 1, "specimen tank displays its broken frame after event")

	var magician := library.get_scene_profile("magician_battle", "laboratory")
	var magician_tanks := magician.get("props", []) as Array
	var phase_two_tank_sprite := Sprite3D.new()
	phase_two_tank_sprite.hframes = 2
	PropStateControllerType.configure_sprite(phase_two_tank_sprite, "lab_specimen_tank", 0, magician_tanks[0] as Dictionary)
	_expect_false(PropStateControllerType.apply_pending_event(phase_two_tank_sprite, {"boss_phase": 0}), "Magician arena tank remains intact in phase one")
	_expect_true(PropStateControllerType.apply_pending_event(phase_two_tank_sprite, {"boss_phase": 1}), "Magician phase two breaches the left tank")
	_expect_equal(str(phase_two_tank_sprite.get_meta(PropStateControllerType.META_TRIGGERED_ID, "")), "magician_phase_two_left_tank_breach", "trigger metadata records the exact event id")

	var lock_profile := library.get_destructible("c01_foyer_door_lock")
	_expect_true(FileAccess.file_exists(str(lock_profile.get("intact", ""))), "foyer lock intact state resolves")
	_expect_true(FileAccess.file_exists(str(lock_profile.get("broken", ""))), "foyer lock broken state resolves")
	_expect_true(library.get_destructible("missing_destructible").is_empty(), "unknown destructible never receives a placeholder")

	var lamp_profile := library.get_prop("garden_lamp")
	_expect_equal(int(lamp_profile.get("hframes", 0)), 2, "animated garden lamp exposes two frames")
	_expect_equal(str(lamp_profile.get("animate", "")), "flicker", "animated garden lamp keeps its motion contract")
	_expect_true(FileAccess.file_exists(str(lamp_profile.get("path", ""))), "garden lamp atlas resolves")
	_expect_true(float(lamp_profile.get("pixel_size", 0.0)) * float(lamp_profile.get("world_scale", 0.0)) * 1024.0 <= 2.5, "garden lamp keeps human-scale proportions")
	var chandelier_profile := library.get_prop("mansion_chandelier")
	_expect_equal(int(chandelier_profile.get("hframes", 0)), 2, "mansion chandelier exposes two flame states")
	_expect_equal(str(chandelier_profile.get("animate", "")), "flicker", "mansion chandelier uses flicker motion")
	_expect_true(float(chandelier_profile.get("pixel_size", 0.0)) * float(chandelier_profile.get("world_scale", 0.0)) * 1024.0 <= 2.6, "chandelier keeps room-scale proportions")
	var sconce_profile := library.get_prop("mansion_sconce")
	_expect_true(float(sconce_profile.get("pixel_size", 0.0)) * float(sconce_profile.get("world_scale", 0.0)) * 1024.0 <= 1.25, "wall sconce keeps fixture-scale proportions")
	var door_profile := library.get_prop("mansion_double_door")
	_expect_equal(int(door_profile.get("hframes", 0)), 2, "mansion door exposes closed and open states")
	_expect_true(not door_profile.has("animate"), "mansion door state is event-driven rather than auto-looped")
	var console_profile := library.get_prop("lab_control_console")
	_expect_equal(int(console_profile.get("hframes", 0)), 2, "laboratory console exposes green and alarm states")
	_expect_equal(str(console_profile.get("animate", "")), "screen_glow", "laboratory console uses non-destructive screen glow")
	var tank_profile := library.get_prop("lab_specimen_tank")
	_expect_equal(int(tank_profile.get("hframes", 0)), 2, "laboratory tank exposes intact and broken states")
	_expect_true(not tank_profile.has("animate"), "laboratory tank broken state is event-driven rather than auto-looped")
	_expect_true(library.get_prop("missing_prop").is_empty(), "unknown prop never receives a placeholder")

	var flicker_sprite := Sprite3D.new()
	flicker_sprite.hframes = 2
	flicker_sprite.modulate = Color(1.0, 0.9, 0.72, 0.63)
	var flicker_motion := MotionControllerType.new()
	flicker_motion.configure_target(flicker_sprite, "flicker")
	flicker_motion._process(0.24)
	_expect_true(is_equal_approx(flicker_sprite.modulate.a, 0.63), "lamp flicker preserves authored alpha")
	_expect_true(flicker_sprite.modulate.r >= 0.90, "lamp flicker never simulates a full blackout")

	var console_sprite := Sprite3D.new()
	console_sprite.hframes = 2
	console_sprite.frame = 1
	console_sprite.modulate = Color(0.8, 0.9, 1.0, 0.57)
	var console_motion := MotionControllerType.new()
	console_motion.configure_target(console_sprite, "screen_glow")
	console_motion._process(0.35)
	_expect_equal(console_sprite.frame, 1, "screen glow does not toggle console state frames")
	_expect_true(is_equal_approx(console_sprite.modulate.a, 0.57), "screen glow preserves authored alpha")

	var sconce_light := OmniLight3D.new()
	sconce_light.light_energy = 2.0
	var sconce_motion := MotionControllerType.new()
	sconce_motion.configure_target(sconce_light, "sconce")
	sconce_motion._process(0.62)
	_expect_true(sconce_light.light_energy >= 1.5, "sconce light animation never approaches the off state")

	var effect_sprite := Sprite3D.new()
	effect_sprite.hframes = 8
	effect_sprite.set_meta("animation_fps", 8.0)
	var effect_motion := MotionControllerType.new()
	effect_motion.configure_target(effect_sprite, "effect_strip")
	effect_motion._process(0.26)
	_expect_equal(effect_sprite.frame, 2, "effect strip advances deterministically at its authored frame rate")
	flicker_motion.free()
	flicker_sprite.free()
	console_motion.free()
	console_sprite.free()
	sconce_motion.free()
	sconce_light.free()
	effect_motion.free()
	effect_sprite.free()
	garden_gate_sprite.free()
	entrance_gate_sprite.free()
	foyer_door_sprite.free()
	tank_sprite.free()
	phase_two_tank_sprite.free()

	var material := library.create_material("lab_painted_metal")
	_expect_true(material.albedo_texture != null, "PBR material loads its albedo")
	_expect_true(material.normal_enabled and material.normal_texture != null, "PBR material loads and enables its normal map")
	_expect_true(material.ao_enabled and material.ao_texture != null, "PBR material loads and enables packed AO")
	_expect_true(material.roughness_texture != null, "PBR material loads packed roughness")
	_expect_true(material.metallic_texture != null, "PBR material loads packed metallic")
	_expect_equal(material.ao_texture_channel, BaseMaterial3D.TEXTURE_CHANNEL_RED, "AO uses the red ORM channel")
	_expect_equal(material.roughness_texture_channel, BaseMaterial3D.TEXTURE_CHANNEL_GREEN, "roughness uses the green ORM channel")
	_expect_equal(material.metallic_texture_channel, BaseMaterial3D.TEXTURE_CHANNEL_BLUE, "metallic uses the blue ORM channel")
	_expect_equal(material.uv1_scale, Vector3(2.0, 5.0, 1.0), "material applies its authored UV scale")

	var duplicate := library.create_material("lab_painted_metal")
	_expect_true(duplicate != material, "cached materials are duplicated per consumer")
	duplicate.roughness = 0.1
	var third := library.create_material("lab_painted_metal")
	_expect_true(not is_equal_approx(third.roughness, duplicate.roughness), "consumer edits cannot mutate the cached material template")

	var missing := library.create_material("missing_material")
	_expect_true(missing != null, "unknown material returns a safe empty material")
	_expect_true(missing.albedo_texture == null, "unknown material does not silently borrow another texture")

	var missing_manifest_library: EnvironmentAssetLibrary = EnvironmentLibraryType.new()
	_expect_false(missing_manifest_library.load_manifest("res://data/assets/does_not_exist.json"), "missing manifest fails cleanly")
	_expect_true(missing_manifest_library.last_error.contains("missing"), "missing manifest reports a useful error")
	_expect_true(missing_manifest_library.materials.is_empty(), "failed load exposes no partial material set")

	if _failures == 0:
		print("ENVIRONMENT ASSET LIBRARY TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("ENVIRONMENT ASSET LIBRARY TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _expect_true(actual: bool, label: String) -> void:
	_expect_equal(actual, true, label)


func _expect_false(actual: bool, label: String) -> void:
	_expect_equal(actual, false, label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual == expected:
		return
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
