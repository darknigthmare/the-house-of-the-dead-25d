extends Node

const GAMEPLAY_SCENE := preload("res://scenes/gameplay/gameplay.tscn")
const AudioCueLibraryType := preload("res://src/audio/audio_cue_library.gd")
const BACKDROP_PATH := "res://assets/environments/mansion-exterior.png"
const AUDIO_CUE_MANIFEST_PATH := "res://data/audio/audio_cues.json"
const UI_CUE_IDS: Array[String] = ["ui_navigate", "ui_confirm", "ui_back", "ui_credit", "ui_join"]

var menu_layer: CanvasLayer
var menu_root: Control
var content_panel: PanelContainer
var active_game: Node
var attract_timer: float = 0.0
var current_menu: String = "home"
var ui_audio_library = null
var ui_audio_player: AudioStreamPlayer
var last_navigation_cued_focus_id: int = 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var saved_settings := SaveManager.data.get("settings", {}) as Dictionary
	SettingsManager.load_dictionary(saved_settings)
	_build_ui_audio()
	_build_menu()
	_show_home()


func _input(event: InputEvent) -> void:
	if active_game != null or not _is_navigation_event(event):
		return
	var focus_owner := get_viewport().gui_get_focus_owner()
	var previous_focus_id := focus_owner.get_instance_id() if focus_owner != null else 0
	call_deferred("_play_navigation_if_focus_changed", previous_focus_id)
	attract_timer = 0.0


func _process(delta: float) -> void:
	if active_game != null:
		return
	attract_timer += delta
	if attract_timer >= 45.0:
		attract_timer = 0.0
		_launch_game("arcade", 1, true)


func _unhandled_input(event: InputEvent) -> void:
	if active_game == null and (event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton):
		attract_timer = 0.0
	if active_game != null or not (event is InputEventKey):
		return
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var keycode := key_event.keycode
	if current_menu == "home" and keycode == KEY_1:
		_play_ui_cue("ui_credit")
		_launch_game("arcade", 1, false)
		get_viewport().set_input_as_handled()
	elif current_menu == "home" and keycode == KEY_2:
		_play_ui_cue("ui_join")
		_launch_game("arcade", 2, false)
		get_viewport().set_input_as_handled()
	elif current_menu != "home" and keycode == KEY_ESCAPE:
		_play_ui_cue("ui_back")
		_show_home()
		get_viewport().set_input_as_handled()


func _build_ui_audio() -> void:
	ui_audio_library = AudioCueLibraryType.new()
	if not ui_audio_library.load_manifest(AUDIO_CUE_MANIFEST_PATH):
		push_warning("Main UI audio disabled: %s" % str(ui_audio_library.last_error))
		ui_audio_library = null
		return
	ui_audio_player = AudioStreamPlayer.new()
	ui_audio_player.name = "InterfaceAudio"
	ui_audio_player.bus = &"Interface"
	add_child(ui_audio_player)
	for cue_id: String in UI_CUE_IDS:
		ui_audio_library.build_stream(cue_id)


func _play_ui_cue(cue_id: String) -> void:
	if not _ui_audio_allowed() or not ui_audio_library.has_cue(cue_id):
		return
	var stream: AudioStreamWAV = ui_audio_library.build_stream(cue_id)
	if stream == null:
		return
	ui_audio_player.stop()
	ui_audio_player.stream = stream
	ui_audio_player.play()


func _ui_audio_allowed() -> bool:
	return (
		ui_audio_library != null
		and ui_audio_player != null
		and active_game == null
		and menu_layer != null
		and menu_layer.visible
	)


func _is_navigation_event(event: InputEvent) -> bool:
	if event is InputEventKey:
		var key_event := event as InputEventKey
		return key_event.pressed and not key_event.echo and key_event.keycode in [KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_TAB]
	if event is InputEventJoypadButton:
		var button_event := event as InputEventJoypadButton
		return button_event.pressed and button_event.button_index in [JOY_BUTTON_DPAD_UP, JOY_BUTTON_DPAD_DOWN, JOY_BUTTON_DPAD_LEFT, JOY_BUTTON_DPAD_RIGHT]
	if event is InputEventJoypadMotion:
		var motion_event := event as InputEventJoypadMotion
		return motion_event.axis in [JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y] and absf(motion_event.axis_value) >= 0.75
	return false


