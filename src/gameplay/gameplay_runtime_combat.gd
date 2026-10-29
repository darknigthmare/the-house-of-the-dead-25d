extends "res://src/gameplay/gameplay_runtime_flow.gd"

const EnvironmentMotionControllerScript := preload("res://src/gameplay/environment_motion_controller.gd")
const PickupControllerScript := preload("res://src/gameplay/pickup_controller.gd")
const BreakableObjectScript := preload("res://src/gameplay/breakable_object.gd")
const CivilianControllerScript := preload("res://src/gameplay/civilian_controller.gd")
const EnemySpawnEventScript := preload("res://src/gameplay/enemy_spawn_event.gd")
const EnemyPursuitControllerScript := preload("res://src/gameplay/enemy_pursuit_controller.gd")
const WalkableSurfaceResolverScript := preload("res://src/gameplay/walkable_surface_resolver.gd")
const EnvironmentLayoutClassifierScript := preload("res://src/gameplay/environment_layout_classifier.gd")
const EnvironmentSceneLifecycleScript := preload("res://src/gameplay/environment_scene_lifecycle.gd")
const CameraRailPathSamplerScript := preload("res://src/rail/camera_rail_path_sampler.gd")
const DEFAULT_ATTACK_TELEGRAPH_SECONDS := 0.65
const DEFAULT_MELEE_RANGE := 2.5
const DEFAULT_PROJECTILE_MIN_VISIBLE_TRAVEL := 3.0
const DEFAULT_PROJECTILE_CONTACT_RANGE := 1.35
const BOSS_ATTACK_TELEGRAPH_SECONDS := 0.9
const BOSS_MELEE_RANGE := 2.8
const BOSS_MELEE_RECOVERY_SECONDS := 0.55
const CONNECTOR_CAMERA_HEIGHT := 1.7
const CONNECTOR_HALF_WIDTH := 4.0
const CONNECTOR_FLOOR_THICKNESS := 0.24
const CONNECTOR_WALL_THICKNESS := 0.24
const CONNECTOR_INDOOR_HEIGHT := 3.8
const CONNECTOR_OPEN_RAIL_HEIGHT := 0.65
const CONNECTOR_END_MARGIN := 0.8
const CONNECTOR_BACKDROP_DISTANCE := 12.0
var retiring_actors: Array[Node3D] = []



func _spawn_enemy(spawn: Dictionary) -> Node3D:
	var spawn_event: EnemySpawnEvent = EnemySpawnEventScript.new()
	spawn_event.configure_from_dictionary(spawn)
	spawn = spawn_event.to_spawn_dictionary()
	var actor_id := str(spawn.get("actor", "sam_a1"))
	var stats := _runtime_stats_for_actor(actor_id)
	var position_data := spawn.get("position", [0.0, 0.0, -11.0]) as Array
	var actor_position := Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))
	var actor := _create_actor(actor_id, actor_position, stats, "enemy")
	actor.set_meta("spawn_event", spawn_event)
	var behavior := str(stats.get("behavior", "walk"))
	if spawn.has("behavior"):
		behavior = str(spawn.behavior)
	elif spawn.has("pattern"):
		behavior = _normalize_enemy_behavior(str(spawn.pattern), behavior)
	var attack_delay := float(spawn.get("attack_delay", 4.2))
	actor.set_meta("attack_at", node_elapsed + attack_delay)
	actor.set_meta("attack_ready_age", attack_delay)
	var authored_lane := float(spawn.get("lane", actor_position.x))
	actor.set_meta("lane", authored_lane)
	actor.set_meta("attack_slot_offset", clampf(authored_lane * 0.12, -0.42, 0.42))
	actor.set_meta("ground_y", actor_position.y)
	actor.set_meta("behavior", behavior)
	actor.set_meta("pattern", behavior)
	actor.set_meta("attack_period", float(stats.get("attack_period", 1.8)))
	actor.set_meta("attack_telegraph_seconds", float(stats.get("attack_telegraph", DEFAULT_ATTACK_TELEGRAPH_SECONDS)))
	actor.set_meta("melee_range", float(stats.get("melee_range", DEFAULT_MELEE_RANGE)))
	actor.set_meta("attack_approach_speed", float(stats.get("attack_approach_speed", 1.25)))
	actor.set_meta("attack_telegraph_started", false)
	actor.set_meta("attack_telegraph_complete", false)
	actor.set_meta("attack_commit_age", 1.0e20)
	actor.set_meta("attack_state", "approach")
	actor.set_meta("recovery_until", 0.0)
	actor.set_meta("collision_radius", EnemyPursuitControllerScript.actor_radius(float(stats.get("scale", 1.0))))
	actor.set_meta("weave_width", float(stats.get("weave_width", 1.0)))
	actor.set_meta("charge_factor", float(stats.get("charge_factor", 1.9)))
	actor.set_meta("jump_height", float(stats.get("jump_height", 1.15)))
	actor.set_meta("drop_height", float(stats.get("drop_height", 4.2)))
	actor.set_meta("drop_duration", float(stats.get("drop_duration", 1.1)))
	actor.set_meta("projectile_asset", str(stats.get("projectile_asset", "")))
	actor.set_meta("projectile_destructible", bool(stats.get("projectile_destructible", true)))
	actor.set_meta("projectile_speed", float(stats.get("projectile_speed", 4.0)))
	actor.set_meta("projectile_min_travel", float(stats.get("projectile_min_travel", DEFAULT_PROJECTILE_MIN_VISIBLE_TRAVEL)))
	actor.set_meta("projectile_contact_range", float(stats.get("projectile_contact_range", DEFAULT_PROJECTILE_CONTACT_RANGE)))
	actor.set_meta("armor_zones", (stats.get("armor_zones", []) as Array).duplicate())
	actor.set_meta("armor_durability", float(stats.get("armor_durability", 0.0)))
	actor.set_meta("target_civilian", bool(spawn.get("targets_civilian", false)))
	actor.set_meta("minimum_front_depth", EnemyPursuitControllerScript.attack_standoff_depth(
		behavior,
		float(actor.get_meta("melee_range", DEFAULT_MELEE_RANGE)),
		float(actor.get_meta("projectile_min_travel", DEFAULT_PROJECTILE_MIN_VISIBLE_TRAVEL)),
		float(actor.get_meta("projectile_contact_range", DEFAULT_PROJECTILE_CONTACT_RANGE))
	))
	if behavior != "flight_swarm":
		var initial_ground := WalkableSurfaceResolverScript.resolve_ground_height(
			actor.global_position,
			actor_position.y,
			_environment_walkable_surfaces(),
			2.0,
			2.0
		)
		actor.set_meta("ground_y", initial_ground)
		actor.global_position.y = initial_ground
	if behavior == "ceiling_drop":
		actor.position.y += float(actor.get_meta("drop_height", 4.2))
	return actor


func _normalize_enemy_behavior(legacy_pattern: String, profile_default: String) -> String:
	match legacy_pattern:
		"advance":
			return profile_default
		"fly":
			return "flight_swarm"
		"weave":
			return "aquatic_weave"
		_:
			return legacy_pattern if not legacy_pattern.is_empty() else profile_default


func _runtime_stats_for_actor(actor_id: String) -> Dictionary:
	var stats := enemy_profile_library.to_runtime_stats(actor_id)
	if stats.is_empty():
		stats = (ACTOR_STATS.get(actor_id, ACTOR_STATS.sam_a1) as Dictionary).duplicate(true)
	# Burner attacks with its blowtorch at close range; Magician's fireball is
	# deliberately never reused as a visual substitute for the flame jet.
	if actor_id == "burner_c3":
		stats["behavior"] = "heavy_weapon"
		stats.erase("projectile_asset")
		stats.erase("projectile_destructible")
	return stats

func _spawn_civilian(data: Dictionary) -> void:
	var position_data := data.get("position", [1.6, 0.0, -10.5]) as Array
	var actor_id := str(data.get("actor_id", "scientist"))
	if actor_id == "scientist":
		var candidates: Array[String] = ["scientist_male_blue", "scientist_male_gray", "scientist_female_lab"]
		for offset in candidates.size():
			var candidate := candidates[(scientists_total + offset) % candidates.size()]
			if not sprite_atlas_library.get_profile(candidate).is_empty():
				actor_id = candidate
				break
	active_civilian = _create_actor(actor_id, Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2])), {"health": 1.0, "speed": 0.0, "scale": 0.94, "score": 0}, "civilian")
	var civilian_ground := WalkableSurfaceResolverScript.resolve_ground_height(
		active_civilian.global_position,
		active_civilian.global_position.y,
		_environment_walkable_surfaces(),
		2.0,
		2.0
	)
	active_civilian.global_position.y = civilian_ground
	var civilian_controller: CivilianController = CivilianControllerScript.new()
	civilian_controller.name = "CivilianController"
	civilian_controller.configure(data)
	active_civilian.add_child(civilian_controller)
	civilian_controller.enter_danger()
	active_civilian.set_meta("deadline", node_elapsed + float(data.get("deadline", 7.0)))
	active_civilian.set_meta("deadline_expired", false)
	active_civilian.set_meta("rescued", false)
	active_civilian.set_meta("escape_sign", -1.0 if active_civilian.position.x < 0.0 else 1.0)
	active_civilian.set_meta("rescued_age", 0.0)
	scientists_total += 1
	chapter_scientists_total += 1
	_play_sfx("danger")
	_set_subtitle(str(data.get("dialogue", "Help me!")), 2.8)


func _expire_civilian_rescue_window(civilian: Node3D) -> void:
	# A timer is only allowed to accelerate a real attacker. It must never kill
	# a civilian by itself: the player must see either physical melee contact or
	# a destructible projectile complete the failure state.
	if not is_instance_valid(civilian) or bool(civilian.get_meta("deadline_expired", false)):
		return
	civilian.set_meta("deadline_expired", true)
	civilian.set_meta("deadline", 1.0e20)
	var threat_accelerated := false
	for candidate in active_actors:
		if not is_instance_valid(candidate) or bool(candidate.get_meta("dead", false)):
			continue
		if str(candidate.get_meta("role", "")) != "enemy" or not bool(candidate.get_meta("target_civilian", false)):
			continue
		var age := float(candidate.get_meta("age", 0.0))
		candidate.set_meta("attack_ready_age", minf(float(candidate.get_meta("attack_ready_age", age)), age))
		candidate.set_meta("attack_at", node_elapsed)
		threat_accelerated = true
	if threat_accelerated:
		_play_sfx("danger")
		_set_subtitle("The scientist is still under visible attack!", 1.6)


func _spawn_breakable(data: Dictionary) -> void:
	var position_data := data.get("position", [0.0, 0.7, -9.0]) as Array
	var fallback_assets := {
		"foyer_choice": "c01_foyer_door_lock", "chain_plate": "c02_chained_hatch_plate",
		"elevator_switch": "c03_elevator_route_switch", "vent_key_route": "c03_vent_key_container"
	}
	var asset_id := str(data.get("asset", fallback_assets.get(current_node_id, "")))
	var profile := environment_asset_library.get_destructible(asset_id)
	var visual_prop_id := str(data.get("visual_prop", ""))
	var visual_profile := environment_asset_library.get_prop(visual_prop_id) if not visual_prop_id.is_empty() else {}
	var instance_id := str(data.get("id", asset_id))
	if instance_id.is_empty():
		instance_id = "breakable_%s_%d" % [current_node_id, active_actors.size()]
	# Asset identity drives authored route/state events; instance identity keeps
	# repeated crates, doors and secrets individually addressable.
	var event_id := asset_id if not asset_id.is_empty() else instance_id
	var texture_path := str(visual_profile.get("path", profile.get("intact", _pickup_texture_path("medal"))))
	var world_scale := float(data.get("scale", visual_profile.get("world_scale", profile.get("world_scale", 0.72))))
	var actor_stats := {
		"health": float(data.get("health", 2.0)), "speed": 0.0,
		"scale": world_scale, "score": int(data.get("score", 200)),
		"custom_texture": texture_path,
		"pixel_size": float(data.get("pixel_size", visual_profile.get("pixel_size", profile.get("pixel_size", 0.0045)))),
		"hframes": int(data.get("hframes", visual_profile.get("hframes", 1))),
		"frame": int(data.get("frame", 0)),
	}
	var actor := _create_actor(instance_id, Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2])), actor_stats, "breakable")
	var breakable_controller: BreakableObject = BreakableObjectScript.new()
	breakable_controller.name = "BreakableObject"
	breakable_controller.configure({
		"id": instance_id,
		"health": float(data.get("health", 2.0)),
		"reward": {"pickup": str(data.get("pickup", "medal"))},
		"persist_broken_visual": bool(data.get("persist_broken_visual", true)),
	})
	actor.add_child(breakable_controller)
	actor.set_meta("pickup", str(data.get("pickup", "medal")))
	actor.set_meta("breakable_asset_id", asset_id)
	actor.set_meta("breakable_instance_id", instance_id)
	actor.set_meta("breakable_event_id", event_id)
	actor.set_meta("route_target_id", str(data.get("route_target", instance_id)))
	actor.set_meta("spawn_pickup_on_break", bool(data.get("spawn_pickup_on_break", false)))
	actor.set_meta("persist_broken_visual", breakable_controller.persist_broken_visual_until_scene_clear)
	actor.set_meta("broken_texture", str(profile.get("broken", "")))
	actor.set_meta("broken_frame", int(data.get("broken_frame", 1)))
	actor.set_meta("branch_target", true)
	_restore_breakable_state(actor)
	if bool(data.get("blocks_enemy_motion", true)):
		var visual_radius := EnemyPursuitControllerScript.prop_radius(visual_prop_id)
		var blocker_radius := float(data.get(
			"blocker_radius",
			visual_radius if visual_radius > 0.0 else clampf(world_scale * 0.82, 0.28, 1.2)
		))
		var default_height := 3.4 if visual_prop_id == "mansion_double_door" else clampf(blocker_radius * 2.0, 0.55, 2.4)
		actor.set_meta("enemy_blocker_radius", maxf(0.0, blocker_radius))
		actor.set_meta("enemy_blocker_height", float(data.get("blocker_height", default_height)))
		actor.set_meta("enemy_blocker_source", "breakable")


func _pickup_texture_path(pickup_type: String) -> String:
	return str(gameplay_support_library.get_pickup(pickup_type).get("path", ""))


func _spawn_pickup(data: Dictionary) -> void:
	var pickup_type := str(data.get("pickup", "medal"))
	var pickup_profile := gameplay_support_library.get_pickup(pickup_type)
	if pickup_profile.is_empty():
		push_error("Unknown pickup profile: %s" % pickup_type)
		return
	var position_data := data.get("position", [0.0, 0.8, -9.0]) as Array
	var pickup_scale := float(data.get("scale", 0.65))
	var actor_stats := {
		"health": 1.0, "speed": 0.0, "scale": pickup_scale, "score": 0,
		"custom_texture": str(pickup_profile.get("path", "")),
		"pixel_size": float(data.get("pixel_size", 0.0032)) * pickup_scale
	}
	var pickup_id := str(data.get("id", "%s_%d" % [pickup_type, active_actors.size()]))
	var actor := _create_actor(pickup_id, Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2])), actor_stats, "pickup")
	var pickup_controller: PickupController = PickupControllerScript.new()
	pickup_controller.name = "PickupController"
	pickup_controller.configure({
		"id": pickup_id,
		"pickup": pickup_type,
		"motion": str(data.get("motion", "bob")),
		"phase": float(data.get("phase", active_actors.size())) * 0.71,
	})
	actor.add_child(pickup_controller)
	actor.set_meta("pickup", pickup_type)
	actor.set_meta("pickup_origin_y", actor.position.y)
	actor.set_meta("pickup_motion", str(data.get("motion", "bob")))
	actor.set_meta("pickup_phase", float(data.get("phase", active_actors.size())) * 0.71)




func _create_actor(actor_id: String, actor_position: Vector3, stats: Dictionary, role: String) -> Node3D:
	var actor := Node3D.new()
	actor.name = "%s_%d" % [actor_id, Time.get_ticks_msec()]
	actor.position = actor_position
	actor.set_meta("actor_id", actor_id)
	actor.set_meta("role", role)
	actor.set_meta("health", float(stats.get("health", 3.0)))
	actor.set_meta("max_health", float(stats.get("health", 3.0)))
	actor.set_meta("speed", float(stats.get("speed", 0.8)))
	actor.set_meta("score", int(stats.get("score", 80)))
	actor.set_meta("visual_scale", float(stats.get("scale", 1.0)))
	actor.set_meta("behavior", str(stats.get("behavior", "walk")))
	actor.set_meta("hitbox_profile", str(stats.get("hitbox_profile", "humanoid")))
	actor.set_meta("dead", false)
	actor.set_meta("attacks", 0)
	actor.set_meta("animation_time", 0.0)
	actor.set_meta("age", 0.0)
	actor.set_meta("frame", 0)
	actor.set_meta("animation_state", 0)
	actor.set_meta("hit_timer", 0.0)
	actor.set_meta("attack_animation_timer", 0.0)
	actor.set_meta("visual_forward", Vector3.BACK)
	actor.set_meta("last_visual_position", actor_position)
	actor.set_meta("visual_motion", 0.0)
	actor_root.add_child(actor)

	var actor_scale := float(stats.get("scale", 1.0))
	var sprite := Sprite3D.new()
	sprite.name = "Sprite3D"
	if role in ["breakable", "pickup"]:
		var item_path := str(stats.get("custom_texture", _pickup_texture_path(actor_id)))
		if item_path.is_empty():
			push_error("No item texture for %s: %s" % [role, actor_id])
		else:
			sprite.texture = load(item_path) as Texture2D
		sprite.hframes = maxi(1, int(stats.get("hframes", 1)))
		sprite.frame = clampi(int(stats.get("frame", 0)), 0, sprite.hframes - 1)
		sprite.pixel_size = float(stats.get("pixel_size", 0.0075))
		sprite.position.y = 0.0
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST if role == "pickup" else BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	elif role == "projectile":
		var projectile_profile := gameplay_support_library.get_projectile(actor_id)
		sprite.texture = gameplay_support_library.load_texture(projectile_profile)
		sprite.pixel_size = float(stats.get("pixel_size", 0.0025)) * actor_scale
		sprite.position.y = 0.0
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	else:
		_configure_actor_sprite(sprite, actor_id, actor_scale)
	sprite.modulate = Color.from_string(str(stats.get("tint", "#ffffff")), Color.WHITE)
	actor.add_child(sprite)

	var shadow := Decal.new()
	shadow.name = "ContactShadow"
	shadow.size = Vector3(1.35, 0.08, 0.82) * float(stats.get("scale", 1.0))
	shadow.position = Vector3(0.0, 0.025, 0.0)
	actor.add_child(shadow)

	_add_actor_hit_zones(actor, role, actor_scale)
	active_actors.append(actor)
	return actor

