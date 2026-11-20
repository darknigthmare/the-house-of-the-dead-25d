# Boss — lot 3 du 20 novembre 2026

## Livraison

Ce lot ajoute **quatre bases statiques de bestiaire**, chacune dans un PNG transparent distinct : High Priestess, Screamer, Crawler et Brutus. Les quatre fichiers retenus totalisent **4 800 390 octets**. Ils sont tous en **RGBA natif, 1 254 × 1 254 pixels**, conservés sans redimensionnement, recadrage, détourage ou recalcul d’alpha après leur sortie d’ImageGen.

Le [manifeste de production](bosses_generated.json) contient les prompts complets, leurs empreintes SHA-256, les références réellement fournies, les étapes de génération, les dimensions, les bornes alpha, les contrôles visuels et les limites par créature. L’[inventaire des sources](../../../sources_art/references-2026-11-20_lot3/bosses/source_index.json) décrit les quinze images de référence, leur URL, leur édition, leur rôle et leur empreinte.

| ID / jeu | Fichier retenu | Octets | État du livrable |
|---|---|---:|---|
| `high_priestess` / `scarlet_dawn` | [high_priestess_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/high_priestess_base.png) | 1 548 040 | Base entière examinée ; source officielle directe |
| `crawler` / `overkill` | [crawler_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/crawler_base.png) | 902 072 | Base entière examinée ; captures PS3 |
| `screamer` / `overkill` | [screamer_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/screamer_base.png) | 1 076 211 | Base entière examinée ; captures PS3 et art Wii complémentaire |
| `brutus` / `overkill` | [brutus_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/bosses/brutus_base.png) | 1 274 067 | Base entière corrigée et examinée ; captures PS3 |

Le statut commun est `static_reference_reviewed`, avec `category: boss_base`, `gallery: true`, `playable: false`, `animation_complete: false` et `runtime_role: bestiary`. Ces quatre images représentent quatre rencontres. Elles n’ajoutent aucun combattant jouable et ne ferment aucun cycle d’animation, moveset ou variante d’édition.

## Références examinées et niveau de preuve

### High Priestess — Scarlet Dawn

