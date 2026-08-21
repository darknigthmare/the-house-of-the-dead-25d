extends Node
class_name PlayerInputRouter

## Converts project actions or raw-light-gun packets into player-indexed intent.

signal aim_requested(player_index: int, screen_position: Vector2)
signal fire_requested(player_index: int, screen_position: Vector2)
signal reload_requested(player_index: int)
signal join_requested(player_index: int)

const Rules := preload("res://src/core/arcade_rule_set.gd")
const FIRE_ACTIONS := [&"p1_fire", &"p2_fire"]
const RELOAD_ACTIONS := [&"p1_reload", &"p2_reload"]
const JOIN_ACTIONS := [&"p1_join", &"p2_join"]

var _aim_positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var _player_enabled: Array[bool] = [true, true]


func _unhandled_input(event: InputEvent) -> void:
	if route_event(event):
		get_viewport().set_input_as_handled()


func set_player_enabled(player_index: int, value: bool) -> bool:
	if not _is_valid_player(player_index):
		return false
	_player_enabled[player_index] = value
	return true


func is_player_enabled(player_index: int) -> bool:
	return _is_valid_player(player_index) and _player_enabled[player_index]


func set_aim_position(player_index: int, screen_position: Vector2) -> bool:
	if not _is_valid_player(player_index):
		return false
	_aim_positions[player_index] = screen_position
	aim_requested.emit(player_index, screen_position)
	return true


func get_aim_position(player_index: int) -> Vector2:
	return _aim_positions[player_index] if _is_valid_player(player_index) else Vector2.ZERO


func route_event(event: InputEvent) -> bool:
	var screen_position: Vector2 = _event_position(event)
	for player_index: int in Rules.PLAYER_COUNT:
		if event.is_action_pressed(JOIN_ACTIONS[player_index]):
			join_requested.emit(player_index)
			return true
		if not _player_enabled[player_index]:
			continue
		if event.is_action_pressed(FIRE_ACTIONS[player_index]):
			if screen_position != Vector2.INF:
				set_aim_position(player_index, screen_position)
			fire_requested.emit(player_index, _aim_positions[player_index])
			return true
		if event.is_action_pressed(RELOAD_ACTIONS[player_index]):
			reload_requested.emit(player_index)
			return true
	return false


func route_action(action_name: StringName, screen_position: Vector2 = Vector2.ZERO) -> bool:
	for player_index: int in Rules.PLAYER_COUNT:
		if action_name == JOIN_ACTIONS[player_index]:
			join_requested.emit(player_index)
			return true
		if not _player_enabled[player_index]:
			continue
		if action_name == FIRE_ACTIONS[player_index]:
			set_aim_position(player_index, screen_position)
			fire_requested.emit(player_index, screen_position)
			return true
		if action_name == RELOAD_ACTIONS[player_index]:
			reload_requested.emit(player_index)
			return true
	return false


func route_light_gun_packet(packet: Dictionary) -> bool:
	if not bool(packet.get("handled", false)):
		return false
	var player_index: int = int(packet.get("player_index", -1))
	if not _is_valid_player(player_index) or not _player_enabled[player_index]:
		return false
	var action_name: StringName = StringName(packet.get("action", ""))
	var position_value: Vector2 = packet.get("position", _aim_positions[player_index]) as Vector2
	match action_name:
		&"aim":
			return set_aim_position(player_index, position_value)
		&"fire":
			set_aim_position(player_index, position_value)
			fire_requested.emit(player_index, position_value)
			return true
		&"reload":
			reload_requested.emit(player_index)
			return true
	return false


func _event_position(event: InputEvent) -> Vector2:
	if event is InputEventMouse:
		return (event as InputEventMouse).position
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).position
	return Vector2.INF


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < Rules.PLAYER_COUNT
