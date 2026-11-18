extends RefCounted

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const ART := "res://assets/dossier_curien/"
const PREFIX := ["rogan", "g", "chariot", "magician"]
const BG := ["mansion-exterior", "mansion-hall", "curien-laboratory"]
const PROPS := [["dead_tree","garden_lamp"], ["mansion_double_door","mansion_sconce"], ["lab_specimen_tank","lab_pipe_cluster"]]
const BONE := Color("f4ead4")
const GOLD := Color("e2b36b")
const DARK := Color("0e161b")
const STEEL := Color("89b5b5")
const FOOT := 601.0
var textures := {}
var sheets: Array[Texture2D] = []
var guards: Array = []
var origin_transform := Transform2D.IDENTITY
var prop_profiles: Dictionary

func load_textures() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/assets/environment_manifest.json"))
	prop_profiles = manifest.props
	for i in Fighter.IDS.size():
		var id: String = Fighter.IDS[i]
		var group := "heroes" if i < 2 else "bosses"
		sheets.append(load("res://assets/sprites_v2/%s/%s/%s__v2__action_cycle__8dirx8f.png" % [group,id,id]))
		guards.append(optional(ART + PREFIX[i] + "_guard.png"))
	for i in BG.size():
		textures[BG[i]] = load("res://assets/environments/%s.png" % BG[i])
		for prop in PROPS[i]:
			textures[prop] = load("res://assets/environments_v2/props/%s/%s.png" % [prop,prop])
	for item in ["court_back","court_mid","court_front","rogan_intro","rogan_rival","rogan_ending","rogan_select","g_select","chariot_select","magician_select","chariot_windup","chariot_contact","chariot_recoil","chariot_recovery","rogan_windup","rogan_contact","rogan_recoil"]:
		textures[item] = optional(ART + item + ".png")

func optional(path: String) -> Texture2D:
	return load(path) as Texture2D if ResourceLoader.exists(path) else null

func heading(c, pos: Vector2, line: String, px: int, color: Color, width := -1.0, align := HORIZONTAL_ALIGNMENT_LEFT) -> void:
	c.draw_string(ThemeDB.fallback_font,pos,line,align,width,px,color)

func draw(c) -> void:
	var drift := 0.0
	if c.fighters.size() == 2:
		drift = ((c.fighters[0].x + c.fighters[1].x) * 0.5 - 640.0) / 565.0
	var backdrop: Texture2D = textures.get(BG[c.stage])
	var court: bool = c.stage == 0 and textures.get("court_back") != null
	if court: backdrop = textures.court_back
	if backdrop: c.draw_texture_rect(backdrop,Rect2(-38 - drift*17,-14,1356,754),false)
	if court:
		layer(c, "court_mid", drift * 32)
	else:
		prop_at(c, PROPS[c.stage][0], 180 - drift*33, 580, 270)
	c.draw_rect(Rect2(0, 0, 1280, 720), Color(0.025, 0.035, 0.05, 0.19))
	if c.fighters.size() == 2:
		for i in 2:
			var f = c.fighters[i]
			var color := Color(0.02, 0.025, 0.032, 0.42)
			var shadow := PackedVector2Array()
			for n in 24:
				shadow.append(Vector2(f.x, FOOT + 1) + Vector2.from_angle(TAU*n/24) * Vector2(64,9))
			c.draw_colored_polygon(shadow, color)
			draw_fighter(c, f, i)
	if court:
		layer(c, "court_front", drift * 58)
	else:
		prop_at(c, PROPS[c.stage][1], 1225 - drift*66, 638, 216)
	if c.phase in ["fight","finish","cinematic","round","result","pause"] and c.fighters.size() == 2:
		hud(c)
		if c.phase == "cinematic": cinematic(c)
		if c.phase == "finish":
			banner(c,"FINIR LE DUEL",("I / RB" if c.winner == 0 else "Y / RB") + "  ·  " + Fighter.FINISHERS[c.fighters[c.winner].id])
	elif c.phase in ["select","brief"]:
		illustration(c)
	if c.phase == "result" and c.mode == 0 and c.winner == 0 and c.route == 2:
		illustration(c)
	if c.panel != null and c.panel.visible:
		c.draw_rect(Rect2(0,0,1280,720),Color(0.015,0.022,0.035,0.19))

