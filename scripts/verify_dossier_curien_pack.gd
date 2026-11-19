extends SceneTree
## Verify resources in the mounted standalone PCK, without the source checkout,
## editor imports, a rendered UI, or direct reads of remapped PNG source bytes.
##
## Godot 4.7:
## godot --headless --main-pack GAME.pck --script /absolute/this.gd
## Optional report: -- --report /absolute/report.json --label final-build

const MANIFEST_PATH := "res://data/assets/dossier_curien_expansion.json"
const ART_ROOT := "res://assets/dossier_curien/expansion/"
const SCRIPT_ROOT := "res://src/dossier_curien/"
const REQUIRED_SCRIPTS := [
	"arena.gd", "combatant.gd", "presentation.gd", "saga.gd", "saga_bestiary.gd",
	"saga_archives.gd", "saga_costumes.gd", "saga_lab.gd", "saga_rush.gd", "saga_stage.gd"
]
const HIDDEN_CATEGORIES := ["fighter_pose", "animation_pose"]

var checks := 0
var failures: Array[String] = []
var texture_results: Array[Dictionary] = []
var script_results: Array[Dictionary] = []
var counters: Dictionary = {}
var linda_results: Dictionary = {}
var report_path := ""
var build_label := "mounted-pack"


func _initialize() -> void:
	call_deferred("_run")


func _check(condition: bool, label: String) -> bool:
	checks += 1
	if not condition:
		failures.append(label)
		printerr("PACK CHECK FAILED: " + label)
	return condition


func _read_object(path: String) -> Dictionary:
	if not _check(FileAccess.file_exists(path), "Pack contains JSON " + path):
		return {}
	var parser := JSON.new()
	if not _check(parser.parse(FileAccess.get_file_as_string(path)) == OK, "Pack JSON parses: " + path):
		return {}
	if not _check(parser.data is Dictionary, "Pack JSON is an object: " + path):
		return {}
	return parser.data


func _numeric_array(value: Variant, length: int) -> bool:
	if not value is Array or value.size() != length:
		return false
	for number: Variant in value:
		if typeof(number) not in [TYPE_INT, TYPE_FLOAT] or not is_finite(float(number)):
			return false
	return true


func _resource_path(value: String) -> String:
	return value if value.begins_with("res://") else "res://" + value


func _load_scripts() -> Dictionary:
	var result: Dictionary = {}
	for filename: String in REQUIRED_SCRIPTS:
		var path := SCRIPT_ROOT + filename
		if not _check(FileAccess.file_exists(path), "Pack contains script source " + filename):
			continue
		if not _check(ResourceLoader.exists(path, "GDScript"), "Script is a resource: " + filename):
			continue
		var script: Resource = ResourceLoader.load(path, "GDScript")
		if not _check(script is GDScript and script.can_instantiate(), "Script loads and parses: " + filename):
			continue
		result[filename] = script
		script_results.append({"path": path, "sha256": FileAccess.get_sha256(path)})
	return result


