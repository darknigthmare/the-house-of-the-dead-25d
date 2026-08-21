extends SceneTree


func _initialize() -> void:
	var scripts := [
		"res://src/main.gd",
		"res://src/ui/crosshair_control.gd",
		"res://src/audio/procedural_sfx.gd",
		"res://src/gameplay/gameplay_runtime_base.gd",
		"res://src/gameplay/gameplay_runtime_flow.gd",
		"res://src/gameplay/gameplay_runtime_combat.gd",
		"res://src/gameplay/gameplay_runtime_final.gd",
		"res://src/gameplay/gameplay_runtime_presentation.gd",
		"res://src/gameplay/gameplay_controller.gd"
	]
	var failed := false
	for path in scripts:
		var resource := load(path)
		if resource == null:
			failed = true
			push_error("PARSE FAILED: %s" % path)
		else:
			print("PARSE OK: ", path)
	quit(1 if failed else 0)
