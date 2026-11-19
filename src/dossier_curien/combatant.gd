extends RefCounted

# Timing is expressed in 60 Hz physics ticks. Bursts arm a separate hit window for each shot.
const LIGHT := {"start": 5, "end": 17, "reach": 125, "damage": 7, "stun": 10}
const HEAVY := {"start": 12, "end": 34, "reach": 165, "damage": 14, "stun": 15}
const THROW := {"start": 7, "end": 39, "reach": 94, "damage": 16, "stun": 20}
const PROFILES := [
	{"id": "rogan", "title": "Thomas Rogan", "home": "curien", "speed": 5.1, "height": 278, "ammo": 6, "reload": 40,
	 "special": "Tir AMS", "finish": "Sceau AMS", "kind": "shot", "color": "a9dbea", "move": {"start": 12, "end": 38, "reach": 700, "damage": 10, "stun": 13}},
	{"id": "g", "title": "Agent G", "home": "curien", "speed": 5.8, "height": 267, "ammo": 6, "reload": 40,
	 "special": "Tir réflexe", "finish": "Extinction des feux", "kind": "shot", "color": "91b9d8", "move": {"start": 8, "end": 32, "reach": 530, "damage": 8, "stun": 12}},
	{"id": "chariot", "title": "Chariot", "home": "curien", "speed": 3.9, "height": 344, "ammo": 0, "reload": 0,
	 "special": "Fauchage", "finish": "Sentence de fer", "kind": "sweep", "color": "e9c283", "move": {"start": 22, "end": 53, "reach": 245, "damage": 23, "stun": 20}},
	{"id": "magician", "title": "Magician", "home": "curien", "speed": 5.4, "height": 308, "ammo": 0, "reload": 0,
	 "special": "Orbe thermique", "finish": "Combustion", "kind": "orb", "color": "ef7543", "move": {"start": 20, "end": 48, "reach": 760, "damage": 15, "stun": 18}},
	{"id": "james", "title": "James Taylor", "home": "hotd2", "speed": 5.45, "height": 278, "ammo": 6, "reload": 36,
	 "special": "Double détente", "finish": "Dernier signal", "kind": "double", "color": "91ced1", "move": {"start": 10, "end": 38, "reach": 610, "damage": 7, "stun": 9}},
	{"id": "lisa", "title": "Lisa Rogan", "home": "hotd3", "speed": 5.0, "height": 261, "ammo": 6, "reload": 18,
	 "special": "Gerbe de plomb", "finish": "Sortie de secours", "kind": "spread", "color": "ffa665", "move": {"start": 13, "end": 42, "reach": 345, "damage": 19, "stun": 15}},
	{"id": "kate", "title": "Kate Green", "home": "hotd4", "speed": 5.9, "height": 266, "ammo": 12, "reload": 42,
	 "special": "Barrage court", "finish": "Ligne de fuite", "kind": "burst", "color": "64bcce", "move": {"start": 9, "end": 36, "reach": 515, "damage": 5, "stun": 8}},
	{"id": "ryan", "title": "Ryan Taylor", "home": "scarlet", "speed": 5.15, "height": 280, "ammo": 10, "reload": 38,
	 "special": "Rafale en marche", "finish": "Aube écarlate", "kind": "advance", "color": "da8882", "move": {"start": 13, "end": 45, "reach": 535, "damage": 6, "stun": 9}},
	{"id": "isaac", "title": "Isaac Washington", "home": "overkill", "speed": 5.4, "height": 282, "ammo": 6, "reload": 34,
	 "special": "Dernier mot", "finish": "Rideau de drive-in", "kind": "stagger", "color": "efa052", "move": {"start": 16, "end": 42, "reach": 490, "damage": 14, "stun": 20}},
	{"id": "zobio", "title": "Zobio", "home": "ex", "speed": 4.65, "height": 300, "ammo": 0, "reload": 0,
	 "special": "Étreinte rebond", "finish": "Coup de foudre", "kind": "hug", "color": "f18fc5", "move": {"start": 11, "end": 38, "reach": 128, "damage": 19, "stun": 17}},
	{"id": "stick", "title": "Stick Breitling", "home": "revenge", "speed": 6.2, "height": 282, "ammo": 0, "reload": 0,
	 "special": "Uppercut de rue", "finish": "Dernier round", "kind": "rise", "color": "e7a849", "move": {"start": 9, "end": 38, "reach": 144, "damage": 18, "stun": 19}},
	{"id": "hierophant", "title": "Hierophant", "home": "hotd2", "speed": 4.1, "height": 325, "ammo": 0, "reload": 0,
	 "special": "Pointe de marée", "finish": "Marée noire", "kind": "thrust", "color": "79c8c8", "move": {"start": 17, "end": 43, "reach": 315, "damage": 17, "stun": 18}},
	{"id": "death", "title": "Death", "home": "hotd3", "speed": 3.65, "height": 370, "ammo": 0, "reload": 0,
	 "special": "Coup de massue", "finish": "Porte condamnée", "kind": "crush", "color": "db8a65", "move": {"start": 26, "end": 60, "reach": 228, "damage": 26, "stun": 24}},
	{"id": "justice", "title": "Justice", "home": "hotd4", "speed": 3.85, "height": 360, "ammo": 0, "reload": 0,
	 "special": "Étau à quatre bras", "finish": "Quais condamnés", "kind": "clasp", "color": "c3ab89", "move": {"start": 19, "end": 51, "reach": 166, "damage": 22, "stun": 22}},
	{"id": "jasper", "title": "Jasper Guns", "home": "overkill", "speed": 4.0, "height": 316, "ammo": 0, "reload": 0,
	 "special": "Onde psychique", "finish": "Dernière bobine", "kind": "psychic", "color": "c8aaef", "move": {"start": 22, "end": 52, "reach": 450, "damage": 15, "stun": 22}},
	{"id": "zobiko", "title": "Zobiko", "home": "ex", "speed": 6.3, "height": 252, "ammo": 0, "reload": 0,
	 "special": "Bond du cœur", "finish": "Rappel en duo", "kind": "hop", "color": "e6a8bc", "move": {"start": 12, "end": 37, "reach": 157, "damage": 15, "stun": 14}},
	{"id": "rikiya", "title": "Rikiya Busujima", "home": "revenge", "speed": 5.65, "height": 284, "ammo": 0, "reload": 0,
	 "special": "Paume de rupture", "finish": "Dernière frappe", "kind": "palm", "color": "8bbed9", "move": {"start": 15, "end": 41, "reach": 168, "damage": 17, "stun": 17}},
	{"id": "emperor", "title": "Emperor", "home": "hotd2", "speed": 4.8, "height": 310, "ammo": 0, "reload": 0,
	 "special": "Salve satellite", "finish": "Règne de mercure", "kind": "satellite", "color": "b8dded", "move": {"start": 17, "end": 49, "reach": 580, "damage": 8, "stun": 12},
	 "alt_name": "Lame de mercure", "alt_move": {"start": 10, "end": 37, "reach": 219, "damage": 17, "stun": 16}},
	{"id": "wheel", "title": "Wheel of Fate", "home": "hotd3", "speed": 3.8, "height": 360, "ammo": 0, "reload": 0,
	 "special": "Roue conductrice", "finish": "Révolution zéro", "kind": "rotor", "color": "95d3f4", "move": {"start": 20, "end": 76, "reach": 466, "damage": 9, "stun": 13}},
	{"id": "gary", "title": "Gary Stewart", "home": "hotd2", "speed": 5.75, "height": 273, "ammo": 6, "reload": 34,
	 "special": "Tir de repli", "finish": "Dernière couverture", "kind": "retreat", "color": "e4c797", "move": {"start": 15, "end": 38, "reach": 610, "damage": 11, "stun": 12}},
	{"id": "daniel", "title": "Daniel Curien", "home": "hotd3", "speed": 5.05, "height": 275, "ammo": 6, "reload": 20,
	 "special": "Gerbe de rupture", "finish": "Fin de l’expérience", "kind": "choke", "color": "f1dcb1", "move": {"start": 12, "end": 39, "reach": 290, "damage": 18, "stun": 17},
	 "alt_name": "Gerbe concentrée", "alt_move": {"start": 20, "end": 47, "reach": 470, "damage": 14, "stun": 14}},
	{"id": "world", "title": "The World", "home": "hotd4", "speed": 4.5, "height": 332, "ammo": 0, "reload": 0,
	 "special": "Éclats de banquise", "finish": "Dernier hiver", "kind": "frost", "color": "a6e5ff", "move": {"start": 18, "end": 58, "reach": 590, "damage": 7, "stun": 12},
	 "alt_name": "Hache de givre", "alt_move": {"start": 14, "end": 42, "reach": 216, "damage": 18, "stun": 18}},
	{"id": "moon", "title": "Moon", "home": "scarlet", "speed": 3.5, "height": 374, "ammo": 0, "reload": 0,
	 "special": "Bras de l’Arche", "finish": "Éclipse de l’Arche", "kind": "canopy", "color": "c5cda0", "move": {"start": 22, "end": 62, "reach": 522, "damage": 19, "stun": 18},
	 "alt_name": "Appel du cyclone", "alt_move": {"start": 25, "end": 55, "reach": 405, "damage": 11, "stun": 19}},
	{"id": "linda", "title": "Linda Rotta", "home": "revenge", "speed": 6.35, "height": 261, "ammo": 8, "reload": 36,
	 "special": "Tir de liaison", "finish": "Dernière issue", "kind": "slide_shot", "color": "efd46a", "move": {"start": 11, "end": 35, "reach": 520, "damage": 10, "stun": 12},
	 "alt_name": "Glissade armée", "alt_move": {"start": 19, "end": 45, "reach": 345, "damage": 12, "stun": 14}}
]
# Distinct close-range timing and geometry for the crossover combatants.
const QUICK_LIGHT := {"start": 4, "end": 15, "reach": 111, "damage": 6, "stun": 9}
const BOXER_HEAVY := {"start": 10, "end": 31, "reach": 143, "damage": 15, "stun": 16}
const POLE_LIGHT := {"start": 8, "end": 24, "reach": 179, "damage": 9, "stun": 11}
const GIANT_HEAVY := {"start": 18, "end": 46, "reach": 191, "damage": 20, "stun": 19}
const GRAPPLER_THROW := {"start": 6, "end": 36, "reach": 112, "damage": 18, "stun": 21}
const NOTES := [
	"Le tir passe au-dessus d’une cible accroupie.", "Sortie rapide. Le tir se baisse et dépense une cartouche.",
	"Grand arc de fauchage. La longue récupération expose Chariot.", "Orbe à longue portée, après un amorçage visible.",
	"Deux tirs espacés de cinq images. Chaque pression dépense deux cartouches.",
	"La gerbe couvre les sauts bas. La recharge insère une cartouche à la fois.",
	"Trois impacts espacés de cinq images. Une rafale consomme trois cartouches.",
	"Ryan avance pendant l’amorce et lâche trois tirs. La rafale consomme trois cartouches.",
	"Le coup de revolver repousse fortement la cible. Isaac retrouve sa garde après le recul.",
	"Zobio ouvre la garde avec son étreinte. Elle touche uniquement un adversaire au sol.",
	"L’uppercut atteint une cible en l’air. Stick dispose d’un léger rapide et d’un lourd court.",
	"Le trident allonge la portée du léger et du spécial. Gardez l’agent au bout de la pointe.",
	"L’impact de la massue inflige un fort recul. Son amorce est la plus lente de la sélection.",
	"La prise à quatre bras ouvre la garde au sol. Le lourd et la projection de Justice privilégient la portée.",
	"L’onde psychique attire la cible au lieu de la repousser. Son amorce laisse le temps de se rapprocher.",
	"Zobiko quitte le sol au début de son spécial. Le bond échappe aux projections au sol et atteint les sauts bas.",
	"Une paume sur la garde inflige trois points de pression sans pouvoir conclure le duel. Le contact libre repousse la cible.",
	"Deux sphères sortent à dix images d’intervalle. Maintenir bas au départ du spécial forme une lame courte qui atteint les cibles accroupies.",
	"La roue parcourt 466 unités en 23 images et revient sur le même axe. Chaque trajet peut toucher une fois. Un saut haut évite son passage.",
	"Gary recule pendant les dix premières images avant de tirer. Accroupissez-vous pour éviter le tir et surveillez la distance jusqu’au bord.",
	"Le tir debout disperse les plombs et couvre les sauts bas. Bas + spécial resserre la gerbe pour gagner en portée. Chaque recharge insère une cartouche.",
	"Deux volées hautes à douze tics d’intervalle. Sur touche, le givre ralentit la marche pendant 36 tics. Bas + spécial frappe à la hache et atteint une cible accroupie.",
	"Le bras court près du sol. Sautez au-dessus de son extrémité. Bas + spécial aspire les cibles entre 150 et 405 unités. Le corps à corps échappe au cyclone.",
	"Le tir debout passe au-dessus d’une cible accroupie. Bas + spécial avance de 40 unités en position basse puis tire à courte portée. La glissade ne rend pas invincible ; sautez ou projetez Linda avant le tir. Chaque tir dépense une cartouche."
]
const STORY := [[1, 2, 3], [0, 3, 2], [1, 0, 3], [2, 1, 0]]
const STORY_STAGES := [[0, 1, 2], [0, 2, 1], [0, 1, 2], [1, 2, 0]]

