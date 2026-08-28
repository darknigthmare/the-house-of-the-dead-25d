class_name EnvironmentSceneLifecycle
extends RefCounted


static func clear_immediately(root: Node) -> int:
	if root == null or not is_instance_valid(root):
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
