# Validation locale — Dossier Curien, lot 6

Date : **20 novembre 2026 — Europe/Paris**. Base : `7f14d7b49dcc8d884629245eef71e65198665b8e`, tête du lot 5 dans la [PR #3](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/3), encore ouverte et en brouillon au début du lot. Le lot 6 poursuit la même branche `feat/dossier-curien-lot5` et la même PR.

## Commandes et environnement

Environnement relevé : **Godot 4.7.2.stable.official.ed1daf0bf**, **Node v24.22.3**, **Python 3.12.14**. Les arguments réellement exécutés figurent dans [VALIDATION.json](VALIDATION.json).

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/test_saga_expansion.gd
godot --headless --path . --script res://tests/test_saga_gallery.gd
godot --headless --path . --script res://tests/test_saga_motion.gd
godot --headless --path . --script res://scripts/smoke_dossier_saga.gd
npm test
git diff --check
```

L’import a précédé les suites finales. **117 fichiers** participant aux contrôles ont été épinglés par SHA-256 puis relus après les suites : **aucune mutation**. Les guides et inventaires finaux sont contrôlés séparément.

## Résultats observés

| Contrôle | Résultat |
| --- | --- |
| Import Godot et analyse des scripts | Code 0 ; aucune erreur de script ou de parsing |
| Expansion, galerie réelle et arènes | **960 contrôles, 0 échec** |
| Collections isolées de galerie | **51 contrôles, 0 échec** |
| Poses et calibration natives | **227 contrôles, 0 échec** |
| Parcours et modes Saga | **854 contrôles, 0 échec** |
| `npm test` | **Code 0** |
| Données générales | **307/307** |
| Environnement | **1977 assertions** |
| Effets animés | **340/340** |
| Support gameplay | **113/113** |
| Audit des familles | **905 contrôles, 6 avertissements historiques, 0 erreur** |
| Profils d’import | **132 fichiers, 0 différence** |
| Art Saga | **1951 contrôles, 268 PNG** |
| Validateur de galerie | **33 cas** |
| Validateur motion | **15 cas** |

Les compteurs se recouvrent ; ils ne doivent pas être additionnés. Les **298 PNG** des catalogues d’art historique et Saga représentent un périmètre distinct de l’ensemble du répertoire Dossier Curien.

Extraits versionnés : [Expansion](qa_logs/godot-expansion-final.txt), [Galerie](qa_logs/godot-gallery-final.txt), [Motion](qa_logs/godot-motion-final.txt), [Saga](qa_logs/godot-smoke-final.txt) et [résumé npm](qa_logs/npm-test-summary.txt).

## Galerie et arènes

Le lot ajoute **4 fiches statiques** dans la sixième collection. Le test d’intégration fixe leur liste d’identifiants, charge chaque texture aux dimensions déclarées, ouvre chaque détail sans bouton « Jouer » et contrôle les limites du panneau. Les filtres et le focus clavier/manette sont exercés par leurs signaux réels. Les **89 fiches antérieures** conservent leurs identités et leurs chemins.

Les fixtures couvrent la base et les six collections : collisions d’identité, emprunt d’une autre racine, images absentes, faux statuts jouables, animation prétendument complète et pannes indépendantes des manifestes. Le validateur Node compare les empreintes des reçus et chaque objet livré au manifeste runtime.

Les arènes aux indices **18 à 32** sont sélectionnées par leur bouton puis démarrent un duel avec deux combattants. Les indices **29 à 32** identifient **Sous-sols AMS — Escape**, **Annexe — Scarlet Dawn**, **Manoir — Papa’s Palace of Pain** et **Égouts industriels — Zombie Revenge**. Les trois plans chargent et le sol reste à **y = 601**. Escape complète la page 6 ; les trois autres arènes occupent la page 7. Chaque choix affiche une seule note complète ; les limites des panneaux restent contrôlées.

## Poses de combat

Le second manifeste motion ajoute **9 poses de Rikiya** : montée et descente du saut, accroupissement, garde accroupie, blocage, projection, victoire, provocation et finition. Les poses gardent leurs dimensions natives, pivots et hauteur anatomique de référence. Le chargeur assemble les deux collections sans écraser la première ; les tests motion consignent les cas exercés dans le journal versionné.

Les nouvelles poses sont utilisées par le rendu des états de combat correspondants. Elles réduisent les lacunes nommées dans l’[inventaire motion dérivé](../motion_2026-11-20_lot6/MANQUANTS.json). Elles ne constituent pas des animations chronologiques complètes. Le [rapport motion](../motion_2026-11-20_lot6/RAPPORT.md) précise la calibration et les limites visuelles.

## Dimensions, intégrité et provenance

Les fichiers retenus comprennent **4 PNG de galerie**, **9 PNG motion** et **12 plans d’arènes**, soit **25 PNG / 26,100,409 octets**. Leurs dimensions natives se répartissent ainsi : 4 en 1024 × 1536, 9 en 1254 × 1254, 12 en 1672 × 941. Aucune conversion de dimensions n’est effectuée par cette intégration.

Les **414 PNG de la base** sont relus et leurs empreintes Git sont inchangées. Les **7 manifestes antérieurs** contrôlés, dont l’expansion, les cinq collections de galerie et le premier catalogue motion, sont identiques octet pour octet. Les fichiers retenus, dimensions, tailles et empreintes sont listés dans le reçu JSON.

Le [manifeste de galerie](../../../../../data/assets/dossier_curien_gallery_2026-11-20_lot6.json), son [reçu](costumes_generated.json), le [manifeste motion](../../../../../data/assets/dossier_curien_motion_2026-11-20_lot6.json) et le [rapport des arènes](../stages_2026-11-20_lot6/RAPPORT.md) conservent leur provenance. Le [delta](DELTA_LIVRAISON.md) distingue les sorties retenues, rejetées et les manquants effectivement résolus.

## Contrôle documentaire

**190 cibles locales dans 12 documents**, aucun lien manquant ; 11 destinations historiques confirmées dans l’arbre Git.

Ce contrôle vérifie les destinations locales des liens Markdown dans les guides et reçus finaux. Les documents historiques absents de la copie de travail sont rapprochés de l’arbre Git de la base. Il ne vérifie pas les URL externes ni les ancres de section. Les [personnages et tenues](PERSONNAGES_TENUES.md) et les [stages manquants](STAGES_MANQUANTS.md) conservent les travaux encore ouverts.

## Limites et publication

Les suites sont **headless**. Les producteurs ont inspecté les images et leurs références ; ce reçu ne certifie ni fidélité canonique 1:1, ni capture native du viewport, ni session manuelle complète au clavier ou à la manette. Les réserves visuelles sont maintenues dans les reçus. La forme boss de Mother n’a pas fait l’objet d’une nouvelle tentative.

**Aucun nouveau PCK ni export web n’a été construit.** Les builders et le vérificateur de paquet incluent la sixième collection, les deux manifestes motion et les nouvelles arènes. Cette mise à jour de source ne valide aucun nouveau binaire distribué. Les poses restantes et les **204 masters historiques non récupérés** constituent des déficits distincts.

La CI sera relevée sur le commit effectivement publié et consignée dans la **PR #3 existante**. Les résultats du lot 5 ne servent pas de preuve à ce lot. Le statut Vercel sera relevé séparément sans relancer un déploiement bloqué par le quota. La PR reste ouverte ; aucune fusion n’est effectuée.
