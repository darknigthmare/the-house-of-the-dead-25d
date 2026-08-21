class_name GameplayController
extends Node3D

signal exit_requested

const CrosshairControlScript := preload("res://src/ui/crosshair_control.gd")
const ProceduralSfxScript := preload("res://src/audio/procedural_sfx.gd")
const SpriteAtlasLibraryScript := preload("res://src/gameplay/sprite_atlas_library.gd")
const DirectionalSpriteResolverScript := preload("res://src/gameplay/directional_sprite_resolver.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"
const SPRITE_MANIFEST_PATH := "res://data/assets/sprite_manifest.json"
const QA_SCORE_DEV_PATH := "res://logs/score/score_qa.jsonl"
const QA_SCORE_EXPORT_PATH := "user://score_qa.jsonl"
const MAGAZINE_SIZE := 6

const ITEM_TEXTURES := {
	"medal": "res://assets/sprites/items/gold-coin.png",
	"frog": "res://assets/sprites/items/golden-frog.png",
	"life": "res://assets/sprites/items/medical-kit.png"
}

const ACTOR_STATS := {
	# Canonical arcade roster. Until a licensed atlas exists for every type, each
	# entry explicitly reuses one of the project's fan-made sheets and applies a
	# stable tint/scale silhouette treatment. Gameplay identity is driven by data.
	"sam_a1": {"health": 3.0, "speed": 1.0, "scale": 1.0, "score": 80, "behavior": "walk", "tint": "#ffffff", "attack_period": 1.8},
	"neil_a2": {"health": 3.0, "speed": 0.9, "scale": 0.96, "score": 80, "behavior": "walk", "tint": "#c7d6b9", "attack_period": 1.9},
	"cyril_a3": {"health": 4.0, "speed": 1.26, "scale": 1.05, "score": 80, "behavior": "charge", "tint": "#c6a69c", "attack_period": 1.55},
	"kageo_b1": {"health": 2.0, "speed": 1.15, "scale": 0.93, "score": 80, "behavior": "ceiling_drop", "tint": "#8f9da7", "drop_height": 4.4, "drop_duration": 1.25, "attack_period": 1.7},
	"bourbon_b2": {"health": 6.0, "speed": 0.64, "scale": 1.18, "score": 80, "behavior": "heavy_weapon", "tint": "#ba916e", "armor_zones": ["torso"], "armor_durability": 2.0, "attack_period": 2.35},
	"ebitan_a_b3": {"health": 2.0, "speed": 1.48, "scale": 0.58, "score": 80, "behavior": "aquatic_weave", "tint": "#91b9a9", "weave_width": 1.25, "attack_period": 1.65},
	"ebitan_b_b4": {"health": 3.0, "speed": 1.62, "scale": 0.64, "score": 80, "behavior": "aquatic_weave", "tint": "#6f9aa7", "weave_width": 1.65, "attack_period": 1.5},
	"samson_c1": {"health": 6.0, "speed": 0.58, "scale": 1.22, "score": 80, "behavior": "heavy_weapon", "tint": "#9d7b6d", "attack_period": 2.5},
	"bentley_c2": {"health": 7.0, "speed": 0.52, "scale": 1.28, "score": 80, "behavior": "armored_advance", "tint": "#788a8e", "armor_zones": ["head", "torso"], "armor_durability": 4.0, "attack_period": 2.2},
	"burner_c3": {"health": 5.0, "speed": 0.72, "scale": 1.14, "score": 80, "behavior": "throw_projectile", "tint": "#b57a56", "projectile_actor": "murrer_g1", "projectile_speed": 3.8, "attack_period": 2.25},
	"simon_d1": {"health": 3.0, "speed": 1.18, "scale": 0.96, "score": 80, "behavior": "jump", "tint": "#a0b0a0", "jump_height": 1.2, "attack_period": 1.7},
	"gilmore_d2": {"health": 4.0, "speed": 1.42, "scale": 1.04, "score": 80, "behavior": "charge", "tint": "#c98f83", "charge_factor": 2.15, "attack_period": 1.45},
	"harris_d3": {"health": 3.0, "speed": 0.92, "scale": 0.78, "score": 80, "behavior": "throw_projectile", "tint": "#d4c18d", "projectile_actor": "bouere_f3", "projectile_speed": 4.2, "attack_period": 2.0},
	"robert_d4": {"health": 6.0, "speed": 0.66, "scale": 1.2, "score": 80, "behavior": "heavy_weapon", "tint": "#8d766b", "armor_zones": ["torso"], "armor_durability": 3.0, "attack_period": 2.3},
	"rubin_e1": {"health": 3.0, "speed": 1.3, "scale": 0.94, "score": 80, "behavior": "jump", "tint": "#b39e87", "jump_height": 1.55, "attack_period": 1.55},
	"drake_e2": {"health": 3.0, "speed": 0.9, "scale": 0.82, "score": 80, "behavior": "throw_projectile", "tint": "#9aa5bf", "projectile_actor": "murrer_g1", "projectile_speed": 4.5, "attack_period": 1.85},
	"moody_e3": {"health": 3.0, "speed": 1.08, "scale": 0.91, "score": 80, "behavior": "ceiling_drop", "tint": "#879286", "drop_height": 5.0, "drop_duration": 0.95, "attack_period": 1.6},
	"parlor_e4": {"health": 4.0, "speed": 1.55, "scale": 1.0, "score": 80, "behavior": "charge", "tint": "#aa8179", "charge_factor": 2.4, "attack_period": 1.35},
	"kenfis_f1": {"health": 2.0, "speed": 1.3, "scale": 0.74, "score": 80, "behavior": "jump", "tint": "#ffffff", "jump_height": 1.0, "attack_period": 1.7},
	"saruzou_f2": {"health": 2.0, "speed": 1.34, "scale": 0.7, "score": 80, "behavior": "ceiling_drop", "tint": "#b4ac91", "drop_height": 4.7, "drop_duration": 0.82, "attack_period": 1.5},
	"bouere_f3": {"health": 2.0, "speed": 1.72, "scale": 0.6, "score": 80, "behavior": "jump", "tint": "#8da899", "jump_height": 1.35, "attack_period": 1.4},
	"devilon_f4": {"health": 1.0, "speed": 2.0, "scale": 0.52, "score": 80, "behavior": "flight_swarm", "tint": "#a391b7", "weave_width": 1.0, "attack_period": 1.25},
	"murrer_g1": {"health": 1.0, "speed": 2.15, "scale": 0.4, "score": 80, "behavior": "flight_swarm", "tint": "#9ca788", "weave_width": 1.4, "attack_period": 1.2},
	"name_g2": {"health": 2.0, "speed": 1.65, "scale": 0.62, "score": 80, "behavior": "aquatic_weave", "tint": "#ffffff", "weave_width": 1.1, "attack_period": 1.55},
	"taran_g3": {"health": 4.0, "speed": 1.1, "scale": 0.86, "score": 80, "behavior": "armored_advance", "tint": "#657f78", "armor_zones": ["head"], "armor_durability": 2.0, "attack_period": 1.85},
	# Compatibility aliases retained for boss scripts and older route data.
	"axe_creature": {"health": 5.0, "speed": 0.68, "scale": 1.12, "score": 80, "behavior": "heavy_weapon", "tint": "#ffffff", "attack_period": 2.2},
	"mutant_bat": {"health": 1.0, "speed": 1.9, "scale": 0.54, "score": 80, "behavior": "flight_swarm", "tint": "#ffffff", "weave_width": 0.9, "attack_period": 1.3}
}

var configuration: Dictionary = {
	"mode": "arcade", "players": 1, "demo": false, "start_chapter": 1,
	"language": "fr", "authentic_ratio": true, "reduced_flashes": false,
	"reduced_shake": false, "blood_level": 2,
	"qa_score_logging": false, "qa_score_log_path": ""
}
var campaign: Dictionary = {}
var chapters: Array = []
var chapter_index: int = 0
var current_chapter: Dictionary = {}
var current_node: Dictionary = {}
var current_node_id: String = ""
var state: String = "boot"
var state_timer: float = 0.0
var node_elapsed: float = 0.0
var spawn_cursor: int = 0
var branch_success: bool = false
var all_scientists_saved: bool = true
var scientists_saved: int = 0
var scientists_total: int = 0
var chapter_scientists_saved: int = 0
var chapter_scientists_total: int = 0
var routes_discovered: Dictionary = {}
var boss_queue: Array[String] = []
var current_boss: Node3D
var boss_phase: int = 0
var boss_max_health: float = 1.0
var boss_attack_timer: float = 2.0
var boss_weak_window: float = 0.0
var session_started: bool = false
var paused_by_player: bool = false
var active_play_rect := Rect2(160.0, 0.0, 960.0, 720.0)
var cursor_velocities: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var demo_fire_timer: float = 0.0
var continue_timer: float = 0.0
var continuing_player: int = -1

var players: Array[Dictionary] = []
var camera_3d: Camera3D
var world_root: Node3D
var actor_root: Node3D
var fx_root: Node3D
var active_actors: Array[Node3D] = []
var active_civilian: Node3D
var rail_origin := Vector3(0.0, 1.7, 8.0)
var rail_target := Vector3(0.0, 1.55, 4.5)
var rail_duration: float = 8.0

var hud_layer: CanvasLayer
var hud_root: Control
var p1_status: Label
var p2_status: Label
var chapter_label: Label
var objective_label: Label
var subtitle_label: Label
var route_label: Label
var boss_panel: PanelContainer
var boss_name_label: Label
var boss_health_bar: ProgressBar
var boss_weak_label: Label
var center_overlay: PanelContainer
var center_title: Label
var center_body: Label
var crosshairs: Array[Control] = []
var flash_rect: ColorRect
var score_feed: VBoxContainer
var audio_players: Dictionary = {}
var qa_score_log_error_reported: bool = false
var sprite_atlas_library = SpriteAtlasLibraryScript.new()
var directional_sprite_resolver = DirectionalSpriteResolverScript.new()


func configure(options: Dictionary) -> void:
	for key in options:
		configuration[key] = options[key]
	if is_node_ready():
		for crosshair in crosshairs:
			crosshair.scale = Vector2.ONE * clampf(float(configuration.get("crosshair_scale", 1.0)), 0.65, 2.5)
	if is_node_ready() and not session_started:
		_start_session()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_world_nodes()
	_build_hud()
	_build_audio()
	call_deferred("_start_session")


func _start_session() -> void:
	if session_started:
		return
	session_started = true
	if not _load_sprite_manifest():
		session_started = false
		return
	_load_campaign()
	_setup_players(int(configuration.get("players", 1)))
	_update_play_rect()
	if str(configuration.get("mode", "arcade")) == "boss_rush":
		boss_queue.assign(["chariot", "hangedman", "hermit", "magician"])
		_show_overlay("BOSS RUSH", "Quatre expériences de Curien. Une seule vie.", 2.8)
		state = "boss_rush_intro"
		state_timer = 2.8
	elif str(configuration.get("mode", "arcade")) == "training":
		chapter_index = 0
		_show_overlay("ENTRAÎNEMENT AMS", "Précision, recharge et sauvetage civil.", 2.4)
		state = "training_intro"
		state_timer = 2.4
	else:
		chapter_index = clampi(int(configuration.get("start_chapter", 1)) - 1, 0, maxi(0, chapters.size() - 1))
		_begin_chapter(chapter_index)


func _load_campaign() -> void:
	if not FileAccess.file_exists(CAMPAIGN_PATH):
		push_error("Campaign timeline is missing: %s" % CAMPAIGN_PATH)
		campaign = {"chapters": []}
		chapters = []
		return
	var file := FileAccess.open(CAMPAIGN_PATH, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Campaign timeline is invalid JSON")
		campaign = {"chapters": []}
		chapters = []
		return
	campaign = parsed as Dictionary
	chapters = campaign.get("chapters", []) as Array


func _load_sprite_manifest() -> bool:
	if not sprite_atlas_library.load_manifest(SPRITE_MANIFEST_PATH):
		push_error(sprite_atlas_library.last_error)
		return false
	directional_sprite_resolver.direction_count = 8
	directional_sprite_resolver.frames_per_direction = 8
	directional_sprite_resolver.mirror_symmetric_directions = false
	directional_sprite_resolver.direction_order.assign([0, 1, 2, 3, 4, 5, 6, 7])
	return true


func _configure_actor_sprite(sprite: Sprite3D, actor_id: String, actor_scale: float) -> bool:
	var profile := sprite_atlas_library.get_profile(actor_id) as Dictionary
	if profile.is_empty():
		push_error("No directional sprite profile for actor: %s" % actor_id)
		return false
	var texture_path := str(profile.get("path", ""))
	var texture := load(texture_path) as Texture2D
	if texture == null:
		push_error("Directional sprite texture failed to load: %s" % texture_path)
		return false
	sprite.texture = texture
	sprite.region_enabled = false
	sprite.hframes = 8
	sprite.vframes = 8
	sprite.frame = 0
	sprite.pixel_size = float(profile.get("base_pixel_size", 0.0075)) * actor_scale
	sprite.position.y = float(profile.get("origin_y", 0.95)) * actor_scale
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED if str(profile.get("billboard", "fixed_y")) == "full" else BaseMaterial3D.BILLBOARD_FIXED_Y
	sprite.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	return true


func _apply_directional_sprite_frame(actor: Node3D, local_frame: int) -> int:
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null:
		return -1
	var actor_forward := actor.get_meta("visual_forward", Vector3.BACK) as Vector3
	var camera_position := actor.global_position - actor_forward
	if camera_3d != null:
		camera_position = camera_3d.global_position
	return directional_sprite_resolver.apply_to_sprite(
		sprite,
		actor_forward,
		camera_position,
		actor.global_position,
		clampi(local_frame, 0, 7)
	)


func _setup_players(requested_count: int) -> void:
	players.clear()
	for index in 2:
		players.append({
			"active": index < requested_count,
			"ammo": MAGAZINE_SIZE,
			"lives": 3,
			"score": 0,
			"credits": 3,
			"shots": 0,
			"hits": 0,
			"continues": 0,
			"cursor": Vector2(640.0 + (float(index) * 90.0), 410.0),
			"color": Color("#ef3340") if index == 0 else Color("#35a9ff")
		})
	for index in 2:
		crosshairs[index].visible = bool(players[index].active)
	_update_hud()


func _build_world_nodes() -> void:
	world_root = Node3D.new()
	world_root.name = "ProceduralEnvironment"
	add_child(world_root)
	actor_root = Node3D.new()
	actor_root.name = "SpriteActors3D"
	add_child(actor_root)
	fx_root = Node3D.new()
	fx_root.name = "CombatFx"
	add_child(fx_root)
	camera_3d = Camera3D.new()
	camera_3d.name = "RailCamera"
	camera_3d.fov = 58.0
	camera_3d.near = 0.08
	camera_3d.far = 90.0
	add_child(camera_3d)
	camera_3d.position = rail_origin
	camera_3d.look_at(Vector3(0.0, 1.35, -8.0), Vector3.UP)


func _build_audio() -> void:
	var definitions := {
		"shot": ProceduralSfxScript.tone(126.0, 0.12, 0.55, 22.0, 0.68),
		"reload": ProceduralSfxScript.tone(740.0, 0.14, 0.22, 7.0, 0.15),
		"empty": ProceduralSfxScript.tone(980.0, 0.05, 0.12, 16.0, 0.0),
		"hit": ProceduralSfxScript.tone(64.0, 0.11, 0.4, 20.0, 0.75),
		"rescue": ProceduralSfxScript.tone(880.0, 0.28, 0.16, 3.2, 0.0),
		"danger": ProceduralSfxScript.tone(48.0, 0.36, 0.18, 2.0, 0.32)
	}
	for key in definitions:
		var player := AudioStreamPlayer.new()
		player.stream = definitions[key]
		player.bus = "Effects"
		add_child(player)
		audio_players[key] = player


func _play_sfx(key: String) -> void:
	if audio_players.has(key):
		(audio_players[key] as AudioStreamPlayer).play()


func _default_qa_score_log_path() -> String:
	return QA_SCORE_DEV_PATH if OS.has_feature("editor") else QA_SCORE_EXPORT_PATH


func _qa_score_log_path() -> String:
	var configured_path := str(configuration.get("qa_score_log_path", "")).strip_edges()
	return _default_qa_score_log_path() if configured_path.is_empty() else configured_path


func _append_score_qa_entry(
	player_index: int,
	source: String,
	target: String,
	shot_type: String,
	requested_value: int,
	score_before: int,
	score_after: int
) -> void:
	if not bool(configuration.get("qa_score_logging", false)):
		return
	var log_path := _qa_score_log_path()
	var absolute_path := ProjectSettings.globalize_path(log_path)
	var directory_error := DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	if directory_error != OK and directory_error != ERR_ALREADY_EXISTS:
		_report_qa_score_log_error(log_path, directory_error)
		return
	var file: FileAccess
	if FileAccess.file_exists(log_path):
		file = FileAccess.open(log_path, FileAccess.READ_WRITE)
		if file != null:
			file.seek_end()
	else:
		file = FileAccess.open(log_path, FileAccess.WRITE)
	if file == null:
		_report_qa_score_log_error(log_path, FileAccess.get_open_error())
		return
	var actual_delta := score_after - score_before
	var chapter_id := str(current_chapter.get("id", ""))
	if chapter_id.is_empty() and chapter_index >= 0:
		chapter_id = "chapter_%02d" % (chapter_index + 1)
	var entry := {
		"timestamp": Time.get_datetime_string_from_system(true, false),
		"player": player_index + 1,
		"source": source,
		"target": target,
		"shot_type": shot_type,
		"value": actual_delta,
		"delta": actual_delta,
		"requested_value": requested_value,
		"score_before": score_before,
		"score_after": score_after,
		"chapter": chapter_id,
		"node": current_node_id
	}
	file.store_line(JSON.stringify(entry))
	file.flush()
	file.close()


func _report_qa_score_log_error(log_path: String, error_code: Error) -> void:
	if qa_score_log_error_reported:
		return
	qa_score_log_error_reported = true
	push_warning("QA score log could not be written (%s): %s" % [log_path, error_string(error_code)])


func _build_hud() -> void:
	hud_layer = CanvasLayer.new()
	hud_layer.layer = 5
	add_child(hud_layer)
	hud_root = Control.new()
	hud_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_layer.add_child(hud_root)

	for side in ["left", "right"]:
		var bar := ColorRect.new()
		bar.name = "Pillar_%s" % side
		bar.color = Color(0.004, 0.006, 0.008, 1.0)
		bar.position = Vector2(0.0, 0.0) if side == "left" else Vector2(1120.0, 0.0)
		bar.size = Vector2(160.0, 720.0)
		bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
		hud_root.add_child(bar)

	p1_status = _hud_label(Vector2(178.0, 20.0), Vector2(350.0, 72.0), 20, Color("#f15b62"))
	p2_status = _hud_label(Vector2(752.0, 20.0), Vector2(350.0, 72.0), 20, Color("#63bfff"))
	p2_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	chapter_label = _hud_label(Vector2(420.0, 18.0), Vector2(440.0, 32.0), 17, Color("#d9c08b"))
	chapter_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label = _hud_label(Vector2(330.0, 84.0), Vector2(620.0, 48.0), 16, Color.WHITE)
	objective_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	route_label = _hud_label(Vector2(174.0, 676.0), Vector2(932.0, 24.0), 13, Color(0.6, 0.64, 0.65))
	route_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var subtitle_panel := PanelContainer.new()
	subtitle_panel.position = Vector2(280.0, 575.0)
	subtitle_panel.size = Vector2(720.0, 72.0)
	var subtitle_style := StyleBoxFlat.new()
	subtitle_style.bg_color = Color(0.0, 0.0, 0.0, 0.78)
	subtitle_style.content_margin_left = 16.0
	subtitle_style.content_margin_right = 16.0
	subtitle_style.content_margin_top = 10.0
	subtitle_style.content_margin_bottom = 10.0
	subtitle_panel.add_theme_stylebox_override("panel", subtitle_style)
	hud_root.add_child(subtitle_panel)
	subtitle_label = Label.new()
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	subtitle_label.add_theme_font_size_override("font_size", 17)
	subtitle_panel.add_child(subtitle_label)
	subtitle_panel.visible = false
	subtitle_label.set_meta("panel", subtitle_panel)

	boss_panel = PanelContainer.new()
	boss_panel.position = Vector2(375.0, 126.0)
	boss_panel.size = Vector2(530.0, 74.0)
	hud_root.add_child(boss_panel)
	var boss_box := VBoxContainer.new()
	boss_panel.add_child(boss_box)
	boss_name_label = Label.new()
	boss_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_name_label.add_theme_font_size_override("font_size", 16)
	boss_box.add_child(boss_name_label)
	boss_health_bar = ProgressBar.new()
	boss_health_bar.show_percentage = false
	boss_health_bar.custom_minimum_size.y = 17.0
	boss_box.add_child(boss_health_bar)
	boss_weak_label = Label.new()
	boss_weak_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	boss_weak_label.add_theme_font_size_override("font_size", 12)
	boss_box.add_child(boss_weak_label)
	boss_panel.visible = false

	center_overlay = PanelContainer.new()
	center_overlay.position = Vector2(295.0, 226.0)
	center_overlay.size = Vector2(690.0, 250.0)
	var center_style := StyleBoxFlat.new()
	center_style.bg_color = Color(0.005, 0.009, 0.014, 0.94)
	center_style.border_color = Color("#8c6f3e")
	center_style.set_border_width_all(1)
	center_style.content_margin_left = 38.0
	center_style.content_margin_right = 38.0
	center_style.content_margin_top = 28.0
	center_style.content_margin_bottom = 28.0
	center_overlay.add_theme_stylebox_override("panel", center_style)
	hud_root.add_child(center_overlay)
	var center_box := VBoxContainer.new()
	center_box.alignment = BoxContainer.ALIGNMENT_CENTER
	center_overlay.add_child(center_box)
	center_title = Label.new()
	center_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_title.add_theme_font_size_override("font_size", 34)
	center_title.add_theme_color_override("font_color", Color("#e8d7ad"))
	center_box.add_child(center_title)
	center_body = Label.new()
	center_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	center_body.add_theme_font_size_override("font_size", 17)
	center_box.add_child(center_body)
	center_overlay.visible = false

	for index in 2:
		var crosshair := CrosshairControlScript.new()
		crosshair.name = "CrosshairP%d" % (index + 1)
		crosshair.player_color = Color("#ef3340") if index == 0 else Color("#35a9ff")
		crosshair.size = Vector2(52.0, 52.0)
		hud_root.add_child(crosshair)
		crosshairs.append(crosshair)

	flash_rect = ColorRect.new()
	flash_rect.color = Color(1.0, 0.9, 0.68, 0.0)
	flash_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(flash_rect)

	score_feed = VBoxContainer.new()
	score_feed.position = Vector2(904.0, 500.0)
	score_feed.size = Vector2(196.0, 110.0)
	score_feed.alignment = BoxContainer.ALIGNMENT_END
	hud_root.add_child(score_feed)


func _hud_label(at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(label)
	return label


func _update_play_rect() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if bool(configuration.get("authentic_ratio", true)):
		var width := minf(viewport_size.x, viewport_size.y * 4.0 / 3.0)
		active_play_rect = Rect2(Vector2((viewport_size.x - width) * 0.5, 0.0), Vector2(width, viewport_size.y))
	else:
		active_play_rect = Rect2(Vector2.ZERO, viewport_size)
	var left_bar := hud_root.get_node_or_null("Pillar_left") as ColorRect
	var right_bar := hud_root.get_node_or_null("Pillar_right") as ColorRect
	if left_bar != null and right_bar != null:
		left_bar.visible = bool(configuration.get("authentic_ratio", true))
		right_bar.visible = bool(configuration.get("authentic_ratio", true))
		left_bar.position = Vector2.ZERO
		left_bar.size = Vector2(active_play_rect.position.x, viewport_size.y)
		right_bar.position = Vector2(active_play_rect.end.x, 0.0)
		right_bar.size = Vector2(maxf(0.0, viewport_size.x - active_play_rect.end.x), viewport_size.y)

# Virtual contract implemented by the specialized runtime layers.
func _show_overlay(_title: String, _body: String, _duration: float) -> void:
	pass

func _begin_chapter(_index: int) -> void:
	pass

func _update_node(_delta: float) -> void:
	pass

func _update_boss(_delta: float) -> void:
	pass

func _update_continue(_delta: float) -> void:
	pass

func _update_demo(_delta: float) -> void:
	pass

func _update_hud() -> void:
	pass

func _update_camera_rail(_delta: float) -> void:
	pass

func _update_actors(_delta: float) -> void:
	pass

func _attempt_shot(_player_index: int, _screen_position: Vector2) -> void:
	pass

func _reload(_player_index: int) -> void:
	pass

func _accept_continue() -> void:
	pass

func _feed(_message: String, _color: Color) -> void:
	pass

func _begin_credits() -> void:
	pass

func _clear_actors() -> void:
	pass

func _build_environment(_style: String) -> void:
	pass

func _set_subtitle(_text_value: String, _duration: float) -> void:
	pass

func _spawn_civilian(_data: Dictionary) -> void:
	pass

func _spawn_breakable(_data: Dictionary) -> void:
	pass

func _start_boss(_boss_id: String) -> void:
	pass

func _spawn_enemy(_spawn: Dictionary) -> Node3D:
	return null

func _has_active_hostiles() -> bool:
	return false

func _rescue_civilian(_civilian: Node3D) -> void:
	pass

func _combined_score() -> int:
	return 0

func _resolve_ending(_short_result: bool) -> void:
	pass

func _start_continue(_player_index: int) -> void:
	pass

func _persist_chapter_progress() -> void:
	pass
