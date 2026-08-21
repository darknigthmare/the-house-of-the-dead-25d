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
