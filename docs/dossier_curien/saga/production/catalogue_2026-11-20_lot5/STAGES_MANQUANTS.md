# Stages et familles de zones — état après le lot 5

**63 lignes suivies face aux 29 arènes du projet : 22 adaptations dédiées, 8 adaptations partielles, 26 lignes absentes et 7 lignes demandant encore une référence.** Ces nombres ne sont ni un quota de nouvelles arènes ni une mesure de complétude de la saga.

État du **20 novembre 2026 — Europe/Paris**, après main `6da249f2`. Le [JSON courant](stages_manquants.json) conserve les 61 IDs précédents dans leur ordre et ajoute `zr_edward_street` et `zr_cassandra`. L’[inventaire du lot 4](../catalogue_2026-11-20_lot4/STAGES_MANQUANTS.md) reste inchangé.

## Changements du lot

| Ligne | Arène ajoutée | Portée |
|---|---|---|
| `hotd2_rues` | 26 — Place d’A Prelude | Place latérale HOTD2, façades, tour et pavés recoupés avec trois captures du guide arcade/Wii. Plateforme exacte non établie ; autres branches ouvertes. |
| `overkill_hospital` | 27 — Hôpital — Ballistic Trauma | Salle commune du troisième étage d’après le guide PS3. Élargissement latéral et porte adaptés ; salle du Screamer non livrée. |
| `zr_plant` | 28 — Usine chimique — Zombie Revenge | Salle de réservoirs et plateformes d’après le storyboard 6 ; carton **Area 4 — Chemical Plant** visible. Détails et projection latérale interprétés. |

Les trois arènes apportent **neuf PNG natifs**, fond et deux plans de parallaxe pour chacune. Voir le [manifeste](../stages_2026-11-20_lot5/manifest.json) et le [rapport des décors](../stages_2026-11-20_lot5/RAPPORT.md). « Existant » désigne cette adaptation dédiée, sans déclarer le chapitre terminé.

### Correction Zombie Revenge

L’ancien listing numérotait sept familles depuis une galerie. Le longplay Dreamcast distingue neuf Areas. Les titres **Area 2 — Edward Street**, **Area 3 — Industrial Sewage Plant** et **Area 4 — Chemical Plant** sont directement lisibles dans les captures retenues ; les autres noms et leur ordre reposent sur le chapitrage auteur. Edward Street et Cassandra sont ajoutées comme manques. `zr_river` et `zr_plant` gardent leurs IDs, mais leurs noms et numéros sont corrigés.

**Aucun titre Cassandra lisible n’a été conservé.** L’intérieur industriel visible après le train est associé par séquence et chapitrage. Une confirmation visuelle du titre reste requise. Les références sont des storyboards natifs, cellules 320×180, sans agrandissement. Voir [l’index des captures](../../../../../docs/dossier_curien/sources_art/references-2026-11-20_lot5/stages/source_index.json) et [le chapitrage retenu](../../../../../docs/dossier_curien/sources_art/references-2026-11-20_lot5/stages/zr_longplay_chapters.json).

## Sens des statuts

| Statut | Sens |
|---|---|
| `existant` | Une arène dédiée à ce lieu est enregistrée et possède son art. Cela signifie une adaptation 2D disponible, jamais un chapitre complet ni une fidélité 1:1 certifiée. |
| `adaptation_partielle` | Une évocation, une portion, ou un état d’un autre épisode existe ; les éléments explicités restent à réaliser. |
| `absent` | Lieu identifié dans les sources, sans arène dédiée correspondante parmi les 29 entrées. Une ligne peut regrouper plusieurs variantes. |
| `reference_requise` | L’épreuve/le contexte est connu, mais son lieu précis, ses variantes ou une référence visuelle exploitable restent à établir. Ce statut ne ferme pas le manque. |

## The House of the Dead

