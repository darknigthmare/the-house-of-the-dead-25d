# Personnages, formes et tenues — inventaire courant après le lot 3

**62 lignes de travail suivies : 28 ont reçu une base statique au fil des trois lots, pour 29 nouvelles fiches de galerie ; 34 lignes ne sont pas couvertes par ces livraisons.** Le projet conserve 24 combattants jouables. Une illustration entière ne constitue pas un combattant animé ni une tenue sélectionnable.

État documentaire du **20 novembre 2026**. Le point initial `59372b618882da17510351f2a5bd46226682eac4` reste historique et gelé. La comparaison propre au lot 3 part du commit publié `af0e4933c07b9016a6be552ce874b61007dd7836` ; les tableaux ci-dessous décrivent les sources et les livraisons assemblées après ce point, sans présumer un export ou une publication distante.

Le [registre JSON courant](personnages_tenues.json) conserve les 62 identifiants initiaux dans leur ordre, leurs anciens statuts et références, les livraisons rattachées, les réserves exactes et les 35 rencontres de boss par édition. L’[inventaire initial](../catalogue_2026-11-20/PERSONNAGES_TENUES.md), le [delta du lot 1](../catalogue_2026-11-20/delta_livraison.json) et l’[inventaire après le lot 2](../catalogue_2026-11-20_lot2/PERSONNAGES_TENUES.md) restent inchangés.

## Compteurs à lire séparément

| Indicateur | Initial 59372b6 | Avant lot 2 — 6291e0d | Avant lot 3 — af0e4933 | Courant après lot 3 |
|---|---:|---:|---:|---:|
| Combattants jouables | 24 | 24 | 24 | **24** |
| Routes Histoire du projet | 26 | 26 | 26 | **26** |
| Arènes enregistrées | 18 | 20 | 22 | **24** |
| Entrées Archives | 29 | 29 | 29 | **29** |
| Fiches de galerie | 40 | 49 | 61 | **69** |
| Chemins PNG Dossier Curien | 332 | 347 | 365 | **379** |
| Blobs Git PNG distincts | 330 | 345 | 363 | **377** |
| Tenues alternatives sélectionnables | 2 | 2 | 2 | **2** |
| Poses minimales nommées encore manquantes | 277 | 277 | 277 | **277** |
| Masters historiques encore non récupérés | 204 | 204 | 204 | **204** |

Les routes, arènes et Archives sont des adaptations et structures du projet. Ces nombres ne décrivent pas autant de chapitres, jeux ou personnages originaux. Les PNG mélangent personnages, poses, décors et accessoires ; les fichiers de référence documentaire et les sorties écartées hors du répertoire des assets Dossier Curien n’entrent pas dans ce total.

Le [snapshot af0e4933](baseline_af0e4933.json) fournit 365 chemins et 363 blobs. Les 14 PNG retenus pour le jeu dans le lot 3 — 8 silhouettes de galerie et 6 plans d’arènes — ont des empreintes distinctes et portent le total à 379 chemins / 377 blobs. Les trois lots réunis apportent 29 PNG de galerie et 18 plans d’arènes, soit 47 PNG depuis l’état initial. La galerie conserve ses 40 fiches initiales et reçoit 9 + 12 + 8 fiches. L’image initiale de James écartée puis conservée comme référence d’édition ne constitue pas une fiche supplémentaire.

Le lot motion du 19 novembre reste à 30 entrées : 24 nouveaux dessins retenus, 4 récupérations et 2 gardes EX recâblées. Les nouvelles bases ne réduisent pas son [suivi des 277 poses](../motion_2026-11-19/MANQUANTS.json). De nouvelles générations ne récupèrent pas non plus les 204 masters historiques perdus.

## Comment les livraisons se rattachent aux tâches

| Livraison | Lignes recevant une base | PNG de galerie | Détail |
|---|---:|---:|---|
| Lot 1 | 9 | 9 | 4 bases humaines, 3 variantes d’époque, Hangedman et Hermit HOTD 1. |
| Lot 2 — humains | 4 | 4 | Goldman humain, Thornheart, Papa Caesar, Clement Darling. |
| Lot 2 — boss | 5 | 6 | Judgment produit deux silhouettes, Zeal et Kuarl ; Tower, Strength, Fool et Sun en produisent une chacun. |
| Lot 2 — équipements | 2 | 2 | James et Gary dans The Typing of the Dead. |
| Lot 3 — adaptations humaines | 2 | 2 | Sophie Richards et Dr. Curien HOTD 1 ; identités déjà présentes dans les ressources historiques. |
| Lot 3 — boss | 4 | 4 | High Priestess, Screamer, Crawler et Brutus. |
| Lot 3 — variantes d’édition | 2 | 2 | James HOTD 4 et G HOTD 4 Special ; identités déjà connues. |
| **Cumul** | **28** | **29** | **34 lignes initiales restent non couvertes par les trois lots.** |

Les 62 lignes sont des identités, formes, apparences de rencontre, ensembles de variantes ou recherches. **34 lignes ne signifie pas 34 personnages uniques restants.** Les 35 rencontres ci-dessous recoupent une partie de ces tâches et ne s’y additionnent pas. Une base reçue ferme seulement l’étape « disposer d’une image statique » ; la validation des détails, les animations et l’intégration jouable peuvent rester ouvertes.

La ligne `judgment` conserve son identifiant et se rattache à `zeal` + `kuarl`. La ligne `clement` se rattache à `clement_darling`, `sophie` à `sophie_richards`, et `curien` à `dr_curien`. Tower est une rencontre représentée avec cinq têtes dans une seule image. La livraison `hangedman` couvre HOTD 1 uniquement ; son redesign Scarlet Dawn demeure un manque distinct dans le tableau des rencontres.

