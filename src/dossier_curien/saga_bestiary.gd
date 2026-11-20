extends RefCounted

const MANIFEST := "res://data/assets/dossier_curien_expansion.json"
const GALLERY_MANIFEST := "res://data/assets/dossier_curien_gallery_2026-11-20.json"
const ART_ROOT := "res://assets/dossier_curien/expansion/"
const GALLERY_ART_ROOT := "res://assets/dossier_curien/gallery_2026-11-20/"
const LOT2_MANIFEST := "res://data/assets/dossier_curien_gallery_2026-11-20_lot2.json"
const LOT2_ART_ROOT := "res://assets/dossier_curien/gallery_2026-11-20_lot2/"
const LOT3_MANIFEST := "res://data/assets/dossier_curien_gallery_2026-11-20_lot3.json"
const LOT3_ART_ROOT := "res://assets/dossier_curien/gallery_2026-11-20_lot3/"
const LOT4_MANIFEST := "res://data/assets/dossier_curien_gallery_2026-11-20_lot4.json"
const LOT4_ART_ROOT := "res://assets/dossier_curien/gallery_2026-11-20_lot4/"
const LOT5_MANIFEST := "res://data/assets/dossier_curien_gallery_2026-11-20_lot5.json"
const LOT5_ART_ROOT := "res://assets/dossier_curien/gallery_2026-11-20_lot5/"
const GALLERY_COLLECTIONS := [
	{"manifest":GALLERY_MANIFEST, "art_root":GALLERY_ART_ROOT},
	{"manifest":LOT2_MANIFEST, "art_root":LOT2_ART_ROOT},
	{"manifest":LOT3_MANIFEST, "art_root":LOT3_ART_ROOT},
	{"manifest":LOT4_MANIFEST, "art_root":LOT4_ART_ROOT},
	{"manifest":LOT5_MANIFEST, "art_root":LOT5_ART_ROOT}
]
const BASE_FILTERS := [
	{"game":"", "label":"Tous"},
	{"game":"zombie_revenge", "label":"Zombie Revenge"},
	{"game":"hotd_ex", "label":"Loving Deads EX"}
]
const CATEGORIES := {
	"character_base":"Personnage", "dialogue_portrait":"Personnage de l’histoire",
	"boss_base":"Boss", "enemy_base":"Créature", "fighter_pose":"Pose de combat",
	"npc_base":"PNJ", "costume_variant":"Variante de costume",
	"character_form":"Forme de personnage"
}
var assets: Array = []
var filters: Array = BASE_FILTERS.duplicate(true)
var filter_index := 0
var page := 0
var selected := -1

func load_manifest(path := MANIFEST, additional_collections: Array = []) -> bool:
	assets.clear()
	var ids := {}
	_append_collection(path, ART_ROOT, ids)
	var extras: Array = GALLERY_COLLECTIONS if path == MANIFEST and additional_collections.is_empty() else additional_collections
	for collection in extras:
		if not collection is Dictionary: continue
		var manifest_path := str(collection.get("manifest", ""))
		var art_root := str(collection.get("art_root", ""))
		if manifest_path == "" or art_root not in [GALLERY_ART_ROOT, LOT2_ART_ROOT, LOT3_ART_ROOT, LOT4_ART_ROOT, LOT5_ART_ROOT]: continue
		_append_collection(manifest_path, art_root, ids, true)
	assets.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("name", a.id)).naturalnocasecmp_to(str(b.get("name", b.id))) < 0)
	_refresh_filters()
	return not assets.is_empty()

