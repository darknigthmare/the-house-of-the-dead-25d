extends "res://src/gameplay/gameplay_runtime_final.gd"


const CURIEN_ATTACK_WINDUP_SECONDS := 0.65
const CURIEN_PROJECTILE_TRAVEL_SECONDS := 0.44
const CURIEN_HIT_RECOIL_SECONDS := 0.36
const CURIEN_DEATH_FALL_SECONDS := 0.68
const CURIEN_MIN_CORPSE_HOLD_SECONDS := 5.0


var story_actors: Array[Node3D] = []
var curien_story_actor: Node3D = null
var curien_finale_tween: Tween = null


func _enter_node(node_id: String) -> void:
	super._enter_node(node_id)
	if current_node_id == "curien_confrontation" and state == "node":
		_spawn_story_actor("curien", Vector3(0.0, 0.0, -11.0), 1.08)
	elif current_node_id == "magician_battle" and state == "boss":
		curien_story_actor = _spawn_story_actor("curien", Vector3(2.35, 0.0, -9.65), 1.08, false)
		_play_curien_finale(curien_story_actor)
	elif current_node_id == "sophie_corridor" and state == "node":
		var sprite := active_civilian.get_node_or_null("Sprite3D") as Sprite3D if active_civilian != null else null
		if sprite != null:
			_configure_actor_sprite(sprite, "sophie", float(active_civilian.get_meta("visual_scale", 0.94)))
			_apply_directional_sprite_frame(active_civilian, int(active_civilian.get_meta("animation_state", 0)))


func _finish_node() -> void:
	if current_node_id == "bonus_gate":
		branch_success = all_scientists_saved
		scientists_total = maxi(scientists_total, scientists_saved)
	super._finish_node()


func _clear_actors() -> void:
	if curien_finale_tween != null and curien_finale_tween.is_valid():
		curien_finale_tween.kill()
	curien_finale_tween = null
	curien_story_actor = null
	for actor in story_actors:
		if is_instance_valid(actor):
			actor.queue_free()
	story_actors.clear()
	super._clear_actors()


func _set_story_actor_frame(actor: Node3D, local_frame: int) -> void:
	if not is_instance_valid(actor):
		return
	actor.set_meta("animation_state", local_frame)
	_apply_directional_sprite_frame(actor, local_frame)


func _spawn_story_actor(actor_id: String, at: Vector3, actor_scale: float, animate_idle: bool = true) -> Node3D:
	var root := Node3D.new()
	root.name = "StoryActor_%s" % actor_id
	root.position = at
	actor_root.add_child(root)
	story_actors.append(root)
	root.set_meta("actor_id", actor_id)
	root.set_meta("role", "story")
	root.set_meta("targetable", false)
	root.set_meta("dead", false)
	root.set_meta("narrative_state", "idle")
	root.set_meta("visual_forward", Vector3.BACK)
	var sprite := Sprite3D.new()
	sprite.name = "Sprite3D"
	_configure_actor_sprite(sprite, actor_id, actor_scale)
	root.add_child(sprite)
	var story_forward := camera_3d.global_position - root.global_position if camera_3d != null and is_instance_valid(camera_3d) else Vector3.BACK
	story_forward.y = 0.0
	if not story_forward.is_zero_approx():
		root.set_meta("visual_forward", story_forward.normalized())
	_apply_directional_sprite_frame(root, 0)
	if not animate_idle:
		return root
	var tween := root.create_tween().set_loops()
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 1))
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 2))
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 0))
	return root


