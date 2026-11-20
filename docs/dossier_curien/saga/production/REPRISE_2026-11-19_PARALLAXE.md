# Complément de production — marches et parallaxe du 19 novembre 2026

## Contenu de cette reprise

Ce complément apporte **28 PNG individuels** au mode **Dossier Curien — Anthologie de combat** : **8 poses de marche, 16 calques de parallaxe, 2 objets de décor et 2 pièces séparées pour Lisa**. Il s’ajoute au [premier lot du 19 novembre, composé de 22 PNG](REPRISE_2026-11-19.md), retrouvé dans la tête GitHub `1586e4c`. **Les deux lots réunissent 50 images supplémentaires depuis le volume IV**, sans doublon entre eux. Les marches, calques et objets de décor disposent d’un branchement dans le rendu. Le fusil et les lunettes de Lisa sont enregistrés comme sources séparées pour un futur assemblage.

Le premier examen portait sur `a3fbcf13455a945ccc929ce43907a9755d82e6c7`. Le rapprochement avec la tête distante plus récente `1586e4c` de la branche `feat/dossier-curien-combat`, associée à la PR nº 2, a confirmé la présence des 22 images du lot précédent. Les décomptes ci-dessous utilisent donc cette base actualisée et portent sur les PNG du Dossier Curien, sous-dossiers compris.

| Indicateur | Avant cette reprise | Après cette reprise |
|---|---:|---:|
| PNG du Dossier Curien | 225 | **253** |
| Dont PNG dans `assets/dossier_curien/saga/` | 195 | **223** |
| PNG du dossier initial, hors Saga | 30 | 30 |
| Combattants du roster | 23 | 23 |
| Arènes disponibles | 18 | 18 |
| Combattants avec deux appuis de marche en tenue de base | 3 | **6** |
| Arènes Saga avec arrière-plan, plan intermédiaire et premier plan en PNG | 7 sur 15 | **15 sur 15** |
| Combattants avec une pose `recovery` dédiée | 4 sur 23 | 4 sur 23 |

Les six combattants disposant désormais de deux appuis sont **Kate Green, James Taylor, Lisa Rogan, Ryan Taylor, Gary Stewart et Daniel Curien**. Kate et Ryan disposent également des appuis de leur tenue de réception ; ces variantes ne constituent pas des combattants supplémentaires. Les quatre personnages avec une récupération peinte sont **Rogan, Agent G, Magician et Chariot**. Le roster et les terrains sont définis dans [combatant.gd](../../../../src/dossier_curien/combatant.gd) et [saga.gd](../../../../src/dossier_curien/saga.gd).

### Premier lot conservé dans l’ensemble livré

Les douze poses de combat de Rogan, G et Magician, les quatre appuis de Kate dans ses deux tenues, les trois accessoires de Venise et les trois plans de la **Rue dévastée de Despair** restent présents. Le [bilan initial](REPRISE_2026-11-19.md) et ses six rapports documentent ces 22 images. Le complément décrit ici ajoute ses 28 fichiers à cet ensemble ; l’arène Despair demeure accessible dans le sélecteur libre des 18 terrains.

## Huit poses de marche

Chaque PNG contient un personnage entier, orienté vers la droite, sur fond transparent. Les gardes déjà présentes servent de références pour le visage, la tenue, l’arme et le style. Pour Ryan en tenue de réception, l’illustration officielle de *Scarlet Dawn* complète la référence du projet ; sa provenance figure dans le rapport Ryan.

| Personnage et tenue | Premier appui | Appui opposé | Rapport de production |
|---|---|---|---|
| James Taylor | [james_walk1.png](../../../../assets/dossier_curien/saga/james_walk1.png) | [james_walk2.png](../../../../assets/dossier_curien/saga/james_walk2.png) | [James et Lisa](2026-11-19_james_lisa_walk.json) |
| Lisa Rogan | [lisa_walk1.png](../../../../assets/dossier_curien/saga/lisa_walk1.png) | [lisa_walk2.png](../../../../assets/dossier_curien/saga/lisa_walk2.png) | [James et Lisa](2026-11-19_james_lisa_walk.json) |
| Ryan, tenue de base du projet | [ryan_walk1.png](../../../../assets/dossier_curien/saga/ryan_walk1.png) | [ryan_walk2.png](../../../../assets/dossier_curien/saga/ryan_walk2.png) | [Ryan et ses deux tenues](2026-11-19_ryan_walk.json) |
| Ryan, réception du manoir | [ryan_soiree_walk1.png](../../../../assets/dossier_curien/saga/ryan_soiree_walk1.png) | [ryan_soiree_walk2.png](../../../../assets/dossier_curien/saga/ryan_soiree_walk2.png) | [Ryan et ses deux tenues](2026-11-19_ryan_walk.json) |

