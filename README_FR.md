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

## Instantané prépublication — 21 août 2026

`npm.cmd test` passe 252/252 et `npm.cmd run qa` 257/257, avec 232 assertions cœur, 57 assertions d'atomicité du manifeste et un smoke directionnel couvrant 35 liaisons, sept représentants et les huit directions. Les 35 atlas de 2048×2048 RGBA contiennent 64 cellules chacun, soit 2 240 cellules; les 25 ennemis disposent de profils dédiés. L'audit visuel final passe après réparation des découpes, de la cellule de mort de Samson et des franges chromatiques.

Les smokes valident deux joueurs, quatre chapitres, six tirs, le rechargement hors écran, les visées manette indépendantes, les scores `+120`/`-100`, les initiales `COD` et la campagne complète : Chariot, Hangedman, Hermit, les deux rematchs, Magician, 15/15 scientifiques, fin et crédits. Deux instances `ObjectDB` restent signalées à l'arrêt des smokes gameplay/campagne sans bloquer leur succès.

Les exports finaux mesurent 202 088 128 octets sous Windows (démarrage headless validé), 166 452 720 octets sous Linux et 132 826 890 octets pour neuf fichiers Web. Le PCK mesure 92 982 496 octets, sous la limite de 100 000 000 avec une marge de 7 017 504 octets; le WASM mesure 39 513 091 octets. `qa:web` passe 256/256 et `verify:web` est OK.

Dans Chromium local via agent-browser 0.34, Godot 4.7.1 WebGL2 mono-thread a `crossOriginIsolated=true`, PCK/WASM répondent en 200 et le jeu montre le menu puis P1/P2 avec deux HUD et deux viseurs. Les formats 1280×720, 390×844 et 844×390 passent sans erreur de page. Axe 4.12 retourne 23 passes et 0 violation. Les mesures menu/cache — TTFB 2,39 ms, FCP/LCP 99,13 ms, CLS 0 — ne constituent pas une mesure de campagne complète.

Le cycle compact de huit états par direction est une base détaillée et jouable, pas une bibliothèque complète des animations licenciées de la borne. Les périphériques physiques, une machine Windows propre, les archives/SHA-256, GitHub, Vercel et la QA publique restent en attente.

## Statut légal

Le dépôt ne contient ni ROM, ni extraction de la borne, ni musique, voix, logo ou géométrie commerciale. Les visuels livrés sont des créations fan-made originales OpenAI ImageGen ou des ressources appartenant au même utilisateur. Le projet n'est pas affilié à Sega.
