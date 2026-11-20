# Personnages, formes et tenues — inventaire courant après le lot 4

**62 lignes de travail suivies : 36 ont reçu une base statique au fil des quatre lots, pour 38 nouvelles fiches de galerie ; 26 lignes ne sont pas couvertes par ces livraisons.** Le projet conserve 24 combattants jouables. Une image entière de galerie n’ajoute pas à elle seule un combattant animé ou une tenue sélectionnable.

État documentaire du **20 novembre 2026**. Le point initial `59372b618882da17510351f2a5bd46226682eac4` reste historique et gelé. La comparaison du lot 4 part du commit publié `c7162f7bb46aa7a3ef0546124949e96e2f25bc49`. Les tableaux décrivent les sources et les livraisons assemblées après ce point, sans présumer un export ou une publication distante.

Le [registre JSON courant](personnages_tenues.json) conserve les 62 identifiants initiaux dans leur ordre, leurs statuts et références historiques, les livraisons rattachées, les réserves exactes et les 35 rencontres de boss par édition. L’[inventaire initial](../catalogue_2026-11-20/PERSONNAGES_TENUES.md), le [delta du lot 1](../catalogue_2026-11-20/delta_livraison.json) et les inventaires après les [lots 2](../catalogue_2026-11-20_lot2/PERSONNAGES_TENUES.md) et [3](../catalogue_2026-11-20_lot3/PERSONNAGES_TENUES.md) restent inchangés.

## Compteurs à lire séparément

| Indicateur | Initial 59372b6 | Avant lot 2 — 6291e0d | Avant lot 3 — af0e4933 | Avant lot 4 — c7162f7b | Courant après lot 4 |
|---|---:|---:|---:|---:|---:|
| Combattants jouables | 24 | 24 | 24 | 24 | **24** |
| Routes Histoire du projet | 26 | 26 | 26 | 26 | **26** |
| Arènes enregistrées | 18 | 20 | 22 | 24 | **26** |
| Entrées Archives | 29 | 29 | 29 | 29 | **29** |
| Fiches de galerie | 40 | 49 | 61 | 69 | **78** |
| Chemins PNG Dossier Curien | 332 | 347 | 365 | 379 | **394** |
| Blobs Git PNG distincts | 330 | 345 | 363 | 377 | **392** |
| Tenues alternatives sélectionnables | 2 | 2 | 2 | 2 | **2** |
| Poses minimales nommées encore manquantes | 277 | 277 | 277 | 277 | **277** |
| Masters historiques encore non récupérés | 204 | 204 | 204 | 204 | **204** |

Les routes, arènes et Archives sont des adaptations et structures du projet. Ces nombres ne décrivent pas autant de chapitres, jeux ou personnages originaux. Les PNG mélangent personnages, poses, décors et accessoires ; les références documentaires et les sorties écartées hors du répertoire des assets Dossier Curien sont exclues du total.

Le [snapshot c7162f7b](baseline_c7162f7b.json) fournit 379 chemins et 377 blobs. Les **15 PNG retenus pour le jeu au lot 4 — 9 silhouettes de galerie et 6 plans d’arènes —** ont des empreintes distinctes et portent le total à 394 chemins / 392 blobs. Les quatre lots réunis ajoutent 38 silhouettes de galerie et 24 plans d’arènes. La galerie conserve ses 40 fiches initiales et reçoit 9 + 12 + 8 + 9 fiches.

**Mother mutée n’a pas été produite.** Sa tentative du lot 4 a été bloquée par le filtre de sortie d’ImageGen (`HTTP400`, `moderation_blocked`, catégorie `sexual`) sans image. Elle ne compte ni comme PNG, ni comme fiche, ni comme tâche couverte. La forme humaine de Mother en fauteuil ne remplace pas sa forme de boss. Les autres essais écartés et références d’édition restent séparés des images retenues pour le jeu.

Le lot motion du 19 novembre reste à 30 entrées : 24 nouveaux dessins retenus, 4 récupérations et 2 gardes EX recâblées. Les bases statiques ne réduisent pas son [suivi des 277 poses](../motion_2026-11-19/MANQUANTS.json). Les 204 masters historiques non récupérés ne sont pas restaurés par de nouvelles générations.

## Comment les livraisons se rattachent aux tâches

