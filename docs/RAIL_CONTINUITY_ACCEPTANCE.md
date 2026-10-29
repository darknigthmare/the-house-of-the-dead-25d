# Rail et continuité — critères de régression

Ce document transforme les constats de CONTINUATION.md en scénarios reproductibles. Il ne prétend pas que ces scénarios ont été exécutés.

## P0 — Contrat des transitions
1. Au passage entre deux nœuds, relever la pose de sortie du rail A et la pose d'entrée du rail B. L'écart planaire prévu doit rester de 9 m selon la convention actuellement documentée.
2. Vérifier que world_root et actor_root conservent le même repère ; aucune dérive verticale cumulée.
3. Vérifier la tangente finale : Bézier = cible moins contrôle B ; rail à points = dernier segment non nul.
4. Pendant le connecteur temporaire, vérifier sol, murs, arche, collisions, deux matériaux (sortie/entrée) et absence de trou visible.
5. Au remplacement du décor, aucun ennemi, projectile, scientifique ou état de porte ne doit être orphelin ou téléporté par erreur.
6. Vérifier que le masque de transition débute à 0,79 et couvre l'intersection connue près de 0,812 ; ces valeurs sont des références internes, pas des mesures arcade.
7. Contrôler en jeu les deux chemins du chapitre 2 : raised_bridge/lower_stairs → corridor_cache → roof_approach → roof_rescue → Hangedman.
8. Ne pas appeler « monde persistant » la reconstruction de décors par nœud. Le P0 n'est clos que lorsque les états du chapitre et les surfaces praticables sont conservés et testés.

## P0 — Fidélité et embranchements
- Décisions 2 et 6 : substituts inexacts documentés.
- Décisions 3, 4 et 9 : provisoires.
- Conserver TBD-AUTH en l'absence de référence arcade autorisée ; documenter séparément fidélité observée et fonctionnement technique.

## P1 — Validation par niveaux
- Test automatisé : graphes connectés, absence de nœud inaccessible, identifiants d'embranchement et de destination valides.
- Test Godot headless : pas d'erreur de parsing/chargement ; code de sortie non nul sur échec.
- Test visuel : enregistrement du passage avant/pendant/après transition à 1280×720, visibilité des surfaces et des ennemis.
- Régression : deux joueurs, rechargement, collisions, boss, sauvetages et score.
- Distribution : QA Web, contrôle navigateur, puis nouveaux exports Windows/Linux, distincts de la release v0.5.0.

## Preuves attendues avant clôture
Pour chaque correction : commit, chemins modifiés, scénario reproductible, commandes réellement exécutées, résultats, capture ou vidéo lorsque l'affichage change, limites restantes.

## Automatisation ajoutée à la PR
Le workflow `.github/workflows/qa.yml` exécute désormais `res://tests/test_runner.gd` après l'import Godot 4.7.1 sur checkout propre. Ce runner appelle `tests/test_camera_rail_continuity.gd`. Les huit assertions supplémentaires couvrent les bornes temporelles, la transition immobile et la direction verticale. Le pipeline doit être vert **sur le commit final**, pas seulement sur un commit documentaire antérieur.

Les contrôles d'intégrité ne remplacent pas la revue visuelle de la transition, ni la persistance effective du décor et des états de chapitre.
