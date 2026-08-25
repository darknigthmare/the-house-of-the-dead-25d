class_name BreakableObject
extends Node

signal damaged(amount: float, remaining_durability: float, source_player_index: int)
signal broken(source_player_index: int, reward_definition: Dictionary)

@export_category("Breakable")
@export var object_id: StringName = &"breakable"
@export_range(0.01, 10000.0, 0.01) var max_durability: float = 1.0
@export var reward_definition: Dictionary = {}

var durability: float = 1.0
var is_broken: bool = false


func configure(data: Dictionary) -> void:
	object_id = StringName(str(data.get("id", object_id)))
	max_durability = maxf(0.01, float(data.get("durability", data.get("health", max_durability))))
	durability = max_durability
	reward_definition = (data.get("reward", {}) as Dictionary).duplicate(true)
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
