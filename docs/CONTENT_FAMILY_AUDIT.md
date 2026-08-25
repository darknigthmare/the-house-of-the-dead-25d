# Content Family Runtime Audit

## Scope and source of truth

This bounded audit covers props, enemy identities and variants, hostile projectiles, civilians/background NPCs, pickups and collectibles, breakables, and animated decorative elements. It checks the active runtime path (`data/runtime/campaign_timeline.json`) against the sprite, enemy, environment, gameplay-support and boss manifests, then traces those identifiers into the Godot runtime, including boss-support actors spawned directly by combat code.

The four `data/chapters/*.json` files and four JSON/TRES route graphs are treated as secondary planning/validation data because `GameplayRuntime` loads `campaign_timeline.json` directly. Arcade-exact completeness is not certified: no authorized Sega reference build or licensed master asset set was available for this pass.

Run the reproducible audit with:

```powershell
node scripts/audit_content_families.mjs
```

Current result: **746 checks, 6 explicit warnings, 0 reference errors**. The audit is also part of the `npm test`, `npm run qa` and `npm run qa:web` gates.

## Inventory actually present

| Family | Files/data present | Active runtime coverage | Integrity result |
|---|---:|---:|---|
| Props | 14 authored PNG profiles | 62 placements across all 33 runtime nodes, including 9 event-driven state changes | All IDs and paths resolve; all 14 are placed; continuous and event-driven frame bindings are validated |
| Breakables | 4 active profiles, 8 distinct intact/broken PNGs | 4 campaign interactions after the conditional-gate and bonus-room corrections | Every active profile is used exactly once; the two superseded Chapter 4 proxy profiles and their PNGs were removed |
| Enemy variants | 25 data profiles and 25 dedicated atlases, plus the separate `mutant_bat` atlas | All 25 profile IDs occur in timeline spawns; one runtime boss-support spawn site creates Hangedman's five `mutant_bat` actors | No enemy atlas is a binary duplicate; the scene placement of `sam_a1`, `kenfis_f1` and `name_g2` remains explicitly pending reference verification |
| Projectiles | 7 dedicated 512×512 PNGs | All 7 manifest projectile families are now reachable from campaign enemies or bosses | All paths resolve and all files are unique; runtime reachability does not certify arcade-exact timing or placement |
| Civilians/NPCs | 6 dedicated non-hero atlases: Sophie, Curien, DBR scientist and three scientist variants | 20 route placements use 5 civilian visuals (Sophie plus 4 scientist profiles); Curien is separately spawned as a story actor | Every non-hero atlas has an active runtime path and no file is missing |
| Pickups | 3 validated manifest profiles: `medal`, `frog`, `life` | 12 explicit bonus-room placements: 4 life, 3 frogs, 5 medals; four other rewards remain attached to breakables | IDs, paths, hashes and rewards resolve through `gameplay_support_manifest.json`; score-bearing pickups total 4,000 points |
| Animated props | 8 two-frame prop sheets | 5 continuous bindings plus 9 event-driven state changes across `estate_gate`, `mansion_double_door` and `lab_specimen_tank` placements | Frame changes are handled by `EnvironmentPropStateController`; no active two-frame prop remains without a runtime binding |
| Decorative effects | 4 dedicated eight-frame strips plus the remaining procedural scene effects | `drips`, `water_flow`, `electrical_arc` and `monitor_scan` use their own manifest-driven `Sprite3D` animations | All four strip paths resolve and are bound through the animated-effect runtime path |

The binary-identity pass covered 74 relevant actor, prop, breakable-state, projectile, pickup and dedicated animated-effect files. It found **74/74 unique SHA-256 values** and no absent file.

## Corrections made during this audit

Five encounter entries declared `throw_projectile` even though their actor profile intentionally has no projectile visual. In the current combat path that attack returns `null`, deals no direct damage and lets the attacker consume its attack count. The data now uses the actors' real close-range family, `heavy_weapon`, at:

- `chapter_01/upper_stairs`: `burner_c3`;
- `chapter_02/chain_plate`: `harris_d3`;
- `chapter_02/library_rescue`: `burner_c3`;
- `chapter_03/back_attack_rescue`: `harris_d3` and `burner_c3`.

The separate `chapter_04/bonus_room` correction replaces its hostile/crate proxy with twelve explicit collectible placements. The audit asserts exactly 12 unique IDs, 4 life pickups, 3 frogs, 5 medals, no hostile, no breakable and a 4,000-point score-pickup total.

The three pickup families now live in the validated `pickups` group of `data/assets/gameplay_support_manifest.json`. Runtime lookup, scoring and life rewards use that manifest instead of a hard-coded texture table.

The runtime and secondary route graphs now use the same node IDs, start nodes and edges. Chapter 1 adds the active `sophie_antechamber` step, Chapter 2 adds `roof_rescue`, and the previous planning-only aliases are replaced by the active `garden_rescue`, `chain_plate` and `back_attack_rescue` IDs.

Route selection now passes through the deterministic `RouteOutcomePolicy`. On nodes that contain a breakable, `branch_success` is derived only from destruction of that node's expected breakable ID; a civilian rescue cannot silently select the breakable-success route. Civilian-only branches keep their rescue success/failure outcome.

