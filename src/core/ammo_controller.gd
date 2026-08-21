extends RefCounted
class_name AmmoController

## Owns one independent magazine for each local player.

signal ammo_changed(player_index: int, before: int, after: int)
signal shot_fired(player_index: int, remaining_ammo: int)
signal empty_triggered(player_index: int)
signal reloaded(player_index: int, previous_ammo: int, current_ammo: int)

const Rules := preload("res://src/core/arcade_rule_set.gd")

var magazine_size: int = Rules.MAGAZINE_SIZE
var _ammo: Array[int] = []


func _init(player_count: int = Rules.PLAYER_COUNT, requested_magazine_size: int = Rules.MAGAZINE_SIZE) -> void:
	magazine_size = maxi(1, requested_magazine_size)
	_ammo.resize(maxi(1, player_count))
	reset_all()


func player_count() -> int:
	return _ammo.size()


func get_ammo(player_index: int) -> int:
	return _ammo[player_index] if _is_valid_player(player_index) else 0


func can_fire(player_index: int) -> bool:
	return _is_valid_player(player_index) and _ammo[player_index] > 0


func try_fire(player_index: int) -> bool:
	if not _is_valid_player(player_index):
		return false
	if _ammo[player_index] <= 0:
		empty_triggered.emit(player_index)
		return false
	var before: int = _ammo[player_index]
	_ammo[player_index] = before - 1
	ammo_changed.emit(player_index, before, _ammo[player_index])
	shot_fired.emit(player_index, _ammo[player_index])
	return true


func reload(player_index: int) -> int:
	if not _is_valid_player(player_index):
		return 0
	var before: int = _ammo[player_index]
	_ammo[player_index] = magazine_size
	ammo_changed.emit(player_index, before, _ammo[player_index])
	reloaded.emit(player_index, before, _ammo[player_index])
	return _ammo[player_index]


func reset_player(player_index: int) -> bool:
	if not _is_valid_player(player_index):
		return false
	_ammo[player_index] = magazine_size
	return true


func reset_all() -> void:
	for player_index: int in _ammo.size():
		_ammo[player_index] = magazine_size


func snapshot() -> Array[int]:
	return _ammo.duplicate()


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < _ammo.size()
