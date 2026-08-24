extends SceneTree

const ProceduralSfxType := preload("res://src/audio/procedural_sfx.gd")
const AudioCueLibraryType := preload("res://src/audio/audio_cue_library.gd")
const MANIFEST_PATH: String = "res://data/audio/audio_cues.json"
const REQUIRED_CUES: Array[String] = [
	"shot",
	"reload",
	"empty",
	"hit",
	"rescue",
	"danger",
	"ui_navigate",
	"ui_confirm",
	"ui_back",
	"ui_credit",
	"ui_join",
	"ambience_garden",
	"ambience_mansion",
	"ambience_sewer",
	"ambience_roof",
	"ambience_laboratory",
	"music_chapter_01",
	"music_chapter_02",
	"music_chapter_03",
	"music_chapter_04",
	"boss_telegraph",
	"boss_projectile",
	"boss_web_projectile",
	"projectile_intercept",
	"voice_radio_scientist",
	"voice_radio_rogan",
	"voice_radio_g",
	"voice_radio_curien"
]

var _assertions: int = 0
var _failures: int = 0


func _initialize() -> void:
	var library = AudioCueLibraryType.new()
	_expect_true(library.load_manifest(MANIFEST_PATH), "audio manifest loads: %s" % library.last_error)
	_expect_equal(library.cue_ids().size(), REQUIRED_CUES.size(), "manifest contains the complete temporary cue set")
	_expect_equal(library.category_ids("ambience").size(), 5, "five environment ambience loops exist")
	_expect_equal(library.category_ids("music").size(), 4, "four original chapter music loops exist")
	_expect_equal(library.category_ids("interface").size(), 5, "five interface cues exist")
	_expect_equal(library.category_ids("voice_placeholder").size(), 4, "four non-verbal radio placeholders exist")
	_expect_false(bool(library.provenance.get("licensed_reference_audio_used", true)), "manifest does not claim licensed audio")
	_expect_false(bool(library.provenance.get("rom_or_video_audio_used", true)), "manifest does not use ROM or video audio")

	var signatures: Dictionary = {}
	for cue_id: String in REQUIRED_CUES:
		_expect_true(library.has_cue(cue_id), "required cue is registered: %s" % cue_id)
		var definition: Dictionary = library.get_definition(cue_id)
		var stream: AudioStreamWAV = library.build_stream(cue_id)
		_expect_true(stream != null, "cue synthesizes: %s" % cue_id)
		if stream == null:
			continue
		_test_stream_contract(cue_id, definition, stream)
		var signature := _stream_signature(stream)
		_expect_false(signatures.has(signature), "cue waveform signature is distinct: %s" % cue_id)
		signatures[signature] = cue_id

	for voice_id: String in library.category_ids("voice_placeholder"):
		_expect_true(bool(library.get_definition(voice_id).get("non_intelligible", false)), "%s is explicitly non-intelligible" % voice_id)

	for deterministic_id: String in ["shot", "ambience_laboratory", "music_chapter_04", "voice_radio_curien"]:
		var first: AudioStreamWAV = library.build_stream(deterministic_id)
		library.clear_cache()
		var second: AudioStreamWAV = library.build_stream(deterministic_id)
		_expect_equal(first.data, second.data, "%s is deterministic across rebuilds" % deterministic_id)

	var compatibility_tone: AudioStreamWAV = ProceduralSfxType.tone(440.0, 0.1, 0.2, 5.0, 0.1)
	_expect_equal(compatibility_tone.mix_rate, 22_050, "legacy tone helper keeps the project mix rate")
	_expect_false(compatibility_tone.stereo, "legacy tone helper remains mono")
	_expect_equal(compatibility_tone.data.size(), 2 * 2_205, "legacy tone helper keeps exact frame count")

	if _failures == 0:
		print("PROCEDURAL AUDIO TEST PASSED: %d assertions, %d distinct cues" % [_assertions, signatures.size()])
		quit(0)
		return
	push_error("PROCEDURAL AUDIO TEST FAILED: %d/%d assertions failed" % [_failures, _assertions])
	quit(1)


func _test_stream_contract(cue_id: String, definition: Dictionary, stream: AudioStreamWAV) -> void:
	var channels := int(definition.get("channels", 1))
	var expected_frames := int(round(float(definition.get("duration", 0.0)) * float(stream.mix_rate)))
	var bytes_per_frame := channels * 2
	_expect_equal(stream.format, AudioStreamWAV.FORMAT_16_BITS, "%s uses signed 16-bit PCM" % cue_id)
	_expect_equal(stream.mix_rate, int(definition.get("mix_rate", 0)), "%s uses manifest mix rate" % cue_id)
	_expect_equal(stream.stereo, channels == 2, "%s channel layout matches manifest" % cue_id)
	_expect_equal(stream.data.size(), expected_frames * bytes_per_frame, "%s has exact PCM frame count" % cue_id)
	_expect_true(absf(stream.get_length() - float(definition.get("duration", 0.0))) <= 1.0 / float(stream.mix_rate), "%s length matches manifest" % cue_id)

	var peak := _peak_sample(stream)
	_expect_true(peak > 96, "%s is not silent" % cue_id)
	_expect_true(peak <= int(ProceduralSfxType.MAX_SAMPLE * 32767.0) + 1, "%s stays below the safe peak ceiling" % cue_id)

	var should_loop := bool(definition.get("loop", false))
	if should_loop:
		_expect_equal(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD, "%s uses forward looping" % cue_id)
		_expect_equal(stream.loop_begin, 0, "%s loop starts at frame zero" % cue_id)
		_expect_equal(stream.loop_end, expected_frames, "%s loop ends on the final frame boundary" % cue_id)
		var first_sample := stream.data.decode_s16(0)
		var last_sample := stream.data.decode_s16((expected_frames - 1) * bytes_per_frame)
		_expect_true(absi(last_sample - first_sample) <= 1, "%s has a continuous left-channel loop boundary" % cue_id)
	else:
		_expect_equal(stream.loop_mode, AudioStreamWAV.LOOP_DISABLED, "%s does not loop" % cue_id)


func _peak_sample(stream: AudioStreamWAV) -> int:
	var peak := 0
	for byte_offset: int in range(0, stream.data.size(), 2):
		peak = maxi(peak, absi(stream.data.decode_s16(byte_offset)))
	return peak


func _stream_signature(stream: AudioStreamWAV) -> int:
	var bytes_per_frame := 4 if stream.stereo else 2
	var frame_count := stream.data.size() / bytes_per_frame
	var stride := maxi(1, frame_count / 521)
	var signature: int = 17
	for frame_index: int in range(0, frame_count, stride):
		var left := int(stream.data.decode_s16(frame_index * bytes_per_frame))
		var right := int(stream.data.decode_s16(frame_index * bytes_per_frame + 2)) if stream.stereo else 0
		signature = posmod(signature * 65_599 + left * 31 + right * 17 + frame_index, 2_147_483_647)
	return signature


func _expect_true(actual: bool, label: String) -> void:
	_expect_equal(actual, true, label)


func _expect_false(actual: bool, label: String) -> void:
	_expect_equal(actual, false, label)


func _expect_equal(actual: Variant, expected: Variant, label: String) -> void:
	_assertions += 1
	if actual == expected:
		return
	_failures += 1
	push_error("ASSERT: %s | expected=%s actual=%s" % [label, str(expected), str(actual)])
