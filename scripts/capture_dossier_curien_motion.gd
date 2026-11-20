extends SceneTree
## Native Godot calibration captures using the production fighter renderer.
## No save files or source resources are changed. A real display/rendering
## driver is required; headless/dummy rendering is deliberately rejected.
##
## godot --path CHECKOUT --resolution 1280x720 --audio-driver Dummy \
##   --script res://scripts/capture_dossier_curien_motion.gd -- \
##   --output /absolute/new-capture-directory [--only linda,zobio,zobiko,rogan]

const Arena := preload("res://src/dossier_curien/arena.gd")
const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
const Motion := preload("res://src/dossier_curien/saga_motion.gd")
const CASES := [
	{"id":"linda_block", "fighter":23, "pose":"block"},
	{"id":"linda_jump_rise", "fighter":23, "pose":"jump_rise"},
	{"id":"linda_jump_fall", "fighter":23, "pose":"jump_fall"},
	{"id":"linda_reload", "fighter":23, "pose":"reload"},
	{"id":"linda_throw", "fighter":23, "pose":"throw"},
	{"id":"linda_taunt", "fighter":23, "pose":"taunt"},
	{"id":"linda_victory_after_shot", "fighter":23, "pose":"victory"},
	{"id":"linda_finish_right", "fighter":23, "pose":"finish", "side":0},
	{"id":"linda_finish_left", "fighter":23, "pose":"finish", "side":1},
	{"id":"zobio_crouch_fallback", "fighter":9, "pose":"crouch", "expected":""},
	{"id":"zobio_windup", "fighter":9, "pose":"windup"},
	{"id":"zobio_contact", "fighter":9, "pose":"contact"},
	{"id":"zobio_recoil", "fighter":9, "pose":"recoil"},
	{"id":"zobio_recovery", "fighter":9, "pose":"recovery"},
	{"id":"zobio_walk1", "fighter":9, "pose":"walk1"},
	{"id":"zobio_walk2", "fighter":9, "pose":"walk2"},
	{"id":"zobiko_crouch_fallback", "fighter":15, "pose":"crouch", "expected":""},
	{"id":"zobiko_windup", "fighter":15, "pose":"windup"},
	{"id":"zobiko_contact", "fighter":15, "pose":"contact"},
	{"id":"zobiko_recoil", "fighter":15, "pose":"recoil"},
	{"id":"zobiko_recovery", "fighter":15, "pose":"recovery"},
	{"id":"zobiko_walk1", "fighter":15, "pose":"walk1"},
	{"id":"zobiko_walk2", "fighter":15, "pose":"walk2"},
	{"id":"rogan_crouch", "fighter":0, "pose":"crouch"},
	{"id":"rogan_crouch_guard_fallback", "fighter":0, "pose":"crouch_guard", "expected":"_crouch"},
	{"id":"rogan_jump_rise", "fighter":0, "pose":"jump_rise"},
	{"id":"stick_walk1", "fighter":10, "pose":"walk1"},
	{"id":"stick_walk2", "fighter":10, "pose":"walk2"},
	{"id":"stick_recovery", "fighter":10, "pose":"recovery"},
	{"id":"rikiya_walk1", "fighter":16, "pose":"walk1"},
	{"id":"rikiya_walk2", "fighter":16, "pose":"walk2"},
	{"id":"rikiya_recovery", "fighter":16, "pose":"recovery"},
	{"id":"rikiya_jump_rise", "fighter":16, "pose":"jump_rise"},
	{"id":"rikiya_jump_fall", "fighter":16, "pose":"jump_fall"},
	{"id":"rikiya_crouch", "fighter":16, "pose":"crouch"},
	{"id":"rikiya_crouch_guard", "fighter":16, "pose":"crouch_guard"},
	{"id":"rikiya_block", "fighter":16, "pose":"block"},
	{"id":"rikiya_throw", "fighter":16, "pose":"throw"},
	{"id":"rikiya_victory", "fighter":16, "pose":"victory"},
	{"id":"rikiya_taunt", "fighter":16, "pose":"taunt"},
	{"id":"rikiya_finish", "fighter":16, "pose":"finish"},
]

