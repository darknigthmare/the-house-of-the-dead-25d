# The House of the Dead 2.5D

Recréation fan-made originale du rail shooter d'arcade de 1997, construite avec Godot 4.7.1. Les acteurs organiques sont des sprites animés placés dans un monde 3D réel : perspective, occultation, rails de caméra, hitboxes corporelles et collisions restent tridimensionnels.

Le pipeline visuel V2 fournit 35 atlas directionnels uniques de 2048×2048 RGBA. Chaque atlas contient huit vues — avant, avant-gauche, gauche, arrière-gauche, arrière, arrière-droite, droite et avant-droite — et huit états — repos, trois temps de déplacement, préparation, frappe, impact et chute/mort. Cela représente 64 cellules par acteur et 2 240 cellules contrôlées au total. Le résolveur sélectionne automatiquement la vue relative à la caméra pour produire l'effet de fausse 3D demandé.

Le projet propose une campagne jouable en quatre chapitres avec embranchements, scientifiques à sauver, objets destructibles, Chariot, Hangedman, Hermit, Magician, les rematchs du dernier chapitre, trois fins, crédits, score, vies, munitions, continues et coopération locale à deux joueurs. Entraînement, Boss Rush, sélection de chapitre et classement local sont également accessibles depuis le menu; une partie non-démo terminée demande trois initiales avant d'enregistrer son score.

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

## Publication vérifiée — 21 août 2026

`npm.cmd test` passe 252/252 et `npm.cmd run qa` 257/257, avec 232 assertions cœur, 57 assertions d'atomicité du manifeste et un smoke directionnel couvrant 35 liaisons, sept représentants et les huit directions. Les 35 atlas de 2048×2048 RGBA contiennent 64 cellules chacun, soit 2 240 cellules; les 25 ennemis disposent de profils dédiés. L'audit visuel final passe après réparation des découpes, de la cellule de mort de Samson et des franges chromatiques.

Les smokes valident deux joueurs, quatre chapitres, six tirs, le rechargement hors écran, les visées manette indépendantes, les scores `+120`/`-100`, les initiales `COD` et la campagne complète : Chariot, Hangedman, Hermit, les deux rematchs, Magician, 15/15 scientifiques, fin et crédits. Deux instances `ObjectDB` restent signalées à l'arrêt des smokes gameplay/campagne sans bloquer leur succès.

Les exports finaux mesurent 202 088 128 octets sous Windows (démarrage headless validé), 166 452 720 octets sous Linux et 132 826 890 octets pour neuf fichiers Web. Le PCK mesure 92 982 496 octets, sous la limite de 100 000 000 avec une marge de 7 017 504 octets; le WASM mesure 39 513 091 octets. `qa:web` passe 256/256 et `verify:web` est OK.

La version de production Vercel exécute Godot 4.7.1 WebGL2 mono-thread avec `crossOriginIsolated=true`. Le document, le WASM et le PCK répondent en HTTP 200, le WASM utilise `application/wasm`, et les en-têtes COOP/COEP sont présents. Le contrôle Chromium de production affiche le titre puis P1/P2 avec deux HUD et deux viseurs; le réseau charge PCK/WASM en 200, la console et la page restent à zéro erreur, et Axe retourne 23 passes pour 0 violation. Les mesures menu/cache locales — TTFB 2,39 ms, FCP/LCP 99,13 ms, CLS 0 — ne constituent pas une mesure de campagne complète.

Le dépôt public est [darknigthmare/the-house-of-the-dead-25d](https://github.com/darknigthmare/the-house-of-the-dead-25d), au commit [`d98487b`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d98487bca5592418e80342221f671538ed40058a). L'[exécution GitHub Actions 32434278324](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32434278324) est verte (`npm test`, `qa:web`, `verify:web`, 20 s). La production est disponible sur [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app) via le déploiement `dpl_Hs23gpsUfidKJeEDPs1K45NeWYyW`, état `READY`, construit en 980 ms. La [release GitHub v0.1.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.1.0) est la cible des archives produites depuis ce même état vérifié.

Le cycle compact de huit états par direction est une base détaillée et jouable, pas une bibliothèque complète des animations licenciées de la borne. Restent hors validation actuelle : l'installation sur une machine Windows physique propre, les pistolets lumineux physiques, le profilage approfondi sur matériel nommé et la comparaison exacte avec une version de référence sous licence.

## Statut légal

Le dépôt ne contient ni ROM, ni extraction de la borne, ni musique, voix, logo ou géométrie commerciale. Les visuels livrés sont des créations fan-made originales OpenAI ImageGen ou des ressources appartenant au même utilisateur. Le projet n'est pas affilié à Sega.