func _add_actor_hit_zones(actor: Node3D, role: String, actor_scale: float) -> void:
	if role not in ["enemy", "boss"]:
		var body_y := 0.45 if role == "projectile" else 1.0
		var body_size := Vector3(0.48, 0.48, 0.24) if role == "projectile" else Vector3(0.58, 1.05, 0.32)
		_add_hit_zone(actor, "body", Vector3(0.0, body_y, 0.0) * actor_scale, body_size * actor_scale, 1.0)
		return
	match str(actor.get_meta("hitbox_profile", "humanoid")):
		"flying_small":
			_add_hit_zone(actor, "body", Vector3(0.0, 0.62, 0.0) * actor_scale, Vector3(0.72, 0.56, 0.34) * actor_scale, 1.0)
		"low_creature", "crawler":
			_add_hit_zone(actor, "head", Vector3(0.0, 0.66, 0.12) * actor_scale, Vector3(0.38, 0.3, 0.35) * actor_scale, 1.4)
			_add_hit_zone(actor, "torso", Vector3(0.0, 0.38, -0.12) * actor_scale, Vector3(0.78, 0.42, 0.62) * actor_scale, 1.0)
		"heavy_humanoid":
			_add_hit_zone(actor, "head", Vector3(0.0, 1.78, 0.0) * actor_scale, Vector3(0.4, 0.4, 0.34) * actor_scale, 2.0)
			_add_hit_zone(actor, "torso", Vector3(0.0, 1.05, 0.0) * actor_scale, Vector3(0.84, 0.82, 0.42) * actor_scale, 1.0)
			_add_hit_zone(actor, "left_arm", Vector3(-0.68, 1.1, 0.0) * actor_scale, Vector3(0.28, 0.68, 0.28) * actor_scale, 0.78)
			_add_hit_zone(actor, "right_arm", Vector3(0.68, 1.1, 0.0) * actor_scale, Vector3(0.28, 0.68, 0.28) * actor_scale, 0.78)
			_add_hit_zone(actor, "legs", Vector3(0.0, 0.42, 0.0) * actor_scale, Vector3(0.68, 0.54, 0.34) * actor_scale, 0.68)
		_:
			_add_hit_zone(actor, "head", Vector3(0.0, 1.68, 0.0) * actor_scale, Vector3(0.34, 0.34, 0.3) * actor_scale, 2.0)
			_add_hit_zone(actor, "torso", Vector3(0.0, 1.05, 0.0) * actor_scale, Vector3(0.62, 0.72, 0.34) * actor_scale, 1.0)
			_add_hit_zone(actor, "left_arm", Vector3(-0.52, 1.08, 0.0) * actor_scale, Vector3(0.23, 0.62, 0.25) * actor_scale, 0.78)
			_add_hit_zone(actor, "right_arm", Vector3(0.52, 1.08, 0.0) * actor_scale, Vector3(0.23, 0.62, 0.25) * actor_scale, 0.78)
			_add_hit_zone(actor, "legs", Vector3(0.0, 0.42, 0.0) * actor_scale, Vector3(0.52, 0.52, 0.28) * actor_scale, 0.68)



func _add_hit_zone(actor: Node3D, zone: String, local_position: Vector3, zone_size: Vector3, multiplier: float) -> void:
	var area := Area3D.new()
	area.name = "HitZone_%s" % zone
	area.collision_layer = 2
	area.collision_mask = 0
	area.monitoring = false
	area.monitorable = true
	area.position = local_position
	area.set_meta("actor", actor)
	area.set_meta("zone", zone)
	area.set_meta("multiplier", multiplier)
	actor.add_child(area)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = zone_size
	shape.shape = box
	area.add_child(shape)


func _update_actors(delta: float) -> void:
	var environment_blockers := _environment_floor_blockers()
	var walkable_surfaces := _environment_walkable_surfaces()
	for actor in active_actors.duplicate():
		if not is_instance_valid(actor):
			active_actors.erase(actor)
			continue
		if bool(actor.get_meta("dead", false)):
			continue
		var role := str(actor.get_meta("role", "enemy"))
		var age := float(actor.get_meta("age", 0.0)) + delta
		actor.set_meta("age", age)
		actor.set_meta("animation_time", float(actor.get_meta("animation_time", 0.0)) + delta)
		actor.set_meta("hit_timer", maxf(0.0, float(actor.get_meta("hit_timer", 0.0)) - delta))
		actor.set_meta("attack_animation_timer", maxf(0.0, float(actor.get_meta("attack_animation_timer", 0.0)) - delta))
		var last_visual_position: Vector3 = actor.get_meta("last_visual_position", actor.position) as Vector3
		var visual_motion: Vector3 = actor.position - last_visual_position
		visual_motion.y = 0.0
		actor.set_meta("visual_motion", visual_motion.length())
		if visual_motion.length_squared() > 0.000001:
			actor.set_meta("visual_forward", visual_motion.normalized())
		elif role == "civilian":
			var civilian_forward: Vector3 = camera_3d.global_position - actor.global_position
			civilian_forward.y = 0.0
			if not civilian_forward.is_zero_approx():
				actor.set_meta("visual_forward", civilian_forward.normalized())
		actor.set_meta("last_visual_position", actor.position)
		_animate_actor(actor, delta)
		if role == "pickup":
			var pickup_origin_y := float(actor.get_meta("pickup_origin_y", actor.position.y))
			var pickup_controller := actor.get_node_or_null("PickupController") as PickupController
			if pickup_controller != null:
				actor.position.y = pickup_origin_y + pickup_controller.vertical_offset(age)
			else:
				var pickup_phase := float(actor.get_meta("pickup_phase", 0.0))
				var pickup_motion := str(actor.get_meta("pickup_motion", "bob"))
				actor.position.y = pickup_origin_y + (absf(sin(age * 3.6 + pickup_phase)) * 0.22 if pickup_motion == "hop" else sin(age * 2.5 + pickup_phase) * 0.09)
			var pickup_sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
			if pickup_sprite != null:
				pickup_sprite.modulate.a = pickup_controller.alpha_at(age) if pickup_controller != null else 1.0
			continue
		if role == "civilian":
			if bool(actor.get_meta("rescued", false)):
				var rescued_age := float(actor.get_meta("rescued_age", 0.0)) + delta
				actor.set_meta("rescued_age", rescued_age)
				var escape_sign := float(actor.get_meta("escape_sign", 1.0))
				actor.position.x += escape_sign * delta * 1.45
				actor.position.z -= delta * 0.72
				actor.set_meta("visual_forward", Vector3(escape_sign, 0.0, -0.5).normalized())
				if rescued_age >= 1.65:
					active_actors.erase(actor)
					if actor == active_civilian:
						active_civilian = null
					actor.queue_free()
			elif state == "node":
				var civilian_controller := actor.get_node_or_null("CivilianController") as CivilianController
				var rescue_window_expired := (
					civilian_controller.advance_danger(delta)
					if civilian_controller != null
					else node_elapsed >= float(actor.get_meta("deadline", 999.0))
				)
				if rescue_window_expired:
					_expire_civilian_rescue_window(actor)
			continue
		if role != "enemy" and role != "projectile":
			continue
		var movement_origin: Vector3 = actor.global_position
		var behavior := str(actor.get_meta("behavior", actor.get_meta("pattern", "walk")))
		var speed := float(actor.get_meta("speed", 0.8))
		var lane := float(actor.get_meta("lane", actor.position.x))
		var ground_y := float(actor.get_meta("ground_y", actor.position.y))
		var forward_speed := speed
		var authored_lane_offset := 0.0
		if role == "projectile":
			_update_projectile_tracking(actor, delta)
		var uses_civilian_target_motion: bool = role == "enemy" and _update_civilian_attacker_motion(actor, behavior, delta)
		var uses_directional_projectile_motion: bool = role == "projectile" and actor.has_meta("travel_direction")
		if not uses_civilian_target_motion and not uses_directional_projectile_motion:
			match behavior:
				"charge":
					var charge_window := age >= float(actor.get_meta("attack_ready_age", 999.0)) - 1.25
					forward_speed *= float(actor.get_meta("charge_factor", 1.9)) if charge_window else 0.72
					authored_lane_offset = sin(age * 2.2) * 0.18
				"throw_projectile":
					forward_speed *= 0.52
					authored_lane_offset = sin(age * 1.7) * 0.26
				"ceiling_drop":
					var drop_duration := maxf(0.1, float(actor.get_meta("drop_duration", 1.1)))
					var drop_progress := clampf(age / drop_duration, 0.0, 1.0)
					var drop_eased := drop_progress * drop_progress * (3.0 - 2.0 * drop_progress)
					actor.position.y = lerpf(ground_y + float(actor.get_meta("drop_height", 4.2)), ground_y, drop_eased)
					forward_speed = 0.0 if drop_progress < 1.0 else speed * 1.15
				"jump":
					actor.position.y = ground_y + absf(sin(age * 3.7)) * float(actor.get_meta("jump_height", 1.15))
					authored_lane_offset = sin(age * 2.4) * 0.4
				"flight_swarm":
					var swarm_width := float(actor.get_meta("weave_width", 1.0))
					actor.position.y = ground_y + sin(age * 5.1) * 0.52
					authored_lane_offset = sin(age * 3.6) * swarm_width
					forward_speed *= 1.1
				"aquatic_weave":
					var aquatic_width := float(actor.get_meta("weave_width", 1.1))
					authored_lane_offset = sin(age * 2.9) * aquatic_width
					actor.position.y = ground_y + 0.12 + sin(age * 5.8) * 0.16
				"armored_advance":
					authored_lane_offset = sin(age * 1.25) * 0.16
					forward_speed *= 0.78
				"heavy_weapon":
					authored_lane_offset = sin(age * 0.9) * 0.12
					forward_speed *= 0.58
				"projectile_weave":
					authored_lane_offset = sin(age * 7.2) * 0.48
					actor.position.y = ground_y + sin(age * 8.4) * 0.22
				_:
					actor.position.y = ground_y + sin(age * 4.0) * 0.035
		var pursuit_camera_forward: Vector3 = Vector3.FORWARD
		var pursuit_attack_target: Vector3 = actor.global_position
		if role == "enemy" and not uses_civilian_target_motion:
			var minimum_depth := float(actor.get_meta("minimum_front_depth", EnemyPursuitControllerScript.MIN_MELEE_FRONT_DEPTH))
			if camera_3d != null and is_instance_valid(camera_3d):
				pursuit_camera_forward = EnemyPursuitControllerScript.flat_camera_forward(-camera_3d.global_transform.basis.z)
				pursuit_attack_target = EnemyPursuitControllerScript.attack_point(
					camera_3d.global_position,
					pursuit_camera_forward,
					minimum_depth,
					actor.global_position.y,
					float(actor.get_meta("attack_slot_offset", 0.0)) + authored_lane_offset
				)
			var recovering := int(actor.get_meta("attacks", 0)) > 0 and age < float(actor.get_meta("recovery_until", 0.0))
			var reached_attack_position := false
			if behavior == "throw_projectile":
				if camera_3d != null and is_instance_valid(camera_3d):
					reached_attack_position = EnemyPursuitControllerScript.camera_depth(actor.global_position, camera_3d.global_position, pursuit_camera_forward) <= minimum_depth + 0.02
			else:
				reached_attack_position = _actor_has_melee_contact(actor)
			if bool(actor.get_meta("attack_telegraph_started", false)) or recovering or reached_attack_position:
				forward_speed = 0.0
			else:
				if age >= float(actor.get_meta("attack_ready_age", 999.0)):
					forward_speed = maxf(forward_speed, float(actor.get_meta("attack_approach_speed", 1.25)))
				if state == "node" and camera_3d != null and is_instance_valid(camera_3d):
					var timing_policy := SequenceTimingPolicyScript.campaign_policy(campaign)
					var governor_value: Variant = timing_policy.get("engagement_governor", {})
					var governor_config := governor_value as Dictionary if typeof(governor_value) == TYPE_DICTIONARY else {}
					forward_speed = EnemyPursuitControllerScript.governed_approach_speed(
						actor.global_position,
						pursuit_attack_target,
						node_elapsed,
						rail_duration,
						float(actor.get_meta("attack_telegraph_seconds", DEFAULT_ATTACK_TELEGRAPH_SECONDS)),
						forward_speed,
						governor_config
					)
		if uses_directional_projectile_motion:
			var travel_direction: Vector3 = actor.get_meta("travel_direction", Vector3.ZERO) as Vector3
			if not travel_direction.is_zero_approx():
				actor.global_position += travel_direction.normalized() * forward_speed * delta
		elif not uses_civilian_target_motion:
			if role == "enemy" and camera_3d != null and is_instance_valid(camera_3d):
				if behavior == "throw_projectile":
					actor.position.x = move_toward(actor.position.x, lane + authored_lane_offset, maxf(0.1, forward_speed) * delta)
					actor.global_position -= pursuit_camera_forward * forward_speed * delta
				else:
					actor.global_position = EnemyPursuitControllerScript.step_toward_attack_point(
						actor.global_position,
						pursuit_attack_target,
						forward_speed,
						delta
					)
			else:
				if not is_zero_approx(authored_lane_offset):
					actor.position.x = lane + authored_lane_offset
				actor.position.z += forward_speed * delta
		if role == "enemy":
			var collision_radius := float(actor.get_meta("collision_radius", EnemyPursuitControllerScript.DEFAULT_ACTOR_RADIUS))
			if camera_3d != null and is_instance_valid(camera_3d):
				actor.global_position = EnemyPursuitControllerScript.resolve_camera_front_motion(
					movement_origin,
					actor.global_position,
					camera_3d.global_position,
					-camera_3d.global_transform.basis.z,
					float(actor.get_meta("minimum_front_depth", EnemyPursuitControllerScript.MIN_MELEE_FRONT_DEPTH)),
					collision_radius,
					environment_blockers
				)
			else:
				actor.global_position = EnemyPursuitControllerScript.resolve_floor_prop_motion(
					movement_origin, actor.global_position, collision_radius, environment_blockers
				)
			_snap_enemy_to_walkable_surface(actor, walkable_surfaces)
		var moved_distance: float = movement_origin.distance_to(actor.global_position)
		if role == "projectile":
			actor.set_meta("travelled_distance", float(actor.get_meta("travelled_distance", 0.0)) + moved_distance)
			if _actor_is_attack_visible(actor):
				actor.set_meta("seen_by_camera", true)
				actor.set_meta("visible_travel_distance", float(actor.get_meta("visible_travel_distance", 0.0)) + moved_distance)
			if EnemyPursuitControllerScript.segment_hits_floor_prop(movement_origin, actor.global_position, 0.12, environment_blockers):
				_spawn_impact(actor.global_position, "projectile")
				_kill_actor(actor, -1, false)
				continue
			_resolve_projectile_contact(actor)
		elif state in ["node", "boss"]:
			_update_enemy_attack(actor, age)


func _animate_actor(actor: Node3D, delta: float = 0.0) -> void:
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null or str(actor.get_meta("role", "enemy")) in ["breakable", "pickup", "projectile"]:
		return
	if sprite.has_meta("directional_clip_player_v3"):
		_animate_actor_v3(actor, sprite, delta)
		return
	var local_frame := 0
	var attack_timer := float(actor.get_meta("attack_animation_timer", 0.0))
	if bool(actor.get_meta("dead", false)):
		local_frame = 7
	elif float(actor.get_meta("hit_timer", 0.0)) > 0.0:
		local_frame = 6
	elif attack_timer > 0.0:
		local_frame = 4 if attack_timer > 0.17 else 5
	elif float(actor.get_meta("visual_motion", 0.0)) > 0.0005 or (str(actor.get_meta("role", "")) in ["enemy", "projectile"] and float(actor.get_meta("speed", 0.0)) > 0.0):
		local_frame = 1 + (int(float(actor.get_meta("animation_time", 0.0)) * 7.0) % 3)
	actor.set_meta("animation_state", local_frame)
	var direction := _apply_directional_sprite_frame(actor, local_frame)
	actor.set_meta("direction_index", direction)
	actor.set_meta("frame", sprite.frame)