Reçus du lot 3 : [humains](humans_generated.json) · [boss](bosses_generated.json) · [variantes d’édition](costumes_generated.json). Les prompts exacts, références inspectées, sorties retenues ou écartées et limites de chaque image y sont conservés. Le [rapport humain](HUMANS.md), le [rapport des boss](BOSSES.md) et le [rapport des tenues](COSTUMES.md) détaillent leur comparaison ; aucun ne certifie une reproduction 1:1.

## Références visuelles encore ouvertes dans les trois lots

**Six des 29 fiches nouvelles portent explicitement un statut de vérification visuelle ouverte** : Varla, Candi, Thornheart, Papa Caesar, Clement et Sophie. Ce compte concerne les trois lots de galerie ; il n’est pas le total des statuts ouverts dans les 69 fiches, et les 23 autres images conservent leurs propres réserves.

| Fiche | Point restant à confirmer |
|---|---|
| Varla Guns | Bas de tenue reconstruit ; référence plein pied à recouper. |
| Candi Stryper | Bas de tenue reconstruit ; référence plein pied à recouper. |
| Thornheart | Le portrait officiel ne montre ni pantalon ni chaussures. |
| Papa Caesar | Mocassins et détails de canne décrits par une source secondaire, encore peu lisibles dans les captures. |
| Clement Darling | Référence de cinématique limitée au buste ; pantalon, chaussures et stature entière adaptés. |
| Sophie Richards | Chaussures visibles à petite échelle dans la capture arcade ; teinte, finition et certains détails de bas/collants restent à recouper. |

Les autres réserves ne disparaissent pas : couleurs des bottes d’Amy interprétées depuis un manuel monochrome, chaussures partiellement cachées de Rogan III, dos de Gary Typing non montré, connectique et petits logos simplifiés, modèles secondaires de Fool/Sun et composition bornée de Sun. Pour le lot 3, le changement de pose, les parties cachées et les petits détails restent bornés par les références ; les images humaines et de tenues gardent leur alpha natif maximal à 254. Un statut « références comparées » ne certifie pas une fidélité 1:1. Les limitations exactes restent dans chaque reçu.

## Profils jouables et tenues de combat conservés

Les constantes de [combatant.gd](../../../../../src/dossier_curien/combatant.gd) conservent les mêmes 24 profils. Les nouvelles fiches n’ajoutent aucune entrée à cette liste.

| Dossier d’origine du profil | Profils du projet |
|---|---|
| Manoir Curien | Thomas Rogan, Agent G, Chariot, Magician |
| HOTD 2 | James Taylor, Hierophant, Emperor, Gary Stewart |
| HOTD III | Lisa Rogan, Death, Wheel of Fate, Daniel Curien |
| HOTD 4 | Kate Green, Justice, The World |
| Scarlet Dawn | Ryan Taylor, Moon |
| Overkill | Isaac Washington, Jasper Guns |
| Loving Deads EX | Zobio, Zobiko |
| Zombie Revenge | Stick Breitling, Rikiya Busujima, Linda Rotta |

Les deux tenues alternatives sélectionnables restent `kate_soiree` et `ryan_soiree`. « Selon le dossier » est une règle de sélection automatique, pas une troisième tenue. G Overkill, G III, Rogan III, James Typing, Gary Typing, James HOTD 4 et G HOTD 4 Special sont sept études de galerie rattachées à des identités existantes ; elles ne deviennent pas sept costumes de combat équipables.

Les rôles des jeux originaux et ceux du projet restent séparés. Varla est PNJ dans Overkill et jouable dans Extended Cut ; une image de Varla dans Dossier Curien reste non jouable. Les fiches de Linda, Zobio et Zobiko peuvent coexister avec leurs profils jouables indépendants ; les compteurs de profils et de fiches ne s’additionnent pas comme des identités.


## Registre courant des 62 lignes

Les identifiants sont ceux de l’inventaire initial. Les anciens statuts, priorités et états de référence sont conservés dans le JSON sous des champs historiques. Les tableaux donnent l’état courant, la livraison éventuelle et la suite nécessaire. Les réserves associées à une base livrée restent distinctes des 34 lignes n’ayant reçu aucune base dans ces trois lots.

### Humains et personnages secondaires — 15 lignes

