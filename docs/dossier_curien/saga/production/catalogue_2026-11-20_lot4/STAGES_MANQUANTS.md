# Stages et familles de zones — état après le lot 4

**26 arènes enregistrées, rapprochées de 61 lignes de lieux, chapitres ou familles de variantes.** Ces lignes ne sont pas un quota de nouvelles arènes ni une mesure de complétude de chaque jeu.

| Statut | Lignes | Sens |
|---|---:|---|
| existant | 19 | Une arène dédiée à ce lieu est enregistrée et possède son art. Cela signifie une adaptation 2D disponible, jamais un chapitre complet ni une fidélité 1:1 certifiée. |
| adaptation_partielle | 8 | Une évocation, une portion, ou un état d’un autre épisode existe ; les éléments explicités restent à réaliser. |
| absent | 27 | Lieu identifié dans les sources, sans arène dédiée correspondante parmi les 26 entrées. Une ligne peut regrouper plusieurs variantes. |
| reference_requise | 7 | L’épreuve/le contexte est connu, mais son lieu précis, ses variantes ou une référence visuelle exploitable restent à établir. Ce statut ne ferme pas le manque. |

## Changements de ce lot

Les arènes **24 — Terrasse de Hangedman** et **25 — Dôme de culture — Hermit** disposent chacune de trois plans natifs. Les lignes `hotd_toits` et `hotd_dome` passent de `absent` à `existant`, au sens limité d’une arène dédiée. Le tunnel d’Hermit, les autres accès et voies de toits restent ouverts. Les 59 autres lignes et tous leurs identifiants sont conservés. Voir le [rapport des six plans](../stages_2026-11-20_lot4/RAPPORT.md).

Le [listing du lot 3](../catalogue_2026-11-20_lot3/STAGES_MANQUANTS.md) reste historique. [stages_manquants.json](stages_manquants.json) contient l’état courant structuré et toutes ses réserves.

## The House of the Dead

Quatre chapitres : Tragedy, Revenge, Truth, The house of the dead. Grands lieux et une branche majeure ; les salles et tous les embranchements ne sont pas détaillés.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `hotd_cour` — Cour et entrée du manoir | Tragedy | existant | 0 | Variantes de parcours et autres cadrages. Arène 0 : Cour du manoir ; présence d’une adaptation, pas du chapitre entier. |
| `hotd_interieurs` — Intérieurs du manoir et annexe | Tragedy / Revenge | adaptation_partielle | 1 | Décor propre à l’annexe et aux grandes salles au-delà de l’antichambre. L’antichambre représente une seule zone intérieure. |
| `hotd_egouts` — Égouts du domaine | Tragedy — embranchement | absent | — | Choisir une capture de la branche, puis produire les plans latéraux.  |
| `hotd_toits` — Toits du manoir / Hangedman | Revenge | existant | 24 | Autres voies et cadrages des toits ; revanche souterraine de Hangedman distincte. Arène 24 : terrasse latérale adaptée des captures arcade. Aucun décor Scarlet Dawn ni parcours complet revendiqué. |
| `hotd_dome` — Dôme de culture / Hermit | Truth | existant | 25 | Tunnel de poursuite d’Hermit, accès et autres cadrages du dôme. Arène 25 : salle verte d’apparition d’Hermit ; trois plans dédiés. Le tunnel est archivé comme contexte, pas livré. |
| `hotd_laboratoire` — Laboratoire de Curien | Truth / The house of the dead | existant | 2 | Autres secteurs, voies d’accès et variations finales. Arène 2 disponible ; aucune reproduction intégrale des deux chapitres. |