func _animate_actor_v3(actor: Node3D, sprite: Sprite3D, delta: float) -> void:
	var clip_player = sprite.get_meta("directional_clip_player_v3")
	var desired_clip := "idle"
	var semantic_state := 0
	var attack_timer := float(actor.get_meta("attack_animation_timer", 0.0))
	if bool(actor.get_meta("dead", false)):
		desired_clip = "death_fall"
		semantic_state = 7
	elif float(actor.get_meta("hit_timer", 0.0)) > 0.0:
		desired_clip = "hit_recoil"
		semantic_state = 6
	elif attack_timer > 0.0:
		desired_clip = "attack"
		semantic_state = 4 if attack_timer > 0.17 else 5
	elif float(actor.get_meta("visual_motion", 0.0)) > 0.0005 or (
		str(actor.get_meta("role", "")) == "enemy" and float(actor.get_meta("speed", 0.0)) > 0.0
	):
		desired_clip = "locomotion"
		semantic_state = 1 + (clip_player.current_frame % 3)
	if str(clip_player.current_clip_id) != desired_clip:
		if not _play_actor_v3_clip(actor, desired_clip):
			return
	clip_player.set_paused(paused_by_player)
	if not clip_player.advance(maxf(0.0, delta)):
		push_warning("Sprite V3 advance failed: %s" % str(clip_player.last_error))
		return
	var actor_forward := actor.get_meta("visual_forward", Vector3.BACK) as Vector3
	var camera_position := actor.global_position - actor_forward
	if camera_3d != null and is_instance_valid(camera_3d):
		camera_position = camera_3d.global_position
	var direction: int = clip_player.update_view(actor_forward, camera_position, actor.global_position)
	actor.set_meta("animation_state", semantic_state)
	actor.set_meta("direction_index", direction)
	actor.set_meta("frame", sprite.frame)


func _constrain_enemy_to_encounter_front(actor: Node3D) -> void:
	if camera_3d == null or not is_instance_valid(camera_3d):
		return
	var minimum_depth := float(actor.get_meta("minimum_front_depth", EnemyPursuitControllerScript.MIN_MELEE_FRONT_DEPTH))
	actor.global_position = EnemyPursuitControllerScript.clamp_to_camera_front(
		actor.global_position,
		camera_3d.global_position,
		-camera_3d.global_transform.basis.z,
		minimum_depth
	)


func _environment_floor_blockers() -> Array[Dictionary]:
	var blockers: Array[Dictionary] = []
	if world_root == null or not is_instance_valid(world_root):
		return blockers
	for child in world_root.get_children():
		var sprite := child as Sprite3D
		if sprite != null:
			var radius := float(sprite.get_meta("enemy_blocker_radius", 0.0))
			if radius <= 0.0:
				continue
			var prop_id := str(sprite.get_meta("environment_prop_id", ""))
			if prop_id in ["estate_gate", "mansion_double_door"] and sprite.frame > 0:
				continue
			var half_height := maxf(0.2, float(sprite.get_meta("enemy_blocker_height", 1.0)) * 0.5)
			blockers.append({
				"position": sprite.global_position,
				"radius": radius,
				"min_y": sprite.global_position.y - half_height,
				"max_y": sprite.global_position.y + half_height,
				"source": "prop",
			})
			continue
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not mesh_instance.has_meta("enemy_blocker_half_extents"):
			continue
		var half_extents: Vector2 = mesh_instance.get_meta("enemy_blocker_half_extents", Vector2.ZERO) as Vector2
		if half_extents.x <= 0.0 or half_extents.y <= 0.0:
			continue
		var mesh_half_height := maxf(0.2, float(mesh_instance.get_meta("enemy_blocker_height", 1.0)) * 0.5)
		var mesh_position := mesh_instance.global_position if mesh_instance.is_inside_tree() else mesh_instance.position
		var mesh_rotation_y := mesh_instance.global_rotation.y if mesh_instance.is_inside_tree() else mesh_instance.rotation.y
		blockers.append({
			"position": mesh_position,
			"half_extents": half_extents,
			"rotation_y": mesh_rotation_y,
			"min_y": mesh_position.y - mesh_half_height,
			"max_y": mesh_position.y + mesh_half_height,
			"source": "layout_mesh",
		})
	for actor in active_actors:
		if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)) or str(actor.get_meta("role", "")) != "breakable":
			continue
		var actor_radius := maxf(0.0, float(actor.get_meta("enemy_blocker_radius", 0.0)))
		if actor_radius <= 0.0:
			continue
		var actor_height := maxf(0.2, float(actor.get_meta("enemy_blocker_height", 1.0)))
		blockers.append({
			"position": actor.global_position,
			"radius": actor_radius,
			"min_y": actor.global_position.y - actor_height * 0.5,
			"max_y": actor.global_position.y + actor_height * 0.5,
			"source": "breakable",
			"actor": actor,
		})
	return blockers


func _environment_walkable_surfaces() -> Array[Dictionary]:
	var surfaces: Array[Dictionary] = []
	if world_root == null or not is_instance_valid(world_root):
		return surfaces
	for child in world_root.get_children():
		var mesh_instance := child as MeshInstance3D
		if mesh_instance == null or not mesh_instance.has_meta("enemy_walkable_dimensions"):
			continue
		var dimensions: Vector3 = mesh_instance.get_meta("enemy_walkable_dimensions", Vector3.ZERO) as Vector3
		if dimensions.x <= 0.0 or dimensions.y <= 0.0 or dimensions.z <= 0.0:
			continue
		var surface_transform := mesh_instance.global_transform if mesh_instance.is_inside_tree() else mesh_instance.transform
		surfaces.append(WalkableSurfaceResolverScript.make_box_surface(
			surface_transform,
			dimensions,
			str(mesh_instance.name)
		))
	return surfaces


func _snap_enemy_to_walkable_surface(actor: Node3D, surfaces: Array[Dictionary]) -> void:
	if not is_instance_valid(actor) or surfaces.is_empty():
		return
	var behavior := str(actor.get_meta("behavior", "walk"))
	if behavior == "flight_swarm":
		return
	var previous_ground := float(actor.get_meta("ground_y", actor.global_position.y))
	var vertical_offset := actor.global_position.y - previous_ground
	var resolved_ground := WalkableSurfaceResolverScript.resolve_ground_height(actor.global_position, previous_ground, surfaces)
	actor.set_meta("ground_y", resolved_ground)
	actor.global_position.y = resolved_ground + vertical_offset


func _has_live_civilian_target(actor: Node3D) -> bool:
	return (
		bool(actor.get_meta("target_civilian", false))
		and active_civilian != null
		and is_instance_valid(active_civilian)
		and not bool(active_civilian.get_meta("dead", false))
		and not bool(active_civilian.get_meta("rescued", false))
	)


func _civilian_attack_anchor(actor: Node3D) -> Vector3:
	var civilian_scale := maxf(0.25, float(active_civilian.get_meta("visual_scale", 1.0)))
	var attacker_scale := maxf(0.25, float(actor.get_meta("visual_scale", 1.0)))
	return active_civilian.global_position + Vector3.UP * (0.9 * civilian_scale - 0.9 * attacker_scale)


func _update_civilian_attacker_motion(actor: Node3D, behavior: String, delta: float) -> bool:
	if not _has_live_civilian_target(actor):
		return false
	var offset := _civilian_attack_anchor(actor) - actor.global_position
	if not offset.is_zero_approx():
		var facing := offset
		facing.y = 0.0
		if not facing.is_zero_approx():
			actor.set_meta("visual_forward", facing.normalized())
	if behavior == "throw_projectile" or bool(actor.get_meta("attack_telegraph_started", false)):
		return true
	var stop_distance := maxf(0.55, float(actor.get_meta("melee_range", DEFAULT_MELEE_RANGE)) * 0.72)
	var distance := offset.length()
	if distance > stop_distance:
		var step := minf(float(actor.get_meta("speed", 0.8)) * delta, distance - stop_distance)
		actor.global_position += offset.normalized() * step
	return true


func _update_enemy_attack(actor: Node3D, age: float) -> bool:
	if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)) or str(actor.get_meta("role", "")) != "enemy":
		return false
	if age < float(actor.get_meta("attack_ready_age", 999.0)):
		actor.set_meta("attack_state", "recovery" if int(actor.get_meta("attacks", 0)) > 0 else "approach")
		return false
	var behavior := str(actor.get_meta("behavior", "walk"))
	var requires_contact := behavior != "throw_projectile"
	var visible := _actor_is_attack_visible(actor)
	var has_contact := not requires_contact or _actor_has_melee_contact(actor)
	if not bool(actor.get_meta("attack_telegraph_started", false)):
		if not visible or not has_contact:
			return false
		var telegraph_seconds := maxf(0.2, float(actor.get_meta("attack_telegraph_seconds", DEFAULT_ATTACK_TELEGRAPH_SECONDS)))
		actor.set_meta("attack_state", "windup")
		actor.set_meta("attack_telegraph_started", true)
		actor.set_meta("attack_telegraph_complete", false)
		actor.set_meta("attack_commit_age", age + telegraph_seconds)
		actor.set_meta("attack_animation_timer", telegraph_seconds)
		_play_sfx("danger")
		return false
	if not visible or not has_contact:
		_cancel_attack_telegraph(actor, age + 0.25)
		return false
	var remaining := float(actor.get_meta("attack_commit_age", age)) - age
	if remaining > 0.0:
		actor.set_meta("attack_animation_timer", maxf(float(actor.get_meta("attack_animation_timer", 0.0)), remaining))
		return false
	actor.set_meta("attack_telegraph_complete", true)
	actor.set_meta("attack_state", "strike")
	return _actor_attack(actor)


func _cancel_attack_telegraph(actor: Node3D, next_ready_age: float) -> void:
	actor.set_meta("attack_telegraph_started", false)
	actor.set_meta("attack_telegraph_complete", false)
	actor.set_meta("attack_commit_age", 1.0e20)
	actor.set_meta("attack_animation_timer", 0.0)
	actor.set_meta("attack_state", "approach")
	actor.set_meta("attack_ready_age", next_ready_age)


func _finish_enemy_attack_cycle(actor: Node3D) -> void:
	var age := float(actor.get_meta("age", 0.0))
	var period := maxf(0.35, float(actor.get_meta("attack_period", 1.8)))
	_cancel_attack_telegraph(actor, age + period)
	actor.set_meta("attack_state", "recovery")
	actor.set_meta("recovery_until", age + period)
	actor.set_meta("attack_animation_timer", maxf(float(actor.get_meta("attack_animation_timer", 0.0)), 0.2))
	actor.set_meta("attack_at", node_elapsed + period)
	var attacks := int(actor.get_meta("attacks", 0)) + 1
	actor.set_meta("attacks", attacks)


func _actor_has_melee_contact(actor: Node3D) -> bool:
	if camera_3d == null or not is_instance_valid(camera_3d):
		return false
	var target_position := camera_3d.global_position
	if bool(actor.get_meta("target_civilian", false)):
		if not _has_live_civilian_target(actor):
			return false
		var civilian_scale := maxf(0.25, float(active_civilian.get_meta("visual_scale", 1.0)))
		target_position = active_civilian.global_position + Vector3.UP * (0.9 * civilian_scale)
	var attacker_scale := maxf(0.25, float(actor.get_meta("visual_scale", 1.0)))
	var attacker_contact_point := actor.global_position + Vector3.UP * (0.9 * attacker_scale)
	if attacker_contact_point.distance_to(target_position) > maxf(0.5, float(actor.get_meta("melee_range", DEFAULT_MELEE_RANGE))):
		return false
	# Sprite visibility does not imply render visibility: walls and closed props
	# can depth-occlude a billboard while its projected focus remains on-screen.
	return not EnemyPursuitControllerScript.segment_hits_floor_prop(
		attacker_contact_point, target_position, 0.04, _environment_floor_blockers()
	)


func _actor_is_attack_visible(actor: Node3D) -> bool:
	if not is_instance_valid(actor) or camera_3d == null or not is_instance_valid(camera_3d):
		return false
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null or sprite.texture == null or not sprite.visible or sprite.modulate.a <= 0.05:
		return false
	var visual_scale := maxf(0.25, float(actor.get_meta("visual_scale", 1.0)))
	var focus := actor.global_position + Vector3(0.0, 0.85 * visual_scale, 0.0)
	if camera_3d.is_position_behind(focus):
		return false
	return active_play_rect.grow(18.0).has_point(camera_3d.unproject_position(focus))


func _actor_attack(actor: Node3D) -> bool:
	if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)):
		return false
	var role := str(actor.get_meta("role", "enemy"))
	if role == "projectile":
		return _resolve_projectile_contact(actor)
	if role != "enemy" or not bool(actor.get_meta("attack_telegraph_complete", false)) or not _actor_is_attack_visible(actor):
		return false
	var behavior := str(actor.get_meta("behavior", "walk"))
	var performed := false
	if behavior == "throw_projectile":
		performed = _spawn_enemy_projectile(actor) != null
	else:
		if not _actor_has_melee_contact(actor):
			return false
		if bool(actor.get_meta("target_civilian", false)):
			if not _has_live_civilian_target(actor):
				return false
			_kill_civilian(active_civilian, false, 0, &"enemy_melee_contact")
			actor.set_meta("target_civilian", false)
		else:
			var target_player_index := _target_player_for_threat(actor)
			if target_player_index < 0:
				return false
			_damage_player(target_player_index, 1, "enemy_melee")
		performed = true
	if performed:
		_finish_enemy_attack_cycle(actor)
	else:
		_cancel_attack_telegraph(actor, float(actor.get_meta("age", 0.0)) + 0.35)
	return performed


func _spawn_enemy_projectile(owner: Node3D) -> Node3D:
	if not bool(owner.get_meta("projectile_destructible", false)) or not bool(owner.get_meta("attack_telegraph_complete", false)):
		return null
	var projectile_id := str(owner.get_meta("projectile_asset", ""))
	if gameplay_support_library.get_projectile(projectile_id).is_empty():
		return null
	var projectile_stats := {"health": 1.0, "speed": float(owner.get_meta("projectile_speed", 4.0)), "scale": 0.72, "score": 0, "pixel_size": 0.0026}
	var authored_civilian_target := bool(owner.get_meta("target_civilian", false))
	var targets_civilian := _has_live_civilian_target(owner)
	if authored_civilian_target and not targets_civilian:
		return null
	var target_player_index := -1
	if not targets_civilian:
		target_player_index = _target_player_for_threat(owner)
		if target_player_index < 0:
			return null
	var projectile := _create_actor(projectile_id, owner.position + Vector3(0.0, 1.1, 0.45), projectile_stats, "projectile")
	projectile.set_meta("destructible", true)
	projectile.set_meta("launch_telegraphed", true)
	projectile.set_meta("behavior", "projectile_weave")
	projectile.set_meta("pattern", "projectile_weave")
	projectile.set_meta("lane", owner.position.x)
	projectile.set_meta("ground_y", projectile.position.y)
	projectile.set_meta("spawn_position", projectile.global_position)
	projectile.set_meta("travelled_distance", 0.0)
	projectile.set_meta("visible_travel_distance", 0.0)
	projectile.set_meta("seen_by_camera", false)
	var minimum_visible_travel := float(owner.get_meta("projectile_min_travel", DEFAULT_PROJECTILE_MIN_VISIBLE_TRAVEL))
	var contact_range := float(owner.get_meta("projectile_contact_range", DEFAULT_PROJECTILE_CONTACT_RANGE))
	projectile.set_meta("contact_range", contact_range)
	projectile.set_meta("target_civilian", targets_civilian)
	if not targets_civilian:
		projectile.set_meta("target_player_index", target_player_index)
	var target_position := camera_3d.global_position if camera_3d != null and is_instance_valid(camera_3d) else projectile.global_position + Vector3.BACK * 8.0
	if targets_civilian:
		target_position = active_civilian.global_position + Vector3.UP
	var target_offset := target_position - projectile.global_position
	if not target_offset.is_zero_approx():
		projectile.set_meta("behavior", "targeted_projectile")
		projectile.set_meta("pattern", "targeted_projectile")
		projectile.set_meta("travel_direction", target_offset.normalized())
		projectile.set_meta("target_position", target_position)
		projectile.set_meta("tracks_camera_target", not targets_civilian)
		projectile.set_meta("tracking_turn_rate", deg_to_rad(210.0))
		if targets_civilian:
			minimum_visible_travel = minf(minimum_visible_travel, maxf(0.5, target_offset.length() - contact_range - 0.2))
	projectile.set_meta("minimum_visible_travel", minimum_visible_travel)
	return projectile


func _update_projectile_tracking(projectile: Node3D, delta: float) -> void:
	if (
		not is_instance_valid(projectile)
		or not bool(projectile.get_meta("tracks_camera_target", false))
		or camera_3d == null
		or not is_instance_valid(camera_3d)
	):
		return
	# Once a projectile has been presented to the player, it cannot steer while
	# off-screen and curve back invisibly. The existing contact gate still
	# requires current visibility and minimum visible travel.
	if bool(projectile.get_meta("seen_by_camera", false)) and not _actor_is_attack_visible(projectile):
		return
	var target_position := camera_3d.global_position
	var desired := target_position - projectile.global_position
	if desired.is_zero_approx():
		return
	desired = desired.normalized()
	var current: Vector3 = projectile.get_meta("travel_direction", desired) as Vector3
	current = desired if current.is_zero_approx() else current.normalized()
	var angle := current.angle_to(desired)
	var maximum_turn := maxf(0.0, float(projectile.get_meta("tracking_turn_rate", deg_to_rad(210.0)))) * maxf(0.0, delta)
	var weight := 1.0 if angle <= maximum_turn or angle <= 0.00001 else clampf(maximum_turn / angle, 0.0, 1.0)
	var steered := current.slerp(desired, weight)
	projectile.set_meta("travel_direction", desired if steered.is_zero_approx() else steered.normalized())
	projectile.set_meta("target_position", target_position)


