# Lot 6 — quatre arènes, douze plans natifs

20 novembre 2026 — Europe/Paris. Base : `7f14d7b49dcc8d884629245eef71e65198665b8e`.

**Quatre arènes ajoutées au registre : 29 → 33.** Douze appels ImageGen, douze PNG retenus, aucune sortie rejetée et aucune retouche locale.

| Index | Arène | Portée de la référence |
| ---: | --- | --- |
| 29 | Sous-sols AMS — Escape | Gameplay captures from an arcade/PS3 guide; exact captured port not established |
| 30 | Annexe — Scarlet Dawn | Arcade screen photographs of Route A; route identified as Annex by secondary textual sources |
| 31 | Manoir — Papa’s Palace of Pain | PlayStation 3; Japanese guide names the edition Director’s Cut |
| 32 | Égouts industriels — Zombie Revenge | Dreamcast according to public longplay author Retronomicon / NVSGamer |

## Fichiers livrés

Tous les plans mesurent **1 672 × 941 pixels natifs**. Les quatre fonds sont RGB opaques ; les huit plans de parallaxe sont RGBA.

| PNG | Plan | Octets |
| --- | --- | ---: |
| [ams_underground_back.png](../../../../../assets/dossier_curien/saga/ams_underground_back.png) | back | 2477224 |
| [ams_underground_mid.png](../../../../../assets/dossier_curien/saga/ams_underground_mid.png) | mid | 206514 |
| [ams_underground_front.png](../../../../../assets/dossier_curien/saga/ams_underground_front.png) | front | 71667 |
| [overkill_papa_back.png](../../../../../assets/dossier_curien/saga/overkill_papa_back.png) | back | 2747268 |
| [overkill_papa_mid.png](../../../../../assets/dossier_curien/saga/overkill_papa_mid.png) | mid | 405942 |
| [overkill_papa_front.png](../../../../../assets/dossier_curien/saga/overkill_papa_front.png) | front | 73829 |
| [scarlet_annex_back.png](../../../../../assets/dossier_curien/saga/scarlet_annex_back.png) | back | 2504131 |
| [scarlet_annex_mid.png](../../../../../assets/dossier_curien/saga/scarlet_annex_mid.png) | mid | 236381 |
| [scarlet_annex_front.png](../../../../../assets/dossier_curien/saga/scarlet_annex_front.png) | front | 80362 |
| [zr_sewage_back.png](../../../../../assets/dossier_curien/saga/zr_sewage_back.png) | back | 3074670 |
| [zr_sewage_mid.png](../../../../../assets/dossier_curien/saga/zr_sewage_mid.png) | mid | 417255 |
| [zr_sewage_front.png](../../../../../assets/dossier_curien/saga/zr_sewage_front.png) | front | 91699 |

Total exact : **12386942 octets**. Les douze contenus sont distincts et identiques aux sorties ImageGen natives.

## Références et adaptations

### Sous-sols AMS — Escape

Les [captures du chapitre 1](https://www.k-triggerhappy.com/hod4/chapter1.html) montrent les panneaux gris-vert, bande ocre, grilles de ventilation, commandes murales et plafond endommagé. Le [guide](https://www.k-triggerhappy.com/hod4/index.html) couvre arcade et PS3 ; le port des captures reste non établi. Plusieurs angles deviennent un seul couloir latéral à portes de service. Les bureaux, autres embranchements et Justice ne sont pas couverts.

### Annexe — Scarlet Dawn

La [photo du hall de la route A](https://k-triggerhappy.com/blog/hod_scarletdawn-secretscore/) montre les balcons sculptés, boiseries, murs verts et lustre. L’association route A / Annex s’appuie sur les [descriptions de chapitre](https://thehouseofthedead.fandom.com/wiki/Kate_and_Ryan) et leur [corroboration textuelle](https://w.atwiki.jp/aniwotawiki/pages/60549.html). La photo du hall est la seule référence visuelle donnée au générateur pour ce fond ; les deux vues voisines conservées apportent le contexte de l’annexe. Porte, espacement, petit mobilier et sol sont interprétés. Le sol rendu se lit comme un pavage brun irrégulier ; ce motif n’est pas documenté par la photo, dont le bas est largement masqué. Salle du piano, ascenseurs et salle de Chariot restent séparés.

### Manoir — Papa’s Palace of Pain

Le [guide PS3](https://www.k-triggerhappy.com/hodoverkill_ps3/stage1.html) fournit deux angles du hall : galerie à balustres clairs, murs olive usés, fenêtres condamnées, portes simples et parquet. L’escalier est reporté à l’arrière gauche pour dégager le combat. Jardin, étages, sous-sol et arène de Jasper restent à réaliser.

### Égouts industriels — Zombie Revenge

Le [longplay](https://www.youtube.com/watch?v=ne37UXflHqw), attribué à Dreamcast par son auteur, montre le titre **AREA3 INDUSTRIAL SEWAGE PLANT** dans la feuille native conservée au lot 5. Ses six vues basses montrent le canal, les berges, murs et tuyaux. Chaque cellule fait 320 × 180 ; aucune extraction haute définition ni minutage exact n’est revendiqué. La berge de premier plan est élargie et l’eau placée derrière les combattants. Les détails fins restent interprétés.

Le [registre des sources](../../../sources_art/references-2026-11-20_lot6/stages/source_index.json) contient URL, dimensions, rôle, empreinte et limites. Aucun pixel source n’est modifié.

## Transparence et calibration

Le renderer garde son rectangle `(-38, -14, 1356, 754)`, son sol à 601 et les amplitudes 17 / 32 / 58. Le centre normalisé `[0.125, 0.20, 0.875, 0.79]` et la bande de combat `[0.125, 0.75, 0.875, 1]` présentent un alpha maximal de **1/255** sur les huit surimpressions. Les fragments visibles restent aux côtés ou coins bas. Les bornes en pixels sont calculées sur les dimensions natives réelles et conservées dans le manifeste.

## Revue et limites

Les douze sorties et toutes les références retenues ont été inspectées par root, puis revues indépendamment par lot6_saturn. Cette seconde revue n’a relevé aucun défaut bloquant dans le périmètre d’adaptation déclaré. Il s’agit d’adaptations peintes pour une caméra latérale, avec sols et espacements adaptés. Le rapport ne certifie aucune reproduction canonique à l’identique.

Le moteur est contrôlé sans affichage dans la [validation intégrée](../catalogue_2026-11-20_lot6/VALIDATION.md). Une capture native a été étudiée : l’environnement refuse la création de sockets AF_UNIX (`EPERM`), empêchant le serveur Xorg disponible de démarrer. Aucune capture de viewport ni session manuelle n’est revendiquée. Le [manifeste](manifest.json) sépare ces limites des mesures des PNG.
