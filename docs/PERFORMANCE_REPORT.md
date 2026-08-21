# Performance Report

## Budget and implementation

The runtime uses one rail camera, atlas-based `Sprite3D` actors, camera-relative eight-direction resolution, simple procedural geometry and deterministic `delta`-based gameplay clocks. The 35 2048×2048 RGBA atlases expose 64 cells each without allocating a new texture for every state. Environments and active encounters are released at route boundaries.

Target: stable 60 fps at 1280×720 on a mid-range Windows PC, invariant gameplay timing, bounded encounter allocations and a compatibility-renderer Web build.

## Published artifacts — 2026-08-21

| Platform | Size | Check |
|---|---:|---|
| Windows x64 | 202,088,128 bytes | headless startup passed |
| Linux x64 | 166,452,720 bytes | export produced |
| Web total | 132,826,890 bytes / nine files | `qa:web` 256/256; `verify:web` OK |
| Web PCK | 92,982,496 bytes | 7,017,504 bytes below 100,000,000 |
| Web WASM | 39,513,091 bytes | HTTP 200 with correct MIME locally |

Five quality-sensitive Web imports use quality 0.92. Their alpha channels are unchanged; measured PSNR is 35.31–35.81 dB and MAE 2.72–2.86/255.

## Local browser observation

Chromium through agent-browser 0.34 ran Godot 4.7.1 WebGL2/Emscripten single-threaded with `crossOriginIsolated=true`, PCK/WASM HTTP 200 and zero page errors. Title/menu and live P1/P2 with two HUDs/two crosshairs rendered at 1280×720, 390×844 and 844×390. Axe 4.12 returned 23 passes and 0 violations.

Cached local menu navigation measured TTFB 2.39 ms, FCP 99.13 ms, LCP 99.13 ms and CLS 0. These are local cached menu figures, not network production metrics or full-gameplay performance evidence.

## Production observation

Vercel deployment `dpl_Hs23gpsUfidKJeEDPs1K45NeWYyW` is `READY` at <https://the-house-of-the-dead-25d.vercel.app>; its reported build duration is 980 ms. The production root, 39,513,091-byte WASM and 92,982,496-byte PCK return HTTP 200. WASM is served as `application/wasm`, COOP/COEP are present and `crossOriginIsolated=true` in Chromium. Production QA observed title rendering, WebGL2, live P1/P2 with two HUDs/two crosshairs, zero console/page errors, network PCK/WASM 200 and axe at 23 passes/0 violations.

## Open measurements

Deep profiling must still record average frame time, 1% low, peak actors, process/GPU memory, first-spawn and boss-transition hitches at 4:3 and 16:9 on named hardware. Two `ObjectDB` instances reported when gameplay/campaign smokes shut down remain a non-blocking cleanup diagnostic. No steady-state leak conclusion is inferred. A clean physical Windows machine, physical light guns and exact comparison with a licensed reference build remain separate validation gates; Vercel production delivery itself is verified.
