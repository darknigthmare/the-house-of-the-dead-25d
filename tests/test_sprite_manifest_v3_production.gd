extends SceneTree

const LibraryType := preload("res://src/gameplay/sprite_clip_library_v3.gd")
const MANIFEST_PATH := "res://data/assets/sprite_manifest_v3.json"

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library = LibraryType.new()
	_expect_true(library.load_manifest(MANIFEST_PATH), "production V3 sidecar parses and validates")
	_expect_equal(library.last_error, "", "production sidecar reports no parser error")
	_expect_equal(library.actor_ids(), ["sam_a1"], "production sidecar exposes only the reviewed Sam pilot")
	_expect_true(library.has_actor("sam_a1"), "Sam pilot profile is queryable")
	_expect_true(library.is_runtime_ready("sam_a1"), "complete Sam pilot is runtime-ready atomically")
	_expect_equal(library.fallback_reason("sam_a1"), "", "complete Sam pilot exposes no fallback reason")
	var profile := library.get_profile("sam_a1")
	_expect_equal(str(profile.get("fallback_v2_id", "")), "sam_a1", "Sam pilot retains its verified V2 fallback")
	_expect_equal((profile.get("clips", {}) as Dictionary).size(), 5, "all five certified clips are published together")
	var locomotion := library.get_clip("sam_a1", "locomotion")
	_expect_equal(int(locomotion.get("frame_count", 0)), 8, "locomotion exposes eight temporal frames")
	_expect_equal(int(locomotion.get("sheet_rows", 0)), 8, "locomotion exposes eight authored directions")
	_expect_equal(int(locomotion.get("cell_px", 0)), 256, "locomotion exposes 256px square cells")
	_expect_true(ResourceLoader.exists(str(locomotion.get("path", ""))), "certified locomotion texture is importable")
	var idle := library.get_clip("sam_a1", "idle")
	_expect_equal(int(idle.get("frame_count", 0)), 8, "idle exposes eight temporal frames")
	_expect_true(bool(idle.get("loop", false)), "idle is a looping presentation clip")
	_expect_true(ResourceLoader.exists(str(idle.get("path", ""))), "idle texture is importable")
	_expect_equal(float(idle.get("display_scale", 0.0)), 1.0, "idle establishes Sam's canonical world scale")
	var attack := library.get_clip("sam_a1", "attack")
	_expect_true(bool(attack.get("hold_last", false)), "attack holds its authored recovery pose until gameplay recovery ends")
	_expect_true(float(attack.get("display_scale", 0.0)) > 1.1, "wide attack art receives actor-level proportion calibration")
	var hit_recoil := library.get_clip("sam_a1", "hit_recoil")
	_expect_true(float(hit_recoil.get("fps", 0.0)) >= 40.0, "hit recoil shows all eight frames inside the 0.22-second gameplay reaction")
	_expect_true(bool(hit_recoil.get("hold_last", false)), "hit recoil holds its recovered frame until the gameplay reaction expires")
	_expect_true(float(library.get_clip("sam_a1", "death_fall").get("display_scale", 0.0)) > 1.08, "death entry preserves Sam's actor-level height before the fall")
	for clip_id: String in ["attack", "hit_recoil", "death_fall"]:
		var clip := library.get_clip("sam_a1", clip_id)
		_expect_equal(int(clip.get("frame_count", 0)), 8, "%s exposes eight temporal frames" % clip_id)
		_expect_equal(int(clip.get("sheet_rows", 0)), 8, "%s exposes eight authored directions" % clip_id)
		_expect_true(ResourceLoader.exists(str(clip.get("path", ""))), "%s texture is importable" % clip_id)

	if _failures == 0:
		print("SPRITE MANIFEST V3 PRODUCTION TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("SPRITE MANIFEST V3 PRODUCTION TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
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