### Deux appuis réellement différents

Les versions finales distinguent la jambe proche et la jambe éloignée : l’une mène le premier pas, l’autre mène le suivant. Pour Ryan, les premières propositions `walk2` conservaient trop l’ordre de recouvrement de `walk1`. Elles ont été écartées, puis redessinées par une correction ciblée des jambes. Le [rapport Ryan](2026-11-19_ryan_walk.json) conserve les prompts de correction et l’identification des variantes rejetées. **Seules les quatre images Ryan retenues entrent dans le décompte du lot.**

Ces dessins forment une première marche à deux appuis. Le cycle du moteur intercale la garde : `walk1 → guard → walk2 → guard`, à raison de six tics par phase. La séquence dure donc 24 tics, soit 0,4 seconde à 60 Hz. L’ordre s’inverse pendant le recul et les appuis au sol cessent d’être sélectionnés en l’air. La sélection dépend désormais de la présence des deux fichiers pour la tenue courante, dans [presentation.gd](../../../../src/dossier_curien/presentation.gd).

**Ce cycle reste à enrichir** : les passages de jambe, les variations de hauteur, les départs et arrêts et des transitions intermédiaires propres à chaque personnage ne sont pas tous dessinés. Deux appuis ne constituent pas une animation complète et fluide image par image.

### Résolution native et points d’appui

Les huit nouvelles marches mesurent **1 254 × 1 254 pixels en RGBA**. Les sorties natives ont été conservées sans rééchantillonnage. Le rendu applique leur échelle et leur pivot à partir de [dossier_curien_additions.json](../../../../data/assets/dossier_curien_additions.json).

Le pivot horizontal vaut 0,5, soit x = 627 sur ces canevas. La hauteur du point d’appui est mesurée sur la silhouette dont l’alpha atteint au moins 128, afin que des pixels presque transparents ne déplacent pas artificiellement la ligne de sol.

| Pose | Ligne de pied retenue par le rendu | Pivot vertical normalisé |
|---|---:|---:|
| `james_walk1` | 1 171 | 0,933811802 |
| `james_walk2` | 1 164 | 0,928229665 |
| `lisa_walk1` | 1 170 | 0,933014354 |
| `lisa_walk2` | 1 156 | 0,921850080 |
| `ryan_walk1` | 1 179 | 0,940191388 |
| `ryan_walk2` | 1 176 | 0,937799043 |
| `ryan_soiree_walk1` | 1 178 | 0,939393939 |
| `ryan_soiree_walk2` | 1 176 | 0,937799043 |

Le manifeste retient la dernière ligne visible du pied. Certaines boîtes de silhouette consignées dans les rapports utilisent une borne inférieure exclusive, supérieure d’un pixel : les paramètres consommés par le rendu font foi pour l’ancrage.

La fraction de hauteur de référence reste `905 / 1024`, afin de raccorder les nouveaux canevas aux gardes existantes. Les métadonnées par pose évitent d’imposer aux images natives le pivot en pixels d’un ancien canevas de 1 024 pixels. [Source : manifeste des ajouts](../../../../data/assets/dossier_curien_additions.json) et [calcul du rendu](../../../../src/dossier_curien/presentation.gd).

## Seize calques pour huit arènes

Chaque arène ci-dessous reçoit un plan intermédiaire `_mid` et un premier plan `_front`. Les arrière-plans existants fournissent les références de palette, matière, perspective et éclairage. Les nouvelles images placent les détails sur les bords et dans les coins pour préserver la lecture des combattants.

