# The House of the Dead 2.5D

An original fan-made recreation of the 1997 arcade rail shooter, built with Godot 4.7.1. Organic actors use animated sprites inside a real 3D world: perspective, occlusion, camera rails, body hit zones and collisions remain three-dimensional.

The current worktree V2 visual contract provides 38 unique 2048×2048 RGBA directional atlases. Each atlas contains eight views — front, front-left, left, back-left, back, back-right, right and front-right — and eight states — idle, three movement poses, wind-up, strike, hit and fall/death. This yields 64 cells per actor and 2,432 addressable cells. The set now includes dedicated `scientist_male_blue`, `scientist_male_gray` and `scientist_female_lab` atlases.

The project includes a playable four-chapter campaign with branches, scientists, breakables, Chariot, Hangedman, Hermit, Magician, final-chapter rematches, three endings, credits, score, lives, ammunition, continues and two-player local co-op. Training, Boss Rush, Chapter Select and a local leaderboard are also available.

## Development after v0.5.0 — connected continuity

The worktree now connects consecutive rails through shared spatial origins and an exact **9-metre planar** join. A temporary physical `connector_root` provides a floor, walls, threshold arch, collisions and two halves using the outgoing and incoming set materials. The mask begins at **0.79**, before the known Steel Door wall intersection. Chapter 2 now follows `raised_bridge`/`lower_stairs` -> `corridor_cache` -> `roof_approach` -> `roof_rescue` -> Hangedman.

The Curien sequence now genuinely precedes Magician: firing and boss damage stay locked for **7.13 seconds**, then the dynamic fight starts; boss defeat holds the final image for **0.50 seconds** before advancing the route. The 7.13-second value is an `internal_sync_only_tbd_authorized_build` marker, not a certified arcade timestamp. The QA launcher also fails on Godot script, parse, compilation or load diagnostics even if the process returns zero.

