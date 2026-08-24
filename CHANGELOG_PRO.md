# Professional Changelog

## 0.2.1 source-verification hotfix — 2026-08-25

- Removed the public-source verifier's mandatory dependency on ignored private ImageGen reports. Tracked atlas manifests and provenance remain mandatory; extended source-sheet cross-checks still run whenever the private reports are locally available.
- Reproduced GitHub Actions run `32781391274`: its 271/271 data checks passed before the previous verifier failed on missing `reports/runtime/group_scientists_v2.json`.
- Verified `npm.cmd test` both with the private reports present and with both private scientist/assembly reports temporarily absent. The reports were restored after the simulation; `qa:web` 275/275 and `verify:web` also pass in tracked-only mode.
- Removed Windows-only separator rewriting from the environment verifier and hardened gameplay-support path normalization after clean run `32783351280` exposed the POSIX failure.
- Verified clean Linux GitHub Actions run [`32783693892`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/32783693892): `npm test`, `qa:web` and `verify:web` all passed in 37 seconds.
- Gameplay content and exported binaries are unchanged. v0.2.1 is the corrected source distribution; the public v0.2.0 tag and artifacts remain immutable.

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
