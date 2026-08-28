extends RefCounted

const TimingPolicyType := preload("res://src/rail/sequence_timing_policy.gd")
const RailSamplerType := preload("res://src/rail/camera_rail_path_sampler.gd")


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var policy := {
		"scene_duration_scale": 1.5,
		"minimum_duration_ratio": 1.0,
		"minimum_floor_seconds": 5.0,
		"post_clear_hold_seconds": 0.9,
		"transition_seconds": 1.8,
		"branch_transition_seconds": 2.2,
		"require_rail_complete": true,
		"rail_motion_keys": [
			{"at": 0.0, "progress": 0.0},
			{"at": 0.3, "progress": 0.38},
			{"at": 0.72, "progress": 0.58},
			{"at": 1.0, "progress": 1.0},
		],
	}
	var encounter := {
		"duration": 8.0,
		"spawns": [
			{"delay": 0.5},
			{"delay": 9.0},
		],
		"rail": {"sweep": 1.0},
	}
	_add_check(checks, TimingPolicyType.effective_duration(encounter, policy), 12.0, "campaign pace scale extends authored scene duration")
	_add_check(checks, TimingPolicyType.rail_duration(encounter, policy), 12.0, "rail traverses for the full effective scene duration")
	_add_check(checks, TimingPolicyType.minimum_duration(encounter, policy), 12.0, "encounter cannot clear before its authored rail duration")
	_add_check(checks, TimingPolicyType.post_clear_hold(encounter, policy), 0.9, "post-clear composition hold comes from campaign policy")
	_add_check(checks, TimingPolicyType.requires_rail_complete(encounter, policy), true, "rail completion gate is enabled by default")

	var late_spawn := encounter.duplicate(true)
	late_spawn["duration"] = 4.0
	(late_spawn["spawns"] as Array)[1] = {"delay": 9.0}
	_add_check(checks, TimingPolicyType.minimum_duration(late_spawn, policy), 10.2, "late scheduled spawn cannot be skipped by an early clear")

	var next_node := {"objective": "CROSS THE LIBRARY", "type": "encounter"}
	var regular_transition := TimingPolicyType.transition_descriptor({"next": "library"}, next_node, true, policy)
	_add_check(checks, regular_transition.get("title"), "ADVANCING", "ordinary sequence transition no longer claims a route consequence")
	_add_check(checks, regular_transition.get("body"), "NEXT: CROSS THE LIBRARY", "ordinary transition previews the connected sequence")
	_add_check(checks, regular_transition.get("duration"), 1.8, "ordinary transition uses paced duration")
	var branch_transition := TimingPolicyType.transition_descriptor({"next_success": "upper", "next_failure": "lower"}, next_node, false, policy)
	_add_check(checks, branch_transition.get("title"), "ALTERNATE ROUTE", "failed branch communicates the actual route change")
	_add_check(checks, branch_transition.get("duration"), 2.2, "branch transition receives a longer readability hold")

	var origin := Vector3(0.0, 1.7, 8.0)
	var target := Vector3(0.8, 1.5, 4.5)
	var rail_start := RailSamplerType.sample(encounter, origin, target, 0.0, 12.0, policy)
	var rail_middle := RailSamplerType.sample(encounter, origin, target, 6.0, 12.0, policy)
	var rail_end := RailSamplerType.sample(encounter, origin, target, 12.0, 12.0, policy)
	_add_check(checks, (rail_start.get("position") as Vector3).is_equal_approx(origin), true, "curved rail begins at its authored origin")
	_add_check(checks, (rail_end.get("position") as Vector3).is_equal_approx(target), true, "curved rail reaches its authored target")
	_add_check(checks, float(rail_middle.get("motion_progress", 0.0)) < 0.6, true, "combat window slows rail progress around the middle beat")
	_add_check(checks, absf((rail_middle.get("position") as Vector3).x - origin.lerp(target, 0.5).x) > 0.015, true, "sweep creates a real lateral camera arc instead of a straight lerp")
	return checks


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
