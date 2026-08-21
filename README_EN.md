# The House of the Dead 2.5D

An original fan-made recreation of the 1997 arcade rail shooter, built with Godot 4.7.1. Organic actors use animated sprites inside a real 3D world: perspective, occlusion, camera rails, body hit zones and collisions remain three-dimensional.

The V2 visual pipeline provides 35 unique 2048×2048 RGBA directional atlases. Each atlas contains eight views — front, front-left, left, back-left, back, back-right, right and front-right — and eight states — idle, three movement poses, wind-up, strike, hit and fall/death. This yields 64 cells per actor and 2,240 verified cells. The resolver automatically selects the camera-relative view to create the requested fake-3D effect.

The project includes a playable four-chapter campaign with branches, scientists, breakables, Chariot, Hangedman, Hermit, Magician, final-chapter rematches, three endings, credits, score, lives, ammunition, continues and two-player local co-op. Training, Boss Rush, Chapter Select and a local leaderboard are also available.

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

## Verified pre-publication snapshot — August 21, 2026

`npm.cmd test` passes 252/252 and `npm.cmd run qa` passes 257/257, including 232 core assertions, 57 manifest-atomicity assertions and a directional smoke covering 35 bindings, seven representatives and all eight directions. The 35 2048×2048 RGBA atlases contain 64 cells each, for 2,240 cells; all 25 enemies have dedicated profiles. The final visual audit passes after repairing clipped parts, Samson's death cell and chroma fringes.

Runtime smokes validate two players, four chapters, six shots, off-screen reload, independent gamepad aim, `+120`/`-100` score events, `COD` initials and the complete campaign: Chariot, Hangedman, Hermit, both rematches, Magician, 15/15 scientists, ending and credits. Two `ObjectDB` instances remain reported at gameplay/campaign smoke shutdown without blocking either result.

Final exports measure 202,088,128 bytes on Windows (headless startup passed), 166,452,720 bytes on Linux and 132,826,890 bytes for nine Web files. The 92,982,496-byte PCK remains below 100,000,000 by 7,017,504 bytes; WASM is 39,513,091 bytes. `qa:web` passes 256/256 and `verify:web` is OK.

In local Chromium through agent-browser 0.34, the Godot 4.7.1 single-threaded WebGL2 build reports `crossOriginIsolated=true`, PCK/WASM HTTP 200, and a working title/menu followed by live P1/P2 with two HUDs and two crosshairs. Viewports 1280×720, 390×844 and 844×390 pass with zero page errors. Axe 4.12 reports 23 passes and 0 violations. Cached menu figures — TTFB 2.39 ms, FCP/LCP 99.13 ms, CLS 0 — are not full-campaign performance evidence.

The compact eight-state cycle per direction is a detailed playable baseline, not a complete licensed arcade animation library. Physical devices, a clean Windows machine, archives/SHA-256, GitHub, Vercel and public QA remain pending.

## Legal status

This repository contains no ROM, arcade extraction, commercial music, voices, logos or geometry. Included visuals are original fan-made OpenAI ImageGen work or assets owned by the same user. This project is not affiliated with Sega.
