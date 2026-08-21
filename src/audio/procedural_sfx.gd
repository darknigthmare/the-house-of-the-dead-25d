class_name ProceduralSfx
extends RefCounted


static func tone(frequency: float, duration: float, volume: float = 0.24, decay: float = 5.0, noise: float = 0.0) -> AudioStreamWAV:
	var mix_rate := 22050
	var sample_count := maxi(1, int(duration * float(mix_rate)))
	var bytes := PackedByteArray()
	bytes.resize(sample_count * 2)
	var random := RandomNumberGenerator.new()
	random.seed = int(frequency * 1000.0) + sample_count
	for sample_index in sample_count:
		var t := float(sample_index) / float(mix_rate)
		var envelope := exp(-decay * t)
		var wave := sin(TAU * frequency * t)
		if noise > 0.0:
			wave = lerpf(wave, random.randf_range(-1.0, 1.0), noise)
		var value := clampi(int(wave * envelope * volume * 32767.0), -32768, 32767)
		bytes.encode_s16(sample_index * 2, value)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = bytes
	return stream