| Livraison | Lignes recevant une base | PNG de galerie | Détail |
|---|---:|---:|---|
| Lot 1 | 9 | 9 | 4 bases humaines, 3 variantes d’époque, Hangedman et Hermit HOTD1. |
| Lot 2 — humains | 4 | 4 | Goldman humain, Thornheart, Papa Caesar, Clement Darling. |
| Lot 2 — boss | 5 | 6 | Judgment donne deux silhouettes, Zeal et Kuarl ; Tower, Strength, Fool et Sun en donnent une chacun. |
| Lot 2 — équipements | 2 | 2 | James et Gary dans The Typing of the Dead. |
| Lot 3 — adaptations humaines | 2 | 2 | Sophie Richards et Dr. Curien HOTD1 ; identités déjà présentes dans les ressources historiques. |
| Lot 3 — boss | 4 | 4 | High Priestess, Screamer, Crawler et Brutus. |
| Lot 3 — variantes d’édition | 2 | 2 | James HOTD4 et G HOTD4 Special ; identités déjà connues. |
| Lot 4 — formes | 4 | 4 | Jasper et Mother humains ; Sophie fin zombie arcade et Goldman fin zombie HOTD2. |
| Lot 4 — boss | 4 | 5 | Nigel & Sebastian conjoint, Lobber, Coco + Sindy, Meat Katie. Mother mutée reste sans image. |
| **Cumul** | **36** | **38** | **26 lignes initiales restent non couvertes par les quatre lots.** |

Les 62 lignes sont des identités, formes, apparences de rencontre, ensembles de variantes ou recherches. **26 lignes ne signifie pas 26 personnages uniques restants.** Les 35 rencontres ci-dessous recoupent une partie de ces tâches et ne s’y additionnent pas. Une livraison ferme seulement l’étape « disposer d’une image statique » ; validation des détails, animations et intégration jouable peuvent rester ouvertes.

`judgment` se rattache à `zeal` + `kuarl`, et `coco_sindy` à `coco` + `sindy` : deux PNG pour chacune de ces lignes de rencontre. `nigel_sebastian` garde un seul PNG de corps conjoint. `clement` se rattache à `clement_darling`, `sophie` à `sophie_richards`, et `curien` à `dr_curien`. Tower est une rencontre représentée avec cinq têtes dans une seule image. La livraison `hangedman` couvre HOTD1 ; le redesign Scarlet Dawn demeure un manque distinct du tableau des rencontres.

Reçus du lot 4 : [formes de personnages](humans_generated.json) et [boss](bosses_generated.json). Les [comparaisons des formes](HUMANS.md) et le [rapport des boss](BOSSES.md) précisent les références, prompts, sorties retenues ou écartées, blocage et réserves. Ils ne certifient aucune reproduction 1:1. Les PNG natifs de production sont conservés inchangés ; certains extraits de sources sont des recadrages d’analyse, décrits comme tels dans les reçus.

## Références visuelles encore ouvertes dans les quatre lots

**Neuf des 38 fiches nouvelles portent explicitement un statut de vérification visuelle ouverte** : Varla, Candi, Thornheart, Papa Caesar, Clement, Sophie humaine, Jasper humain, Mother humaine et Sophie fin zombie. Ce compte concerne les quatre lots de galerie ; il ne représente pas tous les statuts ouverts dans les 78 fiches globales. Les 29 autres images gardent les réserves de leurs manifestes.

| Fiche | Point restant à confirmer |
|---|---|
| Varla Guns | Bas de tenue reconstruit ; référence plein pied à recouper. |
| Candi Stryper | Bas de tenue reconstruit ; référence plein pied à recouper. |
| Thornheart | Le portrait officiel ne montre ni pantalon ni chaussures. |
| Papa Caesar | Mocassins et détails de canne décrits par une source secondaire, encore peu lisibles dans les captures. |
| Clement Darling | Référence de cinématique limitée au buste ; pantalon, chaussures et stature entière adaptés. |
| Sophie Richards humaine | Chaussures visibles à petite échelle ; teinte, finition et certains détails des bas restent à recouper. |
| Jasper Guns humain | Bas du fauteuil, roues, repose-pieds et chaussures insuffisamment résolus. |
| Mother humaine | Ourlet, pieds du fauteuil et chaussures couvertes par la robe insuffisamment attestés. |
| Sophie fin zombie arcade | Visage et yeux visibles dans une très petite vignette ; chaussures, accroche et lettrage DBR du badge à vérifier. |

