class_name UITextSanitizer
extends RefCounted

## Keeps French/English letters intact while replacing ornamental Unicode
## characters that are not consistently covered by every Godot export font.
## Gameplay icons (lives, ammunition and reload) are textures and must not rely
## on font glyphs.
const ORNAMENT_REPLACEMENTS: Dictionary = {
	"•": "|",
	"—": "-",
	"–": "-",
	"←": "<",
	"→": ">",
	"┌": "+",
	"┐": "+",
	"└": "+",
	"┘": "+",
	"◆": "*",
	"●": "*",
	"○": "o",
	"�": "?",
	"\u00a0": " "
}
const SCORE_MODES := {
	"ARCADE": true,
	"TRAINING": true,
	"BOSS_RUSH": true,
	"CHAPTER_SELECT": true,
}


static func sanitize(text_value: String) -> String:
	var result := text_value
	for ornament: String in ORNAMENT_REPLACEMENTS:
		result = result.replace(ornament, str(ORNAMENT_REPLACEMENTS[ornament]))
	return result


static func contains_unsupported_ornament(text_value: String) -> bool:
	for ornament: String in ORNAMENT_REPLACEMENTS:
		if ornament in text_value:
			return true
	return false


static func normalize_score_initials(text_value: String) -> String:
	var candidate := text_value.strip_edges().to_upper()
	if candidate.length() != 3:
		return "---"
	for index in candidate.length():
		var code := candidate.unicode_at(index)
		if code < 65 or code > 90:
			return "---"
	return candidate


static func normalize_score_mode(text_value: String) -> String:
	var candidate := text_value.strip_edges().to_upper().replace("-", "_").replace(" ", "_")
	return candidate if SCORE_MODES.has(candidate) else "ARCADE"
