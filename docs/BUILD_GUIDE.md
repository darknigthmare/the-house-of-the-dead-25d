# Build Guide

## v0.3.0 local release candidate — 2026-08-25 (unpublished)

The current v0.3.0 candidate has been validated and exported locally. It is not yet a committed/tagged GitHub release and is not yet a v0.3.0 Vercel production deployment.

Run the two aggregate gates from the repository root:

```powershell
npm.cmd test
npm.cmd run qa
```

The recorded candidate results are 272/272 and 282/282 respectively. The detailed Godot surfaces are also reproducible with the existing scripts, notably:

```powershell
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_environment_asset_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_gameplay_support_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://tests/test_enemy_profile_library.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_directional_sprites.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_curien_finale.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_gameplay.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_campaign.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_score_qa.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_initials.gd
```

Expected candidate evidence: core 235, atlas 63, environment library 115, gameplay-support library 33, enemy profiles 210, audio 354/28, directional smoke 38/10/8 without leak, Curien smoke 29 without leak, environment verifier 1,708, animated effects 348/348, gameplay support 113/113, content audit 739/16 warnings/0 errors, and 128 imports/0 mismatches. Campaign smoke must traverse chapters 1–4, 15 scientists and the full boss sequence including both rematches; gameplay, score and initials smokes must pass.

Current Godot 4.7.1 outputs:

| Output | Local size | Candidate verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | **187,023,472 bytes** | export succeeded; hidden eight-second startup passed |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | **151,388,064 bytes** | export succeeded |
| `build/web/` | **117,762,238 bytes across nine files** | export succeeded; `qa:web` 276/276; `verify:web` OK |
| Web PCK | **77,917,844 bytes** | candidate payload |
| Web WASM | **39,513,091 bytes** | candidate payload |

Local agent-browser 0.34 verification must retain `crossOriginIsolated=true`, the accessible 1258×622 `role=main` canvas with an ARIA label, menu then Arcade/P1/continue visibility, WebGL2 single-thread operation, zero page errors and only the three expected Godot info logs. This browser gate is local; do not describe it as a v0.3.0 production deployment.

The release process below still applies, but package, commit, tag, push, GitHub upload and Vercel deployment remain subsequent steps. The fresh export artifacts above are the only v0.3.0 build evidence; the older archives under `artifacts/release/` must be regenerated from the exact committed v0.3.0 tree before upload. Keep the exact Sega boundary: without `licensed_assets/` and `reference_build/`, a successful build is not certification of arcade-identical assets or timing. Named-hardware performance profiling also remains outstanding.

## Toolchain

- Godot 4.7.1 stable with matching official export templates.
- Node.js 20 or newer.
- Windows PowerShell for validation, exports and release packaging.
- Python 3 with Pillow and NumPy only when rebuilding directional atlases or generated environment assets. Normal gameplay and export do not require those Python packages.

The portable editor may be stored under `.tools/godot-4.7.1/`. `.tools`, licensed/reference folders and ignored raw generation sources stay outside Git.

## Current v0.2.1 validation

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

Current v0.2.1 outputs and verified sizes (binary payloads unchanged from v0.2.0):

| Output | Size | Verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | 161,321,616 bytes | export succeeded; hidden launch remained active for eight seconds |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | 125,686,208 bytes | export succeeded |
| `build/web/` | 92,060,382 bytes across nine files | export succeeded; `qa:web` 275/275; `verify:web` OK |
| Web PCK | 52,215,988 bytes | current payload |
| Web WASM | 39,513,091 bytes | current payload |

Every Web export rewrites `index.html`; rerun the accessibility patch before Web QA.

After the ResourceLoader correction, local Vercel serving plus agent-browser 0.34 verified zero console errors, `crossOriginIsolated=true`, an accessible 1258×622 canvas, menu/gameplay/HUD/continue and no blocked resource. Production v0.2.1 repeats the isolation, accessible-canvas and menu/P1/continue checks with zero console/page errors.

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

The published v0.2.1 set contains Source (227,864,129 bytes, SHA-256 `1c402e679cfb9c7e20dadba4fb73f88692ca229a8bf237fce6cbcb2a4d5f13fd`), Windows (90,978,140, `17c0b671904712b86c8dd1eb0974b82887f9191cd87de9b6dc7f051b3fb0b2ca`), Linux (81,014,969, `69bec7bfeb195fb36f7069fd547a522ac48e84e255888c9844309026f15bcd9d`) and Web (62,151,092, `8c559faf6d5285a7831510f4e42a41047a4f596340463401dd7e6a032f401522`) plus the 421-byte manifest. Every remote digest matches locally.

## Published v0.2.1

The exact corrected-source commit is [`c13d525`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/c13d525d63dc9ef4e92d30c0ab5851047fa76f66), published through the [v0.2.1 tag and GitHub release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1). Clean Linux run `32784226344` passes all three workflow commands.

Vercel deployment `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Root, PCK and WASM return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. Public Chromium confirms `crossOriginIsolated=true`, an accessible 1258×622 canvas, visible menu/P1/continue and zero console/page errors. v0.2.0 remains available as immutable history and is marked superseded for source use.

On a clean physical Windows 64-bit machine, extract only the Windows archive and verify startup, menu, one encounter, six shots, both reload methods and two-player join. A clean-machine run, physical Gun4IR/Sinden/two-light-gun calibration, named-hardware profiling and exact authorized Sega-reference comparison remain unverified gates.
