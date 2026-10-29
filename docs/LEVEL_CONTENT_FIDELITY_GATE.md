# Production des niveaux et fidélité — The House of the Dead 2.5D

Objectif : atteindre la fidélité 1:1 **uniquement après comparaison mesurée** avec une référence autorisée. Ne pas transformer une approximation en élément certifié.

## Couverture de la campagne
- Chapitre 1 : jardin / entrée du manoir / foyer / couloirs / Sophie / Chariot.
- Chapitre 2 : pont haut ou escalier bas, corridor cache, approche du toit, sauvetage, Hangedman.
- Chapitre 3 : confronter les nœuds et leurs routes à `data/routes/chapter_03_route_graph.json`, puis Hermit.
- Chapitre 4 : confronter les nœuds et leurs routes à `data/routes/chapter_04_route_graph.json`, séquence Curien et Magician.

Les noms ci-dessus sont des repères du projet, **pas** une certification de correspondance arcade.

## Fiche de contrôle par séquence
Pour chaque nœud de `data/runtime/campaign_timeline.json` :
1. Identifiant et chapitre, entrée et sortie, embranchements et conditions exactes.
2. Plan et échelle des décors : géométrie, sols, murs, portes, escaliers, profondeur, éclairage et éléments destructibles.
3. Rail : pose et orientation caméra aux points clés, durée, transition et raccord spatial.
4. Rencontres : identité, position, ordre, animation, point faible, fenêtre de tir, projectiles et conséquences.
5. Interactions : scientifiques, récompenses, événements de portes, score, vies et déclencheurs de route.
6. Audio, sous-titres, boss, résultats et événements cinématiques.
7. Référence autorisée : capture ou métrique **stockée hors dépôt public**, timestamp, plateforme/version, méthode et marge d'erreur.
8. Statut : `TBD-AUTH` / `mesuré` / `implémenté` / `validé en jeu` / `1:1 certifié`.

## Priorités
- P0 : décisions 2 et 6 encore substituées ; décisions 3, 4 et 9 provisoires.
- P0 : continuité physique du monde entre les nœuds et surfaces praticables réellement construites.
- P1 : 37 acteurs V2 à migrer en vrais clips V3 ; ne pas compter des directions miroir comme des dessins indépendants.
- P1 : revue visuelle Web et exports Windows/Linux actualisés.

## Critères de livraison
`npm test`, `npm run qa`, `npm run qa:web`, `npm run verify:web` et test Godot headless doivent réussir sur le commit livré. Une capture de comparaison en jeu à résolution native et les preuves de référence sont obligatoires pour toute affirmation de fidélité 1:1. Les licences, captures commerciales et ROM ne doivent pas être ajoutées au dépôt public.

Ce document est un plan de production et de contrôle, pas une nouvelle carte jouable ni un ensemble de ressources graphiques générées.

## Inventaire vérifié des graphes de routes
Les quatre fichiers `data/routes/chapter_0X_route_graph.json` déclarent respectivement 14, 10, 11 et 7 nœuds. Ces comptes décrivent les graphes de référence et ne doivent pas être confondus avec les 43 nœuds de la timeline runtime.

### Chapitre 2 — ordre technique actuel
`chain_plate` → `underground_passage` ou `great_doors` → `library_rescue` → `raised_bridge` ou `lower_stairs` → `corridor_cache` → `roof_approach` → `roof_rescue` → `hangedman_battle`.

### Chapitre 3 — inventaire
`elevator_switch`, `left_elevator`, `right_elevator`, `back_attack_rescue`, `security_door`, `vent_key_route`, `steel_door_choice`, `steel_door_upper_route`, `steel_door_lower_route`, `curien_tunnel`, `hermit_battle`.

### Chapitre 4 — inventaire
`chariot_rematch`, `hangedman_rematch`, `bonus_gate`, `bonus_room`, `final_waves`, `curien_confrontation`, `magician_battle`.

**Point de contrôle :** confronter chaque graphe JSON à la timeline runtime avant de modifier la géométrie ou les déclencheurs. Les graphes déclaratifs ne prouvent pas à eux seuls la durée, les animations, les positions ou l'authenticité 1:1.
