extends SceneTree

const Rules := preload("res://src/core/arcade_rule_set.gd")
const AmmoControllerType := preload("res://src/core/ammo_controller.gd")
const ScoreManagerType := preload("res://src/core/score_manager.gd")
const HealthManagerType := preload("res://src/core/health_manager.gd")
const CreditContinueManagerType := preload("res://src/core/credit_continue_manager.gd")
const EndingResolverType := preload("res://src/core/ending_resolver.gd")
const PlayerGunControllerType := preload("res://src/core/player_gun_controller.gd")
const PlayerInputRouterType := preload("res://src/core/player_input_router.gd")
const RawLightGunInputType := preload("res://src/core/raw_light_gun_input.gd")
const SettingsManagerType := preload("res://src/core/settings_manager.gd")
const SaveManagerType := preload("res://src/core/save_manager.gd")
const RouteGraphResourceTest := preload("res://tests/test_route_graph_resources.gd")
const DirectionalSpritePipelineTest := preload("res://tests/test_directional_sprite_pipeline.gd")
const RouteOutcomePolicyTest := preload("res://tests/test_route_outcome_policy.gd")
const RuntimeComponentsTest := preload("res://tests/test_runtime_components.gd")
const SpriteActorStateMachineTest := preload("res://tests/test_sprite_actor_state_machine.gd")
const UITextSanitizerType := preload("res://src/ui/ui_text_sanitizer.gd")
const EnemyPursuitControllerTest := preload("res://tests/test_enemy_pursuit_controller.gd")
const SequenceTimingPolicyTest := preload("res://tests/test_sequence_timing_policy.gd")
const EnvironmentLayoutClassifierTest := preload("res://tests/test_environment_layout_classifier.gd")
const WalkableSurfaceResolverTest := preload("res://tests/test_walkable_surface_resolver.gd")
const CameraRailContinuityTest := preload("res://tests/test_camera_rail_continuity.gd")
const EncounterSpawnTimingPolicyTest := preload("res://tests/test_encounter_spawn_timing_policy.gd")

var _failures: int = 0
var _assertions: int = 0


func _initialize() -> void:
	_test_rule_table()
	_test_ammo_and_independent_guns()
	_test_scores()
	_test_health()
	_test_credits_and_continues()
	_test_endings()
	_test_input_router()
	_test_raw_light_guns()
	_test_settings_and_save_models()
	_test_route_graph_resources()
	_test_route_outcome_policy()
	_test_runtime_components()
	_test_enemy_pursuit_controller()
	_test_directional_sprite_pipeline()
	_test_sprite_actor_state_machine()
	_test_sequence_timing_policy()
	_test_environment_layout_classifier()
	_test_encounter_spawn_timing_policy()
	_test_walkable_surface_resolver()
	_test_camera_rail_continuity()
	_test_ui_text_sanitizer()
	if _failures == 0:
		print("CORE TESTS PASSED: %d assertions" % _assertions)
		call_deferred("quit", 0)
		return
	push_error("CORE TESTS FAILED: %d/%d assertions failed" % [_failures, _assertions])
	call_deferred("quit", 1)


func _test_rule_table() -> void:
	_expect_equal(Rules.MAGAZINE_SIZE, 6, "magazine contains six rounds")
	_expect_equal(Rules.score_for(Rules.EVENT_CIVILIAN_SAVED), 400, "civilian save score")
	_expect_equal(Rules.score_for(Rules.EVENT_CIVILIAN_KILLED_BY_MONSTER), -100, "monster civilian kill score")
	_expect_equal(Rules.score_for(Rules.EVENT_CIVILIAN_KILLED_BY_PLAYER), -200, "player civilian kill score")
	_expect_equal(Rules.score_for(Rules.EVENT_ENEMY_KILLED), 80, "enemy kill score")
	_expect_equal(Rules.score_for(Rules.EVENT_HEADSHOT), 120, "headshot score")
	_expect_equal(Rules.score_for(Rules.EVENT_PLAYER_HIT), -100, "player hit score")
	_expect_equal(Rules.score_for(Rules.EVENT_MEDAL), 200, "medal score")
	_expect_equal(Rules.score_for(Rules.EVENT_GOLDEN_FROG), 1000, "golden frog score")
	_expect_equal(Rules.score_for(Rules.EVENT_BOSS_DEFEATED), 1500, "boss score")
	_expect_equal(Rules.score_for(Rules.EVENT_MAGICIAN_DEFEATED), 2500, "Magician score")


