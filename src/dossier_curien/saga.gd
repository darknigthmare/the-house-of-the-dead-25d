extends RefCounted

# Fan-made combat reconstructions. Guest opponents are identified as simulated
# exhibitions in the brief so the original rail-shooter stories stay intact.
const STAGES := ["Cour du manoir", "Antichambre", "Laboratoire de Curien", "Quai de la cité inondée",
	"Poste de sécurité EFI", "Métro souterrain", "Complexe déserté", "Réception de Scarecrow Mansion",
	"Fête foraine de Bayou City", "Plateau de Loving Deads", "Rue en quarantaine",
	"Toit de la tour Goldman", "Chambre d’incubation EFI", "Passage de la tour de l’horloge", "Ponton du bayou", "Parvis du siège Goldman", "Ruines du domaine Scarecrow", "Rue dévastée de Despair",
	"Toit du train — Zombie Revenge", "Abattoir — Creeping Flesh", "Canal souterrain — Tower", "Colisée — Strength", "Enclos du D.B.R. — Fool", "Chambre BIO — Sun"]
const ART := ["", "", "", "venice", "efi", "subway", "special", "scarlet", "carnival", "ex", "revenge", "goldman", "reactor", "clocktower", "bayou", "worldstage", "moonstage", "citydespair", "zr_train", "creeping_flesh", "tower_canal", "strength_colosseum", "fool_enclosure", "sun_bio"]
const STAGE_NOTES := {
	18: "Adaptation 2D documentée du toit du train de Zombie Revenge.",
	19: "Adaptation 2D documentée de l’abattoir de Creeping Flesh, dans Overkill.",
	20: "Adaptation 2D documentée du canal souterrain de Tower, dans The House of the Dead 2.",
	21: "Adaptation 2D documentée du colisée de Strength, dans The House of the Dead 2.",
	22: "Adaptation 2D documentée de la salle de Fool au D.B.R., dans The House of the Dead III. Les autres salles et parcours ne sont pas couverts.",
	23: "Adaptation 2D documentée de la salle de Sun à BIO, dans The House of the Dead III. Les autres salles et parcours ne sont pas couverts."
}
const CASES := {
	"curien": {"name":"The House of the Dead","place":"Manoir Curien","lead":0,"stage":0,"guests":[1,2,3],
		"rule":"Duels du manoir. Deux manches gagnantes de 60 secondes."},
	"hotd2": {"name":"The House of the Dead 2","place":"La cité inondée","lead":4,"stage":3,"guests":[19,11,17],"route_stages":[3,3,11],
		"rule":"Secours sur le quai. Un enchaînement de trois touches rend trois secondes, une fois par joueur et par manche.",
		"intro":"James reçoit une transmission hachée au bord du canal. L’AMS rejoue le passage à quai pour établir à quel moment les derniers civils ont pu rejoindre la rive.",
		"rival":"Hierophant surgit à l’aplomb de l’eau. La pointe du trident reste hors de portée jusqu’au moment où son porteur avance sur les dalles.",
		"final":"Au sommet de la tour Goldman, les sphères d’Emperor se desserrent autour de son thorax. James pose la radio au bord du toit. Pour cet exercice, le scanner peut signaler l’instant où le noyau reste à découvert.",
		"ending":"La radio retrouve un canal libre. James inscrit le lieu du dernier appel sur sa carte et transmet les coordonnées des rescapés."},
	"hotd3": {"name":"The House of the Dead III","place":"Centre de recherche EFI","lead":5,"stage":4,"guests":[20,12,18],"route_stages":[4,4,12],
		"rule":"Relève. Une projection réussie restitue six points de vie à son auteur, une seule fois par manche.",
		"intro":"Lisa et G poussent les portes du centre EFI sur les traces de Thomas. Une tôle froissée conserve la marque ronde d’une massue.",
		"rival":"Death remplit l’encadrement de la porte de sécurité. Lisa profite du temps que prend la massue pour remonter après son passage.",
		"final":"Lisa rejoint Daniel à la chambre d’incubation. La roue électrifiée décrit un tour au-dessus du réacteur. L’écho de la voix du docteur Curien passe dans les haut-parleurs avant que le sujet n’attaque.",
		"ending":"G rejoint Lisa près de la sortie. Elle remet la photo de son père dans sa poche pendant que le portail s’ouvre sur la lumière grise."},
	"hotd4": {"name":"The House of the Dead 4","place":"Sous-sols de la ville","lead":6,"stage":5,"guests":[4,13,21],"route_stages":[5,5,15],
		"rule":"Fenêtre de ravitaillement. La première série de trois touches recharge le magasin du combattant qui l’a réussie.",
		"intro":"À la lueur des blocs de secours, Kate retrouve James entre deux rames immobiles. Une sirène annonce la fermeture des portes.",
		"rival":"Entre deux rames, Justice ouvre ses quatre bras et bloque la sortie. Kate le force à se retourner près de la bande de sécurité.",
		"final":"Dans la cour de Goldman, James couvre la sortie pendant que Kate observe le cœur de The World. Une lame de glace se forme au bout du bras de la créature.",
		"ending":"Le relevé de Kate s’arrête à la voix de James sur le parvis. L’AMS repasse la première image du quai. Dans la vitre de la rame, ils sont encore deux."},
	"special": {"name":"The House of the Dead 4 Special","place":"Complexe déserté","lead":6,"stage":6,"guests":[1,4,3],
		"rule":"Compte à rebours. Une manche dure 35 secondes. Chaque première attaque spéciale confirmée accorde cinq secondes.",
		"intro":"G rejoint Kate sur la piste d’une nouvelle menace. Le bruit d’un générateur couvre la radio quand ils pénètrent dans le complexe.",
		"rival":"Le compte à rebours repart. Entre deux portes blindées, le simulateur restitue un exercice de couverture avec James.",
		"final":"Magician attend dans la dernière chambre. G retient la porte pendant que Kate cherche une ouverture dans la couronne de feu.",
		"ending":"Kate et G quittent la chambre avant la fermeture des cloisons. L’AMS conserve la bande du compte à rebours pour sa prochaine équipe."},
	"scarlet": {"name":"House of the Dead Scarlet Dawn","place":"Scarecrow Mansion","lead":7,"stage":7,"guests":[6,4,22],"route_stages":[7,7,16],
		"rule":"Éclairage de secours. Un coup lourd confirmé repousse l’adversaire de 60 unités supplémentaires, une fois par manche.",
		"intro":"Ryan et Kate se séparent dans la réception du manoir. Les reflets rouges des appliques bougent sur les portes pendant que les invités cherchent une sortie.",
		"rival":"Dans la reconstitution, le reflet de James se place entre Ryan et le grand escalier. Ryan doit couvrir l’évacuation sans céder son côté de la salle.",
		"final":"Sur le parvis de l’église de Thornheart, des pierres montent vers la cime de Moon. Ryan retrouve Kate au pied des marches. Lorsque le vent tourne, un troisième œil apparaît sur le front de la créature.",
		"ending":"La dernière image de l’église brûle sous l’éclair. L’AMS revient à la réception du manoir. Ryan y reconnaît la fenêtre par laquelle Kate repérait les sorties."},
	"overkill": {"name":"The House of the Dead OVERKILL","place":"Bayou City","lead":8,"stage":8,"guests":[1,14,9],"route_stages":[8,8,14],
		"rule":"Prise continue. Un premier enchaînement de trois touches rend huit points de vie à son auteur.",
		"intro":"À Bayou City, Washington retrouve G sous les ampoules d’un manège arrêté. La bobine du projecteur claque contre le métal de sa boîte.",
		"rival":"La pellicule saute. Dans cette bobine reconstituée, Jasper Guns déforme les enseignes de la foire sans les toucher. Washington reconnaît sa silhouette avant son visage.",
		"final":"Une coupe franche fait passer la bobine du carnaval à un ponton de Fetid Waters. Les pilotis grincent. La reconstitution fait entrer un invité de Loving Deads au bout des planches.",
		"ending":"Isaac arrache le ticket de la dernière séance. G l’attend près du grillage pendant que la musique du manège ralentit."},
	"ex": {"name":"Loving Deads • The House of the Dead EX","place":"Plateau des épreuves","lead":9,"stage":9,"guests":[10,15,2],
		"rule":"Coup de cœur. Une première projection réussie rend dix points de vie à son auteur.",
		"intro":"Zobio rejoint le plateau pour un jeu organisé à l’intention de Zobiko. Une rangée d’ampoules s’allume au bord de la piste.",
		"rival":"La cloche retentit. Zobiko a pris le centre du plateau pour leur exhibition à deux. Zobio doit la suivre du regard lorsqu’elle quitte le sol.",
		"final":"Le rideau s’ouvre sur une silhouette en armure, invitée du manoir Curien. Le dernier numéro commence sous les confettis.",
		"ending":"Zobiko attend Zobio derrière le décor. Ils quittent le plateau ensemble avant que les machineries n’abaissent le rideau."},
	"revenge": {"name":"Zombie Revenge","place":"Rue en quarantaine","lead":10,"stage":10,"guests":[8,16,12],
		"rule":"Combat de rue. Un premier enchaînement de trois touches prolonge la manche de cinq secondes.",
		"intro":"Stick Breitling revient dans la rue bouclée. Le bitume porte encore les traces de la dernière évacuation et un néon grésille au-dessus du trottoir.",
		"rival":"Rikiya Busujima se tient de l’autre côté du barrage. La simulation fait rejouer aux deux partenaires un duel d’entraînement au milieu de la rue.",
		"final":"Une silhouette massive franchit le cordon. Le dernier exercice de rue oppose Stick à la massue de Death.",
		"ending":"Stick repousse du pied la grille abandonnée. Les agents peuvent traverser le carrefour. Il suit le gyrophare jusqu’au prochain barrage."}
}

