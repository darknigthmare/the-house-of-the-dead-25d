# The House of the Dead 2.5D

Recréation fan-made originale du rail shooter d'arcade de 1997, construite avec Godot 4.7.1. Les acteurs organiques sont des sprites animés placés dans un monde 3D réel : perspective, occultation, rails de caméra, hitboxes corporelles et collisions restent tridimensionnels.

Le contrat visuel V2 de l’arbre de travail fournit 38 atlas directionnels uniques de 2048×2048 RGBA. Chaque atlas contient huit vues — avant, avant-gauche, gauche, arrière-gauche, arrière, arrière-droite, droite et avant-droite — et huit états — repos, trois temps de déplacement, préparation, frappe, impact et chute/mort. Cela représente 64 cellules par acteur et 2 432 cellules adressables. Le lot comprend désormais les atlas dédiés `scientist_male_blue`, `scientist_male_gray` et `scientist_female_lab`.

Le projet propose une campagne jouable en quatre chapitres avec embranchements, scientifiques à sauver, objets destructibles, Chariot, Hangedman, Hermit, Magician, les rematchs du dernier chapitre, trois fins, crédits, score, vies, munitions, continues et coopération locale à deux joueurs. Entraînement, Boss Rush, sélection de chapitre et classement local sont également accessibles depuis le menu; une partie non-démo terminée demande trois initiales avant d'enregistrer son score.

## Candidate locale v0.5.0 — poursuite, collisions et rythme des routes

L’arbre de travail annonce `0.5.0`. Des exports locaux Windows/Linux/Web ont été produits et vérifiés, mais aucun commit/tag de release, archive de livraison, GitHub Release ni déploiement Vercel v0.5.0 n’est encore revendiqué. Les ennemis de mêlée convergent sur X/Z, restent devant la caméra et répètent approche, anticipation, attaque et récupération. Les volumes OBB bloquent acteurs et projectiles visibles. Un connecteur par interpolation d’Hermite relie les poses caméra entre deux nœuds et un solveur générique maintient les acteurs sur les surfaces praticables détectées.

En coopération locale, une menace choisit un joueur vivant et un projectile lancé conserve ce destinataire au lieu de basculer silencieusement vers le survivant ; une menace assignée à un civil ne se rabat jamais sur un joueur. Chaque attaque de boss exige un télégraphe entièrement visible et continu de 0,90 seconde, réinitialisé après toute perte de visibilité. Les acteurs morts quittent immédiatement la collection active, tandis que leur disparition visible reste suivie séparément jusqu’au nettoyage différé ; les acteurs sans sprite et le nettoyage global suivent la même retraite garantie.

La campagne candidate contient **43 nœuds**, **53 arêtes** et **8/4/8/2 routes** dans les chapitres 1 à 4. Elle déclare **98 apparitions ordinaires**, dont **68 à 71** suivant le parcours, **20 civils placés / 15 rencontrés**, **34 rencontres multi-vagues**, **14 profils de props / 105 placements / 9 événements d’état**, huit destructibles et quatre vies cachées. La dernière vague d’une rencontre multi-vagues commence à au moins **82 %** de son budget. Les budgets fixes hors boss dynamiques sont **106,5 / 97,4 / 93,1 / 40,4 secondes** pour les chapitres 1 à 4 : ils ne représentent pas la durée murale de la campagne.

Les preuves locales actuelles sont : `npm test` **295/295**, cœur déterministe Godot **975 assertions**, orchestration QA **313/313**, QA Web **299/299**, vérificateur d’environnement **1 977 assertions**, audit de contenu **889 contrôles / 6 avertissements connus / 0 erreur**. Windows mesure **191 497 768 octets** (`b1411c67ae6c9636bd00ac6557c4fbe8f6206cff2a23ec843bce57d4015ea280`) et est resté actif après neuf secondes de démarrage ; Linux mesure **155 862 360 octets** (`1e39c76ec8c168f6cc922683f8020123621c7b0384285f3c4ef38e80f4bc511b`). Le Web contient **9 fichiers / 122 236 534 octets**, dont un PCK de **82 392 140** (`b85a0d00b07178efe07bcd3b8fec872fe66e735d6c48a1ff9edbbd5d4e2ca7f3`), un WASM de **39 513 091** (`35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277`) et un HTML de **5 590 octets** (`e9cb46807cdf85ceeb0c40e0dfbbf87232b5a7c7ccb3c427fe881f2b76fc6c1f`).

