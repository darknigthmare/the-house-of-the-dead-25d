# Dossier Curien — lot 6 : variantes, poses et arènes

**25 nouveaux PNG natifs** sont intégrés aux sources : quatre variantes Saturn/PC Mode, neuf états de combat de Rikiya et quatre arènes en trois plans. Ce lot prolonge la [PR 3](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/3) sur `feat/dossier-curien-lot5`, à partir du commit `7f14d7b49dcc8d884629245eef71e65198665b8e`.

## Résultat

| Mesure | Avant | Après intégration |
| --- | ---: | ---: |
| Fiches de galerie | 89 | **93** |
| Arènes sélectionnables | 29 | **33** |
| PNG Dossier Curien | 414 | **439** |
| Blobs Git PNG distincts | 412 | **437** |
| Combattants jouables | 24 | **24** |
| Parcours narratifs | 26 | **26** |
| Entrées Archives | 29 | **29** |
| Costumes alternatifs sélectionnables | 2 | **2** |
| Minimum suivi de poses manquantes | 277 | **268** |
| Masters historiques non récupérés | 204 | **204** |

## Quatre variantes Saturn/PC Mode

Rogan2, G2, Sophie et la chercheuse DBR ont chacun une illustration entière RGBA. Les captures PC détaillées et les vues Saturn de sélection sont conservées avec leurs URL et empreintes. Les différences fines entre ports, les accessoires peu lisibles et certains détails des chaussures gardent une QA ouverte. Les quatre dessins restent des entrées de galerie ; aucune nouvelle sélection de tenue ni identité jouable n’est déclarée. Voir [COSTUMES.md](COSTUMES.md).

## Neuf états de Rikiya utilisés par le moteur

Montée du saut, descente, accroupissement, garde basse, blocage, saisie, victoire, provocation et finisher possèdent maintenant leurs dessins dédiés. Le chargeur ajoute une collection datée au manifeste historique. Les tests vérifient les commandes réelles, les transitions, le retour à la garde, les textures, l’orientation gauche/droite et la conservation des poses antérieures. Les échelles sont définies à partir de repères anatomiques et des appuis, pour éviter de grossir artificiellement les postures basses. Les PNG restent intacts.

Ces neuf fichiers comblent neuf manques nommés : **277 → 268**. Tous les états nommés de Rikiya dans cette matrice disposent désormais d’un dessin. Ce lot ne remplace pas l’animation complète image par image. Voir [RAPPORT.md](../motion_2026-11-20_lot6/RAPPORT.md) et [MANQUANTS.json](../motion_2026-11-20_lot6/MANQUANTS.json).

## Quatre arènes

| Index | Arène | Portion adaptée |
| ---: | --- | --- |
| 29 | Sous-sols AMS — Escape | Couloir technique des sous-sols AMS ; espacement et sol adaptés au duel. |
| 30 | Annexe — Scarlet Dawn | Grande salle avec balcon de l’annexe ; sol interprété à partir d’une photo partiellement masquée. |
| 31 | Manoir — Papa’s Palace of Pain | Vestibule du manoir, avec escalier arrière et fenêtres barricadées. |
| 32 | Égouts industriels — Zombie Revenge | Segment du canal de l’Area 3, avec berge élargie pour la ligne de combat. |

Les douze plans font 1 672 × 941 pixels natifs. Les fonds sont opaques ; les huit surimpressions gardent un alpha maximal de 1/255 au centre et dans la bande de combat. Architecture, provenance de port, espacement et sol interprétés sont détaillés dans le [rapport de stages](../stages_2026-11-20_lot6/RAPPORT.md). Aucune couverture de chapitre entier n’est annoncée.

## Listing poursuivi

Le [listing personnages et tenues](PERSONNAGES_TENUES.md) conserve 62 tâches et 35 rencontres par édition. Les six lots apportent au moins une base à **46 tâches**, tandis que **16 restent sans base de ces lots**. Les familles Yukio, Typing 2 et variantes Zombie Revenge restent partielles, ainsi que les exigences de port et de jeu des quatre nouvelles bases. Le cumul des réserves visuelles explicites est **18 sur les 53 illustrations de ces six lots**, ce qui ne décrit pas toutes les réserves des 93 fiches globales.

Le [listing des stages](STAGES_MANQUANTS.md) conserve 63 lieux ou familles et distingue les portions couvertes, adaptations partielles, absences et besoins de référence. Les 204 masters historiques non récupérés restent ouverts.

## Validation et publication

Le [delta](DELTA_LIVRAISON.md) rapproche les fichiers natifs, leurs empreintes, la matrice de poses et les inventaires. Le [rapport de validation](VALIDATION.md) consigne les résultats réellement exécutés. La CI distante est vérifiée sur le commit publié, et son état est rapporté dans la PR.

Le serveur graphique disponible ne démarre pas car la création de sockets AF_UNIX est refusée (`EPERM`). Les PNG ont été revus indépendamment, les tests moteur sont exécutés sans affichage ; aucune capture graphique native ni session manuelle n’est présentée comme accomplie. Le cache Godot a été déplacé vers un espace temporaire disponible après saturation du disque, avec vérification de ses 1 224 fichiers. Les sources et les images natives sont restées intactes. Aucun nouvel export web ou PCK n’est produit.
