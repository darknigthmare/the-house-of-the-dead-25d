# Route Graph

The public runtime uses `data/runtime/campaign_timeline.json`; the compact audit graphs in `data/routes/` are independently validated for unique nodes and resolvable targets.

The audit graphs retain descriptive condition names such as `scientist_saved`, `hatch_opened` and `all_scientists_saved`. The playable timeline currently reduces per-node outcomes to `branch_success` and resolves `next_success`/`next_failure`; the two representations share route topology but are not the same runtime schema.

```text
CHAPTER 1 — TRAGEDY
garden rescue ─saved──> mansion entrance ─┐
              └failed─> under bridge ─────┴─> foyer choice
foyer ─lock/right──> upper stairs ─┐
       └timeout/left> ground hall ─┴─> Sophie ─> Chariot

CHAPTER 2 — REVENGE
chain hatch ─destroyed> underground ─┐
            └ignored─> great doors ──┴─> library rescue
saved/high switch ─> raised bridge ─┐
failed/low route ──> lower stairs ──┴─> roof ─> Hangedman

CHAPTER 3 — TRUTH
elevator switch ─> left / right ─> rear-attack rescue
saved ─> security door/high bridge ─┐
failed > conduit/access key ────────┴─> Curien tunnel ─> Hermit

CHAPTER 4 — THE HOUSE OF THE DEAD
Chariot rematch ─> Hangedman rematch ─> bonus gate
all scientists ─> bonus room ─┐
otherwise ─────────────────────┴─> final waves ─> Curien ─> Magician ─> ending
```

The runtime records visited node IDs and campaign-wide rescue state. A node's current success/failure outcome selects the next route; camera and route state are shared in co-op, while ammunition, lives, score, credits and continues remain per-player.

## Conditions

- `scientist_saved`: attacker is eliminated before the entity deadline and the player did not shoot the scientist.
- `breakable_destroyed`: the corresponding 3D hit volume reaches zero health before node completion.
- `timeout`: no successful condition before the route window expires.
- `all_scientists_saved`: every tracked scientist in chapters 1–3 has a rescued state.
- `boss_defeated`: the boss controller completed every phase and reached zero health.

The editor-only inspection helper is isolated to `src/tools/debug_route_inspector.gd`; it is not instantiated by the public scene.
