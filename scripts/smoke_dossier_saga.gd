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
			var personal_cards := [] if id == 23 else ["intro","rival","ending"]
			if id in [21,22]: personal_cards.append("final")
			for card in personal_cards:
				verify(arena.visuals.saga_texture(Fighter.PROFILES[id].id+"_"+card) is Texture2D, "Registered alternate story illustration %d/%s" % [id,card])
			arena.start_match()
			victory()
			click("Ouvrir le relevé")
			verify(arena.stage == Saga.stages_for(home,id)[2], "Registered final arena for %d" % id)
			arena.start_match()
			victory()
			verify(arena.box.get_child(1).text == Saga.ALTERNATE_STORIES[id][3], "Personal epilogue for %d" % id)

func roster_and_stages() -> void:
	verify(Fighter.PROFILES.size() == 24, "Gallery-only silhouettes preserve the 24 playable fighters")
	verify(Saga.STAGES.size() == 24 and Saga.ART.size() == 24, "Twenty-four arenas have aligned art registrations")
	for i in Fighter.PROFILES.size():
		var profile: Dictionary = Fighter.PROFILES[i]
		verify(arena.visuals.guard_art(i) is Texture2D, "Registered combat art for " + str(profile.id))
		for suffix in ["_select","_windup","_contact","_recoil"]:
			var tex: Texture2D = arena.visuals.classic_art(profile.id+suffix) if i < 4 else arena.visuals.saga_texture(profile.id+suffix)
			if i == 23 and suffix == "_select": tex = arena.visuals.guard_art(i)
			verify(tex is Texture2D, "Registered " + str(profile.id)+suffix)
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
		for layer in ["_mid","_front"]:
			verify(arena.visuals.saga_texture(Saga.ART[i]+layer) is Texture2D, "Registered plane "+Saga.ART[i]+layer)
	for home in ["hotd2","hotd3","hotd4","scarlet"]:
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
			# Linda's authored throw is a non-firing pose, like Gary's elbow.
			if i == 23 and cmd == "throw": expected = "_throw"
			verify(arena.visuals.pose_suffix(f) == expected, "Firearm contact excluded from %d/%s" % [i,cmd])
		f.action = "special"
		f.tick = f.move_data().start
		verify(arena.visuals.pose_suffix(f) == "_contact", "Firearm contact for %d special" % i)

