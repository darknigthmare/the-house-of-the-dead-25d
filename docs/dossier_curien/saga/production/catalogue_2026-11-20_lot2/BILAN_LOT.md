# Dossier Curien — personnages, costumes et stages, lot 2 du 20 novembre 2026

Ce lot poursuit la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2) à partir du commit `6291e0d723eb4bc5050ffd3de699f6e55a575642`. Il livre **18 nouvelles images natives, 12 fiches de galerie et deux arènes**, avec références, limites documentées, inventaires actualisés et intégration aux sources Godot. Les PNG retenus totalisent **22 890 969 octets**.

## Résultat dans les sources

| Mesure | À la base 6291e0d | Avec le lot 2 |
|---|---:|---:|
| Fiches de galerie | 49 | **61** |
| Arènes du registre | 20 | **22** |
| Combattants jouables | 24 | **24** |
| Parcours narratifs | 26 | **26** |
| Défis Archives | 29 | **29** |
| Costumes alternatifs sélectionnables | 2 | **2** |
| Chemins PNG dans assets/dossier_curien | 347 | **365** |
| Blobs Git PNG distincts | 345 | **363** |
| Minimum suivi de poses nommées manquantes | 277 | **277** |
| Masters historiques non récupérés | 204 | **204** |

La galerie réunit les 40 fiches historiques, les neuf du premier lot et les douze de ce lot. Les 12 nouvelles entrées sont marquées galerie/bestiaire, non jouables et sans animation complète. Les deux arènes possèdent chacune un fond, un plan intermédiaire et un premier plan liés à leur clé artistique.

## Personnages et costumes ajoutés

| Sujet | Ligne du registre | Nature | PNG livré | Revue visuelle |
|---|---|---|---|---|
| Goldman — forme humaine | `goldman_human` | Identité humaine | [goldman_human_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/goldman_human_base.png) | Références examinées ; réserves dans la fiche |
| Thornheart | `thornheart` | Identité humaine | [thornheart_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/thornheart_base.png) | Référence à compléter |
| Papa Caesar | `papa_caesar` | Identité humaine | [papa_caesar_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/papa_caesar_base.png) | Référence à compléter |
| Clement Darling | `clement` | Identité humaine | [clement_darling_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/clement_darling_base.png) | Référence à compléter |
| Zeal — Judgment | `judgment` | Base de boss | [zeal_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/zeal_base.png) | Références examinées ; réserves dans la fiche |
| Kuarl — Judgment | `judgment` | Base de boss | [kuarl_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/kuarl_base.png) | Références examinées ; réserves dans la fiche |
| Tower — Type 8000 | `tower` | Base de boss | [tower_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/tower_base.png) | Références examinées ; réserves dans la fiche |
| Strength — Type 205 | `strength` | Base de boss | [strength_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/strength_base.png) | Références examinées ; réserves dans la fiche |
| Fool — Type 0028 | `fool` | Base de boss | [fool_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/fool_base.png) | Références examinées ; réserves dans la fiche |
| Sun — Type 8830 | `sun` | Base de boss | [sun_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/sun_base.png) | Références examinées ; réserves dans la fiche |
| James Taylor — Typing | `james_typing` | Variante de matériel | [james_typing_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/costumes/james_typing_base.png) | Références examinées ; réserves dans la fiche |
| Gary Stewart — Typing | `gary_typing` | Variante de matériel | [gary_typing_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/costumes/gary_typing_base.png) | Références examinées ; réserves dans la fiche |

Les quatre personnages humains sont Goldman, Thornheart, Papa Caesar et Clement Darling. Le lot ajoute les deux créatures de Judgment, puis Tower et Strength pour HOTD2, Fool et Sun pour HOTD III. James et Gary reçoivent une base avec le clavier frontal et l’équipement de Typing documenté dans les références conservées.

La production représente **19 appels ImageGen pour 18 PNG retenus**. Le premier dessin de Strength plaçait les haches de cuisse et d’épaule du même côté ; une édition ImageGen a corrigé la cuisse. Le PNG rejeté n’est pas livré dans le dépôt. Les images retenues sont conservées telles que générées, sans recadrage ni redimensionnement de leurs pixels.

La [fiche des humains](HUMANS.md), la [fiche des boss](BOSSES.md) et la [fiche des costumes](COSTUMES.md) exposent les références réellement examinées et les choix de mise en scène. Les fichiers de provenance associés contiennent les prompts et les empreintes des entrées comme des sorties.

## Stages ajoutés

