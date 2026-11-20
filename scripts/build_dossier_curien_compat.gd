extends SceneTree
## Separate Godot 4.6 compatibility PCK built from imported local sources.
## Does not mount or rewrite the historical Godot 4.7 distribution.
## godot --headless --path CHECKOUT --script res://scripts/build_dossier_curien_compat.gd -- \
##   --source-root ABS_CHECKOUT --output ABS_NEW_COMPATIBILITY.pck

const MANIFESTS := ["data/assets/environment_manifest.json", "data/assets/dossier_curien_additions.json", "data/assets/dossier_curien_expansion.json", "data/assets/dossier_curien_motion.json", "data/assets/dossier_curien_gallery_2026-11-20.json", "data/assets/dossier_curien_gallery_2026-11-20_lot2.json", "data/assets/dossier_curien_gallery_2026-11-20_lot3.json", "data/assets/dossier_curien_gallery_2026-11-20_lot4.json", "data/assets/dossier_curien_gallery_2026-11-20_lot5.json", "data/audio/audio_cues.json"]
const BACKGROUNDS := ["mansion-exterior", "mansion-hall", "curien-laboratory"]
const PROPS := ["dead_tree", "garden_lamp", "mansion_double_door", "mansion_sconce", "lab_specimen_tank", "lab_pipe_cluster"]
const ATLASES := ["thomas_rogan", "agent_g", "chariot", "magician"]
var sources := {}
var problem := ""
var source_root := ""
var output := ""
var created_files: Array[String] = []
var started_pack := false

func _initialize() -> void:
	var ok := build()
	for path in created_files:
		if FileAccess.file_exists(path): DirAccess.remove_absolute(path)
	if not ok:
		printerr("COMPATIBILITY PACK FAILED: " + problem)
		if started_pack and FileAccess.file_exists(output + ".building"): DirAccess.remove_absolute(output + ".building")
	quit(0 if ok else 1)

func fail(message: String) -> bool:
	problem = message
	return false

func add(relative: String) -> bool:
	if relative.is_absolute_path() or ".." in relative.split("/") or relative.contains(":") or relative.contains("\\"): return fail("Unsafe resource path: " + relative)
	var path := source_root.path_join(relative)
	if not FileAccess.file_exists(path): return fail("Missing source resource: " + path)
	sources["res://" + relative] = path
	return true

func files(directory: String) -> Array[String]:
	var result: Array[String] = []
	var dir := DirAccess.open(source_root.path_join(directory))
	if dir == null:
		fail("Missing source directory: " + directory)
		return result
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name not in [".", ".."]:
			var relative := directory.path_join(name)
			if dir.current_is_dir(): result.append_array(files(relative))
			else: result.append(relative)
		name = dir.get_next()
	dir.list_dir_end()
	return result

func texture(relative: String) -> bool:
	if not FileAccess.file_exists(source_root.path_join(relative)): return fail("Missing PNG source: " + relative)
	var metadata := ConfigFile.new()
	var import_path := relative + ".import"
	if metadata.load(source_root.path_join(import_path)) != OK: return fail("Import PNG before packaging: " + relative)
	if str(metadata.get_value("deps", "source_file", "")) != "res://" + relative: return fail("Import source mismatch: " + relative)
	var imported := str(metadata.get_value("remap", "path", ""))
	if not imported.begins_with("res://.godot/imported/") or not imported.ends_with(".ctex") or ".." in imported.split("/"): return fail("Invalid imported texture path: " + relative)
	return add(import_path) and add(imported.trim_prefix("res://"))

func generated(relative: String, content: String) -> bool:
	var path := output + "." + relative.get_file() + "-building"
	if FileAccess.file_exists(path): return fail("Refusing to overwrite temporary file: " + path)
	var handle := FileAccess.open(path, FileAccess.WRITE)
	if handle == null: return fail("Cannot create project file: " + path)
	created_files.append(path)
	handle.store_string(content)
	handle.close()
	sources["res://" + relative] = path
	return true

