extends "res://src/gameplay/gameplay_runtime_presentation.gd"


func _add_backdrop(style: String) -> void:
	var path := str(environment_scene_profile.get("backdrop", ""))
	if path.is_empty() and style in ["garden", "roof"]:
		path = "res://assets/environments/mansion-exterior.png"
	elif path.is_empty() and style == "laboratory":
		path = "res://assets/environments/curien-laboratory.png"
	elif path.is_empty() and style == "sewer":
		path = "res://assets/environments/underground-tunnel.png"
	elif path.is_empty():
		path = "res://assets/environments/mansion-hall.png"
	var quad := MeshInstance3D.new()
	quad.name = "PaintedDepthBackdrop"
	var mesh := QuadMesh.new()
	mesh.size = Vector2(20.0, 11.25)
	quad.mesh = mesh
	quad.position = Vector3(0.0, 4.2, -30.0)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_texture = load(path) as Texture2D
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(0.72, 0.76, 0.8)
	quad.material_override = material
	world_root.add_child(quad)
