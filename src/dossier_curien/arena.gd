extends Control

signal exit_requested

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
const Saga := preload("res://src/dossier_curien/saga.gd")
const Archives := preload("res://src/dossier_curien/saga_archives.gd")
const Rush := preload("res://src/dossier_curien/saga_rush.gd")
const STAGES := Saga.STAGES
const PAGE_SIZE := 5
const MODES := ["Histoire", "Duel contre IA", "Duel local", "Tournoi", "Entraînement", "Boss Rush AMS"]
const INTROS := [
	"Une sonnerie couvre le moteur de la berline. Rogan arrête l’enregistrement sur le premier mot de Sophie. G ouvre le portail. « Garde la ligne ouverte. » La reconstitution AMS commence.",
	"G règle le son d’un magnétophone. La piste de Rogan sature à l’ouverture du portail. Il bascule sur le second canal, où l’on distingue encore les pas des chercheurs. « On en compte combien ? »",
	"La caméra d’expertise est couchée au sol. Une semelle métallique s’arrête dans le cercle de mise au point. Une main soulève la bardiche. La bande de test émet deux bips et la silhouette de G apparaît.",
	"Seul le reflet de Curien demeure dans la vitre d’observation. Une lueur apparaît du mauvais côté du verre. Quand l’image de Chariot se charge, le sujet flotte déjà hors du cercle qui lui était réservé."
]
const RIVALS := [
	"Chariot · La verrière. Un éclat de verre roule entre les chaussures de Rogan. On entend G évacuer la pièce voisine. Rogan arrête de reculer quand le talon de Chariot écrase l’éclat.",
	"Magician · La salle d’essai. Dans la vitre de contrôle, G aperçoit le reflet de la créature avant sa silhouette. Il pose deux doigts sur la touche de lecture. « Une fois. À vitesse réelle. »",
	"Rogan · Derrière le verre. Le pardessus de Rogan se reflète sur le plastron. Au premier mouvement du viseur, l’armure pivote et le reflet disparaît dans la brèche. Chariot gratte la dalle d’un seul pas.",
	"G · Essai de contrôle. Le viseur de G trace un point entre deux plaques. Magician incline la tête. La bande son répète la même seconde pendant que le point hésite entre le sujet et son reflet."
]
const ENDINGS := [
	"Après Magician, le laboratoire devient une image fixe. Rogan rembobine jusqu’au coup de téléphone initial. Il range la cassette dans l’enveloppe de l’affaire et conserve le petit papier où il a noté l’heure de l’appel.",
	"La reprise s’arrête sur Chariot, dernier sujet de l’exercice. G coupe le son des chocs et remonte le canal des voix. Une personne que le premier écouteur ne distinguait pas répond à l’appel. Il corrige le registre des rescapés dans le compte rendu de simulation.",
	"Le modèle de Magician s’éteint. Encore en mouvement, Chariot traverse le trait blanc qui borne la salle virtuelle. Le film s’arrête sur son pied levé. Dans la régie, un opérateur entoure à la main la dernière image exploitable.",
	"La silhouette de Rogan disparaît du plateau. L’étiquette FIN se reflète dans la vitre, mais trois sphères tournent encore sur le moniteur de contrôle. Un technicien débranche le lecteur. Le dernier cercle rouge s’efface lentement du verre."
]

var rush := Rush.new()
var costumes := preload("res://src/dossier_curien/saga_costumes.gd").new()
var lab := preload("res://src/dossier_curien/saga_lab.gd").new()
var bestiary := preload("res://src/dossier_curien/saga_bestiary.gd").new()
var case_id := ""
var edition_id := ""
var archives := Archives.new()
var rule_awarded := [false, false]
var scan_enabled := true
var scan_last_window := -1
var story_opponents: Array = []
var story_stages: Array = []
var mode := 0
var preview := 0
var chosen := 0
var enemy := 2
var stage := 0
var route := 0
var phase := "menu"
var panel: PanelContainer
var box: VBoxContainer
var fighters: Array = []
var wins := [0, 0]
var winner := -1
var clock_ticks := 3600
var elapsed := 0
var finish_ticks := 0
var flash := 0
var impact_position := Vector2.ZERO
var impact_guard := false
var action_queue := ["", ""]
var ai_key := ""
var ai_dir := 0
var ai_crouch := false
var dummy_guard := false
var tournament: Array[int] = []
var tournament_finalist := -1
var visuals := Painter.new()
var audio_library = preload("res://src/audio/audio_cue_library.gd").new()
var audio_player := AudioStreamPlayer.new()
var audio_available := false
var resume_phase := ""
var moves_return := Callable()
var stick_up := [false, false]
var sheet_revision := 0

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visuals.load_textures()
	audio_player.bus = &"SFX"
	audio_available = audio_library.load_manifest("res://data/audio/audio_cues.json")
	add_child(audio_player)
	panel = PanelContainer.new()
	add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("10181ff6")
	style.border_color = Color("9f8657")
	style.set_border_width_all(1)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 22
	style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", style)
	box = VBoxContainer.new()
	box.add_theme_constant_override("separation", 7)
	panel.add_child(box)
	menu()