| Arène | Nouveaux calques | Rapport |
|---|---|---|
| Quai de la cité inondée | [venice_mid.png](../../../../assets/dossier_curien/saga/venice_mid.png), [venice_front.png](../../../../assets/dossier_curien/saga/venice_front.png) | [Venise et Scarlet](2026-11-19_parallax_venice_scarlet.json) |
| Poste de sécurité EFI | [efi_mid.png](../../../../assets/dossier_curien/saga/efi_mid.png), [efi_front.png](../../../../assets/dossier_curien/saga/efi_front.png) | [EFI et métro](2026-11-19_parallax.json) |
| Métro souterrain | [subway_mid.png](../../../../assets/dossier_curien/saga/subway_mid.png), [subway_front.png](../../../../assets/dossier_curien/saga/subway_front.png) | [EFI et métro](2026-11-19_parallax.json) |
| Complexe déserté de 4 Special | [special_mid.png](../../../../assets/dossier_curien/saga/special_mid.png), [special_front.png](../../../../assets/dossier_curien/saga/special_front.png) | [Special et fête foraine](2026-11-19_parallax_special_carnival.json) |
| Réception de Scarecrow Mansion | [scarlet_mid.png](../../../../assets/dossier_curien/saga/scarlet_mid.png), [scarlet_front.png](../../../../assets/dossier_curien/saga/scarlet_front.png) | [Venise et Scarlet](2026-11-19_parallax_venice_scarlet.json) |
| Fête foraine de Bayou City | [carnival_mid.png](../../../../assets/dossier_curien/saga/carnival_mid.png), [carnival_front.png](../../../../assets/dossier_curien/saga/carnival_front.png) | [Special et fête foraine](2026-11-19_parallax_special_carnival.json) |
| Plateau de Loving Deads EX | [ex_mid.png](../../../../assets/dossier_curien/saga/ex_mid.png), [ex_front.png](../../../../assets/dossier_curien/saga/ex_front.png) | [EX et Zombie Revenge](2026-11-19_parallax_ex_revenge.json) |
| Rue en quarantaine de Zombie Revenge | [revenge_mid.png](../../../../assets/dossier_curien/saga/revenge_mid.png), [revenge_front.png](../../../../assets/dossier_curien/saga/revenge_front.png) | [EX et Zombie Revenge](2026-11-19_parallax_ex_revenge.json) |

Les seize calques sont des PNG RGBA natifs de **1 672 × 941 pixels**. Les rapports mesurent un alpha maximal de **1 sur 255** dans la bande centrale comprise entre x = 12,5–87,5 % et y = 20–79 %. Pour Venise, le contrôle se prolonge jusqu’à y = 88 %, en cohérence avec sa ligne de sol plus basse.

Le moteur recherche désormais les calques disponibles pour toutes les arènes Saga et les dessine avec des déplacements distincts : arrière-plan, plan intermédiaire, puis premier plan. Il conserve le repli procédural prévu pour les anciennes arènes si un calque est absent. La ligne de sol reste à 651 pour Venise et à 601 pour les autres terrains. [Source : sélection des plans et composition](../../../../src/dossier_curien/presentation.gd).

Les sept arènes déjà dotées de trois calques — Goldman, réacteur EFI, tour de l’horloge, ponton du bayou, parvis Goldman, ruines Scarecrow et **Rue dévastée de Despair** — rejoignent ainsi les huit arènes complétées. **Les quinze arènes Saga disposent de leurs trois plans en PNG.** Les [trois plans de Despair](2026-11-19_citydespair.json), issus du premier lot, sont conservés. Cela décrit la disponibilité des plans ; les mouvements de caméra et leur composition finale relèvent de la validation dans le moteur.

## Deux objets de décor et deux pièces pour Lisa

| Fichier | Rôle | État de branchement |
|---|---|---|
| [efi_alarm_beacon.png](../../../../assets/dossier_curien/saga/props/efi_alarm_beacon.png) | Balise murale ambrée et support industriel assortis à EFI | Déclarée pour l’arène EFI et dessinée derrière les combattants |
| [subway_ticket_machine.png](../../../../assets/dossier_curien/saga/props/subway_ticket_machine.png) | Distributeur de billets abîmé assorti au quai du métro | Déclaré pour le métro et dessiné derrière les combattants |
| [lisa_shotgun.png](../../../../assets/dossier_curien/saga/parts/lisa_shotgun.png) | Fusil de Lisa isolé | Source séparée, points de prise et bouche du canon estimés |
| [lisa_goggles.png](../../../../assets/dossier_curien/saga/parts/lisa_goggles.png) | Lunettes de Lisa isolées | Source séparée, pont et sangle repérés |

