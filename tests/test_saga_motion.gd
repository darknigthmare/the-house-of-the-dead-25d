extends SceneTree
const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
const Motion := preload("res://src/dossier_curien/saga_motion.gd")
const Arena := preload("res://src/dossier_curien/arena.gd")
var checks := 0
var failures := 0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)
func _initialize() -> void: call_deferred("run")
func entry(art_id := "linda", pose := "block") -> Dictionary:
	return {"fighter_id":"linda", "art_id":art_id, "pose":pose, "path":"assets/dossier_curien/motion_2026-11-19/"+art_id+"_"+pose+".png", "dimensions":[1254,1254], "pivot_px":[620,1160], "standing_height_px":1000, "emitter_px":[910,249], "anchors_px":{"hand":[800,400]}}

func manifest_validation() -> void:
	var library := Motion.new()
	var valid := entry()
	check(library.load_data({"schema_version":1,"assets":[valid]},false), "Native pose accepts pixel pivots")
	check(library.has_pose("linda","block") and library.get_entry("linda_block").path.begins_with("res://"), "Pose identity and path normalize")
	var duplicate := valid.duplicate(true)
	duplicate.pivot_px = [1,1]
	check(library.load_data({"schema_version":1,"assets":[valid,duplicate]},false) and library.entries.size()==1, "Duplicate cannot replace first accepted drawing")
	check(library.get_entry("linda_block").pivot_px == [620,1160], "Duplicate leaves accepted calibration intact")
	for path in ["assets/dossier_curien/motion_2026-11-19/../escape.png","assets/dossier_curien/motion_2026-11-19//pose.png","assets/dossier_curien/motion_2026-11-19/./pose.png","assets/dossier_curien/motion_2026-11-19/a\\b.png","user://pose.png","assets/elsewhere/pose.png"]:
		var invalid := valid.duplicate(true)
		invalid.path = path
		check(not library.load_data({"schema_version":1,"assets":[invalid]},false) and library.entries.is_empty(), "Unsafe path leaves no active pose: "+path)
	for field in [{"dimensions":[0,1254]},{"dimensions":[1254.5,1254]},{"pivot_px":[1500,10]},{"standing_height_px":0},{"standing_height_px":"1000"},{"fighter_id":"../linda"},{"pose":"unknown"}]:
		var invalid := valid.duplicate(true)
		invalid.merge(field,true)
		check(not library.load_data({"schema_version":1,"assets":[invalid]},false), "Malformed pose ignored: "+str(field))
	var optional := valid.duplicate(true)
	optional.emitter_px = [-1,0]
	optional.anchors_px = {"bad":[9999,0],"good":[200,300]}
	check(library.load_data({"schema_version":1,"assets":[optional]},false), "Invalid optional anchor keeps usable body art")
	var clean: Dictionary = library.get_entry("linda_block")
	check(not clean.has("emitter_px") and clean.anchors_px.keys()==["good"], "Only bounded optional anchors exposed")
	check(not library.load_data(null) and library.entries.is_empty(), "Malformed manifest clears preceding library")
	check(not library.load_manifest("res://data/assets/not_present_motion.json"), "Missing manifest falls back safely")
	check(library.load_data({"schema_version":1,"assets":[valid]},false), "Historical fixture reloads")
	var addition := entry("rikiya","crouch")
	addition.fighter_id = "rikiya"
	addition.path = "assets/dossier_curien/motion_2026-11-20_lot6/rikiya_crouch.png"
	check(library.append_data({"schema_version":1,"assets":[addition]},false) and library.entries.size()==2, "Dated collection adds a distinct action without clearing history")
	check(not library.append_data(null,false) and library.entries.size()==2, "Malformed addition preserves preceding poses")
	var collision := valid.duplicate(true)
	collision.path = "assets/dossier_curien/motion_2026-11-20_lot6/linda_block.png"
	collision.pivot_px = [5,5]
	check(not library.append_data({"schema_version":1,"assets":[collision]},false), "Duplicate from a later collection cannot replace historical identity")
	check(library.get_entry("linda_block").pivot_px == [620,1160], "Historical native calibration survives collection collision")
	for path in ["res://assets/dossier_curien/motion_2026-11-20_lot6/../escape.png","res://assets/dossier_curien/motion_2026-11-20_lot6_extra/pose.png"]:
		check(not Motion.safe_path(path), "New collection cannot extend its path boundary: "+path)

