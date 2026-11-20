# Deux arènes supplémentaires — production du 20 novembre 2026

## Résultat

Ce lot fournit **deux décors de combat en trois plans chacun**, soit **6 PNG natifs distincts** et **5 725 296 octets**. Les lieux retenus sont le toit du train de **Zombie Revenge** et l’abattoir de **Creeping Flesh**, dans **The House of the Dead: OVERKILL — Extended Cut**.

Les images sont des **adaptations 2D documentées**. Elles transposent les matériaux et les motifs visibles dans les sources vers la disposition latérale utilisée par le projet. Elles ne sont ni des extractions originales de SEGA ni des reproductions certifiées à l’identique.

Le [manifeste de production](manifest.json) contient les six prompts complets, leurs SHA-256 calculés sur le texte UTF-8, les empreintes des PNG et des références, les dimensions, la transparence et les paramètres de composition. Chaque fichier provient d’un appel distinct à ImageGen intégré. Les copies intégrées conservent exactement les octets générés ; aucune retouche, découpe ou mise à l’échelle n’a été appliquée aux sources PNG.

| Arène proposée | Clé de décor | Fond opaque | Plan intermédiaire | Premier plan |
|---|---|---|---|---|
| Toit du train — Zombie Revenge | `zr_train` | [zr_train_back.png](../../../../../assets/dossier_curien/saga/zr_train_back.png) | [zr_train_mid.png](../../../../../assets/dossier_curien/saga/zr_train_mid.png) | [zr_train_front.png](../../../../../assets/dossier_curien/saga/zr_train_front.png) |
| Abattoir — Creeping Flesh | `creeping_flesh` | [creeping_flesh_back.png](../../../../../assets/dossier_curien/saga/creeping_flesh_back.png) | [creeping_flesh_mid.png](../../../../../assets/dossier_curien/saga/creeping_flesh_mid.png) | [creeping_flesh_front.png](../../../../../assets/dossier_curien/saga/creeping_flesh_front.png) |

Les six images mesurent **1672 × 941 pixels**. Les deux fonds sont en RGB opaque ; les quatre autres plans sont en RGBA avec transparence native.

## Pourquoi ces lieux étaient manquants

L’audit porte sur les tableaux `STAGES` et `ART` de [saga.gd](../../../../../src/dossier_curien/saga.gd), à la révision **59372b6**, avant l’intégration de ce lot. Ils enregistrent les 18 arènes suivantes :

| Index | Arène existante |
|---:|---|
| 0 | Cour du manoir |
| 1 | Antichambre |
| 2 | Laboratoire de Curien |
| 3 | Quai de la cité inondée |
| 4 | Poste de sécurité EFI |
| 5 | Métro souterrain |
| 6 | Complexe déserté |
| 7 | Réception de Scarecrow Mansion |
| 8 | Fête foraine de Bayou City |
| 9 | Plateau de Loving Deads |
| 10 | Rue en quarantaine |
| 11 | Toit de la tour Goldman |
| 12 | Chambre d’incubation EFI |
| 13 | Passage de la tour de l’horloge |
| 14 | Ponton du bayou |
| 15 | Parvis du siège Goldman |
| 16 | Ruines du domaine Scarecrow |
| 17 | Rue dévastée de Despair |

Zombie Revenge y dispose de la **Rue en quarantaine**, sans arène sur le toit du train. Overkill y possède la fête foraine et le bayou, sans abattoir de Creeping Flesh. Le métro existant est un autre lieu ; il ne représente pas le toit du train de Zombie Revenge.

Cette sélection établit deux absences concrètes dans le registre. Elle ne constitue pas un inventaire exhaustif de tous les niveaux, embranchements, salles, décors alternatifs ou cadrages de la saga. L’augmentation à 20 arènes dépend de leur inscription et de leur validation dans le jeu par la tâche d’intégration.

## Sources et choix d’adaptation

### Toit du train — Zombie Revenge

La référence visuelle principale est la [capture Dreamcast « On a train roof »](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/1117675/), contribuée par GTramp et hébergée par MobyGames. Sa [copie locale intacte](../../../sources_art/references-2026-11-20/stages/zr_train_roof.png) montre le toit segmenté gris verdâtre, une passerelle grillagée longitudinale et un tunnel ocre parcouru de conduites.

