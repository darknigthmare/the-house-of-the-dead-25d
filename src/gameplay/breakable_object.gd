class_name BreakableObject
extends Node

signal damaged(amount: float, remaining_durability: float, source_player_index: int)
signal broken(source_player_index: int, reward_definition: Dictionary)

@export_category("Breakable")
@export var object_id: StringName = &"breakable"
@export_range(0.01, 10000.0, 0.01) var max_durability: float = 1.0
@export var reward_definition: Dictionary = {}
@export var persist_broken_visual_until_scene_clear: bool = true

var durability: float = 1.0
var is_broken: bool = false


func configure(data: Dictionary) -> void:
	object_id = StringName(str(data.get("id", object_id)))
	max_durability = maxf(0.01, float(data.get("durability", data.get("health", max_durability))))
	durability = max_durability
	reward_definition = (data.get("reward", {}) as Dictionary).duplicate(true)
	persist_broken_visual_until_scene_clear = bool(data.get("persist_broken_visual", true))
	is_broken = false


func take_damage(amount: float, source_player_index: int = 0) -> bool:
	if is_broken or amount <= 0.0:
		return false
	durability = maxf(0.0, durability - amount)
	damaged.emit(amount, durability, source_player_index)
	if durability <= 0.0:
		is_broken = true
		broken.emit(source_player_index, reward_definition.duplicate(true))
	return true


func repair(amount: float) -> float:
	if amount <= 0.0:
		return durability
	durability = minf(max_durability, durability + amount)
	is_broken = durability <= 0.0
	return durability


func get_reward() -> Dictionary:
	return reward_definition.duplicate(true)


# Data-only state can be retained when a chapter scene is reconstructed.
# Restoring does not emit damaged/broken signals or grant rewards again.
func capture_state() -> Dictionary:
	return {
		"durability": durability,
		"is_broken": is_broken,
	}


func restore_state(snapshot: Dictionary) -> bool:
	if snapshot.is_empty():
		return false
	durability = clampf(float(snapshot.get("durability", max_durability)), 0.0, max_durability)
	is_broken = bool(snapshot.get("is_broken", durability <= 0.0)) or durability <= 0.0
	if is_broken:
		durability = 0.0
	return true
