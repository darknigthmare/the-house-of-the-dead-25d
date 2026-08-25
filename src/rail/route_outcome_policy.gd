class_name RouteOutcomePolicy
extends RefCounted


static func branch_succeeded(
	node_data: Dictionary,
	civilian_success: bool,
	destroyed_breakable_id: String
) -> bool:
	if not node_data.has("breakable"):
		return civilian_success
	var breakable := node_data.get("breakable", {}) as Dictionary
	var expected_id := str(breakable.get("asset", ""))
	return (
		not expected_id.is_empty()
		and destroyed_breakable_id == expected_id
	)
