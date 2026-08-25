# Missing Licensed Assets

No `[LICENSED_ASSETS_ROOT]` or `[REFERENCE_BUILD_ROOT]` was present when the project was initialized. The game therefore ships with original procedural replacements and an explicit integration surface for:

- original English voice files and verified line timing;
- original music and transition cues;
- original weapon, creature, UI and environment sound effects;
- authorized manual/revision identifier and operator configuration;
- authorized reference build for frame/timing capture;
- licensed model/animation sources for reference-faithful eight-direction sprite renders;
- the complete per-actor animation library: separate multi-frame idle, walk, run, approach, attack, projectile, localized-hit, weapon-loss, limb-loss and death clips;
- licensed boss phase/destruction animation sources for Chariot, Hangedman, Hermit and Magician;
- verified room geometry, rail coordinates and every object placement;
- the original logo and credits/legal cards.

Do not source these from public videos, ROMs or ripped archives. Add them only through an authorized local `licensed_assets/` folder, which is ignored by Git, then record transformed deliverables here before publication.

## Current directional replacement status

The missing licensed sources do **not** leave the project without directional replacement artwork. The current asset contract contains 38 unique original fan-made v2 atlases under `assets/sprites_v2/`, each at 2048×2048 RGBA with eight directions and eight state cells per direction. They provide 2,432 addressable cells and do not share proxy atlases between identities. The three additions are `scientist_male_blue`, `scientist_male_gray` and `scientist_female_lab`.

These replacements are intentionally one eight-state action cycle per identity: idle, three locomotion poses, action windup, action strike, hit recoil and death fall. They are not represented as the complete arcade animation set. Exact attack variants, body-part reactions, dismemberment layers, boss-phase clips and longer transitional sequences remain missing until authorized models/animations can be rendered into additional directional sheets.

The generated source sheets supplied six or seven complete direction rows. The production assembler fills the eight-row runtime contract through documented mirror derivation, not by claiming the missing views were authored: right comes from the left profile for every identity, and six-row sources also derive back-right from back-left. Samson's unusable `front_right/death_fall` source fragment is transparently derived from `right/death_fall`; Dr. Curien's missing clean hit column is derived from `action_strike`. These are production fallbacks, not additional licensed animations.

The final repair pipeline extracts complete eight-connected silhouettes, reattaches small weapon/limb fragments, aspect-fits them with ground anchoring and applies chroma despill before enforcing a 12-pixel transparent gutter plus a 2-pixel art margin. Chariot uses the dedicated ignored source `reports/runtime/directional-sources/chariot_compact_v2.png`; Moody's two action columns localize and shorten the chain to preserve a 196-pixel body target at 86% of usable height. The atlas verification contract covers all 38 files and 2,432 cells. Per-asset details and hashes are in `data/assets/sprite_generation_provenance.json`.

The older 4×4 files under `assets/sprites/` remain legacy provenance/migration material. They are not counted as v2 completion and are not active shared proxies for the 38 directional identities.

## Current original replacement families

The active environment completion contract contains 38 sanitized provenance records: 20 individual material sources converted to albedo, normal and ORM maps, 14 prop atlases and four breakables with intact/broken outputs. `data/assets/environment_manifest.json` describes all 33 campaign nodes. The final bonus-gate seal and emergency supply crate from the earlier production wave were removed as obsolete active assets and remain recoverable through Git history. These files are original fan-made replacements, not Sega source textures or verified arcade geometry.

The gameplay-support wave contains seven projectile cutouts, three HUD families (`life_torch`, `bullet_round`, `reload_offscreen_icon`) and four boss weak-point diagrams. They are original project artwork and do not claim to reproduce captured Sega pixels.

Exact Sega dialogue performances, voices, music, transitions and sound effects remain absent. The current procedural sounds, ambience, short musical loops and non-verbal voice-like cues are original temporary replacements only.

Selected ImageGen production sources and selection reports remain under ignored local `reports/runtime/` paths; sanitized manifests and SHA-256 values are tracked. Neither `licensed_assets/` nor `reference_build/` was available for this pass.
