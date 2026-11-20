extends RefCounted

const NAMES := ["Selon le dossier", "Tenue du jeu 2D", "Réception du manoir"]
var preference := {6:0, 7:0}
var back := Callable()

func art_id(a, id: int) -> String:
	var base: String = a.Fighter.PROFILES[id].id
	var choice: int = preference.get(id,1)
	if choice == 2 or (choice == 0 and a.case_id == "scarlet"):
		return base+"_soiree" if preference.has(id) else base
	return base

func show(a, previous: Callable) -> void:
	back = previous
	a.phase = "costumes"
	a.sheet("Tenues de combat","La réception du manoir reprend les vêtements portés par Kate et Ryan au début de Scarlet Dawn. Le réglage vaut pour les deux côtés du duel jusqu’à la fermeture du jeu.")
	for id in preference:
		a.button("%s   ·   %s" % [a.Fighter.PROFILES[id].title,NAMES[preference[id]]],cycle.bind(a,id))
	a.paragraph("Selon le dossier sélectionne la tenue de réception dans la chronique Scarlet Dawn. Le choix manuel s’applique aussi aux duels libres.")
	a.button("Retour à la sélection", back)

func cycle(a, id: int) -> void:
	preference[id] = (int(preference[id])+1)%NAMES.size()
	show(a,back)
	# Preserve focus for a second controller press on the same outfit.
	for node in a.box.get_children():
		if node is Button and node.text.begins_with(a.Fighter.PROFILES[id].title):
			node.grab_focus()
			break
