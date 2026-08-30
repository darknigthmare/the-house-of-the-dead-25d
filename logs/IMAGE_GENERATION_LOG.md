# Image Generation Log

## 2026-08-30 — Sam A1 directional animation pilot v3

The built-in OpenAI ImageGen tool generated original fan-made Sam A1 source sheets for a five-clip v3 pilot. No API key was used or stored. This wave replaces neither the verified v2 atlas nor licensed Sega content: it establishes a per-clip animation contract with `idle`, `locomotion`, `attack`, `hit_recoil` and `death_fall`.

Every completed v3 clip must contain eight chronological frames in each of these eight independently authored directions: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`. Mirroring is forbidden. Single-sheet raw outputs are 1254×1254 RGB and the split death sources are 1774×887 RGB. All have a baked neutral checkerboard and require deterministic local background recovery before they can become 2048×2048 RGBA runtime sheets.

### Candidate ledger

| Clip/status | Selected or rejected source | SHA-256 | Evidence status |
|---|---|---|---|
| `locomotion` — certified normalized | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__locomotion__8dirx8f.openai.png` | `28cc24cf4ffb02ea72f3a7faa0776a028f9e51f1c53d547f44ba250ed176e8a5` | Accepted source. Final atlas has 64/64 non-empty cells, eight distinct frames per direction, zero mirrored-right matches, RGBA alpha, 12-pixel gutters and stable foot anchor. |
| `idle` — rejected | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__idle__8dirx8f.openai.png` | `2a94529659ffafc028365bd7a7157bd51d93e41173a01bd1dd547738155761e2` | Rejected: deterministic segmentation found 56/64 substantial silhouettes and visual audit confirms seven direction rows. |
| `idle` directions 1–4 — accepted source half | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__idle__front_half__4dirx8f.openai.png` | `b10f1ad495a2cadc639f8b8962ccce6ba1ecb9603ddadcfe3fda2ae87c2ca906` | Accepted for `front`, `front_left`, `left`, `back_left`; eight frames per direction. |
| `idle` directions 5–8 — accepted source half | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__idle__back_half__4dirx8f.openai.png` | `8d0772ae9d1f2ebceb66626c1be71f913ba263a22edea669aada8230d4de09e1` | Accepted for `back`, `back_right`, `right`, `front_right`; composed final SHA-256 `0f5954ad96f253749abf4654a76aed390242e78eb43c3917192e4026a0a165f1`. |
| `attack` — certified normalized | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__attack__8dirx8f.openai-v2.png` | `a134c3689b14c06d075723c9bfb6c51c2f4a34bd23fe379c03dbd9cea181b1b2` | Final SHA-256 `c317ee6ff60fc43dc74881197f2c74e554aed6f14b25c5e756e7b62a110f2348`. Supersedes the cropped first attempt. |
| `hit_recoil` — certified normalized | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__hit_recoil__8dirx8f.openai-v2.png` | `42673c2dec4fd1c3ac4af9eed901b15a1484e2933369f9c78a21968dab1b3030` | Final SHA-256 `8b175bf3f8a4e42289e676dbb9859f6ce2588d702f85453ced4bf72e3f1bb164`. Supersedes the incomplete first attempt. |
| `death_fall` — rejected full-sheet attempt | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__death_fall__8dirx8f.openai-v2.png` | `46ce50bf19a4da3867e0c06f6c31f9043a99321bd5bc963a98b2565fa5914725` | Rejected: visual audit found seven direction rows, not eight. Retained for provenance only. |
| `death_fall` directions 1–4 — accepted source half | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__death_fall__front_half__4dirx8f.openai.png` | `64a4d9acb4e32c6fa67bce0ae27db574186b8be3cb6f57e43a1ef34575b34dce` | Accepted source for `front`, `front_left`, `left`, `back_left`; eight frames per direction. |
| `death_fall` directions 5–8 — accepted source half | `reports/runtime/directional-sources-v3/sam_a1/sam_a1__v3__death_fall__back_half__4dirx8f.openai.png` | `96b58464c2a9061085813fba37365bb492e82bc3ad17527e1d0c29c3fd939dc6` | Accepted source for `back`, `back_right`, `right`, `front_right`; composed final SHA-256 `4e2b0420574630334778cffb749b983d49c627b4ad14790d42fa2f18a807439c`. |

The five certified normalized outputs are `idle` (2,316,276 bytes, SHA-256 `0f5954ad96f253749abf4654a76aed390242e78eb43c3917192e4026a0a165f1`), `locomotion` (2,518,639 bytes, `56cdaab26e434afc8568dc0eefcd63220e7b7f04d7deffd5da1de4de3fec21a4`), `attack` (2,585,028 bytes, `c317ee6ff60fc43dc74881197f2c74e554aed6f14b25c5e756e7b62a110f2348`), `hit_recoil` (2,417,677 bytes, `8b175bf3f8a4e42289e676dbb9859f6ce2588d702f85453ced4bf72e3f1bb164`) and `death_fall` (1,893,296 bytes, `4e2b0420574630334778cffb749b983d49c627b4ad14790d42fa2f18a807439c`). If the normalizer changes and any file is rebuilt, its hash and sidecar provenance must be updated together before certification.

`scripts/build_sprite_contract_v3.mjs` flood-removes the edge-connected checkerboard, decontaminates neutral edge fringe, extracts ordered whole figures, applies one clip-wide scale, anchors grounded feet and writes 64 RGBA cells with transparent gutters. Final PNGs are written through a validated temporary file and atomic rename with retry. Runtime then applies a non-cumulative presentation scale from immutable `base_pixel_size`: `idle` 1.0, `locomotion` 1.0282, `attack` 1.1231, `hit_recoil` 1.0282 and `death_fall` 1.0896. This deterministic pass cannot create a missing row, direction or animation phase and does not change gameplay hitboxes.

The exact initial raw prompts for `locomotion` and `idle` were not persisted in the repository. Detailed raw prompts for the later replacement/split requests exist in the task evidence but are also not yet repository artifacts. `docs/OPENAI_IMAGE_PROMPTS.md` therefore records a complete normalized production template and explicitly does not present it as a verbatim transcript.

Runtime selection remains atomic. All five normalized clips now pass their hashes and structural validation, so Sam A1 activates the complete v3 profile. Any future missing/invalid required clip falls the actor back in full to `assets/sprites_v2/enemies/sam_a1/sam_a1__v2__action_cycle__8dirx8f.png`; no individual v3 clip is ever mixed into an incomplete profile. Current v3 runtime coverage is 1/38 actors.

## 2026-08-21 — directional sprite production v2

The built-in OpenAI ImageGen tool produced original fan-made source sheets for 38 distinct organic identities. No ROM, model rip, screenshot, frame grab or artwork extracted from public video was used. No API key or absolute machine path is stored in the repository.

The selected set covers Thomas Rogan, Agent G, Sophie Richards, the DBR scientist, `scientist_male_blue`, `scientist_male_gray`, `scientist_female_lab`, Dr. Curien, 25 canonical enemy profiles, the mutant bat and Chariot, Hangedman, Hermit and Magician. Each identity has its own final path and SHA-256; there is no proxy sharing within the v2 set.

### Source request and observed output

- Requested layout: eight state columns across seven direction rows on exact removable green.
- Requested directions: front, front-left, left, back-left, back, back-right and front-right.
- Requested states: idle, move contact A, move passing, move contact B, action windup, action strike, hit recoil and death fall.
- Accepted ImageGen sheets retained six or seven complete direction rows. Incomplete/cropped alternatives were rejected or relaunched; Harris and Kenfis corrections are retained in the selection records. Samson retains one explicitly documented cell fallback where the selected source contains only a detached `front_right/death_fall` fragment.
- Most sheets retained eight state columns. Sources with seven columns were normalized horizontally only when a complete source stripe could be duplicated without inventing new artwork. Hangedman's final `hit_recoil` is explicitly mapped from its authored `action_strike` source cell.

### Deterministic assembly

`scripts/assemble_directional_atlases.py` converts the green background to alpha, labels eight-connected foreground components, assigns complete silhouettes by ordered source row, reattaches nearby weapon/limb fragments, aspect-fits each recovered object, anchors it to the ground and reduces green edge spill. It then writes each object into a 256×256 RGBA cell with a 12-pixel transparent gutter plus a 2-pixel art margin, producing one 2048×2048 atlas per identity under `assets/sprites_v2/`.

Final direction rows are always: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`. Right is mirrored from the left profile for all 38 identities. For six-row sources, back-right is also mirrored from back-left; seven-row sources keep their generated back-right. The final result is 38 unique atlases × 64 cells, or 2,432 direction/state cells.