| ID | Sujet et édition | Type | État courant | Livraison ou travail restant |
|---|---|---|---|---|
| `varla` | Varla Guns — Overkill Extended Cut | Identité ; PNJ dans Overkill ; jouable dans Extended Cut | Base livrée, lot 1 ; référence à confirmer | [Varla Guns](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/varla_guns_base.png) — Base du lot 1 ; bas de tenue reconstruit et vérification visuelle explicite encore ouverte. Aucun nouveau profil jouable. |
| `candi` | Candi Stryper — Overkill Extended Cut | Identité ; Protagoniste jouable du jeu source | Base livrée, lot 1 ; référence à confirmer | [Candi Stryper](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/candi_stryper_base.png) — Base du lot 1 ; bas de tenue reconstruit et vérification visuelle explicite encore ouverte. Aucun nouveau profil jouable. |
| `amy` | Amy Crystal — HOTD 2 | Identité ; Personnage de soutien | Base livrée, lot 1 | [Amy Crystal](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/amy_crystal_base.png) — Base HOTD 2 du lot 1 ; les couleurs des bottes interprétées depuis le manuel monochrome restent une réserve. |
| `harry` | Harry Harris — HOTD 2 | Identité ; Personnage de soutien | Base livrée, lot 1 | [Harry Harris](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/harry_harris_base.png) — Base HOTD 2 du lot 1 ; la substitution Original Mode reste une tâche distincte. |
| `goldman_human` | Goldman — forme humaine — HOTD 2 | Identité ; Antagoniste humain | Base livrée, lot 2 | [Goldman — forme humaine](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/goldman_human_base.png) — Base humaine HOTD 2 du lot 2 ; pose debout adaptée depuis le manuel et le modèle assis. Ni forme zombie ni substitution Original Mode livrées. |
| `thornheart` | Thornheart — Scarlet Dawn | Identité ; Antagoniste humain | Base livrée, lot 2 ; référence à confirmer | [Thornheart](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/thornheart_base.png) — Base Scarlet Dawn du lot 2 ; buste officiel inspecté, pantalon et chaussures reconstruits, vérification plein pied ouverte. |
| `papa_caesar` | Papa Caesar — Overkill | Identité ; Antagoniste humain | Base livrée, lot 2 ; référence à confirmer | [Papa Caesar](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/papa_caesar_base.png) — Base Overkill du lot 2 ; tenue verte documentée, détails de canne et mocassins encore à confirmer visuellement. |
| `clement` | Clement Darling — Overkill | Identité ; Antagoniste humain | Base livrée, lot 2 ; référence à confirmer | [Clement Darling](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/clement_darling_base.png) — Base Overkill du lot 2 sous l’ID clement_darling ; buste du jeu inspecté, pantalon et chaussures reconstruits. |
| `sophie` | Sophie Richards — HOTD 1 | Identité ; Personnage de soutien | Base livrée, lot 3 ; référence à confirmer | [Sophie Richards — HOTD1](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/characters/sophie_richards_base.png) — Adaptation statique HOTD 1 livrée au lot 3 après comparaison du manuel et de captures arcade. Le maître historique ne servait pas de référence canonique. Chaussures et détails fins restent à confirmer ; la variante Saturn et les animations demeurent distinctes. |
| `curien` | Dr. Curien — HOTD 1 | Identité ; Antagoniste humain | Base livrée, lot 3 | [Dr. Curien — HOTD1](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/characters/dr_curien_base.png) — Adaptation humaine HOTD 1 livrée au lot 3 : ensemble beige, lunettes foncées et canne rosée comparés aux captures arcade. Les ressources historiques sont conservées ; Wheel of Fate reste une autre forme. |
| `dan_taylor` | Dan Taylor — HOTD III | Personnage secondaire ; Partenaire jouable du prologue, attribution à corroborer | Non couvert par les trois lots | Nom et rôle à corroborer au générique ; capture de jeu visible. Ne pas confondre avec Daniel Curien ni renommer Scott. |
| `yukio` | Yukio — HOTD III | Personnage secondaire ; PNJ et forme de créature à documenter | Non couvert par les trois lots | Identité secondaire et forme à documenter avant production ; pas de costume inventé. |
| `jasper_human` | Jasper Guns — forme humaine — Overkill | Forme humaine ; Forme humaine d’un PNJ | Non couvert par les trois lots | Même identité que le boss Jasper déjà jouable ; nouvelle forme visuelle, pas nouveau nom de roster. |
| `mother_human` | Mother — forme humaine — Overkill | Forme humaine ; Forme humaine d’un PNJ | Non couvert par les trois lots | Liée à la forme boss Mother ; ne pas additionner deux nouvelles identités. |
| `bart_picard` | Bart Picard — Overkill | Personnage secondaire ; Mention textuelle ou hors champ | Non couvert par les trois lots | Nom dans la lettre du manuel ; apparence physique non attestée ici. Aucune génération canonique autorisée par cette seule mention. |

### Apparences de rencontres de boss — 16 lignes

