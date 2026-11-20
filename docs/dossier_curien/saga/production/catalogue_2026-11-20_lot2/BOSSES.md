# Boss — lot 2 du 20 novembre 2026

Le lot contient **six PNG natifs RGBA**, une image par entrée de bestiaire, pour **cinq rencontres** : Judgment est représenté par ses deux partenaires séparés, Zeal et Kuarl ; Tower conserve ses cinq serpents dans une seule composition. Strength, Fool et Sun complètent le lot. Les six silhouettes sont retenues après inspection des références et des sorties. Le premier essai de Strength a reçu une correction ciblée.

Les fichiers sont prêts pour la galerie statique Dossier Curien. Ils restent déclarés `gallery: true`, `playable: false`, `animation_complete: false` et `runtime_role: bestiary`. Les images ne constituent pas des cycles de combat ni de nouveaux combattants jouables.

## Reçu des actifs

Les six images mesurent **1254 × 1254 pixels**, dimensions natives réellement produites. Le carré demandé dans les prompts était de 1024 × 1024 ; aucune mise à l’échelle n’a été appliquée au résultat. Volume total exact : **8 361 989 octets**.

| ID | Jeu | PNG accepté | Octets | SHA-256, préfixe |
|---|---|---|---:|---|
| `zeal` | HOTD2 | [zeal_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/zeal_base.png) | 1 040 063 | `f9fb19f51b21e942…` |
| `kuarl` | HOTD2 | [kuarl_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/kuarl_base.png) | 1 483 738 | `e0fb0f39cb9127bc…` |
| `tower` | HOTD2 | [tower_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/tower_base.png) | 1 456 044 | `8c1efb17fc2d2bbe…` |
| `strength` | HOTD2 | [strength_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/strength_base.png) | 1 251 730 | `34941067d2152ee4…` |
| `fool` | HOTDIII | [fool_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/fool_base.png) | 1 348 742 | `218d0c7fed5c5f5f…` |
| `sun` | HOTDIII | [sun_base.png](../../../../../assets/dossier_curien/gallery_2026-11-20_lot2/bosses/sun_base.png) | 1 781 672 | `6303bce979aa2f21…` |

Les empreintes complètes, données alpha, boîtes visibles, prompts exacts et étapes de génération sont dans [bosses_generated.json](bosses_generated.json). Chaque fichier conserve exactement les octets de la sortie native sélectionnée. Aucun recadrage, redimensionnement, détourage manuel ni recalcul de transparence n’a été effectué.

## Références et choix de représentation

