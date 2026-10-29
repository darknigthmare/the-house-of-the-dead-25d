extends RefCounted

const PickupType := preload("res://src/gameplay/pickup_controller.gd")
const BreakableType := preload("res://src/gameplay/breakable_object.gd")
const CivilianType := preload("res://src/gameplay/civilian_controller.gd")
const SpawnEventType := preload("res://src/gameplay/enemy_spawn_event.gd")
const RuntimeFlowType := preload("res://src/gameplay/gameplay_runtime_flow.gd")
const EnvironmentLifecycleType := preload("res://src/gameplay/environment_scene_lifecycle.gd")
const EnvironmentPropStateType := preload("res://src/gameplay/environment_prop_state_controller.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	_test_pickup(checks)
	_test_breakable(checks)
	_test_civilian(checks)
	_test_spawn_event(checks)
	_test_runtime_breakable_context(checks)
	_test_chapter_start_selection(checks)
	_test_environment_lifecycle(checks)
	_test_environment_prop_snapshot(checks)
	return checks


static func _test_pickup(checks: Array[Dictionary]) -> void:
	var pickup: PickupController = PickupType.new()
	pickup.configure({"id": "bonus_medal_01", "pickup": "medal", "motion": "bob", "phase": 0.25})
	_add_check(checks, pickup.collect_by_shot(1), true, "pickup accepts its first valid shot")
	_add_check(checks, pickup.collect_by_shot(0), false, "pickup cannot reward a second player twice")
	_add_check(checks, pickup.is_collected, true, "pickup records one-shot collection state")
	_add_check(checks, pickup.vertical_offset(0.5) != pickup.vertical_offset(0.0), true, "pickup motion is sampled deterministically by runtime time")
	pickup.free()


static func _test_breakable(checks: Array[Dictionary]) -> void:
	var breakable: BreakableObject = BreakableType.new()
	breakable.configure({"id": "lock", "health": 2.0, "reward": {"pickup": "medal"}})
	_add_check(checks, breakable.take_damage(1.0, 0), true, "breakable accepts first authored hit")
	_add_check(checks, is_equal_approx(breakable.durability, 1.0), true, "breakable retains exact deterministic durability")
	_add_check(checks, breakable.is_broken, false, "breakable survives before durability reaches zero")
	_add_check(checks, breakable.take_damage(1.0, 0), true, "breakable accepts final authored hit")
	_add_check(checks, breakable.is_broken, true, "breakable enters broken state at zero durability")
	_add_check(checks, breakable.take_damage(1.0, 0), false, "broken object cannot award or break twice")
	_add_check(checks, str(breakable.get_reward().get("pickup", "")), "medal", "breakable returns its authored reward without a random roll")
	_add_check(checks, breakable.persist_broken_visual_until_scene_clear, true, "broken scenery remains visible until its sequence ends by default")
	breakable.configure({"id": "short_lived", "health": 1.0, "persist_broken_visual": false})
	_add_check(checks, breakable.persist_broken_visual_until_scene_clear, false, "authored transient breakables may explicitly retire")
	breakable.free()


static func _test_civilian(checks: Array[Dictionary]) -> void:
	var civilian: CivilianController = CivilianType.new()
	civilian.configure({"actor_id": "scientist_male_blue", "deadline": 1.0})
	_add_check(checks, civilian.enter_danger(), true, "civilian enters danger")
	_add_check(checks, civilian.advance_danger(0.5), false, "civilian deadline remains open before its duration")
	_add_check(checks, civilian.advance_danger(0.5), true, "civilian requests visible-threat acceleration at its deadline")
	_add_check(checks, civilian.civilian_state, CivilianType.CivilianState.ENDANGERED, "deadline alone never marks a civilian lost")
	_add_check(checks, civilian.confirm_visible_loss(&"timeout"), false, "timer-only loss is rejected")
	_add_check(checks, civilian.request_rescue(0), true, "civilian remains rescuable after the deadline")
	_add_check(checks, civilian.civilian_state, CivilianType.CivilianState.RESCUED, "rescued civilian transitions once")
	civilian.free()

	var contacted: CivilianController = CivilianType.new()
	contacted.configure({"actor_id": "scientist_female_lab", "deadline": 2.0})
	contacted.enter_danger()
	_add_check(checks, contacted.confirm_visible_loss(&"enemy_projectile_contact"), true, "visible projectile contact can fail a rescue")
	_add_check(checks, contacted.civilian_state, CivilianType.CivilianState.LOST, "visible contact records civilian loss")
	_add_check(checks, contacted.request_rescue(0), false, "lost civilian cannot be rescued afterward")
	contacted.free()


static func _test_spawn_event(checks: Array[Dictionary]) -> void:
	var event: EnemySpawnEvent = SpawnEventType.new()
	event.configure_from_dictionary({
		"delay": 1.25,
		"count": 2,
		"interval": 0.5,
		"actor": "sam_a1",
		"position": [1.5, 0.25, -12.0],
		"behavior": "charge",
		"attack_delay": 4.0,
	})
	var first := event.to_spawn_dictionary(0)
	var second := event.to_spawn_dictionary(1)
	_add_check(checks, str(first.get("actor", "")), "sam_a1", "spawn event preserves actor identity")
	_add_check(checks, first.get("position", []), [1.5, 0.25, -12.0], "spawn event preserves authored 3D position")
	_add_check(checks, str(first.get("behavior", "")), "charge", "spawn event preserves runtime behavior")
	_add_check(checks, float(first.get("attack_delay", 0.0)), 4.0, "spawn event preserves attack timing")
	_add_check(checks, float(first.get("delay", 0.0)), 1.25, "first spawn keeps authored delay")
	_add_check(checks, float(second.get("delay", 0.0)), 1.75, "spawn interval produces deterministic schedule")
	_add_check(checks, event.validate().is_empty(), true, "metadata-driven spawn event does not require a PackedScene")


static func _test_runtime_breakable_context(checks: Array[Dictionary]) -> void:
	var runtime = RuntimeFlowType.new()
	runtime.state = "node"
	runtime.current_node = {"breakable": {"asset": "expected_lock"}, "spawns": []}
	runtime.destroyed_breakable_id = "actual_destroyed_lock"
	var context: Dictionary = runtime._environment_prop_state_context(false)
	_add_check(checks, bool(context.get("breakable_destroyed", false)), true, "runtime reports a destroyed breakable")
	_add_check(checks, str(context.get("breakable_id", "")), "actual_destroyed_lock", "runtime forwards the exact destroyed breakable id instead of the node expectation")
	runtime.destroyed_breakable_id = ""
	context = runtime._environment_prop_state_context(false)
	_add_check(checks, bool(context.get("breakable_destroyed", true)), false, "runtime clears the breakable event when nothing was destroyed")
	_add_check(checks, str(context.get("breakable_id", "missing")), "", "runtime never invents a destroyed breakable id from node data")
	runtime.free()


static func _test_chapter_start_selection(checks: Array[Dictionary]) -> void:
	var explicit_chapter := {
		"start": "hatch_gallery",
		"nodes": [{"id": "wrong_fallback"}, {"id": "hatch_gallery"}],
	}
	_add_check(checks, RuntimeFlowType.chapter_start_node_id(explicit_chapter), "hatch_gallery", "chapter intro resolves the authored start node before building its environment")
	var fallback_chapter := {"nodes": [{"id": "estate_arrival"}]}
	_add_check(checks, RuntimeFlowType.chapter_start_node_id(fallback_chapter), "estate_arrival", "chapter intro uses the first node only when no explicit start exists")


static func _test_environment_lifecycle(checks: Array[Dictionary]) -> void:
	var root := Node3D.new()
	var old_environment := WorldEnvironment.new()
	var stale_prop := Sprite3D.new()
	root.add_child(old_environment)
	root.add_child(stale_prop)
	_add_check(checks, EnvironmentLifecycleType.clear_immediately(root), 2, "environment lifecycle reports every detached scene child")
	_add_check(checks, root.get_child_count(), 0, "previous environment and props leave the tree before the replacement is built")
	_add_check(checks, is_instance_valid(old_environment), false, "old WorldEnvironment cannot overlap the new environment for one frame")
	_add_check(checks, is_instance_valid(stale_prop), false, "stale props cannot be returned during immediate state configuration")
	var empty_root := Node3D.new()
	_add_check(checks, EnvironmentLifecycleType.clear_immediately(empty_root), 0, "empty environment cleanup is idempotent")
	_add_check(checks, EnvironmentLifecycleType.clear_immediately(root), 0, "repeated cleanup cannot remove already-freed children")
	_add_check(checks, EnvironmentLifecycleType.clear_immediately(null), 0, "null environment root is safely ignored")
	root.free()
	empty_root.free()
	_add_check(checks, EnvironmentLifecycleType.clear_immediately(root), 0, "freed environment root is safely ignored")



static func _test_environment_prop_snapshot(checks: Array[Dictionary]) -> void:
	var original := Sprite3D.new()
	original.hframes = 4
	original.vframes = 2
	EnvironmentPropStateType.configure_sprite(original, "door", 0, {
		"initial_frame": 1,
		"state_event": {"id": "door_open", "trigger": "node_enter", "target_frame": 5},
	})
	_add_check(checks, EnvironmentPropStateType.apply_pending_event(original, {}), true, "door event applies before snapshot")
	var snapshot := EnvironmentPropStateType.capture_state(original)
	_add_check(checks, int(snapshot.get("frame", -1)), 5, "snapshot records the visible door frame")
	_add_check(checks, bool(snapshot.get("applied", false)), true, "snapshot records consumed event")
	original.free()
	var rebuilt := Sprite3D.new()
	rebuilt.hframes = 4
	rebuilt.vframes = 2
	EnvironmentPropStateType.configure_sprite(rebuilt, "door", 0, {
		"initial_frame": 1,
		"state_event": {"id": "door_open", "trigger": "node_enter", "target_frame": 5},
	})
	_add_check(checks, EnvironmentPropStateType.restore_state(rebuilt, snapshot), true, "new sprite accepts previous state")
	_add_check(checks, rebuilt.frame, 5, "rebuilt door retains its open frame")
	_add_check(checks, EnvironmentPropStateType.apply_pending_event(rebuilt, {}), false, "restored event cannot trigger twice")
	_add_check(checks, str(rebuilt.get_meta(EnvironmentPropStateType.META_TRIGGERED_ID, "")), "door_open", "restored trigger identity survives reconstruction")
	_add_check(checks, EnvironmentPropStateType.restore_state(rebuilt, {"frame": 100}), true, "out-of-range snapshot is accepted safely")
	_add_check(checks, rebuilt.frame, 7, "out-of-range snapshot frame is clamped")
	rebuilt.free()


static func _add_check(
	checks: Array[Dictionary],
	actual: Variant,
	expected: Variant,
	label: String
) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
