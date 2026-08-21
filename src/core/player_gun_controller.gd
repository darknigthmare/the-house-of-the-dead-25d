extends RefCounted
class_name PlayerGunController

## Per-player trigger facade over a shared AmmoController.

signal aim_changed(player_index: int, screen_position: Vector2)
signal shot_requested(player_index: int, screen_position: Vector2)
signal dry_fire(player_index: int)
signal reload_requested(player_index: int)

const Rules := preload("res://src/core/arcade_rule_set.gd")
const AmmoControllerType := preload("res://src/core/ammo_controller.gd")

var player_index: int = 0
var enabled: bool = true
var aim_position: Vector2 = Vector2.ZERO
var ammo_controller: AmmoControllerType


func _init(index: int = 0, shared_ammo_controller: AmmoControllerType = null) -> void:
	player_index = clampi(index, 0, Rules.PLAYER_COUNT - 1)
	ammo_controller = shared_ammo_controller if shared_ammo_controller != null else AmmoControllerType.new()


func set_enabled(value: bool) -> void:
	enabled = value


func set_aim_position(screen_position: Vector2) -> void:
	aim_position = screen_position
	aim_changed.emit(player_index, aim_position)


func fire(screen_position: Vector2 = aim_position) -> bool:
	if not enabled:
		return false
	set_aim_position(screen_position)
	if not ammo_controller.try_fire(player_index):
		dry_fire.emit(player_index)
		return false
	shot_requested.emit(player_index, aim_position)
	return true


func reload() -> int:
	if not enabled:
		return ammo_controller.get_ammo(player_index)
	var current_ammo: int = ammo_controller.reload(player_index)
	reload_requested.emit(player_index)
	return current_ammo


func get_ammo() -> int:
	return ammo_controller.get_ammo(player_index)