| ID | Sujet et édition | Type | État courant | Livraison ou travail restant |
|---|---|---|---|---|
| `hangedman` | Hangedman — HOTD 1 | Apparence de boss | Base livrée, lot 1 | [Hangedman — Type 041](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hangedman_base.png) — Adaptation statique HOTD 1 livrée au lot 1 ; le redesign Scarlet Dawn reste absent de cette livraison. |
| `hermit` | Hermit — HOTD 1 | Apparence de boss | Base livrée, lot 1 | [Hermit — Type 6803](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hermit_base.png) — Adaptation statique HOTD 1 livrée au lot 1 ; les atlas historiques restent un corpus distinct. |
| `judgment` | Judgment (Zeal + Kuarl) — HOTD 2 | Apparence de boss | Base livrée, lot 2 | [Zeal — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/zeal_base.png) · [Kuarl — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/kuarl_base.png) — Une ligne de rencontre, deux images livrées au lot 2 : Zeal et Kuarl. Animation coordonnée et comportement de rencontre restent à réaliser. |
| `tower` | Tower — HOTD 2 | Apparence de boss | Base livrée, lot 2 | [Tower — Type 8000](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/tower_base.png) — Une image du lot 2 regroupe les cinq têtes du boss ; une rencontre, aucune multiplication par cinq du roster. |
| `strength` | Strength — HOTD 2 | Apparence de boss | Base livrée, lot 2 | [Strength — Type 205](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/strength_base.png) — Base statique du lot 2 ; pose de garde adaptée. Les attaques, déplacements et transitions ne sont pas livrés. |
| `fool` | Fool — HOTD III | Apparence de boss | Base livrée, lot 2 | [Fool — Type 0028](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/fool_base.png) — Base statique du lot 2 ; pose suspendue recomposée, avec réserve de provenance sur le modèle secondaire utilisé en complément du visuel SEGA. |
| `sun` | Sun — HOTD III | Apparence de boss | Base livrée, lot 2 | [Sun — Type 8830](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/sun_base.png) — Base statique du lot 2 ; boss environnemental borné au cadre, racines et branches adaptées ; certains appendices restent masqués ou partiellement fermés. |
| `high_priestess` | High Priestess — Scarlet Dawn | Apparence de boss | Base livrée, lot 3 | [High Priestess](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/high_priestess_base.png) — Base Scarlet Dawn livrée au lot 3, comparée à une référence officielle. Une rencontre statique de galerie ; animation et comportement de boss non livrés. |
| `screamer` | Screamer — Overkill | Apparence de boss | Base livrée, lot 3 | [Screamer](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/screamer_base.png) — Base Overkill livrée au lot 3, comparée aux captures de jeu PS3 et à un visuel de menu Wii complémentaire. Une image statique ; comportements et différences entre éditions restent à documenter. |
| `nigel_sebastian` | Nigel & Sebastian — Overkill | Apparence de boss | Non couvert par les trois lots | Une rencontre peut réunir plusieurs individus ; cette ligne ne constitue pas un décompte d’identités. Référence visuelle de l’édition requise avant production. |
| `crawler` | Crawler — Overkill | Apparence de boss | Base livrée, lot 3 | [Crawler](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/crawler_base.png) — Base Overkill livrée au lot 3, comparée à des captures de jeu PS3. Une image statique ; animations, mouvements et comportement de rencontre restent ouverts. |
| `lobber` | Lobber — Overkill | Apparence de boss | Non couvert par les trois lots | Une rencontre peut réunir plusieurs individus ; cette ligne ne constitue pas un décompte d’identités. Référence visuelle de l’édition requise avant production. |
| `brutus` | Brutus — Overkill | Apparence de boss | Base livrée, lot 3 | [Brutus](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/brutus_base.png) — Base Overkill livrée au lot 3 après retrait, par une nouvelle génération, d’un motif de HUD interprété comme tatouage. Références de jeu PS3 comparées ; animations et comportement restent ouverts. |
| `mother` | Mother — boss — Overkill | Apparence de boss | Non couvert par les trois lots | Une rencontre peut réunir plusieurs individus ; cette ligne ne constitue pas un décompte d’identités. Référence visuelle de l’édition requise avant production. |
| `coco_sindy` | Coco & Sindy — Overkill Extended Cut | Apparence de boss | Non couvert par les trois lots | Une rencontre peut réunir plusieurs individus ; cette ligne ne constitue pas un décompte d’identités. Référence visuelle de l’édition requise avant production. |
| `meat_katie` | Meat Katie — Overkill Extended Cut | Apparence de boss | Non couvert par les trois lots | Une rencontre peut réunir plusieurs individus ; cette ligne ne constitue pas un décompte d’identités. Référence visuelle de l’édition requise avant production. Nom Meat Katie confirmé par le billet SEGA PlayStation du30août2011 ; graphie Meat Katey dans un index secondaire de collectibles, sans créer une seconde identité. |

### Tenues, équipements, modèles et formes — 27 lignes

