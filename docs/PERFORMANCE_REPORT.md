# Performance Report

## Published v0.5.0 release — structural budget, 2026-08-28

The published release has fixed authored sequence timing of **106.5, 97.4, 93.1 and 40.4 seconds** for chapters 1–4, excluding dynamic boss phases. These figures are neither captured wall-clock playthrough times nor chapter/campaign duration floors, and no total campaign duration can be derived from them. They are not arcade timing certification.

| Runtime content surface | Current budget |
|---|---:|
| active campaign graph | **43 nodes / 53 edges** |
| complete path combinations | **8 / 4 / 8 / 2** |
| ordinary spawn entries | **98 total; 68–71 per complete route** |
| civilian placements | **20 total; 15 per complete route** |
| props and environment events | **14 profiles / 105 placements / 9 events** |
| multi-wave encounters | **34; final wave at ≥82% of the encounter sequence** |
| destructibles | **8 active** |
| hidden-life interactions | **4 two-step secrets** |

The targeted deterministic core passes **975 assertions**. The repository/data suite passes **295/295**, complete QA passes **313/313**, Web static QA passes **299/299**, the environment verifier passes **1,977 assertions**, and the content audit reports **889 checks / 6 warnings / 0 errors**. These are correctness results, not render-throughput measurements.

| Release output | Size | Integrity/startup gate |
|---|---:|---|
| Windows x64 EXE | **191,497,768 bytes** | SHA-256 `b1411c67ae6c9636bd00ac6557c4fbe8f6206cff2a23ec843bce57d4015ea280`; active and alive after nine seconds during the startup smoke |
| Linux x64 | **155,862,360 bytes** | SHA-256 `1e39c76ec8c168f6cc922683f8020123621c7b0384285f3c4ef38e80f4bc511b` |
| Web total | **9 files / 122,236,534 bytes** | `qa:web` passed 299/299 and `verify:web` passed |
| Web PCK | **82,392,140 bytes** | SHA-256 `b85a0d00b07178efe07bcd3b8fec872fe66e735d6c48a1ff9edbbd5d4e2ca7f3` |
| Web WASM | **39,513,091 bytes** | SHA-256 `35116f68540ac41acf7d71ea457added91b5e960a9cca3e2acc72918eaf01277` |
| Web HTML | **5,590 bytes** | SHA-256 `e9cb46807cdf85ceeb0c40e0dfbbf87232b5a7c7ccb3c427fe881f2b76fc6c1f` |

Fresh local browser QA at 1280×720 loaded the menu and then gameplay. COOP/COEP produced `crossOriginIsolated=true`; one 1280×720 canvas exposed `role=main` and the correct accessible label, every local resource returned HTTP 200, no page error or framework overlay appeared, and only normal Godot/WebGL informational logs were present. This is a rendering, isolation, accessibility and presentation gate, not a frame-time capture.

The co-op single-target/projectile-lock rule, civilian no-retarget rule, uninterrupted visible 0.90-second boss telegraph, and `active`/`retiring` actor lifecycle are deterministic correctness invariants. Their passing coverage is not frame-time, memory or throughput evidence.

Hermite interpolation provides continuous camera motion in the current implementation, but the rail control points and surrounding set are reconstructed and the ground surface remains generic. Without `licensed_assets/` and `reference_build/`, neither the assets nor overall arcade fidelity are certified.

The new OBB generation and collision path need a named-hardware cost capture: peak active volumes, broad-phase pairs, projectile intersection cost and worst scene-transition hitch are not yet measured. Their correctness coverage must not be presented as performance evidence.

No new v0.5.0 named-hardware performance capture is recorded here. Stable 60 fps, 1% low, CPU/GPU frame time, peak process/GPU memory, atlas residency, route-transition hitches and physical light-gun latency remain unprofiled. Profiling must be repeated after exact rails, persistent chapter continuity and walkable-surface/stair-height authoring are complete.

