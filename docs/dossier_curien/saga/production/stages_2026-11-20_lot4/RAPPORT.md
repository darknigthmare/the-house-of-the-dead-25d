# Deux arènes HOTD original — lot 4 du 20 novembre 2026

**Six PNG natifs pour Terrasse de Hangedman (index 24) et Dôme de culture — Hermit (index 25).** Le registre passe de 24 à 26 arènes. Ce sont des adaptations latérales de deux lieux précis du jeu arcade original ; leurs parcours voisins restent ouverts.

## Fichiers retenus

| Image | Plan | Dimensions | Mode | Octets |
|---|---|---:|---|---:|
| [hangedman_roof_back.png](../../../../../assets/dossier_curien/saga/hangedman_roof_back.png) | back | 1672 × 941 | RGB | 2 528 424 |
| [hangedman_roof_mid.png](../../../../../assets/dossier_curien/saga/hangedman_roof_mid.png) | mid | 1672 × 941 | RGBA | 421 462 |
| [hangedman_roof_front.png](../../../../../assets/dossier_curien/saga/hangedman_roof_front.png) | front | 1672 × 941 | RGBA | 93 863 |
| [hermit_dome_back.png](../../../../../assets/dossier_curien/saga/hermit_dome_back.png) | back | 1672 × 941 | RGB | 2 863 113 |
| [hermit_dome_mid.png](../../../../../assets/dossier_curien/saga/hermit_dome_mid.png) | mid | 1672 × 941 | RGBA | 281 253 |
| [hermit_dome_front.png](../../../../../assets/dossier_curien/saga/hermit_dome_front.png) | front | 1672 × 941 | RGBA | 88 592 |

Total exact : **6 276 707 octets**, six contenus distincts, six appels ImageGen, aucune sortie rejetée. Aucun recadrage, redimensionnement ni retouche locale ; les fichiers natifs sont copiés à octets identiques.

## Terrasse de Hangedman

Les [captures arcade examinées](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) montrent les toits d’ardoise gris-bleu, des lucarnes étroites, des arcades de pierre, des corniches et une balustrade. La séquence d’introduction montre la lune et le ciel indigo. Ces motifs sont conservés sans le boss, les chauves-souris, les otages ni l’interface.

Le cadrage latéral, l’espacement des arcades, la position de la lune et la terrasse de combat continue sont des adaptations. **Les autres voies des toits, la revanche souterraine et le décor de Scarlet Dawn ne sont pas couverts.**

## Dôme de culture — Hermit

Les [deux vues du dôme](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) montrent des panneaux verts de végétation spiralée, des tubes lumineux verticaux, des structures industrielles sombres, une rambarde courbe et des dalles hexagonales vertes. La vue d’introduction d’Hermit permet aussi de voir une grille claire au plafond. Les motifs sont repris et le sol est élargi pour le combat. Curien et Hermit sont retirés du décor.

**Le tunnel de poursuite d’Hermit reste à produire.** Sa capture est archivée comme preuve de cette limite, mais n’a pas servi à générer le dôme. Le rythme des panneaux et la portion du plafond hors champ restent interprétés. Ce décor est distinct de la chambre BIO de Sun ajoutée au lot 3.

## Calage et alpha

Le rectangle existant `(-38, -14, 1356, 754)` et le sol `y = 601` sont conservés. La ligne de contact correspond à `615 / 754`, soit environ 0,81565 de la hauteur. Les amplitudes de parallaxe restent 17, 32 et 58. Les plans intermédiaires sont de minces fragments architecturaux aux bords ; les avant-plans sont limités aux coins bas.

| Overlay | Alpha global | Alpha au centre | Alpha bande de combat |
|---|---|---|---|
| `hangedman_roof_mid` | [0, 255] | [0, 1] | [0, 1] |
| `hangedman_roof_front` | [0, 255] | [0, 1] | [0, 1] |
| `hermit_dome_mid` | [0, 255] | [0, 1] | [0, 1] |
| `hermit_dome_front` | [0, 255] | [0, 1] | [0, 1] |

Le centre mesuré est `[0,125 ; 0,20 ; 0,875 ; 0,79]` ; la bande de combat est `[0,125 ; 0,75 ; 0,875 ; 1]`. Les maxima autorisés sont 1/255. Les pixels à 1/255 ne sont pas décrits comme un zéro exact. Les quatre overlays disposent d’un véritable canal alpha.

Les six sorties et les sept captures de contexte ont été inspectées visuellement. Le [manifeste](manifest.json) conserve prompts exacts, empreintes, sources, dimensions et contrôles. La validation moteur figure dans [VALIDATION.md](../catalogue_2026-11-20_lot4/VALIDATION.md) ; aucun test headless n’est présenté comme une session de jeu manuelle ou une capture de viewport.

## Références et limites

Les images sont des captures de jeu arcade original hébergées par un guide communautaire ; son auteur indique jouer à la version japonaise sur émulateur Model 2. Le texte de l’article et ses légendes biographiques ne servent pas de référence. Aucune identité de détail entre les éditions Arcade, Saturn, Windows, les remakes ou Scarlet Dawn n’est certifiée.

- [hangedman_roof_intro](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hangedman_roof_intro.png) ; référence visuelle d’architecture.
- [hangedman_roof_battle](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hangedman_roof_battle.png) ; recoupement de l’architecture des toits.
- [hangedman_roof_wide](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hangedman_roof_wide.png) ; référence visuelle d’architecture.
- [hangedman_roof_edge](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hangedman_roof_edge.png) ; référence visuelle d’architecture.
- [hermit_dome_curien](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hermit_dome_curien.png) ; référence visuelle d’architecture.
- [hermit_dome_intro](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hermit_dome_intro.png) ; référence visuelle d’architecture.
- [hermit_tunnel_phase](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) — [capture conservée](../../../sources_art/references-2026-11-20_lot4/stages/hermit_tunnel_phase.png) ; limite de portée : tunnel de poursuite non livré dans ce lot.

Le décor Strength sert seulement de référence de matière peinte et de disposition latérale. **Les nouvelles images sont des adaptations générées, pas des fonds Sega extraits ni des reproductions 1:1 certifiées.** Aucun nouveau PCK ni export web n’est produit par ce lot.