func build() -> bool:
	var version := Engine.get_version_info()
	if int(version.major) != 4 or int(version.minor) != 6: return fail("This separate compatibility builder targets Godot 4.6 only.")
	var args := OS.get_cmdline_user_args()
	var options := {}
	for index in range(0, args.size(), 2):
		if index + 1 >= args.size() or args[index] not in ["--source-root", "--output"] or options.has(args[index]): return fail("Expected --source-root ABS_CHECKOUT --output ABS_NEW.pck")
		options[args[index]] = str(args[index + 1]).replace("\\", "/").simplify_path()
	if options.size() != 2: return fail("Source root and new output filename are required")
	source_root = options["--source-root"]
	output = options["--output"]
	if not source_root.is_absolute_path() or not output.is_absolute_path() or source_root.contains("://") or output.contains("://"): return fail("Use absolute filesystem paths")
	if not output.ends_with(".pck") or not DirAccess.dir_exists_absolute(output.get_base_dir()): return fail("Choose a .pck path in an existing directory")
	if FileAccess.file_exists(output) or FileAccess.file_exists(output + ".building"): return fail("Refusing to overwrite an existing build")
	for relative in MANIFESTS:
		if not add(relative): return false
		var manifest = JSON.parse_string(FileAccess.get_file_as_string(source_root.path_join(relative)))
		if not manifest is Dictionary: return fail("Malformed manifest: " + relative)
		if relative.ends_with("dossier_curien_motion.json"):
			if manifest.get("provisional", false) == true or not manifest.get("assets") is Array: return fail("Finalize motion catalogue before packaging")
			for entry in manifest.assets:
				if not entry is Dictionary or entry.get("provenance_pending", false) == true: return fail("Motion provenance is still pending")
	for relative in files("src/dossier_curien"):
		if relative.ends_with(".gd") or relative.ends_with(".gd.uid"):
			if not add(relative): return false
	for relative in ["src/audio/audio_cue_library.gd", "src/audio/procedural_sfx.gd"]:
		if not add(relative): return false
	for relative in files("assets/dossier_curien"):
		if relative.ends_with(".png") and not texture(relative): return false
	for name in BACKGROUNDS:
		if not texture("assets/environments/" + name + ".png"): return false
	for name in PROPS:
		if not texture("assets/environments_v2/props/" + name + "/" + name + ".png"): return false
	for index in ATLASES.size():
		var name: String = ATLASES[index]
		var group := "heroes" if index < 2 else "bosses"
		if not texture("assets/sprites_v2/" + group + "/" + name + "/" + name + "__v2__action_cycle__8dirx8f.png"): return false
	if problem != "": return false
	var project := "config_version=5\n\n[application]\nconfig/name=\"Dossier Curien - Compatibilite Godot 4.6\"\nrun/main_scene=\"res://demo.tscn\"\nconfig/features=PackedStringArray(\"4.6\", \"GL Compatibility\")\n\n[display]\nwindow/size/viewport_width=1280\nwindow/size/viewport_height=720\nwindow/stretch/mode=\"canvas_items\"\n\n[rendering]\nrenderer/rendering_method=\"gl_compatibility\"\nrenderer/rendering_method.mobile=\"gl_compatibility\"\n\n[dossier_curien]\nbuild_kind=\"compatibility_from_sources\"\nsource_engine_contract=\"4.7\"\ncompatibility_engine=\"4.6\"\n"
	var scene := "[gd_scene load_steps=2 format=3]\n\n[ext_resource type=\"Script\" path=\"res://compatibility_launcher.gd\" id=\"1\"]\n\n[node name=\"DossierCurien\" type=\"Control\"]\nlayout_mode=3\nanchors_preset=15\nanchor_right=1.0\nanchor_bottom=1.0\ngrow_horizontal=2\ngrow_vertical=2\nscript=ExtResource(\"1\")\n"
	var launcher := "extends \"res://src/dossier_curien/arena.gd\"\n\nfunc _ready() -> void:\n\tsuper._ready()\n\taudio_player.bus = &\"Master\"\n\texit_requested.connect(get_tree().quit)\n\nfunc menu() -> void:\n\tsuper.menu()\n\tfor child in box.get_children():\n\t\tif child is Button and child.text.begins_with(\"Retour à l’arcade\"):\n\t\t\tchild.text = \"Quitter\"\n"
	if not generated("project.godot", project) or not generated("demo.tscn", scene) or not generated("compatibility_launcher.gd", launcher): return false
	var packer := PCKPacker.new()
	started_pack = true
	if packer.pck_start(output + ".building") != OK: return fail("Cannot create compatibility pack")
	var paths: Array = sources.keys()
	paths.sort()
	for path: String in paths:
		if packer.add_file(path, sources[path]) != OK: return fail("Cannot add resource: " + path)
	if packer.flush() != OK: return fail("Cannot finish compatibility pack")
	packer = null
	if DirAccess.rename_absolute(output + ".building", output) != OK: return fail("Cannot finalize compatibility pack")
	print(JSON.stringify({"status":"ok", "build_kind":"compatibility_from_sources", "engine":version.string, "original_release_validated":false, "resources":paths.size(), "sha256":FileAccess.get_sha256(output), "output":output}))
	return true
