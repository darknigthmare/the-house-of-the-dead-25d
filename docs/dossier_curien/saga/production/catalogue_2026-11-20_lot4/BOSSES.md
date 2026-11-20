# Boss Overkill — lot 4 du 20 novembre 2026

Ce lot livre **cinq PNG natifs transparents**, représentant **quatre rencontres** : Nigel et Sebastian dans une anatomie conjointe, Lobber, Coco et Sindy sur deux images séparées, puis Meat Katie. Les cinq bases sont destinées à la galerie et au bestiaire. Elles n’ajoutent ni combattant jouable, ni animation, ni comportement de combat.

**Mother dans sa forme mutée finale reste sans base dédiée.** Son appel ImageGen a été bloqué au contrôle de la sortie ; aucun PNG n’a été renvoyé. La forme humaine de Mother, produite par un autre volet du lot, ne remplace pas cette rencontre.

## Livrables et compte des tentatives

| ID | Rencontre représentée | Taille native | Octets | Statut |
|---|---|---:|---:|---|
| `nigel_sebastian` | Nigel & Sebastian, un corps conjoint | 1254 × 1254 RGBA | 1 139 398 | Base statique revue |
| `lobber` | Lobber | 1254 × 1254 RGBA | 1 601 057 | Base statique revue |
| `coco` | Coco & Sindy | 1254 × 1254 RGBA | 1 148 566 | Base corrigée puis revue |
| `sindy` | Coco & Sindy | 1254 × 1254 RGBA | 1 434 048 | Base statique revue |
| `meat_katie` | Meat Katie | 1254 × 1254 RGBA | 1 230 904 | Base statique revue |
| **Total retenu** | **4 rencontres, 5 fiches** | **5 PNG** | **6 553 973** | **Galerie seule** |

Les **sept appels tentés** se répartissent en cinq sorties retenues, un premier Coco écarté et une tentative Mother bloquée sans fichier. Six PNG ont donc été renvoyés au total, dont cinq actifs. Le rejet binaire Coco et le blocage sans sortie Mother sont deux événements distincts, consignés respectivement dans `rejected_generations` et `blocked_generations` du [manifeste des boss](bosses_generated.json).

Les entrées actives utilisent `game: overkill`, `category: boss_base`, `gallery: true`, `playable: false`, `animation_complete: false` et `runtime_role: bestiary`. Coco et Sindy partagent `encounter_id: coco_sindy` et leurs `companion_id` sont réciproques. Nigel et Sebastian ne sont pas deux PNG artificiellement séparés.

## Références et différences d’édition

Les références ont été inspectées avant les appels correspondants. Le [registre des sources](../../../sources_art/references-2026-11-20_lot4/bosses/source_index.json) conserve dix-sept images intactes, soit **2 417 475 octets** : deux publications primaires et quinze images hébergées par des sources secondaires. Douze images d’identité ont servi aux cinq bases retenues, quatre à la seule tentative Mother, et une capture PS3 supplémentaire au contrôle de Nigel et Sebastian. Isaac guard, déjà présent dans le projet, sert uniquement de référence de peinture et de contours.

