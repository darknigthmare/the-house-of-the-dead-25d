# Costumes et modèles Saturn/PC Mode — lot6

Date : 20 novembre 2026. Comparaison : `7f14d7b49dcc8d884629245eef71e65198665b8e`.

**4 bases statiques natives,4 appels imagegen,4 images retenues,0 rejet.** Aucune nouvelle identité, aucun personnage jouable, aucun costume sélectionnable et aucune animation complète ajoutés. Les quatre entrées restent en QA visuelle sur la concordance exacte entre les ports Saturn et Windows.

## Livraisons

| Entrée | Caractéristiques vérifiées sur références | Réserves ouvertes |
|---|---|---|
| Rogan2 — Saturn/PC Mode | Casquette sombre à carreaux, visage rasé et cheveux sombres ; visibles dans la miniature et le portrait de sélection PC Mode. Veste courte brun-bordeaux sombre, chemise sombre et cravate rouge ; visibles dans la miniature, le portrait et la cinématique finale. | Forme et teinte détaillées des chaussures non résolues dans les vignettes : chaussures fermées brun sombre interprétées. Concordance Saturn/PC à vérifier. |
| G2 — Saturn/PC Mode | Cheveux sombres courts, lunettes à monture claire et barbe/moustache courtes ; visibles dans la miniature et le portrait PC Mode. Veste et pantalon noirs, chemise jaune à long col, cravate noire et poignets jaunes ; visibles dans la miniature et les vues finales en jeu. | Forme détaillée des chaussures non résolue ; chaussures noires fermées interprétées. Concordance Saturn/PC à vérifier. |
| Sophie — Saturn/PC Mode | Cheveux blonds courts en carré, tailleur roux/orange, large col/poignets blancs et badge DBR ; portrait de sélection et cinématique finale PC Mode. Jupe courte assortie, jambes de teinte chair et chaussures fermées brun-ocre à talon ; visibles dans la miniature entière du modèle. | Miniature composée par l’auteur de la vidéo : elle montre le modèle, mais ne constitue pas une capture brute non montée. Concordance Saturn/PC à vérifier. |
| Chercheuse DBR — Saturn/PC Mode | Modèle féminin brun portant des lunettes rondes ; miniature et gros plan final PC Mode. Une seconde capture vidéo montre une courte queue de cheval à la nuque. Tunique blanche à col haut fermé et fermeture oblique, badge DBR bleu-gris ; visibles dans le gros plan et la miniature. | Chaussures non résolues par les captures retenues : forme fermée blanche basse interprétée. Concordance Saturn/PC à vérifier. |

## Ce que les captures établissent

Les références de détail proviennent de véritables modèles du PC Mode Windows. Les miniatures publiées par LyricBR présentent des montages de ces modèles ; les feuilles de storyboards natives du même enregistrement confirment les portraits de sélection et les vues en jeu. Pour Rogan2 et Sophie, une seconde vidéo NintendoComplete montre également la sélection Saturn Mode, mais ses cases ne mesurent que 120×90 pixels. Cette comparaison ne suffit pas à certifier les textures ou les modèles Saturn dans le détail.

Les images de galerie sont des adaptations peintes en 2D. La pose, les plis, les coutures et les petits accessoires sont interprétés. Chaque fiche du reçu sépare les caractéristiques observées et celles qui restent incertaines. La chercheuse DBR est un modèle féminin à lunettes et pantalon blanc, documenté par une seconde capture latérale de Rocsen ; elle n’est pas remplacée par un chercheur masculin générique.

Sophie conserve la même identité que le PNJ narratif. Cette livraison représente son modèle armé de Saturn/PC Mode dans le tailleur roux/orange du port consulté ; elle ne déclare aucune seconde personne ni implémentation du mode.

## Contrôles natifs

| Asset | Dimensions | SHA-256 | Alpha maximal au bord |
|---|---:|---|---:|
| `rogan_saturn2` | 1024 × 1536 | `81883bb1a652193d866a198a39bf3c136870e1101cc6725800ebac67cf3586aa` | 1 |
| `g_saturn2` | 1024 × 1536 | `9b2be879589ceff02ff11babdd4dadd252be03a3a5e1937ac116042a3013c738` | 2 |
| `sophie_saturn` | 1024 × 1536 | `464f45b82e4546014fd69cebd68860e9e1ad803ce4fb54aab874cccbc7a3936d` | 1 |
| `researcher_saturn` | 1024 × 1536 | `6137b6e3b6283af77b179fc84b62119b43c13ebf0caf43f09d58b862316ee21b` | 1 |

Les quatre sorties sont des PNG RGBA natifs. Tête, mains, arme, jambes et chaussures sont entièrement cadrées. Aucun pixel alpha > 127 ne touche les bords. De très faibles valeurs d’alpha 1 ou 2 subsistent sur certains bords ; elles sont enregistrées, conservées et n’ont pas été nettoyées. Le RGB caché sous alpha peut produire un halo apparent dans une prévisualisation qui ignore la transparence.

Les fichiers ont été copiés sans modification des octets. Aucun dessin local, détourage, recadrage, redimensionnement ou réencodage des PNG générés. Les références de ce lot sont également conservées dans leurs octets natifs, sans recadrage des storyboards.

## État du listing

Les tâches `rogan_saturn2`, `g_saturn2`, `sophie_saturn` et `researcher_saturn` disposent maintenant chacune d’une base de galerie. Elles restent partielles : conformité Saturn précise à vérifier, absence de sélection de modèle et absence d’animation complète. Les sources consultées pour Bruno Delinger/Original Mode n’ont donné lieu à aucune génération dans ce lot, les quatre sujets prévus ayant pu être documentés.

## Références

- Rogan2, PC Mode, LyricBR : https://www.youtube.com/watch?v=mYHcTCZf4wg
- G2, PC Mode, LyricBR : https://www.youtube.com/watch?v=5ZhcdZuQUnA
- Sophie, PC Mode, LyricBR : https://www.youtube.com/watch?v=ABYT4bFjoto
- Researcher, PC Mode, LyricBR : https://www.youtube.com/watch?v=orSO1dCHHdk
- Researcher, vue latérale, Rocsen : https://www.youtube.com/watch?v=gaxE3kF8D7k
- Sélections Saturn Mode, NintendoComplete : https://www.youtube.com/watch?v=owrOwiLUjZ4
- Identification du mode et des entrées : https://thehouseofthedead.fandom.com/wiki/Saturn_Mode

Les scans de guide officiel mentionnés par la page Saturn Mode n’ont pas été obtenus ; ils ne sont pas présentés comme des références examinées. L’index des 15 fichiers natifs indique URL, auteur de vidéo, grille, positions temporelles approximatives, définition et empreinte SHA-256.

## Reçu et revue

- Reçu machine : `costumes_generated.json`.
- Index des références : `docs/dossier_curien/sources_art/references-2026-11-20_lot6/costumes/references.json`.
- Prompts exacts, arguments envoyés, références, empreintes et limites : inclus dans le reçu.
- Revue visuelle de production et revue indépendante root effectuées sur les quatre PNG et leurs références ; quatre QA de concordance Saturn/PC demeurent ouvertes.
- Publication/PR confiée à l’intégration du lot ; aucun commit ou changement de PR effectué par cette sous-tâche.
