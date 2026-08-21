# QA Report

This report separates static validation, Godot runtime smokes, exported-artifact checks, visual audit and local browser evidence. GitHub/Vercel/public results are not claimed before publication.

## Verified snapshot — 2026-08-21

| Surface | Observed result | Proven scope |
|---|---|---|
| `npm.cmd test` | 252/252 | static data, manifest, atlas, route and roster checks |
| `npm.cmd run qa` | 257/257 | full local QA orchestration |
| deterministic core suite | 232 assertions | arcade rules and controllers |
| manifest atomicity suite | 57 assertions | invalid/late failures cannot leave partial bindings |
| directional runtime smoke | passed: 35 bindings, seven representatives, eight directions | manifest-to-runtime direction/state selection |
| atlas verifier | 35 unique 2048×2048 RGBA atlases, 64 cells each, 2,240 cells | dimensions, alpha, unique bindings and cell population |
| enemy roster | 25 dedicated profiles | no final V2 enemy proxy binding |
| visual audit after repairs | PASS | long-part crops, Samson death cell, chroma fringe and direction readability |
| gameplay smoke | passed | 2P records, four chapters, six shots, off-screen reload, independent gamepad aim |
| score smoke | passed | attributed `+120` and `-100`; disabled logging remains silent |
| initials smoke | passed | `COD`, confirmation and credits |
| campaign smoke | passed with shutdown warning | chapters 1–4; Chariot, Hangedman, Hermit, both rematches, Magician; 15/15 scientists; ending and credits |
| Windows export | 202,088,128 bytes; headless startup passed | exported Windows x64 launch |
| Linux export | 166,452,720 bytes | configured Linux artifact produced |
| Web export | nine files, 132,826,890 bytes | PCK 92,982,496; WASM 39,513,091 |
| five Web quality imports | quality 0.92; alpha unchanged; PSNR 35.31–35.81; MAE 2.72–2.86/255 | measured transformed-image quality |
| `npm.cmd run qa:web` | 256/256 | final patched Web payload and accessibility guards |
| `npm.cmd run verify:web` | OK | HTML/JS/WASM/PCK/title markers |
| local Chromium | passed; zero page errors | agent-browser 0.34, Godot 4.7.1 WebGL2 single-thread, `crossOriginIsolated=true`, PCK/WASM HTTP 200 |
| live browser P1/P2 | passed | title/menu then two HUDs and two crosshairs |
| responsive browser | passed | 1280×720, 390×844, 844×390 |
| axe 4.12 | 23 passes, 0 violations | canvas has `role=main`; current three-view local pass |

The PCK remains below 100,000,000 bytes by 7,017,504 bytes. Gameplay/campaign smokes report two leaked `ObjectDB` instances at shutdown; this is a non-blocking diagnostic, not a clean leak audit.

## Evidence boundaries

The automated campaign proves the four-chapter success route and required boss/rematch sequence through ending and credits. The local Chromium pass proves startup, local Web asset delivery, P1/P2 presentation and responsive/accessibility states. It is not a complete browser playthrough of every route or ending.

Still pending: physical mouse/controller/light-gun combinations, Gun4IR/Sinden calibration, clean-machine Windows installation, exhaustive manual alternative routes/endings, signed archives and SHA-256, GitHub publication, Vercel deployment and all public URL probes.