Les autres limites restent applicables : bottes d’Amy dont la couleur est interprétée depuis un manuel monochrome, chaussures partiellement cachées de Rogan III, dos de Gary Typing non montré, connectique et logos simplifiés, modèles secondaires de Fool/Sun, composition bornée de Sun. Au lot 4, le port exact du rendu de Goldman et de certaines références boss n’est pas établi ; détails cachés, textures et proportions restent adaptés. Les détails du pied altéré de Meat Katie restent peu lisibles dans une vignette de 320×180. Les limites des références PS3 ou de la famille visuelle Extended Cut/Typing ne disparaissent pas parce que l’ID de jeu est regroupé sous `overkill`. Mother mutée, sans fiche produite, n’entre pas dans ces neuf statuts de fiches livrées.

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



Les quatre formes du lot 4 restent elles aussi des fiches de bestiaire. Jasper humain ne crée pas un second profil Jasper ; Sophie et Goldman zombies ne rendent pas leurs transformations jouables.

## Registre courant des 62 lignes

Les identifiants sont ceux de l’inventaire initial. Statuts, priorités et états de référence historiques sont conservés dans le JSON. Les tableaux donnent l’état courant, la livraison et la suite nécessaire. Une réserve de détail sur une base livrée reste distincte des 26 lignes sans base issue des quatre lots.

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
| `dan_taylor` | Dan Taylor — HOTD III | Personnage secondaire ; Partenaire jouable du prologue, attribution à corroborer | Non couvert par les quatre lots | Nom et rôle à corroborer au générique ; capture de jeu visible. Ne pas confondre avec Daniel Curien ni renommer Scott. |
| `yukio` | Yukio — HOTD III | Personnage secondaire ; PNJ et forme de créature à documenter | Non couvert par les quatre lots | Identité secondaire et forme à documenter avant production ; pas de costume inventé. |
| `jasper_human` | Jasper Guns — forme humaine — Overkill | Forme humaine ; Forme humaine d’un PNJ | Base livrée, lot 4 ; référence à confirmer | [Jasper Guns — forme humaine](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/characters/jasper_human_base.png) — Forme humaine avant mutation livrée au lot 4 : lunettes, chemise olive, débardeur violet et posture assise comparés à la cinématique. Bas du fauteuil, roues, repose-pieds et chaussures restent interprétés. Même identité que Jasper boss, sans nouveau profil jouable. |
| `mother_human` | Mother — forme humaine — Overkill | Forme humaine ; Forme humaine d’un PNJ | Base livrée, lot 4 ; référence à confirmer | [Mother — forme humaine](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/characters/mother_human_base.png) — Forme humaine assise livrée au lot 4 : visage âgé, voile à roses, robe ivoire et fauteuil rouge comparés à la cinématique. Bas de robe et de fauteuil restent interprétés ; pieds couverts. Cette fiche ne livre pas Mother mutée. |
| `bart_picard` | Bart Picard — Overkill | Personnage secondaire ; Mention textuelle ou hors champ | Non couvert par les quatre lots | Nom dans la lettre du manuel ; apparence physique non attestée ici. Aucune génération canonique autorisée par cette seule mention. |

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
| `nigel_sebastian` | Nigel & Sebastian — Overkill | Apparence de boss | Base livrée, lot 4 | [Nigel & Sebastian](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/nigel_sebastian_base.png) — Une base statique conjointe livrée au lot 4 pour la rencontre Nigel & Sebastian ; un PNG, pas deux nouvelles fiches. Références de jeu comparées ; port d’une capture non authentifié, aucune équivalence exhaustive Wii/PS3/PC fermée. Comportements et animations non livrés. |
| `crawler` | Crawler — Overkill | Apparence de boss | Base livrée, lot 3 | [Crawler](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/crawler_base.png) — Base Overkill livrée au lot 3, comparée à des captures de jeu PS3. Une image statique ; animations, mouvements et comportement de rencontre restent ouverts. |
| `lobber` | Lobber — Overkill | Apparence de boss | Base livrée, lot 4 | [Lobber](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/lobber_base.png) — Base statique livrée au lot 4 ; rendu entier croisé avec des références de jeu PS3. Le port exact du rendu entier n’est pas garanti, et les comportements/animations restent ouverts. |
| `brutus` | Brutus — Overkill | Apparence de boss | Base livrée, lot 3 | [Brutus](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/brutus_base.png) — Base Overkill livrée au lot 3 après retrait, par une nouvelle génération, d’un motif de HUD interprété comme tatouage. Références de jeu PS3 comparées ; animations et comportement restent ouverts. |
| `mother` | Mother — boss — Overkill | Apparence de boss | Base non livrée ; génération bloquée | Mother mutée reste sans base. La tentative du lot 4 a été bloquée en sortie par ImageGen (HTTP400, moderation_blocked, catégorie sexual), sans image produite ni relance équivalente. La forme humaine assise est une autre fiche et ne couvre pas cette rencontre. |
| `coco_sindy` | Coco & Sindy — Overkill Extended Cut | Apparence de boss | Base livrée, lot 4 | [Coco](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/coco_base.png) · [Sindy](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/sindy_base.png) — Deux images statiques livrées au lot 4, Coco et Sindy, pour une seule ligne de rencontre. Coco conserve quatre appuis après correction générée. Références de la famille visuelle Extended Cut/Typing, sans plateforme précise affirmée pour toutes les captures ; animations et comportement du duo restent ouverts. |
| `meat_katie` | Meat Katie — Overkill Extended Cut | Apparence de boss | Base livrée, lot 4 | [Meat Katie](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/meat_katie_base.png) — Base statique livrée au lot 4 pour la rencontre Meat Katie de l’édition étendue, d’après les références de jeu retenues. Aucune animation ou simulation du combat ajoutée. |

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
| `typing2_player_equipment` | Lisa/G/Daniel — équipement Typing2 — The Typing of the Dead 2 | Ensemble à documenter | Non couvert par les quatre lots | Ne pas extrapoler un sac Dreamcast à partir du premier Typing. |
| `typing2004_kids` | James/Gary — Kids2004 — Typing 2004 | Variantes d’âge | Non couvert par les quatre lots | Le wiki décrit des versions enfants ; capture ou manuel primaire exigé avant noms de variantes et génération. |
| `rogan_saturn2` | Rogan2 — Saturn Mode — HOTD 1 — Saturn Mode | Modèle alternatif | Non couvert par les quatre lots | Modèle alternatif, pas seconde personne ; couleur et pièces de tenue non inventées. |
| `g_saturn2` | G2 — Saturn Mode — HOTD 1 — Saturn Mode | Modèle alternatif | Non couvert par les quatre lots | Même règle. |
| `sophie_saturn` | Sophie — modèle Saturn Mode — HOTD 1 — Saturn Mode | Modèle d’un mode | Non couvert par les quatre lots | PNJ narratif et sélection de mode sont deux statuts distincts. |
| `researcher_saturn` | Chercheur DBR — Saturn Mode — HOTD 1 — Saturn Mode | Modèle générique | Non couvert par les quatre lots | Chercheurs génériques existent dans le jeu historique ; modèle de ce mode à comparer. |
| `stick_alts` | Stick — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les quatre lots | Commande de changement attestée secondaire ; nombre et apparences distinctes non comptés. |
| `linda_alts` | Linda — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les quatre lots | Ne pas transformer les8 nouvelles poses en8 tenues. |
| `rikiya_alts` | Rikiya — tenues alternatives Dreamcast — Zombie Revenge | Ensemble de tenues | Non couvert par les quatre lots | Référence exacte requise pour une éventuelle tenue hommage ; pas de nom de film déduit seul. |
| `sophie_zombie` | Sophie — fin zombie — HOTD 1 | Forme de fin alternative | Base livrée, lot 4 ; référence à confirmer | [Sophie Richards — fin zombie arcade](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/characters/sophie_zombie_base.png) — Forme de la fin arcade originale livrée au lot 4 ; distincte des versions Saturn/Windows et des remakes. Réserves sur visage, yeux, chaussures et badge/lettrage DBR. Une forme de Sophie, sans nouvelle identité ni animation de transformation. |
| `goldman_zombie` | Goldman — fin zombie — HOTD 2 | Forme de fin alternative | Base livrée, lot 4 | [Goldman — fin zombie HOTD2](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/characters/goldman_zombie_base.png) — Forme de la fin HOTD2 originale livrée au lot 4 et comparée à deux captures, dont une entière. Port précis non établi ; textures et proportions restent adaptées. Ne remplace ni Goldman humain ni la version de HOTD4. |
| `hotd_remake_redesigns` | Rogan/G/Sophie/Curien et boss — Remake1 — HOTD Remake | Apparences du remake | Non couvert par les quatre lots | Comparer chaque redesign au jeu initial ; aucune nouvelle identité par défaut. |
| `hotd2_remake_redesigns` | Personnages et boss — Remake2 — HOTD 2 Remake | Apparences du remake | Non couvert par les quatre lots | Comparer chaque redesign ; ne pas déclarer toutes les bases de1998 conformes au remake. |
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