func _play_curien_finale(curien: Node3D) -> void:
	if not is_instance_valid(curien):
		return
	var strike_effect := _spawn_magician_story_projectile(curien)
	var recoil_position := curien.position + Vector3(0.34, 0.16, 0.16)
	var death_position := curien.position + Vector3(0.44, -0.52, 0.26)
	curien.set_meta("narrative_state", "awaiting_magician_attack")
	curien.set_meta("corpse_persistent", true)
	curien.set_meta("corpse_hold_seconds", CURIEN_MIN_CORPSE_HOLD_SECONDS)
	curien.set_meta("corpse_hold_complete", false)
	curien_finale_tween = curien.create_tween()
	curien_finale_tween.tween_interval(CURIEN_ATTACK_WINDUP_SECONDS)
	curien_finale_tween.tween_callback(_show_magician_curien_strike.bind(curien, strike_effect))
	curien_finale_tween.tween_property(strike_effect, "position", curien.position + Vector3(0.0, 1.12, 0.0), CURIEN_PROJECTILE_TRAVEL_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	curien_finale_tween.tween_callback(_apply_curien_hit_recoil.bind(curien, strike_effect))
	curien_finale_tween.tween_property(curien, "position", recoil_position, CURIEN_HIT_RECOIL_SECONDS).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	curien_finale_tween.tween_callback(_begin_curien_death_fall.bind(curien))
	curien_finale_tween.tween_property(curien, "position", death_position, CURIEN_DEATH_FALL_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	curien_finale_tween.parallel().tween_property(curien, "rotation:z", deg_to_rad(78.0), CURIEN_DEATH_FALL_SECONDS).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	curien_finale_tween.tween_callback(_ground_curien_corpse.bind(curien))
	curien_finale_tween.tween_interval(CURIEN_MIN_CORPSE_HOLD_SECONDS)
	curien_finale_tween.tween_callback(_confirm_curien_corpse_hold.bind(curien))


func _spawn_magician_story_projectile(curien: Node3D) -> Node3D:
	var effect := Node3D.new()
	effect.name = "StoryEffect_MagicianCurienStrike"
	effect.set_meta("actor_id", "magician_curien_strike")
	effect.set_meta("role", "story_effect")
	effect.set_meta("targetable", false)
	effect.set_meta("narrative_state", "hidden")
	actor_root.add_child(effect)
	story_actors.append(effect)
	if current_boss != null and is_instance_valid(current_boss):
		effect.position = current_boss.position + Vector3(0.0, 1.24, 0.0)
	else:
		effect.position = curien.position + Vector3(-2.0, 1.24, 0.0)
	var sprite := Sprite3D.new()
	sprite.name = "Sprite3D"
	sprite.texture = gameplay_support_library.load_texture(gameplay_support_library.get_projectile("magician_fireball"))
	sprite.pixel_size = 0.0035
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	sprite.shaded = false
	sprite.modulate = Color(1.0, 0.78, 0.58, 1.0)
	effect.add_child(sprite)
	effect.visible = false
	return effect


func _show_magician_curien_strike(curien: Node3D, effect: Node3D) -> void:
	if not is_instance_valid(curien) or not is_instance_valid(effect):
		return
	if current_boss != null and is_instance_valid(current_boss):
		var strike_forward := curien.global_position - current_boss.global_position
		strike_forward.y = 0.0
		if not strike_forward.is_zero_approx():
			current_boss.set_meta("visual_forward", strike_forward.normalized())
		effect.position = current_boss.position + Vector3(0.0, 1.24, 0.0)
		current_boss.set_meta("narrative_attack", "curien_execution")
		current_boss.set_meta("attack_animation_timer", maxf(float(current_boss.get_meta("attack_animation_timer", 0.0)), CURIEN_PROJECTILE_TRAVEL_SECONDS + 0.16))
		current_boss.set_meta("animation_state", 4)
		_apply_directional_sprite_frame(current_boss, 4)
	effect.visible = true
	effect.set_meta("narrative_state", "in_flight")
	_play_sfx("boss_projectile")


func _apply_curien_hit_recoil(curien: Node3D, effect: Node3D) -> void:
	if not is_instance_valid(curien):
		return
	if is_instance_valid(effect):
		effect.visible = false
		effect.set_meta("narrative_state", "impact")
		_retire_story_effect(effect)
	curien.set_meta("narrative_state", "hit_recoil")
	curien.set_meta("dead", false)
	_set_story_actor_frame(curien, 6)
	var sprite := curien.get_node_or_null("Sprite3D") as Sprite3D
	if sprite != null:
		sprite.modulate = Color(1.0, 0.58, 0.52, 1.0)
	_spawn_impact(curien.global_position + Vector3(0.0, 1.12, 0.0), "torso")
	_play_sfx("hit")


func _begin_curien_death_fall(curien: Node3D) -> void:
	if not is_instance_valid(curien):
		return
	curien.set_meta("narrative_state", "death_fall")
	_set_story_actor_frame(curien, 7)


func _ground_curien_corpse(curien: Node3D) -> void:
	if not is_instance_valid(curien):
		return
	curien.set_meta("narrative_state", "dead_grounded")
	curien.set_meta("dead", true)
	curien.set_meta("targetable", false)
	curien.rotation.z = deg_to_rad(78.0)
	_set_story_actor_frame(curien, 7)
	var sprite := curien.get_node_or_null("Sprite3D") as Sprite3D
	if sprite != null:
		sprite.modulate = Color(0.72, 0.62, 0.62, 1.0)


func _confirm_curien_corpse_hold(curien: Node3D) -> void:
	if is_instance_valid(curien) and str(curien.get_meta("narrative_state", "")) == "dead_grounded":
		curien.set_meta("corpse_hold_complete", true)


func _retire_story_effect(effect: Node3D) -> void:
	story_actors.erase(effect)
	if is_instance_valid(effect):
		effect.queue_free()
