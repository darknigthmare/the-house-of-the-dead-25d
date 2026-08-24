# The House of the Dead 2.5D

Recréation fan-made originale du rail shooter d'arcade de 1997, construite avec Godot 4.7.1. Les acteurs organiques sont des sprites animés placés dans un monde 3D réel : perspective, occultation, rails de caméra, hitboxes corporelles et collisions restent tridimensionnels.

Le contrat visuel V2 de l’arbre de travail fournit 38 atlas directionnels uniques de 2048×2048 RGBA. Chaque atlas contient huit vues — avant, avant-gauche, gauche, arrière-gauche, arrière, arrière-droite, droite et avant-droite — et huit états — repos, trois temps de déplacement, préparation, frappe, impact et chute/mort. Cela représente 64 cellules par acteur et 2 432 cellules adressables. Le lot comprend désormais les atlas dédiés `scientist_male_blue`, `scientist_male_gray` et `scientist_female_lab`.

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

## Validation locale v0.2.0 — 24 août 2026

La vague v0.2.0 fournit 38 atlas directionnels/2 432 cellules, 25 profils ennemis uniques, 20 matériaux de décor individuels, 33 nœuds d’environnement, six destructibles, 14 props, sept projectiles, trois familles HUD, quatre diagrammes de point faible et 28 cues audio procéduraux originaux. `npm.cmd test` passe 271/271 et l’orchestration complète `npm.cmd run qa` passe 280/280.

Les smokes sans avertissement de fuite valident deux joueurs, quatre chapitres, six tirs, le rechargement hors écran, les projectiles destructibles ou non, les visées manette indépendantes, les scores `+120`/`-100`, les initiales `COD` et la campagne complète : Chariot, Hangedman, Hermit, les deux rematchs, Magician, 15/15 scientifiques, fin et crédits.

Les exports v0.2.0 mesurent 161 321 616 octets sous Windows, 125 686 208 octets sous Linux et 92 060 382 octets pour neuf fichiers Web. Le PCK mesure 52 215 988 octets et le WASM 39 513 091 octets. Le build Windows est resté actif pendant le smoke de démarrage de huit secondes; `qa:web` passe 275/275 et `verify:web` est OK.

La QA Chromium locale, servie par Vercel avec les en-têtes de production, exécute Godot 4.7.1 WebGL2 mono-thread avec `crossOriginIsolated=true`. Elle a révélé puis fait corriger l’usage de `FileAccess` pour des textures importées; les loaders utilisent désormais `ResourceLoader`. Après réexport, la console reste sans erreur, le canvas accessible mesure 1258×622, et le menu, le démarrage P1, les décors, le HUD, le continue et la pause sont visibles. Aucune ressource réseau n’est bloquée.

Le dépôt public reste [darknigthmare/the-house-of-the-dead-25d](https://github.com/darknigthmare/the-house-of-the-dead-25d) et la production historique v0.1.0 reste disponible sur [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app). À cet instant de validation, la v0.2.0 est une candidate locale vérifiée : son commit, ses archives, son tag, sa release GitHub et son nouveau déploiement ne sont pas encore revendiqués.

Le cycle compact de huit états par direction est une base détaillée et jouable, pas une bibliothèque complète des animations licenciées de la borne. Restent hors validation actuelle : l'installation sur une machine Windows physique propre, les pistolets lumineux physiques, le profilage approfondi sur matériel nommé et la comparaison exacte avec une version de référence sous licence.

## Statut légal

Le dépôt ne contient ni ROM, ni extraction de la borne, ni musique, voix, logo ou géométrie commerciale. Les visuels livrés sont des créations fan-made originales OpenAI ImageGen ou des ressources appartenant au même utilisateur. Le projet n'est pas affilié à Sega.
