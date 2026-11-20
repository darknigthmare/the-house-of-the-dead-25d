# Deux arènes HOTD III — lot 3 du 20 novembre 2026

**Six PNG natifs livrés pour Enclos du D.B.R. — Fool (index 22) et Chambre BIO — Sun (index 23).** Le registre passe de 22 à 24 arènes. Ces deux salles de boss complètent partiellement les familles D.B.R./EFI et BIO ; elles ne couvrent pas leurs parcours entiers.

## Fichiers retenus

| Image | Plan | Dimensions natives | Mode | Octets |
|---|---|---:|---|---:|
| [fool_enclosure_back.png](../../../../../assets/dossier_curien/saga/fool_enclosure_back.png) | back | 1672 × 941 | RGB | 3 320 895 |
| [fool_enclosure_mid.png](../../../../../assets/dossier_curien/saga/fool_enclosure_mid.png) | mid | 1672 × 941 | RGBA | 278 835 |
| [fool_enclosure_front.png](../../../../../assets/dossier_curien/saga/fool_enclosure_front.png) | front | 1672 × 941 | RGBA | 101 799 |
| [sun_bio_back.png](../../../../../assets/dossier_curien/saga/sun_bio_back.png) | back | 1672 × 941 | RGB | 2 497 179 |
| [sun_bio_mid.png](../../../../../assets/dossier_curien/saga/sun_bio_mid.png) | mid | 1672 × 941 | RGBA | 395 054 |
| [sun_bio_front.png](../../../../../assets/dossier_curien/saga/sun_bio_front.png) | front | 1672 × 941 | RGBA | 109 846 |

Total exact : **6 703 608 octets**  six contenus distincts  six appels ImageGen  aucune sortie rejetée. Les pixels natifs sont conservés sans recadrage  redimensionnement ni retouche locale.

## Fool : enclos du D.B.R.

La [fiche officielle SEGA](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type0028_fool_1.html) et les [captures du D.B.R.](https://www.k-triggerhappy.com/hod3/chapter2A.html) montrent une haute structure métallique grillagée, des passerelles superposées et un escalier. Le fond conserve ces éléments. Le cadrage devient latéral et le sol de maintenance est élargi pour le combat. Le boss et les éléments d’interface ne sont pas repris.

**Les autres secteurs du D.B.R. et la variante EFI Genome Ward restent à produire.** Le nom de l’arène identifie la portion choisie ; il ne transforme pas toute la famille en décor terminé.

## Sun : chambre industrielle BIO

Les [images officielles SEGA](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type8830_sun.html) et les [captures du parcours BIO](https://www.k-triggerhappy.com/hod3/chapter3A.html) montrent une salle industrielle fermée, des parois courbes avec bandes horizontales, des câbles, des traces végétales, des lampes pâles et une zone de plantation basse. Le fond conserve ces motifs ; la plante boss et ses attaques sont retirées du passage.

La disposition latérale, les détails de matière et le sol continu sont des adaptations pour ce moteur. **Les branches L2 BIO Plant et L3 BIO Lab demeurent partiellement couvertes.** La salle n’est pas présentée comme une serre ensoleillée ou une reproduction exacte de chaque variante.

## Calage et contrôle

Les trois plans de chaque arène utilisent le rectangle existant `(-38, -14, 1356, 754)` et le sol `y = 601`, soit une ligne de contact normalisée à `0,81565`. Les amplitudes de parallaxe sont conservées : 17 pour le fond, 32 pour le plan intermédiaire et 58 pour l’avant-plan.

Les quatre overlays sont de vrais PNG RGBA, avec un alpha global de 0 à 255. Dans la zone centrale `[0,125 ; 0,20 ; 0,875 ; 0,79]`, leur alpha est compris entre **0 et 1 sur 255**. La bande de combat `[0,125 ; 0,75 ; 0,875 ; 1]` respecte aussi un maximum de 1 ; celle de `fool_enclosure_front` est strictement à zéro. Les quelques pixels à 1/255 ne sont pas présentés comme un zéro exact.

Les six sorties ont été inspectées visuellement. Les quatre overlays restent aux bords et aux coins ; aucun personnage, boss ou HUD n’est conservé. Les références téléchargées et les PNG générés sont conservés à octets identiques, vérifiés par SHA-256 dans le [manifeste](manifest.json).

Les vérifications Godot sont consignées dans [VALIDATION.md](../catalogue_2026-11-20_lot3/VALIDATION.md). Une validation headless ne vaut pas session manuelle ni capture du viewport. Ce lot ne fournit aucun nouveau PCK ni export web.

## Références et limites

Les deux petites captures officielles proviennent du guide Wii 2&3 Return publié par SEGA/Sonic Team. Les captures plus grandes sont hébergées par Trigger Happy ; leur port exact n’est pas établi. Les sources sont rapprochées sur l’architecture visible, sans certifier une identité visuelle de toutes les éditions.

- [fool_official_01](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type0028_fool_1.html) — [image conservée](../../../sources_art/references-2026-11-20_lot3/stages/fool_official_01.jpg) ; Official SEGA/Sonic Team 2&3 Return Wii guide, 2008.
- [fool_capture_02](https://www.k-triggerhappy.com/hod3/chapter2A.html) — [image conservée](../../../sources_art/references-2026-11-20_lot3/stages/fool_capture_02.jpg) ; Actual HOTD3 gameplay capture hosted by a community guide; capture port not independently established.
- [sun_official_01](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type8830_sun.html) — [image conservée](../../../sources_art/references-2026-11-20_lot3/stages/sun_official_01.jpg) ; Official SEGA/Sonic Team 2&3 Return Wii guide, 2008.
- [sun_capture_boss3-1](https://www.k-triggerhappy.com/hod3/chapter3A.html) — [image conservée](../../../sources_art/references-2026-11-20_lot3/stages/sun_capture_boss3-1.jpg) ; Actual HOTD3 gameplay capture hosted by a community guide; capture port not independently established.
- [sun_capture_boss3-2](https://www.k-triggerhappy.com/hod3/chapter3A.html) — [image conservée](../../../sources_art/references-2026-11-20_lot3/stages/sun_capture_boss3-2.jpg) ; Actual HOTD3 gameplay capture hosted by a community guide; capture port not independently established.

Le décor Strength du lot précédent n’a servi que de référence de matière peinte et de lisibilité du sol. Aucun motif de colisée n’est employé comme preuve de l’architecture HOTD III. **Ces images sont des adaptations 2D générées, pas des fonds extraits du jeu ni des reproductions 1:1 certifiées.**