func _play_navigation_if_focus_changed(previous_focus_id: int) -> void:
	if not _ui_audio_allowed():
		return
	var focus_owner := get_viewport().gui_get_focus_owner()
	var focus_id := focus_owner.get_instance_id() if focus_owner != null else 0
	if focus_id == 0 or focus_id == previous_focus_id or focus_id == last_navigation_cued_focus_id:
		return
	last_navigation_cued_focus_id = focus_id
	_play_ui_cue("ui_navigate")


func _build_menu() -> void:
	menu_layer = CanvasLayer.new()
	menu_layer.layer = 10
	add_child(menu_layer)
	menu_root = Control.new()
	menu_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	menu_layer.add_child(menu_root)

	var background := TextureRect.new()
	background.texture = load(BACKDROP_PATH) as Texture2D
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.modulate = Color(0.62, 0.68, 0.78)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(background)

	var vignette := ColorRect.new()
	vignette.color = Color(0.005, 0.008, 0.014, 0.52)
	vignette.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu_root.add_child(vignette)

	var header := VBoxContainer.new()
	header.position = Vector2(58.0, 34.0)
	header.size = Vector2(820.0, 130.0)
	menu_root.add_child(header)
	var eyebrow := Label.new()
	eyebrow.text = "SEGA MODEL 2 HOMAGE  •  ORIGINAL FAN-MADE 2.5D EDITION"
	eyebrow.add_theme_color_override("font_color", Color("#d8b46a"))
	eyebrow.add_theme_font_size_override("font_size", 16)
	header.add_child(eyebrow)
	var title := Label.new()
	title.text = "THE HOUSE\nOF THE DEAD"
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color("#f2ede2"))
	title.add_theme_constant_override("line_spacing", -8)
	header.add_child(title)
	var edition := Label.new()
	edition.text = "2.5D • ARCADE AUTHENTIQUE"
	edition.add_theme_font_size_override("font_size", 19)
	edition.add_theme_color_override("font_color", Color("#d13a32"))
	header.add_child(edition)

	content_panel = PanelContainer.new()
	content_panel.position = Vector2(58.0, 218.0)
	content_panel.size = Vector2(470.0, 440.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.018, 0.024, 0.032, 0.92)
	panel_style.border_color = Color(0.42, 0.34, 0.22, 0.8)
	panel_style.set_border_width_all(1)
	panel_style.corner_radius_top_left = 4
	panel_style.corner_radius_top_right = 4
	panel_style.corner_radius_bottom_left = 4
	panel_style.corner_radius_bottom_right = 4
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 24.0
	panel_style.content_margin_bottom = 24.0
	content_panel.add_theme_stylebox_override("panel", panel_style)
	menu_root.add_child(content_panel)

	var footer := Label.new()
	footer.text = _ui_text("1 : START P1     2 : JOINDRE P2     SOURIS : VISER / TIRER     CLIC DROIT OU R : RECHARGER", "1: START P1     2: JOIN P2     MOUSE: AIM / FIRE     RIGHT CLICK OR R: RELOAD")
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_top = -38.0
	footer.add_theme_font_size_override("font_size", 14)
	footer.add_theme_color_override("font_color", Color(0.78, 0.78, 0.72))
	menu_root.add_child(footer)


func _clear_content() -> VBoxContainer:
	for child in content_panel.get_children():
		child.queue_free()
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	content_panel.add_child(box)
	return box


func _clear_scrollable_content() -> VBoxContainer:
	for child in content_panel.get_children():
		child.queue_free()
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size = Vector2(414.0, 392.0)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content_panel.add_child(scroll)
	var box := VBoxContainer.new()
	box.custom_minimum_size = Vector2(386.0, 0.0)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 10)
	scroll.add_child(box)
	return box


