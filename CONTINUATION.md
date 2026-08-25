# Continuation

## Published v0.4.0 release — route and runtime-component integrity

Package version `0.4.0` is published from immutable tag `v0.4.0` at exact commit `b3b8b3b37a027189a83afaa21e6e959debbd99a5`. The bounded route/component/directional integrity wave, source archive and Windows/Linux/Web outputs were validated before publication.

Implemented:

- aligned all JSON/TRES route graphs, chapter start metadata and runtime timeline topology, including `garden_rescue`, `sophie_antechamber`, `chain_plate`, `roof_rescue` and `back_attack_rescue`;
- added deterministic `RouteOutcomePolicy` resolution so `branch_success` for breakable nodes requires the exact destroyed breakable ID, while rescue-only branches preserve civilian success/failure;
- integrated `PickupController`, `BreakableObject`, `CivilianController` and `EnemySpawnEvent` into the active metadata-driven runtime, with timer-only civilian loss explicitly rejected;
- added three-degree directional-sector hysteresis with per-actor previous-direction state, so camera jitter around a 22.5-degree boundary does not flicker the visible atlas row;
- removed the two obsolete Chapter 4 destructible profiles/four PNGs and the unreferenced AMS item PNG; the deleted files and import sidecars remain recoverable through Git history;
- reduced the reproducible content audit to 746 checks, 6 warnings and 0 errors, with 4 active breakables/4 uses and 74/74 unique audited binaries.

Verification already completed:

- `npm.cmd test`: 278/278 checks passed;
- Godot deterministic core: 286 assertions passed;
- strengthened `npm.cmd run qa`: 292/292 checks passed;
- gameplay, complete-campaign, score-ledger and initials/credits smokes: passed inside the aggregate QA command.
- Windows x64 export: 182,039,024 bytes, SHA-256 `4c4ebc7eba42658a389312f312f3e465ff1501c9746ffc7345c193d1021e6d3d`; hidden eight-second startup passed;
- Linux x64 export: 146,403,616 bytes, SHA-256 `1ad3d1c3c53104c07daae1c5b7a30e29a131aa5047b1ae9a0d70254600a29788`;
- Web export: 112,777,790 bytes across nine files; PCK 72,933,396 bytes (`caa42ba7…`), WASM 39,513,091 (`35116f68…`), `qa:web` 282/282 and `verify:web` passed after the accessibility patch.
- local Chromium through agent-browser 0.35: `crossOriginIsolated=true`, one visible accessible 1258×566 `main` canvas, PCK/WASM loaded, no error overlay or page error and only three expected Godot informational logs.

Publication completed:

- GitHub Actions run `32893740154` passed on the tagged commit in 37 seconds;
- GitHub release v0.4.0 exposes Source 223,487,206 bytes (`c6a32581…`), Windows 111,706,553 (`03c9073d…`), Linux 101,742,516 (`f99bd5aa…`), Web 82,878,986 (`0d3e07cc…`) and the 421-byte checksum manifest (`91243d6a…`); every remote size/digest matches locally;
- the extracted public Source ZIP passes 278/278 with optional private reports absent;
- Vercel deployment `dpl_HeyKmQ5aZ5yypUXokC5ZJXsgrYLW` is `READY` at <https://the-house-of-the-dead-25d.vercel.app>; public root/PCK/WASM are byte-identical to the local build, and Chromium reports isolation, one accessible 1258×566 canvas, zero page errors and the visually inspected menu.

Files changed in this wave:

- route/chapter data under `data/routes/` and `data/chapters/`;
- runtime policy/components under `src/rail/route_outcome_policy.gd` and `src/gameplay/`;
- deterministic coverage in `tests/test_route_outcome_policy.gd`, `tests/test_runtime_components.gd`, `tests/test_route_graph_resources.gd`, `tests/test_environment_asset_library.gd` and `tests/test_runner.gd`;
- environment manifests/provenance and reproducible scripts under `data/assets/` and `scripts/`, including the strengthened `scripts/qa.mjs`;
- current audit, route, QA, changelog and continuation documentation.

No exact Sega arcade fidelity is certified. The three provisional placements and the directional-animation limitations remain explicit.

## Previous published release — v0.3.0

