extends "res://src/gameplay/gameplay_runtime_final.gd"


var story_actors: Array[Node3D] = []


func _enter_node(node_id: String) -> void:
	super._enter_node(node_id)
	if current_node_id == "curien_confrontation" and state == "node":
		_spawn_story_actor("curien", Vector3(0.0, 0.0, -11.0), 1.08)
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


func _spawn_story_actor(actor_id: String, at: Vector3, actor_scale: float) -> void:
	var root := Node3D.new()
	root.name = "StoryActor_%s" % actor_id
	root.position = at
	actor_root.add_child(root)
	story_actors.append(root)
	root.set_meta("visual_forward", Vector3.BACK)
	var sprite := Sprite3D.new()
	_configure_actor_sprite(sprite, actor_id, actor_scale)
	root.add_child(sprite)
	var story_forward := camera_3d.global_position - root.global_position
	story_forward.y = 0.0
	if not story_forward.is_zero_approx():
		root.set_meta("visual_forward", story_forward.normalized())
	_apply_directional_sprite_frame(root, 0)
	var tween := root.create_tween().set_loops()
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 1))
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 2))
	tween.tween_interval(0.24)
	tween.tween_callback(_set_story_actor_frame.bind(root, 0))
