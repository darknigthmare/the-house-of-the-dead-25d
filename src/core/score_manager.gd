extends RefCounted
class_name ScoreManager

## Applies the arcade score table while keeping P1 and P2 totals independent.

signal score_changed(player_index: int, before: int, after: int, source: StringName)

const Rules := preload("res://src/core/arcade_rule_set.gd")

var _scores: Array[int] = []


func _init(player_count: int = Rules.PLAYER_COUNT) -> void:
	_scores.resize(maxi(1, player_count))
	reset_all()


func player_count() -> int:
	return _scores.size()


func get_score(player_index: int) -> int:
	return _scores[player_index] if _is_valid_player(player_index) else 0


func add_points(player_index: int, points: int, source: StringName = &"manual") -> int:
	if not _is_valid_player(player_index):
		return 0
	var before: int = _scores[player_index]
	_scores[player_index] = maxi(0, before + points)
	score_changed.emit(player_index, before, _scores[player_index], source)
	return _scores[player_index]


func apply_event(player_index: int, event_name: StringName) -> int:
	return add_points(player_index, Rules.score_for(event_name), event_name)


func combined_score() -> int:
	var total: int = 0
	for score: int in _scores:
		total += score
	return total


func reset_player(player_index: int) -> bool:
	if not _is_valid_player(player_index):
		return false
	_scores[player_index] = 0
	return true


func reset_all() -> void:
	for player_index: int in _scores.size():
		_scores[player_index] = 0


func snapshot() -> Array[int]:
	return _scores.duplicate()


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < _scores.size()
