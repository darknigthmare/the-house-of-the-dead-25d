# Image Generation Log

## 2026-08-21 — directional sprite production v2

The built-in OpenAI ImageGen tool produced original fan-made source sheets for 35 distinct organic identities. No ROM, model rip, screenshot, frame grab or artwork extracted from public video was used. No API key or absolute machine path is stored in the repository.

The selected set covers Thomas Rogan, Agent G, Sophie Richards, the DBR scientist, Dr. Curien, 25 canonical enemy profiles, the mutant bat and Chariot, Hangedman, Hermit and Magician. Each identity has its own final path and SHA-256; there is no proxy sharing within the v2 set.

### Source request and observed output

- Requested layout: eight state columns across seven direction rows on exact removable green.
- Requested directions: front, front-left, left, back-left, back, back-right and front-right.
- Requested states: idle, move contact A, move passing, move contact B, action windup, action strike, hit recoil and death fall.
- Accepted ImageGen sheets retained six or seven complete direction rows. Incomplete/cropped alternatives were rejected or relaunched; Harris and Kenfis corrections are retained in the selection records. Samson retains one explicitly documented cell fallback where the selected source contains only a detached `front_right/death_fall` fragment.
- Most sheets retained eight state columns. Sources with seven columns were normalized horizontally only when a complete source stripe could be duplicated without inventing new artwork. Hangedman's final `hit_recoil` is explicitly mapped from its authored `action_strike` source cell.

### Deterministic assembly

`scripts/assemble_directional_atlases.py` converts the green background to alpha, labels eight-connected foreground components, assigns complete silhouettes by ordered source row, reattaches nearby weapon/limb fragments, aspect-fits each recovered object, anchors it to the ground and reduces green edge spill. It then writes each object into a 256×256 RGBA cell with a 12-pixel transparent gutter plus a 2-pixel art margin, producing one 2048×2048 atlas per identity under `assets/sprites_v2/`.

Final direction rows are always: `front`, `front_left`, `left`, `back_left`, `back`, `back_right`, `right`, `front_right`. Right is mirrored from the left profile for all 35 identities. For six-row sources, back-right is also mirrored from back-left; seven-row sources keep their generated back-right. The final result is 35 unique atlases × 64 cells, or 2,240 direction/state cells.

The assembly is intentionally an eight-state action cycle, not a complete licensed multi-clip animation library. Separate longer clips for all attacks, body-part reactions, dismemberment and boss phases remain pending authorized source material.

### Final repair pass

- Chariot was relaunched as the compact source `reports/runtime/directional-sources/chariot_compact_v2.png` using generation reference `01a00811-e655-7262-8c79-852788f57b9b/exec-9cf6af14-9456-4839-95ef-2bee67c502b9.png`. The earlier source remains preserved locally; the compact selection plus whole-component extraction keeps the bardiche silhouette attached across action cells.
- Samson maps `front_right/death_fall` from the valid neighbouring `right/death_fall` cell because the authored source slot contains only a tiny detached fragment. The derivation is recorded as `front_right/death_fall_from_right/death_fall`.
- Dr. Curien maps `hit_recoil` from the complete `action_strike` source cell because the selected source contains seven usable state columns. No partial clipped figures are retained.
- Moody's columns 4 and 5 use the localized-chain policy in all seven authored directions: the body targets 196 pixels, or 86% of the 228-pixel usable cell height, while the long chain is shortened horizontally without discarding the body, claw head or terminal spike.

The final automated audit reports **PASS** for 35 dedicated atlases and 2,240 direction/state cells. Its full-cell scan detected zero empty cells, zero visible pixels inside the 12-pixel gutter, zero silhouettes touching the inner cut-risk boundary and zero keyed-green fringe pixels under the configured despill rule. The final visual re-audit also reports zero blocking sprite cuts. This is evidence for the repaired compact atlas contract, not evidence that a full licensed arcade animation library is present.

### Provenance records

- `data/assets/sprite_generation_provenance.json`: sanitized public record for all 35 outputs, including provider, generation reference, source/final hashes, row/column counts and derivations.
- `data/assets/sprite_manifest.json`: active schema-2 runtime bindings, all marked `dedicated_fan_made_v2`, with legacy paths retained only for audit/migration.
- `reports/runtime/group_humans_bosses.json`: local selection report for ten identities.
- `reports/runtime/group_enemies_ad.json`: local selection report for 13 identities.
- `reports/runtime/group_enemies_eg.json`: local selection report for 11 identities.
- `reports/runtime/directional-atlas-assembly.json`: local 35-atlas assembly report.
- `reports/runtime/directional-sources/`: selected local source sheets, ignored by Git and excluded from the public deliverable.

The three grouped reports account for 34 identities; the Sam A1 pilot is included directly in the consolidated public provenance and final assembly report. Generated originals remain in the image tool's managed output storage outside the repository. Only the final transparent atlases and sanitized provenance are intended for the public source tree.

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