La source principale est le [site officiel SEGA/Sonic Team de The House of the Dead 2 & 3 Return](https://www.sonicteam.com/HOD2and3RETURN/jp/). Ses fiches distinguent les boss et fournissent des visuels publiés par SEGA. Les images téléchargées sont conservées intactes ; leurs URL de page, URL de média, dimensions, tailles et empreintes figurent dans [source_index.json](../../../../../docs/dossier_curien/sources_art/references-2026-11-20_lot2/bosses/source_index.json).

Les vues officielles sont petites : 260 × 347 ou 260 × 195 pixels. Elles permettent de comparer les grandes formes, les couleurs et les accessoires. Le détail fin du rendu peint et les poses de galerie constituent une adaptation. Pour Fool et Sun, deux modèles présentés sur des wikis communautaires complètent la lecture des proportions et des extrémités ; ils sont identifiés comme sources secondaires et recoupés visuellement avec les publications SEGA. Les sources des remakes récents ne servent pas de référence à ce lot.

### Zeal et Kuarl : deux figures, une rencontre

La [fiche officielle Judgment](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/judgment_1.html) présente explicitement l’association du petit démon volant et du géant sans tête. Le même visuel source a servi à les distinguer, puis à générer une figure isolée de chacun.

**Zeal** conserve son visage pâle, ses oreilles pointues, ses tons rouges, ses protections à pointes et ses ailes membraneuses. La sortie montre une tête, deux bras, deux jambes et deux ailes séparées des bras. Les mains, les pieds et les pointes des ailes sont visibles. Sa position de vol est composée pour la galerie.

**Kuarl** conserve le cou vide, l’armure grise à pointes, les jambes bandées, les pieds nus et la grande hache. Deux mains saisissent le même manche ; aucune tête ou silhouette de Zeal n’a été ajoutée. La posture et l’angle de l’arme sont adaptés au cadre.

Les deux entrées portent `encounter_id: judgment` et un `companion_id` réciproque. Leur taille dans deux PNG indépendants ne fixe pas une échelle relative de combat.

### Tower : conserver les cinq serpents

La [fiche officielle Tower](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/tower.html) distingue quatre cous bruns et le meneur bleu. Le visuel retenu présente **cinq têtes distinctes**, quatre bronze et une bleu-vert, dans une composition unique. Les corps sont segmentés, les bouches dentées et violettes ; la crête appartient au meneur bleu. Aucun œil, membre ou torse de dragon commun n’a été ajouté.

Les cous, les enroulements et les queues sont composés pour garder les cinq silhouettes lisibles. Les têtes s’orientent en éventail, comme le permet une fiche de galerie. Cet agencement ne définit pas une nouvelle phase de combat et ne représente pas cinq entrées de bestiaire indépendantes.

### Strength : costume, arme et correction de côté

La [fiche officielle Strength](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/strength.html) montre le géant masqué avec sa tronçonneuse et ses haches. Le [contrôle descriptif secondaire](https://thehouseofthedead.fandom.com/wiki/Strength) précise la répartition des deux petites haches : épaule droite et cuisse gauche.

La figure retenue conserve le masque bleu, le corps massif gris pâle, les pièces bleues à l’abdomen et au short, les mains bandées et les pieds nus. Les deux mains tiennent deux poignées distinctes de la tronçonneuse orange ; la chaîne et le marquage `BLAME` sont visibles.

Le premier essai plaçait la hache de cuisse à droite. Une édition ImageGen a déplacé cette petite hache vers la cuisse anatomique gauche, en conservant la hache d’épaule droite, la posture et la prise de l’arme. La sortie corrigée est le PNG actif.

### Fool : anatomie de paresseux et quatre pattes lisibles

La [fiche officielle Fool](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type0028_fool_1.html) identifie un monstre de type paresseux et ses quatre extrémités. Le [modèle secondaire inspecté](https://mzh.moegirl.org.cn/Fool) complète la lecture du torse rond et des longues pattes.

La silhouette possède un corps couvert de fourrure gris sombre, un visage pâle, quatre pattes orangées et **trois griffes par patte**. Les griffes avant sont plus longues que les griffes arrière. Les quatre extrémités sont séparées visuellement. La pose suspendue est librement adaptée ; la cage et les autres éléments de son arène ne font pas partie du sprite.

### Sun : une silhouette complète pour un boss environnemental

La [fiche officielle Sun](https://www.sonicteam.com/HOD2and3RETURN/jp/2008/02/type8830_sun.html) montre le tronc couvert de visages, les fleurs, les vrilles et les racines. Le [modèle secondaire inspecté](https://thehouseofthedead.fandom.com/wiki/Sun) sert à compléter la lecture du pied et du tronc.

Le PNG retenu conserve le tronc moussu, la bande de visages, les trois bourgeons rouge et vert, la couronne de vrilles rayées et trois appendices Sunsun. Une fleur est ouverte ; les deux autres restent partiellement fermées. Le troisième appendice Sunsun passe en partie derrière le tronc. Les racines, pétales, branches et extrémités des vrilles restent dans le cadre.

**Le sommet et l’étendue des racines sont adaptés au cadrage.** Les références ne montrent pas simultanément toute l’étendue de cet organisme environnemental. Le dessin donne donc une terminaison visible aux branches et rassemble ses appendices dans un carré. Il ne certifie ni l’étendue complète du modèle d’origine, ni une fidélité 1:1.

## Contrôles effectués

- Inspection des images de référence avant génération ; les fichiers sources restent intacts.
- Inspection des sept sorties ImageGen : six retenues, une remplacée.
- Six empreintes SHA-256 différentes et comparaison des octets avec les sorties natives sélectionnées.
- Six PNG RGBA, avec alpha minimal 0 et maximal 255.
- Zéro pixel d’alpha supérieur à 127 sur les quatre bords de chaque image ; toutes les silhouettes visibles sont contenues dans le cadre.
- Contrôle des points d’identité décrits ci-dessus : membres de Zeal, absence de tête de Kuarl, cinq têtes de Tower, deux haches de Strength aux bons côtés, quatre pattes de Fool et structures principales de Sun.
- Contrôle des chemins de références, des empreintes de prompts et des liens locaux de ce rapport.

Les boîtes visibles utilisent le seuil `alpha > 127`. Des pixels de faible alpha subsistent dans les sorties natives ; ils n’ont pas été modifiés. Les marges réellement obtenues sont enregistrées dans le manifeste et ne sont pas présentées comme une marge uniforme de 7 %, même si celle-ci figurait dans les demandes de cadrage.

Ce reçu porte sur les PNG et leur provenance. L’intégration de galerie et ses essais Godot sont suivis par le reçu général du lot. Aucune nouvelle capture en moteur n’a été réalisée pour ce rapport d’images.

## Essai remplacé et conservation

Le premier Strength est identifié par le nom natif `exec-72341c49-5a5e-4069-9923-9322630a7f02.png` et par le SHA-256 `6329a9e6c40f689cf55b2d51835e825d35e0b4fffdeac637c9f108f6d4735131`. Son prompt, ses références, le motif du rejet et le fichier de remplacement figurent dans `rejected_generations` du manifeste.

Le binaire rejeté reste uniquement dans les sorties natives hors dépôt. Il n’entre ni dans les six PNG retenus, ni dans le volume de 8 361 989 octets. Le dossier du lot ne contient aucun PNG rejeté.

## Portée finale

Le lot est limité à ces six illustrations statiques et à leur documentation. Les noms et rapports de rencontre sont conservés ; les poses, la peinture, les enroulements et les limites de cadrage sont adaptés au Dossier Curien. Aucun cycle intermédiaire, attaque, réaction, collision ou comportement ennemi supplémentaire n’est livré par ces images. La fidélité canonique 1:1 reste non certifiée.