func _resolve_projectile_contact(projectile: Node3D) -> bool:
	if not is_instance_valid(projectile) or bool(projectile.get_meta("dead", false)) or str(projectile.get_meta("role", "")) != "projectile":
		return false
	if state not in ["node", "boss"]:
		return false
	var currently_visible := _actor_is_attack_visible(projectile)
	if currently_visible:
		projectile.set_meta("seen_by_camera", true)
	var can_damage := bool(projectile.get_meta("destructible", false)) and bool(projectile.get_meta("launch_telegraphed", false))
	can_damage = can_damage and bool(projectile.get_meta("seen_by_camera", false)) and currently_visible
	can_damage = can_damage and float(projectile.get_meta("visible_travel_distance", 0.0)) >= maxf(0.5, float(projectile.get_meta("minimum_visible_travel", DEFAULT_PROJECTILE_MIN_VISIBLE_TRAVEL)))
	var aimed_at_civilian := bool(projectile.get_meta("target_civilian", false))
	var target_is_civilian := aimed_at_civilian and _has_live_civilian_target(projectile)
	var target_player_index := int(projectile.get_meta("target_player_index", -1))
	var target_available := target_is_civilian if aimed_at_civilian else _is_live_player(target_player_index)
	var target_position := camera_3d.global_position if camera_3d != null else Vector3.ZERO
	if target_is_civilian:
		target_position = active_civilian.global_position + Vector3.UP
	elif aimed_at_civilian:
		target_position = projectile.get_meta("target_position", projectile.global_position) as Vector3
	can_damage = can_damage and target_available
	var has_contact := projectile.global_position.distance_to(target_position) <= maxf(0.5, float(projectile.get_meta("contact_range", DEFAULT_PROJECTILE_CONTACT_RANGE)))
	if not target_available and has_contact:
		_kill_actor(projectile, -1, false)
		return false
	if can_damage and has_contact:
		if target_is_civilian:
			_kill_civilian(active_civilian, false, 0, &"enemy_projectile_contact")
		else:
			_damage_player(target_player_index, 1, "enemy_projectile")
		_kill_actor(projectile, -1, false)
		return true
	if camera_3d != null and is_instance_valid(camera_3d):
		var camera_forward := -camera_3d.global_transform.basis.z.normalized()
		var camera_depth := (projectile.global_position - camera_3d.global_position).dot(camera_forward)
		if camera_depth < -1.5 or float(projectile.get_meta("travelled_distance", 0.0)) > 50.0:
			_kill_actor(projectile, -1, false)
	return false


func _attempt_shot(player_index: int, screen_position: Vector2) -> void:
	if player_index < 0 or player_index >= players.size() or not bool(players[player_index].active):
		return
	var cinematic_fire_enabled := (
		state == "boss_cinematic"
		and not _boss_cinematic_disables_fire()
	)
	if state not in ["node", "boss", "continue"] and not cinematic_fire_enabled:
		return
	if state == "continue":
		_accept_continue()
		return
	if not active_play_rect.has_point(screen_position):
		_reload(player_index)
		return
	if int(players[player_index].ammo) <= 0:
		_play_sfx("empty")
		_feed("RELOAD!", players[player_index].color)
		return
	players[player_index].ammo = int(players[player_index].ammo) - 1
	players[player_index].shots = int(players[player_index].shots) + 1
	_play_sfx("shot")
	crosshairs[player_index].pulse()
	if not bool(configuration.get("reduced_flashes", false)):
		flash_rect.color.a = 0.13
	var hit := _raycast_actor(screen_position)
	if hit.is_empty():
		hit = _screen_pick_actor(screen_position)
	if not hit.is_empty():
		players[player_index].hits = int(players[player_index].hits) + 1
		_damage_actor(hit.actor as Node3D, str(hit.zone), float(hit.multiplier), player_index)
	_update_hud()


func _raycast_actor(screen_position: Vector2) -> Dictionary:
	var origin := camera_3d.project_ray_origin(screen_position)
	var direction := camera_3d.project_ray_normal(screen_position)
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * 90.0, 2)
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	if result.is_empty():
		return {}
	var collider := result.get("collider") as Area3D
	if collider == null or not collider.has_meta("actor"):
		return {}
	var hit_actor := collider.get_meta("actor") as Node3D
	if not is_instance_valid(hit_actor) or bool(hit_actor.get_meta("dead", false)):
		return {}
	return {"actor": hit_actor, "zone": collider.get_meta("zone", "torso"), "multiplier": collider.get_meta("multiplier", 1.0)}


func _screen_pick_actor(screen_position: Vector2) -> Dictionary:
	var best: Node3D
	var aim_assist := clampf(float(configuration.get("aim_assist", 0.0)), 0.0, 1.0)
	var best_distance := 58.0 + aim_assist * 56.0
	for actor in active_actors:
		if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)):
			continue
		if camera_3d.is_position_behind(actor.global_position + Vector3.UP):
			continue
		var visual_scale := float(actor.get_meta("visual_scale", 1.0))
		var projected := camera_3d.unproject_position(actor.global_position + Vector3(0.0, 1.05 * visual_scale, 0.0))
		var distance := projected.distance_to(screen_position)
		if distance < best_distance:
			best_distance = distance
			best = actor
	if best == null:
		return {}
	var best_scale := float(best.get_meta("visual_scale", 1.0))
	var projected_head := camera_3d.unproject_position(best.global_position + Vector3(0.0, 1.68 * best_scale, 0.0))
	var zone := "head" if projected_head.distance_to(screen_position) < 32.0 + aim_assist * 10.0 else "torso"
	return {"actor": best, "zone": zone, "multiplier": 2.0 if zone == "head" else 1.0}


func _damage_actor(actor: Node3D, zone: String, multiplier: float, player_index: int) -> void:
	if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)):
		return
	var role := str(actor.get_meta("role", "enemy"))
	if role == "civilian":
		_kill_civilian(actor, true, player_index)
		return
	if role == "pickup":
		var pickup_controller := actor.get_node_or_null("PickupController") as PickupController
		if pickup_controller == null or not pickup_controller.collect_by_shot(player_index):
			return
		_play_sfx("rescue")
		_spawn_impact(actor.global_position + Vector3.UP * 0.45, "pickup")
		_apply_pickup(str(actor.get_meta("pickup", "medal")), player_index)
		_kill_actor(actor, player_index, false)
		return
	if role == "projectile":
		if not bool(actor.get_meta("destructible", true)):
			_play_sfx("empty")
			_spawn_impact(actor.global_position + Vector3.UP * 0.5, "armor")
			_feed("PROJECTILE ARMORED", Color(0.8, 0.78, 0.68))
			return
		_play_sfx("projectile_intercept")
		_spawn_impact(actor.global_position + Vector3.UP * 0.5, "projectile")
		_feed("PROJECTILE DESTROYED", Color("#e2cc8c"))
		_kill_actor(actor, -1, false)
		return
	if role == "breakable":
		var breakable_controller := actor.get_node_or_null("BreakableObject") as BreakableObject
		if breakable_controller == null or not breakable_controller.take_damage(1.0, player_index):
			return
		var durability := breakable_controller.durability
		actor.set_meta("health", durability)
		actor.set_meta("hit_timer", 0.22)
		actor.set_meta("last_hit_zone", zone)
		_play_sfx("hit")
		_spawn_impact(actor.global_position + Vector3(0.0, 1.15, 0.05), zone)
		if breakable_controller.is_broken:
			_kill_actor(actor, player_index, true)
		return
	if role == "enemy":
		var armor_zones := actor.get_meta("armor_zones", []) as Array
		var armor_durability := float(actor.get_meta("armor_durability", 0.0))
		if armor_durability > 0.0 and zone in armor_zones:
			armor_durability = maxf(0.0, armor_durability - maxf(1.0, multiplier))
			actor.set_meta("armor_durability", armor_durability)
			_play_sfx("hit")
			_spawn_impact(actor.global_position + Vector3(0.0, 1.15, 0.05), "armor")
			if armor_durability > 0.0:
				_feed("ARMORED", Color(0.8, 0.78, 0.68))
			else:
				actor.set_meta("armor_zones", [])
				_feed("ARMOR BROKEN", Color("#e2b966"))
				var armored_sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
				if armored_sprite != null:
					armored_sprite.modulate = armored_sprite.modulate.darkened(0.16)
			return
	if role == "boss" and bool(actor.get_meta("combat_locked", false)):
		return
	if role == "boss" and not _boss_zone_is_vulnerable(zone):
		_feed("ARMORED", Color(0.8, 0.78, 0.68))
		_play_sfx("empty")
		return
	var damage := multiplier
	var health := float(actor.get_meta("health", 1.0)) - damage
	actor.set_meta("health", health)
	actor.set_meta("hit_timer", 0.22)
	actor.set_meta("last_hit_zone", zone)
	if role == "enemy" and health > 0.0 and bool(actor.get_meta("attack_telegraph_started", false)):
		# A visible recoil cannot coexist with an invisible committed strike.
		# Successful enemy hits interrupt the windup and schedule a fresh,
		# fully visible telegraph after the brief reaction window.
		_cancel_attack_telegraph(actor, float(actor.get_meta("age", 0.0)) + 0.36)
	_play_sfx("hit")
	_spawn_impact(actor.global_position + Vector3(0.0, 1.15 if zone != "head" else 1.68, 0.05), zone)
	if zone == "head" and role == "enemy":
		_add_score(player_index, 120, "HEAD SHOT", str(actor.get_meta("actor_id", "enemy")), "headshot")
	if zone.contains("arm") and health > 0.0 and int(actor.get_meta("limb_hits", 0)) == 0:
		actor.set_meta("limb_hits", 1)
		_spawn_limb(actor.global_position + Vector3(-0.5 if zone == "left_arm" else 0.5, 1.0, 0.0))
	if health <= 0.0:
		_kill_actor(actor, player_index, true)
	elif role == "boss":
		_update_boss_phase()


func _kill_actor(actor: Node3D, player_index: int, award: bool) -> void:
	if not is_instance_valid(actor) or bool(actor.get_meta("dead", false)):
		return
	actor.set_meta("dead", true)
	var role := str(actor.get_meta("role", "enemy"))
	for child in actor.get_children():
		var hit_zone := child as Area3D
		if hit_zone != null:
			hit_zone.set_deferred("monitoring", false)
			hit_zone.set_deferred("monitorable", false)
			hit_zone.set_deferred("collision_layer", 0)
			hit_zone.set_deferred("collision_mask", 0)
	if award and player_index >= 0 and role == "enemy":
		var hit_zone := str(actor.get_meta("last_hit_zone", "body"))
		var kill_shot_type := "headshot_kill" if hit_zone == "head" else "%s_kill" % hit_zone
		_add_score(player_index, int(actor.get_meta("score", 80)), "TARGET DOWN", str(actor.get_meta("actor_id", "enemy")), kill_shot_type)
	if role == "breakable":
		destroyed_breakable_id = str(actor.get_meta("breakable_event_id", actor.get_meta("actor_id", "")))
		var route_target_id := str(actor.get_meta("route_target_id", ""))
		var destroyed_targets := route_condition_context.get("destroyed_route_targets", []) as Array
		if not route_target_id.is_empty() and not destroyed_targets.has(route_target_id):
			destroyed_targets.append(route_target_id)
			route_condition_context["destroyed_route_targets"] = destroyed_targets
		if (
			str(route_condition_context.get("selected_route_target_id", "")).is_empty()
			and RouteOutcomePolicyScript.accepts_route_target(current_node, route_target_id)
		):
			route_condition_context["selected_route_target_id"] = route_target_id
			_set_subtitle("Route selected. Moving through the chosen steel door.", 2.0)
		var pickup_type := str(actor.get_meta("pickup", "medal"))
		var breakable_controller := actor.get_node_or_null("BreakableObject") as BreakableObject
		if breakable_controller != null:
			pickup_type = str(breakable_controller.get_reward().get("pickup", pickup_type))
		if bool(actor.get_meta("spawn_pickup_on_break", false)) and not pickup_type.is_empty():
			var reward_position := actor.position + Vector3(0.0, 0.48, 0.0)
			_spawn_pickup({
				"id": "%s_revealed_%d" % [str(actor.get_meta("actor_id", "secret")), Time.get_ticks_msec()],
				"pickup": pickup_type,
				"position": [reward_position.x, reward_position.y, reward_position.z],
				"motion": "hop",
			})
			# A hidden item is collected by shooting it, like the arcade scenery
			# rewards. Restart the clear hold so the reveal cannot be erased by an
			# immediate rail transition.
			node_clear_elapsed = 0.0
		else:
			_apply_pickup(pickup_type, player_index)
		var broken_path := str(actor.get_meta("broken_texture", ""))
		var breakable_sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
		if breakable_sprite != null and not broken_path.is_empty():
			breakable_sprite.texture = load(broken_path) as Texture2D
		elif breakable_sprite != null and breakable_sprite.hframes > 1:
			breakable_sprite.frame = clampi(int(actor.get_meta("broken_frame", 1)), 0, breakable_sprite.hframes - 1)
	if actor == current_boss:
		_on_boss_defeated()
	active_actors.erase(actor)
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	var retirement_delay := 0.0
	if sprite != null:
		if not retiring_actors.has(actor):
			retiring_actors.append(actor)
		if role != "breakable" and sprite.hframes * sprite.vframes >= 64:
			actor.set_meta("animation_state", 7)
			if sprite.has_meta("directional_clip_player_v3") and _play_actor_v3_clip(actor, "death_fall"):
				var clip_player = sprite.get_meta("directional_clip_player_v3")
				clip_player.seek(0)
				var death_tween := actor.create_tween()
				var death_duration: float = float(maxi(1, clip_player.frame_count - 1)) / maxf(1.0, clip_player.fps)
				# Keep the actor fully opaque until every authored fall frame has
				# been shown. A parallel fade used to free Sam before frame eight.
				retirement_delay = death_duration + 0.18
				death_tween.tween_method(
					Callable(self, "_set_retiring_v3_death_frame").bind(actor),
					0.0,
					float(clip_player.frame_count - 1),
					death_duration
				)
			else:
				_apply_directional_sprite_frame(actor, 7)
		if role == "breakable" and bool(actor.get_meta("persist_broken_visual", true)):
			# Broken doors and scenery remain visible, but stay outside the active
			# actor/blocker lists, until the sequence itself is cleaned up.
			return
		var tween := actor.create_tween()
		if role == "breakable":
			tween.tween_interval(0.42)
		elif retirement_delay > 0.0:
			tween.tween_interval(retirement_delay)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
		tween.parallel().tween_property(actor, "position:y", actor.position.y - 0.35, 0.5)
		tween.tween_callback(Callable(self, "_finalize_actor_retirement").bind(actor))
	else:
		_finalize_actor_retirement(actor)


func _set_retiring_v3_death_frame(frame_value: float, actor: Node3D) -> void:
	if not is_instance_valid(actor):
		return
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null or not sprite.has_meta("directional_clip_player_v3"):
		return
	var clip_player = sprite.get_meta("directional_clip_player_v3")
	clip_player.seek(clampi(roundi(frame_value), 0, clip_player.frame_count - 1))
	var actor_forward := actor.get_meta("visual_forward", Vector3.BACK) as Vector3
	var camera_position := actor.global_position - actor_forward
	if camera_3d != null and is_instance_valid(camera_3d):
		camera_position = camera_3d.global_position
	var direction: int = clip_player.update_view(actor_forward, camera_position, actor.global_position)
	actor.set_meta("direction_index", direction)
	actor.set_meta("frame", sprite.frame)


func _finalize_actor_retirement(actor: Node3D) -> void:
	active_actors.erase(actor)
	retiring_actors.erase(actor)
	if is_instance_valid(actor):
		actor.queue_free()


func _kill_civilian(civilian: Node3D, by_player: bool, player_index: int = 0, visible_reason: StringName = &"enemy_melee_contact") -> void:
	if not is_instance_valid(civilian) or bool(civilian.get_meta("dead", false)):
		return
	var civilian_controller := civilian.get_node_or_null("CivilianController") as CivilianController
	var resolved_reason := &"friendly_fire" if by_player else visible_reason
	if civilian_controller != null and not civilian_controller.confirm_visible_loss(resolved_reason):
		return
	all_scientists_saved = false
	branch_success = false
	var target := str(civilian.get_meta("actor_id", "scientist"))
	if by_player:
		_add_score(player_index, -200, "CIVILIAN HIT", target, "civilian_shot")
		_damage_player(player_index, 1, "civilian", false)
	else:
		_add_score(_first_active_player(), -100, "RESCUE FAILED", target, "enemy_kill")
	_set_subtitle("Scientist lost! The route has changed.", 3.2)
	_kill_actor(civilian, -1, false)


