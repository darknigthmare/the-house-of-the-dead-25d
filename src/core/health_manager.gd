extends RefCounted
class_name HealthManager

## Tracks arcade lives, including the hard five-life pickup cap.

signal lives_changed(player_index: int, before: int, after: int)
signal player_depleted(player_index: int)

const Rules := preload("res://src/core/arcade_rule_set.gd")

var starting_lives: int = Rules.STARTING_LIVES
var maximum_lives: int = Rules.MAX_LIVES
var _lives: Array[int] = []


func _init(
	player_count: int = Rules.PLAYER_COUNT,
	requested_starting_lives: int = Rules.STARTING_LIVES,
	requested_maximum_lives: int = Rules.MAX_LIVES
) -> void:
	maximum_lives = maxi(1, requested_maximum_lives)
	starting_lives = clampi(requested_starting_lives, 0, maximum_lives)
	_lives.resize(maxi(1, player_count))
	reset_all()


func player_count() -> int:
	return _lives.size()


func get_lives(player_index: int) -> int:
	return _lives[player_index] if _is_valid_player(player_index) else 0


func is_alive(player_index: int) -> bool:
	return get_lives(player_index) > 0


func take_damage(player_index: int, amount: int = 1) -> int:
	if not _is_valid_player(player_index) or amount <= 0:
		return get_lives(player_index)
	var before: int = _lives[player_index]
	_lives[player_index] = maxi(0, before - amount)
	lives_changed.emit(player_index, before, _lives[player_index])
	if before > 0 and _lives[player_index] == 0:
		player_depleted.emit(player_index)
	return _lives[player_index]


func add_life(player_index: int, amount: int = 1) -> int:
	if not _is_valid_player(player_index) or amount <= 0:
		return get_lives(player_index)
	var before: int = _lives[player_index]
	_lives[player_index] = mini(maximum_lives, before + amount)
	lives_changed.emit(player_index, before, _lives[player_index])
	return _lives[player_index]


func restore_starting_lives(player_index: int) -> int:
	if not _is_valid_player(player_index):
		return 0
	var before: int = _lives[player_index]
	_lives[player_index] = starting_lives
	lives_changed.emit(player_index, before, _lives[player_index])
	return _lives[player_index]


func reset_all() -> void:
	for player_index: int in _lives.size():
		_lives[player_index] = starting_lives


func snapshot() -> Array[int]:
	return _lives.duplicate()


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < _lives.size()
