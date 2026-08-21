class_name CivilianController
extends SpriteActor3D

signal civilian_state_changed(new_state: CivilianState)
signal rescued(civilian_id: StringName, rescuer_peer_id: int, score_value: int)
signal civilian_lost(civilian_id: StringName, reason: StringName)

enum CivilianState {
	SAFE,
	ENDANGERED,
	RESCUED,
	LOST,
}

@export_category("Civilian")
@export var civilian_id: StringName = &"civilian"
@export_range(0, 100000, 1) var rescue_score: int = 500
@export_range(0.0, 120.0, 0.1) var danger_timeout: float = 8.0
@export var fail_on_any_hit: bool = true

var civilian_state: CivilianState = CivilianState.SAFE
var danger_remaining: float = 0.0
var threat: Node3D


func _process(delta: float) -> void:
	if civilian_state != CivilianState.ENDANGERED or danger_timeout <= 0.0:
		return
	danger_remaining = maxf(0.0, danger_remaining - maxf(delta, 0.0))
	if danger_remaining <= 0.0:
		mark_lost(&"timeout")


func enter_danger(source: Node3D = null) -> bool:
	if civilian_state == CivilianState.RESCUED or civilian_state == CivilianState.LOST:
		return false
	threat = source
	danger_remaining = danger_timeout
	_set_civilian_state(CivilianState.ENDANGERED)
	return true


func request_rescue(rescuer_peer_id: int = 0) -> bool:
	if civilian_state == CivilianState.RESCUED or civilian_state == CivilianState.LOST:
		return false
	threat = null
	clear_move_target()
	_set_civilian_state(CivilianState.RESCUED)
	rescued.emit(civilian_id, rescuer_peer_id, rescue_score)
	return true


func mark_lost(reason: StringName = &"killed") -> bool:
	if civilian_state == CivilianState.RESCUED or civilian_state == CivilianState.LOST:
		return false
	threat = null
	_set_civilian_state(CivilianState.LOST)
	civilian_lost.emit(civilian_id, reason)
	return true


func take_damage(amount: float, hit_zone: StringName = &"body", source_peer_id: int = 0) -> bool:
	if civilian_state == CivilianState.RESCUED or civilian_state == CivilianState.LOST:
		return false
	if fail_on_any_hit:
		mark_lost(&"friendly_fire")
		return super.take_damage(maxf(amount, health), hit_zone, source_peer_id)
	var accepted := super.take_damage(amount, hit_zone, source_peer_id)
	if accepted and not is_alive():
		mark_lost(&"killed")
	return accepted


func is_rescuable() -> bool:
	return civilian_state == CivilianState.SAFE or civilian_state == CivilianState.ENDANGERED


func _set_civilian_state(value: CivilianState) -> void:
	if civilian_state == value:
		return
	civilian_state = value
	civilian_state_changed.emit(civilian_state)
