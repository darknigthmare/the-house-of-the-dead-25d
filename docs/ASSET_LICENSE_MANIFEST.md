# Asset License Manifest

The user states that they hold the permissions needed for this remake. This public-worktree audit still keeps every absent licensed file separate and includes no ROM, frame grab, video extraction or ripped commercial asset.

## Active v2 sprite-production assets

| Name | Path | Type | Provenance supplied | Status | Usage | Replacement | Transformed version | Integration date |
|---|---|---|---|---|---|---|---|---|
| 35 dedicated directional actor atlases | `assets/sprites_v2/{heroes,npcs,enemies,bosses}/<actor>/<actor>__v2__action_cycle__8dirx8f.png` | 2048×2048 RGBA PNG, 8 directions × 8 states | Built-in OpenAI ImageGen source selection plus deterministic project assembler | Project-owned original fan art; `dedicated_fan_made_v2` | Active organic-actor rendering in the 2.5D runtime | Replaces legacy/shared proxy bindings | Contract v2; connected-component extraction, fragment reattachment, aspect-fit, ground anchoring, chroma removal/despill, 12-pixel gutter, 2-pixel art margin and documented derivations | 2026-08-21 |
| Selected directional source sheets | `reports/runtime/directional-sources/<actor>.png` | Local production intermediate, six or seven direction rows | Built-in OpenAI ImageGen; per-source generation reference and SHA-256 recorded | Local/ignored, not part of the public source deliverable | Reproducible atlas assembly and visual QA | Not a runtime asset | Selected/corrected source; Chariot uses `chariot_compact_v2.png`; occasional state-cell normalization is explicitly logged | 2026-08-21 |
| Sprite generation provenance | `data/assets/sprite_generation_provenance.json` | Sanitized JSON metadata | Generated from the three selection reports, Sam pilot record and assembly report | Public project metadata | Provider, source/final hashes, row counts, derived directions/states and notes for all 35 identities | Replaces informal filename-only provenance | Schema 1 | 2026-08-21 |
| Directional sprite manifest | `data/assets/sprite_manifest.json` | Runtime JSON manifest | Deterministically built by `scripts/build_sprite_contract_v2.mjs` | Active runtime source of truth | Unique atlas binding, dimensions, layout, billboard, anchors and legacy audit pointers | Replaces legacy 4×4 runtime bindings | Schema 2 / contract v2 | 2026-08-21 |
| Directional atlas assembler | `scripts/assemble_directional_atlases.py` | Original project tooling | Project-authored Pillow/NumPy pipeline | Project-owned | Eight-connected component extraction, fragment reattachment, aspect-fit, ground anchoring, chroma-to-alpha, edge despill, special-cell derivation and assembly report | Replaces manual atlas slicing | Art pipeline v2 repaired/final | 2026-08-21 |

The 35 unique identities are: `thomas_rogan`, `agent_g`, `sophie_richards`, `dbr_scientist`, `dr_curien`, `sam_a1`, `neil_a2`, `cyril_a3`, `kageo_b1`, `bourbon_b2`, `ebitan_a_b3`, `ebitan_b_b4`, `samson_c1`, `bentley_c2`, `burner_c3`, `simon_d1`, `gilmore_d2`, `harris_d3`, `robert_d4`, `rubin_e1`, `drake_e2`, `moody_e3`, `parlor_e4`, `kenfis_f1`, `saruzou_f2`, `bouere_f3`, `devilon_f4`, `murrer_g1`, `name_g2`, `taran_g3`, `mutant_bat`, `chariot`, `hangedman`, `hermit` and `magician`.

Every final atlas contains 64 addressable 256×256 cells, for 2,240 cells across the set. No v2 identity uses another identity's atlas as a proxy. The right profile is consistently derived from the left profile; six-row sources also derive back-right from back-left. Seven-row sources retain generated back-right. Any direction, state-column or individual-cell derivation is listed per asset in `data/assets/sprite_generation_provenance.json` and the ignored local assembly report.

The final repair pass records the following non-destructive transformations: Chariot's compact regeneration and whole-bardiche extraction; Samson's `front_right/death_fall` copy from `right/death_fall`; Dr. Curien's `hit_recoil` copy from `action_strike`; and Moody's localized action-chain treatment in columns 4 and 5 at a 196-pixel body target, 86% of the usable cell height. These transformations reuse generated pixels and are not presented as additional authored frames. The repository atlas verifier passes all 35 atlases and reports no cell-boundary cut, transparent-gutter violation or retained keyed-green fringe under its deterministic checks.

## Legacy and non-character assets

| Asset family | Paths | Provenance supplied | Status | Usage | Integration date |
|---|---|---|---|---|---|
| Nine prior actor sheets | `assets/sprites/{heroes,enemies,bosses}` | OpenAI ImageGen audit from the user's `lively-darwin` project | Project-owned original fan art; legacy/superseded for v2 actors | Provenance and migration fallback only | 2026-08-16 |
| Hermit, Curien, DBR scientist, axe creature, mutant bat 4×4 sheets | `assets/sprites/{bosses,npcs,enemies}` | Built-in OpenAI ImageGen in this project | Project-owned original fan art; legacy/superseded for v2 actors | Provenance and migration fallback only | 2026-08-16 |
| Item icons | `assets/sprites/items` | OpenAI ImageGen audit from the user's `lively-darwin` project | Project-owned original fan art | Pickups and equipment UI | 2026-08-16 |
| Four environment backdrops | `assets/environments` | Built-in OpenAI ImageGen in this project | Project-owned original fan art | Garden, mansion, tunnel and laboratory depth backdrops | 2026-08-16 |
| Procedural geometry/materials | Runtime code | Original code and engine primitives | Project-owned | Mansion/lab route staging | 2026-08-16 |
| Procedural sound | Runtime code | Original synthesis | Project-owned | Temporary SFX/ambience | 2026-08-16 |

The five 2026-08-16 actor outputs were deterministically normalized by `scripts/normalize_generated_atlases.mjs` to add usable alpha and a 1024×1024 4×4-compatible canvas. This post-processing does not change their OpenAI ImageGen provenance; see `logs/IMAGE_GENERATION_LOG.md`. These files do not satisfy or replace the v2 directional contract.

Names and narrative identities belong to their respective owners. No ownership claim is made. Licensed original music, voices, logos, manuals, models, animation clips and geometry are not committed. The current v2 fan-art action-cycle atlases are replacements, not a claim that the complete licensed arcade animation library has been integrated. Production-source paths in this document are repository-relative and ignored; no personal absolute path is published.
