extends RefCounted

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const ART := "res://assets/dossier_curien/"
const EXPANSION_ART := {"linda_guard":"res://assets/dossier_curien/expansion/zombie_revenge_characters/linda_rotta_base.png"}
const Saga := preload("res://src/dossier_curien/saga.gd")
const Stage := preload("res://src/dossier_curien/saga_stage.gd")
const ATLAS_IDS := ["thomas_rogan", "agent_g", "chariot", "magician"]
const BG := ["mansion-exterior", "mansion-hall", "curien-laboratory"]
const PROPS := [["dead_tree","garden_lamp"], ["mansion_double_door","mansion_sconce"], ["lab_specimen_tank","lab_pipe_cluster"]]
# Offsets are measured from the grounded foot pivot on the registered contact art.
const CONTACT_PIVOTS := {
	"double":Vector2(148,234), "spread":Vector2(127,205), "burst":Vector2(167,210),
	"advance":Vector2(211,205), "stagger":Vector2(118,242), "rise":Vector2(90,258),
	"choke":Vector2(242,204), "retreat":Vector2(126,232),
	"frost":Vector2(195,28), "canopy":Vector2(193,41)
}
# Contact art is 1024 px high, with feet at y=960 and 905 px per standing body.
const GALA_MUZZLES := {"kate_soiree":Vector2(320,734), "ryan_soiree":Vector2(392,738)}
# Horizontal coordinates use a normalized 1024-unit texture width. Vertical coordinates follow the 1024-pixel source height.
const CORE_PIXELS := {
	17: {"_guard":Vector2(559,297), "_windup":Vector2(544,387), "_contact":Vector2(564,426), "_recoil":Vector2(339,300)},
	18: {"_guard":Vector2(539,444), "_windup":Vector2(510,477), "_contact":Vector2(587,476), "_recoil":Vector2(457,429)},
	21: {"_guard":Vector2(576,473), "_windup":Vector2(472,443), "_contact":Vector2(545,550), "_recoil":Vector2(657,408)},
	22: {"_guard":Vector2(737,302), "_windup":Vector2(748,379), "_contact":Vector2(838,453), "_recoil":Vector2(481,215)}
}
const BONE := Color("f4ead4")
const GOLD := Color("e2b36b")
const DARK := Color("0e161b")
const STEEL := Color("89b5b5")
var textures := {}
var walk_cycles := {}
var recent_textures: Array[String] = []
var origin_transform := Transform2D.IDENTITY
var scan_position := Vector2.ZERO
var prop_profiles: Dictionary
var visible_rects := {}
var contact_emitters := {}
var pose_emitters := {}
var pose_profiles: Dictionary = {}
var saga_props: Array = []

static func floor_y(stage: int) -> float:
	# The Venetian playable strip runs in front of the canal balustrade.
	return 651.0 if stage == 3 else 601.0

func load_textures() -> void:
	pose_emitters.clear()
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/assets/environment_manifest.json"))
	prop_profiles = manifest.props
	var additions: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/assets/dossier_curien_additions.json"))
	for entry in additions.get("assets", []):
		if not entry.has("bounds_px"): continue
		var box: Array = entry.bounds_px
		visible_rects["res://" + str(entry.path)] = Rect2(box[0], box[1], box[2], box[3])
		if entry.has("emitter_px"):
			var point: Array = entry.emitter_px
			var dims: Array = entry.dimensions
			contact_emitters[str(entry.fighter_id)] = Vector2((point[0] - dims[0]*0.5)*1024.0/dims[1], 960.0 - point[1]*1024.0/dims[1])
	pose_profiles = additions.get("poses", {})
	saga_props = additions.get("stage_props", [])
	var expansion_path := "res://data/assets/dossier_curien_expansion.json"
	if FileAccess.file_exists(expansion_path):
		var expansion = JSON.parse_string(FileAccess.get_file_as_string(expansion_path))
		if expansion is Dictionary and expansion.get("assets", []) is Array:
			for entry in expansion.get("assets", []):
				if not entry is Dictionary: continue
				var asset_path := str(entry.get("path", "")).trim_prefix("res://")
				if not asset_path.begins_with("assets/dossier_curien/expansion/zombie_revenge_characters/"): continue
				var stem: String = asset_path.get_file().get_basename()
				if stem != "linda_rotta_base" and not stem.begins_with("linda_"): continue
				var pose_key := "linda_guard" if stem == "linda_rotta_base" else stem
				var bounds = entry.get("visible_bbox", entry.get("alpha_bbox", []))
				var dims = entry.get("dimensions", [])
				if not finite_numbers(bounds,4) or not finite_numbers(dims,2): continue
				if dims[0] <= 0 or dims[1] <= 0 or bounds[0] < 0 or bounds[1] < 0 or bounds[2] > dims[0] or bounds[3] > dims[1]: continue
				if bounds[2] <= bounds[0] or bounds[3] <= bounds[1]: continue
				pose_profiles[pose_key] = {
					"pivot":[(bounds[0]+bounds[2])*0.5/dims[0],bounds[3]/float(dims[1])],
					"source_size":dims,
					"body_fraction":maxf(0.01,(bounds[3]-bounds[1])/float(dims[1]))}
				var emitter = entry.get("emitter_px", [])
				if finite_numbers(emitter,2) and emitter[0] >= 0 and emitter[1] >= 0 and emitter[0] <= dims[0] and emitter[1] <= dims[1]:
					pose_emitters[pose_key] = Vector2(float(emitter[0]), float(emitter[1]))

static func finite_numbers(value: Variant, count: int) -> bool:
	if not value is Array or value.size() != count: return false
	for number in value:
		if typeof(number) not in [TYPE_INT,TYPE_FLOAT] or not is_finite(float(number)): return false
	return true

