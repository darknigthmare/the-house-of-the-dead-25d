class_name BossController
extends SpriteActor3D

signal phase_changed(phase_index: int, phase_definition: Dictionary)
signal attack_requested(attack_id: StringName, phase_index: int, attack_data: Dictionary)
signal weak_window_changed(is_open: bool, remaining_seconds: float)
signal damage_blocked(hit_zone: StringName, source_peer_id: int)
signal boss_defeated(source_peer_id: int)

@export_category("Boss Phases")
@export var phases: Array[Dictionary] = []
@export var weak_window_required: bool = false
@export_range(0.05, 60.0, 0.05) var default_attack_interval: float = 2.5

var phase_index: int = -1
var attack_timer: float = 0.0
var weak_window_remaining: float = 0.0
var _attack_cursor: int = 0


func _ready() -> void:
	super._ready()
	_refresh_phase(true)
	_reset_attack_timer()


func _process(delta: float) -> void:
	if not is_alive():
		return
	var step := maxf(delta, 0.0)
	if weak_window_remaining > 0.0:
		weak_window_remaining = maxf(0.0, weak_window_remaining - step)
		weak_window_changed.emit(weak_window_remaining > 0.0, weak_window_remaining)
	attack_timer -= step
	if attack_timer <= 0.0:
		_request_next_attack()
		_reset_attack_timer()


func take_damage(amount: float, hit_zone: StringName = &"body", source_peer_id: int = 0) -> bool:
	if not _can_damage_zone(hit_zone):
		damage_blocked.emit(hit_zone, source_peer_id)
		return false
	var phase := get_current_phase()
	var adjusted_damage := amount * maxf(0.0, float(phase.get("damage_multiplier", 1.0)))
	var was_alive := is_alive()
	var accepted := super.take_damage(adjusted_damage, hit_zone, source_peer_id)
	if accepted:
		_refresh_phase(false)
	if accepted and was_alive and not is_alive():
		boss_defeated.emit(source_peer_id)
	return accepted


func open_weak_window(duration_seconds: float) -> void:
	weak_window_remaining = maxf(0.0, duration_seconds)
	weak_window_changed.emit(weak_window_remaining > 0.0, weak_window_remaining)


func close_weak_window() -> void:
	weak_window_remaining = 0.0
	weak_window_changed.emit(false, 0.0)


func get_current_phase() -> Dictionary:
	if phase_index < 0 or phase_index >= phases.size():
		return {}
	return phases[phase_index]


func force_phase(new_phase_index: int) -> bool:
	if new_phase_index < 0 or new_phase_index >= phases.size():
		return false
	phase_index = new_phase_index
	_attack_cursor = 0
	_reset_attack_timer()
	phase_changed.emit(phase_index, get_current_phase().duplicate(true))
	return true


func _refresh_phase(force_emit: bool) -> void:
	if phases.is_empty():
		if phase_index != 0 or force_emit:
			phase_index = 0
			phase_changed.emit(phase_index, {})
		return
	var ratio := health_ratio()
	var resolved_index := 0
	for index in phases.size():
		var threshold := clampf(float(phases[index].get("health_ratio", 1.0)), 0.0, 1.0)
		if ratio <= threshold:
			resolved_index = index
	if resolved_index != phase_index or force_emit:
		phase_index = resolved_index
		_attack_cursor = 0
		_reset_attack_timer()
		phase_changed.emit(phase_index, get_current_phase().duplicate(true))


func _can_damage_zone(hit_zone: StringName) -> bool:
	if weak_window_required and weak_window_remaining <= 0.0:
		return false
	var weak_zones := get_current_phase().get("weak_zones", []) as Array
	if weak_zones.is_empty():
		return true
	for zone_value in weak_zones:
		if StringName(str(zone_value)) == hit_zone:
			return true
	return false


func _request_next_attack() -> void:
	var attacks := get_current_phase().get("attacks", []) as Array
	if attacks.is_empty():
		return
	var attack_value: Variant = attacks[_attack_cursor % attacks.size()]
	_attack_cursor += 1
	var attack_data: Dictionary = attack_value.duplicate(true) if attack_value is Dictionary else {"id": str(attack_value)}
	var attack_id := StringName(str(attack_data.get("id", &"attack")))
	attack_requested.emit(attack_id, phase_index, attack_data)
	if attack_data.has("weak_window"):
		open_weak_window(float(attack_data.weak_window))


func _reset_attack_timer() -> void:
	attack_timer = maxf(0.05, float(get_current_phase().get("attack_interval", default_attack_interval)))
