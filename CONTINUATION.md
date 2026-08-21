# Continuation

## Current state

Godot 4.7.1 project with a four-chapter data-driven campaign, local 2P, 4:3 framing, rail camera, 3D environments and collisions, Sprite3D actors, body hit zones, civilians, breakables, score, ammunition, lives, continues, branching, four bosses, chapter-four rematches, three endings, credits, Training, Boss Rush and Chapter Select.

Directional Sprite V2 is integrated and visually approved: 35 unique 2048×2048 RGBA atlases, eight directions × eight states, 64 cells per actor and 2,240 cells total. The 25 enemy identities have dedicated profiles. The post-repair audit passes for framing, long parts, Samson's death cell and chroma cleanup. The eight-state cycle is a compact game-ready set, not a complete licensed arcade animation library.

The project is public at <https://github.com/darknigthmare/the-house-of-the-dead-25d>, commit `d98487bca5592418e80342221f671538ed40058a`. GitHub Actions run 32434278324 is green for `npm test`, `qa:web` and `verify:web`. Production is live at <https://the-house-of-the-dead-25d.vercel.app> through deployment `dpl_Hs23gpsUfidKJeEDPs1K45NeWYyW`, status `READY`.

## Last completed task

Final validation and public publication on 2026-08-21:

- `npm.cmd test`: 252/252.
- `npm.cmd run qa`: 257/257; CORE 232, atomic manifest 57, directional smoke 35 bindings/seven representatives/eight directions.
- gameplay smoke: 2P, four chapters, six shots, off-screen reload and independent gamepad aim passed;
- score smoke: `+120` and `-100`; initials smoke: `COD` then credits;
- campaign smoke: chapters 1–4, Chariot, Hangedman, Hermit, Chariot rematch, Hangedman rematch, Magician, 15/15 scientists, ending and credits;
- two `ObjectDB` shutdown instances remain a non-blocking gameplay/campaign diagnostic;
- final exports: Windows 202,088,128 bytes with headless startup, Linux 166,452,720 bytes, Web nine files/132,826,890 bytes, PCK 92,982,496 bytes, WASM 39,513,091 bytes;
- five Web quality imports: quality 0.92, unchanged alpha, PSNR 35.31–35.81 dB, MAE 2.72–2.86/255;
- `qa:web`: 256/256; `verify:web`: OK;
- local browser: agent-browser 0.34, Godot 4.7.1 WebGL2 single-thread, `crossOriginIsolated=true`, PCK/WASM 200, title/menu and live P1/P2 with two HUDs/two crosshairs, 1280×720, 390×844 and 844×390, zero page errors, axe 4.12 23 passes/0 violations;
- caveated cached-menu vitals: TTFB 2.39 ms, FCP/LCP 99.13 ms, CLS 0;
- public GitHub repository and commit verified;
- GitHub Actions run 32434278324 green in 20 seconds (`npm test`, `qa:web`, `verify:web`);
- Vercel production deployment `dpl_Hs23gpsUfidKJeEDPs1K45NeWYyW` `READY`, build 980 ms;
- production root/WASM/PCK HTTP 200, WASM `application/wasm`, COOP/COEP present;
- production browser: title, WebGL2, `crossOriginIsolated=true`, live P1/P2 with two HUDs/two crosshairs, PCK/WASM 200, zero console/page errors, axe 23 passes/0 violations.

## Next exact task

1. Run `scripts/package_release.ps1` from the committed `HEAD`.
2. Verify every archive and entry in `SHA256SUMS.txt`.
3. Publish the archives on the [GitHub v0.1.0 release target](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.1.0), then verify the downloaded files and hashes.

After that release packaging check, no priority delivery task remains.

## Precautions

- Do not stage the unrelated parent repository, `.tools`, `.godot`, licensed assets, reference builds, ignored ImageGen source sheets or secrets.
- Do not claim arcade-exact timings until an authorized reference build is measured.
- Keep the two-`ObjectDB` shutdown warning visible.
- Do not confuse the verified production-browser evidence or cached-menu vitals with deep full-campaign hardware profiling.
- A clean physical Windows machine, physical light guns, deep profiling on named hardware and a licensed reference-build comparison remain separate unverified gates.
- After extracting the Linux ZIP, run `chmod +x The_House_of_the_Dead_25D.x86_64` before launch.
