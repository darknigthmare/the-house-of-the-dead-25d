# OpenAI Image Prompts

All listed generation used the built-in OpenAI image tool and produced original fan-made project artwork with no copied official pixels. Selected actor sources use a removable flat green background; the deterministic assembly pass produces transparent RGBA atlases. Environment backdrops are intentionally full-frame opaque scenes.

## Active directional actor-atlas contract — v2

Use case: `stylized-concept`. Asset: 2.5D rail-shooter directional sprite source sheet. Request a strict eight-state horizontal sequence for seven camera directions, with isolated full-body poses, consistent identity/scale/palette and hand-painted 1990s arcade-horror sprite art. Use an exact removable green background, no text, logo, UI, watermark, scenery, floor shadow, cast shadow, frame labels or overlapping cells.

Direction rows requested, top to bottom:

1. front;
2. front-left three-quarter;
3. left profile;
4. back-left three-quarter;
5. back;
6. back-right three-quarter;
7. front-right three-quarter.

State columns requested, left to right:

1. idle;
2. move contact A;
3. move passing;
4. move contact B;
5. action windup;
6. action strike;
7. hit recoil;
8. death fall.

Keep feet on one baseline for grounded actors. Keep flying actors centered with complete wings/limbs inside each cell. Preserve silhouette, costume, carried weapon and damage cues in every view. Render one identity only and do not invent accessories between rows.

ImageGen did not always retain all seven requested direction rows. Accepted sources contain six or seven complete rows. Final assembly always produces an 8×8, 2048×2048 RGBA atlas by deriving the opposite right profile from the left profile and, for six-row sources, the back-right view from the back-left view. The final eighth row is the authored front-right view. This policy prevents identity drift and is recorded per asset in `data/assets/sprite_generation_provenance.json`.

The v2 request deliberately targets one eight-state action cycle per identity. It is not a prompt for a full licensed multi-clip animation library. Future authorized production should request separate directional sheets for idle, walk, run, every attack, each localized hit, dismemberment layers, boss phases and death variants.

## Legacy actor-atlas contract

The earlier 2026-08-16 generation used a strict 4×4 grid with sixteen isolated full-body frames, stable identity and scale, transparent-target post-processing, and no text/logo/UI/watermark/scenery/floor shadow/overlap. Those sheets remain under `assets/sprites/` as legacy provenance/migration material; the v2 runtime contract does not reuse them as shared actor proxies.

## Environment-backdrop contract

Use case: `stylized-concept`. Asset: original 2.5D rail-shooter depth backdrop. Full-frame 16:9 composition, strong central rail perspective, readable foreground/midground/background separation, 1990s gothic arcade-horror palette, no characters, text, logo, UI, watermark or copied room geometry.

## 2026-08-16 additions

- **Hermit Type 6803:** armored laboratory spider; idle, charge, leg/web attacks, exposed-head reactions and death; charcoal/brown/olive palette.
- **Dr. Roy Curien:** gaunt bioengineer in a long black laboratory coat; command, walk, console, shock and fall sequences.
- **DBR scientist:** anxious researcher in an aged-ivory lab coat; danger, run, rescue, accidental-hit and fall sequences.
- **Axe creature:** gray-blue heavy humanoid with fire axe; walk, charge, swing, disarm, hit and death.
- **Mutant bat:** diseased gothic bat; hover, flight, dive, bite, hit-spin and fall.

The output paths, generation focus and post-processing provenance are recorded in `logs/IMAGE_GENERATION_LOG.md`. The repository does not present its summarized focus lines as a verbatim raw tool transcript.

## 2026-08-21 directional production

The fixed prompt above was specialized with one canonical identity block per actor: silhouette, anatomy, costume/armor, weapon or carried object, palette, scale, anchor and forbidden elements. The completed 38-output contract covers 25 canonical enemy profiles, the mutant bat, eight human/narrative actors and four bosses. The three added civilian identities are `scientist_male_blue`, `scientist_male_gray` and `scientist_female_lab`. Rejected/corrected generations, relaunch counts, selected-source hashes and any duplicated state stripe are documented in:

- `data/assets/sprite_generation_provenance.json` — public, sanitized 38-asset provenance;
- `reports/runtime/group_humans_bosses.json` — local selection audit for ten identities;
- `reports/runtime/group_enemies_ad.json` — local selection audit for 13 identities;
- `reports/runtime/group_enemies_eg.json` — local selection audit for 11 identities;
- `reports/runtime/directional-atlas-assembly.json` — local final assembly report for all 38 atlases.

The selected source sheets under `reports/runtime/directional-sources/` are local production/QA intermediates and are ignored by Git. The public deliverables are the transparent atlases under `assets/sprites_v2/` plus sanitized hashes and generation references; no absolute machine path or API key is recorded.

## 2026-08-24 environment and gameplay-support production

All requests used the built-in OpenAI ImageGen tool and asked for original fan-made 1990s arcade-horror artwork without copied official pixels, text, logos, UI labels, watermarks, screenshots or extracted geometry.

### Individual material prompt contract

Use case: `stylized-concept`. Asset: square seamless surface source viewed straight-on with even diffuse lighting, no perspective, objects, borders, text or baked shadow. Keep the palette and wear appropriate to the named garden, mansion, sewer, roof or laboratory surface. Twenty selected sources are deterministically converted into 1024×1024 albedo, 512×512 normal and 256×256 packed ORM outputs.

### Prop and destructible prompt contract

Use case: isolated transparent game asset. Asset: one complete environment object, readable silhouette, hand-painted low-poly 1997 arcade-horror style, stable scale and no floor/cast shadow. Legacy two-state requests show two equal side-by-side objects with only the intended flame, indicator, open/closed or intact/broken state changing. The active tracked contract contains 14 prop atlases and eight two-state breakables. Four additional set-piece breakables (`c01_water_barrel`, `c01_chariot_antechamber_barrels`, `c02_corridor_crates`, `c03_unlocked_room_crates`) were supplied as separate intact/broken images and use the same silhouette/state contract. The original production wave also generated a final bonus-gate seal and an emergency supply crate; those two obsolete outputs remain outside the active contract.

The second prop wave specializes that contract for `mansion_chandelier`, `mansion_sconce`, `mansion_double_door`, `library_bookcase`, `mansion_portrait` and `lab_control_console`. Where the downloaded RGB source flattened a pale checkerboard, deterministic edge-connected flood fill, narrow alpha feathering and despill remove only the exterior matte; light stone, candle wax, flames and portrait details remain protected.

### Projectile, HUD and weak-point prompt contract

Use case: `transparent-background`. Asset: centered isolated cutout with a strong arcade-readable silhouette and no label or frame decoration. Seven projectile requests cover thrown axe, thrown dagger, thrown barrel, organic spit, iron claw, Hermit web ball and Magician fireball. Three HUD families cover an eight-frame life torch, a bullet round and a reload-offscreen icon. Four monochrome boss diagrams mark only the intended red weak zones for Chariot, Hangedman, Hermit and Magician.

Selected production sources are local ignored intermediates under `reports/runtime/environment-sources/`. Public normalized outputs and sanitized hashes live under `assets/environments_v2/`, `assets/gameplay_v2/` and `data/assets/`. Active environment provenance contains exactly 42 records: 20 materials, 14 props and eight breakables. For the four paired additions, provenance records each source file hash plus a deterministic ordered-pair fingerprint; their exact built-in generation references were not present in the supplied metadata and are not invented. No Sega asset or licensed-source directory contributed pixels to this wave.
