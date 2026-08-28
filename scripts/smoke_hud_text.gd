extends SceneTree

const UITextSanitizerType := preload("res://src/ui/ui_text_sanitizer.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/gameplay/gameplay.tscn") as PackedScene
	if packed == null:
		_fail("gameplay scene could not be loaded")
		return
	var game := packed.instantiate()
	game.call("configure", {"mode": "arcade", "players": 2, "demo": false, "start_chapter": 1})
	root.add_child(game)
	await process_frame
	await process_frame
	await process_frame
	if not bool(game.get("session_started")):
		_fail("gameplay session did not start", game)
		return

	var players := game.get("players") as Array
	players[0].score = 12_345
	players[0].lives = 3
	players[0].ammo = 4
	game.set("state", "node")
	game.call("_update_hud")
	var p1_status := game.get("p1_status") as Label
	if p1_status == null or p1_status.text != "P1  SCORE 012345":
		_fail("P1 status still depends on font icons: %s" % (p1_status.text if p1_status != null else "<missing>"), game)
		return
	if UITextSanitizerType.contains_unsupported_ornament(p1_status.text):
		_fail("P1 status contains an unsafe ornamental glyph", game)
		return

	var life_rows := game.get("life_icon_rows") as Array
	var bullet_rows := game.get("bullet_icon_rows") as Array
	if life_rows.size() != 2 or bullet_rows.size() != 2:
		_fail("the two independent icon rows were not built", game)
		return
	if not _rows_have_textures(life_rows) or not _rows_have_textures(bullet_rows):
		_fail("lives or ammunition are not backed by HUD textures", game)
		return

	game.call("_show_overlay", "CHAPTER — ÉPREUVE", "Précision • dégâts • Entrée", 1.0)
	var center_title := game.get("center_title") as Label
	var center_body := game.get("center_body") as Label
	if center_title.text != "CHAPTER - ÉPREUVE" or center_body.text != "Précision | dégâts | Entrée":
		_fail("overlay normalization damaged text or retained ornaments", game)
		return
	game.call("_set_subtitle", "Scientifique — sauvé • route ouverte", 1.0)
	var subtitle := game.get("subtitle_label") as Label
	if subtitle.text != "Scientifique - sauvé | route ouverte":
		_fail("subtitle normalization regressed: %s" % subtitle.text, game)
		return
	game.call("_feed", "TARGET • +120", Color.WHITE)
	await process_frame
	var score_feed := game.get("score_feed") as VBoxContainer
	var feed_label := score_feed.get_child(score_feed.get_child_count() - 1) as Label
	if feed_label == null or feed_label.text != "TARGET | +120":
		_fail("score feed normalization regressed", game)
		return

	game.call("_start_boss", "chariot")
	var boss_name := game.get("boss_name_label") as Label
	var boss_weak := game.get("boss_weak_label") as Label
	var boss_objective := game.get("objective_label") as Label
	if boss_name == null or boss_weak == null or boss_objective == null:
		_fail("boss HUD labels are missing", game)
		return
	if UITextSanitizerType.contains_unsupported_ornament(boss_name.text + boss_weak.text + boss_objective.text):
		_fail("boss HUD retained an unsafe ornamental glyph", game)
		return
	print("SMOKE HUD STATUS: ", p1_status.text)
	print("SMOKE HUD TEXTURES: life/ammo rows OK")
	print("SMOKE HUD FRENCH: accents preserved")
	print("SMOKE HUD GLYPHS: export-safe")
	game.free()
	await process_frame
	await create_timer(0.05).timeout
	quit(0)


func _rows_have_textures(rows: Array) -> bool:
	for row_value in rows:
		for icon_value in row_value as Array:
			var icon := icon_value as TextureRect
			if icon == null or icon.texture == null:
				return false
	return true


func _fail(message: String, game: Node = null) -> void:
	push_error("SMOKE HUD: %s" % message)
	if game != null and is_instance_valid(game):
		game.free()
		await process_frame
		await create_timer(0.05).timeout
	quit(1)