func sound(cue: String) -> void:
	if audio_available:
		audio_player.stream = audio_library.build_stream(cue)
		audio_player.play()

func sheet(title: String, subtitle := "") -> void:
	sheet_revision += 1
	panel.show()
	for n in box.get_children():
		box.remove_child(n)
		n.queue_free()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	panel.custom_minimum_size = Vector2(580, 0)
	panel.size = Vector2(580, 0)
	panel.position = (size - panel.size) / 2
	if phase in ["select","brief","bestiary_detail"] or (phase == "result" and mode == 0 and route == 2 and winner == 0):
		panel.position.x = size.x * 0.055
		panel.grow_horizontal = Control.GROW_DIRECTION_END
	var h := Label.new()
	h.text = title
	h.add_theme_font_size_override("font_size", 30)
	h.add_theme_color_override("font_color", Color("e1c08a"))
	box.add_child(h)
	if subtitle != "": paragraph(subtitle)
	_refit_sheet.call_deferred(sheet_revision)
	queue_redraw()

func _refit_sheet(revision: int) -> void:
	if revision != sheet_revision or not is_instance_valid(panel) or not panel.visible: return
	# A rebuilt list can have the same minimum as its predecessor. Godot then
	# has no minimum-size change to expand the panel reset by sheet(). Read and
	# apply the completed content's minimum explicitly, after all rows exist.
	box.update_minimum_size()
	panel.update_minimum_size()
	var minimum := panel.get_combined_minimum_size()
	panel.size = Vector2(maxf(580.0,minimum.x),minimum.y)
	panel.position = (size-panel.size)*0.5
	if phase in ["select","brief","bestiary_detail"] or (phase == "result" and mode == 0 and route == 2 and winner == 0):
		panel.position.x = size.x*0.055
	panel.queue_sort()
	queue_redraw()

func paragraph(line: String) -> Label:
	var p := Label.new()
	p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.custom_minimum_size.x = 505
	p.text = line
	box.add_child(p)
	return p

func button(label: String, call: Callable) -> Button:
	var b := Button.new()
	b.text = label
	b.custom_minimum_size.y = 33
	b.pressed.connect(call)
	box.add_child(b)
	if box.find_children("*", "Button", false, false).size() == 1:
		b.grab_focus()
	return b

func menu() -> void:
	case_id = ""
	edition_id = ""
	stage = 0
	phase = "menu"
	fighters.clear()
	sheet("DOSSIER CURIEN", "Anthologie de combat  /  Archives de l’AMS")
	for m in Rush.MODE:
		button(MODES[m], pick_fighter.bind(m))
	button("Chroniques de la saga", case_menu)
	button("Archives et variantes", edition_menu)
	button("Bestiaire & personnages", bestiary.show.bind(self))
	button(MODES[Rush.MODE], rush.courses_menu.bind(self))
	button("Commandes et liste des coups", controls)
	button("Retour à l’arcade", func(): exit_requested.emit())

func controls() -> void:
	phase = "controls"
	sheet("Commandes")
	paragraph("J1 · Flèches pour se déplacer, ↑ pour sauter, ↓ pour se baisser. Maintenir arrière pour garder. J léger, K lourd, L spécial, U projection, R recharge, I finition.")
	paragraph("J2 · Q/D ou A/D, Z ou W pour sauter, S pour se baisser. F léger, G lourd, H spécial, T projection, E recharge, Y finition.")
	paragraph("Manette · Croix ou stick pour se déplacer. A léger, X lourd, B spécial, Y projection, LB recharge, RB finition, Start pause. Une manette pilote J1, deux permettent le duel local.")
	paragraph("Un léger confirmé s’enchaîne en lourd puis en spécial. La projection ouvre la garde. Un tir AMS passe au-dessus d’une cible accroupie.")
	paragraph("Provocation · O pour J1, C pour J2 ou clic du stick gauche. Depuis le neutre au sol ; déplacement, action ou impact l’annulent immédiatement.")
	button("Liste des coups par combattant", move_select)
	button("Retour", menu)

