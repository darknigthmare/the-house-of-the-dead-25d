class_name HitZoneController
extends Area3D

signal hit_registered(
	zone_id: StringName,
	final_damage: float,
	source_peer_id: int,
	world_position: Vector3
)
signal hit_rejected(zone_id: StringName)

@export_category("Hit Zone")
@export var zone_id: StringName = &"body"
@export_range(0.0, 100.0, 0.01) var damage_multiplier: float = 1.0
@export_range(-1000.0, 1000.0, 0.01) var flat_damage_bonus: float = 0.0
@export var damage_receiver: Node
@export var enabled: bool = true


func _ready() -> void:
	monitorable = enabled


func receive_hit(
		base_damage: float,
		source_peer_id: int = 0,
		world_hit_position: Vector3 = Vector3.ZERO
) -> bool:
	if not enabled or damage_receiver == null or not damage_receiver.has_method("take_damage"):
		hit_rejected.emit(zone_id)
		return false
	var final_damage := maxf(0.0, (base_damage * damage_multiplier) + flat_damage_bonus)
	if final_damage <= 0.0:
		hit_rejected.emit(zone_id)
		return false
	var accepted := bool(damage_receiver.call("take_damage", final_damage, zone_id, source_peer_id))
	if accepted:
		var position := global_position if world_hit_position == Vector3.ZERO else world_hit_position
		hit_registered.emit(zone_id, final_damage, source_peer_id, position)
	else:
		hit_rejected.emit(zone_id)
	return accepted


func set_hit_enabled(value: bool) -> void:
	enabled = value
	monitorable = value
	monitoring = value


func preview_damage(base_damage: float) -> float:
	return maxf(0.0, (base_damage * damage_multiplier) + flat_damage_bonus)
