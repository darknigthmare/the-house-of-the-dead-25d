extends SceneTree

const Arena := preload("res://src/dossier_curien/arena.gd")
const Rush := preload("res://src/dossier_curien/saga_rush.gd")
var a
var checks := 0
var failures := 0
var folder := "user://rush_test_" + str(Time.get_ticks_usec())

func _initialize() -> void:
	call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func press(label: String) -> void:
	for child in a.box.get_children():
		if child is Button and child.text.begins_with(label):
			child.pressed.emit()
			return
	check(false, "Missing button " + label + " in " + a.phase)

func enter(course: Dictionary) -> void:
	a.menu()
	press("Boss Rush AMS")
	press(course.title)
	press("Thomas Rogan")
	check(a.phase == "rush_intro", "Course briefing")
	press("Démarrer le circuit")

func run() -> void:
	a = Arena.new()
	root.add_child(a)
	a.set_physics_process(false)
	DirAccess.make_dir_absolute(ProjectSettings.globalize_path(folder))
	a.rush.save_directory = folder
	for course in Rush.COURSES:
		enter(course)
		var sum_ticks := 0
		for i in course.bouts.size():
			check(a.mode == Rush.MODE and a.enemy == course.bouts[i][0] and a.stage == course.bouts[i][1], "Authored encounter")
			if i == 1:
				check(a.fighters[0].health == 74 and a.fighters[0].ammo == 2, "Paid heal and ammo carry")
			if i == 2:
				check(a.fighters[0].health == 56 and a.fighters[0].ammo == a.fighters[0].profile.ammo, "Paid magazine and health carry")
			a.fighters[0].health = 56
			a.fighters[0].ammo = 2
			a.fighters[1].health = 0
			a.elapsed = 120+i
			sum_ticks += a.elapsed
			a.round_over()
			if i < course.bouts.size()-1:
				check(a.phase == "rush_service", "Intermediate service")
				if i == 0:
					press("Soins")
					sum_ticks += 300
				elif i == 1:
					press("Chargeur plein")
					sum_ticks += 180
				else:
					press("Repartir immédiatement")
			else:
				check(a.phase == "finish", "Final KO allows a finisher")
				check(a.rush.hud(a).ends_with(Rush.duration(sum_ticks)), "Race timer is settled once")
				a.trigger_finisher()
				for tick in 72: a._physics_process(1/60.0)
				check(a.phase == "result" and a.rush.read_record(a) == sum_ticks, "Final screen and saved record")
				a.rush.race_ticks = sum_ticks+10
				a.rush.show_result(a)
				check(a.rush.read_record(a) == sum_ticks, "Slower result preserves best")
				a.rush.race_ticks = sum_ticks-10
				a.rush.show_result(a)
				check(a.rush.read_record(a) == sum_ticks-10, "Faster result replaces best")
	enter(Rush.COURSES[0])
	a.clock_ticks = 0
	a.round_over()
	check(a.rush.overtime and a.clock_ticks == 600 and a.fighters[0].health == 1 and a.fighters[1].health == 1, "First tie starts sudden death")
	a.clock_ticks = 0
	a.round_over()
	check(a.phase == "result" and a.winner == 1, "Second tie ends attempt")
	press("Recommencer")
	check(a.rush.leg == 0 and a.rush.race_ticks == 0 and a.rush.starting_hp == 100, "Retry resets race")
	a.menu()
	press("Tournoi")
	check(a.mode == 3 and a.phase == "select", "Original tournament remains available")
	for f in DirAccess.get_files_at(folder):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(folder.path_join(f)))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder))
	print("Boss Rush AMS: %d checks, %d failures." % [checks,failures])
	a.queue_free()
	quit(1 if failures else 0)
