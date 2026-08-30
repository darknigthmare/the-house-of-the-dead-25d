# Fidelity Report

## Unreleased worktree — continuity improvements and Sprite V3 pilot after v0.5.0

The current worktree improves internal spatial/narrative continuity and activates one complete five-clip Sprite V3 actor without claiming a newly verified Sega reference match.

### Spatial continuity

- Every consecutive rail join computes a connected origin from the outgoing endpoint and incoming entry pose. The planar connector length is exactly **9 metres** and vertical origin drift is sanitized.
- Environment and actor roots share that origin; non-zero-origin boss contact positions are transformed exactly once into actor-local space.
- A temporary physical `connector_root` spans the swap. Its old-set and new-set halves use their respective materials and provide floor, side walls, threshold arch, backdrop and collision bodies. It is removed after the destination set is built.
- The transition mask begins at **0.79**, before the known Steel Door wall crossing near 0.812.
- This is still a sequence of node-specific reconstructed sets. The connector improves readable travel between them but does not provide persistent decor, arcade-authored architecture or uninterrupted chapter geometry.

### Route and finale continuity

- Chapter 2 now orders both bridge/stair branches through `corridor_cache`, then `roof_approach`, `roof_rescue` and Hangedman. This removes the previous roof-to-interior-to-roof discontinuity while preserving the encoded route count and fixed timing budget.
- Curien's execution is serialized before the Magician encounter for **7.13 seconds**; player firing is disabled and boss damage is locked until the sequence completes.
- Boss completion remains dynamic and is followed by a **0.50-second** death hold before route advancement.
- The 7.13-second value is labeled `internal_sync_only_tbd_authorized_build`. It is an internally coherent staging duration, not an arcade-exact timestamp.

### Evidence and unresolved fidelity gates

Final local verification passes complete QA **328/328**, deterministic core **1,281 assertions**, Curien-finale smoke **60 assertions**, route smoke **25** and engagement coverage **34 encounters / 98 spawns**. The V3 wave includes loader **67**, player **97** and production-manifest **30** assertions, five atlas clips **5/5**, exported-PCK lifecycle/gameplay smokes and content audit **905 checks / 6 warnings / 0 errors**.

No authorized `reference_build/` or timestamp evidence is present; reference timing remains `TBD-AUTH`. Sam A1 now uses five true eight-frame/eight-direction V3 clips without mirrored opposite rows, but this covers only 1/38 actor profiles. The other 37 profiles remain Sprite V2 with eight semantic cells per direction, all of their right views and many back-right views are mirrored, and the content audit retains six known warnings. These limitations prevent any 100% or revision-exact fidelity claim.

## Published v0.5.0 release — measured state, 2026-08-28

This report describes immutable tag `v0.5.0` at exact commit `6d84764745102b95e22b2462eeaa364103678c0b`, its public delivery archives and verified production deployment.

The release is a playable, internally verified 2.5D fan-made reconstruction. Its evidence proves the tracked replacement-content, runtime and publication contracts; it does not prove revision-exact Sega arcade fidelity.

## Verification snapshot

| Checkpoint | Current local result | What it establishes |
|---|---:|---|
| deterministic Godot core | **975 assertions** | targeted gameplay, routing and runtime regressions pass |
| repository suite | `npm test` **295/295** | tracked repository tests pass |
| complete QA | **313/313** | aggregate local QA passes |
| Web QA | **299/299** | current Web-oriented checks pass |
| environment verifier | **1,977 assertions** | active environment contract is internally consistent |
| content audit | **889 checks / 6 warnings / 0 errors** | no blocking content error; the six fidelity warnings below remain |

These results are part of the verified release evidence. They remain neither a comparison against an authorized arcade build nor Sega arcade-fidelity certification.

## Campaign and pacing contract

| Surface | Current v0.5.0 measure | Certification boundary |
|---|---:|---|
| route graph | **43 nodes / 53 edges** | structural topology, not exact arcade staging |
| complete chapter paths | **8 / 4 / 8 / 2** | every encoded exit is deterministically reachable |
| ordinary enemies | **98 spawn entries / 68–71 per complete route** | declared density, not exact coordinates, order or co-op formations |
| civilians | **20 placements / 15 encountered per route** | structural rescue coverage, not exact identities or rescue windows |
| encounters | **34 multi-wave encounters** | every final wave begins at or after **82%** of its encounter budget |
| environment props | **14 profiles / 105 placements / 9 state events** | active decoration and state-change coverage |
| fixed chapter runtime outside dynamic bosses | **106.5 / 97.4 / 93.1 / 40.4 seconds** | per-chapter fixed budgets only; dynamic boss fights are excluded |

The four fixed-runtime figures must not be summed or reported as a measured campaign wall-clock duration. Player performance, dynamic boss fights, transitions and other runtime variation prevent that interpretation.

