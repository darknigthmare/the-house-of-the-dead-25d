class_name AudioDirector
extends Node

signal cue_played(cue_id: StringName)
signal music_changed(stream: AudioStream)
signal voice_started(stream: AudioStream)
signal voice_finished

@export_category("Audio")
@export_range(1, 32, 1) var sfx_pool_size: int = 8
@export var music_bus: StringName = &"Music"
@export var sfx_bus: StringName = &"SFX"
@export var voice_bus: StringName = &"Voice"

var _cue_library: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer] = []
var _music_players: Array[AudioStreamPlayer] = []
var _music_index: int = 0
var _voice_player: AudioStreamPlayer


func _ready() -> void:
	_build_players()


func register_cue(
		cue_id: StringName,
		stream: AudioStream,
		volume_db: float = 0.0,
		pitch_scale: float = 1.0,
		bus: StringName = &""
) -> void:
	_cue_library[cue_id] = {
		"stream": stream,
		"volume_db": volume_db,
		"pitch_scale": pitch_scale,
		"bus": sfx_bus if bus == &"" else bus,
	}


func unregister_cue(cue_id: StringName) -> void:
	_cue_library.erase(cue_id)


func play_cue(cue_id: StringName, pitch_multiplier: float = 1.0) -> AudioStreamPlayer:
	if not _cue_library.has(cue_id):
		return null
	if _sfx_players.is_empty():
		_build_players()
	var player := _find_sfx_player()
	var definition := _cue_library[cue_id] as Dictionary
	player.stop()
	player.stream = definition.get("stream") as AudioStream
	player.bus = str(definition.get("bus", sfx_bus))
	player.volume_db = float(definition.get("volume_db", 0.0))
	player.pitch_scale = maxf(0.01, float(definition.get("pitch_scale", 1.0)) * pitch_multiplier)
	player.play()
	cue_played.emit(cue_id)
	return player


func play_music(stream: AudioStream, fade_seconds: float = 0.5) -> void:
	if stream == null:
		stop_music(fade_seconds)
		return
	if _music_players.is_empty():
		_build_players()
	var outgoing := _music_players[_music_index]
	_music_index = 1 - _music_index
	var incoming := _music_players[_music_index]
	incoming.stop()
	incoming.stream = stream
	incoming.bus = str(music_bus)
	incoming.volume_db = -60.0 if fade_seconds > 0.0 else 0.0
	incoming.play()
	if fade_seconds > 0.0:
		create_tween().tween_property(incoming, "volume_db", 0.0, fade_seconds)
		if outgoing.playing:
			var fade_out := create_tween()
			fade_out.tween_property(outgoing, "volume_db", -60.0, fade_seconds)
			fade_out.tween_callback(outgoing.stop)
	else:
		outgoing.stop()
	music_changed.emit(stream)


func stop_music(fade_seconds: float = 0.25) -> void:
	for player in _music_players:
		if not player.playing:
			continue
		if fade_seconds <= 0.0:
			player.stop()
		else:
			var tween := create_tween()
			tween.tween_property(player, "volume_db", -60.0, fade_seconds)
			tween.tween_callback(player.stop)


func play_voice(stream: AudioStream, volume_db: float = 0.0) -> void:
	if _voice_player == null:
		_build_players()
	_voice_player.stop()
	_voice_player.stream = stream
	_voice_player.volume_db = volume_db
	_voice_player.play()
	voice_started.emit(stream)


func stop_all() -> void:
	for player in _sfx_players:
		player.stop()
	for player in _music_players:
		player.stop()
	if _voice_player != null:
		_voice_player.stop()


func set_bus_volume(bus_name: StringName, volume_db: float) -> bool:
	var bus_index := AudioServer.get_bus_index(str(bus_name))
	if bus_index < 0:
		return false
	AudioServer.set_bus_volume_db(bus_index, volume_db)
	return true


func _build_players() -> void:
	if _sfx_players.is_empty():
		for index in maxi(1, sfx_pool_size):
			var sfx_player := AudioStreamPlayer.new()
			sfx_player.name = "SfxPlayer%d" % index
			sfx_player.bus = str(sfx_bus)
			add_child(sfx_player)
			_sfx_players.append(sfx_player)
	if _music_players.is_empty():
		for index in 2:
			var music_player := AudioStreamPlayer.new()
			music_player.name = "MusicPlayer%d" % index
			music_player.bus = str(music_bus)
			add_child(music_player)
			_music_players.append(music_player)
	if _voice_player == null:
		_voice_player = AudioStreamPlayer.new()
		_voice_player.name = "VoicePlayer"
		_voice_player.bus = str(voice_bus)
		add_child(_voice_player)
		_voice_player.finished.connect(voice_finished.emit)


func _find_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0]
