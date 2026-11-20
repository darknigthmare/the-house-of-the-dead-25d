# Validation du troisième lot du 20 novembre 2026

**Les contrôles locaux des sources sont réussis.** Le moteur charge **69 fiches**, conserve les 61 précédentes et ajoute les huit illustrations statiques du lot. Les arènes **Enclos du D.B.R. — Fool** et **Chambre BIO — Sun** portent la sélection à **24**, avec trois plans chacune. Les **24 combattants**, **26 parcours**, **29 archives** et **deux tenues sélectionnables** restent les mêmes profils de jeu.

La base publiée de départ est `af0e4933c07b9016a6be552ce874b61007dd7836`. Ce reçu porte sur le delta source du troisième lot. Le SHA publié et sa CI doivent être relus dans la PR #2 après publication ; la CI verte de cette base ne constitue pas une preuve pour le nouveau lot.

## Commandes et résultats finaux

| Commande | Résultat | Portée |
|---|---|---|
| `npm test` | **Code de sortie 0** | Suite complète des données et ressources, avec les 14 nouveaux PNG de production, les trois lots de galerie et leurs reçus. |
| `godot --headless --path . --editor --import` | **Code de sortie 0 ; aucun diagnostic d’erreur** | Import des ressources restaurées et des quatorze nouveaux PNG. |
| `godot --headless --path . --script res://tests/test_saga_expansion.gd` | **555 contrôles, 0 échec, aucun diagnostic d’erreur** | Conservation des anciennes fiches, huit nouveaux IDs exacts, chaque texture et dimension native, panneaux sans bouton Jouer, filtres, focus, arènes 18 à 23, régressions Linda et entraînement. |
| `godot --headless --path . --script res://tests/test_saga_gallery.gd` | **34 contrôles, 0 échec, aucun diagnostic d’erreur** | Fixtures de quatre collections : identités, racines distinctes, déclarations de non-jouabilité, filtres HOTD/HOTD 4/4 Special, rechargement et pannes indépendantes. |
| `git diff --check` | **Code de sortie 0** | Espaces et fins de lignes du delta suivi. |

Le moteur local est **Godot 4.7.2.stable.official.ed1daf0bf**, avec **Node v24.22.3**. La CI du dépôt reste configurée sur **Godot 4.7.1 et Node 22**. Les suites Expansion, Galerie et Motion restent dans sa boucle ; leurs résultats devront être relevés sur le nouveau SHA précis.

Le checkout a été restauré depuis la base publiée, avec les ressources historiques et les références nécessaires aux validateurs. Les anciens paquets volumineux sont hors checkout. Les tests s’exécutent directement dans cette copie, avec les fichiers nouveaux présents. **74 entrées pertinentes ont été rehachées avant et après les tests, sans aucun changement** ; leurs empreintes sont conservées dans [VALIDATION.json](VALIDATION.json). Les bilans et inventaires sont finalisés séparément. Aucun ancien PCK ne sert à valider les sources nouvelles.

Le contrôle documentaire a résolu **248 cibles locales Markdown dans 13 documents**, sans cible introuvable. Les fichiers historiques non matérialisés sont contrôlés dans l’arbre Git ; les sites externes et les ancres de section ne sont pas validés par ce contrôle.

## Images, collections et provenance

Le manifeste du troisième lot contient **huit fiches non jouables, 11 587 927 octets** : deux PNJ, quatre bases de boss et deux variantes d’édition. Les lignes sont copiées à l’identique des trois shards de production, dont le SHA-256 est enregistré et vérifié. Les identités restent distinctes à travers l’expansion et les trois lots ; chaque image doit rester dans le répertoire de sa collection.

Les huit silhouettes gardent leurs formats natifs : **quatre images de 1254 × 1254 et quatre portraits de 1024 × 1536**. Chaque texture chargée est comparée aux dimensions déclarées. Le renderer conserve le ratio dans le cadre de la fiche. Les trois lots réunissent **29 fiches statiques** ; le validateur Node réussit **24 auto-tests**.