const HUD_RULES := {
	"hotd2":"Secours du quai · 3 touches enchaînées   +3 s",
	"hotd3":"Relève EFI · projection confirmée   +6 PV",
	"hotd4":"Ravitaillement · 3 touches enchaînées   magasin plein",
	"special":"Compte à rebours · spécial confirmé   +5 s",
	"scarlet":"Éclairage de secours · lourd confirmé   recul accru",
	"overkill":"Prise continue · 3 touches enchaînées   +8 PV",
	"ex":"Coup de cœur · projection confirmée   +10 PV",
	"revenge":"Combat de rue · 3 touches enchaînées   +5 s"
}
const ALTERNATE_STORIES := {
	23: ["Linda vérifie son chargeur derrière le barrage. Dans cette reconstitution de l’AMS, Stick lui sert de partenaire pour répéter une progression entre les véhicules abandonnés. Une radio grésille au fond de la rue.",
		"Rikiya attend à l’autre extrémité du passage. Leur exercice oppose la courte glissade de Linda à la portée de sa paume. Elle doit choisir son angle avant de s’engager.",
		"Le simulateur introduit un sujet des archives EFI : Death bloque la sortie du secteur. Linda attend le choc de la massue pour rejoindre la dernière couverture.",
		"La lumière d’une voiture balaie le trottoir. Linda range son pistolet et signale à Stick et Rikiya que le passage est libre. L’AMS arrête le relevé au moment où les trois agents quittent le barrage."],
	21: ["Le relevé AMS dépose le sujet β sur le quai du métro. Une ligne de glace court jusqu’aux pieds de James. Dans le verre d’une rame, le cœur de The World bat encore.",
		"Entre deux rames, Justice se libère du givre. Ses quatre mains cherchent le même appui sur les portes gelées. The World relève son bras.",
		"La cour de Goldman a remplacé les rails. Kate se tient au bord de la dalle fendue. Dans le cœur de la créature, elle distingue la lueur de sa propre lampe.",
		"Les dalles de la cour se réchauffent. Un éclat de glace tient encore dans la paume d’un gant abandonné. Lorsqu’il fond, l’AMS arrête l’enregistrement."],
	22: ["Dans le hall de Scarecrow Mansion, une racine perce le dallage devant Kate. Le relevé AMS ramène le corps de Moon à l’échelle du hall. La poussière monte jusqu’au plafond.",
		"Le simulateur projette James devant un vitrail brisé. Son reflet se disperse à mesure que les feuilles se soulèvent autour de Moon.",
		"Sur le parvis, Ryan entend Kate derrière lui. Le front de Moon émerge des branches et le dernier duel du relevé commence sous l’orage.",
		"Après l’éclair, le vent retombe devant les marches. Sur la pierre mouillée, une rose bleue tient encore à sa tige. Le microphone ne capte plus que la pluie."],
	17: ["Une sphère d’argent roule sous l’horloge. Gary relève la tête. Les autres sphères se rassemblent derrière lui et le modèle Alpha prend forme dans le relevé de l’AMS.",
		"Sur le quai, les sphères entourent les trois pointes du trident. Le reflet de Hierophant se plisse. Emperor étire son bras jusqu’à donner au métal leur longueur.",
		"Au sommet de la tour, James retrouve la sphère qui manque à la couronne. Le modèle reconstitué d’Emperor la rappelle à lui et engage le dernier duel.",
		"La silhouette se défait. Chaque sphère reflète le ciel sous un angle différent. Une seule reste suspendue devant le capteur lorsque la bande s’arrête."],
	18: ["Le moniteur EFI affiche une roue immobile et une silhouette devant le poste de garde. Daniel reconnaît l’anneau. Le simulateur remet le mécanisme en mouvement.",
		"La massue de Death frappe la dalle. La roue passe dans le creux laissé entre deux coups et revient fermer le passage.",
		"Dans la chambre d’incubation, Lisa lève son arme vers l’emblème. La roue couvre le ronflement du réacteur une révolution de plus.",
		"La roue achève son tour sans un bruit. Un cercle de condensation persiste sur la vitre de la chambre après l’arrêt des capteurs."],
	19: ["Sous la tour de l’horloge, Gary repère une sortie pour les civils. James lui barre le passage pour un exercice de couverture. Gary vérifie l’espace laissé derrière son talon.",
		"Hierophant affleure à la surface du canal. Gary attend que le trident découvre le parapet pour prendre du recul et dégager son angle de tir.",
		"Sur le toit, les sphères d’Emperor se détachent une par une. Derrière Gary, il ne reste qu’un pas avant la rambarde.",
		"Gary récupère la radio de James et lève les yeux vers la ville. Sous la tour de l’horloge, une lampe vient de se rallumer."],
	20: ["Daniel entend Lisa frapper de l’autre côté du volet de sécurité. Le relevé de l’AMS leur donne un couloir vide pour répéter la relève avant l’ouverture du sas.",
		"Le sol vibre sous les pas de Death. Daniel compte ses cartouches et laisse la masse passer dans l’embrasure avant de relever le canon.",
		"Dans la chambre d’incubation, Daniel entend la voix de son père. Le disque électrifié s’écarte du corps de Wheel of Fate et revient couper sa retraite.",
		"Daniel garde la main sur la paroi froide du réacteur jusqu’à l’arrêt de la dernière vibration. Dans le couloir, Lisa lui tient la porte ouverte."],
	14: ["La bobine commence sans bande sonore. Autour de Jasper, trois boulons se soulèvent au-dessus des dalles humides du champ de foire.",
		"Washington entre dans le cadre. Jasper incline la tête. Sur les bords de la pellicule, les marques de perforation se tordent.",
		"Le dernier raccord transporte Jasper au bord du bayou. Le projecteur éclaire un invité de Loving Deads sur les planches du ponton.",
		"Une enseigne retombe au bord de la piste. La bobine continue de tourner, avec un bruit régulier, dans le projecteur abandonné."],
	15: ["Zobiko fait signe au régisseur. Une ampoule dessine le bord de la scène. Derrière le rideau, Zobio attend son tour.",
		"Zobio prend position pour leur numéro en duo. Zobiko choisit l’endroit où retomber avant même le coup de cloche.",
		"L’armure d’un invité du manoir fait pencher la piste. Zobiko reprend son élan sous les lumières de la dernière épreuve.",
		"Le rideau redescend. Zobiko glisse sa main dans celle de Zobio et emporte l’ampoule rose restée allumée à leurs pieds."],
	16: ["Rikiya écoute le grésillement d’un poteau électrique. De l’autre côté du carrefour, un agent a laissé ses gants sur une barrière.",
		"Stick ferme le passage près du passage piéton. Pour cet entraînement, les partenaires ont convenu que le premier à reculer laissera l’autre passer.",
		"Un sujet issu des archives d’EFI entre dans le secteur. Rikiya garde la paume ouverte et attend que la massue touche le sol.",
		"Le bruit de la massue s’est arrêté. Rikiya traverse la rue et dépose les gants de Stick sur le capot de la voiture de liaison."],
	11: ["Le premier reflet est celui d’un trident. Entre les piliers du quai, le sujet attend que la silhouette déposée par l’AMS entre dans l’eau.",
		"James prend position sur la berge. Chaque fois que le sujet retire le trident, le moniteur perd le point exact où la pointe a touché le quai.",
		"L’AMS transporte le relevé sur le toit Goldman. L’eau s’égoutte encore du trident quand les sphères d’Emperor forment une pointe d’argent.",
		"Lorsque le trident passe sous la surface, l’AMS coupe le son. Il reste trois sillons sur le quai et une image inexploitable du canal."],
	12: ["Le poste de garde donne encore accès aux anciennes caméras. L’une d’elles ne montre que la tête d’une massue, cadrée trop près.",
		"Une ombre s’avance dans le couloir. Death s’arrête devant Lisa et laisse glisser la massue le long de la porte.",
		"Le relevé traverse une cloison et s’ouvre sur la chambre d’incubation. La massue de Death se reflète dans l’anneau de Wheel of Fate.",
		"La massue heurte le carrelage après la fin de l’enregistrement. Le microphone du poste de sécurité transmet encore un choc, puis se tait."],
	13: ["Sur le plan de la station, deux couloirs communiquent avec les quais. L’enregistrement de Justice commence exactement entre les deux.",
		"Kate traverse le passage central. Le sujet écarte ses quatre bras. Les caméras du quai perdent simultanément le visage de l’agente.",
		"Le dernier train virtuel cesse de défiler. L’enregistrement transporte Justice dans la cour où une pellicule de glace gagne les dalles autour de The World.",
		"Le panneau d’affichage est éteint. Dans son reflet, quatre mains se referment encore sur les montants des portes."],
	1: ["G rejoint Kate à l’entrée du complexe. Le nouvel exercice lui confie la couverture pendant que sa partenaire ouvre le passage.",
		"Un relevé de James réapparaît entre deux cloisons. G identifie l’écho dans sa radio avant d’avancer.",
		"Le brassard de Kate disparaît derrière la porte. G retrouve Magician dans la chambre où s’arrête la piste.",
		"La chambre est vide. G rejoint Kate à l’air libre et inscrit l’heure exacte de l’évacuation sur le dossier."]
}

