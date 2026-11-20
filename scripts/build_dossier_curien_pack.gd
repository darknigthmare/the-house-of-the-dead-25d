extends SceneTree
## Rebuild the small Dossier Curien standalone pack from its mounted baseline.
##
## Usage:
## godot --headless --main-pack BASE.pck --script /absolute/path/to/this.gd -- \
##   --source-root /absolute/path/to/checkout --output /absolute/path/to/NEW.pck
##
## Run the editor import before building. Scripts, manifests and Dossier Curien
## texture imports are refreshed; other baseline resources are preserved.
##
## Godot 4.7 API: https://docs.godotengine.org/en/4.7/classes/class_pckpacker.html

const ADDITIONS_PATH := "res://data/assets/dossier_curien_additions.json"
const EXPANSION_PATH := "res://data/assets/dossier_curien_expansion.json"
const MOTION_PATH := "res://data/assets/dossier_curien_motion.json"
const GALLERY_PATHS := [
	"res://data/assets/dossier_curien_gallery_2026-11-20.json",
	"res://data/assets/dossier_curien_gallery_2026-11-20_lot2.json"
]
const ASSET_PREFIX := "res://assets/dossier_curien/"
const IMPORT_PREFIX := "res://.godot/imported/"
const REQUIRED_BASE_FILES := [
	"res://project.godot",
	"res://demo.tscn",
	"res://src/dossier_curien/arena.gd",
	"res://src/dossier_curien/combatant.gd",
	"res://src/dossier_curien/saga.gd",
	"res://src/dossier_curien/saga_stage.gd",
]

var _failed := false


func _initialize() -> void:
	quit(0 if _build() else 1)


