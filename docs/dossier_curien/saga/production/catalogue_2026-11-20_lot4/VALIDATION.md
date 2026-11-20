# Validation — quatrième lot du 20 novembre 2026

**Résultat local : PASS.** L’import Godot, la suite `npm test`, les **675 contrôles d’intégration Expansion** et les **41 contrôles de galerie** terminent avec un code de sortie nul, sans erreur moteur ni échec de suite.

Le lot est comparé à `c7162f7bb46aa7a3ef0546124949e96e2f25bc49`. Il ajoute neuf fiches statiques et deux arènes en trois plans, soit **15 PNG / 18 952 552 octets**. Le [bilan](BILAN_LOT.md) et le [delta](DELTA_LIVRAISON.md) conservent les comptes de livraison ; ce reçu décrit les contrôles effectivement exécutés.

## Environnement et commandes

- Godot local : **4.7.2.stable.official.ed1daf0bf**.
- Node : **v24.22.3** ; Python : **3.12.14**.
- Exécution dans le checkout de travail, avec les quinze nouveaux PNG et leurs imports présents.
- Les commandes ci-dessous sont reproduisibles depuis la racine du dépôt ; les arguments effectivement exécutés sont conservés dans [VALIDATION.json](VALIDATION.json).

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/test_saga_expansion.gd
godot --headless --path . --script res://tests/test_saga_gallery.gd
npm test
git diff --check
```

L’import a précédé les trois suites. **86 fichiers d’entrée** — code modifié, tests, manifestes, reçus de production, images, imports et références — ont été épinglés par SHA-256 avant ces suites puis relus après : **aucune mutation**. Leurs empreintes et tailles figurent dans le reçu JSON.

## Résultats

| Contrôle | Résultat observé |
|---|---|
| Import et analyse Godot | Code 0 ; aucune erreur de script ou de parsing |
| Expansion, galerie réelle et arènes | **675 contrôles, 0 échec** |
| Chargement isolé des collections | **41 contrôles, 0 échec** |
| `npm test` | Code 0 |
| Données générales | **307/307** |
| Environnement | **1 977 assertions** |
| Effets animés | **340/340** |
| Support gameplay | **113/113** |
| Audit des familles de contenu | **905 contrôles, 6 avertissements historiques, 0 erreur** |
| Profils d’import des textures | **132 fichiers, 0 différence** |
| Art Saga | **1 720 contrôles, 247 PNG Saga** |
| Expansion historique | **49 PNG, 40 fiches, 10 cas du validateur** |
| Manifeste motion historique | **30 PNG, 11 cas du validateur** |
| Quatre collections supplémentaires | **38 PNG et fiches statiques distinctes** |
| Validateur de galerie | **27 cas** |

Les compteurs se recouvrent et ne doivent pas être additionnés en un total unique. Les 247 PNG Saga s’ajoutent aux 30 du catalogue initial d’art ; ce périmètre est distinct des 394 PNG présents sous `assets/dossier_curien`.

Extraits versionnés : [Expansion](qa_logs/godot-expansion-final.txt), [Galerie](qa_logs/godot-gallery-final.txt), [résumé npm](qa_logs/npm-test-summary.txt). Les journaux npm complets restent des fichiers de travail ; le résumé conserve les résultats des sous-commandes.

## Ce que les contrôles exercent

La suite d’intégration charge les **78 fiches** réelles : 40 historiques puis 9, 12, 8 et 9 ajouts. Elle compare les identités de chaque manifeste à une liste attendue indépendante, conserve les chemins des sujets historiques et charge chaque texture. Les dimensions importées sont comparées aux dimensions natives déclarées, y compris **1199 × 1312** pour les deux fauteuils et **1024 × 1536** pour les fins zombies.

Les nouveaux détails sont ouverts dans le moteur. Ils restent non jouables, sans bouton « Jouer », et leur contenu tient dans le panneau. Le libellé **Forme de personnage · non jouable** distingue les variantes humaines ou zombies d’une transformation de combat. Les filtres de jeu, leur signal de sélection et le maintien du focus clavier/manette sont exercés.

Les fixtures de galerie couvrent la base et les quatre collections : collision d’identité avec un lot antérieur, emprunt d’une autre racine, image manquante, faux statut jouable ou animation complète, rôle non autorisé et panne indépendante d’un manifeste. Les références de production du manifeste fusionné sont contrôlées par SHA-256 ; chaque ligne doit rester strictement identique à celle de son shard.

Les arènes aux indices **18 à 25** sont sélectionnées par leurs boutons, puis démarrent un duel avec les deux combattants. Les indices **24 / 25** correspondent à **Terrasse de Hangedman / Dôme de culture — Hermit**. Les trois textures de chaque arène sont chargées et leur sol reste à **y = 601**.

## Régression du menu corrigée

L’ajout de Hangedman complétait la page 5. Le premier passage ciblé a trouvé **5 échecs sur 81 contrôles** : cette page dépassait verticalement du viewport, car chaque bouton était suivi de sa longue note et les deux directions de pagination étaient désormais présentes.

Le menu affiche maintenant **une seule note complète**, initialisée pour le premier choix puis mise à jour au focus clavier/manette ou au survol. Les cinq choix, leurs textes et les deux boutons de pagination sont conservés. Le réajustement différé reste protégé contre les callbacks d’une ancienne page.

Le même contrôle de limites du panneau reste en place. Le passage ciblé corrigé donne **97 contrôles, 0 échec**, après ajout de vérifications du focus et de la note affichée une seule fois. Ces contrôles font aussi partie des **675 contrôles finaux** ; ce ne sont pas 97 contrôles supplémentaires à additionner. Hangedman reste en fin de page 5 et Hermit ouvre la page 6, conformément au [guide de jeu](../../../JOUER.md).

## Intégrité et provenance

- **379 PNG de la base** relus : leurs empreintes Git sont toutes conservées.
- **394 chemins PNG / 392 blobs Git distincts** après ajout des quinze fichiers.
- Les quatre anciens manifestes de galerie/expansion sont **identiques octet pour octet** à la base.
- Manifeste du lot : [dossier_curien_gallery_2026-11-20_lot4.json](../../../../../data/assets/dossier_curien_gallery_2026-11-20_lot4.json), SHA-256 `c1f970994f8a6eb7c6dd1de2ddc22e9eb74bf5040a6ad18f295daecd9d3a0df2`.
- Les neuf lignes sont conservées depuis [humans_generated.json](humans_generated.json) et [bosses_generated.json](bosses_generated.json), dont les empreintes sont épinglées dans le manifeste.
- Le [manifeste des stages](../stages_2026-11-20_lot4/manifest.json) et le catalogue global conservent les six PNG natifs et leurs empreintes.

Le lot représente **17 appels de génération tentés : 15 sorties retenues, un premier essai Coco rejeté et une génération Mother bloquée sans PNG**. Mother boss n’est ni un fichier livré ni une entrée runtime ; son manque reste ouvert. Le premier essai Coco reste hors du dépôt. Aucune image de production n’a été redimensionnée ou retouchée après sa génération retenue.

Le contrôle documentaire porte sur les liens locaux en Markdown des guides courants et rapports du lot. Les fichiers historiques non matérialisés dans ce checkout sont rapprochés de l’arbre Git. Les URL externes et les ancres de section ne font pas partie de ce contrôle ; le résultat détaillé figure dans le reçu JSON.

Une revue indépendante en lecture seule du runtime, des validateurs, des builders et des tests n’a trouvé aucun défaut concret supplémentaire. Elle a notamment relu l’initialisation de la note, les signaux de focus/survol et la conservation des anciennes collections.

## Limites de cette validation

Les tests sont **headless**. Les PNG de production ont été inspectés comme images sources par leurs producteurs et lors des revues, mais ce reçu ne revendique ni capture native du viewport, ni session manuelle complète au clavier/manette, ni certification de fidélité 1:1.

**Aucun nouveau PCK ni export du jeu web n’a été construit.** Les builders et le vérificateur du futur pack prennent en compte la nouvelle collection et les arènes ; cela ne constitue pas une validation d’un nouveau binaire distribué. Les PCK et exports antérieurs conservent leur contenu d’origine.

Les **277 poses minimales encore manquantes**, les **204 masters historiques non récupérés** et les réserves de référence restent ouverts. Neuf des 38 fiches issues des quatre lots ont un statut explicite de référence à compléter ; cette mesure ne résume pas tous les statuts des 78 fiches.

La CI du commit de publication sera relevée sur son SHA exact et consignée dans la [PR #2](https://github.com/darknigthmare/the-house-of-the-dead-25d/pull/2). Les résultats d’une ancienne révision ne sont pas repris comme preuve de ce lot.