| Index Godot | Arène | Clé artistique | Trois plans | Portée |
|---:|---|---|---|---|
| 20 | Canal souterrain — Tower | `tower_canal` | [back](../../../../../assets/dossier_curien/saga/tower_canal_back.png), [mid](../../../../../assets/dossier_curien/saga/tower_canal_mid.png), [front](../../../../../assets/dossier_curien/saga/tower_canal_front.png) | Branche en eau ; rebord de combat adapté en 2D. Sable et retour chez Goldman non couverts. |
| 21 | Colisée — Strength | `strength_colosseum` | [back](../../../../../assets/dossier_curien/saga/strength_colosseum_back.png), [mid](../../../../../assets/dossier_curien/saga/strength_colosseum_mid.png), [front](../../../../../assets/dossier_curien/saga/strength_colosseum_front.png) | Labyrinthe aux murs clairs avec cage en retrait. Murs sombres et autres parcours non couverts. |

Les six plans sont natifs de **1672 × 941 pixels**. Les fonds sont opaques ; les autres plans sont RGBA avec un couloir central dégagé. L’étagement conserve les vitesses 17/32/58 et la ligne de sol de combat à 601 pixels. Le [rapport de fabrication des stages](../stages_2026-11-20_lot2/RAPPORT.md) documente les captures utilisées, les adaptations latérales et les mesures de transparence.

## Listing poursuivi et rapproché des fichiers

Le [catalogue personnages et tenues courant](PERSONNAGES_TENUES.md) conserve les 62 lignes de travail et les 35 rencontres de boss réparties par épisode ou édition. **20 lignes ont maintenant une base statique issue des deux lots du 20 novembre, et 42 ne sont pas couvertes par ces lots.** Le lot 2 fait avancer onze lignes pour douze images : Zeal et Kuarl partagent la ligne Judgment. Les formes, costumes et groupes de variantes ne sont pas additionnés comme des identités inédites.

Le [catalogue des stages courant](STAGES_MANQUANTS.md) relie les 22 arènes enregistrées à 61 lignes de couverture : 17 lignes disposent d’une arène dédiée, six restent des adaptations partielles, 31 sont absentes et sept nécessitent une référence. Il indique les variantes encore ouvertes et les branches du corpus qui ne disposent pas d’un inventaire visuel suffisant.

Les travaux restants incluent notamment l’adaptation de Sophie et Dr. Curien, High Priestess, les boss Overkill encore sans base Dossier Curien, les formes humaines secondaires documentables, les variantes d’édition de James et G, Saturn Mode, Typing2/Kids2004, les tenues alternatives de Zombie Revenge et les redesigns des remakes. Le détail et les références nécessaires restent dans le registre, plutôt qu’une liste de costumes supposés.

## Réserves et portée exacte

Thornheart et Clement Darling manquent encore d’une référence canonique nette en pied ; les détails de chaussures, canne et tenue de Papa Caesar demandent une comparaison plus précise. Avec Varla et Candi du premier lot, cela laisse cinq fiches au statut explicite de revue de référence incomplète parmi les 21 fiches de ces deux lots. Les autres fiches restent des adaptations documentées, sans promesse de fidélité 1:1.

Sun, boss lié à son environnement, est ramené à une silhouette autonome ; les racines et branches sont recomposées pour le cadre et un appendice Sunsun reste partiellement masqué. Le matériel Typing est rapproché de la jaquette japonaise et d’une capture publiée dans un article Dreamcast ; le port exact de cette capture, les logos régionaux et les variantes Mac/PS2 ne sont pas certifiés. Le dos de Gary n’étant pas visible dans ces références, son matériel commun est repris des autres agents documentés.

Les nouveaux sprites n’ajoutent aucun combattant, costume sélectionnable ni cycle d’animation. Les 277 lacunes de poses suivies et les 204 masters historiques à récupérer restent ouverts. Hangedman Scarlet Dawn, les embranchements sable/retour de Tower et les autres labyrinthes de Strength ne sont pas clos par ces bases.

## Validation et publication

Le [delta de livraison](DELTA_LIVRAISON.md) et son [JSON vérifiable](delta_livraison.json) relient chaque fichier à sa tâche, contrôlent les empreintes et distinguent le résultat du présent lot du cumul. Les contrôles Godot, galerie et catalogue ainsi que leurs journaux sont consignés dans [VALIDATION.md](VALIDATION.md).

La validation moteur est effectuée sans affichage. Elle ne constitue pas une capture native ni une session manuelle de gameplay. Aucun export web ou paquet PCK n’est reconstruit dans ce lot. Les changements sont destinés à la branche `feat/dossier-curien-combat` de la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2), sans fusion de la PR.
