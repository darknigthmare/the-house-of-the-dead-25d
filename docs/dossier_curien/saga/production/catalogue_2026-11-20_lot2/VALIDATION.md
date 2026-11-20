# Validation du deuxième lot du 20 novembre 2026

**Les contrôles locaux des sources sont réussis.** Le moteur charge **61 fiches**, conserve les 49 précédentes et ajoute douze illustrations statiques. Les deux nouvelles arènes portent la sélection à **22** ; elles démarrent de vrais duels avec leurs six plans et le sol commun à 601. Le nombre de combattants reste **24** et celui des tenues alternatives sélectionnables **2**.

La base publiée de départ est `6291e0d723eb4bc5050ffd3de699f6e55a575642`. Ce reçu porte sur le delta source du deuxième lot. Le SHA publié et sa CI doivent être relus après publication dans la PR #2 ; la CI verte de cette base ne constitue pas une preuve pour le nouveau lot.

## Commandes et résultats finaux

| Commande | Résultat | Portée |
|---|---|---|
| `npm test` | **Code de sortie 0** | Suite complète des données et ressources, avec les 18 nouveaux PNG, les deux lots de galerie et les reçus de production. |
| `godot --headless --path . --import` | **Code de sortie 0 ; aucun diagnostic d’erreur** | Import natif des ressources matérialisées, dont les douze fiches et les six nouveaux plans. |
| `godot --headless --path . --script res://tests/test_saga_expansion.gd` | **446 contrôles, 0 échec, aucun diagnostic d’erreur** | Conservation des anciennes fiches, présence de chaque ID livré, textures et dimensions natives, détails sans bouton Jouer, filtres, focus, panneaux, arènes 18 à 21, régressions Linda et entraînement. |
| `godot --headless --path . --script res://tests/test_saga_gallery.gd` | **25 contrôles, 0 échec, aucun diagnostic d’erreur** | Fixtures de trois collections : doublons entre lots, racines distinctes, fausses déclarations, filtres Typing et Scarlet Dawn, rechargement et traitement de collections invalides. |
| `git diff --check` | **Code de sortie 0** | Espaces et fins de lignes des fichiers suivis du delta. |

Le moteur local est **Godot 4.6.3.stable.official.7d41c59c4**, avec **Node v24.22.3**. La CI du dépôt reste configurée sur **Godot 4.7.1 et Node 22**. Les suites Expansion, Galerie et Motion sont déjà dans sa boucle ; leurs résultats sur le prochain SHA publié devront être relevés sur ce SHA précis.

Le checkout principal est partiel. La suite `npm test` a donc été exécutée dans le worktree de QA disposant des ressources historiques nécessaires, aligné sur la même base `6291e0d`. **92 fichiers nouveaux ou modifiés ont été recopiés et rehachés avant cette exécution**, notamment les douze PNG de galerie, les six plans, les imports, le nouveau manifeste, les références et les trois reçus de production. Les empreintes des entrées pertinentes sont conservées dans [VALIDATION.json](VALIDATION.json) et correspondent toujours aux fichiers du checkout principal. Les documents de bilan et ce reçu sont finalisés séparément ; aucun ancien PCK n’a servi à valider les sources nouvelles.

## Vérification des images et des collections

Le nouveau manifeste contient **12 fiches non jouables, 14 814 532 octets** : quatre PNJ, six bases de boss et deux variantes Typing. Zeal et Kuarl ont deux fiches pour leur rencontre commune Judgment. Les trois shards de production sont vérifiés par SHA256 ; chaque ligne du manifeste fusionné doit être identique à sa ligne de provenance. Les identités ne peuvent remplacer celles de l’expansion ni d’un lot antérieur, et chaque image doit rester dans le répertoire de sa collection.

Les neuf fiches du premier lot restent présentes. Le validateur de galerie couvre les deux lots, soit **21 fiches statiques**, et réussit **21 auto-tests**, dont les collisions entre lots, les répertoires étrangers, la non-jouabilité et les reçus modifiés ou divergents.

Les dimensions natives des nouvelles silhouettes sont **10 × 1254 × 1254 pixels et 2 × 1024 × 1536 pixels**. Le test moteur compare les dimensions de chaque texture chargée à son manifeste. Le renderer ajuste la taille au cadre en conservant le ratio ; les portraits ne sont pas forcés dans une image carrée. Les PNG sources restent inchangés.

Les six plans de décor totalisent **8 076 437 octets**. Leur ajout fait passer le catalogue Saga de 229 à **235 PNG**, vérifiés par **1 588 contrôles**. Le catalogue initial et le catalogue Saga réunis comptent **265 PNG** ; les collections expansion, motion et galerie ont leurs propres manifestes et ne doivent pas être déduites de ce seul sous-total.

Le [delta de livraison](DELTA_LIVRAISON.md) rapproche les **18 nouveaux PNG distincts, 22 890 969 octets**, des **365 chemins PNG et 363 contenus distincts** sous `assets/dossier_curien`. Les variantes sélectionnables et les **277 lacunes minimales de poses** ne changent pas.

## Résultats conservés du reste de la suite

- Données : **307/307** ; environnement : **1 977 assertions** ; effets animés : **340/340** ; support gameplay : **113/113**.
- Audit des familles de contenu : **905 contrôles, 6 avertissements historiques, 0 erreur** ; profils d’import : **132 fichiers, 0 écart**.
- Expansion antérieure : **49 PNG, 40 fiches**, puis **10 auto-tests**.
- Motion antérieur : **30 PNG**, puis **11 auto-tests**.

Un passage ciblé des arènes avait auparavant réussi **41 contrôles** ; ces scénarios sont repris dans les 446 contrôles finaux. Les compteurs qui couvrent les mêmes scénarios ne doivent pas être additionnés comme des tests indépendants.

Le contrôle documentaire a résolu **243 cibles locales Markdown**, sans cible introuvable, dans les README, le guide de jeu, la bible et les rapports du lot. Les fichiers historiques non matérialisés sont vérifiés dans l’arbre Git ; ce contrôle ne teste pas les sites externes ni les ancres de section.

## Limites réelles

Les vérifications moteur sont **headless**. Aucune session visuelle, capture native du viewport, partie interactive complète ou utilisation d’une manette physique n’a été effectuée pour ce lot. La propriété du focus et le contenu des panneaux sont testés dans le moteur, sans prétendre remplacer ces observations visuelles.

**Aucun PCK ni export web n’a été reconstruit.** Les anciens paquets conservent leur contenu et leurs empreintes. Les builders et le vérificateur de paquet sont préparés pour les deux manifestes de galerie et les 22 arènes ; une nouvelle distribution n’a pas été exécutée ni certifiée par ce reçu.

Goldman, les six bases de boss et les deux variantes Typing ont un statut de références examinées. **Thornheart, Papa Caesar et Clement Darling** gardent le statut `static_needs_visual_reference_qa`. Varla et Candi conservent leur réserve du premier lot. Ces cinq réserves concernent les 21 fiches des deux lots ; elles ne recensent pas toutes les limites de la galerie historique. Aucun statut ne certifie une fidélité canonique 1:1 ou des animations complètes.

## Preuves compactes

- [Reçu structuré, commandes et empreintes des entrées testées](VALIDATION.json)
- [Résumé des sorties de npm test](qa_logs/npm-test-summary.txt)
- [Intégration native : 446 contrôles](qa_logs/godot-expansion-final.txt)
- [Fixtures de galerie : 25 contrôles](qa_logs/godot-gallery-final.txt)
- [Bilan du lot et limites de diffusion](BILAN_LOT.md)