func cosmetic_timing() -> void:
	var f := Fighter.new(23,400,1)
	f.step(0,false,"taunt",700)
	check(f.taunt_ticks==60 and f.action=="" and f.ammo==8 and f.buffer_ticks==0, "Neutral taunt has no damage state, ammo cost or input buffer")
	for tick in 59: f.step(0,false,"",700)
	check(f.taunt_ticks==1, "Taunt remains through final display tick")
	f.step(0,false,"",700)
	check(f.taunt_ticks==0, "Taunt expires at sixty idle simulation ticks")
	f.step(1,false,"taunt",700)
	check(f.taunt_ticks==0 and f.x>400, "Simultaneous movement prevents taunt immediately")
	f.step(0,false,"taunt",700)
	check(f.taunt_ticks==60, "Releasing movement permits taunt immediately")
	f.step(0,true,"taunt",700)
	check(f.crouching and f.taunt_ticks==0, "Crouch cancels taunt and cannot restart it")
	f.step(0,false,"taunt",700)
	f.step(0,false,"jump",700)
	check(f.altitude>0 and f.taunt_ticks==0, "Jump cancels taunt without action delay")
	f = Fighter.new(23,400,1)
	f.begin("taunt")
	f.step(0,false,"special",700)
	check(f.taunt_ticks==0 and f.action=="special" and f.tick==1 and f.ammo==7, "Attack cancels taunt with normal startup and ammunition")
	check(not f.begin("taunt") and f.action=="special", "Taunt cannot interrupt committed attack")
	check(not f.begin("unrecognized"), "Unknown input cannot enter undefined action")
	var attacker := Fighter.new(0,480,-1)
	var target := Fighter.new(23,400,1)
	target.begin("taunt")
	attacker.begin("light")
	attacker.tick = attacker.move_data().start
	check(attacker.hit(target) and target.taunt_ticks==0 and target.health==93, "Real hit cancels taunt and deals normal damage")
	target = Fighter.new(23,400,1)
	target.guarding = true
	attacker.connected = false
	check(not attacker.hit(target) and target.block_ticks==8 and target.health==100, "Guard impact triggers block pose without damage")
	target.guarding = false
	check(not target.begin("taunt"), "Guard impact must finish before neutral taunt")
	for tick in 8: target.step(0,false,"",700)
	check(target.block_ticks==0, "Block reaction expires independently")

