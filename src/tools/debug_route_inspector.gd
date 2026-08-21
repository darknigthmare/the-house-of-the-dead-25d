@tool
class_name DebugRouteInspector
extends PanelContainer

signal route_selected(destination_id: StringName)

@export_category("Inspection")
@export var route_graph: RouteGraph:
	set(value):
		route_graph = value
		refresh()
@export var current_segment_id: StringName:
	set(value):
		current_segment_id = value
		refresh()
@export_multiline var context_json: String = "{}":
	set(value):
		context_json = value
		refresh()
@export var show_only_available: bool = false:
	set(value):
		show_only_available = value
		refresh()

var _label: RichTextLabel


func _ready() -> void:
	_ensure_ui()
	refresh()


func refresh() -> void:
	if not is_inside_tree():
		return
	_ensure_ui()
	_label.text = build_report()


func build_report() -> String:
	if route_graph == null:
		return "[b]Route Inspector[/b]\nNo RouteGraph assigned."
	var context := parse_context()
	var lines := PackedStringArray([
		"[b]Route Inspector[/b]",
		"Current: [code]%s[/code]" % current_segment_id,
		"Context keys: %d" % context.size(),
		"",
	])
	var connections := route_graph.get_connections_from(current_segment_id)
	if connections.is_empty():
		lines.append("No outgoing route.")
	for connection in connections:
		var available := route_graph.conditions_match(connection, context)
		if show_only_available and not available:
			continue
		var marker := "[color=7ee787]OPEN[/color]" if available else "[color=ff7b72]LOCKED[/color]"
		lines.append("%s  -> [code]%s[/code]  priority %d" % [marker, connection.get("to", ""), int(connection.get("priority", 0))])
		for condition_value in connection.get("conditions", []) as Array:
			if condition_value is RouteCondition:
				lines.append("    - %s" % (condition_value as RouteCondition).describe())
	return "\n".join(lines)


func parse_context() -> Dictionary:
	var parsed: Variant = JSON.parse_string(context_json)
	return parsed as Dictionary if parsed is Dictionary else {}


func select_destination(destination_id: StringName) -> bool:
	if route_graph == null:
		return false
	for connection in route_graph.get_available_connections(current_segment_id, parse_context()):
		if StringName(str(connection.get("to", &""))) == destination_id:
			route_selected.emit(destination_id)
			return true
	return false


func _ensure_ui() -> void:
	if _label != null:
		return
	_label = RichTextLabel.new()
	_label.name = "RouteReport"
	_label.bbcode_enabled = true
	_label.fit_content = true
	_label.custom_minimum_size = Vector2(360.0, 180.0)
	add_child(_label)