var id: int
var x: float
var altitude := 0.0
var vy := 0.0
var facing := 1
var health := 100
var ammo: int
var profile: Dictionary
var shots_per_special := 1
var alternate_special := false
var stun := 0
var action := ""
var tick := 0
var connected := false
var confirmed := false
var guarding := false
var crouching := false
var moving := false
var walk_ticks := 0
var taunt_ticks := 0
var block_ticks := 0
var frost_ticks := 0
var combo := 0
var combo_window := 0
var buffered := ""
var buffer_ticks := 0

func _init(identity: int, position_x: float, direction: int) -> void:
	id = identity
	profile = PROFILES[id]
	ammo = profile.ammo
	if profile.kind in ["double","satellite","rotor","frost"]: shots_per_special = 2
	elif profile.kind in ["burst", "advance"]: shots_per_special = 3
	x = position_x
	facing = direction

func move_data(command := "") -> Dictionary:
	match action if command == "" else command:
		"light":
			if profile.kind in ["rise", "double", "burst", "hop", "palm", "retreat", "slide_shot"]: return QUICK_LIGHT
			if profile.kind == "thrust": return POLE_LIGHT
			return LIGHT
		"heavy":
			if profile.kind in ["rise", "stagger", "palm"]: return BOXER_HEAVY
			if profile.kind in ["crush", "clasp", "rotor", "canopy"]: return GIANT_HEAVY
			return HEAVY
		"throw":
			return GRAPPLER_THROW if profile.kind in ["hug", "clasp"] else THROW
		"special": return profile.alt_move if alternate_special else profile.move
	return {}