Quatre chapitres : Tragedy, Revenge, Truth, The house of the dead. Grands lieux et une branche majeure ; les salles et tous les embranchements ne sont pas détaillés.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `hotd_cour` | Tragedy | Cour et entrée du manoir | `existant` | 0 — Cour du manoir | Variantes de parcours et autres cadrages. Arène 0 : Cour du manoir ; présence d’une adaptation, pas du chapitre entier. Sources : [H1B](#h1b). |
| `hotd_interieurs` | Tragedy / Revenge | Intérieurs du manoir et annexe | `adaptation_partielle` | 1 — Antichambre | Décor propre à l’annexe et aux grandes salles au-delà de l’antichambre. L’antichambre représente une seule zone intérieure. Sources : [H1](#h1). |
| `hotd_egouts` | Tragedy — embranchement | Égouts du domaine | `absent` | — | Choisir une capture de la branche, puis produire les plans latéraux.  Sources : [H1B](#h1b). |
| `hotd_toits` | Revenge | Toits du manoir / Hangedman | `existant` | 24 — Terrasse de Hangedman | Autres voies et cadrages des toits ; revanche souterraine de Hangedman distincte. Arène 24 : terrasse latérale adaptée des captures arcade. Aucun décor Scarlet Dawn ni parcours complet revendiqué. Sources : [H1R](#h1r) · [H1ARCADE_CAPTURE](#h1arcade_capture). |
| `hotd_dome` | Truth | Dôme de culture / Hermit | `existant` | 25 — Dôme de culture — Hermit | Tunnel de poursuite d’Hermit, accès et autres cadrages du dôme. Arène 25 : salle verte d’apparition d’Hermit ; trois plans dédiés. Le tunnel est archivé comme contexte, pas livré. Sources : [H1T](#h1t) · [H1ARCADE_CAPTURE](#h1arcade_capture). |
| `hotd_laboratoire` | Truth / The house of the dead | Laboratoire de Curien | `existant` | 2 — Laboratoire de Curien | Autres secteurs, voies d’accès et variations finales. Arène 2 disponible ; aucune reproduction intégrale des deux chapitres. Sources : [H1T](#h1t) · [H1](#h1). |

## The House of the Dead 2

Six chapitres ; certains comportent plusieurs grands lieux et branches. La colonne lieu fixe ce qui est évalué.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `hotd2_rues` | A Prelude | Rues et place de la première rencontre | `existant` | 26 — Place d’A Prelude | Autres rues, secours et embranchements d’A Prelude ; cadrages supplémentaires de la place. Arène 26 : adaptation latérale dédiée depuis trois captures. Guide arcade/Wii, plateforme exacte non établie. Une place adaptée ne livre pas tout le chapitre. Sources : [H2](#h2) · [H2P_CAPTURE](#h2p_capture). |
| `hotd2_quai` | Muddy | Canal / quai de Hierophant | `existant` | 3 — Quai de la cité inondée | Autres branches, berges et cadrages. Arène 3 : Quai de la cité inondée. Sources : [H2M](#h2m). |
| `hotd2_horloge` | Muddy — branche | Passage de la tour de l’horloge | `existant` | 13 — Passage de la tour de l’horloge | Variantes et contexte de l’embranchement. Le passage est lié à Muddy, pas au Colisée de Despair. Sources : [H2M](#h2m). |
| `hotd2_souterrain` | Darkness | Voie d’eau souterraine / parcours de Tower | `existant` | 20 — Canal souterrain — Tower | Branche sable de Tower, autres parcours du canal et reprise au siège Goldman. Arène20 : variante aquatique. Berge de combat ajoutée pour une composition latérale ; géométrie originale non certifiée. Sources : [H2D](#h2d) · [H2T_OFFICIAL](#h2t_official) · [H2C3_CAPTURE](#h2c3_capture). |
| `hotd2_colisee` | Despair | Colisée / Strength | `existant` | 21 — Colisée — Strength | Variante aux murs sombres et autres chemins du labyrinthe. Arène21 : murs clairs, partitions de pierre et cage. Ancienne mention de bassin retirée faute de preuve dans les captures inspectées. Sources : [H2C](#h2c) · [H2S_OFFICIAL](#h2s_official) · [H2C4_CAPTURE](#h2c4_capture). |
| `hotd2_pont` | Dawn | Pont routier vers Goldman | `absent` | — | Produire la route/pont et son état HOTD2.  Sources : [H2A](#h2a). |
| `hotd2_cour_goldman` | Dawn | Cour du siège Goldman, époque HOTD2 | `adaptation_partielle` | 15 — Parvis du siège Goldman | Décliner une cour HOTD2 correspondant à Magician. Le décor15 est construit pour World dans HOTD4 ; même site narratif, autre état. Sources : [H2A](#h2a) · [HQ](#hq). |
| `hotd2_interieur_goldman` | Original Sin | Intérieurs, laboratoire et bureau de Goldman | `absent` | — | Sélectionner un grand intérieur représentatif.  Sources : [HQ](#hq) · [H2D](#h2d). |
| `hotd2_toit` | Original Sin | Sommet de la tour / Emperor | `existant` | 11 — Toit de la tour Goldman | Autres cadrages de la séquence finale. Arène 11 : Toit de la tour Goldman. Sources : [HQ](#hq). |

## The House of the Dead III

Ch.0 Reminiscence ; ch.1 Chasing Shadows ; ch.2 Bewilderment, ch.3 Sensory Chaos et ch.4 Ultimate Challenge traversent trois familles choisies par le joueur, chacune avec deux variantes ; ch.5 Wheel of Fate. Les variantes ne sont pas six campagnes.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `hotd3_entree` | Reminiscence / Chasing Shadows | Entrée et sécurité du centre EFI | `adaptation_partielle` | 4 — Poste de sécurité EFI | Extérieurs et cadrages du prologue à traiter séparément. Le Poste de sécurité EFI représente une portion de cette arrivée. Sources : [H3](#h3). |
| `hotd3_efi_dbr` | Chapitres 2–4 — zone au choix | EFI Genome Ward / DBR Institute | `adaptation_partielle` | 22 — Enclos du D.B.R. — Fool | Produire les autres secteurs du D.B.R., la branche EFI Genome Ward et leurs variantes de parcours. Arène22 : adaptation latérale de l’enclos de Fool ; sol élargi. Cette seule salle ne clôture pas les deux parcours. Sources : [H3V](#h3v) · [H3FOOL_OFFICIAL](#h3fool_official) · [H3DBR_CAPTURE](#h3dbr_capture) · [H3EFI_ROUTE](#h3efi_route). |
| `hotd3_bio` | Chapitres 2–4 — zone au choix | L2 BIO Plant / L3 BIO Lab | `adaptation_partielle` | 23 — Chambre BIO — Sun | Différencier les chemins et autres secteurs L2 BIO Plant / L3 BIO Lab ; comparer les variantes de salle si nécessaire. Arène23 : chambre industrielle de Sun, cadrage latéral et sol continu adaptés. Ce n’est pas une couverture des deux chapitres. Sources : [H3V](#h3v) · [H3SUN_OFFICIAL](#h3sun_official) · [H3L2_CAPTURE](#h3l2_capture) · [H3L3_ROUTE](#h3l3_route). |
| `hotd3_information` | Chapitres 2–4 — zone au choix | Information Systems Department — ailes est/ouest | `absent` | — | Relever les bureaux et passages de poursuite ; différencier les ailes.  Sources : [H3V](#h3v). |
| `hotd3_incubation` | Wheel of Fate | L4 / chambre d’incubation finale | `existant` | 12 — Chambre d’incubation EFI | Autres secteurs du chapitre et angles de la salle finale. Arène 12 ; sources de la chambre détaillées dans SOURCES_ARENES_III.md. Sources : [H3](#h3). |

## The House of the Dead 4

Six chapitres : Escape, Lost, Emptiness, Despair, Reunion, Hope. Les lieux principaux distincts sont séparés sans inventorier chaque salle.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `hotd4_ams` | Escape | Sous-sols du bureau européen de l’AMS | `absent` | — | Relever les couloirs et ascenseurs de départ. Le poste EFI appartient à III, le métro à une autre zone de 4. Sources : [H4E](#h4e). |
| `hotd4_egouts` | Lost | Égouts / parcours de Lovers | `absent` | — | Produire une galerie d’égout identifiable et la zone d’ascenseur. P1 possible après choix d’une capture. Sources : [H4L](#h4l). |
| `hotd4_metro` | Emptiness | Quai et réseau de métro | `existant` | 5 — Métro souterrain | Autres quais et tunnels. Le décor existe, même si la narration de simulation y fait apparaître Justice. Sources : [H4M](#h4m). |
| `hotd4_train` | Emptiness | Train de l’Empress | `absent` | — | Créer l’intérieur/la toiture spécifique retenue après examen des captures. Ni le quai fixe ni le train Zombie Revenge ne couvrent ce véhicule. Sources : [H4M](#h4m). |
| `hotd4_commerces` | Despair | Quartier commercial souterrain | `absent` | — | Relever les commerces et la progression vers la surface.  Sources : [H4D](#h4d). |
| `hotd4_rue` | Despair | Rue dévastée / Temperance | `existant` | 17 — Rue dévastée de Despair | Autres secteurs et destruction animée. Arène 17 : Rue dévastée de Despair. Sources : [H4D](#h4d). |
| `hotd4_pont` | Reunion | Route et pont vers Goldman | `absent` | — | Produire l’état HOTD4 du trajet routier. Même axe que Dawn, mais pas la même époque. Sources : [H4R](#h4r). |
| `hotd4_interieur_goldman` | Hope | Intérieurs et bureau de Goldman | `absent` | — | Choisir le grand intérieur représentatif ; le parvis ne suffit pas.  Sources : [H4H](#h4h). |
| `hotd4_parvis` | Hope | Parvis / World | `existant` | 15 — Parvis du siège Goldman | Phases, bris et autres cadrages. Arène 15 ; référence décrite dans SOURCES_ARENES_IV.md. Sources : [H4H](#h4h). |

## The House of the Dead 4 Special

Deux stages principaux. Le complexe du projet est une évocation unique, pas deux niveaux reconstitués.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `special_approche` | Stage 1 | Approche extérieure / parcours routier et Justice | `absent` | — | Choisir les captures du trajet puis produire une arène propre au stage 1.  Sources : [SP1](#sp1). |
| `special_laboratoire` | Stage 2 | Installation de recherche / chambre de Magician | `adaptation_partielle` | 6 — Complexe déserté | Confronter le complexe peint aux salles du stage 2 et compléter leur identité. Arène 6 : Complexe déserté ; sa présence ne valide pas tous les lieux de Special. Sources : [SP2](#sp2). |

## House of the Dead: Scarlet Dawn

Prologue Scarecrow Manor ; chapitres 1–3 Kate and Ryan, Homo sapiens, Pandora’s Box selon l’ordre des trois zones ; final A Glimmer of Hope. Les trois routes ne sont pas des campagnes séparées.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `scarlet_reception` | Scarecrow Manor — prologue | Hall et réception | `existant` | 7 — Réception de Scarecrow Mansion | Autres vues et effondrement. Arène 7 : Réception de Scarecrow Mansion. Sources : [SDP](#sdp) · [SD](#sd). |
| `scarlet_annex` | Chapitres 1–3 — zone au choix | Annex | `absent` | — | Relever l’annexe et un espace propre au combat Chariot. La réception ne couvre pas l’annexe. Sources : [SD](#sd). |
| `scarlet_laboratory` | Chapitres 1–3 — zone au choix | Laboratory | `absent` | — | Sélectionner une salle caractéristique du laboratoire. Ne pas réutiliser EFI/Curien comme preuve de présence. Sources : [SDL](#sdl). |
| `scarlet_elevator` | Chapitres 1–3 — zone au choix | Elevator Lobby / toits | `absent` | — | Produire les toits ou le lobby, puis le complément restant. Le toit de Hangedman est spécifique à cette version. Sources : [SDE](#sde). |
| `scarlet_church` | A Glimmer of Hope | Église avant destruction | `absent` | — | Relever l’intérieur et la structure avant le combat final. Les ruines existantes ne couvrent pas l’état intact. Sources : [SD](#sd). |
| `scarlet_ruines` | A Glimmer of Hope | Ruines et terrain de Moon | `existant` | 16 — Ruines du domaine Scarecrow | Autres phases et états du terrain. Arène 16 : Ruines du domaine Scarecrow. Sources : [SDM](#sdm). |

## Overkill / Extended Cut / Typing of the Dead: Overkill

Les neuf titres du parcours Extended Cut sont tous recensés ci-dessous. Cet inventaire n’implique ni toutes les extensions de trajet du mode Director’s Cut ni les mini-jeux.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `overkill_papa` | 1 — Papa’s Palace of Pain | Manoir/plantation de Papa Caesar | `absent` | — | Produire le grand hall ou les abords propres à Overkill. La cour Curien n’est pas ce manoir. Sources : [OV1](#ov1). |
| `overkill_naked` | 2 — Naked Terror | Club, rues et bar de Bayou City | `absent` | — | Commencer par le club documenté par la capture officielle. Chapitre supplémentaire Extended Cut. Sources : [OV2](#ov2). |
| `overkill_hospital` | 3 — Ballistic Trauma | Hôpital | `existant` | 27 — Hôpital — Ballistic Trauma | Autres étages, parcours et salle du Screamer ; comparaison des différences Wii/PS3/PC. Arène 27 : salle commune du troisième étage d’après le guide PS3. Élargissement latéral et porte adaptée depuis le couloir voisin. La salle circulaire rouge du Screamer n’est pas représentée. Sources : [OV3](#ov3) · [OVH_CAPTURE](#ovh_capture). |
| `overkill_carny` | 4 — Carny | Fête foraine | `existant` | 8 — Fête foraine de Bayou City | Autres attractions et parcours. Arène 8. Sources : [OV](#ov) · [OVA](#ova). |
| `overkill_flesh` | 5 — Creeping Flesh | Abattoir infesté | `existant` | 19 — Abattoir — Creeping Flesh | Autres pièces, tunnel organique et variantes de combat. Lot du 20 novembre : adaptation documentée à trois plans. Sources : [OV5](#ov5). |
| `overkill_train` | 6 — Scream Train | Train d’Overkill | `absent` | — | Choisir quai/intérieur/toit, puis produire sa propre composition. L’arène 18 est Zombie Revenge, pas Scream Train. Sources : [OV6](#ov6). |
| `overkill_bayou` | 7 — The Fetid Waters | Marais / ponton du bayou | `existant` | 14 — Ponton du bayou | Autres marais et embarcations. Arène 14 ; sources dans SOURCES_ARENES_III.md. Sources : [OV](#ov). |
| `overkill_jail` | 8 — Jailhouse Judgment | Prison | `absent` | — | Créer un grand secteur de cellules ou la cour. Le jeu/les sources emploient aussi la graphie Judgement. Sources : [OV8](#ov8). |
| `overkill_lab` | 9 — Overkill | Laboratoire souterrain final | `absent` | — | Relever l’installation de recherche et le cadre de Mother. Les laboratoires des autres épisodes ne ferment pas cette ligne. Sources : [OV9](#ov9). |

## Zombie Revenge

Neuf Areas du longplay Dreamcast sont distinguées : Woodside City, Edward Street, Industrial Sewage Plant, Chemical Plant, South Union Railway, Cassandra, Mt. Sacrifice, The House of the Dead et The Dawn. Les titres 2/3/4 sont directement lisibles dans les références retenues ; les autres noms et leur ordre reposent sur le chapitrage de l’auteur. Sous-zones, branches, salles de boss et variantes arcade restent non exhaustives.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `zr_woodside` | Area 1 — Woodside City | Woodside City | `adaptation_partielle` | 10 — Rue en quarantaine | Aligner la rue générique sur des captures précises de Woodside. Arène 10 : Rue en quarantaine, interprétation générique de Zombie Revenge. Ordre et nom selon le chapitrage auteur ; aucun recalage du décor au lot 5. Sources : [ZR_CHAPTERS](#zr_chapters). |
| `zr_edward_street` | Area 2 — Edward Street | Ruelles et accès de service d’Edward Street | `absent` | — | Documenter une vue lisible puis composer les trois plans ; aucune arène dédiée encore livrée. Nouvelle ligne du lot 5. Titre AREA2 EDWARD STREET visible en haut au centre du storyboard 2, partiellement recouvert par le personnage. Ruelles de briques distinctes de la rue générique du projet. Sources : [ZR_LONGPLAY](#zr_longplay) · [ZR_CHAPTERS](#zr_chapters). |
| `zr_river` | Area 3 — Industrial Sewage Plant | Installation d’assainissement industrielle / cours d’eau souterrain | `absent` | — | Relever murs, conduites, plateformes et courant depuis les captures ; produire les plans dédiés. ID historique zr_river conservé. Titre AREA3 INDUSTRIAL SEWAGE PLANT lisible sur le storyboard 3 ; le canal HOTD2 ne couvre pas ce site. Sources : [ZR_LONGPLAY](#zr_longplay) · [ZR_CHAPTERS](#zr_chapters). |
| `zr_plant` | Area 4 — Chemical Plant | Usine chimique / Chemical Plant | `existant` | 28 — Usine chimique — Zombie Revenge | Autres sections, bureaux et salle de boss ; références plus détaillées pour les tuyaux et garde-corps. Arène 28 : réservoirs, colonnes vertes et plateformes adaptés depuis le storyboard 6. Titre AREA4 CHEMICAL PLANT visible sur le storyboard 5. Cellules 320×180 ; composition latérale et détails interprétés. Sources : [ZR_LONGPLAY](#zr_longplay) · [ZR_CHAPTERS](#zr_chapters). |
| `zr_train` | Area 5 — South Union Railway | Toit du train dans le tunnel | `existant` | 18 — Toit du train — Zombie Revenge | Intérieur, extérieur nocturne et autres sections du train. Arène 18 : un segment du toit dans le tunnel, pas toute l’Area 5. Ordre et nom selon le chapitrage auteur ; décor antérieur conservé. Sources : [ZRT](#zrt) · [ZR_CHAPTERS](#zr_chapters). |
| `zr_cassandra` | Area 6 — Cassandra | Cassandra — intérieur industriel après le train | `absent` | — | Confirmer un carton Cassandra lisible et relever la pièce avec des captures détaillées avant génération. Nouvelle ligne du lot 5. Nom et ordre selon le chapitrage auteur ; intérieur industriel jaunâtre visible sur les storyboards 10/11 après le train. Aucun titre Cassandra lisible conservé : association par séquence, pas lecture directe d’un carton. Sources : [ZR_CHAPTERS](#zr_chapters) · [ZR_LONGPLAY](#zr_longplay). |
| `zr_gate` | Area 7 — Mt. Sacrifice | Mt. Sacrifice — famille historique The Gate | `absent` | — | Récupérer un carton de jeu et des captures pour fixer le cadrage de Mt. Sacrifice ; aucune architecture déduite du nom seul. ID historique zr_gate conservé. Ancien libellé The Gate retiré de la numérotation ; Mt. Sacrifice/Area 7 proviennent du chapitrage auteur, sans carton visuel de cette zone retenu au lot 5. Sources : [ZR_CHAPTERS](#zr_chapters). |
| `zr_house` | Area 8 — The House of the Dead | Manoir tel que parcouru dans Zombie Revenge | `absent` | — | Comparer le parcours ZR aux décors HOTD existants avant mutualisation. Ordre et nom selon le chapitrage auteur. Les arènes HOTD 0–2 ne prouvent pas une adaptation du parcours propre à Zombie Revenge. Sources : [ZR_CHAPTERS](#zr_chapters). |
| `zr_dawn` | Area 9 — The Dawn | The Dawn / zone finale | `absent` | — | Choisir une vue documentée de la dernière zone. Ordre et nom selon le chapitrage auteur ; architecture et phases finales restent à relever. Sources : [ZR_CHAPTERS](#zr_chapters). |

## Loving Deads: The House of the Dead EX

Recensement limité au laboratoire de départ et aux six mini-jeux du verso du flyer SEGA inspecté. L’ordre, les chapitres, variantes et autres épreuves restent à documenter ; aucune exhaustivité n’est annoncée.

| ID | Chapitre / Area | Lieu | Statut | Arène liée | Travail restant et preuve |
|---|---|---|---|---|---|
| `ex_plateau` | Synthèse du projet | Plateau générique des épreuves | `adaptation_partielle` | 9 — Plateau de Loving Deads | Rattacher chaque décor futur à une épreuve réellement montrée. Arène 9 est une interprétation de l’ambiance EX, pas la preuve de six mini-jeux représentés. Sources : [EXF](#exf). |
| `ex_laboratoire` | Départ / fuite | Laboratoire de départ | `reference_requise` | — | Obtenir des captures de l’introduction et du lieu avant de cadrer l’arène. Le contexte est officiel ; la géométrie exploitable n’est pas établie. Sources : [EXP](#exp). |
| `ex_zombz` | Mini-jeu — ZomB’z | Scène musicale / projecteurs | `reference_requise` | — | Obtenir une capture plus grande de l’épreuve. Titre du flyer ; le plateau9 n’est pas identifié à cette scène. Sources : [EXF](#exf). |
| `ex_bowling` | Mini-jeu — Zombie Bowling | Piste de bowling | `reference_requise` | — | Obtenir une vue lisible de la piste et du fond. Traduction de travail du titre japonais. Sources : [EXF](#exf). |
| `ex_sumo` | Mini-jeu — sumo | Dohyō / ring de sumo | `reference_requise` | — | Relever le ring et son environnement. Traduction de travail ; vignette primaire trop petite pour un contrat visuel complet. Sources : [EXF](#exf). |
| `ex_apples` | Mini-jeu — cueillette de pommes | Verger | `reference_requise` | — | Relever arbres, terrain et barrières. Mini-jeu visible dans le flyer ; variantes non recensées. Sources : [EXF](#exf). |
| `ex_flying` | Mini-jeu — Flying zoneB | Entrepôt / parcours de vol | `reference_requise` | — | Récupérer une capture de l’entrepôt à résolution exploitable.  Sources : [EXF](#exf). |
| `ex_lifting` | Mini-jeu — Zombie Lifting | Zone de jonglage | `reference_requise` | — | Identifier le lieu derrière les personnages et les éléments de jeu. Pas de nom de salle inventé à partir de la seule vignette. Sources : [EXF](#exf). |

## Arènes du registre

Les 29 indices sont reliés au moins à une ligne. Ce sont des adaptations 2D, sans certification 1:1.

| Index | Nom | Clé graphique |
|---:|---|---|
| 0 | Cour du manoir | `` |
| 1 | Antichambre | `` |
| 2 | Laboratoire de Curien | `` |
| 3 | Quai de la cité inondée | `venice` |
| 4 | Poste de sécurité EFI | `efi` |
| 5 | Métro souterrain | `subway` |
| 6 | Complexe déserté | `special` |
| 7 | Réception de Scarecrow Mansion | `scarlet` |
| 8 | Fête foraine de Bayou City | `carnival` |
| 9 | Plateau de Loving Deads | `ex` |
| 10 | Rue en quarantaine | `revenge` |
| 11 | Toit de la tour Goldman | `goldman` |
| 12 | Chambre d’incubation EFI | `reactor` |
| 13 | Passage de la tour de l’horloge | `clocktower` |
| 14 | Ponton du bayou | `bayou` |
| 15 | Parvis du siège Goldman | `worldstage` |
| 16 | Ruines du domaine Scarecrow | `moonstage` |
| 17 | Rue dévastée de Despair | `citydespair` |
| 18 | Toit du train — Zombie Revenge | `zr_train` |
| 19 | Abattoir — Creeping Flesh | `creeping_flesh` |
| 20 | Canal souterrain — Tower | `tower_canal` |
| 21 | Colisée — Strength | `strength_colosseum` |
| 22 | Enclos du D.B.R. — Fool | `fool_enclosure` |
| 23 | Chambre BIO — Sun | `sun_bio` |
| 24 | Terrasse de Hangedman | `hangedman_roof` |
| 25 | Dôme de culture — Hermit | `hermit_dome` |
| 26 | Place d’A Prelude | `prelude_square` |
| 27 | Hôpital — Ballistic Trauma | `overkill_hospital` |
| 28 | Usine chimique — Zombie Revenge | `zr_chemical_plant` |

## Portées complémentaires

### The Typing of the Dead / éditions de frappe liées à HOTD2 ; The Typing of the Dead2 ; Typing Overkill ; 2&3 Return

Statut : `adaptation_partielle`. Réutiliser les familles de lieux du jeu source lorsqu’une équivalence est établie. Ne pas multiplier automatiquement les arènes pour une même carte ; interfaces et cadrages propres restent à examiner. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

### Remake du premier jeu / HOTD2 Remake

Statut : `reference_requise`. Campagnes apparentées ; l’état visuel, les embranchements et les modifications propres aux remakes demandent une comparaison distincte. Les adaptations classiques ne certifient pas ces variantes. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

### Overkill — The Lost Reels

Statut : `reference_requise`. Inventorier les bobines mobiles réellement disponibles et leurs lieux ; ne pas recopier sans vérification les neuf chapitres PS3. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

### The Pinball of the Dead, English of the Dead, Darts of the Dead et variantes de saisie

Statut : `reference_requise`. Documenter tables, écrans et mini-jeux propres avant d’en déduire des arènes. Aucun nombre de nouveaux lieux n’est affirmé ici. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

### The Site of the Dead, Mobile, Nightmare et services téléphoniques

Statut : `reference_requise`. Recenser les écrans et lieux à partir de captures identifiables par version ; ce backlog ne transforme pas les noms de produits en lieux inventés. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

### Attractions Scarlet Dawn, Battle Genesis / On Reels, Reawakened

Statut : `reference_requise`. Traiter les dispositifs et missions propres dans un audit dédié. Les sources de produits sont recensées dans SOURCES_SAGA.json ; aucun lieu supplémentaire n’est déclaré confirmé ici. Source : [SOURCES_SAGA.json](../../../../../docs/dossier_curien/saga/SOURCES_SAGA.json).

## Sources

Une notice textuelle ne remplace pas une référence visuelle. Les sources historiques conservées ne sont pas présentées comme toutes réexaminées au lot 5.

### H1

[HOTD — nomenclature des chapitres du guide officiel (notice/transcription)](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_Official_Guide) — `secondary_catalogue_of_official_guide`. Quatre chapitres ; la notice n’est pas une planche visuelle de référence.

### H1B

[HOTD — parcours et branche des égouts](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_%281997_video_game%29) — `secondary_encyclopedia`. Structure du premier jeu et embranchement de Tragedy.

### H1T

[Truth — laboratoire et dôme de culture](https://thehouseofthedead.fandom.com/wiki/Truth) — `secondary_encyclopedia`. Checkpoint, laboratoire, dôme de culture d’Hermit.

### H1R

[Hangedman — lieu du combat original](https://thehouseofthedead.fandom.com/wiki/Hangedman) — `secondary_encyclopedia`. Toits du manoir ; distinguer le design original de Scarlet Dawn.

### H2

[HOTD2 — chapitres](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_2) — `secondary_encyclopedia`. Six titres de chapitres.

### H2M

[HOTD2 — chapitre Muddy illustré](https://www.k-triggerhappy.com/hod2/chapter2.html) — `gameplay_capture_walkthrough`. Canaux, quai et branche de l’horloge ; captures de jeu.

### H2D

[HOTD2 — Darkness et sites du mode Original](https://thehouseofthedead.fandom.com/wiki/Original_Mode) — `secondary_encyclopedia`. Canaux et voie d’eau souterraine ; intérieurs de Goldman.

### H2C

[HOTD2 — Despair / Colisée](https://thehouseofthedead.fandom.com/wiki/Despair_%28The_House_of_the_Dead_2_chapter%29) — `secondary_encyclopedia`. Passage souterrain et Colisée de Strength.

### H2A

[HOTD2 — Dawn](https://thehouseofthedead.fandom.com/wiki/Dawn) — `secondary_encyclopedia`. Place, pont routier et cour du siège Goldman.

### HQ

[Siège Goldman — comparaison HOTD2 et HOTD4](https://thehouseofthedead.fandom.com/wiki/Caleb_Goldman%27s_headquarters) — `secondary_encyclopedia`. Même site narratif, intérieurs et états d’époque distincts.

### H3

[HOTDIII — chapitres et ordre des zones](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_III) — `secondary_encyclopedia`. Prologue 0, chapitres 1–5, trois familles de zones choisies pour les chapitres 2–4.

### H3V

[HOTDIII — index illustré des six variantes de zones](https://www.k-triggerhappy.com/hod3/index.html) — `gameplay_capture_walkthrough`. EFI/DBR, L2/L3, Information Systems est/ouest ; captures consultables par zone.

### H4

[HOTD4 — index des six chapitres](https://www.k-triggerhappy.com/hod4/index.html) — `gameplay_capture_walkthrough`. Index et captures par chapitre.

### H4E

[HOTD4 — sous-sols de l’AMS](https://thehouseofthedead.fandom.com/wiki/AMS_European_branch_office) — `secondary_encyclopedia`. Lieu de départ ; distinct du métro et du poste EFI.

### H4L

[HOTD4 — Lost](https://thehouseofthedead.fandom.com/wiki/Lost) — `secondary_encyclopedia`. Égouts et progression vers la surface.

### H4M

[HOTD4 — Emptiness](https://thehouseofthedead.fandom.com/wiki/Emptiness) — `secondary_encyclopedia`. Métro, quai et train de l’Empress.

### H4D

[HOTD4 — Despair](https://thehouseofthedead.fandom.com/wiki/Despair_%28The_House_of_the_Dead_4_chapter%29) — `secondary_encyclopedia`. Quartier marchand souterrain et rues de la ville.

### H4R

[HOTD4 — Reunion](https://thehouseofthedead.fandom.com/wiki/Reunion) — `secondary_encyclopedia`. Retour routier vers Goldman, avec le pont.

### H4H

[HOTD4 — Hope illustré](https://www.k-triggerhappy.com/hod4/chapter6.html) — `gameplay_capture_walkthrough`. Intérieurs du siège et combat de World sur le parvis.

### SP1

[HOTD4 Special — stage1 illustré](https://www.k-triggerhappy.com/hod4/special1.html) — `gameplay_capture_walkthrough`. Progression extérieure/routière et Justice.

### SP2

[HOTD4 Special — stage2 illustré](https://www.k-triggerhappy.com/hod4/special2.html) — `gameplay_capture_walkthrough`. Installation de recherche et chambre de Magician.

### SDP

[Scarlet Dawn — site officiel SEGA](https://hod.sega.jp/) — `primary_publisher`. Présentation de l’infiltration du manoir et de la réception ; les noms précis des routes viennent des sources complémentaires.

### SD

[Scarlet Dawn — chapitres et zones](https://thehouseofthedead.fandom.com/wiki/House_of_the_Dead%3A_Scarlet_Dawn) — `secondary_encyclopedia`. Prologue, trois routes sélectionnables et final.

### SDL

[Scarlet Dawn — Laboratory](https://thehouseofthedead.fandom.com/wiki/Laboratory) — `secondary_encyclopedia`. Laboratoire sélectionnable et High Priestess.

### SDE

[Scarlet Dawn — Elevator Lobby](https://thehouseofthedead.fandom.com/wiki/Elevator_Lobby) — `secondary_encyclopedia`. Ascenseurs, toits et Hangedman.

### SDM

[Scarlet Dawn — confrontation finale illustrée](https://k-triggerhappy.com/blog/hod_scarletdawn-moon/) — `gameplay_capture_walkthrough`. Référence déjà employée par SOURCES_ARENES_IV.md pour les ruines.

### OV

[Overkill Extended Cut — index des neuf chapitres](https://www.k-triggerhappy.com/hodoverkill_ps3/index.html) — `gameplay_capture_walkthrough`. Ordre PS3 et titres des neuf chapitres.

### OVA

[Typing/House of the Dead Overkill — succès officiels du jeu](https://steamcommunity.com/achievements/246580) — `primary_game_metadata`. Confirme les noms des chapitres communs aux deux modes ; le dernier niveau est repris de l’index PS3.

### OV1

[Papa’s Palace of Pain — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage1.html) — `gameplay_capture_walkthrough`. Manoir/plantation et sous-sol.

### OV2

[Naked Terror — annonce officielle](https://blog.playstation.com/2011/08/01/house-of-the-dead-overkill-naked-terror-revealed/) — `primary_publisher_promotion`. Club, rues et bar ; capture de presse.

### OV3

[Ballistic Trauma — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage3.html) — `gameplay_capture_walkthrough`. Hôpital.

### OV5

[Creeping Flesh — annonce officielle](https://blog.playstation.com/2011/08/30/house-of-the-dead-overkill-extended-cut-creeping-flesh-level-reveal/) — `primary_publisher_promotion`. Abattoir et infestation organique ; capture fournie à la génération.

### OV6

[Scream Train — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage6.html) — `gameplay_capture_walkthrough`. Train propre à Overkill.

### OV8

[Jailhouse Judgment — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage8.html) — `gameplay_capture_walkthrough`. Prison.

### OV9

[Overkill — parcours final illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage9.html) — `gameplay_capture_walkthrough`. Installation de recherche souterraine.

### ZR

[Zombie Revenge — galerie Dreamcast utilisée dans les lots antérieurs](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/) — `contributed_gameplay_captures`. Référence historique des sept familles de l’ancien inventaire. Ses légendes ne suffisent pas à établir l’ordre des neuf Areas ; la nomenclature courante est corrigée au lot 5.

### ZRP

[Zombie Revenge — fiche officielle SEGA](https://www.sega.jp/history/arcade/product/8161/) — `primary_publisher`. Fiche SEGA conservée pour le contexte général. Le décompte des neuf Areas Dreamcast et leurs noms reposent ici sur les captures et le chapitrage distincts ; ne pas assimiler automatiquement le découpage global en stages à ces Areas.

### ZRT

[Zombie Revenge — toit du train](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/1117675/) — `contributed_gameplay_capture`. Source du toit dans le tunnel adapté pour l’arène 18.

### EXP

[Loving Deads EX — fiche officielle SEGA](https://www.sega.jp/history/arcade/product/8762/) — `primary_publisher`. Fuite du laboratoire et mini-jeux coopératifs ; page en maintenance lors de l’ouverture directe du 20 novembre, contenu de recherche consulté.

### EXF

[Loving Deads EX — flyer SEGA, verso](https://flyers.arcade-museum.com/videogames/show/5803) — `primary_promotional_artifact_secondary_host`. Six mini-jeux montrés, pas un inventaire complet. Scan du dépôt inspecté.

### H2T_OFFICIAL

[SEGA — Tower, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/tower.html) — `official_publisher_guide`. Variantes eau/sable, cinq têtes et phase finale.

### H2S_OFFICIAL

[SEGA — Strength, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/strength.html) — `official_publisher_guide`. Parcours est/ouest du Colisée.

### H2C3_CAPTURE

[Trigger Happy — captures du chapitre 3](https://www.k-triggerhappy.com/hod2/chapter3.html) — `community_gameplay_captures`. Captures boss3-1 et boss3-2 réellement inspectées.

### H2C4_CAPTURE

[Trigger Happy — captures du chapitre 4](https://www.k-triggerhappy.com/hod2/chapter4.html) — `community_gameplay_captures`. Captures des murs clairs/sombres et cage inspectées.

### H3FOOL_OFFICIAL

[SEGA — Type0028 Fool, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type0028_fool_1.html) — `official_publisher_guide`. Enclos grillagé et passerelles ; image Fool_01 réellement inspectée.

### H3SUN_OFFICIAL

[SEGA — Type8830 Sun, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type8830_sun.html) — `official_publisher_guide`. Salle industrielle BIO ; image Sun_01 réellement inspectée.

### H3DBR_CAPTURE

[Trigger Happy — D.B.R. Institute](https://www.k-triggerhappy.com/hod3/chapter2A.html) — `community_gameplay_captures`. Boss2-2 inspecté ; enclos et escalier. Port de capture non établi.

### H3L2_CAPTURE

[Trigger Happy — L2 BIO Plant](https://www.k-triggerhappy.com/hod3/chapter3A.html) — `community_gameplay_captures`. Boss3-1 et boss3-2 inspectés ; chambre industrielle de Sun. Port non établi.

### H3EFI_ROUTE

[Trigger Happy — EFI Genome Ward](https://www.k-triggerhappy.com/hod3/chapter2B.html) — `community_guide`. Autre branche de la famille, non clôturée par le nouvel enclos.

### H3L3_ROUTE

[Trigger Happy — L3 BIO Lab](https://www.k-triggerhappy.com/hod3/chapter3B.html) — `community_guide`. Autre branche BIO, non clôturée par la nouvelle salle.

### H1ARCADE_CAPTURE

[HOTD original — captures arcade Model 2, Hangedman et Hermit](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — `community_hosted_original_gameplay_captures`. Sept images inspectées ; cinq entrées visuelles de génération. Captures arcade japonaises selon l’auteur. Toit, dôme et distinction du tunnel.

### H2P_CAPTURE

[HOTD2 — place et rue d’A Prelude, captures de jeu](https://www.k-triggerhappy.com/hod2/chapter1.html) — `community_gameplay_captures`. Captures chapter1-1, boss1-1 et boss1-2 inspectées : façades, tour crénelée, lampadaires et sol. Guide arcade/Wii ; plateforme exacte des captures non établie.

### OVH_CAPTURE

[Overkill PS3 — salle commune de Ballistic Trauma](https://www.k-triggerhappy.com/hodoverkill_ps3/stage3.html) — `community_gameplay_captures`. Captures civ3-3 (salle commune du troisième étage) et civ3-2 (couloir adjacent). Édition PS3 Extended Cut / Director’s Cut ; la salle du Screamer n’est pas livrée.

### ZR_LONGPLAY

[Zombie Revenge — Dreamcast Longplay (1080p 60fps), Retronomicon / NVSGamer](https://www.youtube.com/watch?v=ne37UXflHqw) — `community_gameplay_video_and_native_storyboards`. Titres Area 2 Edward Street, Area 3 Industrial Sewage Plant et Area 4 Chemical Plant lisibles dans les storyboards 2, 3 et 5. Le storyboard 6 montre les réservoirs, tuyaux et plateformes de l’usine. Cellules natives 320×180 ; horodatage précis non certifié. Dreamcast selon l’auteur.

### ZR_CHAPTERS

[Zombie Revenge — neuf Areas dans le chapitrage public du longplay](https://www.youtube.com/watch?v=ne37UXflHqw) — `community_video_chapter_metadata`. Ordre et noms des neuf Areas fournis par l’auteur ; titres 2/3/4 directement recoupés dans les captures retenues. Cassandra associée par ce chapitrage aux séquences 10/11 après le train ; aucun carton Cassandra lisible conservé.

## Vérification et limites

Les 61 identifiants précédents sont préservés, deux lignes sont ajoutées, les statuts sont recalculés depuis les 63 entrées et les 29 arènes sont rapprochées d’au moins une ligne. Les neuf nouveaux chemins de plans existent. Les variantes de salles, embranchements, éditions, remakes et épreuves EX non documentées restent ouvertes. Aucune observation de jeu n’est revendiquée par le seul rafraîchissement documentaire. Les résultats moteur figurent dans [VALIDATION.md](VALIDATION.md).