func pandora_and_ark() -> void:
	var world := Fighter.new(21,400,1)
	var rival := Fighter.new(6,470,-1)
	world.begin("special")
	world.tick = world.move_data().start
	rival.crouching = true
	verify(not world.can_strike(rival), "Crouch beneath both high ice volleys")
	rival.crouching = false
	verify(world.can_strike(rival) and world.hit(rival) and rival.frost_ticks == 36, "A landed shard frosts the target")
	rival.stun = 0
	var before := rival.x
	rival.step(-1,false,"",world.x)
	verify(is_equal_approx(before-rival.x,rival.profile.speed*0.5), "Frost slows actual walk displacement")
	for n in 35: rival.step(0,false,"",world.x)
	verify(rival.frost_ticks==0,"Frost expires after 36 simulated ticks")
	before = rival.x
	rival.step(-1,false,"",world.x)
	verify(is_equal_approx(before-rival.x,float(rival.profile.speed)), "Frost expiry restores full walk speed")
	world.action = ""
	world.begin("special",true)
	world.tick = world.move_data().start
	rival.crouching = true
	verify(world.special_hits()==1 and world.can_strike(rival), "Grounded hatchet punishes crouch")
	rival.guarding = true
	verify(not world.hit(rival) and rival.frost_ticks==0, "Blocking hatchet keeps the defender unfrozen")
	var moon := Fighter.new(22,400,1)
	moon.begin("special")
	moon.tick = moon.move_data().start
	rival.x=750
	verify(not moon.can_strike(rival), "The arm cannot hit ahead of the growing tip")
	moon.tick+=10
	rival.x=moon.x+moon.surge_radius()
	verify(moon.can_strike(rival), "The advancing wooden tip lands at the rendered position")
	rival.altitude=80
	verify(not moon.can_strike(rival),"Jump over the tip of the arm")
	moon.action=""
	moon.begin("special",true)
	moon.tick=moon.move_data().start
	rival.x=moon.x+125
	verify(not moon.can_strike(rival),"The eye of the cyclone leaves a close safe zone")
	rival.x=moon.x+350
	rival.guarding=false
	before=rival.x
	verify(moon.can_strike(rival) and moon.hit(rival) and rival.x==before-78, "Cyclone draws an unguarded opponent inwards")
	for variant in [[4,"james"],[5,"lisa"],[6,"kate"],[6,"kate_soiree"],[7,"ryan"],[7,"ryan_soiree"],[19,"gary"],[20,"daniel"]]:
		var id: int = variant[0]
		var sheet_id: String = variant[1]
		var walker := Fighter.new(id,400,1)
		for suffix in ["_walk1","_walk2"]:
			verify(arena.visuals.saga_texture(sheet_id+suffix) is Texture2D, "Registered stride "+sheet_id+suffix)
		var phases: Array[String] = []
		for tick in 24:
			walker.step(1,false,"",1000)
			if tick % 6 == 0: phases.append(arena.visuals.pose_suffix(walker,sheet_id))
		verify(phases==["_walk1","_guard","_walk2","_guard"], "Forward stride for "+sheet_id)
		walker.step(0,false,"",1000)
		verify(walker.walk_ticks==0 and arena.visuals.pose_suffix(walker,sheet_id)=="", "Release direction returns to neutral")
		phases.clear()
		for tick in 24:
			walker.step(-1,false,"",1000)
			if tick % 6 == 0: phases.append(arena.visuals.pose_suffix(walker,sheet_id))
		verify(phases==["_guard","_walk2","_guard","_walk1"], "Backward stride keeps the selected costume for "+sheet_id)
		walker.stun = 8
		verify(arena.visuals.pose_suffix(walker,sheet_id)=="_recoil", "Impact interrupts the walking pose")
		walker.stun = 0
		walker.step(0,false,"",1000)
		walker.step(1,false,"jump",1000)
		verify(walker.altitude>0 and arena.visuals.pose_suffix(walker,sheet_id)=="", "An airborne walker never uses grounded steps")
	verify(not arena.visuals.has_walk_cycle(7,"ryan_missing"), "A missing costume never borrows another costume's stride")
	var no_stride := Fighter.new(7,400,1)
	no_stride.step(1,false,"",1000)
	verify(arena.visuals.pose_suffix(no_stride,"unpainted_test_costume")=="", "A costume without a full painted cycle keeps the existing movement")
	verify(arena.visuals.stage_plane(2,"mid")==null, "Classic stages retain their own scenery path")
	for pose in ["james_walk1","james_walk2","lisa_walk1","lisa_walk2","ryan_walk1","ryan_walk2","ryan_soiree_walk1","ryan_soiree_walk2",
		"linda_guard","linda_windup","linda_contact","linda_recovery","linda_recoil","linda_walk1","linda_walk2"]:
		verify(arena.visuals.pose_profiles.has(pose), "Registered native painted pivot: " + pose)
	var loaded_props: Array = []
	for prop in arena.visuals.saga_props:
		loaded_props.append(str(prop.id))
	verify(loaded_props.has("efi_alarm_beacon") and loaded_props.has("subway_ticket_machine"), "Both independent stage props are registered with the renderer")
	for prop in ["props/efi_alarm_beacon","props/subway_ticket_machine"]:
		verify(arena.visuals.saga_texture(prop) is Texture2D, "Registered independent stage prop "+prop)
	var course: Dictionary=arena.Rush.COURSES.back()
	verify(course.id=="pandore_arche" and course.bouts==[[13,5],[21,15],[22,16]], "New course uses provenances of Justice, The World and Moon")

func production_assets() -> void:
	for id in [0, 1, 3]:
		var fighter := Fighter.new(id, 400, 1)
		var key: String = fighter.profile.id
		verify(arena.visuals.classic_art(key + "_recovery") is Texture2D, "Classic recovery loaded: " + key)
		fighter.begin("special")
		verify(arena.visuals.pose_suffix(fighter) == "_windup", "Classic special starts with its authored anticipation")
		fighter.tick = fighter.move_data().start
		verify(arena.visuals.pose_suffix(fighter) == "_contact", "Classic special shows its contact art")
		fighter.tick += 3
		verify(arena.visuals.pose_suffix(fighter) == "_recovery", "Classic special releases contact after its active frames")
		fighter.stun = 8
		verify(arena.visuals.pose_suffix(fighter) == "_recoil", "Classic hit reaction interrupts every attack phase")
		verify(arena.visuals.contact_emitters.has(key), "Classic effect has a measured source anchor: " + key)
	for costume in ["kate", "kate_soiree"]:
		for suffix in ["_walk1", "_walk2"]:
			var tex: Texture2D = arena.visuals.saga_texture(costume + suffix)
			verify(tex is Texture2D, "Native stride loaded: " + costume + suffix)
			if tex == null: continue
			var bounds: Rect2 = arena.visuals.visible_bounds(tex)
			verify(bounds.has_area() and bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < tex.get_width() and bounds.end.y < tex.get_height(), "Registered body excludes transparent margins: " + costume + suffix)
	var kate := Fighter.new(6, 400, 1)
	for preference in [1, 2]:
		arena.costumes.preference[6] = preference
		verify(arena.costumes.art_id(arena, 6) == ("kate" if preference == 1 else "kate_soiree"), "Manual outfit selects its own stride set")
	arena.costumes.preference[6] = 0
	for tick in 24: kate.step(-1, false, "", 1000)
	verify(kate.guarding and kate.x < 400 and arena.visuals.pose_suffix(kate) == "_walk1", "Retreat uses reverse grounded stride while guarding")
	kate.stun = 10
	verify(arena.visuals.pose_suffix(kate) == "_recoil", "A hit interrupts the stride immediately")
	for prop in ["venice_lamp", "venice_railing", "venice_bollard"]:
		var tex: Texture2D = arena.visuals.saga_texture("props/" + prop)
		verify(tex is Texture2D, "Individual quay prop loaded: " + prop)
		if tex != null:
			var bounds: Rect2 = arena.visuals.visible_bounds(tex)
			verify(bounds.has_area() and bounds.size.x < tex.get_width() and bounds.size.y < tex.get_height(), "Measured prop bounds: " + prop)
	arena.menu()
	click("Duel local")
	pages(6 / arena.PAGE_SIZE)
	click("Kate Green")
	click("James Taylor", true)
	pages(17 / arena.PAGE_SIZE)
	click("Rue dévastée de Despair", true)
	verify(arena.phase == "fight" and arena.stage == 17 and arena.fighters[0].id == 6 and arena.fighters[1].id == 4, "New street is reachable through the actual duel selection")

