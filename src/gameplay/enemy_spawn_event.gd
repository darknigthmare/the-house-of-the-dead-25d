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

var _source_data: Dictionary = {}


func configure_from_dictionary(data: Dictionary) -> void:
	_source_data = data.duplicate(true)
	delay = maxf(0.0, float(data.get("delay", 0.0)))
	count = maxi(1, int(data.get("count", 1)))
	interval = maxf(0.0, float(data.get("interval", 0.0)))
	actor_id = StringName(str(data.get("actor", data.get("actor_id", actor_id))))
	encounter_tag = StringName(str(data.get("encounter_tag", "")))
	properties = (data.get("properties", {}) as Dictionary).duplicate(true)
	var position_data := data.get("position", [0.0, 0.0, -11.0]) as Array
	if position_data.size() >= 3:
		spawn_transform.origin = Vector3(float(position_data[0]), float(position_data[1]), float(position_data[2]))


func get_spawn_time(instance_index: int = 0) -> float:
	return delay + float(clampi(instance_index, 0, maxi(0, count - 1))) * interval


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


func validate() -> PackedStringArray:
	var issues := PackedStringArray()
	if actor_id == &"":
		issues.append("actor_id must not be empty")
	if count < 1:
		issues.append("count must be at least 1")
	return issues


func to_spawn_dictionary(instance_index: int = 0) -> Dictionary:
	var result := _source_data.duplicate(true)
	result["delay"] = get_spawn_time(instance_index)
	result["actor"] = str(actor_id)
	result["position"] = [spawn_transform.origin.x, spawn_transform.origin.y, spawn_transform.origin.z]
	result["encounter_tag"] = str(encounter_tag)
	result["properties"] = properties.duplicate(true)
	result["event"] = self
	return result