The assembly is intentionally an eight-state action cycle, not a complete licensed multi-clip animation library. Separate longer clips for all attacks, body-part reactions, dismemberment and boss phases remain pending authorized source material.

### Final repair pass

- Chariot was relaunched as the compact source `reports/runtime/directional-sources/chariot_compact_v2.png` using generation reference `01a00811-e655-7262-8c79-852788f57b9b/exec-9cf6af14-9456-4839-95ef-2bee67c502b9.png`. The earlier source remains preserved locally; the compact selection plus whole-component extraction keeps the bardiche silhouette attached across action cells.
- Samson maps `front_right/death_fall` from the valid neighbouring `right/death_fall` cell because the authored source slot contains only a tiny detached fragment. The derivation is recorded as `front_right/death_fall_from_right/death_fall`.
- Dr. Curien maps `hit_recoil` from the complete `action_strike` source cell because the selected source contains seven usable state columns. No partial clipped figures are retained.
- Moody's columns 4 and 5 use the localized-chain policy in all seven authored directions: the body targets 196 pixels, or 86% of the 228-pixel usable cell height, while the long chain is shortened horizontally without discarding the body, claw head or terminal spike.

The current automated audit contract covers 38 dedicated atlases and 2,432 direction/state cells, including the three additional scientist identities. It scans for empty cells, visible pixels inside the 12-pixel gutter, silhouettes touching the inner cut-risk boundary and keyed-green fringe pixels under the configured despill rule. This validates the repaired compact atlas contract; it is not evidence that a full licensed arcade animation library is present.

