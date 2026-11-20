# Dossier Curien — personnages, costumes et stages, lot 4

Ce lot poursuit la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2) depuis `c7162f7bb46aa7a3ef0546124949e96e2f25bc49`. Il livre **15 nouvelles images natives, neuf fiches de galerie et deux arènes**, avec références examinées et listing actualisé. Les PNG retenus totalisent **18 952 552 octets**.

## Résultat dans les sources

| Mesure | Avant le lot 4 | Après intégration |
|---|---:|---:|
| Fiches de galerie | 69 | **78** |
| Arènes | 24 | **26** |
| PNG Dossier Curien | 379 | **394** |
| Blobs Git PNG distincts | 377 | **392** |
| Combattants jouables | 24 | **24** |
| Parcours narratifs | 26 | **26** |
| Entrées Archives | 29 | **29** |
| Costumes alternatifs sélectionnables | 2 | **2** |
| Minimum suivi de poses manquantes | 277 | **277** |
| Masters historiques non récupérés | 204 | **204** |

La galerie contient 40 fiches historiques, neuf du lot 1, douze du lot 2, huit du lot 3 et neuf du lot 4. Les nouvelles bases sont statiques et non jouables. Les deux arènes disposent chacune de leurs trois plans et sont disponibles dans le sélecteur des arènes.

## Quatre formes et quatre rencontres de boss

| Sujet | Livraison | Portée |
|---|---|---|
| Jasper Guns humain | Une fiche `character_form` | Forme humaine assise dans son fauteuil ; bas de tenue et fauteuil à confirmer plus finement. |
| Mother humaine | Une fiche `character_form` | Robe, voile et fauteuil rouge ; détails bas gardés en revue de référence. |
| Sophie zombie | Une fiche `character_form` | Fin du HOTD arcade original, distincte des variantes Saturn/PC ; petits détails encore ouverts. |
| Goldman zombie | Une fiche `character_form` | Fin HOTD2 ; capture entière comparée, port précis non établi. |
| Nigel & Sebastian | Une fiche de boss | Anatomie conjointe conservée sur une seule image. |
| Lobber | Une fiche de boss | Rendu entier rapproché des captures du combat ; posture, jambes et pieds documentés. |
| Coco & Sindy | Deux fiches de boss | Deux silhouettes séparées pour une seule rencontre Extended Cut. |
| Meat Katie | Une fiche de boss | Rencontre Extended Cut ; réserves anatomiques et d’édition documentées. |

**Mother mutée reste manquante.** Sa génération a été bloquée par le filtre de sortie ImageGen (`moderation_blocked`, catégorie `sexual`). Aucun PNG n’a été créé. La tentative et ses références sont tracées séparément des images livrées, sans variante habillée inventée ni relance équivalente. Coco a nécessité une correction pour rendre lisible son quatrième appui ; seul le résultat corrigé est livré.

Voir [HUMANS.md](HUMANS.md) et [BOSSES.md](BOSSES.md) pour les images, leurs éditions de référence, les prompts exacts et les limites propres à chaque sujet. Les fichiers natifs conservent leurs dimensions, leur alpha et leurs octets ; les copies dans le dépôt sont vérifiées par empreinte.

## Deux arènes HOTD original

| Index | Arène | Plans | Portion couverte |
|---:|---|---|---|
| 24 | Terrasse de Hangedman | `hangedman_roof_back/mid/front.png` | Toits d’ardoise, arcades, balustrades et nuit indigo du jeu original. Autres voies et revanche souterraine ouvertes. |
| 25 | Dôme de culture — Hermit | `hermit_dome_back/mid/front.png` | Salle verte, végétation spiralée, tubes lumineux et sol hexagonal. Tunnel de poursuite encore absent. |

Les six plans sont natifs en **1672 × 941**. Deux fonds RGB opaques et quatre overlays RGBA conservent le sol du moteur à **y = 601**. L’alpha maximal au centre et sur la bande de combat est **1/255** pour chaque overlay. Les passages latéraux et les sols continus sont des adaptations pour le duel. Le [rapport des stages](../stages_2026-11-20_lot4/RAPPORT.md) conserve les captures et les décisions.

## Listing poursuivi

Le [listing personnages et tenues](PERSONNAGES_TENUES.md) conserve **62 tâches et 35 rencontres de boss par épisode ou édition**. Au cumul, **36 lignes ont reçu une base statique dans les quatre lots, 26 restent sans base de ces lots**, pour 38 images de galerie. Ces tâches ne sont pas des personnes uniques.

Quatre rencontres Overkill jusque-là sans base dédiée sont désormais représentées en galerie. Les 35 rencontres comprennent **14 bases d’identité jouables demandant une revue d’édition, 15 rencontres représentées en galerie, quatre comparaisons EX/HOTD4, une refonte Hangedman Scarlet Dawn et une Mother mutée sans base dédiée**. Cela ne signifie pas que tous les boss disposent d’un personnage de combat complet.

Le [listing des stages](STAGES_MANQUANTS.md) garde ses **61 lignes** : 19 lieux avec arène dédiée, huit couvertures partielles, 27 absences et sept besoins de référence. Les deux nouveaux lieux passent à `existant` selon la définition limitée du registre ; leurs parcours voisins restent à produire.

La revue de référence demeure explicitement ouverte sur **9 des 38 fiches des quatre lots**, dont 3 de ce lot. Les autres fiches conservent aussi leurs réserves d’adaptation. Les tenues Saturn Mode, Typing/Kids, variantes de Zombie Revenge, redesigns et autres tâches non livrées restent détaillées dans le listing.

## Intégration et contrôles

Le moteur charge la quatrième collection, refuse les collisions entre lots et présente les nouvelles formes avec leur statut non jouable. Les builders futurs et les validateurs suivent le même manifeste. Un débordement du sélecteur a été corrigé sur la page 5 devenue pleine : la note complète suit désormais l’arène au focus clavier/manette ou au survol, sans empiler les cinq notes sous les boutons. Le guide JOUER place Hangedman en fin de page 5 et Hermit en page 6.

Les vérifications de sélection, de galerie, des textures, des catalogues et du moteur sont détaillées dans [VALIDATION.md](VALIDATION.md). Le [delta](DELTA_LIVRAISON.md) rapproche chaque livraison de sa tâche et distingue images, rencontres, arènes et contenus jouables. La CI est contrôlée sur le commit réellement publié et reportée dans la PR.

**Aucun nouveau PCK ni export web n’est produit dans ce lot.** Les 277 manques minimum de poses suivis et les 204 masters historiques non récupérés restent ouverts. Aucune reproduction 1:1 certifiée ni session manuelle dans le viewport n’est revendiquée. La PR reste non fusionnée.
