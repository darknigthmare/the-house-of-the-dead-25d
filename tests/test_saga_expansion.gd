extends SceneTree

const Arena := preload("res://src/dossier_curien/arena.gd")
const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Saga := preload("res://src/dossier_curien/saga.gd")
const Bestiary := preload("res://src/dossier_curien/saga_bestiary.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
var a
var checks := 0
var failures := 0
var redraws := 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func shots_and_slide() -> void:
	var linda := Fighter.new(23, 400, 1)
	var target := Fighter.new(0, 600, -1)
	check(linda.profile.id == "linda" and linda.ammo == 8, "Linda is appended with an eight-round pistol")
	check(Fighter.PROFILES.size() == Fighter.NOTES.size(), "Every fighter keeps its move-list note")
	check(linda.begin("special") and linda.ammo == 7, "Standing shot spends exactly one round")
	for tick in int(linda.profile.move.start): linda.step(0, false, "", target.x)
	check(linda.x == 400 and linda.can_strike(target), "Standing shot holds position and reaches a standing target")
	target.crouching = true
	check(not linda.can_strike(target), "Crouch avoids Linda's standing shot")
	target.crouching = false
	target.guarding = true
	check(not linda.hit(target) and target.health == 100, "Standing shot respects guard")
	linda.action = ""
	linda.ammo = 0
	check(not linda.begin("special") and linda.ammo == 0 and linda.action == "", "Empty pistol rejects attack without negative ammunition")
	check(linda.begin("reload"), "Empty pistol can reload")
	for tick in int(linda.profile.reload): linda.step(0, false, "", target.x)
	check(linda.ammo == 8 and linda.action == "", "Reload restores the magazine after its full recovery")
	check(not linda.begin("reload"), "Full magazine does not accept a redundant reload")
	var slide := Fighter.new(23, 400, 1)
	for tick in 8: slide.step(0, true, "special" if tick == 0 else "", target.x)
	check(slide.alternate_special and slide.x == 440 and slide.ammo == 7, "Down-special advances exactly forty units and costs one round")
	check(slide.crouching and not slide.guarding, "Slide lowers Linda without applying guard or invulnerability")
	var shooter := Fighter.new(0, 500, -1)
	shooter.begin("special")
	shooter.tick = shooter.profile.move.start
	check(not shooter.can_strike(slide), "The low startup avoids a high pistol shot")
	shooter.action = "throw"
	shooter.tick = shooter.move_data().start
	check(shooter.can_strike(slide), "A grounded throw can catch the slide")
	for tick in 11: slide.step(0, true, "", target.x)
	target.crouching = true
	target.guarding = false
	check(slide.x == 440 and slide.can_strike(target), "Low shot reaches a crouched target after movement stops")
	target.altitude = 70
	check(not slide.can_strike(target), "Jumping out of the low band avoids the sliding shot")
	target.altitude = 0
	slide.stun = 3
	check(not slide.can_strike(target), "Hit stun interrupts the shot")
	slide.stun = 0
	check(slide.hit(target) and target.health == 88, "Unblocked sliding shot deals twelve damage")
	check(not slide.can_strike(target), "One sliding shot cannot hit twice")
	var reverse := Fighter.new(23, 600, -1)
	for tick in 8: reverse.step(0, true, "special" if tick == 0 else "", 300)
	check(reverse.x == 560, "Slide respects facing on the other side")
	var air := Fighter.new(23, 400, 1)
	air.altitude = 60
	air.begin("special", true)
	check(not air.alternate_special, "Airborne down-special cannot start a grounded slide")

func gallery_and_story() -> void:
	check(a.visuals.guard_art(23) is Texture2D, "Linda's independent recovered master is loaded in combat")
	check(a.visuals.pose_profiles.has("linda_guard"), "Native alpha bounds calibrate Linda's grounded pivot")
	check(Saga.opponents("revenge",23) == [10,16,12], "Linda's simulation route meets both partners before its guest boss")
	check(Saga.ALTERNATE_STORIES[23].size() == 4, "Linda has introduction, rival, finale and ending")
	a.case_details("revenge")
	a.pick_fighter(0)
	var found := false
	for button in a.box.get_children():
		if button is Button and button.text.begins_with("Linda Rotta"): found = true
	check(found, "Zombie Revenge's story menu offers its third protagonist")
	a.choose(23)
	check(a.phase == "brief" and a.chosen == 23 and a.enemy == 10, "Linda's story enters its own briefing")
	a.start_match()
	check(a.fighters[0].id == 23 and a.fighters[0].ammo == 8, "Linda is a real match participant")
	a.bestiary.show(a)
	check(a.phase == "bestiary" and not a.bestiary.assets.is_empty() and a.fighters.is_empty(), "Bestiary opens and leaves the prior match")
	var total: int = a.bestiary.assets.size()
	for button in a.box.get_children():
		if button is Button and button.text.begins_with("Page suivante"):
			button.pressed.emit()
			break
	check(a.bestiary.page == 1 and a.phase == "bestiary", "Next-page button preserves the arena argument")
	for button in a.box.get_children():
		if button is Button and button.text.contains("Page précédente"):
			button.pressed.emit()
			break
	check(a.bestiary.page == 0, "Previous-page button returns to the first subjects")
	a.bestiary.select_filter(a,1)
	var revenge: Array = a.bestiary.filtered()
	check(not revenge.is_empty() and revenge.size() < total, "Zombie Revenge filter isolates its collection")
	for entry in revenge: check(a.bestiary.family(entry) == "zombie_revenge", "No EX subject leaks into Zombie Revenge")
	var linda_index := -1
	for i in revenge.size():
		if revenge[i].id == "linda_rotta": linda_index = i
	check(linda_index >= 0, "Recovered Linda appears as a gallery subject")
	if linda_index >= 0:
		a.bestiary.detail(a,linda_index)
		check(a.phase == "bestiary_detail" and a.bestiary.fighter_id(revenge[linda_index]) == 23, "Linda detail identifies the playable fighter")
		var event := InputEventKey.new()
		event.keycode = KEY_ESCAPE
		event.pressed = true
		a._input(event)
		check(a.phase == "bestiary" and a.bestiary.filter_index == 1, "Escape preserves the gallery filter and list page")
		a.bestiary.play(a,23)
		check(a.phase == "opponent" and a.chosen == 23 and a.mode == 1, "Gallery's Play Linda action enters opponent selection")
	a.bestiary.select_filter(a,2)
	check(not a.bestiary.filtered().is_empty(), "EX filter has its own subjects")
	for entry in a.bestiary.filtered(): check(a.bestiary.fighter_id(entry) < 0, "Static EX assets are not offered as new playable fighters")

func painted_muzzle() -> void:
	check(Painter.finite_numbers([1024,1536.0],2), "Pose calibration accepts finite integer and float coordinates")
	check(not Painter.finite_numbers([1024,"1536"],2) and not Painter.finite_numbers([1024,INF],2) and not Painter.finite_numbers(null,2), "Malformed calibration is rejected before coordinate arithmetic")
	if a.visuals.saga_texture("linda_contact") is Texture2D:
		check(a.visuals.pose_emitters.get("linda_contact",Vector2.ZERO) == Vector2(910,249), "Linda contact loads its native muzzle coordinates")
	var source := Vector2(1024,1536)
	var point := Vector2(910,249)
	var pivot := Vector2(0.5,1457.0/1536.0)
	var drawn := Vector2(204.8,307.2)
	var right := Transform2D(0,Vector2(400,601))
	var right_point := Painter.painted_point(point,source,drawn,pivot,right)
	check(right_point.is_equal_approx(Vector2(479.6,359.4)), "Non-square native image places the flash at the barrel instead of the torso")
	var left := Transform2D(0,Vector2(400,601))
	left.x *= -1
	var left_point := Painter.painted_point(point,source,drawn,pivot,left)
	check(left_point.is_equal_approx(Vector2(320.4,359.4)), "Mirroring the sprite mirrors its flash about the fighter pivot")
	var turned := Transform2D(0.17,Vector2(415,608))
	turned.x *= -1
	var native_offset := Vector2(79.6,-241.6)
	check(Painter.painted_point(point,source,drawn,pivot,turned).is_equal_approx(turned*native_offset), "Tilt and shifted ground position are shared with the rendered sprite")
	var low := Painter.painted_point(point,source,drawn*0.71,pivot,right)
	check(low.is_equal_approx(right.origin+(right_point-right.origin)*0.71), "Low-pose scaling keeps the emitter attached to the same native pixel")
	var anchored := Painter.painted_point(pivot*source,source,drawn,pivot,turned)
	check(anchored.is_equal_approx(turned.origin), "The measured foot pixel remains exactly at the drawn pivot")

func linda_low_poses() -> void:
	var linda := Fighter.new(23,400,1)
	linda.step(0,true,"",700)
	check(a.visuals.pose_suffix(linda) == "_crouch", "Crouching Linda selects the anatomical low pose")
	linda.step(-1,true,"",700)
	check(linda.guarding and a.visuals.pose_suffix(linda) == "_crouch_guard", "Low guard has its own painted pose")
	linda.step(0,true,"special",700)
	check(linda.alternate_special and a.visuals.pose_suffix(linda) == "_slide_contact", "Grounded low special selects the sliding pose during startup")
	check(Painter.special_name(linda) == "Glissade armée", "HUD names the active alternate move")
	for tick in 19: linda.step(0,false,"",700)
	check(linda.crouching and a.visuals.pose_suffix(linda) == "_slide_contact", "The shot remains in the low pose during its active window")
	for tick in 4: linda.step(0,false,"",700)
	check(not linda.crouching and a.visuals.pose_suffix(linda) == "_recovery", "The standing recovery resumes after the low window")
	linda.stun = 4
	check(a.visuals.pose_suffix(linda) == "_recoil", "Hit reaction takes priority over low poses")
	linda.stun = 0
	linda.action = ""
	check(Painter.special_name(linda) == "Tir de liaison", "HUD returns to the default move after recovery")
	var standing: Dictionary = a.visuals.pose_profiles.linda_guard
	var size_values: Array = standing.source_size
	var source := Vector2(size_values[0],size_values[1])
	var low_size: Vector2 = a.visuals.linda_low_canvas_size(source,261)
	check(is_equal_approx(low_size.y,261.0/standing.body_fraction), "Low artwork retains standing anatomical pixel scale instead of shrinking the whole fighter")
	for suffix in ["crouch","crouch_guard","slide_contact"]:
		if a.visuals.saga_texture("linda_"+suffix) is Texture2D:
			check(a.visuals.pose_profiles.has("linda_"+suffix), "Imported low pose has its own grounded pivot: "+suffix)
	if a.visuals.saga_texture("linda_slide_contact") is Texture2D:
		check(a.visuals.pose_emitters.has("linda_slide_contact"), "Sliding shot loads its own native muzzle measurement")

func frozen_resume_redraw() -> void:
	a.menu()
	a.mode = 4
	a.chosen = 23
	a.enemy = 0
	a.start_match()
	a.lab.speed = 2
	a.pause_menu()
	a.lab.open(a)
	for tick in 3: await process_frame
	var before: int = redraws
	var elapsed: int = a.elapsed
	a.resume()
	for tick in 3: await process_frame
	check(a.phase == "fight" and not a.panel.visible and a.elapsed == elapsed, "Frame-step resume closes the panel without advancing combat")
	check(redraws > before, "Resuming frame-step training redraws the combat HUD before the next manual tick")

func invalid_gallery_data() -> void:
	var path := "user://bestiary_manifest_test_%d.json" % Time.get_ticks_usec()
	var valid := {"id":"test_linda", "name":"Linda", "game":"zombie_revenge", "category":"character_base", "path":"assets/dossier_curien/expansion/zombie_revenge_characters/linda_rotta_base.png"}
	var external := valid.duplicate()
	external.id = "external"
	external.path = "assets/dossier_curien/rogan_guard.png"
	var missing := valid.duplicate()
	missing.id = "missing"
	missing.path = "assets/dossier_curien/expansion/missing.png"
	var frame := valid.duplicate()
	frame.id = "frame"
	frame.category = "fighter_pose"
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"assets":[valid,valid,external,missing,frame,"bad-row"]}))
	file.close()
	var gallery := Bestiary.new()
	check(gallery.load_manifest(path) and gallery.assets.size() == 1, "Gallery rejects duplicates, missing art, animation rows and out-of-collection paths")
	file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify({"assets":"not-an-array"}))
	file.close()
	check(not gallery.load_manifest(path) and gallery.assets.is_empty(), "Malformed collection fails cleanly without retaining stale entries")
	check(not gallery.load_manifest("user://missing_collection.json"), "Missing collection fails cleanly")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func verify_sheet_layout(label: String) -> void:
	for tick in 3: await process_frame
	var rect: Rect2 = a.panel.get_rect()
	var minimum: Vector2 = a.panel.get_combined_minimum_size()
	check(rect.size.y >= minimum.y-0.5 and rect.size.y > 200, label + ": panel encloses the reconstructed minimum height")
	check(rect.position.y >= -0.5 and rect.end.y <= a.size.y+0.5, label + ": panel remains inside the viewport vertically")
	var panel_rect: Rect2 = a.panel.get_global_rect()
	var children_fit := true
	for node in a.box.get_children():
		if node is Control and node.visible and not panel_rect.encloses(node.get_global_rect()): children_fit = false
	check(children_fit, label + ": visible rows remain inside the panel")

