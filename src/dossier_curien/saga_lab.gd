extends RefCounted

const SPEEDS := ["Temps réel", "Ralenti × 0,5", "Image par image"]
const DRILLS := ["Briser la garde", "Confirmer le lourd", "Toucher avec le spécial"]
const HELP := ["U ou Y sur la garde du mannequin.", "Touchez avec J, puis enchaînez K pendant la récupération du léger.", "Trouvez la distance et touchez avec le spécial L ou B."]
const LABELS := {"light":"Léger", "heavy":"Lourd", "special":"Spécial", "throw":"Projection"}
var speed := 0
var overlay := false
var drill := -1
var cleared := false
var pending_steps := 0
var half_tick := false
var chain_started := false
var history: Array[String] = []
var marks := ConfigFile.new()
var save_file := "user://dossier_curien_atelier.cfg"
var loaded := false

func reset_session() -> void:
	speed = 0
	overlay = false
	drill = -1
	reset_round()

func reset_round() -> void:
	pending_steps = 0
	half_tick = false
	cleared = false
	chain_started = false
	history.clear()

func allow_tick() -> bool:
	if speed == 1:
		half_tick = not half_tick
		return half_tick
	if speed == 2:
		if pending_steps == 0: return false
		pending_steps -= 1
	return true

func change_speed(a) -> void:
	speed = (speed+1) % SPEEDS.size()
	pending_steps = 0
	half_tick = false
	overlay = true
	open(a)

func toggle_hud(a) -> void:
	overlay = not overlay
	open(a)

func open(a) -> void:
	if not loaded:
		marks.load(save_file)
		loaded = true
	a.phase = "lab"
	a.sheet("Atelier technique", str(a.fighters[0].profile.title) + "   /   Trois exercices par combattant")
	a.button("Reprendre l’entraînement", a.resume)
	a.button("Cadence   ·   " + SPEEDS[speed], change_speed.bind(a))
	a.button("Journal des impacts   ·   " + ("affiché" if overlay else "masqué"), toggle_hud.bind(a))
	for i in DRILLS.size():
		var done: bool = marks.get_value(str(a.fighters[0].profile.id), str(i), false) == true
		a.button(("✓  " if done else "") + DRILLS[i], start_exercise.bind(a,i))
	if drill >= 0: a.button("Quitter l’exercice", start_exercise.bind(a,-1))
	a.paragraph("Image par image    ·    commandez un coup, puis pressez le point, N ou le stick droit pour avancer d’un tic à 60 Hz.")
	a.button("Retour à la pause", a.return_to_pause)

func start_exercise(a, pick: int) -> void:
	drill = pick
	overlay = true
	a.dummy_guard = pick == 0
	a.start_round()

func place(a) -> void:
	reset_round()
	if drill < 0: return
	var gap := 82.0
	if drill == 2:
		gap = clampf(a.fighters[0].profile.move.reach * 0.52, 70, 260)
	a.fighters[0].x = 640.0 - gap/2
	a.fighters[1].x = 640.0 + gap/2

func observe_action(f, before: String, confirmed_before: bool) -> void:
	if f.action != before:
		chain_started = f.action == "heavy" and before == "light" and confirmed_before

func impact(a, f, hit: bool, guarded: bool, damage: int) -> void:
	var command: String = f.action
	var name: String = LABELS.get(command,command)
	if command == "special":
		name = f.profile.alt_name if f.alternate_special else f.profile.special
	history.push_front("t%d   %s   ·   %s   ·   %d PV" % [a.elapsed,name,"touché" if hit else "gardé",damage])
	if history.size() > 3: history.pop_back()
	if not hit or cleared or drill < 0: return
	var success := (drill == 0 and command == "throw" and guarded) or (drill == 1 and command == "heavy" and chain_started) or (drill == 2 and command == "special")
	if success:
		cleared = true
		marks.set_value(str(f.profile.id),str(drill),true)
		var dst := ProjectSettings.globalize_path(save_file)
		if marks.save(dst+".tmp") == OK:
			DirAccess.rename_absolute(dst+".tmp",dst)

func paint(a, painter) -> void:
	if not overlay: return
	var lines := PackedStringArray()
	lines.append(SPEEDS[speed]+("    ·    N / point / stick droit : +1 tic" if speed==2 else ""))
	if drill >= 0: lines.append(("RÉUSSI    " if cleared else "") + DRILLS[drill] + ("    ·    " + HELP[drill] if not cleared else ""))
	for line in history: lines.append(line)
	a.draw_rect(Rect2(38,159,675,14+lines.size()*23),Color("101820df"))
	for i in lines.size():
		painter.heading(a,Vector2(49,183+i*23),lines[i],16,painter.GOLD if i==0 else painter.BONE,656)
