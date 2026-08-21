class_name DismembermentController
extends Node

signal part_damaged(part_id: StringName, damage: float, remaining_health: float)
signal part_detached(part_id: StringName, source_peer_id: int, part_definition: Dictionary)
signal detached_part_spawn_requested(scene: PackedScene, world_transform: Transform3D)

@export_category("References")
@export var damage_receiver: Node

@export_category("Body Parts")
@export var body_parts: Array[Dictionary] = []
@export var enabled: bool = true

var _part_health: Dictionary = {}
var _detached_parts: Dictionary = {}


func _ready() -> void:
	reset_parts()


func reset_parts() -> void:
	_part_health.clear()
	_detached_parts.clear()
	for definition in body_parts:
		var part_id := StringName(str(definition.get("id", &"body")))
		_part_health[part_id] = maxf(0.01, float(definition.get("health", 1.0)))


func apply_part_damage(
		part_id: StringName,
		damage: float,
		source_peer_id: int = 0,
		world_transform: Transform3D = Transform3D.IDENTITY
) -> bool:
	if not enabled or damage <= 0.0 or not _part_health.has(part_id) or is_part_detached(part_id):
		return false
	var definition := get_part_definition(part_id)
	var remaining := maxf(0.0, float(_part_health[part_id]) - damage)
	_part_health[part_id] = remaining
	part_damaged.emit(part_id, damage, remaining)
	if damage_receiver != null and damage_receiver.has_method("take_damage"):
		var actor_damage := damage * maxf(0.0, float(definition.get("actor_damage_multiplier", 1.0)))
		damage_receiver.call("take_damage", actor_damage, part_id, source_peer_id)
	if remaining <= 0.0:
		_detach_part(part_id, source_peer_id, definition, world_transform)
	return true


func is_part_detached(part_id: StringName) -> bool:
	return bool(_detached_parts.get(part_id, false))


func get_part_health(part_id: StringName) -> float:
	return float(_part_health.get(part_id, 0.0))


func get_part_definition(part_id: StringName) -> Dictionary:
	for definition in body_parts:
		if StringName(str(definition.get("id", &""))) == part_id:
			return definition
	return {}


func create_state_snapshot() -> Dictionary:
	return {
		"health": _part_health.duplicate(true),
		"detached": _detached_parts.duplicate(true),
	}


func restore_state(snapshot: Dictionary) -> void:
	_part_health = (snapshot.get("health", {}) as Dictionary).duplicate(true)
	_detached_parts = (snapshot.get("detached", {}) as Dictionary).duplicate(true)


func _detach_part(
		part_id: StringName,
		source_peer_id: int,
		definition: Dictionary,
		world_transform: Transform3D
) -> void:
	_detached_parts[part_id] = true
	part_detached.emit(part_id, source_peer_id, definition.duplicate(true))
	var part_scene := definition.get("detached_scene") as PackedScene
	if part_scene != null:
		detached_part_spawn_requested.emit(part_scene, world_transform)
