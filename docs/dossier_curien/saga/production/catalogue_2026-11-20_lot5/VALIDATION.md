# Validation locale — Dossier Curien, lot 5

Date : **20 novembre 2026 — Europe/Paris**. Base : `6da249f2c2cc9a988e31230dae1f805e3d7e1daf`, la branche main après fusion de la PR #2. Cette continuation utilise la branche `feat/dossier-curien-lot5` et sera publiée dans une nouvelle PR.

## Commandes et environnement

Les commandes utilisent **Godot 4.7.2.stable.official.ed1daf0bf**, **Node v24.22.3** et **Python 3.12.14**. Les arguments réellement exécutés sont conservés dans [VALIDATION.json](VALIDATION.json).

```sh
godot --headless --path . --editor --import
godot --headless --path . --script res://tests/test_saga_expansion.gd
godot --headless --path . --script res://tests/test_saga_gallery.gd
npm test
git diff --check
```

L’import a précédé les trois suites finales. **96 fichiers liés aux entrées testées** ont ensuite été épinglés par SHA-256 puis relus après exécution : **aucune mutation**. Ils couvrent le code modifié, les tests, les manifestes, les reçus de production, les PNG, leurs imports et les références nouvelles. Les inventaires et les rapports de prose, finalisés en parallèle, ont été contrôlés séparément dans leur état final.

## Résultats

| Contrôle | Résultat observé |
| --- | --- |
| Import Godot et analyse des scripts | Code 0 ; aucune erreur de script ou de parsing |
| Expansion : galerie réelle, détails, filtres et arènes | **866 contrôles, 0 échec** |
| Chargement isolé des collections | **46 contrôles, 0 échec** |
| `npm test` | **Code 0** |
| Données générales | **307/307** |
| Environnement | **1 977 assertions** |
| Effets animés | **340/340** |
| Support gameplay | **113/113** |
| Audit des familles de contenu | **905 contrôles, 6 avertissements historiques, 0 erreur** |
| Profils d’import des textures | **132 fichiers, 0 différence** |
| Art Saga | **1 819 contrôles, 256 PNG Saga** |
| Expansion historique | **49 PNG, 40 fiches, 10 cas du validateur** |
| Manifeste motion historique | **30 PNG, 11 cas du validateur** |
| Cinq collections supplémentaires | **49 PNG et fiches statiques distinctes** |
| Validateur de galerie | **30 cas** |

Les compteurs se recouvrent et ne doivent pas être additionnés. Les 256 PNG Saga complètent les 30 PNG du catalogue initial d’art, soit 286 pour ce contrôle ; ce périmètre diffère des **414 chemins PNG / 412 contenus distincts** du répertoire Dossier Curien.

Extraits versionnés : [Expansion](qa_logs/godot-expansion-final.txt), [Galerie](qa_logs/godot-gallery-final.txt) et [résumé npm](qa_logs/npm-test-summary.txt). Les deux contrôles préliminaires de collection donnaient déjà 46 contrôles Godot et 30 cas Node ; ils sont repris dans les suites finales et ne sont pas comptés une seconde fois.

## Ce que les suites exercent

La galerie charge **89 fiches** : 40 historiques puis 9, 12, 8, 9 et 11 ajouts. La liste attendue des onze nouveaux IDs est explicite dans le test d’intégration. Chaque sujet est chargé, sa texture est comparée aux dimensions natives déclarées, son détail est ouvert sans bouton « Jouer » et son panneau doit rester dans le viewport. Les 78 fiches antérieures gardent leurs identités et leurs chemins.

Le filtre **The Typing of the Dead 2** reste distinct de Typing. Les six variantes visuelles de Zombie Revenge utilisent leur filtre existant ; Dan et Yukio apparaissent sous HOTD III, Hangedman sous Scarlet Dawn. Les signaux de sélection, les filtres et le focus clavier/manette sont contrôlés. Les cinq nouvelles réserves de référence sont conservées dans [CHARACTERS.md](CHARACTERS.md) et [COSTUMES.md](COSTUMES.md).

Les fixtures couvrent la base et les cinq collections : collision d’identité avec un lot antérieur, emprunt d’une autre racine, image manquante, faux statut jouable ou animation complète, rôle non autorisé et panne indépendante d’un manifeste. Le validateur Node contrôle les SHA-256 des deux reçus de production et l’égalité exacte de chaque ligne avec le manifeste fusionné.