class CalibrationOverlay:
	extends Control
	var caption := ""
	var reference_height := 280.0
	var ground_y := 601.0
	func _draw() -> void:
		draw_rect(Rect2(32, 151, 1216, 62), Color(0.015, 0.025, 0.035, 0.88))
		draw_string(ThemeDB.fallback_font, Vector2(48, 178), caption, HORIZONTAL_ALIGNMENT_LEFT, 1184, 21, Color.WHITE)
		draw_string(ThemeDB.fallback_font, Vector2(48, 201), "Calibration de poses imposées · trait vert : sol · traits bleus : hauteur debout de référence", HORIZONTAL_ALIGNMENT_LEFT, 1184, 15, Color("9eb4c6"))
		draw_line(Vector2(45, ground_y), Vector2(1235, ground_y), Color(0.2, 1, 0.5, 0.8), 1.0)
		for x in [360.0, 900.0]:
			draw_line(Vector2(x - 120, ground_y - reference_height), Vector2(x + 120, ground_y - reference_height), Color(0.3, 0.65, 1, 0.8), 1.0)
			draw_line(Vector2(x, ground_y - 8), Vector2(x, ground_y + 8), Color(0.2, 1, 0.5, 0.8), 1.0)

var output := ""
var prefixes: Array[String] = []
var captures: Array[Dictionary] = []
var failures: Array[String] = []
var arena
var overlay: CalibrationOverlay

func _initialize() -> void:
	call_deferred("run")

func options() -> bool:
	var args := OS.get_cmdline_user_args()
	for index in range(0, args.size(), 2):
		if index + 1 >= args.size() or args[index] not in ["--output", "--only"]:
			failures.append("Usage: --output ABS_NEW_DIRECTORY [--only id_prefix,id_prefix]")
			return false
		if args[index] == "--output": output = args[index + 1]
		else:
			for prefix in str(args[index + 1]).split(",", false): prefixes.append(prefix)
	if not output.is_absolute_path() or output.contains("://"):
		failures.append("Output must be an absolute filesystem directory")
		return false
	if FileAccess.file_exists(output.path_join("capture_report.json")):
		failures.append("Choose a new capture directory; an existing report is never overwritten")
		return false
	return DirAccess.make_dir_recursive_absolute(output) == OK

func selected(identity: String) -> bool:
	if prefixes.is_empty(): return true
	for prefix in prefixes:
		if identity.begins_with(prefix): return true
	return false

func prepare_case(item: Dictionary) -> void:
	var id: int = item.fighter
	arena.mode = 2
	arena.stage = 0
	arena.phase = "fight"
	arena.resume_phase = ""
	arena.case_id = ""
	arena.edition_id = ""
	arena.winner = -1
	arena.elapsed = 0
	arena.flash = 0
	arena.wins = [0, 0]
	arena.clock_ticks = 3600
	arena.fighters = [Fighter.new(id, 360, 1), Fighter.new(id, 900, 1)]
	var side: int = item.get("side", 1)
	var fighter = arena.fighters[side]
	if side == 1 and item.pose == "finish": fighter.facing = -1
	match str(item.pose):
		"crouch", "crouch_guard":
			fighter.crouching = true
			fighter.guarding = item.pose == "crouch_guard"
		"block": fighter.block_ticks = 8
		"jump_rise", "jump_fall":
			fighter.altitude = 60
			fighter.vy = 6 if item.pose == "jump_rise" else -6
		"reload":
			fighter.ammo = 4
			fighter.action = "reload"
			fighter.tick = int(fighter.profile.reload) / 2
		"throw":
			fighter.action = "throw"
			fighter.tick = int(fighter.move_data().start)
		"taunt": fighter.taunt_ticks = 48
		"recoil": fighter.stun = 8
		"walk1", "walk2":
			fighter.moving = true
			fighter.walk_ticks = 1 if item.pose == "walk1" else 13
		"windup", "contact", "recovery":
			fighter.action = "special"
			fighter.tick = int(fighter.profile.move.start) - 2 if item.pose == "windup" else int(fighter.profile.move.start) + 1 if item.pose == "contact" else int(fighter.profile.move.end) - 3
		"victory", "finish":
			# Keep the last shot frozen at first contact to expose any stale VFX.
			fighter.action = "special"
			fighter.tick = int(fighter.profile.move.start)
			arena.winner = side
			arena.phase = "result" if item.pose == "victory" else "cinematic"
			arena.finish_ticks = 70
	arena.panel.hide()
	overlay.reference_height = float(fighter.profile.height)
	overlay.ground_y = Painter.floor_y(arena.stage)
	var reference_side := "Droite" if side == 0 else "Gauche"
	var pose_side := "gauche" if side == 0 else "droite"
	overlay.caption = "%s · %s : garde de référence · %s : %s" % [fighter.profile.title, reference_side, pose_side, str(item.pose)]
	arena.queue_redraw()
	overlay.queue_redraw()