func special_hits() -> int:
	return 1 if alternate_special else shots_per_special

func pulse_gap() -> int:
	if profile.kind == "frost": return 12
	return 10 if profile.kind == "satellite" else 5

func satellite_radius() -> float:
	var age := maxi(0, tick - int(profile.move.start))
	return lerpf(42, float(profile.move.reach), minf(1, float(age % pulse_gap()) / 8.0))

# The returning wheel occupies a moving band rather than the whole attack radius.
func wheel_radius() -> float:
	var age := clampi(tick - int(profile.move.start), 0, 47)
	var progress := age / 23.0 if age < 24 else (47-age) / 23.0
	return float(profile.move.reach) * progress

# The leading edge determines both the contact position and the rendered effect.
func surge_radius() -> float:
	var age := maxi(0, tick - int(profile.move.start))
	if profile.kind == "frost":
		return lerpf(70.0, float(profile.move.reach), float(age % pulse_gap()) / 11.0)
	return lerpf(68.0, float(profile.move.reach), clampf(age / 17.0, 0.0, 1.0))

func begin(command: String, low := false) -> bool:
	if command not in ["jump", "light", "heavy", "special", "throw", "reload", "taunt"] or stun > 0:
		return false
	if command == "taunt":
		if action != "" or altitude > 0 or vy > 0 or moving or guarding or crouching or block_ticks > 0 or taunt_ticks > 0: return false
		taunt_ticks = 60
		return true
	if command == "jump":
		if action == "" and altitude <= 0.0:
			taunt_ticks = 0
			vy = 13.2
			return true
		return false
	if action != "":
		# A confirmed light can chain to a heavy, a confirmed heavy to a special.
		if not confirmed or not ((action == "light" and command == "heavy") or (action == "heavy" and command == "special")):
			return false
	if command == "reload" and (profile.ammo == 0 or ammo == profile.ammo or altitude > 0.0):
		return false
	if command == "special" and profile.ammo > 0:
		if ammo < shots_per_special: return false
		ammo -= shots_per_special
	alternate_special = command == "special" and low and altitude <= 0 and profile.has("alt_move")
	if command == "special" and profile.kind == "hop" and altitude <= 0: vy = 6.8
	action = command
	taunt_ticks = 0
	tick = 0
	connected = false
	confirmed = false
	guarding = false
	return true

