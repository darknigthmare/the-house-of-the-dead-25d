extends Node

signal settings_changed(key: String, value: Variant)

const DEFAULTS := {
	"language": "fr",
	"authentic_ratio": true,
	"master_volume": 0.8,
	"music_volume": 0.7,
	"voice_volume": 0.8,
	"effects_volume": 0.85,
	"interface_volume": 0.8,
	"ambience_volume": 0.75,
	"reduced_flashes": false,
	"reduced_shake": false,
	"crosshair_scale": 1.0,
	"blood_level": 2,
	"dismemberment": true,
	"aim_assist": 0.0,
	"button_reload": true,
	"pixel_filter": "sharp"
}

const AUDIO_BUS_SETTINGS := {
	"Music": "music_volume",
	"Voice": "voice_volume",
	"Effects": "effects_volume",
	"Interface": "interface_volume",
	"Ambience": "ambience_volume"
}

var values: Dictionary = DEFAULTS.duplicate(true)


func reset_defaults() -> void:
	values = DEFAULTS.duplicate(true)
	_apply_runtime_settings()


func set_value(key: String, value: Variant) -> bool:
	if not DEFAULTS.has(key):
		return false
	var normalized: Variant = _normalize_value(key, value)
	if normalized == null:
		return false
	values[key] = normalized
	_apply_runtime_settings()
	settings_changed.emit(key, normalized)
	return true


func get_value(key: String, fallback: Variant = null) -> Variant:
	return values.get(key, fallback)


func load_dictionary(data: Dictionary) -> void:
	values = DEFAULTS.duplicate(true)
	for key in DEFAULTS:
		if data.has(key):
			var normalized: Variant = _normalize_value(str(key), data[key])
			if normalized != null:
				values[key] = normalized
	_apply_runtime_settings()


func export_dictionary() -> Dictionary:
	return values.duplicate(true)


func _normalize_value(key: String, value: Variant) -> Variant:
	match key:
		"language":
			var locale := str(value).to_lower()
			return locale if locale in ["fr", "en"] else null
		"authentic_ratio", "reduced_flashes", "reduced_shake", "dismemberment", "button_reload":
			return value if typeof(value) == TYPE_BOOL else null
		"master_volume", "music_volume", "voice_volume", "effects_volume", "interface_volume", "ambience_volume", "aim_assist":
			return clampf(float(value), 0.0, 1.0) if typeof(value) in [TYPE_INT, TYPE_FLOAT] else null
		"crosshair_scale":
			return clampf(float(value), 0.6, 1.8) if typeof(value) in [TYPE_INT, TYPE_FLOAT] else null
		"blood_level":
			return clampi(int(value), 0, 2) if typeof(value) in [TYPE_INT, TYPE_FLOAT] else null
		"pixel_filter":
			var filter_name := str(value)
			return filter_name if filter_name in ["sharp", "smooth"] else null
	return null


func _apply_runtime_settings() -> void:
	TranslationServer.set_locale(str(values.get("language", "fr")))
	_apply_audio()


func _apply_audio() -> void:
	var master_index := AudioServer.get_bus_index("Master")
	if master_index >= 0:
		_set_bus_volume(master_index, float(values.get("master_volume", 0.8)))
	for bus_name: String in AUDIO_BUS_SETTINGS:
		var bus_index := _ensure_audio_bus(bus_name)
		_set_bus_volume(bus_index, float(values.get(AUDIO_BUS_SETTINGS[bus_name], 1.0)))


func _ensure_audio_bus(bus_name: String) -> int:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		return bus_index
	AudioServer.add_bus()
	bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, bus_name)
	AudioServer.set_bus_send(bus_index, "Master")
	return bus_index


func _set_bus_volume(bus_index: int, linear: float) -> void:
	if bus_index < 0:
		return
	var clamped := clampf(linear, 0.0, 1.0)
	AudioServer.set_bus_mute(bus_index, clamped <= 0.0)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(maxf(clamped, 0.0001)))