func _test_ammo_and_independent_guns() -> void:
	var ammo: AmmoControllerType = AmmoControllerType.new()
	var p1: PlayerGunControllerType = PlayerGunControllerType.new(0, ammo)
	var p2: PlayerGunControllerType = PlayerGunControllerType.new(1, ammo)
	for shot_index: int in Rules.MAGAZINE_SIZE:
		_expect_true(p1.fire(Vector2(100.0 + shot_index, 100.0)), "P1 round %d fires" % shot_index)
	_expect_equal(p1.get_ammo(), 0, "P1 magazine empties after six rounds")
	_expect_false(p1.fire(), "P1 cannot fire an empty magazine")
	_expect_equal(p2.get_ammo(), 6, "P2 magazine is independent")
	_expect_true(p2.fire(Vector2(500.0, 300.0)), "P2 fires independently")
	_expect_equal(p2.get_ammo(), 5, "P2 consumes only its own round")
	_expect_equal(p1.reload(), 6, "P1 reload restores six rounds")
	_expect_equal(p2.get_ammo(), 5, "P1 reload does not alter P2")


func _test_scores() -> void:
	var scores: ScoreManagerType = ScoreManagerType.new()
	scores.apply_event(0, Rules.EVENT_CIVILIAN_SAVED)
	scores.apply_event(0, Rules.EVENT_ENEMY_KILLED)
	scores.apply_event(0, Rules.EVENT_HEADSHOT)
	scores.apply_event(0, Rules.EVENT_MEDAL)
	scores.apply_event(0, Rules.EVENT_GOLDEN_FROG)
	scores.apply_event(0, Rules.EVENT_BOSS_DEFEATED)
	scores.apply_event(0, Rules.EVENT_MAGICIAN_DEFEATED)
	_expect_equal(scores.get_score(0), 5800, "positive score events use the canonical table")
	scores.apply_event(0, Rules.EVENT_PLAYER_HIT)
	scores.apply_event(0, Rules.EVENT_CIVILIAN_KILLED_BY_MONSTER)
	scores.apply_event(0, Rules.EVENT_CIVILIAN_KILLED_BY_PLAYER)
	_expect_equal(scores.get_score(0), 5400, "score penalties are applied")
	_expect_equal(scores.get_score(1), 0, "P2 score remains independent")
	scores.add_points(1, 80, &"test")
	_expect_equal(scores.combined_score(), 5480, "combined score sums both players")
	scores.add_points(1, -1000, &"test_floor")
	_expect_equal(scores.get_score(1), 0, "score never becomes negative")


func _test_health() -> void:
	var health: HealthManagerType = HealthManagerType.new()
	_expect_equal(health.get_lives(0), 3, "P1 starts with three lives")
	_expect_equal(health.get_lives(1), 3, "P2 starts with three lives")
	health.add_life(0, 20)
	_expect_equal(health.get_lives(0), 5, "life pickups cap at five")
	_expect_equal(health.get_lives(1), 3, "P1 life pickup does not alter P2")
	health.take_damage(0, 5)
	_expect_equal(health.get_lives(0), 0, "damage cannot reduce lives below zero")
	_expect_true(health.is_alive(1), "P2 survives independently")


func _test_credits_and_continues() -> void:
	var credits: CreditContinueManagerType = CreditContinueManagerType.new()
	_expect_true(credits.use_continue(0), "P1 can spend a credit")
	_expect_equal(credits.get_credits(0), 2, "P1 credit is consumed")
	_expect_equal(credits.get_continue_count(0), 1, "P1 continue is counted")
	_expect_equal(credits.get_credits(1), 3, "P2 credits remain independent")
	credits.use_continue(0)
	credits.use_continue(0)
	_expect_false(credits.use_continue(0), "continue is denied at zero credits")
	_expect_true(credits.can_continue(1), "P2 may still continue")


