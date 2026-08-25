# Performance Report

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
