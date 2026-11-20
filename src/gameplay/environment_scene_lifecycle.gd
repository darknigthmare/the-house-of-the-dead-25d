class_name EnvironmentSceneLifecycle
extends RefCounted


# A caller may repeat cleanup with a handle to an already freed scene root.
# Godot rejects a freed value at a typed Node parameter before this guard can run.
static func clear_immediately(root: Variant) -> int:
	if typeof(root) != TYPE_OBJECT or not is_instance_valid(root) or not root is Node:
		return 0
	var removed_count := 0
	for child in root.get_children():
		# The procedural environment is replaced as one atomic scene chunk.
		# Immediate detach-and-free prevents duplicate WorldEnvironments, stale
		# colliders, prop lookups and detached queue_free orphans from crossing
		# a sequence boundary.
		root.remove_child(child)
		child.free()
		removed_count += 1
	return removed_count
