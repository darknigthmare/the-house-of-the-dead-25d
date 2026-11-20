extends SceneTree

# Exercise the same menu and knockout paths the player uses. The core runner
# separately tests move timing and hits on individual frames.
var failures := 0
var arena

func _initialize() -> void:
	call_deferred("run")

func verify(condition: bool, detail: String) -> void:
	if not condition:
		failures += 1
		push_error(detail)

func click_button(prefix: String) -> void:
	for child in arena.box.get_children():
		if child is Button and child.text.begins_with(prefix):
			child.pressed.emit()
			return
	verify(false,"Button missing: " + prefix)

func win_round(side: int) -> void:
	arena.fighters[1-side].health = 0
	arena._physics_process(1.0/60.0)

func win_match() -> void:
	win_round(0)
	click_button("Manche suivante")
	win_round(0)
	verify(arena.phase == "finish","Finisher window")
	arena.trigger_finisher()
	for i in 72: arena._physics_process(1.0/60.0)
	verify(arena.phase == "result","Post-match result")

func run() -> void:
	var main = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	main._launch_dossier_curien()
	arena = main.active_game
	verify(arena.phase == "menu" and not main.menu_layer.visible,"Annex opens from game home")
	click_button("Histoire")
	click_button("Thomas Rogan")
	for i in 3:
		verify(arena.route == i and arena.phase == "brief","Story briefing " + str(i))
		click_button("Entrer dans")
		win_match()
		if i < 2: click_button("Ouvrir")
	verify((arena.box.get_child(0) as Label).text.begins_with("Épilogue"),"Story ending")
	click_button("Retour au dossier")
	click_button("Tournoi")
	click_button("Chariot")
	click_button("Disputer ma")
	win_match()
	click_button("Voir la finale")
	verify(arena.enemy != arena.chosen and arena.route == 1,"Tournament finalist")
	click_button("Disputer la finale")
	win_match()
	verify((arena.box.get_child(0) as Label).text == "Champion du tournoi","Tournament victory")
	click_button("Retour au dossier")
	click_button("Entraînement")
	click_button("Magician")
	click_button("Agent G")
	click_button("Laboratoire")
	arena.pause_menu()
	click_button("Mannequin")
	click_button("Reprendre")
	arena._physics_process(1.0/60.0)
	verify(arena.fighters[1].guarding and arena.clock_ticks==3600,"Guard dummy and infinite time")
	arena.pause_menu()
	click_button("Quitter le duel")
	click_button("Duel local")
	click_button("Agent G")
	click_button("Chariot")
	click_button("Cour")
	var key := InputEventKey.new()
	key.keycode = KEY_G
	key.pressed = true
	arena._input(key)
	arena._physics_process(1.0/60.0)
	verify(arena.fighters[1].action=="heavy","Local player two input")
	arena.pause_menu()
	click_button("Quitter le duel")
	click_button("Retour à l’arcade")
	verify(main.active_game==null and main.menu_layer.visible,"Original arcade menu restored")
	main.queue_free()
	await process_frame
	print("DOSSIER CURIEN SMOKE: ", failures, " failure(s)")
	quit(1 if failures else 0)
