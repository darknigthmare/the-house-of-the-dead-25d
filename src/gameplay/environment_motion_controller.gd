class_name EnvironmentMotionController
extends Node3D

var mode: String = ""
var elapsed: float = 0.0
var target: Node
var base_scale := Vector3.ONE
var base_color := Color.WHITE
var base_energy: float = 1.0
var bounds := Vector3(6.0, 3.0, 13.0)


func configure_target(target_node: Node, animation_mode: String) -> void:
	target = target_node
	mode = animation_mode
	if target is Node3D:
		base_scale = (target as Node3D).scale
	if target is Sprite3D:
		base_color = (target as Sprite3D).modulate
	if target is Light3D:
		base_energy = (target as Light3D).light_energy


func configure_motes(effect_id: String, count: int, effect_bounds: Vector3) -> void:
	mode = "motes:%s" % effect_id
	bounds = effect_bounds
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(effect_id) & 0x7fffffff
	var quad := QuadMesh.new()
	if effect_id == "rain":
		quad.size = Vector2(0.025, 0.34)
	elif effect_id == "distant_bats":
		quad.size = Vector2(0.16, 0.045)
	elif effect_id == "wind":
		quad.size = Vector2(0.11, 0.025)
	else:
		quad.size = Vector2(0.075, 0.075)
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_color = _mote_color(effect_id)
	quad.material = material
	for mote_index in count:
		var mote := MeshInstance3D.new()
		mote.name = "Mote_%02d" % mote_index
		mote.mesh = quad
		mote.position = Vector3(
			rng.randf_range(-bounds.x, bounds.x),
			rng.randf_range(-bounds.y, bounds.y),
			rng.randf_range(-bounds.z, bounds.z)
		)
		mote.set_meta("velocity", _mote_velocity(effect_id, rng))
		mote.set_meta("phase", rng.randf_range(0.0, TAU))
		add_child(mote)


func _process(delta: float) -> void:
	elapsed += delta
	if mode.begins_with("motes:"):
		_update_motes(delta)
		return
	if not is_instance_valid(target):
		return
	match mode:
		"frame_toggle", "flicker":
			if target is Sprite3D:
				var sprite := target as Sprite3D
				if sprite.hframes > 1:
					sprite.frame = int(elapsed * (7.0 if mode == "flicker" else 3.5)) % sprite.hframes
				if mode == "flicker":
					sprite.modulate = base_color * (0.84 + sin(elapsed * 13.0) * 0.12)
		"pulse":
			if target is Node3D:
				(target as Node3D).scale = base_scale * (1.0 + sin(elapsed * 2.7) * 0.025)
			if target is Sprite3D:
				var sprite := target as Sprite3D
				if sprite.hframes > 1:
					sprite.frame = int(elapsed * 2.0) % sprite.hframes
		"lightning", "alarm", "sconce":
			if target is Light3D:
				var light := target as Light3D
				var wave := sin(elapsed * (18.0 if mode == "alarm" else 7.0))
				light.light_energy = base_energy * (0.52 + maxf(0.0, wave) * 0.62)


func _update_motes(delta: float) -> void:
	var effect_id := mode.trim_prefix("motes:")
	for child in get_children():
		var mote := child as Node3D
		if mote == null:
			continue
		var velocity := mote.get_meta("velocity", Vector3.ZERO) as Vector3
		mote.position += velocity * delta
		if effect_id in ["dust", "web_drift", "embers"]:
			mote.position.x += sin(elapsed * 1.5 + float(mote.get_meta("phase", 0.0))) * delta * 0.08
		if effect_id == "distant_bats":
			var flap := 0.35 + absf(sin(elapsed * 8.0 + float(mote.get_meta("phase", 0.0)))) * 0.95
			mote.scale = Vector3(1.0, flap, 1.0)
		if mote.position.y < -bounds.y:
			mote.position.y = bounds.y
		elif mote.position.y > bounds.y:
			mote.position.y = -bounds.y
		if absf(mote.position.x) > bounds.x:
			mote.position.x = -signf(mote.position.x) * bounds.x
		if absf(mote.position.z) > bounds.z:
			mote.position.z = -signf(mote.position.z) * bounds.z


func _mote_color(effect_id: String) -> Color:
	match effect_id:
		"rain":
			return Color(0.58, 0.69, 0.76, 0.38)
		"steam", "mist":
			return Color(0.63, 0.78, 0.73, 0.2)
		"embers":
			return Color(1.0, 0.3, 0.08, 0.72)
		"web_drift":
			return Color(0.78, 0.84, 0.81, 0.34)
		"wind":
			return Color(0.63, 0.7, 0.75, 0.16)
		"distant_bats":
			return Color(0.025, 0.03, 0.045, 0.78)
		_:
			return Color(0.72, 0.65, 0.52, 0.24)


func _mote_velocity(effect_id: String, rng: RandomNumberGenerator) -> Vector3:
	match effect_id:
		"rain":
			return Vector3(rng.randf_range(-0.18, 0.04), rng.randf_range(-6.8, -5.2), rng.randf_range(-0.12, 0.12))
		"steam", "mist":
			return Vector3(rng.randf_range(-0.08, 0.08), rng.randf_range(0.18, 0.5), rng.randf_range(-0.05, 0.05))
		"embers":
			return Vector3(rng.randf_range(-0.12, 0.12), rng.randf_range(0.35, 0.9), rng.randf_range(-0.08, 0.08))
		"web_drift":
			return Vector3(rng.randf_range(-0.12, 0.12), rng.randf_range(-0.05, 0.12), rng.randf_range(-0.04, 0.04))
		"wind":
			return Vector3(rng.randf_range(0.9, 1.8), rng.randf_range(-0.04, 0.07), rng.randf_range(-0.08, 0.08))
		"distant_bats":
			return Vector3(rng.randf_range(0.45, 1.05), rng.randf_range(-0.05, 0.12), rng.randf_range(-0.04, 0.04))
		_:
			return Vector3(rng.randf_range(-0.05, 0.05), rng.randf_range(-0.03, 0.06), rng.randf_range(-0.03, 0.03))