### Provenance records

- `data/assets/sprite_generation_provenance.json`: sanitized public record for all 38 outputs, including provider, generation reference, source/final hashes, row/column counts and derivations.
- `data/assets/sprite_manifest.json`: active schema-2 runtime bindings, all marked `dedicated_fan_made_v2`, with legacy paths retained only for audit/migration.
- `reports/runtime/group_humans_bosses.json`: local selection report for ten identities.
- `reports/runtime/group_enemies_ad.json`: local selection report for 13 identities.
- `reports/runtime/group_enemies_eg.json`: local selection report for 11 identities.
- `reports/runtime/directional-atlas-assembly.json`: local 38-atlas assembly report.
- `reports/runtime/directional-sources/`: selected local source sheets, ignored by Git and excluded from the public deliverable.

The three original grouped reports account for 34 identities; the Sam A1 pilot and the three additional scientist sheets complete the 38-identity consolidated public provenance and final assembly report. Generated originals remain in the image tool's managed output storage outside the repository. Only the final transparent atlases and sanitized provenance are intended for the public source tree.

## 2026-08-24 — environment and gameplay-support completion

The built-in OpenAI ImageGen tool supplied original fan-made sources for 20 individual materials, 14 environment props and eight active two-state destructibles. Deterministic local processing writes 42 sanitized provenance records and converts those selections into material albedo/normal/ORM maps, transparent prop atlases and 16 intact/broken destructible outputs available to the 42-node environment contract.

The same built-in tool supplied seven projectile cutouts, three HUD families and four boss weak-point diagrams. These are original project replacements, not extracted Sega artwork.

Selected sources, exact local selection manifests and visual contacts remain under ignored `reports/runtime/environment-sources/` paths. Public normalized files and source/final SHA-256 values are recorded under `assets/environments_v2/`, `assets/gameplay_v2/` and `data/assets/`. No `licensed_assets/` or `reference_build/` directory contributed content.

The `garden_lamp` source was replaced on 2026-08-25 by the geometry-consistent ON/OFF selection identified by built-in generation reference `01a00811-e655-7262-8c79-852788f57b9b/exec-e5b102ac-9615-4234-888c-1175bc796dde.png`. Its painted checkerboard is recovered to alpha locally; neutral edge despill and a one-way ON-silhouette clamp remove the white fringe without changing internal metal or flame highlights. The final atlas and source fingerprint are recorded by `data/assets/environment_generation_provenance.json`.

On 2026-08-25, four additional set-piece breakables were integrated from already selected per-state sources: `c01_water_barrel`, `c01_chariot_antechamber_barrels`, `c02_corridor_crates` and `c03_unlocked_room_crates`. The local source metadata did not include their exact built-in generation references, so none are claimed. `scripts/build_environment_assets.py` records each intact/broken source hash plus an ordered-pair fingerprint, recovers alpha from the flattened neutral matte, removes large white remnants, despills the silhouette edge and writes grounded 1024×1024 RGBA states. Visual review on a dark contact sheet confirmed eight distinct, readable states without visible white cards or clipped silhouettes.

No image generation was used to fabricate Sega audio. Exact Sega voices, dialogue performances, music and sound effects remain missing; current audio substitutes are original procedural replacements only.