The v0.5.0 sizes above are tagged export evidence. Publication is verified by immutable commit/tag `6d84764745102b95e22b2462eeaa364103678c0b` / `v0.5.0`, passing GitHub Actions run `33136431022`, the four public release archives and Vercel production `dpl_BTEuXpYNMWmEYbWP2h2hNjAVGkGL`. These delivery facts do not replace named-hardware frame-time or memory profiling. The published v0.4.0 measurements below remain historical evidence and must not be relabeled as v0.5.0 performance measurements.

## Published v0.4.0 release — 2026-08-25

The tagged Godot 4.7.1 release exports successfully, starts on the development Windows machine and is deployed publicly. These remain size, integrity and startup gates, not a frame-time profile.

| Platform | Local release measurement | Verified check |
|---|---:|---|
| Windows x64 | **182,039,024 bytes** | hidden launch remained active for eight seconds |
| Linux x64 | **146,403,616 bytes** | export completed |
| Web total | **112,777,790 bytes across nine files** | `qa:web` 282/282; `verify:web` passed |
| Web PCK | **72,933,396 bytes** | below the 100,000,000-byte Web gate |
| Web WASM | **39,513,091 bytes** | unchanged engine payload |

Local Chromium reports `crossOriginIsolated=true`, one visible accessible 1258×566 main canvas, loaded PCK/WASM resources, no page error and the expected WebGL2 single-thread Godot information logs. This is a rendering/startup gate, not frame pacing evidence.

Vercel production `dpl_HeyKmQ5aZ5yypUXokC5ZJXsgrYLW` is `READY`. Downloaded root, PCK and WASM match local files exactly (SHA-256 `847421ad…`, `caa42ba7…`, `35116f68…`); public Chromium confirms the same isolation/accessibility markers, zero page errors and the visually inspected menu. This proves delivery and startup, not throughput, latency or frame pacing.

The strengthened full QA passes 292/292 and includes the complete campaign and interaction smokes. Stable 60 fps, 1% low, CPU/GPU frame time, memory residency and physical light-gun latency remain unprofiled on named hardware; the eight-second Windows check proves startup only.

## Published v0.3.0 release — 2026-08-25

Immutable tag `v0.3.0` at exact commit `8add70a31a751928ea12c247ca584d8b030b2139` was exported with Godot 4.7.1 and exercised through static, executable-startup, source-distribution and browser gates before publication.

| Platform | Local release-candidate measurement | Verified check |
|---|---:|---|
| Windows x64 | **187,023,472 bytes** | export succeeded; hidden launch remained active for eight seconds |
| Linux x64 | **151,388,064 bytes** | export succeeded |
| Web total | **117,762,238 bytes across nine files** | export succeeded; `qa:web` 276/276; `verify:web` OK |
| Web PCK | **77,917,844 bytes** | local payload observed |
| Web WASM | **39,513,091 bytes** | local payload observed |

The content/import gates completed with 128 texture imports and zero mismatches, 1,708 environment-verifier assertions, 348/348 dedicated animated-effect assertions and 113/113 gameplay-support assertions. The full local orchestration passed 282/282, while the audio contract remained green at 354 assertions across 28 cues. These are integrity and startup measurements, not frame-time measurements.

A local Chromium run through agent-browser 0.34 reported `crossOriginIsolated=true`, an accessible 1258×622 main canvas, WebGL2 in the single-thread Web path, zero page errors and three Godot informational logs. Menu, Arcade/P1 gameplay and continue were visible. This proves successful local rendering and flow reachability; it does not establish throughput, latency, frame pacing or memory residency.

Vercel production `dpl_KUcS7Xh1NEMU2GRJTki2Hc4kwPuy` is `Ready`. Downloaded root, PCK and WASM sizes/hashes match locally; Chromium confirms isolation, one visible 1258×622 canvas and zero page errors. This proves delivery and startup, not frame pacing.

The target of stable 60 fps remains **unprofiled** for v0.3.0. No named-hardware capture currently establishes average frame time, 1% low, worst frame, CPU/GPU memory, atlas residency or boss/route-transition hitch behavior. The eight-second Windows smoke is a startup gate only.

