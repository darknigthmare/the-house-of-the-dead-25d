extends SceneTree
const Fighter := preload("res://src/dossier_curien/combatant.gd")
const Painter := preload("res://src/dossier_curien/presentation.gd")
const Motion := preload("res://src/dossier_curien/saga_motion.gd")
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

func run() -> void:
	manifest_validation()
	cosmetic_timing()
	pose_selection_and_scale()
	print("SAGA MOTION: %d checks, %d failures" % [checks,failures])
	quit(0 if failures==0 else 1)
