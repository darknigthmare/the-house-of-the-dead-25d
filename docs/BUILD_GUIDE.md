# Build Guide

## Toolchain

- Godot 4.7.1 stable with matching official export templates.
- Node.js 20 or newer.
- Windows PowerShell for validation, exports and release packaging.
- Python 3 with Pillow and NumPy only when rebuilding directional atlases or generated environment assets. Normal gameplay and export do not require those Python packages.

The portable editor may be stored under `.tools/godot-4.7.1/`. `.tools`, licensed/reference folders and ignored raw generation sources stay outside Git.

## Current v0.2.0 validation

Run the complete local orchestration:

```powershell
npm.cmd run qa
```

The verified 2026-08-24 result is 280/280 checks. Its current content contracts include:

- 38 dedicated atlases and 2,432 directional/state cells;
- 25 enemy profiles and unique enemy types;
- 1,517 environment assertions covering 20 materials, 33 nodes, 6 destructibles and 14 props;
- 83/83 gameplay-support checks;
- 124 texture import profiles with zero mismatches.

The targeted Godot commands remain useful during iteration:

```powershell
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --quit-after 2
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_procedural_audio.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_gameplay.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_campaign.gd
```

Current verified results: Godot parse/startup passed; procedural audio passed 354 assertions across 28 distinct cues; gameplay and complete-campaign smokes passed without a shutdown warning or leak report after cleanup.

## Exports

```powershell
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Windows Desktop'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Linux'
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --export-release 'Web'
npm.cmd run fix:web-accessibility
npm.cmd run qa:web
npm.cmd run verify:web
```

Current v0.2.0 outputs and verified sizes:

| Output | Size | Verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | 161,321,616 bytes | export succeeded; hidden launch remained active for eight seconds |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | 125,686,208 bytes | export succeeded |
| `build/web/` | 92,060,382 bytes across nine files | export succeeded; `qa:web` 275/275; `verify:web` OK |
| Web PCK | 52,215,988 bytes | current payload |
| Web WASM | 39,513,091 bytes | current payload |

Every Web export rewrites `index.html`; rerun the accessibility patch before Web QA.

After the ResourceLoader correction, local Vercel serving plus agent-browser 0.34 verified zero console errors, `crossOriginIsolated=true`, a 1258×622 canvas with `role=main` and an `aria-label`, visible menu/gameplay/HUD/continue surfaces, 31 performance entries and no blocked resource. This is local Web evidence, not a public Vercel production deployment.

## Asset rebuilds

Install Python dependencies only when the corresponding ignored generation sources are present:

```powershell
py -m pip install -r requirements-art.txt
py scripts/assemble_directional_atlases.py
node scripts/verify_sprite_atlas_v2.mjs
py scripts/build_environment_assets.py
node scripts/verify_environment_assets.mjs
py scripts/build_gameplay_support_assets.py
node scripts/verify_gameplay_support_assets.mjs
```

Do not claim a licensed reconstruction when the licensed/reference source material is absent. The current procedural voices, music and sound effects are original temporary replacements, not Sega audio.

## Release archives

Commit the exact verified tree first because the source archive is produced from `HEAD`, then run:

```powershell
& '.\scripts\package_release.ps1'
```

The script creates source, Windows, Linux and Web ZIP files plus `artifacts/release/SHA256SUMS.txt`. Recalculate and verify every SHA-256 before uploading. After extracting the Linux ZIP on Linux, restore its executable bit before launch:

```bash
chmod +x The_House_of_the_Dead_25D.x86_64
./The_House_of_the_Dead_25D.x86_64
```

The published v0.2.0 set contains Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969), Web (62,151,092) and `SHA256SUMS.txt`; every uploaded ZIP digest matches its local SHA-256.

## Published v0.2.0

The exact content commit is [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21), published through the [v0.2.0 tag and GitHub release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0).

Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Root, PCK and WASM return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. Public Chromium confirms `crossOriginIsolated=true`, a 1258×622 canvas, visible menu/P1/gameplay/continue and zero console/page errors.

On a clean physical Windows 64-bit machine, extract only the Windows archive and verify startup, menu, one encounter, six shots, both reload methods and two-player join. A clean-machine run, physical Gun4IR/Sinden/two-light-gun calibration, named-hardware profiling and exact authorized Sega-reference comparison remain unverified gates.
