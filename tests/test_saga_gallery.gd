extends SceneTree

const Bestiary := preload("res://src/dossier_curien/saga_bestiary.gd")
var checks := 0
var failures := 0
var fixture_textures: Array[ImageTexture] = []

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func fixture_art(path: String) -> String:
	# Cached resources exercise collection loading without writing fake game art.
	var image := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	var texture := ImageTexture.create_from_image(image)
	texture.take_over_path(path)
	fixture_textures.append(texture)
	return path

func write_manifest(path: String, entries: Variant) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"schema_version":1, "assets":entries}))
	file.close()

func filter_for(gallery, game: String) -> int:
	for index in gallery.filters.size():
		if gallery.filters[index].game == game: return index
	return -1

func _initialize() -> void:
	var stamp := str(Time.get_ticks_usec())
	var base_path := "user://gallery_base_" + stamp + ".json"
	var extra_path := "user://gallery_extra_" + stamp + ".json"
	var lot2_path := "user://gallery_lot2_" + stamp + ".json"
	var lot3_path := "user://gallery_lot3_" + stamp + ".json"
	var lot4_path := "user://gallery_lot4_" + stamp + ".json"
	var collections := [
		{"manifest":extra_path, "art_root":Bestiary.GALLERY_ART_ROOT},
		{"manifest":lot2_path, "art_root":Bestiary.LOT2_ART_ROOT},
		{"manifest":lot3_path, "art_root":Bestiary.LOT3_ART_ROOT},
		{"manifest":lot4_path, "art_root":Bestiary.LOT4_ART_ROOT}
	]
	var base := {"id":"existing_subject", "name":"Existing", "game":"zombie_revenge", "game_label":"Zombie Revenge", "category":"character_base", "path":fixture_art(Bestiary.ART_ROOT + "__fixture_base.png")}
	var npc := {"id":"test_npc", "name":"NPC", "game":"overkill", "game_label":"Overkill", "category":"npc_base", "path":fixture_art(Bestiary.GALLERY_ART_ROOT + "__fixture_npc.png"), "gallery":true, "playable":false, "animation_complete":false, "runtime_role":"bestiary"}
	var costume := npc.duplicate()
	costume.merge({"id":"test_costume", "name":"Costume", "game":"hotd3", "game_label":"The House of the Dead III", "category":"costume_variant", "path":fixture_art(Bestiary.GALLERY_ART_ROOT + "__fixture_costume.png")}, true)
	var duplicate := npc.duplicate()
	duplicate.id = base.id
	var false_playable := npc.duplicate()
	false_playable.id = "false_playable"
	false_playable.playable = true
	var complete := npc.duplicate()
	complete.id = "false_complete"
	complete.animation_complete = true
	var foreign := npc.duplicate()
	foreign.id = "foreign_collection"
	foreign.path = base.path
	var animation := npc.duplicate()
	animation.id = "animation_frame"
	animation.category = "animation_pose"
	var impostor := npc.duplicate()
	impostor.id = "linda_rotta"
	impostor.path = fixture_art(Bestiary.GALLERY_ART_ROOT + "__fixture_impostor.png")
	var missing := npc.duplicate()
	missing.id = "missing_image"
	missing.path = Bestiary.GALLERY_ART_ROOT + "__missing.png"
	var wrong_role := npc.duplicate()
	wrong_role.id = "false_runtime_role"
	wrong_role.runtime_role = "fighter"
	var implicit_gallery := npc.duplicate()
	implicit_gallery.id = "implicit_gallery"
	implicit_gallery.erase("gallery")
	var later := npc.duplicate()
	later.merge({"id":"test_lot2_npc", "game":"scarlet_dawn", "game_label":"Scarlet Dawn", "path":fixture_art(Bestiary.LOT2_ART_ROOT + "__fixture_later.png")}, true)
	var typing := costume.duplicate()
	typing.merge({"id":"test_lot2_costume", "game":"typing", "game_label":"The Typing of the Dead", "path":fixture_art(Bestiary.LOT2_ART_ROOT + "__fixture_typing.png")}, true)
	var previous_lot_duplicate := later.duplicate()
	previous_lot_duplicate.id = npc.id
	var previous_lot_path := later.duplicate()
	previous_lot_path.id = "previous_lot_path"
	previous_lot_path.path = npc.path
	var classic_npc := npc.duplicate()
	classic_npc.merge({"id":"test_lot3_npc", "game":"hotd", "game_label":"The House of the Dead", "path":fixture_art(Bestiary.LOT3_ART_ROOT + "__fixture_classic.png")}, true)
	var hotd4 := costume.duplicate()
	hotd4.merge({"id":"test_lot3_hotd4", "game":"hotd4", "game_label":"The House of the Dead 4", "path":fixture_art(Bestiary.LOT3_ART_ROOT + "__fixture_hotd4.png")}, true)
	var special := costume.duplicate()
	special.merge({"id":"test_lot3_special", "game":"hotd4_special", "game_label":"The House of the Dead 4 Special", "path":fixture_art(Bestiary.LOT3_ART_ROOT + "__fixture_special.png")}, true)
	var oldest_duplicate := classic_npc.duplicate()
	oldest_duplicate.id = npc.id
	var latest_duplicate := classic_npc.duplicate()
	latest_duplicate.id = later.id
	var latest_foreign_path := classic_npc.duplicate()
	latest_foreign_path.id = "latest_foreign_path"
	latest_foreign_path.path = later.path
	var character_form := npc.duplicate()
	character_form.merge({"id":"test_lot4_form", "category":"character_form", "path":fixture_art(Bestiary.LOT4_ART_ROOT + "__fixture_form.png")}, true)
	var fourth_boss := npc.duplicate()
	fourth_boss.merge({"id":"test_lot4_boss", "category":"boss_base", "path":fixture_art(Bestiary.LOT4_ART_ROOT + "__fixture_boss.png")}, true)
	var third_lot_duplicate := character_form.duplicate()
	third_lot_duplicate.id = classic_npc.id
	var third_lot_path := character_form.duplicate()
	third_lot_path.id = "third_lot_path"
	third_lot_path.path = classic_npc.path
	var playable_form := character_form.duplicate()
	playable_form.id = "false_playable_form"
	playable_form.playable = true
	write_manifest(base_path, [base])
	write_manifest(extra_path, [npc, costume, duplicate, false_playable, complete, foreign, animation, impostor, missing, wrong_role, implicit_gallery, "bad-row"])
	write_manifest(lot2_path, [later, typing, previous_lot_duplicate, previous_lot_path])
	write_manifest(lot3_path, [classic_npc, hotd4, special, oldest_duplicate, latest_duplicate, latest_foreign_path])
	write_manifest(lot4_path, [character_form, fourth_boss, third_lot_duplicate, third_lot_path, playable_form])
	var gallery := Bestiary.new()
	check(gallery.load_manifest(base_path, collections), "All five collections load through native resource lookup")
	check(gallery.assets.size() == 11, "Merge rejects duplicate IDs, foreign paths, missing art, animations and false gallery/runtime/playable/complete claims")
	var ids := {}
	for entry in gallery.assets: ids[entry.id] = entry
	check(ids.has("existing_subject") and ids.existing_subject.path == base.path, "Extension cannot replace an existing subject")
	check(ids.has("test_npc") and ids.has("test_costume"), "New NPC and costume categories remain visible")
	check(ids.has(later.id) and ids.has(typing.id), "The later batch adds subjects from its own art directory")
	check(ids.test_npc.path == npc.path and not ids.has("previous_lot_path"), "Later collections cannot replace previous subjects or claim their image paths")
	check(ids.has(classic_npc.id) and ids.has(hotd4.id) and ids.has(special.id), "The third batch adds its distinct classic NPC and edition variants")
	check(ids.test_npc.path == npc.path and ids.test_lot2_npc.path == later.path and not ids.has("latest_foreign_path"), "Third collection preserves both earlier batches and cannot borrow their artwork")
	check(ids.has(character_form.id) and ids.has(fourth_boss.id), "The fourth batch adds its distinct character form and boss")
	check(ids.test_lot3_npc.path == classic_npc.path and not ids.has("third_lot_path") and not ids.has("false_playable_form"), "Fourth collection preserves earlier subjects, respects its art root and rejects playable forms")
	check(ids.has("linda_rotta") and gallery.fighter_id(ids.linda_rotta) < 0, "Linda's identity alone cannot expose a new image as playable")
	check(gallery.role_label(npc) == "PNJ · non jouable", "NPC card states its non-playable role")
	check(gallery.role_label(costume) == "Variante de costume · non jouable", "Costume card does not imply an equipped costume")
	check(gallery.role_label(character_form) == "Forme de personnage · non jouable", "Character form is explicitly static and non-playable")
	check(gallery.filters.size() == 10 and filter_for(gallery, "zombie_revenge") == 1 and filter_for(gallery, "hotd_ex") == 2, "New game filters extend the established collection order")
	for game in ["overkill", "hotd3", "scarlet_dawn", "typing", "hotd", "hotd4", "hotd4_special"]:
		gallery.filter_index = filter_for(gallery, game)
		var entries: Array = gallery.filtered()
		check(not entries.is_empty(), "New game filter has subjects: " + game)
		for entry in entries: check(gallery.family(entry) == game, "Filter isolates the selected game: " + game)
	gallery.filter_index = filter_for(gallery, "hotd3")
	gallery.load_manifest(base_path, collections)
	check(gallery.filters[gallery.filter_index].game == "hotd3", "Reload preserves the chosen game's filter")
	check(gallery.family({"game":"hotd4_special"}) == "hotd4_special" and gallery.family({"game":"next_game"}) == "next_game", "Game IDs are not folded into EX by substring")
	write_manifest(lot2_path, [later, typing])
	write_manifest(lot3_path, [classic_npc, hotd4, special])
	write_manifest(lot4_path, "malformed")
	check(gallery.load_manifest(base_path, collections) and gallery.assets.size() == 9, "Malformed fourth extension preserves every earlier collection")
	write_manifest(lot4_path, [character_form, fourth_boss])
	write_manifest(extra_path, "malformed")
	check(gallery.load_manifest(base_path, collections) and gallery.assets.size() == 8, "Malformed earlier extension preserves the base and all later collections, without retaining stale subjects")
	check(gallery.filter_index == 0, "Removed collection resets the unavailable filter")
	write_manifest(lot2_path, "malformed")
	check(gallery.load_manifest(base_path, collections) and gallery.assets.size() == 6, "Malformed second extension leaves the independent base and both later batches intact")
	write_manifest(lot3_path, "malformed")
	check(gallery.load_manifest(base_path, collections) and gallery.assets.size() == 3, "Malformed third extension leaves the independent base and fourth batch intact")
	write_manifest(lot4_path, "malformed")
	check(gallery.load_manifest(base_path, collections) and gallery.assets.size() == 1, "Malformed fourth extension leaves the independent base intact")
	write_manifest(base_path, "malformed")
	check(not gallery.load_manifest(base_path, collections) and gallery.assets.is_empty(), "Malformed collections do not retain stale subjects")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(base_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(extra_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(lot2_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(lot3_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(lot4_path))
	fixture_textures.clear()
	print("SAGA GALLERY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