func pose_selection_and_scale() -> void:
	var painter := Painter.new()
	var assets: Array = []
	for pose in ["guard","jump_rise","jump_fall","crouch","crouch_guard","block","throw","victory","taunt","finish","reload"]: assets.append(entry("linda",pose))
	assets.append(entry("kate_soiree","block"))
	assets.append(entry("rogan","crouch"))
	assets.append(entry("zobio","guard"))
	check(painter.motion.load_data({"schema_version":1,"assets":assets},false), "Authored set loads for pose selection")
	var f := Fighter.new(23,400,1)
	f.vy = 13.2
	check(painter.pose_suffix(f)=="_jump_rise", "Takeoff resolves rising art before altitude update")
	f.altitude = 50
	f.vy = -1
	check(painter.pose_suffix(f)=="_jump_fall", "Descent follows vertical velocity")
	f.altitude = 0
	f.vy = 0
	f.crouching = true
	check(painter.pose_suffix(f)=="_crouch", "Ground crouch resolves its own drawing")
	f.guarding = true
	check(painter.pose_suffix(f)=="_crouch_guard", "Low guard uses dedicated low silhouette")
	f.crouching = false
	f.guarding = false
	f.block_ticks = 8
	check(painter.pose_suffix(f)=="_block", "Standing impact resolves block art")
	f.block_ticks = 0
	f.taunt_ticks = 60
	check(painter.pose_suffix(f)=="_taunt", "Neutral taunt resolves dedicated drawing")
	f.action = "reload"
	check(painter.pose_suffix(f)=="_reload", "Reload beats stale cosmetic timer")
	f.action = "throw"
	check(painter.pose_suffix(f)=="_throw", "Firearm fighter uses dedicated throw")
	f.stun = 10
	check(painter.pose_suffix(f)=="_recoil", "Damage reaction takes priority")
	var arena := {"winner":0,"phase":"finish","resume_phase":""}
	check(painter.pose_suffix(f,"linda",arena,0)=="_victory", "Winner celebrates during finisher opportunity")
	arena.phase = "cinematic"
	check(painter.pose_suffix(f,"linda",arena,0)=="_finish", "Finisher resolves dedicated winner art")
	arena.phase = "pause"
	arena.resume_phase = "finish"
	check(painter.pose_suffix(f,"linda",arena,0)=="_victory", "Pause preserves underlying celebration")
	check(painter.pose_suffix(f,"linda",arena,1)=="_recoil", "Loser does not inherit celebration")
	var kate := Fighter.new(6,400,1)
	kate.block_ticks = 8
	check(painter.pose_suffix(kate,"kate_soiree")=="_block" and painter.pose_suffix(kate,"kate")!="_block", "Costume pose never leaks to another outfit")
	var zobio := Fighter.new(9,400,1)
	zobio.crouching = true
	check(is_equal_approx(painter.pose_height(zobio,"zobio","_guard"),213.0), "Authored standing guard still lowers for crouch fallback")
	var rogan := Fighter.new(0,400,1)
	rogan.crouching = true
	rogan.guarding = true
	check(painter.pose_suffix(rogan)=="_crouch", "Low guard reuses painted crouch before standing fallback")
	check(is_equal_approx(painter.pose_height(rogan,"rogan","_crouch"),278.0), "Painted crouch retains anatomical scale")
	check(Painter.action_effects_active({"phase":"fight","resume_phase":""}), "Live attack retains effects")
	check(Painter.action_effects_active({"phase":"pause","resume_phase":"fight"}), "Pause preserves active fight effects")
	for phase in ["finish","cinematic","round","result"]:
		check(not Painter.action_effects_active({"phase":phase,"resume_phase":""}), "Final shot never leaks into "+phase)
	check(not Painter.action_effects_active({"phase":"pause","resume_phase":"finish"}), "Pause during finisher opportunity does not restore old shot")
	var cinematic_arena := {"winner":0,"stage":0}
	painter.rendered_pose_emitters[0] = {"pose":"_finish","position":Vector2(480.25,407.5)}
	check(painter.finisher_origin(cinematic_arena,f).is_equal_approx(Vector2(480.25,407.5)), "Finisher uses exact rendered barrel position")
	painter.rendered_pose_emitters[0].pose = "_contact"
	check(not painter.finisher_origin(cinematic_arena,f).is_equal_approx(Vector2(480.25,407.5)), "Finisher rejects old ordinary contact emitter")
	var pose := entry()
	var size := Motion.canvas_size(pose,261.0)
	var pivot := Vector2(620,1160)/Vector2(1254,1254)
	var right := Transform2D(0.0,Vector2(400,601))
	var left := right
	left.x *= -1
	check(Painter.painted_point(Vector2(620,1160),Vector2(1254,1254),size,pivot,right).is_equal_approx(Vector2(400,601)), "Native foot pivot stays on floor")
	var muzzle_right := Painter.painted_point(Vector2(910,249),Vector2(1254,1254),size,pivot,right)
	var muzzle_left := Painter.painted_point(Vector2(910,249),Vector2(1254,1254),size,pivot,left)
	check(is_equal_approx(muzzle_right.x-400,400-muzzle_left.x) and is_equal_approx(muzzle_right.y,muzzle_left.y), "Facing mirrors barrel around body without changing height")
	check(is_equal_approx(size.y/1254.0,261.0/1000.0), "Low and aerial art use standing anatomical reference")

