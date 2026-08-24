# Performance Report

## Current v0.2.0 content budget

The runtime uses one rail camera, atlas-based `Sprite3D` actors, camera-relative eight-direction resolution, procedural 3D layout geometry and deterministic `delta`-based gameplay clocks.

The current verified content contract contains:

- 38 dedicated directional atlases and 2,432 animation cells;
- 25 dedicated enemy profiles and unique enemy types;
- 20 environment materials and 33 route-node environment profiles;
- 6 destructible profiles and 14 decorative prop profiles;
- 28 deterministic procedural audio cues, including five ambience loops and four short original music loops.

The environment source PNG set totals 75.67 MiB. The static import audit covers 124 texture files with zero profile mismatches. These are source/content measurements, not runtime resident-memory measurements.

## Target

The target remains stable 60 fps at 1280×720 on a mid-range Windows PC, invariant gameplay timing, bounded encounter allocations and a compatibility-renderer Web build. No v0.2.0 frame-time capture on named hardware has yet demonstrated that target, so it remains a target rather than a measured result.

Atlas reuse avoids a separate texture allocation for every direction/state cell. Route transitions release active encounter and environment nodes, while procedural audio avoids shipping unlicensed Sega recordings. These implementation choices reduce obvious allocation pressure, but they do not replace profiling.

## Current build measurements

| Platform | Current v0.2.0 size | Verified check |
|---|---:|---|
| Windows x64 | 161,321,616 bytes | Godot 4.7.1 export succeeded; hidden launch remained active for eight seconds |
| Linux x64 | 125,686,208 bytes | Godot 4.7.1 export succeeded |
| Web total | 92,060,382 bytes across nine files | Godot 4.7.1 export succeeded; `qa:web` 275/275; `verify:web` OK |
| Web PCK | 52,215,988 bytes | current payload observed |
| Web WASM | 39,513,091 bytes | current payload observed |

The Windows launch smoke demonstrates startup continuity on the development machine only. It is not a frame-rate benchmark, a full playthrough or a clean-machine installation test.

## Current runtime verification

The complete v0.2.0 local QA orchestration passed 280/280 checks. The procedural-audio suite passed 354 assertions across 28 distinct cues, including safe peak amplitudes and deterministic stream dimensions. Godot gameplay and full-campaign smokes completed after cleanup without a shutdown warning or leaked-instance report.

## Local Web observation

After the ResourceLoader correction, Vercel deployment `dpl_548ttUkKWa3tHvBQzkDDQzmNgx6Z` reached `Ready` production at <https://the-house-of-the-dead-25d.vercel.app>. Public Chromium reported zero console/page errors and `crossOriginIsolated=true`; the 1258×622 Godot canvas rendered the menu, P1 gameplay, HUD and continue surfaces.

Public root, PCK and WASM probes return HTTP 200, WASM uses `application/wasm`, and COOP/COEP are present. This proves successful production resource delivery for that run; it is not a latency benchmark or frame-time profile.

## Published release evidence

The v0.2.0 evidence is anchored to commit [`d79f86a`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/d79f86ac9f1e3f990ff6fdc9535d165a2ca7db21) and the public [v0.2.0 release](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.0). Source (227,860,921 bytes), Windows (90,978,140), Linux (81,014,969) and Web (62,151,092) are uploaded, with remote ZIP SHA-256 digests matching local files.

## Required profiling pass

Record the following for both faithful 4:3 and composed 16:9 gameplay on named hardware:

- average frame time, 1% low and worst observed frame;
- peak visible actors, projectiles, impacts and decorative motes;
- process memory, GPU memory and atlas residency;
- first encounter spawn, route transition and every boss-phase hitch;
- audio generation/cache cost and simultaneous bus activity;
- chapter-transition loading time and Web PCK/WASM startup behavior.

A clean physical Windows machine and physical light guns remain separate functional/performance gates. Exact comparison with an authorized licensed Sega arcade reference build also remains unverified.
