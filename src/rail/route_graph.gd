class_name RouteGraph
extends Resource

@export var entry_segment_id: StringName
@export var connections: Array[Dictionary] = []


func add_connection(
		from_id: StringName,
		to_id: StringName,
		conditions: Array[RouteCondition] = [],
		priority: int = 0,
		label: String = ""
) -> void:
	connections.append({
		"from": from_id,
		"to": to_id,
		"conditions": conditions.duplicate(),
		"priority": priority,
		"label": label,
	})
	emit_changed()


func remove_connections_from(from_id: StringName) -> int:
	var removed := 0
	for index in range(connections.size() - 1, -1, -1):
		if _as_id(connections[index].get("from", &"")) == from_id:
			connections.remove_at(index)
			removed += 1
	if removed > 0:
		emit_changed()
	return removed


func get_connections_from(from_id: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection in connections:
		if _as_id(connection.get("from", &"")) == from_id:
			result.append(connection)
	return result


func get_available_connections(from_id: StringName, context: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for connection in get_connections_from(from_id):
		if conditions_match(connection, context):
			result.append(connection)
	result.sort_custom(func(left: Dictionary, right: Dictionary) -> bool:
		return int(left.get("priority", 0)) > int(right.get("priority", 0))
	)
	return result


func resolve_next(from_id: StringName, context: Dictionary) -> StringName:
	var available := get_available_connections(from_id, context)
	if available.is_empty():
		return &""
	return _as_id(available[0].get("to", &""))


func conditions_match(connection: Dictionary, context: Dictionary) -> bool:
	for condition_value in connection.get("conditions", []) as Array:
		if condition_value is RouteCondition and not (condition_value as RouteCondition).evaluate(context):
			return false
	return true


func validate(known_segment_ids: Array[StringName]) -> PackedStringArray:
	var issues := PackedStringArray()
	if entry_segment_id != &"" and not known_segment_ids.has(entry_segment_id):
		issues.append("Unknown entry segment: %s" % entry_segment_id)
	for connection in connections:
		var from_id := _as_id(connection.get("from", &""))
		var to_id := _as_id(connection.get("to", &""))
		if from_id == &"" or to_id == &"":
			issues.append("A route connection has an empty endpoint")
			continue
		if not known_segment_ids.has(from_id):
			issues.append("Unknown route origin: %s" % from_id)
		if not known_segment_ids.has(to_id):
			issues.append("Unknown route destination: %s" % to_id)
	return issues


static func _as_id(value: Variant) -> StringName:
	return StringName(str(value))
