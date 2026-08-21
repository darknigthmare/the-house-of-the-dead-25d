# Gameplay Rules

## Authentic Arcade defaults

- One trigger press fires one shot.
- Six rounds per player; an empty magazine cannot fire.
- Firing outside the active 4:3 play area reloads. Mouse, keyboard/controller reload buttons are available as an accessibility equivalent.
- Enemy hit or civilian shot costs one life. The current reconstruction starts at three lives with a five-life ceiling; these defaults are centralized in `src/core/arcade_rule_set.gd` and mirrored by the playable runtime. A selectable operator-revision profile is not yet exposed.
- Players join independently but share camera, encounters, civilians, bosses and route state.

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
