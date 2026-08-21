extends Node

signal save_loaded(data: Dictionary)
signal save_written(path: String)
signal save_recovered(reason: String)

const SAVE_VERSION := 3
const SAVE_PATH := "user://house_of_dead_25d_save.json"
const BACKUP_PATH := "user://house_of_dead_25d_save.backup.json"

var data: Dictionary = {}


func _ready() -> void:
	data = _defaults()
	load_save()


func default_data() -> Dictionary:
	return _defaults()


func _defaults() -> Dictionary:
	return {
		"version": SAVE_VERSION,
		"settings": {},
		"high_scores": [],
		"chapters_unlocked": [1],
		"bosses_unlocked": [],
		"routes_discovered": [],
		"endings_obtained": [],
		"statistics": {
			"runs": 0,
			"shots": 0,
			"hits": 0,
			"scientists_saved": 0,
			"continues": 0,
			"chapters_completed": 0
		}
	}


func load_save() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		data = _defaults()
		return data
	var loaded := _read_json(SAVE_PATH)
	if loaded.is_empty():
		loaded = _read_json(BACKUP_PATH)
		if loaded.is_empty():
			data = _defaults()
			save_recovered.emit("invalid primary and backup")
			return data
		save_recovered.emit("primary invalid; backup loaded")
	data = _migrate(loaded)
	save_loaded.emit(data.duplicate(true))
	return data


func write_save(new_data: Dictionary = data) -> bool:
	data = _migrate(new_data.duplicate(true))
	if FileAccess.file_exists(SAVE_PATH):
		var current := FileAccess.open(SAVE_PATH, FileAccess.READ)
		var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if current != null and backup != null:
			backup.store_string(current.get_as_text())
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data, "  "))
	save_written.emit(SAVE_PATH)
	return true


func set_settings(settings: Dictionary) -> void:
	_ensure_data()
	data.settings = settings.duplicate(true)


func has_chapter_unlocked(chapter_number: int) -> bool:
	_ensure_data()
	for value: Variant in data.get("chapters_unlocked", []) as Array:
		if int(value) == chapter_number:
			return true
	return false


func unlock_chapter(chapter_number: int) -> bool:
	_ensure_data()
	if chapter_number <= 0 or has_chapter_unlocked(chapter_number):
		return false
	var unlocked := data.get("chapters_unlocked", []) as Array
	unlocked.append(chapter_number)
	unlocked.sort()
	data.chapters_unlocked = unlocked
	return true


func unlock_boss(boss_id: String) -> bool:
	_ensure_data()
	return _append_unique_string("bosses_unlocked", boss_id)


func discover_route(route_id: String) -> bool:
	_ensure_data()
	return _append_unique_string("routes_discovered", route_id)


func record_ending(ending_id: String) -> bool:
	_ensure_data()
	return _append_unique_string("endings_obtained", ending_id)


func add_statistics(increments: Dictionary) -> void:
	_ensure_data()
	var statistics := data.get("statistics", {}) as Dictionary
	var defaults := (_defaults().get("statistics", {}) as Dictionary)
	for key: Variant in defaults:
		var key_name := str(key)
		if increments.has(key_name):
			statistics[key_name] = maxi(0, int(statistics.get(key_name, 0)) + int(increments[key_name]))
	data.statistics = statistics


func merge_progress(progress: Dictionary) -> Dictionary:
	_ensure_data()
	if progress.has("settings") and typeof(progress.settings) == TYPE_DICTIONARY:
		set_settings(progress.settings as Dictionary)
	for chapter_number: Variant in progress.get("chapters_unlocked", []) as Array:
		unlock_chapter(int(chapter_number))
	for boss_id: Variant in progress.get("bosses_unlocked", []) as Array:
		unlock_boss(str(boss_id))
	for route_id: Variant in progress.get("routes_discovered", []) as Array:
		discover_route(str(route_id))
	for ending_id: Variant in progress.get("endings_obtained", []) as Array:
		record_ending(str(ending_id))
	if progress.has("statistics") and typeof(progress.statistics) == TYPE_DICTIONARY:
		add_statistics(progress.statistics as Dictionary)
	if progress.has("high_score") and typeof(progress.high_score) == TYPE_DICTIONARY:
		var high_score := progress.high_score as Dictionary
		if not high_score.is_empty():
			record_score(high_score)
	return data.duplicate(true)


func record_score(entry: Dictionary) -> void:
	_ensure_data()
	var scores := data.get("high_scores", []) as Array
	scores.append(entry.duplicate(true))
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("score", 0)) > int(b.get("score", 0)))
	if scores.size() > 20:
		scores.resize(20)
	data.high_scores = scores


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _migrate(input: Dictionary) -> Dictionary:
	var migrated := _defaults()
	if typeof(input.get("settings", {})) == TYPE_DICTIONARY:
		migrated.settings = (input.get("settings", {}) as Dictionary).duplicate(true)
	for key_name: String in ["chapters_unlocked", "bosses_unlocked", "routes_discovered", "endings_obtained"]:
		if typeof(input.get(key_name, [])) == TYPE_ARRAY:
			migrated[key_name] = (input.get(key_name, []) as Array).duplicate(true)
	if not (migrated.chapters_unlocked as Array).any(func(value: Variant) -> bool: return int(value) == 1):
		(migrated.chapters_unlocked as Array).append(1)
	(migrated.chapters_unlocked as Array).sort()
	if typeof(input.get("statistics", {})) == TYPE_DICTIONARY:
		var old_statistics := input.get("statistics", {}) as Dictionary
		var statistics := migrated.statistics as Dictionary
		for key: Variant in statistics:
			statistics[key] = maxi(0, int(old_statistics.get(key, statistics[key])))
		migrated.statistics = statistics
	if typeof(input.get("high_scores", [])) == TYPE_ARRAY:
		var scores: Array = []
		for entry: Variant in input.get("high_scores", []) as Array:
			if typeof(entry) == TYPE_DICTIONARY:
				scores.append((entry as Dictionary).duplicate(true))
		scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("score", 0)) > int(b.get("score", 0)))
		if scores.size() > 20:
			scores.resize(20)
		migrated.high_scores = scores
	migrated.version = SAVE_VERSION
	return migrated


func _ensure_data() -> void:
	data = _migrate(data)


func _append_unique_string(key: String, value: String) -> bool:
	var normalized := value.strip_edges()
	if normalized.is_empty():
		return false
	var values := data.get(key, []) as Array
	if values.has(normalized):
		return false
	values.append(normalized)
	values.sort()
	data[key] = values
	return true
