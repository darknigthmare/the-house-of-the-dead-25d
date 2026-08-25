# Continuation

## Current state — v0.3.0 worktree, not yet published

The package version is `0.3.0`. The current worktree builds on the immutable public v0.2.1 baseline and contains an attack-readability, environment-state and content-coverage pass that has not yet completed its release gates.

Completed implementation in this worktree:

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

Latest verified release-candidate results:

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

The local code/data QA and export gates are complete. Fresh exports measure Windows **187,023,472 bytes** (SHA-256 `A54A13E64810109AD8C894DD896DD2DC8A94F4F1262ED490A9756A15CF9F954D`), Linux **151,388,064 bytes** (`3FC7539397BA3A512ADF6482FEFBD0D1AC3121B17C00DF282E18AE8ADD6FEB64`) and Web **117,762,238 bytes** across nine files. The Web PCK is **77,917,844 bytes** (`955FFD21080A99FCC052800145A4AD28B8162009AECF66DCC7E251F040AEEC4A`) and WASM is **39,513,091 bytes** (`35116F68540AC41ACF7D71EA457ADDED91B5E960A9CCA3E2ACC72918EAF01277`). The Windows eight-second startup smoke, `qa:web` 276/276, `verify:web` and local browser startup all pass. Source-ZIP extraction verification, regenerated release archives, commit/push, immutable v0.3.0 tag, GitHub release and Vercel production deployment remain pending; none of those v0.3.0 publication steps is complete yet.


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

1. Commit and push the exact green source, then wait for the clean GitHub Actions checkout to pass.
2. Regenerate the release archives and `SHA256SUMS.txt` from that exact commit, extract the source ZIP into a clean temporary directory and prove its tracked-only verification.
3. Create the immutable v0.3.0 tag and GitHub release, deploy the exact Web export to Vercel, then verify remote sizes/digests, root/PCK/WASM responses and public browser runtime.
4. Keep physical clean-machine Windows installation, physical Gun4IR/Sinden validation, named-hardware profiling and authorized Sega reference comparison as separate unverified gates.

## Commands to resume

```powershell
npm.cmd test
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

Keep the public v0.2.0 and v0.2.1 tags immutable. Existing published archives belong to those releases; no v0.3.0 archive or tag exists until the pending release workflow succeeds.

## Precautions

- Preserve unrelated local changes. Do not stage `.tools`, `.godot`, licensed/reference folders, ignored ImageGen source sheets, secrets or unrelated parent-repository files.
- Treat the current sprites, environments, UI and procedural audio as original replacement assets, never as extracted or certified Sega masters.
- Do not claim “100% arcade faithful”, exact timings, exact ending thresholds or exact audio until an authorized reference build is measured.
- Anchor v0.2.0 publication claims to commit `d79f86a`, its public GitHub release and Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z`, not to package metadata alone.
- Anchor v0.2.1 source-distribution claims to commit `c13d525`, release v0.2.1 and Vercel deployment `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs`; never move either public tag.
- Keep physical Windows installation, physical light-gun calibration, deep named-hardware profiling and authorized reference comparison as separate unverified gates.
- Do not describe v0.3.0 as built, archived, committed, tagged, released or deployed until those exact gates have been executed and recorded.
