# Professional Changelog

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
- Published commit `d98487bca5592418e80342221f671538ed40058a` to the public repository at <https://github.com/darknigthmare/the-house-of-the-dead-25d>.
- Verified GitHub Actions run 32434278324 green in 20 seconds for `npm test`, `qa:web` and `verify:web`.
- Deployed production to <https://the-house-of-the-dead-25d.vercel.app> as `dpl_Hs23gpsUfidKJeEDPs1K45NeWYyW`: `READY`, 980 ms build, root/WASM/PCK HTTP 200, `application/wasm`, and COOP/COEP present.
- Repeated Chromium QA against production: title and live P1/P2 with two HUDs/two crosshairs, PCK/WASM 200, zero console/page errors and axe at 23 passes/0 violations.
- Recorded caveated local cached-menu vitals: TTFB 2.39 ms, FCP/LCP 99.13 ms and CLS 0.
- Recorded the honest art boundary: eight compact states per direction are game-ready, but are not a complete licensed arcade animation library.
- Prepared the [GitHub v0.1.0 release target](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.1.0); release archives and SHA-256 are generated from the committed `HEAD` immediately after this documentation update.

## 0.1.0 — 2026-08-16

- Initialized a Godot 4.7.1 typed-GDScript project with GL Compatibility rendering.
- Added modular arcade rules, two-player input/session foundations, rail/route systems, Sprite3D actors, hit zones, civilians, breakables, pickups and boss phase controllers.
- Added all four chapters, boss order, route branches, score/life/continue rules and three endings.
- Added Arcade, Training, Boss Rush and Chapter Select plus accessibility, settings and save foundations.
- Added research, route, art, licensing, QA, performance, build and continuation documentation.
