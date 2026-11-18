extends SceneTree
const Arena := preload("res://src/dossier_curien/arena.gd")
var a
var assertions := 0
var errors := 0
var done_count := 0
func check(ok: bool, label: String) -> void:
	assertions += 1
	if not ok:
		errors += 1
		push_error(label)
func _initialize(): call_deferred("run")
func step(n:=1):
	for i in n: a._physics_process(1.0/60.0)
func key(code):
	var e := InputEventKey.new()
	e.pressed = true
	e.keycode = code
	a._input(e)
func click(label: String):
	for b in a.box.get_children():
		if b is Button and b.text.contains(label):
			b.pressed.emit()
			return
	check(false,"Missing button "+label+" on "+a.phase)
func run():
	a=Arena.new()
	root.add_child(a)
	await process_frame
	a.set_physics_process(false)
	var path: String = "user://lab_test_%d.cfg" % Time.get_ticks_usec()
	a.lab.save_file=path
	a.mode=4
	a.stage=0
	a.enemy=2
	for i in a.Fighter.PROFILES.size():
		a.chosen=i
		a.start_match()
		for task in 3:
			a.pause_menu()
			click("Atelier technique")
			click(a.lab.DRILLS[task])
			check(a.phase=="fight" and a.lab.drill==task, "Exercise entry")
			if task==0: key(KEY_U)
			if task==1: key(KEY_J)
			if task==2: key(KEY_L)
			for tick in 160:
				if task==1 and a.fighters[0].action=="light" and a.fighters[0].confirmed:
					key(KEY_K)
				step()
				if a.lab.cleared: break
			check(a.lab.cleared, "Authored exercise %s, %s" % [i,task])
			if a.lab.cleared: done_count+=1
			check(a.lab.history.size()>0 and a.lab.history.size()<=3,"Impact history")
	var save := ConfigFile.new()
	check(save.load(path)==OK and save.get_sections().size()==a.Fighter.PROFILES.size(),"Completion persisted per fighter")
	a.chosen=19
	a.start_match()
	a.pause_menu()
	click("Atelier technique")
	click("Cadence")
	click("Reprendre l’entraînement")
	step(60)
	check(a.elapsed==30,"Half-speed simulation")
	a.pause_menu()
	click("Atelier technique")
	click("Cadence")
	click("Reprendre l’entraînement")
	key(KEY_L)
	step(8)
	check(a.elapsed==30 and a.action_queue[0]=="special","Freeze preserves buffered command")
	key(KEY_N)
	step(8)
	check(a.elapsed==31 and a.fighters[0].action=="special" and a.fighters[0].tick==1,"One key advances exactly one tick")
	a.pause_menu()
	click("Atelier technique")
	key(KEY_ESCAPE)
	check(a.phase=="pause","Back goes to pause")
	a.lab.speed=0
	a.lab.start_exercise(a,0)
	key(KEY_J)
	step(20)
	check(not a.lab.cleared and a.lab.history[0].contains("gardé"),"Blocked light never passes throw drill")
	a.lab.start_exercise(a,1)
	key(KEY_J)
	step(60)
	key(KEY_K)
	step(45)
	check(not a.lab.cleared,"Late heavy outside the cancel is rejected")
	a.mode=1
	a.lab.speed=2
	a.start_match()
	step(12)
	check(a.elapsed==12,"Other modes ignore lab settings")
	a.pick_fighter(1,1)
	click("Tenues de Kate")
	check(a.phase=="costumes", "Wardrobe entry")
	a.case_id="scarlet"
	check(a.costumes.art_id(a,6)=="kate_soiree" and a.costumes.art_id(a,7)=="ryan_soiree","Scarlet default")
	click("Kate Green")
	check(a.costumes.art_id(a,6)=="kate","Original override")
	click("Kate Green")
	a.case_id=""
	check(a.costumes.art_id(a,6)=="kate_soiree" and a.costumes.art_id(a,7)=="ryan","Only selected agent changes")
	key(KEY_ESCAPE)
	check(a.phase=="select","Wardrobe restores selection")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	print("Atelier technique : %d/%d exercices, %d contrôles, %d erreurs." % [done_count,a.Fighter.PROFILES.size()*3,assertions,errors])
	a.audio_player.stop()
	a.queue_free()
	await process_frame
	quit(int(errors>0))