Les publications primaires sont le [portfolio de production de Rick Nath](https://www.behance.net/gallery/12504423/House-of-the-Dead-Overkill) et l’[annonce SEGA/PlayStation de Creeping Flesh](https://blog.playstation.com/2011/08/30/house-of-the-dead-overkill-extended-cut-creeping-flesh-level-reveal/). Le premier montre l’anatomie entière des jumeaux à gauche de sa planche ; les deux prisonniers en pantalon orange n’ont pas été repris. La seconde publie l’affiche de Meat Katie et décrit l’hybride humain-vache armé d’un grand couperet. L’affiche reste une référence de silhouette et d’arme : aucun titre, décor ou graphisme de l’affiche n’apparaît dans le PNG livré.

Les autres références comprennent les rendus de modèles republiés sur le CDN public du Wiki of the Dead, les fiches d’identification présentes dans le jeu, les captures des guides PS3 de [Naked Terror](https://www.k-triggerhappy.com/hodoverkill_ps3/stage2.html), [Carny](https://www.k-triggerhappy.com/hodoverkill_ps3/stage4.html) et [Overkill](https://www.k-triggerhappy.com/hodoverkill_ps3/stage9.html), ainsi que trois planches publiques de vignettes de la [vidéo PS3 de GetRektNoob](https://www.youtube.com/watch?v=X4r5zGgNbW8). Ces sources secondaires ne sont pas présentées comme des publications directes de SEGA.

Une précision de provenance est conservée pour Nigel et Sebastian : le prompt nomme « PS3 » la capture du [Gamers Library](https://www.thegamerslibrary.com/the-typing-of-the-dead-overkill-review.html), alors que cette page est une critique PC. Sa plateforme de capture n’est pas prouvée ; son apparence Extended Cut a été croisée avec la vraie capture du guide PS3. Le registre corrige cette qualification au lieu d’affirmer une origine non vérifiée.

## Contrôle des cinq créatures

### Nigel et Sebastian

La base conserve deux têtes adultes sur un seul corps, le petit torse fusionné à l’abdomen, son bras et sa jambe exposés, les deux grands bras de Nigel, les chaînes, le pagne et les deux pieds porteurs. Les plages de cheveux sombres de Sebastian et les bras plus massifs ont été confrontés aux vues Extended Cut. Le volume musculaire et les plis restent une interprétation peinte ; la fiche ne ferme pas toutes les adaptations Wii, PS3 et PC.

### Lobber

Les captures du marais ne suffisaient pas : elles masquent le bas du corps dans l’eau. Un rendu entier de 738 × 640 a permis de contrôler le squat, les deux mains au sol, les deux pieds larges et les bandes autour du ventre et du bassin. La fiche Extended Cut confirme les poches sous le menton et les reliefs du corps. La révision exacte du rendu entier, Wii ou Extended Cut, n’a pas été authentifiée. Le pliage du tissu et la surface de peau sont adaptés au style du projet.

### Coco et Sindy

Le guide PS3 identifie Coco comme la petite créature mobile et Sindy comme la grande. Leurs rendus entiers ont servi à préserver leurs silhouettes très différentes. Sindy garde sa masse, ses cheveux sombres à mèche rose, ses ongles magenta, son costume assorti et ses pieds nus ; sa pose a été reconstruite debout à partir d’un rendu en perspective.

Le premier Coco ne rendait lisible qu’un seul pied arrière. Une édition ciblée par ImageGen a dégagé le pied lointain derrière l’avant-bras gauche de l’image, en conservant exactement deux bras et deux jambes. Les deux mains et les deux pieds se lisent dans le PNG retenu. Le visage, la langue, la coiffure et les longues griffes vertes restent cohérents avec le modèle source.

Cette correction a bien utilisé le **premier PNG généré comme entrée principale**, avec deux références du jeu en soutien. Le manifeste donne son basename, son SHA-256 et sa taille, en précisant `binary_in_repository: false`. Ce rejet n’est pas disponible comme fichier du dépôt ; il reste dans la sortie native extérieure au dépôt. Les références du jeu, les deux prompts exacts et le PNG corrigé sont conservés.

### Meat Katie

Le crâne à deux cornes, les orbites sombres, le tablier, les gants et la ceinture ont été comparés à la capture de combat et à l’affiche officielle. Le couperet reste dans la main droite anatomique, à gauche de l’image. La botte blanche est au pied droit ; le pied gauche est transformé. La planche vidéo permet de vérifier cette asymétrie, mais ses vues unitaires font 320 × 180 : la finition du pied, de l’anneau de ceinture et de la lame demeure une interprétation des petits détails visibles.

## Mother mutée : tentative bloquée, manque conservé

Les vignettes publiques des planches 12 et 13 montrent la silhouette entière, les deux jambes et les appuis. La fiche d’identification et la capture PS3 rapprochée complètent le visage, les masses cérébrales et l’appendice ventral fermé. Les petits détails des pieds et l’échelle restaient moins fiables ; ils auraient été signalés comme contrôle ouvert.

L’appel demandait une figure statique de bestiaire non sexuelle, avec l’appendice fermé, sans victime ni reproduction de cinématique. ImageGen a néanmoins renvoyé `HTTP 400 / moderation_blocked`, au stade `output`, catégorie `sexual`. Le reçu exact et l’identifiant de la requête sont dans le manifeste. Aucun PNG, hash de sortie, fichier actif ou nouvelle fiche Mother n’a été inventé. Aucune relance équivalente ni version habillée non référencée n’a été produite.

Les planches sont des JPEG publics de vignettes, conservés sans découpe ; elles ne sont pas des captures natives réalisées par cet agent. La tentative de téléchargement d’un extrait MP4 a renvoyé 403 et n’a produit aucun extrait utilisable. L’illustration dite Mother CG render trouvée pendant la recherche montrait une autre forme et n’a pas servi à cette tentative.

## Vérification et limites communes

Chaque PNG retenu conserve exactement les octets de sa sortie native ImageGen. Il n’a subi ni recadrage, ni redimensionnement, ni recoloration, ni réparation d’alpha par logiciel. Les empreintes SHA-256, les octets, les dimensions, les comptes d’alpha, les boîtes visibles et les prompts sont consignés dans le manifeste.

Les cinq images sont RGBA, avec alpha de 0 à 255. Aucun pixel d’alpha supérieur à 127 ne touche un bord du canevas ; les silhouettes visibles sont entières. Des franges de très faible opacité peuvent subsister dans les pixels natifs et n’ont pas été retouchées.

Les cinq sorties retenues ont été comparées aux références puis relues indépendamment par root. Cette revue visuelle et documentaire est faite hors moteur. Elle ne constitue ni une capture native du projet, ni un test d’animation, ni une validation de combat ou d’export. Les cycles, poses, variantes d’édition, comportements et proportions relatives en jeu restent à produire ou à vérifier. Aucune fidélité canonique 1:1 n’est certifiée.
