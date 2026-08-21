class_name DialogueTimeline
extends Node

signal timeline_started
signal line_started(speaker: StringName, text: String, duration: float, line_index: int)
signal line_finished(line_index: int)
signal cue_reached(cue_id: StringName, payload: Dictionary)
signal choice_requested(line_index: int, choices: Array)
signal choice_selected(line_index: int, choice_index: int, choice: Dictionary)
signal timeline_finished

@export_category("Timeline")
@export var entries: Array[Dictionary] = []
@export var process_automatically: bool = true
@export_range(0.1, 60.0, 0.1) var default_line_duration: float = 3.0

var current_index: int = -1
var remaining: float = 0.0
var playing: bool = false
var paused: bool = false
var waiting_for_choice: bool = false


func _ready() -> void:
	set_process(process_automatically)


func _process(delta: float) -> void:
	advance(delta)


func play(timeline_entries: Array[Dictionary] = [], from_index: int = 0) -> void:
	if not timeline_entries.is_empty():
		entries = timeline_entries.duplicate(true)
	current_index = clampi(from_index, 0, entries.size()) - 1
	remaining = 0.0
	paused = false
	waiting_for_choice = false
	playing = true
	timeline_started.emit()
	_begin_next_entry()


func advance(delta: float) -> void:
	if not playing or paused or waiting_for_choice:
		return
	remaining -= maxf(delta, 0.0)
	var guard := 0
	while playing and not waiting_for_choice and remaining <= 0.0 and guard < 128:
		if current_index >= 0:
			line_finished.emit(current_index)
		_begin_next_entry()
		guard += 1


func skip_current() -> void:
	if playing and not waiting_for_choice:
		remaining = 0.0


func choose(choice_index: int) -> bool:
	if not playing or not waiting_for_choice or current_index < 0:
		return false
	var choices := entries[current_index].get("choices", []) as Array
	if choice_index < 0 or choice_index >= choices.size():
		return false
	var value: Variant = choices[choice_index]
	var choice: Dictionary = value.duplicate(true) if value is Dictionary else {"text": str(value)}
	choice_selected.emit(current_index, choice_index, choice)
	waiting_for_choice = false
	if choice.has("next_index"):
		current_index = clampi(int(choice.next_index), 0, entries.size()) - 1
	_begin_next_entry()
	return true


func set_paused(value: bool) -> void:
	paused = value


func stop(emit_finished: bool = false) -> void:
	playing = false
	paused = false
	waiting_for_choice = false
	if emit_finished:
		timeline_finished.emit()


func current_entry() -> Dictionary:
	if current_index < 0 or current_index >= entries.size():
		return {}
	return entries[current_index]


func _begin_next_entry() -> void:
	current_index += 1
	if current_index >= entries.size():
		playing = false
		timeline_finished.emit()
		return
	var entry := entries[current_index]
	var speaker := StringName(str(entry.get("speaker", &"")))
	var text := str(entry.get("text", ""))
	remaining = maxf(0.01, float(entry.get("duration", default_line_duration)))
	line_started.emit(speaker, text, remaining, current_index)
	if entry.has("cue"):
		cue_reached.emit(StringName(str(entry.cue)), entry.duplicate(true))
	var choices := entry.get("choices", []) as Array
	if not choices.is_empty():
		waiting_for_choice = true
		choice_requested.emit(current_index, choices.duplicate(true))