func _manifest_textures(entries: Array, summary: Dictionary) -> Dictionary:
	var by_id: Dictionary = {}
	var paths: Dictionary = {}
	var expected_gallery: Dictionary = {}
	var declared_bytes := 0
	for value: Variant in entries:
		if not _check(value is Dictionary, "Expansion manifest entry is an object"):
			continue
		var entry: Dictionary = value
		var identity := str(entry.get("id", ""))
		var path := _resource_path(str(entry.get("path", "")))
		if not _check(not identity.is_empty() and not by_id.has(identity), "Unique nonempty identity: " + identity):
			continue
		by_id[identity] = entry
		if not _check(path.begins_with(ART_ROOT) and path.ends_with(".png") and not ".." in path.split("/") and not path.contains("\\"), "Safe expansion resource path: " + identity):
			continue
		_check(not paths.has(path), "One manifest entry per texture: " + path)
		paths[path] = true
		if entry.get("gallery", true) != false and str(entry.get("category", "")) not in HIDDEN_CATEGORIES:
			expected_gallery[identity] = path
		declared_bytes += int(entry.get("bytes", 0))
		var dimensions: Variant = entry.get("dimensions", [])
		if not _check(_numeric_array(dimensions, 2) and dimensions[0] > 0 and dimensions[1] > 0, "Native dimensions declared: " + identity):
			continue
		var expected := Vector2(float(dimensions[0]), float(dimensions[1]))
		# Exported PNG paths can exist only through .import -> .ctex remapping.
		# ResourceLoader is the production loading path; FileAccess PNG reads are
		# intentionally absent from this verifier.
		if not _check(ResourceLoader.exists(path, "Texture2D"), "Pack texture resource exists: " + identity):
			continue
		var texture: Resource = ResourceLoader.load(path, "Texture2D")
		if not _check(texture is Texture2D, "Pack texture loads as Texture2D: " + identity):
			continue
		var actual: Vector2 = texture.get_size()
		_check(actual.is_equal_approx(expected), "Pack texture retains native dimensions: " + identity)
		texture_results.append({"id": identity, "path": path, "expected_dimensions": dimensions, "loaded_dimensions": [actual.x, actual.y], "matches": actual.is_equal_approx(expected)})
	_check(int(summary.get("assets", -1)) == entries.size(), "Summary asset count equals manifest rows")
	_check(int(summary.get("gallery_entries", -1)) == expected_gallery.size(), "Summary gallery count equals visible subject rows")
	if summary.has("bytes"):
		_check(int(summary.bytes) == declared_bytes, "Summary source byte count equals its manifest receipts")
	_check(texture_results.size() == entries.size(), "Every manifest image loaded from the actual pack")
	counters["manifest_assets"] = entries.size()
	counters["loaded_textures"] = texture_results.size()
	counters["expected_gallery_entries"] = expected_gallery.size()
	counters["hidden_pose_entries"] = entries.size() - expected_gallery.size()
	counters["declared_source_bytes"] = declared_bytes
	return {"by_id": by_id, "expected_gallery": expected_gallery}


func _game_contract(scripts: Dictionary) -> int:
	if not scripts.has("combatant.gd") or not scripts.has("saga.gd"):
		return -1
	var fighter_constants: Dictionary = scripts["combatant.gd"].get_script_constant_map()
	var saga_constants: Dictionary = scripts["saga.gd"].get_script_constant_map()
	var profiles: Array = fighter_constants.get("PROFILES", [])
	var manor_routes: Array = fighter_constants.get("STORY", [])
	var cases: Dictionary = saga_constants.get("CASES", {})
	var alternate: Dictionary = saga_constants.get("ALTERNATE_STORIES", {})
	var stages: Array = saga_constants.get("STAGES", [])
	var story_count := manor_routes.size() + cases.size() - (1 if cases.has("curien") else 0) + alternate.size()
	_check(profiles.size() == 24, "Mounted code contains the 24 combat profiles")
	_check(cases.has("curien") and manor_routes.size() == 4, "The manor Chronicle has four routes and is counted once")
	_check(story_count == 26, "Mounted code has 26 routes: manor + other Chronicles + alternates")
	_check(stages.size() == 18, "Mounted code contains 18 arenas")
	counters.merge({"fighters": profiles.size(), "chronicles": cases.size(), "manor_routes": manor_routes.size(), "alternate_stories": alternate.size(), "story_routes": story_count, "stages": stages.size()})
	var linda_id := -1
	for index: int in profiles.size():
		if str(profiles[index].get("id", "")) == "linda":
			linda_id = index
	_check(linda_id == 23, "Linda is the appended combat profile at index 23")
	if linda_id >= 0:
		_check(int(profiles[linda_id].get("ammo", 0)) == 8, "Linda's packed profile retains eight rounds")
		_check(alternate.has(linda_id) and alternate[linda_id].size() == 4, "Linda's packed story has four narrative beats")
	return linda_id


func _gallery(scripts: Dictionary, expected: Dictionary, linda_id: int) -> void:
	if not scripts.has("saga_bestiary.gd"):
		return
	var gallery: RefCounted = scripts["saga_bestiary.gd"].new()
	if not _check(gallery.load_manifest(), "Packed bestiary loads its manifest"):
		return
	var loaded: Array = gallery.get("assets")
	_check(loaded.size() == expected.size(), "Packed bestiary does not silently drop any subject")
	var seen: Dictionary = {}
	for entry: Dictionary in loaded:
		var identity := str(entry.get("id", ""))
		_check(expected.has(identity) and not seen.has(identity), "Packed gallery subject matches manifest: " + identity)
		seen[identity] = true
		if expected.has(identity):
			_check(str(entry.get("path", "")) == str(expected[identity]), "Packed gallery uses the declared texture: " + identity)
		if identity == "linda_rotta":
			_check(gallery.fighter_id(entry) == linda_id, "Linda's packed gallery card resolves to the combat profile")
		else:
			_check(gallery.fighter_id(entry) < 0, "Illustration is not exposed as a new playable fighter: " + identity)
	for identity: String in expected:
		_check(seen.has(identity), "Expected subject is visible in the packed gallery: " + identity)
	counters["loaded_gallery_entries"] = loaded.size()


