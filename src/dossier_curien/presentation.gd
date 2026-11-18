extends RefCounted

const Fighter := preload("res://src/dossier_curien/combatant.gd")
const ART := "res://assets/dossier_curien/"
const Saga := preload("res://src/dossier_curien/saga.gd")
const Stage := preload("res://src/dossier_curien/saga_stage.gd")
const ATLAS_IDS := ["thomas_rogan", "agent_g", "chariot", "magician"]
const BG := ["mansion-exterior", "mansion-hall", "curien-laboratory"]
const PROPS := [["dead_tree","garden_lamp"], ["mansion_double_door","mansion_sconce"], ["lab_specimen_tank","lab_pipe_cluster"]]
# Offsets are measured from the grounded foot pivot on the registered contact art.
const CONTACT_PIVOTS := {
	"double":Vector2(148,234), "spread":Vector2(127,205), "burst":Vector2(167,210),
	"advance":Vector2(211,205), "stagger":Vector2(118,242), "rise":Vector2(90,258)
}
const BONE := Color("f4ead4")
const GOLD := Color("e2b36b")
const DARK := Color("0e161b")
const STEEL := Color("89b5b5")
var textures := {}
var recent_textures: Array[String] = []
var origin_transform := Transform2D.IDENTITY
var prop_profiles: Dictionary

static func floor_y(stage: int) -> float:
	# The Venetian playable strip runs in front of the canal balustrade.
	return 651.0 if stage == 3 else 601.0

func load_textures() -> void:
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/assets/environment_manifest.json"))
	prop_profiles = manifest.props

func cached(path: String) -> Texture2D:
	if textures.has(path):
		if textures[path] != null and recent_textures.back() != path:
			recent_textures.erase(path)
			recent_textures.append(path)
		return textures[path]
	var texture: Texture2D = load(path) if ResourceLoader.exists(path) else null
	if texture:
		# A match needs at most three stage layers and two active poses per fighter.
		# Release older textures so touring all the dossiers fits browser memory.
		if recent_textures.size() >= 10: textures.erase(recent_textures.pop_front())
		recent_textures.append(path)
	textures[path] = texture
	return texture

func classic_art(key: String) -> Texture2D:
	return cached(ART + key + ".png")

func saga_texture(key: String) -> Texture2D:
	return cached(ART + "saga/" + key + ".png")

func guard_art(fighter_id: int) -> Texture2D:
	var key: String = Fighter.PROFILES[fighter_id].id + "_guard"
	return classic_art(key) if fighter_id < 4 else saga_texture(key)

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
		layer(c, "court_mid", drift * 32)
	elif not classic:
		Stage.mid(c, c.stage, drift)
	else:
		prop_at(c, PROPS[c.stage][0], 180 - drift*33, 580, 270)
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
	if c.phase == "fight" and c.flash > 0:
		var distance: float = (7.0-c.flash)*4.0
		var impact := Vector2(c.impact_position.x,floor_y(c.stage)-c.impact_position.y)
		var ink := Color("a0cfda") if c.impact_guard else Color("f3cf86")
		ink.a = c.flash/6.0
		for n in (5 if c.impact_guard else 8):
			var direction := Vector2.from_angle(n*TAU/(5 if c.impact_guard else 8))
			c.draw_line(impact+direction*(5+distance*0.5),impact+direction*(12+distance),ink,2,true)
	if court:
		layer(c, "court_front", drift * 58)
	elif not classic:
		Stage.front(c, c.stage, drift)
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
	if c.panel != null and c.panel.visible:
		c.draw_rect(Rect2(0,0,1280,720),Color(0.015,0.022,0.035,0.19))

func layer(c, id: String, offset: float) -> void:
	var tex := classic_art(id)
	if tex: c.draw_texture_rect(tex,Rect2(-38-offset,-14,1356,754),false)

func prop_at(c, id: String, x: float, bottom: float, h: float) -> void:
	var tex := cached("res://assets/environments_v2/props/%s/%s.png" % [id,id])
	if tex == null: return
	var frames: int = prop_profiles[id].get("hframes",1)
	var cell := tex.get_size() / Vector2(frames,1)
	var w := h * cell.x / cell.y
	var index: int = int(c.elapsed / 12.0) % frames if prop_profiles[id].has("animate") else 0
	c.draw_texture_rect_region(tex,Rect2(x-w/2,bottom-h,w,h),Rect2(cell.x * index,0,cell.x,cell.y))