Ces chemins historiques sont présents dans l’index Git. Les maîtres Sophie et Curien ont été inspectés au lot 3 : leurs différences avec les captures du jeu ont conduit à privilégier manuel et vues arcade pour les nouvelles bases. Ils restent conservés. Sophie et Curien ne deviennent pas deux identités nouvelles ; une forme de fin ne remplace pas leur base humaine. Un atlas historique animé ne garantit ni le style, ni l’ancrage, ni la compatibilité avec le combat Dossier Curien.

## Les 35 rencontres de boss, par édition

Ce tableau conserve les 35 couples rencontre/édition initiaux, dans le même ordre. Judgment rassemble Zeal et Kuarl ; Tower regroupe cinq têtes ; Nigel & Sebastian est un corps conjoint ; Coco & Sindy est une rencontre représentée par deux images. La forme humaine de Curien et Wheel of Fate sont distinctes, comme Mother humaine et Mother mutée. Une apparence d’un autre épisode ou une fiche étiquetée EX ne certifie pas automatiquement la version examinée.

| Jeu / édition | Rencontre | Couverture courante de la base |
|---|---|---|
| HOTD1 | Chariot | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD1 | Hangedman | Galerie statique : [Hangedman — Type 041](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hangedman_base.png) ; non jouable, animations ouvertes. |
| HOTD1 | Hermit | Galerie statique : [Hermit — Type 6803](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hermit_base.png) ; non jouable, animations ouvertes. |
| HOTD1 | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD2 | Judgment (Zeal + Kuarl) | Galerie statique : [Zeal — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/zeal_base.png) + [Kuarl — Judgment](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/kuarl_base.png) ; non jouable, animations ouvertes. Deux images, une rencontre. |
| HOTD2 | Hierophant | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD2 | Tower | Galerie statique : [Tower — Type 8000](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/tower_base.png) ; non jouable, animations ouvertes. Cinq têtes, une image et une rencontre. |
| HOTD2 | Strength | Galerie statique : [Strength — Type 205](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/strength_base.png) ; non jouable, animations ouvertes. |
| HOTD2 | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD2 | Emperor | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD III | Death | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD III | Fool | Galerie statique : [Fool — Type 0028](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/fool_base.png) ; non jouable, animations ouvertes. |
| HOTD III | Sun | Galerie statique : [Sun — Type 8830](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/sun_base.png) ; non jouable, animations ouvertes. |
| HOTD III | Wheel of Fate | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD4 | Justice | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD4 | Lovers | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD4 | Empress | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD4 | Temperance | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD4 | Star | Une fiche existe sous l’étiquette EX ; son fichier ne ferme pas l’adaptation HOTD 4 de cette rencontre. |
| HOTD4 | The World | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD4 Special | Justice | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| HOTD4 Special | Magician | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Scarlet Dawn | Chariot | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Scarlet Dawn | Hangedman | La base HOTD 1 du lot 1 ne couvre pas le redesign Scarlet Dawn. |
| Scarlet Dawn | High Priestess | Galerie statique : [High Priestess](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/high_priestess_base.png) ; non jouable, animations ouvertes. |
| Scarlet Dawn | Moon | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Overkill | Jasper Guns — mutant | Une base de cette identité est déjà jouable dans Dossier Curien ; cela ne certifie pas l’apparence exacte de cette édition. |
| Overkill | Screamer | Galerie statique : [Screamer](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/screamer_base.png) ; non jouable, animations ouvertes. |
| Overkill | Nigel & Sebastian | Galerie statique : [Nigel & Sebastian](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/nigel_sebastian_base.png) ; non jouable, animations ouvertes. Corps conjoint, une image et une rencontre. |
| Overkill | Crawler | Galerie statique : [Crawler](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/crawler_base.png) ; non jouable, animations ouvertes. |
| Overkill | Lobber | Galerie statique : [Lobber](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/lobber_base.png) ; non jouable, animations ouvertes. |
| Overkill | Brutus | Galerie statique : [Brutus](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/brutus_base.png) ; non jouable, animations ouvertes. |
| Overkill | Mother — boss | Mother mutée reste sans base dédiée : tentative ImageGen bloquée sans image produite au lot 4. La forme humaine en fauteuil ne couvre pas le boss ; animations et comportement restent ouverts. |
| Overkill Extended Cut | Coco & Sindy | Galerie statique : [Coco](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/coco_base.png) + [Sindy](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/sindy_base.png) ; non jouable, animations ouvertes. Deux images, une rencontre. |
| Overkill Extended Cut | Meat Katie | Galerie statique : [Meat Katie](../../../../../assets/dossier_curien/gallery_2026-11-20_lot4/bosses/meat_katie_base.png) ; non jouable, animations ouvertes. |

