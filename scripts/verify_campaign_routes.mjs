import fs from "node:fs";

const CAMPAIGN_PATH = "data/runtime/campaign_timeline.json";
const EXPECTED_SCIENTISTS = Object.freeze({
  chapter_01: 6,
  chapter_02: 6,
  chapter_03: 3,
  chapter_04: 0,
});
const REQUIRED_BOSS_NODES = Object.freeze({
  chapter_01: ["chariot_battle"],
  chapter_02: ["hangedman_battle"],
  chapter_03: ["hermit_battle"],
  chapter_04: ["chariot_rematch", "hangedman_rematch", "magician_battle"],
});
const MINIMUM_FIXED_SEQUENCE_SECONDS = Object.freeze({
  chapter_01: 90,
  chapter_02: 80,
  chapter_03: 75,
  chapter_04: 30,
});
const P0_ROUTE_DECISIONS = Object.freeze({
  chapter_01: [
    {
      id: "wall_passage_impact", kind: "enemy_impact",
      success: "wall_passage_high", failure: "wall_passage_fall",
    },
    {
      id: "painting_corridor_impact", kind: "enemy_impact",
      success: "painting_gallery_high", failure: "painting_floor_fall",
    },
  ],
  chapter_03: [
    {
      id: "steel_door_choice", kind: "target_choice",
      success: "steel_door_upper_route", failure: "steel_door_lower_route",
    },
  ],
});


const campaign = JSON.parse(fs.readFileSync(CAMPAIGN_PATH, "utf8"));
const sequencePolicy = campaign.sequence_policy ?? {};
let failed = false;

const fail = (message) => {
  console.error(`ERROR: ${message}`);
  failed = true;
};

if ((sequencePolicy.scene_duration_scale ?? 0) < 1.25) fail("sequence policy must materially extend short authored scenes");
if ((sequencePolicy.minimum_duration_ratio ?? 0) < 1) fail("sequence policy must gate completion through the full effective rail");
if ((sequencePolicy.post_clear_hold_seconds ?? 0) < 0.5) fail("sequence policy needs a readable post-clear hold");
if ((sequencePolicy.transition_seconds ?? 0) < 0.8) fail("ordinary transitions are too abrupt");
if ((sequencePolicy.branch_transition_seconds ?? 0) < (sequencePolicy.transition_seconds ?? 0)) fail("branch transitions must be at least as readable as ordinary transitions");
if (sequencePolicy.require_rail_complete !== true) fail("node completion must require the authored rail to finish");
if (!Array.isArray(sequencePolicy.rail_motion_keys) || sequencePolicy.rail_motion_keys.length < 4) fail("rail motion needs entry, combat hold and outro beats");