func _test_endings() -> void:
	var resolver: EndingResolverType = EndingResolverType.new()
	_expect_equal(resolver.resolve(62_000), EndingResolverType.GOOD, "threshold score yields good ending")
	_expect_equal(resolver.resolve(71_000), EndingResolverType.GOOD, "good ending has priority over units digit")
	_expect_equal(resolver.resolve(61_990), EndingResolverType.BAD, "lower score ending in zero yields bad ending")
	_expect_equal(resolver.resolve(61_999), EndingResolverType.NORMAL, "other lower score yields normal ending")
	_expect_equal(resolver.resolve_combined([31_001, 31_000]), EndingResolverType.GOOD, "ending uses combined two-player score")


func _test_input_router() -> void:
	var router: PlayerInputRouterType = PlayerInputRouterType.new()
	var fired_players: Array[int] = []
	var reload_players: Array[int] = []
	router.fire_requested.connect(func(player_index: int, _position: Vector2) -> void: fired_players.append(player_index))
	router.reload_requested.connect(func(player_index: int) -> void: reload_players.append(player_index))
	_expect_true(router.route_action(&"p1_fire", Vector2(100.0, 200.0)), "router accepts P1 fire")
	_expect_true(router.route_action(&"p2_fire", Vector2(900.0, 300.0)), "router accepts P2 fire")
	_expect_true(router.route_action(&"p2_reload"), "router accepts P2 reload")
	_expect_equal(fired_players, [0, 1], "router preserves player identities")
	_expect_equal(reload_players, [1], "router sends reload to the correct player")
	_expect_equal(router.get_aim_position(0), Vector2(100.0, 200.0), "P1 aim remains independent")
	_expect_equal(router.get_aim_position(1), Vector2(900.0, 300.0), "P2 aim remains independent")
	router.free()


func _test_raw_light_guns() -> void:
	var raw_input: RawLightGunInputType = RawLightGunInputType.new()
	_expect_true(raw_input.register_device(0, 10), "raw device 10 registers to P1")
	_expect_true(raw_input.register_device(1, 20), "raw device 20 registers to P2")
	var play_rect := Rect2(100.0, 50.0, 1080.0, 620.0)
	var p1_motion := InputEventMouseMotion.new()
	p1_motion.device = 10
	p1_motion.position = Vector2(320.0, 240.0)
	var p1_aim: Dictionary = raw_input.ingest(p1_motion, play_rect)
	_expect_equal(p1_aim.get("player_index"), 0, "raw P1 aim retains device identity")
	var p2_motion := InputEventMouseMotion.new()
	p2_motion.device = 20
	p2_motion.position = Vector2(960.0, 540.0)
	raw_input.ingest(p2_motion, play_rect)
	var p2_trigger := InputEventMouseButton.new()
	p2_trigger.device = 20
	p2_trigger.position = Vector2(960.0, 540.0)
	p2_trigger.button_index = MOUSE_BUTTON_LEFT
	p2_trigger.pressed = true
	var p2_fire: Dictionary = raw_input.ingest(p2_trigger, play_rect)
	_expect_equal(p2_fire.get("action"), &"fire", "on-screen raw trigger fires")
	_expect_equal(p2_fire.get("player_index"), 1, "raw trigger belongs to P2")
	var p1_offscreen := InputEventMouseButton.new()
	p1_offscreen.device = 10
	p1_offscreen.position = Vector2(10.0, 10.0)
	p1_offscreen.button_index = MOUSE_BUTTON_LEFT
	p1_offscreen.pressed = true
	var p1_reload: Dictionary = raw_input.ingest(p1_offscreen, play_rect)
	_expect_equal(p1_reload.get("action"), &"reload", "off-screen trigger reloads")
	_expect_equal(raw_input.get_position(1), Vector2(960.0, 540.0), "P1 input does not move P2 aim")


func _test_route_graph_resources() -> void:
	for check in RouteGraphResourceTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_route_outcome_policy() -> void:
	for check in RouteOutcomePolicyTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_runtime_components() -> void:
	for check in RuntimeComponentsTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_enemy_pursuit_controller() -> void:
	for check in EnemyPursuitControllerTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_directional_sprite_pipeline() -> void:
	for check in DirectionalSpritePipelineTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_sprite_actor_state_machine() -> void:
	for check in SpriteActorStateMachineTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_sequence_timing_policy() -> void:
	for check in SequenceTimingPolicyTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_environment_layout_classifier() -> void:
	for check in EnvironmentLayoutClassifierTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))


