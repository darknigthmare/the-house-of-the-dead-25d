# QA Report

This report records the v0.2.1 source-distribution hotfix, the unchanged v0.2.0 gameplay-content evidence and historical v0.1.0 separately. An older export or deployment is not evidence for the current revision.

## Verified distribution hotfix — 2026-08-25 (v0.2.1)

| Surface | Observed result | Proven scope |
|---|---|---|
| package/tag | `0.2.1`; `v0.2.1` resolves to `c13d525d63dc9ef4e92d30c0ab5851047fa76f66` | exact released source |
| clean Linux CI | run `32784226344` passed in 33 seconds | `npm test`, `qa:web`, `verify:web` from checkout without private reports |
| GitHub release | public; five assets `uploaded` | Source 227,864,129; Windows 90,978,140; Linux 81,014,969; Web 62,151,092; manifest 421 bytes; all remote digests matched |
| production | Vercel `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` `Ready` | root/PCK/WASM 200; WASM MIME; COOP/COEP |
| public browser | zero console/page errors; isolation true; accessible 1258×622 canvas; menu and P1/continue visible | production runtime startup and core visible flow |

The source hotfix changes QA portability only. Gameplay content and exported Windows/Linux/Web payloads are unchanged from v0.2.0; the detailed gameplay evidence follows.

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