La QA navigateur locale fraîche charge le menu puis une vraie partie à 1280×720 avec `crossOriginIsolated=true`, un unique canvas 1280×720 `role=main` portant le bon libellé accessible, toutes les ressources locales en HTTP 200, aucune erreur de page ni overlay, et uniquement les logs d’information Godot/WebGL normaux. Le raccord Hermite ne rend pas le monde persistant : le décor est encore reconstruit entre les nœuds, et le solveur de sol reste générique. Les décisions #2/#6 sont des substituts inexacts; #3/#4/#9 restent provisoires. Les 38 atlas fournissent 2 432 cellules, mais seulement huit états sémantiques par direction et plusieurs vues droites miroitées. Trois variantes ennemies restent non arcade-exactes. Sans `licensed_assets/` ni `reference_build/`, aucune fidélité Sega exacte n’est certifiée.

## Release publique v0.4.0 — intégrité des routes et des composants

La [release GitHub v0.4.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.4.0) est publiée depuis le commit exact [`b3b8b3b`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/b3b8b3b37a027189a83afaa21e6e959debbd99a5), validé par la CI. Cette vague aligne les graphes de routes sur la timeline jouable, exige l’identifiant exact de l’objet détruit pour les embranchements associés, active les contrôleurs dédiés des pickups, destructibles, scientifiques et apparitions ennemies, et stabilise les changements de direction des sprites par hystérésis. La production Vercel vérifiée est disponible sur [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app).

## Release précédente — v0.3.0, lisibilité des attaques et contenu d’environnement

La release v0.3.0 corrige les dégâts qui pouvaient sembler invisibles. Une attaque de mêlée ordinaire ou de soutien de boss doit désormais être visible, terminer sa préparation et atteindre un vrai contact 3D. L’ancien chemin basé uniquement sur la profondeur a été supprimé. Les attaques à distance utilisent des projectiles visibles, destructibles et tirables, avec une distance minimale de trajet à l’écran avant tout impact. Chariot et Hangedman avancent physiquement lors de leurs frappes; Hermit et Magician lancent leurs projectiles dédiés.

Les proportions des props ont été recalibrées. La lampe de jardin possède des états allumé/éteint lisibles, et les résidus blancs des transparences ont été nettoyés sur la lampe, la grille du domaine, le lustre et l’applique murale. La grille, les portes et les réservoirs de laboratoire changent maintenant d’état via des événements runtime; un sauvetage de scientifique ne peut plus être confondu avec la destruction d’un objet.

La salle bonus du chapitre final contient désormais douze collectibles réels dans le monde 3D — quatre vies, trois grenouilles dorées et cinq médailles — sans ennemi ni caisse de substitution. Les 25 profils ennemis disposent d’un chemin runtime et les sept familles de projectiles sont atteignables. Trois placements de variantes (`sam_a1`, `kenfis_f1`, `name_g2`) restent volontairement marqués comme provisoires jusqu’à comparaison avec une référence arcade autorisée.

Quatre effets décoratifs originaux OpenAI, chacun en bande RGBA de huit images, sont intégrés : gouttes, écoulement d’eau, arc électrique et balayage de moniteur. La finale Curien/Magician comprend aussi une attaque visible, le recul, la chute et le maintien au sol de Curien. La QA locale complète passe 282/282 après les régressions de lisibilité des attaques; le ZIP source public extrait repasse 272/272 sans les rapports privés optionnels.