func _heading(box: VBoxContainer, text_value: String, subtext: String = "") -> void:
	var heading := Label.new()
	heading.text = text_value
	heading.add_theme_font_size_override("font_size", 25)
	heading.add_theme_color_override("font_color", Color("#ead9b4"))
	box.add_child(heading)
	if not subtext.is_empty():
		var subtitle := Label.new()
		subtitle.text = subtext
		subtitle.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle.add_theme_font_size_override("font_size", 14)
		subtitle.add_theme_color_override("font_color", Color(0.68, 0.71, 0.72))
		box.add_child(subtitle)
	box.add_child(HSeparator.new())


func _menu_button(box: VBoxContainer, label_text: String, callback: Callable, disabled: bool = false, cue_id: String = "ui_confirm") -> Button:
	var button := Button.new()
	button.text = label_text
	button.custom_minimum_size = Vector2(0.0, 42.0)
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.disabled = disabled
	button.add_theme_font_size_override("font_size", 17)
	button.pressed.connect(_on_menu_button_pressed.bind(callback, cue_id))
	box.add_child(button)
	return button


func _on_menu_button_pressed(callback: Callable, cue_id: String) -> void:
	_play_ui_cue(cue_id)
	callback.call()


func _show_home() -> void:
	current_menu = "home"
	var box := _clear_scrollable_content()
	_heading(box, "INSERT COIN", _ui_text("Campagne complète en quatre chapitres • 1–2 joueurs locaux", "Complete four-chapter campaign • 1–2 local players"))
	_menu_button(box, _ui_text("JOUER — ARCADE AUTHENTIQUE", "PLAY — AUTHENTIC ARCADE"), _launch_game.bind("arcade", 1, false), false, "ui_credit")
	_menu_button(box, _ui_text("COOP LOCALE — 2 JOUEURS", "LOCAL CO-OP — 2 PLAYERS"), _launch_game.bind("arcade", 2, false), false, "ui_join")
	_menu_button(box, _ui_text("ENTRAÎNEMENT", "TRAINING"), _launch_game.bind("training", 1, false))
	_menu_button(box, "BOSS RUSH", _launch_game.bind("boss_rush", 1, false))
	_menu_button(box, _ui_text("SÉLECTION DE CHAPITRE", "CHAPTER SELECT"), _show_chapters)
	_menu_button(box, _ui_text("CLASSEMENT LOCAL", "LOCAL LEADERBOARD"), _show_leaderboard)
	_menu_button(box, _ui_text("CALIBRATION & OPTIONS", "CALIBRATION & SETTINGS"), _show_settings)
	var note := Label.new()
	note.text = _ui_text("Mode démo automatique dans 45 secondes", "Automatic attract mode in 45 seconds")
	note.add_theme_font_size_override("font_size", 13)
	note.add_theme_color_override("font_color", Color(0.55, 0.58, 0.58))
	box.add_child(note)


func _show_leaderboard() -> void:
	current_menu = "leaderboard"
	var box := _clear_scrollable_content()
	_heading(box, _ui_text("CLASSEMENT LOCAL", "LOCAL LEADERBOARD"), _ui_text("Les dix meilleurs scores enregistrés sur cette machine.", "The ten best scores saved on this machine."))
	var scores := (SaveManager.data.get("high_scores", []) as Array).duplicate(true)
	scores.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return int(a.get("score", 0)) > int(b.get("score", 0)))
	if scores.is_empty():
		var empty_label := Label.new()
		empty_label.text = _ui_text("AUCUN SCORE ENREGISTRÉ", "NO SCORE RECORDED")
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		empty_label.add_theme_font_size_override("font_size", 17)
		empty_label.add_theme_color_override("font_color", Color(0.68, 0.71, 0.72))
		empty_label.custom_minimum_size.y = 110.0
		box.add_child(empty_label)
	else:
		var limit := mini(10, scores.size())
		for index in limit:
			var entry := scores[index] as Dictionary
			var initials := str(entry.get("initials", "---")).strip_edges().to_upper()
			if initials.length() != 3:
				initials = "---"
			var row := Label.new()
			row.text = "%02d   %s   %07d   %s   %dP" % [index + 1, initials, maxi(0, int(entry.get("score", 0))), str(entry.get("mode", "arcade")).to_upper(), clampi(int(entry.get("players", 1)), 1, 2)]
			row.add_theme_font_size_override("font_size", 16)
			row.add_theme_color_override("font_color", Color("#f2ede2") if index > 2 else Color("#d8b46a"))
			box.add_child(row)
	_menu_button(box, _ui_text("← RETOUR", "← BACK"), _show_home, false, "ui_back")


