# Lot 2 — quatre bases humaines pour le bestiaire

**État au 20 novembre 2026 : quatre dessins retenus, quatre PNG natifs, 4 764 872 octets.** Ce volet ajoute Goldman humain, Thornheart, Papa Caesar et Clement Darling à la galerie. Il n’ajoute aucun combattant jouable, costume sélectionnable ou cycle d’animation. Le point de départ est le commit `6291e0d723eb4bc5050ffd3de699f6e55a575642`.

Les quatre silhouettes ont été produites avec l’outil ImageGen intégré, en quatre appels. Chaque sortie retenue a été copiée sans modification des pixels, sans redimensionnement et sans recompression. Les prompts exacts, empreintes, dimensions, limites et références se trouvent dans [humans_generated.json](humans_generated.json). Le registre [sources_humans.json](sources_humans.json) distingue document officiel, capture du jeu réhébergée, miniature vidéo et description textuelle secondaire.

## Livraisons et portée

| Identifiant exact | Jeu | PNG natif | Statut de référence |
|---|---|---|---|
| `goldman_human` | The House of the Dead 2 | [Goldman humain](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/goldman_human_base.png), 1024 × 1536, 1 532 697 octets | Références comparées ; pose debout adaptée depuis des représentations assises. |
| `thornheart` | House of the Dead: Scarlet Dawn | [Thornheart](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/thornheart_base.png), 1254 × 1254, 589 379 octets | Vérification du bas de la tenue encore ouverte. |
| `papa_caesar` | The House of the Dead: Overkill | [Papa Caesar](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/papa_caesar_base.png), 1024 × 1536, 1 947 397 octets | Détails de canne et de chaussures encore à confirmer visuellement. |
| `clement_darling` | The House of the Dead: Overkill | [Clement Darling](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/characters/clement_darling_base.png), 1254 × 1254, 695 399 octets | Vérification du bas de la tenue encore ouverte. |

Le manifeste prépare quatre entrées de catégorie `npc_base`, avec `gallery: true`, `playable: false`, `animation_complete: false` et `runtime_role: bestiary`. Goldman porte le statut machine `static_reference_reviewed`. Les trois autres portent `static_needs_visual_reference_qa`. Ces statuts concernent la couverture documentaire du dessin ; ils ne certifient pas une reproduction 1:1.

## Ce qui est effectivement documenté

### Goldman — forme humaine originale de HOTD 2