func _rescue_civilian(civilian: Node3D) -> void:
	if not is_instance_valid(civilian) or bool(civilian.get_meta("dead", false)) or bool(civilian.get_meta("rescued", false)):
		return
	var civilian_controller := civilian.get_node_or_null("CivilianController") as CivilianController
	if civilian_controller != null and not civilian_controller.request_rescue(_first_active_player()):
		return
	civilian.set_meta("rescued", true)
	civilian.set_meta("rescued_age", 0.0)
	civilian.set_meta("speed", 1.35)
	civilian.set_meta("animation_time", 0.0)
	branch_success = true
	scientists_saved += 1
	chapter_scientists_saved += 1
	_add_score(_first_active_player(), 400, "SCIENTIST SAVED", str(civilian.get_meta("actor_id", "scientist")), "rescue")
	_play_sfx("rescue")
	_set_subtitle("Thank you! Take the safe route.", 2.8)


func _reload(player_index: int) -> void:
	if player_index < 0 or player_index >= players.size() or not bool(players[player_index].active):
		return
	players[player_index].ammo = MAGAZINE_SIZE
	_play_sfx("reload")
	_feed("P%d RELOAD" % (player_index + 1), players[player_index].color)
	_update_hud()


func _apply_pickup(pickup: String, player_index: int) -> void:
	var recipient := maxi(0, player_index)
	match pickup:
		"life":
			players[recipient].lives = mini(5, int(players[recipient].lives) + 1)
			_feed("LIFE +1", Color("#ef6e72"))
		"frog":
			_add_score(recipient, 1000, "GOLDEN FROG", pickup, "pickup")
		_:
			_add_score(recipient, 200, "MEDAL", pickup, "pickup")


func _add_score(player_index: int, value: int, source: String, target: String = "", shot_type: String = "") -> void:
	if player_index < 0 or player_index >= players.size():
		return
	var score_before := int(players[player_index].score)
	var score_after := maxi(0, score_before + value)
	players[player_index].score = score_after
	var resolved_shot_type := shot_type if not shot_type.is_empty() else source.to_lower().replace(" ", "_")
	_append_score_qa_entry(player_index, source, target, resolved_shot_type, value, score_before, score_after)
	_feed("%s  %s%d" % [source, "+" if value >= 0 else "", value], Color(0.93, 0.78, 0.42) if value >= 0 else Color(0.95, 0.28, 0.28))


func _damage_player(player_index: int, amount: int, source: String, score_penalty: bool = true) -> void:
	if not _is_live_player(player_index):
		return
	if amount > 0 and state == "node" and RouteOutcomePolicyScript.accepts_visible_enemy_impact(current_node, source):
		if not bool(route_condition_context.get("visible_enemy_impact_received", false)):
			route_condition_context["visible_enemy_impact_received"] = true
			route_condition_context["visible_enemy_impact_source"] = source
			_set_subtitle("The enemy impact gives way beneath the agents!", 2.2)
	players[player_index].lives = maxi(0, int(players[player_index].lives) - amount)
	_play_sfx("hit")
	if score_penalty:
		_add_score(player_index, -100, "PLAYER HIT", "player_%d" % (player_index + 1), source)
	if not bool(configuration.get("reduced_shake", false)):
		var tween := create_tween()
		tween.tween_property(camera_3d, "rotation:z", 0.022, 0.05)
		tween.tween_property(camera_3d, "rotation:z", -0.018, 0.05)
		tween.tween_property(camera_3d, "rotation:z", 0.0, 0.08)
	if int(players[player_index].lives) <= 0:
		_start_continue(player_index)

func _is_live_player(player_index: int) -> bool:
	return (
		player_index >= 0
		and player_index < players.size()
		and bool(players[player_index].get("active", false))
		and int(players[player_index].get("lives", 0)) > 0
	)



func _first_active_player() -> int:
	for index in players.size():
		if bool(players[index].active) and int(players[index].lives) > 0:
			return index
	return 0


static func select_threat_target_player(player_states: Array[Dictionary], threat_screen_position: Vector2, previous_target: int = -1) -> int:
	if previous_target >= 0 and previous_target < player_states.size():
		var previous := player_states[previous_target]
		if bool(previous.get("active", false)) and int(previous.get("lives", 0)) > 0:
			return previous_target
	var selected := -1
	var nearest_distance_squared := INF
	for index in player_states.size():
		var player := player_states[index]
		if not bool(player.get("active", false)) or int(player.get("lives", 0)) <= 0:
			continue
		var cursor := player.get("cursor", threat_screen_position) as Vector2
		var distance_squared := cursor.distance_squared_to(threat_screen_position)
		if distance_squared < nearest_distance_squared:
			nearest_distance_squared = distance_squared
			selected = index
	return selected


static func boss_telegraph_step(timer: float, started: bool, visible: bool, delta: float) -> Dictionary:
	var next_timer := timer - maxf(0.0, delta)
	var next_started := started
	var started_this_tick := false
	if next_timer <= BOSS_ATTACK_TELEGRAPH_SECONDS:
		if not visible:
			next_started = false
			next_timer = maxf(next_timer, BOSS_ATTACK_TELEGRAPH_SECONDS)
		elif not next_started:
			next_started = true
			started_this_tick = true
			# Cooldown overshoot must never consume the visible warning.
			next_timer = BOSS_ATTACK_TELEGRAPH_SECONDS
	return {
		"timer": next_timer,
		"started": next_started,
		"started_this_tick": started_this_tick,
		"ready": next_started and not started_this_tick and visible and next_timer <= 0.0,
	}


func _target_player_for_threat(threat: Node3D, refresh: bool = false) -> int:
	if not is_instance_valid(threat):
		return select_threat_target_player(players, active_play_rect.get_center(), -1)
	var previous_target := -1 if refresh else int(threat.get_meta("target_player_index", -1))
	var threat_screen_position := active_play_rect.get_center()
	if camera_3d != null and is_instance_valid(camera_3d):
		var focus := threat.global_position + Vector3(0.0, 0.85 * maxf(0.25, float(threat.get_meta("visual_scale", 1.0))), 0.0)
		if not camera_3d.is_position_behind(focus):
			threat_screen_position = camera_3d.unproject_position(focus)
	var selected := select_threat_target_player(players, threat_screen_position, previous_target)
	threat.set_meta("target_player_index", selected)
	return selected


func _has_active_hostiles() -> bool:
	for actor in active_actors:
		if is_instance_valid(actor) and not bool(actor.get_meta("dead", false)) and str(actor.get_meta("role", "")) in ["enemy", "boss", "projectile"]:
			return true
	return false


func _clear_actors() -> void:
	EnvironmentSceneLifecycleScript.clear_immediately(actor_root)
	active_actors.clear()
	retiring_actors.clear()
	current_boss = null
	active_civilian = null


func _spawn_impact(at: Vector3, zone: String) -> void:
	var mesh_instance := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.055
	sphere.height = 0.11
	mesh_instance.mesh = sphere
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color("#f1c267") if int(configuration.get("blood_level", 2)) == 0 else Color("#9e171c")
	mesh_instance.material_override = material
	mesh_instance.position = at
	fx_root.add_child(mesh_instance)
	var tween := create_tween()
	tween.tween_property(mesh_instance, "scale", Vector3.ONE * 2.7, 0.1)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.32)
	tween.tween_callback(mesh_instance.queue_free)


func _spawn_limb(at: Vector3) -> void:
	if int(configuration.get("blood_level", 2)) <= 0 or not bool(configuration.get("dismemberment", true)):
		return
	var limb := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.12
	capsule.height = 0.62
	limb.mesh = capsule
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("#53605e")
	limb.material_override = material
	limb.position = at
	fx_root.add_child(limb)
	var tween := create_tween()
	tween.tween_property(limb, "position", at + Vector3(0.7, -0.75, 0.45), 0.55).set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(limb, "rotation", Vector3(2.0, 0.4, 2.8), 0.55)
	tween.tween_interval(0.5)
	tween.tween_callback(limb.queue_free)


func _update_camera_rail(_delta: float) -> void:
	if state != "node":
		return
	var sample := CameraRailPathSamplerScript.sample(
		current_node,
		rail_origin,
		rail_target,
		node_elapsed,
		rail_duration,
		SequenceTimingPolicyScript.campaign_policy(campaign)
	)
	var local_position := sample.get("position", rail_origin) as Vector3
	var local_look_target := sample.get("look_target", Vector3(0.0, 1.25, -9.0)) as Vector3
	camera_3d.position = environment_origin + local_position
	var look_target := environment_origin + local_look_target
	if camera_3d.position.distance_squared_to(look_target) > 0.0001:
		camera_3d.look_at(look_target, Vector3.UP)


func _start_boss(boss_id: String) -> void:
	_clear_actors()
	state = "boss"
	boss_phase = 0
	boss_attack_timer = 2.8
	boss_weak_window = 2.0
	if str(configuration.get("mode", "")) == "boss_rush":
		_set_music_for_boss(boss_id)
	var stats := _boss_stats(boss_id)
	boss_max_health = float(stats.health)
	var spawned_boss := _create_actor(boss_id, Vector3(0.0, 0.0 if boss_id != "hangedman" else 1.4, -10.5), {"health": boss_max_health, "speed": 0.0, "scale": float(stats.scale), "score": int(stats.score)}, "boss")
	if spawned_boss == null or not is_instance_valid(spawned_boss):
		current_boss = null
		state = "node"
		boss_panel.visible = false
		push_error("Unable to create boss actor: %s" % boss_id)
		return
	current_boss = spawned_boss
	current_boss.set_meta("boss_id", boss_id)
	current_boss.set_meta("telegraph_played", false)
	current_boss.set_meta("attack_telegraph_started", false)
	current_boss.set_meta("attack_telegraph_complete", false)
	current_boss.set_meta("melee_range", BOSS_MELEE_RANGE)
	current_boss.set_meta("melee_recovery_remaining", 0.0)
	current_boss.set_meta("attack_home_position", current_boss.position)
	current_boss.set_meta("melee_contact_position", current_boss.position)
	boss_panel.visible = true
	boss_name_label.text = _safe_ui_text("%s — TYPE %s" % [str(stats.name), str(stats.type)])
	boss_health_bar.max_value = boss_max_health
	boss_health_bar.value = boss_max_health
	boss_weak_label.text = _safe_ui_text(str(stats.weak_hint))
	var weakpoint_profile := gameplay_support_library.get_weakpoint(boss_id)
	boss_weakpoint_texture.texture = gameplay_support_library.load_texture(weakpoint_profile)
	objective_label.text = _safe_ui_text("DESTROY THE BOSS")
	_set_subtitle(str(stats.intro), 4.2)
	if boss_id == "hangedman":
		for index in 5:
			_spawn_enemy({"actor": "mutant_bat", "position": [-2.4 + index * 1.2, 2.0 + (index % 2) * 0.5, -9.0 - index * 0.25], "attack_delay": 4.0 + index * 0.4, "pattern": "fly"})


func _boss_stats(boss_id: String) -> Dictionary:
	match boss_id:
		"chariot":
			return {"health": 34.0, "scale": 1.55, "score": 1500, "name": "CHARIOT", "type": "27", "weak_hint": "WEAK POINT: OPENING IN THE ARMOR", "intro": "You shall never leave this place!"}
		"hangedman":
			return {"health": 38.0, "scale": 1.32, "score": 1500, "name": "HANGEDMAN", "type": "041", "weak_hint": "DESTROY THE BATS • FIRE DURING CHARGES", "intro": "Nobody leaves here alive."}
		"hermit":
			return {"health": 44.0, "scale": 1.75, "score": 1500, "name": "HERMIT", "type": "6803", "weak_hint": "WEAK POINT: HEAD • DESTROY THE WEB", "intro": "Something enormous is moving in the tunnel!"}
		_:
			return {"health": 68.0, "scale": 1.5, "score": 2500, "name": "MAGICIAN", "type": "0", "weak_hint": "WEAK POINT: EXPOSED RED TISSUE", "intro": "You shall all die."}


func _update_boss(delta: float) -> void:
	if current_boss == null or not is_instance_valid(current_boss):
		return
	boss_weak_window = maxf(0.0, boss_weak_window - delta)
	var boss_id := str(current_boss.get_meta("boss_id", "chariot"))
	var is_melee_boss := boss_id in ["chariot", "hangedman"]
	# node_elapsed advances only while boss gameplay is active, so pausing cannot
	# phase-jump the boss along a wall-clock-driven orbit on the first resumed frame.
	var t := node_elapsed
	var home_position := _boss_home_position(boss_id, t)
	current_boss.set_meta("attack_home_position", home_position)
	var recovery_remaining := maxf(0.0, float(current_boss.get_meta("melee_recovery_remaining", 0.0)) - delta)
	current_boss.set_meta("melee_recovery_remaining", recovery_remaining)
	var telegraph_state: Dictionary = {"ready": false}
	if recovery_remaining > 0.0 and is_melee_boss:
		var recovery_progress := 1.0 - recovery_remaining / BOSS_MELEE_RECOVERY_SECONDS
		var contact_position: Vector3 = current_boss.get_meta("melee_contact_position", home_position) as Vector3
		current_boss.position = contact_position.lerp(home_position, smoothstep(0.0, 1.0, recovery_progress))
	else:
		current_boss.position = home_position
		var boss_visible := _actor_is_attack_visible(current_boss)
		telegraph_state = boss_telegraph_step(
			boss_attack_timer,
			bool(current_boss.get_meta("attack_telegraph_started", false)),
			boss_visible,
			delta
		)
		boss_attack_timer = float(telegraph_state.timer)
		current_boss.set_meta("attack_telegraph_started", bool(telegraph_state.started))
		if boss_attack_timer <= BOSS_ATTACK_TELEGRAPH_SECONDS:
			if not boss_visible:
				current_boss.set_meta("attack_telegraph_started", false)
				current_boss.set_meta("attack_telegraph_complete", false)
				current_boss.set_meta("telegraph_played", false)
			else:
				if bool(telegraph_state.started_this_tick):
					current_boss.set_meta("telegraph_played", true)
					_target_player_for_threat(current_boss, true)
					_play_sfx("boss_telegraph")
				var telegraph_remaining := maxf(0.0, boss_attack_timer)
				current_boss.set_meta("attack_animation_timer", maxf(float(current_boss.get_meta("attack_animation_timer", 0.0)), telegraph_remaining))
				if is_melee_boss:
					var lunge_progress := clampf(1.0 - telegraph_remaining / BOSS_ATTACK_TELEGRAPH_SECONDS, 0.0, 1.0)
					var contact_position := _boss_melee_contact_position(home_position)
					current_boss.set_meta("melee_contact_position", contact_position)
					current_boss.position = home_position.lerp(contact_position, smoothstep(0.0, 1.0, lunge_progress))
	if bool(telegraph_state.get("ready", false)):
		var telegraph_ready := bool(current_boss.get_meta("attack_telegraph_started", false)) and _actor_is_attack_visible(current_boss)
		current_boss.set_meta("attack_telegraph_complete", telegraph_ready)
		var performed := _boss_attack(boss_id) if telegraph_ready else false
		if performed and is_melee_boss:
			current_boss.set_meta("melee_recovery_remaining", BOSS_MELEE_RECOVERY_SECONDS)
		current_boss.set_meta("attack_telegraph_started", false)
		current_boss.set_meta("attack_telegraph_complete", false)
		current_boss.set_meta("telegraph_played", false)
		boss_attack_timer = maxf(BOSS_ATTACK_TELEGRAPH_SECONDS + 0.35, 2.8 - float(boss_phase) * 0.55)
		boss_weak_window = 1.2
	boss_health_bar.value = float(current_boss.get_meta("health", 0.0))


func _boss_home_position(boss_id: String, elapsed: float) -> Vector3:
	match boss_id:
		"chariot":
			return Vector3(sin(elapsed * 0.8) * (0.55 + boss_phase * 0.35), 0.0, -10.5)
		"hangedman":
			return Vector3(sin(elapsed * 1.7) * 2.5, 1.5 + cos(elapsed * 1.2) * 0.8, -9.0 + sin(elapsed))
		"hermit":
			return Vector3(0.0, 0.0, -9.5 + sin(elapsed * 1.2) * 1.2)
		"magician":
			return Vector3(sin(elapsed * (2.5 + boss_phase)) * 3.0, 0.3 + absf(cos(elapsed * 1.8)) * 1.4, -10.5)
	return current_boss.position


func _boss_melee_contact_position(home_position: Vector3) -> Vector3:
	if camera_3d == null or not is_instance_valid(camera_3d):
		return home_position
	var camera_forward := -camera_3d.global_transform.basis.z.normalized()
	var global_contact := camera_3d.global_position + camera_forward * (BOSS_MELEE_RANGE * 0.58)
	var contact_position := global_contact - environment_origin
	if actor_root != null and is_instance_valid(actor_root):
		contact_position = actor_root.to_local(global_contact)
	# Boss home positions are authored in ActorRoot-local coordinates.
	contact_position.y = home_position.y
	return contact_position


