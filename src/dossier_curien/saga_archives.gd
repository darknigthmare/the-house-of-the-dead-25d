extends RefCounted

# Published source titles and their original combat adaptations.
const CATALOG := [
	{"id": "typing", "title": "The Typing of the Dead", "case_id": "hotd2", "rule": "word", "description": "Saisir les appels de la radio du canal. Un mot complet interrompt l’adversaire.", "words": ["CANAL", "PONT", "RADIO", "QUAI"]},
	{"id": "typing2", "title": "The Typing of the Dead 2", "case_id": "hotd3", "rule": "word", "description": "Saisir le vocabulaire du centre EFI. Une confirmation rend aussi une cartouche à Lisa.", "words": ["ALARME", "DOSSIER", "ARCHIVE", "SECOURS"]},
	{"id": "typing_overkill", "title": "The Typing of the Dead: Overkill", "case_id": "overkill", "rule": "word", "description": "Remonter la bobine mot à mot. Les termes sont ceux d’un tournage à Bayou City.", "words": ["BOBINE", "MOTEUR", "CADRE", "COUPEZ"]},
	{"id": "english", "title": "English of the Dead", "case_id": "hotd2", "rule": "translation", "description": "Lire le mot français et saisir sa traduction anglaise. Une réponse correcte étourdit le rival."},
	{"id": "flick", "title": "Zombie Da: Flick of the Dead", "case_id": "hotd2", "rule": "flick", "description": "Reproduire trois directions successives avec les flèches ou la croix. La dernière libère une onde."},
	{"id": "ktyping", "title": "K-Typing of the Dead", "case_id": "hotd2", "rule": "word", "description": "Saisir des mots courts sur le terminal de poche. Les mots reprennent le format bref de l’écran.", "words": ["SOS", "LAC", "RUE", "BUS"]},
	{"id": "pinball", "title": "The Pinball of the Dead", "case_id": "hotd2", "rule": "pinball", "description": "Suivre la bille sur le mini-plateau. Près du bas, Tab ou View actionne le batteur. Le troisième retour frappe le rival."},
	{"id": "darts", "title": "Darts of the Dead", "case_id": "curien", "rule": "darts", "description": "Une cible balaie la réglette. Tab ou View lance une fléchette. Viser la bande centrale pour toucher."},
	{"id": "site", "title": "The Site of the Dead", "case_id": "curien", "rule": "lab", "description": "Élever un spécimen en duel. Un coup léger, un lourd et une projection confirmés le font évoluer et rendent de la vie."},
	{"id": "mobile", "title": "The House of the Dead Mobile", "case_id": "curien", "rule": "battery", "description": "Gérer la batterie du terminal. Une attaque spéciale confirmée la vide, une parade tenue la recharge."},
	{"id": "nightmare", "title": "The House of the Dead: Nightmare", "case_id": "curien", "rule": "sector", "description": "Traverser le secteur signalé au sol. Trois passages alternés donnent une ouverture sur le rival."},
	{"id": "extended", "title": "Overkill – Extended Cut", "case_id": "overkill", "rule": "reel", "description": "Monter une prise complète. Confirmer un léger, un lourd puis un spécial dans cet ordre, sur autant d’échanges que nécessaire."},
	{"id": "lost", "title": "Overkill – The Lost Reels", "case_id": "overkill", "rule": "sector", "description": "Retrouver trois fragments de bobine en passant d’un repère latéral à l’autre."},
	{"id": "return", "title": "The House of the Dead 2 & 3 Return", "case_id": "hotd2", "rule": "relay", "description": "Rejouer la sélection Wii sous forme de relais. Les manches alternent entre le canal du II et le poste de sécurité du III."},
	{"id": "remake", "title": "The House of the Dead: Remake", "case_id": "curien", "rule": "rescue", "description": "Remplir une fenêtre de secours de six secondes. Confirmer un lourd ou un spécial pendant le signal rend six points de vie."},
	{"id": "remake2", "title": "The House of the Dead 2: Remake", "case_id": "hotd2", "rule": "rescue", "description": "L’appel du quai revient par intermittence. Un lourd ou un spécial confirmé pendant l’appel ajoute du temps à la manche."},
	{"id": "attraction", "title": "Scarlet Dawn – The Attraction", "case_id": "scarlet", "rule": "sector", "description": "Rejoindre trois postes lumineux tirés de la salle collective. Les postes s’activent en alternance."},
	{"id": "genesis", "title": "Scarlet Dawn – Battle Genesis", "case_id": "scarlet", "rule": "reel", "description": "Réaliser la combinaison légère, lourde, spéciale. Les trois symboles complétés déclenchent un impact."},
	{"id": "reels", "title": "Scarlet Dawn on Reels", "case_id": "scarlet", "rule": "locks", "description": "Arrêter trois bandes lumineuses sur le centre. Tab ou View verrouille la bande active. Trois verrous réussis déclenchent un impact."},
	{"id": "panic", "title": "The Typing of the Dead: Zombie Panic", "case_id": "hotd2", "rule": "word", "description": "Transcrire les messages d’alerte dans une réserve de mots propre à cette édition.", "words": ["FUITE", "VITE", "ALERTE", "ABRI"]},
	{"id": "online", "title": "The Typing of the Dead Online", "case_id": "hotd2", "rule": "word", "description": "Rejouer en solo une série de transmission. Les mots appartiennent au lexique des communications.", "words": ["ENVOI", "RELAIS", "RESEAU", "SIGNAL"]},
	{"id": "t2003", "title": "The Typing of the Dead 2003", "case_id": "hotd2", "rule": "word", "description": "Réviser une série autour de la ville inondée. Chaque saisie correcte facilite le prochain échange.", "words": ["VILLE", "DIGUE", "PORTE", "RIVE"]},
	{"id": "t2004", "title": "The Typing of the Dead 2004", "case_id": "hotd2", "rule": "word", "description": "Série de saisie consacrée aux lieux de passage de l’enquête.", "words": ["PASSAGE", "TUNNEL", "RUELLE", "COULOIR"]},
	{"id": "rakuten", "title": "The Typing of the Dead featuring Rakuten", "case_id": "hotd2", "rule": "word", "description": "Saisir le lexique du bureau. Une transmission correcte déclenche une ouverture.", "words": ["BUREAU", "POSTE", "DOSSIER", "PROJET"]},
	{"id": "lariat", "title": "Zombie Da: Typing Lariat for Mac", "case_id": "hotd2", "rule": "word", "description": "Épreuve de frappe réservée aux mots du corps-à-corps, dans la simulation du canal.", "words": ["PRISE", "GARDE", "APPUI", "POING"]},
	{"id": "typing_us", "title": "The Typing of the Dead US Edition", "case_id": "hotd2", "rule": "word", "description": "Appels de secours en anglais. Transmettre le mot affiché au poste du quai pour interrompre le rival.", "words": ["BRIDGE", "DOCK", "FERRY", "RESCUE"]},
	{"id": "typing_budget", "title": "The Typing of the Dead · réédition PC 2005", "case_id": "hotd2", "rule": "word", "description": "Réédition à prix révisé. Dans cet exercice AMS, une saisie courte rend une seconde, dans la limite du temps initial.", "words": ["BUS", "BAC", "CLE", "RUE"]},
	{"id": "lariat_win", "title": "Zombie Da: Typing Lariat · Windows", "case_id": "hotd2", "rule": "word", "description": "Valider un ordre de lutte pour prolonger l’étourdissement du rival, puis s’approcher pour la projection.", "words": ["SAISIR", "PIVOTER", "CEINTURER", "PROJETER"]},
	{"id": "reawakened", "title": "House of the Dead: Reawakened", "case_id": "curien", "rule": "openings", "description": "Les trois ouvertures. La borne VR propose trois missions en solo ou en coopération. Dans ce duel AMS, surveillez le volet gauche, la porte puis le volet droit. Appuyez sur Tab ou View, ou touchez le rival pendant chaque ouverture verte. Une série complète enlève 12 PV. Une ouverture manquée annule la série."},
]
const OPENINGS := ["Volet gauche", "Porte de face", "Volet droit"]
const SIGNAL_TICKS := 120
const SIGNAL_START := 48
const SIGNAL_END := 96
const TRANSLATIONS := [["PORTE", "DOOR"], ["CLEF", "KEY"], ["EAU", "WATER"], ["PONT", "BRIDGE"]]
const BUMPERS := [Vector2(31,23),Vector2(64,33),Vector2(97,19)]
const ARROWS := ["←", "↑", "→", "↓"]
const FLICK_PATTERNS := [[0, 1, 2], [3, 0, 2], [1, 2, 3], [2, 0, 1]]
const STEPS := ["light", "heavy", "special"]
const NAMES := {"light":"léger", "heavy":"lourd", "throw":"projection", "special":"spécial"}
var active: Dictionary = {}
var age := 0
var score := 0
var cursor := 0
var typed := ""
var terminal := false
var pad_input := false
var cycle := 0
var progress := 0
var charge := 100
var last_hp := 100
var next_award := 0
var captured: Array = []
var feedback := ""
var feedback_until := 0
var last_bumper := -30
var ball := Vector2(38, 16)
var velocity := Vector2(1.6, 0.65)

