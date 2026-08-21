# QA Report

This report separates static validation, Godot runtime smokes, exported-artifact checks, visual audit, local browser evidence and verified public-production results.

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
| public GitHub release | v0.1.0 at exact tag commit `4f222998e1225cde3f2933477344cf782f84f6a8` | <https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.1.0> |
| release assets | all remote states `uploaded`; sizes and ZIP SHA-256 digests match local files | Linux 121,139,247; Source 137,825,223; Web 102,962,391; Windows 130,767,749; `SHA256SUMS.txt` 421 bytes |
| GitHub Actions | runs 32435148599 (tag, 28 s) and 32435035804 (documentation, 38 s) green | final release/tag and documentation checks |
| Vercel production | Git-connected `main`, `Ready` | <https://the-house-of-the-dead-25d.vercel.app> |
| public HTTP | root/WASM/PCK 200; WASM `application/wasm`; COOP/COEP present | production artifact delivery and isolation headers |
| public Chromium | title, WebGL2, `crossOriginIsolated=true`, zero console/page errors | deployed Godot startup and clean browser runtime |
| public live P1/P2 | two HUDs and two crosshairs; PCK/WASM network 200 | deployed two-player presentation |
| public axe | 23 passes, 0 violations | production accessibility scan |

The release ZIP digests verified locally and remotely are Linux `4b43df0004b9e16f014b94c99357421ec631f038791cd25acab9a97d9df6c17a`, Source `3643a7d94028e70d89c69f015a4408b353342f251026ecf6fba899a44814703a`, Web `c40bdad9aa9852ae0348c6efe926119acaf5fe1b08bc8460965c959a9ffe944c` and Windows `f8d0338aa8a727fb6088d697cc6ba888bec6ed84275ddbaccac73afe5f9d5a1a`.

The PCK remains below 100,000,000 bytes by 7,017,504 bytes. Gameplay/campaign smokes report two leaked `ObjectDB` instances at shutdown; this is a non-blocking diagnostic, not a clean leak audit.

## Evidence boundaries

The automated campaign proves the four-chapter success route and required boss/rematch sequence through ending and credits. The local and production Chromium passes prove startup, Web asset delivery, P1/P2 presentation and accessibility state on the deployed artifact. The exact arcade-reference equivalence remains gated by an authorized licensed reference build.

Still unverified: a clean physical Windows-machine installation, physical light-gun/Gun4IR/Sinden calibration, deep profiling on named hardware and exact comparison with a licensed reference build. GitHub publication, CI, Vercel production and public URL probes are complete.
