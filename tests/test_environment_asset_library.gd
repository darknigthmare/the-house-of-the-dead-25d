extends SceneTree

const EnvironmentLibraryType := preload("res://src/gameplay/environment_asset_library.gd")
const MANIFEST_PATH := "res://data/assets/environment_manifest.json"

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library: EnvironmentAssetLibrary = EnvironmentLibraryType.new()
	_expect_true(library.load_manifest(MANIFEST_PATH), "environment manifest loads with every generated path present")
	_expect_equal(library.materials.size(), 20, "library exposes twenty individual materials")
	_expect_equal(library.styles.size(), 5, "library exposes five environment styles")
	_expect_equal(library.nodes.size(), 33, "library exposes all campaign sequence profiles")
	_expect_equal(library.destructibles.size(), 6, "library exposes six two-state destructibles")
	_expect_equal(library.props.size(), 14, "library exposes fourteen environment props")
	for prop_id: String in ["mansion_chandelier", "mansion_sconce", "mansion_double_door", "library_bookcase", "mansion_portrait", "lab_control_console"]:
		var profile := library.get_prop(prop_id)
		_expect_true(not profile.is_empty(), "new authored prop resolves: %s" % prop_id)
		_expect_true(FileAccess.file_exists(str(profile.get("path", ""))), "new authored prop atlas exists: %s" % prop_id)

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

	var lock_profile := library.get_destructible("c01_foyer_door_lock")
	_expect_true(FileAccess.file_exists(str(lock_profile.get("intact", ""))), "foyer lock intact state resolves")
	_expect_true(FileAccess.file_exists(str(lock_profile.get("broken", ""))), "foyer lock broken state resolves")
	_expect_true(library.get_destructible("missing_destructible").is_empty(), "unknown destructible never receives a placeholder")

	var lamp_profile := library.get_prop("garden_lamp")
	_expect_equal(int(lamp_profile.get("hframes", 0)), 2, "animated garden lamp exposes two frames")
	_expect_equal(str(lamp_profile.get("animate", "")), "flicker", "animated garden lamp keeps its motion contract")
	_expect_true(FileAccess.file_exists(str(lamp_profile.get("path", ""))), "garden lamp atlas resolves")
	var chandelier_profile := library.get_prop("mansion_chandelier")
	_expect_equal(int(chandelier_profile.get("hframes", 0)), 2, "mansion chandelier exposes two flame states")
	_expect_equal(str(chandelier_profile.get("animate", "")), "flicker", "mansion chandelier uses flicker motion")
	var door_profile := library.get_prop("mansion_double_door")
	_expect_equal(int(door_profile.get("hframes", 0)), 2, "mansion door exposes closed and open states")
	_expect_true(not door_profile.has("animate"), "mansion door state is event-driven rather than auto-looped")
	var console_profile := library.get_prop("lab_control_console")
	_expect_equal(int(console_profile.get("hframes", 0)), 2, "laboratory console exposes green and alarm states")
	_expect_equal(str(console_profile.get("animate", "")), "pulse", "laboratory console uses pulse motion")
	_expect_true(library.get_prop("missing_prop").is_empty(), "unknown prop never receives a placeholder")

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
