class_name EncounterDirector
extends Node

signal encounter_started(encounter_id: StringName)
signal spawn_requested(spawn_definition: Dictionary)
signal encounter_cleared(encounter_id: StringName)
signal encounter_stopped(encounter_id: StringName)

@export_category("Encounter Data")
@export var encounters: Array[Dictionary] = []
@export var process_automatically: bool = true

var current_encounter_id: StringName
var elapsed: float = 0.0
var running: bool = false
var _scheduled_spawns: Array[Dictionary] = []
var _spawn_cursor: int = 0
var _active_actor_ids: Dictionary = {}
var _minimum_duration: float = 0.0


func _ready() -> void:
	set_process(process_automatically)


func _process(delta: float) -> void:
	advance(delta)


func start_encounter(encounter_id: StringName) -> bool:
	var definition := get_encounter(encounter_id)
	if definition.is_empty():
		return false
	stop_encounter(false)
	current_encounter_id = encounter_id
	elapsed = 0.0
	_spawn_cursor = 0
	_active_actor_ids.clear()
	_minimum_duration = maxf(0.0, float(definition.get("minimum_duration", 0.0)))
	_scheduled_spawns.clear()
	for spawn_value in definition.get("spawns", []) as Array:
		if spawn_value is Dictionary:
			_scheduled_spawns.append((spawn_value as Dictionary).duplicate(true))
	_scheduled_spawns.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return float(left.get("delay", 0.0)) < float(right.get("delay", 0.0))
	)
	running = true
	encounter_started.emit(current_encounter_id)
	return true


func advance(delta: float) -> void:
	if not running:
		return
	elapsed += maxf(delta, 0.0)
	while _spawn_cursor < _scheduled_spawns.size():
		var spawn := _scheduled_spawns[_spawn_cursor]
		if elapsed < float(spawn.get("delay", 0.0)):
			break
		_spawn_cursor += 1
		spawn_requested.emit(spawn.duplicate(true))
	_prune_actors()
	if _spawn_cursor >= _scheduled_spawns.size() and _active_actor_ids.is_empty() and elapsed >= _minimum_duration:
		var completed_id := current_encounter_id
		running = false
		encounter_cleared.emit(completed_id)


func register_spawned_actor(actor: Node) -> void:
	if actor == null:
		return
	var instance_id := actor.get_instance_id()
	if _active_actor_ids.has(instance_id):
		return
	_active_actor_ids[instance_id] = weakref(actor)
	actor.tree_exited.connect(_on_actor_tree_exited.bind(instance_id), CONNECT_ONE_SHOT)


func notify_actor_defeated(actor: Node) -> void:
	if actor != null:
		_active_actor_ids.erase(actor.get_instance_id())


func stop_encounter(emit_signal: bool = true) -> void:
	if not running:
		return
	var stopped_id := current_encounter_id
	running = false
	_scheduled_spawns.clear()
	_active_actor_ids.clear()
	if emit_signal:
		encounter_stopped.emit(stopped_id)


func get_encounter(encounter_id: StringName) -> Dictionary:
	for definition in encounters:
		if StringName(str(definition.get("id", &""))) == encounter_id:
			return definition
	return {}


func active_actor_count() -> int:
	_prune_actors()
	return _active_actor_ids.size()


func _on_actor_tree_exited(instance_id: int) -> void:
	_active_actor_ids.erase(instance_id)


func _prune_actors() -> void:
	for instance_id in _active_actor_ids.keys():
		var reference := _active_actor_ids[instance_id] as WeakRef
		if reference == null or reference.get_ref() == null:
			_active_actor_ids.erase(instance_id)