func _linda(scripts: Dictionary, by_id: Dictionary, linda_id: int) -> void:
	if not scripts.has("presentation.gd") or linda_id < 0:
		return
	if not _check(by_id.has("linda_rotta") and by_id.has("linda_contact"), "Pack declares Linda guard and contact artwork"):
		return
	var painter: RefCounted = scripts["presentation.gd"].new()
	painter.load_textures()
	var profiles: Variant = painter.get("pose_profiles")
	var emitters: Variant = painter.get("pose_emitters")
	if not _check(profiles is Dictionary and emitters is Dictionary, "Packed presentation exposes pose pivots and emitters"):
		return
	var guard: Variant = painter.guard_art(linda_id)
	var contact: Variant = painter.saga_texture("linda_contact")
	_check(guard is Texture2D, "Packed presentation resolves Linda's guard")
	_check(contact is Texture2D, "Packed presentation resolves Linda's contact")
	if guard is Texture2D:
		_check(guard.resource_path == _resource_path(str(by_id.linda_rotta.path)), "Linda guard binds the declared expansion image")
	if contact is Texture2D:
		_check(contact.resource_path == _resource_path(str(by_id.linda_contact.path)), "Linda contact binds the declared expansion image")
	var pose_results: Array[Dictionary] = []
	for identity: String in by_id:
		var entry: Dictionary = by_id[identity]
		var stem := str(entry.get("path", "")).get_file().get_basename()
		if stem != "linda_rotta_base" and not stem.begins_with("linda_"):
			continue
		var key := "linda_guard" if stem == "linda_rotta_base" else stem
		var bounds: Variant = entry.get("visible_bbox", entry.get("alpha_bbox", []))
		var dimensions: Variant = entry.get("dimensions", [])
		if not _check(_numeric_array(bounds, 4) and _numeric_array(dimensions, 2), "Linda calibration metadata exists: " + key):
			continue
		if not _check(profiles.has(key), "Packed presentation registers Linda's pivot: " + key):
			continue
		var expected_pivot := Vector2(float(bounds[0] + bounds[2]) * 0.5 / float(dimensions[0]), float(bounds[3]) / float(dimensions[1]))
		var metrics: Dictionary = profiles[key]
		var pivot: Variant = metrics.get("pivot", [])
		if _check(_numeric_array(pivot, 2), "Linda pivot is a numeric pair: " + key):
			_check(Vector2(float(pivot[0]), float(pivot[1])).is_equal_approx(expected_pivot), "Linda foot pivot matches the visible artwork: " + key)
		var expected_fraction := maxf(0.01, float(bounds[3] - bounds[1]) / float(dimensions[1]))
		_check(is_equal_approx(float(metrics.get("body_fraction", 0.0)), expected_fraction), "Linda scale matches its visible height: " + key)
		var emitter: Variant = entry.get("emitter_px", [])
		if entry.has("emitter_px") and _check(_numeric_array(emitter, 2), "Linda emitter is a native pixel pair: " + key):
			var expected_emitter := Vector2(float(emitter[0]), float(emitter[1]))
			_check(emitters.has(key) and emitters[key] is Vector2 and emitters[key].is_equal_approx(expected_emitter), "Packed Linda emitter matches the painted contact: " + key)
		pose_results.append({"pose": key, "expected_pivot": [expected_pivot.x, expected_pivot.y], "body_fraction": expected_fraction, "emitter_px": emitter})
	var contact_emitter: Variant = by_id.linda_contact.get("emitter_px", [])
	_check(_numeric_array(contact_emitter, 2) and Vector2(float(contact_emitter[0]), float(contact_emitter[1])).is_equal_approx(Vector2(910, 249)), "Linda standing contact retains the calibrated emitter [910, 249]")
	_check(painter.has_walk_cycle(linda_id, "linda"), "Both Linda walk contacts can be loaded from the pack")
	# The earlier 46-image pack has no low poses. Once those entries are packed,
	# their standing pixel scale becomes part of the contract automatically.
	for low_pose: String in ["linda_crouch", "linda_crouch_guard", "linda_slide_contact"]:
		if not by_id.has(low_pose):
			continue
		if not _check(painter.has_method("linda_low_canvas_size"), "Packed presentation handles native low-pose scaling"):
			continue
		var dims: Array = by_id[low_pose].dimensions
		var guard_bounds: Array = by_id.linda_rotta.visible_bbox
		var expected_size := Vector2(float(dims[0]), float(dims[1])) * 261.0 / float(guard_bounds[3] - guard_bounds[1])
		var actual_size: Vector2 = painter.linda_low_canvas_size(Vector2(float(dims[0]), float(dims[1])), 261.0)
		_check(actual_size.is_equal_approx(expected_size), "Low pose retains standing anatomical scale: " + low_pose)
	linda_results = {"fighter_id": linda_id, "poses": pose_results, "standing_contact_emitter_px": contact_emitter}