func _show_chapters() -> void:
	current_menu = "chapters"
	var box := _clear_content()
	_heading(box, _ui_text("SÉLECTION DE CHAPITRE", "CHAPTER SELECT"), _ui_text("Choisissez une séquence déjà découverte.", "Choose a previously discovered sequence."))
	var chapter_entries: Array[Dictionary] = [
		{"number": 1, "label": "I — TRAGEDY / CHARIOT"},
		{"number": 2, "label": "II — REVENGE / HANGEDMAN"},
		{"number": 3, "label": "III — TRUTH / HERMIT"},
		{"number": 4, "label": "IV — THE HOUSE OF THE DEAD / MAGICIAN"}
	]
	for chapter_entry: Dictionary in chapter_entries:
		var chapter_number := int(chapter_entry.number)
		var unlocked := SaveManager.has_chapter_unlocked(chapter_number)
		var chapter_label := str(chapter_entry.label)
		if not unlocked:
			chapter_label += _ui_text("  •  VERROUILLÉ", "  •  LOCKED")
		_menu_button(box, chapter_label, _launch_game.bind("chapter_select", 1, false, chapter_number), not unlocked)
	_menu_button(box, _ui_text("← RETOUR", "← BACK"), _show_home, false, "ui_back")


func _show_settings() -> void:
	current_menu = "settings"
	var box := _clear_scrollable_content()
	_heading(box, _ui_text("CALIBRATION & OPTIONS", "CALIBRATION & SETTINGS"), _ui_text("Les assistances sont séparées du mode Arcade Authentique.", "Assists are kept separate from Authentic Arcade mode."))
	var language_row := HBoxContainer.new()
	var language_label := Label.new()
	language_label.text = "Langue / Language"
	language_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	language_row.add_child(language_label)
	var language_choice := OptionButton.new()
	language_choice.add_item("Français")
	language_choice.add_item("English")
	language_choice.selected = 0 if str(SettingsManager.get_value("language", "fr")) == "fr" else 1
	language_choice.item_selected.connect(func(index: int) -> void:
		SettingsManager.set_value("language", "fr" if index == 0 else "en")
		_play_ui_cue("ui_confirm")
	)
	language_row.add_child(language_choice)
	box.add_child(language_row)
	_add_setting_toggle(box, _ui_text("Cadrage authentique 4:3", "Authentic 4:3 framing"), "authentic_ratio")
	_add_setting_toggle(box, _ui_text("Réduire les flashes", "Reduce flashes"), "reduced_flashes")
	_add_setting_toggle(box, _ui_text("Réduire les tremblements", "Reduce camera shake"), "reduced_shake")
	_add_setting_toggle(box, _ui_text("Démembrement", "Dismemberment"), "dismemberment")
	_add_setting_toggle(box, _ui_text("Bouton de rechargement", "Reload button"), "button_reload")
	var blood_row := HBoxContainer.new()
	var blood_label := Label.new()
	blood_label.text = _ui_text("Niveau de sang", "Blood level")
	blood_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	blood_row.add_child(blood_label)
	var blood_choice := OptionButton.new()
	blood_choice.add_item(_ui_text("Désactivé", "Off"))
	blood_choice.add_item(_ui_text("Réduit", "Reduced"))
	blood_choice.add_item(_ui_text("Arcade", "Arcade"))
	blood_choice.selected = int(SettingsManager.get_value("blood_level", 2))
	blood_choice.item_selected.connect(func(index: int) -> void: SettingsManager.set_value("blood_level", index))
	blood_row.add_child(blood_choice)
	box.add_child(blood_row)
	_add_setting_slider(box, _ui_text("Assistance de visée", "Aim assist"), "aim_assist")
	_add_setting_slider(box, _ui_text("Volume général", "Master volume"), "master_volume")
	_add_setting_slider(box, _ui_text("Volume musique", "Music volume"), "music_volume")
	_add_setting_slider(box, _ui_text("Volume voix", "Voice volume"), "voice_volume")
	_add_setting_slider(box, _ui_text("Volume effets", "Effects volume"), "effects_volume")
	_add_setting_slider(box, _ui_text("Volume interface", "Interface volume"), "interface_volume")
	_add_setting_slider(box, _ui_text("Volume ambiance", "Ambience volume"), "ambience_volume")
	var calibration := ColorRect.new()
	calibration.color = Color(0.04, 0.05, 0.06, 1.0)
	calibration.custom_minimum_size = Vector2(0.0, 105.0)
	calibration.tooltip_text = _ui_text("Visez les coins puis le centre ; le tir hors de cette zone recharge.", "Aim at the corners and center; firing outside this area reloads.")
	box.add_child(calibration)
	var calibration_text := Label.new()
	calibration_text.text = "┌   ZONE DE VISÉE / OFF-SCREEN RELOAD   ┐\n\n      + centre      • coins      "
	calibration_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	calibration_text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	calibration_text.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	calibration_text.mouse_filter = Control.MOUSE_FILTER_IGNORE
	calibration.add_child(calibration_text)
	_menu_button(box, _ui_text("← ENREGISTRER & RETOUR", "← SAVE & BACK"), _save_settings_and_return, false, "ui_back")