Répartition des 35 lignes : **14** disposent d’une base d’identité déjà jouable dont la variante d’édition reste à vérifier ; **15** reçoivent une base statique de galerie dans les quatre lots ; **4** disposent d’une fiche sous une autre étiquette d’édition ; **1** garde le redesign Hangedman Scarlet Dawn manquant ; **1** reste sans base dédiée, Mother mutée. Les 14 premières sont des lignes de rencontre, pas un décompte d’identités distinctes. Les apparences par édition, les comportements et les animations restent à vérifier séparément.

## Couverture du corpus : 31 entrées principales

Le registre conserve le périmètre documenté des jeux et éditions et rapproche les nouvelles livraisons. Il ne prétend pas réexaminer chaque créature, figurant, palette, salle ou variante de toutes les éditions. Les références externes héritées gardent leurs limites d’accès et de vérification. Les 31 entrées ne sont pas 31 jeux narratifs principaux : ports, services, spin-offs et attractions y sont distingués.

| Œuvre / édition | Type de branche | État courant du recensement |
|---|---|---|
| The House of the Dead | arcade | Hangedman/Hermit et Sophie/Curien humains ont des bases statiques des lots précédents. Sophie fin zombie arcade reçoit une forme au lot 4, avec réserves de détail ; variantes Saturn/Windows, figurants et animations ne sont pas exhaustifs. |
| The House of the Dead 2 | arcade | Amy/Harry/Goldman humains et Judgment/Tower/Strength ont une base de galerie. Goldman fin zombie originale reçoit une forme au lot 4, port précis non établi. Original Mode, foules et variantes restent distincts. |
| The House of the Dead III | arcade | G/Rogan III et Fool/Sun ont une base statique ; autres tenues, personnages secondaires et animations restent ouverts. |
| The House of the Dead 4 | arcade | James reçoit une variante statique HOTD 4 au lot 3. Les fiches Lovers, Empress, Temperance et Star étiquetées EX ne ferment pas leur adaptation HOTD 4 ; foules et variantes restent ouvertes. |
| The House of the Dead 4 Special | prolongement narratif | G reçoit une variante statique propre à Special au lot 3. Justice et Magician conservent une vérification d’apparence par édition ; aucune nouvelle tenue de combat sélectionnable. |
| House of the Dead: Scarlet Dawn | arcade | Thornheart est livré avec bas de tenue à confirmer ; High Priestess reçoit une base statique au lot 3. Le redesign Hangedman Scarlet Dawn reste ouvert. |
| The House of the Dead: Overkill | branche grindhouse | Les bases précédentes sont complétées au lot 4 par Jasper/Mother humains, Nigel & Sebastian conjoint et Lobber. Mother mutée reste sans image après blocage de génération. Réserves d’édition et animations non closes. |
| The House of the Dead: Overkill – Extended Cut | édition étendue | Varla/Candi restent en galerie avec QA de tenue ouverte ; Coco et Sindy reçoivent deux images pour une rencontre, Meat Katie une base au lot 4. Références de la famille visuelle Extended Cut/Typing ; plateforme précise de certaines captures non affirmée, aucune exhaustivité des variantes ni animation complète. |
| The House of the Dead: Overkill – The Lost Reels | adaptation mobile | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| Zombie Revenge | beat’em up | Trio jouable et 42 ressources d’expansion déjà indexés, dont 33 fiches ; tenues alternatives à documenter. |
| Loving Deads: The House of the Dead EX | arcade à mini-jeux | Duo jouable et sept fiches déjà indexés ; rôles exacts des apparitions secondaires à confirmer. |
| The Typing of the Dead | arcade à clavier | James/Gary avec matériel livrés au lot 2 ; ni identités nouvelles ni costumes de combat sélectionnables. Ports et variantes non exhaustifs. |
| The Typing of the Dead 2 | Windows | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead: Zombie Panic | édition PS2 | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead Online | service PC | Œuvre enregistrée ; apparences et variantes non examinées exhaustivement. |
| The Typing of the Dead: Overkill | Windows | Les cinématiques PC documentent notamment Jasper/Mother humains du lot 4 ; certaines vues complètes ne sont disponibles qu’en petites vignettes. Aucun nouveau nom de roster compté par duplication de port. |
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

