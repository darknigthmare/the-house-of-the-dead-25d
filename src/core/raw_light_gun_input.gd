extends RefCounted
class_name RawLightGunInput

## Preserves per-device coordinates so two raw-input light guns never share
## aim state. Off-screen trigger presses become arcade reload requests.

signal device_registered(player_index: int, device_id: int)
signal raw_packet(packet: Dictionary)

const Rules := preload("res://src/core/arcade_rule_set.gd")

var _device_ids: Array[int] = [-1, -1]
var _positions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]


func register_device(player_index: int, device_id: int) -> bool:
	if not _is_valid_player(player_index) or device_id < 0:
		return false
	for index: int in Rules.PLAYER_COUNT:
		if index != player_index and _device_ids[index] == device_id:
			_device_ids[index] = -1
	_device_ids[player_index] = device_id
	device_registered.emit(player_index, device_id)
	return true


func unregister_player(player_index: int) -> bool:
	if not _is_valid_player(player_index):
		return false
	_device_ids[player_index] = -1
	return true


func get_device_id(player_index: int) -> int:
	return _device_ids[player_index] if _is_valid_player(player_index) else -1


func get_position(player_index: int) -> Vector2:
	return _positions[player_index] if _is_valid_player(player_index) else Vector2.ZERO


func player_for_device(device_id: int) -> int:
	return _device_ids.find(device_id)


func ingest(event: InputEvent, play_rect: Rect2) -> Dictionary:
	var player_index: int = player_for_device(event.device)
	if player_index < 0:
		return _packet(false)
	var position_value: Vector2 = _extract_position(event, player_index)
	if position_value != Vector2.INF:
		_positions[player_index] = position_value
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		return _emit_packet(player_index, &"aim", _positions[player_index])
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			return _trigger_packet(player_index, play_rect)
		return _packet(false)
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if not button.pressed:
			return _packet(false)
		if button.button_index == MOUSE_BUTTON_LEFT:
			return _trigger_packet(player_index, play_rect)
		if button.button_index == MOUSE_BUTTON_RIGHT:
			return _emit_packet(player_index, &"reload", _positions[player_index])
	return _packet(false)


func _trigger_packet(player_index: int, play_rect: Rect2) -> Dictionary:
	var action_name: StringName = &"fire" if play_rect.has_point(_positions[player_index]) else &"reload"
	return _emit_packet(player_index, action_name, _positions[player_index])


func _extract_position(event: InputEvent, player_index: int) -> Vector2:
	if event is InputEventMouse:
		return (event as InputEventMouse).position
	if event is InputEventScreenTouch:
		return (event as InputEventScreenTouch).position
	if event is InputEventScreenDrag:
		return (event as InputEventScreenDrag).position
	return _positions[player_index]


func _emit_packet(player_index: int, action_name: StringName, position_value: Vector2) -> Dictionary:
	var packet: Dictionary = {
		"handled": true,
		"player_index": player_index,
		"action": action_name,
		"position": position_value,
	}
	raw_packet.emit(packet)
	return packet


func _packet(handled: bool) -> Dictionary:
	return {
		"handled": handled,
		"player_index": -1,
		"action": StringName(),
		"position": Vector2.ZERO,
	}


func _is_valid_player(player_index: int) -> bool:
	return player_index >= 0 and player_index < Rules.PLAYER_COUNT
