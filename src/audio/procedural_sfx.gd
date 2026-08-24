class_name ProceduralSfx
extends RefCounted

## Deterministic, runtime-generated placeholder audio.
##
## The synthesis deliberately does not imitate or reconstruct licensed Sega
## recordings. It provides an original temporary soundscape until approved
## music, dialogue and sound masters are supplied by the rights holder.

const DEFAULT_MIX_RATE: int = 22_050
const MAX_SAMPLE: float = 0.90
const DEFAULT_MANIFEST_PATH: String = "res://data/audio/audio_cues.json"


static func tone(
	frequency: float,
	duration: float,
	volume: float = 0.24,
	decay: float = 5.0,
	noise: float = 0.0
) -> AudioStreamWAV:
	return build_definition({
		"generator": "tone",
		"duration": duration,
		"channels": 1,
		"gain": volume,
		"frequency": frequency,
		"decay": decay,
		"noise": noise,
		"seed": int(frequency * 1000.0) + int(duration * DEFAULT_MIX_RATE)
	})


static func build_cue(cue_id: String, manifest_path: String = DEFAULT_MANIFEST_PATH) -> AudioStreamWAV:
	var manifest := load_manifest(manifest_path)
	var cues_value: Variant = manifest.get("cues", {})
	if typeof(cues_value) != TYPE_DICTIONARY:
		push_error("ProceduralSfx: invalid cue manifest: %s" % manifest_path)
		return null
	var cues := cues_value as Dictionary
	var definition_value: Variant = cues.get(cue_id, {})
	if typeof(definition_value) != TYPE_DICTIONARY or (definition_value as Dictionary).is_empty():
		push_error("ProceduralSfx: unknown cue '%s'" % cue_id)
		return null
	return build_definition(definition_value as Dictionary, cue_id.hash())


static func load_manifest(path: String = DEFAULT_MANIFEST_PATH) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary


static func build_definition(definition: Dictionary, fallback_seed: int = 1) -> AudioStreamWAV:
	var mix_rate := clampi(int(definition.get("mix_rate", DEFAULT_MIX_RATE)), 8_000, 48_000)
	var duration := clampf(float(definition.get("duration", 0.1)), 0.02, 16.0)
	var frame_count := maxi(1, int(round(duration * float(mix_rate))))
	var stereo := int(definition.get("channels", 1)) == 2
	var seed := int(definition.get("seed", fallback_seed))
	if seed == 0:
		seed = fallback_seed if fallback_seed != 0 else 1

	var left := PackedFloat32Array()
	var right := PackedFloat32Array()
	left.resize(frame_count)
	right.resize(frame_count)
	var generator := str(definition.get("generator", "tone"))
	for frame_index: int in frame_count:
		var t := float(frame_index) / float(mix_rate)
		var sample := _sample_generator(generator, t, frame_index, frame_count, mix_rate, seed, definition)
		left[frame_index] = sample.x
		right[frame_index] = sample.y if stereo else sample.x

	var should_loop := bool(definition.get("loop", false))
	if should_loop:
		_make_loop_seamless(left, right, maxi(32, int(float(mix_rate) * 0.08)))

	var gain := clampf(float(definition.get("gain", 0.3)), 0.0, 1.0)
	var bytes_per_frame := 4 if stereo else 2
	var bytes := PackedByteArray()
	bytes.resize(frame_count * bytes_per_frame)
	for frame_index: int in frame_count:
		var left_value := clampf(left[frame_index] * gain, -MAX_SAMPLE, MAX_SAMPLE)
		bytes.encode_s16(frame_index * bytes_per_frame, clampi(int(round(left_value * 32767.0)), -32768, 32767))
		if stereo:
			var right_value := clampf(right[frame_index] * gain, -MAX_SAMPLE, MAX_SAMPLE)
			bytes.encode_s16(frame_index * bytes_per_frame + 2, clampi(int(round(right_value * 32767.0)), -32768, 32767))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = stereo
	stream.data = bytes
	if should_loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = frame_count
	return stream


