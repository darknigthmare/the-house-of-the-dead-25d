# James HOTD4 et G HOTD4 Special — variantes de galerie

Deux bases en pied complètent les apparences par édition de personnages déjà connus. Elles sont destinées au bestiaire de Dossier Curien. Les deux tenues historiques sélectionnables en combat restent inchangées.

Base de comparaison : commit `af0e4933c07b9016a6be552ce874b61007dd7836`. Le reçu complet est dans [costumes_generated.json](costumes_generated.json), avec les prompts exacts, toutes les entrées de référence, les deux étapes de James et les empreintes des images.

| Fiche | PNG natif | Taille | Statut |
|---|---|---:|---|
| James Taylor — HOTD4 | [james_hotd4_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/costumes/james_hotd4_base.png) | 1 766 431 octets | Référence examinée, réserves détaillées ci-dessous |
| Agent G — HOTD4 Special | [g_hotd4special_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/costumes/g_hotd4special_base.png) | 1 638 061 octets | Référence examinée, réserves détaillées ci-dessous |

Les deux fichiers finaux sont des sorties ImageGen natives **RGBA 1024 × 1536**. Ils totalisent **3 404 492 octets**. Trois appels ont produit deux dessins retenus et une première version de James écartée. Le fichier final de chaque image a été copié sans modification de pixels ni réencodage.

## James Taylor — The House of the Dead 4

La page officielle SEGA fournit les deux parties d’une illustration de James : son manteau bleu-gris ouvert sur une chemise noire, puis le pantalon sombre à fines rayures verticales et les chaussures. Un rendu en pied rehébergé par IMFDB complète la pose et la construction de la tenue. Les cheveux courts dressés et les vêtements de cette édition sont conservés.

La première génération avait un avant d’arme trop allongé. Une intervention ciblée ImageGen a simplifié et raccourci le boîtier en s’appuyant sur les rendus de James et de G Special, ainsi que sur une capture de rechargement. La seconde sortie est retenue. La première, conservée comme entrée de provenance dans [james_hotd4_before_weapon_revision.png](../../../sources_art/references-2026-11-20_lot3/costumes/james_hotd4_before_weapon_revision.png), ne compte pas comme fiche de galerie supplémentaire.

La silhouette compacte de l’arme a été revue ; ses petits détails mécaniques et ses dimensions ne sont pas certifiés identiques au modèle du jeu. La pose de garde, les coutures, les reflets et les détails du visage restent une adaptation peinte.

Références inspectées :

- [Illustration SEGA : haut du corps de James, à gauche](../../../sources_art/references-2026-11-20_lot3/costumes/james_hotd4_official_upper.jpg).
- [Illustration SEGA : pantalon et chaussures de James, à gauche](../../../sources_art/references-2026-11-20_lot3/costumes/james_hotd4_official_legs.jpg).
- [Rendu en pied de James rehébergé par IMFDB](../../../sources_art/references-2026-11-20_lot3/costumes/james_hotd4_render_imfdb.jpg).
- [Capture de rechargement pour la silhouette de l’arme](../../../sources_art/references-2026-11-20_lot3/costumes/hotd4_james_reload_imfdb.jpg).

## Agent G — The House of the Dead 4 Special

Le rendu en pied de G montre un costume bleu nuit brillant, une chemise bleue à léger reflet violet, une cravate sombre, des cheveux foncés coiffés en arrière et des chaussures brunes. Le flyer SEGA japonais de 2006 corrobore le visage, le haut de la tenue et l’arme. Le bas du corps et les chaussures viennent du rendu en pied ; ils ne sont pas visibles dans le petit personnage du flyer.

La fiche conserve cette apparence de Special. Elle ne reprend ni le gilet et les cheveux gris de HOTD III, ni la chemise blanche et les lunettes d’Overkill. La pose et les détails fins du visage, de l’arme et du tissu restent interprétés. La précision du dessin ne constitue pas une certification de texture ou de proportions 1:1.

Références inspectées :

- [G Special en pied, rendu rehébergé par IMFDB](../../../sources_art/references-2026-11-20_lot3/costumes/g_hotd4special_render_imfdb.jpg).
- [Flyer japonais SEGA 2006, scan Arcade Museum](../../../sources_art/references-2026-11-20_lot3/costumes/g_hotd4special_sega_flyer.jpg).

## Provenance et contrôles

La [page de personnages SEGA HOTD4](https://hod4.sega.jp/howto_character.html) est la source primaire directe de James. [IMFDB](https://www.imfdb.org/wiki/The_House_of_the_Dead_4) réhéberge les rendus en pied et la capture d’arme ; leur présence sur ce site ne les transforme pas en publication officielle SEGA. Le [flyer Special](https://flyers.arcade-museum.com/videogames/show/5090) est une publication SEGA conservée par Arcade Museum. [isaac_guard.png](../../../../../assets/dossier_curien/saga/isaac_guard.png) sert uniquement de référence de style.

Les dimensions, les SHA-256, la présence d’un canal alpha, les marges visibles et les chemins de référence ont été vérifiés. Les images natives conservent l’alpha 0–254 et ses éventuelles valeurs résiduelles faibles aux bords. Le RGB des pixels transparents peut afficher un dégradé dans certains aperçus ; aucun fond opaque n’a été ajouté.

Les fiches utilisent `gallery: true`, `playable: false`, `animation_complete: false` et `runtime_role: bestiary`. Aucun profil de combat, costume sélectionnable ou animation complète n’est ajouté. La revue des PNG est distincte d’une observation du rendu dans le moteur.

Le validateur d’actifs existant du projet a accepté les deux lignes du reçu. Le contrôle complémentaire des deux reçus comprend 47 assertions ciblées et 20 liens locaux vérifiés. Une seconde revue visuelle indépendante a comparé les quatre PNG aux captures/rendus sources et confirmé leurs silhouettes complètes et leur transparence ; la réserve sur les chaussures de Sophie reste ouverte.