func entries() -> Array:
	return CATALOG.duplicate(true)

func start_round(arena, edition_id: String) -> void:
	active = {}
	for item in CATALOG:
		if item.id == edition_id:
			active = item
			break
	age = 0
	score = 0
	cycle = 0
	progress = 0
	charge = 100
	next_award = 0
	captured = []
	last_hp = int(arena.fighters[1].health)
	reset_terminal()
	feedback = ""
	feedback_until = 0
	last_bumper = -30
	ball = Vector2(38, 16)
	velocity = Vector2(1.6, 0.65)
	if edition_id == "return":
		arena.stage = 4 if (arena.wins[0] + arena.wins[1]) % 2 == 1 else 3

func reset_terminal() -> void:
	terminal = false
	pad_input = false
	typed = ""
	cursor = 0

func tell(msg: String) -> void:
	feedback = msg
	feedback_until = age + 72

func reward(arena, msg: String, impact := 7) -> void:
	score += 1
	arena.fighters[1].health = maxi(0, int(arena.fighters[1].health) - impact)
	arena.fighters[1].stun = maxi(14, int(arena.fighters[1].stun))
	last_hp = int(arena.fighters[1].health)
	tell(msg)
	arena.sound("boss_telegraph")

func target_word() -> String:
	if active.rule == "translation": return TRANSLATIONS[cycle % TRANSLATIONS.size()][1]
	return active.words[cycle % active.words.size()]