func layer(c, id: String, offset: float) -> void:
	var tex: Texture2D = textures.get(id)
	if tex: c.draw_texture_rect(tex,Rect2(-38-offset,-14,1356,754),false)

func prop_at(c, id: String, x: float, bottom: float, h: float) -> void:
	var tex: Texture2D = textures[id]
	var frames: int = prop_profiles[id].get("hframes",1)
	var cell := tex.get_size() / Vector2(frames,1)
	var w := h * cell.x / cell.y
	var index: int = int(c.elapsed / 12.0) % frames if prop_profiles[id].has("animate") else 0
	c.draw_texture_rect_region(tex,Rect2(x-w/2,bottom-h,w,h),Rect2(cell.x * index,0,cell.x,cell.y))

func illustration(c) -> void:
	var tex: Texture2D
	if c.phase == "select":
		tex = textures.get(PREFIX[c.preview] + "_select")
		if tex == null: tex = guards[c.preview]
	elif c.chosen == 0:
		if c.phase == "result": tex = textures.rogan_ending
		elif c.route == 0: tex = textures.rogan_intro
		elif c.route == 1: tex = textures.rogan_rival
	if tex == null: return
	if c.phase == "select":
		var r := tex.get_size()
		var scale := minf(510.0/r.x, 507.0/r.y)
		var ext := r * scale
		c.draw_texture_rect(tex,Rect2(Vector2(940,376)-ext/2,ext),false)
	else:
		c.draw_texture_rect(tex,Rect2(0,0,1280,720),false)
		c.draw_rect(Rect2(0,0,1280,720), Color(0,0,0,0.12))

func draw_fighter(c, f, side: int) -> void:
	var art: Texture2D = guards[f.id]
	var idle: bool = f.action == "" and not f.moving and f.stun == 0 and f.altitude == 0
	if f.id in [0,2]:
		var pose: Texture2D
		if f.stun > 0:
			pose = textures.get(PREFIX[f.id] + "_recoil")
		elif f.action in ["light","heavy","special","throw"]:
			var key := "_windup" if f.tick < int(f.move_data().start) else "_contact"
			if f.id == 2 and f.tick > int(f.move_data().start) + 2: key = "_recovery"
			pose = textures.get(PREFIX[f.id] + key)
		if pose:
			art = pose
			idle = true
	var height: float = [278,267,344,308][f.id]
	var bottom := FOOT - float(f.altitude)
	if f.crouching: height *= 0.71
	var collapse: float = 0.0
	if c.phase == "cinematic" and side != c.winner:
		collapse = 1.0 - float(c.finish_ticks) / 72
		height *= 1.0 - collapse * 0.78
	var tint := Color.WHITE
	if f.stun > 0 and f.stun % 5 < 2: tint = Color(1.0,0.65,0.55)
	if art and idle:
		var breathing := sin(float(c.elapsed + side * 24)*0.062)*1.5
		var h := (height + breathing) * 1024 / 905
		var w := h * art.get_width() / art.get_height()
		var pivot := Transform2D(0.0,Vector2(f.x,bottom))
		pivot.x *= f.facing
		c.draw_set_transform_matrix(origin_transform * pivot)
		c.draw_texture_rect(art,Rect2(-w*0.5,-h*960/1024,w,h),false,tint)
		c.draw_set_transform_matrix(origin_transform)
	else:
		var frame := 0
		if f.stun > 0: frame = 6
		elif f.action == "reload": frame = 4
		elif f.action != "":
			var start: int = f.move_data().start
			frame = 4 if f.tick < start else 5
		elif f.moving: frame = 1 + int(c.elapsed/7.0) % 3
		var tex: Texture2D = sheets[f.id]
		var cell := tex.get_size() / 8
		var row := 6 if f.facing > 0 else 2
		var side_len := height * 256 / 228
		var dst := Rect2(f.x-side_len*0.5,bottom-side_len*242/256,side_len,side_len)
		c.draw_texture_rect_region(tex,dst,Rect2(Vector2(frame,row)*cell,cell),tint)
	if f.action == "special" and f.tick >= f.move_data().start and f.tick < int(f.move_data().start)+6:
		var origin := Vector2(f.x+f.facing*52,bottom-height*0.59)
		var end := origin + Vector2(f.facing*float(f.move_data().reach)*0.86,0)
		if f.id < 2:
			c.draw_line(origin,end,Color("f5cc80"),2,true)
			c.draw_circle(origin,8,GOLD)
		elif f.id == 3:
			var travel := float(f.tick - int(f.move_data().start))/5
			c.draw_circle(origin.lerp(end, travel),17,Color("ed7c42"))
			c.draw_circle(origin.lerp(end, travel),8,BONE)
		else:
			c.draw_arc(origin, 115, -1.75 if f.facing>0 else 1.4, 1.75 if f.facing>0 else 4.9, 24, GOLD, 4,true)