func step(axis: int, down: bool, command: String, other_x: float) -> void:
	block_ticks = maxi(0,block_ticks-1)
	if axis != 0 or down or altitude > 0 or stun > 0 or action != "" or (command != "" and command != "taunt"):
		taunt_ticks = 0
	else:
		taunt_ticks = maxi(0,taunt_ticks-1)
	if action == "":
		facing = 1 if other_x >= x else -1
	if stun > 0:
		stun -= 1
	combo_window = maxi(0, combo_window - 1)
	if combo_window == 0:
		combo = 0
	# Resolve this tick's movement before accepting a cosmetic gesture.
	if command != "" and command != "taunt":
		buffered = command
		buffer_ticks = 5
	if buffer_ticks > 0:
		if begin(buffered, down):
			buffer_ticks = 0
		else:
			buffer_ticks -= 1
	if altitude > 0.0 or vy > 0.0:
		altitude = maxf(0.0, altitude + vy)
		vy -= 0.72
		if altitude == 0.0: vy = 0.0
	crouching = down and altitude == 0.0 and action == "" and stun == 0
	if profile.kind == "slide_shot" and alternate_special and action == "special" and altitude == 0 and stun == 0:
		crouching = tick < int(profile.alt_move.start) + 3
	guarding = axis == -facing and altitude == 0.0 and action == "" and stun == 0
	moving = axis != 0 and not crouching and action == "" and stun == 0
	if moving:
		x += axis * float(profile.speed) * (0.58 if guarding else 1.0) * (0.5 if frost_ticks > 0 else 1.0)
	if moving and altitude == 0:
		walk_ticks += 1
	else:
		walk_ticks = 0
	if command == "taunt": begin(command)
	frost_ticks = maxi(0, frost_ticks - 1)
	if action == "": return
	tick += 1
	if action == "reload":
		if tick >= int(profile.reload):
			ammo = mini(ammo + 1, profile.ammo) if profile.kind in ["spread","choke"] else int(profile.ammo)
			action = ""
	else:
		var move := move_data()
		if action == "special":
			var elapsed := tick - int(move.start)
			if profile.kind == "rotor" and elapsed == 24:
				connected = false
			elif profile.kind != "rotor" and special_hits() > 1 and elapsed > 0 and elapsed < special_hits() * pulse_gap() and elapsed % pulse_gap() == 0:
				connected = false
			if profile.kind == "advance" and tick <= int(move.start): x += facing * 2.0
			if profile.kind == "retreat" and tick <= 10: x -= facing * 4.0
			if profile.kind == "slide_shot" and alternate_special and tick <= 8 and stun == 0:
				x += facing * 5.0
		if tick >= int(move.end): action = ""

