# Build Guide

## v0.5.0 published release — 2026-08-28

Package version `0.5.0` is published from immutable tag `v0.5.0` at exact commit `6d84764745102b95e22b2462eeaa364103678c0b`. The tagged Windows/Linux/Web exports, delivery archives, GitHub Release and Vercel deployment are verified below; older version measurements remain separate immutable historical evidence.

Release scope:

- melee pursuit converges on X/Z, keeps attackers in front of the camera and repeats wind-up/attack/recovery while a target remains valid;
- oriented OBB obstacles cover walls, rails, columns, doors, shelves and props;
- visible hostile projectiles stop on those obstacles;
- co-op threat ownership resolves to one living player, retains that player while valid and locks every player-targeted projectile to its launch recipient; if that recipient is no longer available, the projectile dissipates instead of retargeting;
- civilian-assigned attackers never fall back to a player: no player-targeted projectile is created after their civilian target disappears, and an already launched civilian-targeted projectile dissipates without redirection;
- every boss commit requires a full, uninterrupted **0.90-second** visible telegraph; losing visibility resets the telegraph rather than preserving or consuming hidden time;
- logical actor death removes the actor from the `active` set immediately; sprite fades live in `retiring` until final cleanup, sprite-less actors finalize immediately, and scene cleanup drains both sets;
- HUD text is sanitized before display;
- campaign topology is 43 nodes, 53 edges and 8/4/8/2 complete paths; fixed authored sequence timing, excluding dynamic boss phases, is 106.5/97.4/93.1/40.4 seconds for chapters 1–4; these figures are neither wall-clock durations nor chapter/campaign floors and must not be summed into a campaign total;
- 98 ordinary spawn entries select 68–71 per complete run, 20 civilian placements select 15 per run, and 34 multi-wave encounters place their last wave at or beyond 82% of the encounter sequence;
- Hermite interpolation provides continuous camera motion across the authored rail points, while the set remains a reconstruction and the walkable ground remains generic;
- four hidden lives, eight destructibles and provisional route decisions #3/#4/#9 are integrated.

Verified release gates:

| Gate | Result | Boundary |
|---|---:|---|
| deterministic Godot core | **975 assertions** | pursuit, collision, timing, route and existing core contracts |
| repository/data suite | **295/295** | `npm.cmd test` against the exact tagged tree and extracted public source archive |
| complete QA orchestration | **313/313** | current aggregate local QA command |
| Web static QA | **299/299** | patched Web shell and current exported payload |
| environment verifier | **1,977 assertions** | authored environment/OBB/destructible contracts |
| content-family audit | **889 checks / 6 warnings / 0 errors** | current content reachability and declared fidelity limitations |

Tagged release outputs:

| Output | Size | Local verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | **191,497,768 bytes** | SHA-256 `b1411c67ae6c9636bd00ac6557c4fbe8f6206cff2a23ec843bce57d4015ea280`; hidden startup remained active and alive after nine seconds |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | **155,862,360 bytes** | SHA-256 `1e39c76ec8c168f6cc922683f8020123621c7b0384285f3c4ef38e80f4bc511b` |
| `build/web/` | **9 files / 122,236,534 bytes** | `qa:web` passed 299/299 and `verify:web` passed |
| `build/web/index.pck` | **82,392,140 bytes** | SHA-256 `b85a0d00b07178efe07bcd3b8fec872fe66e735d6c48a1ff9edbbd5d4e2ca7f3` |
| `build/web/index.wasm` | **39,513,091 bytes** | SHA-256 `35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277` |
| `build/web/index.html` | **5,590 bytes** | SHA-256 `e9cb46807cdf85ceeb0c40e0dfbbf87232b5a7c7ccb3c427fe881f2b76fc6c1f` |

Fresh local browser QA at 1280×720 loaded the menu and then gameplay. COOP/COEP produced `crossOriginIsolated=true`; the page exposed one 1280×720 canvas with `role=main` and the correct accessible label, every local resource returned HTTP 200, no page error or framework overlay appeared, and the console contained only normal Godot/WebGL informational logs.