func move_select(page := 0) -> void:
	moves_return = controls
	phase = "moves"
	sheet("Liste des coups", "Données du simulateur à 60 images par seconde.")
	for i in range(page*PAGE_SIZE, mini((page+1)*PAGE_SIZE, Fighter.PROFILES.size())):
		button(Fighter.PROFILES[i].title, move_sheet.bind(i, move_select.bind(page)))
	page_buttons(page, Fighter.PROFILES.size(), move_select)
	button("Retour", controls)

func move_sheet(id: int, back: Callable) -> void:
	moves_return = back
	phase = "moves"
	var f := Fighter.new(id, 0, 1)
	sheet(str(f.profile.title), Fighter.NOTES[id])
	for item in [["light","J  ·  Léger"],["heavy","K  ·  Lourd"],["special","L  ·  " + str(f.profile.special)],["throw","U  ·  Projection"]]:
		var data := f.move_data(item[0])
		var damage := str(data.damage) if item[0] != "special" or f.shots_per_special == 1 else "%d × %d" % [int(data.damage), f.shots_per_special]
		paragraph("%s    /    %s dégâts    ·    actif i%d    ·    portée %d" % [item[1], damage, data.start, data.reach])
	if f.profile.has("alt_move"):
		var alt: Dictionary = f.profile.alt_move
		paragraph("↓ + L  ·  %s    /    %d dégâts    ·    actif i%d    ·    portée %d" % [f.profile.alt_name,alt.damage,alt.start,alt.reach])
	if int(f.profile.ammo) > 0: paragraph("R  ·  Recharge en %d images. Capacité %d." % [f.profile.reload, f.profile.ammo])
	paragraph("I  ·  Finition « %s » après le K.-O. décisif.   /   Manette RB." % f.profile.finish)
	paragraph("O / clic du stick gauche  ·  Provocation depuis le neutre au sol. Geste cosmétique, sans effet sur les dégâts.")
	button("Retour", back)

func case_menu(page := 0) -> void:
	phase = "cases"
	sheet("Chroniques de la saga", "Choisissez le jeu et son terrain de combat.")
	var keys := Saga.CASES.keys()
	for index in range(page * PAGE_SIZE, mini((page + 1) * PAGE_SIZE, keys.size())):
		var key: String = keys[index]
		button(Saga.CASES[key].name, case_details.bind(key))
	page_buttons(page, keys.size(), case_menu)
	button("Retour", menu)

func case_details(key: String) -> void:
	case_id = key
	edition_id = ""
	mode = 0
	stage = int(Saga.CASES[key].stage)
	phase = "dossier"
	var dossier: Dictionary = Saga.CASES[key]
	sheet(dossier.name, dossier.place + "   /   " + dossier.rule)
	for m in Rush.MODE:
		button(MODES[m], pick_fighter.bind(m))
	button("Autres dossiers", case_menu)
	button("Menu principal", menu)

func edition_menu(page := 0) -> void:
	phase = "archives"
	var entries: Array = archives.entries()
	sheet("Archives et variantes", "Épreuves de combat inspirées des autres éditions et dérivés.")
	for index in range(page * PAGE_SIZE, mini((page + 1) * PAGE_SIZE, entries.size())):
		var entry: Dictionary = entries[index]
		button(entry.title, edition_details.bind(entry, page))
	page_buttons(page, entries.size(), edition_menu)
	button("Retour", menu)

func edition_details(entry: Dictionary, page: int) -> void:
	case_id = entry.case_id
	edition_id = entry.id
	mode = 0
	route = 0
	stage = int(Saga.CASES[case_id].stage)
	phase = "edition"
	sheet(entry.title, entry.description)
	paragraph("Dossier associé  /  " + str(Saga.CASES[case_id].name))
	button("Lancer l’épreuve", start_exhibition)
	button("Choisir une autre édition", edition_menu.bind(page))
	button("Menu principal", menu)

func start_exhibition() -> void:
	mode = 1
	var dossier: Dictionary = Saga.CASES[case_id]
	chosen = dossier.lead
	enemy = dossier.guests[1]
	stage = dossier.stage
	start_match()