| ID | Sujet et édition | Type | État courant | Livraison ou travail restant |
|---|---|---|---|---|
| `g_overkill` | Agent G — Overkill — Overkill | Apparence d’époque | Base livrée, lot 1 | [G — Overkill](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/g_overkill_base.png) — Variante d’époque du lot 1, liée au même Agent G ; galerie seulement, sans entrée au sélecteur de combat. |
| `g_hotd3` | Agent G — HOTDIII — HOTD III | Apparence d’époque | Base livrée, lot 1 | [Agent G — HOTD III](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/g_hotd3_base.png) — Variante d’époque du lot 1 ; vue et plis adaptés depuis les références, sans cycle d’animation propre. |
| `rogan_hotd3` | Thomas Rogan — HOTDIII — HOTD III | Apparence d’époque | Base livrée, lot 1 | [Thomas Rogan — HOTD III](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/rogan_hotd3_base.png) — Variante d’époque du lot 1 ; référence sous éclairage coloré et chaussures partiellement cachées, limites conservées. |
| `james_hotd4` | James Taylor — HOTD4 — HOTD 4 | Tenue d’une édition | Base livrée, lot 3 | [James Taylor — HOTD4](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/costumes/james_hotd4_base.png) — Variante HOTD 4 livrée au lot 3 : tenue et silhouette comparées aux éléments SEGA et au rendu entier, arme compacte corrigée par génération. Aucun costume de combat sélectionnable ajouté. |
| `g_hotd4special` | G — HOTD4 Special — HOTD 4 Special | Tenue d’une édition | Base livrée, lot 3 | [Agent G — HOTD4 Special](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/costumes/g_hotd4special_base.png) — Variante HOTD 4 Special livrée au lot 3 : costume bleu foncé et chemise bleue comparés au rendu entier et au flyer SEGA. Ne ferme ni G III, ni G Overkill, ni leurs animations. |
| `james_typing` | James — matériel de Typing — The Typing of the Dead | Variante d’équipement | Base livrée, lot 2 | [James Taylor — Typing](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/costumes/james_typing_base.png) — Matériel de Typing livré au lot 2 ; clavier, unité dorsale et batterie adaptés, détails et logos simplifiés. Pas de nouvelle identité. |
| `gary_typing` | Gary — matériel de Typing — The Typing of the Dead | Variante d’équipement | Base livrée, lot 2 | [Gary Stewart — Typing](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/costumes/gary_typing_base.png) — Matériel de Typing livré au lot 2 ; le dos de Gary n’est pas montré par les références récupérées, matériel commun recoupé sur d’autres agents. Pas de nouvelle identité. |
| `typing2_player_equipment` | Lisa/G/Daniel — équipement Typing2 — The Typing of the Dead 2 | Ensemble à documenter | Non couvert par les trois lots | Ne pas extrapoler un sac Dreamcast à partir du premier Typing. |
| `typing2004_kids` | James/Gary — Kids2004 — Typing 2004 | Variantes d’âge | Non couvert par les trois lots | Le wiki décrit des versions enfants ; capture ou manuel primaire exigé avant noms de variantes et génération. |
| `rogan_saturn2` | Rogan2 — Saturn Mode — HOTD 1 — Saturn Mode | Modèle alternatif | Non couvert par les trois lots | Modèle alternatif, pas seconde personne ; couleur et pièces de tenue non inventées. |
| `g_saturn2` | G2 — Saturn Mode — HOTD 1 — Saturn Mode | Modèle alternatif | Non couvert par les trois lots | Même règle. |
| `sophie_saturn` | Sophie — modèle Saturn Mode — HOTD 1 — Saturn Mode | Modèle d’un mode | Non couvert par les trois lots | PNJ narratif et sélection de mode sont deux statuts distincts. |
| `researcher_saturn` | Chercheur DBR — Saturn Mode — HOTD 1 — Saturn Mode | Modèle générique | Non couvert par les trois lots | Chercheurs génériques existent dans le jeu historique ; modèle de ce mode à comparer. |
| `stick_alts` | Stick — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les trois lots | Commande de changement attestée secondaire ; nombre et apparences distinctes non comptés. |
| `linda_alts` | Linda — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les trois lots | Ne pas transformer les8 nouvelles poses en8 tenues. |
| `rikiya_alts` | Rikiya — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les trois lots | Référence exacte requise pour une éventuelle tenue hommage ; pas de nom de film déduit seul. |
| `sophie_zombie` | Sophie — fin zombie — HOTD 1 | Forme de fin alternative | Non couvert par les trois lots | Même personne ; fin alternative et rééditions à identifier. |
| `goldman_zombie` | Goldman — fin zombie — HOTD 2 | Forme de fin alternative | Non couvert par les trois lots | Même personne ; ne pas substituer cette forme à Goldman humain. |
| `hotd_remake_redesigns` | Rogan/G/Sophie/Curien et boss — Remake1 — HOTD Remake | Apparences du remake | Non couvert par les trois lots | Comparer chaque redesign au jeu initial ; aucune nouvelle identité par défaut. |
| `hotd2_remake_redesigns` | Personnages et boss — Remake2 — HOTD 2 Remake | Apparences du remake | Non couvert par les trois lots | Comparer chaque redesign ; ne pas déclarer toutes les bases de1998 conformes au remake. |
| `original_model_amy` | Amy — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | La base Amy de galerie existe ; l’objet de substitution Original Mode et son intégration restent non livrés. |
| `original_model_harry` | Harry — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | La base Harry de galerie existe ; l’objet de substitution Original Mode et son intégration restent non livrés. |
| `original_model_g` | G — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | Objet remplaçant le modèle joueur ; ne rend pas le PNJ protagoniste de la campagne. Bruno est un invité extérieur, pas un agent AMS. |
| `original_model_rogan` | Rogan — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | Objet remplaçant le modèle joueur ; ne rend pas le PNJ protagoniste de la campagne. Bruno est un invité extérieur, pas un agent AMS. |
| `original_model_goldman` | Goldman — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | La base Goldman humaine existe ; l’objet de substitution Original Mode et son intégration restent non livrés. |
| `original_model_civilian` | Civilian — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | Objet remplaçant le modèle joueur ; ne rend pas le PNJ protagoniste de la campagne. Bruno est un invité extérieur, pas un agent AMS. |
| `original_model_bruno` | Bruno Delinger — objet Original Mode — HOTD 2 — Original Mode | Substitution de modèle | Substitution non livrée | Objet remplaçant le modèle joueur ; ne rend pas le PNJ protagoniste de la campagne. Bruno est un invité extérieur, pas un agent AMS. |

### Recherches préalables — 4 lignes

| ID | Sujet et édition | Type | État courant | Livraison ou travail restant |
|---|---|---|---|---|
| `site_doctor` | Docteur et créature de The Site of the Dead — The Site of the Dead | Recherche préalable | Recherche ouverte | Rôles du jeu mobile documentés ; noms, design et évolution à établir. |
| `reawakened_roster` | Personnages de Reawakened — Reawakened | Recherche préalable | Recherche ouverte | Annonce officielle vérifiée le20novembre ; aucun nouveau roster nominatif dérivé d’un décor ou de commentaires Reddit. |
| `mobile_nightmare_roster` | Variantes Mobile / Nightmare — Mobile / Nightmare | Recherche préalable | Recherche ouverte | Éditions et noms de personnages à recouper ; Mobile2/V/Deluxe ne créent pas de nouveaux héros sans preuve. |
| `ex_unverified_cameos` | Rôles des apparitions secondaires EX — Loving Deads EX | Recherche préalable | Recherche ouverte | Temperance/Lovers sont étiquetés cameo dans le projet. La catégorie de production boss_base ne prouve pas un combat de boss dans EX. |

Les sept lignes `original_model_*` sont des **objets de substitution du modèle joueur dans Original Mode** : Amy, Harry, G, Rogan, Goldman, Civilian et Bruno. Elles ne correspondent pas à sept identités nouvelles, et les bases Amy/Harry/Goldman livrées ne constituent pas l’implémentation de ces objets. Bruno reste un invité extérieur.

