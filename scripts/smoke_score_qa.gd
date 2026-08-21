extends SceneTree

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/gameplay.tscn"
const REQUIRED_FIELDS: Array[String] = [
	"timestamp", "player", "source", "target", "shot_type", "value", "delta",
	"score_before", "score_after", "chapter", "node"
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var log_path := "user://score_qa_smoke_%d.jsonl" % Time.get_ticks_usec()
	_remove_temp_log(log_path)
	var packed := load(GAMEPLAY_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("gameplay scene could not be loaded", null, log_path)
		return
	var game := packed.instantiate()
	game.call("configure", {
		"mode": "arcade",
		"players": 1,
		"demo": false,
		"start_chapter": 1,
		"qa_score_logging": true,
		"qa_score_log_path": log_path
	})
	root.add_child(game)
	await process_frame
	await process_frame
	game.call("_add_score", 0, 120, "HEAD SHOT", "sam_a1", "headshot")
	game.call("_add_score", 0, -100, "PLAYER HIT", "player_1", "enemy")
	if not FileAccess.file_exists(log_path):
		_fail("the configured JSONL file was not created", game, log_path)
		return
	var entries := _read_entries(log_path)
	if entries.size() != 2:
		_fail("expected 2 entries, got %d" % entries.size(), game, log_path)
		return
	for index in entries.size():
		var entry := entries[index]
		for field in REQUIRED_FIELDS:
			if not entry.has(field):
				_fail("entry %d is missing field %s" % [index, field], game, log_path)
				return
	var first := entries[0]
	var second := entries[1]
	if int(first.delta) != 120 or int(first.score_before) != 0 or int(first.score_after) != 120:
		_fail("the +120 attribution was not logged with its real score delta", game, log_path)
		return
	if str(first.target) != "sam_a1" or str(first.shot_type) != "headshot":
		_fail("headshot context is incomplete", game, log_path)
		return
	if int(second.delta) != -100 or int(second.score_before) != 120 or int(second.score_after) != 20:
		_fail("the -100 attribution was not logged with its real score delta", game, log_path)
		return
	if str(second.target) != "player_1" or str(second.shot_type) != "enemy":
		_fail("player-hit context is incomplete", game, log_path)
		return
	game.call("configure", {"qa_score_logging": false})
	game.call("_add_score", 0, 80, "TARGET DOWN", "sam_a1", "torso_kill")
	if _read_entries(log_path).size() != 2:
		_fail("normal mode wrote a QA score entry", game, log_path)
		return
	print("SMOKE SCORE QA ENTRIES: 2")
	print("SMOKE SCORE QA DELTAS: +120,-100")
	print("SMOKE SCORE QA NORMAL MODE: NO LOG")
	print("SMOKE SCORE QA: OK")
	await _dispose(game)
	_remove_temp_log(log_path)
	quit(0)


func _read_entries(log_path: String) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var file := FileAccess.open(log_path, FileAccess.READ)
	if file == null:
		return entries
	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue
		var parsed: Variant = JSON.parse_string(line)
		if typeof(parsed) != TYPE_DICTIONARY:
			return []
		entries.append(parsed as Dictionary)
	file.close()
	return entries


func _fail(message: String, game: Node, log_path: String) -> void:
	push_error("SMOKE SCORE QA: %s" % message)
	if game != null and is_instance_valid(game):
		await _dispose(game)
	_remove_temp_log(log_path)
	quit(1)


func _dispose(game: Node) -> void:
	game.free()
	await process_frame
	await process_frame


func _remove_temp_log(log_path: String) -> void:
	if FileAccess.file_exists(log_path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(log_path))
