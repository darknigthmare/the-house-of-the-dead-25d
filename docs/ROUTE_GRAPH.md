# Route Graph

The public runtime uses `data/runtime/campaign_timeline.json`; the compact audit graphs in `data/routes/` are independently validated against it for matching start nodes, node IDs, edges, unique nodes and resolvable targets. Chapters 1–3 now use the active IDs `garden_rescue`, `sophie_antechamber`, `chain_plate`, `roof_rescue` and `back_attack_rescue`; no planning-only alias remains in those graphs.

The audit graphs retain descriptive condition names such as `scientist_saved`, `hatch_opened` and `all_scientists_saved`. The playable timeline resolves `next_success`/`next_failure` through `RouteOutcomePolicy`: rescue-only nodes use their civilian outcome, while a node containing a breakable succeeds only when that exact breakable ID was destroyed. The two representations now share topology, although their condition schemas remain intentionally different.

```text
CHAPTER 1 — TRAGEDY
garden rescue ─saved──> mansion entrance ─┐
              └failed─> under bridge ─────┴─> foyer choice
foyer ─lock/right──> upper stairs ─┐
       └timeout/left> ground hall ─┴─> Sophie antechamber ─> Sophie corridor ─> Chariot

CHAPTER 2 — REVENGE
chain plate ─destroyed> underground ─┐
            └ignored─> great doors ──┴─> library rescue
saved/high switch ─> raised bridge ─┐
failed/low route ──> lower stairs ──┴─> roof approach ─> roof rescue ─> Hangedman

CHAPTER 3 — TRUTH
elevator switch ─> left / right ─> rear-attack rescue
saved ─> security door/high bridge ─┐
failed > conduit/access key ────────┴─> Curien tunnel ─> Hermit

CHAPTER 4 — THE HOUSE OF THE DEAD
Chariot rematch ─> Hangedman rematch ─> bonus gate
all scientists ─> bonus room ─┐
otherwise ─────────────────────┴─> final waves ─> Curien ─> Magician ─> ending
```

The runtime records visited node IDs and campaign-wide rescue state. A node's evaluated outcome selects the next route; camera and route state are shared in co-op, while ammunition, lives, score, credits and continues remain per-player.

`branch_success` is no longer an ambiguous shared flag for breakable and civilian outcomes. `RouteOutcomePolicy.branch_succeeded()` requires the node's authored breakable asset to match `destroyed_breakable_id`, preventing a scientist rescue from opening a lock, hatch or elevator route. Deterministic tests cover the foyer lock, Chapter 2 chain plate, Chapter 3 elevator switch and a civilian-only rescue branch.

## Conditions

- `scientist_saved`: the scientist remains alive until the visible threat is resolved; the attacker is eliminated before a visible 3D melee contact or visible projectile impact, and the player did not shoot the scientist. The authored deadline may accelerate the threat, but it cannot kill the scientist by itself.
- `breakable_destroyed`: the corresponding 3D hit volume reaches zero health before node completion.
- `timeout`: no successful condition before the route window expires.
- `all_scientists_saved`: every tracked scientist in chapters 1–3 has a rescued state.
- `boss_defeated`: the boss controller completed every phase and reached zero health.

The editor-only inspection helper is isolated to `src/tools/debug_route_inspector.gd`; it is not instantiated by the public scene.