Les ensembles de tenues Dreamcast de Zombie Revenge restent à documenter : aucune palette, aucun nom de costume et aucun nombre de variantes ne sont déduits des poses. Les équipements Typing du lot 2 ne ferment ni Typing 2, ni Kids 2004, ni les variantes Mac/PS2. Les remakes conservent leurs propres tâches de comparaison.


### Réutilisation des ressources historiques

| Sujet | Ressources présentes dans le dépôt historique | État courant |
|---|---|---|
| Sophie Richards | `assets/sprites/heroes/sophie-hotd.png` ; `assets/sprites_v2/npcs/sophie_richards/sophie_richards__v2__action_cycle__8dirx8f.png` | Adaptation statique HOTD 1 livrée au lot 3 après comparaison du manuel et de captures arcade. Le maître historique ne servait pas de référence canonique. Chaussures et détails fins restent à confirmer ; la variante Saturn et les animations demeurent distinctes. |
| Dr. Curien | `assets/sprites/npcs/dr-curien.png` ; `assets/sprites_v2/npcs/dr_curien/dr_curien__v2__action_cycle__8dirx8f.png` | Adaptation humaine HOTD 1 livrée au lot 3 : ensemble beige, lunettes foncées et canne rosée comparés aux captures arcade. Les ressources historiques sont conservées ; Wheel of Fate reste une autre forme. |
| Hangedman | `assets/sprites/bosses/hangedman.png` ; `assets/sprites_v2/bosses/hangedman/hangedman__v2__action_cycle__8dirx8f.png` | Adaptation statique HOTD 1 livrée au lot 1 ; le redesign Scarlet Dawn reste absent de cette livraison. |
| Hermit | `assets/sprites/bosses/hermit-type-6803.png` ; `assets/sprites_v2/bosses/hermit/hermit__v2__action_cycle__8dirx8f.png` | Adaptation statique HOTD 1 livrée au lot 1 ; les atlas historiques restent un corpus distinct. |

Ces chemins historiques sont présents dans l’index Git. Les deux maîtres Sophie et Curien ont également été inspectés pour la production du lot 3 : leurs différences avec les captures du jeu ont conduit à privilégier le manuel et les images arcade pour les nouvelles bases. Ils restent conservés sans modification. Sophie et Curien ne deviennent donc pas deux identités nouvelles. Un atlas ancien animé ne garantit ni le style, ni l’ancrage, ni la compatibilité avec le combat Dossier Curien.

## Les 35 rencontres de boss, par édition

Ce tableau conserve les 35 couples rencontre/édition initiaux, dans le même ordre. Judgment rassemble Zeal et Kuarl ; Tower regroupe cinq têtes ; Nigel & Sebastian et Coco & Sindy sont des paires. La forme humaine de Curien et Wheel of Fate sont distinctes. Les apparences d’autres épisodes et les fiches étiquetées EX ne certifient pas automatiquement la version examinée.

| Jeu / édition | Rencontre | Couverture courante de la base |
|---|---|---|
| HOTD 1 | Chariot | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 1 | Hangedman | Galerie statique : [Hangedman — Type 041](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hangedman_base.png) ; non jouable, animations ouvertes. |
| HOTD 1 | Hermit | Galerie statique : [Hermit — Type 6803](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hermit_base.png) ; non jouable, animations ouvertes. |
| HOTD 1 | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 2 | Judgment (Zeal + Kuarl) | Galerie statique : [Zeal — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/zeal_base.png) + [Kuarl — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/kuarl_base.png) ; non jouable, animations ouvertes. Deux images, une rencontre. |
| HOTD 2 | Hierophant | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 2 | Tower | Galerie statique : [Tower — Type 8000](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/tower_base.png) ; non jouable, animations ouvertes. Cinq têtes, une image et une rencontre. |
| HOTD 2 | Strength | Galerie statique : [Strength — Type 205](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/strength_base.png) ; non jouable, animations ouvertes. |
| HOTD 2 | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 2 | Emperor | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD III | Death | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD III | Fool | Galerie statique : [Fool — Type 0028](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/fool_base.png) ; non jouable, animations ouvertes. |
| HOTD III | Sun | Galerie statique : [Sun — Type 8830](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/sun_base.png) ; non jouable, animations ouvertes. |
| HOTD III | Wheel of Fate | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 4 | Justice | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 4 | Lovers | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD 4 | Empress | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD 4 | Temperance | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD 4 | Star | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD 4 | The World | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 4 Special | Justice | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD 4 Special | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Scarlet Dawn | Chariot | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Scarlet Dawn | Hangedman | La base HOTD 1 du lot 1 ne couvre pas le redesign Scarlet Dawn. |
| Scarlet Dawn | High Priestess | Galerie statique : [High Priestess](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/high_priestess_base.png) ; non jouable, animations ouvertes. |
| Scarlet Dawn | Moon | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Overkill | Jasper Guns — mutant | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Overkill | Screamer | Galerie statique : [Screamer](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/screamer_base.png) ; non jouable, animations ouvertes. |
| Overkill | Nigel & Sebastian | Aucune base dédiée livrée pour cette rencontre par les trois lots ; références et production restent à traiter. |
| Overkill | Crawler | Galerie statique : [Crawler](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/crawler_base.png) ; non jouable, animations ouvertes. |
| Overkill | Lobber | Aucune base dédiée livrée pour cette rencontre par les trois lots ; références et production restent à traiter. |
| Overkill | Brutus | Galerie statique : [Brutus](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/brutus_base.png) ; non jouable, animations ouvertes. |
| Overkill | Mother — boss | Aucune base dédiée livrée pour cette rencontre par les trois lots ; références et production restent à traiter. |
| Overkill Extended Cut | Coco & Sindy | Aucune base dédiée livrée pour cette rencontre par les trois lots ; références et production restent à traiter. |
| Overkill Extended Cut | Meat Katie | Aucune base dédiée livrée pour cette rencontre par les trois lots ; références et production restent à traiter. |