Ces quatre fichiers mesurent **1 254 × 1 254 pixels en RGBA**. Leur [rapport de production](2026-11-19_props_parts.json) contient les références, prompts, dimensions, alpha et empreintes SHA-256.

Le bloc `stage_props` de [dossier_curien_additions.json](../../../../data/assets/dossier_curien_additions.json) fournit l’arène, la position, la taille à l’écran, le pivot et le déplacement de parallaxe des deux objets de décor. [presentation.gd](../../../../src/dossier_curien/presentation.gd) les dessine avant les combattants.

Le bloc `parts` décrit les deux éléments de Lisa avec le statut `separate_source_not_rigged`. **Ils ne sont pas encore assemblés sur un personnage animé.** Les points d’ancrage sont des estimations à ajuster lors du futur travail d’articulation ; aucune superposition automatique ni animation indépendante de ces pièces n’est revendiquée.

## Récupération : 22 images retrouvées, 204 maîtres encore manquants

**Les 22 PNG du premier lot sont présents sur GitHub et sont intégrés au total de 253 PNG.** L’hypothèse initiale selon laquelle ils manquaient provenait d’un état de branche antérieur ; elle est corrigée par le rapprochement avec `1586e4c`.

La limite de récupération porte sur un autre ensemble : **204 fichiers maîtres et variantes de production**, totalisant **369 644 488 octets**, dont la publication n’avait pas abouti. Le [relevé de récupération](RECUPERATION_LOCALE_2026-11-19.json) distingue 219 maîtres examinés, 15 originaux déjà présents et ces 204 originaux non publiés. Ils n’ont pas été retrouvés lors de cette reprise.

Ces maîtres sources ne correspondent pas à 204 nouveaux sprites jouables. Ils restent hors du décompte des 50 images ajoutées depuis le volume IV et du total de 253 PNG du Dossier Curien. Leur récupération ultérieure devra s’appuyer sur les fichiers et les empreintes consignées avant tout ajout.

## Paquet regroupant les deux lots

Le paquet actualisé doit être assemblé avec le **nouveau [fragments.json](../jeu/fragments.json)** et tous les fragments qu’il désigne, pris dans le même état du dossier [jeu](../jeu). Ce manifeste fournit la liste, les tailles et les empreintes de référence ; aucun nombre fixe de fragments n’est imposé dans cette note.

La reconstruction couvre **les deux lots du 19 novembre, soit 50 images depuis le volume IV** : poses de Rogan, G et Magician, marches de Kate et de sa tenue de réception, Despair et ses trois plans, accessoires de Venise, puis les 28 ressources de ce complément. Les deux pièces de Lisa sont incluses comme sources séparées ; leur présence dans le paquet ne signifie pas qu’un assemblage animé est déjà réalisé.

Le [guide de lancement actualisé](../../JOUER.md) décrit l’assemblage et l’accès aux nouveaux visuels. La section consacrée aux paquets dans le [bilan initial](REPRISE_2026-11-19.md) est conservée comme état historique du premier lot ; ce complément et le nouveau manifeste précisent la livraison regroupée.

### Contrôle visuel et captures

**La vérification visuelle de cette version dans le navigateur est bloquée** : Chromium n’a pas pu démarrer (`socket() : Operation not permitted`) et le service de bureau partagé était indisponible. Les contrôles de fichiers et les essais sans affichage ne remplacent pas cette revue visuelle.

Les captures et vidéos déjà présentes documentent les volumes antérieurs. Aucune capture actualisée de cette livraison n’est présentée comme preuve du rendu des deux lots. Les résultats d’exécution et d’empaquetage sont consignés dans le [rapport de validation](VALIDATION_PARALLAXE_2026-11-19.json).

## Fidélité et suite de production