Les **six plans natifs de 1672 × 941**, **6 703 608 octets**, ont leurs SHA, dimensions, modes RGB/RGBA et empreintes de prompts rapprochés du manifeste de stages. Les quatre overlays gardent un alpha central maximal de **1/255**, conformément au contrat déclaré. Le catalogue Saga compte **241 PNG**, vérifiés par **1 654 contrôles**. Les catalogues initial et Saga réunis comptent **271 PNG** ; expansion, motion et galerie possèdent leurs propres manifestes.

Le total livré dans `assets/dossier_curien` pour ce lot est **14 PNG distincts, 18 291 535 octets**. Le répertoire compte désormais **379 chemins PNG et 377 contenus Git distincts**. Les **365 chemins PNG de la base sont restés identiques octet pour octet**. Le [delta de livraison](DELTA_LIVRAISON.md) conserve le rapprochement avec les tâches et le cumul.

La production compte **16 appels ImageGen pour 14 images retenues dans les assets du jeu**. Deux sorties ont été écartées pour le jeu. La première version de James est conservée uniquement dans les références de provenance comme entrée exacte de sa correction ; elle n’est pas une neuvième fiche de galerie. Le premier Brutus n’est pas committé ; son nom, son empreinte et la correction restent documentés. Les PNG retenus ne sont ni recadrés ni redimensionnés après génération.

## Arènes et navigation

Un contrôle ciblé préliminaire avait réussi **61 vérifications** des arènes 18 à 23 : clés artistiques, sélection réelle, taille des panneaux, démarrage d’un duel, sol à 601 et chargement des trois plans. Ces scénarios sont repris dans les 555 contrôles finaux ; ils ne doivent pas être additionnés comme une suite indépendante.

Le guide `JOUER.md` corrige une erreur de pagination antérieure : **cinq arènes par page** placent le train et l’abattoir sur la **quatrième page**, puis Tower, Strength, Fool et Sun sur la **cinquième**. Les deux nouveaux lieux sont des adaptations des salles de boss ; les autres salles et branches de D.B.R./EFI et BIO restent ouvertes.

La revue indépendante du diff runtime et tests n’a signalé aucun défaut concret. Les trois anciens manifestes conservent leurs octets et leurs 61 fiches visibles. Le contrôle d’identités et de chemins reste global ; les filtres HOTD 4 et 4 Special restent distincts et seul le chemin canonique de Linda ouvre une action Jouer.

## Reste de la suite et limites

Les données passent **307/307** ; le contrôle d’environnement conserve **1 977 assertions**, les effets animés **340/340** et le support gameplay **113/113**. L’audit de contenu passe **905 contrôles, six avertissements historiques, zéro erreur**. Les profils d’import restent vérifiés. L’expansion antérieure conserve 49 PNG et 40 fiches, et le manifeste motion conserve 30 PNG.

Les vérifications moteur sont **headless**. Les images sources ont été examinées par leurs producteurs et lors des revues indépendantes, sans capture native de viewport, session interactive complète ou manette physique. Les tests de focus et de panneaux ne remplacent pas ces observations en jeu.

**Aucun PCK ni export web n’a été reconstruit.** Les builders et le vérificateur de paquet connaissent les trois manifestes et les 24 arènes, en préparation d’une distribution ultérieure. Les paquets historiques conservent leur contenu.

Sophie garde le statut `static_needs_visual_reference_qa`. Avec Varla, Candi, Thornheart, Papa Caesar et Clement, cela fait six réserves explicites parmi les 29 fiches des trois lots ; ce compte ne recense pas toutes les limites de la galerie historique. Aucun statut ne certifie une fidélité 1:1 ou des animations complètes. Les **277 lacunes minimales de poses** et les **204 masters historiques non récupérés** restent distincts et ouverts.

## Preuves compactes

- [Reçu structuré et empreintes des 74 entrées testées](VALIDATION.json)
- [Résumé des sorties de npm test](qa_logs/npm-test-summary.txt)
- [Intégration native :555 contrôles](qa_logs/godot-expansion-final.txt)
- [Fixtures de galerie :34 contrôles](qa_logs/godot-gallery-final.txt)
- [Bilan du lot et limites de diffusion](BILAN_LOT.md)
