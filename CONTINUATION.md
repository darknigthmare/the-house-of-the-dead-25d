# Continuation

## Current state

Godot 4.7.1 project with a four-chapter data-driven campaign, local 2P, 4:3 framing, rail camera, 3D environments and collisions, Sprite3D actors, body hit zones, civilians, breakables, score, ammunition, lives, continues, branching, four bosses, chapter-four rematches, three endings, credits, Training, Boss Rush and Chapter Select.

Directional Sprite V2 is integrated and visually approved: 35 unique 2048×2048 RGBA atlases, eight directions × eight states, 64 cells per actor and 2,240 cells total. The 25 enemy identities have dedicated profiles. The post-repair audit passes for framing, long parts, Samson's death cell and chroma cleanup. The eight-state cycle is a compact game-ready set, not a complete licensed arcade animation library.

The project is public at <https://github.com/darknigthmare/the-house-of-the-dead-25d>. Release v0.1.0 is published at exact tag commit `4f222998e1225cde3f2933477344cf782f84f6a8`; Source, Windows, Linux, Web and `SHA256SUMS.txt` assets are uploaded and their remote sizes/digests match the local release set. GitHub Actions runs 32435148599 (tag, 28 s) and 32435035804 (documentation, 38 s) are green. Git-connected `main` production is `Ready` at <https://the-house-of-the-dead-25d.vercel.app>.

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
- public GitHub repository and exact v0.1.0 tag commit `4f222998e1225cde3f2933477344cf782f84f6a8` verified;
- v0.1.0 published with Source (137,825,223 bytes), Windows (130,767,749 bytes), Linux (121,139,247 bytes), Web (102,962,391 bytes) and `SHA256SUMS.txt` (421 bytes);
- all remote release assets report `uploaded`; every remote ZIP digest matches the local SHA-256 manifest;
- GitHub Actions runs 32435148599 (tag, 28 s) and 32435035804 (documentation, 38 s) green;
- Git-connected `main` production `Ready` on Vercel;
- production root/WASM/PCK HTTP 200, WASM `application/wasm`, COOP/COEP present;
- production browser: title, WebGL2, `crossOriginIsolated=true`, live P1/P2 with two HUDs/two crosshairs, PCK/WASM 200, zero console/page errors, axe 23 passes/0 violations.

## Next exact task

No priority release-delivery task remains. The next work is limited to the still-unverified physical/reference gates:

1. install and run the Windows archive on a clean physical Windows 64-bit machine;
2. calibrate and test physical Gun4IR/Sinden/light-gun devices, including two independent devices;
3. perform deep full-campaign profiling on named target hardware;
4. compare routes, timings and endings against an authorized licensed reference build.

## Precautions

- Do not stage the unrelated parent repository, `.tools`, `.godot`, licensed assets, reference builds, ignored ImageGen source sheets or secrets.
- Do not claim arcade-exact timings until an authorized reference build is measured.
- Keep the two-`ObjectDB` shutdown warning visible.
- Do not confuse the verified production-browser evidence or cached-menu vitals with deep full-campaign hardware profiling.
- A clean physical Windows machine, physical light guns, deep profiling on named hardware and a licensed reference-build comparison remain separate unverified gates.
- After extracting the Linux ZIP, run `chmod +x The_House_of_the_Dead_25D.x86_64` before launch.
