# Content Asset Catalog

This catalog separates the new original fan-made production from commercial assets that require a licensed local source. No ROM, emulator package, video frame, compressed soundtrack, official sprite sheet or trademarked logo was downloaded or extracted for this wave.

## Fidelity baseline

The arcade release remains the rules and composition reference. The official Sega history page dates the game to March 1997 and identifies its one-to-two-player rail-shooter structure. The Sega operator manual is the reference for the six-round display, off-screen reload, lives, civilian penalty, hidden objects, boss gauge and continue flow. Public recordings were used only to observe staging, relative composition and rhythm.

`licensed_assets/` and `reference_build/` were not present during this production pass. Therefore the repository must continue to label the following as unavailable rather than identical to Sega's masters:

- original dialogue recordings and actor performances;
- original score and music transitions;
- original sound-effect recordings;
- official logo/title art;
- exact source textures, models and animation clips;
- revision-specific frame timing and camera measurements that require an authorized arcade build.

## Directional organic actors

The active sprite contract now contains 38 dedicated 2048×2048 RGBA atlases. Each atlas provides eight direction rows and eight state columns: 2,432 cells in total.

The added civilian variants are:

- `scientist_male_blue`;
- `scientist_male_gray`;
- `scientist_female_lab`.

They complement `dbr_scientist` and `sophie_richards` and are assigned across the 20 campaign civilian placements. ImageGen produced six complete authored direction rows for each new scientist; the deterministic assembler derives only the missing right profile from the authored left profile and records that operation in public provenance.

## Individual environment materials

Twenty OpenAI-generated material sources are converted into compact tracked albedo, normal and ORM maps. The conversion is deterministic and does not synthesize commercial source pixels.

| Area | Material IDs |
|---|---|
| Garden and estate | `garden_mud_moss`, `garden_flagstone`, `estate_weathered_stone` |
| Mansion and library | `mansion_damp_plaster`, `mansion_dark_wood_panel`, `mansion_marble_floor`, `mansion_worn_red_carpet`, `mansion_oak_door`, `library_dark_oak_shelf` |
| Underground | `sewer_wet_brick`, `sewer_slick_stone`, `sewer_rusted_iron` |
| Roof | `roof_weathered_slate`, `roof_gothic_stone` |
| Laboratory and Hermit tunnel | `lab_painted_metal`, `lab_grated_floor`, `lab_rusted_pipe`, `lab_grimy_glass`, `lab_bio_machine_panel`, `hermit_web_membrane` |

`data/assets/environment_manifest.json` assigns an explicit environment profile to all 33 campaign nodes instead of selecting only one of four generic backdrops.

The environment-generation provenance contains exactly 40 records: 20 material families, 14 prop atlases and six destructible sources. Their selected ImageGen inputs remain local and ignored under `reports/runtime/environment-sources/`; normalized outputs and sanitized source/final hashes are tracked under `assets/environments_v2/` and `data/assets/environment_generation_provenance.json`.

## Props and animated decoration

The tracked prop catalog contains exactly 14 original fan-made cutouts with fixed world scale, ground anchor and optional two-frame animation:

- estate gate, garden lamp, dead tree and stone bridge arch;
- roof gargoyle;
- laboratory specimen tank, pipe cluster and ventilation fan;
- mansion chandelier, candle sconce, double door, portrait and library bookcase;
- laboratory control console.

The common ImageGen contract was: isolated complete game prop; hand-painted low-poly 1997 arcade-horror rendering; readable silhouette; genuine transparent target; no scene, text, logo, watermark, official artwork or copied geometry. Animated/two-state assets were requested as two identical side-by-side objects with only the flame, door or indicator state changing.

Distinctive final prompt requests for the second prop wave were:

- `mansion_chandelier`: eight-candle blackened-iron chandelier, steady/flickering flame frames;
- `mansion_sconce`: one-candle wrought-iron wall sconce, steady/leaning flame frames;
- `mansion_double_door`: weathered pointed-arch oak double door, closed/open states;
- `library_bookcase`: complete dark-oak gothic shelf with irregular unreadable books and restrained cobwebs;
- `mansion_portrait`: cracked, indistinct nineteenth-century silhouette in a battered original frame;
- `lab_control_console`: late-1990s bio-lab console, green normal/red alarm states, no readable text.

Generated originals remain in the image tool's managed storage. Selected production copies and exact local selection records live under `reports/runtime/environment-sources/` and are ignored by Git. Normalized project assets and sanitized hashes are tracked under `assets/environments_v2/` and `data/assets/`.

## Destructibles and pickups

Six campaign interactions have dedicated intact/broken visuals:

- foyer door lock;
- chained hatch plate;
- elevator route switch;
- vent key container;
- final bonus gate seal;
- emergency supply crate.

The tracked content contract maps each interaction to its dedicated asset ID and preserves both intact and broken visual states; this catalog does not claim release-build verification.

## Projectiles and boss UI

Seven dedicated projectile cutouts replace enemy-sprite proxies:

- thrown axe;
- thrown dagger;
- thrown barrel;
- organic spit;
- iron claw;
- Hermit web ball;
- Magician fireball.

The three HUD families are the eight-frame life torch, bullet-round icon and reload-offscreen icon. Four separate weak-point diagrams cover Chariot, Hangedman, Hermit and Magician. These are original project UI assets, not captured arcade pixels.

## Audio status

Procedural audio is an original temporary replacement layer. It covers weapon/UI feedback, environmental ambience, boss telegraphs, short musical loops and non-verbal radio-like voice cues. It must not be described as Sega's original voice cast, dialogue, score or sound library: exact Sega audio remains missing. Commercial audio can only replace it when authorized files are supplied locally and entered in `docs/ASSET_LICENSE_MANIFEST.md`.
