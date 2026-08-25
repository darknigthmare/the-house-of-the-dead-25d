# QA Report

This report records the published v0.3.0 release, then preserves the v0.2.1 source-distribution hotfix, v0.2.0 gameplay-content evidence and historical v0.1.0 separately. An older export or deployment is not evidence for the current revision.

## Published release — 2026-08-25 (v0.3.0)

This evidence applies to immutable tag `v0.3.0` at exact commit `8add70a31a751928ea12c247ca584d8b030b2139`. GitHub Actions run `32865563840` passed before publication; the extracted public source ZIP separately passes 272/272 without optional private reports.

| Surface | Observed result | Proven scope |
|---|---|---|
| repository/data suite | `npm.cmd test`: **272/272** | current static data, manifests, runtime contracts and content gates |
| complete local orchestration | `npm.cmd run qa`: **282/282** | current release-candidate QA command completed |
| deterministic/runtime libraries | core **235**; sprite-atlas atomicity **63**; environment library **115**; gameplay-support library **33**; enemy profiles **210** | typed deterministic contracts and manifest loaders |
| procedural audio | **354 assertions / 28 distinct cues** | dimensions, duration, loop, signature and safe-amplitude contracts for original temporary audio |
| directional runtime smoke | **38 bindings / 10 representatives / 8 directions**, with cleanup and no leaked instance | all directional views plus live state/death cleanup sampling |
| Curien finale smoke | **29 assertions**, with cleanup and no leaked instance | Curien story spawn, Magician strike, recoil, fall and persistent corpse sequence |
| asset verifiers | environment **1,708**; animated effects **348/348**; gameplay support **113/113** | current environment, four dedicated effect strips, projectiles, pickups, HUD and weak-point assets |
| content-family audit | **739 checks / 16 warnings / 0 errors** | all active paths resolve; the 16 documented fidelity/architecture backlog warnings remain intentionally visible |
| texture imports | **128 files / 0 mismatches** | current lossless/lossy import-profile contract |
| complete campaign smoke | chapters **1–4**; **15/15 scientists**; Chariot, Hangedman, Hermit, Chariot rematch, Hangedman rematch and Magician; ending and credits | automated success-path campaign continuity |
| focused gameplay smokes | gameplay, score QA and initials entry all passed | two-player/gameplay rules, score events and initials-to-credits flow |
| Windows x64 export | **187,023,472 bytes**; SHA-256 `A54A13E6…`; hidden **8-second** startup passed | local Godot 4.7.1 export starts and remains active on the development machine |
| Linux x64 export | **151,388,064 bytes**; SHA-256 `3FC75393…` | local Godot 4.7.1 export completed |
| Web export | **9 files / 117,762,238 bytes**; PCK **77,917,844** (`955FFD21…`); WASM **39,513,091** (`35116F68…`) | local Godot 4.7.1 Web payload |
| Web static gates | `qa:web` **276/276**; `verify:web` **OK** | patched accessibility/isolation shell and required Web payload markers |
| local browser, agent-browser 0.34 | isolation true; accessible **1258×622** canvas with `role=main` and an ARIA label; menu then Arcade/P1/continue visible; WebGL2 single-thread; **0 page errors** | live local Web startup and core visible flow |
| browser logging | **3 Godot info logs only** | no browser page error was observed; informational engine logs are not suppressed |

The [GitHub v0.3.0 release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.3.0) contains five `uploaded` assets whose remote sizes and SHA-256 digests match locally. Vercel deployment `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` is `Ready`; public root/PCK/WASM downloads are byte-identical to the verified build, and Chromium reports isolation true, one visible accessible 1258×622 canvas, chapter-I/attract-menu rendering, three expected engine logs and zero page errors.

These checks do not prove installation on a clean physical Windows system, physical light-gun behavior, sustained performance on named hardware, every failure route, or exact Sega arcade timing and assets. The 60 fps performance target remains unprofiled.

## Verified distribution hotfix — 2026-08-25 (v0.2.1)

