extends SceneTree

const Arena := preload("res://src/dossier_curien/arena.gd")
const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Saga := preload("res://src/dossier_curien/saga.gd")

var arena: Control
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("run")

func verify(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func click(label: String, exact := false) -> bool:
	for node in arena.box.get_children():
		if node is Button and (node.text == label if exact else node.text.begins_with(label)):
			node.pressed.emit()
			return true
	verify(false, "Missing visible button '%s' on %s" % [label, arena.phase])
	return false

func pages(n: int) -> void:
	for i in n: click("Page suivante")

func victory() -> void:
	for round_index in 2:
		arena.fighters[1].health = 0
		arena._physics_process(1/60.0)
		if round_index == 0: click("Manche suivante")
	verify(arena.phase == "finish", "Finisher window")
	arena.trigger_finisher()
	for tick in 72: arena._physics_process(1/60.0)
	verify(arena.phase == "result", "Duel result")

func cases_and_routes() -> void:
	var case_index := 0
	for case_id in Saga.CASES:
		var dossier: Dictionary = Saga.CASES[case_id]
		arena.menu()
		click("Chroniques")
		pages(case_index/arena.PAGE_SIZE)
		click(dossier.name,true)
		click("Histoire")
		click(Fighter.PROFILES[dossier.lead].title)
		if case_id != "curien":
			for card in ["intro","rival","ending"]:
				verify(arena.visuals.saga_texture(case_id+"_"+card) is Texture2D, "Registered narrative card " + case_id+"_"+card)
		for chapter in 3:
			verify(arena.phase == "brief" and arena.route == chapter, "%s chapter %d" % [case_id,chapter])
			click("Entrer dans")
			verify(arena.phase == "fight" and arena.fighters.size() == 2, "Loaded fighters " + case_id)
			if case_id != "curien": verify(arena.stage == Saga.stages_for(case_id, dossier.lead)[chapter], "Arena " + case_id)
			victory()
			if chapter < 2: click("Ouvrir le relevé")
		verify(arena.box.get_child(0).text.begins_with("Épilogue"), "Ending " + case_id)
		case_index += 1
	for id in Saga.ALTERNATE_STORIES:
		var home: String = "special" if id == 1 else Fighter.PROFILES[id].home
		arena.case_details(home)
		arena.pick_fighter(0)
		click(Fighter.PROFILES[id].title)
		verify(arena.box.get_child(1).text == Saga.ALTERNATE_STORIES[id][0], "Alternate introduction for %d" % id)
		verify(arena.chosen not in arena.story_opponents, "No self-match in the campaign for %d" % id)
		arena.next_story()
		verify(arena.box.get_child(1).text == Saga.ALTERNATE_STORIES[id][1], "Alternate rival for %d" % id)
		if id >= 17:
			for card in ["intro","rival","ending"]:
				verify(arena.visuals.saga_texture(Fighter.PROFILES[id].id+"_"+card) is Texture2D, "Registered alternate story illustration %d/%s" % [id,card])
			arena.start_match()
			victory()
			click("Ouvrir le relevé")
			verify(arena.stage == (11 if home == "hotd2" else 12), "Original final arena for %d" % id)
			arena.start_match()
			victory()
			verify(arena.box.get_child(1).text == Saga.ALTERNATE_STORIES[id][3], "Personal epilogue for %d" % id)

func roster_and_stages() -> void:
	for i in Fighter.PROFILES.size():
		var profile: Dictionary = Fighter.PROFILES[i]
		verify(arena.visuals.guard_art(i) is Texture2D, "Registered combat art for " + str(profile.id))
		if i >= 4:
			for suffix in ["_select","_windup","_contact","_recoil"]:
				verify(arena.visuals.saga_texture(profile.id+suffix) is Texture2D, "Registered " + str(profile.id)+suffix)
		var attacker := Fighter.new(i, 500, 1)
		var target := Fighter.new(0, 580, -1)
		var landed := 0
		attacker.begin("special")
		for tick in int(profile.move.end):
			attacker.step(0,false,"",target.x)
			if attacker.can_strike(target) and attacker.hit(target): landed += 1
		verify(landed == attacker.shots_per_special, "Special hit count for " + str(profile.id))
		verify(target.health == 100 - landed * int(profile.move.damage), "Special damage for " + str(profile.id))
		arena.menu()
		click("Commandes")
		click("Liste des coups")
		pages(i/arena.PAGE_SIZE)
		click(profile.title,true)
		verify(arena.box.get_child(0).text == profile.title and arena.box.get_child(1).text == Fighter.NOTES[i], "Move list " + str(profile.id))
	for i in range(3,Saga.STAGES.size()):
		verify(arena.visuals.saga_texture(Saga.ART[i] + "_back") is Texture2D, "Registered backdrop " + Saga.ART[i])
		if i >= 11:
			for layer in ["_mid","_front"]:
				verify(arena.visuals.saga_texture(Saga.ART[i]+layer) is Texture2D, "Registered plane "+Saga.ART[i]+layer)
	for home in ["hotd2","hotd3"]:
		verify(arena.visuals.saga_texture(home+"_final") is Texture2D, "Final portrait for "+home)
	arena.menu()
	click("Duel local")
	pages(16/arena.PAGE_SIZE)
	click("Rikiya")
	pages(2)
	click("Death")
	pages(2)
	click("Rue en quarantaine")
	verify(arena.chosen == 16 and arena.enemy == 12 and arena.stage == 10 and arena.mode == 2, "Preserve both paged choices and local mode")
	arena.pause_menu()
	click("Liste des coups")
	key(KEY_ESCAPE)
	verify(arena.phase == "pause", "Escape closes the move list without exiting the paused duel")
	click("Reprendre")
	verify(arena.phase == "fight" and arena.fighters[0].id == 16, "Resume same duel from its move list")

func styles() -> void:
	var lisa := Fighter.new(5, 400, 1)
	lisa.ammo = 1
	lisa.begin("reload")
	for i in int(lisa.profile.reload): lisa.step(0,false,"",600)
	verify(lisa.ammo == 2, "Lisa reloads one shell")
	var ryan := Fighter.new(7, 400, 1)
	ryan.begin("special")
	for i in int(ryan.profile.move.start): ryan.step(0,false,"",600)
	verify(ryan.x > 420 and ryan.ammo == 7, "Ryan advances during the three-shot startup")
	for i in [9,13]:
		var grappler := Fighter.new(i,400,1)
		var guard := Fighter.new(1,480,-1)
		guard.guarding = true
		grappler.begin("special")
		grappler.tick = grappler.profile.move.start
		verify(grappler.can_strike(guard) and grappler.hit(guard), "Command grab beats block for %d" % i)
	var jasper := Fighter.new(14,400,1)
	var foe := Fighter.new(1,690,-1)
	jasper.begin("special")
	jasper.tick = jasper.profile.move.start
	jasper.hit(foe)
	verify(foe.x < 690, "Psychic wave pulls the target")
	var zobiko := Fighter.new(15,400,1)
	zobiko.step(0,false,"special",480)
	var grab := Fighter.new(9,480,-1)
	grab.begin("throw")
	grab.tick = grab.move_data().start
	verify(zobiko.altitude > 0 and not grab.can_strike(zobiko), "Zobiko's hop avoids a grounded grab")
	var rikiya := Fighter.new(16,400,1)
	var defended := Fighter.new(1,480,-1)
	defended.health = 2
	defended.guarding = true
	rikiya.begin("special")
	rikiya.tick = rikiya.profile.move.start
	verify(not rikiya.hit(defended) and defended.health == 1, "Rikiya's pressure cannot KO a blocking rival")

func new_styles() -> void:
	var dummy := Fighter.new(0,570,-1)
	var emperor := Fighter.new(17,400,1)
	emperor.step(0,true,"special",dummy.x)
	verify(emperor.alternate_special and emperor.special_hits() == 1 and emperor.move_data().damage == 17, "Mercury blade selected by down + special")
	emperor.tick = emperor.move_data().start
	dummy.crouching = true
	verify(emperor.can_strike(dummy), "The blade reaches a crouched target")
	verify(arena.visuals.pose_suffix(emperor)=="_contact", "Low special selects the registered blade")
	var orbit := Fighter.new(17,400,1)
	orbit.begin("special")
	orbit.tick = orbit.move_data().start + 2
	verify(not orbit.can_strike(dummy), "Crouching avoids the high satellite")
	verify(arena.visuals.pose_suffix(orbit)=="_windup", "High satellites use the sphere-casting pose")
	dummy.crouching = false
	verify(orbit.can_strike(dummy), "A standing target can meet the travelling satellite")
	orbit.tick -= 2
	verify(not orbit.can_strike(dummy), "The satellite cannot strike ahead of its visible position")
	var wheel := Fighter.new(18,400,1)
	wheel.begin("special")
	wheel.tick = wheel.move_data().start
	verify(not wheel.can_strike(dummy), "A remote target is safe before the wheel arrives")
	wheel.tick += 8
	verify(wheel.can_strike(dummy), "Outgoing wheel occupies its visible position")
	dummy.altitude = 120
	verify(not wheel.can_strike(dummy), "Jumping above the wheel avoids its band")
	dummy.altitude = 0
	var gary := Fighter.new(19,650,1)
	for t in 10: gary.step(0,false,"special" if t == 0 else "",dummy.x+700)
	verify(gary.x == 610 and gary.ammo == 5, "Gary steps back 40 units before one shot")
	verify(arena.visuals.saga_texture("gary_melee") is Texture2D, "Registered elbow art for Gary's light")
	var elbow := Fighter.new(19,400,1)
	elbow.begin("light")
	elbow.tick = elbow.move_data().start
	verify(arena.visuals.pose_suffix(elbow)=="_melee" and elbow.ammo==6, "Gary's elbow consumes no bullet and uses only the close-combat image")
	elbow.tick += 3
	verify(arena.visuals.pose_suffix(elbow)=="", "Gary recovers from the elbow without the firing pose")
	var daniel := Fighter.new(20,400,1)
	daniel.step(0,true,"special",dummy.x)
	verify(daniel.alternate_special and daniel.move_data().reach == 470 and daniel.ammo == 5, "Daniel's aimed spread extends range")
	daniel.action = ""
	daniel.ammo = 1
	daniel.begin("reload")
	for t in daniel.profile.reload: daniel.step(0,false,"",dummy.x)
	verify(daniel.ammo == 2, "Daniel reloads by the shell")
	for i in Fighter.PROFILES.size():
		var f := Fighter.new(i,400,1)
		if f.profile.ammo == 0: continue
		for cmd in ["light","heavy","throw"]:
			f.action = cmd
			f.tick = f.move_data().start
			var expected := "_melee" if i == 19 and cmd == "light" else ""
			verify(arena.visuals.pose_suffix(f) == expected, "Firearm contact excluded from %d/%s" % [i,cmd])
		f.action = "special"
		f.tick = f.move_data().start
		verify(arena.visuals.pose_suffix(f) == "_contact", "Firearm contact for %d special" % i)

func boss_scans() -> void:
	for id in ["hotd2","hotd3"]:
		var dossier: Dictionary = Saga.CASES[id]
		arena.case_details(id)
		arena.choose(dossier.lead)
		arena.next_story()
		arena.next_story()
		verify(arena.has_boss_scan() and arena.enemy == (17 if id == "hotd2" else 18), "Canonical final opponent for "+id)
		var switches: Array = arena.box.find_children("*","CheckButton",false,false)
		verify(switches.size() == 1, "Player can toggle the chest scan at the brief")
		switches[0].button_pressed = false
		arena.start_match()
		arena.elapsed = 135
		verify(arena.scan_state() == "", "Analysis may be disabled")
		arena.pause_menu()
		arena.box.find_children("*","CheckButton",false,false)[0].button_pressed = true
		arena.resume()
		arena.elapsed = 90
		verify(arena.scan_state() == "repérage", "Scan telegraphs 45 frames ahead")
		arena.elapsed = 135
		verify(arena.scan_state() == "ouvert", "Scan confirmation at the exposed core")
		var a = arena.fighters[0]
		var b = arena.fighters[1]
		a.x=400
		b.x=495
		a.action="heavy"
		a.tick=a.move_data().start
		b.guarding=true
		arena.resolve_strikes(arena.fighters,true)
		verify(b.health == 100 and arena.scan_state()=="ouvert","Blocked impact leaves the analysis available")
		b.guarding=false
		a.connected=false
		arena.resolve_strikes(arena.fighters,true)
		verify(b.health == 100-int(a.move_data().damage)-6 and b.stun>=23 and arena.scan_state()=="confirmé", "Exposed core pays six bonus and interrupts")
		arena.elapsed = 375
		verify(arena.scan_state()=="ouvert","Next 240-frame cycle reopens")
		arena.mode=2
		verify(not arena.has_boss_scan() and arena.scan_state()=="", "Scan does not affect versus")

func case_rules() -> void:
	for case_id in Saga.CASES:
		if case_id == "curien": continue
		arena.case_details(case_id)
		arena.start_exhibition()
		var f = arena.fighters[0]
		var target = arena.fighters[1]
		f.health = 70
		f.ammo = 0
		f.confirmed = true
		f.combo = 3
		f.action = "throw" if case_id in ["hotd3","ex"] else ("heavy" if case_id == "scarlet" else "special")
		var clock: int = arena.clock_ticks
		var before: float = target.x
		Saga.apply_rule(arena, case_id)
		verify(arena.rule_awarded[0], "Signature rule triggered for " + case_id)
		match case_id:
			"hotd2": verify(arena.clock_ticks == clock+180, "Canal rescue timer")
			"overkill": verify(f.health == 78, "Grindhouse take restored health")
			"ex": verify(f.health == 80, "Heart grab restored health")
			"hotd3": verify(f.health == 76, "EFI rescue restored health")
			"scarlet": verify(target.x == before+60, "Mansion signal pushed the defender")
			"hotd4": verify(f.ammo == f.profile.ammo, "Fourth dossier reloaded magazine")
			"special": verify(clock == 2100 and arena.clock_ticks == clock+300, "Special short clock and bonus")
			"revenge": verify(arena.clock_ticks == clock+300, "Street combo timer")
		var snapshot := [arena.clock_ticks,f.health,f.ammo,target.x]
		Saga.apply_rule(arena,case_id)
		verify(snapshot == [arena.clock_ticks,f.health,f.ammo,target.x], "Case bonus can only pay once")

func archives_and_keys() -> void:
	var editions: Array = arena.archives.entries()
	var count := 0
	for edition in editions:
		arena.menu()
		click("Archives et variantes")
		pages(count/arena.PAGE_SIZE)
		click(edition.title,true)
		click("Lancer l’épreuve")
		arena._physics_process(1/60.0)
		verify(arena.phase == "fight" and arena.edition_id == edition.id and arena.archives.active.id == edition.id, "Playable edition " + str(edition.id))
		if edition.id == "typing":
			key(KEY_TAB)
			verify(arena.archives.terminal, "Typing terminal opened with Tab")
			key(KEY_ESCAPE)
			verify(not arena.archives.terminal and arena.phase == "fight", "Escape closes terminal, preserves duel")
			key(KEY_TAB)
			var word: String = arena.archives.target_word()
			for n in word.length(): key(word.unicode_at(n),word.unicode_at(n))
			key(KEY_ENTER)
			verify(arena.archives.score == 1 and arena.fighters[1].health < 100, "Typed command applied to the actual opponent")
		count += 1

func key(code: int, unicode := 0) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.unicode = unicode
	event.pressed = true
	arena._input(event)

func run() -> void:
	arena = Arena.new()
	root.add_child(arena)
	await process_frame
	arena.set_physics_process(false)
	cases_and_routes()
	roster_and_stages()
	styles()
	new_styles()
	boss_scans()
	case_rules()
	archives_and_keys()
	arena.queue_free()
	await process_frame
	print("DOSSIER SAGA: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