func illustration(c) -> void:
	var tex: Texture2D
	if c.phase == "select":
		var id: String = Fighter.PROFILES[c.preview].id
		tex = classic_art(id + "_select") if c.preview < 4 else saga_texture(id + "_select")
		if tex == null: tex = guard_art(c.preview)
	elif c.case_id != "" and c.case_id != "curien" and c.chosen == Saga.CASES[c.case_id].lead:
		var shot := "ending" if c.phase == "result" else ["intro","rival","final"][c.route] as String
		tex = saga_texture(c.case_id + "_" + shot)
	elif c.chosen == 0:
		if c.phase == "result": tex = classic_art("rogan_ending")
		elif c.route == 0: tex = classic_art("rogan_intro")
		elif c.route == 1: tex = classic_art("rogan_rival")
	if tex == null and c.case_id != "" and c.case_id != "curien" and c.phase != "select":
		var subject: int = c.enemy if c.route == 1 and c.phase != "result" else c.chosen
		var silhouette: Texture2D = guard_art(subject)
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

func draw_fighter(c, f, side: int) -> void:
	var art: Texture2D = guard_art(f.id)
	var idle: bool = f.action == "" and not f.moving and f.stun == 0 and f.altitude == 0
	if f.id in [0,2] or f.id >= 4:
		var pose: Texture2D
		if f.stun > 0:
			pose = saga_texture(f.profile.id + "_recoil") if f.id >= 4 else classic_art(f.profile.id + "_recoil")
		elif f.action in ["light","heavy","special","throw"]:
			var key := "_windup" if f.tick < int(f.move_data().start) else "_contact"
			var age: int = f.tick-int(f.move_data().start)
			var later_shot: bool = f.action == "special" and age < f.shots_per_special*5 and age%5 <= 2
			if f.id != 0 and age > 2 and not later_shot: key = "_recovery"
			pose = saga_texture(f.profile.id + key) if f.id >= 4 else classic_art(f.profile.id + key)
		if pose:
			art = pose
			idle = true
	var height: float = f.profile.height
	var bottom := floor_y(c.stage) - float(f.altitude)
	if f.crouching: height *= 0.71
	var collapse: float = 0.0
	if c.phase == "cinematic" and side != c.winner:
		collapse = 1.0 - float(c.finish_ticks) / 72
		height *= 1.0 - collapse * 0.78
	var tint := Color.WHITE
	if f.stun > 0 and f.stun % 5 < 2: tint = Color(1.0,0.65,0.55)
	if art and (idle or f.id >= 4):
		var breathing := sin(float(c.elapsed + side * 24)*0.062)*1.5
		var h := (height + breathing) * 1024 / 905
		var w := h * art.get_width() / art.get_height()
		var tilt := 0.0
		var shift := Vector2.ZERO
		if f.id >= 4 and not idle:
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
		c.draw_set_transform_matrix(origin_transform * pivot)
		c.draw_texture_rect(art,Rect2(-w*0.5,-h*960/1024,w,h),false,tint)
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
		if age < maxi(5, f.shots_per_special*5):
			var anchor: Vector2 = CONTACT_PIVOTS.get(f.profile.kind, Vector2(47,height*0.58))
			draw_special(c, f, Vector2(f.x+f.facing*anchor.x,bottom-anchor.y), age)
	elif f.id >= 4 and f.action in ["light","heavy","throw"]:
		var age: int = f.tick - int(f.move_data().start)
		if age >= 0 and age < 4:
			var fist := Vector2(f.x+f.facing*35,bottom-height*0.54)
			var tip := fist+Vector2(f.facing*float(f.move_data().reach)*0.68,-8 if f.action=="light" else 13)
			c.draw_line(fist,tip,Color(f.profile.color,0.76),2 if f.action=="light" else 5,true)
			c.draw_arc(tip,9+age*3,-2.15,1.8,12,Color(f.profile.color,0.80),2,true)

func draw_special(c, f, origin: Vector2, age: int) -> void:
	var reach := float(f.profile.move.reach)*0.86
	var end := origin + Vector2(f.facing*reach,0)
	var accent := Color(f.profile.color)
	match str(f.profile.kind):
		"shot","double","burst","advance","stagger":
			if age%5 > 2: return
			end.x = f.x+f.facing*float(f.profile.move.reach)
			if f.profile.kind == "stagger": end.y -= 34
			c.draw_line(origin,end,accent,3 if f.profile.kind=="stagger" else 2,true)
			c.draw_circle(origin,8 if age%5 == 0 else 4,GOLD)
		"spread":
			end.x = f.x+f.facing*float(f.profile.move.reach)
			for n in range(-2,3): c.draw_line(origin,end+Vector2(0,n*15),Color(accent,0.76),2,true)
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
		var status: String = ("%s   %d / %d" % [str(f.profile.special).to_upper(),f.ammo,f.profile.ammo]) if int(f.profile.ammo) > 0 else str(f.profile.special).to_upper()
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
		var names := {"light":"Léger","heavy":"Lourd","special":str(f.profile.special),"throw":"Projection","reload":"Recharge"}
		var label: String = "Neutre" if f.action == "" else "%s   ·   image %d" % [names[f.action], f.tick]
		heading(c, Vector2(48,147), "ENTRAÎNEMENT     " + label,19,BONE)
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
	banner(c,str(f.profile.finish).to_upper(),str(f.profile.title))