La référence immédiate des nouvelles poses est la garde existante de chaque personnage. Les calques et objets prolongent les décors déjà illustrés pour le projet. Les sources officielles consultées pour les costumes sont consignées dans les rapports concernés.

**La fidélité canonique 1:1 n’est pas certifiée par cette livraison.** Les illustrations sont des adaptations pour la caméra latérale du mode combat. Une comparaison détaillée avec les modèles, animations et cadrages des éditions originales reste nécessaire. Les rapports signalent également les légères variations possibles de visage, tissu et ombrage entre poses générées.

Les principales lacunes visibles après cette reprise sont les suivantes :

- **17 combattants sur 23** n’ont pas encore leurs deux appuis de marche en tenue de base. Les variantes de costume doivent également recevoir leurs propres phases lorsque la silhouette ou les vêtements changent.
- **19 combattants sur 23** n’ont pas de PNG `recovery` dédié ; Rogan, G, Magician et Chariot possèdent désormais cette pose.
- Les cycles à deux appuis de James, Lisa et Ryan demandent des phases intermédiaires et des transitions supplémentaires pour atteindre une animation plus fluide.
- Les sauts, accroupissements, rechargements et autres actions doivent être complétés par des dessins propres lorsque le rendu emploie encore une transformation d’une pose existante.
- Les deux pièces de Lisa attendent leur assemblage, leurs articulations et leurs tests d’alignement.

Les rapports de ce dossier constituent la trace de production : ils relient chaque fichier livré à son prompt, ses références et son SHA-256. L’[inventaire détaillé](MANQUANTS_2026-11-19.json) conserve **291 poses nommées encore absentes**, en comptant les deux costumes et les actions avancées. Ce chiffre dépasse les seuls appuis et récupérations prioritaires ; il ne constitue pas un inventaire exhaustif de toute la franchise.


## Validation de l’ensemble regroupé

Validation réalisée avec **Godot 4.7.1**. Le [rapport structuré](VALIDATION_PARALLAXE_2026-11-19.json) conserve commandes, résultats, empreintes des logs et limites.

| Contrôle | Résultat |
|---|---|
| Catalogue et reçus d’images | 253 PNG, dont 50 ajouts vérifiés par dimensions, SHA-256 et limites alpha |
| Audit du complément Saga | 1 456 contrôles ; 223 PNG, huit pivots de marche |
| Socle de jeu | 1 335 assertions réussies |
| Saga depuis les sources | 772 contrôles, zéro échec |
| Saga depuis le paquet reconstruit | 772 contrôles, zéro échec |
| Archives | 29 épreuves, zéro échec |
| Boss Rush | 74 contrôles, zéro échec |
| Atelier | 69 exercices, 220 contrôles, zéro erreur |
| Vérifications npm et Web | `npm test`, `npm run qa:web`, `npm run verify:web` réussis |
| Assemblage et préparation Web | Empreinte du paquet vérifiée, préparation réussie |

Le nouveau paquet contient **549 ressources** : 437 ressources du paquet de référence conservées, 11 fichiers source actualisés, 50 nouvelles textures importées avec leurs 50 métadonnées d’import, et le manifeste des ajouts. Il mesure **50 384 932 octets** et se reconstitue à partir de **14 fragments**. Son SHA-256 vaut :

`94317806dba0c1a39246f275d06a7dd2e99066b4e0941d8a1e89d1a7bea897e0`

Le script [build_dossier_curien_pack.gd](../../../../scripts/build_dossier_curien_pack.gd) permet de reproduire cette construction après import des sources. Il conserve le paquet de référence et refuse d’écraser un fichier de sortie existant. Le programme [preparer_web.py](../jeu/preparer_web.py) a ensuite vérifié l’assemblage et préparé le site local. La validation Web structurelle et cette préparation ne remplacent pas le contrôle visuel interactif signalé plus haut.

Deux limites de test restent consignées : le Boss Rush signale quatre instances `ObjectDB` encore allouées à la fermeture, malgré son code de sortie 0 ; l’audit du jeu de tir conserve six avertissements connus sur les placements et les vues de sprites. Aucun de ces avertissements n’est présenté comme corrigé par ce lot.