Sources du groupe : [H1](#h1), [H1ARCADE_CAPTURE](#h1arcade_capture).

## The House of the Dead 2

Six chapitres ; certains comportent plusieurs grands lieux et branches. La colonne lieu fixe ce qui est évalué.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `hotd2_rues` — Rues et place de la première rencontre | A Prelude | absent | — | Relever la place et les façades propres à ce chapitre. Les rues Zombie Revenge et HOTD4 ne sont pas des substituts. |
| `hotd2_quai` — Canal / quai de Hierophant | Muddy | existant | 3 | Autres branches, berges et cadrages. Arène 3 : Quai de la cité inondée. |
| `hotd2_horloge` — Passage de la tour de l’horloge | Muddy — branche | existant | 13 | Variantes et contexte de l’embranchement. Le passage est lié à Muddy, pas au Colisée de Despair. |
| `hotd2_souterrain` — Voie d’eau souterraine / parcours de Tower | Darkness | existant | 20 | Branche sable de Tower, autres parcours du canal et reprise au siège Goldman. Arène20 : variante aquatique. Berge de combat ajoutée pour une composition latérale ; géométrie originale non certifiée. |
| `hotd2_colisee` — Colisée / Strength | Despair | existant | 21 | Variante aux murs sombres et autres chemins du labyrinthe. Arène21 : murs clairs, partitions de pierre et cage. Ancienne mention de bassin retirée faute de preuve dans les captures inspectées. |
| `hotd2_pont` — Pont routier vers Goldman | Dawn | absent | — | Produire la route/pont et son état HOTD2.  |
| `hotd2_cour_goldman` — Cour du siège Goldman, époque HOTD2 | Dawn | adaptation_partielle | 15 | Décliner une cour HOTD2 correspondant à Magician. Le décor15 est construit pour World dans HOTD4 ; même site narratif, autre état. |
| `hotd2_interieur_goldman` — Intérieurs, laboratoire et bureau de Goldman | Original Sin | absent | — | Sélectionner un grand intérieur représentatif.  |
| `hotd2_toit` — Sommet de la tour / Emperor | Original Sin | existant | 11 | Autres cadrages de la séquence finale. Arène 11 : Toit de la tour Goldman. |

Sources du groupe : [H2](#h2).

## The House of the Dead III

Ch.0 Reminiscence ; ch.1 Chasing Shadows ; ch.2 Bewilderment, ch.3 Sensory Chaos et ch.4 Ultimate Challenge traversent trois familles choisies par le joueur, chacune avec deux variantes ; ch.5 Wheel of Fate. Les variantes ne sont pas six campagnes.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `hotd3_entree` — Entrée et sécurité du centre EFI | Reminiscence / Chasing Shadows | adaptation_partielle | 4 | Extérieurs et cadrages du prologue à traiter séparément. Le Poste de sécurité EFI représente une portion de cette arrivée. |
| `hotd3_efi_dbr` — EFI Genome Ward / DBR Institute | Chapitres 2–4 — zone au choix | adaptation_partielle | 22 | Produire les autres secteurs du D.B.R., la branche EFI Genome Ward et leurs variantes de parcours. Arène22 : adaptation latérale de l’enclos de Fool ; sol élargi. Cette seule salle ne clôture pas les deux parcours. |
| `hotd3_bio` — L2 BIO Plant / L3 BIO Lab | Chapitres 2–4 — zone au choix | adaptation_partielle | 23 | Différencier les chemins et autres secteurs L2 BIO Plant / L3 BIO Lab ; comparer les variantes de salle si nécessaire. Arène23 : chambre industrielle de Sun, cadrage latéral et sol continu adaptés. Ce n’est pas une couverture des deux chapitres. |
| `hotd3_information` — Information Systems Department — ailes est/ouest | Chapitres 2–4 — zone au choix | absent | — | Relever les bureaux et passages de poursuite ; différencier les ailes.  |
| `hotd3_incubation` — L4 / chambre d’incubation finale | Wheel of Fate | existant | 12 | Autres secteurs du chapitre et angles de la salle finale. Arène 12 ; sources de la chambre détaillées dans SOURCES_ARENES_III.md. |

Sources du groupe : [H3](#h3), [H3V](#h3v), [H3FOOL_OFFICIAL](#h3fool_official), [H3SUN_OFFICIAL](#h3sun_official), [H3DBR_CAPTURE](#h3dbr_capture), [H3L2_CAPTURE](#h3l2_capture), [H3EFI_ROUTE](#h3efi_route), [H3L3_ROUTE](#h3l3_route).

## The House of the Dead 4

Six chapitres : Escape, Lost, Emptiness, Despair, Reunion, Hope. Les lieux principaux distincts sont séparés sans inventorier chaque salle.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `hotd4_ams` — Sous-sols du bureau européen de l’AMS | Escape | absent | — | Relever les couloirs et ascenseurs de départ. Le poste EFI appartient à III, le métro à une autre zone de 4. |
| `hotd4_egouts` — Égouts / parcours de Lovers | Lost | absent | — | Produire une galerie d’égout identifiable et la zone d’ascenseur. P1 possible après choix d’une capture. |
| `hotd4_metro` — Quai et réseau de métro | Emptiness | existant | 5 | Autres quais et tunnels. Le décor existe, même si la narration de simulation y fait apparaître Justice. |
| `hotd4_train` — Train de l’Empress | Emptiness | absent | — | Créer l’intérieur/la toiture spécifique retenue après examen des captures. Ni le quai fixe ni le train Zombie Revenge ne couvrent ce véhicule. |
| `hotd4_commerces` — Quartier commercial souterrain | Despair | absent | — | Relever les commerces et la progression vers la surface.  |
| `hotd4_rue` — Rue dévastée / Temperance | Despair | existant | 17 | Autres secteurs et destruction animée. Arène 17 : Rue dévastée de Despair. |
| `hotd4_pont` — Route et pont vers Goldman | Reunion | absent | — | Produire l’état HOTD4 du trajet routier. Même axe que Dawn, mais pas la même époque. |
| `hotd4_interieur_goldman` — Intérieurs et bureau de Goldman | Hope | absent | — | Choisir le grand intérieur représentatif ; le parvis ne suffit pas.  |
| `hotd4_parvis` — Parvis / World | Hope | existant | 15 | Phases, bris et autres cadrages. Arène 15 ; référence décrite dans SOURCES_ARENES_IV.md. |

Sources du groupe : [H4](#h4).

## The House of the Dead 4 Special

Deux stages principaux. Le complexe du projet est une évocation unique, pas deux niveaux reconstitués.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `special_approche` — Approche extérieure / parcours routier et Justice | Stage 1 | absent | — | Choisir les captures du trajet puis produire une arène propre au stage 1.  |
| `special_laboratoire` — Installation de recherche / chambre de Magician | Stage 2 | adaptation_partielle | 6 | Confronter le complexe peint aux salles du stage 2 et compléter leur identité. Arène 6 : Complexe déserté ; sa présence ne valide pas tous les lieux de Special. |

Sources du groupe : [SP1](#sp1), [SP2](#sp2).

## House of the Dead: Scarlet Dawn

Prologue Scarecrow Manor ; chapitres 1–3 Kate and Ryan, Homo sapiens, Pandora’s Box selon l’ordre des trois zones ; final A Glimmer of Hope. Les trois routes ne sont pas des campagnes séparées.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `scarlet_reception` — Hall et réception | Scarecrow Manor — prologue | existant | 7 | Autres vues et effondrement. Arène 7 : Réception de Scarecrow Mansion. |
| `scarlet_annex` — Annex | Chapitres 1–3 — zone au choix | absent | — | Relever l’annexe et un espace propre au combat Chariot. La réception ne couvre pas l’annexe. |
| `scarlet_laboratory` — Laboratory | Chapitres 1–3 — zone au choix | absent | — | Sélectionner une salle caractéristique du laboratoire. Ne pas réutiliser EFI/Curien comme preuve de présence. |
| `scarlet_elevator` — Elevator Lobby / toits | Chapitres 1–3 — zone au choix | absent | — | Produire les toits ou le lobby, puis le complément restant. Le toit de Hangedman est spécifique à cette version. |
| `scarlet_church` — Église avant destruction | A Glimmer of Hope | absent | — | Relever l’intérieur et la structure avant le combat final. Les ruines existantes ne couvrent pas l’état intact. |
| `scarlet_ruines` — Ruines et terrain de Moon | A Glimmer of Hope | existant | 16 | Autres phases et états du terrain. Arène 16 : Ruines du domaine Scarecrow. |

Sources du groupe : [SDP](#sdp), [SD](#sd).

## Overkill / Extended Cut / Typing of the Dead: Overkill

Les neuf titres du parcours Extended Cut sont tous recensés ci-dessous. Cet inventaire n’implique ni toutes les extensions de trajet du mode Director’s Cut ni les mini-jeux.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `overkill_papa` — Manoir/plantation de Papa Caesar | 1 — Papa’s Palace of Pain | absent | — | Produire le grand hall ou les abords propres à Overkill. La cour Curien n’est pas ce manoir. |
| `overkill_naked` — Club, rues et bar de Bayou City | 2 — Naked Terror | absent | — | Commencer par le club documenté par la capture officielle. Chapitre supplémentaire Extended Cut. |
| `overkill_hospital` — Hôpital | 3 — Ballistic Trauma | absent | — | Produire un secteur hospitalier identifiable. P1 : nouvelle famille architecturale. |
| `overkill_carny` — Fête foraine | 4 — Carny | existant | 8 | Autres attractions et parcours. Arène 8. |
| `overkill_flesh` — Abattoir infesté | 5 — Creeping Flesh | existant | 19 | Autres pièces, tunnel organique et variantes de combat. Lot du 20 novembre : adaptation documentée à trois plans. |
| `overkill_train` — Train d’Overkill | 6 — Scream Train | absent | — | Choisir quai/intérieur/toit, puis produire sa propre composition. L’arène 18 est Zombie Revenge, pas Scream Train. |
| `overkill_bayou` — Marais / ponton du bayou | 7 — The Fetid Waters | existant | 14 | Autres marais et embarcations. Arène 14 ; sources dans SOURCES_ARENES_III.md. |
| `overkill_jail` — Prison | 8 — Jailhouse Judgment | absent | — | Créer un grand secteur de cellules ou la cour. Le jeu/les sources emploient aussi la graphie Judgement. |
| `overkill_lab` — Laboratoire souterrain final | 9 — Overkill | absent | — | Relever l’installation de recherche et le cadre de Mother. Les laboratoires des autres épisodes ne ferment pas cette ligne. |

Sources du groupe : [OV](#ov), [OVA](#ova).

## Zombie Revenge

Les sept intitulés de zones Dreamcast sont recensés. Les sous-zones, routes, boss arenas et variantes arcade ne sont pas déclarés exhaustifs.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `zr_woodside` — Woodside City | Area 1 — Woodside City | adaptation_partielle | 10 | Aligner la rue générique sur des captures précises de Woodside. Arène 10 : Rue en quarantaine, interprétation de Zombie Revenge. |
| `zr_river` — Rivière souterraine | Area 2 — Underground River | absent | — | Relever le cours d’eau et les plateformes. Le canal HOTD2 ne couvre pas ce site. |
| `zr_plant` — Usine / The Plant | Area 3 — The Plant | absent | — | Récupérer une vue lisible de l’usine puis composer les plans. P1 : contraste avec la rue et le train déjà présents. |
| `zr_train` — Toit du train dans le tunnel | Area 4 — The Train | existant | 18 | Intérieur, extérieur nocturne et autres sections du train. Lot du 20 novembre ; un segment adapté, pas toute la zone. |
| `zr_gate` — The Gate | Area 5 — The Gate | absent | — | Établir le cadrage exact à partir du carton et des captures suivantes. Nom conservé sans inventer de description architecturale. |
| `zr_house` — Manoir tel que parcouru dans Zombie Revenge | Area 6 — The House of the Dead | absent | — | Comparer le parcours ZR aux décors HOTD existants avant mutualisation. La présence des arènes 0–2 ne prouve pas une adaptation de ce chapitre. |
| `zr_dawn` — The Dawn / zone finale | Area 7 — The Dawn | absent | — | Choisir une vue documentée de la dernière zone. Nom de zone validé ; architecture à relever. |

Sources du groupe : [ZR](#zr), [ZRP](#zrp).

## Loving Deads: The House of the Dead EX

Recensement limité au laboratoire de départ et aux six mini-jeux du verso du flyer SEGA inspecté. L’ordre, les chapitres, variantes et autres épreuves restent à documenter ; aucune exhaustivité n’est annoncée.

| ID / lieu | Chapitre ou portée | Statut | Arènes | Travail restant |
|---|---|---|---|---|
| `ex_plateau` — Plateau générique des épreuves | Synthèse du projet | adaptation_partielle | 9 | Rattacher chaque décor futur à une épreuve réellement montrée. Arène 9 est une interprétation de l’ambiance EX, pas la preuve de six mini-jeux représentés. |
| `ex_laboratoire` — Laboratoire de départ | Départ / fuite | reference_requise | — | Obtenir des captures de l’introduction et du lieu avant de cadrer l’arène. Le contexte est officiel ; la géométrie exploitable n’est pas établie. |
| `ex_zombz` — Scène musicale / projecteurs | Mini-jeu — ZomB’z | reference_requise | — | Obtenir une capture plus grande de l’épreuve. Titre du flyer ; le plateau9 n’est pas identifié à cette scène. |
| `ex_bowling` — Piste de bowling | Mini-jeu — Zombie Bowling | reference_requise | — | Obtenir une vue lisible de la piste et du fond. Traduction de travail du titre japonais. |
| `ex_sumo` — Dohyō / ring de sumo | Mini-jeu — sumo | reference_requise | — | Relever le ring et son environnement. Traduction de travail ; vignette primaire trop petite pour un contrat visuel complet. |
| `ex_apples` — Verger | Mini-jeu — cueillette de pommes | reference_requise | — | Relever arbres, terrain et barrières. Mini-jeu visible dans le flyer ; variantes non recensées. |
| `ex_flying` — Entrepôt / parcours de vol | Mini-jeu — Flying zoneB | reference_requise | — | Récupérer une capture de l’entrepôt à résolution exploitable.  |
| `ex_lifting` — Zone de jonglage | Mini-jeu — Zombie Lifting | reference_requise | — | Identifier le lieu derrière les personnages et les éléments de jeu. Pas de nom de salle inventé à partir de la seule vignette. |

Sources du groupe : [EXP](#exp), [EXF](#exf).

## Arènes du registre

| Index | Nom | Art |
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

## Portées complémentaires

### The Typing of the Dead / éditions de frappe liées à HOTD2 ; The Typing of the Dead2 ; Typing Overkill ; 2&3 Return

**adaptation_partielle** — Réutiliser les familles de lieux du jeu source lorsqu’une équivalence est établie. Ne pas multiplier automatiquement les arènes pour une même carte ; interfaces et cadrages propres restent à examiner.

### Remake du premier jeu / HOTD2 Remake

**reference_requise** — Campagnes apparentées ; l’état visuel, les embranchements et les modifications propres aux remakes demandent une comparaison distincte. Les adaptations classiques ne certifient pas ces variantes.

### Overkill — The Lost Reels

**reference_requise** — Inventorier les bobines mobiles réellement disponibles et leurs lieux ; ne pas recopier sans vérification les neuf chapitres PS3.

### The Pinball of the Dead, English of the Dead, Darts of the Dead et variantes de saisie

**reference_requise** — Documenter tables, écrans et mini-jeux propres avant d’en déduire des arènes. Aucun nombre de nouveaux lieux n’est affirmé ici.

### The Site of the Dead, Mobile, Nightmare et services téléphoniques

**reference_requise** — Recenser les écrans et lieux à partir de captures identifiables par version ; ce backlog ne transforme pas les noms de produits en lieux inventés.

### Attractions Scarlet Dawn, Battle Genesis / On Reels, Reawakened

**reference_requise** — Traiter les dispositifs et missions propres dans un audit dédié. Les sources de produits sont recensées dans SOURCES_SAGA.json ; aucun lieu supplémentaire n’est déclaré confirmé ici.

## Sources

### H1

[HOTD — nomenclature des chapitres du guide officiel (notice/transcription)](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_Official_Guide) — secondary_catalogue_of_official_guide. Quatre chapitres ; la notice n’est pas une planche visuelle de référence.

### H1B

[HOTD — parcours et branche des égouts](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_%281997_video_game%29) — secondary_encyclopedia. Structure du premier jeu et embranchement de Tragedy.

### H1T

[Truth — laboratoire et dôme de culture](https://thehouseofthedead.fandom.com/wiki/Truth) — secondary_encyclopedia. Checkpoint, laboratoire, dôme de culture d’Hermit.

### H1R

[Hangedman — lieu du combat original](https://thehouseofthedead.fandom.com/wiki/Hangedman) — secondary_encyclopedia. Toits du manoir ; distinguer le design original de Scarlet Dawn.

### H2

[HOTD2 — chapitres](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_2) — secondary_encyclopedia. Six titres de chapitres.

### H2M

[HOTD2 — chapitre Muddy illustré](https://www.k-triggerhappy.com/hod2/chapter2.html) — gameplay_capture_walkthrough. Canaux, quai et branche de l’horloge ; captures de jeu.

### H2D

[HOTD2 — Darkness et sites du mode Original](https://thehouseofthedead.fandom.com/wiki/Original_Mode) — secondary_encyclopedia. Canaux et voie d’eau souterraine ; intérieurs de Goldman.

### H2C

[HOTD2 — Despair / Colisée](https://thehouseofthedead.fandom.com/wiki/Despair_%28The_House_of_the_Dead_2_chapter%29) — secondary_encyclopedia. Passage souterrain et Colisée de Strength.

### H2A

[HOTD2 — Dawn](https://thehouseofthedead.fandom.com/wiki/Dawn) — secondary_encyclopedia. Place, pont routier et cour du siège Goldman.

### HQ

[Siège Goldman — comparaison HOTD2 et HOTD4](https://thehouseofthedead.fandom.com/wiki/Caleb_Goldman%27s_headquarters) — secondary_encyclopedia. Même site narratif, intérieurs et états d’époque distincts.

### H3

[HOTDIII — chapitres et ordre des zones](https://thehouseofthedead.fandom.com/wiki/The_House_of_the_Dead_III) — secondary_encyclopedia. Prologue 0, chapitres 1–5, trois familles de zones choisies pour les chapitres 2–4.

### H3V

[HOTDIII — index illustré des six variantes de zones](https://www.k-triggerhappy.com/hod3/index.html) — gameplay_capture_walkthrough. EFI/DBR, L2/L3, Information Systems est/ouest ; captures consultables par zone.

### H4

[HOTD4 — index des six chapitres](https://www.k-triggerhappy.com/hod4/index.html) — gameplay_capture_walkthrough. Index et captures par chapitre.

### H4E

[HOTD4 — sous-sols de l’AMS](https://thehouseofthedead.fandom.com/wiki/AMS_European_branch_office) — secondary_encyclopedia. Lieu de départ ; distinct du métro et du poste EFI.

### H4L

[HOTD4 — Lost](https://thehouseofthedead.fandom.com/wiki/Lost) — secondary_encyclopedia. Égouts et progression vers la surface.

### H4M

[HOTD4 — Emptiness](https://thehouseofthedead.fandom.com/wiki/Emptiness) — secondary_encyclopedia. Métro, quai et train de l’Empress.

### H4D

[HOTD4 — Despair](https://thehouseofthedead.fandom.com/wiki/Despair_%28The_House_of_the_Dead_4_chapter%29) — secondary_encyclopedia. Quartier marchand souterrain et rues de la ville.

### H4R

[HOTD4 — Reunion](https://thehouseofthedead.fandom.com/wiki/Reunion) — secondary_encyclopedia. Retour routier vers Goldman, avec le pont.

### H4H

[HOTD4 — Hope illustré](https://www.k-triggerhappy.com/hod4/chapter6.html) — gameplay_capture_walkthrough. Intérieurs du siège et combat de World sur le parvis.

### SP1

[HOTD4 Special — stage1 illustré](https://www.k-triggerhappy.com/hod4/special1.html) — gameplay_capture_walkthrough. Progression extérieure/routière et Justice.

### SP2

[HOTD4 Special — stage2 illustré](https://www.k-triggerhappy.com/hod4/special2.html) — gameplay_capture_walkthrough. Installation de recherche et chambre de Magician.

### SDP

[Scarlet Dawn — site officiel SEGA](https://hod.sega.jp/) — primary_publisher. Présentation de l’infiltration du manoir et de la réception ; les noms précis des routes viennent des sources complémentaires.

### SD

[Scarlet Dawn — chapitres et zones](https://thehouseofthedead.fandom.com/wiki/House_of_the_Dead%3A_Scarlet_Dawn) — secondary_encyclopedia. Prologue, trois routes sélectionnables et final.

### SDL

[Scarlet Dawn — Laboratory](https://thehouseofthedead.fandom.com/wiki/Laboratory) — secondary_encyclopedia. Laboratoire sélectionnable et High Priestess.

### SDE

[Scarlet Dawn — Elevator Lobby](https://thehouseofthedead.fandom.com/wiki/Elevator_Lobby) — secondary_encyclopedia. Ascenseurs, toits et Hangedman.

### SDM

[Scarlet Dawn — confrontation finale illustrée](https://k-triggerhappy.com/blog/hod_scarletdawn-moon/) — gameplay_capture_walkthrough. Référence déjà employée par SOURCES_ARENES_IV.md pour les ruines.

### OV

[Overkill Extended Cut — index des neuf chapitres](https://www.k-triggerhappy.com/hodoverkill_ps3/index.html) — gameplay_capture_walkthrough. Ordre PS3 et titres des neuf chapitres.

### OVA

[Typing/House of the Dead Overkill — succès officiels du jeu](https://steamcommunity.com/achievements/246580) — primary_game_metadata. Confirme les noms des chapitres communs aux deux modes ; le dernier niveau est repris de l’index PS3.

### OV1

[Papa’s Palace of Pain — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage1.html) — gameplay_capture_walkthrough. Manoir/plantation et sous-sol.

### OV2

[Naked Terror — annonce officielle](https://blog.playstation.com/2011/08/01/house-of-the-dead-overkill-naked-terror-revealed/) — primary_publisher_promotion. Club, rues et bar ; capture de presse.

### OV3

[Ballistic Trauma — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage3.html) — gameplay_capture_walkthrough. Hôpital.

### OV5

[Creeping Flesh — annonce officielle](https://blog.playstation.com/2011/08/30/house-of-the-dead-overkill-extended-cut-creeping-flesh-level-reveal/) — primary_publisher_promotion. Abattoir et infestation organique ; capture fournie à la génération.

### OV6

[Scream Train — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage6.html) — gameplay_capture_walkthrough. Train propre à Overkill.

### OV8

[Jailhouse Judgment — parcours illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage8.html) — gameplay_capture_walkthrough. Prison.

### OV9

[Overkill — parcours final illustré](https://www.k-triggerhappy.com/hodoverkill_ps3/stage9.html) — gameplay_capture_walkthrough. Installation de recherche souterraine.

### ZR

[Zombie Revenge — sept cartons de zones Dreamcast](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/) — contributed_gameplay_captures. Sept noms de zones lus dans la galerie ; ne pas inventer de sous-titres architecturaux pour The Gate/The Dawn.

### ZRP

[Zombie Revenge — fiche officielle SEGA](https://www.sega.jp/history/arcade/product/8161/) — primary_publisher. Contexte et sept stages ; les noms précis sont confirmés par les cartons de jeu.

### ZRT

[Zombie Revenge — toit du train](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/1117675/) — contributed_gameplay_capture. Source du toit dans le tunnel adapté pour l’arène 18.

### EXP

[Loving Deads EX — fiche officielle SEGA](https://www.sega.jp/history/arcade/product/8762/) — primary_publisher. Fuite du laboratoire et mini-jeux coopératifs ; page en maintenance lors de l’ouverture directe du 20 novembre, contenu de recherche consulté.

### EXF

[Loving Deads EX — flyer SEGA, verso](https://flyers.arcade-museum.com/videogames/show/5803) — primary_promotional_artifact_secondary_host. Six mini-jeux montrés, pas un inventaire complet. Scan du dépôt inspecté.

### H2T_OFFICIAL

[SEGA — Tower, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/tower.html) — official_publisher_guide. Variantes eau/sable, cinq têtes et phase finale.

### H2S_OFFICIAL

[SEGA — Strength, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/strength.html) — official_publisher_guide. Parcours est/ouest du Colisée.

### H2C3_CAPTURE

[Trigger Happy — captures du chapitre 3](https://www.k-triggerhappy.com/hod2/chapter3.html) — community_gameplay_captures. Captures boss3-1 et boss3-2 réellement inspectées.

### H2C4_CAPTURE

[Trigger Happy — captures du chapitre 4](https://www.k-triggerhappy.com/hod2/chapter4.html) — community_gameplay_captures. Captures des murs clairs/sombres et cage inspectées.

### H3FOOL_OFFICIAL

[SEGA — Type0028 Fool, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type0028_fool_1.html) — official_publisher_guide. Enclos grillagé et passerelles ; image Fool_01 réellement inspectée.

### H3SUN_OFFICIAL

[SEGA — Type8830 Sun, 2&3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type8830_sun.html) — official_publisher_guide. Salle industrielle BIO ; image Sun_01 réellement inspectée.

### H3DBR_CAPTURE

[Trigger Happy — D.B.R. Institute](https://www.k-triggerhappy.com/hod3/chapter2A.html) — community_gameplay_captures. Boss2-2 inspecté ; enclos et escalier. Port de capture non établi.

### H3L2_CAPTURE

[Trigger Happy — L2 BIO Plant](https://www.k-triggerhappy.com/hod3/chapter3A.html) — community_gameplay_captures. Boss3-1 et boss3-2 inspectés ; chambre industrielle de Sun. Port non établi.

### H3EFI_ROUTE

[Trigger Happy — EFI Genome Ward](https://www.k-triggerhappy.com/hod3/chapter2B.html) — community_guide. Autre branche de la famille, non clôturée par le nouvel enclos.

### H3L3_ROUTE

[Trigger Happy — L3 BIO Lab](https://www.k-triggerhappy.com/hod3/chapter3B.html) — community_guide. Autre branche BIO, non clôturée par la nouvelle salle.

### H1ARCADE_CAPTURE

[HOTD original — captures arcade Model 2, Hangedman et Hermit](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — community_hosted_original_gameplay_captures. Sept images inspectées ; cinq entrées visuelles de génération. Captures arcade japonaises selon l’auteur. Toit, dôme et distinction du tunnel.

## Limites

- Les correspondances sont un audit de production du projet, pas une mesure de couverture de chaque chapitre original.
- Une ligne peut représenter une famille de variantes ; les nombres de lignes ne sont pas des nombres de nouvelles arènes à commander.
- Un même décor peut être associé à plusieurs lignes avec un statut partiel ; aucun pourcentage de complétude de la saga n’est calculé.
- Les sources primaires ne détaillent pas tous les lieux. Les notices secondaires et captures communautaires sont explicitement identifiées.
- Le lot3 apporte six plans pour deux salles de boss HOTD III ; les deux familles correspondantes passent de absent à adaptation_partielle, sans clôturer les branches entières.
- Le lot 4 apporte deux arènes dédiées aux lieux hotd_toits et hotd_dome ; leur statut existant conserve les autres parcours et le tunnel d’Hermit comme travaux distincts non terminés.
