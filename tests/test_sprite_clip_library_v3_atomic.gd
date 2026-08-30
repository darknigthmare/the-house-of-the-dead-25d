extends SceneTree

const LibraryType := preload("res://src/gameplay/sprite_clip_library_v3.gd")
const TEXTURE_PATH := "res://assets/sprites_v2/enemies/sam_a1/sam_a1__v2__action_cycle__8dirx8f.png"
const DIRECTIONS := [
	"front", "front_left", "left", "back_left",
	"back", "back_right", "right", "front_right",
]
const REQUIRED_CLIPS := [
	"idle", "move", "attack_windup",
	"attack_strike", "hit_recoil", "death_fall",
]

var _assertions: int = 0
var _failures: int = 0
var _fixture_paths: Array[String] = []
var _texture_sha256: String = ""


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_texture_sha256 = FileAccess.get_sha256(TEXTURE_PATH)
	_expect_true(not _texture_sha256.is_empty(), "fixture texture has a readable SHA-256")
	_test_empty_production_manifest_loads()
	_test_partial_profile_loads_with_fallback()
	_test_complete_profile_is_runtime_ready()
	_test_invalid_alias_is_atomic()
	_test_invalid_fallback_is_rejected()
	_test_invalid_path_is_rejected()
	_test_invalid_sha_is_rejected()
	_test_mismatched_sha_is_rejected()
	_test_invalid_display_scale_is_rejected()
	_test_direction_order_is_exact()
	_test_late_failure_clears_previous_state()
	_cleanup_fixtures()
	if _failures == 0:
		print("SPRITE CLIP LIBRARY V3 ATOMIC TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("SPRITE CLIP LIBRARY V3 ATOMIC TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _test_empty_production_manifest_loads() -> void:
	var library = LibraryType.new()
	var path := _write_fixture("empty", _manifest([]))
	_expect_true(library.load_manifest(path), "manifest can load before any V3 production profile exists")
	_expect_true(library.actor_ids().is_empty(), "optional production profiles remain empty")
	_expect_equal(library.direction_order, DIRECTIONS, "empty manifest still publishes the exact direction contract")
	_expect_equal(library.required_clips, REQUIRED_CLIPS, "empty manifest still publishes the required clip contract")


func _test_partial_profile_loads_with_fallback() -> void:
	var library = LibraryType.new()
	var profile := _profile("sam_a1", "sam_a1", {"idle": _valid_clip()})
	var path := _write_fixture("partial", _manifest([profile], {"sam_pilot": "sam_a1"}))
	_expect_true(library.load_manifest(path), "partial production profile loads")
	_expect_true(library.has_actor("sam_a1"), "partial canonical actor is published")
	_expect_true(library.has_actor("sam_pilot"), "partial actor alias resolves")
	_expect_equal(library.actor_ids(), ["sam_a1"], "actor_ids excludes aliases")
	_expect_equal(str(library.get_profile("sam_pilot").get("fallback_v2_id", "")), "sam_a1", "profile exposes its V2 fallback")
	_expect_equal(str(library.get_clip("sam_a1", "idle").get("path", "")), TEXTURE_PATH, "valid partial clip is available")
	_expect_true(library.get_clip("sam_a1", "move").is_empty(), "missing production clip stays absent")
	_expect_false(library.is_runtime_ready("sam_a1"), "partial profile is not runtime-ready")
	_expect_true(library.fallback_reason("sam_pilot").contains("missing_required_clips:move"), "partial profile reports deterministic missing clips")
	var detached: Dictionary = library.get_profile("sam_a1")
	detached["fallback_v2_id"] = "mutated"
	_expect_equal(str(library.get_profile("sam_a1").get("fallback_v2_id", "")), "sam_a1", "profile reads are defensive copies")


func _test_complete_profile_is_runtime_ready() -> void:
	var library = LibraryType.new()
	var clips: Dictionary = {}
	for clip_id: String in REQUIRED_CLIPS:
		clips[clip_id] = _valid_clip()
	var path := _write_fixture("complete", _manifest([_profile("sam_a1", "sam_a1", clips)], {"sam_pilot": "sam_a1"}))
	_expect_true(library.load_manifest(path), "complete simulated V3 profile loads")
	_expect_true(library.is_runtime_ready("sam_a1"), "complete profile is runtime-ready")
	_expect_true(library.is_runtime_ready("sam_pilot"), "runtime-ready status follows aliases")
	_expect_equal(library.fallback_reason("sam_a1"), "", "ready profile has no fallback reason")
	_expect_equal(int(library.get_clip("sam_a1", "death_fall").get("sheet_rows", 0)), 8, "clip normalizes eight direction rows")
	_expect_equal(int(library.get_clip("sam_a1", "death_fall").get("sheet_columns", 0)), 8, "clip normalizes its frame columns")
	_expect_equal(int(library.get_clip("sam_a1", "death_fall").get("cell_px", 0)), 256, "clip geometry resolves square cells")
	_expect_equal(library.fallback_reason("unknown_actor"), "unknown_actor:unknown_actor", "unknown actor reports an explicit fallback reason")


func _test_invalid_alias_is_atomic() -> void:
	var manifest := _manifest([_complete_profile("sam_a1")], {"bad_alias": "missing_profile"})
	_expect_rejected(manifest, "unknown profile", "invalid alias")


func _test_invalid_fallback_is_rejected() -> void:
	var profile := _complete_profile("sam_a1")
	profile["fallback_v2_id"] = "../sam"
	_expect_rejected(_manifest([profile]), "fallback_v2_id", "invalid fallback ID")


func _test_invalid_path_is_rejected() -> void:
	var profile := _complete_profile("sam_a1")
	(profile["clips"] as Dictionary)["idle"] = _valid_clip("res://assets/sprites_v3/missing_fixture.png")
	_expect_rejected(_manifest([profile]), "path is missing", "missing clip path")


func _test_invalid_sha_is_rejected() -> void:
	var profile := _complete_profile("sam_a1")
	var clip := _valid_clip()
	clip["sha256"] = "not-a-sha"
	(profile["clips"] as Dictionary)["idle"] = clip
	_expect_rejected(_manifest([profile]), "sha256 is invalid", "malformed clip SHA-256")


func _test_mismatched_sha_is_rejected() -> void:
	var profile := _complete_profile("sam_a1")
	var clip := _valid_clip()
	clip["sha256"] = "0".repeat(64)
	(profile["clips"] as Dictionary)["idle"] = clip
	_expect_rejected(_manifest([profile]), "sha256 mismatch", "mismatched clip SHA-256")


func _test_invalid_display_scale_is_rejected() -> void:
	var profile := _complete_profile("sam_a1")
	var clip := _valid_clip()
	clip["display_scale"] = 2.0
	(profile["clips"] as Dictionary)["idle"] = clip
	_expect_rejected(_manifest([profile]), "display_scale", "unsafe clip display scale")


func _test_direction_order_is_exact() -> void:
	var manifest := _manifest([_complete_profile("sam_a1")])
	var wrong_directions := DIRECTIONS.duplicate()
	var right_value: Variant = wrong_directions[6]
	wrong_directions[6] = wrong_directions[7]
	wrong_directions[7] = right_value
	manifest["direction_order"] = wrong_directions
	_expect_rejected(manifest, "canonical eight directions", "non-canonical direction order")


func _test_late_failure_clears_previous_state() -> void:
	var library = LibraryType.new()
	var valid_path := _write_fixture("atomic_valid", _manifest([_complete_profile("sam_a1")]))
	_expect_true(library.load_manifest(valid_path), "atomic fixture first publishes a valid profile")
	_expect_true(library.has_actor("sam_a1"), "valid state is initially visible")
	var late_manifest := _manifest(
		[_complete_profile("sam_a1"), _profile("neil_a2", "neil_a2", {"idle": _valid_clip()})],
		{"late_invalid_alias": "missing_profile"}
	)
	var late_path := _write_fixture("atomic_late", late_manifest)
	_expect_false(library.load_manifest(late_path), "late alias failure rejects the replacement manifest")
	_expect_true(library.last_error.contains("unknown profile"), "late failure reports its precise cause")
	_expect_true(library.actor_ids().is_empty(), "late failure publishes no temporary profiles")
	_expect_false(library.has_actor("sam_a1"), "late failure clears the previously published state")
	_expect_true(library.get_profile("neil_a2").is_empty(), "late profile never leaks through atomic validation")
	_expect_true(library.direction_order.is_empty(), "late failure leaves no root direction state")
	_expect_true(library.required_clips.is_empty(), "late failure leaves no root clip contract state")


func _manifest(profiles: Array, aliases: Dictionary = {}) -> Dictionary:
	return {
		"schema_version": 3,
		"direction_order": DIRECTIONS.duplicate(),
		"required_clips": REQUIRED_CLIPS.duplicate(),
		"profiles": profiles,
		"aliases": aliases,
	}


func _complete_profile(actor_id: String) -> Dictionary:
	var clips: Dictionary = {}
	for clip_id: String in REQUIRED_CLIPS:
		clips[clip_id] = _valid_clip()
	return _profile(actor_id, actor_id, clips)


func _profile(actor_id: String, fallback_v2_id: String, clips: Dictionary) -> Dictionary:
	return {
		"id": actor_id,
		"fallback_v2_id": fallback_v2_id,
		"clips": clips,
	}


func _valid_clip(path: String = TEXTURE_PATH) -> Dictionary:
	return {
		"path": path,
		"frame_count": 8,
		"fps": 10.0,
		"loop": true,
		"hold_last": false,
		"display_scale": 1.0,
		"sha256": _texture_sha256,
		"provenance": {
			"source": "atomic_test_fixture",
			"direction_order": DIRECTIONS.duplicate(),
		},
	}


func _expect_rejected(manifest: Dictionary, error_fragment: String, label: String) -> void:
	var library = LibraryType.new()
	var path := _write_fixture("rejected_%d" % _fixture_paths.size(), manifest)
	_expect_false(library.load_manifest(path), "%s is rejected" % label)
	_expect_true(library.last_error.contains(error_fragment), "%s reports a precise validation error" % label)
	_expect_true(library.actor_ids().is_empty(), "%s publishes no profiles" % label)
	_expect_true(library.direction_order.is_empty(), "%s publishes no directions" % label)
	_expect_true(library.required_clips.is_empty(), "%s publishes no required clips" % label)


func _write_fixture(label: String, manifest: Dictionary) -> String:
	var path := "user://sprite_clip_v3_%s_%d.json" % [label, Time.get_ticks_usec()]
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_expect_true(false, "fixture can be written: %s" % label)
		return path
	file.store_string(JSON.stringify(manifest))
	file.close()
	_fixture_paths.append(path)
	return path


func _cleanup_fixtures() -> void:
	for path: String in _fixture_paths:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	_fixture_paths.clear()


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
