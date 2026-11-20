extends RefCounted

const MANIFEST := "res://data/assets/dossier_curien_motion.json"
const ART_ROOT := "res://assets/dossier_curien/motion_2026-11-19/"
const POSES := ["guard","windup","contact","recoil","recovery","jump_rise","jump_fall","crouch","crouch_guard","block","throw","victory","taunt","finish","reload","walk1","walk2","slide_contact"]
var entries := {}

func load_manifest(path := MANIFEST) -> bool:
	entries.clear()
	if not FileAccess.file_exists(path): return false
	return load_data(JSON.parse_string(FileAccess.get_file_as_string(path)))

func load_data(data: Variant, require_resources := true) -> bool:
	entries.clear()
	if not data is Dictionary or data.get("schema_version") != 1 or not data.get("assets") is Array: return false
	for item in data.assets:
		if not item is Dictionary: continue
		var fighter := str(item.get("fighter_id", ""))
		var art_id := str(item.get("art_id",fighter))
		var pose := str(item.get("pose", ""))
		var key := art_id + "_" + pose
		var path := str(item.get("path", ""))
		if not path.begins_with("res://"): path = "res://" + path
		if not identifier(fighter) or not identifier(art_id) or pose not in POSES or entries.has(key): continue
		if not safe_path(path): continue
		var dimensions = item.get("dimensions")
		var pivot = item.get("pivot_px")
		var height = item.get("standing_height_px")
		if not point(dimensions) or dimensions[0] <= 0 or dimensions[1] <= 0 or not point(pivot): continue
		if dimensions[0] != floor(dimensions[0]) or dimensions[1] != floor(dimensions[1]): continue
		if not within(pivot,dimensions) or not finite_number(height) or height <= 0: continue
		if require_resources:
			if not ResourceLoader.exists(path, "Texture2D"): continue
			var texture: Resource = ResourceLoader.load(path, "Texture2D")
			if not texture is Texture2D or texture.get_size() != Vector2(dimensions[0], dimensions[1]): continue
		var entry: Dictionary = item.duplicate(true)
		entry.path = path
		entry.art_id = art_id
		entry.erase("emitter_px")
		if within(item.get("emitter_px"),dimensions): entry.emitter_px = item.emitter_px
		var anchors := {}
		if item.get("anchors_px") is Dictionary:
			for name in item.anchors_px:
				if within(item.anchors_px[name],dimensions): anchors[name] = item.anchors_px[name]
		entry.anchors_px = anchors
		entries[key] = entry
	return not entries.is_empty()

func get_entry(key: String) -> Dictionary:
	return entries.get(key,{})

func has_pose(art_id: String, pose: String) -> bool:
	return entries.has(art_id+"_"+pose.trim_prefix("_"))

static func identifier(value: String) -> bool:
	if value.is_empty(): return false
	for character in value:
		if not (character >= "a" and character <= "z") and not (character >= "0" and character <= "9") and character != "_": return false
	return true

static func safe_path(path: String) -> bool:
	if not path.begins_with(ART_ROOT) or not path.ends_with(".png") or path.contains("\\") or path.to_utf8_buffer().has(0): return false
	for segment in path.trim_prefix("res://").split("/"):
		if segment in ["", ".", ".."] or segment.contains(":"): return false
	return true

static func finite_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT,TYPE_FLOAT] and is_finite(float(value))

static func point(value: Variant) -> bool:
	return value is Array and value.size() == 2 and finite_number(value[0]) and finite_number(value[1])

static func within(value: Variant, dimensions: Array) -> bool:
	return point(value) and value[0] >= 0 and value[1] >= 0 and value[0] <= dimensions[0] and value[1] <= dimensions[1]

static func canvas_size(entry: Dictionary, standing_height: float) -> Vector2:
	return Vector2(entry.dimensions[0],entry.dimensions[1]) * standing_height / float(entry.standing_height_px)