Nineteen decorative placements were added across the five previously sparse scenes. This raises the active total to 105 prop placements without implying that their positions reproduce the arcade layouts.

## Runtime corrections now covered

### Enemies, melee and collision

- Ordinary enemies are clamped to the camera-front plane and converge laterally on both X and Z instead of stopping at depth-only range.
- A melee strike requires line of sight as well as physical contact; a wall or intact blocker cannot be bypassed by the damage check.
- Pursuit uses swept collision so a fast step cannot tunnel through scene volumes. Intact props remain blockers until their authored state changes.
- The repeatable combat sequence is `approach -> wind-up -> strike -> recovery -> re-attack` while a valid target remains. An attack count no longer removes the enemy.
- Hostile projectiles are visible, shootable and destructible. Camera-targeted projectiles steer progressively toward the moving camera instead of snapping instantly, while visibility and minimum-travel gates still apply before damage.
- In co-op, each threat resolves to one living player and retains that target while it remains valid. A player-targeted projectile locks its recipient at launch and dissipates instead of redirecting if that player becomes unavailable.
- A civilian-assigned attacker cannot fall back to a player. If the civilian disappears before launch, no player-targeted projectile is created; an already launched civilian-targeted projectile dissipates without retargeting.
- Every boss attack must accumulate a full, uninterrupted **0.90 seconds while visible** before commit. Losing visibility resets the telegraph, and hidden or cooldown-overshoot time cannot consume the interval.
- Logical actor death removes the actor from `active` immediately. A visible fade is tracked in `retiring` until final cleanup, a sprite-less actor finalizes immediately, and scene cleanup drains both lifecycle sets.

These contracts improve readable, physical combat. They do not certify exact arcade enemy resistance, attack windows, per-limb reactions or placement.

### HUD and text

- French accents and supported HUD glyphs render cleanly in the verified local surface.
- Unsafe decorative glyphs are sanitized without stripping ordinary accented text.
- Player initials and mode labels are sanitized before display or persistence, preventing unsupported control or decorative characters from leaking into the HUD and leaderboard.

This validates the current text contract, not the original Sega fonts, logos, artwork or layout.

### Camera continuity and walkable surfaces

- Hermite interpolation connects the outgoing and incoming camera poses between nodes.
- The environment swap is delayed until late in the connector, reducing the visible cut.
- The environment is still reconstructed at the node boundary: the connector does not provide a persistent world or prove arcade-exact spatial continuity.
- A generic ground solver handles detected floor, stair and slope surfaces. It remains a generic reconstruction rather than scene-authored arcade geometry and navigation.

## Route fidelity status

All nine documented decisions have an active structural representation, but their triggers and staging do not all match the observed arcade behavior:

- decisions **#2 and #6** remain substitute or inaccurate route conditions;
- decisions **#3, #4 and #9** exist, but their impact/fall and independent-door staging remains provisional;
- the other decisions are structural approximations until checked against a revision-identifiable authorized build.

Accordingly, the `43 nodes / 53 edges / 8/4/8/2 paths` result proves graph completeness only. It must not be described as arcade-exact route reproduction.

## Visual and content limits

The active sprite contract combines the 38-profile V2 fallback set with one complete Sam A1 V3 sidecar. Sam A1 exposes five independently authored 8-direction × 8-frame clips (`idle`, `locomotion`, `attack`, `hit_recoil`, `death_fall`); the other **37/38 profiles** still expose only **eight semantic V2 states** per direction, not full multi-frame clips for every motion, attack, localized hit, dismemberment and death variant.

The remaining directional derivations are explicit:

- **38/38** right-profile rows are mirrored from the left;
- **25/38** back-right rows are mirrored from back-left;
- three enemy placement variants remain intentionally marked non-arcade-exact.

Those three placement warnings plus right mirroring, back-right mirroring and the eight-state semantic-animation limitation account for the current **six known content-audit warnings**. They are fidelity warnings, not suppressed errors.

## Sega certification boundary

Neither `LICENSED_ASSETS_ROOT` nor `REFERENCE_BUILD_ROOT` is available to this verification pass. There is therefore no authorized, revision-identifiable Sega build or licensed source-master set against which to certify:

- camera rails, coordinates, FOV, pauses, transitions and timings;
- spawn order, co-op variants, damage windows, hit zones and resistance values;
- civilian identities, rescue deadlines, hidden items, route triggers, scoring and endings;
- source geometry, animation, dialogue, music, sound effects, fonts, logos and credits presentation.

Public recordings can support qualitative observation only; they cannot establish numerical certification or supply licensed assets. The current verdict is therefore:

> **v0.5.0 is a published, internally verified fan-made release, not a Sega-certified arcade-exact reproduction.**
