extends SceneTree

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay/gameplay.tscn"
const EXPECTED_CHAPTERS: Array[int] = [1, 2, 3, 4]
const EXPECTED_BOSS_SEQUENCE: Array[String] = [
	"chariot",
	"hangedman",
	"hermit",
	"chariot",
	"hangedman",
	"magician",
]
const MAX_NODES_PER_CHAPTER := 32


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load(GAMEPLAY_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("gameplay scene could not be loaded")
		return
	var game := packed.instantiate()
	game.call("configure", {
		"mode": "arcade",
		"players": 1,
		"demo": true,
		"start_chapter": 1,
	})
	root.add_child(game)
	await process_frame
	await process_frame
	if not bool(game.get("session_started")):
		_fail("runtime session did not start", game)
		return

	# Stop clocks and rendering updates; transitions below still call production
	# chapter, rescue, boss, score and ending methods directly.
	game.set("paused_by_player", true)
	game.process_mode = Node.PROCESS_MODE_DISABLED
	var chapters_seen: Array[int] = []
	var bosses_seen: Array[String] = []

	for expected_chapter_index in 4:
		if int(game.get("chapter_index")) != expected_chapter_index:
			_fail("chapter transition mismatch before chapter %d" % (expected_chapter_index + 1), game)
			return
		var chapter := game.get("current_chapter") as Dictionary
		if chapter.is_empty():
			_fail("chapter %d has no runtime data" % (expected_chapter_index + 1), game)
			return
		chapters_seen.append(expected_chapter_index + 1)
		var node_id := str(chapter.get("start", ""))
		var node_guard := 0
		while node_id != "chapter_complete" and node_guard < MAX_NODES_PER_CHAPTER:
			node_guard += 1
			var node_data := _find_node(chapter, node_id)
			if node_data.is_empty():
				_fail("missing node %s in chapter %d" % [node_id, expected_chapter_index + 1], game)
				return
			game.set("current_node", node_data)
			game.set("current_node_id", node_id)
			(game.get("routes_discovered") as Dictionary)["%d:%s" % [expected_chapter_index + 1, node_id]] = true

			if node_data.has("civilian"):
				game.set("scientists_total", int(game.get("scientists_total")) + 1)
				game.set("chapter_scientists_total", int(game.get("chapter_scientists_total")) + 1)
				var civilian := Node3D.new()
				civilian.set_meta("actor_id", "scientist_%02d_%02d" % [expected_chapter_index + 1, node_guard])
				game.add_child(civilian)
				game.call("_rescue_civilian", civilian)
				civilian.free()

			if str(node_data.get("type", "")) == "boss":
				var boss_id := str(node_data.get("boss", chapter.get("boss", "magician")))
				bosses_seen.append(boss_id)
				var configuration := game.get("configuration") as Dictionary
				configuration["mode"] = "boss_rush"
				game.set("configuration", configuration)
				game.call("_start_boss", boss_id)
				game.call("_on_boss_defeated")
				configuration["mode"] = "arcade"
				game.set("configuration", configuration)
				game.call("_clear_actors")

			game.set("branch_success", true)
			if node_data.has("next_success"):
				node_id = str(node_data.get("next_success", "chapter_complete"))
			else:
				node_id = str(node_data.get("next", "chapter_complete"))

		if node_guard >= MAX_NODES_PER_CHAPTER:
			_fail("node guard reached in chapter %d" % (expected_chapter_index + 1), game)
			return
		game.call("_complete_chapter")
		game.call("_advance_after_chapter")

	if chapters_seen != EXPECTED_CHAPTERS:
		_fail("chapters mismatch: %s" % str(chapters_seen), game)
		return
	if bosses_seen != EXPECTED_BOSS_SEQUENCE:
		_fail("boss sequence mismatch: %s" % str(bosses_seen), game)
		return
	if int(game.get("scientists_saved")) != 15 or int(game.get("scientists_total")) != 15:
		_fail("expected 15/15 scientists, got %d/%d" % [int(game.get("scientists_saved")), int(game.get("scientists_total"))], game)
		return
	if not bool(game.get("all_scientists_saved")):
		_fail("all_scientists_saved was false", game)
		return
	if str(game.get("state")) != "ending":
		_fail("runtime did not reach ending", game)
		return

	print("SMOKE CAMPAIGN CHAPTERS: ", chapters_seen)
	print("SMOKE CAMPAIGN BOSSES: ", bosses_seen)
	print("SMOKE CAMPAIGN SCIENTISTS: 15/15")
	print("SMOKE CAMPAIGN ALL SCIENTISTS: true")
	print("SMOKE CAMPAIGN FINAL STATE: ending")
	game.call("_begin_credits")
	if str(game.get("state")) != "credits":
		_fail("demo credits could not be started from the ending", game)
		return
	print("SMOKE CAMPAIGN CREDITS: credits")
	print("SMOKE CAMPAIGN: OK")
	await _dispose(game)
	quit(0)


func _find_node(chapter: Dictionary, node_id: String) -> Dictionary:
	for entry: Variant in chapter.get("nodes", []) as Array:
		var candidate := entry as Dictionary
		if str(candidate.get("id", "")) == node_id:
			return candidate
	return {}


func _fail(message: String, game: Node = null) -> void:
	push_error("SMOKE CAMPAIGN: %s" % message)
	if game != null and is_instance_valid(game):
		await _dispose(game)
	quit(1)


func _dispose(game: Node) -> void:
	game.free()
	await process_frame
	await process_frame
