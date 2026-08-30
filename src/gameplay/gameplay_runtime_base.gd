class_name GameplayController
extends Node3D

signal exit_requested

const CrosshairControlScript := preload("res://src/ui/crosshair_control.gd")
const UITextSanitizerScript := preload("res://src/ui/ui_text_sanitizer.gd")
const ProceduralSfxScript := preload("res://src/audio/procedural_sfx.gd")
const AudioCueLibraryScript := preload("res://src/audio/audio_cue_library.gd")
const SpriteAtlasLibraryScript := preload("res://src/gameplay/sprite_atlas_library.gd")
const SpriteClipLibraryV3Script := preload("res://src/gameplay/sprite_clip_library_v3.gd")
const DirectionalClipPlayerV3Script := preload("res://src/gameplay/directional_clip_player_v3.gd")
const DirectionalSpriteResolverScript := preload("res://src/gameplay/directional_sprite_resolver.gd")
const EnvironmentAssetLibraryScript := preload("res://src/gameplay/environment_asset_library.gd")
const GameplaySupportLibraryScript := preload("res://src/gameplay/gameplay_support_library.gd")
const EnemyProfileLibraryScript := preload("res://src/gameplay/enemy_profile_library.gd")
const CAMPAIGN_PATH := "res://data/runtime/campaign_timeline.json"
const SPRITE_MANIFEST_PATH := "res://data/assets/sprite_manifest.json"
const SPRITE_MANIFEST_V3_PATH := "res://data/assets/sprite_manifest_v3.json"
const ENVIRONMENT_MANIFEST_PATH := "res://data/assets/environment_manifest.json"
const GAMEPLAY_SUPPORT_MANIFEST_PATH := "res://data/assets/gameplay_support_manifest.json"
const AUDIO_CUE_MANIFEST_PATH := "res://data/audio/audio_cues.json"
const QA_SCORE_DEV_PATH := "res://logs/score/score_qa.jsonl"
const QA_SCORE_EXPORT_PATH := "user://score_qa.jsonl"
const MAGAZINE_SIZE := 6