The published v0.3.0 release package version is `0.3.0`. The attack-readability, environment-state and content-coverage pass is published from immutable tag `v0.3.0` at exact commit `8add70a31a751928ea12c247ca584d8b030b2139`.

Completed v0.3.0 implementation:

- ordinary and boss-support melee damage requires the attacker to be visible, to finish its wind-up and to reach real 3D contact;
- the legacy boss-support depth-threshold damage path was removed, including regression coverage for a hidden support enemy already close to the camera;
- enemy projectiles are visible, destructible Sprite3D actors that require a telegraphed launch, minimum visible travel and physical contact before damage; civilian deadlines only accelerate real assigned attackers, assigned melee actors approach the civilian in 3D, and already-launched civilian projectiles cannot retarget a player after rescue; Chariot/Hangedman use visible lunges and Hermit/Magician use interceptable projectiles;
- prop proportions were recalibrated, the garden lamp has readable lit/unlit frames, and white matte/halo remnants were cleaned from the lamp, estate gate, chandelier and mansion sconce;
- affected prop and destructible textures retain lossless alpha imports;
- the estate gate, mansion doors and laboratory specimen tanks have manifest-driven state events; `breakable_destroyed` requires the actual destroyed breakable ID and can no longer be triggered by a civilian save;
- the chapter-four bonus room contains twelve explicit world pickups — four lives, three golden frogs and five medals — with no hostile or breakable proxy; pickups bob in 3D, can be shot once and are loaded from the gameplay-support manifest;
- all 25 enemy behavior profiles have a runtime path and all seven projectile families are reachable; the added `sam_a1`, `kenfis_f1` and `name_g2` scene placements remain explicitly provisional pending an authorized arcade comparison;
- four original OpenAI-generated transparent environment strips are integrated through the environment manifest and runtime motion controller: falling drips, flowing water, electrical arcs and monitor scan, each with eight 256-pixel frames in a 2048×256 RGBA image;
- the Magician finale respawns Curien as a non-targetable story actor, shows Magician's visible fireball strike, applies Curien hit-recoil and death-fall frames, and keeps the grounded corpse for a minimum verified five-second hold before cleanup.

Recorded v0.3.0 release-candidate results:

- `npm.cmd test`: 272/272;
- `npm.cmd run qa`: 282/282;
- targeted runtime parse: 9/9 scripts;
- gameplay smoke: passed without leaks, including timer-only civilian death, 3D civilian melee approach, civilian projectile targeting/no-retarget, invisible-damage regressions and bonus pickups;
- environment asset library: 115 assertions;
- gameplay-support library: 33 assertions, plus 113/113 manifest checks;
- environment verifier: 1,708 assertions;
- animated-effect verifier: 348/348 assertions;
- Curien-finale smoke: 29/29 assertions;
- campaign: chapters 1–4, all six boss encounters, 15/15 scientists, ending and credits;
- score ledger and initials: passed (`+120`, `-100`, `COD`).

The local code/data QA and export gates are complete. Fresh exports measure Windows **187,023,472 bytes** (SHA-256 `A54A13E64810109AD8C894DD896DD2DC8A94F4F1262ED490A9756A15CF9F954D`), Linux **151,388,064 bytes** (`3FC7539397BA3A512ADF6482FEFBD0D1AC3121B17C00DF282E18AE8ADD6FEB64`) and Web **117,762,238 bytes** across nine files. The Web PCK is **77,917,844 bytes** (`955FFD21080A99FCC052800145A4AD28B8162009AECF66DCC7E251F040AEEC4A`) and WASM is **39,513,091 bytes** (`35116F68540AC41ACF7D71EA457ADDED91B5E960A9CCA3E2ACC72918EAF01277`). The Windows eight-second startup smoke, `qa:web` 276/276, `verify:web` and browser startup all pass.

GitHub Actions run `32865563840` passed on the exact release commit. [Release v0.3.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.3.0) exposes Source **228,874,505 bytes** (`997fee97…`), Windows **116,689,194** (`e35f1295…`), Linux **106,725,425** (`3b49c364…`), Web **87,860,665** (`4274d1fc…`) and `SHA256SUMS.txt` **421** (`59cb1bd7…`); all remote states are `uploaded` and all remote digests match locally. The extracted source archive passes 272/272 without private reports.

