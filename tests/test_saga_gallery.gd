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
	write_manifest(base_path, [base])
	write_manifest(extra_path, [npc, costume, duplicate, false_playable, complete, foreign, animation, impostor, missing, "bad-row"])
	var gallery := Bestiary.new()
	check(gallery.load_manifest(base_path, extra_path), "Both collections load through native resource lookup")
	check(gallery.assets.size() == 4, "Merge rejects duplicate IDs, foreign paths, missing art, animations and false playable/complete claims")
	var ids := {}
	for entry in gallery.assets: ids[entry.id] = entry
	check(ids.has("existing_subject") and ids.existing_subject.path == base.path, "Extension cannot replace an existing subject")
	check(ids.has("test_npc") and ids.has("test_costume"), "New NPC and costume categories remain visible")
	check(ids.has("linda_rotta") and gallery.fighter_id(ids.linda_rotta) < 0, "Linda's identity alone cannot expose a new image as playable")
	check(gallery.role_label(npc) == "PNJ · non jouable", "NPC card states its non-playable role")
	check(gallery.role_label(costume) == "Variante de costume · non jouable", "Costume card does not imply an equipped costume")
	check(gallery.filters.size() == 5 and filter_for(gallery, "zombie_revenge") == 1 and filter_for(gallery, "hotd_ex") == 2, "New game filters extend the established collection order")
	for game in ["overkill", "hotd3"]:
		gallery.filter_index = filter_for(gallery, game)
		var entries: Array = gallery.filtered()
		check(not entries.is_empty(), "New game filter has subjects: " + game)
		for entry in entries: check(gallery.family(entry) == game, "Filter isolates the selected game: " + game)
	gallery.filter_index = filter_for(gallery, "hotd3")
	gallery.load_manifest(base_path, extra_path)
	check(gallery.filters[gallery.filter_index].game == "hotd3", "Reload preserves the chosen game's filter")
	check(gallery.family({"game":"hotd4_special"}) == "hotd4_special" and gallery.family({"game":"next_game"}) == "next_game", "Game IDs are not folded into EX by substring")
	write_manifest(extra_path, "malformed")
	check(gallery.load_manifest(base_path, extra_path) and gallery.assets.size() == 1, "Malformed extension preserves the base and removes stale extra subjects")
	check(gallery.filter_index == 0, "Removed collection resets the unavailable filter")
	write_manifest(base_path, "malformed")
	check(not gallery.load_manifest(base_path, extra_path) and gallery.assets.is_empty(), "Malformed collections do not retain stale subjects")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(base_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(extra_path))
	fixture_textures.clear()
	print("SAGA GALLERY: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
