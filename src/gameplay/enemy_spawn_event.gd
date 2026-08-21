class_name EnemySpawnEvent
extends Resource

@export_category("Schedule")
@export_range(0.0, 600.0, 0.01) var delay: float = 0.0
@export_range(1, 64, 1) var count: int = 1
@export_range(0.0, 60.0, 0.01) var interval: float = 0.0

@export_category("Enemy")
@export var actor_id: StringName = &"enemy"
@export var actor_scene: PackedScene
@export var spawn_transform: Transform3D = Transform3D.IDENTITY
@export var encounter_tag: StringName
@export var properties: Dictionary = {}


func get_spawn_time(instance_index: int = 0) -> float:
	return delay + (float(clampi(instance_index, 0, maxi(0, count - 1))) * interval)


func instantiate_actor(instance_index: int = 0) -> Node3D:
	if actor_scene == null or instance_index < 0 or instance_index >= count:
		return null
	var instance := actor_scene.instantiate()
	if not instance is Node3D:
		instance.free()
		return null
	var actor := instance as Node3D
	actor.transform = spawn_transform
	actor.set_meta("actor_id", actor_id)
	actor.set_meta("encounter_tag", encounter_tag)
	actor.set_meta("spawn_instance_index", instance_index)
	if actor.has_method("configure"):
		var actor_data := properties.duplicate(true)
		actor_data["id"] = actor_id
		actor.call("configure", actor_data)
	return actor


func instantiate_all(parent: Node3D) -> Array[Node3D]:
	var actors: Array[Node3D] = []
	if parent == null:
		return actors
	for index in count:
		var actor := instantiate_actor(index)
		if actor != null:
			parent.add_child(actor)
			actors.append(actor)
	return actors


func validate() -> PackedStringArray:
	var issues := PackedStringArray()
	if actor_id == &"":
		issues.append("actor_id must not be empty")
	if actor_scene == null:
		issues.append("actor_scene is required")
	if count < 1:
		issues.append("count must be at least 1")
	return issues


func to_spawn_dictionary(instance_index: int = 0) -> Dictionary:
	return {
		"delay": get_spawn_time(instance_index),
		"actor": actor_id,
		"transform": spawn_transform,
		"encounter_tag": encounter_tag,
		"properties": properties.duplicate(true),
		"event": self,
	}