Vercel deployment `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Root, PCK and WASM return 200 with COOP/COEP and correct WASM MIME, and their downloaded SHA-256 hashes match local files. Public Chromium reports `crossOriginIsolated=true`, one visible accessible 1258×622 canvas, chapter-I then attract/menu rendering, three Godot information logs and zero page errors.


The art and audio boundary remains unchanged: these are original fan-made/project replacement assets, not extracted or certified Sega masters. Exact arcade timing, placement and revision fidelity still require the authorized reference build and licensed assets listed in `docs/MISSING_LICENSED_ASSETS.md`.

## Previous public baseline — published v0.2.1 source-QA hotfix

The published v0.2.1 package contains the four-chapter data-driven campaign, local 2P, 4:3 framing, rail camera, Sprite3D actors, 3D hit zones/collisions, scientists, breakables, scoring, six-round ammunition, lives, continues, routes, four bosses, chapter-four rematches, three endings, credits, Training, Boss Rush and Chapter Select.

The original replacement-content contract is integrated:

- 38 dedicated 2048×2048 RGBA directional actor atlases, eight directions × eight states, 2,432 cells total;
- 25 dedicated enemy profiles plus distinct heroes, narrative actors, bosses and three additional scientist variants;
- 20 environment material families (60 albedo/normal/ORM maps), profiles for all 33 campaign nodes, 14 props and six intact/broken destructibles;
- seven projectile cutouts, an eight-frame life torch, bullet/reload HUD assets and four boss weak-point diagrams;
- 28 distinct original procedural audio cues used as temporary replacements for weapon, UI, ambience, boss, short music-loop and non-verbal voice-like feedback;
- manifest-driven runtime integration for node-specific environments, PBR surfaces, props/decorative motion, projectile visuals, breakables, civilians and support HUD.

The environment, enemy-profile and gameplay-support loaders use `ResourceLoader` for export-safe resource resolution. The correction is covered by successful Windows, Linux and Web exports rather than editor-only parsing.

GitHub Actions runs `32781391274` and `32783351280` exposed two source-distribution-only issues: a mandatory ignored scientist report, then Windows-only environment paths. The v0.2.1 verifier always validates tracked manifest/provenance data, optionally cross-checks private reports when present and resolves JSON asset paths on Windows or POSIX. Local QA passes in normal and tracked-only modes; final clean Linux run `32784226344` passes `npm test`, `qa:web` and `verify:web` in 33 seconds.

This replacement contract is verified locally. It must not be described as exact Sega arcade certification: no authorized Sega reference build, revision/operator configuration or licensed visual/audio masters were available.

## Previous completed release — 2026-08-25

Completed the v0.2.0 original content wave, then corrected its public-source validation and cross-platform paths as the v0.2.1 hotfix while preserving the gameplay and binary payloads:

- `npm.cmd test`: 271/271;
- `npm.cmd run qa`: 280/280;
- core suite: 235 assertions;
- sprite atlas atomicity: 63 assertions;
- environment library: 56 assertions;
- gameplay-support library: 25 assertions;
- enemy profile runtime contract: 135 assertions;
- procedural audio: 354 assertions across 28 distinct cues;
- directional smoke: 38 bindings, ten representatives, eight directions, death and cleanup states;
- environment verifier: 1,517 assertions, 20 materials, 33 nodes, six destructibles and 14 props;
- gameplay-support verifier: 83/83;
- texture import profile: 124 files, zero mismatches;
- targeted runtime parse: 9/9 scripts;
- gameplay smoke: two players, four chapters, six shots to empty, off-screen reload to six, independent gamepad aim and projectile rules;
- score smoke: `+120` and `-100` with QA logging disabled in normal mode;
- initials smoke: `COD`, confirmation to credits and demo bypass;
- campaign smoke: chapters 1–4, Chariot, Hangedman, Hermit, both rematches, Magician, 15/15 scientists, ending and credits;
- Windows export: 161,321,616 bytes; eight-second startup check passed;
- Linux export: 125,686,208 bytes;
- Web export: 92,060,382 bytes total, including a 52,215,988-byte PCK and 39,513,091-byte WASM;
- Web static checks: `qa:web` 275/275 and `verify:web` OK;
- local browser: Vercel local server plus agent-browser 0.34, no console errors, `crossOriginIsolated=true`, accessible canvas at 1258×622, with menu, gameplay, HUD and continue visible.

The content is anchored to exact commit `d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21` and the public [v0.2.0 GitHub release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0). Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969) and Web (62,151,092) are uploaded with remote ZIP SHA-256 digests matching local files. Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>; root/PCK/WASM return HTTP 200, WASM uses `application/wasm`, COOP/COEP are present, and public Chromium reports isolation true, a 1258×622 canvas, visible menu/P1/gameplay/continue and zero console/page errors.

The corrected source distribution is anchored to exact commit/tag `c13d525d63dc9ef4e92d30c0ab5851047fa76f66` and [GitHub release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1). All five assets are uploaded; remote sizes and SHA-256 digests match local files. Final clean GitHub Actions run `32784226344` passed in 33 seconds. Vercel production `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` is `Ready`; root/PCK/WASM return 200 with WASM MIME and COOP/COEP, while public Chromium reports isolation true, an accessible 1258×622 canvas, menu/P1/continue visibility and zero console/page errors. v0.2.0 remains immutable and is marked superseded for source use.

## Main delivered areas in v0.2.0 and v0.2.1

- `assets/sprites_v2/`, `assets/environments_v2/`, `assets/gameplay_v2/`;
- `data/assets/`, `data/audio/`, `data/runtime/campaign_timeline.json`;
- `src/gameplay/`, `src/audio/`, `src/main.gd`;
- asset-build/verification scripts and deterministic tests;
- README, licensing, missing-assets, production, catalog and continuation documentation.

The release contains the reviewed Godot import metadata required by its texture contracts; ignored tools, caches, licensed/reference folders and ImageGen source sheets remain outside the public package.

## Next exact task

1. Resolve the three provisional enemy placements only from an authorized, revision-identifiable Sega reference build; do not invent arcade-exact placement evidence.
2. Replace mirrored right/back-right profiles and compact semantic cells only with genuinely authored directional multi-frame art and recorded provenance.
3. Integrate licensed voices, music and remaining source assets only when they are supplied through the authorized asset root; keep project-owned replacements explicit until then.
4. Perform physical Windows installation, independent light-gun calibration and named-hardware frame-time/memory profiling before claiming those gates.

## Commands to resume

```powershell
npm.cmd test
node scripts/audit_content_families.mjs
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_runner.gd
npm.cmd run qa
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/parse_runtime.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_environment_asset_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_gameplay_support_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_enemy_profile_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_gameplay.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_score_qa.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_initials.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_campaign.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_curien_finale.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Windows Desktop'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Linux'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Web'
npm run fix:web-accessibility
npm.cmd run qa:web
npm.cmd run verify:web
git diff --check
```

Keep the public v0.2.0, v0.2.1, v0.3.0 and v0.4.0 tags immutable. The v0.3.0 archives belong to commit `8add70a`; the v0.4.0 archives belong to commit `b3b8b3b`; never regenerate or replace either release from a later documentation-only commit.

## Precautions

- Preserve unrelated local changes. Do not stage `.tools`, `.godot`, licensed/reference folders, ignored ImageGen source sheets, secrets or unrelated parent-repository files.
- Treat the current sprites, environments, UI and procedural audio as original replacement assets, never as extracted or certified Sega masters.
- Do not claim “100% arcade faithful”, exact timings, exact ending thresholds or exact audio until an authorized reference build is measured.
- Anchor v0.2.0 publication claims to commit `d79f86a`, its public GitHub release and Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z`, not to package metadata alone.
- Anchor v0.2.1 source-distribution claims to commit `c13d525`, release v0.2.1 and Vercel deployment `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs`; never move either public tag.
- Keep physical Windows installation, physical light-gun calibration, deep named-hardware profiling and authorized reference comparison as separate unverified gates.
- Anchor v0.3.0 publication claims to commit/tag `8add70a`, GitHub Actions run `32865563840`, the public release assets and Vercel deployment `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy`.
- Anchor v0.4.0 publication claims to commit/tag `b3b8b3b`, GitHub Actions run `32893740154`, release v0.4.0 and Vercel deployment `dpl_HeyKmQ5aZ5yypUXokC5ZJXsgrYLW`; never move the public tag.