Une [seconde capture Dreamcast intitulée « Area 4 - The Train »](https://www.mobygames.com/game/4412/zombie-revenge/screenshots/dreamcast/18302/), contribuée par quizzley7, documente le même type de toit depuis un cadrage extérieur nocturne. Sa [copie locale](../../../sources_art/references-2026-11-20/stages/zr_train_area4.jpg) sert à confirmer l’identité du lieu ; cette ambiance extérieure n’a pas été mélangée au tunnel retenu.

Ces captures de jeu proviennent d’un hébergeur secondaire et ne sont pas présentées comme des images de presse officielles. La [fiche historique SEGA](https://www.sega.jp/history/arcade/product/8161/) fournit un contexte officiel sur Zombie Revenge, mais sa capture générique ne suffit pas à identifier le train et n’a pas servi de modèle de cet environnement.

Le fond produit place le toit et sa grille dans l’axe horizontal du combat. Les raccords de tôle, la courbure de la caisse, les nervures du tunnel et les conduites maintiennent le vocabulaire visuel de la source. L’éclairage, l’espacement des supports et la caméra sont recomposés pour le projet. Les deux autres plans ajoutent seulement de petits supports de conduites sur les côtés et deux fragments du rebord métallique dans les coins inférieurs.

### Abattoir — Creeping Flesh

La [présentation officielle publiée par PlayStation.Blog le 30 août 2011](https://blog.playstation.com/2011/08/30/house-of-the-dead-overkill-extended-cut-creeping-flesh-level-reveal/) situe ce niveau dans un abattoir envahi. La [capture officielle conservée localement](../../../sources_art/references-2026-11-20/stages/creeping_flesh_official.jpg) donne les repères visuels utilisés : cadres métalliques de plafond, tubes lumineux, sol industriel pâle, croissance organique sombre et lumière orange.

L’adaptation transforme le corridor vu à la première personne en un mur latéral et un sol continu. Elle conserve l’infestation comme matière du décor, sans reproduire les mutants, les corps ou l’interface présents dans la capture. Les plans séparés restent limités à quelques conduites prises dans cette matière aux bords de l’image et à de petits détails dans les coins inférieurs. La géométrie du mur est une interprétation pour le combat 2D.

## Accord avec la direction artistique et le moteur

Le [fond de la fête foraine existant](../../../../../assets/dossier_curien/saga/carnival_back.png) a servi de référence de rendu : surfaces peintes et vieillies, profondeur lisible, lumière chaude et détails de matière. Aucun élément de fête foraine n’a été importé dans les nouveaux lieux.

Le calibrage reprend le rectangle actuel de [presentation.gd](../../../../../src/dossier_curien/presentation.gd) : `Rect2(-38, -14, 1356, 754)`. La ligne de pied suggérée est **601 pixels** dans le viewport ; elle correspond à environ **81,56 %** de la hauteur native du fond après ce placement. Les déplacements relatifs existants sont conservables : 17 pour le fond, 32 pour le plan intermédiaire et 58 pour le premier plan.

Les deux fonds ont été inspectés pour vérifier qu’une bande de sol continue traverse la scène à cette hauteur. Les zones épaisses du décor restent derrière les personnages ; aucun personnage, texte, réticule ou HUD n’a été généré.

## Contrôles effectués et portée de la validation

Les six images ont été vues individuellement. Leurs dimensions, modes, tailles et empreintes ont été relevés, puis les empreintes des copies de destination ont été comparées à celles des sorties ImageGen.

Les quatre overlays satisfont le même contrat de dégagement que les plans déjà présents dans le projet : dans le rectangle normalisé **[0,125 ; 0,20 ; 0,875 ; 0,79]**, aucun pixel ne dépasse un alpha de **1 sur 255**. À cette résolution, le contrôle couvre le rectangle **[209, 188, 1463, 743]**, avec borne finale exclue. Les premiers plans ont un alpha central strictement nul ; les plans intermédiaires contiennent seulement quelques résidus d’alpha 1 dans ce rectangle. Il n’y a eu aucun effacement correctif des pixels.

**Aucune capture native du moteur, séquence de combat complète ou validation du défilement en jeu n’est revendiquée dans ce rapport.** L’inscription des arènes, leur éventuelle affectation aux parcours Histoire et les contrôles exécutables appartiennent à l’intégration. La lisibilité avec tous les combattants et aux positions extrêmes doit être appréciée dans ce contexte.

Il n’y a aucun rejet de génération dans ce lot. Les deux nouveaux décors ne ferment pas les besoins en autres stages, variantes, parcours ou fidélité de chaque cadrage original.

