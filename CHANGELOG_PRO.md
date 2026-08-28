# Professional Changelog

## 0.5.0 — pursuit, collision and route-density integrity — published 2026-08-28

- Updated melee pursuit so enemies converge on both X and Z, stay in front of the camera during approach, and cycle through wind-up, attack, recovery and re-attack instead of stopping after one attempt.
- Added oriented OBB collision volumes for walls, rails, columns, doors, shelves and relevant props. Actor movement is constrained by these volumes and visible hostile projectiles are blocked instead of passing through authored obstacles.
- Added HUD text sanitization so internal IDs and markup cannot leak into player-facing labels.
- Expanded the authored campaign to **43 nodes**, **53 edges** and **8/4/8/2 routes** for Chapters 1–4. It now declares **98 ordinary spawn entries**, with **68–71** selected per run, **20 civilian placements / 15 encountered per run**, **34 multi-wave encounters**, and **14 prop profiles / 105 placements / 9 state events**. Every multi-wave encounter starts its final wave at or after **82%** of its budget.
- Measured fixed runtime outside dynamic boss fights at **106.5 / 97.4 / 93.1 / 40.4 seconds** for Chapters 1–4. These per-chapter fixed budgets must not be summed or presented as campaign wall-clock duration.
- Added Hermite interpolation between camera poses and a generic detected-surface ground solver. The connector smooths pose-to-pose motion but does not preserve a continuous world: decor is still reconstructed between nodes, and ground, stair and landing treatment is not individually authored.
- Integrated **four hidden-life pickups** and expanded the active destructible set to **eight**.
- Kept route decisions **#2/#6** explicitly marked as inaccurate substitutes and **#3/#4/#9** as provisional mappings pending an authorized arcade-reference comparison.
- Hardened local co-op threat ownership: each hostile action selects one living player, projectiles lock that recipient at launch and dissipate rather than damaging the survivor if the locked player becomes unavailable. Civilian-authored threats never silently retarget a player.
- Enforced a complete **0.90-second continuously visible** boss telegraph. Cooldown overshoot cannot consume the warning, and losing visibility resets the full telegraph before any melee commit or projectile launch.
- Made actor retirement explicit and idempotent: dead actors leave `active_actors` immediately, visible fades remain tracked in `retiring_actors`, sprite-less actors still reach `queue_free()`, and scene cleanup drains both collections.
- Verified the current worktree with `npm test` at **295/295**, **975 deterministic Godot core assertions**, complete QA at **313/313**, Web QA at **299/299**, **1,977 environment assertions**, and the content audit at **889 checks / 6 known warnings / 0 errors**.
- Exported the tagged release tree locally: Windows **191,497,768 bytes** (`b1411c67ae6c9636bd00ac6557c4fbe8f6206cff2a23ec843bce57d4015ea280`); Linux **155,862,360 bytes** (`1e39c76ec8c168f6cc922683f8020123621c7b0384285f3c4ef38e80f4bc511b`); Web **9 files / 122,236,534 bytes**, including PCK **82,392,140** (`b85a0d00b07178efe07bcd3b8fec872fe66e735d6c48a1ff9edbbd5d4e2ca7f3`), WASM **39,513,091** (`35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277`) and HTML **5,590** (`e9cb46807cdf85ceeb0c40e0dfbbf87232b5a7c7ccb3c427fe881f2b76fc6c1f`). The Windows executable started and remained alive after nine seconds.
- Verified the fresh local Web export through the real menu and real gameplay at 1280×720: `crossOriginIsolated=true`, one 1280×720 `role=main` canvas with the correct accessible label, every local resource returned HTTP 200, no page error or framework overlay appeared, and only normal Godot/WebGL informational logs were recorded.
- Retained the visual-fidelity limits explicitly: the **38 atlases / 2,432 cells** expose only **eight semantic states per direction**, right-side profiles are often mirrored, and three enemy variants are not arcade-exact. Neither `licensed_assets/` nor `reference_build/` is present, so exact Sega fidelity is not certified.
- Published immutable tag `v0.5.0` at exact commit `6d84764745102b95e22b2462eeaa364103678c0b`; GitHub Actions release-check run `33136431022` passed.
- Published the source, Windows, Linux and Web archives plus `SHA256SUMS.txt` in the [GitHub v0.5.0 release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.5.0). The extracted public source archive independently passed `npm test` **295/295**.
- Deployed the exact Web export as Vercel production `dpl_BTEuXpYNMWmEYbWP2h2hNjAVGkGL` at [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app); public HTML/PCK/WASM hashes match the tagged export and fresh browser QA reached real gameplay with HTTP 200 resources, isolation enabled and no page error.