func _append_collection(path: String, art_root: String, ids: Dictionary, gallery_only := false) -> void:
	if not FileAccess.file_exists(path): return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or not parsed.get("assets") is Array: return
	for item in parsed.assets:
		if not item is Dictionary: continue
		if item.get("gallery", true) == false: continue
		if gallery_only and (item.get("gallery", false) != true or item.get("playable", true) != false or item.get("animation_complete", true) != false or item.get("runtime_role", "") != "bestiary"): continue
		var id := str(item.get("id", ""))
		var asset_path := str(item.get("path", ""))
		if not asset_path.begins_with("res://"): asset_path = "res://" + asset_path
		var parts := asset_path.trim_prefix("res://").split("/")
		if id == "" or ids.has(id) or not asset_path.begins_with(art_root) or ".." in parts or "." in parts or "" in parts or asset_path.contains("\\"): continue
		if not asset_path.ends_with(".png") or not ResourceLoader.exists(asset_path): continue
		# Animation frames belong to the fighter; the gallery shows distinct subjects.
		if item.get("category", "") in ["fighter_pose", "animation_pose"]: continue
		var entry: Dictionary = item.duplicate(true)
		entry.path = asset_path
		assets.append(entry)
		ids[id] = true

func _refresh_filters() -> void:
	var selected_game := str(filters[filter_index].game) if filter_index >= 0 and filter_index < filters.size() else ""
	filters = BASE_FILTERS.duplicate(true)
	var games := {"":true, "zombie_revenge":true, "hotd_ex":true}
	var additions := []
	for entry: Dictionary in assets:
		var game := family(entry)
		if games.has(game): continue
		games[game] = true
		additions.append({"game":game, "label":str(entry.get("game_label", game))})
	additions.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.label).naturalnocasecmp_to(str(b.label)) < 0)
	filters.append_array(additions)
	filter_index = 0
	for index in filters.size():
		if str(filters[index].game) == selected_game: filter_index = index

func filtered() -> Array:
	if filter_index == 0: return assets
	if filter_index < 0 or filter_index >= filters.size(): return []
	var game := str(filters[filter_index].game)
	return assets.filter(func(entry: Dictionary): return family(entry) == game)

func family(entry: Dictionary) -> String:
	var game := str(entry.get("game", "")).to_lower()
	if game in ["zombie_revenge", "zombie revenge", "revenge"]: return "zombie_revenge"
	if game in ["hotd_ex", "ex", "loving_deads", "loving deads ex"]: return "hotd_ex"
	return game

func show(a, requested_page := 0) -> void:
	load_manifest()
	a.phase = "bestiary"
	a.fighters.clear()
	a.case_id = ""
	a.edition_id = ""
	var entries := filtered()
	page = clampi(requested_page, 0, maxi(0, ceili(entries.size()/float(a.PAGE_SIZE))-1))
	a.sheet("Bestiaire & personnages", "Personnages, PNJ et variantes  /  Galerie des archives")
	var choice := OptionButton.new()
	choice.fit_to_longest_item = false
	choice.custom_minimum_size.y = 33
	choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for filter: Dictionary in filters: choice.add_item(str(filter.label))
	choice.select(filter_index)
	choice.item_selected.connect(func(index: int): select_filter(a, index))
	a.box.add_child(choice)
	choice.grab_focus()
	a.paragraph("%d fiches  ·  Les illustrations de créatures sont consultables ici ; seules les fiches marquées « Jouable » donnent accès à un combattant." % entries.size())
	for index in range(page*a.PAGE_SIZE, mini((page+1)*a.PAGE_SIZE, entries.size())):
		var entry: Dictionary = entries[index]
		var kind := role_label(entry)
		a.button("%s  ·  %s" % [entry.get("name", entry.id), kind], detail.bind(a, index))
	if entries.is_empty(): a.paragraph("Aucune fiche disponible dans cette collection.")
	a.page_buttons(page, entries.size(), func(next_page): show(a, next_page))
	a.button("Menu principal", a.menu)

func select_filter(a, index: int) -> void:
	filter_index = clampi(index, 0, filters.size()-1)
	show(a)

func fighter_id(entry: Dictionary) -> int:
	return 23 if str(entry.get("id", "")) == "linda_rotta" and str(entry.get("path", "")).trim_prefix("res://") == "assets/dossier_curien/expansion/zombie_revenge_characters/linda_rotta_base.png" else -1