func _build() -> bool:
	var options := _parse_options(OS.get_cmdline_user_args())
	if _failed:
		return false
	var source_root: String = options["--source-root"]
	var output_path: String = options["--output"]
	# Godot consumes --main-pack before exposing script command-line arguments.
	# Validate the mounted standalone project itself, and require a new output
	# path so neither the baseline nor an earlier build can be overwritten.
	if str(ProjectSettings.get_setting("application/run/main_scene", "")) != "res://demo.tscn":
		return _fail("Mount the standalone baseline with --main-pack BASE.pck.")
	if FileAccess.file_exists(output_path):
		return _fail("Output already exists; choose a new path: " + output_path)
	if not FileAccess.file_exists(source_root.path_join("project.godot")):
		return _fail("Source checkout has no project.godot: " + source_root)
	if not DirAccess.dir_exists_absolute(output_path.get_base_dir()):
		return _fail("Output directory does not exist: " + output_path.get_base_dir())
	for required_path: String in REQUIRED_BASE_FILES:
		if not FileAccess.file_exists(required_path):
			return _fail("Mounted baseline is missing " + required_path)

	var baseline_paths := _collect_files("res://")
	if _failed or baseline_paths.is_empty():
		return _fail("Cannot inventory the mounted baseline.")
	var baseline_set: Dictionary = {}
	var buffers: Dictionary = {}
	var replaced_sources := 0
	var preserved_files := 0
	for pack_path: String in baseline_paths:
		baseline_set[pack_path] = true
		var read_path := pack_path
		if pack_path.begins_with("res://src/"):
			read_path = source_root.path_join(pack_path.trim_prefix("res://"))
			replaced_sources += 1
		else:
			preserved_files += 1
		buffers[pack_path] = _read_bytes(read_path)
		if _failed:
			return false
	if replaced_sources == 0:
		return _fail("Baseline contains no src/ files to refresh.")
	# New modes must enter the pack even when the mounted baseline predates them.
	var source_modes := source_root.path_join("src/dossier_curien")
	for source_file: String in _collect_files(source_modes):
		if not source_file.ends_with(".gd") and not source_file.ends_with(".gd.uid"):
			continue
		var pack_path := "res://" + source_file.trim_prefix(source_root + "/")
		buffers[pack_path] = _read_bytes(source_file)
		if _failed:
			return false

	var additions_source := source_root.path_join(ADDITIONS_PATH.trim_prefix("res://"))
	var refreshed_manifest_count := 0
	var additions_bytes := _read_bytes(additions_source)
	if _failed:
		return false
	var parser := JSON.new()
	var parse_error := parser.parse(additions_bytes.get_string_from_utf8())
	if parse_error != OK or not parser.data is Dictionary:
		return _fail("Additions manifest must be a valid JSON object: " + additions_source)
	buffers[ADDITIONS_PATH] = additions_bytes
	if baseline_set.has(ADDITIONS_PATH): refreshed_manifest_count += 1
	var expansion_source := source_root.path_join(EXPANSION_PATH.trim_prefix("res://"))
	if FileAccess.file_exists(expansion_source):
		var expansion_bytes := _read_bytes(expansion_source)
		var expansion_parser := JSON.new()
		if _failed or expansion_parser.parse(expansion_bytes.get_string_from_utf8()) != OK or not expansion_parser.data is Dictionary:
			return _fail("Expansion manifest must be a valid JSON object: " + expansion_source)
		buffers[EXPANSION_PATH] = expansion_bytes
		if baseline_set.has(EXPANSION_PATH): refreshed_manifest_count += 1
	var motion_source := source_root.path_join(MOTION_PATH.trim_prefix("res://"))
	if not FileAccess.file_exists(motion_source): return _fail("Motion manifest is required: " + motion_source)
	var motion_bytes := _read_bytes(motion_source)
	var motion_parser := JSON.new()
	if _failed or motion_parser.parse(motion_bytes.get_string_from_utf8()) != OK or not motion_parser.data is Dictionary or not motion_parser.data.get("assets") is Array:
		return _fail("Motion manifest must contain an assets array: " + motion_source)
	if motion_parser.data.get("provisional", false) == true: return _fail("Finalize the provisional motion catalogue before packaging.")
	for entry in motion_parser.data.assets:
		if not entry is Dictionary or entry.get("provenance_pending", false) == true: return _fail("Every motion pose requires finalized provenance.")
	buffers[MOTION_PATH] = motion_bytes
	if baseline_set.has(MOTION_PATH): refreshed_manifest_count += 1
	for gallery_path: String in GALLERY_PATHS:
		var gallery_source := source_root.path_join(gallery_path.trim_prefix("res://"))
		var gallery_bytes := _read_bytes(gallery_source)
		var gallery_parser := JSON.new()
		if _failed or gallery_parser.parse(gallery_bytes.get_string_from_utf8()) != OK or not gallery_parser.data is Dictionary or not gallery_parser.data.get("assets") is Array:
			return _fail("Gallery manifest must contain an assets array: " + gallery_source)
		for entry in gallery_parser.data.assets:
			if not entry is Dictionary or entry.get("gallery", false) != true or entry.get("playable", true) != false or entry.get("animation_complete", true) != false or entry.get("runtime_role", "") != "bestiary":
				return _fail("Gallery illustrations must remain explicitly non-playable, incomplete and assigned to the bestiary.")
		buffers[gallery_path] = gallery_bytes
		if baseline_set.has(gallery_path): refreshed_manifest_count += 1

	var source_assets := source_root.path_join(ASSET_PREFIX.trim_prefix("res://"))
	if not DirAccess.dir_exists_absolute(source_assets):
		return _fail("Dossier Curien asset directory is missing: " + source_assets)
	var asset_paths := _collect_files(source_assets)
	if _failed:
		return false
	var new_import_count := 0
	var new_texture_count := 0
	var refreshed_import_count := 0
	var refreshed_texture_count := 0
	# A new PNG without import metadata must not be silently omitted.
	for absolute_path: String in asset_paths:
		if not absolute_path.to_lower().ends_with(".png"):
			continue
		if not FileAccess.file_exists(absolute_path + ".import"):
			return _fail("PNG has not been imported by Godot: " + absolute_path)

	for absolute_path: String in asset_paths:
		if not absolute_path.to_lower().ends_with(".png.import"):
			continue
		var relative_path := absolute_path.trim_prefix(source_root + "/")
		var pack_path := "res://" + relative_path
		var replacing_import := baseline_set.has(pack_path)
		var expected_source := pack_path.trim_suffix(".import")
		if not FileAccess.file_exists(absolute_path.trim_suffix(".import")):
			return _fail("Import metadata has no source PNG: " + absolute_path)
		var config := ConfigFile.new()
		var config_error := config.load(absolute_path)
		if config_error != OK:
			return _fail("Cannot read import metadata: " + absolute_path)
		var declared_source := str(config.get_value("deps", "source_file", ""))
		var texture_path := str(config.get_value("remap", "path", ""))
		if declared_source != expected_source:
			return _fail("Unexpected source_file in " + absolute_path)
		if not _is_texture_path(texture_path):
			return _fail("Import must resolve to one .godot/imported/*.ctex: " + absolute_path)
		buffers[pack_path] = _read_bytes(absolute_path)
		if _failed:
			return false
		if replacing_import: refreshed_import_count += 1
		else: new_import_count += 1
		# Corrected PNGs must replace cached baseline art as well as new paths.
		var replacing_texture := baseline_set.has(texture_path)
		var texture_source := source_root.path_join(texture_path.trim_prefix("res://"))
		buffers[texture_path] = _read_bytes(texture_source)
		if _failed: return false
		if replacing_texture: refreshed_texture_count += 1
		else: new_texture_count += 1

	# Every resource is already readable before creating or replacing any output.
	var target_paths: Array = buffers.keys()
	target_paths.sort()
	var temporary_path := output_path + ".building"
	if FileAccess.file_exists(temporary_path):
		return _fail("Temporary output already exists; inspect it before retrying: " + temporary_path)
	var packer: PCKPacker = PCKPacker.new()
	var pack_error := packer.pck_start(temporary_path)
	if pack_error != OK:
		return _fail("Cannot create temporary pack (error %d)." % pack_error)
	for pack_path: String in target_paths:
		pack_error = packer.add_file_from_buffer(pack_path, buffers[pack_path])
		if pack_error != OK:
			packer = null
			DirAccess.remove_absolute(temporary_path)
			return _fail("Cannot pack %s (error %d)." % [pack_path, pack_error])
	pack_error = packer.flush()
	packer = null
	if pack_error != OK:
		DirAccess.remove_absolute(temporary_path)
		return _fail("Cannot finish pack (error %d)." % pack_error)
	var rename_error := DirAccess.rename_absolute(temporary_path, output_path)
	if rename_error != OK:
		return _fail("Pack is complete at %s but cannot replace output (error %d)." % [temporary_path, rename_error])

	print(JSON.stringify({
		"status": "ok",
		"output": output_path,
		"sha256": FileAccess.get_sha256(output_path),
		"baseline_files": baseline_paths.size(),
		"preserved_files": preserved_files - refreshed_import_count - refreshed_texture_count - refreshed_manifest_count,
		"replaced_source_files": replaced_sources,
		"added_png_imports": new_import_count,
		"added_ctex_files": new_texture_count,
		"refreshed_png_imports": refreshed_import_count,
		"refreshed_ctex_files": refreshed_texture_count,
		"additions_manifest": ADDITIONS_PATH,
		"motion_manifest": MOTION_PATH,
		"packed_files": target_paths.size(),
		"ordering": "sorted resource paths",
	}, "\t"))
	return true