**Restent ouverts dans la couverture globale :** ennemis ordinaires hors sous-ensemble déjà indexé, figurants, formes mobiles, personnages du laboratoire Site, détails de Kids 2004, silhouettes nominatives de Reawakened, variations d’édition et redesigns précis des remakes. Ce périmètre déborde les 26 tâches non couvertes : aucun pourcentage d’exhaustivité de toute la saga n’est calculé.



## Preuves, contrôles et portée

La chaîne historique reste consultable : [inventaire initial JSON](../catalogue_2026-11-20/personnages_tenues.json), [delta du lot 1](../catalogue_2026-11-20/delta_livraison.json), inventaires après les [lots 2](../catalogue_2026-11-20_lot2/personnages_tenues.json) et [3](../catalogue_2026-11-20_lot3/personnages_tenues.json), et [snapshot c7162f7b](baseline_c7162f7b.json). Les références initiales restent accessibles dans le [registre personnages et tenues](../catalogue_2026-11-20/sources_personnages_tenues.json) et le [corpus SOURCES_SAGA](../../SOURCES_SAGA.json).

Les [sources humaines du lot 2](../catalogue_2026-11-20_lot2/sources_humans.json) restent applicables à ses livraisons. Les reçus du lot 3 — [humains](../catalogue_2026-11-20_lot3/humans_generated.json), [boss](../catalogue_2026-11-20_lot3/bosses_generated.json), [variantes](../catalogue_2026-11-20_lot3/costumes_generated.json) — restent inchangés. Pour le lot 4, les deux reçus [formes](humans_generated.json) et [boss](bosses_generated.json) conservent les sources locales inspectées, les limites et les tentatives. Le JSON courant conserve les empreintes des fichiers utilisés pour ce rapprochement.