Publication evidence: [GitHub Release v0.5.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.5.0) contains the source (**233,538,836 bytes**; SHA-256 `341c4d0575dd64b43d2896021c9aa15b7db53718be982c64b647ea3aee801368`), Windows (**119,954,813**; `3d49b98c5f4a26a6ed283db389fad59442521131459457a32cc26c97a6af2f08`), Linux (**110,326,829**; `e9d6b043173c27b635c46fd282cdebba5808c159f44e13425fc0aac951d72c1f`) and Web (**92,152,402**; `4b4f44a01b00df7948e291b02acee4d6fa13df8d0bbb7a6eba9ea9376216fd31`) archives plus `SHA256SUMS.txt`. GitHub Actions run [`33136431022`](https://github.com/darknigthmare/the-house-of-the-dead-25d/actions/runs/33136431022) passed. Vercel production `dpl_BTEuXpYNMWmEYbWP2h2hNjAVGkGL` is live at <https://the-house-of-the-dead-25d.vercel.app>; public HTML/PCK/WASM hashes match the tagged export and fresh public browser QA reached gameplay without page errors.

For any later release, rerun the focused route, sequence-pacing, HUD and gameplay smokes plus aggregate gates after every source change, then regenerate the three exports from that exact tree. Do not carry forward v0.5.0 binary measurements as evidence for a later revision.

Decisions #3/#4/#9 and other reference-pending placements remain provisional until checked against an authorized, revision-identifiable arcade build. The Hermite rails are continuous in the current implementation, but their control points and surrounding set are reconstructed rather than arcade-reference verified; the ground surface is still generic. Persistent scene state and exact walkable-surface/stair/landing authoring remain P0. Without `licensed_assets/` and `reference_build/`, the local tests and exports do not certify exact Sega timing, geometry, assets, visual fidelity or route logic.

## v0.4.0 published release — 2026-08-25

Immutable tag `v0.4.0` points to exact commit `b3b8b3b37a027189a83afaa21e6e959debbd99a5`. `npm.cmd test` passes 278/278, the deterministic Godot core passes 286 assertions and strengthened `npm.cmd run qa` passes 292/292; GitHub Actions run `32893740154` is green.

Fresh Godot 4.7.1 outputs from the exact tagged tree:

| Output | Local size | Release verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | **182,039,024 bytes** | export succeeded; hidden eight-second startup passed; SHA-256 `4c4ebc7eba42658a389312f312f3e465ff1501c9746ffc7345c193d1021e6d3d` |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | **146,403,616 bytes** | export succeeded; SHA-256 `1ad3d1c3c53104c07daae1c5b7a30e29a131aa5047b1ae9a0d70254600a29788` |
| `build/web/` | **112,777,790 bytes across nine files** | accessibility patch applied; `qa:web` 282/282; `verify:web` passed |
| Web PCK | **72,933,396 bytes** | SHA-256 `caa42ba7ee0f95cf129da2a8de36a1bceefcc4d8d28eabe4957e8b1d02843b46` |
| Web WASM | **39,513,091 bytes** | SHA-256 `35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277` |
Local Vercel serving plus agent-browser 0.35 verified isolation, one accessible 1258×566 `main` canvas, loaded PCK/WASM resources, no page error and only the three expected Godot informational logs.

[GitHub release v0.4.0](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.4.0) publishes Source **223,487,206 bytes**, Windows **111,706,553**, Linux **101,742,516**, Web **82,878,986** and a **421-byte** checksum manifest; all remote digests match. Vercel deployment `dpl_HeyKmQ5aZ5yypUXokC5ZJXsgrYLW` is `READY`, its public root/PCK/WASM match the local hashes and public Chromium has no page error.


## v0.3.0 published release — 2026-08-25

Immutable tag `v0.3.0` at exact commit `8add70a31a751928ea12c247ca584d8b030b2139` has been validated, exported, packaged, source-ZIP tested, published on GitHub and deployed to Vercel production.

To reproduce immutable v0.3.0, first check out tag `v0.3.0` in a clean worktree, then run the two aggregate gates from that worktree root:

```powershell
npm.cmd test
npm.cmd run qa
```

The recorded v0.3.0 candidate results are 272/272 and 282/282 respectively. From the checked-out v0.3.0 tag, the detailed Godot surfaces are reproducible with its scripts, notably:

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

Recorded v0.3.0 evidence: core 235, atlas 63, environment library 115, gameplay-support library 33, enemy profiles 210, audio 354/28, directional smoke 38/10/8 without leak, Curien smoke 29 without leak, environment verifier 1,708, animated effects 348/348, gameplay support 113/113, content audit 739/16 warnings/0 errors, and 128 imports/0 mismatches. Campaign smoke traversed chapters 1–4, 15 scientists and the full boss sequence including both rematches; gameplay, score and initials smokes passed.

Recorded v0.3.0 Godot 4.7.1 outputs:

| Output | Local size | Candidate verification |
|---|---:|---|
| `build/windows/The_House_of_the_Dead_25D.exe` | **187,023,472 bytes** | export succeeded; hidden eight-second startup passed |
| `build/linux/The_House_of_the_Dead_25D.x86_64` | **151,388,064 bytes** | export succeeded |
| `build/web/` | **117,762,238 bytes across nine files** | export succeeded; `qa:web` 276/276; `verify:web` OK |
| Web PCK | **77,917,844 bytes** | candidate payload |
| Web WASM | **39,513,091 bytes** | candidate payload |

Local and production agent-browser 0.34 verification retain `crossOriginIsolated=true`, one visible accessible 1258×622 `role=main` canvas with an ARIA label, chapter-I then attract/menu rendering, WebGL2 single-thread operation, zero page errors and only the three expected Godot information logs.

The release process below produced Source 228,874,505 bytes, Windows 116,689,194, Linux 106,725,425, Web 87,860,665 and a 421-byte checksum manifest; all remote GitHub digests match locally. Vercel deployment `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` is `Ready` and serves byte-identical root/PCK/WASM files. Keep the exact Sega boundary: without `licensed_assets/` and `reference_build/`, a successful release is not certification of arcade-identical assets or timing. Named-hardware performance profiling also remains outstanding.

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