static func _sample_generator(
	generator: String,
	t: float,
	frame_index: int,
	frame_count: int,
	mix_rate: int,
	seed: int,
	definition: Dictionary
) -> Vector2:
	match generator:
		"gunshot":
			return _gunshot(t, frame_index, seed)
		"reload":
			return _reload(t, frame_index, seed)
		"dry_fire":
			return _dry_fire(t, frame_index, seed)
		"body_hit":
			return _body_hit(t, frame_index, seed)
		"alarm":
			return _alarm(t, definition)
		"ui_chime":
			return _ui_chime(t, definition)
		"ui_click":
			return _ui_click(t, frame_index, seed, definition)
		"ambience_loop":
			return _ambience(t, frame_index, frame_count, mix_rate, seed, definition)
		"music_loop":
			return _music(t, definition)
		"boss_telegraph":
			return _boss_telegraph(t, frame_index, seed, definition)
		"projectile":
			return _projectile(t, frame_index, seed, definition)
		"radio_chirp":
			return _radio_chirp(t, frame_index, seed, definition)
		_:
			return _tone_sample(t, frame_index, seed, definition)


static func _tone_sample(t: float, frame_index: int, seed: int, definition: Dictionary) -> Vector2:
	var frequency := float(definition.get("frequency", 440.0))
	var decay := float(definition.get("decay", 5.0))
	var noise_mix := clampf(float(definition.get("noise", 0.0)), 0.0, 1.0)
	var wave := sin(TAU * frequency * t)
	wave = lerpf(wave, _noise(seed, frame_index, 0), noise_mix)
	wave *= exp(-decay * t)
	return Vector2(wave, wave)


static func _gunshot(t: float, frame_index: int, seed: int) -> Vector2:
	var attack := clampf(t / 0.0025, 0.0, 1.0)
	var blast := _noise(seed, frame_index, 0) * exp(-25.0 * t)
	var body := sin(TAU * (73.0 - 35.0 * t) * t) * exp(-13.0 * t)
	var crack := sin(TAU * 980.0 * t) * exp(-58.0 * t)
	var sample := attack * (0.72 * blast + 0.54 * body + 0.18 * crack)
	return Vector2(sample, sample)


static func _reload(t: float, frame_index: int, seed: int) -> Vector2:
	var sample := _metal_impulse(t, 0.025, 0.018, 1320.0, frame_index, seed)
	sample += 0.72 * _metal_impulse(t, 0.155, 0.024, 810.0, frame_index, seed + 13)
	sample += 0.85 * _metal_impulse(t, 0.285, 0.021, 1110.0, frame_index, seed + 29)
	return Vector2(sample, sample)


static func _dry_fire(t: float, frame_index: int, seed: int) -> Vector2:
	var sample := _metal_impulse(t, 0.012, 0.009, 1740.0, frame_index, seed)
	sample += 0.42 * _metal_impulse(t, 0.058, 0.012, 940.0, frame_index, seed + 7)
	return Vector2(sample, sample)


static func _body_hit(t: float, frame_index: int, seed: int) -> Vector2:
	var thud := sin(TAU * (91.0 - 22.0 * t) * t) * exp(-16.0 * t)
	var texture := _noise(seed, frame_index, 0) * exp(-23.0 * t)
	return Vector2(0.84 * thud + 0.45 * texture, 0.84 * thud + 0.45 * texture)


static func _alarm(t: float, definition: Dictionary) -> Vector2:
	var duration := float(definition.get("duration", 0.7))
	var progress := clampf(t / maxf(duration, 0.02), 0.0, 1.0)
	var frequency := lerpf(145.0, 238.0, 0.5 + 0.5 * sin(TAU * progress * 2.0))
	var pulse := 0.45 + 0.55 * _square(t * 7.0, 0.64)
	var sample := (0.72 * sin(TAU * frequency * t) + 0.24 * _saw(frequency * 0.5 * t)) * pulse
	return Vector2(sample, sample)