Répartition des 35 lignes : **14** disposent d’une base d’identité déjà jouable dont la variante d’édition reste à vérifier ; **11** reçoivent une base statique de galerie dans les trois lots ; **4** disposent d’une fiche sous une autre étiquette d’édition ; **1** garde un redesign Scarlet Dawn manquant ; **5** n’ont reçu aucune base dédiée. Les 14 premières sont des lignes de rencontre, pas un nouveau décompte d’identités distinctes. Les cinq rencontres sans base sont Nigel & Sebastian, Lobber, Mother, Coco & Sindy et Meat Katie.

## Couverture du corpus : 31 entrées principales

Ce registre conserve le périmètre documenté des jeux et éditions et rapproche les nouvelles livraisons ; il ne prétend pas réexaminer chaque créature, figurant, palette, salle ou variante de toutes les éditions. Les références externes héritées conservent leurs limites d’accès et de vérification. Les 31 entrées ne désignent pas 31 jeux narratifs principaux : ports, services, spin-offs et attractions y sont distingués.

| Œuvre / édition | Type de branche | État courant du recensement |
|---|---|---|
| The House of the Dead | arcade | Hangedman et Hermit adaptés au lot 1 ; Sophie et Curien humains adaptés au lot 3 après comparaison des références originales. Sophie conserve une réserve de détail ; figurants, autres variantes et animations ne sont pas exhaustifs. |
| The House of the Dead 2 | arcade | Amy/Harry/Goldman humains et Judgment/Tower/Strength ont une base de galerie. Original Mode, foules et variantes restent distincts. |
| The House of the Dead III | arcade | G/Rogan III et Fool/Sun ont une base statique ; autres tenues, personnages secondaires et animations restent ouverts. |
| The House of the Dead 4 | arcade | James reçoit une variante statique HOTD 4 au lot 3. Les fiches Lovers, Empress, Temperance et Star étiquetées EX ne ferment pas leur adaptation HOTD 4 ; foules et variantes restent ouvertes. |
| The House of the Dead 4 Special | prolongement narratif | G reçoit une variante statique propre à Special au lot 3. Justice et Magician conservent une vérification d’apparence par édition ; aucune nouvelle tenue de combat sélectionnable. |
| House of the Dead: Scarlet Dawn | arcade | Thornheart est livré avec bas de tenue à confirmer ; High Priestess reçoit une base statique au lot 3. Le redesign Hangedman Scarlet Dawn reste ouvert. |
| The House of the Dead: Overkill | branche grindhouse | Varla, G Overkill, Papa et Clement ont une base avec des statuts distincts. Screamer, Crawler et Brutus reçoivent une base au lot 3 ; Nigel & Sebastian, Lobber, Mother et les formes humaines restent ouverts. |
| The House of the Dead: Overkill – Extended Cut | édition étendue | Varla/Candi en galerie, avec vérification de tenue encore ouverte ; boss supplémentaires et variantes restent à produire. |
| The House of the Dead: Overkill – The Lost Reels | adaptation mobile | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| Zombie Revenge | beat’em up | Trio jouable et 42 ressources d’expansion déjà indexés, dont 33 fiches ; tenues alternatives à documenter. |
| Loving Deads: The House of the Dead EX | arcade à mini-jeux | Duo jouable et sept fiches déjà indexés ; rôles exacts des apparitions secondaires à confirmer. |
| The Typing of the Dead | arcade à clavier | James/Gary avec matériel livrés au lot 2 ; ni identités nouvelles ni costumes de combat sélectionnables. Ports et variantes non exhaustifs. |
| The Typing of the Dead 2 | Windows | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead: Zombie Panic | édition PS2 | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead Online | service PC | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead: Overkill | Windows | Les références de cette version documentent certaines bases Overkill ; aucune nouvelle identité n’est comptée par duplication de port. |
| K-Typing of the Dead | service J-PHONE | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| Zombie Da: Flick of the Dead | iPhone | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| English of the Dead | Nintendo DS | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Pinball of the Dead | Game Boy Advance | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| Darts of the Dead | DARTSLIVE2 | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Site of the Dead | RPG i-mode | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The House of the Dead Mobile | Japon, téléphone | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The House of the Dead: Nightmare | téléphone Java | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The House of the Dead 2 & 3 Return | compilation Wii | Identités communes ; différences propres à cette édition encore à comparer. |
| The House of the Dead: Remake | remake du premier jeu | Identités communes ; différences propres à cette édition encore à comparer. |
| The House of the Dead 2: Remake | remake du deuxième jeu | Identités communes ; différences propres à cette édition encore à comparer. |
| House of the Dead: Scarlet Dawn – The Attraction | attraction de groupe | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| House of the Dead: Scarlet Dawn – Battle Genesis | machine à sous | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| Winning Cash – House of the Dead Scarlet Dawn on Reels | machine à sous | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| House of the Dead: Reawakened | attraction d’arcade VR | Titre officiel documenté dans le registre ; liste nominative non établie. |

### Cinq fiches d’éditions complémentaires

Certaines fiches regroupent plusieurs titres : cinq fiches ne signifie pas cinq identités de jeu supplémentaires. Leur présence dans le corpus ne prouve pas un nouveau costume.