# Use the same native pixels, rectangle and transform as the painted body.
# The returned point is in arena coordinates; origin_transform is applied once
# by the canvas when draw_special renders the flash and its trace.
static func painted_point(point_px: Vector2, source_size: Vector2, drawn_size: Vector2, source_pivot: Vector2, transform: Transform2D) -> Vector2:
	return transform * ((point_px / source_size - source_pivot) * drawn_size)

func linda_low_canvas_size(source_size: Vector2, standing_height: float) -> Vector2:
	# These low poses are painted at the standing master's anatomical pixel scale.
	# Keep that scale: their shorter silhouette comes from bent joints, not from
	# shrinking the head, hands and torso to 71 percent of their standing size.
	var reference: Dictionary = pose_profiles.get("linda_guard", {})
	var dimensions: Array = reference.get("source_size", [1024,1536])
	var visible_height: float = float(reference.get("body_fraction",905.0/1024.0)) * float(dimensions[1])
	return source_size * standing_height / maxf(1.0,visible_height)

func cached(path: String) -> Texture2D:
	if textures.has(path):
		if textures[path] != null and recent_textures.back() != path:
			recent_textures.erase(path)
			recent_textures.append(path)
		return textures[path]
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if texture:
		# Keep stage layers, props and the two fighters' short pose cycles in memory.
		# Release older textures so touring all the dossiers fits browser memory.
		if recent_textures.size() >= 16: textures.erase(recent_textures.pop_front())
		recent_textures.append(path)
	textures[path] = texture
	return texture

func classic_art(key: String) -> Texture2D:
	return cached(ART + key + ".png")

func saga_texture(key: String) -> Texture2D:
	var ordinary := cached(ART + "saga/" + key + ".png")
	if ordinary: return ordinary
	if EXPANSION_ART.has(key): return cached(EXPANSION_ART[key])
	if key.begins_with("linda_"): return cached(ART + "expansion/zombie_revenge_characters/" + key + ".png")
	return null

func guard_art(fighter_id: int) -> Texture2D:
	var key: String = Fighter.PROFILES[fighter_id].id + "_guard"
	return classic_art(key) if fighter_id < 4 else saga_texture(key)

func has_walk_cycle(fighter_id: int, sheet_id: String) -> bool:
	var prefix := ART + ("saga/" if fighter_id >= 4 else "") + sheet_id
	if sheet_id == "linda": prefix = ART + "expansion/zombie_revenge_characters/linda"
	if not walk_cycles.has(prefix):
		walk_cycles[prefix] = ResourceLoader.exists(prefix + "_walk1.png") and ResourceLoader.exists(prefix + "_walk2.png")
	return walk_cycles[prefix]

func stage_plane(stage: int, plane: String) -> Texture2D:
	if stage < BG.size() or stage >= Saga.ART.size(): return null
	return saga_texture(Saga.ART[stage] + "_" + plane)

func atlas(fighter_id: int) -> Texture2D:
	var id: String = ATLAS_IDS[fighter_id]
	var group := "heroes" if fighter_id < 2 else "bosses"
	return cached("res://assets/sprites_v2/%s/%s/%s__v2__action_cycle__8dirx8f.png" % [group,id,id])