## 2026-08-25 — dedicated animated environment effects

The built-in OpenAI ImageGen tool produced four original fan-made 4×2 source sheets on a removable green key. Each request specified eight ordered animation moments, isolated effect artwork, stable scale/palette, no text, no logo, no UI, no character, no scenery and no copied Sega frame. The selected generations are:

| Effect | Generation reference | Final runtime path |
|---|---|---|
| Damp ceiling drips and splash cycle | `01a00811-e655-7262-8c79-852788f57b9b/exec-4fc2df33-f942-4336-b121-9a1068b26e72.png` | `assets/environments_v2/effects/drips/drips_strip.png` |
| Sewer/laboratory water-flow cycle | `01a00811-e655-7262-8c79-852788f57b9b/exec-ba9ad960-9b27-43d4-8056-a79b64fcad44.png` | `assets/environments_v2/effects/water_flow/water_flow_strip.png` |
| Laboratory electrical-arc cycle | `01a00811-e655-7262-8c79-852788f57b9b/exec-0b7ed69d-2226-4d21-aa7d-dafbefd11ba8.png` | `assets/environments_v2/effects/electrical_arc/electrical_arc_strip.png` |
| Green CRT monitor-scan cycle | `01a00811-e655-7262-8c79-852788f57b9b/exec-d18efd19-b490-453d-94c5-9c21c1932c1e.png` | `assets/environments_v2/effects/monitor_scan/monitor_scan_strip.png` |

`scripts/build_animated_effects.py` splits each selected 4×2 source in row-major order, removes connected green-key regions, despills edge pixels, preserves a transparent four-pixel gutter and assembles an eight-frame 2048×256 RGBA strip. The monitor frames receive one shared display-plane alignment so the two source rows do not produce a vertical jump. Exact hashes, processing steps and private-source boundaries are tracked in `data/assets/animated_effect_generation_provenance.json`; `scripts/verify_animated_effects.mjs` validates the public outputs without requiring ignored private sources.

## 2026-08-16 — built-in OpenAI ImageGen

Actor-atlas constraints: original fan-made art; transparent background; strict 4x4 atlas; sixteen isolated frames; stable identity/scale/palette; no text, logo, UI, watermark, scenery, official screenshot or copied asset.

Environment constraints: original fan-made full-frame 16:9 backdrop; strong rail perspective and layered depth; no characters, text, logo, UI, watermark, official screenshot or copied room geometry.

| Output | Prompt focus | Tool |
|---|---|---|
| `assets/sprites/bosses/hermit-type-6803.png` | Armored giant spider; idle, charge, leg/web attack, head exposure and death | built-in ImageGen |
| `assets/sprites/npcs/dr-curien.png` | Long black coat; command, walk, console, shock and fall | built-in ImageGen |
| `assets/sprites/npcs/dbr-scientist.png` | 1990s lab coat; danger, run, rescue and fall | built-in ImageGen |
| `assets/sprites/enemies/axe-creature.png` | Gray-blue heavy humanoid; axe locomotion/attacks/disarm/death | built-in ImageGen |
| `assets/sprites/enemies/mutant-bat.png` | Gothic mutant bat; hover/flight/dive/bite/fall | built-in ImageGen |
| `assets/environments/mansion-exterior.png` | Gothic manor exterior with arcade-readable central approach | built-in ImageGen |
| `assets/environments/mansion-hall.png` | Mansion hall with layered occluders and central rail composition | built-in ImageGen |
| `assets/environments/curien-laboratory.png` | Green-blue underground bioengineering chamber | built-in ImageGen |
| `assets/environments/underground-tunnel.png` | Damp masonry tunnel, iron walkways and strong vanishing point | built-in ImageGen |

## Post-generation normalization

The five built-in actor outputs were normalized with `scripts/normalize_generated_atlases.mjs`: checkerboard-colored edge backgrounds were flood-selected, converted to transparent alpha and the complete sheets resized to 1024×1024 RGBA. This deterministic Sharp pass did not source or synthesize replacement artwork. Repository QA subsequently verified PNG signatures, alpha declaration and dimensions divisible by four. These 4×4 sheets are now legacy/superseded for the actors covered by the directional v2 contract.

The environment images were not processed by the actor-atlas normalizer.

## Prior project-owned assets

The nine older actor sheets and four item icons were copied from a prior user-owned project. Their original generation and QA are documented in that project's `generated-complete-sprites-house-of-the-dead-2026-07-22.md` audit. The actor sheets remain as legacy provenance/migration files; they are not active v2 proxies.