func page_buttons(page: int, count: int, target: Callable) -> void:
	if page > 0: button("‹  Page précédente", target.bind(page - 1))
	if (page + 1) * PAGE_SIZE < count: button("Page suivante  ›", target.bind(page + 1))

func roster_order() -> Array:
	var order := range(Fighter.PROFILES.size())
	if case_id != "":
		var first: int = Saga.CASES[case_id].lead
		order.erase(first)
		order.push_front(first)
	return order

func pick_fighter(m: int, page := 0) -> void:
	mode = m
	phase = "select"
	fighters.clear()
	var order := roster_order()
	if mode == 0 and case_id != "":
		if case_id == "curien": order = [0,1,2,3]
		else:
			order = [6,1] if case_id == "special" else [int(Saga.CASES[case_id].lead)]
			for i in Fighter.PROFILES.size():
				if Fighter.PROFILES[i].home == case_id and i not in order: order.append(i)
	preview = order[page * PAGE_SIZE]
	sheet(MODES[mode], "Choisissez votre combattant." if case_id == "" else str(Saga.CASES[case_id].name))
	for index in range(page * PAGE_SIZE, mini((page + 1) * PAGE_SIZE, order.size())):
		var i: int = order[index]
		var b := button(Fighter.PROFILES[i].title + "   ·   " + Fighter.PROFILES[i].special, choose.bind(i))
		b.focus_entered.connect(preview_fighter.bind(i))
		b.mouse_entered.connect(preview_fighter.bind(i))
	page_buttons(page, order.size(), func(p): pick_fighter(m, p))
	button("Tenues de Kate et Ryan",costumes.show.bind(self,pick_fighter.bind(m,page)))
	button("Retour", rush.courses_menu.bind(self) if mode == Rush.MODE else (menu if case_id == "" else case_details.bind(case_id)))

func preview_fighter(i: int) -> void:
	preview = i
	queue_redraw()

func choose(i: int) -> void:
	chosen = i
	route = 0
	if mode == Rush.MODE:
		rush.enter(self)
		return
	if mode == 0:
		if case_id == "": case_id = Fighter.PROFILES[i].home
		if case_id == "curien":
			story_opponents = Fighter.STORY[chosen]
			story_stages = Fighter.STORY_STAGES[chosen]
		else:
			story_opponents = Saga.opponents(case_id, chosen)
			story_stages = Saga.stages_for(case_id, chosen)
		prepare_story()
	elif mode == 3:
		tournament.assign(range(Fighter.PROFILES.size()))
		tournament.erase(i)
		tournament.shuffle()
		tournament.resize(3)
		enemy = tournament[0]
		stage = 0 if case_id == "" else int(Saga.CASES[case_id].stage)
		bracket()
	else:
		opponent_menu()

func opponent_menu(page := 0) -> void:
	phase = "opponent"
	var order := roster_order()
	sheet("Adversaire", "Choix du joueur 2" if mode == 2 else MODES[mode])
	for index in range(page * PAGE_SIZE, mini((page + 1) * PAGE_SIZE, order.size())):
		var other: int = order[index]
		button(Fighter.PROFILES[other].title, pick_stage.bind(other))
	page_buttons(page, order.size(), opponent_menu)
	button("Retour", pick_fighter.bind(mode))

func pick_stage(i: int, page := 0) -> void:
	enemy = i
	phase = "stage"
	sheet("Arène")
	var order := range(STAGES.size())
	if case_id != "":
		var first: int = Saga.CASES[case_id].stage
		order.erase(first)
		order.push_front(first)
	var note := paragraph("Choisissez le lieu du duel.")
	var revision := sheet_revision
	var describe := func(stage_id: int):
		note.text = str(Saga.STAGE_NOTES.get(stage_id, "Choisissez le lieu du duel."))
		_refit_sheet.call_deferred(revision)
	for index in range(page * PAGE_SIZE, mini((page + 1) * PAGE_SIZE, order.size())):
		var s: int = order[index]
		var choice := button(STAGES[s], begin_at.bind(s))
		choice.focus_entered.connect(describe.bind(s))
		choice.mouse_entered.connect(describe.bind(s))
		if index == page * PAGE_SIZE: describe.call(s)
	page_buttons(page, order.size(), func(p): pick_stage(i, p))
	button("Retour", opponent_menu)

func begin_at(s: int) -> void:
	stage = s
	start_match()