func hud(c) -> void:
	c.draw_rect(Rect2(0,0,1280,111),Color("0e141cdd"))
	for i in 2:
		var f = c.fighters[i]
		var x := 48.0 if i == 0 else 763.0
		var align := HORIZONTAL_ALIGNMENT_LEFT if i == 0 else HORIZONTAL_ALIGNMENT_RIGHT
		var player: String = "J1" if i == 0 else ("J2" if c.mode == 2 else "IA")
		heading(c,Vector2(x,39),player + "   /   " + Fighter.NAMES[f.id].to_upper(),24,BONE,469,align)
		c.draw_rect(Rect2(x,50,469,16),Color("3c4648"))
		var w: float = 465.0 * f.health / 100
		c.draw_rect(Rect2(x+2 if i == 0 else x+467-w,52,w,12),GOLD if i==0 else STEEL)
		var status: String = ("AMS   %d / 6" % f.ammo) if f.id < 2 else Fighter.SPECIAL_NAMES[f.id].to_upper()
		if f.combo > 1: status += "     %d COUPS" % f.combo
		if f.guarding: status += "     GARDE"
		heading(c,Vector2(x,91),status,17,BONE,469,align)
	heading(c,Vector2(520,52),"∞" if c.mode==4 else str(ceili(float(c.clock_ticks)/60)),42,BONE,240,HORIZONTAL_ALIGNMENT_CENTER)
	heading(c,Vector2(520,83),"%d    /    %d" % [c.wins[0],c.wins[1]],18,GOLD,240,HORIZONTAL_ALIGNMENT_CENTER)
	c.draw_rect(Rect2(0,664,1280,56),Color("10151cdd"))
	heading(c,Vector2(42,698),c.STAGES[c.stage].to_upper(),17,GOLD)
	heading(c,Vector2(440,698),"J LÉGER   ·   K LOURD   ·   L SPÉCIAL   ·   U PROJECTION   ·   ÉCHAP PAUSE",16,BONE,800,HORIZONTAL_ALIGNMENT_RIGHT)
	if c.mode == 4:
		var f = c.fighters[0]
		var label: String = "Neutre" if f.action == "" else "%s   ·   image %d" % [f.action, f.tick]
		heading(c, Vector2(48,147), "ENTRAÎNEMENT     " + label,19,BONE)

func banner(c, title: String, detail: String) -> void:
	c.draw_rect(Rect2(270,202,740,105),Color("101820eb"))
	heading(c,Vector2(270,253),title,33,GOLD,740,HORIZONTAL_ALIGNMENT_CENTER)
	heading(c,Vector2(270,283),detail,18,BONE,740,HORIZONTAL_ALIGNMENT_CENTER)

func cinematic(c) -> void:
	var f = c.fighters[c.winner]
	var loser = c.fighters[1-c.winner]
	var progress := 1.0 - float(c.finish_ticks)/72.0
	var center := Vector2(loser.x,FOOT-110)
	var fade := 1.0 - progress
	var color: Color = [Color("a9dbea"), Color("91b9d8"), Color("e9c283"), Color("ef7543")][f.id]
	color.a = fade
	match f.id:
		0:
			c.draw_arc(center,32+progress*90,0,TAU,48,color,5,true)
			c.draw_line(center-Vector2(70,0),center+Vector2(70,0),color,3)
			c.draw_line(center-Vector2(0,70),center+Vector2(0,70),color,3)
		1:
			for n in 3:
				c.draw_line(Vector2(f.x,FOOT-155+n*9),center+Vector2(0,n*13),color,3)
		2:
			c.draw_arc(center,42+progress*115,-2.65,0.95,32,color,12,true)
		3:
			for n in 5:
				c.draw_circle(center+Vector2.from_angle(n*TAU/5+progress)*progress*107,21*(1-progress)+3,color)
	banner(c,Fighter.FINISHERS[f.id].to_upper(),Fighter.NAMES[f.id])
