# Dossier Curien — personnages, costumes et stages, lot 3

Ce lot poursuit la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2) à partir de `af0e4933c07b9016a6be552ce874b61007dd7836`. Il livre **14 nouvelles images natives, huit fiches de galerie et deux arènes**, avec références inspectées, réserves documentées et listing actualisé. Les PNG retenus totalisent **18 291 535 octets**.

## Résultat dans les sources

| Mesure | Avant le lot 3 | Après intégration |
|---|---:|---:|
| Fiches de galerie | 61 | **69** |
| Arènes | 22 | **24** |
| PNG Dossier Curien | 365 | **379** |
| Blobs Git PNG distincts | 363 | **377** |
| Combattants jouables | 24 | **24** |
| Parcours narratifs | 26 | **26** |
| Entrées Archives | 29 | **29** |
| Costumes alternatifs sélectionnables | 2 | **2** |
| Minimum suivi de poses manquantes | 277 | **277** |
| Masters historiques non récupérés | 204 | **204** |

La galerie contient les 40 fiches historiques, neuf du lot 1, douze du lot 2 et huit du lot 3. Les nouvelles fiches sont des illustrations de bestiaire non jouables. Les deux arènes disposent chacune de leurs trois plans et peuvent être sélectionnées dans le registre des arènes.

## Personnages, costumes et boss

| Sujet | Édition | Livraison | Réserve principale |
|---|---|---|---|
| Sophie Richards | HOTD1 classique | Nouvelle adaptation statique Dossier Curien | Chaussures et petits détails à confirmer ; statut de référence ouvert. |
| Dr. Curien | HOTD1 classique | Nouvelle adaptation de la forme humaine | Petit modèle d’origine ; détails de canne, gilet et accessoires interprétés. |
| James Taylor | HOTD4 | Tenue et matériel de cette édition | Arme corrigée ; détails mécaniques illustrés, pas certifiés à l’identique. |
| Agent G | HOTD4 Special | Costume de cette édition | Nuances et microdétails interprétés ; rendu en pied recoupé avec flyer SEGA. |
| High Priestess | Scarlet Dawn | Base de boss entière | Huit tentacules comparés au rendu officiel ; vue arrière et animation non livrées. |
| Screamer | Overkill | Base de boss entière | Captures PS3 et artwork Wii rapprochés ; correspondance exacte entre éditions ouverte. |
| Crawler | Overkill | Base de boss entière | Pose reconstruite depuis des captures en mouvement ; proportions fines non certifiées. |
| Brutus | Overkill | Base de boss entière corrigée | Latéralité contrôlée ; tatouages et mécanique restent une adaptation. |

Les ressources historiques de Sophie et Curien ne sont pas recopiées comme référence canonique : la Sophie antérieure ajoutait des accessoires absents des captures ; la palette du Curien historique différait du modèle arcade. Les nouvelles bases suivent les éléments effectivement visibles dans le jeu, tout en conservant les anciens fichiers.

Les quatre humains/costumes sont des PNG RGBA de **1024 × 1536** ; les quatre boss sont des PNG RGBA de **1254 × 1254**. Les sorties sont conservées à leurs dimensions et octets natifs. Les 16 appels ImageGen comprennent deux corrections : arme de James et retrait du réticule d’interface repris sur le ventre de Brutus. Les deux premières sorties sont exclues de la galerie. Le premier James est archivé uniquement comme entrée documentaire de son édition ; le premier Brutus reste hors dépôt.

Voir [HUMANS.md](HUMANS.md), [COSTUMES.md](COSTUMES.md) et [BOSSES.md](BOSSES.md) pour les images, références, prompts et limites par sujet.

## Deux arènes HOTD III

| Index | Arène | Plans | Portion couverte |
|---:|---|---|---|
| 22 | Enclos du D.B.R. — Fool | `fool_enclosure_back/mid/front.png` | Salle grillagée et passerelles ; autres secteurs D.B.R./EFI encore ouverts. |
| 23 | Chambre BIO — Sun | `sun_bio_back/mid/front.png` | Chambre industrielle végétalisée ; chemins L2/L3 BIO encore ouverts. |

Les six plans natifs de **1672 × 941** conservent le sol du moteur à **y = 601**. Les fonds sont RGB opaques ; les plans intermédiaires et avant sont RGBA, avec un alpha maximal de **1/255** dans la zone centrale et sur la bande de combat. Leur disposition latérale et le sol continu sont des choix d’adaptation, pas une copie exacte du rail shooter. Le [rapport des stages](../stages_2026-11-20_lot3/RAPPORT.md) détaille les références officielles et les captures comparées.

## Listing poursuivi

Le [listing personnages et tenues](PERSONNAGES_TENUES.md) conserve **62 lignes de travail et 35 rencontres de boss par épisode ou édition**. Au cumul des trois lots, **28 lignes disposent d’une nouvelle base statique, 34 n’en ont pas reçu** ; elles représentent 29 images de galerie. Ce ne sont pas 62 personnes uniques.

Les 35 rencontres se répartissent maintenant entre **14 bases d’identité jouables demandant une revue d’édition, 11 rencontres représentées en galerie, cinq rencontres sans base dédiée, une refonte Hangedman Scarlet Dawn ouverte et quatre comparaisons EX/HOTD4 ouvertes**. Les cinq rencontres sans base dédiée sont Nigel & Sebastian, Lobber, Mother, Coco & Sindy et Meat Katie.

Le [listing des stages](STAGES_MANQUANTS.md) conserve **61 lignes** : 17 avec une arène dédiée, huit couvertures partielles, 29 absences et sept besoins de référence. Les deux nouvelles salles font passer leurs familles de `absent` à `adaptation_partielle` ; elles ne ferment pas des chapitres entiers.

Les autres travaux restent détaillés par ligne : mouvements et animations, personnages secondaires, tenues de Saturn Mode, Typing2/Kids2004, variantes de Zombie Revenge, comparaisons entre éditions et redesigns des remakes. Les inventaires historiques sont conservés ; le [delta courant](DELTA_LIVRAISON.md) rapproche chaque nouvelle base de sa ligne.

## Contrôles et portée

Les sorties et leurs références ont été examinées, les empreintes recalculées et les flags de galerie rapprochés des manifestes. Les validations Node, Godot et des catalogues, avec leurs résultats exacts, sont consignées dans [VALIDATION.md](VALIDATION.md). Le guide JOUER corrige aussi la pagination : train et abattoir en page 4 ; Tower, Strength, Fool et Sun en page 5.

Sophie rejoint Candi, Varla, Thornheart, Papa Caesar et Clement Darling parmi les **six fiches à revue de référence explicitement ouverte dans les trois lots**. Les autres fiches gardent leurs limites d’adaptation. Aucune reproduction canonique 1:1, animation complète, session de jeu manuelle ou capture de viewport n’est revendiquée.

L’intégration concerne les sources et la galerie du projet. **Aucun nouveau PCK ni export web n’est produit dans ce lot.** Les 277 manques minimum de poses suivis et les 204 masters historiques non récupérés restent ouverts. La PR n’est pas fusionnée.