func _boss_attack(boss_id: String) -> bool:
	if current_boss == null or not is_instance_valid(current_boss):
		return false
	if not bool(current_boss.get_meta("attack_telegraph_complete", false)) or not _actor_is_attack_visible(current_boss):
		return false
	if boss_id in ["hermit", "magician"]:
		current_boss.set_meta("projectile_asset", "hermit_web_ball" if boss_id == "hermit" else "magician_fireball")
		current_boss.set_meta("projectile_destructible", true)
		current_boss.set_meta("projectile_speed", 4.25 if boss_id == "hermit" else 5.0)
		current_boss.set_meta("projectile_min_travel", 4.0 if boss_id == "hermit" else 3.5)
		current_boss.set_meta("projectile_contact_range", DEFAULT_PROJECTILE_CONTACT_RANGE)
		var projectile := _spawn_enemy_projectile(current_boss)
		if projectile == null:
			return false
		projectile.set_meta("lane", current_boss.position.x)
		projectile.set_meta("target_civilian", false)
		_play_sfx("boss_web_projectile" if boss_id == "hermit" else "boss_projectile")
		return true
	if not _actor_has_melee_contact(current_boss):
		return false
	var target_player_index := _target_player_for_threat(current_boss)
	if target_player_index < 0:
		return false
	_damage_player(target_player_index, 1, "boss_melee")
	return true


func _boss_zone_is_vulnerable(zone: String) -> bool:
	if current_boss == null:
		return true
	var boss_id := str(current_boss.get_meta("boss_id", ""))
	match boss_id:
		"chariot":
			return zone == "head" or boss_phase >= 2
		"hangedman":
			var bats_alive := false
			for actor in active_actors:
				if is_instance_valid(actor) and str(actor.get_meta("actor_id", "")) == "mutant_bat" and not bool(actor.get_meta("dead", false)):
					bats_alive = true
			return not bats_alive and (boss_weak_window > 0.0 or boss_phase >= 2)
		"hermit":
			return zone == "head" and (boss_weak_window > 0.0 or boss_phase >= 2)
		"magician":
			return zone in ["head", "torso", "legs"] and boss_weak_window > 0.0
	return true


func _update_boss_phase() -> void:
	if current_boss == null:
		return
	var health_ratio := float(current_boss.get_meta("health", 0.0)) / boss_max_health
	var next_phase := 0 if health_ratio > 0.67 else (1 if health_ratio > 0.34 else 2)
	if next_phase != boss_phase:
		boss_phase = next_phase
		boss_weak_window = 2.0
		_feed("BOSS PHASE %d" % (boss_phase + 1), Color("#e0b964"))
		var sprite := current_boss.get_node_or_null("Sprite3D") as Sprite3D
		if sprite != null:
			sprite.modulate = Color(1.0, 0.78 + boss_phase * 0.08, 0.78 + boss_phase * 0.06)


func _on_boss_defeated() -> void:
	if current_boss == null:
		return
	var boss_id := str(current_boss.get_meta("boss_id", "magician"))
	var value := 2500 if boss_id == "magician" else 1500
	_add_score(_first_active_player(), value, "%s DEFEATED" % boss_id.to_upper(), boss_id, "boss_defeat")
	_retire_active_projectiles()
	boss_panel.visible = false
	current_boss = null
	if str(configuration.get("mode", "")) == "boss_rush":
		state = "boss_rush_intro"
		state_timer = 2.0
		_show_overlay("TARGET DESTROYED", "%d experiments remaining" % boss_queue.size(), state_timer)
	else:
		branch_success = true
		var post_defeat_hold := maxf(0.0, float(current_node.get("post_defeat_hold_seconds", 0.5)))
		if post_defeat_hold > 0.0:
			state = "boss_defeat_hold"
			state_timer = post_defeat_hold
			objective_label.text = _safe_ui_text("TARGET DESTROYED")
		else:
			state = "node"
			call_deferred("_finish_node")


func _retire_active_projectiles() -> void:
	for actor: Node3D in active_actors.duplicate():
		if not is_instance_valid(actor):
			continue
		if str(actor.get_meta("role", "")) == "projectile":
			_retire_projectile_immediately(actor)


func _retire_projectile_immediately(projectile: Node3D) -> void:
	if not is_instance_valid(projectile):
		return
	projectile.set_meta("dead", true)
	projectile.visible = false
	for child in projectile.get_children():
		var hit_zone := child as Area3D
		if hit_zone == null:
			continue
		hit_zone.set_deferred("monitoring", false)
		hit_zone.set_deferred("monitorable", false)
		hit_zone.set_deferred("collision_layer", 0)
		hit_zone.set_deferred("collision_mask", 0)
	active_actors.erase(projectile)
	retiring_actors.erase(projectile)
	projectile.queue_free()


func _clear_sequence_connector() -> void:
	if connector_root == null or not is_instance_valid(connector_root):
		return
	EnvironmentSceneLifecycleScript.clear_immediately(connector_root)
	for meta_key: StringName in connector_root.get_meta_list():
		connector_root.remove_meta(meta_key)


func _build_sequence_connector(from_pose: Dictionary, to_pose: Dictionary, next_profile: Dictionary) -> void:
	_clear_sequence_connector()
	if connector_root == null or not is_instance_valid(connector_root):
		return
	var from_camera := from_pose.get("position", Vector3.ZERO) as Vector3
	var to_camera := to_pose.get("position", from_camera) as Vector3
	var travel := to_camera - from_camera
	if travel.length_squared() <= 0.01:
		return
	var travel_direction := travel.normalized()
	var extended_start := from_camera - travel_direction * CONNECTOR_END_MARGIN
	var extended_end := to_camera + travel_direction * CONNECTOR_END_MARGIN
	var threshold := from_camera.lerp(to_camera, 0.5)
	_add_sequence_connector_segment(extended_start, threshold, environment_scene_profile, "from")
	_add_sequence_connector_segment(threshold, extended_end, next_profile, "to")
	var old_layout := str(environment_scene_profile.get("layout", ""))
	var next_layout := str(next_profile.get("layout", ""))
	if old_layout != next_layout or bool(environment_scene_profile.get("open_ceiling", false)) != bool(next_profile.get("open_ceiling", false)):
		_add_sequence_connector_threshold(threshold, travel_direction, next_profile)
	_add_sequence_connector_backdrop(to_camera, travel_direction, next_profile)
	connector_root.set_meta("sequence_connector_active", true)
	connector_root.set_meta("sequence_connector_segment_count", 2)
	connector_root.set_meta("sequence_connector_from_layout", old_layout)
	connector_root.set_meta("sequence_connector_to_layout", next_layout)
	connector_root.set_meta("sequence_connector_from", from_camera)
	connector_root.set_meta("sequence_connector_to", to_camera)


func _add_sequence_connector_segment(start_camera: Vector3, end_camera: Vector3, profile: Dictionary, phase: String) -> void:
	var start_ground := start_camera - Vector3.UP * CONNECTOR_CAMERA_HEIGHT
	var end_ground := end_camera - Vector3.UP * CONNECTOR_CAMERA_HEIGHT
	var segment := end_ground - start_ground
	if segment.length_squared() <= 0.001:
		return
	var basis := _sequence_connector_basis(segment.normalized())
	var right := basis.x.normalized()
	var up := basis.y.normalized()
	var midpoint := start_ground.lerp(end_ground, 0.5)
	var length := segment.length()
	var floor_material := _sequence_connector_material(profile, "floor", Color("#24272a"))
	var wall_material := _sequence_connector_material(profile, "wall", Color("#33363a"))
	_add_sequence_connector_box(
		"ConnectorFloor_%s" % phase,
		midpoint - up * (CONNECTOR_FLOOR_THICKNESS * 0.5 + 0.015),
		basis,
		Vector3(CONNECTOR_HALF_WIDTH * 2.0, CONNECTOR_FLOOR_THICKNESS, length),
		floor_material,
		"floor",
		phase
	)
	var open_ceiling := bool(profile.get("open_ceiling", false))
	var wall_height := CONNECTOR_OPEN_RAIL_HEIGHT if open_ceiling else CONNECTOR_INDOOR_HEIGHT
	for side in [-1.0, 1.0]:
		_add_sequence_connector_box(
			"ConnectorWall_%s_%s" % [phase, "L" if side < 0.0 else "R"],
			midpoint + right * side * (CONNECTOR_HALF_WIDTH + CONNECTOR_WALL_THICKNESS * 0.5) + up * (wall_height * 0.5),
			basis,
			Vector3(CONNECTOR_WALL_THICKNESS, wall_height, length),
			wall_material,
			"wall",
			phase
		)
	if not open_ceiling:
		var ceiling_material := _sequence_connector_material(profile, "ceiling", Color("#292c30"))
		_add_sequence_connector_box(
			"ConnectorCeiling_%s" % phase,
			midpoint + up * CONNECTOR_INDOOR_HEIGHT,
			basis,
			Vector3(CONNECTOR_HALF_WIDTH * 2.0, CONNECTOR_WALL_THICKNESS, length),
			ceiling_material,
			"ceiling",
			phase
		)


func _add_sequence_connector_threshold(at_camera: Vector3, travel_direction: Vector3, profile: Dictionary) -> void:
	var ground := at_camera - Vector3.UP * CONNECTOR_CAMERA_HEIGHT
	var basis := _sequence_connector_basis(travel_direction)
	var right := basis.x.normalized()
	var up := basis.y.normalized()
	var material := _sequence_connector_material(profile, "wall", Color("#34383d"))
	var height := CONNECTOR_INDOOR_HEIGHT
	for side in [-1.0, 1.0]:
		_add_sequence_connector_box(
			"ConnectorThresholdPost_%s" % ("L" if side < 0.0 else "R"),
			ground + right * side * (CONNECTOR_HALF_WIDTH - 0.18) + up * (height * 0.5),
			basis,
			Vector3(0.36, height, 0.36),
			material,
			"threshold",
			"to"
		)
	_add_sequence_connector_box(
		"ConnectorThresholdHeader",
		ground + up * (height - 0.18),
		basis,
		Vector3(CONNECTOR_HALF_WIDTH * 2.0, 0.36, 0.36),
		material,
		"threshold",
		"to"
	)