func rikiya_runtime_poses() -> void:
	var painter := Painter.new()
	painter.load_textures()
	var historical = JSON.parse_string(FileAccess.get_file_as_string(Motion.MANIFEST))
	var additions = JSON.parse_string(FileAccess.get_file_as_string(Motion.MANIFESTS[1]))
	check(painter.motion.entries.size()==historical.assets.size()+additions.assets.size(), "Default renderer loads all dated motion collections")
	for item in historical.assets:
		var key: String = str(item.get("art_id",item.fighter_id))+"_"+str(item.pose)
		var actual: Dictionary = painter.motion.get_entry(key)
		check(actual.get("path","")=="res://"+str(item.path) and actual.get("pivot_px")==item.pivot_px and actual.get("standing_height_px")==item.standing_height_px, "Historical drawing and native calibration retained: "+key)
	var rikiya := Fighter.new(16,400,1)
	for item in additions.assets:
		var texture := painter.saga_texture(item.id)
		check(texture != null and texture.get_size()==Vector2(item.dimensions[0],item.dimensions[1]), "Renderer consumes native texture: "+str(item.id))
		var native_size := Vector2(item.dimensions[0],item.dimensions[1])
		var pivot := Vector2(item.pivot_px[0],item.pivot_px[1])
		var size := Motion.canvas_size(item,float(rikiya.profile.height))
		for facing in [-1,1]:
			var transform := Transform2D(0.0,Vector2(400,601))
			transform.x *= facing
			check(Painter.painted_point(pivot,native_size,size,pivot/native_size,transform).is_equal_approx(Vector2(400,601)), "Native pivot pins both facings: "+str(item.id)+" "+str(facing))
		check(not painter.motion.has_pose("rikiya_zr_alt_suit",str(item.pose)), "Base motion does not leak into gallery-only costume: "+str(item.pose))
	rikiya.step(0,true,"",700)
	check(painter.pose_suffix(rikiya)=="_crouch", "Real down input selects new crouch")
	check(is_equal_approx(painter.pose_height(rikiya,"rikiya","_crouch"),284.0), "Authored crouch avoids secondary 71-percent body shrink")
	rikiya.step(-1,true,"",700)
	check(painter.pose_suffix(rikiya)=="_crouch_guard" and not rikiya.moving, "Real down-back input selects new low guard")
	check(is_equal_approx(painter.pose_height(rikiya,"rikiya","_crouch_guard"),284.0), "Low guard keeps its calibrated anatomical scale")
	rikiya.step(0,false,"",700)
	check(painter.pose_suffix(rikiya)=="", "Releasing low guard returns to neutral artwork")
	rikiya.step(0,false,"jump",700)
	check(painter.pose_suffix(rikiya)=="_jump_rise", "Real jump command selects rise before apex")
	var saw_descent := false
	for tick in 60:
		rikiya.step(0,false,"",700)
		if rikiya.altitude > 0 and rikiya.vy <= 0:
			saw_descent = true
			check(painter.pose_suffix(rikiya)=="_jump_fall", "Real negative jump velocity selects descent")
		if rikiya.altitude == 0: break
	check(saw_descent and rikiya.altitude==0 and painter.pose_suffix(rikiya)=="", "Jump completes rise, fall and neutral landing")
	rikiya = Fighter.new(16,400,1)
	rikiya.step(-1,false,"",470)
	var attacker := Fighter.new(0,470,-1)
	attacker.begin("light")
	attacker.tick = int(attacker.move_data().start)
	check(not attacker.hit(rikiya) and rikiya.block_ticks>0 and rikiya.health==100, "Real blocked hit retains original damage rules")
	check(painter.pose_suffix(rikiya)=="_block", "Real standing guard impact selects new block over moving guard")
	for tick in 8: rikiya.step(0,false,"",470)
	check(painter.pose_suffix(rikiya)=="", "Block timer expires to neutral pose")
	rikiya.step(0,false,"throw",470)
	check(rikiya.action=="throw" and painter.pose_suffix(rikiya)=="_throw", "Real throw command selects dedicated grasp art")
	var throw_end := int(rikiya.move_data().end)
	for tick in throw_end:
		rikiya.step(0,false,"",470)
		if rikiya.action=="throw": check(painter.pose_suffix(rikiya)=="_throw", "Throw retains dedicated drawing during its existing timing")
	check(rikiya.action=="" and painter.pose_suffix(rikiya)=="", "Throw recovery returns to existing neutral artwork")
	rikiya.stun = 4
	check(painter.pose_suffix(rikiya)=="_recoil", "Existing hit reaction still overrides new neutral action poses")

func press(arena, keycode: int) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	arena._input(event)