func _options() -> bool:
	var args := OS.get_cmdline_user_args()
	var index := 0
	while index < args.size():
		if index + 1 >= args.size() or args[index] not in ["--report", "--label"]:
			return _check(false, "Expected optional --report ABSOLUTE_PATH and --label BUILD_LABEL")
		var value := str(args[index + 1])
		if args[index] == "--report":
			if not _check(value.is_absolute_path() and not value.contains("://"), "Report destination is an absolute filesystem path"):
				return false
			report_path = value
		else:
			build_label = value
		index += 2
	return true


func _run() -> void:
	if not _options():
		_finish()
		return
	var version := Engine.get_version_info()
	_check(int(version.major) == 4 and int(version.minor) == 7, "Verification uses the Godot 4.7 engine contract")
	if not _check(str(ProjectSettings.get_setting("application/run/main_scene", "")) == "res://demo.tscn", "Mounted standalone main scene is res://demo.tscn"):
		_finish()
		return
	_check(ResourceLoader.exists("res://demo.tscn", "PackedScene"), "Main scene exists in the mounted pack")
	_check(ResourceLoader.load("res://demo.tscn", "PackedScene") is PackedScene, "Main scene loads without instantiation")
	var scripts := _load_scripts()
	var manifest := _read_object(MANIFEST_PATH)
	if not _check(manifest.get("assets") is Array and not manifest.assets.is_empty(), "Mounted expansion manifest is nonempty"):
		_finish()
		return
	if not _check(manifest.get("summary") is Dictionary, "Mounted expansion manifest has a summary"):
		_finish()
		return
	var collection := _manifest_textures(manifest.assets, manifest.summary)
	var linda_id := _game_contract(scripts)
	_gallery(scripts, collection.expected_gallery, linda_id)
	_linda(scripts, collection.by_id, linda_id)
	_finish()


func _finish() -> void:
	var summary := {
		"label": build_label, "status": "passed" if failures.is_empty() else "failed",
		"engine": Engine.get_version_info().get("string", "unknown"),
		"scope": "mounted_pck_resources_only", "main_scene_instantiated": false,
		"checks": checks, "failures": failures, "counts": counters,
		"scripts": script_results, "textures": texture_results, "linda": linda_results,
		"notes": ["Textures are loaded through ResourceLoader and import remapping; source PNG bytes are not required inside the PCK.", "This verifies packaging and resource calibration, not animation smoothness or canonical visual fidelity."]
	}
	if not report_path.is_empty():
		var file := FileAccess.open(report_path, FileAccess.WRITE)
		if file == null:
			_check(false, "Cannot write report: " + report_path)
			summary.status = "failed"
			summary.checks = checks
		else:
			file.store_string(JSON.stringify(summary, "\t") + "\n")
			file.close()
	print("DOSSIER CURIEN PACK: %s; %d checks; %d failures; %d/%d textures; %d gallery entries." % [summary.status, checks, failures.size(), int(counters.get("loaded_textures", 0)), int(counters.get("manifest_assets", 0)), int(counters.get("loaded_gallery_entries", 0))])
	print(JSON.stringify({"label": build_label, "status": summary.status, "counts": counters, "failures": failures, "report": report_path}))
	quit(0 if failures.is_empty() else 1)