func run() -> void:
	if not options():
		printerr("CAPTURE OPTIONS: " + str(failures))
		quit(1)
		return
	if DisplayServer.get_name() == "headless" or RenderingServer.get_current_rendering_method() == "dummy":
		printerr("CAPTURE BLOCKED: a real native display and rendering driver are required; no headless screenshot is claimed.")
		quit(2)
		return
	root.size = Vector2i(1280, 720)
	root.content_scale_size = Vector2i(1280, 720)
	arena = Arena.new()
	root.add_child(arena)
	await process_frame
	arena.set_physics_process(false)
	overlay = CalibrationOverlay.new()
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arena.add_child(overlay)
	var manifest_path := "res://data/assets/dossier_curien_motion.json"
	var before_hash := FileAccess.get_sha256(manifest_path)
	var manifest_hashes := {}
	var provisional_by_path := {}
	var any_provisional := false
	for collection_path in Motion.MANIFESTS:
		manifest_hashes[collection_path] = FileAccess.get_sha256(collection_path)
		var collection = JSON.parse_string(FileAccess.get_file_as_string(collection_path))
		var provisional: bool = collection.get("provisional",false) if collection is Dictionary else true
		provisional_by_path[collection_path] = provisional
		any_provisional = any_provisional or provisional
	for item: Dictionary in CASES:
		if not selected(item.id): continue
		var path := output.path_join(item.id + ".png")
		if FileAccess.file_exists(path):
			failures.append("Refusing to overwrite " + path)
			continue
		prepare_case(item)
		await process_frame
		await RenderingServer.frame_post_draw
		var image: Image = root.get_texture().get_image()
		if image == null or image.is_empty() or image.save_png(path) != OK:
			failures.append("Cannot capture the rendered viewport: " + item.id)
			continue
		var side: int = item.get("side", 1)
		var fighter = arena.fighters[side]
		var art_id: String = fighter.profile.id
		var actual: String = arena.visuals.pose_suffix(fighter, art_id, arena, side)
		var expected: String = item.get("expected", "_" + str(item.pose))
		var visible_pose := actual if actual != "" else "_guard"
		var emitter: Dictionary = arena.visuals.rendered_pose_emitters.get(side, {})
		var emitter_position: Array = []
		if emitter.has("position"): emitter_position = [emitter.position.x, emitter.position.y]
		if actual != expected: failures.append("Pose not ready: %s expected %s, got %s" % [item.id, expected, actual])
		captures.append({"id":item.id, "path":path, "sha256":FileAccess.get_sha256(path), "dimensions":[image.get_width(),image.get_height()],
			"fighter_id":art_id, "side":side, "requested_pose":item.pose, "expected_suffix":expected, "selected_suffix":actual, "selection_matches":actual==expected,
			"phase":arena.phase, "action":fighter.action, "action_tick":fighter.tick, "action_effects_active":Painter.action_effects_active(arena),
			"standing_world_height":fighter.profile.height, "render_height":arena.visuals.pose_height(fighter,art_id,visible_pose),
			"native_calibration":arena.visuals.motion.get_entry(art_id+visible_pose), "rendered_emitter_pose":emitter.get("pose", ""), "rendered_emitter_world":emitter_position})
	var after_hash := FileAccess.get_sha256(manifest_path)
	var collections_stable := true
	for collection_path in manifest_hashes:
		if manifest_hashes[collection_path] != FileAccess.get_sha256(collection_path): collections_stable = false
	var report := {"scope":"isolated_pose_calibration", "scripted_states":true, "full_gameflow_validated":false, "canonical_fidelity_validated":false,
		"engine":Engine.get_version_info().string, "display_server":DisplayServer.get_name(), "rendering_method":RenderingServer.get_current_rendering_method(),
		"manifest_provisional":any_provisional, "manifest_provisional_by_path":provisional_by_path, "manifest_sha256":before_hash,
		"manifest_stable_during_capture":before_hash==after_hash and collections_stable, "manifest_sha256_by_path":manifest_hashes,
		"presentation_sha256":FileAccess.get_sha256("res://src/dossier_curien/presentation.gd"),
		"captures":captures, "failures":failures}
	var handle := FileAccess.open(output.path_join("capture_report.json"), FileAccess.WRITE)
	if handle == null:
		failures.append("Cannot write capture report")
	else:
		handle.store_string(JSON.stringify(report, "\t") + "\n")
		handle.close()
	print("MOTION NATIVE CAPTURE: %d rendered PNG; %d pending poses/errors; %s" % [captures.size(), failures.size(), output])
	arena.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)
