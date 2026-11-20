# Sophie Richards et Dr. Curien — adaptations HOTD1

Deux silhouettes en pied sont ajoutées à la galerie de Dossier Curien. Elles reprennent des identités déjà présentes dans les ressources historiques du projet. Les anciens masters restent intacts ; leurs détails ont été comparés aux images du jeu avant de produire ces nouvelles bases.

Base de comparaison : commit `af0e4933c07b9016a6be552ce874b61007dd7836`. Le reçu complet, les prompts exacts, leurs empreintes, les références utilisées et les mesures PNG sont dans [humans_generated.json](humans_generated.json).

| Fiche | PNG natif | Taille | Statut |
|---|---|---:|---|
| Sophie Richards — HOTD1 | [sophie_richards_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/characters/sophie_richards_base.png) | 1 574 153 octets | Vérification visuelle encore ouverte sur les chaussures et les bas |
| Dr. Curien — HOTD1 | [dr_curien_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot3/characters/dr_curien_base.png) | 1 808 892 octets | Référence examinée, réserves détaillées ci-dessous |

Les deux images sont des sorties ImageGen natives **RGBA 1024 × 1536**, avec un alpha allant de 0 à 254. Elles totalisent **3 383 045 octets**. Deux appels ont produit deux dessins retenus, sans retouche de pixels, détourage ou redimensionnement après génération. Les contours visibles ne touchent pas les bords ; les très faibles valeurs d’alpha résiduelles sont conservées telles quelles.

## Sophie Richards

Les captures de la version arcade montrent un tailleur rouge sombre, une chemise blanche à grand col ouvert, un badge DBR à la poitrine et des cheveux blonds courts. L’illustration du manuel SEGA, page imprimée 16, confirme ces éléments de silhouette. La fiche présente Sophie vivante, debout et sans arme.

La capture où Hangedman la porte permet de voir les jambes et les chaussures, mais à petite échelle. **La teinte et la finition des chaussures, ainsi que le rendu exact des bas, restent en vérification visuelle ouverte.** Le dessin choisit des chaussures fermées à talon, de teinte sombre bordeaux-brun. Les coutures et le mécanisme d’accroche du petit badge restent interprétés.

L’ancien master `assets/sprites/heroes/sophie-hotd.png` a été examiné comme contexte historique. Sa pochette médicale, son extincteur et sa coiffure plus longue ne sont pas des preuves de l’apparence originale ; ils n’ont pas été transférés à cette fiche. La tâche du modèle alternatif Saturn conserve sa portée distincte.

Références inspectées :

- [Sophie dans la cinématique de la fontaine](../../../sources_art/references-2026-11-20_lot3/characters/sophie_standing_arcade_hackernoon.png) : couleur du tailleur, coupe des cheveux et placement du badge.
- [Sophie portée par Hangedman](../../../sources_art/references-2026-11-20_lot3/characters/sophie_carried_arcade_hackernoon.png) : silhouette, longueur de jupe et forme générale des chaussures.
- [Extrait du manuel SEGA, page 16](../../../sources_art/references-2026-11-20_lot3/characters/sophie_hotd1_manual_p16_detail.png) : coiffure, blouse et costume en monochrome.

## Dr. Curien

La capture arcade en pied montre un long manteau taupe/beige ouvert sur un gilet clair, un pantalon beige, des chaussures sombres, de petites lunettes teintées et une canne rosée. Le portrait du manuel SEGA, page imprimée 17, complète les traits du visage et la tenue formelle. La nouvelle base reprend les mains posées sur la canne, dans une orientation adaptée à la galerie.

Le master historique `assets/sprites/npcs/dr-curien.png` est sombre et plus grisonnant. Il est conservé, mais la nouvelle fiche suit les couleurs de la capture arcade. Le monochrome du manuel n’a pas servi à déduire une palette noire.

Les petits éléments de couture, les boutons, la moustache, les lunettes et les embouts de canne restent interprétés. La nuance rosée du bâton vient du rendu en jeu ; son matériau et sa couleur hors de cet éclairage ne sont pas certifiés. L’article hébergeant la capture appelle Curien « Roy » : ce prénom n’est pas repris dans le projet.

Références inspectées :

- [Curien en pied dans la version arcade](../../../sources_art/references-2026-11-20_lot3/characters/curien_original_hackernoon.png) : silhouette entière, tenue, lunettes et canne.
- [Extrait du manuel SEGA, page 17](../../../sources_art/references-2026-11-20_lot3/characters/curien_hotd1_manual_p17_detail.png) : visage et vêtements formels en monochrome.

## Provenance et portée

Les captures viennent de [l’article consacré à la version arcade Model 2](https://hackernoon.com/the-house-of-the-dead-walkthrough-and-review-arcade-sega-model-2) ; il s’agit de publications communautaires montrant le jeu. Les illustrations du [manuel SEGA Saturn](https://oldgamesdownload.com/wp-content/uploads/manuals/the-house-of-the-dead_saturn_manual_en_b2o.pdf) sont réhébergées par Old Games Download. Seuls les extraits utiles sont conservés ici, avec les coordonnées de découpe du PDF, l’index des pages et l’empreinte du document source dans le reçu. Le style peint vient de [isaac_guard.png](../../../../../assets/dossier_curien/saga/isaac_guard.png).

Les quatre drapeaux d’intégration sont explicites : `gallery: true`, `playable: false`, `animation_complete: false`, `runtime_role: bestiary`. Ces deux fiches ne créent aucun combattant jouable ni costume sélectionnable. Ce sont des adaptations picturales contrôlées sur les éléments visibles ; elles ne certifient pas une reproduction 1:1 et ne ferment aucune série d’animations.

## Contrôles effectués

Les fichiers copiés correspondent octet pour octet aux sorties natives. Les dimensions, l’alpha, les marges visibles, les références locales et les SHA-256 ont été contrôlés. Chaque silhouette complète a été inspectée visuellement. Cette revue ne constitue pas une capture du jeu Dossier Curien en fonctionnement.

Le validateur d’actifs existant du projet a accepté les deux lignes du reçu. Le contrôle complémentaire des deux reçus comprend 47 assertions ciblées et 20 liens locaux vérifiés. Une seconde revue visuelle indépendante a comparé les quatre PNG aux captures/rendus sources et confirmé leurs silhouettes complètes et leur transparence ; la réserve sur les chaussures de Sophie reste ouverte.
