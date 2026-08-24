# The House of the Dead 2.5D

An original fan-made recreation of the 1997 arcade rail shooter, built with Godot 4.7.1. Organic actors use animated sprites inside a real 3D world: perspective, occlusion, camera rails, body hit zones and collisions remain three-dimensional.

The current worktree V2 visual contract provides 38 unique 2048×2048 RGBA directional atlases. Each atlas contains eight views — front, front-left, left, back-left, back, back-right, right and front-right — and eight states — idle, three movement poses, wind-up, strike, hit and fall/death. This yields 64 cells per actor and 2,432 addressable cells. The set now includes dedicated `scientist_male_blue`, `scientist_male_gray` and `scientist_female_lab` atlases.

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

## Local v0.2.0 validation — August 24, 2026

The v0.2.0 wave provides 38 directional atlases/2,432 cells, 25 unique enemy profiles, 20 individual environment materials, 33 environment nodes, six destructibles, 14 props, seven projectile cutouts, three HUD families, four boss weak-point diagrams and 28 original procedural audio cues. `npm.cmd test` passes 271/271 and the complete `npm.cmd run qa` orchestration passes 280/280.

Warning-free runtime smokes validate two players, four chapters, six shots, off-screen reload, destructible and non-destructible projectile rules, independent gamepad aim, `+120`/`-100` score events, `COD` initials and the complete campaign: Chariot, Hangedman, Hermit, both rematches, Magician, 15/15 scientists, ending and credits.

The v0.2.0 exports measure 161,321,616 bytes on Windows, 125,686,208 bytes on Linux and 92,060,382 bytes for nine Web files. PCK is 52,215,988 bytes and WASM is 39,513,091 bytes. The Windows executable remained alive during an eight-second startup smoke; `qa:web` passes 275/275 and `verify:web` is OK.

Local Chromium QA served through Vercel with production headers runs Godot 4.7.1 single-threaded WebGL2 with `crossOriginIsolated=true`. It exposed and led to a fix for using `FileAccess` with imported textures; asset loaders now use `ResourceLoader`. After re-export, the console remains error-free, the accessible canvas measures 1258×622, and the menu, P1 start, environments, HUD, continue and pause are visible. No network resource remains blocked.

The public repository remains [darknigthmare/the-house-of-the-dead-25d](https://github.com/darknigthmare/the-house-of-the-dead-25d), and the historical v0.1.0 production remains available at [the-house-of-the-dead-25d.vercel.app](https://the-house-of-the-dead-25d.vercel.app). At this validation point, v0.2.0 is a verified local candidate: its commit, archives, tag, GitHub release and new deployment are not yet claimed.

The compact eight-state cycle per direction is a detailed playable baseline, not a complete licensed arcade animation library. The remaining unverified gates are installation on a clean physical Windows machine, physical light guns, deep profiling on named hardware and exact comparison against a licensed reference build.

## Legal status

This repository contains no ROM, arcade extraction, commercial music, voices, logos or geometry. Included visuals are original fan-made OpenAI ImageGen work or assets owned by the same user. This project is not affiliated with Sega.