func rikiya_match_end_states() -> void:
	var arena := Arena.new()
	root.add_child(arena)
	arena.set_physics_process(false)
	arena.mode = 2
	arena.stage = 0
	arena.case_id = ""
	arena.edition_id = ""
	arena.phase = "fight"
	arena.clock_ticks = 3600
	arena.wins = [0,0]
	arena.fighters = [Fighter.new(16,400,1),Fighter.new(16,470,-1)]
	arena.panel.hide()
	press(arena,KEY_O)
	arena._physics_process(1.0/60.0)
	var winner = arena.fighters[0]
	check(winner.taunt_ticks==60 and arena.visuals.pose_suffix(winner)=="_taunt", "Rikiya O key selects the new cosmetic taunt through arena input")
	check(winner.action=="" and winner.health==100 and arena.fighters[1].health==100, "Taunt art adds no attack, damage or new action")
	for tick in 60: arena._physics_process(1.0/60.0)
	check(winner.taunt_ticks==0 and arena.visuals.pose_suffix(winner)=="", "Rikiya taunt expires to existing guard after sixty ticks")
	press(arena,KEY_O)
	arena._physics_process(1.0/60.0)
	press(arena,KEY_J)
	arena._physics_process(1.0/60.0)
	check(winner.taunt_ticks==0 and winner.action=="light" and arena.visuals.pose_suffix(winner)!="_taunt", "Real attack input cancels Rikiya's taunt without delay")
	# A real light hit produces the round/match transitions; no fake winner
	# dictionary substitutes for the arena's KO and finisher input handling.
	arena.fighters = [Fighter.new(16,400,1),Fighter.new(16,470,-1)]
	arena.fighters[1].health = 1
	press(arena,KEY_J)
	for tick in 20:
		arena._physics_process(1.0/60.0)
		if arena.phase != "fight": break
	winner = arena.fighters[0]
	check(arena.phase=="round" and arena.winner==0 and arena.wins[0]==1 and arena.fighters[1].health==0, "Actual Rikiya hit wins an ordinary round")
	check(arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_victory", "Ordinary round winner displays dedicated victory over frozen attack")
	check(arena.visuals.pose_suffix(arena.fighters[1],"rikiya",arena,1)!="_victory", "Same-character defeated fighter cannot inherit winner art")
	arena.phase = "fight"
	arena.clock_ticks = 3600
	arena.action_queue = ["",""]
	arena.fighters = [Fighter.new(16,400,1),Fighter.new(16,470,-1)]
	arena.fighters[1].health = 1
	arena.panel.hide()
	press(arena,KEY_J)
	for tick in 20:
		arena._physics_process(1.0/60.0)
		if arena.phase != "fight": break
	winner = arena.fighters[0]
	check(arena.phase=="finish" and arena.wins[0]==2 and arena.finish_ticks==150, "Second real KO opens the existing finisher opportunity")
	check(arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_victory", "Victory remains visible during the finisher opportunity")
	press(arena,KEY_ESCAPE)
	check(arena.phase=="pause" and arena.resume_phase=="finish" and arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_victory", "Pausing the actual finisher opportunity preserves winner celebration")
	press(arena,KEY_ESCAPE)
	press(arena,KEY_Y)
	check(arena.phase=="finish", "Defeated side's finisher key cannot trigger Rikiya's finish")
	press(arena,KEY_I)
	check(arena.phase=="cinematic" and arena.finish_ticks==72, "Winner's actual I key starts the existing finisher cinematic")
	check(arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_finish", "Finisher cinematic consumes the new open-palm contact drawing")
	check(arena.visuals.pose_suffix(arena.fighters[1],"rikiya",arena,1)!="_finish", "Defeated same-character fighter does not inherit finisher art")
	check(not Painter.action_effects_active(arena), "Frozen winning attack cannot leak ordinary combat effects into finisher")
	var finisher: Dictionary = arena.visuals.motion.get_entry("rikiya_finish")
	check(not finisher.has("emitter_px") and finisher.anchors_px.has("striking_palm"), "Target-centered palm cinematic retains a review anchor without unused projectile emitter")
	for tick in 71: arena._physics_process(1.0/60.0)
	check(arena.phase=="cinematic" and arena.finish_ticks==1 and arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_finish", "Finisher pose lasts through the final cinematic tick")
	arena._physics_process(1.0/60.0)
	check(arena.phase=="result" and arena.visuals.pose_suffix(winner,"rikiya",arena,0)=="_victory", "Completed finisher transitions back to victory on results")
	check(not Painter.action_effects_active(arena), "Result celebration does not restore stale combat effects")
	arena.audio_player.stop()
	arena.queue_free()
	# Match sheets defer their old controls' deletion; let the real scene tree
	# complete that cleanup before closing this headless integration test.
	await process_frame

func run() -> void:
	manifest_validation()
	cosmetic_timing()
	pose_selection_and_scale()
	rikiya_runtime_poses()
	await rikiya_match_end_states()
	print("SAGA MOTION: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
