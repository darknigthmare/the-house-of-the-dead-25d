extends SceneTree

const EnemyLibraryType := preload("res://src/gameplay/enemy_profile_library.gd")

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library: EnemyProfileLibrary = EnemyLibraryType.new()
	_expect_true(library.load_profiles(), "canonical enemy roster loads")
	_expect_equal(library.profiles.size(), 25, "twenty-five enemy profiles commit atomically")
	for enemy_id: String in library.profiles:
		var profile := library.get_profile(enemy_id)
		var runtime := library.to_runtime_stats(enemy_id)
		_expect_equal(str(profile.get("id", "")), enemy_id, "%s keeps its canonical id" % enemy_id)
		_expect_true(float(runtime.get("health", 0.0)) > 0.0, "%s has positive health" % enemy_id)
		_expect_equal(int(runtime.get("score", 0)), 80, "%s preserves arcade target score" % enemy_id)
		_expect_true(not str(runtime.get("behavior", "")).is_empty(), "%s resolves a runtime behavior" % enemy_id)
		_expect_true(not str(runtime.get("hitbox_profile", "")).is_empty(), "%s resolves a hitbox profile" % enemy_id)
	_expect_equal(str(library.to_runtime_stats("cyril_a3").get("projectile_asset", "")), "thrown_axe", "Cyril throws the dedicated axe")
	_expect_equal(str(library.to_runtime_stats("bentley_c2").get("projectile_asset", "")), "thrown_barrel", "Bentley throws the dedicated barrel")
	_expect_equal(str(library.to_runtime_stats("drake_e2").get("projectile_asset", "")), "thrown_dagger", "Drake throws the dedicated dagger")
	_expect_equal(str(library.to_runtime_stats("moody_e3").get("projectile_asset", "")), "iron_claw", "Moody launches the dedicated claw")
	_expect_equal(str(library.to_runtime_stats("name_g2").get("projectile_asset", "")), "organic_spit", "Name uses the dedicated organic spit")
	_expect_equal(str(library.to_runtime_stats("taran_g3").get("behavior", "")), "ceiling_drop", "Taran uses its ceiling-drop behavior")
	_expect_equal(str(library.to_runtime_stats("harris_d3").get("behavior", "")), "heavy_weapon", "Harris remains a melee ball-and-chain brute")
	_expect_true(library.to_runtime_stats("missing").is_empty(), "unknown enemies never get a fallback profile")
	if _failures == 0:
		print("ENEMY PROFILE LIBRARY TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("ENEMY PROFILE LIBRARY TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _expect_true(actual: bool, label: String) -> void:
	_expect_equal(actual, true, label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual == expected:
		return
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
