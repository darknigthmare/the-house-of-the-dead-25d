extends RefCounted

# The courses use authored encounters, so later additions to the roster do not
# change a saved time. One tick is one 60 Hz combat update, independent of FPS.
const MODE := 5
const COURSES := [
	{"id":"manoir","title":"Les gardiens du manoir","bouts":[[2,1],[3,2]]},
	{"id":"goldman","title":"Les créations de Goldman","bouts":[[11,3],[3,13],[17,11]]},
	{"id":"efi","title":"Les gardiens d’EFI","bouts":[[12,4],[18,12]]},
	{"id":"anthologie","title":"L’anthologie des gardiens","bouts":[[2,0],[11,3],[13,5],[14,14],[3,6],[12,4],[17,11],[18,12]]},
	{"id":"pandore_arche","title":"De Pandore à l’Arche","bouts":[[13,5],[21,15],[22,16]]}
]
var course: Dictionary
var leg := 0
var race_ticks := 0
var starting_hp := 100
var starting_ammo := 0
var overtime := false
var settled := false
var save_directory := "user://"

static func duration(ticks: int) -> String:
	var centis := roundi(ticks * 100.0 / 60.0)
	return "%d:%02d.%02d" % [int(centis/6000.0), int(centis/100.0)%60, centis%100]

func courses_menu(a) -> void:
	a.mode = MODE
	a.case_id = ""
	a.edition_id = ""
	a.fighters.clear()
	a.phase = "rush_menu"
	a.sheet("Boss Rush AMS", "Une manche par gardien. La vie et le chargeur suivent le combattant. Le record récompense le meilleur temps sur un circuit terminé.")
	for c in COURSES:
		a.button("%s  ·  %d adversaires" % [c.title,c.bouts.size()], select_course.bind(a,c))
	a.button("Menu principal", a.menu)

func select_course(a, item: Dictionary) -> void:
	course = item
	a.pick_fighter(MODE)

func enter(a) -> void:
	leg = 0
	race_ticks = 0
	starting_hp = 100
	starting_ammo = int(a.Fighter.PROFILES[a.chosen].ammo)
	set_encounter(a)
	a.phase = "rush_intro"
	a.sheet(course.title, "Boss Rush  /  " + str(a.Fighter.PROFILES[a.chosen].title))
	var names := PackedStringArray()
	for bout in course.bouts:
		names.append(a.Fighter.PROFILES[bout[0]].title)
	a.paragraph("  ›  ".join(names))
	var best := read_record(a)
	a.paragraph("Record personnel   " + (duration(best) if best > 0 else "Premier passage"))
	a.paragraph("À égalité, une prolongation de 10 secondes se joue à 1 PV. Une seconde égalité termine le circuit.")
	a.button("Démarrer le circuit", a.start_match)
	a.button("Changer de combattant", a.pick_fighter.bind(MODE))
	a.button("Autres circuits", courses_menu.bind(a))

func set_encounter(a) -> void:
	a.enemy = course.bouts[leg][0]
	a.stage = course.bouts[leg][1]

func on_round_start(a) -> void:
	overtime = false
	settled = false
	a.fighters[0].health = starting_hp
	a.fighters[0].ammo = starting_ammo

func decide(a) -> void:
	if settled: return
	var player = a.fighters[0]
	var boss = a.fighters[1]
	if player.health == boss.health and not overtime:
		overtime = true
		player.health = 1
		boss.health = 1
		for f in a.fighters:
			f.action = ""
			f.stun = 0
			f.buffered = ""
			f.buffer_ticks = 0
		a.clock_ticks = 600
		return
	settled = true
	a.winner = 0 if player.health > boss.health else 1
	a.wins[a.winner] = 1
	race_ticks += a.elapsed
	if a.winner == 0 and leg == course.bouts.size()-1 and a.clock_ticks > 0:
		a.phase = "finish"
		a.finish_ticks = 150
	else:
		a.end_match()

func show_result(a) -> void:
	if a.winner != 0:
		a.sheet("Circuit interrompu", "%s   /   %d gardiens vaincus sur %d" % [course.title,leg,course.bouts.size()])
		a.button("Recommencer le circuit", enter.bind(a))
	elif leg == course.bouts.size()-1:
		var best := read_record(a)
		var previous_best := best > 0 and best <= race_ticks
		var saved := true if previous_best else save_record(a,race_ticks)
		a.sheet("Circuit terminé", "%s   /   %s" % [course.title, a.Fighter.PROFILES[a.chosen].title])
		a.paragraph("Temps final   " + duration(race_ticks))
		if previous_best: a.paragraph("Record personnel   " + duration(best))
		elif saved: a.paragraph("Nouveau record personnel")
		else: a.paragraph("Record de session. L’enregistrement local est indisponible.")
		a.button("Retenter le circuit", enter.bind(a))
	else:
		starting_hp = a.fighters[0].health
		starting_ammo = a.fighters[0].ammo
		a.phase = "rush_service"
		a.sheet("Entre deux gardiens", "%s   /   %d sur %d   /   %s" % [course.title,leg+1,course.bouts.size(),duration(race_ticks)])
		a.paragraph("Prochain adversaire   " + str(a.Fighter.PROFILES[course.bouts[leg+1][0]].title))
		var cap: int = a.fighters[0].profile.ammo
		a.paragraph("Vie   %d / 100%s" % [starting_hp, "     Cartouches   %d / %d" % [starting_ammo,cap] if cap > 0 else ""])
		a.button("Repartir immédiatement", advance.bind(a,"continue"))
		if starting_hp < 100: a.button("Soins   +18 PV   /   +5 secondes", advance.bind(a,"heal"))
		if starting_ammo < cap: a.button("Chargeur plein   /   +3 secondes", advance.bind(a,"ammo"))
	a.button("Autres circuits", courses_menu.bind(a))
	a.button("Menu principal", a.menu)

func advance(a, service: String) -> void:
	if a.phase != "rush_service": return
	if service == "heal":
		starting_hp = mini(100,starting_hp+18)
		race_ticks += 300
	elif service == "ammo":
		starting_ammo = int(a.Fighter.PROFILES[a.chosen].ammo)
		race_ticks += 180
	leg += 1
	set_encounter(a)
	a.start_match()

func hud(a) -> String:
	var prefix := "MORT SUBITE" if overtime else "BOSS RUSH"
	return "%s     %d/%d     %s" % [prefix, leg+1, course.bouts.size(), duration(race_ticks + (0 if settled else a.elapsed))]

func record_path(a) -> String:
	return save_directory.path_join("rush_%s_%s.cfg" % [course.id,a.Fighter.PROFILES[a.chosen].id])

func read_record(a) -> int:
	var cfg := ConfigFile.new()
	if cfg.load(record_path(a)) != OK: return 0
	var value: Variant = cfg.get_value("record","ticks",0)
	return maxi(0,value) if typeof(value) == TYPE_INT else 0

func save_record(a, ticks: int) -> bool:
	var cfg := ConfigFile.new()
	cfg.set_value("record","ticks",ticks)
	var dest := ProjectSettings.globalize_path(record_path(a))
	var temp := dest + ".tmp"
	if cfg.save(temp) != OK: return false
	return DirAccess.rename_absolute(temp,dest) == OK