func _add_setting_toggle(box: VBoxContainer, label_text: String, key: String) -> void:
	var toggle := CheckButton.new()
	toggle.text = label_text
	toggle.button_pressed = bool(SettingsManager.get_value(key, false))
	toggle.toggled.connect(func(value: bool) -> void:
		SettingsManager.set_value(key, value)
		_play_ui_cue("ui_confirm")
	)
	box.add_child(toggle)

func _add_setting_slider(box: VBoxContainer, label_text: String, key: String) -> void:
	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 2)
	var header := HBoxContainer.new()
	var label := Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(label)
	var value_label := Label.new()
	header.add_child(value_label)
	container.add_child(header)
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = float(SettingsManager.get_value(key, 0.0))
	slider.custom_minimum_size.y = 24.0
	value_label.text = "%d%%" % int(round(slider.value * 100.0))
	slider.value_changed.connect(func(value: float) -> void:
		SettingsManager.set_value(key, value)
		value_label.text = "%d%%" % int(round(value * 100.0))
	)
	container.add_child(slider)
	box.add_child(container)

func _save_settings_and_return() -> void:
	SaveManager.set_settings(SettingsManager.export_dictionary())
	SaveManager.write_save()
	_show_home()

func _ui_text(french: String, english: String) -> String:
	return english if str(SettingsManager.get_value("language", "fr")) == "en" else french

func _launch_game(mode: String, player_count: int = 1, demo: bool = false, chapter: int = 1) -> void:
	if active_game != null:
		return
	menu_layer.visible = false
	active_game = GAMEPLAY_SCENE.instantiate()
	add_child(active_game)
	if active_game.has_signal("exit_requested"):
		active_game.exit_requested.connect(_on_game_exit)
	var configuration := {
		"mode": mode,
		"players": player_count,
		"demo": demo,
		"start_chapter": chapter
	}
	configuration.merge(SettingsManager.export_dictionary(), true)
	if active_game.has_method("configure"):
		active_game.configure(configuration)

func _on_game_exit() -> void:
	if active_game != null:
		active_game.queue_free()
		active_game = null
	menu_layer.visible = true
	attract_timer = 0.0
	_show_home()
