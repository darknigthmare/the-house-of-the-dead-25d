class_name CivilianController
extends Node

signal civilian_state_changed(new_state: CivilianState)
signal rescue_window_expired(civilian_id: StringName)
signal rescued(civilian_id: StringName, rescuer_player_index: int, score_value: int)
signal civilian_lost(civilian_id: StringName, reason: StringName)

enum CivilianState {
	SAFE,
	ENDANGERED,
	RESCUED,
	LOST,
}

const VISIBLE_LOSS_REASONS: Array[StringName] = [
	&"enemy_melee_contact",
	&"enemy_projectile_contact",
	&"friendly_fire",
]

@export_category("Civilian")
@export var civilian_id: StringName = &"civilian"
@export_range(0, 100000, 1) var rescue_score: int = 400
@export_range(0.0, 120.0, 0.1) var danger_timeout: float = 8.0

var civilian_state: CivilianState = CivilianState.SAFE
var danger_remaining: float = 0.0
var deadline_announced: bool = false


func configure(data: Dictionary) -> void:
	civilian_id = StringName(str(data.get("id", data.get("actor_id", civilian_id))))
	rescue_score = maxi(0, int(data.get("rescue_score", rescue_score)))
	danger_timeout = maxf(0.0, float(data.get("deadline", danger_timeout)))
	danger_remaining = danger_timeout
	deadline_announced = false
	civilian_state = CivilianState.SAFE


func enter_danger() -> bool:
	if civilian_state in [CivilianState.RESCUED, CivilianState.LOST]:
		return false
	danger_remaining = danger_timeout
	deadline_announced = false
	_set_civilian_state(CivilianState.ENDANGERED)
	return true


func advance_danger(delta: float) -> bool:
	if civilian_state != CivilianState.ENDANGERED or deadline_announced:
		return false
	danger_remaining = maxf(0.0, danger_remaining - maxf(delta, 0.0))
	if danger_remaining > 0.0:
		return false
	deadline_announced = true
	rescue_window_expired.emit(civilian_id)
	return true


func request_rescue(rescuer_player_index: int = 0) -> bool:
	if not is_rescuable():
		return false
	_set_civilian_state(CivilianState.RESCUED)
	rescued.emit(civilian_id, rescuer_player_index, rescue_score)
	return true


func confirm_visible_loss(reason: StringName) -> bool:
	if not is_rescuable() or reason not in VISIBLE_LOSS_REASONS:
		return false
	_set_civilian_state(CivilianState.LOST)
	civilian_lost.emit(civilian_id, reason)
	return true


func is_rescuable() -> bool:
	return civilian_state in [CivilianState.SAFE, CivilianState.ENDANGERED]


func _set_civilian_state(value: CivilianState) -> void:
	if civilian_state == value:
		return
	civilian_state = value
	civilian_state_changed.emit(civilian_state)
