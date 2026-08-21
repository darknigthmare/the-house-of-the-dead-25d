# Continuation

## Current state

Godot 4.7.1 project with a four-chapter data-driven campaign, local 2P, 4:3 framing, rail camera, 3D environments and collisions, Sprite3D actors, body hit zones, civilians, breakables, score, ammunition, lives, continues, branching, four bosses, chapter-four rematches, three endings, credits, Training, Boss Rush and Chapter Select.

Directional Sprite V2 is integrated and visually approved: 35 unique 2048×2048 RGBA atlases, eight directions × eight states, 64 cells per actor and 2,240 cells total. The 25 enemy identities have dedicated profiles. The post-repair audit passes for framing, long parts, Samson's death cell and chroma cleanup. The eight-state cycle is a compact game-ready set, not a complete licensed arcade animation library.

## Last completed task

Final pre-publication validation on 2026-08-21:

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
- caveated cached-menu vitals: TTFB 2.39 ms, FCP/LCP 99.13 ms, CLS 0.

## Next exact task

1. Run the final Git preflight and inspect/stage only project files.
2. Commit the exact verified tree and push it to the new GitHub repository.
3. Run `scripts/package_release.ps1` from the committed tree; verify all archives and `SHA256SUMS.txt`, then publish the GitHub release.
4. Link/deploy the same commit to Vercel.
5. Repeat HTTP headers, PCK/WASM, page-error, P1/P2, responsive and axe checks on the public URL.

GitHub, release archives/SHA-256, Vercel and public QA are pending and must not be reported as completed before those checks.

## Precautions

- Do not stage the unrelated parent repository, `.tools`, `.godot`, licensed assets, reference builds, ignored ImageGen source sheets or secrets.
- Do not claim arcade-exact timings until an authorized reference build is measured.
- Keep the two-`ObjectDB` shutdown warning visible.
- Do not confuse local browser evidence with production evidence or cached-menu vitals with full-campaign performance.
- After extracting the Linux ZIP, run `chmod +x The_House_of_the_Dead_25D.x86_64` before launch.