func _add_sequence_connector_backdrop(to_camera: Vector3, travel_direction: Vector3, profile: Dictionary) -> void:
	var path := str(profile.get("backdrop", ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var texture := ResourceLoader.load(path, "Texture2D") as Texture2D
	if texture == null:
		return
	var quad := MeshInstance3D.new()
	quad.name = "ConnectorNextBackdrop"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(18.0, 10.0)
	quad.mesh = mesh
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_texture = texture
	material.albedo_color = Color(0.62, 0.66, 0.70)
	quad.material_override = material
	connector_root.add_child(quad)
	var basis := _sequence_connector_basis(travel_direction)
	quad.global_transform = Transform3D(basis, to_camera + travel_direction.normalized() * CONNECTOR_BACKDROP_DISTANCE + basis.y.normalized() * 2.5)
	quad.set_meta("sequence_connector_role", "backdrop")
	quad.set_meta("sequence_connector_phase", "to")


func _add_sequence_connector_box(node_name: String, center: Vector3, basis: Basis, dimensions: Vector3, material: Material, role: String, phase: String) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.material_override = material
	connector_root.add_child(instance)
	instance.global_transform = Transform3D(basis, center)
	instance.set_meta("sequence_connector_role", role)
	instance.set_meta("sequence_connector_phase", phase)
	instance.set_meta("sequence_connector_dimensions", dimensions)
	var body := StaticBody3D.new()
	body.name = "%sBody" % node_name
	connector_root.add_child(body)
	body.global_transform = Transform3D(basis, center)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collision.shape = shape
	body.add_child(collision)
	body.set_meta("sequence_connector_role", role)
	body.set_meta("sequence_connector_phase", phase)


func _sequence_connector_material(profile: Dictionary, key: String, fallback_color: Color) -> Material:
	var material_id := str(profile.get(key, profile.get("wall", "")))
	if not material_id.is_empty():
		var authored := environment_asset_library.create_material(material_id)
		if authored != null:
			return authored
	var fallback := StandardMaterial3D.new()
	fallback.albedo_color = fallback_color
	fallback.roughness = 0.86
	return fallback


func _sequence_connector_basis(travel_direction: Vector3) -> Basis:
	var forward := travel_direction.normalized() if not travel_direction.is_zero_approx() else Vector3.FORWARD
	var back := -forward
	var right := Vector3.UP.cross(back)
	if right.is_zero_approx():
		right = Vector3.RIGHT
	right = right.normalized()
	var up := back.cross(right).normalized()
	return Basis(right, up, back).orthonormalized()


func _build_environment(style: String) -> void:
	EnvironmentSceneLifecycleScript.clear_immediately(world_root)
	environment_scene_profile = environment_asset_library.get_scene_profile(current_node_id, style)
	style = str(environment_scene_profile.get("style", style))
	_set_ambience_for_style(style)
	var environment_node := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#080b0f")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(str(environment_scene_profile.get("ambient", "#62706c")))
	environment.ambient_light_energy = 0.43
	environment.fog_enabled = true
	environment.fog_light_color = Color(str(environment_scene_profile.get("fog", "#394a48")))
	environment.fog_density = 0.016
	environment.fog_aerial_perspective = 0.38
	environment_node.environment = environment
	world_root.add_child(environment_node)

	var floor_color := Color("#30352f")
	var wall_color := Color("#27282b")
	if style == "garden":
		floor_color = Color("#263129")
		wall_color = Color("#171d1a")
	elif style == "sewer":
		floor_color = Color("#29312f")
		wall_color = Color("#202a29")
	elif style == "laboratory":
		floor_color = Color("#273433")
		wall_color = Color("#32403f")
	elif style == "roof":
		floor_color = Color("#36383e")
		wall_color = Color("#242831")
	_add_box("Floor", Vector3(0.0, -0.25, -8.0), Vector3(13.0, 0.5, 31.0), floor_color)
	_add_box("LeftWall", Vector3(-6.3, 2.8, -8.0), Vector3(0.45, 6.0, 31.0), wall_color)
	_add_box("RightWall", Vector3(6.3, 2.8, -8.0), Vector3(0.45, 6.0, 31.0), wall_color)
	if style not in ["garden", "roof"]:
		_add_box("Ceiling", Vector3(0.0, 5.8, -8.0), Vector3(13.0, 0.35, 31.0), wall_color.darkened(0.18))
	for index in 7:
		var z := -1.5 - index * 4.1
		_add_box("ColumnL%d" % index, Vector3(-4.9, 1.5, z), Vector3(0.6, 3.0, 0.6), wall_color.lightened(0.09))
		_add_box("ColumnR%d" % index, Vector3(4.9, 1.5, z), Vector3(0.6, 3.0, 0.6), wall_color.lightened(0.09))
		if index % 2 == 0:
			var light := OmniLight3D.new()
			light.position = Vector3(-3.9 if index % 4 == 0 else 3.9, 2.8, z)
			light.light_color = Color(str(environment_scene_profile.get("light", "#d28a5a")))
			light.light_energy = 2.1
			light.omni_range = 6.0
			light.shadow_enabled = false
			world_root.add_child(light)
	_apply_environment_materials()
	_build_environment_layout()
	_spawn_environment_props()
	_spawn_environment_effects()
	_add_backdrop(style)


func _add_box(node_name: String, at: Vector3, dimensions: Vector3, color: Color) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.position = at
	_configure_environment_mesh_blocker(instance, node_name, dimensions)
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.82
	material.metallic = 0.18 if "laboratory" in node_name.to_lower() else 0.0
	instance.material_override = material
	world_root.add_child(instance)



func _configure_environment_mesh_blocker(instance: MeshInstance3D, node_name: String, dimensions: Vector3) -> void:
	var lower_name := node_name.to_lower()
	var walkable_terms := PackedStringArray([
		"floor", "path", "forecourt", "step", "landing", "runner", "walk",
		"deck", "gallery", "vestibule", "slope", "ledge", "platform", "carpet",
		"dais", "grating", "gantry",
	])
	var rejected_walkable_terms := PackedStringArray([
		"wall", "rail", "balustrade", "parapet", "beam", "header", "lintel",
		"shelf", "support", "brace", "crown", "lip",
	])
	var is_walkable := dimensions.x >= 0.5 and dimensions.z >= 0.5 and dimensions.y <= 1.2
	if is_walkable:
		is_walkable = false
		for term: String in walkable_terms:
			if term in lower_name:
				is_walkable = true
				break
	if is_walkable:
		for term: String in rejected_walkable_terms:
			if term in lower_name:
				is_walkable = false
				break
	if is_walkable:
		instance.set_meta("enemy_walkable_dimensions", dimensions.abs())
		instance.set_meta("enemy_walkable_source", "layout_mesh")
	var solid_terms := PackedStringArray([
		"wall", "column", "rail", "balustrade", "parapet", "buttress", "pier",
		"post", "frame", "door", "gate", "shelf", "alcove", "wing", "beam",
		"rubble", "support", "duct", "brace", "crown", "pipe", "veil", "ridge",
		"arch", "header", "lintel", "pylon", "console", "tank", "lip",
	])
	var blocks_floor_motion := false
	for term: String in solid_terms:
		if term in lower_name:
			blocks_floor_motion = true
			break
	if not blocks_floor_motion:
		return
	instance.set_meta("enemy_blocker_half_extents", Vector2(maxf(0.04, dimensions.x * 0.5), maxf(0.04, dimensions.z * 0.5)))
	instance.set_meta("enemy_blocker_height", maxf(0.1, dimensions.y))
	instance.set_meta("enemy_blocker_source", "layout_mesh")


func _apply_environment_materials() -> void:
	for child in world_root.get_children():
		var instance := child as MeshInstance3D
		if instance == null:
			continue
		var lower_name := instance.name.to_lower()
		var material_id := ""
		if lower_name == "floor":
			material_id = str(environment_scene_profile.get("floor", ""))
		elif "wall" in lower_name:
			material_id = str(environment_scene_profile.get("wall", ""))
		elif "column" in lower_name:
			material_id = str(environment_scene_profile.get("column", ""))
		elif lower_name == "ceiling":
			material_id = str(environment_scene_profile.get("ceiling", environment_scene_profile.get("wall", "")))
		if not material_id.is_empty():
			instance.material_override = environment_asset_library.create_material(material_id)


func _build_environment_layout() -> void:
	var layout := str(environment_scene_profile.get("layout", "mansion_hall"))
	var family: StringName = EnvironmentLayoutClassifierScript.classify(layout)
	world_root.set_meta("environment_layout", layout)
	world_root.set_meta("environment_layout_family", family)
	if family == EnvironmentLayoutClassifierScript.FAMILY_ESTATE:
		_build_estate_layout(layout)
	elif family == EnvironmentLayoutClassifierScript.FAMILY_MANSION:
		_build_mansion_layout(layout)
	elif family == EnvironmentLayoutClassifierScript.FAMILY_SEWER:
		_build_sewer_layout(layout)
	elif family == EnvironmentLayoutClassifierScript.FAMILY_LIBRARY:
		_build_library_layout()
	elif family == EnvironmentLayoutClassifierScript.FAMILY_ROOF:
		_build_roof_layout(layout)
	elif family == EnvironmentLayoutClassifierScript.FAMILY_CHARIOT_ARENA:
		_build_chariot_arena_layout()
	elif family == EnvironmentLayoutClassifierScript.FAMILY_HERMIT_TUNNEL:
		_build_hermit_tunnel_layout()
	elif family == EnvironmentLayoutClassifierScript.FAMILY_LABORATORY:
		_build_laboratory_layout(layout)
	else:
		# A safe textured fallback for editor-only layouts; public campaign ids are
		# required to be explicit by test_environment_layout_classifier.gd.
		_build_mansion_layout("mansion_hall")
	var uses_door_portal := layout in ["foyer_crossroad", "great_doors", "portrait_antechamber", "bonus_gate"] or "door" in layout or "gate" in layout or "entrance" in layout
	if uses_door_portal:
		_add_material_box("EndPortalL", Vector3(-2.3, 2.0, -21.5), Vector3(1.3, 4.0, 0.65), _environment_material_id("column"))
		_add_material_box("EndPortalR", Vector3(2.3, 2.0, -21.5), Vector3(1.3, 4.0, 0.65), _environment_material_id("column"))
		_add_material_box("EndPortalLintel", Vector3(0.0, 4.25, -21.5), Vector3(5.9, 0.5, 0.7), _environment_material_id("column"))
		_add_material_box("EndPortalDoor", Vector3(0.0, 2.0, -21.66), Vector3(3.3, 4.0, 0.26), _environment_material_id("door", "wall"))


func _layout_is_laboratory(layout: String) -> bool:
	return EnvironmentLayoutClassifierScript.is_laboratory(layout)


func _environment_material_id(key: String, fallback_key: String = "floor") -> String:
	var material_id := str(environment_scene_profile.get(key, ""))
	if material_id.is_empty():
		material_id = str(environment_scene_profile.get(fallback_key, ""))
	if material_id.is_empty():
		material_id = str(environment_scene_profile.get("floor", "garden_flagstone"))
	return material_id


func _build_estate_layout(layout: String) -> void:
	var path_material := _environment_material_id("accent")
	var stone_material := _environment_material_id("wall")
	_add_material_box("EstatePath", Vector3(0.0, 0.03, -10.0), Vector3(2.8, 0.08, 24.0), path_material)
	if layout == "estate_arrival":
		_add_material_box("EstateRetainingL", Vector3(-4.85, 0.55, -10.5), Vector3(0.7, 1.1, 22.0), stone_material)
		_add_material_box("EstateRetainingR", Vector3(4.85, 0.55, -10.5), Vector3(0.7, 1.1, 22.0), stone_material)
		for pier_index in 3:
			var z := -4.5 - pier_index * 7.0
			_add_material_box("EstatePierL_%02d" % pier_index, Vector3(-4.85, 1.35, z), Vector3(1.05, 2.7, 1.05), stone_material)
			_add_material_box("EstatePierR_%02d" % pier_index, Vector3(4.85, 1.35, z), Vector3(1.05, 2.7, 1.05), stone_material)
	else:
		_add_material_box("FrontForecourt", Vector3(0.0, 0.08, -6.0), Vector3(9.4, 0.16, 7.0), path_material)
		for step_index in 9:
			_add_material_box("FrontStep_%02d" % step_index, Vector3(0.0, 0.11 + step_index * 0.13, -10.2 - step_index * 0.58), Vector3(8.6, 0.22, 0.72), stone_material)
		_add_material_box("FrontLanding", Vector3(0.0, 1.25, -17.35), Vector3(10.4, 0.34, 5.2), stone_material)
		_add_material_box("FrontBalustradeL", Vector3(-4.65, 1.35, -14.1), Vector3(0.46, 2.2, 8.0), stone_material)
		_add_material_box("FrontBalustradeR", Vector3(4.65, 1.35, -14.1), Vector3(0.46, 2.2, 8.0), stone_material)


func _build_mansion_layout(layout: String) -> void:
	var floor_material := _environment_material_id("floor")
	var wall_material := _environment_material_id("wall")
	var trim_material := _environment_material_id("column")
	var accent_material := _environment_material_id("accent")
	_add_material_box("MansionRunner", Vector3(0.0, 0.025, -10.0), Vector3(2.25, 0.06, 24.0), accent_material)
	if layout == "foyer_crossroad":
		_add_material_box("FoyerLanding", Vector3(0.0, 0.09, -12.0), Vector3(10.8, 0.18, 8.5), floor_material)
		_add_material_box("FoyerBalcony", Vector3(0.0, 4.0, -15.4), Vector3(10.4, 0.34, 2.4), trim_material)
		_add_material_box("FoyerWingL", Vector3(-5.0, 2.1, -10.8), Vector3(1.0, 4.2, 5.6), wall_material)
		_add_material_box("FoyerWingR", Vector3(5.0, 2.1, -10.8), Vector3(1.0, 4.2, 5.6), wall_material)
	elif layout == "upper_staircase":
		for step_index in 9:
			var step_z := -8.8 - step_index * 0.62
			var step_y := 0.12 + step_index * 0.17
			_add_material_box("UpperStair_%02d" % step_index, Vector3(0.0, step_y, step_z), Vector3(5.8, 0.24, 0.76), floor_material)
		_add_material_box("UpperGallery", Vector3(0.0, 1.7, -16.6), Vector3(10.2, 0.34, 4.8), floor_material)
		_add_material_box("UpperRailL", Vector3(-3.25, 2.25, -13.6), Vector3(0.22, 1.3, 9.0), trim_material)
		_add_material_box("UpperRailR", Vector3(3.25, 2.25, -13.6), Vector3(0.22, 1.3, 9.0), trim_material)
	elif layout == "collapsed_hall":
		_add_material_box("CollapsedBeamL", Vector3(-3.8, 1.2, -11.5), Vector3(0.65, 0.75, 5.8), trim_material, Vector3(0.0, 18.0, -16.0))
		_add_material_box("CollapsedBeamR", Vector3(3.9, 0.8, -16.2), Vector3(0.8, 0.65, 4.2), trim_material, Vector3(0.0, -24.0, 13.0))
		for rubble_index in 4:
			_add_material_box("CollapsedRubble_%02d" % rubble_index, Vector3(-4.1 + rubble_index * 2.7, 0.24, -13.0 - float(rubble_index % 2) * 3.2), Vector3(1.2, 0.45, 1.0), wall_material, Vector3(0.0, rubble_index * 17.0, 0.0))
	elif layout == "portrait_antechamber":
		_add_material_box("PortraitBackWall", Vector3(0.0, 2.6, -18.2), Vector3(9.8, 5.2, 0.5), wall_material)
		_add_material_box("PortraitAlcoveL", Vector3(-3.7, 2.3, -16.7), Vector3(1.1, 4.6, 3.0), trim_material)
		_add_material_box("PortraitAlcoveR", Vector3(3.7, 2.3, -16.7), Vector3(1.1, 4.6, 3.0), trim_material)
	elif layout == "narrow_corridor":
		_add_material_box("NarrowInnerWallL", Vector3(-4.15, 2.45, -10.5), Vector3(0.48, 4.9, 23.0), wall_material)
		_add_material_box("NarrowInnerWallR", Vector3(4.15, 2.45, -10.5), Vector3(0.48, 4.9, 23.0), wall_material)
		for beam_index in 5:
			_add_material_box("NarrowCeilingBeam_%02d" % beam_index, Vector3(0.0, 4.85, -3.0 - beam_index * 4.4), Vector3(8.6, 0.34, 0.5), trim_material)
	elif layout == "raised_bridge":
		_add_material_box("RaisedBridgeDeck", Vector3(0.0, 0.38, -11.5), Vector3(5.1, 0.62, 22.0), floor_material)
		_add_material_box("RaisedBridgeRailL", Vector3(-2.55, 1.15, -11.5), Vector3(0.22, 1.55, 22.0), trim_material)
		_add_material_box("RaisedBridgeRailR", Vector3(2.55, 1.15, -11.5), Vector3(0.22, 1.55, 22.0), trim_material)
		for support_index in 4:
			_add_material_box("RaisedBridgeSupport_%02d" % support_index, Vector3(0.0, 0.9, -4.0 - support_index * 6.0), Vector3(10.4, 0.45, 0.55), trim_material)
	elif layout == "great_doors":
		_add_material_box("GreatDoorVestibule", Vector3(0.0, 0.09, -17.0), Vector3(9.8, 0.18, 7.0), floor_material)
		_add_material_box("GreatDoorArch", Vector3(0.0, 4.6, -20.5), Vector3(9.8, 0.7, 1.0), trim_material)


func _build_sewer_layout(layout: String) -> void:
	var floor_material := _environment_material_id("floor")
	var wall_material := _environment_material_id("wall")
	var iron_material := _environment_material_id("column")
	_add_material_box("SewerWetChannel", Vector3(0.0, -0.01, -11.0), Vector3(2.3, 0.08, 25.0), floor_material)
	if layout == "bridge_channel":
		_add_material_box("ChannelWalkL", Vector3(-3.75, 0.2, -11.0), Vector3(4.0, 0.4, 23.0), wall_material)
		_add_material_box("ChannelWalkR", Vector3(3.75, 0.2, -11.0), Vector3(4.0, 0.4, 23.0), wall_material)
		_add_material_box("ChannelRailL", Vector3(-1.65, 0.9, -11.0), Vector3(0.18, 1.45, 23.0), iron_material)
		_add_material_box("ChannelRailR", Vector3(1.65, 0.9, -11.0), Vector3(0.18, 1.45, 23.0), iron_material)
	elif layout == "hatch_gallery":
		_add_material_box("HatchGalleryDeck", Vector3(0.0, 0.24, -13.0), Vector3(8.4, 0.48, 14.0), wall_material)
		_add_material_box("HatchFrameL", Vector3(-2.4, 2.0, -19.5), Vector3(0.55, 4.0, 0.75), iron_material)
		_add_material_box("HatchFrameR", Vector3(2.4, 2.0, -19.5), Vector3(0.55, 4.0, 0.75), iron_material)
		_add_material_box("HatchFrameTop", Vector3(0.0, 4.0, -19.5), Vector3(5.3, 0.55, 0.75), iron_material)
	elif layout == "low_tunnel":
		# This node has no prop placements: repeated masonry ribs and the lowered
		# crown provide its complete silhouette and depth cadence.
		_add_material_box("LowTunnelCrown", Vector3(0.0, 4.25, -11.0), Vector3(11.0, 0.7, 25.0), wall_material)
		for rib_index in 7:
			var z := -2.5 - rib_index * 3.4
			_add_material_box("LowTunnelRibL_%02d" % rib_index, Vector3(-4.8, 2.0, z), Vector3(0.52, 4.0, 0.55), iron_material)
			_add_material_box("LowTunnelRibR_%02d" % rib_index, Vector3(4.8, 2.0, z), Vector3(0.52, 4.0, 0.55), iron_material)
			_add_material_box("LowTunnelRibTop_%02d" % rib_index, Vector3(0.0, 4.05, z), Vector3(10.1, 0.44, 0.55), iron_material)
	elif layout == "lower_stairs":
		# The stair flight is procedural because this transition intentionally has
		# no decorative prop sprites.
		for step_index in 10:
			_add_material_box("LowerStep_%02d" % step_index, Vector3(0.0, 1.5 - step_index * 0.14, -6.8 - step_index * 0.68), Vector3(6.4, 0.25, 0.82), wall_material)
		_add_material_box("LowerStairRailL", Vector3(-3.35, 1.65, -10.0), Vector3(0.24, 2.2, 11.0), iron_material)
		_add_material_box("LowerStairRailR", Vector3(3.35, 1.65, -10.0), Vector3(0.24, 2.2, 11.0), iron_material)
	elif layout == "service_lift":
		_add_material_box("ServiceLiftBack", Vector3(0.0, 2.5, -19.5), Vector3(7.2, 5.0, 0.6), iron_material)
		for x in [-3.4, 3.4]:
			_add_material_box("ServiceLiftPost_%s" % str(x), Vector3(x, 2.5, -16.8), Vector3(0.45, 5.0, 5.8), iron_material)
		_add_material_box("ServiceLiftHeader", Vector3(0.0, 4.8, -16.8), Vector3(7.2, 0.45, 5.8), iron_material)
	elif layout == "vent_conduit":
		_add_material_box("VentDuctL", Vector3(-4.65, 3.25, -11.0), Vector3(1.3, 1.3, 23.0), iron_material)
		_add_material_box("VentDuctR", Vector3(4.65, 3.25, -11.0), Vector3(1.3, 1.3, 23.0), iron_material)
		for brace_index in 6:
			_add_material_box("VentBrace_%02d" % brace_index, Vector3(0.0, 4.5, -2.5 - brace_index * 4.0), Vector3(10.0, 0.4, 0.48), iron_material)


func _build_library_layout() -> void:
	var shelf_material := _environment_material_id("wall")
	var floor_material := _environment_material_id("floor")
	var trim_material := _environment_material_id("column")
	var accent_material := _environment_material_id("accent")
	_add_material_box("LibraryRunner", Vector3(0.0, 0.025, -10.0), Vector3(2.4, 0.06, 24.0), accent_material)
	for shelf_index in 5:
		var z := -3.4 - shelf_index * 4.6
		_add_material_box("LibraryShelfL_%02d" % shelf_index, Vector3(-5.1, 2.15, z), Vector3(1.25, 4.3, 3.35), shelf_material)
		_add_material_box("LibraryShelfR_%02d" % shelf_index, Vector3(5.1, 2.15, z), Vector3(1.25, 4.3, 3.35), shelf_material)
	_add_material_box("LibraryUpperGallery", Vector3(0.0, 4.25, -15.0), Vector3(10.6, 0.28, 2.0), floor_material)
	_add_material_box("LibraryGalleryRail", Vector3(0.0, 4.75, -13.95), Vector3(10.6, 0.85, 0.18), trim_material)
	_add_material_box("LibraryReadingDais", Vector3(0.0, 0.18, -19.0), Vector3(6.5, 0.36, 3.0), floor_material)


func _build_roof_layout(layout: String) -> void:
	var floor_material := _environment_material_id("floor")
	var stone_material := _environment_material_id("wall")
	var trim_material := _environment_material_id("column")
	_add_material_box("RoofParapetL", Vector3(-5.45, 0.75, -10.0), Vector3(1.1, 1.5, 25.0), stone_material)
	_add_material_box("RoofParapetR", Vector3(5.45, 0.75, -10.0), Vector3(1.1, 1.5, 25.0), stone_material)
	if layout == "roof_approach":
		_add_material_box("RoofSlopeL", Vector3(-3.25, 0.32, -11.5), Vector3(4.7, 0.32, 23.0), floor_material, Vector3(0.0, 0.0, -7.0))
		_add_material_box("RoofSlopeR", Vector3(3.25, 0.32, -11.5), Vector3(4.7, 0.32, 23.0), floor_material, Vector3(0.0, 0.0, 7.0))
		_add_material_box("RoofRidge", Vector3(0.0, 0.8, -11.5), Vector3(0.5, 1.0, 23.0), trim_material)
	elif layout == "roof_ledge":
		_add_material_box("RoofRescueLedge", Vector3(0.0, 0.2, -15.5), Vector3(9.4, 0.4, 8.0), floor_material)
		_add_material_box("RoofLedgeLip", Vector3(0.0, 0.8, -19.4), Vector3(9.4, 1.3, 0.6), stone_material)
	elif layout == "hangedman_arena":
		_add_material_box("HangedmanPlatform", Vector3(0.0, 0.18, -13.0), Vector3(10.7, 0.36, 16.0), floor_material)
		for arena_x in [-4.65, 4.65]:
			for arena_z in [-7.0, -19.0]:
				_add_material_box("HangedmanPinnacle_%s_%s" % [str(arena_x), str(arena_z)], Vector3(arena_x, 2.0, arena_z), Vector3(0.9, 4.0, 0.9), trim_material)
		_add_material_box("HangedmanFarParapet", Vector3(0.0, 0.8, -21.0), Vector3(11.0, 1.6, 0.8), stone_material)
	elif layout == "rematch_roof":
		_add_material_box("RematchRoofDeck", Vector3(0.0, 0.16, -13.0), Vector3(9.8, 0.32, 15.0), floor_material)
		_add_material_box("BrokenParapetL", Vector3(-3.6, 0.8, -20.0), Vector3(3.4, 1.6, 0.8), stone_material, Vector3(0.0, -8.0, 0.0))
		_add_material_box("BrokenParapetR", Vector3(3.8, 0.62, -20.3), Vector3(2.8, 1.2, 0.8), stone_material, Vector3(0.0, 13.0, 5.0))


func _build_chariot_arena_layout() -> void:
	var floor_material := _environment_material_id("floor")
	var wall_material := _environment_material_id("wall")
	var trim_material := _environment_material_id("column")
	var accent_material := _environment_material_id("accent")
	_add_material_box("ChariotArenaFloor", Vector3(0.0, 0.08, -13.0), Vector3(10.8, 0.16, 17.5), floor_material)
	_add_material_box("ChariotCarpet", Vector3(0.0, 0.18, -13.0), Vector3(3.2, 0.06, 16.5), accent_material)
	_add_material_box("ChariotDais", Vector3(0.0, 0.34, -19.2), Vector3(7.4, 0.68, 3.8), floor_material)
	for pillar_index in 4:
		var z := -6.0 - pillar_index * 4.3
		_add_material_box("ChariotButtressL_%02d" % pillar_index, Vector3(-5.15, 2.55, z), Vector3(1.05, 5.1, 1.15), trim_material)
		_add_material_box("ChariotButtressR_%02d" % pillar_index, Vector3(5.15, 2.55, z), Vector3(1.05, 5.1, 1.15), trim_material)
	_add_material_box("ChariotBackWall", Vector3(0.0, 2.6, -21.0), Vector3(10.8, 5.2, 0.7), wall_material)
	_add_material_box("ChariotArchTop", Vector3(0.0, 4.65, -20.5), Vector3(8.4, 0.7, 1.4), trim_material)


func _build_hermit_tunnel_layout() -> void:
	var web_material := _environment_material_id("wall")
	var floor_material := _environment_material_id("floor")
	var rib_material := _environment_material_id("column")
	_add_material_box("HermitTunnelFloor", Vector3(0.0, 0.05, -12.0), Vector3(8.6, 0.1, 23.0), floor_material)
	_add_material_box("HermitWebCrown", Vector3(0.0, 4.55, -12.0), Vector3(9.2, 0.48, 23.0), web_material)
	for rib_index in 7:
		var z := -2.8 - rib_index * 3.3
		_add_material_box("HermitWebRibL_%02d" % rib_index, Vector3(-4.0, 2.45, z), Vector3(0.42, 5.0, 0.48), web_material, Vector3(0.0, 0.0, -18.0))
		_add_material_box("HermitWebRibR_%02d" % rib_index, Vector3(4.0, 2.45, z), Vector3(0.42, 5.0, 0.48), web_material, Vector3(0.0, 0.0, 18.0))
		_add_material_box("HermitTunnelBrace_%02d" % rib_index, Vector3(0.0, 4.2, z), Vector3(8.6, 0.3, 0.5), rib_material)
	_add_material_box("HermitWebVeilL", Vector3(-3.4, 2.2, -15.0), Vector3(0.12, 3.3, 7.0), web_material, Vector3(0.0, -12.0, 0.0))
	_add_material_box("HermitWebVeilR", Vector3(3.5, 2.0, -11.0), Vector3(0.12, 3.0, 6.0), web_material, Vector3(0.0, 16.0, 0.0))


func _build_laboratory_layout(layout: String) -> void:
	var floor_material := _environment_material_id("floor")
	var wall_material := _environment_material_id("wall")
	var pipe_material := _environment_material_id("column")
	var machine_material := _environment_material_id("accent")
	var glass_material := _environment_material_id("glass", "wall")
	_add_material_box("LabCenterGrating", Vector3(0.0, 0.035, -11.0), Vector3(4.0, 0.08, 25.0), floor_material)
	for rib_index in 6:
		var z := -2.8 - rib_index * 4.2
		_add_material_box("LabRibL_%02d" % rib_index, Vector3(-5.45, 2.5, z), Vector3(0.36, 5.0, 0.46), pipe_material)
		_add_material_box("LabRibR_%02d" % rib_index, Vector3(5.45, 2.5, z), Vector3(0.36, 5.0, 0.46), pipe_material)
		_add_material_box("LabRibTop_%02d" % rib_index, Vector3(0.0, 5.0, z), Vector3(11.2, 0.3, 0.46), pipe_material)
	if layout == "elevator_lobby":
		_add_material_box("ElevatorBack", Vector3(0.0, 2.5, -20.3), Vector3(7.6, 5.0, 0.65), wall_material)
		_add_material_box("ElevatorDoorL", Vector3(-1.7, 2.15, -19.9), Vector3(3.25, 4.3, 0.25), machine_material)
		_add_material_box("ElevatorDoorR", Vector3(1.7, 2.15, -19.9), Vector3(3.25, 4.3, 0.25), machine_material)
		_add_material_box("ElevatorHeader", Vector3(0.0, 4.65, -19.7), Vector3(7.5, 0.65, 0.8), pipe_material)
	elif layout in ["upper_research", "specimen_bay"]:
		_add_material_box("ResearchGlassL", Vector3(-4.15, 2.3, -13.5), Vector3(0.16, 3.8, 9.5), glass_material)
		_add_material_box("ResearchGlassR", Vector3(4.15, 2.3, -13.5), Vector3(0.16, 3.8, 9.5), glass_material)
		_add_material_box("ResearchPlinthL", Vector3(-4.1, 0.38, -13.5), Vector3(2.3, 0.76, 9.5), machine_material)
		_add_material_box("ResearchPlinthR", Vector3(4.1, 0.38, -13.5), Vector3(2.3, 0.76, 9.5), machine_material)
	elif layout == "high_bridge":
		_add_material_box("LabBridgeDeck", Vector3(0.0, 0.42, -12.0), Vector3(4.8, 0.68, 23.0), floor_material)
		_add_material_box("LabBridgeRailL", Vector3(-2.45, 1.3, -12.0), Vector3(0.18, 1.65, 23.0), pipe_material)
		_add_material_box("LabBridgeRailR", Vector3(2.45, 1.3, -12.0), Vector3(0.18, 1.65, 23.0), pipe_material)
	elif layout == "curien_tunnel":
		_add_material_box("CurienConduitL", Vector3(-4.8, 3.45, -12.0), Vector3(1.0, 1.1, 23.0), pipe_material)
		_add_material_box("CurienConduitR", Vector3(4.8, 3.45, -12.0), Vector3(1.0, 1.1, 23.0), pipe_material)
	elif layout == "rematch_arena":
		_add_material_box("RematchArenaDeck", Vector3(0.0, 0.16, -13.0), Vector3(10.4, 0.32, 17.0), floor_material)
		_add_material_box("RematchArenaDais", Vector3(0.0, 0.42, -19.0), Vector3(7.0, 0.84, 3.6), machine_material)
		for x in [-4.7, 4.7]:
			_add_material_box("RematchPylon_%s" % str(x), Vector3(x, 2.4, -17.5), Vector3(1.0, 4.8, 1.2), pipe_material)
	elif layout == "bonus_gate":
		_add_material_box("BonusVaultWall", Vector3(0.0, 2.5, -20.6), Vector3(10.0, 5.0, 0.65), wall_material)
		_add_material_box("BonusVaultHeader", Vector3(0.0, 4.55, -20.0), Vector3(8.4, 0.65, 1.2), pipe_material)
	elif layout == "supply_cache":
		# The conditional bonus room has no prop sprites; these textured racks and
		# storage bays make it a complete reward room instead of an empty corridor.
		_add_material_box("SupplyBackWall", Vector3(0.0, 2.5, -20.5), Vector3(10.2, 5.0, 0.65), wall_material)
		for rack_index in 4:
			var x := -4.2 + rack_index * 2.8
			_add_material_box("SupplyRack_%02d" % rack_index, Vector3(x, 1.5, -17.8), Vector3(1.8, 3.0, 1.2), machine_material)
			_add_material_box("SupplyRackShelf_%02d" % rack_index, Vector3(x, 2.55, -17.1), Vector3(1.9, 0.16, 1.4), pipe_material)
	elif layout == "final_horde":
		_add_material_box("HordeTankBayL", Vector3(-4.25, 1.25, -14.0), Vector3(2.7, 2.5, 10.0), machine_material)
		_add_material_box("HordeTankBayR", Vector3(4.25, 1.25, -14.0), Vector3(2.7, 2.5, 10.0), machine_material)
		_add_material_box("HordeGlassL", Vector3(-3.35, 2.5, -14.0), Vector3(0.12, 3.5, 9.5), glass_material)
		_add_material_box("HordeGlassR", Vector3(3.35, 2.5, -14.0), Vector3(0.12, 3.5, 9.5), glass_material)
	elif layout == "bioreactor":
		_add_material_box("BioreactorDeck", Vector3(0.0, 0.18, -14.0), Vector3(10.4, 0.36, 16.0), floor_material)
		for x in [-4.4, 4.4]:
			_add_material_box("BioreactorCore_%s" % str(x), Vector3(x, 2.35, -15.5), Vector3(1.7, 4.7, 4.5), machine_material)
			_add_material_box("BioreactorGlass_%s" % str(x), Vector3(x * 0.78, 2.4, -15.5), Vector3(0.14, 3.8, 4.0), glass_material)
		_add_material_box("BioreactorGantry", Vector3(0.0, 4.35, -15.5), Vector3(10.4, 0.42, 3.2), pipe_material)
	elif layout == "magician_arena":
		_add_material_box("MagicianArenaDeck", Vector3(0.0, 0.18, -13.5), Vector3(10.6, 0.36, 17.5), floor_material)
		_add_material_box("MagicianAxisX", Vector3(0.0, 0.39, -14.0), Vector3(9.5, 0.08, 0.55), machine_material)
		_add_material_box("MagicianAxisZ", Vector3(0.0, 0.39, -14.0), Vector3(0.55, 0.08, 14.0), machine_material)
		for arena_x in [-4.6, 4.6]:
			for arena_z in [-8.0, -19.0]:
				_add_material_box("MagicianPylon_%s_%s" % [str(arena_x), str(arena_z)], Vector3(arena_x, 2.5, arena_z), Vector3(0.9, 5.0, 1.1), pipe_material)


func _add_material_box(node_name: String, at: Vector3, dimensions: Vector3, material_id: String, rotation_degrees_value: Vector3 = Vector3.ZERO) -> void:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = dimensions
	instance.mesh = mesh
	instance.position = at
	instance.rotation_degrees = rotation_degrees_value
	_configure_environment_mesh_blocker(instance, node_name, dimensions)
	instance.material_override = environment_asset_library.create_material(material_id)
	world_root.add_child(instance)


func _spawn_environment_props() -> void:
	for placement_value in environment_scene_profile.get("props", []) as Array:
		var placement := placement_value as Dictionary
		var prop_id := str(placement.get("id", ""))
		var profile := environment_asset_library.get_prop(prop_id)
		if profile.is_empty():
			continue
		var sprite := Sprite3D.new()
		sprite.name = "Prop_%s" % prop_id
		sprite.texture = load(str(profile.get("path", ""))) as Texture2D
		sprite.hframes = maxi(1, int(profile.get("hframes", 1)))
		sprite.frame = 0
		sprite.pixel_size = float(profile.get("pixel_size", 0.0065))
		sprite.scale = Vector3.ONE * float(profile.get("world_scale", 1.0))
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
		sprite.set_meta("environment_prop_id", prop_id)
		var position_data := placement.get("position", [0.0, 0.0, -12.0]) as Array
		if position_data.size() >= 3:
			sprite.position = Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))
		var blocker_radius := EnemyPursuitControllerScript.prop_radius(prop_id)
		if blocker_radius > 0.0 and sprite.texture != null:
			var blocker_height := float(sprite.texture.get_height()) * sprite.pixel_size * sprite.scale.y
			sprite.set_meta("enemy_blocker_radius", blocker_radius)
			sprite.set_meta("enemy_blocker_height", blocker_height)
		world_root.add_child(sprite)
		var animation_mode := str(profile.get("animate", ""))
		if not animation_mode.is_empty():
			var controller := EnvironmentMotionControllerScript.new()
			controller.configure_target(sprite, animation_mode)
			world_root.add_child(controller)
		if animation_mode == "flicker":
			var light := OmniLight3D.new()
			light.position = sprite.position + Vector3(0.0, 0.9, 0.35)
			light.light_color = Color("#e7a061")
			light.light_energy = 1.45
			light.omni_range = 4.2
			world_root.add_child(light)
			var light_controller := EnvironmentMotionControllerScript.new()
			light_controller.configure_target(light, "sconce")
			world_root.add_child(light_controller)