static func _ui_chime(t: float, definition: Dictionary) -> Vector2:
	var notes_value: Variant = definition.get("notes", [72])
	var notes := notes_value as Array if typeof(notes_value) == TYPE_ARRAY else [72]
	var spacing := float(definition.get("note_spacing", 0.11))
	var sample := 0.0
	for note_index: int in notes.size():
		var local_time := t - float(note_index) * spacing
		if local_time < 0.0:
			continue
		var frequency := _midi_to_frequency(float(notes[note_index]))
		var envelope := exp(-9.5 * local_time) * clampf(local_time / 0.004, 0.0, 1.0)
		sample += envelope * (0.78 * sin(TAU * frequency * local_time) + 0.22 * sin(TAU * frequency * 2.01 * local_time))
	return Vector2(sample, sample)


static func _ui_click(t: float, frame_index: int, seed: int, definition: Dictionary) -> Vector2:
	var frequency := float(definition.get("frequency", 1200.0))
	var direction := float(definition.get("direction", 0.0))
	var swept := frequency * (1.0 + direction * t * 5.0)
	var sample := sin(TAU * swept * t) * exp(-25.0 * t)
	sample += 0.15 * _noise(seed, frame_index, 0) * exp(-42.0 * t)
	return Vector2(sample, sample)


static func _ambience(
	t: float,
	frame_index: int,
	frame_count: int,
	mix_rate: int,
	seed: int,
	definition: Dictionary
) -> Vector2:
	var profile := str(definition.get("profile", "mansion"))
	var slow_left := _smooth_noise(seed, frame_index, maxi(1, mix_rate / 16), 0)
	var slow_right := _smooth_noise(seed + 31, frame_index, maxi(1, mix_rate / 17), 1)
	var fine_left := _smooth_noise(seed + 71, frame_index, maxi(1, mix_rate / 190), 0)
	var fine_right := _smooth_noise(seed + 103, frame_index, maxi(1, mix_rate / 181), 1)
	var left := 0.0
	var right := 0.0
	match profile:
		"garden":
			left = 0.62 * slow_left + 0.18 * fine_left + 0.18 * sin(TAU * 39.0 * t)
			right = 0.62 * slow_right + 0.18 * fine_right + 0.18 * sin(TAU * 40.4 * t)
		"sewer":
			var drip_phase := fmod(t * 0.83, 1.0)
			var drip := sin(TAU * 1680.0 * drip_phase) * exp(-38.0 * drip_phase)
			left = 0.34 * slow_left + 0.38 * sin(TAU * 42.0 * t) + 0.32 * drip
			right = 0.34 * slow_right + 0.38 * sin(TAU * 43.3 * t) + 0.20 * drip
		"roof":
			var gust := 0.45 + 0.55 * sin(TAU * t * 0.19)
			left = (0.65 * slow_left + 0.4 * fine_left) * gust + 0.12 * sin(TAU * 57.0 * t)
			right = (0.65 * slow_right + 0.4 * fine_right) * gust + 0.12 * sin(TAU * 59.0 * t)
		"laboratory":
			var relay := exp(-80.0 * absf(fmod(t, 1.4) - 0.05))
			left = 0.42 * sin(TAU * 50.0 * t) + 0.21 * sin(TAU * 100.0 * t) + 0.16 * slow_left + 0.22 * relay
			right = 0.42 * sin(TAU * 50.4 * t) + 0.21 * sin(TAU * 100.8 * t) + 0.16 * slow_right + 0.18 * relay
		_:
			var creak_phase := fmod(t * 0.29, 1.0)
			var creak := sin(TAU * (118.0 + 90.0 * creak_phase) * t) * exp(-10.0 * creak_phase)
			left = 0.38 * slow_left + 0.26 * sin(TAU * 46.0 * t) + 0.12 * creak
			right = 0.38 * slow_right + 0.26 * sin(TAU * 46.7 * t) + 0.08 * creak
	var loop_phase := float(frame_index) / float(maxi(1, frame_count))
	left += 0.03 * sin(TAU * loop_phase * 3.0)
	right += 0.03 * sin(TAU * loop_phase * 4.0)
	return Vector2(left, right)