func tick(arena, _edition_id: String) -> void:
	if active.is_empty(): return
	age += 1
	var f = arena.fighters[0]
	var foe = arena.fighters[1]
	var landed: bool = int(foe.health) < last_hp and bool(f.confirmed)
	match active.rule:
		"openings":
			if age % (SIGNAL_TICKS * OPENINGS.size()) == 0: progress = 0
			if age % SIGNAL_TICKS == SIGNAL_END and progress == opening_index():
				progress = 0
			if landed: confirm_opening(arena)
		"pinball":
			ball += velocity
			if ball.x <= 4 or ball.x >= 124:
				ball.x = clampf(ball.x, 4, 124)
				velocity.x *= -1
			if ball.y <= 4:
				ball.y = 4
				velocity.y = absf(velocity.y)
			if age - last_bumper > 8:
				for bumper: Vector2 in BUMPERS:
					var relative := ball - bumper
					if relative.length_squared() > 52.0 or velocity.dot(relative) >= 0: continue
					var normal := relative.normalized()
					ball = bumper + normal * 7.3
					velocity = velocity.bounce(normal).limit_length(2.35)
					last_bumper = age
					break
			velocity.y = minf(velocity.y + 0.014, 1.7)
			if ball.y > 70:
				ball = Vector2(30 + (age % 60), 12)
				velocity = Vector2(1.6, 0.55)
				progress = 0
				tell("Bille perdue · nouveau service")
			elif landed and ball.y >= 44:
				flipper(arena)
		"lab":
			if landed and f.action in ["light","heavy","throw"] and not f.action in captured:
				captured.append(f.action)
				if captured.size() == 3:
					captured.clear()
					f.health = mini(100, int(f.health) + 7)
					reward(arena, "Évolution · 7 PV restaurés", 3)
		"reel":
			if landed and f.action == STEPS[progress]:
				progress += 1
				if progress == STEPS.size():
					progress = 0
					reward(arena, "Prise complète")
		"battery":
			if f.guarding: charge = mini(100, charge + 1)
			if landed and f.action == "special":
				if charge >= 40:
					charge -= 40
					reward(arena, "Signal amplifié", 4)
				else: tell("Batterie faible · maintenir la garde")
		"sector":
			var target_x := 340 if progress % 2 == 0 else 930
			if absf(f.x - target_x) < 63 and age >= next_award:
				next_award = age + 45
				progress += 1
				tell("Balise validée")
				if progress == 3:
					progress = 0
					reward(arena, "Trois balises reliées", 10)
		"rescue":
			if age % 720 < 360 and age >= next_award and landed and f.action in ["heavy","special"]:
				if active.id == "remake": f.health = mini(100, int(f.health) + 6)
				else: arena.clock_ticks += 180
				next_award = age - (age % 720) + 720
				reward(arena, "Secours confirmé", 2)
		"relay":
			if age >= next_award and landed and f.action == ("special" if arena.stage == 3 else "heavy"):
				next_award = age + 240
				reward(arena, "Relais confirmé", 4)
	last_hp = int(foe.health)

