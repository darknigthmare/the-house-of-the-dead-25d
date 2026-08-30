# Sprite Production Bible

## Contract

All organic actors render as `Sprite3D` nodes inside the 3D world. Collision and damage volumes are separate 3D shapes, so a visual atlas never defines gameplay accuracy. Feet use a bottom anchor; flying actors use their body center. Every atlas is preloaded before its encounter.

The repository contains original fan-made OpenAI artwork only. No Sega model, frame grab, scan, ROM texture, or video extraction is included.

## Directional-atlas baseline — v2

The repository contains **38 dedicated, identity-specific v2 atlases** under `assets/sprites_v2/`. They cover Thomas Rogan, Agent G, Sophie Richards, the DBR scientist, three additional scientist variants, Dr. Curien, the four bosses, the mutant bat and 25 canonical enemy profiles. No two v2 identities share a proxy atlas. V2 remains the active fallback for 37/38 profiles; Sam A1 now atomically selects the complete v3 sidecar described below.

- Each final PNG is 2048×2048 RGBA.
- The atlas is eight columns by eight rows: 64 cells of 256×256 pixels.
- The 38 atlases therefore expose 2,432 addressable direction/state cells.
- Row order: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`.
- Column order: `idle`, `move_contact_a`, `move_passing`, `move_contact_b`, `action_windup`, `action_strike`, `hit_recoil`, `death_fall`.
- Every cell keeps a 12-pixel transparent gutter plus a 2-pixel art margin, so visible pixels remain at least 14 pixels away from an atlas boundary.
- Actor identity, scale, costume and palette remain fixed across cells.
- `SpriteActor3D` advances local state frames independently of the render frame rate. `DirectionalSpriteResolver` selects the direction row from the actor/camera relationship and applies the documented mirror policy.

OpenAI ImageGen source sheets retained either six or seven complete direction rows. The deterministic assembler never labels a nonexistent source view as generated:

- every atlas derives `right` by mirroring the authored `left` profile;
- a seven-row source keeps its authored `back_right` and derives only `right`;
- a six-row source derives `back_right` from `back_left` and `right` from `left`;
- source and final SHA-256 values, observed row/column counts and every derived direction/state are recorded in `data/assets/sprite_generation_provenance.json` and `reports/runtime/directional-atlas-assembly.json`.

Some source sheets arrived with seven state columns. Horizontal-only normalization duplicated one complete source stripe where documented; Hangedman and Dr. Curien specifically map `hit_recoil` from their complete `action_strike` source cell. These cases are recorded per identity rather than hidden.

## Final repair and isolation pass

The final v2 assembler does not divide a source sheet into blind equal-width crops. It keys the green production background, labels eight-connected foreground components, assigns each complete silhouette to its ordered direction/state slot and reattaches small weapon or limb fragments to the nearest primary body. Each recovered object is then aspect-fitted into its 256×256 destination cell, anchored to the ground and edge-despilled before the 12-pixel gutter plus 2-pixel art margin is enforced. This prevents a long weapon that crosses a logical source boundary from becoming a floating or missing fragment in the runtime atlas.

The targeted repair cases are explicit and reproducible:

- Chariot uses the ignored production source `reports/runtime/directional-sources/chariot_compact_v2.png`, generated as `01a00811-e655-7262-8c79-852788f57b9b/exec-9cf6af14-9456-4839-95ef-2bee67c502b9.png`. Whole-component extraction keeps the bardiche attached through windup, strike and recoil cells.
- Samson's unusable `front_right/death_fall` source fragment is replaced by a documented copy of the valid `right/death_fall` cell: `front_right/death_fall_from_right/death_fall`.
- Dr. Curien's seven-state source maps `hit_recoil` from the complete `action_strike` cell instead of retaining two clipped partial figures.
- Moody's action columns 4 and 5 use a 196-pixel target body height, 86% of the 228-pixel usable area. The chain is localized and shortened horizontally while retaining the body, claw head and terminal spike; the policy covers both action cells in all seven authored rows.

The current atlas audit contract covers all 38 atlases and 2,432 cells, including `scientist_male_blue`, `scientist_male_gray` and `scientist_female_lab`. Its deterministic checks reject empty cells, transparent-gutter violations, silhouettes touching the inner cut-risk boundary and retained keyed-green fringe pixels. These checks validate atlas isolation; they do not turn the compact eight-state cycle into a complete licensed arcade animation library.

Each v2 atlas is intentionally one compact eight-state **action cycle**. It is not presented as a complete licensed animation library with separate multi-frame clips for every idle, walk, run, attack, localized hit, dismemberment, boss phase and death variation. Those richer per-clip sources remain an integration target when authorized assets become available.

## Directional animation-clip convention — v3 Sam A1 pilot

The v3 pilot is a separate, stricter sidecar contract. It does not relabel duplicated v2 cells as longer animation and it does not silently mix incomplete v3 clips with v2 states. One actor profile becomes runtime-eligible only after all five required clips pass validation:

1. `idle`;
2. `locomotion`;
3. `attack`;
4. `hit_recoil`;
5. `death_fall`.

Each clip has its own sheet rather than sharing one semantic action-cycle atlas. A completed sheet is 2048×2048 RGBA, arranged as eight direction rows by eight chronological animation frames. The canonical row order is `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`. All eight directions must be independently authored: v3 forbids left/right or diagonal mirroring, and the verifier explicitly rejects a right row copied from a mirrored left row.

The selected OpenAI single-sheet sources are 1254×1254 RGB images with a baked neutral checkerboard. The accepted idle replacement uses two 1254×1254 RGB sheets containing four directions each; the accepted split-death replacement uses two 1774×887 RGB sheets containing four directions each. None has native alpha and none is shipped directly. `scripts/build_sprite_contract_v3.mjs` removes only edge-connected background, decontaminates neutral fringe, extracts the ordered figures, applies one clip-wide raster scale, grounds every frame and writes real RGBA cells with a 12-pixel transparent gutter. It writes to a validated temporary PNG and performs an atomic rename with retry, so a transient Windows write failure cannot leave a partial final atlas. The generated silhouette supplies the artwork; this normalization does not invent an animation frame or direction.

Sam A1 is the first pilot because its fixed identity is simple to audit: pale gray-green flesh, torn stained off-white maintenance shirt, dark blue work trousers, black boots, no armor and no firearm. As of 2026-08-30:

- all five required clips — `idle`, `locomotion`, `attack`, `hit_recoil` and `death_fall` — are certified final atlases: each has 64/64 unique non-empty cells, eight distinct frames in each direction, zero exact mirrors across all three left/right direction pairs, true RGBA, zero detected neutral fringe, enforced gutters and a stable ground anchor;
- the first single-sheet `idle` attempt remains rejected because deterministic segmentation found 56/64 substantial silhouettes and visual review confirmed only seven direction rows; two accepted four-direction idle sources now compose the certified final `idle` atlas;
- the attempted single-sheet `death_fall` replacement also remains rejected because it contains only seven direction rows; the accepted `front_half` and `back_half` sources each contain four ordered directions by eight frames and compose the certified final `death_fall` atlas;
- non-cumulative runtime `display_scale` values are applied from immutable `base_pixel_size`: `idle` 1.0, `locomotion` 1.0282, `attack` 1.1231, `hit_recoil` 1.0282 and `death_fall` 1.0896. The five opening poses therefore present the same 219-pixel apparent standing height without resampling or changing any hitbox.

Activation is atomic at actor-profile level. All five required Sam A1 sheets now exist with validated hashes, so the gameplay runtime activates the complete v3 profile; any invalid/missing clip makes the whole actor fall back to its verified v2 profile. The adapter is presentation-only and does not alter hitboxes, health, score, attack ranges or route timing. Attack and recoil hold their last frame through their gameplay recovery window, an interrupted wind-up cannot damage while recoil is shown, and death displays every authored frame before its hold/fade. The remaining 37 actor profiles continue to use v2, so current production coverage is honestly **1/38 V3**.

## Legacy 4×4 convention

The older `assets/sprites/` sheets use four columns by four rows and sixteen equal cells: idle/anticipation, locomotion, action and hit/death groupings. They are retained for provenance and migration compatibility but are not the dedicated v2 visual contract. `legacy_path` in `data/assets/sprite_manifest.json` is an audit pointer, not permission for active v2 identities to share a proxy.

## 2.5D integration

Sprites use camera-facing billboards, depth testing, fog, ambient tint and a separate contact shadow decal. Hitboxes stay in world space. Grounded actors use fixed-Y billboarding; flying actors may use full billboarding. The current campaign runtime uses nearest filtering for its atlas sprites in both aspect modes; smoother HD sampling exists only as an art-direction target until it is wired and verified.

## Damage layers

Humanoid campaign actors use separate head, torso, left-arm, right-arm and leg hit areas; non-humanoids use a body area, while boss vulnerability adds encounter-specific filtering. Hits can change atlas regions and spawn impact feedback. Reduced flashes, reduced shake and blood-level settings affect the current presentation; detached-limb behavior is not claimed as integrated.

## Acceptance checks

1. PNG loads with alpha.
2. Final dimensions are exactly 2048×2048.
3. Eight direction rows and eight state columns expose 64 non-empty cells.
4. Feet/body origin does not jump between frames.
5. No text, watermark or baked backdrop.
6. Collision volumes align at front, rear, profile and three-quarter camera angles.
7. Every identity resolves to a unique final v2 path and SHA-256.
8. Mirrored/derived rows and state columns match the per-asset provenance record.
9. No visible pixel enters the 12-pixel gutter or touches its inner cut-risk boundary.
10. Keyed green is absent from semi-transparent edge pixels under the repository verifier's despill rule.
11. A v3 profile exposes all five required clips atomically; each clip has eight independently authored direction rows and eight chronological frames with no exact mirrored opposite row.
12. A v3 `display_scale` stays within 0.75–1.35 and is always recalculated from immutable `base_pixel_size`, never multiplied cumulatively across clip swaps.
13. The exported PCK loads the tracked v3 manifest, scripts and textures and completes the production-manifest, directional lifecycle and gameplay smokes.

Repository QA automates PNG signature, RGBA/alpha declaration, exact dimensions, 8×8 layout, 38 unique v2 bindings, 64 non-empty cells per atlas, the 12-pixel gutter, likely boundary clipping, green-edge despill, Moody action-scale stability and provenance consistency. V3 adds hash/path/profile uniqueness, 64 unique cells per clip, eight distinct frames per direction, mirror/fringe/proportion rejection, atomic loader fallback, direction hysteresis and full clip-lifecycle tests. Origin stability, artistic continuity and multi-angle collision alignment remain visual acceptance gates.