static func _music(t: float, definition: Dictionary) -> Vector2:
	var bpm := float(definition.get("bpm", 120.0))
	var beat := t * bpm / 60.0
	var step := int(floor(beat * 2.0))
	var step_phase := fmod(beat * 2.0, 1.0)
	var bass_pattern := _int_array(definition.get("bass_pattern", [36, -1, 36, -1]))
	var lead_pattern := _int_array(definition.get("lead_pattern", [60, -1, 63, -1]))
	var root_midi := float(definition.get("root_midi", 36.0))
	var bass_note := _pattern_note(bass_pattern, step, int(root_midi))
	var lead_note := _pattern_note(lead_pattern, step, int(root_midi + 24.0))
	var bass_frequency := _midi_to_frequency(float(bass_note))
	var bass_gate := 1.0 if _pattern_active(bass_pattern, step) else 0.0
	var lead_frequency := _midi_to_frequency(float(lead_note))
	var lead_gate := 1.0 if _pattern_active(lead_pattern, step) else 0.0
	var bass_envelope := exp(-2.1 * step_phase) * bass_gate
	var lead_envelope := exp(-3.8 * step_phase) * lead_gate
	var bass := (0.56 * _triangle(bass_frequency * t) + 0.22 * sin(TAU * bass_frequency * 0.5 * t)) * bass_envelope
	var lead := (0.58 * sin(TAU * lead_frequency * t) + 0.18 * _square(lead_frequency * 0.5 * t, 0.38)) * lead_envelope
	var pad_root := _midi_to_frequency(root_midi + 12.0)
	var pad := 0.16 * sin(TAU * pad_root * t) + 0.1 * sin(TAU * pad_root * 1.498 * t)
	var kick_phase := fmod(beat, 1.0)
	var kick := sin(TAU * (72.0 - 33.0 * kick_phase) * kick_phase) * exp(-11.0 * kick_phase)
	var pulse := float(definition.get("pulse", 0.2)) * kick
	var pan := 0.5 + 0.5 * sin(TAU * t * float(definition.get("pan_rate", 0.09)))
	return Vector2(bass + lead * (0.75 + 0.25 * (1.0 - pan)) + pad + pulse, bass + lead * (0.75 + 0.25 * pan) + pad * 0.94 + pulse)


static func _boss_telegraph(t: float, frame_index: int, seed: int, definition: Dictionary) -> Vector2:
	var duration := float(definition.get("duration", 1.0))
	var progress := clampf(t / maxf(duration, 0.02), 0.0, 1.0)
	var base_frequency := float(definition.get("frequency", 68.0))
	var frequency := lerpf(base_frequency, base_frequency * 4.1, progress * progress)
	var rumble := 0.58 * sin(TAU * frequency * t) + 0.28 * _saw(frequency * 0.5 * t)
	var texture := 0.18 * _noise(seed, frame_index, 0)
	var envelope := sin(PI * progress) * (0.55 + 0.45 * progress)
	var sample := (rumble + texture) * envelope
	return Vector2(sample, sample * 0.97)


static func _projectile(t: float, frame_index: int, seed: int, definition: Dictionary) -> Vector2:
	var duration := float(definition.get("duration", 0.5))
	var progress := clampf(t / maxf(duration, 0.02), 0.0, 1.0)
	var profile := str(definition.get("profile", "fire"))
	var sample := 0.0
	match profile:
		"intercept":
			sample = _noise(seed, frame_index, 0) * exp(-28.0 * t) + 0.5 * sin(TAU * 510.0 * t) * exp(-17.0 * t)
		"web":
			sample = 0.5 * _noise(seed, frame_index, 0) * sin(PI * progress) + 0.52 * sin(TAU * lerpf(160.0, 72.0, progress) * t)
		_:
			sample = 0.58 * _noise(seed, frame_index, 0) * sin(PI * progress) + 0.48 * _saw(lerpf(85.0, 310.0, progress) * t)
	var pan := lerpf(-0.55, 0.55, progress)
	return Vector2(sample * (1.0 - maxf(0.0, pan)), sample * (1.0 + minf(0.0, pan)))