func _test_walkable_surface_resolver() -> void:
	for check in WalkableSurfaceResolverTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))

func _test_camera_rail_continuity() -> void:
	for check in CameraRailContinuityTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))



func _test_encounter_spawn_timing_policy() -> void:
	for check in EncounterSpawnTimingPolicyTest.collect_checks():
		_expect_equal(check.actual, check.expected, str(check.label))



func _test_ui_text_sanitizer() -> void:
	var french := "Précision, dégâts, Entrée et sélection"
	_expect_equal(UITextSanitizerType.sanitize(french), french, "French accented letters remain unchanged")
	var decorated := "ROUTE • CHAPTER — ← ◆ ● ○ ┌┐"
	var sanitized := UITextSanitizerType.sanitize(decorated)
	_expect_equal(sanitized, "ROUTE | CHAPTER - < * * o ++", "fragile UI ornaments use export-safe ASCII")
	_expect_false(UITextSanitizerType.contains_unsupported_ornament(sanitized), "sanitized UI text contains no unsupported ornament")
	_expect_equal(UITextSanitizerType.normalize_score_initials("abc"), "ABC", "leaderboard initials normalize to ASCII capitals")
	_expect_equal(UITextSanitizerType.normalize_score_initials("A◆B"), "---", "leaderboard rejects unsupported initial glyphs")
	_expect_equal(UITextSanitizerType.normalize_score_mode("boss rush"), "BOSS_RUSH", "leaderboard normalizes a known score mode")
	_expect_equal(UITextSanitizerType.normalize_score_mode("arcade◆"), "ARCADE", "leaderboard rejects an unsafe score mode")


func _test_settings_and_save_models() -> void:
	var settings: Node = SettingsManagerType.new()
	settings.load_dictionary({
		"language": "en",
		"blood_level": 1.0,
		"aim_assist": 2.0,
		"interface_volume": 0.4,
		"ambience_volume": 0.3
	})
	_expect_equal(settings.get_value("language"), "en", "saved language is loaded")
	_expect_equal(settings.get_value("blood_level"), 1, "JSON numeric blood level is normalized")
	_expect_equal(settings.get_value("aim_assist"), 1.0, "aim assist is clamped")
	_expect_equal(settings.get_value("interface_volume"), 0.4, "interface volume is retained")
	_expect_equal(settings.get_value("ambience_volume"), 0.3, "ambience volume is retained")
	settings.free()

	var saves: Node = SaveManagerType.new()
	saves.data = saves.default_data()
	saves.merge_progress({
		"chapters_unlocked": [2],
		"bosses_unlocked": ["chariot"],
		"routes_discovered": ["1:foyer"],
		"endings_obtained": ["normal"],
		"statistics": {"runs": 1, "shots": 12, "hits": 8},
		"high_score": {"score": 1234, "mode": "arcade"}
	})
	_expect_equal(int(saves.data.get("version", 0)), 3, "save data migrates to version three")
	_expect_true(saves.has_chapter_unlocked(2), "chapter unlock is persisted in memory")
	_expect_true((saves.data.get("bosses_unlocked", []) as Array).has("chariot"), "boss unlock is persisted in memory")
	_expect_true((saves.data.get("routes_discovered", []) as Array).has("1:foyer"), "route discovery is persisted in memory")
	_expect_true((saves.data.get("endings_obtained", []) as Array).has("normal"), "ending is persisted in memory")
	_expect_equal(int((saves.data.get("statistics", {}) as Dictionary).get("shots", 0)), 12, "statistics are accumulated")
	_expect_equal(int(((saves.data.get("high_scores", []) as Array)[0] as Dictionary).get("score", 0)), 1234, "high score is recorded")
	saves.free()


func _expect_true(value: bool, label: String) -> void:
	_assertions += 1
	if not value:
		_fail(label, true, value)


func _expect_false(value: bool, label: String) -> void:
	_assertions += 1
	if value:
		_fail(label, false, value)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual != expected:
		_fail(label, expected, actual)


func _fail(label: String, expected: Variant, actual: Variant) -> void:
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