func prepare_story() -> void:
	enemy = story_opponents[route]
	stage = story_stages[route]
	phase = "brief"
	var chapter: String = ["Introduction", "Rival", "Duel final"][route]
	var body: String
	if case_id == "curien":
		body = [INTROS[chosen], RIVALS[chosen], "Dernier relevé du dossier. Le signal revient une fois, puis disparaît."][route]
	else:
		var dossier: Dictionary = Saga.CASES[case_id]
		body = str(dossier[["intro", "rival", "final"][route]])
		if chosen != dossier.lead:
			body = Saga.ALTERNATE_STORIES[chosen][route]
	sheet(chapter + "  /  " + Fighter.PROFILES[chosen].title, body)
	paragraph("%s  ·  Face à %s" % [STAGES[stage], Fighter.PROFILES[enemy].title])
	if case_id != "curien" and route == 0: paragraph(Saga.CASES[case_id].rule)
	button("Entrer dans l’arène", start_match)
	if has_boss_scan():
		paragraph("Analyse AMS · guettez le cercle ouvert sur le point faible. Confirmez un lourd ou un spécial pour interrompre le boss et infliger six dégâts supplémentaires.")
		scan_switch()
	button("Retour au dossier", menu)

func has_boss_scan() -> bool:
	return mode == 0 and route == 2 and enemy == {"hotd2":17, "hotd3":18, "hotd4":21, "scarlet":22}.get(case_id, -1)

func scan_switch() -> void:
	var toggle := CheckButton.new()
	toggle.text = "Analyse AMS du point faible"
	toggle.button_pressed = scan_enabled
	toggle.toggled.connect(func(enabled: bool): scan_enabled = enabled)
	box.add_child(toggle)

# The cue is deterministic, freezes in pause and can pay only once per cycle.
func scan_state() -> String:
	if not scan_enabled or not has_boss_scan(): return ""
	if scan_last_window == floori(elapsed / 240.0): return "confirmé"
	var local_tick := elapsed % 240
	if local_tick >= 90 and local_tick < 135: return "repérage"
	if local_tick >= 135 and local_tick < 177: return "ouvert"
	return ""

func bracket() -> void:
	phase = "bracket"
	sheet("Tournoi AMS", "Élimination directe  /  4 participants")
	paragraph("Demi-finale A     %s   ×   %s" % [Fighter.PROFILES[chosen].title, Fighter.PROFILES[tournament[0]].title])
	paragraph("Demi-finale B     %s   ×   %s" % [Fighter.PROFILES[tournament[1]].title, Fighter.PROFILES[tournament[2]].title])
	if route == 1:
		paragraph("Finale     %s   ×   %s" % [Fighter.PROFILES[chosen].title, Fighter.PROFILES[tournament_finalist].title])
	button("Disputer la finale" if route == 1 else "Disputer ma demi-finale", start_match)
	button("Retour au dossier", menu)

# The two remaining CPU seeds fight with the same move/hit rules as the player.
func simulate_semifinal(a: int, b: int) -> int:
	var scores := [0, 0]
	var sudden := false
	while maxi(scores[0], scores[1]) < 2:
		var f := [Fighter.new(a, 500, 1), Fighter.new(b, 680, -1)]
		for n in 3600:
			var feed := []
			for side in 2:
				var me = f[side]
				var foe = f[1-side]
				var distance := absf(me.x - foe.x)
				var options := ["light","heavy","throw","special"]
				var cmd: String = options.pick_random() if n % 18 == 0 else ""
				if int(me.profile.ammo) > 0 and me.ammo < me.shots_per_special: cmd = "reload"
				var direction := int(signf(foe.x - me.x))
				if distance < 120: direction = -direction if n % 55 < 12 else 0
				feed.append([direction, cmd])
			for side in 2:
				f[side].step(feed[side][0], false, feed[side][1], f[1-side].x)
			resolve_strikes(f, false)
			clamp_positions(f)
			if mini(f[0].health, f[1].health) == 0: break
		if f[0].health != f[1].health:
			scores[0 if f[0].health > f[1].health else 1] += 1
		elif sudden:
			scores[randi_range(0, 1)] += 1
		sudden = f[0].health == f[1].health
	return a if scores[0] == 2 else b

func start_match() -> void:
	if mode == 4: lab.reset_session()
	wins = [0, 0]
	start_round()