for (const chapter of campaign.chapters ?? []) {
  const expectedScientists = EXPECTED_SCIENTISTS[chapter.id];
  if (expectedScientists === undefined) {
    fail(`${chapter.id}: no expected scientist count configured`);
    continue;
  }
  if (chapter.rescues_expected !== expectedScientists) {
    fail(`${chapter.id}: rescues_expected=${chapter.rescues_expected}, expected ${expectedScientists}`);
  }

  const nodes = new Map((chapter.nodes ?? []).map((node) => [node.id, node]));
  if (nodes.size !== chapter.nodes.length) fail(`${chapter.id}: duplicate node id`);
  for (const spec of P0_ROUTE_DECISIONS[chapter.id] ?? []) {
    const decision = nodes.get(spec.id);
    if (!decision) {
      fail(`${chapter.id}: missing P0 physical route decision ${spec.id}`);
      continue;
    }
    checkP0Decision(decision, spec, chapter.id);
    if (spec.kind === "enemy_impact") {
      const sources = decision.route_condition?.accepted_sources ?? [];
      if (!sources.includes("enemy_melee") || !sources.includes("enemy_projectile")) {
        fail(`${chapter.id}/${spec.id}: fall trigger must accept only production enemy-contact sources`);
      }
      if (decision.route_condition?.success_when !== "avoided") {
        fail(`${chapter.id}/${spec.id}: high route must mean the enemy impact was avoided`);
      }
      const lowNode = nodes.get(spec.failure);
      const points = lowNode?.rail?.points ?? [];
      const heights = points.map((point) => Number(point?.position?.[1])).filter(Number.isFinite);
      if (heights.length < 3 || Math.max(...heights) - Math.min(...heights) < 0.55) {
        fail(`${chapter.id}/${spec.failure}: low route needs a visible authored camera fall`);
      }
    } else if (spec.kind === "target_choice") {
      const targets = decision.breakables ?? [];
      const ids = targets.map((target) => String(target.route_target ?? "")).sort();
      if (JSON.stringify(ids) !== JSON.stringify(["c03_steel_door_lower", "c03_steel_door_upper"])) {
        fail(`${chapter.id}/${spec.id}: two independent steel-door targets are required`);
      }
      if (!targets.every((target) => target.visual_prop === "mansion_double_door" && Number(target.health) === 1)) {
        fail(`${chapter.id}/${spec.id}: both steel doors must be visible one-shot world targets`);
      }
      if (!(targets.some((target) => Number(target.position?.[0]) < 0) && targets.some((target) => Number(target.position?.[0]) > 0))) {
        fail(`${chapter.id}/${spec.id}: steel doors must occupy visibly distinct sides`);
      }
      if (decision.route_condition?.requires_resolution !== true || (decision.spawns ?? []).length !== 0) {
        fail(`${chapter.id}/${spec.id}: door chamber must wait for a physical choice without a hidden combat timeout`);
      }
    }
  }


  for (const node of chapter.nodes) {
    if (node.type === "boss" && node.civilian) {
      fail(`${chapter.id}/${node.id}: civilian placed in a boss node`);
    }
    if (node.civilian && !(node.spawns ?? []).some((spawn) => spawn.targets_civilian === true)) {
      fail(`${chapter.id}/${node.id}: civilian has no explicitly targeted attacker`);
    }
  }

  const routes = [];
  const globallyVisited = new Set();
  const visit = (nodeId, path, scientistCount, fixedSecondsExcludingBoss) => {
    if (nodeId === "chapter_complete") {
      routes.push({ path, scientistCount, fixedSecondsExcludingBoss });
      return;
    }
    const node = nodes.get(nodeId);
    if (!node) {
      fail(`${chapter.id}: missing node ${nodeId}`);
      return;
    }
    if (path.includes(nodeId)) {
      fail(`${chapter.id}: cycle ${[...path, nodeId].join(" -> ")}`);
      return;
    }

    globallyVisited.add(nodeId);
    const nextPath = [...path, nodeId];
    const nextCount = scientistCount + (node.civilian ? 1 : 0);
    const nodeDuration = Number(node.duration ?? 0);
    if (!Number.isFinite(nodeDuration) || nodeDuration < 4) fail(`${chapter.id}/${node.id}: authored duration is too short`);
    // Boss fights are health/phase driven at runtime, so their JSON duration is
    // not a deterministic floor. Only mandatory rail and connector time belongs here.
    const runtimeDuration = node.type === "boss" ? 0 : nodeDuration * Number(sequencePolicy.scene_duration_scale ?? 1);
    const spawns = node.spawns ?? [];
    for (let spawnIndex = 1; spawnIndex < spawns.length; spawnIndex += 1) {
      if (Number(spawns[spawnIndex].delay ?? 0) < Number(spawns[spawnIndex - 1].delay ?? 0)) {
        fail(`${chapter.id}/${node.id}: spawn delays are not chronological`);
      }
    }
    const exits = [...new Set([node.next, node.next_success, node.next_failure].filter(Boolean))];
    if (exits.length === 0) {
      fail(`${chapter.id}/${node.id}: route cannot reach chapter_complete`);
      return;
    }
    for (const exit of exits) {
      const transitionDuration = exit === "chapter_complete"
        ? 0
        : node.next_success
          ? Number(sequencePolicy.branch_transition_seconds ?? 0)
          : Number(sequencePolicy.transition_seconds ?? 0);
      visit(exit, nextPath, nextCount, fixedSecondsExcludingBoss + runtimeDuration + transitionDuration);
    }
  };

  visit(chapter.start, [], 0, 0);
  if (routes.length === 0) fail(`${chapter.id}: no complete playable route`);

  const requiredBossNodes = REQUIRED_BOSS_NODES[chapter.id] ?? [];
  for (const route of routes) {
    if (route.scientistCount !== expectedScientists) {
      fail(`${chapter.id}: route has ${route.scientistCount} scientists, expected ${expectedScientists}: ${route.path.join(" -> ")}`);
    }
    const reachesExpectedBoss = route.path.some((nodeId) => {
      const node = nodes.get(nodeId);
      return node?.type === "boss" && node.boss === chapter.boss;
    });
    if (!reachesExpectedBoss) {
      fail(`${chapter.id}: route does not reach expected boss ${chapter.boss}: ${route.path.join(" -> ")}`);
    }
    for (const bossNodeId of requiredBossNodes) {
      if (!route.path.includes(bossNodeId)) {
        fail(`${chapter.id}: route misses required boss node ${bossNodeId}: ${route.path.join(" -> ")}`);
      }
    }
  }

  for (const nodeId of nodes.keys()) {
    if (!globallyVisited.has(nodeId)) fail(`${chapter.id}: unreachable node ${nodeId}`);
  }

  const counts = routes.map((route) => route.scientistCount);
  const minimum = counts.length ? Math.min(...counts) : 0;
  const maximum = counts.length ? Math.max(...counts) : 0;
  const routeSeconds = routes.map((route) => route.fixedSecondsExcludingBoss);
  const minimumRouteSeconds = routeSeconds.length ? Math.min(...routeSeconds) : 0;
  const minimumRequiredSeconds = MINIMUM_FIXED_SEQUENCE_SECONDS[chapter.id] ?? 30;
  if (minimumRouteSeconds < minimumRequiredSeconds) fail(`${chapter.id}: mandatory non-boss rails remain structurally too short (${minimumRouteSeconds.toFixed(1)}s)`);
  console.log(
    `${chapter.id}: paths=${routes.length} scientists min=${minimum} max=${maximum} ` +
      `fixed_runtime_min_excluding_boss=${minimumRouteSeconds.toFixed(1)}s bosses_dynamic=${requiredBossNodes.join(",")}`,
  );
}

function checkP0Decision(decision, spec, chapterId) {
  if (decision.next_success !== spec.success || decision.next_failure !== spec.failure) {
    fail(`${chapterId}/${spec.id}: P0 route outputs do not match their authored high/low scenes`);
  }
  if (decision.route_condition?.kind !== spec.kind) {
    fail(`${chapterId}/${spec.id}: expected route condition ${spec.kind}`);
  }
  if (decision.provisional_reference !== true || decision.route_condition?.provisional !== true) {
    fail(`${chapterId}/${spec.id}: unverified arcade timing/placement must remain marked provisional`);
  }
}

if (failed) {
  process.exitCode = 1;
} else {
  console.log("Campaign route verification passed.");
}
