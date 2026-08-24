extends SceneTree

const SupportLibraryType := preload("res://src/gameplay/gameplay_support_library.gd")

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library: GameplaySupportLibrary = SupportLibraryType.new()
	_expect_true(library.load_manifest(), "gameplay support manifest loads")
	_expect_equal(library.projectiles.size(), 7, "seven dedicated projectile visuals")
	_expect_equal(library.ui.size(), 3, "three HUD visual families")
	_expect_equal(library.weakpoints.size(), 4, "four boss weakpoint diagrams")
	for projectile_id: String in ["thrown_axe", "thrown_dagger", "thrown_barrel", "organic_spit", "iron_claw", "hermit_web_ball", "magician_fireball"]:
		var profile := library.get_projectile(projectile_id)
		_expect_true(not profile.is_empty(), "projectile resolves: %s" % projectile_id)
		_expect_true(library.load_texture(profile) != null, "projectile texture loads: %s" % projectile_id)
	for boss_id: String in ["chariot", "hangedman", "hermit", "magician"]:
		_expect_true(library.load_texture(library.get_weakpoint(boss_id)) != null, "weakpoint diagram loads: %s" % boss_id)
	_expect_equal(int(library.get_ui("life_torch").get("hframes", 0)), 8, "life torch keeps eight animation frames")
	_expect_true(library.get_projectile("unknown").is_empty(), "unknown projectile has no fallback")
	_expect_true(library.get_weakpoint("unknown").is_empty(), "unknown boss diagram has no fallback")
	if _failures == 0:
		print("GAMEPLAY SUPPORT LIBRARY TEST PASSED: %d assertions" % _assertions)
		quit(0)
		return
	push_error("GAMEPLAY SUPPORT LIBRARY TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _expect_true(actual: bool, label: String) -> void:
	_expect_equal(actual, true, label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual == expected:
		return
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
