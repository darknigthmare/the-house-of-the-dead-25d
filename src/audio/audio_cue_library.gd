class_name AudioCueLibrary
extends RefCounted

const ProceduralSfxType := preload("res://src/audio/procedural_sfx.gd")
const DEFAULT_MANIFEST_PATH: String = "res://data/audio/audio_cues.json"
const ALLOWED_GENERATORS: Array[String] = [
	"tone",
	"gunshot",
	"reload",
	"dry_fire",
	"body_hit",
	"alarm",
	"ui_chime",
	"ui_click",
	"ambience_loop",
	"music_loop",
	"boss_telegraph",
	"projectile",
	"radio_chirp"
]

var last_error: String = ""
var manifest_path: String = ""
var mix_rate: int = ProceduralSfxType.DEFAULT_MIX_RATE
var provenance: Dictionary = {}
var _cues: Dictionary = {}
var _stream_cache: Dictionary = {}


func load_manifest(path: String = DEFAULT_MANIFEST_PATH) -> bool:
	last_error = ""
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return _fail("cannot open manifest: %s" % path)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return _fail("manifest root must be a dictionary")

	var candidate := parsed as Dictionary
	if int(candidate.get("schema_version", 0)) != 1:
		return _fail("unsupported schema_version")
	var candidate_rate := int(candidate.get("mix_rate", 0))
	if candidate_rate < 8_000 or candidate_rate > 48_000:
		return _fail("mix_rate must be between 8000 and 48000")
	var cues_value: Variant = candidate.get("cues", {})
	if typeof(cues_value) != TYPE_DICTIONARY or (cues_value as Dictionary).is_empty():
		return _fail("cues must be a non-empty dictionary")

	var validated: Dictionary = {}
	for cue_key: Variant in cues_value as Dictionary:
		var cue_id := str(cue_key)
		var definition_value: Variant = (cues_value as Dictionary).get(cue_key, {})
		if typeof(definition_value) != TYPE_DICTIONARY:
			return _fail("cue '%s' must be a dictionary" % cue_id)
		var definition := (definition_value as Dictionary).duplicate(true)
		if not _validate_definition(cue_id, definition):
			return false
		definition["mix_rate"] = candidate_rate
		validated[cue_id] = definition

	var provenance_value: Variant = candidate.get("provenance", {})
	if typeof(provenance_value) != TYPE_DICTIONARY:
		return _fail("provenance must be a dictionary")
	var candidate_provenance := (provenance_value as Dictionary).duplicate(true)
	if bool(candidate_provenance.get("licensed_reference_audio_used", true)):
		return _fail("temporary procedural manifest must not claim licensed reference audio")
	if bool(candidate_provenance.get("rom_or_video_audio_used", true)):
		return _fail("temporary procedural manifest must not contain ROM or video audio")

	manifest_path = path
	mix_rate = candidate_rate
	provenance = candidate_provenance
	_cues = validated
	_stream_cache.clear()
	return true


func has_cue(cue_id: String) -> bool:
	return _cues.has(cue_id)


func cue_ids() -> Array[String]:
	var result: Array[String] = []
	for cue_key: Variant in _cues:
		result.append(str(cue_key))
	result.sort()
	return result


func category_ids(category: String) -> Array[String]:
	var result: Array[String] = []
	for cue_id: String in cue_ids():
		var definition := _cues.get(cue_id, {}) as Dictionary
		if str(definition.get("category", "")) == category:
			result.append(cue_id)
	return result


func get_definition(cue_id: String) -> Dictionary:
	var definition_value: Variant = _cues.get(cue_id, {})
	if typeof(definition_value) != TYPE_DICTIONARY:
		return {}
	return (definition_value as Dictionary).duplicate(true)


func is_loop(cue_id: String) -> bool:
	return bool(get_definition(cue_id).get("loop", false))


func build_stream(cue_id: String) -> AudioStreamWAV:
	if _stream_cache.has(cue_id):
		return _stream_cache[cue_id] as AudioStreamWAV
	var definition := get_definition(cue_id)
	if definition.is_empty():
		last_error = "unknown cue: %s" % cue_id
		return null
	var stream: AudioStreamWAV = ProceduralSfxType.build_definition(definition, cue_id.hash())
	if stream == null:
		last_error = "failed to synthesize cue: %s" % cue_id
		return null
	_stream_cache[cue_id] = stream
	return stream


func clear_cache() -> void:
	_stream_cache.clear()


func _validate_definition(cue_id: String, definition: Dictionary) -> bool:
	if cue_id.is_empty():
		return _fail("cue id cannot be empty")
	var category := str(definition.get("category", ""))
	if category.is_empty():
		return _fail("cue '%s' is missing category" % cue_id)
	var generator := str(definition.get("generator", ""))
	if not ALLOWED_GENERATORS.has(generator):
		return _fail("cue '%s' uses unsupported generator '%s'" % [cue_id, generator])
	var duration := float(definition.get("duration", 0.0))
	if duration < 0.02 or duration > 16.0:
		return _fail("cue '%s' duration is outside 0.02..16 seconds" % cue_id)
	var channels := int(definition.get("channels", 0))
	if channels != 1 and channels != 2:
		return _fail("cue '%s' channels must be 1 or 2" % cue_id)
	var gain := float(definition.get("gain", -1.0))
	if gain < 0.0 or gain > 1.0:
		return _fail("cue '%s' gain must be within 0..1" % cue_id)
	var loops := bool(definition.get("loop", false))
	if (category == "ambience" or category == "music") and not loops:
		return _fail("cue '%s' must loop for category '%s'" % [cue_id, category])
	if category == "voice_placeholder" and not bool(definition.get("non_intelligible", false)):
		return _fail("voice placeholder '%s' must be declared non-intelligible" % cue_id)
	return true


func _fail(message: String) -> bool:
	last_error = message
	manifest_path = ""
	mix_rate = ProceduralSfxType.DEFAULT_MIX_RATE
	provenance.clear()
	_cues.clear()
	_stream_cache.clear()
	return false