static func _radio_chirp(t: float, frame_index: int, seed: int, definition: Dictionary) -> Vector2:
	var duration := float(definition.get("duration", 0.8))
	var progress := clampf(t / maxf(duration, 0.02), 0.0, 1.0)
	var profile := float(definition.get("profile_offset", 0.0))
	var syllable := int(floor(progress * 7.0))
	var syllable_phase := fmod(progress * 7.0, 1.0)
	var base := 245.0 + profile * 37.0 + float((syllable * 53 + seed) % 91)
	var carrier := 0.56 * sin(TAU * base * t) + 0.21 * sin(TAU * base * 2.31 * t)
	var nonverbal_gate := sin(PI * syllable_phase) * (0.72 + 0.28 * _square(t * 19.0, 0.56))
	var radio_noise := 0.16 * _noise(seed, frame_index, 0)
	var static_clicks := 0.08 * _noise(seed + 47, frame_index, 1) * _square(t * 31.0, 0.14)
	var sample := (carrier * nonverbal_gate + radio_noise + static_clicks) * sin(PI * progress)
	return Vector2(sample, sample)


static func _metal_impulse(t: float, event_time: float, width: float, frequency: float, frame_index: int, seed: int) -> float:
	var local_time := t - event_time
	if local_time < 0.0:
		return 0.0
	var envelope := exp(-local_time / maxf(width, 0.001))
	return envelope * (0.72 * sin(TAU * frequency * local_time) + 0.28 * _noise(seed, frame_index, 0))


static func _make_loop_seamless(left: PackedFloat32Array, right: PackedFloat32Array, requested_frames: int) -> void:
	var blend_frames := mini(requested_frames, left.size() / 4)
	if blend_frames <= 1:
		return
	var left_head := left.slice(0, blend_frames)
	var right_head := right.slice(0, blend_frames)
	for blend_index: int in blend_frames:
		var amount := float(blend_index + 1) / float(blend_frames)
		var tail_index := left.size() - blend_frames + blend_index
		left[tail_index] = lerpf(left[tail_index], left_head[0], amount)
		right[tail_index] = lerpf(right[tail_index], right_head[0], amount)


static func _noise(seed: int, sample_index: int, channel: int) -> float:
	var value := sin(float(sample_index + seed * 131 + channel * 977) * 12.9898) * 43758.5453
	return (value - floor(value)) * 2.0 - 1.0


static func _smooth_noise(seed: int, sample_index: int, period: int, channel: int) -> float:
	var block := sample_index / period
	var phase := float(sample_index % period) / float(period)
	var smooth_phase := phase * phase * (3.0 - 2.0 * phase)
	return lerpf(_noise(seed, block, channel), _noise(seed, block + 1, channel), smooth_phase)


static func _square(phase: float, duty: float = 0.5) -> float:
	return 1.0 if fmod(phase, 1.0) < duty else -1.0


static func _saw(phase: float) -> float:
	return 2.0 * (phase - floor(phase + 0.5))


static func _triangle(phase: float) -> float:
	return 2.0 * absf(2.0 * (phase - floor(phase + 0.5))) - 1.0


static func _midi_to_frequency(note: float) -> float:
	return 440.0 * pow(2.0, (note - 69.0) / 12.0)


static func _int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for item: Variant in value as Array:
		result.append(int(item))
	return result


static func _pattern_active(pattern: Array[int], step: int) -> bool:
	return not pattern.is_empty() and pattern[posmod(step, pattern.size())] >= 0

static func _pattern_note(pattern: Array[int], step: int, fallback: int) -> int:
	if pattern.is_empty():
		return fallback
	var note := pattern[posmod(step, pattern.size())]
	return note if note >= 0 else fallback