func boss_scans() -> void:
	for id in ["hotd2","hotd3","hotd4","scarlet"]:
		var dossier: Dictionary = Saga.CASES[id]
		arena.case_details(id)
		arena.choose(dossier.lead)
		arena.next_story()
		arena.next_story()
		verify(arena.has_boss_scan() and arena.enemy == {"hotd2":17,"hotd3":18,"hotd4":21,"scarlet":22}[id], "Canonical final opponent for "+id)
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
	verify(editions.size() == 29, "29 playable archives")
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

func advance_signals(to_tick: int) -> void:
	while arena.archives.age < to_tick:
		arena.archives.tick(arena, "reawakened")

func reawakened() -> void:
	var board = arena.archives
	arena.edition_details(board.entries().back(),5)
	arena.start_exhibition()
	verify(arena.edition_id == "reawakened" and board.active.rule == "openings", "Dedicated Reawakened circuit")
	advance_signals(47)
	key(KEY_TAB)
	verify(board.progress == 0 and not board.opening_live(), "Closed shutters ignore early input")
	advance_signals(48)
	arena.pause_menu()
	arena._physics_process(1/60.0)
	verify(board.age == 48 and board.progress == 0, "Pause freezes the opening clock")
	arena.resume()
	key(KEY_TAB)
	key(KEY_TAB)
	verify(board.progress == 1 and board.score == 0, "Tab operates the left shutter once")
	advance_signals(215)
	var view := InputEventJoypadButton.new()
	view.button_index = JOY_BUTTON_BACK
	view.pressed = true
	verify(board.handle_key(arena,"reawakened",view) and board.progress == 2, "View confirms the front door on its last open tick")
	advance_signals(287)
	var player = arena.fighters[0]
	var foe = arena.fighters[1]
	foe.x = player.x+80
	foe.stun = 10
	player.begin("light")
	player.tick = player.move_data().start-1
	arena._physics_process(1/60.0)
	verify(board.score == 1 and board.progress == 3 and foe.health == 100-int(player.move_data().damage)-12 and foe.stun >= 14, "A confirmed hit on the right shutter completes the circuit")
	key(KEY_TAB)
	verify(board.score == 1 and board.hud_line(arena,"reawakened").contains("Séries 1"), "The HUD counts full circuits and repeats cannot pay twice")
	advance_signals(360)
	verify(board.progress == 0 and board.score == 1, "A fresh cycle keeps the round total")
	advance_signals(455)
	key(KEY_TAB)
	advance_signals(576)
	key(KEY_TAB)
	verify(board.progress == 0 and board.score == 1, "Missing the front door resets the chain at the close edge")
	advance_signals(648)
	key(KEY_TAB)
	verify(board.progress == 0, "The right shutter cannot restart a broken circuit")
	arena.start_round()
	verify(board.age == 0 and board.score == 0 and board.progress == 0, "A new round resets the Reawakened circuit")

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
	pandora_and_ark()
	production_assets()
	boss_scans()
	case_rules()
	archives_and_keys()
	reawakened()
	arena.audio_player.stop()
	arena.queue_free()
	# Let the headless audio mixer retire the last WAV playback before shutdown.
	await create_timer(0.1).timeout
	print("DOSSIER SAGA: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