| Surface | Observed result | Proven scope |
|---|---|---|
| package/tag | `0.2.1`; `v0.2.1` resolves to `c13d525d63dc9ef4e92d30c0ab5851047fa76f66` | exact released source |
| clean Linux CI | run `32784226344` passed in 33 seconds | `npm test`, `qa:web`, `verify:web` from checkout without private reports |
| GitHub release | public; five assets `uploaded` | Source 227,864,129; Windows 90,978,140; Linux 81,014,969; Web 62,151,092; manifest 421 bytes; all remote digests matched |
| production | Vercel `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` `Ready` | root/PCK/WASM 200; WASM MIME; COOP/COEP |
| public browser | zero console/page errors; isolation true; accessible 1258×622 canvas; menu and P1/continue visible | production runtime startup and core visible flow |

The source hotfix changes QA portability only. Gameplay content and exported Windows/Linux/Web payloads are unchanged from v0.2.0; the detailed gameplay evidence follows.

## Current working-tree combat readability validation — 2026-08-25

This evidence applies to the current local working tree after the published v0.2.1 tag. It is not evidence that the already published v0.2.1 archives contain these later combat changes.

| Check | Observed result | Proven scope |
|---|---|---|
| `tests/test_enemy_profile_library.gd` | 210 assertions passed | 25 profiles expose telegraph and 3D melee-range data; every runtime projectile is destructible and has minimum visible travel/contact data; Ebitan b and Burner do not emit non-destructible runtime projectiles |
| `tests/test_runner.gd` | 235 assertions passed | existing deterministic core rules remain green |
| Godot 4.7.1 headless parse/startup | passed with no script error | current gameplay inheritance chain parses and the main runtime initializes |
| `scripts/smoke_gameplay.gd` | passed; `SMOKE PROJECTILE RULES`, `SMOKE BONUS PICKUPS` and `SMOKE ATTACK READABILITY` all reported `OK` | live two-player runtime plus the attack cases listed below |
| `scripts/smoke_campaign.gd` | passed | chapters `[1, 2, 3, 4]`; bosses `[Chariot, Hangedman, Hermit, Chariot, Hangedman, Magician]`; 15/15 scientists; ending and credits reached |
| targeted `git diff --check` | passed | no whitespace error in the combat, enemy-profile, regression-test or smoke changes |

The attack-readability smoke directly exercised these failure and success cases:

- a melee actor with a forged completed telegraph cannot damage from eight world units away;
- matching X/Z does not count as contact while the attacker remains five world units above the player;
- close contact cannot damage before the telegraph completes, then damages once after completion;
- hiding the actor billboard invalidates a close melee strike;
- a projectile owner marked non-destructible cannot launch a runtime projectile;
- a visible projectile at contact cannot damage before completing its minimum visible travel;
- a hidden projectile cannot damage even after satisfying its travel requirement;
- a visible, destructible and telegraphed projectile damages once only after sufficient visible travel and physical contact;
- an expired civilian deadline with no living assailant leaves the civilian alive instead of applying a timer-only death;
- a civilian-assigned melee enemy must approach in 3D, remain visible, complete its telegraph and reach contact before killing;
- a civilian-assigned projectile travels toward the civilian in full 3D and only kills after its visible-travel and contact gates pass;
- a projectile already aimed at a rescued civilian dissipates at that target without damaging or silently retargeting a player;
- Chariot cannot damage from its home position, but can damage after the completed visible lunge reaches melee range.

The automated campaign smoke proves the scripted success path remains traversable. It does not prove every real-time enemy formation, every failure branch or exact timing against an authorized Sega arcade build.

## Verified release — 2026-08-24 (v0.2.0)

