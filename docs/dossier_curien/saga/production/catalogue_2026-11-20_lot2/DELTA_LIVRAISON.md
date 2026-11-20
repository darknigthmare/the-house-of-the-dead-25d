# Livraison graphique du 20 novembre 2026 — lot 2

Le lot ajoute **18 PNG natifs distincts**, soit **22 890 969 octets** : quatre bases humaines, six bases de boss, deux variantes de matériel Typing et six plans pour deux arènes. Les douze premières images alimentent la galerie ; le registre de stages reçoit deux entrées. Le rapprochement utilise le commit `6291e0d723eb4bc5050ffd3de699f6e55a575642` et les empreintes réelles des fichiers.

## Effet sur le projet

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

Les deux formats de silhouettes, 1254 × 1254 et 1024 × 1536, sont conservés. Le cadrage de la galerie respecte leur rapport largeur/hauteur. Les six plans de stage restent à 1672 × 941 pixels. Il n’y a aucun redimensionnement ni retouche de pixels après génération. Le premier Strength a été rejeté puis corrigé avec ImageGen ; seul le résultat accepté entre dans les assets.

## Douze bases livrées

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

**Judgment avance d’une ligne de registre grâce à deux images : Zeal et Kuarl.** Tower reste une rencontre et une fiche regroupant cinq serpents. Les deux équipements Typing sont des variantes de James et Gary. Ils ne créent pas de nouvelles identités et n’activent pas de costumes supplémentaires dans la sélection de combat.

Les manifestes [humains](humans_generated.json), [boss](bosses_generated.json) et [costumes](costumes_generated.json) conservent les prompts, sources, références visuelles, tailles, SHA256 et réserves. Le statut « références examinées » ne certifie aucune reproduction canonique 1:1.

## Deux arènes en trois plans

| Index Godot | Arène | Clé artistique | Trois plans | Portée |
|---:|---|---|---|---|
| 20 | Canal souterrain — Tower | `tower_canal` | [back](../../../../../assets/dossier_curien/saga/tower_canal_back.png), [mid](../../../../../assets/dossier_curien/saga/tower_canal_mid.png), [front](../../../../../assets/dossier_curien/saga/tower_canal_front.png) | Branche en eau ; rebord de combat adapté en 2D. Sable et retour chez Goldman non couverts. |
| 21 | Colisée — Strength | `strength_colosseum` | [back](../../../../../assets/dossier_curien/saga/strength_colosseum_back.png), [mid](../../../../../assets/dossier_curien/saga/strength_colosseum_mid.png), [front](../../../../../assets/dossier_curien/saga/strength_colosseum_front.png) | Labyrinthe aux murs clairs avec cage en retrait. Murs sombres et autres parcours non couverts. |

Le [rapport des stages](../stages_2026-11-20_lot2/RAPPORT.md) fixe l’étagement, la ligne de sol à 601 pixels et les limites par embranchement. Les quatre plans transparents gardent leur couloir central presque transparent : alpha compris entre 0 et 1 sur l’échantillon contractuel. Cette mesure n’est pas présentée comme un alpha strictement nul sur chaque pixel.

## Rapprochement cumulatif des 62 lignes

Le [registre actualisé](PERSONNAGES_TENUES.md) reprend les **62 tâches** du catalogue initial. Le lot précédent en dotait neuf d’une base statique ; le présent lot en avance onze autres. **20 lignes sur 62 ont donc reçu une base Dossier Curien dans ces deux lots, et 42 ne sont pas couvertes par leurs générations.** Les 20 lignes correspondent à 21 images de galerie, en raison du duo Judgment.

Ces lignes regroupent des identités, des formes, des rencontres, des ensembles de variantes et des recherches. Le nombre 42 ne représente pas 42 personnages uniques à créer. Le JSON de livraison donne les trois ensembles d’identifiants — précédent, courant et cumulatif — ainsi que les 42 lignes restantes, sans réécrire la base historique.

Les huit identités humaines initialement prioritaires disposent maintenant d’une base. **Cinq fiches parmi les 21 images de ces deux lots** gardent le statut explicite de référence à compléter : Varla, Candi, Thornheart, Papa Caesar et Clement Darling. Ce compte porte uniquement sur ces deux lots ; il ne résume pas les réserves de toute la galerie historique. Les autres fiches conservent également leurs limites détaillées.

Hangedman reste validé ici dans le périmètre du premier jeu : sa version Scarlet Dawn demeure ouverte. Les bases Lovers, Empress, Temperance et Star déjà rangées sous EX ne suffisent pas à confirmer leurs modèles HOTD4. Les sept objets Original Mode restent des substitutions de modèle à implémenter. Sophie et Dr. Curien disposent d’arts historiques à adapter ; leur identité ne doit pas être présentée comme absente de tout le dépôt.

## Ce qui reste suivi

L’inventaire des décors contient toujours **61 lignes** : **17 avec une arène dédiée, 6 adaptations partielles, 31 absentes et 7 nécessitant une référence**. Ce sont des lignes de couverture, pas un devis de 31 nouveaux stages ni une mesure de reproduction intégrale des chapitres. Les variantes d’embranchement sont conservées même lorsqu’une arène du lieu existe.

Les **277 lacunes de poses nommées** du registre motion et les **204 masters historiques non récupérés** restent inchangés. Une illustration statique n’en ferme aucune. Les besoins d’animation des nouveaux sujets demanderont leur propre découpage si un rôle jouable leur est attribué.

## Vérification

Le [JSON de réconciliation](delta_livraison.json) rapproche les 18 fichiers, leurs tailles et leurs SHA256 avec les manifestes. Les 18 blobs Git sont distincts entre eux et absents des 345 blobs initiaux. Aucun PNG déjà suivi à la base n’est modifié. Les identifiants livrés correspondent tous à une ligne de l’inventaire, et les lots ne couvrent aucune ligne en double.

Les contrôles moteur, catalogue et galerie figurent dans [VALIDATION.md](VALIDATION.md). Une validation sans affichage ne remplace pas une session de jeu visuelle. Ce lot ne reconstruit pas les exports web/PCK. La destination de publication est la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2) ; le commit qui contient ce document identifie la livraison publiée.