| Édition ou groupe | État | Sources héritées |
|---|---|---|
| The Typing of the Dead 2003 ; The Typing of the Dead 2004 | Édition consignée ; nouveautés visuelles non supposées. | [Source 1](https://game.watch.impress.co.jp/docs/20021025/sega.htm) · [Source 2](https://www.sega.jp/game/pc/?page=8) |
| The Typing of the Dead featuring Rakuten Minna no Shūshoku Katsudō Nikki ; Zombie Da: Typing Lariat for Mac | Édition consignée ; nouveautés visuelles non supposées. | [Source 1](https://www.sega.jp/game/pc/?mode=view&page=6) |
| The Typing of the Dead US Edition | Édition consignée ; nouveautés visuelles non supposées. | [Source 1](https://www.suruga-ya.jp/product/detail/145020547) |
| The Typing of the Dead, édition à prix révisé (2005) | Édition consignée ; nouveautés visuelles non supposées. | [Source 1](https://www.sega.jp/game/pc/?mode=start&page=7) |
| Zombie Da: Typing Lariat (Windows) | Édition consignée ; nouveautés visuelles non supposées. | [Source 1](https://www.sega.jp/game/pc/?mode=start&page=7) |

### Pistes d’archives et homonymes

| Intitulé | Qualification héritée du registre | Source |
|---|---|---|
| The Kanji of the Dead | titre provisoire présenté en 2007 ; sortie à établir | [Référence](https://game.watch.impress.co.jp/docs/20070420/segat.htm) |
| Zombie Buster | homonyme mobile classé chez Capcom | [Référence](https://game.watch.impress.co.jp/docs/20011228/jsky.htm) |
| Blood Bullet: The House of the Dead Side Story | nom de travail de Zombie Revenge | [Référence](https://www.mobygames.com/group/365/the-house-of-the-dead-series/) |
| The House of the Dead for Mobile | intitulé de fiche de plateforme pour Mobile 2005 | [Référence](https://gamefaqs.gamespot.com/mobile/928541-the-house-of-the-dead) |

### Cinéma et créations du projet

Les films et projets de film appartiennent à une continuité séparée. Leurs noms ne sont pas ajoutés au roster des jeux.

| Œuvre | Qualification consignée | Source |
|---|---|---|
| House of the Dead | adaptation cinéma | [Référence](https://catalog.afi.com/Catalog/moviedetails/62771) |
| House of the Dead 2: Dead Aim | adaptation cinéma | [Référence](https://www.sonypictures.jp/he/824693) |
| The House of the Dead, projet de Paul W. S. Anderson | projet annoncé par Story Kitchen ; aucune campagne de jeu attribuée | [Référence](https://www.story-kitchen.com/news/tomb-raider-the-legend-of-lara-croft-renewed-for-season-2-at-netflix-hmysa) |

*Requiem* et *Absolution* sont des histoires créées pour ce projet. Les invités SEGA restent des invités. *Blood Bullet* reste un nom de travail de *Zombie Revenge*. Aucun titre provisoire, homonyme ou décor d’annonce n’autorise à inventer une liste de personnages.

**Restent ouverts dans la couverture globale :** ennemis ordinaires hors sous-ensemble déjà indexé, figurants, formes mobiles, personnages du laboratoire Site, détails de Kids 2004, silhouettes nominatives de Reawakened, variations d’édition et redesigns précis des remakes. Ce périmètre déborde les 34 tâches non couvertes : aucun pourcentage d’exhaustivité de toute la saga n’est calculé.


## Preuves, contrôles et portée

La chaîne historique reste consultable : [inventaire initial JSON](../catalogue_2026-11-20/personnages_tenues.json), [delta du lot 1](../catalogue_2026-11-20/delta_livraison.json), [inventaire après le lot 2](../catalogue_2026-11-20_lot2/personnages_tenues.json) et [snapshot af0e4933](baseline_af0e4933.json). Les références initiales sont conservées dans le [registre personnages et tenues](../catalogue_2026-11-20/sources_personnages_tenues.json) et le [corpus SOURCES_SAGA](../../SOURCES_SAGA.json).

Les [sources humaines du lot 2](../catalogue_2026-11-20_lot2/sources_humans.json) restent applicables à ses livraisons. Pour le lot 3, les sources précises et les chemins locaux inspectés figurent dans les trois reçus : [humains](humans_generated.json), [boss](bosses_generated.json) et [variantes](costumes_generated.json). Les empreintes de tous les fichiers ayant servi au rapprochement sont conservées dans le JSON courant. Le [suivi des stages courant](STAGES_MANQUANTS.md) garde séparément ses 61 lignes de lieux et ses 24 indices d’arènes couverts ; l’enclos de Fool et la chambre BIO de Sun restent des adaptations partielles de leur chapitre.

Contrôles documentaires : les 62 IDs de tâches et les 35 couples rencontre/édition sont conservés ; 28 tâches reçoivent exactement 29 assets distincts ; les 34 autres IDs restent explicitement listés. Les six statuts visuels ouverts cités correspondent aux reçus. Les empreintes et tailles des 29 images de galerie, leurs références locales et les 14 PNG de jeu nouveaux du lot 3 ont été contrôlés. Les profils, routes, arènes et Archives ont été recomptés dans les constantes du code ; le total PNG est rapproché du snapshot Git et de l’ensemble des chemins locaux. Les compteurs d’animations manquantes et de masters non récupérés restent distincts et inchangés.

Ce document ne constitue pas une nouvelle revue visuelle de toutes les sources du corpus, une capture moteur ou une preuve d’export. Les rapports de production décrivent les comparaisons des huit bases du lot 3 ; les tests d’intégration, la publication et les distributions relèvent de la validation du lot global. Les anciens inventaires datés ne sont pas réécrits.