La source principale est la [galerie officielle SEGA de Scarlet Dawn](https://hod.sega.jp/). Son [rendu entier](https://hod.sega.jp/images/top/chara_creature_img_uncompress//highpriestess.png), son [détail du visage](https://hod.sega.jp/images/top/chara_creature_bg/highpriestess_b.png) et sa [vue en situation](https://hod.sega.jp/images/top/chara_creature_bg/highpriestess_a.jpg) sont conservés dans le dossier des références. Les deux premiers fichiers ont été fournis à ImageGen ; le troisième sert de rapprochement visuel.

La base reprend la présentation frontale, le manteau céphalopode bleu-gris, les plis pâles, les deux yeux orange, la bouche verticale bordée de dents en forme de bec et **huit tentacules reliés à huit palettes dentées distinctes**. Le contour blanc du rendu promotionnel n’a pas été repris. Une revue indépendante de root a confirmé le nombre d’extrémités, la continuité des tentacules, la silhouette entière et la concordance générale avec le rendu SEGA.

L’[article CGWORLD consacré au développement de Scarlet Dawn](https://cgworld.jp/feature/201810-cgw243-hod.html) documente le contexte de production ; les concepts de dégâts ou de peau retirée qu’il présente ne sont pas utilisés comme modèle livré. Aucun numéro de type n’a été inventé. Le rendu entier officiel donne ici un niveau de preuve supérieur à celui des captures sombres d’Overkill, sans établir une reproduction pixel à pixel.

### Crawler — Overkill / Extended Cut

Les [captures de Scream Train sur PS3](https://www.k-triggerhappy.com/hodoverkill_ps3/stage6.html), hébergées par le guide k-triggerhappy, montrent le torse humain aminci, la tête de mante et ses yeux saillants, les deux bras terminés en longues faux organiques et les deux longues jambes articulées. Trois vues sont utilisées directement ; une quatrième vue aérienne a été examinée pour la silhouette.

La sortie contient une seule tête, deux bras-faux et deux jambes, entièrement visibles. Le cadrage statique dégage les articulations. Le train, les flammes, les cibles et les éléments d’interface sont absents. La pose et certains volumes de pieds sont reconstruits pour la galerie : les captures ne permettent pas de certifier chaque segment, chaque orteil ou le dos. La vue est presque frontale, la tête tournée vers la gauche ; aucune orientation de combat n’est déclarée.

### Screamer — Overkill / Extended Cut, complément Wii

Les [captures de Ballistic Trauma sur PS3](https://www.k-triggerhappy.com/hodoverkill_ps3/stage3.html) montrent la silhouette voûtée, les longs cheveux sombres, la bouche ouverte, les bras tendus et la blouse. Deux de ces captures servent à la génération. La première, surexposée par un effet de jeu, a été examinée puis écartée des entrées de génération.

Une [capture du menu d’art de la version Wii conservée par MobyGames](https://www.mobygames.com/game/40939/the-house-of-the-dead-overkill/screenshots/wii/496620/) complète la vue entière, notamment la blouse et les pieds nus. Son rôle et son édition sont explicitement séparés des références PS3. Il s’agit d’un petit artwork au sein d’un menu ; il ne prouve pas l’identité de tous les détails entre les deux éditions.

La sortie représente une seule créature adulte, avec une forte voûte dorsale, deux mains séparées et deux pieds nus. Les apparitions multiples, les autres mutants, l’eau et les effets de cri sont exclus. La microtexture, les plis du vêtement, la structure du dos cachée et la forme précise des pieds restent des adaptations graphiques.

### Brutus — Overkill / Extended Cut

Les [captures de Jailhouse Judgment sur PS3](https://www.k-triggerhappy.com/hodoverkill_ps3/stage8.html) servent au rapprochement de face, de dos et de silhouette : corps massif, cagoule sombre, torse tatoué, pantalon de prison, matériel électrique et bottes.

La latéralité est contrôlée : le lanceur remplace **l’avant-bras anatomique droit**, situé à gauche de l’image retenue ; le bras anatomique gauche conserve une main humaine. La batterie dorsale et les éléments de ceinture sont visibles dans la composition. Le détail des tatouages, les inscriptions de poitrine et la topologie exacte de l’appareil restent insuffisamment définis par les captures pour une certification 1:1.

## Production et correction

Le lot a nécessité **cinq appels au générateur intégré** : quatre générations initiales et une édition ciblée de Brutus. Un fichier a été rejeté. Aucun appel CLI, dessin par code, montage de silhouettes ou transformation des pixels par script n’a été utilisé.

La première sortie de Brutus avait transformé le réticule concentrique visible dans une capture de jeu en tatouage sur le ventre. Cette contamination de l’interface a motivé le rejet. L’édition a retiré le motif et conservé l’arme à droite, la main gauche, la cagoule, les vêtements et les équipements. Le PNG corrigé natif constitue l’unique actif Brutus de ce lot.

Le rejet `exec-bf9795a3-e919-416a-bac4-04598ad77fae.png` demeure hors dépôt, dans les sorties natives de travail. Son SHA-256 est `9f635354f2d64feadbb64f223cf7d57caefa25fa19d4fced2fd75f71bd2ad7b8`. Le manifeste conserve son prompt, son motif de rejet, sa taille, ses références et le lien vers le résultat retenu. Il n’est compté ni comme actif ni comme fiche.

Le [sprite Isaac existant](../../../../../assets/dossier_curien/saga/isaac_guard.png) a servi uniquement de référence de rendu Dossier Curien : modelé peint, lisibilité des contours et traitement des matières. Il ne constitue pas une source d’anatomie, de costume ou d’accessoires pour ces boss.

## Vérifications techniques et portée

Les empreintes des quatre actifs ont été recalculées après installation dans le projet et comparées aux sorties natives. Les références ont également été recomptées et vérifiées : **15 images, 1 198 170 octets**, dont 3 visuels officiels SEGA et 12 captures hébergées par des tiers. Onze images d’identité distinctes ont été fournies au générateur, auxquelles s’ajoute le sprite de style.

| Actif | SHA-256 du PNG retenu |
|---|---|
| High Priestess | `4d7cddf4ba5d354bdd29093d3e700bf5c2946329822731b1f9382beeb7775caa` |
| Crawler | `ea197204f588b5cad38992fd4ba8c281964a0d72af3262198f413c6fbc3c5d38` |
| Screamer | `0068cb065b171e5ecd83db2f64115b77730f18be4b26ebb5cc5c69a6f170e033` |
| Brutus | `be58dc0fe9847b94ad6d3de7bd5c9764ba7950fb7f48404c432d3a347b1fd967` |

Chaque PNG possède un alpha allant de 0 à 255 et **aucun pixel du sujet avec alpha supérieur à 127 sur les quatre bords du canevas**. Les bornes visibles enregistrées utilisent ce même seuil. Des valeurs alpha très faibles peuvent atteindre les marges et produire de fines franges colorées dans certaines prévisualisations ; elles appartiennent à la sortie native et ont été conservées. Pour High Priestess, la vérification indépendante des franges bleues et rouges a mesuré des alpha de 1 à 4, sans pixel coloré examiné dépassant 127.

Ce reçu couvre les images et leur provenance. Il ne prétend pas à une capture native du moteur, à une validation de gameplay ni à une animation complète ; l’intégration et les tests de la galerie relèvent du reçu de validation général du lot. La demande de fidélité guide les formes, proportions et accessoires visibles, mais **la fidélité canonique 1:1 n’est certifiée pour aucun de ces quatre PNG**. Les différences de pose, le rendu peint et les détails insuffisamment résolus par les sources sont conservés comme limites explicites.