func opening_index() -> int:
	return floori(age / float(SIGNAL_TICKS)) % OPENINGS.size()

func opening_live() -> bool:
	var clock := age % SIGNAL_TICKS
	return clock >= SIGNAL_START and clock < SIGNAL_END

func confirm_opening(arena) -> void:
	if not opening_live() or progress != opening_index(): return
	progress += 1
	if progress == OPENINGS.size(): reward(arena, "Trois ouvertures sécurisées", 12)
	else: arena.sound("ui_confirm")

func flipper(arena) -> void:
	if ball.y < 44 or velocity.y <= 0:
		tell("Attendre la descente de la bille")
		return
	velocity.y = -1.7
	progress += 1
	if progress == 3:
		progress = 0
		reward(arena, "Troisième retour · jackpot", 12)
	else: tell("Retour %d/3" % progress)

func meter() -> float:
	var rate := 2.25 if active.rule == "darts" else 1.6 + progress * 0.35
	return pingpong((age * rate) + progress * 17.0, 100.0)

func action_button(arena) -> void:
	match active.rule:
		"openings": confirm_opening(arena)
		"pinball": flipper(arena)
		"darts","locks":
			if age < next_award: return
			next_award = age + 15
			if absf(meter() - 50.0) <= 12.0:
				if active.rule == "darts": reward(arena, "Dans le mille", 6)
				else:
					progress += 1
					if progress == 3:
						progress = 0
						reward(arena, "Trois rouleaux alignés", 12)
					else: tell("Rouleau bloqué")
			else: tell("Hors du centre")
		"word","translation","flick":
			terminal = not terminal
			typed = ""
			cursor = 0

func handle_key(arena, _edition_id: String, event: InputEvent) -> bool:
	if active.is_empty(): return false
	var key := 0
	var pad := -1
	if event is InputEventKey:
		if not event.pressed or event.echo: return false
		key = event.keycode
	elif event is InputEventJoypadButton:
		if not event.pressed: return false
		pad = event.button_index
	else: return false
	if key == KEY_TAB or pad == JOY_BUTTON_BACK:
		if not active.rule in ["pinball","darts","locks","word","translation","flick","openings"]: return false
		action_button(arena)
		pad_input = pad >= 0
		return true
	if not terminal: return false
	if key == KEY_ESCAPE:
		reset_terminal()
		return true
	if pad == JOY_BUTTON_START: return false
	var direction: int = {KEY_LEFT:0,KEY_UP:1,KEY_RIGHT:2,KEY_DOWN:3}.get(key, -1)
	if pad >= 0: direction = {JOY_BUTTON_DPAD_LEFT:0,JOY_BUTTON_DPAD_UP:1,JOY_BUTTON_DPAD_RIGHT:2,JOY_BUTTON_DPAD_DOWN:3}.get(pad, -1)
	if active.rule == "flick" or pad >= 0:
		if direction < 0: return true
		var expected := expected_dir()
		if direction == expected: cursor += 1
		else:
			cursor = 0
			tell("Reprendre la séquence")
		if cursor >= (3 if active.rule == "flick" else target_word().length()): complete_word(arena)
		return true
	if key == KEY_BACKSPACE:
		typed = typed.left(maxi(0, typed.length()-1))
		return true
	if key == KEY_ENTER or key == KEY_KP_ENTER:
		if typed == target_word(): complete_word(arena)
		else:
			typed = ""
			tell("Reprendre le mot")
		return true
	if event is InputEventKey and event.unicode >= 32:
		var letter := String.chr(event.unicode).to_upper()
		if letter.length() == 1 and "ABCDEFGHIJKLMNOPQRSTUVWXYZ".contains(letter) and typed.length() < 12: typed += letter
	return true

