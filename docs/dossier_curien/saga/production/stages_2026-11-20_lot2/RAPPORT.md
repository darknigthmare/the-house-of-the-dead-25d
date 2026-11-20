# Deux arènes HOTD2 — lot 2 du 20 novembre 2026

**Six PNG natifs livrés pour deux arènes intégrées au registre : Canal souterrain — Tower (20) et Colisée — Strength (21).** Le registre passe de 20 à 22 arènes. Les images sont des adaptations latérales 2D des lieux documentés ; leur présence ne clôt pas toutes les routes de leurs chapitres.

## Fichiers retenus

| Image | Plan | Dimensions natives | Mode | Octets |
|---|---|---:|---|---:|
| [strength_colosseum_back.png](../../../../../assets/dossier_curien/saga/strength_colosseum_back.png) | back | 1672 × 941 | RGB | 3 290 066 |
| [strength_colosseum_mid.png](../../../../../assets/dossier_curien/saga/strength_colosseum_mid.png) | mid | 1672 × 941 | RGBA | 648 437 |
| [strength_colosseum_front.png](../../../../../assets/dossier_curien/saga/strength_colosseum_front.png) | front | 1672 × 941 | RGBA | 123 889 |
| [tower_canal_back.png](../../../../../assets/dossier_curien/saga/tower_canal_back.png) | back | 1672 × 941 | RGB | 2 950 360 |
| [tower_canal_mid.png](../../../../../assets/dossier_curien/saga/tower_canal_mid.png) | mid | 1672 × 941 | RGBA | 910 442 |
| [tower_canal_front.png](../../../../../assets/dossier_curien/saga/tower_canal_front.png) | front | 1672 × 941 | RGBA | 153 243 |

Total exact : **8 076 437 octets**, six contenus distincts, six appels ImageGen, aucune sortie rejetée. Les pixels natifs sont conservés sans redimensionnement, recadrage ni retouche locale.

## Tower : variante aquatique

Les captures de la première et de la seconde phase montrent des arcades épaisses, des piliers en pierre humide gris-vert et un bassin bleu-gris. Le fond conserve ces motifs. Une berge continue a été ajoutée pour la ligne de combat du moteur ; elle constitue une décision d’adaptation, pas une affirmation sur la géométrie exacte du rail shooter.

La [fiche officielle SEGA](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/tower.html) distingue les affrontements dans l’eau et sur le sable. **La branche sable, les autres parcours du canal et la reprise du boss au siège Goldman restent à produire.** Le quai extérieur de Hierophant déjà présent est un autre lieu.

## Strength : murs clairs du labyrinthe

Les références montrent le combat dans des couloirs et des partitions de pierre, avec une cage métallique de libération, des ouvertures supérieures et un ciel sombre. Le décor retient les murs clairs et la cage dans un renfoncement. Les couloirs sont ouverts latéralement pour permettre le duel sur un sol continu.

La [fiche officielle SEGA](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/strength.html) confirme des parcours est et ouest. Le [guide illustré du chapitre 4](https://www.k-triggerhappy.com/hod2/chapter4.html) montre aussi la différence entre murs clairs et sombres. **La variante sombre et les autres chemins du labyrinthe restent ouverts.** Aucun bassin n’est ajouté : la mention d’un bassin dans l’ancien backlog n’était pas étayée par ces captures et a été corrigée dans le registre courant.

## Calage et vérification

Les trois plans utilisent le rectangle existant `(-38, -14, 1356, 754)` et le sol de combat `y = 601`, soit une hauteur de contact normalisée de `0,81565`. Les amplitudes de parallaxe existantes sont conservées. Les deux fonds présentent une bande horizontale dégagée sous les pieds des combattants.

Les quatre plans transparents sont cantonnés aux bords et aux coins. Dans la zone centrale normalisée `[0,125 ; 0,20 ; 0,875 ; 0,79]`, l’alpha mesuré est compris entre **0 et 1 sur 255** pour chacun : le contrat du moteur est respecté. Cette mesure ne signifie pas que chaque pixel du centre est strictement à zéro.

Les six images ont été inspectées. Les dimensions, modes, empreintes SHA-256, prompts et sources sont consignés dans le [manifeste](manifest.json). Les sources copiées sont identiques aux fichiers téléchargés. Les plans intermédiaire et avant utilisent leur fond généré comme référence d’alignement et de matière.

Les contrôles d’intégration Godot sont documentés dans [VALIDATION.md](../catalogue_2026-11-20_lot2/VALIDATION.md). Ils n’équivalent pas à une session manuelle de jeu ni à une capture du viewport. Aucun nouveau PCK ou export web n’est fourni dans ce lot.

## Sources et limites

Les captures de jeu sont hébergées par le guide communautaire Trigger Happy ; leur port de capture exact n’est pas établi. Elles montrent le design classique HOTD2. Les pages officielles de 2&3 Return servent de recoupement sur les rencontres et leurs routes ; elles n’ont pas été fournies à ImageGen comme images.

- [tower_phase1](https://www.k-triggerhappy.com/hod2/chapter3.html) — [capture conservée](../../../sources_art/references-2026-11-20_lot2/stages/tower_phase1.jpg) ; Damp masonry, stone arches and the first-phase water chamber.
- [tower_phase2](https://www.k-triggerhappy.com/hod2/chapter3.html) — [capture conservée](../../../sources_art/references-2026-11-20_lot2/stages/tower_phase2.jpg) ; Water variant of the second-phase room, dark arches and stone piers.
- [strength_phase4](https://www.k-triggerhappy.com/hod2/chapter4.html) — [capture conservée](../../../sources_art/references-2026-11-20_lot2/stages/strength_phase4.jpg) ; Pale brick and stone maze walls, ground and upper sky openings.
- [strength_phase2](https://www.k-triggerhappy.com/hod2/chapter4.html) — [capture conservée](../../../sources_art/references-2026-11-20_lot2/stages/strength_phase2.jpg) ; Maze partitions; main color follows the pale-wall variant, not this dark route.
- [strength_intro](https://www.k-triggerhappy.com/hod2/chapter4.html) — [capture conservée](../../../sources_art/references-2026-11-20_lot2/stages/strength_intro.jpg) ; Release cage with rusty iron bars.

La composition latérale, les détails de matière ajoutés et les plans de parallaxe sont créés pour Dossier Curien. **Aucune reproduction 1:1 de toutes les éditions n’est certifiée.**
