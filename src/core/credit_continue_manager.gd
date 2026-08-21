extends RefCounted
class_name CreditContinueManager

## Consumes credits and counts continues independently for both players.

signal credits_changed(player_index: int, before: int, after: int)
signal continue_used(player_index: int, continue_count: int, remaining_credits: int)
signal continue_denied(player_index: int)

const Rules := preload("res://src/core/arcade_rule_set.gd")

var starting_credits: int = Rules.STARTING_CREDITS
var _credits: Array[int] = []
var _continues: Array[int] = []


func _init(player_count: int = Rules.PLAYER_COUNT, requested_starting_credits: int = Rules.STARTING_CREDITS) -> void:
	starting_credits = maxi(0, requested_starting_credits)
	var count: int = maxi(1, player_count)
	_credits.resize(count)
	_continues.resize(count)
	reset_all()


func player_count() -> int:
	return _credits.size()


func get_credits(player_index: int) -> int:
	return _credits[player_index] if _is_valid_player(player_index) else 0


func get_continue_count(player_index: int) -> int:
	return _continues[player_index] if _is_valid_player(player_index) else 0


func can_continue(player_index: int) -> bool:
	return _is_valid_player(player_index) and _credits[player_index] > 0


func use_continue(player_index: int) -> bool:
	if not can_continue(player_index):
		if _is_valid_player(player_index):
			continue_denied.emit(player_index)
		return false
	var before: int = _credits[player_index]
	_credits[player_index] = before - 1
	_continues[player_index] += 1
	credits_changed.emit(player_index, before, _credits[player_index])
	continue_used.emit(player_index, _continues[player_index], _credits[player_index])
	return true


func add_credits(player_index: int, amount: int = 1) -> int:
	if not _is_valid_player(player_index) or amount <= 0:
		return get_credits(player_index)
	var before: int = _credits[player_index]
	_credits[player_index] += amount
	credits_changed.emit(player_index, before, _credits[player_index])
	return _credits[player_index]


func reset_player(player_index: int) -> bool:
	if not _is_valid_player(player_index):
		return false
	_credits[player_index] = starting_credits
	_continues[player_index] = 0
	return true


func reset_all() -> void:
	for player_index: int in _credits.size():
		_credits[player_index] = starting_credits
		_continues[player_index] = 0


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < _credits.size()