Le [manuel Dreamcast de SEGA, page imprimée 4](https://www.digitpress.com/library/manuals/dreamcast/house_dead_2.pdf), montre Goldman assis : costume, pantalon et chaussures sont visibles, mais en monochrome et à petite taille. Une [miniature de vidéo consacrée aux scènes de Goldman](https://www.youtube.com/watch?v=mIG8p0gB2Ew), téléchargée et inspectée, montre son modèle humain original en couleur : cheveux sombres, lunettes légèrement teintées, costume sombre à dominante prune, chemise blanche et cravate ocre. Il s’agit d’une miniature éditorialisée, pas d’un visionnage de la vidéo complète ni d’une capture à un instant mesuré.

Références locales : [détail du manuel](../../../sources_art/references-2026-11-20_lot2/characters/goldman_hotd2_manual_detail.png) et [miniature couleur](../../../sources_art/references-2026-11-20_lot2/characters/goldman_hotd2_game_thumbnail.jpg).

La pose debout et les mains ajustant une manche sont créées pour Dossier Curien. Les détails de couture et la teinte exacte ne sont pas certifiés. La transformation de fin, le modèle de HOTD 4 et celui du remake restent distincts.

### Thornheart — Scarlet Dawn

Le [portrait officiel SEGA du rang S](https://hod.sega.jp/images/result/rank_s_pct.png) a été téléchargé et inspecté. Il documente le visage âgé et creusé, les cheveux rabattus, le costume sombre, la cravate blanche et la pochette rouge. Ce PNG appartient au répertoire public du [site officiel et de son mini-jeu](https://hod.sega.jp/result/054.html) ; la page de résultat ouverte ne correspond pas elle-même au rang S.

Référence locale : [portrait officiel de Thornheart](../../../sources_art/references-2026-11-20_lot2/characters/thornheart_rank_s_official.png).

Le portrait s’arrête au buste. Le pantalon sombre, les chaussures noires, la stature entière et la pose des mains constituent une adaptation sobre. **Une référence plein pied reste nécessaire pour fermer ces points.** Les apparitions du mystérieux homme dans III et 4 ne sont pas assimilées automatiquement à cette tenue Scarlet Dawn.

### Papa Caesar — Overkill

Le [manuel officiel SEGA de The Typing of the Dead: Overkill, page imprimée 20](https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/246580/manuals/TOTDO_STEAM_MANUAL_ENG.PDF?t=1763675367) montre le visage, la barbe, la chemise à poches et le foulard à pois. La [miniature d’une cinématique Wii](https://www.youtube.com/watch?v=7Stu6VTJg6g) permet de voir la longue chemise et le pantalon verts. Une [capture du jeu réhébergée par IMFDB](https://www.imfdb.org/images/a/a3/TOTD-CaesarMagnum.jpg) précise les manches retroussées, bracelets et bague ; visage et jambes y sont hors champ.

Références locales : [portrait du manuel](../../../sources_art/references-2026-11-20_lot2/characters/papa_caesar_official_manual_detail.png), [miniature Wii](../../../sources_art/references-2026-11-20_lot2/characters/papa_caesar_wii_game_thumbnail.jpg) et [détail de la chemise](../../../sources_art/references-2026-11-20_lot2/characters/papa_caesar_green_shirt_game.jpg).

Les mocassins rouges et la canne en bois rouge à poignée beige sont décrits dans l’extrait indexé de la section « Appearance » du [Wiki of the Dead](https://thehouseofthedead.fandom.com/wiki/Papa_Caesar). Cette description est secondaire ; elle ne remplace pas une inspection visuelle. **La coupe des chaussures, les ferrures et la forme exacte de la canne restent ouvertes.** Le téléphone du manuel et le revolver de la capture ne sont pas repris dans cette pose avec canne. Les sources de différentes éditions servent à une base Overkill ; aucune identité visuelle complète entre Wii et Extended Cut n’est affirmée.

### Clement Darling — Overkill

Le [post 2 « CAST » du sujet LP Zone](https://www.lp.zone/t/lets-play-the-typing-of-the-dead-overkill/2448) identifie Clement Darling et fournit une [capture de cinématique](https://i.imgur.com/6me77Rr.jpg). L’image a été téléchargée et inspectée : visage creusé, cheveux bruns rabattus, veste bleue à fines rayures, grand col clair et cravate verte/bleutée rayée. Il s’agit d’un hébergement communautaire d’une image du jeu, pas d’une publication officielle SEGA.

Référence locale : [Clement dans la cinématique](../../../sources_art/references-2026-11-20_lot2/characters/clement_darling_game_lpzone.jpg).

Le cadrage s’arrête au buste et l’éclairage est bleuté. Le pantalon assorti, la continuité de ses rayures, les chaussures sombres et la morphologie entière sont adaptés. **La référence plein pied reste à trouver.** La présence d’une silhouette complète produite ne ferme pas cette vérification de tenue.

## Vérifications effectuées

Les références locales ont été vues avant génération, puis les quatre sorties ont été inspectées. Les têtes, mains et pieds sont entiers ; Papa conserve sa canne complète. La garde d’Isaac existante a servi uniquement à guider la peinture, les contours et la lisibilité du sprite.

Le validateur existant `validate()` de [verify_dossier_curien_expansion.mjs](../../../../../scripts/verify_dossier_curien_expansion.mjs) a accepté ce manifeste avec la racine limitée au dossier `characters`, les trois jeux concernés et la catégorie `npc_base` : **4 PNG, 4 entrées de galerie, 4 764 872 octets**. Il a vérifié les chemins, l’existence des références et reçus, les tailles, SHA-256, données RGBA et boîtes alpha. Un contrôle complémentaire a confirmé les quatre identifiants attendus et leurs indicateurs de galerie non jouable. Les empreintes des copies finales concordent également avec celles des sorties natives.

Goldman et Papa ont un alpha natif allant de 0 à 254 ; Thornheart et Clement de 0 à 255. Ces valeurs sont conservées telles quelles. Les boîtes visibles au seuil alpha > 127 restent à l’intérieur du canevas. Des couleurs RGB peuvent subsister dans les pixels transparents d’un PNG ; l’aperçu de ces couleurs ne constitue pas un fond opaque à supprimer.

| Identifiant | SHA-256 du PNG retenu |
|---|---|
| `goldman_human` | `9e0bce590c78813dd2ab0bc6d95077cc8ab2c3aa70ce9dd1700b31d37e4a9058` |
| `thornheart` | `f8e3a0256e788d43eef25c5ca67064ebe77d95fe4aca4184766818e8cf670693` |
| `papa_caesar` | `d123a603c6ddd6c9372cd4b88887c29ac022ecc65db04e5e25bb5c439a6df30c` |
| `clement_darling` | `5c62a633d582a01c1e09c65ad3e6659a9c70fdbb11311f81c511916a8b0901df` |

Ce contrôle porte sur les fichiers et leur documentation. Aucune capture moteur ou revue de l’interface native n’a été réalisée pour ce volet. La fusion du manifeste runtime, ses tests d’intégration et la publication appartiennent au lot global. **Aucune des 277 poses manquantes du suivi précédent n’est soustraite par ces quatre bases.**