func start_round() -> void:
	fighters = [Fighter.new(chosen, 395, 1), Fighter.new(enemy, 885, -1)]
	panel.hide()
	action_queue = ["", ""]
	ai_dir = 0
	ai_key = ""
	ai_crouch = false
	elapsed = 0
	flash = 0
	winner = -1
	clock_ticks = 2100 if case_id == "special" else 3600
	rule_awarded = [false, false]
	scan_last_window = -1
	phase = "fight"
	if mode == Rush.MODE: rush.on_round_start(self)
	if mode == 4: lab.place(self)
	if edition_id != "": archives.start_round(self, edition_id)
	queue_redraw()

func pause_menu() -> void:
	resume_phase = phase
	phase = "pause"
	sheet("Pause", MODES[mode] + "  /  " + STAGES[stage])
	button("Reprendre", resume)
	button("Liste des coups  ·  J1", move_sheet.bind(chosen, return_to_pause))
	if has_boss_scan(): scan_switch()
	if mode == 4:
		button("Mannequin  ·  " + ("garde" if dummy_guard else "immobile"), toggle_dummy)
		button("Atelier technique", lab.open.bind(self))
		button("Réinitialiser", start_round)
	button("Quitter le duel", menu)

func return_to_pause() -> void:
	phase = resume_phase
	pause_menu()

func toggle_dummy() -> void:
	dummy_guard = not dummy_guard
	phase = resume_phase
	pause_menu()

func resume() -> void:
	phase = resume_phase
	panel.hide()
	action_queue = ["",""]
	queue_redraw()

func _input(event: InputEvent) -> void:
	if edition_id != "" and phase == "fight":
		var primary_pad := Input.get_connected_joypads().find(event.device) == 0
		var archive_event: bool = event is InputEventKey or (event is InputEventJoypadButton and primary_pad and event.button_index != JOY_BUTTON_START)
		if archive_event and archives.handle_key(self, edition_id, event):
			action_queue[0] = ""
			get_viewport().set_input_as_handled()
			return
	var key := 0
	var pad := -1
	var side := 0
	if event is InputEventKey:
		if not event.pressed or event.echo: return
		key = event.keycode
	elif event is InputEventJoypadButton:
		if not event.pressed: return
		pad = event.button_index
		var devices := Input.get_connected_joypads()
		side = devices.find(event.device)
		if side < 0 or side > 1 or (side == 1 and mode != 2): return
	else: return
	if key == KEY_ESCAPE or pad == JOY_BUTTON_START:
		if phase == "bestiary_detail": bestiary.show(self, bestiary.page)
		elif phase == "costumes" and costumes.back.is_valid(): costumes.back.call()
		elif phase == "lab": return_to_pause()
		elif phase == "pause": resume()
		elif phase in ["fight", "finish"]: pause_menu()
		elif phase == "menu": exit_requested.emit()
		elif phase == "moves" and moves_return.is_valid(): moves_return.call()
		elif phase == "cinematic": return
		else: menu()
		get_viewport().set_input_as_handled()
		return
	if mode == 4 and phase == "fight" and lab.speed == 2 and (key in [KEY_PERIOD,KEY_N] or pad == JOY_BUTTON_RIGHT_STICK):
		lab.pending_steps += 1
		get_viewport().set_input_as_handled()
		return
	if not phase in ["fight", "finish"]: return
	var command: String
	if pad >= 0:
		command = {JOY_BUTTON_A:"light", JOY_BUTTON_X:"heavy", JOY_BUTTON_B:"special", JOY_BUTTON_Y:"throw", JOY_BUTTON_LEFT_SHOULDER:"reload", JOY_BUTTON_RIGHT_SHOULDER:"finish", JOY_BUTTON_DPAD_UP:"jump",JOY_BUTTON_LEFT_STICK:"taunt"}.get(pad, "")
	else:
		command = {KEY_UP:"jump", KEY_J:"light", KEY_K:"heavy", KEY_L:"special", KEY_U:"throw", KEY_R:"reload", KEY_I:"finish",KEY_O:"taunt"}.get(key, "")
		if command == "" and mode == 2:
			side = 1
			command = {KEY_Z:"jump", KEY_W:"jump", KEY_F:"light", KEY_G:"heavy", KEY_H:"special", KEY_T:"throw", KEY_E:"reload", KEY_Y:"finish",KEY_C:"taunt"}.get(key, "")
	if side == 0 and key in [KEY_J, KEY_K] and Input.is_key_pressed(KEY_J) and Input.is_key_pressed(KEY_K): command = "throw"
	if side == 1 and key in [KEY_F, KEY_G] and Input.is_key_pressed(KEY_F) and Input.is_key_pressed(KEY_G): command = "throw"
	if command == "": return
	get_viewport().set_input_as_handled()
	if phase == "finish" and command == "finish" and side == winner:
		trigger_finisher()
	elif phase == "fight" and command != "finish":
		action_queue[side] = command

