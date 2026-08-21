extends Node

signal locale_changed(locale: String)

const SUPPORTED := ["en", "fr"]

var locale: String = "fr"
var strings: Dictionary = {
	"en": {
		"start": "START GAME", "reload": "RELOAD", "save_scientist": "SAVE THE SCIENTIST",
		"continue": "CONTINUE?", "game_over": "GAME OVER", "chapter_complete": "CHAPTER COMPLETE"
	},
	"fr": {
		"start": "JOUER", "reload": "RECHARGER", "save_scientist": "SAUVEZ LE SCIENTIFIQUE",
		"continue": "CONTINUER ?", "game_over": "PARTIE TERMINÉE", "chapter_complete": "CHAPITRE TERMINÉ"
	}
}


func set_locale(next_locale: String) -> void:
	locale = next_locale if next_locale in SUPPORTED else "en"
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)


func text(key: String, values: Dictionary = {}) -> String:
	var table := strings.get(locale, strings.en) as Dictionary
	var result := str(table.get(key, key))
	for name in values:
		result = result.replace("{%s}" % name, str(values[name]))
	return result
