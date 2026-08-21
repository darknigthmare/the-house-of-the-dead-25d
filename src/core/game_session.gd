extends Node

signal session_started(mode: String, player_count: int)
signal session_ended(summary: Dictionary)
signal player_joined(player_index: int)
signal score_changed(player_index: int, before: int, after: int, source: String)

const MAGAZINE_SIZE := 6

var mode: String = "arcade"
var active: bool = false
var chapter: int = 1
var route_flags: Dictionary = {}
var scientists_saved: Dictionary = {}
var players: Array[Dictionary] = []


func _ready() -> void:
	reset()


func reset() -> void:
	active = false
	chapter = 1
	route_flags.clear()
	scientists_saved.clear()
	players = [_new_player(true), _new_player(false)]


func start(new_mode: String = "arcade", player_count: int = 1) -> void:
	reset()
	mode = new_mode
	active = true
	players[1].active = player_count >= 2
	session_started.emit(mode, player_count)


func join_player(player_index: int) -> bool:
	if player_index < 0 or player_index >= players.size():
		return false
	players[player_index].active = true
	player_joined.emit(player_index)
	return true


func add_score(player_index: int, value: int, source: String) -> int:
	if player_index < 0 or player_index >= players.size():
		return 0
	var before := int(players[player_index].score)
	players[player_index].score = maxi(0, before + value)
	score_changed.emit(player_index, before, int(players[player_index].score), source)
	return int(players[player_index].score)


func combined_score() -> int:
	var result := 0
	for player in players:
		result += int(player.score)
	return result


func finish() -> Dictionary:
	active = false
	var summary := {
		"mode": mode,
		"chapter": chapter,
		"combined_score": combined_score(),
		"players": players.duplicate(true),
		"routes": route_flags.duplicate(true),
		"scientists": scientists_saved.duplicate(true)
	}
	session_ended.emit(summary)
	return summary


func _new_player(is_active: bool) -> Dictionary:
	return {"active": is_active, "ammo": MAGAZINE_SIZE, "lives": 3, "score": 0, "credits": 3, "continues": 0}