func _physics_process(_delta: float) -> void:
	if phase == "finish":
		finish_ticks -= 1
		if finish_ticks <= 0: end_match()
		queue_redraw()
		return
	if phase == "cinematic":
		finish_ticks -= 1
		if finish_ticks <= 0: end_match()
		queue_redraw()
		return
	if phase != "fight": return
	if mode == 4 and not lab.allow_tick(): return
	elapsed += 1
	flash = maxi(0, flash - 1)
	if mode != 4: clock_ticks -= 1
	var devices := Input.get_connected_joypads()
	for side in 2:
		var me = fighters[side]
		var foe = fighters[1-side]
		var command: String = action_queue[side]
		var axis := 0
		var down := false
		if side == 0 or mode == 2:
			if side == 0:
				axis = int(Input.is_key_pressed(KEY_RIGHT)) - int(Input.is_key_pressed(KEY_LEFT))
				down = Input.is_key_pressed(KEY_DOWN)
			else:
				axis = int(Input.is_key_pressed(KEY_D)) - int(Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_A))
				down = Input.is_key_pressed(KEY_S)
			if side < devices.size():
				var device := devices[side]
				var up := Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) < -0.65
				if up and not stick_up[side]: command = "jump"
				stick_up[side] = up
				var analog := Input.get_joy_axis(device, JOY_AXIS_LEFT_X)
				if absf(analog) > 0.45: axis = int(signf(analog))
				if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_LEFT): axis = -1
				if Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_RIGHT): axis = 1
				down = down or Input.is_joy_button_pressed(device, JOY_BUTTON_DPAD_DOWN) or Input.get_joy_axis(device, JOY_AXIS_LEFT_Y) > 0.55
		elif mode == 4:
			axis = -me.facing if dummy_guard else 0
		else:
			cpu_input(me, foe)
			axis = ai_dir
			down = ai_crouch
			command = ai_key
		if side == 0 and edition_id != "" and archives.terminal:
			axis = 0
			down = false
			command = ""
		var old_x: float = me.x
		var previous_action: String = me.action
		var had_hit: bool = me.confirmed
		me.step(axis, down, command, foe.x)
		if mode == 4 and side == 0: lab.observe_action(me,previous_action,had_hit)
		if mode == 4 and side == 1: me.x = old_x
		if command == "reload" and me.action == "reload" and me.tick == 1: sound("reload")
		if me.action == "special" and me.tick == int(me.move_data().start):
			sound("shot" if int(me.profile.ammo) > 0 else "boss_projectile" if me.id == 3 else "boss_telegraph")
	action_queue = ["",""]
	resolve_strikes(fighters, true)
	if case_id != "" and mode != 4: Saga.apply_rule(self, case_id)
	if edition_id != "": archives.tick(self, edition_id)
	clamp_positions(fighters)
	if mode == 4:
		if fighters[1].health == 0: fighters[1].health = 100
	elif fighters[0].health == 0 or fighters[1].health == 0 or clock_ticks <= 0:
		round_over()
	queue_redraw()

func clamp_positions(pair: Array) -> void:
	var d: float = pair[1].x - pair[0].x
	if absf(d) < 62 and absf(pair[0].altitude - pair[1].altitude) < 90:
		var push := (62 - absf(d)) / 2 * (1 if d >= 0 else -1)
		pair[0].x -= push
		pair[1].x += push
	for f in pair:
		f.x = clampf(f.x, 75, 1205)

func resolve_strikes(pair: Array, live: bool) -> void:
	var strikes := [pair[0].can_strike(pair[1]), pair[1].can_strike(pair[0])]
	for side in 2:
		if not strikes[side]: continue
		var previous_health: int = pair[1-side].health
		var was_guarding: bool = pair[1-side].guarding
		var hit: bool = pair[side].hit(pair[1-side])
		if live and mode == 4 and side == 0:
			lab.impact(self,pair[side],hit,was_guarding,previous_health-pair[1-side].health)
		if live:
			flash = 6
			impact_guard = not hit
			var target = pair[1-side]
			if side == 0 and hit and pair[0].action in ["special","heavy"] and scan_state() == "ouvert":
				scan_last_window = floori(elapsed / 240.0)
				target.health = maxi(0, target.health - 6)
				target.stun = maxi(23, target.stun)
			impact_position = Vector2(target.x-18*pair[side].facing, target.altitude+float(target.profile.height)*0.54)
			sound("hit" if hit else "ui_back")
	for side in 2:
		if strikes[side] and pair[1-side].stun > 0:
			pair[1-side].action = ""
			pair[1-side].buffer_ticks = 0