func expected_dir() -> int:
	if active.rule == "flick": return FLICK_PATTERNS[cycle % FLICK_PATTERNS.size()][cursor]
	return (int(target_word().unicode_at(cursor)) - 65) % 4

func complete_word(arena) -> void:
	reward(arena, "Transmission reçue", 8)
	if active.id == "typing2":
		var player = arena.fighters[0]
		player.ammo = mini(int(player.profile.ammo), int(player.ammo) + 1)
	if active.id == "typing_budget":
		arena.clock_ticks = mini(3600, arena.clock_ticks+60)
	elif active.id == "lariat_win":
		arena.fighters[1].stun = maxi(32, arena.fighters[1].stun)
	cycle += 1
	reset_terminal()

func hud_line(arena, _edition_id: String) -> String:
	if active.is_empty(): return ""
	if active.rule == "openings":
		var slot := opening_index()
		var state := "OUVERT" if opening_live() else "fermé"
		if progress > slot: state = "validé"
		elif progress < slot: state = "reprendre au volet gauche"
		return "Les trois ouvertures  ·  %s  ·  %s  ·  %d/3  ·  Séries %d  ·  Tab / View ou touche confirmée" % [OPENINGS[slot],state,progress,score]
	if feedback_until > age and not terminal: return feedback
	var button := "Tab / View"
	match active.rule:
		"word","translation","flick":
			if not terminal: return button + " · ouvrir le terminal   |   Validés %d" % score
			if active.rule == "flick":
				var marks := ""
				for i in FLICK_PATTERNS[cycle % 4]: marks += ARROWS[i] + " "
				return "Balayage   %s    %d / 3" % [marks, cursor]
			if pad_input: return "Canal manette   %s    %d / %d" % [ARROWS[expected_dir()], cursor, target_word().length()]
			var prompt := str(TRANSLATIONS[cycle % TRANSLATIONS.size()][0]) + " en anglais" if active.rule == "translation" else target_word()
			return "%s   ›   %s_   [Entrée]" % [prompt, typed]
		"pinball": return "Batteur %s / touche confirmée · retours %d/3" % [button, progress]
		"darts": return "Viser le centre · %s pour lancer · réussites %d" % [button,score]
		"locks": return "Viser le centre · %s pour verrouiller · %d/3" % [button,progress]
		"lab": return "Labo · léger / lourd / projection   %d/3 · évolutions %d" % [captured.size(), score]
		"sector": return "Rejoindre la balise %s · %d/3" % ["gauche" if progress % 2 == 0 else "droite", progress]
		"reel": return "Prise %d/3 · confirmer %s" % [progress, NAMES[STEPS[progress]]]
		"battery": return "Batterie %d %% · garder pour recharger" % charge
		"relay": return "Relais II · spécial" if arena.stage == 3 else "Relais III · lourd"
		"rescue": return "Secours ouvert" if age % 720 < 360 and age >= next_award else "Secours en attente"
	return ""