`PickupController`, `BreakableObject`, `CivilianController` and `EnemySpawnEvent` are now instantiated by the active metadata-driven runtime and have deterministic tests. Pickup collection is one-shot, breakable durability and rewards are explicit, civilian deadlines request visible-threat acceleration without causing timer-only death, and spawn timing preserves authored delay/interval data.

Nine prop state events now drive authored closed/open or intact/breached frames rather than leaving the second frame dormant; continuous bindings separately handle blinking and other ON/OFF props:

- the garden `estate_gate` opens after successful node completion;
- three `mansion_double_door` placements open after the matching destroyed lock/plate or a cleared encounter;
- five `lab_specimen_tank` placements breach at their elapsed-time cue or the configured Magician boss phase.

Four previously procedural stand-ins now have dedicated eight-frame strips and manifest profiles: `drips`, `water_flow`, `electrical_arc` and `monitor_scan`. Their individual frame rates, scale, placement, tint and optional light pulse are resolved by the animated-effect runtime binding.

All 25 enemy profiles are now reachable, but three new Chapter 1 placements deliberately retain `reference_status: canonical_chapter_verified_scene_placement_pending`: `sam_a1` in `garden_rescue`, then `kenfis_f1` and `name_g2` in `mansion_entrance`. The audit emits one warning per placement; these entries must not be described as arcade-exact until their exact scenes are verified against the authorized reference.

`mutant_bat` is also active outside the timeline: Hangedman's startup loop creates five bats, and boss vulnerability remains gated while any of those actors is alive.

## Asset resolution and removed content

No active manifest or timeline asset path is absent. Every active prop, breakable state, enemy/civilian/boss atlas, projectile, weak-point image and pickup texture resolves on disk.

The previously questioned items have been resolved as follows:

- `dr_curien` is visibly spawned during `curien_confrontation`, then respawned as a non-targetable story actor at `magician_battle`: Magician displays an attack windup and dedicated fireball strike, Curien enters directional hit-recoil and death-fall frames, then remains grounded through a verified five-second minimum hold and until scene cleanup. `smoke_curien_finale.gd` proves this runtime contract; exact arcade staging/timing still requires the authorized reference.
- `c04_bonus_gate_seal` and `c04_emergency_supply_crate` were obsolete stand-ins for the conditional gate and reward room. Their two profiles and four PNGs were removed from the active tree.
- `assets/sprites/items/ams-eater-custom.png` had no manifest ID or runtime reference and was removed.

All five deleted PNGs, plus their Godot import sidecars, remain recoverable from Git history if a future non-authentic mode gives them a justified, manifest-backed role. They are not counted as active content.

## Duplication and proxy audit

There are no byte-identical production assets in the audited families, every one of the 25 enemy identities points to its own atlas, all three pickup identities resolve through the gameplay-support manifest, and the four named animated effects use dedicated strips. The remaining structural limitations are:

- Enemy archetypes collapse to a small runtime behavior set. Most `attacks`, `weapon`, weak-zone and dismemberment detail stored in `enemy_profiles.json` is not forwarded by `EnemyProfileLibrary.to_runtime_stats()`.
- Projectile aliases collapse `laser_dagger` to `thrown_dagger`, `vomit_burst` to `organic_spit`, `launched_iron_claw` to `iron_claw` and `short_flame_jet` to `magician_fireball`. The seven manifest families are reachable, but these aliases remain shared visual identities; Burner's flame jet does not currently use projectile behavior in the active timeline.
- All 38 actor atlases mirror the right profile from the left profile; 25 of 38 also mirror back-right from back-left. The sheets expose eight semantic state cells per direction, not a multi-frame clip for every state. Runtime three-degree sector hysteresis prevents angular flicker but does not replace the missing authored directions or high-frame clips.

## Exact content/runtime backlog

### Remaining reference-gated work

- Verify the exact scene coordinates/timing of `sam_a1`, `kenfis_f1` and `name_g2` against the authorized arcade reference, then remove their `_placement_pending` status only when evidenced.
- Validate the now-reachable axe, barrel, claw and organic-spit attack windows against the reference; runtime wiring alone is not fidelity proof.

### Current 6-warning ledger

The reproducible audit deliberately remains yellow, not green. Its six warnings are: 3 reference-pending enemy placements; 1 aggregate warning covering all 38 right-facing profiles mirrored from left; 1 aggregate warning covering the 25 of 38 back-right rows mirrored from back-left; and 1 warning that each direction exposes eight semantic state cells rather than true multi-frame clips for every state.

### Animation-production gap

The current `8dir×8-state` actor contract should remain a compatibility baseline. A detailed production contract needs per-actor, per-direction clips for at least idle, walk/run, approach, primary/secondary attack, projectile throw, localized hits, weapon/limb loss, decapitation and multiple death/fall states. A defensible path convention is:

`assets/sprites_v3/<role>/<actor>/<clip>__8dirxNf.png`

No v3 clip should be marked complete until its authored directions, frame count, derivations and atlas hash are recorded. Exact new scientist identities, enemy placement changes and prop additions must follow the authorized reference matrix rather than being invented to inflate counts.

## Release boundary

This audit proves internal asset/reference integrity and exposes active coverage gaps. It does not prove exact Sega enemy counts, scene timing, hidden-object placement, civilian identities, bonus-room staging or projectile behavior. Those remain gated on the authorized arcade reference and licensed assets already listed in `docs/MISSING_LICENSED_ASSETS.md`.
