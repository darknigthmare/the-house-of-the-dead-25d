# QA Report

This report separates the current v0.2.0 working-tree evidence from historical v0.1.0 release evidence. An older export or deployment is not evidence for the current revision.

## Verified snapshot — 2026-08-24 (v0.2.0 working tree)

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

The current local QA proves the declared atlas, route, enemy, environment, gameplay-support, audio and import contracts. The Godot runs prove parsing, core two-player gun behavior and the complete automated campaign success path through credits. The current Windows, Linux and Web exports were produced successfully; the Windows launch smoke proves only that the executable stayed active for eight seconds on the development machine.

The local browser evidence proves that the current Web export loads after the ResourceLoader correction, preserves cross-origin isolation, exposes an accessible canvas and reaches menu, gameplay, HUD and continue without console errors or blocked resources. It is not a public-production deployment check and does not prove exact arcade-reference timing or every failure branch.

The following v0.2.0 gates remain unverified:

- current source/build archives and their final SHA-256 manifest;
- v0.2.0 GitHub release, Vercel production deployment and public HTTP/browser probes;
- installation and startup on a clean physical Windows 64-bit machine;
- physical Gun4IR, Sinden or other light-gun calibration, including two-device play;
- sustained frame-time, 1% low, CPU/GPU memory and hitch profiling on named hardware;
- exact route, score, timing, dialogue and ending comparison against an authorized licensed Sega arcade reference build.

## Historical publication boundary

The repository has a previously verified v0.1.0 GitHub release and Vercel deployment. Those artifacts predate the v0.2.0 atlas, environment, gameplay-support and procedural-audio expansion, so their sizes, hashes, browser checks and publication status must not be reused as v0.2.0 evidence.