func can_strike(target) -> bool:
	if action == "" or action == "reload" or connected: return false
	var move := move_data()
	var active_tick := tick - int(move.start)
	if active_tick < 0: return false
	if action == "special" and profile.kind == "rotor":
		if active_tick >= 48: return false
	elif action == "special" and profile.kind == "canopy" and not alternate_special:
		if active_tick >= 18: return false
	elif action == "special" and profile.kind in ["satellite","frost"] and not alternate_special:
		if active_tick >= special_hits() * pulse_gap(): return false
	elif action == "special" and special_hits() > 1:
		if active_tick >= special_hits() * pulse_gap() or active_tick % pulse_gap() > 2: return false
	elif active_tick > 2: return false
	var separation: float = (target.x - x) * facing
	if separation < -16 or separation > float(move.reach): return false
	if action == "special":
		if profile.kind == "slide_shot":
			if stun > 0: return false
			if alternate_special: return absf(altitude - target.altitude) < 70
			return not target.crouching and absf(altitude - target.altitude) < 89
		if profile.kind == "frost":
			if alternate_special: return absf(altitude - target.altitude) < 114
			return not target.crouching and absf(separation-surge_radius()) <= 35 and absf(altitude-target.altitude) < 95
		if profile.kind == "canopy":
			if alternate_special: return separation >= 150 and absf(altitude-target.altitude) < 176
			return absf(separation-surge_radius()) <= 46 and absf(altitude-target.altitude) < 72
		if profile.kind == "rotor": return absf(separation - wheel_radius()) <= 44 and absf(altitude-target.altitude) < 96
		if profile.kind == "satellite" and not alternate_special:
			return not target.crouching and absf(separation - satellite_radius()) <= 40 and absf(altitude-target.altitude) < 89
		if profile.kind in ["shot", "double", "burst", "advance", "stagger", "retreat"] and target.crouching: return false
		if profile.kind in ["hug", "clasp"] and (altitude > 0 or target.altitude > 0): return false
		if profile.kind == "choke": return absf(altitude-target.altitude) < (70 if alternate_special else 175)
		if profile.kind in ["rise", "spread", "hop"]: return absf(altitude - target.altitude) < 185
		if profile.kind == "thrust": return absf(altitude - target.altitude) < 125
	if action == "throw" and (altitude > 0.0 or target.altitude > 0.0): return false
	return absf(altitude - target.altitude) < 89.0

func hit(target) -> bool:
	var move := move_data()
	var grab: bool = action == "throw" or (action == "special" and profile.kind in ["hug", "clasp"])
	var blocked: bool = target.guarding and not grab
	connected = true
	target.taunt_ticks = 0
	if blocked:
		target.block_ticks = 8
		if action == "special" and profile.kind == "palm": target.health = maxi(1, target.health - 3)
		target.x += facing * 6
		return false
	confirmed = true
	target.health = maxi(0, target.health - int(move.damage))
	target.stun = int(move.stun)
	var push := 42 if grab else 17
	if action == "special":
		if profile.kind == "frost" and not alternate_special: target.frost_ticks = 36
		if profile.kind == "canopy" and alternate_special: push = -78
		elif special_hits() > 1: push = 4
		elif profile.kind in ["stagger", "crush", "palm"]: push = 65
		elif profile.kind == "psychic": push = -64
	target.x += facing * push
	combo += 1
	combo_window = 32
	return true
