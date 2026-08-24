# Continuation

## Current state — local v0.2.0 worktree

The package version is `0.2.0`. The current local Godot 4.7.1 worktree contains the four-chapter data-driven campaign, local 2P, 4:3 framing, rail camera, Sprite3D actors, 3D hit zones/collisions, scientists, breakables, scoring, six-round ammunition, lives, continues, routes, four bosses, chapter-four rematches, three endings, credits, Training, Boss Rush and Chapter Select.

The original replacement-content contract is integrated:

- 38 dedicated 2048×2048 RGBA directional actor atlases, eight directions × eight states, 2,432 cells total;
- 25 dedicated enemy profiles plus distinct heroes, narrative actors, bosses and three additional scientist variants;
- 20 environment material families (60 albedo/normal/ORM maps), profiles for all 33 campaign nodes, 14 props and six intact/broken destructibles;
- seven projectile cutouts, an eight-frame life torch, bullet/reload HUD assets and four boss weak-point diagrams;
- 28 distinct original procedural audio cues used as temporary replacements for weapon, UI, ambience, boss, short music-loop and non-verbal voice-like feedback;
- manifest-driven runtime integration for node-specific environments, PBR surfaces, props/decorative motion, projectile visuals, breakables, civilians and support HUD.

The environment, enemy-profile and gameplay-support loaders use `ResourceLoader` for export-safe resource resolution. The correction is covered by successful Windows, Linux and Web exports rather than editor-only parsing.

This replacement contract is verified locally. It must not be described as exact Sega arcade certification: no authorized Sega reference build, revision/operator configuration or licensed visual/audio masters were available.

## Last completed task — 2026-08-24

Completed the v0.2.0 original content-completion and runtime-integration pass, corrected export-time resource loading, then re-ran its deterministic, export and browser validation surfaces:

- `npm.cmd test`: 271/271;
- `npm.cmd run qa`: 280/280;
- core suite: 235 assertions;
- sprite atlas atomicity: 63 assertions;
- environment library: 56 assertions;
- gameplay-support library: 25 assertions;
- enemy profile runtime contract: 135 assertions;
- procedural audio: 354 assertions across 28 distinct cues;
- directional smoke: 38 bindings, ten representatives, eight directions, death and cleanup states;
- environment verifier: 1,517 assertions, 20 materials, 33 nodes, six destructibles and 14 props;
- gameplay-support verifier: 83/83;
- texture import profile: 124 files, zero mismatches;
- targeted runtime parse: 9/9 scripts;
- gameplay smoke: two players, four chapters, six shots to empty, off-screen reload to six, independent gamepad aim and projectile rules;
- score smoke: `+120` and `-100` with QA logging disabled in normal mode;
- initials smoke: `COD`, confirmation to credits and demo bypass;
- campaign smoke: chapters 1–4, Chariot, Hangedman, Hermit, both rematches, Magician, 15/15 scientists, ending and credits;
- Windows export: 161,321,616 bytes; eight-second startup check passed;
- Linux export: 125,686,208 bytes;
- Web export: 92,060,382 bytes total, including a 52,215,988-byte PCK and 39,513,091-byte WASM;
- Web static checks: `qa:web` 275/275 and `verify:web` OK;
- local browser: Vercel local server plus agent-browser 0.34, no console errors, `crossOriginIsolated=true`, accessible canvas at 1258×622, with menu, gameplay, HUD and continue visible.

The raw Windows, Linux and Web exports are locally verified, but no v0.2.0 commit, push, tag, packaged archive, GitHub release or Vercel deployment is recorded by this checkpoint. The previously published v0.1.0 release remains historical evidence only and must not be presented as containing the v0.2.0 worktree.

## Main modified areas in the v0.2.0 worktree

- `assets/sprites_v2/`, `assets/environments_v2/`, `assets/gameplay_v2/`;
- `data/assets/`, `data/audio/`, `data/runtime/campaign_timeline.json`;
- `src/gameplay/`, `src/audio/`, `src/main.gd`;
- asset-build/verification scripts and deterministic tests;
- README, licensing, missing-assets, production, catalog and continuation documentation.

The worktree also contains generated Godot import metadata. Review it selectively before staging; do not assume every unrelated or ignored workspace file belongs in a release.

## Next exact task

1. Review the complete v0.2.0 diff and stage only project-owned source, normalized assets, manifests, tests and documentation.
2. Create and record the v0.2.0 commit from that reviewed staged candidate.
3. Package the verified Windows, Linux and Web exports plus the source archive, then generate and verify `SHA256SUMS.txt`.
4. Create the v0.2.0 tag, push the commit/tag, publish the GitHub release and upload the verified archives.
5. Deploy the same v0.2.0 Web candidate to Vercel, then repeat HTTP, isolation, console and visible-flow checks against production.
6. Separately retain clean physical Windows, two-light-gun, named-hardware profiling and authorized Sega reference comparison as unverified gates.

## Commands to resume

```powershell
npm.cmd test
npm.cmd run qa
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/parse_runtime.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_gameplay.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_score_qa.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_initials.gd
& '.tools\godot-4.7.1\Godot_v4.7.1-stable_win64_console.exe' --headless --path . --script res://scripts/smoke_campaign.gd
npm.cmd run qa:web
npm.cmd run verify:web
git diff --check
```

Run packaging, checksum and publication commands only after the v0.2.0 candidate has been reviewed, staged and committed.

## Precautions

- Preserve unrelated local changes. Do not stage `.tools`, `.godot`, licensed/reference folders, ignored ImageGen source sheets, secrets or unrelated parent-repository files.
- Treat the current sprites, environments, UI and procedural audio as original replacement assets, never as extracted or certified Sega masters.
- Do not claim “100% arcade faithful”, exact timings, exact ending thresholds or exact audio until an authorized reference build is measured.
- Do not infer a v0.2.0 commit, tag, GitHub release or Vercel deployment from the package version or from the previously published v0.1.0 state.
- Keep physical Windows installation, physical light-gun calibration, deep named-hardware profiling and authorized reference comparison as separate unverified gates.
