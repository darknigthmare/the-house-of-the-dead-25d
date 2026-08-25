# Fidelity Report

## v0.3.0 local release candidate — verified locally, unpublished

The current working tree strengthens the internally verifiable 2.5D replacement contract without changing the exact-Sega certification boundary. It is a local release candidate only: no v0.3.0 commit, tag, GitHub release or Vercel deployment is claimed here.

The locally verified changes include visible and destructible hostile projectiles, contact-gated telegraphed melee, civilian rescue failures caused only by a visible assigned assailant rather than a timer, event-driven estate-gate/door/specimen-tank frames, manifest-driven medal/frog/life pickups, four dedicated animated environment strips (`drips`, `water_flow`, `electrical_arc`, `monitor_scan`) and the Curien/Magician finale story staging. These runtime improvements remain original project interpretations until compared against an authorized Sega reference build.

| Validator checkpoint | v0.3.0 local result |
|---|---|
| repository/data suite | `npm.cmd test` **272/272** |
| complete local QA | `npm.cmd run qa` **282/282** |
| deterministic libraries | core **235**; atlas **63**; environment **115**; gameplay support **33**; enemy profiles **210** |
| audio replacement contract | **354 assertions / 28 distinct cues** |
| directional runtime | **38 bindings / 10 representatives / all 8 directions**; cleanup without leak |
| Curien finale runtime | **29 assertions**; cleanup without leak |
| asset verification | environment **1,708**; animated effects **348/348**; gameplay support **113/113** |
| content-family audit | **739 checks / 16 warnings / 0 errors** |
| texture imports | **128 files / 0 mismatches** |
| campaign | chapters **1–4**, **15/15 scientists**, complete boss sequence including both rematches, ending and credits |
| focused runtime smokes | gameplay, score and initials passed |
| Windows/Linux/Web exports | **187,023,472 / 151,388,064 / 117,762,238 bytes** |
| Web payload | 9 files; PCK **77,917,844**; WASM **39,513,091**; `qa:web` **276/276**; `verify:web` **OK** |
| local browser | agent-browser 0.34; isolation true; accessible 1258×622 main canvas with ARIA label; menu then Arcade/P1/continue visible; WebGL2 single-thread; 0 page errors and 3 Godot info logs |

The 16 content-audit warnings are retained, not hidden: three runtime/route-graph drifts, three reference-pending enemy placements, two unused destructibles, two direction-mirroring warnings, one semantic-atlas animation warning, one unreferenced AMS item and four inactive legacy controller classes. Passing local QA therefore proves internal consistency and campaign reachability, not revision-exact arcade fidelity.

`licensed_assets/` and `reference_build/` remain unavailable. Exact camera rails, spawn coordinates, attack windows, scientist timing, routes, score values, endings, dialogue, audio, geometry, animation and operator-revision behavior cannot be certified as Sega-authentic from these local replacement assets. Public recordings remain observation references only and are not asset sources.

The v0.2.1 section below is preserved as immutable published history; its lower asset/check counts and export sizes must not be reported as v0.3.0 results.

## v0.2.1 status — verified distribution, 2026-08-25

This report separates two different claims:

1. the **original replacement contract**, which can be verified from the tracked project assets, manifests, runtime and automated tests;
2. **exact Sega arcade certification**, which cannot be completed without an authorized revision-identifiable arcade build and the licensed Sega source masters.

The first claim is verified below. The second remains explicitly blocked and is not implied by the project name, the Arcade Authentique mode or the breadth of the current campaign.
v0.2.1 changes source-validation portability only: ignored private reports are optional, tracked manifests/provenance remain mandatory and asset paths validate on Windows/POSIX. The replacement assets, gameplay, exports and fidelity boundary are unchanged from v0.2.0.


## Original replacement contract — verified

- **Directional actors:** 38 unique 2048×2048 RGBA Sprite3D atlases. Every identity has eight views and eight gameplay states, for 64 addressable cells per actor and 2,432 cells total. The set includes 25 dedicated enemy identities, distinct heroes, narrative actors, bosses and three additional scientist variants.
- **Fake-3D runtime:** camera-relative direction selection covers front, rear, both sides and four diagonals. Perspective, ground anchoring, depth, occlusion and 3D body hit zones remain independent from the sprite artwork.
- **Environment replacement:** 20 original material families produce 60 albedo/normal/ORM maps. All 33 campaign nodes have an environment profile; the catalog also contains 14 props and six destructibles with intact/broken states.
- **Gameplay-support replacement:** seven dedicated projectile cutouts, three HUD families (eight-frame life torch, bullet round and reload icon) and four boss weak-point diagrams are present and manifest-addressable.
- **Runtime integration:** environment and gameplay-support manifests drive node-specific backdrops, PBR surfaces, layouts, props, light decorative motion, projectile visuals, breakable transitions and the support HUD. Civilian placements can use the three dedicated scientist variants without changing route or scoring rules. The environment, enemy-profile and gameplay-support loaders now resolve their resources through `ResourceLoader`, including in exported builds.
- **Audio replacement:** 28 distinct project-authored procedural cues provide temporary weapon, UI, ambience, boss, short music-loop and non-verbal voice-like feedback. They are not Sega recordings or performances.
- **Provenance:** the replacement artwork and procedural audio are original project assets. No ROM, emulator extraction, video-frame extraction, ripped commercial sprite, Sega master audio or official source geometry is included.