func heading(c, pos: Vector2, line: String, px: int, color: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	c.draw_string(ThemeDB.fallback_font,pos,line,align,width,px,color)

func draw(c) -> void:
	var drift := 0.0
	if c.fighters.size() == 2:
		drift = ((c.fighters[0].x + c.fighters[1].x) * 0.5 - 640.0) / 565.0
	var classic: bool = c.stage < BG.size()
	var backdrop: Texture2D = classic_art("court_back") if c.stage == 0 else null
	var court: bool = backdrop != null
	if not court:
		backdrop = cached("res://assets/environments/%s.png" % BG[c.stage]) if classic else saga_texture(Saga.ART[c.stage] + "_back")
	if backdrop: c.draw_texture_rect(backdrop,Rect2(-38 - drift*17,-14,1356,754),false)
	if court:
		layer(c, classic_art("court_mid"), drift * 32)
	elif not classic:
		var middle := stage_plane(c.stage, "mid")
		if middle: layer(c, middle, drift * 32)
		elif c.stage < 11: Stage.mid(c, c.stage, drift)
		if c.stage == 3:
			saga_prop_at(c, "venice_lamp", 100 - drift*32, 644, 300)
			saga_prop_at(c, "venice_railing", 1150 - drift*32, 644, 88)
	else:
		prop_at(c, PROPS[c.stage][0], 180 - drift*33, 580, 270)
	stage_props(c, drift)
	c.draw_rect(Rect2(0, 0, 1280, 720), Color(0.025, 0.035, 0.05, 0.19))
	if c.fighters.size() == 2:
		for i in 2:
			var f = c.fighters[i]
			var color := Color(0.02, 0.025, 0.032, 0.42)
			var shadow := PackedVector2Array()
			for n in 24:
				shadow.append(Vector2(f.x, floor_y(c.stage) + 1) + Vector2.from_angle(TAU*n/24) * Vector2(64,9))
			c.draw_colored_polygon(shadow, color)
			draw_fighter(c, f, i)
	if c.phase == "fight" and c.has_boss_scan() and c.scan_enabled:
		draw_scan(c)
	if c.phase == "fight" and c.flash > 0:
		var distance: float = (7.0-c.flash)*4.0
		var impact := Vector2(c.impact_position.x,floor_y(c.stage)-c.impact_position.y)
		var ink := Color("a0cfda") if c.impact_guard else Color("f3cf86")
		ink.a = c.flash/6.0
		for n in (5 if c.impact_guard else 8):
			var direction := Vector2.from_angle(n*TAU/(5 if c.impact_guard else 8))
			c.draw_line(impact+direction*(5+distance*0.5),impact+direction*(12+distance),ink,2,true)
	if court:
		layer(c, classic_art("court_front"), drift * 58)
	elif not classic:
		var foreground := stage_plane(c.stage, "front")
		if foreground: layer(c, foreground, drift * 58)
		elif c.stage < 11 and c.stage != 3: Stage.front(c, c.stage, drift)
		if c.stage == 3:
			saga_prop_at(c, "venice_bollard", -4 - drift*58, 686, 64)
			saga_prop_at(c, "venice_bollard", 1284 - drift*58, 686, 64)
	else:
		prop_at(c, PROPS[c.stage][1], 1225 - drift*66, 638, 216)
	if c.phase in ["fight","finish","cinematic","round","result","pause"] and c.fighters.size() == 2:
		if c.edition_id != "" and c.phase == "fight": c.archives.paint(c, floor_y(c.stage))
		hud(c)
		if c.phase == "cinematic": cinematic(c)
		if c.phase == "finish":
			banner(c,"FINIR LE DUEL",("I / RB" if c.winner == 0 else "Y / RB") + "  ·  " + str(c.fighters[c.winner].profile.finish))
	elif c.phase in ["select","brief"]:
		illustration(c)
	if c.phase == "result" and c.mode == 0 and c.winner == 0 and c.route == 2:
		illustration(c)
	if c.phase == "bestiary_detail": c.bestiary.draw(c)
	if c.panel != null and c.panel.visible:
		c.draw_rect(Rect2(0,0,1280,720),Color(0.015,0.022,0.035,0.19))

func layer(c, tex: Texture2D, offset: float) -> void:
	if tex: c.draw_texture_rect(tex,Rect2(-38-offset,-14,1356,754),false)

func stage_props(c, drift: float) -> void:
	# Sources remain separate PNGs. These decorations stay behind the fighters.
	for prop in saga_props:
		if int(prop.stage) != c.stage: continue
		var texture := cached(prop.path)
		if texture == null: continue
		var h := float(prop.canvas_height)
		var size := Vector2(h * texture.get_width() / texture.get_height(), h)
		var position := Vector2(prop.position[0] - drift * prop.parallax, prop.position[1])
		var pivot := Vector2(prop.pivot[0], prop.pivot[1])
		c.draw_texture_rect(texture, Rect2(position - size * pivot, size), false)

func prop_at(c, id: String, x: float, bottom: float, h: float) -> void:
	var tex := cached("res://assets/environments_v2/props/%s/%s.png" % [id,id])
	if tex == null: return
	var frames: int = prop_profiles[id].get("hframes",1)
	var cell := tex.get_size() / Vector2(frames,1)
	var w := h * cell.x / cell.y
	var index: int = int(c.elapsed / 12.0) % frames if prop_profiles[id].has("animate") else 0
	c.draw_texture_rect_region(tex,Rect2(x-w/2,bottom-h,w,h),Rect2(cell.x * index,0,cell.x,cell.y))

# Native masters retain their source pixels. Registered alpha bounds use a
# 16/255 threshold so nearly invisible generator speckles do not move the feet.
# Measurements are loaded once; drawing never reads back GPU texture data.
func visible_bounds(tex: Texture2D) -> Rect2:
	return visible_rects.get(tex.resource_path, Rect2(Vector2.ZERO, tex.get_size()))

func saga_prop_at(c, key: String, x: float, bottom: float, height: float) -> void:
	var tex := saga_texture("props/" + key)
	if tex == null: return
	var source := visible_bounds(tex)
	if not source.has_area(): return
	var width := height * source.size.x / source.size.y
	c.draw_texture_rect_region(tex, Rect2(x-width*0.5, bottom-height, width, height), source)

func illustration(c) -> void:
	var tex: Texture2D
	if c.phase == "select":
		var id: String = c.costumes.art_id(c,c.preview)
		tex = classic_art(id + "_select") if c.preview < 4 else saga_texture(id + "_select")
		if tex == null: tex = guard_art(c.preview)
	elif c.case_id != "" and c.case_id != "curien":
		var shot := "ending" if c.phase == "result" else ["intro","rival","final"][c.route] as String
		if c.chosen == Saga.CASES[c.case_id].lead:
			tex = saga_texture(c.case_id + "_" + shot)
		elif c.chosen >= 17:
			tex = saga_texture(str(Fighter.PROFILES[c.chosen].id) + "_" + shot)
	elif c.chosen == 0:
		if c.phase == "result": tex = classic_art("rogan_ending")
		elif c.route == 0: tex = classic_art("rogan_intro")
		elif c.route == 1: tex = classic_art("rogan_rival")
	if tex == null and c.case_id != "" and c.case_id != "curien" and c.phase != "select":
		var subject: int = c.enemy if c.route >= 1 and c.phase != "result" else c.chosen
		var silhouette: Texture2D = saga_texture(c.costumes.art_id(c,subject)+"_guard") if subject >= 4 else guard_art(subject)
		if silhouette:
			var dims := silhouette.get_size()
			dims *= minf(490.0/dims.x, 520.0/dims.y)
			c.draw_texture_rect(silhouette,Rect2(Vector2(930,365)-dims/2,dims),false)
		return
	if tex == null: return
	if c.phase == "select":
		var r := tex.get_size()
		var scale := minf(510.0/r.x, 507.0/r.y)
		var ext := r * scale
		c.draw_texture_rect(tex,Rect2(Vector2(940,376)-ext/2,ext),false)
	else:
		c.draw_texture_rect(tex,Rect2(0,0,1280,720),false)
		c.draw_rect(Rect2(0,0,1280,720), Color(0,0,0,0.12))

func pose_suffix(f, sheet_id: String = "") -> String:
	if f.stun > 0: return "_recoil"
	if sheet_id == "": sheet_id = f.profile.id
	if f.id == 23 and f.crouching and f.altitude == 0:
		if f.action == "": return "_crouch_guard" if f.guarding else "_crouch"
		if f.action == "special" and f.alternate_special: return "_slide_contact"
	if f.action == "" and f.moving and f.altitude == 0 and has_walk_cycle(f.id, sheet_id):
		var stride := floori((f.walk_ticks-1) / 6.0) % 4
		if f.guarding: stride = 3-stride
		return ["_walk1","_guard","_walk2","_guard"][stride]
	if f.action not in ["light","heavy","special","throw"]: return ""
	var data: Dictionary = f.move_data()
	var age: int = f.tick - int(data.start)
	if f.id == 17:
		if f.action != "special": return ""
		if not f.alternate_special and age < 2*f.pulse_gap(): return "_windup"
	# Gary's elbow has separate art. The painted firearm attacks belong to specials.
	if f.action != "special" and f.profile.ammo > 0:
		return "_melee" if f.id == 19 and f.action == "light" and age >= 0 and age <= 2 else ""
	if age < 0: return "_windup"
	if f.action == "special":
		if f.profile.kind in ["canopy","frost"] and not f.alternate_special:
			return "_contact" if age < (18 if f.profile.kind == "canopy" else 24) else "_recovery"
		if f.profile.kind == "rotor" and age < 48: return "_contact"
		if age < f.special_hits()*f.pulse_gap() and age%f.pulse_gap() <= 2: return "_contact"
	return "_contact" if age <= 2 else "_recovery"

func draw_fighter(c, f, side: int) -> void:
	var sheet_id: String = c.costumes.art_id(c,f.id)
	var art: Texture2D = saga_texture(sheet_id+"_guard") if f.id >= 4 else guard_art(f.id)
	var displayed_pose := "_guard"
	var idle: bool = f.action == "" and not f.moving and f.stun == 0 and f.altitude == 0
	var unarmed_fallback: bool = f.profile.ammo > 0 and f.action in ["light","heavy","throw"] and f.stun == 0
	var key := pose_suffix(f, sheet_id)
	if key != "":
		var pose := saga_texture(sheet_id + key) if f.id >= 4 else classic_art(sheet_id + key)
		if pose:
			art = pose
			idle = true
			displayed_pose = key
	var height: float = f.profile.height
	var bottom := floor_y(c.stage) - float(f.altitude)
	var painted_low: bool = f.id == 23 and displayed_pose in ["_crouch","_crouch_guard","_slide_contact"]
	if f.crouching and not painted_low: height *= 0.71
	var collapse: float = 0.0
	if c.phase == "cinematic" and side != c.winner:
		collapse = 1.0 - float(c.finish_ticks) / 72
		height *= 1.0 - collapse * 0.78
	var tint := Color.WHITE
	if f.frost_ticks > 0: tint = Color("abd9ee")
	if f.stun > 0 and f.stun % 5 < 2: tint = Color(1.0,0.65,0.55)
	var effect_scale := height / 905.0
	var has_painted_emitter := false
	var painted_emitter := Vector2.ZERO
	if art and (idle or f.id >= 4 or unarmed_fallback):
		var breathing := sin(float(c.elapsed + side * 24)*0.062)*1.5
		effect_scale = (height + breathing) / 905.0
		# Native outputs keep their source dimensions; per-pose pivots pin the
		# visible supporting foot to the ground without resampling the artwork.
		var metrics: Dictionary = pose_profiles.get(sheet_id + displayed_pose, {})
		var pivot_values: Array = metrics.get("pivot", [0.5, 960.0/1024.0])
		var source_pivot := Vector2(float(pivot_values[0]), float(pivot_values[1]))
		var h := (height + breathing) / float(metrics.get("body_fraction",905.0/1024.0))
		if painted_low: h = linda_low_canvas_size(art.get_size(),height+breathing).y
		# Kate's two outfits keep the earlier alpha-16 body calibration.
		if f.id == 6 and displayed_pose in ["_walk1", "_walk2"]:
			var bounds := visible_bounds(art)
			if bounds.has_area():
				h = (height + breathing) * art.get_height() / bounds.size.y
				source_pivot.y = bounds.end.y / art.get_height()
		var w := h * art.get_width() / art.get_height()
		var tilt := 0.0
		var shift := Vector2.ZERO
		if (f.id >= 4 or unarmed_fallback) and not idle:
			if f.stun > 0:
				tilt = -0.14 * minf(1.0, f.stun/7.0)
			elif f.action == "reload":
				tilt = -0.07
				shift.y = 8 * sin(PI*f.tick/float(f.profile.reload))
			elif f.action != "":
				var data: Dictionary = f.move_data()
				var lead := float(f.tick)/float(data.start)
				var recover: float = (f.tick-float(data.start))/maxf(1.0,float(data.end-data.start))
				var extension := sin(PI*lead*0.5) if lead <= 1.0 else maxf(0,1-recover)
				tilt = 0.14 * extension - 0.06 * sin(PI*minf(1.0,lead))
				shift.x = 17 * extension
				if f.profile.kind == "rise" and f.action == "special": shift.y = -26 * extension
			elif f.moving:
				tilt = 0.045 * cos(c.elapsed*0.26)
				shift.y = -3.5 * absf(sin(c.elapsed*0.26))
			elif f.altitude > 0: tilt = -0.06
		var pivot := Transform2D(tilt * f.facing, Vector2(f.x + shift.x*f.facing, bottom+shift.y))
		pivot.x *= f.facing
		if displayed_pose in ["_contact","_slide_contact"] and pose_emitters.has(sheet_id + displayed_pose):
			painted_emitter = painted_point(pose_emitters[sheet_id + displayed_pose], art.get_size(), Vector2(w,h), source_pivot, pivot)
			has_painted_emitter = true
		if side == 1 and CORE_PIXELS.has(f.id):
			var marks: Dictionary = CORE_PIXELS[f.id]
			var core: Vector2 = marks.get(displayed_pose, marks["_guard"])
			scan_position = pivot * Vector2(w*(core.x-512)/1024.0, h*(core.y-960)/1024.0)
		c.draw_set_transform_matrix(origin_transform * pivot)
		if f.id == 17 and f.alternate_special and displayed_pose == "_contact":
			draw_mercury_blade(c,art,w,h,float(f.move_data().reach),tint)
		else:
			c.draw_texture_rect(art,Rect2(-w*source_pivot.x,-h*source_pivot.y,w,h),false,tint)
		c.draw_set_transform_matrix(origin_transform)
	elif f.id < ATLAS_IDS.size():
		var frame := 0
		if f.stun > 0: frame = 6
		elif f.action == "reload": frame = 4
		elif f.action != "":
			var start: int = f.move_data().start
			frame = 4 if f.tick < start else 5
		elif f.moving: frame = 1 + int(c.elapsed/7.0) % 3
		var tex := atlas(f.id)
		if tex == null: return
		var cell := tex.get_size() / 8
		var row := 6 if f.facing > 0 else 2
		var side_len := height * 256 / 228
		var dst := Rect2(f.x-side_len*0.5,bottom-side_len*242/256,side_len,side_len)
		c.draw_texture_rect_region(tex,dst,Rect2(Vector2(frame,row)*cell,cell),tint)
	if f.action == "special" and f.tick >= f.move_data().start:
		var age: int = f.tick-int(f.move_data().start)
		var visible_ticks := maxi(5, f.special_hits()*f.pulse_gap())
		if f.profile.kind == "rotor": visible_ticks = 48
		if f.profile.kind == "canopy" and not f.alternate_special: visible_ticks = 18
		if age < visible_ticks:
			var anchor: Vector2 = CONTACT_PIVOTS.get(f.profile.kind, Vector2(47,height*0.58))
			if contact_emitters.has(sheet_id):
				anchor = contact_emitters[sheet_id] * effect_scale
			elif GALA_MUZZLES.has(sheet_id):
				anchor = GALA_MUZZLES[sheet_id] * effect_scale
			var emission := painted_emitter if has_painted_emitter else Vector2(f.x+f.facing*anchor.x,bottom-anchor.y)
			draw_special(c, f, emission, age)
	elif f.id >= 4 and f.action in ["light","heavy","throw"]:
		var age: int = f.tick - int(f.move_data().start)
		if age >= 0 and age < 4:
			var fist := Vector2(f.x+f.facing*35,bottom-height*0.54)
			var tip := fist+Vector2(f.facing*float(f.move_data().reach)*0.68,-8 if f.action=="light" else 13)
			if f.id == 19 and f.action == "light":
				tip = Vector2(f.x+f.facing*108,bottom-214)
				fist = tip-Vector2(f.facing*22,5)
			c.draw_line(fist,tip,Color(f.profile.color,0.76),2 if f.action=="light" else 5,true)
			c.draw_arc(tip,9+age*3,-2.15,1.8,12,Color(f.profile.color,0.80),2,true)

func draw_mercury_blade(c, art: Texture2D, w: float, h: float, reach: float, tint: Color) -> void:
	# The liquid blade contracts without changing the body anchored to the floor.
	var join_fraction := 1450.0/2272.0
	var tip_fraction := 2243.0/2272.0
	var source := art.get_size()
	var split := source.x * join_fraction
	var y := -h*960/1024
	var joint := w*(join_fraction-0.5)
	var blade_width := (reach-joint)*(1.0-join_fraction)/(tip_fraction-join_fraction)
	c.draw_texture_rect_region(art,Rect2(-w*0.5,y,w*join_fraction,h),Rect2(0,0,split,source.y),tint)
	c.draw_texture_rect_region(art,Rect2(joint,y,blade_width,h),Rect2(split,0,source.x-split,source.y),tint)

func draw_special(c, f, origin: Vector2, age: int) -> void:
	var reach := float(f.move_data().reach)*0.86
	var end := origin + Vector2(f.facing*reach,0)
	var accent := Color(f.profile.color)
	match str(f.profile.kind):
		"shot","double","burst","advance","stagger","retreat","slide_shot":
			if age%5 > 2: return
			end.x = f.x+f.facing*float(f.move_data().reach)
			if f.profile.kind == "stagger": end.y -= 34
			c.draw_line(origin,end,accent,3 if f.profile.kind=="stagger" else 2,true)
			c.draw_circle(origin,8 if age%5 == 0 else 4,GOLD)
		"spread","choke":
			if age > 2: return
			end.x = f.x+f.facing*float(f.move_data().reach)
			for n in range(-2,3): c.draw_line(origin,end+Vector2(0,n*(5 if f.alternate_special else 15)),Color(accent,0.76),2,true)
		"satellite":
			if f.alternate_special:
				if age > 2: return
				var blade_tip := Vector2(f.x+f.facing*float(f.move_data().reach),floor_y(c.stage)-f.altitude-float(f.profile.height)*582/905)
				c.draw_arc(blade_tip,3+age*2,-1.6,1.6,8,accent,2,true)
			else:
				var spot := Vector2(f.x+f.facing*f.satellite_radius(),origin.y)
				c.draw_arc(spot,15,0,TAU,22,Color(accent,0.65),2,true)
				c.draw_circle(spot,11,accent)
				c.draw_circle(spot-Vector2(3,3),4,BONE)
		"rotor":
			var spot := Vector2(f.x+f.facing*f.wheel_radius(),origin.y)
			c.draw_arc(spot,34,0,TAU,32,Color(accent,0.70),4,true)
			for n in 8:
				var ray := Vector2.from_angle(age*0.21+n*TAU/8)
				c.draw_line(spot+ray*29,spot+ray*42,accent,3,true)
		"frost":
			if f.alternate_special:
				if age > 2: return
				var tip := Vector2(f.x + f.facing * float(f.move_data().reach), origin.y-71)
				c.draw_line(origin,tip,accent.darkened(0.2),5,true)
				var axe := PackedVector2Array([tip+Vector2(-f.facing*25,-30),tip+Vector2(f.facing*7,-5),tip+Vector2(0,22),tip+Vector2(-f.facing*13,7)])
				c.draw_colored_polygon(axe,accent)
			else:
				var front := Vector2(f.x+f.facing*f.surge_radius(),floor_y(c.stage)-f.altitude-190)
				if age%f.pulse_gap() < 3:
					var launch := Vector2(f.x+f.facing*70,front.y)
					var arc := PackedVector2Array([origin,origin+Vector2(-f.facing*26,-50),launch])
					c.draw_polyline(arc,Color(accent,0.62),3,true)
				for n in range(-1,2):
					var head := front+Vector2(-abs(n)*f.facing*10,n*11)
					var shard := PackedVector2Array([head+Vector2(f.facing*11,0),head+Vector2(-f.facing*19,4),head+Vector2(-f.facing*29,-3)])
					c.draw_colored_polygon(shard,accent)
		"canopy":
			if f.alternate_special:
				if age > 2: return
				var edge := Vector2(f.x+f.facing*float(f.move_data().reach),origin.y-46)
				var inside := Vector2(f.x+f.facing*150,origin.y-46)
				for n in 3:
					var motes := PackedVector2Array()
					for i in 16:
						var t := i/15.0
						var at := inside.lerp(edge,t)
						at.y += sin(t*TAU+n*TAU/3+age*0.6)*36*t
						motes.append(at)
					c.draw_polyline(motes,accent,2,true)
			else:
				var tip := Vector2(f.x+f.facing*f.surge_radius(),floor_y(c.stage)-f.altitude-42)
				var joint := origin.lerp(tip,0.58)+Vector2(0,18)
				c.draw_polyline(PackedVector2Array([origin,joint,tip]),Color("665945"),13,true)
				c.draw_polyline(PackedVector2Array([origin,joint,tip]),accent,3,true)
				for n in [-1,0,1]: c.draw_line(tip,tip+Vector2(f.facing*15,-8+n*9),accent,3,true)
		"orb":
			var travel := age/5.0
			c.draw_circle(origin.lerp(end, travel),17,accent)
			c.draw_circle(origin.lerp(end, travel),8,BONE)
		"thrust":
			c.draw_line(origin,end,accent.darkened(0.24),6,true)
			for offset in [-15,0,15]:
				c.draw_line(end-Vector2(f.facing*35,0),end+Vector2(0,offset),accent,3,true)
		"clasp","hug":
			for n in [-1,1]:
				c.draw_arc(end,32+age*2,n*1.3-0.7,n*1.3+0.7,12,accent,5,true)
			if f.profile.kind == "clasp":
				c.draw_arc(end,51,1.8,4.8,20,accent,3,true)
		"rise":
			c.draw_line(origin+Vector2(-f.facing*21,28),origin,accent,3,true)
			c.draw_arc(origin,7+age*1.5,-2.2,0.7,12,accent,2,true)
		"psychic":
			for n in 3: c.draw_arc(end,19+n*13+age*3,0,TAU,18,Color(accent,0.85-n*0.18),3,true)
		"hop":
			c.draw_arc(origin+Vector2(f.facing*52,12),59,-PI+0.4,-0.3,18,accent,4,true)
		"palm":
			for n in [0,1]: c.draw_arc(end,18+n*13+age*2,-1.45 if f.facing>0 else 1.7,1.45 if f.facing>0 else 4.6,15,accent,4,true)
		"crush":
			c.draw_line(origin-Vector2(0,65),end+Vector2(0,66),accent,6,true)
			c.draw_arc(end+Vector2(0,64),21+age*4,0,TAU,20,accent,4,true)
		_:
			c.draw_arc(origin,115,-1.75 if f.facing>0 else 1.4,1.75 if f.facing>0 else 4.9,24,accent,4,true)

func draw_scan(c) -> void:
	var state: String = c.scan_state()
	if state not in ["repérage","ouvert"]: return
	var point := scan_position
	var exposed := state == "ouvert"
	var radius: float = 20.0 if exposed else 39.0 - float((c.elapsed % 240)-90)*0.38
	var ink := Color("87e9d5") if exposed else GOLD
	for quadrant in 4:
		var angle := quadrant*PI/2
		c.draw_arc(point,radius,angle+0.08,angle+1.18,10,ink,3,true)
	if exposed: c.draw_circle(point,3,BONE)
	var label := "ŒIL EXPOSÉ" if c.enemy == 22 else ("CŒUR EXPOSÉ" if c.enemy == 21 else "NOYAU OUVERT")
	heading(c,Vector2(420,170),label + "  ·  LOURD / SPÉCIAL" if exposed else "ANALYSE AMS  ·  REPÉRAGE",18,ink,440,HORIZONTAL_ALIGNMENT_CENTER)

static func special_name(f) -> String:
	return str(f.profile.alt_name) if f.action == "special" and f.alternate_special and f.profile.has("alt_name") else str(f.profile.special)

func hud(c) -> void:
	c.draw_rect(Rect2(0,0,1280,111),Color("0e141cdd"))
	for i in 2:
		var f = c.fighters[i]
		var x := 48.0 if i == 0 else 763.0
		var align := HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		var player: String = "J1" if i == 0 else ("J2" if c.mode == 2 else "IA")
		heading(c,Vector2(x,39),player + "   /   " + str(f.profile.title).to_upper(),24,BONE,469,align)
		c.draw_rect(Rect2(x,50,469,16),Color("3c4648"))
		var w: float = 465.0 * f.health / 100
		c.draw_rect(Rect2(x+2 if i == 0 else x+467-w,52,w,12),GOLD if i==0 else STEEL)
		var move_name := special_name(f).to_upper()
		var status: String = ("%s   %d / %d" % [move_name,f.ammo,f.profile.ammo]) if int(f.profile.ammo) > 0 else move_name
		if f.combo > 1: status += "     %d COUPS" % f.combo
		if f.guarding: status += "     GARDE"
		heading(c,Vector2(x,91),status,17,BONE,469,align)
	heading(c,Vector2(520,52),"∞" if c.mode==4 else str(ceili(float(c.clock_ticks)/60)),42,BONE,240,HORIZONTAL_ALIGNMENT_CENTER)
	heading(c,Vector2(520,83),"%d    /    %d" % [c.wins[0],c.wins[1]],18,GOLD,240,HORIZONTAL_ALIGNMENT_CENTER)
	c.draw_rect(Rect2(0,664,1280,56),Color("10151cdd"))
	heading(c,Vector2(42,698),c.STAGES[c.stage].to_upper(),17,GOLD)
	heading(c,Vector2(440,698),"J LÉGER   ·   K LOURD   ·   L SPÉCIAL   ·   U PROJECTION   ·   ÉCHAP PAUSE",16,BONE,800,HORIZONTAL_ALIGNMENT_RIGHT)
	if c.mode == c.Rush.MODE:
		heading(c,Vector2(312,143),c.rush.hud(c),18,BONE,656,HORIZONTAL_ALIGNMENT_CENTER)
	if c.mode == 4:
		var f = c.fighters[0]
		var names := {"light":"Léger","heavy":"Lourd","special":special_name(f),"throw":"Projection","reload":"Recharge"}
		var label: String = "Neutre" if f.action == "" else "%s   ·   image %d" % [names[f.action], f.tick]
		heading(c, Vector2(48,147), "ENTRAÎNEMENT     " + label,19,BONE)
		c.lab.paint(c,self)
	elif c.edition_id != "" or c.case_id != "":
		var info: String = c.archives.hud_line(c, c.edition_id) if c.edition_id != "" else str(Saga.HUD_RULES.get(c.case_id, Saga.CASES[c.case_id].place))
		if c.edition_id == "" and c.case_id != "curien":
			if c.rule_awarded[0]: info += "    /    J1 ✓"
			if c.rule_awarded[1]: info += "    /    " + ("J2 ✓" if c.mode == 2 else "IA ✓")
		if info != "":
			c.draw_rect(Rect2(0,111,1280,31),Color("10151cdd"))
			heading(c,Vector2(20,133),info,16,BONE,1240,HORIZONTAL_ALIGNMENT_CENTER)

func banner(c, title: String, detail: String) -> void:
	c.draw_rect(Rect2(270,202,740,105),Color("101820eb"))
	heading(c,Vector2(270,253),title,33,GOLD,740,HORIZONTAL_ALIGNMENT_CENTER)
	heading(c,Vector2(270,283),detail,18,BONE,740,HORIZONTAL_ALIGNMENT_CENTER)

func cinematic(c) -> void:
	var f = c.fighters[c.winner]
	var loser = c.fighters[1-c.winner]
	var progress := 1.0 - float(c.finish_ticks)/72.0
	var center := Vector2(loser.x,floor_y(c.stage)-110)
	var fade := 1.0 - progress
	var color := Color(f.profile.color)
	color.a = fade
	var beat := clampi(int(progress*3.0), 0, 2)
	var origin := Vector2(f.x,floor_y(c.stage)-float(f.profile.height)*0.6)
	var reach := 38.0+progress*102.0
	match int(f.id):
		0:
			c.draw_arc(center,32+progress*90,0,TAU,48,color,5,true)
			c.draw_line(center-Vector2(70,0),center+Vector2(70,0),color,3)
			c.draw_line(center-Vector2(0,70),center+Vector2(0,70),color,3)
		1:
			for n in 3: c.draw_line(origin+Vector2(0,n*9),center+Vector2(0,n*13),color,3)
		2:
			c.draw_arc(center,42+progress*115,-2.65,0.95,32,color,12,true)
		3:
			for n in 5: c.draw_circle(center+Vector2.from_angle(n*TAU/5+progress)*progress*107,21*(1-progress)+3,color)
		4: # A radio pulse, then two staggered converging tracers.
			c.draw_arc(center,reach,0,TAU,40,color,3,true)
			for n in beat: c.draw_line(origin+Vector2(0,n*20),center+Vector2(0,-35+n*68),color,4,true)
		5: # A diverging cone strikes the emergency gate.
			for n in range(-3,4):
				c.draw_line(origin,center+Vector2(0,n*reach*0.25),color,3,true)
			if beat>0: c.draw_rect(Rect2(center-Vector2(reach,78),Vector2(reach*2,156)),color,false,4)
		6: # The evacuation route closes behind three bursts.
			for n in beat+1:
				var marker := center+Vector2((n-1)*44,-31+n*33)
				c.draw_line(origin,marker,color,3,true)
				c.draw_arc(marker,10+progress*12,0,TAU,16,color,3,true)
		7: # Dawn rising between two tracer lanes.
			c.draw_arc(center+Vector2(0,58),reach,PI,TAU,40,color,6,true)
			for n in range(-1,2,2): c.draw_line(origin+Vector2(0,n*19),center+Vector2(0,n*reach*0.5),color,3,true)
		8: # Drive-in projector iris with film perforations.
			c.draw_arc(center,132.0*(1-progress)+9.0,0,TAU,56,color,7,true)
			for n in 7:
				c.draw_rect(Rect2(center.x-94+n*27,center.y+84,13,6),color)
				c.draw_rect(Rect2(center.x-94+n*27,center.y-88,13,6),color)
		9: # Two looping heart lobes split into sparks.
			var path := PackedVector2Array()
			for n in 49:
				var t := n*TAU/48
				var heart := Vector2(16*pow(sin(t),3),-(13*cos(t)-5*cos(2*t)-2*cos(3*t)-cos(4*t)))
				path.append(center+heart*(2.5+progress*4))
			c.draw_polyline(path,color,4,true)
		10: # Upward boxing trails climb from the pavement.
			for n in beat+1:
				var base := center+Vector2(-f.facing*(48-n*20),57-n*22)
				c.draw_line(base,base+Vector2(f.facing*(62+n*9),-95-n*15),color,6,true)
		11: # The trident rises out of three ripples.
			for n in 3:
				var prong := center+Vector2((n-1)*36,25)
				c.draw_line(prong,prong+Vector2(0,-reach),color,5,true)
			c.draw_arc(center+Vector2(0,35),reach,0.12,PI-0.12,32,color,4,true)
		12: # Three expanding impact rings across the ground.
			for n in beat+1:
				var ring := PackedVector2Array()
				for j in 33: ring.append(Vector2(center.x,floor_y(c.stage))+Vector2.from_angle(j*TAU/32)*Vector2(reach+n*20,12+n*8))
				c.draw_polyline(ring,color,5,true)
		13: # Four arms seal the platform from opposite corners.
			for n in 4:
				var diagonal := Vector2.from_angle(PI*0.25+n*PI/2)
				var contact := center+diagonal*(1-progress)*62
				c.draw_line(center+diagonal*146,contact,color,7,true)
				c.draw_arc(contact,13,-PI,PI,16,color,3,true)
		14: # Objects rise in broken orbit before the reel cuts.
			for n in 7:
				var mark := center+Vector2.from_angle(n*TAU/7+progress*PI)*reach
				c.draw_set_transform_matrix(origin_transform * Transform2D(n*0.3+progress,mark))
				c.draw_rect(Rect2(-9,-4,18,8),color)
				c.draw_set_transform_matrix(origin_transform)
		15: # Two crossed stage lights frame a closing curtain.
			for n in [-1,1]:
				var edge := center+Vector2(n*(130-progress*75),80)
				c.draw_line(edge,center+Vector2(-n*48,-114),color,7,true)
				c.draw_arc(edge,16+progress*9,PI,TAU,16,color,3,true)
		16: # Successive palm marks deepen over the crossing.
			for n in beat+1:
				var contact := center+Vector2((n-1)*28,-n*17)
				c.draw_arc(contact,16+n*12+progress*18,-2.65,2.30,23,color,5,true)
				c.draw_line(contact-Vector2(f.facing*35,0),contact,color,3,true)
		17: # Satellites converge around the rival and fragment into silver droplets.
			for n in 8:
				var mote := center + Vector2.from_angle(n*TAU/8+progress*TAU) * lerpf(140,12,progress)
				c.draw_circle(mote,5+7*fade,color)
				if beat == 2: c.draw_line(center,mote,color,2,true)
		18: # Two concentric conductors discharge as the wheel locks.
			for n in 2:
				var rim := reach+n*22
				c.draw_arc(center,rim,0,TAU,56,color,4,true)
				for tooth in 10:
					var r := Vector2.from_angle(tooth*TAU/10+progress*3)
					c.draw_line(center+r*rim,center+r*(rim+14),color,3,true)
		19: # Crossing cover lines give way to the signal for evacuation.
			for n in [-1,1]:
				var end := center+Vector2(0,n*reach*0.42)
				c.draw_line(origin+Vector2(0,n*8),end,color,3,true)
				c.draw_arc(end,reach*0.29,0,TAU,32,color,2,true)
		20: # The containment doors close around a final cone of light.
			for n in [-1,1]:
				var edge := center+Vector2(n*(100-94*progress),0)
				c.draw_line(edge-Vector2(0,64),edge+Vector2(0,64),color,5,true)
			if beat < 2:
				for n in [-1,0,1]: c.draw_line(origin,center+Vector2(0,n*reach*0.45),color,2,true)
		21: # Facets close, hold and burst outwards.
			for i in 9:
				var axis := Vector2.from_angle(i*TAU/9)
				var dist := 98*(1-progress*1.25) if beat < 2 else 12+(progress-0.66)*330
				var gem := center+axis*dist
				c.draw_colored_polygon(PackedVector2Array([gem-axis*20,gem+axis.orthogonal()*7,gem+axis*18,gem-axis.orthogonal()*7]),color)
		22: # Branches close around the storm eye; one bolt splits its halo.
			for i in 6:
				var root := center+Vector2((i-2.5)*36,85)
				var bud := center+Vector2.from_angle(i*TAU/6+progress)*reach*0.36
				var fork := root.lerp(bud,0.52)+Vector2((-1 if i%2 else 1)*18,0)
				c.draw_polyline(PackedVector2Array([root,fork,bud]),color,5,true)
			if beat == 2:
				c.draw_polyline(PackedVector2Array([center+Vector2(32,-175),center+Vector2(-9,-60),center+Vector2(11,-65),center]),BONE,5,true)
	banner(c,str(f.profile.finish).to_upper(),str(f.profile.title))