const ACTOR_STATS := {
	# Canonical arcade roster. Until a licensed atlas exists for every type, each
	# entry explicitly reuses one of the project's fan-made sheets and applies a
	# stable tint/scale silhouette treatment. Gameplay identity is driven by data.
	"sam_a1": {"health": 3.0, "speed": 1.0, "scale": 1.0, "score": 80, "behavior": "walk", "tint": "#ffffff", "attack_period": 1.8},
	"neil_a2": {"health": 3.0, "speed": 0.9, "scale": 0.96, "score": 80, "behavior": "walk", "tint": "#c7d6b9", "attack_period": 1.9},
	"cyril_a3": {"health": 4.0, "speed": 1.26, "scale": 1.05, "score": 80, "behavior": "throw_projectile", "projectile_asset": "thrown_axe", "projectile_speed": 4.0, "tint": "#c6a69c", "attack_period": 1.55},
	"kageo_b1": {"health": 2.0, "speed": 1.15, "scale": 0.93, "score": 80, "behavior": "ceiling_drop", "tint": "#8f9da7", "drop_height": 4.4, "drop_duration": 1.25, "attack_period": 1.7},
	"bourbon_b2": {"health": 6.0, "speed": 0.64, "scale": 1.18, "score": 80, "behavior": "heavy_weapon", "tint": "#ba916e", "armor_zones": ["torso"], "armor_durability": 2.0, "attack_period": 2.35},
	"ebitan_a_b3": {"health": 2.0, "speed": 1.48, "scale": 0.58, "score": 80, "behavior": "aquatic_weave", "tint": "#91b9a9", "weave_width": 1.25, "attack_period": 1.65},
	"ebitan_b_b4": {"health": 3.0, "speed": 1.62, "scale": 0.64, "score": 80, "behavior": "aquatic_weave", "tint": "#6f9aa7", "weave_width": 1.65, "attack_period": 1.5},
	"samson_c1": {"health": 6.0, "speed": 0.58, "scale": 1.22, "score": 80, "behavior": "heavy_weapon", "tint": "#9d7b6d", "attack_period": 2.5},
	"bentley_c2": {"health": 7.0, "speed": 0.52, "scale": 1.28, "score": 80, "behavior": "throw_projectile", "projectile_asset": "thrown_barrel", "projectile_speed": 3.25, "tint": "#788a8e", "armor_zones": ["head", "torso"], "armor_durability": 4.0, "attack_period": 2.2},
	"burner_c3": {"health": 5.0, "speed": 0.72, "scale": 1.14, "score": 80, "behavior": "heavy_weapon", "tint": "#b57a56", "attack_period": 2.25},
	"simon_d1": {"health": 3.0, "speed": 1.18, "scale": 0.96, "score": 80, "behavior": "throw_projectile", "projectile_asset": "thrown_barrel", "projectile_speed": 3.4, "tint": "#a0b0a0", "attack_period": 1.7},
	"gilmore_d2": {"health": 4.0, "speed": 1.42, "scale": 1.04, "score": 80, "behavior": "heavy_weapon", "tint": "#c98f83", "attack_period": 1.45},
	"harris_d3": {"health": 3.0, "speed": 0.92, "scale": 0.78, "score": 80, "behavior": "heavy_weapon", "tint": "#d4c18d", "attack_period": 2.0},
	"robert_d4": {"health": 6.0, "speed": 0.66, "scale": 1.2, "score": 80, "behavior": "heavy_weapon", "tint": "#8d766b", "armor_zones": ["torso"], "armor_durability": 3.0, "attack_period": 2.3},
	"rubin_e1": {"health": 3.0, "speed": 1.3, "scale": 0.94, "score": 80, "behavior": "jump", "tint": "#b39e87", "jump_height": 1.55, "attack_period": 1.55},
	"drake_e2": {"health": 3.0, "speed": 0.9, "scale": 0.82, "score": 80, "behavior": "throw_projectile", "tint": "#9aa5bf", "projectile_asset": "thrown_dagger", "projectile_speed": 4.5, "attack_period": 1.85},
	"moody_e3": {"health": 3.0, "speed": 1.08, "scale": 0.91, "score": 80, "behavior": "throw_projectile", "tint": "#879286", "projectile_asset": "iron_claw", "projectile_speed": 4.15, "attack_period": 1.6},
	"parlor_e4": {"health": 4.0, "speed": 1.55, "scale": 1.0, "score": 80, "behavior": "throw_projectile", "tint": "#aa8179", "projectile_asset": "thrown_dagger", "projectile_speed": 4.65, "attack_period": 1.35},
	"kenfis_f1": {"health": 2.0, "speed": 1.3, "scale": 0.74, "score": 80, "behavior": "jump", "tint": "#ffffff", "jump_height": 1.0, "attack_period": 1.7},
	"saruzou_f2": {"health": 2.0, "speed": 1.34, "scale": 0.7, "score": 80, "behavior": "ceiling_drop", "tint": "#b4ac91", "drop_height": 4.7, "drop_duration": 0.82, "attack_period": 1.5},
	"bouere_f3": {"health": 2.0, "speed": 1.72, "scale": 0.6, "score": 80, "behavior": "jump", "tint": "#8da899", "jump_height": 1.35, "attack_period": 1.4},
	"devilon_f4": {"health": 1.0, "speed": 2.0, "scale": 0.52, "score": 80, "behavior": "flight_swarm", "tint": "#a391b7", "weave_width": 1.0, "attack_period": 1.25},
	"murrer_g1": {"health": 1.0, "speed": 2.15, "scale": 0.4, "score": 80, "behavior": "flight_swarm", "tint": "#9ca788", "weave_width": 1.4, "attack_period": 1.2},
	"name_g2": {"health": 2.0, "speed": 1.65, "scale": 0.62, "score": 80, "behavior": "throw_projectile", "projectile_asset": "organic_spit", "projectile_speed": 4.0, "tint": "#ffffff", "weave_width": 1.1, "attack_period": 1.55},
	"taran_g3": {"health": 4.0, "speed": 1.1, "scale": 0.86, "score": 80, "behavior": "ceiling_drop", "tint": "#657f78", "drop_height": 4.8, "drop_duration": 0.9, "attack_period": 1.85},
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
var connector_root: Node3D
var actor_root: Node3D
var fx_root: Node3D
var active_actors: Array[Node3D] = []
var active_civilian: Node3D
var rail_origin := Vector3(0.0, 1.7, 8.0)
var rail_target := Vector3(0.0, 1.55, 4.5)
var rail_duration: float = 8.0
var environment_origin := Vector3.ZERO
var pending_environment_origin := Vector3.ZERO

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
var boss_weakpoint_texture: TextureRect
var reload_icon: TextureRect
var life_icon_rows: Array = [[], []]
var bullet_icon_rows: Array = [[], []]
var torch_frames: Array[Texture2D] = []
var center_overlay: PanelContainer
var center_title: Label
var center_body: Label
var crosshairs: Array[Control] = []
var flash_rect: ColorRect
var score_feed: VBoxContainer
var audio_players: Dictionary = {}
var ambience_audio_player: AudioStreamPlayer
var music_audio_player: AudioStreamPlayer
var voice_audio_player: AudioStreamPlayer
var active_ambience_cue: String = ""
var active_music_cue: String = ""
var last_subtitle_audio_text: String = ""
var last_subtitle_audio_msec: int = 0
var qa_score_log_error_reported: bool = false
var sprite_atlas_library = SpriteAtlasLibraryScript.new()
var sprite_clip_library_v3 = SpriteClipLibraryV3Script.new()
var directional_sprite_resolver = DirectionalSpriteResolverScript.new()
var environment_asset_library = EnvironmentAssetLibraryScript.new()
var gameplay_support_library = GameplaySupportLibraryScript.new()
var enemy_profile_library = EnemyProfileLibraryScript.new()
var audio_cue_library = AudioCueLibraryScript.new()
var environment_scene_profile: Dictionary = {}
var destroyed_breakable_id: String = ""
var route_condition_context: Dictionary = {}


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


func _exit_tree() -> void:
	_release_audio_resources()


func _release_audio_resources() -> void:
	for player_value in audio_players.values():
		var player := player_value as AudioStreamPlayer
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	audio_players.clear()
	for player_value in [ambience_audio_player, music_audio_player, voice_audio_player]:
		var player := player_value as AudioStreamPlayer
		if is_instance_valid(player):
			player.stop()
			player.stream = null
	active_ambience_cue = ""
	active_music_cue = ""
	audio_cue_library.clear_cache()


func _start_session() -> void:
	if session_started:
		return
	session_started = true
	if not _load_sprite_manifest():
		session_started = false
		return
	if not _load_visual_support_manifests():
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
	# V3 is a non-destructive sidecar. It is validated on every session, but an
	# invalid or incomplete V3 profile can never prevent the verified V2 actor
	# from loading. Runtime activation remains actor-atomic: all required clips
	# must pass before a future presentation player may select that profile.
	if not sprite_clip_library_v3.load_manifest(SPRITE_MANIFEST_V3_PATH):
		push_warning("Sprite V3 sidecar rejected; retaining V2 actors: %s" % sprite_clip_library_v3.last_error)
	directional_sprite_resolver.direction_count = 8
	directional_sprite_resolver.frames_per_direction = 8
	directional_sprite_resolver.direction_hysteresis_degrees = 3.0
	directional_sprite_resolver.mirror_symmetric_directions = false
	directional_sprite_resolver.direction_order.assign([0, 1, 2, 3, 4, 5, 6, 7])
	return true


func _load_visual_support_manifests() -> bool:
	if not environment_asset_library.load_manifest(ENVIRONMENT_MANIFEST_PATH):
		push_error(environment_asset_library.last_error)
		return false
	if not gameplay_support_library.load_manifest(GAMEPLAY_SUPPORT_MANIFEST_PATH):
		push_error(gameplay_support_library.last_error)
		return false
	if not enemy_profile_library.load_profiles():
		push_error(enemy_profile_library.last_error)
		return false
	_configure_support_hud_assets()
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
	var has_v3_profile := sprite_clip_library_v3.has_actor(actor_id)
	sprite.set_meta("v3_profile_present", has_v3_profile)
	sprite.set_meta("v3_profile_ready", has_v3_profile and sprite_clip_library_v3.is_runtime_ready(actor_id))
	sprite.set_meta(
		"v3_fallback_reason",
		sprite_clip_library_v3.fallback_reason(actor_id) if has_v3_profile else "v3_profile_not_authored"
	)
	if has_v3_profile and sprite_clip_library_v3.is_runtime_ready(actor_id):
		var idle_definition := _sprite_v3_clip_definition(actor_id, "idle")
		var clip_player = DirectionalClipPlayerV3Script.new()
		if not idle_definition.is_empty() and clip_player.configure(sprite, idle_definition):
			sprite.set_meta("directional_clip_player_v3", clip_player)
			sprite.set_meta("v3_actor_id", actor_id)
			sprite.set_meta("v3_fallback_reason", "")
		else:
			sprite.set_meta("v3_profile_ready", false)
			sprite.set_meta(
				"v3_fallback_reason",
				"runtime_configuration_failed:%s" % str(clip_player.last_error)
			)
	return true


func _sprite_v3_clip_definition(actor_id: String, clip_id: String) -> Dictionary:
	var clip := sprite_clip_library_v3.get_clip(actor_id, clip_id)
	if clip.is_empty():
		return {}
	var texture_path := str(clip.get("path", ""))
	var texture := load(texture_path) as Texture2D
	if texture == null:
		push_warning("Sprite V3 clip texture failed to load: %s/%s (%s)" % [actor_id, clip_id, texture_path])
		return {}
	clip["id"] = StringName(clip_id)
	clip["texture"] = texture
	return clip


func _play_actor_v3_clip(actor: Node3D, clip_id: String, restart: bool = true) -> bool:
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null or not sprite.has_meta("directional_clip_player_v3"):
		return false
	var clip_player = sprite.get_meta("directional_clip_player_v3")
	var actor_id := str(sprite.get_meta("v3_actor_id", actor.get_meta("actor_id", "")))
	var definition := _sprite_v3_clip_definition(actor_id, clip_id)
	if definition.is_empty() or not clip_player.play_clip(definition, restart):
		push_warning("Sprite V3 clip switch failed: %s/%s (%s)" % [actor_id, clip_id, str(clip_player.last_error)])
		return false
	return true


func _apply_directional_sprite_frame(actor: Node3D, local_frame: int) -> int:
	var sprite := actor.get_node_or_null("Sprite3D") as Sprite3D
	if sprite == null:
		return -1
	var actor_forward := actor.get_meta("visual_forward", Vector3.BACK) as Vector3
	var camera_position := actor.global_position - actor_forward
	if camera_3d != null:
		camera_position = camera_3d.global_position
	if sprite.has_meta("directional_clip_player_v3"):
		var clip_player = sprite.get_meta("directional_clip_player_v3")
		var semantic_frame := clampi(local_frame, 0, 7)
		var clip_id := "idle"
		var clip_frame := 0
		match semantic_frame:
			1, 2, 3:
				clip_id = "locomotion"
				clip_frame = [0, 3, 6][semantic_frame - 1]
			4, 5:
				clip_id = "attack"
				clip_frame = 2 if semantic_frame == 4 else 5
			6:
				clip_id = "hit_recoil"
				clip_frame = 3
			7:
				clip_id = "death_fall"
				clip_frame = 7
		if str(clip_player.current_clip_id) != clip_id and not _play_actor_v3_clip(actor, clip_id):
			return -1
		if not clip_player.seek(clampi(clip_frame, 0, clip_player.frame_count - 1)):
			return -1
		var v3_direction: int = clip_player.update_view(actor_forward, camera_position, actor.global_position)
		if v3_direction >= 0:
			actor.set_meta("direction_index", v3_direction)
		return v3_direction
	var previous_direction := int(actor.get_meta("direction_index", -1))
	var resolved_direction := directional_sprite_resolver.apply_to_sprite(
		sprite,
		actor_forward,
		camera_position,
		actor.global_position,
		clampi(local_frame, 0, 7),
		previous_direction
	)
	if resolved_direction >= 0:
		actor.set_meta("direction_index", resolved_direction)
	return resolved_direction


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
	connector_root = Node3D.new()
	connector_root.name = "SequenceConnector"
	add_child(connector_root)
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
	audio_players.clear()
	ambience_audio_player = _create_audio_player("AmbienceLoop", &"Ambience")
	music_audio_player = _create_audio_player("ChapterMusic", &"Music")
	voice_audio_player = _create_audio_player("SubtitleRadioPunctuation", &"Voice")
	voice_audio_player.set_meta("provenance", "original_non_intelligible_placeholder")
	if not audio_cue_library.load_manifest(AUDIO_CUE_MANIFEST_PATH):
		push_warning("Procedural gameplay audio manifest unavailable: %s" % str(audio_cue_library.last_error))
		_build_fallback_effect_audio()
		return
	var effect_cues: Array[String] = [
		"shot",
		"reload",
		"empty",
		"hit",
		"rescue",
		"danger",
		"boss_telegraph",
		"boss_projectile",
		"boss_web_projectile",
		"projectile_intercept"
	]
	for cue_id: String in effect_cues:
		if not audio_cue_library.has_cue(cue_id):
			push_warning("Gameplay audio cue is missing: %s" % cue_id)
			continue
		var player := _create_audio_player("Sfx_%s" % cue_id, &"Effects")
		player.stream = audio_cue_library.build_stream(cue_id)
		audio_players[cue_id] = player


func _create_audio_player(player_name: String, bus_name: StringName) -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	player.name = player_name
	player.bus = bus_name
	add_child(player)
	return player


func _build_fallback_effect_audio() -> void:
	var definitions := {
		"shot": ProceduralSfxScript.tone(126.0, 0.12, 0.55, 22.0, 0.68),
		"reload": ProceduralSfxScript.tone(740.0, 0.14, 0.22, 7.0, 0.15),
		"empty": ProceduralSfxScript.tone(980.0, 0.05, 0.12, 16.0, 0.0),
		"hit": ProceduralSfxScript.tone(64.0, 0.11, 0.4, 20.0, 0.75),
		"rescue": ProceduralSfxScript.tone(880.0, 0.28, 0.16, 3.2, 0.0),
		"danger": ProceduralSfxScript.tone(48.0, 0.36, 0.18, 2.0, 0.32)
	}
	for key: String in definitions:
		var player := _create_audio_player("Fallback_%s" % key, &"Effects")
		player.stream = definitions[key] as AudioStream
		audio_players[key] = player


func _play_sfx(key: String) -> void:
	if not audio_players.has(key):
		return
	var player := audio_players[key] as AudioStreamPlayer
	if player == null or player.stream == null:
		return
	player.stop()
	player.play()


func _play_audio_cue(player: AudioStreamPlayer, cue_id: String) -> bool:
	if player == null or not audio_cue_library.has_cue(cue_id):
		return false
	var stream: AudioStreamWAV = audio_cue_library.build_stream(cue_id)
	if stream == null:
		return false
	player.stop()
	player.stream = stream
	player.play()
	return true


func _set_ambience_for_style(style: String) -> void:
	var cue_id := str({
		"garden": "ambience_garden",
		"mansion": "ambience_mansion",
		"sewer": "ambience_sewer",
		"roof": "ambience_roof",
		"laboratory": "ambience_laboratory"
	}.get(style, "ambience_mansion"))
	if cue_id == active_ambience_cue and ambience_audio_player != null and ambience_audio_player.playing:
		return
	if _play_audio_cue(ambience_audio_player, cue_id):
		active_ambience_cue = cue_id


func _set_music_for_chapter(index: int) -> void:
	var cue_id := "music_chapter_%02d" % clampi(index + 1, 1, 4)
	if cue_id == active_music_cue and music_audio_player != null and music_audio_player.playing:
		return
	if _play_audio_cue(music_audio_player, cue_id):
		active_music_cue = cue_id


func _set_music_for_boss(boss_id: String) -> void:
	var chapter_for_boss := int({
		"chariot": 0,
		"hangedman": 1,
		"hermit": 2,
		"magician": 3
	}.get(boss_id, 3))
	_set_music_for_chapter(chapter_for_boss)


func _play_subtitle_punctuation(text_value: String) -> void:
	var normalized := text_value.strip_edges().to_lower()
	if normalized.is_empty() or voice_audio_player == null:
		return
	var now := Time.get_ticks_msec()
	if normalized == last_subtitle_audio_text and now - last_subtitle_audio_msec < 750:
		return
	var cue_id := "voice_radio_rogan"
	if "curien" in normalized or "masterpiece" in normalized or "magician" in normalized:
		cue_id = "voice_radio_curien"
	elif "help" in normalized or "human" in normalized or "scientist" in normalized or "sophie" in normalized or "rogan!" in normalized:
		cue_id = "voice_radio_scientist"
	elif "aim" in normalized or "fire" in normalized or "shoot" in normalized or "switch" in normalized or "vulnerable" in normalized or "type " in normalized:
		cue_id = "voice_radio_g"
	if _play_audio_cue(voice_audio_player, cue_id):
		last_subtitle_audio_text = normalized
		last_subtitle_audio_msec = now


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
	boss_panel.position = Vector2(340.0, 126.0)
	boss_panel.size = Vector2(600.0, 104.0)
	hud_root.add_child(boss_panel)
	var boss_row := HBoxContainer.new()
	boss_row.add_theme_constant_override("separation", 12)
	boss_panel.add_child(boss_row)
	boss_weakpoint_texture = TextureRect.new()
	boss_weakpoint_texture.custom_minimum_size = Vector2(86.0, 86.0)
	boss_weakpoint_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	boss_weakpoint_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	boss_weakpoint_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	boss_row.add_child(boss_weakpoint_texture)
	var boss_box := VBoxContainer.new()
	boss_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boss_row.add_child(boss_box)
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


	_build_player_icon_rows()
	reload_icon = TextureRect.new()
	reload_icon.name = "ReloadOffscreenIcon"
	reload_icon.position = Vector2(592.0, 488.0)
	reload_icon.size = Vector2(96.0, 96.0)
	reload_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	reload_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	reload_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	reload_icon.visible = false
	hud_root.add_child(reload_icon)

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


func _build_player_icon_rows() -> void:
	for player_index in 2:
		var life_row := HBoxContainer.new()
		life_row.name = "LifeIconsP%d" % (player_index + 1)
		life_row.position = Vector2(178.0, 64.0) if player_index == 0 else Vector2(938.0, 64.0)
		life_row.size = Vector2(138.0, 28.0)
		life_row.add_theme_constant_override("separation", 0)
		hud_root.add_child(life_row)
		var life_icons: Array = []
		for _icon_index in 5:
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(26.0, 26.0)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			life_row.add_child(icon)
			life_icons.append(icon)
		life_icon_rows[player_index] = life_icons

		var bullet_row := HBoxContainer.new()
		bullet_row.name = "AmmoIconsP%d" % (player_index + 1)
		bullet_row.position = Vector2(324.0, 67.0) if player_index == 0 else Vector2(794.0, 67.0)
		bullet_row.size = Vector2(126.0, 22.0)
		bullet_row.add_theme_constant_override("separation", -1)
		hud_root.add_child(bullet_row)
		var bullet_icons: Array = []
		for _icon_index in MAGAZINE_SIZE:
			var icon := TextureRect.new()
			icon.custom_minimum_size = Vector2(20.0, 20.0)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
			bullet_row.add_child(icon)
			bullet_icons.append(icon)
		bullet_icon_rows[player_index] = bullet_icons


func _configure_support_hud_assets() -> void:
	torch_frames.clear()
	var torch_profile := gameplay_support_library.get_ui("life_torch")
	var torch_texture := gameplay_support_library.load_texture(torch_profile)
	if torch_texture != null:
		var frame_count := maxi(1, int(torch_profile.get("hframes", 8)))
		var frame_width := torch_texture.get_width() / frame_count
		for frame_index in frame_count:
			var frame_texture := AtlasTexture.new()
			frame_texture.atlas = torch_texture
			frame_texture.region = Rect2(frame_width * frame_index, 0.0, frame_width, torch_texture.get_height())
			torch_frames.append(frame_texture)
	var bullet_texture := gameplay_support_library.load_texture(gameplay_support_library.get_ui("bullet_round"))
	for row_value in bullet_icon_rows:
		for icon_value in row_value as Array:
			(icon_value as TextureRect).texture = bullet_texture
	if reload_icon != null:
		reload_icon.texture = gameplay_support_library.load_texture(gameplay_support_library.get_ui("reload_offscreen_icon"))


func _update_support_hud() -> void:
	if players.size() < 2:
		return
	var torch_frame := 0
	if not torch_frames.is_empty():
		torch_frame = int(Time.get_ticks_msec() / 110) % torch_frames.size()
	for player_index in 2:
		var active := bool(players[player_index].active)
		var lives := int(players[player_index].lives)
		var ammo := int(players[player_index].ammo)
		var life_icons := life_icon_rows[player_index] as Array
		for icon_index in life_icons.size():
			var icon := life_icons[icon_index] as TextureRect
			icon.visible = active and icon_index < lives
			if not torch_frames.is_empty():
				icon.texture = torch_frames[torch_frame]
		var bullet_icons := bullet_icon_rows[player_index] as Array
		for icon_index in bullet_icons.size():
			var icon := bullet_icons[icon_index] as TextureRect
			icon.visible = active
			icon.modulate = Color.WHITE if icon_index < ammo else Color(0.18, 0.2, 0.22, 0.36)
	if reload_icon != null:
		var needs_reload := false
		for player: Dictionary in players:
			needs_reload = needs_reload or (bool(player.active) and int(player.ammo) <= 0)
		reload_icon.visible = needs_reload and state in ["node", "boss"]
		if reload_icon.visible:
			reload_icon.modulate.a = 0.58 + sin(Time.get_ticks_msec() * 0.012) * 0.32


func _hud_label(at: Vector2, dimensions: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.position = at
	label.size = dimensions
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud_root.add_child(label)
	return label


func _safe_ui_text(text_value: String) -> String:
	return UITextSanitizerScript.sanitize(text_value)


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

func _build_sequence_connector(_from_pose: Dictionary, _to_pose: Dictionary, _next_profile: Dictionary) -> void:
	pass

func _clear_sequence_connector() -> void:
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
