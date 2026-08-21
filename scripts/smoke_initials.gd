extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed := load("res://scenes/gameplay/gameplay.tscn") as PackedScene
	if packed == null:
		_fail("gameplay scene could not be loaded")
		return
	var game := packed.instantiate()
	game.call("configure", {"mode": "arcade", "players": 1, "demo": false, "start_chapter": 1})
	root.add_child(game)
	await process_frame
	await process_frame
	(game.get("players") as Array)[0].score = 12_345
	game.call("_begin_credits")
	if str(game.get("state")) != "initials":
		_fail("a non-demo result did not open initials entry", game)
		return

	for code in [67, 79, 68]:
		var event := InputEventKey.new()
		event.pressed = true
		event.unicode = code
		game.call("_unhandled_input", event)
	var letters := game.get("initials_letters") as Array
	if "".join(letters) != "COD":
		_fail("keyboard initials entry produced %s" % "".join(letters), game)
		return

	# Suppress disk writes for this smoke while still exercising confirmation.
	var configuration := game.get("configuration") as Dictionary
	configuration["demo"] = true
	game.set("configuration", configuration)
	var enter := InputEventKey.new()
	enter.pressed = true
	enter.physical_keycode = KEY_ENTER
	game.call("_unhandled_input", enter)
	if str(game.get("state")) != "credits":
		_fail("initials confirmation did not reach credits", game)
		return

	game.set("state", "ending")
	game.call("_begin_credits")
	if str(game.get("state")) != "credits":
		_fail("demo mode did not bypass initials", game)
		return
	print("SMOKE INITIALS VALUE: COD")
	print("SMOKE INITIALS CONFIRM: credits")
	print("SMOKE INITIALS DEMO BYPASS: credits")
	print("SMOKE INITIALS: OK")
	game.free()
	await process_frame
	await process_frame
	quit(0)


func _fail(message: String, game: Node = null) -> void:
	push_error("SMOKE INITIALS: %s" % message)
	if game != null and is_instance_valid(game):
		game.free()
		await process_frame
	quit(1)
