# Lot 5 — trois arènes et neuf plans natifs

Date : 20 novembre 2026 — Europe/Paris. Base : `6da249f2c2cc9a988e31230dae1f805e3d7e1daf`, après fusion de la PR 2.

**Trois arènes ajoutées au registre : 26→29.** Neuf appels ImageGen ont produit neuf PNG retenus, sans sortie rejetée ni retouche locale.

| Index | Arène | Référence et portée |
| --- | --- | --- |
| 26 | Place d’A Prelude | Classic HOTD2 gameplay from a guide covering arcade/Wii; exact captured port not established ; une zone adaptée. |
| 27 | Hôpital — Ballistic Trauma | PlayStation 3 guide; Extended Cut / Japanese Director’s Cut ; une zone adaptée. |
| 28 | Usine chimique — Zombie Revenge | Dreamcast according to public longplay author Retronomicon / NVSGamer ; une zone adaptée. |

## Fichiers retenus

| PNG | Plan | Dimensions natives | Mode | Octets |
| --- | --- | --- | --- | ---: |
| [overkill_hospital_back.png](../../../../../assets/dossier_curien/saga/overkill_hospital_back.png) | back | 1672 × 941 | RGB | 2773909 |
| [overkill_hospital_mid.png](../../../../../assets/dossier_curien/saga/overkill_hospital_mid.png) | mid | 1672 × 941 | RGBA | 282999 |
| [overkill_hospital_front.png](../../../../../assets/dossier_curien/saga/overkill_hospital_front.png) | front | 1672 × 941 | RGBA | 90840 |
| [prelude_square_back.png](../../../../../assets/dossier_curien/saga/prelude_square_back.png) | back | 1672 × 941 | RGB | 3201924 |
| [prelude_square_mid.png](../../../../../assets/dossier_curien/saga/prelude_square_mid.png) | mid | 1672 × 941 | RGBA | 342834 |
| [prelude_square_front.png](../../../../../assets/dossier_curien/saga/prelude_square_front.png) | front | 1672 × 941 | RGBA | 87497 |
| [zr_chemical_plant_back.png](../../../../../assets/dossier_curien/saga/zr_chemical_plant_back.png) | back | 1672 × 941 | RGB | 2885222 |
| [zr_chemical_plant_mid.png](../../../../../assets/dossier_curien/saga/zr_chemical_plant_mid.png) | mid | 1672 × 941 | RGBA | 336310 |
| [zr_chemical_plant_front.png](../../../../../assets/dossier_curien/saga/zr_chemical_plant_front.png) | front | 1673 × 940 | RGBA | 93225 |

Total exact : **10094760 octets**, neuf contenus distincts. Les sorties ImageGen sont conservées à octets identiques.

## Références et décisions

### Place d’A Prelude

Les captures de la rue initiale et du combat Judgment montrent les façades ocres, balcons, volets, auvents rouges, lampadaires ouvragés et tour crénelée. Le [guide de chapitre HOTD2](https://www.k-triggerhappy.com/hod2/chapter1.html) couvre arcade/Wii ; le port exact des captures n’est pas établi. La place latérale assemble ces motifs et dégage le pavage pour le combat. Les canaux et autres rues ne sont pas livrés.

### Hôpital — Ballistic Trauma

Le [guide PS3](https://www.k-triggerhappy.com/hodoverkill_ps3/stage3.html) fournit une salle commune au troisième étage et un couloir adjacent. Lits tubulaires, rideaux, murs gris-bleu, carrelage et plafond endommagé sont retenus. Les lits restent en arrière de la bande de combat. La salle circulaire de Screamer et les autres portions de l’hôpital restent à réaliser.

### Usine chimique — Zombie Revenge

Le [longplay public](https://www.youtube.com/watch?v=ne37UXflHqw), attribué à Dreamcast par son auteur, montre le titre **AREA4 CHEMICAL PLANT**. Les deux premières rangées du storyboard 6 donnent cuves, tuyaux, ossature turquoise, plateformes et bandes de danger. Les cellules sources font 320 × 180 ; les neuf vues par feuille sont conservées sans agrandissement ni découpage. Les détails fins et l’espacement latéral restent interprétés. Les extractions vidéo haute définition ont échoué ; aucune image haute définition extraite n’est revendiquée.

Le listing distingue désormais neuf Areas citées par l’auteur. Les titres Areas 2/3/4 sont directement visibles dans les feuilles conservées ; Cassandra est associée à son intérieur par la séquence et le chapitrage, sans titre en jeu retenu. Cette recherche ajoute deux lignes encore manquantes : Edward Street et Cassandra. Les [références locales](../../../sources_art/references-2026-11-20_lot5/stages/source_index.json) et le [chapitrage attribué](../../../sources_art/references-2026-11-20_lot5/stages/zr_longplay_chapters.json) permettent de vérifier cette distinction.

## Transparence et calibration

Le renderer conserve son rectangle `(-38, -14, 1356, 754)`, son sol 601 et ses amplitudes de parallaxe 17/32/58. Les fonds sont RGB opaques ; les six surimpressions sont RGBA. Le centre normalisé `[0.125, 0.20, 0.875, 0.79]` et la bande `[0.125, 0.75, 0.875, 1.0]` ont tous un alpha maximal de 1/255. Les fragments visibles restent sur les côtés ou les coins bas.

Huit plans ont une taille native de 1672 × 941 ; l’avant-plan de l’usine mesure 1673 × 940. Cette variation native est conservée. Chaque plan est dessiné dans le même rectangle du moteur, et ses contrôles alpha utilisent ses dimensions réelles. Aucun PNG n’a été redimensionné ou nettoyé.

## Revue et limites

Les neuf sorties ont été inspectées visuellement par root. Les sources de décor et les feuilles de contexte retenues ont aussi été vues. Les silhouettes de personnages, HUD et textes des captures ne sont pas reproduits. Il s’agit d’adaptations peintes, avec un sol de combat ajouté ou élargi ; aucune fidélité canonique 1:1 ni couverture de chapitre entier n’est certifiée.

Le [manifeste complet](manifest.json) retient prompts, références, dimensions, empreintes et mesures. La [validation intégrée](../catalogue_2026-11-20_lot5/VALIDATION.md) documente les contrôles moteur séparément ; aucune session manuelle ni capture de viewport n’est revendiquée ici.
