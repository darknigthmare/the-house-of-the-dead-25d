extends Control

signal exit_requested

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
const STAGES := ["Cour du manoir", "Antichambre", "Laboratoire de Curien"]
const MODES := ["Histoire", "Duel contre IA", "Duel local", "Tournoi", "Entraînement"]
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
var stick_up := [false, false]

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	visuals.load_textures()
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
	if phase in ["select","brief"] or (phase == "result" and mode == 0 and route == 2 and winner == 0):
		panel.position.x = size.x * 0.055
		panel.grow_horizontal = Control.GROW_DIRECTION_END
	var h := Label.new()
	h.text = title
	h.add_theme_font_size_override("font_size", 30)
	h.add_theme_color_override("font_color", Color("e1c08a"))
	box.add_child(h)
	if subtitle != "": paragraph(subtitle)
	queue_redraw()

func paragraph(line: String) -> void:
	var p := Label.new()
	p.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	p.custom_minimum_size.x = 505
	p.text = line
	box.add_child(p)

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
	phase = "menu"
	fighters.clear()
	sheet("DOSSIER CURIEN", "Simulation de combat AMS  /  Domaine Curien")
	for m in MODES.size():
		button(MODES[m], pick_fighter.bind(m))
	button("Commandes", controls)
	button("Retour à l’arcade", func(): exit_requested.emit())

func controls() -> void:
	phase = "controls"
	sheet("Commandes")
	paragraph("J1 · Flèches pour se déplacer, ↑ pour sauter, ↓ pour se baisser. Maintenir arrière pour garder. J léger, K lourd, L spécial, U projection, R recharge, I finition.")
	paragraph("J2 · Q/D ou A/D, Z ou W pour sauter, S pour se baisser. F léger, G lourd, H spécial, T projection, E recharge, Y finition.")
	paragraph("Manette · Croix ou stick pour se déplacer. A léger, X lourd, B spécial, Y projection, LB recharge, RB finition, Start pause. Une manette pilote J1, deux permettent le duel local.")
	paragraph("Un léger confirmé s’enchaîne en lourd puis en spécial. La projection ouvre la garde. Un tir AMS passe au-dessus d’une cible accroupie.")
	button("Retour", menu)

func pick_fighter(m: int) -> void:
	mode = m
	phase = "select"
	fighters.clear()
	sheet(MODES[mode], "Choisissez votre combattant.")
	for i in Fighter.NAMES.size():
		var b := button(Fighter.NAMES[i] + "   ·   " + Fighter.SPECIAL_NAMES[i], choose.bind(i))
		b.focus_entered.connect(preview_fighter.bind(i))
		b.mouse_entered.connect(preview_fighter.bind(i))
	button("Retour", menu)

func preview_fighter(i: int) -> void:
	preview = i
	queue_redraw()

func choose(i: int) -> void:
	chosen = i
	route = 0
	if mode == 0:
		prepare_story()
	elif mode == 3:
		tournament.assign([0, 1, 2, 3])
		tournament.erase(i)
		tournament.shuffle()
		enemy = tournament[0]
		stage = 0
		bracket()
	else:
		phase = "opponent"
		sheet("Adversaire", "Choix du joueur 2" if mode == 2 else MODES[mode])
		for other in Fighter.NAMES.size():
			button(Fighter.NAMES[other], pick_stage.bind(other))
		button("Retour", pick_fighter.bind(mode))

func pick_stage(i: int) -> void:
	enemy = i
	phase = "stage"
	sheet("Arène")
	for s in STAGES.size():
		button(STAGES[s], begin_at.bind(s))
	button("Retour", choose.bind(chosen))

func begin_at(s: int) -> void:
	stage = s
	start_match()

func prepare_story() -> void:
	enemy = Fighter.STORY[chosen][route]
	stage = Fighter.STORY_STAGES[chosen][route]
	phase = "brief"
	var chapter: String = ["Introduction", "Rival", "Duel final"][route]
	var body: String = [INTROS[chosen], RIVALS[chosen], "Dernier relevé du dossier. Le signal revient une fois, puis disparaît."][route]
	sheet(chapter + "  /  " + Fighter.NAMES[chosen], body)
	paragraph("%s  ·  Face à %s" % [STAGES[stage], Fighter.NAMES[enemy]])
	button("Entrer dans l’arène", start_match)
	button("Retour au dossier", menu)