## 0.4.0 route and runtime-component integrity release — 2026-08-25

- Aligned all four secondary route graphs with the active campaign timeline: matching node IDs, start nodes and edges, including `sophie_antechamber` and `roof_rescue`.
- Added deterministic `RouteOutcomePolicy` resolution so a civilian rescue cannot satisfy a breakable-driven branch; the foyer lock, chain plate and elevator switch require destruction of their exact authored asset.
- Integrated `PickupController`, `BreakableObject`, `CivilianController` and `EnemySpawnEvent` into the active runtime. Their deterministic tests cover one-shot collection, durability/rewards, visible-contact-only civilian loss and authored spawn scheduling.
- Added a three-degree eight-sector directional hysteresis. Each actor retains its previous view until the camera crosses the full margin, preventing rapid front/diagonal/side flicker without changing hitboxes, combat timing or the atlas cells.
- Removed the unused `c04_bonus_gate_seal` and `c04_emergency_supply_crate` profiles and four PNGs, plus the unreferenced `ams-eater-custom.png`; all removed files and import sidecars remain recoverable from Git history.
- Reduced the content audit to **746 checks / 6 warnings / 0 errors**, with **4 breakables / 4 uses** and **74/74 unique audited binaries**. The six retained warnings are three reference-pending placements and the three explicit directional-animation limitations.
- Verified `npm.cmd test` at **278/278**, the **286-assertion** Godot deterministic core and the strengthened `npm.cmd run qa` at **292/292**, including gameplay, complete campaign, score and initials/credits smokes.
- Hardened the release packager: Windows, Linux and Web exports are all mandatory, checksums cover the exact four expected ZIPs, and an unexpected archive now aborts packaging instead of contaminating the release set.
- Fresh Godot 4.7.1 exports succeed: Windows **182,039,024 bytes**, Linux **146,403,616**, Web **112,777,790 across nine files**, including a **72,933,396-byte** PCK. Windows remained active for the eight-second startup smoke; `qa:web` passes **282/282** and `verify:web` passes. Local Chromium reports isolation true, one accessible 1258×566 main canvas, loaded PCK/WASM, no page errors and only the three expected Godot information logs. Exact Sega-reference fidelity remains unverified without an authorized reference build and licensed masters.
- Published immutable tag `v0.4.0` at exact commit [`b3b8b3b`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/b3b8b3b37a027189a83afaa21e6e959debbd99a5) after [GitHub Actions run 32893740154](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32893740154) passed in 37 seconds.
- [Release v0.4.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.4.0) contains Source **223,487,206 bytes** (`c6a32581…`), Windows **111,706,553** (`03c9073d…`), Linux **101,742,516** (`f99bd5aa…`), Web **82,878,986** (`0d3e07cc…`) and `SHA256SUMS.txt` **421** (`91243d6a…`); all five remote sizes and SHA-256 digests match locally, and the extracted source archive passes 278/278 without optional private reports.
- Vercel production `dpl_HeyKmQ5aZ5yypUXokC5ZJXsgrYLW` is `READY` at <https://the-house-of-the-dead-25d.vercel.app>. Root, PCK and WASM return 200 with COOP/COEP and correct WASM MIME and match local SHA-256 exactly. Public Chromium reports isolation true, one accessible 1258×566 canvas, loaded PCK/WASM, no page errors, three expected Godot logs and a visually inspected menu.