func role_label(entry: Dictionary) -> String:
	if fighter_id(entry) >= 0: return "Jouable"
	return str(CATEGORIES.get(str(entry.get("category", "")), "Illustration")) + " · non jouable"

func status_label(entry: Dictionary) -> String:
	var status := str(entry.get("status", ""))
	if status.contains("framing") or status.contains("clipped"): return "Silhouette à affiner"
	if status.contains("alpha_cleanup"): return "Détourage à affiner"
	if status.contains("provenance_review"): return "Références à vérifier"
	if status.contains("needs_visual") or status.contains("reference_pending"): return "Référence visuelle à confirmer"
	return "Adaptation d’après les références du jeu"

func detail(a, index: int) -> void:
	var entries := filtered()
	if entries.is_empty():
		show(a)
		return
	selected = clampi(index, 0, entries.size()-1)
	page = selected / a.PAGE_SIZE
	var entry: Dictionary = entries[selected]
	a.phase = "bestiary_detail"
	var game := str(entry.get("game_label", family(entry)))
	a.sheet(str(entry.get("name", entry.id)), game)
	var kind := role_label(entry)
	a.paragraph(kind + "  ·  " + status_label(entry))
	if fighter_id(entry) >= 0:
		a.paragraph("Jouable dans les duels, le tournoi, l’entraînement et le Boss Rush. Son parcours Histoire rejoint les Chroniques de Zombie Revenge.")
		a.paragraph("Pistolet et glissade armée  ·  8 cartouches")
		a.button("Jouer Linda", play.bind(a, fighter_id(entry)))
	elif str(entry.get("category", "")) == "npc_base":
		a.paragraph("PNJ présenté dans la galerie. Cette illustration n’ajoute pas de combattant au duel.")
	elif str(entry.get("category", "")) == "costume_variant":
		a.paragraph("Variante de costume consultable dans la galerie. Elle ne peut pas être sélectionnée pour combattre ; les poses et les transitions restent à produire.")
	elif str(entry.get("category", "")) == "character_form":
		a.paragraph("Forme de personnage présentée dans la galerie. Cette illustration ne crée ni combattant ni transformation jouable ; les poses et les transitions restent à produire.")
	else:
		a.paragraph("Illustration de référence. Ce visuel n’est pas encore associé à une variante jouable dans le mode duel.")
	if str(entry.get("category", "")) == "dialogue_portrait":
		a.paragraph("Portrait destiné aux dialogues et aux scènes de l’histoire.")
	elif str(entry.get("category", "")) not in ["npc_base", "costume_variant", "character_form"]:
		a.paragraph("Les poses et les animations de combat continuent d’être complétées.")
	a.paragraph("Fiche %d / %d" % [selected+1, entries.size()])
	if selected > 0: a.button("‹  Fiche précédente", detail.bind(a, selected-1))
	if selected+1 < entries.size(): a.button("Fiche suivante  ›", detail.bind(a, selected+1))
	a.button("Retour à la liste", show.bind(a, page))
	a.button("Menu principal", a.menu)

func play(a, identity: int) -> void:
	a.case_id = "revenge"
	a.edition_id = ""
	a.mode = 1
	a.choose(identity)

func draw(a) -> void:
	var entries := filtered()
	if selected < 0 or selected >= entries.size(): return
	var entry: Dictionary = entries[selected]
	var texture: Texture2D = a.visuals.cached(entry.path)
	if texture == null: return
	var frame := Rect2(701, 93, 514, 548)
	a.draw_style_box(card_style(), frame)
	var dims := texture.get_size()
	var available := frame.size - Vector2(44, 50)
	dims *= minf(available.x/dims.x, available.y/dims.y)
	a.draw_texture_rect(texture, Rect2(frame.get_center()-dims*0.5, dims), false)
	a.visuals.heading(a, Vector2(701, 675), "ARCHIVES DE L’AMS", 17, Color("d4b884"), 514, HORIZONTAL_ALIGNMENT_CENTER)

func card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("17242dee")
	style.border_color = Color("766447")
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	return style
