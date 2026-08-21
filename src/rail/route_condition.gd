class_name RouteCondition
extends Resource

enum Comparison {
	ALWAYS,
	EQUALS,
	NOT_EQUALS,
	GREATER_OR_EQUAL,
	LESS_OR_EQUAL,
	IS_TRUE,
	IS_FALSE,
	CONTAINS,
}

@export var context_key: StringName
@export var comparison: Comparison = Comparison.EQUALS
@export var compare_value: Variant = true
@export var invert_result: bool = false


func evaluate(context: Dictionary) -> bool:
	var result := _evaluate_raw(context)
	return not result if invert_result else result


func _evaluate_raw(context: Dictionary) -> bool:
	if comparison == Comparison.ALWAYS:
		return true
	var value: Variant = context.get(context_key, context.get(str(context_key), null))
	match comparison:
		Comparison.EQUALS:
			return value == compare_value
		Comparison.NOT_EQUALS:
			return value != compare_value
		Comparison.GREATER_OR_EQUAL:
			return _is_number(value) and _is_number(compare_value) and float(value) >= float(compare_value)
		Comparison.LESS_OR_EQUAL:
			return _is_number(value) and _is_number(compare_value) and float(value) <= float(compare_value)
		Comparison.IS_TRUE:
			return bool(value)
		Comparison.IS_FALSE:
			return not bool(value)
		Comparison.CONTAINS:
			return _contains(value, compare_value)
	return false


func describe() -> String:
	if comparison == Comparison.ALWAYS:
		return "always"
	return "%s %s %s%s" % [context_key, Comparison.keys()[comparison], compare_value, " (inverted)" if invert_result else ""]


static func _is_number(value: Variant) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT


static func _contains(container: Variant, expected: Variant) -> bool:
	if typeof(container) == TYPE_ARRAY:
		return (container as Array).has(expected)
	if typeof(container) == TYPE_DICTIONARY:
		return (container as Dictionary).has(expected)
	if typeof(container) == TYPE_STRING or typeof(container) == TYPE_STRING_NAME:
		return str(container).contains(str(expected))
	return false