func bracket() -> void:
	phase = "bracket"
	sheet("Tournoi AMS", "Élimination directe  /  4 participants")
	paragraph("Demi-finale A     %s   ×   %s" % [Fighter.NAMES[chosen], Fighter.NAMES[tournament[0]]])
	paragraph("Demi-finale B     %s   ×   %s" % [Fighter.NAMES[tournament[1]], Fighter.NAMES[tournament[2]]])
	if route == 1:
		paragraph("Finale     %s   ×   %s" % [Fighter.NAMES[chosen], Fighter.NAMES[tournament_finalist]])
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
				if me.ammo == 0 and me.id < 2: cmd = "reload"
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
	clock_ticks = 3600
	phase = "fight"
	queue_redraw()

func pause_menu() -> void:
	resume_phase = phase
	phase = "pause"
	sheet("Pause", MODES[mode] + "  /  " + STAGES[stage])
	button("Reprendre", resume)
	if mode == 4:
		button("Mannequin  ·  " + ("garde" if dummy_guard else "immobile"), toggle_dummy)
		button("Réinitialiser", start_round)
	button("Quitter le duel", menu)

func toggle_dummy() -> void:
	dummy_guard = not dummy_guard
	phase = resume_phase
	pause_menu()

func resume() -> void:
	phase = resume_phase
	panel.hide()
	action_queue = ["",""]

func _input(event: InputEvent) -> void:
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
		if phase == "pause": resume()
		elif phase in ["fight", "finish"]: pause_menu()
		elif phase == "menu": exit_requested.emit()
		elif phase == "cinematic": return
		else: menu()
		get_viewport().set_input_as_handled()
		return
	if not phase in ["fight", "finish"]: return
	var command: String
	if pad >= 0:
		command = {JOY_BUTTON_A:"light", JOY_BUTTON_X:"heavy", JOY_BUTTON_B:"special", JOY_BUTTON_Y:"throw", JOY_BUTTON_LEFT_SHOULDER:"reload", JOY_BUTTON_RIGHT_SHOULDER:"finish", JOY_BUTTON_DPAD_UP:"jump"}.get(pad, "")
	else:
		command = {KEY_UP:"jump", KEY_J:"light", KEY_K:"heavy", KEY_L:"special", KEY_U:"throw", KEY_R:"reload", KEY_I:"finish"}.get(key, "")
		if command == "" and mode == 2:
			side = 1
			command = {KEY_Z:"jump", KEY_W:"jump", KEY_F:"light", KEY_G:"heavy", KEY_H:"special", KEY_T:"throw", KEY_E:"reload", KEY_Y:"finish"}.get(key, "")
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
		var old_x: float = me.x
		me.step(axis, down, command, foe.x)
		if mode == 4 and side == 1: me.x = old_x
		if command == "reload" and me.action == "reload" and me.tick == 1: sound("reload")
	action_queue = ["",""]
	resolve_strikes(fighters, true)
	clamp_positions(fighters)
	if mode == 4:
		if fighters[1].health == 0: fighters[1].health = 100
	elif fighters[0].health == 0 or fighters[1].health == 0 or clock_ticks == 0:
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
		var hit: bool = pair[side].hit(pair[1-side])
		if live:
			flash = 6
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
	if me.id < 2 and me.ammo == 0 and distance > 190:
		ai_key = "reload"
	elif foe.action != "" and randf() < 0.30:
		ai_dir = -direction
		ai_crouch = foe.action == "special"
	elif distance < 150:
		ai_key = ["heavy", "light", "light", "throw", "special"].pick_random()
	elif distance < float(Fighter.SPECIALS[me.id].reach) and randf() < 0.36:
		ai_key = "special"

func round_over() -> void:
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
		sheet("Manche remportée", "%s   /   %d – %d" % [Fighter.NAMES[fighters[winner].id],wins[0],wins[1]])
		button("Manche suivante", start_round)

func trigger_finisher() -> void:
	phase = "cinematic"
	finish_ticks = 72
	sound("shot" if fighters[winner].id < 2 else "hit")

func end_match() -> void:
	phase = "result"
	var winner_name: String = Fighter.NAMES[fighters[winner].id]
	if mode == 0 and winner == 0 and route == 2:
		sheet("Épilogue  /  " + winner_name, ENDINGS[chosen])
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
	stage = 2
	bracket()

func _draw() -> void:
	var view_scale := minf(size.x / 1280.0, size.y / 720.0)
	if view_scale <= 0: return
	visuals.origin_transform = Transform2D(0.0, Vector2.ONE * view_scale, 0.0, (size - Vector2(1280, 720) * view_scale) / 2)
	draw_set_transform_matrix(visuals.origin_transform)
	visuals.draw(self)