Le [suivi des stages courant](STAGES_MANQUANTS.md) conserve séparément ses 61 lignes de lieux et ses 26 indices d’arènes couverts. La terrasse de Hangedman et le dôme de Hermit sont des adaptations latérales documentées ; les variantes de lieu, autres séquences du chapitre et poursuites ne sont pas fermées par leur seule livraison.

Contrôles documentaires : 62 IDs de tâches et 35 couples rencontre/édition préservés ; 36 tâches rattachées à 38 assets distincts ; les 26 autres IDs explicitement listés. Les neuf statuts visuels ouverts correspondent aux reçus. Empreintes et tailles des 38 images de galerie, références locales et 15 PNG de jeu nouveaux du lot 4 contrôlés. Profils, routes, arènes et Archives recomptés dans les constantes du code ; total PNG rapproché du snapshot Git et de l’ensemble des chemins locaux. Poses manquantes et masters non récupérés gardent leurs compteurs distincts.

Ce rafraîchissement n’est pas une nouvelle revue visuelle de toutes les sources du corpus, une capture moteur ou une preuve d’export. Les rapports de production décrivent la comparaison des neuf bases livrées au lot 4. Les tests d’intégration, la publication et les distributions sont documentés par la validation du lot global. Les anciens inventaires datés ne sont pas réécrits.
