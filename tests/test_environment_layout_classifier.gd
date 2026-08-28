extends RefCounted

const ClassifierType := preload("res://src/gameplay/environment_layout_classifier.gd")
const RuntimeCombatType := preload("res://src/gameplay/gameplay_runtime_combat.gd")
const EnvironmentLibraryType := preload("res://src/gameplay/environment_asset_library.gd")
const MANIFEST_PATH := "res://data/assets/environment_manifest.json"


static func collect_checks() -> Array[Dictionary]:
	var checks: Array[Dictionary] = []
	var manifest := _load_manifest()
	var nodes := manifest.get("nodes", {}) as Dictionary
	var observed_layouts: Dictionary = {}
	for node_id_value: Variant in nodes.keys():
		var node_id := str(node_id_value)
		var profile := nodes.get(node_id, {}) as Dictionary
		var layout := str(profile.get("layout", ""))
		observed_layouts[layout] = true
		_add_check(checks, ClassifierType.is_known(layout), true, "campaign layout is explicitly classified: %s" % layout)
	_add_check(checks, nodes.size(), 43, "environment manifest exposes all 43 campaign nodes")
	_add_check(checks, observed_layouts.size(), 33, "campaign nodes reuse only the 33 authored deterministic layouts")
	_add_check(checks, ClassifierType.authored_layout_count(), 33, "layout taxonomy covers exactly the 33 authored layout ids")

	_add_check(checks, ClassifierType.classify("estate_arrival"), ClassifierType.FAMILY_ESTATE, "estate arrival uses exterior geometry")
	_add_check(checks, ClassifierType.classify("front_steps"), ClassifierType.FAMILY_ESTATE, "front steps use exterior geometry")
	_add_check(checks, ClassifierType.classify("library"), ClassifierType.FAMILY_LIBRARY, "library owns its shelf geometry")
	_add_check(checks, ClassifierType.classify("hermit_tunnel"), ClassifierType.FAMILY_HERMIT_TUNNEL, "Hermit owns its web tunnel geometry")
	_add_check(checks, ClassifierType.classify("hangedman_arena"), ClassifierType.FAMILY_ROOF, "Hangedman owns roof geometry")
	_add_check(checks, ClassifierType.classify("magician_arena"), ClassifierType.FAMILY_LABORATORY, "Magician owns laboratory arena geometry")

	for non_lab_boss_layout: String in ["chariot_arena", "hangedman_arena", "hermit_tunnel", "rematch_roof"]:
		_add_check(checks, ClassifierType.is_laboratory(non_lab_boss_layout), false, "non-laboratory boss never receives lab ribs: %s" % non_lab_boss_layout)
	_add_check(checks, ClassifierType.is_laboratory("magician_arena"), true, "Magician arena remains a laboratory")
	_add_check(checks, ClassifierType.is_laboratory("rematch_arena"), true, "Chariot rematch intentionally occurs in the final laboratory")
	_add_check(checks, ClassifierType.classify("invented_arena"), ClassifierType.FAMILY_UNKNOWN, "generic arena substring never implies laboratory")
	var densified_nodes := {
		"underground_passage": ClassifierType.FAMILY_SEWER,
		"raised_bridge": ClassifierType.FAMILY_MANSION,
		"lower_stairs": ClassifierType.FAMILY_SEWER,
		"hermit_battle": ClassifierType.FAMILY_HERMIT_TUNNEL,
		"bonus_room": ClassifierType.FAMILY_LABORATORY,
	}
	for node_id: String in densified_nodes:
		var profile := nodes.get(node_id, {}) as Dictionary
		_add_check(checks, (profile.get("props", []) as Array).size() >= 3, true, "formerly sparse sequence now has at least three individual props: %s" % node_id)
		_add_check(checks, ClassifierType.classify(str(profile.get("layout", ""))), densified_nodes[node_id], "densified sequence keeps its authored geometry family: %s" % node_id)
	_test_geometry_builds(checks, nodes)
	return checks