## 0.3.0 attack-readability and environment-content release — 2026-08-25

- Reworked hostile damage readability. Ordinary and boss-support melee attacks now require a visible attacker, a completed wind-up and real 3D contact before damage can be applied; the remaining legacy depth-threshold path that could damage the player without a readable strike was removed.
- Made ranged threats physical and interceptable. Enemy projectiles are visible Sprite3D actors, must complete a minimum visible travel distance and reach contact before dealing damage, and can be shot down. Civilian rescue deadlines now accelerate a real assailant instead of killing by timer; assigned melee enemies approach in 3D, civilian-bound projectiles aim at the civilian, and an in-flight projectile dissipates rather than retargeting a player after a rescue. Chariot and Hangedman use visible lunges, while Hermit and Magician use dedicated destructible projectile attacks.
- Corrected environment presentation: prop scales were recalibrated, the garden lamp received readable lit/unlit frames, white matte/halo remnants were removed from the lamp, estate gate, chandelier and wall sconce, and affected props/destructibles retain lossless alpha imports.
- Added event-driven prop state changes for the estate gate, mansion doors and laboratory specimen tanks. Breakable-driven events now require the actual recorded breakable ID; saving a civilian can no longer open or break an unrelated prop.
- Replaced the chapter-four bonus-room hostile/crate proxy with twelve visible, shootable-once world pickups: four lives, three golden frogs and five medals. Pickups use the validated gameplay-support manifest, bob in 3D and preserve the configured 4,000-point collectible total.
- Activated all 25 enemy behavior profiles in runtime content and made all seven projectile visual families reachable. `sam_a1`, `kenfis_f1` and `name_g2` now have provisional runtime placements explicitly marked as awaiting authorized arcade scene-placement validation.
- Added four original OpenAI-generated eight-frame transparent environment strips — falling drips, flowing water, electrical arcs and monitor scan — with manifest-driven animation and runtime placement. These are project-owned fan-made replacements, not extracted Sega assets.
- Completed the Curien/Magician finale presentation: Curien is a non-targetable story actor, Magician's attack has a visible fireball strike, Curien uses hit-recoil and death-fall frames, and the grounded corpse persists for a verified minimum five-second hold before scene cleanup.
- The complete v0.3.0 QA matrix passes: `npm.cmd test` 272/272 and `npm.cmd run qa` 282/282, plus campaign, score-ledger and initials smokes. Windows/Linux/Web exports measure 187,023,472 / 151,388,064 / 117,762,238 bytes; the Windows startup smoke, Web `qa:web` 276/276, `verify:web` and browser startup all pass. The extracted public source ZIP independently passes 272/272 with optional private sources absent.
- Published exact green commit/tag [`8add70a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/8add70a31a751928ea12c247ca584d8b030b2139) after [GitHub Actions run 32865563840](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32865563840) passed. [Release v0.3.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.3.0) contains Source 228,874,505 bytes, Windows 116,689,194, Linux 106,725,425, Web 87,860,665 and the 421-byte checksum manifest; all five remote SHA-256 digests match locally.
- Deployed Vercel production `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Public root/PCK/WASM return 200 with COOP/COEP and correct WASM MIME; all three downloaded hashes match the local build. Chromium reports isolation true, one visible accessible 1258×622 canvas, the chapter-I/attract-menu flow, three expected Godot information logs and zero page errors.

## 0.2.1 source-verification hotfix — 2026-08-25

- Removed the public-source verifier's mandatory dependency on ignored private ImageGen reports. Tracked atlas manifests and provenance remain mandatory; extended source-sheet cross-checks still run whenever the private reports are locally available.
- Reproduced GitHub Actions run `32781391274`: its 271/271 data checks passed before the previous verifier failed on missing `reports/runtime/group_scientists_v2.json`.
- Verified `npm.cmd test` both with the private reports present and with both private scientist/assembly reports temporarily absent. The reports were restored after the simulation; `qa:web` 275/275 and `verify:web` also pass in tracked-only mode.
- Removed Windows-only separator rewriting from the environment verifier and hardened gameplay-support path normalization after clean run `32783351280` exposed the POSIX failure.
- Verified final clean Linux GitHub Actions run [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344): `npm test`, `qa:web` and `verify:web` all passed in 33 seconds.
- Gameplay content and exported binaries are unchanged. v0.2.1 is the corrected source distribution; the public v0.2.0 tag and artifacts remain immutable.
- Tagged exact green commit `c13d525d63dc9ef4e92d30c0ab5851047fa76f66` as v0.2.1 after final GitHub Actions run [`32784226344`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32784226344) passed in 33 seconds.
- Published [GitHub release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1) with Source (227,864,129 bytes), Windows (90,978,140), Linux (81,014,969), Web (62,151,092) and `SHA256SUMS.txt` (421 bytes); all five assets are uploaded and every remote digest matches locally.
- Deployed Vercel production `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs`, `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Root/PCK/WASM return HTTP 200 with WASM MIME and COOP/COEP; public Chromium has isolation enabled, an accessible 1258×622 canvas, visible menu/P1/continue flow and zero console/page errors.

## 0.2.0 content-completion release — 2026-08-24

- Expanded the directional Sprite3D contract to 38 unique 2048×2048 RGBA atlases and 2,432 addressable cells, adding three dedicated scientist identities while preserving eight camera-relative directions and eight gameplay states per actor.
- Added 25 behavior-backed enemy profiles with dedicated visuals, body hitbox profiles, projectile metadata and runtime distinctions instead of texture-only archetype swaps.
- Added 20 individual environment material families (60 albedo/normal/ORM maps), 33 node layouts, 14 props, six intact/broken destructibles, animated fog/dust/wind/bat accents and manifest-driven runtime integration.
- Added seven projectile cutouts, three HUD families, four boss weak-point diagrams, node-specific scientist bindings and accurate destructible/non-destructible projectile lifetime rules.
- Added 28 deterministic original procedural cues across effects, interface, ambience, short music loops and non-intelligible radio punctuations. Licensed Sega voices, music and effects remain explicitly external.
- Reduced imported sprite textures from 87.4 MiB to 27.64 MiB and environment imports from 55.8 MiB to 12.63 MiB while preserving alpha/normal/ORM profiles; 124 import contracts verify with zero mismatches.
- Fixed exported-resource validation by using `ResourceLoader` for imported textures in the environment, enemy and gameplay-support libraries. Local Chromium first exposed the defect; the re-exported build has no console errors.
- Passed `npm.cmd test` 271/271 and complete `npm.cmd run qa` 280/280, plus warning-free gameplay, score, initials and full-campaign smokes through all chapters, bosses/rematches, 15/15 scientists, ending and credits.
- Exported Windows (161,321,616 bytes), Linux (125,686,208 bytes) and nine-file Web (92,060,382 bytes) builds. PCK is 52,215,988 bytes, WASM 39,513,091 bytes, Windows remained alive during an eight-second startup smoke, `qa:web` passes 275/275 and `verify:web` is OK.
- Verified local Vercel/Chromium with agent-browser 0.34: Godot 4.7.1 WebGL2 single-thread, `crossOriginIsolated=true`, accessible 1258×622 game canvas, visible menu/P1/gameplay/HUD/continue/pause, no blocked network resource and zero console errors.
- Published exact content commit [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21) through the public [v0.2.0 tag and GitHub release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0).
- Uploaded Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969), Web (62,151,092) and `SHA256SUMS.txt`; every remote ZIP digest matches its local SHA-256.
- Promoted Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` to `Ready` production at <https://the-house-of-the-dead-25d.vercel.app>. Root/PCK/WASM return HTTP 200 with `application/wasm` and COOP/COEP; public Chromium reports isolation true, a 1258×622 canvas, visible menu/P1/gameplay/continue and zero console/page errors.
- Kept the release boundary explicit: these are original fan-made replacement assets and verified project behavior, not exact Sega-master or revision-specific arcade certification.

## Directional Sprite V2 and verified public release — 2026-08-21

- Replaced the organic-actor presentation with 35 unique 2048×2048 RGBA directional atlases: eight directions and eight action states, 64 cells per actor and 2,240 cells total.
- Added automatic camera-relative direction resolution, manifest-atomic loading and runtime idle/move/wind-up/strike/hit/death transitions.
- Kept 25 dedicated enemy profiles and distinct hero, civilian, narrative-character, small-creature and boss bindings; no final V2 identity uses another actor as a proxy.
- Repaired long-weapon/limb crops, Samson's missing death cell and chroma fringes. The post-repair visual audit passed.
- Verified `npm.cmd test` at 252/252 and `npm.cmd run qa` at 257/257, including 232 core assertions, 57 manifest-atomicity assertions and the 35-binding/seven-representative/eight-direction smoke.
- Verified gameplay (2P, four chapters, six shots, off-screen reload, independent gamepad aim), score (`+120`/`-100`), initials (`COD`) and complete campaign smokes (all chapters, required bosses/rematches, 15/15 scientists, ending and credits). Gameplay/campaign smokes retain a non-blocking two-`ObjectDB` shutdown warning.
- Produced final Windows (202,088,128 bytes), Linux (166,452,720 bytes) and nine-file Web (132,826,890 bytes) exports. Windows headless startup passed; Web PCK is 92,982,496 bytes and WASM 39,513,091 bytes.
- Verified five Web quality imports at quality 0.92: alpha unchanged, PSNR 35.31–35.81 dB and MAE 2.72–2.86/255. `qa:web` passes 256/256 and `verify:web` is OK.
- Verified local Chromium with agent-browser 0.34: Godot 4.7.1 WebGL2 single-thread, `crossOriginIsolated=true`, PCK/WASM 200, live P1/P2 two-HUD/two-crosshair view, three target viewport shapes, zero page errors and axe 4.12 at 23 passes/0 violations.
- Published the public repository at <https://github.com/darknigthmare/the-house-of-the-dead-25d> and the v0.1.0 tag at exact commit `4f222998e1225cde3f2933477344cf782f84f6a8`.
- Verified final GitHub Actions runs 32435148599 (tag, 28 seconds) and 32435035804 (documentation, 38 seconds) green.
- Kept Git-connected `main` production `Ready` at <https://the-house-of-the-dead-25d.vercel.app>; root/WASM/PCK return HTTP 200 with `application/wasm` and COOP/COEP present.
- Repeated Chromium QA against production: title and live P1/P2 with two HUDs/two crosshairs, PCK/WASM 200, zero console/page errors and axe at 23 passes/0 violations.
- Recorded caveated local cached-menu vitals: TTFB 2.39 ms, FCP/LCP 99.13 ms and CLS 0.
- Recorded the honest art boundary: eight compact states per direction are game-ready, but are not a complete licensed arcade animation library.
- Published [GitHub v0.1.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.1.0) with Source (137,825,223 bytes), Windows (130,767,749 bytes), Linux (121,139,247 bytes), Web (102,962,391 bytes) and `SHA256SUMS.txt` (421 bytes). Remote asset states are `uploaded`, and every remote ZIP digest matches the local SHA-256 manifest.

## 0.1.0 — 2026-08-16

- Initialized a Godot 4.7.1 typed-GDScript project with GL Compatibility rendering.
- Added modular arcade rules, two-player input/session foundations, rail/route systems, Sprite3D actors, hit zones, civilians, breakables, pickups and boss phase controllers.
- Added all four chapters, boss order, route branches, score/life/continue rules and three endings.
- Added Arcade, Training, Boss Rush and Chapter Select plus accessibility, settings and save foundations.
- Added research, route, art, licensing, QA, performance, build and continuation documentation.