func cpu_input(me, foe) -> void:
	ai_key = ""
	if elapsed % 12 != 1: return
	var direction := int(signf(foe.x - me.x))
	var distance := absf(me.x - foe.x)
	ai_dir = direction if distance > 118 else 0
	ai_crouch = false
	if int(me.profile.ammo) > 0 and me.ammo < me.shots_per_special and distance > 190:
		ai_key = "reload"
	elif foe.action != "" and randf() < 0.30:
		ai_dir = -direction
		ai_crouch = foe.action == "special"
	elif distance < 150:
		ai_key = ["heavy", "light", "light", "throw", "special"].pick_random()
	elif distance < float(me.profile.move.reach) and randf() < 0.36:
		ai_key = "special"

	if ai_key == "special":
		if me.profile.kind == "frost": ai_crouch = distance <= int(me.profile.alt_move.reach) and (foe.crouching or randf() < 0.45)
		if me.profile.kind == "canopy": ai_crouch = distance >= 150 and distance <= int(me.profile.alt_move.reach) and (foe.altitude > 0 or randf() < 0.4)

func round_over() -> void:
	if mode == Rush.MODE:
		rush.decide(self)
		return
	if fighters[0].health == fighters[1].health:
		phase = "round"
		sheet("Égalité", "La manche est rejouée.")
		button("Rejouer", start_round)
		return
	winner = 0 if fighters[0].health > fighters[1].health else 1
	wins[winner] += 1
	if wins[winner] >= 2:
		if clock_ticks > 0:
			phase = "finish"
			finish_ticks = 150
			if winner == 1 and mode != 2: trigger_finisher()
		else: end_match()
	else:
		phase = "round"
		sheet("Manche remportée", "%s   /   %d – %d" % [Fighter.PROFILES[fighters[winner].id].title,wins[0],wins[1]])
		button("Manche suivante", start_round)

func trigger_finisher() -> void:
	phase = "cinematic"
	finish_ticks = 72
	sound("shot" if int(fighters[winner].profile.ammo) > 0 else "hit")

func end_match() -> void:
	phase = "result"
	if mode == Rush.MODE:
		rush.show_result(self)
		return
	var winner_name: String = Fighter.PROFILES[fighters[winner].id].title
	if mode == 0 and winner == 0 and route == 2:
		var ending: String = ENDINGS[chosen] if case_id == "curien" else str(Saga.CASES[case_id].ending)
		if case_id != "curien" and chosen != Saga.CASES[case_id].lead:
			ending = Saga.ALTERNATE_STORIES[chosen][3]
		sheet("Épilogue  /  " + winner_name, ending)
	elif mode == 3 and winner == 0 and route == 1:
		sheet("Champion du tournoi", winner_name + " remporte la finale.")
	else:
		sheet("Victoire  /  " + winner_name, "%s   ·   %d – %d" % [STAGES[stage],wins[0],wins[1]])
	if mode == 0 and winner == 0 and route < 2:
		button("Ouvrir le relevé suivant", next_story)
	elif mode == 3 and winner == 0 and route == 0:
		button("Voir la finale", next_tournament)
	elif mode != 3:
		button("Rejouer ce duel", start_match)
	button("Retour au dossier", menu)

func next_story() -> void:
	route += 1
	prepare_story()

func next_tournament() -> void:
	tournament_finalist = simulate_semifinal(tournament[1], tournament[2])
	enemy = tournament_finalist
	route = 1
	stage = 2 if case_id == "" else int(Saga.CASES[case_id].stage)
	bracket()

func _draw() -> void:
	var view_scale := minf(size.x / 1280.0, size.y / 720.0)
	if view_scale <= 0: return
	visuals.origin_transform = Transform2D(0.0, Vector2.ONE * view_scale, 0.0, (size - Vector2(1280, 720) * view_scale) / 2)
	draw_set_transform_matrix(visuals.origin_transform)
	visuals.draw(self)