func paint(arena, ground: float = 601.0) -> void:
	if active.is_empty(): return
	if active.rule == "openings":
		paint_openings(arena)
	elif active.rule == "sector":
		var pos := Vector2(340 if progress % 2 == 0 else 930, ground-4)
		arena.draw_rect(Rect2(pos-Vector2(52,2),Vector2(104,5)),Color("#f4d478"))
		arena.draw_circle(pos-Vector2(0,14),6,Color("#ffde92"))
	elif active.rule == "lab":
		var center := Vector2(640,173)
		arena.draw_rect(Rect2(center-Vector2(66,32),Vector2(132,64)),Color("#11212af2"))
		var pigment := Color("#81b699").lerp(Color("#e3ac87"),minf(1.0,score/3.0))
		var radius := 7.0 + mini(score,3)*1.5
		arena.draw_circle(center-Vector2(0,11),radius,pigment)
		arena.draw_line(center-Vector2(0,4),center+Vector2(0,15),pigment,5+mini(score,3))
		for side in [-1,1]:
			arena.draw_line(center,center+Vector2(side*(11+captured.size()*3),6),pigment,3)
			arena.draw_line(center+Vector2(0,14),center+Vector2(side*7,22),pigment,3)
		for i in 3:
			arena.draw_circle(center+Vector2(-46+i*8,21),2.5,pigment if i<captured.size() else Color("#475653"))
	elif active.rule in ["pinball","locks","darts"]:
		var o := Vector2(574, 142)
		arena.draw_rect(Rect2(o,Vector2(132,74)),Color("#11212af2"))
		arena.draw_rect(Rect2(o,Vector2(132,74)),Color("#9e9579"),false,1.5)
		if active.rule == "pinball":
			for v in BUMPERS:
				arena.draw_circle(o+v,5,Color("#f9d58b") if age-last_bumper<6 else Color("#c88852"))
			arena.draw_line(o+Vector2(17,64),o+Vector2(51,68),Color("#75cbbf"),3)
			arena.draw_line(o+Vector2(79,68),o+Vector2(113,64),Color("#75cbbf"),3)
			arena.draw_circle(o+ball,3,Color.WHITE)
		else:
			arena.draw_rect(Rect2(o+Vector2(53,22),Vector2(26,30)),Color("#499782"))
			if active.rule == "locks":
				for i in 3:
					arena.draw_circle(o+Vector2(55+i*11,62),3,Color("#ffcc67") if i<progress else Color("#596469"))
			var here := o+Vector2(12+meter()*1.08,16)
			arena.draw_line(here,here+Vector2(0,40),Color("#ffd38d"),3)

func paint_openings(arena) -> void:
	var slot := opening_index()
	var clock := age % SIGNAL_TICKS
	arena.draw_rect(Rect2(510,146,260,84),Color("10191ff4"))
	for i in OPENINGS.size():
		var door := i == 1
		var center := Vector2(560+i*80,187)
		var size := Vector2(58,64) if door else Vector2(47,45)
		var box := Rect2(center-size/2,size)
		var recorded := i < progress
		var live := i == slot and opening_live() and progress == i
		var border := Color("f1cd80") if recorded else (Color("84ecbd") if live else Color("8a9899"))
		var light := Color("9ce1bf") if live else Color("364852")
		arena.draw_rect(box,light)
		var fraction := 0.0
		if i == slot:
			fraction = clampf(minf((clock-SIGNAL_START+8)/8.0,(SIGNAL_END+8-clock)/8.0),0,1)
		var panel_w := maxf(2,box.size.x*(1-fraction)/2)
		for side in 2:
			var x: float = box.position.x if side == 0 else box.end.x-panel_w
			var leaf := Rect2(x,box.position.y,panel_w,box.size.y)
			arena.draw_rect(leaf,Color("554d45"))
			arena.draw_rect(leaf,Color("b5a389"),false,1)
			for n in range(1,4):
				var y: float = box.position.y+box.size.y*n/4
				arena.draw_line(Vector2(x,y),Vector2(x+panel_w,y),Color("827665"),1)
		arena.draw_rect(box,border,false,2.5)
		if recorded:
			var mark := center+Vector2(0,3)
			arena.draw_polyline(PackedVector2Array([mark+Vector2(-8,0),mark+Vector2(-2,6),mark+Vector2(9,-7)]),border,3,true)
