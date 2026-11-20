# Validation du lot du 20 novembre 2026

**Les contrôles locaux des sources sont réussis.** Le lot testé ajoute neuf fiches de galerie et deux arènes en six plans, tout en conservant 24 combattants et deux tenues alternatives sélectionnables. Le moteur a chargé **49 fiches** ; les deux nouveaux stages entrent dans de vrais duels avec leurs six textures et le sol commun à 601.

La base de départ est `59372b618882da17510351f2a5bd46226682eac4`. Cette validation porte sur le delta source préparé pour la PR #2. Le SHA publié et les résultats de CI de ce SHA sont à vérifier sur la PR après publication ; le vert de la base ne constitue pas un résultat pour le nouveau lot.

## Commandes et résultats

| Commande | Résultat final | Périmètre |
|---|---|---|
| `npm test` | **Code de sortie 0** | Suite complète des données et ressources du dépôt, avec les quinze nouveaux PNG, leur catalogue et le manifeste de galerie. |
| `godot --headless --path . --import` | **Code de sortie 0 ; aucune erreur de diagnostic** | Import des ressources matérialisées, dont les neuf fiches et les six plans supplémentaires. |
| `godot --headless --path . --script res://tests/test_saga_expansion.gd` | **228 contrôles, 0 échec, aucune erreur de diagnostic** | Régressions Linda, galerie native de 49 fiches, textures, menus, pagination, filtres, focus, panneaux et démarrage des nouveaux stages. |
| `godot --headless --path . --script res://tests/test_saga_gallery.gd` | **18 contrôles, 0 échec, aucune erreur de diagnostic** | Fixtures de ressources en mémoire : fusion des collections, doublons, chemins, fausses déclarations de jouabilité, filtres et suppression des anciennes données après un chargement invalide. |
| `git diff --check` | **Code de sortie 0** | Espaces et fins de lignes du delta suivi. |

Les contrôles Godot locaux utilisent **4.6.3.stable.official.7d41c59c4**. La CI du dépôt utilise Godot **4.7.1** ; elle inclut maintenant `test_saga_gallery.gd`, en plus des suites expansion et motion déjà présentes. Node local est **v24.22.3** ; la CI reste configurée sur Node 22.

Le checkout de travail étant partiel, `npm test` a été exécuté dans un worktree de QA partageant la même base Git, après restauration des ressources historiques nécessaires. **Les 80 fichiers nouveaux ou modifiés disponibles au début de cette exécution ont été recopiés et rehachés**, notamment le manifeste neuf fiches, les neuf PNG de galerie et les six plans. Les 47 entrées pertinentes de code, tests, données et images correspondent aux empreintes conservées dans [VALIDATION.json](VALIDATION.json). Les documents de bilan et ce reçu sont ajoutés séparément ; aucun ancien PCK n’a servi à faire passer ces tests de sources.

## Résultats détaillés de `npm test`

- QA des données : **307/307** ; audit des familles de contenu : **905 contrôles, 6 avertissements déjà présents, 0 erreur**.
- Catalogue courant : **259 PNG** dans les catalogues initiaux et Saga, dont **229 PNG Saga** ; vérification Saga : **1 522 contrôles**. Les collections expansion, motion et galerie sont vérifiées par leurs propres manifestes.
- Expansion antérieure : **49 PNG, 40 fiches**, puis **10 cas d’auto-test**.
- Motion antérieur : **30 PNG**, puis **11 cas d’auto-test**.
- Galerie du 20 novembre : **9 PNG non jouables, 7 741 468 octets**, puis **14 cas d’auto-test**. Empreintes, dimensions, alpha, références, provenance, identités distinctes et couverture du répertoire sont vérifiés.

Le rapprochement des fichiers complets confirme **347 chemins PNG et 345 contenus distincts** sous `assets/dossier_curien`. Les quinze nouveaux PNG totalisent **13 466 764 octets**. Voir le [delta de livraison](DELTA_LIVRAISON.md) pour la séparation entre personnages, variantes de costume, adaptations de boss et arènes.

## Défauts trouvés et corrigés pendant la validation

Le premier passage complet de `npm test` a détecté un catalogue Saga resté à **223 images**. Les six plans supplémentaires ont été ajoutés avec leurs dimensions, empreintes et lien de production ; le catalogue atteint maintenant **229 images**. Le vérificateur contrôle aussi leur import Godot, leur statut d’adaptation et les canaux natifs RGB des fonds ou RGBA des surcouches.

La revue indépendante a reproduit une absence de focus à l’ouverture de la galerie : le nouveau `OptionButton` était ajouté directement et empêchait le premier bouton de fiche de prendre le focus. Le sélecteur prend désormais explicitement le focus après sa création. La suite d’intégration vérifie son propriétaire à l’ouverture et après chaque changement de filtre testé, afin que la navigation au clavier ou à la manette puisse reprendre.

## Limites du reçu

Les contrôles natifs sont **headless**. Aucun affichage X11/Wayland ni serveur Xvfb/Weston n’était disponible ; aucune capture de viewport ou partie interactive de ce lot n’est donc revendiquée. La propriété du focus est testée, sans essai d’une manette physique.

**Aucun PCK ni export web n’a été reconstruit.** Les distributions du 19 novembre gardent leur contenu et leurs empreintes ; elles ne contiennent pas ces deux nouvelles arènes ni les neuf nouvelles fiches. Les builders et le vérificateur de paquet sont préparés pour inclure le nouveau manifeste lors d’une reconstruction ultérieure, mais leur exécution n’est pas certifiée par ce reçu.

Les fiches de **Varla et Candi** gardent le statut `static_needs_visual_reference_qa`. Les sept autres fiches du lot sont `static_reference_reviewed`. Les contrôles techniques ne certifient ni fidélité 1:1 ni animation complète. Les **277 lacunes de poses minimales** restent inchangées.

## Preuves compactes

- [Reçu structuré et empreintes des entrées testées](VALIDATION.json)
- [Résumé des sorties de la suite npm](qa_logs/npm-test-summary.txt)
- [Sortie finale de l’intégration native, 228 contrôles](qa_logs/godot-expansion-final.txt)
- [Sortie des fixtures de galerie, 18 contrôles](qa_logs/godot-gallery-final.txt)

Les compteurs de suites qui couvrent les mêmes scénarios ne doivent pas être additionnés comme des tests indépendants. Les résultats intermédiaires antérieurs à la correction du focus et du catalogue ne remplacent pas les résultats finaux ci-dessus.
