# Gameplay Rules

## Authentic Arcade defaults

- One trigger press fires one shot.
- Six rounds per player; an empty magazine cannot fire.
- Firing outside the active 4:3 play area reloads. Mouse, keyboard/controller reload buttons are available as an accessibility equivalent.
- Enemy hit or civilian shot costs one life. The current reconstruction starts at three lives with a five-life ceiling; these defaults are centralized in `src/core/arcade_rule_set.gd` and mirrored by the playable runtime. A selectable operator-revision profile is not yet exposed.
- Players join independently but share camera, encounters, civilians, bosses and route state.

## Attack readability and damage gates

A player life can only be removed by one of two readable attack paths:

- Melee requires an on-screen actor, a completed telegraph and physical contact inside the actor's configured three-dimensional range. Matching only the X/Z position is insufficient; an attacker still above or below the player cannot hit. Losing visibility or contact cancels the pending telegraph.
- A projectile requires a visible, completed launch telegraph. The projectile must be destructible, become visible to the camera, remain visible at impact, travel its configured minimum visible distance and physically enter its contact radius. A fixed timer alone can never apply projectile damage.
A civilian rescue deadline never applies death directly. It can only accelerate an assigned living attacker, which must still become visible and complete melee contact or launch a visible, destructible projectile. Assigned attackers retain their civilian target; a projectile already in flight dissipates at its original target if that civilian is rescued, and cannot silently retarget a player.


Ordinary enemy telegraphs range from 0.55 to 0.90 seconds by archetype, with a 0.65-second default. Their melee contact ranges are 2.3 to 2.8 world units. Interceptable ordinary projectiles require at least 3.0 world units of visible travel and use a 1.35-unit contact radius. Canonical profile effects marked non-destructible, including Ebitan b's vomit burst and Burner's short flame jet, remain physical melee-pattern attacks in this runtime rather than becoming invisible projectiles.

Boss attacks use the same invariant:

- Chariot and Hangedman telegraph for 0.90 seconds, visibly lunge into the 2.8-unit melee-contact range, apply damage only at contact, then recover to their encounter position over 0.55 seconds.
- Hermit and Magician complete a visible telegraph before emitting an interceptable projectile. Hermit's web must visibly travel at least 4.0 world units; Magician's fireball at least 3.5. Both use physical contact resolution instead of a damage timer.
- If a boss becomes invisible before commit, the telegraph is cancelled and no damage is applied.

These gates govern damage readability only; they do not claim exact attack durations or distances from an authorized Sega reference build.

## Score ledger

| Event | Value |
|---|---:|
| scientist rescued | +400 |
| scientist killed by creature | −100 |
| scientist shot by player | −200 plus life loss |
| ordinary enemy destroyed | +80 |
| qualifying head impact | +120 |
| player hit | −100 plus life loss |
| medal | +200 |
| golden frog | +1,000 |
| Chariot, Hangedman, Hermit | +1,500 each |
| Magician | +2,500 |

`ScoreManager` exposes player, source and before/after values through its signal and is covered by deterministic tests. The current playable timeline applies the same values through its local `_add_score` path; wiring every live score mutation through `ScoreManager` remains an integration task and is not claimed as complete.

## Continues and endings

A continue restores three lives and a full magazine, consumes one credit and adds one score unit for revision-compatible ending encoding. Default arcade ending resolution:

1. score at least 62,000 → good/Special Agent ending;
2. otherwise score units digit equals zero → bad ending;
3. otherwise → normal ending.

The 60,000 PC observation is documented for comparison but is not exposed as a selectable runtime ruleset. The current implementation combines both local-player scores; whether that matches every target arcade revision remains provisional until an authorized reference build is measured.

## Boss invariants

- Chariot: armor opening first; progressive armor break; exposed-body phase.
- Hangedman: bat formation before body vulnerability; aerial charges; roof fall.
- Hermit: protected head; attack windows; destructible web projectile.
- Magician: only exposed tissue; rapid repositioning; destructible fireballs; final aerial phase.

Presentation ratio and accessibility settings do not intentionally change hit volumes, health, score or encounter timing.