This is a production-ready replacement contract, not a claim that the generated visuals or procedural sounds are identical to Sega's protected masters. The eight-state atlas cycle is compact and game-ready; it is not the complete licensed arcade animation library with every anticipation, attack variant, localized wound, dismemberment and death frame.

## Gameplay structure — locally verified

- Four data-driven chapters and all currently encoded routes parse and resolve: four paths in chapters 1–3 and two paths in chapter 4.
- The deterministic campaign smoke reaches Chariot, Hangedman, Hermit, the Chariot and Hangedman rematches, Magician, the ending and credits with 15/15 scientists.
- Two independent players, six-round magazines, empty-magazine behavior, off-screen reload, projectile rules and independent gamepad aim pass the gameplay smoke.
- Score QA records `+120` and `-100`; initials accept `COD` and transition to credits.
- Arcade, Training, Boss Rush and Chapter Select remain implemented. These local structural checks do not certify revision-exact Sega timings.

## Validator checkpoints — 2026-08-25

| Checkpoint | Verified result |
|---|---|
| repository/data suite | `npm.cmd test`: 271/271 |
| complete local QA | `npm.cmd run qa`: 280/280 |
| deterministic core | 235 assertions |
| sprite-manifest atomicity | 63 assertions |
| directional runtime | 38 bindings, ten representatives, all eight directions, death and cleanup states |
| environment library | 56 assertions |
| environment asset verification | 1,517 assertions; 20 materials, 33 nodes, six destructibles, 14 props |
| gameplay-support library | 25 assertions |
| gameplay-support asset verification | 83/83 |
| enemy runtime contract | 135 assertions; 25 profiles and 25 unique types |
| procedural audio | 354 assertions; 28 distinct cues |
| texture import profile | 124 files, zero mismatches |
| targeted Godot parse | 9/9 runtime scripts |
| gameplay smoke | 2P, four chapters, six shots to empty, reload to six, independent gamepad aim and projectile rules passed |
| score / initials smoke | `+120`, `-100`, `COD`, credits passed |
| complete campaign smoke | chapters 1–4, required bosses/rematches, 15/15 scientists, ending and credits passed |
| export-safe resource loading | environment, enemy-profile and gameplay-support `ResourceLoader` correction verified in exports |
| Windows export | 161,321,616 bytes; eight-second startup check passed |
| Linux export | 125,686,208 bytes |
| Web export | 92,060,382 bytes total; PCK 52,215,988 bytes; WASM 39,513,091 bytes |
| Web static QA | `qa:web`: 275/275; `verify:web`: OK |
| public browser | Vercel `dpl_3f4W7BXUfgMjeFjVh5wGd8N4xuzs` `Ready`; no console/page errors; `crossOriginIsolated=true`; accessible 1258×622 canvas; menu and P1/continue visible |

These results are anchored to exact commit [`c13d525`](https://github.com/darknigthmare/the-house-of-the-dead-25d/commit/c13d525d63dc9ef4e92d30c0ab5851047fa76f66), [release v0.2.1](https://github.com/darknigthmare/the-house-of-the-dead-25d/releases/tag/v0.2.1), clean run `32784226344` and `Ready` production at <https://the-house-of-the-dead-25d.vercel.app>. All uploaded digests match locally; root/PCK/WASM return HTTP 200 with WASM MIME and COOP/COEP verified. This certifies distribution integrity, not exact Sega arcade timing/assets.

## Exact Sega arcade certification — blocked

`licensed_assets/` and `reference_build/` were not available for this verification pass. No authorized build revision, operator configuration, licensed manual package, source models/animations, source textures, original dialogue, score or sound-effect masters could therefore be measured or compared.

The following remain provisional technical reconstructions rather than certified Sega-arcade matches:

- per-frame rail coordinates, camera orientation, pauses, FOV and acceleration;
- revision-specific spawn positions, attack windows, resistance values and hit-zone behavior;
- every scientist deadline, route trigger, hidden-object rule and score award;
- operator settings, continue behavior and disputed ending thresholds;
- original dialogue timing and performance, music transitions and sound mixing;
- exact source geometry, texture, animation, logo, title and credits presentation.

Public recordings may inform staging, relative composition and rhythm only; they are not a lawful source for extracted frames or audio and cannot establish revision-exact numerical certification. The 2022 remake is a secondary spatial reference, not numerical canon.

Certification can resume only after an authorized reference build and licensed masters are supplied locally. The next fidelity pass must record the exact revision and operator settings, timestamp each sequence, compare rails/events/routes/boss phases and audio transitions, and retain per-checkpoint evidence without replacing the verified original-asset/runtime contract.
