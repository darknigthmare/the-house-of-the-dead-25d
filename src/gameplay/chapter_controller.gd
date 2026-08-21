class_name ChapterController
extends Node

signal chapter_started(chapter_id: StringName, chapter_data: Dictionary)
signal route_node_entered(node_id: StringName, node_data: Dictionary)
signal objective_changed(objective: String)
signal route_resolved(from_id: StringName, to_id: StringName)
signal chapter_finished(chapter_id: StringName, context: Dictionary)
signal chapter_failed(chapter_id: StringName, reason: StringName)

@export_category("Campaign Data")
@export var chapters: Array[Dictionary] = []
@export var route_graph: RouteGraph

var context: Dictionary = {}
var current_chapter: Dictionary = {}
var current_node: Dictionary = {}
var current_chapter_id: StringName
var current_node_id: StringName
var chapter_active: bool = false


func load_chapters(chapter_data: Array[Dictionary]) -> void:
	chapters = chapter_data.duplicate(true)


func start_chapter(chapter_id: StringName, initial_context: Dictionary = {}) -> bool:
	var chapter := get_chapter(chapter_id)
	if chapter.is_empty():
		return false
	context = initial_context.duplicate(true)
	current_chapter = chapter
	current_chapter_id = chapter_id
	chapter_active = true
	chapter_started.emit(current_chapter_id, current_chapter.duplicate(true))
	var start_id := StringName(str(current_chapter.get("start", route_graph.entry_segment_id if route_graph != null else &"")))
	if start_id == &"":
		finish_chapter()
		return true
	return enter_route_node(start_id)


func start_chapter_by_index(index: int, initial_context: Dictionary = {}) -> bool:
	if index < 0 or index >= chapters.size():
		return false
	return start_chapter(StringName(str(chapters[index].get("id", index))), initial_context)


func enter_route_node(node_id: StringName) -> bool:
	if not chapter_active:
		return false
	var node_data := get_route_node(node_id)
	if node_data.is_empty():
		fail_chapter(&"missing_route_node")
		return false
	current_node_id = node_id
	current_node = node_data
	context[&"current_node"] = current_node_id
	route_node_entered.emit(current_node_id, current_node.duplicate(true))
	objective_changed.emit(str(current_node.get("objective", "")))
	return true


func complete_current_node(outcome: Dictionary = {}) -> StringName:
	if not chapter_active or current_node.is_empty():
		return &""
	context.merge(outcome, true)
	var from_id := current_node_id
	var next_id := _resolve_next_node(outcome)
	route_resolved.emit(from_id, next_id)
	if next_id == &"" or next_id == &"chapter_complete":
		finish_chapter()
	else:
		enter_route_node(next_id)
	return next_id


func set_context_value(key: StringName, value: Variant) -> void:
	context[key] = value


func get_context_value(key: StringName, default_value: Variant = null) -> Variant:
	return context.get(key, context.get(str(key), default_value))


func finish_chapter() -> void:
	if not chapter_active:
		return
	chapter_active = false
	chapter_finished.emit(current_chapter_id, context.duplicate(true))


func fail_chapter(reason: StringName) -> void:
	if not chapter_active:
		return
	chapter_active = false
	chapter_failed.emit(current_chapter_id, reason)


func get_chapter(chapter_id: StringName) -> Dictionary:
	for chapter in chapters:
		if StringName(str(chapter.get("id", &""))) == chapter_id:
			return chapter
	return {}


func get_route_node(node_id: StringName) -> Dictionary:
	for node_value in current_chapter.get("nodes", []) as Array:
		if node_value is Dictionary:
			var node_data := node_value as Dictionary
			if StringName(str(node_data.get("id", &""))) == node_id:
				return node_data
	return {}


func create_checkpoint() -> Dictionary:
	return {
		"chapter_id": current_chapter_id,
		"node_id": current_node_id,
		"context": context.duplicate(true),
		"active": chapter_active,
	}


func restore_checkpoint(checkpoint: Dictionary) -> bool:
	var chapter_id := StringName(str(checkpoint.get("chapter_id", &"")))
	if not start_chapter(chapter_id, checkpoint.get("context", {}) as Dictionary):
		return false
	var node_id := StringName(str(checkpoint.get("node_id", &"")))
	return node_id == &"" or enter_route_node(node_id)


func _resolve_next_node(outcome: Dictionary) -> StringName:
	if current_node.has("next_success"):
		return StringName(str(current_node.get("next_success"))) if bool(outcome.get("success", false)) else StringName(str(current_node.get("next_failure", &"")))
	if route_graph != null:
		var graph_result := route_graph.resolve_next(current_node_id, context)
		if graph_result != &"":
			return graph_result
	return StringName(str(current_node.get("next", &"chapter_complete")))