static func stages_for(case_id: String, chosen: int) -> Array:
	var dossier: Dictionary = CASES[case_id]
	var route_stages: Array = dossier.get("route_stages", [dossier.stage, dossier.stage, dossier.stage]).duplicate()
	if case_id == "hotd2" and chosen in [17,19]: route_stages[0] = 13
	return route_stages

static func opponents(case_id: String, chosen: int) -> Array:
	if case_id == "revenge" and chosen == 23: return [10,16,12]
	var dossier: Dictionary = CASES[case_id]
	var rivals: Array = dossier.guests.duplicate()
	if chosen in rivals:
		rivals[rivals.find(chosen)] = int(dossier.lead)
	return rivals

static func apply_rule(arena, case_id: String) -> void:
	for side in 2:
		if arena.rule_awarded[side]: continue
		var f = arena.fighters[side]
		var trigger := false
		match case_id:
			"hotd2","revenge","hotd4","overkill":
				trigger = f.combo >= 3
			"hotd3","ex":
				trigger = f.action == "throw" and f.confirmed
			"special":
				trigger = f.action == "special" and f.confirmed
			"scarlet":
				trigger = f.action == "heavy" and f.confirmed
		if not trigger: continue
		arena.rule_awarded[side] = true
		match case_id:
			"hotd2": arena.clock_ticks += 180
			"revenge","special": arena.clock_ticks += 300
			"hotd4": f.ammo = f.profile.ammo
			"hotd3": f.health = mini(100, f.health + 6)
			"ex": f.health = mini(100, f.health + 10)
			"overkill": f.health = mini(100, f.health + 8)
			"scarlet": arena.fighters[1-side].x += f.facing * 60
