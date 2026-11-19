extends RefCounted

const MANIFEST := "res://data/assets/dossier_curien_expansion.json"
const ART_ROOT := "res://assets/dossier_curien/expansion/"
const FILTERS := ["Tous", "Zombie Revenge", "Loving Deads EX"]
const CATEGORIES := {
	"character_base":"Personnage", "dialogue_portrait":"Personnage de l’histoire",
	"boss_base":"Boss", "enemy_base":"Créature", "fighter_pose":"Pose de combat"
}
var assets: Array = []
var filter_index := 0
var page := 0
var selected := -1

func load_manifest(path := MANIFEST) -> bool:
	assets.clear()
	if not FileAccess.file_exists(path): return false
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(path))
	if not parsed is Dictionary or not parsed.get("assets") is Array: return false
	var ids := {}
	for item in parsed.assets:
		if not item is Dictionary: continue
		if item.get("gallery", true) == false: continue
		var id := str(item.get("id", ""))
		var asset_path := str(item.get("path", ""))
		if not asset_path.begins_with("res://"): asset_path = "res://" + asset_path
		if id == "" or ids.has(id) or not asset_path.begins_with(ART_ROOT) or ".." in asset_path.split("/"): continue
		if not asset_path.ends_with(".png") or not ResourceLoader.exists(asset_path): continue
		# Animation frames belong to the fighter; the gallery shows distinct subjects.
		if item.get("category", "") in ["fighter_pose", "animation_pose"]: continue
		var entry: Dictionary = item.duplicate(true)
		entry.path = asset_path
		assets.append(entry)
		ids[id] = true
	assets.sort_custom(func(a: Dictionary, b: Dictionary): return str(a.get("name", a.id)).naturalnocasecmp_to(str(b.get("name", b.id))) < 0)
	return not assets.is_empty()

func filtered() -> Array:
	if filter_index == 0: return assets
	var game := "zombie_revenge" if filter_index == 1 else "hotd_ex"
	return assets.filter(func(entry: Dictionary): return family(entry) == game)

func family(entry: Dictionary) -> String:
	var game := str(entry.get("game", "")).to_lower()
	return "zombie_revenge" if game.contains("revenge") else "hotd_ex" if game.contains("ex") or game.contains("loving") else game

func show(a, requested_page := 0) -> void:
	load_manifest()
	a.phase = "bestiary"
	a.fighters.clear()
	a.case_id = ""
	a.edition_id = ""
	var entries := filtered()
	page = clampi(requested_page, 0, maxi(0, ceili(entries.size()/float(a.PAGE_SIZE))-1))
	a.sheet("Bestiaire & personnages", "Zombie Revenge et Loving Deads EX  /  Galerie des archives")
	var filters := HBoxContainer.new()
	filters.add_theme_constant_override("separation", 8)
	a.box.add_child(filters)
	for index in FILTERS.size():
		var choice := Button.new()
		choice.text = ("• " if index == filter_index else "") + FILTERS[index]
		choice.custom_minimum_size.y = 33
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		choice.pressed.connect(select_filter.bind(a, index))
		filters.add_child(choice)
	a.paragraph("%d fiches  ·  Les illustrations de créatures sont consultables ici ; seules les fiches marquées « Jouable » donnent accès à un combattant." % entries.size())
	for index in range(page*a.PAGE_SIZE, mini((page+1)*a.PAGE_SIZE, entries.size())):
		var entry: Dictionary = entries[index]
		var kind: String = "Jouable" if fighter_id(entry) >= 0 else CATEGORIES.get(str(entry.get("category", "")), "Illustration")
		a.button("%s  ·  %s" % [entry.get("name", entry.id), kind], detail.bind(a, index))
	if entries.is_empty(): a.paragraph("Aucune fiche disponible dans cette collection.")
	a.page_buttons(page, entries.size(), func(next_page): show(a, next_page))
	a.button("Menu principal", a.menu)

func select_filter(a, index: int) -> void:
	filter_index = clampi(index, 0, FILTERS.size()-1)
	show(a)

func fighter_id(entry: Dictionary) -> int:
	return 23 if str(entry.get("id", "")) == "linda_rotta" else -1

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
	var game := str(entry.get("game_label", "Zombie Revenge" if family(entry) == "zombie_revenge" else "Loving Deads EX"))
	a.sheet(str(entry.get("name", entry.id)), game)
	var kind: String = CATEGORIES.get(str(entry.get("category", "")), "Illustration")
	a.paragraph(kind + "  ·  " + status_label(entry))
	if fighter_id(entry) >= 0:
		a.paragraph("Jouable dans les duels, le tournoi, l’entraînement et le Boss Rush. Son parcours Histoire rejoint les Chroniques de Zombie Revenge.")
		a.paragraph("Pistolet et glissade armée  ·  8 cartouches")
		a.button("Jouer Linda", play.bind(a, fighter_id(entry)))
	else:
		a.paragraph("Illustration de référence. Ce visuel n’est pas encore associé à une variante jouable dans le mode duel.")
	if str(entry.get("category", "")) == "dialogue_portrait":
		a.paragraph("Portrait destiné aux dialogues et aux scènes de l’histoire.")
	else:
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
