extends SceneTree

const AtlasLibraryType := preload("res://src/gameplay/sprite_atlas_library.gd")
const MANIFEST_PATH := "res://data/assets/sprite_manifest.json"
const EXPECTED_ALIASES := {
	"scientist": "dbr_scientist",
	"sophie": "sophie_richards",
	"curien": "dr_curien",
	"axe_creature": "cyril_a3"
}

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library: SpriteAtlasLibrary = AtlasLibraryType.new()
	_expect_true(library.load_manifest(MANIFEST_PATH), "valid v2 manifest loads")
	_expect_equal(library.actor_ids().size(), 38, "manifest commits exactly 38 v2 profiles")
	_expect_equal(library.aliases.size(), EXPECTED_ALIASES.size(), "manifest commits the complete alias table")
	for alias_id: String in EXPECTED_ALIASES:
		var canonical_id := str(EXPECTED_ALIASES[alias_id])
		_expect_equal(library.canonical_id(alias_id), canonical_id, "alias %s resolves canonically" % alias_id)
		_expect_true(library.has_actor(alias_id), "alias %s resolves to a loaded profile" % alias_id)
	for scientist_id: String in ["scientist_male_blue", "scientist_male_gray", "scientist_female_lab"]:
		_expect_true(library.has_actor(scientist_id), "dedicated scientist profile resolves: %s" % scientist_id)
	for actor_id: String in library.actor_ids():
		_expect_equal(int(library.get_profile(actor_id).get("contract_version", 0)), 2, "%s uses contract v2" % actor_id)
	_expect_false(library.has_actor("unknown_actor"), "unknown actor has no implicit profile")
	_expect_true(library.get_profile("unknown_actor").is_empty(), "unknown actor profile remains empty")
	_expect_equal(library.get_texture_path("unknown_actor"), "", "unknown actor texture path remains empty")

	var invalid_path := "user://sprite_manifest_late_failure_%d.json" % Time.get_ticks_usec()
	_expect_true(_write_manifest_with_invalid_late_alias(invalid_path), "late-failure fixture is written")
	_expect_false(library.load_manifest(invalid_path), "invalid late alias rejects the entire manifest")
	_expect_true(library.last_error.contains("unknown profile"), "late alias error is reported")
	_expect_true(library.layout.is_empty(), "layout remains empty after late validation failure")
	_expect_true(library.aliases.is_empty(), "aliases remain empty after late validation failure")
	_expect_true(library.profiles.is_empty(), "profiles remain empty after late validation failure")
	_expect_true(library.actor_ids().is_empty(), "no partially validated actor is visible")
	_expect_true(library.get_profile("sam_a1").is_empty(), "failed load does not retain a fallback profile")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(invalid_path))

	if _failures == 0:
		print("SPRITE ATLAS ATOMIC TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("SPRITE ATLAS ATOMIC TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _write_manifest_with_invalid_late_alias(path: String) -> bool:
	var source := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if source == null:
		return false
	var parsed: Variant = JSON.parse_string(source.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var manifest := parsed as Dictionary
	var fixture_aliases := (manifest.get("aliases", {}) as Dictionary).duplicate(true)
	fixture_aliases["late_invalid_alias"] = "missing_v2_profile"
	manifest["aliases"] = fixture_aliases
	var fixture := FileAccess.open(path, FileAccess.WRITE)
	if fixture == null:
		return false
	fixture.store_string(JSON.stringify(manifest))
	fixture.close()
	return true


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