The performance evidence below is retained as versioned v0.2.1 history and must not be substituted for a v0.3.0 profiling run.

## Current v0.2.1 content budget

The runtime uses one rail camera, atlas-based `Sprite3D` actors, camera-relative eight-direction resolution, procedural 3D layout geometry and deterministic `delta`-based gameplay clocks.

The current verified content contract contains:

- 38 dedicated directional atlases and 2,432 animation cells;
- 25 dedicated enemy profiles and unique enemy types;
- 20 environment materials and 33 route-node environment profiles;
- 6 destructible profiles and 14 decorative prop profiles;
- 28 deterministic procedural audio cues, including five ambience loops and four short original music loops.

The environment source PNG set totals 75.67 MiB. The static import audit covers 124 texture files with zero profile mismatches. These are source/content measurements, not runtime resident-memory measurements.

## Target

The target remains stable 60 fps at 1280×720 on a mid-range Windows PC, invariant gameplay timing, bounded encounter allocations and a compatibility-renderer Web build. No v0.2.1 frame-time capture on named hardware has yet demonstrated that target, so it remains a target rather than a measured result.

Atlas reuse avoids a separate texture allocation for every direction/state cell. Route transitions release active encounter and environment nodes, while procedural audio avoids shipping unlicensed Sega recordings. These implementation choices reduce obvious allocation pressure, but they do not replace profiling.

## Current build measurements

| Platform | Current v0.2.1 size | Verified check |
|---|---:|---|
| Windows x64 | 161,321,616 bytes | Godot 4.7.1 export succeeded; hidden launch remained active for eight seconds |
| Linux x64 | 125,686,208 bytes | Godot 4.7.1 export succeeded |
| Web total | 92,060,382 bytes across nine files | Godot 4.7.1 export succeeded; `qa:web` 275/275; `verify:web` OK |
| Web PCK | 52,215,988 bytes | current payload observed |
| Web WASM | 39,513,091 bytes | current payload observed |

The Windows launch smoke demonstrates startup continuity on the development machine only. It is not a frame-rate benchmark, a full playthrough or a clean-machine installation test.

## Current runtime verification

The complete v0.2.1 local QA orchestration passed 280/280 checks against the unchanged runtime payload. The procedural-audio suite passed 354 assertions across 28 distinct cues, including safe peak amplitudes and deterministic stream dimensions. Godot gameplay and full-campaign smokes completed after cleanup without a shutdown warning or leaked-instance report.

## Production Web observation

After the ResourceLoader and source-QA corrections, v0.2.1 Vercel deployment `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` reached `Ready` production at <https://the-house-of-the-dead-25d.vercel.app>. Public Chromium reported zero console/page errors and `crossOriginIsolated=true`; the accessible 1258×622 Godot canvas rendered the menu and P1/continue flow.

Public root, PCK and WASM probes return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. This proves successful production resource delivery for that run; it is not a latency benchmark or frame-time profile.

## Published release evidence

The corrected source evidence is anchored to commit [`c13d525`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/c13d525d63dc9ef4e92d30c0ab5851047fa76f66) and [release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1). Source (227,864,129 bytes), Windows (90,978,140), Linux (81,014,969), Web (62,151,092) and the 421-byte manifest are uploaded with matching remote digests. The executable/Web payloads are unchanged, so v0.2.0 runtime measurements remain the applicable performance evidence.

## Required profiling pass

Record the following for both faithful 4:3 and composed 16:9 gameplay on named hardware:

- average frame time, 1% low and worst observed frame;
- peak visible actors, projectiles, impacts and decorative motes;
- process memory, GPU memory and atlas residency;
- first encounter spawn, route transition and every boss-phase hitch;
- audio generation/cache cost and simultaneous bus activity;
- chapter-transition loading time and Web PCK/WASM startup behavior.

A clean physical Windows machine and physical light guns remain separate functional/performance gates. Exact comparison with an authorized licensed Sega arcade reference build also remains unverified.
