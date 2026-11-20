# Lot personnages, costumes et stages — 20 novembre 2026

Ce lot poursuit la PR [#2 — Dossier Curien](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2), depuis la base publiée `59372b618882da17510351f2a5bd46226682eac4`. Il ajoute **15 PNG natifs distincts**, soit **13 466 764 octets**, leur provenance, les inventaires actualisés et leur intégration aux sources du jeu.

## Résultat dans les sources

| Mesure | Avant | Avec ce lot | Portée |
|---|---:|---:|---|
| Combattants jouables | 24 | **24** | Une silhouette de galerie ne crée pas de profil de combat. |
| Arènes sélectionnables | 18 | **20** | Deux nouveaux lieux, trois plans par lieu. |
| Fiches du bestiaire et de la galerie | 40 | **49** | Neuf ajouts statiques, avec filtre par jeu. |
| PNG sous `assets/dossier_curien` | 332 | **347** | Personnages, poses, décors et autres images réunis. |
| Contenus d’image distincts | 330 | **345** | Les deux doublons historiques de garde EX restent identifiés. |
| Tenues alternatives sélectionnables | 2 | **2** | Les trois nouvelles variantes restent dans la galerie. |
| Minimum de poses manquantes suivi | 277 | **277** | Une base statique ne termine aucun mouvement. |

Les comptes sont rapprochés fichier par fichier dans [DELTA_LIVRAISON.md](DELTA_LIVRAISON.md) et [delta_livraison.json](delta_livraison.json). Les 347 chemins ne représentent ni 347 personnages ni 347 animations.

## Neuf silhouettes, une image par élément

| Élément | Classement | Fichier | Limite principale |
|---|---|---|---|
| Varla Guns | Identité nouvellement illustrée | [varla_guns_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/varla_guns_base.png) | Bas de tenue à recroiser avec une vue canonique complète. |
| Candi Stryper | Identité nouvellement illustrée | [candi_stryper_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/candi_stryper_base.png) | Bas de tenue et orthèse à recroiser avec une vue complète. |
| Amy Crystal | PNJ nouvellement illustré | [amy_crystal_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/amy_crystal_base.png) | Couleur exacte des bottes à confirmer ; le manuel est monochrome. |
| Harry Harris | PNJ nouvellement illustré | [harry_harris_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/characters/harry_harris_base.png) | Pose et détail des chaussures adaptés. |
| G — Overkill | Variante d’époque | [g_overkill_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/g_overkill_base.png) | Garde à une arme adaptée depuis le rendu de production. |
| G — HOTD III | Variante d’époque | [g_hotd3_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/g_hotd3_base.png) | Garde et arme simplifiées. |
| Thomas Rogan — HOTD III | Variante d’époque | [rogan_hotd3_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/costumes/rogan_hotd3_base.png) | Pieds partiellement cachés dans la source. |
| Hangedman — HOTD1 | Adaptation d’une identité de l’ancien jeu | [hangedman_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hangedman_base.png) | Master historique réutilisé ; redesign Scarlet Dawn encore ouvert. |
| Hermit — HOTD1 | Adaptation d’une identité de l’ancien jeu | [hermit_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20/bosses/hermit_base.png) | Master historique et capture PC ; aucune équivalence détaillée des ports revendiquée. |

Ces neuf images sont des PNG **RGBA natifs de 1254 × 1254 pixels**, avec des silhouettes visibles entièrement contenues dans le canevas. Leur total est de **7 741 468 octets**. Le [manifeste de galerie](../../../../../data/assets/dossier_curien_gallery_2026-11-20.json) contient tailles, SHA256, bornes alpha, prompts, références et limites.

La galerie fusionne la collection historique et cette nouvelle collection. Les filtres s’adaptent aux jeux présents. Les PNJ et variantes indiquent leur statut non jouable ; aucun bouton ne les présente comme un combattant disponible. Linda conserve son accès existant au combat.

## Deux arènes supplémentaires

| Arène | Plans séparés | Registre |
|---|---|---|
| Toit du train — Zombie Revenge | `zr_train_back.png`, `zr_train_mid.png`, `zr_train_front.png` | Index 18 |
| Abattoir — Creeping Flesh | `creeping_flesh_back.png`, `creeping_flesh_mid.png`, `creeping_flesh_front.png` | Index 19 |

Les six fichiers mesurent **1672 × 941 pixels**, pour **5 725 296 octets**. Chaque lieu possède un fond opaque et deux plans RGBA. Dans la zone centrale prévue pour les combattants, aucun pixel des quatre plans transparents ne dépasse un alpha de **1 sur 255**.

Le [rapport des stages](../stages_2026-11-20/RAPPORT.md) explique les sources, la transposition latérale et la ligne de pied à **601 pixels**. Le [manifeste](../stages_2026-11-20/manifest.json) conserve les six prompts et empreintes. Ces lieux sont des adaptations 2D documentées, sans certification de reproduction à l’identique.

## Inventaires poursuivis

Le [catalogue personnages et tenues](PERSONNAGES_TENUES.md) suit les personnages principaux, les apparences par édition, **35 rencontres de boss** et **62 lignes de production ou de recherche**. Il distingue les identités, variantes d’âge ou d’équipement, substitutions de modèles et ensembles encore à documenter.

**Neuf lignes reçoivent une base statique ; 53 ne sont pas couvertes par les générations de ce lot.** Les mouvements, transitions, profils de combat et vérifications restantes ne disparaissent pas. Ce catalogue ne prétend pas recenser chaque figurant, palette ou version mobile.

Le [listing des stages](STAGES_MANQUANTS.md), accompagné de [son registre JSON](stages_manquants.json), rapproche les lieux et chapitres documentés des 20 arènes. Une arène inspirée d’un lieu ne signifie pas que chaque salle ou embranchement de son chapitre est reproduit.

Ce registre suit **61 entrées : 15 existantes, 6 adaptations partielles, 33 absentes et 7 références à établir**. Ce sont des lignes de suivi par lieu, chapitre ou ensemble ; elles ne correspondent pas à 61 arènes distinctes.

Suites identifiées :

- **Personnages humains :** Goldman humain, Thornheart, Papa Caesar et Clement Darling restent sans base Dossier Curien dédiée dans cet inventaire.
- **Art historique :** Sophie et Curien humain ont déjà des dessins dans l’ancien jeu ; leur adaptation Dossier Curien reste à traiter.
- **Boss :** Judgment, Tower, Strength, Fool, Sun, High Priestess et plusieurs boss d’Overkill restent au registre, avec leurs variantes suivies par édition.
- **Tenues :** alternatives Dreamcast de Zombie Revenge, équipements de Typing et différences entre éditions demandent des références explicites.
- **Mouvements et récupération :** les **277 lacunes minimales** du [lot motion précédent](../motion_2026-11-19/RAPPORT.md) restent ouvertes. Les **204 masters historiques non retrouvés** constituent un déficit de récupération distinct.

## Provenance et qualité

Le lot comprend **15 dessins retenus pour 17 appels ImageGen**. Deux essais ne sont pas intégrés comme assets du jeu : la première Varla, remplacée après correction du pendentif, et un essai de nettoyage de Candi sans gain justifiant son remplacement. Les reçus les identifient par leur nom et leur empreinte.

Les sorties retenues sont copiées sans redimensionnement, découpe ni retouche locale des pixels. Une correction demandée à ImageGen reste une génération distincte et son prompt est conservé. Manuels SEGA, captures du jeu hébergées par des tiers, rendu publié par un artiste de production et masters historiques sont identifiés séparément.

Un statut de revue signifie que les références indiquées ont été examinées. **Aucun statut ne certifie une fidélité canonique 1:1.** Varla et Candi gardent un besoin de revue visuelle supplémentaire ; les détails moins documentés des autres silhouettes sont consignés dans leurs limitations.

Reçus par sous-lot :

- [Cinq silhouettes — prompts, références et contrôles](root_generated.json)
- [Deux variantes III](costumes_generated.json)
- [Deux adaptations de boss](bosses_generated.json)
- [Six plans de décor](../stages_2026-11-20/manifest.json)

## Vérification et diffusion

Les commandes et résultats exécutables figurent dans [VALIDATION.md](VALIDATION.md). Ils couvrent les PNG et leur provenance, le chargement des 49 fiches, les filtres et la navigation, ainsi que les deux nouvelles arènes. Les tests moteur ont été exécutés sans interface graphique ; aucune capture de viewport ni session manuelle complète n’est revendiquée.

Les builders et leurs contrôles connaissent le nouveau manifeste et les 20 arènes pour les prochaines constructions. **Les paquets PCK et exports web historiques n’ont pas été reconstruits par ce lot.** Le contenu décrit ici est livré dans la branche source de la PR ; un ancien paquet ne contient pas automatiquement ces ajouts.