static func _test_geometry_builds(checks: Array[Dictionary], nodes: Dictionary) -> void:
	var library = EnvironmentLibraryType.new()
	_add_check(checks, library.load_manifest(MANIFEST_PATH), true, "geometry smoke loads the environment material library")
	var runtime = RuntimeCombatType.new()
	runtime.environment_asset_library = library
	runtime.world_root = Node3D.new()
	for node_id_value: Variant in nodes.keys():
		var node_id := str(node_id_value)
		var raw_profile := nodes.get(node_id, {}) as Dictionary
		var style := str(raw_profile.get("style", "mansion"))
		var layout := str(raw_profile.get("layout", ""))
		runtime.environment_scene_profile = library.get_scene_profile(node_id, style)
		runtime._build_environment_layout()
		_add_check(checks, runtime.world_root.get_child_count() > 0, true, "layout builds visible textured geometry: %s" % layout)
		_add_check(checks, runtime.world_root.get_meta("environment_layout_family", ClassifierType.FAMILY_UNKNOWN), ClassifierType.classify(layout), "built layout records its deterministic family: %s" % layout)
		var untextured_meshes := 0
		for child: Node in runtime.world_root.get_children():
			var mesh_instance := child as MeshInstance3D
			if mesh_instance == null:
				continue
			var material := mesh_instance.material_override as StandardMaterial3D
			if material == null or material.albedo_texture == null:
				untextured_meshes += 1
		_add_check(checks, untextured_meshes, 0, "layout never creates a white placeholder mesh: %s" % layout)
		# Runtime rooms always add a base floor and structural side walls before
		# the authored layout. Both navigation contracts are verified below.
		runtime._add_box("Floor", Vector3(0.0, -0.25, -8.0), Vector3(13.0, 0.5, 31.0), Color.BLACK)
		runtime._add_box("LeftWall", Vector3(-6.3, 2.8, -8.0), Vector3(0.45, 6.0, 31.0), Color.BLACK)
		runtime._add_box("RightWall", Vector3(6.3, 2.8, -8.0), Vector3(0.45, 6.0, 31.0), Color.BLACK)
		var blockers: Array[Dictionary] = runtime._environment_floor_blockers()
		_add_check(checks, blockers.size() >= 2, true, "campaign scene exposes structural pursuit blockers: %s" % node_id)
		var has_layout_mesh_blocker := false
		for blocker: Dictionary in blockers:
			if str(blocker.get("source", "")) == "layout_mesh" and (blocker.get("half_extents", Vector2.ZERO) as Vector2).length_squared() > 0.0:
				has_layout_mesh_blocker = true
				break
		_add_check(checks, has_layout_mesh_blocker, true, "scene walls and authored props share collision data: %s" % node_id)
		var walkable_surfaces: Array[Dictionary] = runtime._environment_walkable_surfaces()
		_add_check(checks, walkable_surfaces.size() > 0, true, "campaign scene exposes at least one authored walkable surface: %s" % node_id)
		var has_valid_walkable := false
		for surface: Dictionary in walkable_surfaces:
			var dimensions: Vector3 = surface.get("dimensions", Vector3.ZERO) as Vector3
			if dimensions.x >= 0.5 and dimensions.z >= 0.5:
				has_valid_walkable = true
				break
		_add_check(checks, has_valid_walkable, true, "walkable surface carries a usable footprint: %s" % node_id)
		var lab_ribs_present := runtime.world_root.get_node_or_null("LabRibL_00") != null
		if layout in ["chariot_arena", "hangedman_arena", "hermit_tunnel", "rematch_roof"]:
			_add_check(checks, lab_ribs_present, false, "built non-lab boss space contains no lab ribs: %s" % layout)
		elif layout in ["magician_arena", "rematch_arena"]:
			_add_check(checks, lab_ribs_present, true, "built final-lab boss space contains lab ribs: %s" % layout)
		for child: Node in runtime.world_root.get_children():
			child.free()
	runtime.world_root.free()
	runtime.free()


static func _load_manifest() -> Dictionary:
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	return parsed as Dictionary if parsed is Dictionary else {}


static func _add_check(checks: Array[Dictionary], actual: Variant, expected: Variant, label: String) -> void:
	checks.append({"actual": actual, "expected": expected, "label": label})
