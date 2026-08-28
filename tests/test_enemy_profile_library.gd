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
		_expect_true(float(runtime.get("attack_telegraph", 0.0)) >= 0.5, "%s exposes a readable attack telegraph" % enemy_id)
		_expect_true(float(runtime.get("melee_range", 0.0)) >= 2.0, "%s exposes a physical melee range" % enemy_id)
		_expect_true(not runtime.has("max_attacks"), "%s remains active until killed or the encounter ends" % enemy_id)
		if not str(runtime.get("projectile_asset", "")).is_empty():
			_expect_true(bool(runtime.get("projectile_destructible", false)), "%s runtime projectile is interceptable" % enemy_id)
			_expect_true(float(runtime.get("projectile_min_travel", 0.0)) >= 3.0, "%s projectile must visibly traverse the scene" % enemy_id)
			_expect_true(float(runtime.get("projectile_contact_range", 0.0)) > 0.0, "%s projectile uses physical contact" % enemy_id)
	_expect_equal(str(library.to_runtime_stats("cyril_a3").get("projectile_asset", "")), "thrown_axe", "Cyril throws the dedicated axe")
	_expect_equal(str(library.to_runtime_stats("bentley_c2").get("projectile_asset", "")), "thrown_barrel", "Bentley throws the dedicated barrel")
	_expect_equal(str(library.to_runtime_stats("drake_e2").get("projectile_asset", "")), "thrown_dagger", "Drake throws the dedicated dagger")
	_expect_equal(str(library.to_runtime_stats("moody_e3").get("projectile_asset", "")), "iron_claw", "Moody launches the dedicated claw")
	_expect_equal(str(library.to_runtime_stats("name_g2").get("projectile_asset", "")), "organic_spit", "Name uses the dedicated organic spit")
	_expect_equal(str(library.to_runtime_stats("taran_g3").get("behavior", "")), "ceiling_drop", "Taran uses its ceiling-drop behavior")
	_expect_equal(str(library.to_runtime_stats("harris_d3").get("behavior", "")), "heavy_weapon", "Harris remains a melee ball-and-chain brute")
	_expect_equal(str(library.to_runtime_stats("ebitan_b_b4").get("behavior", "")), "ceiling_drop", "Ebitan b keeps a physical ceiling-drop attack")
	_expect_equal(str(library.to_runtime_stats("ebitan_b_b4").get("projectile_asset", "")), "", "Ebitan b never emits an invisible non-destructible projectile")
	_expect_equal(str(library.to_runtime_stats("burner_c3").get("behavior", "")), "heavy_weapon", "Burner keeps a physical blowtorch attack")
	_expect_equal(str(library.to_runtime_stats("burner_c3").get("projectile_asset", "")), "", "Burner never emits an invisible non-destructible flame projectile")
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