Le commit/tag exact [`8add70a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/8add70a31a751928ea12c247ca584d8b030b2139) est publié dans la [release GitHub v0.3.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.3.0), dont les cinq assets distants correspondent aux tailles et SHA-256 locaux. La production Vercel `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` est `Ready` sur [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app); racine, PCK et WASM sont octet pour octet identiques au build vérifié et Chromium public ne remonte aucune erreur de page.

## Démarrage rapide

1. Ouvrir `project.godot` avec Godot 4.7.1 stable.
2. Lancer la scène principale.
3. Choisir Arcade Authentique, Coop locale, Entraînement ou Boss Rush.

- Joueur 1 : souris, clic gauche pour tirer, clic droit ou `R` pour recharger.
- Joueur 2 : flèches, `F` pour tirer, `G` pour recharger.
- Manettes : stick droit, A pour tirer, B pour recharger, Start pour rejoindre.
- `1`/`2` : rejoindre; `Échap` : pause.
- En cadrage 4:3, tirer dans une barre latérale recharge hors écran.

## Architecture et construction

La campagne est pilotée par `data/runtime/campaign_timeline.json`, les graphes par `data/routes/` et les atlas par `data/assets/sprite_manifest.json`. Les systèmes spécialisés sont sous `src/core`, `src/rail`, `src/gameplay` et `src/tools`. Les ressources commerciales absentes sont consignées dans `docs/MISSING_LICENSED_ASSETS.md`.

```powershell
npm.cmd test
npm.cmd run qa
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Windows Desktop'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Linux'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Web'
npm run fix:web-accessibility
npm.cmd run qa:web
npm.cmd run verify:web
```

## Correctif de distribution v0.2.1 — 25 août 2026

La v0.2.1 corrige l’autovalidation du ZIP source public : les rapports ImageGen privés restent volontairement ignorés, tandis que les manifestes et provenances suivis par Git restent obligatoirement vérifiés. Elle corrige aussi les séparateurs de chemins Windows qui bloquaient le vérificateur de décors sous Linux.

Le run GitHub Actions final [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344) passe `npm test`, `qa:web` et `verify:web` sur un checkout Linux propre. Le contenu de jeu et les binaires exportés sont identiques à v0.2.0; la [release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1) devient la distribution source recommandée sans déplacer ni réécrire v0.2.0.

La release pointe sur le commit/tag exact `c13d525d63dc9ef4e92d30c0ab5851047fa76f66`; le run final [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344) est vert. Les cinq fichiers GitHub sont `uploaded` : Source 227 864 129 octets (`1c402e67…`), Windows 90 978 140 (`17c0b671…`), Linux 81 014 969 (`69bec7bf…`), Web 62 151 092 (`8c559faf…`) et manifeste 421 octets. Le déploiement Vercel `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` est `Ready`; racine/PCK/WASM répondent 200 et Chromium public reste sans erreur avec isolation active.

## Release publique v0.2.0 — 24 août 2026

La vague v0.2.0 fournit 38 atlas directionnels/2 432 cellules, 25 profils ennemis uniques, 20 matériaux de décor individuels, 33 nœuds d’environnement, six destructibles, 14 props, sept projectiles, trois familles HUD, quatre diagrammes de point faible et 28 cues audio procéduraux originaux. `npm.cmd test` passe 271/271 et l’orchestration complète `npm.cmd run qa` passe 280/280.

Les smokes sans avertissement de fuite valident deux joueurs, quatre chapitres, six tirs, le rechargement hors écran, les projectiles destructibles ou non, les visées manette indépendantes, les scores `+120`/`-100`, les initiales `COD` et la campagne complète : Chariot, Hangedman, Hermit, les deux rematchs, Magician, 15/15 scientifiques, fin et crédits.

Les exports v0.2.0 mesurent 161 321 616 octets sous Windows, 125 686 208 octets sous Linux et 92 060 382 octets pour neuf fichiers Web. Le PCK mesure 52 215 988 octets et le WASM 39 513 091 octets. Le build Windows est resté actif pendant le smoke de démarrage de huit secondes; `qa:web` passe 275/275 et `verify:web` est OK.

La QA Chromium locale, servie par Vercel avec les en-têtes de production, exécute Godot 4.7.1 WebGL2 mono-thread avec `crossOriginIsolated=true`. Elle a révélé puis fait corriger l’usage de `FileAccess` pour des textures importées; les loaders utilisent désormais `ResourceLoader`. Après réexport, la console reste sans erreur, le canvas accessible mesure 1258×622, et le menu, le démarrage P1, les décors, le HUD, le continue et la pause sont visibles. Aucune ressource réseau n’est bloquée.

La v0.2.0 est publiée au commit exact [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21) via le [tag et la release GitHub v0.2.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0). Les archives Source (227 860 921 octets), Windows (90 978 140), Linux (81 014 969) et Web (62 151 092) sont téléversées; leurs SHA-256 distants concordent avec les fichiers locaux. Le déploiement Vercel `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` est `Ready` sur [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app) : racine, PCK et WASM répondent en HTTP 200, le WASM utilise `application/wasm`, et COOP/COEP sont présents. La QA Chromium publique confirme `crossOriginIsolated=true`, un canvas 1258×622, le menu, le démarrage P1, le gameplay et le continue visibles, sans erreur console ni page.

Le cycle compact de huit états par direction est une base détaillée et jouable, pas une bibliothèque complète des animations licenciées de la borne. Restent hors validation actuelle : l'installation sur une machine Windows physique propre, les pistolets lumineux physiques, le profilage approfondi sur matériel nommé et la comparaison exacte avec une version de référence sous licence.

## Statut légal

Le dépôt ne contient ni ROM, ni extraction de la borne, ni musique, voix, logo ou géométrie commerciale. Les visuels livrés sont des créations fan-made originales OpenAI ImageGen ou des ressources appartenant au même utilisateur. Le projet n'est pas affilié à Sega.
