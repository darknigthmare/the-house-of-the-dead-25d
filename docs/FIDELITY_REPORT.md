# Fidelity Report

## Implemented and directly testable

- Four-chapter campaign, branches, scientists, breakables, pickups, conditional bonus path, three endings and credits.
- Chariot, Hangedman, Hermit and Magician phase rules plus Chariot/Hangedman rematches.
- Two independent players, six-round magazines, off-screen/button reload, score, lives, credits and continues.
- Authentic 4:3 play area, Training, Boss Rush and Chapter Select.
- 35 unique 2048×2048 RGBA Sprite3D atlases with eight views and eight states: 64 cells per actor and 2,240 cells total.
- Camera-relative direction resolution for front, four diagonals/sides and back views, while 3D hit zones, perspective, depth and occlusion remain independent of the sprite artwork.
- 25 dedicated enemy profiles plus distinct heroes, civilians, narrative actors, small creature and bosses.
- Original fan-made art only; no ROM, video extraction or commercial audio.

## Validator checkpoints — 2026-08-21

| Checkpoint | Result |
|---|---|
| repository tests | `npm.cmd test` 252/252 |
| complete local QA | `npm.cmd run qa` 257/257 |
| core/manifest suites | 232 core + 57 atomicity assertions |
| directional runtime | 35 bindings, seven representatives, all eight directions |
| visual atlas audit | PASS after crop/Samson/chroma repairs |
| gameplay | 2P, four chapters, six shots, reload and independent gamepad aim passed |
| campaign | chapters 1–4, required bosses/rematches, 15/15 scientists, ending and credits passed |
| local Web presentation | title/menu and P1/P2 with two HUDs/two crosshairs, three target viewports, zero page errors |

## Honest fidelity boundary

The V2 atlas delivers a compact cycle of eight useful states per direction, not a complete licensed arcade animation library containing every original anticipation, attack variant, localized wound, dismemberment and death frame. It materially improves fake-3D continuity and actor uniqueness, but exact arcade animation counts are not claimed.

The authorized reference build, licensed manual assets, original models/audio and exact revision identifier are absent. Exact per-frame rails, every spawn resistance, every scientist deadline, dialogue waveform, music transition and disputed ending thresholds therefore remain provisional technical reconstructions. The 2022 remake is not numerical canon.

When authorized material is supplied, record revision/operator settings and sequence timestamps, then extend per-action clips while preserving the verified direction mapping, hitboxes and deterministic timings.