func _parse_options(args: PackedStringArray) -> Dictionary:
	var result: Dictionary = {}
	var index := 0
	while index < args.size():
		var key := args[index]
		if key not in ["--source-root", "--output"] or result.has(key) or index + 1 >= args.size():
			_fail("Expected --source-root ABS_CHECKOUT --output ABS_FILE.pck.")
			return {}
		var value := args[index + 1].replace("\\", "/").simplify_path()
		if not value.is_absolute_path() or value.contains("://"):
			_fail("Use absolute filesystem paths for " + key)
			return {}
		result[key] = value.trim_suffix("/") if key == "--source-root" else value
		index += 2
	if not result.has("--source-root") or not result.has("--output"):
		_fail("Expected --source-root ABS_CHECKOUT --output ABS_FILE.pck.")
		return {}
	if not str(result["--output"]).to_lower().ends_with(".pck"):
		_fail("Output filename must end in .pck.")
		return {}
	return result


func _collect_files(directory_path: String) -> Array[String]:
	var result: Array[String] = []
	var directory := DirAccess.open(directory_path)
	if directory == null:
		_fail("Cannot open directory: " + directory_path)
		return result
	directory.include_hidden = true
	directory.include_navigational = false
	var list_error := directory.list_dir_begin()
	if list_error != OK:
		_fail("Cannot list directory: " + directory_path)
		return result
	var entry := directory.get_next()
	while not entry.is_empty():
		var path := directory_path.path_join(entry)
		if directory.current_is_dir():
			result.append_array(_collect_files(path))
			if _failed:
				directory.list_dir_end()
				return result
		else:
			result.append(path)
		entry = directory.get_next()
	directory.list_dir_end()
	result.sort()
	return result


func _read_bytes(path: String) -> PackedByteArray:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("Missing or unreadable resource: " + path)
		return PackedByteArray()
	var length := file.get_length()
	if length <= 0:
		_fail("Resource is empty: " + path)
		return PackedByteArray()
	var data := file.get_buffer(length)
	if data.size() != length:
		_fail("Incomplete resource read: " + path)
		return PackedByteArray()
	return data


func _is_texture_path(path: String) -> bool:
	if not path.begins_with(IMPORT_PREFIX) or not path.ends_with(".ctex"):
		return false
	var basename := path.trim_prefix(IMPORT_PREFIX)
	return not basename.is_empty() and not basename.contains("/") and not basename.contains("\\") and not basename.contains("..")


func _fail(message: String) -> bool:
	_failed = true
	printerr("Dossier Curien pack: " + message)
	return false