func gallery_layout() -> void:
	a.menu()
	await verify_sheet_layout("Main menu")
	a.bestiary.select_filter(a,0)
	await verify_sheet_layout("All subjects")
	var selected := 0
	for index in a.bestiary.assets.size():
		if str(a.bestiary.assets[index].id).contains("black_magician"): selected = index
	a.bestiary.detail(a,selected)
	await verify_sheet_layout("Subject detail")
	a.bestiary.show(a,a.bestiary.page)
	await verify_sheet_layout("Return from detail")
	a.bestiary.select_filter(a,2)
	await verify_sheet_layout("EX filter with the same row count")
	a.bestiary.show(a,1)
	await verify_sheet_layout("EX second page")
	a.bestiary.select_filter(a,0)
	a.bestiary.select_filter(a,2)
	a.bestiary.select_filter(a,1)
	await verify_sheet_layout("Latest of three immediate filter changes")

func run() -> void:
	a = Arena.new()
	root.add_child(a)
	a.draw.connect(func(): redraws += 1)
	await process_frame
	a.set_physics_process(false)
	shots_and_slide()
	gallery_and_story()
	painted_muzzle()
	linda_low_poses()
	invalid_gallery_data()
	await gallery_layout()
	await frozen_resume_redraw()
	a.audio_player.stop()
	a.queue_free()
	await process_frame
	print("SAGA EXPANSION: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)