func _spawn_environment_effects() -> void:
	var effects := environment_scene_profile.get("effects", []) as Array
	var mote_effects: Dictionary = {}
	for effect_value in effects:
		var effect_id := str(effect_value)
		var animated_profile := environment_asset_library.get_animated_effect(effect_id)
		if not animated_profile.is_empty():
			_spawn_animated_environment_effect(effect_id, animated_profile)
			continue
		var resolved_mote := effect_id
		if effect_id in ["drips", "water_flow"]:
			resolved_mote = "mist"
		elif effect_id == "collapse_dust":
			resolved_mote = "dust"
		if resolved_mote in ["rain", "dust", "mist", "steam", "web_drift", "embers", "wind", "distant_bats"]:
			mote_effects[resolved_mote] = true
		if effect_id in ["lightning", "sconce_flicker", "alarm_beacon", "electrical_arc", "monitor_scan"]:
			var light := OmniLight3D.new()
			light.position = Vector3(0.0, 3.7, -11.0)
			light.light_color = Color("#a9c9e8") if effect_id == "lightning" else Color(str(environment_scene_profile.get("light", "#56d2a3")))
			light.light_energy = 1.8
			light.omni_range = 10.0
			world_root.add_child(light)
			var controller := EnvironmentMotionControllerScript.new()
			controller.configure_target(light, "lightning" if effect_id == "lightning" else ("alarm" if effect_id == "alarm_beacon" else "sconce"))
			world_root.add_child(controller)
	for mote_id in mote_effects:
		var motes := EnvironmentMotionControllerScript.new()
		motes.name = "Decorative_%s" % mote_id
		motes.position = Vector3(0.0, 2.8, -10.0)
		var mote_count := 32 if str(mote_id) == "rain" else (10 if str(mote_id) == "distant_bats" else 16)
		motes.configure_motes(str(mote_id), mote_count, Vector3(6.0, 3.0, 13.0))
		world_root.add_child(motes)


func _spawn_animated_environment_effect(effect_id: String, profile: Dictionary) -> void:
	var texture := load(str(profile.get("path", ""))) as Texture2D
	if texture == null:
		push_error("Animated environment effect texture missing: %s" % effect_id)
		return
	var sprite := Sprite3D.new()
	sprite.name = "AnimatedEffect_%s" % effect_id
	sprite.texture = texture
	sprite.hframes = maxi(1, int(profile.get("hframes", 8)))
	sprite.frame = 0
	sprite.pixel_size = float(profile.get("pixel_size", 0.004))
	sprite.scale = Vector3.ONE * float(profile.get("world_scale", 1.0))
	sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.shaded = false
	sprite.modulate = Color.from_string(str(profile.get("tint", "#ffffff")), Color.WHITE)
	var position_data := profile.get("position", [0.0, 2.0, -12.0]) as Array
	if position_data.size() >= 3:
		sprite.position = Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))
	sprite.set_meta("animation_fps", float(profile.get("fps", 8.0)))
	sprite.set_meta("effect_pulse", bool(profile.get("pulse", false)))
	world_root.add_child(sprite)
	var controller := EnvironmentMotionControllerScript.new()
	controller.configure_target(sprite, "effect_strip")
	world_root.add_child(controller)
	var light_energy := float(profile.get("light_energy", 0.0))
	if light_energy > 0.0:
		var light := OmniLight3D.new()
		light.position = sprite.position + Vector3(0.0, 0.0, 0.25)
		light.light_color = Color.from_string(str(profile.get("light_color", "#7ecfff")), Color("#7ecfff"))
		light.light_energy = light_energy
		light.omni_range = float(profile.get("light_range", 3.5))
		world_root.add_child(light)

func _add_backdrop(style: String) -> void:
	var path := str(environment_scene_profile.get("backdrop", ""))
	if path.is_empty():
		path = "res://assets/environments/mansion-exterior.png" if style in ["garden", "roof"] else "res://assets/environments/mansion-hall.png"
	var quad := MeshInstance3D.new()
	var mesh := QuadMesh.new()
	mesh.size = Vector2(20.0, 11.25)
	quad.mesh = mesh
	quad.position = Vector3(0.0, 4.2, -30.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = load(path) as Texture2D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.52, 0.58, 0.62) if style == "laboratory" else Color(0.68, 0.72, 0.76)
	quad.material_override = material
	world_root.add_child(quad)


func _update_demo(delta: float) -> void:
	demo_fire_timer -= delta
	if demo_fire_timer > 0.0 or active_actors.is_empty() or state not in ["node", "boss"]:
		return
	demo_fire_timer = 0.18
	if int(players[0].ammo) <= 0:
		_reload(0)
		return
	for actor in active_actors:
		if is_instance_valid(actor) and not bool(actor.get_meta("dead", false)):
			var target := camera_3d.unproject_position(actor.global_position + Vector3(0.0, 1.55, 0.0))
			players[0].cursor = target
			_attempt_shot(0, target)
			break