| Surface | Observed result | Proven scope |
|---|---|---|
| package version | `0.2.0` | current `package.json` |
| `npm.cmd test` | 271/271 passed | static data, manifests, routes, rosters, asset contracts and import profiles |
| `npm.cmd run qa` | 280/280 passed | complete current local QA orchestration |
| sprite atlas verifier | 38 dedicated atlases; 2,432 directional/state cells | atlas bindings and populated eight-direction animation grids |
| campaign route verifier | passed | chapter path counts 4/4/4/2; Chariot, Hangedman, Hermit, both rematches and Magician declared |
| enemy roster | 25 profiles; 25 unique types; 25 dedicated atlases | no final enemy proxy binding in the verified roster |
| environment asset verifier | 1,517 assertions passed | 20 materials, 33 route-node profiles, 6 destructibles, 14 props; 75.67 MiB source PNG |
| gameplay-support verifier | 83/83 passed | projectiles, boss weak points and gameplay support bindings |
| texture import verifier | 124 files; 0 mismatches | current import-profile contract |
| procedural audio suite | 354 assertions; 28 distinct cues | deterministic duration/frame/channel/loop/signature/amplitude checks |
| Godot 4.7.1 headless parse/startup | passed | current main scene and runtime scripts parse and initialize |
| gameplay and campaign smokes | passed without shutdown warning or leak report after cleanup | two players, four chapters, gun/reload behavior, required bosses/rematches, 15/15 scientists, ending and credits |
| Windows x64 export | 161,321,616 bytes | Godot 4.7.1 export completed |
| Windows launch smoke | remained active throughout an eight-second hidden launch | current exported executable starts and does not immediately exit |
| Linux x64 export | 125,686,208 bytes | Godot 4.7.1 export completed |
| Web export | nine files; 92,060,382 bytes total | Godot 4.7.1 export completed |
| Web payload | PCK 52,215,988 bytes; WASM 39,513,091 bytes | current exported payload sizes |
| `npm.cmd run qa:web` | 275/275 passed | current patched Web payload and Web guards |
| `npm.cmd run verify:web` | OK | expected HTML, JavaScript, WASM, PCK and title markers |
| local Vercel + agent-browser 0.34 | passed after ResourceLoader correction | current Web export served and exercised locally |
| browser console/isolation | 0 errors; `crossOriginIsolated=true` | clean local browser startup and required isolation state |
| accessible canvas | 1258×622; `role=main`; `aria-label` present | rendered Godot surface and accessibility metadata |
| browser flow | menu, gameplay, HUD and continue visible | core interactive presentation reached in the local browser |
| browser resources | 31 performance entries; no blocked resource | observed local navigation resource set |

The 28 audio cues are original procedural temporary replacements covering gameplay, UI, five ambiences, four short chapter loops and four non-intelligible radio punctuations. They are not Sega voices, music or sound effects. Licensed Sega audio remains an external asset requirement.

## Evidence boundaries

The v0.2.0 QA proves the declared atlas, route, enemy, environment, gameplay-support, audio and import contracts. The Godot runs prove parsing, core two-player gun behavior and the complete automated campaign success path through credits. Windows, Linux and Web exports were produced successfully; the Windows launch smoke proves only that the executable stayed active for eight seconds on the development machine.

Exact commit [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21) is published through the [v0.2.0 GitHub release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0). Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969) and Web (62,151,092) are uploaded, and remote ZIP SHA-256 digests match local files.

Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>. Root/PCK/WASM return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. Public browser QA confirms `crossOriginIsolated=true`, a 1258×622 canvas, menu, P1 gameplay and continue, with zero console/page errors. This does not prove exact arcade-reference timing or every failure branch.

The following v0.2.1 gates remain unverified:

- installation and startup on a clean physical Windows 64-bit machine;
- physical Gun4IR, Sinden or other light-gun calibration, including two-device play;
- sustained frame-time, 1% low, CPU/GPU memory and hitch profiling on named hardware;
- exact route, score, timing, dialogue and ending comparison against an authorized licensed Sega arcade reference build.

## Historical v0.1.0 boundary

The verified v0.1.0 release remains historical evidence only. Its sizes, hashes and browser checks predate the v0.2.0 atlas, environment, gameplay-support and procedural-audio expansion and must not be reused as v0.2.0 evidence.
