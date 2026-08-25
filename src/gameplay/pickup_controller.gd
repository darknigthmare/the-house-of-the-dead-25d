class_name PickupController
extends Node

signal collected(pickup_id: StringName, pickup_type: StringName, amount: int, player_index: int)

@export_category("Pickup")
@export var pickup_id: StringName = &"pickup"
@export var pickup_type: StringName = &"score"
@export_range(1, 100000, 1) var amount: int = 1

@export_category("Presentation")
@export_range(0.0, 2.0, 0.01) var bob_height: float = 0.09
@export_range(0.0, 10.0, 0.01) var bob_speed: float = 2.5
@export var motion: StringName = &"bob"
@export var phase: float = 0.0

var is_collected: bool = false


func configure(data: Dictionary) -> void:
	pickup_id = StringName(str(data.get("id", pickup_id)))
	pickup_type = StringName(str(data.get("pickup", pickup_type)))
	amount = maxi(1, int(data.get("amount", amount)))
	bob_height = maxf(0.0, float(data.get("bob_height", bob_height)))
	bob_speed = maxf(0.0, float(data.get("bob_speed", bob_speed)))
	motion = StringName(str(data.get("motion", motion)))
	phase = float(data.get("phase", phase))
	is_collected = false


func collect_by_shot(player_index: int) -> bool:
	if is_collected or player_index < 0:
		return false
	is_collected = true
	collected.emit(pickup_id, pickup_type, amount, player_index)
	return true


func vertical_offset(elapsed: float) -> float:
	var sample := maxf(0.0, elapsed) * bob_speed + phase
	if motion == &"hop":
		return absf(sin(sample)) * maxf(bob_height, 0.22)
	return sin(sample) * bob_height


func alpha_at(elapsed: float) -> float:
	return clampf(0.88 + sin(maxf(0.0, elapsed) * 4.0 + phase) * 0.12, 0.0, 1.0)