Final local QA passes **313/313**, with deterministic core **1,281 assertions**, Curien finale **60 assertions** (including data-driven cinematic locks, blocked gameplay input while paused, frozen boss/subtitle clocks and immediate residual-projectile retirement), green sequence connector, complete campaign, HUD and gameplay smokes, and content audit **889 checks / 6 warnings / 0 errors**. The fresh accessibility-patched Web export passes **299/299** plus `verify:web` and measures **122,287,366 bytes** across nine files. Gameplay commit `e884f77` is on GitHub `main`, its CI is green, and verified Vercel deployment `dpl_3uZ9rTZBRyvau7mgwBwePsmFU6kr` is [live](https://the-house-of-the-dead-25d.vercel.app). Boundaries remain explicit: no authorized reference build/timestamps (`TBD-AUTH`), node sets are still reconstructed despite the connector, Sprite V2 still exposes only eight semantic states per direction with mirrored right-side views, and visual browser automation was unavailable. No new release tag was created; the v0.5.0 evidence below remains historical and immutable.

## Public v0.5.0 release — pursuit, collisions and route pacing

[GitHub Release v0.5.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.5.0) is published from immutable tag `v0.5.0` at exact commit [`6d84764`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/6d84764745102b95e22b2462eeaa364103678c0b). [Release checks](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/33136431022) passed, and the verified Web build is live on [Vercel](https://the-house-of-the-dead-25d.vercel.app). Melee enemies converge on X/Z, stay in front of the camera and repeat approach, wind-up, attack and recovery. OBB volumes block actors and visible projectiles. A Hermite connector joins camera poses between nodes, while a generic ground solver keeps actors on detected walkable surfaces.

Local co-op threats select one living player, and a launched projectile keeps that recipient instead of silently moving to the survivor; civilian-authored threats never fall back to a player. Boss attacks require a complete 0.90-second continuously visible telegraph, reset after any visibility loss. Dead actors leave the active set immediately while visible fades are tracked separately until deferred cleanup; sprite-less actors and full scene cleanup follow the same guaranteed retirement path.

The v0.5.0 campaign contains **43 nodes**, **53 edges** and **8/4/8/2 routes** across Chapters 1–4. It declares **98 ordinary spawns**, with **68–71** selected per route, **20 civilian placements / 15 encountered**, **34 multi-wave encounters**, **14 prop profiles / 105 placements / 9 state events**, eight breakables and four hidden lives. The final wave of every multi-wave encounter starts at or after **82%** of its budget. Fixed runtime outside dynamic boss fights is **106.5 / 97.4 / 93.1 / 40.4 seconds** for Chapters 1–4; these figures are not campaign wall-clock duration.

Release evidence is: `npm test` **295/295**, Godot deterministic core **975 assertions**, complete QA **313/313**, Web QA **299/299**, environment verifier **1,977 assertions**, and content audit **889 checks / 6 known warnings / 0 errors**. Windows is **191,497,768 bytes** (`b1411c67ae6c9636bd00ac6557c4fbe8f6206cff2a23ec843bce57d4015ea280`) and remained alive after a nine-second startup check; Linux is **155,862,360 bytes** (`1e39c76ec8c168f6cc922683f8020123621c7b0384285f3c4ef38e80f4bc511b`). Web is **9 files / 122,236,534 bytes**, including PCK **82,392,140** (`b85a0d00b07178efe07bcd3b8fec872fe66e735d6c48a1ff9edbbd5d4e2ca7f3`), WASM **39,513,091** (`35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277`) and HTML **5,590** (`e9cb46807cdf85ceeb0c40e0dfbbf87232b5a7c7ccb3c427fe881f2b76fc6c1f`). The extracted public source archive independently passes the same 295/295 repository suite.

Fresh public browser QA loads the menu and real gameplay at 1280×720 with `crossOriginIsolated=true`, one 1280×720 `role=main` canvas with the correct accessible label, every resource at HTTP 200, no page error or framework overlay, and only normal Godot/WebGL informational logs. The Hermite connector does not make the world persistent: decor is rebuilt between nodes, and the ground solver remains generic. Decisions #2/#6 are inaccurate substitutes; #3/#4/#9 remain provisional. The 38 atlases expose 2,432 cells but only eight semantic states per direction, with several mirrored right-side views. Three enemy variants remain non-arcade-exact. Without `licensed_assets/` and `reference_build/`, exact Sega fidelity is not certified.

## Public v0.4.0 release — route and component integrity

[GitHub release v0.4.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.4.0) is published from exact commit [`b3b8b3b`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/b3b8b3b37a027189a83afaa21e6e959debbd99a5), validated by CI. This wave aligns the route graphs with the playable timeline, requires the exact destroyed-object ID for breakable-driven branches, activates dedicated pickup, breakable, civilian and enemy-spawn components, and stabilizes directional-sprite changes with hysteresis. The verified Vercel production is live at [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app).

## Previous release — v0.3.0 attack readability and environment content

The v0.3.0 release fixes damage that could appear invisible. Ordinary and boss-support melee attacks must now be visible, complete their wind-up and reach real 3D contact. The remaining depth-only legacy damage path has been removed. Ranged attacks use visible, destructible and shootable projectiles with a minimum on-screen travel distance before impact. Chariot and Hangedman physically lunge during their strikes; Hermit and Magician launch their dedicated projectiles.

Prop proportions were recalibrated. The garden lamp has readable lit/unlit states, and white alpha remnants were cleaned from the lamp, estate gate, chandelier and wall sconce. The gate, doors and laboratory tanks now change state through runtime events; saving a scientist can no longer be mistaken for destroying an object.

The final chapter's bonus room now contains twelve real 3D collectibles — four lives, three golden frogs and five medals — with no enemy or crate proxy. All 25 enemy profiles have a runtime path and all seven projectile families are reachable. Three variant placements (`sam_a1`, `kenfis_f1`, `name_g2`) remain deliberately marked provisional until they can be compared against an authorized arcade reference.

Four original OpenAI decorative effects, each an eight-frame RGBA strip, are integrated: falling drips, flowing water, electrical arcs and monitor scan. The Curien/Magician finale also includes a visible attack, Curien's recoil and fall, and a persistent grounded body. Complete local QA passes 282/282 after the attack-readability regressions; the extracted public source ZIP independently passes 272/272 without optional private reports.

Exact commit/tag [`8add70a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/8add70a31a751928ea12c247ca584d8b030b2139) is published through [GitHub release v0.3.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.3.0), whose five remote assets match local sizes and SHA-256 digests. Vercel production `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` is `Ready` at [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app); root, PCK and WASM are byte-identical to the verified build and public Chromium reports no page error.

## Quick start

1. Open `project.godot` with Godot 4.7.1 stable.
2. Run the main scene.
3. Select Authentic Arcade, Local Co-op, Training or Boss Rush.

- Player 1: mouse, left click to fire, right click or `R` to reload.
- Player 2: arrow keys, `F` to fire, `G` to reload.
- Controllers: right stick, A to fire, B to reload, Start to join.
- `1`/`2`: join; `Escape`: pause.
- In authentic 4:3 framing, firing in a side pillar reloads off-screen.

## Architecture and builds

The campaign is driven by `data/runtime/campaign_timeline.json`, route graphs by `data/routes/` and V2 atlases by `data/assets/sprite_manifest.json`. Specialized systems live under `src/core`, `src/rail`, `src/gameplay` and `src/tools`. Missing commercial assets are recorded in `docs/MISSING_LICENSED_ASSETS.md`.

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

## v0.2.1 distribution hotfix — August 25, 2026

v0.2.1 fixes public source-ZIP self-validation: private ImageGen reports remain intentionally ignored while tracked manifests and provenance stay mandatory. It also removes Windows-only path separators that blocked the environment verifier on Linux.

Final GitHub Actions run [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344) passes `npm test`, `qa:web` and `verify:web` from a clean Linux checkout. Gameplay content and exported binaries are identical to v0.2.0; [release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1) is the recommended source distribution without moving or rewriting v0.2.0.

The release resolves to exact commit/tag `c13d525d63dc9ef4e92d30c0ab5851047fa76f66`; final run [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344) is green. All five GitHub files are `uploaded`: Source 227,864,129 bytes (`1c402e67…`), Windows 90,978,140 (`17c0b671…`), Linux 81,014,969 (`69bec7bf…`), Web 62,151,092 (`8c559faf…`) and the 421-byte manifest. Vercel deployment `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` is `Ready`; root/PCK/WASM return 200 and public Chromium remains error-free with isolation enabled.

## Public v0.2.0 release — August 24, 2026

The v0.2.0 wave provides 38 directional atlases/2,432 cells, 25 unique enemy profiles, 20 individual environment materials, 33 environment nodes, six destructibles, 14 props, seven projectile cutouts, three HUD families, four boss weak-point diagrams and 28 original procedural audio cues. `npm.cmd test` passes 271/271 and the complete `npm.cmd run qa` orchestration passes 280/280.

Warning-free runtime smokes validate two players, four chapters, six shots, off-screen reload, destructible and non-destructible projectile rules, independent gamepad aim, `+120`/`-100` score events, `COD` initials and the complete campaign: Chariot, Hangedman, Hermit, both rematches, Magician, 15/15 scientists, ending and credits.

The v0.2.0 exports measure 161,321,616 bytes on Windows, 125,686,208 bytes on Linux and 92,060,382 bytes for nine Web files. PCK is 52,215,988 bytes and WASM is 39,513,091 bytes. The Windows executable remained alive during an eight-second startup smoke; `qa:web` passes 275/275 and `verify:web` is OK.

Local Chromium QA served through Vercel with production headers runs Godot 4.7.1 single-threaded WebGL2 with `crossOriginIsolated=true`. It exposed and led to a fix for using `FileAccess` with imported textures; asset loaders now use `ResourceLoader`. After re-export, the console remains error-free, the accessible canvas measures 1258×622, and the menu, P1 start, environments, HUD, continue and pause are visible. No network resource remains blocked.

v0.2.0 is published at exact commit [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21) through the [v0.2.0 GitHub tag and release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0). The Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969) and Web (62,151,092) archives are uploaded, and their remote SHA-256 digests match the local files. Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` is `Ready` at [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app): root, PCK and WASM return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. Public Chromium QA confirms `crossOriginIsolated=true`, a 1258×622 canvas, visible menu, P1 start, gameplay and continue, with zero console or page errors.

The compact eight-state cycle per direction is a detailed playable baseline, not a complete licensed arcade animation library. The remaining unverified gates are installation on a clean physical Windows machine, physical light guns, deep profiling on named hardware and exact comparison against a licensed reference build.

## Legal status

This repository contains no ROM, arcade extraction, commercial music, voices, logos or geometry. Included visuals are original fan-made OpenAI ImageGen work or assets owned by the same user. This project is not affiliated with Sega.