Les arènes aux indices **18 à 28** sont sélectionnées par leurs boutons puis démarrent un duel avec deux combattants. Les indices **26 / 27 / 28** correspondent à **Place d’A Prelude / Hôpital — Ballistic Trauma / Usine chimique — Zombie Revenge**. Les trois plans de chaque arène sont chargés et le sol reste à **y = 601**. Le sélecteur conserve une seule note complète au focus ou au survol ; la page 6 accueille Hermit et les trois nouveaux lieux. Les limites des panneaux ne sont pas assouplies.

## Dimensions, intégrité et provenance

Les neuf PNG des arènes totalisent **10 094 760 octets**. Huit sont en **1672 × 941**, le premier plan de l’usine est nativement en **1673 × 940**. Cette variation est conservée dans le fichier et dans le catalogue ; le rectangle de rendu existant reste utilisé. Le vérificateur d’art compare les dimensions déclarées à l’en-tête de chaque PNG. Le [rapport des arènes](../stages_2026-11-20_lot5/RAPPORT.md) conserve les mesures alpha des six overlays et les limites des adaptations.

Les onze illustrations de galerie totalisent **16 483 233 octets**. Elles conservent leurs dimensions natives variées, notamment **1254 × 1254** pour Dan, **1086 × 1448** pour Yukio et **1090 × 1443** pour l’armure rouge de Stick. Les autres silhouettes du lot sont en **1024 × 1536**. Le total livré est **20 PNG / 26 577 993 octets**.

- **394 PNG de la base** relus : aucune modification d’empreinte Git.
- Les **cinq manifestes antérieurs**, expansion et quatre lots de galerie, sont identiques octet pour octet à la base.
- Le [manifeste runtime du lot](../../../../../data/assets/dossier_curien_gallery_2026-11-20_lot5.json) conserve exactement les onze objets des [personnages et équipements](characters_generated.json) et des [variantes Zombie Revenge](costumes_generated.json).
- Les vingt PNG retenus gardent leurs pixels et dimensions natifs ; les empreintes et tailles sont consignées dans le reçu JSON.
- L’import a créé 22 sidecars reproductibles pour des images documentaires historiques ; ces seuls fichiers non suivis ont été retirés. Les **20 imports des nouveaux assets** sont conservés.

Le lot compte **21 appels de génération : 20 sorties retenues et un premier cadrage de Rikiya en costume rejeté**. Aucun blocage ne s’est produit dans ce lot. Le manque de Mother boss conserve le blocage du lot 4 ; il n’y a eu aucune nouvelle tentative pour ce sujet.

## Contrôle documentaire

**306 cibles locales dans 13 documents**, aucun lien manquant ; 11 destinations historiques sont confirmées dans l’arbre Git.

Le contrôle porte sur les destinations locales des liens Markdown. Les documents historiques non matérialisés sont rapprochés de l’arbre Git de la base. Les URL externes et les ancres de section ne sont pas vérifiées par ce contrôle. Le [delta de livraison](DELTA_LIVRAISON.md), le [listing des personnages et tenues](PERSONNAGES_TENUES.md) et le [listing des stages](STAGES_MANQUANTS.md) précisent les règles de décompte et les déficits encore ouverts.

## Limites

Les contrôles sont **headless**. Les producteurs et root ont examiné les PNG et leurs références ; ce reçu ne revendique ni capture native du viewport, ni session manuelle complète au clavier/manette, ni certification de fidélité 1:1. **14 des 49 illustrations des cinq lots** gardent une réserve explicite de référence, dont cinq de ce lot. Le statut de l’armure rouge de Stick entre tenue et bonus ARMOR temporaire reste non certifié.

**Aucun nouveau PCK ni export du jeu web n’a été construit.** Les builders et le vérificateur de paquet connaissent la cinquième collection et les trois arènes, sans valider un nouveau binaire distribué. Les 277 poses minimales manquantes et les 204 masters historiques non récupérés restent deux déficits distincts.

La CI sera relevée sur le SHA réellement publié et consignée dans la nouvelle PR de continuation. Les résultats de la PR #2 ne servent pas de preuve à ce lot. Le statut de déploiement Vercel sera relevé séparément, y compris tout blocage de quota.
